--[[
	Fire Mod
	
	This Addition will burn houses as soon they drop below 40% hp and will then
	start to burn down.
	Once it reaches 30% hp it will once try to inflict nearby buildings which will slowly start burning.
	The lower the hp drops the faster the fire will destroy the building.
	
	This can be prevented by:
	- Rain
	- nearby fountains
	
	Also if serfs repair a building and it does regain 50% of its health, it stops burn
	
	-- todo:
	ausbreitung soll nicht gleichzeitig mehrere Gebäude angreifen - aus breitung bei einem brennden gebäude alle x sek 1 mal
	ein Gebäude droppt nicht auf 50 hp nachdem es angezündet wird
	damage schneller machen und gleichmäßig
	damage und ausbreitung mit spiel dauer skalieren - anfangs schwach, später stark
	kontrollieren ob ein gebäude gehealed wird
	
]]
 FireMod = {}

function  FireMod.Init()
	--Message("FireMod Activated");
	
	-- config
	FireMod.Config = {
		InflictBuildingOnAttackThreshold = 0.4; -- at 40% hp building starts burn
		InflictOthersBuildingsOnBurnThreshold = 0.3; -- at 30% hp it starts inflicting surrounding buildings
		StopBurnThreshold = 0.5; -- musst be >= InflictThreshold - stops burning at 50% hp when getting repaired
		InflictBuildingsRange = 2000; -- range in scm, in which closeby buildings are inflicted by fire
		BaseDamagePerTick = 10;
		DamageMissingHealthPerTick = 0.01; -- 0.01 = 1% of missing health per damage tick
		ChanceBurningBuildingInflictsOthers = 10; -- chance to inflict another building on each damage tick => 10 => chance < 10%
		FountainSaveBuildingsRange = 4000;
	};
	
	-- add any entity type which should be excluded from beeing burned
	FireMod.InvincibleBuildings = {
	};
	
	FireMod.BurningBuildings = {};
	for playerId = 1, XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()	 do
		FireMod.BurningBuildings[playerId] = {};
	end
	
	-- don't trigger every single attack
	FireMod.CheckRecentlyAttackedBuildingsJobId = -1;
	FireMod.RecentlyAttackedBuildings = {};
	-- stops recently attacked buildings job
	FireMod.IdleCounter = 0;
	
	
	-- Fountains simply protect surrounding buildings
	FireMod.SaveBuildings = {};
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "FireMod_Condition_FountainOrBuildingCreated", "FireMod_Action_FountainOrBuildingCreated", 1);
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "FireMod_Condition_FountainOrBuildingDestroyed", "FireMod_Action_FountainOrBuildingDestroyed", 1);
	FireMod.GameCallback_OnBuildingConstructionComplete = GameCallback_OnBuildingConstructionComplete;
	GameCallback_OnBuildingConstructionComplete = function(_entity, _playerId)
		local eType = Logic.GetEntityType(_entity);
		local pos = {Logic.GetEntityPosition(_entity)};
		if eType == Entities.PB_Beautification02 or eType == Entities.PB_Beautification08 then
			for eID in S5Hook.EntityIterator(Predicate.InCircle(pos[1], pos[2],  FireMod.Config.FountainSaveBuildingsRange), Predicate.IsBuilding()) do
				-- make sure its not a construction site
				if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(eID)), "PB", 1, true) then
					if  FireMod.SaveBuildings[eID] then
						table.insert( FireMod.SaveBuildings[eID], _entity);
					else
						 FireMod.SaveBuildings[eID] = {_entity};
					end
				end
			end
		end
		 FireMod.GameCallback_OnBuildingConstructionComplete(_entity, _playerId);
	end
	function ViewX()
		local pos;
		for k,v in pairs( FireMod.SaveBuildings) do
			pos = {Logic.GetEntityPosition(k)};
			Logic.CreateEffect(GGL_Effects.FXDarioFear,pos[1],pos[2],3); 
		end
	end
	StartSimpleJob("ViewX");
	
	-- setup OSI
	 FireMod.BurnIcon = S5Hook.OSILoadImage("graphics\\textures\\gui\\fire");
     FireMod.BurnIconSize = {S5Hook.OSIGetImageSize( FireMod.BurnIcon)};
	 FireMod.BurnIconDisabled = S5Hook.OSILoadImage("graphics\\textures\\gui\\fire_disabled");
	 FireMod.BurnIconDisabledSize = {S5Hook.OSIGetImageSize( FireMod.BurnIconDisabled)};
	
	 FireMod.EntityHurtTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "FireMod_Action_EntityHurt", 1);
end

function  FireMod_Action_EntityHurt()
	-- Id of target entity
	local eId = Event.GetEntityID2();
	if Logic.IsBuilding(eId) == 0 then
		return false;
	end
	if Logic.IsConstructionComplete() == 0 then
		-- don't ignite unfinished buildings
		return false;
	end
	if  FireMod.InvincibleBuildings[Logic.GetEntityType(eId)] then
		-- building type not allowed
		return false;
	end
	-- to prevent controlling conditions on each single attack,
	-- attacks are gathered and checked all together
	 FireMod.RecentlyAttackedBuildings[eId] = 0;
	if JobIsRunning( FireMod.CheckRecentlyAttackedBuildingsJobId) == 0 then
		FireMod.CheckRecentlyAttackedBuildingsJobId = StartSimpleJob("FireMod_CheckRecentlyAttackedBuildings");
	end
end
function  FireMod_CheckRecentlyAttackedBuildings()
	if Logic.GetWeatherState() == 2 then
		return;
	end
	local entries = 0;
	local HP = 0;

	for eId,v in pairs( FireMod.RecentlyAttackedBuildings) do
		entries = entries + 1;
		if Logic.GetWeatherState() ~= 2
		and not  FireMod.InvincibleBuildings[Logic.GetEntityType(eId)]
		and not  FireMod.BurningBuildings[Logic.EntityGetPlayer(eId)][eId]
		and not  FireMod.SaveBuildings[eId] then
			HP = Logic.GetEntityHealth(eId)/Logic.GetEntityMaxHealth(eId);
			if HP <=  FireMod.Config.InflictBuildingOnAttackThreshold then
				 FireMod.BurningBuildings[Logic.EntityGetPlayer(eId)][eId] = {InflictedOthers = false; HPAfterLastDamage = HP;};
				if JobIsRunning( FireMod.ControlJob) == 0 then
					 FireMod.OSITriggerId = OSI.AddDrawTrigger( FireMod.OSITrigger)
					Message("Start BURNING");
					 FireMod.ControlJob = StartSimpleJob("FireMod_ControlJob_BurnBuildings");
				end
			end
		else
			-- remove building from list - conditions not fullfilled
			 FireMod.RecentlyAttackedBuildings[eId] = nil;
		end
	end
	if entries > 0 then
		 FireMod.IdleCounter = 0;
	else
		 FireMod.IdleCounter =  FireMod.IdleCounter + 1;
		if  FireMod.IdleCounter > 5 then
			-- no buildings checked the last 5 seconds
			 FireMod.IdleCounter = 0;
			return true;
		end
	end
end

--[[
function  _FireMod_Condition_InflictBuilding()
	local target = Event.GetEntityID2();
	if Logic.IsBuilding(target) == 0 then
		-- only inflicht buildings
		return false;
	end
	if Logic.IsConstructionComplete() == 0 then
		-- don't ignite unfinished buildings
		return false;
	end
	if Logic.GetWeatherState() == 2 then
		-- dont ignite buildings while rain
		return false;
	end
	if  FireMod.InvincibleBuildings[Logic.GetEntityType(target)] then
		-- building type not allowed to burn
		return false;
	end
	if  FireMod.BurningBuildings[GetPlayer(target)][target] then
		-- building burns already
		return false;
	end
	if  FireMod.SaveBuildings[target] then
		-- is protected by a fountain from burning
		return false;
	end
	if Logic.GetEntityHealth(target)/Logic.GetEntityMaxHealth(target) >  FireMod.Config.InflictBuildingOnAttackThreshold then
		return false;
	end
	return true;
end

function  _FireMod_Action_InflictBuilding()
	local target = Event.GetEntityID2();
	 FireMod.BurningBuildings[GetPlayer(target)][target] = {InflictedOthers = false;};
	if JobIsRunning( FireMod.ControlJob) == 0 then
		 FireMod.OSITriggerId = OSI.AddDrawTrigger( FireMod.OSITrigger)
		 FireMod.ControlJob = StartSimpleJob(" _FireMod_ControlJob_BurnBuildings");
	end
end ]]

function  FireMod_Condition_FountainOrBuildingCreated()
	local entity = Event.GetEntityID();
	if Logic.IsBuilding(entity) == 1 and Logic.IsConstructionComplete(entity) == 0 then
		return true;
	end
	return false;
end

function  FireMod_Action_FountainOrBuildingCreated()
	local entity = Event.GetEntityID();
	local eType = Logic.GetEntityType(entity);
	local pos = {Logic.GetEntityPosition(entity)};

	-- check if nearby fountains can protect building - even for fountains
	local foundFountain = {};
	for eID in S5Hook.EntityIterator(Predicate.InCircle(pos[1], pos[2],  FireMod.Config.FountainSaveBuildingsRange), Predicate.IsBuilding(), Predicate.OfType(Entities.PB_Beautification02)) do
		if Logic.IsConstructionComplete(eID) == 1 then
			table.insert(foundFountain, eID);
		end
	end
	for eID in S5Hook.EntityIterator(Predicate.InCircle(pos[1], pos[2],  FireMod.Config.FountainSaveBuildingsRange), Predicate.IsBuilding(), Predicate.OfType(Entities.PB_Beautification08)) do
		if Logic.IsConstructionComplete(eID) == 1 then
			table.insert(foundFountain, eID);
		end
	end
	if table.getn(foundFountain) > 0 then
		 FireMod.SaveBuildings[entity] = foundFountain;
	end

end

function  FireMod_Condition_FountainOrBuildingDestroyed()
	local entity = Event.GetEntityID();
	if Logic.IsBuilding(entity) == 1 then
		return true;
	end
end

function  FireMod_Action_FountainOrBuildingDestroyed()
	local entity = Event.GetEntityID();
	local eType = Logic.GetEntityType(entity);
	local pos = {Logic.GetEntityPosition(entity)};
	local tsize;
	if eType == Entities.PB_Beautification02 or eType == Entities.PB_Beautification08 then
		-- its a fountain -> check if nearby buildings get vulernable to fire
		for eID in S5Hook.EntityIterator(Predicate.InCircle(pos[1], pos[2],  FireMod.Config.FountainSaveBuildingsRange), Predicate.IsBuilding()) do
			if  FireMod.SaveBuildings[eID] then
				tsize = table.getn( FireMod.SaveBuildings[eID]);
				if tsize == 1 then
					 FireMod.SaveBuildings[eID] = nil;
				else
					for i = 1, tsize do
						if  FireMod.SaveBuildings[eID][i] == entity then
							table.remove( FireMod.SaveBuildings[eID], i);
						end
					end
				end
			end
		end
	else
	-- its a building - remove it from save list
		 FireMod.SaveBuildings[entity] = nil;
	end
end

function  FireMod_ControlJob_BurnBuildings()
	local HP;
	if Logic.GetWeatherState() == 2 then
		for playerId = 1, MaxPlayers do
			 FireMod.BurningBuildings[playerId] = {};
		end
		OSI.RemoveDrawTrigger( FireMod.OSITriggerId);
		Trigger.UnrequestTrigger( FireMod.ControlJob);
		return true;
	end
	local count = 0;
	for playerId = 1, MaxPlayers do
		for buildingId, t in pairs( FireMod.BurningBuildings[playerId]) do
			count = count + 1;
			HP = Logic.GetEntityHealth(buildingId)/Logic.GetEntityMaxHealth(buildingId);
			if HP <  FireMod.Config.InflictBuildingOnAttackThreshold or HP <= t.HPAfterLastDamage then
				 FireMod.DamageBuilding(buildingId, HP);
			else
				-- building gets repaired and HP > Threshold
				 FireMod.BurningBuildings[playerId][buildingId] = nil;
			end
		end
	end
	if count == 0 then
		OSI.RemoveDrawTrigger( FireMod.OSITriggerId);
		Trigger.UnrequestTrigger( FireMod.ControlJob);
		return true;
	end
end

function  FireMod.TryInflictBuildingsInArea(_buildingId)
	local pos = {Logic.GetEntityPosition(_buildingId)};
	local buildingMaxHealth, buildingHealth, HP;
	local chance;
	for eID in S5Hook.EntityIterator(Predicate.InCircle(pos[1], pos[2],  FireMod.Config.InflictBuildingsRange), Predicate.IsBuilding()) do
		if Logic.IsConstructionComplete(eID) == 1 and eID ~= _buildingId and not  FireMod.SaveBuildings[eID] and
			string.find(Logic.GetEntityTypeName(Logic.GetEntityType(eID)), "PB", 1, true) then
			-- chance to inflict building is 10% - dont inflict all of them at the same time
			chance = math.random(1,100);
			if chance <= 10 then
				-- inflict a building with burn -> health less 50%
				buildingHealth = Logic.GetEntityHealth(eID);
				buildingMaxHealth = Logic.GetEntityMaxHealth(eID);
				HP = buildingHealth/buildingMaxHealth;
				if HP >= 0.5 then
					--Logic.HurtEntity(eID, buildingHealth - (buildingMaxHealth/2) + 1);
				end
				 FireMod.BurningBuildings[Logic.EntityGetPlayer(eID)][eID] = {InflictedOthers = false; HPAfterLastDamage = HP;};
			end
		end
	end
end

function  FireMod.DamageBuilding(_buildingId, _HPInPercent)
	local buildingHealth = Logic.GetEntityHealth(_buildingId);
	local buildingMaxHealth = Logic.GetEntityMaxHealth(_buildingId);
	
	-- building inflicts only once -> check if inflicted already and hp below threshold
	if _HPInPercent <  FireMod.Config.InflictOthersBuildingsOnBurnThreshold then
		-- chance in percentage to inflict is given in config
		local inflictOtherBuilding = math.random(1, 100);
		if inflictOtherBuilding <  FireMod.Config.ChanceBurningBuildingInflictsOthers then
			 FireMod.TryInflictBuildingsInArea(_buildingId);
		end
	end
	
	-- Damage: 1% of missing health per Tick
	local damage = math.random(1, FireMod.Config.BaseDamagePerTick) +  FireMod.Config.DamageMissingHealthPerTick * (buildingMaxHealth - buildingHealth);
	--log("Burn building ".._buildingId.." with " .. damage .. " damage! MaxHealth("..buildingMaxHealth..")".." Health("..buildingHealth..")");
	if damage < 0 then
		damage = 0;
	end
	Logic.HurtEntity(_buildingId, damage);
	-- update new hp percentage
	 FireMod.BurningBuildings[Logic.EntityGetPlayer(_buildingId)][_buildingId].HPAfterLastDamage = buildingHealth/buildingMaxHealth;
end

function  FireMod.OSITrigger(_eID, _active, _x, _y)
	local player = Logic.EntityGetPlayer(_eID);
	if not  FireMod.BurningBuildings[player] then
		return;
	end
	if not  FireMod.BurningBuildings[player][_eID] then
		return;
	end
	LuaDebugger.Log("ShowBurnIcon on " .. _eID);
	local offsetX = 0;
	local offsetY = 0;
	if _active then
		offsetX = -30;
	end
	if Logic.GetWeatherState() == 2 then
		S5Hook.OSIDrawImage( FireMod.BurnIconDisabled, _x+offsetX, _y+offsetY, 32, 32);
	else
		S5Hook.OSIDrawImage( FireMod.BurnIcon, _x+offsetX, _y+offsetY, 32, 32);
	end
end




