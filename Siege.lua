Siege = {AttackerIDs = {}, DefenderIDs = {}, TrapPositions = {}, TrapActivationRange = 300, TrapDamage = 100, TrapDamageRange = 800,
		PitchFieldPositions = {}, PitchFieldDefaultPlayer = 8, PitchFieldEnemyTreshold = 10, PitchFieldActivationRange = 500, PitchFieldAlreadyTargetted = {},
		PitchBurnerRange = 500, PitchBurnerEnemyTreshold = 1, PitchBurnerRefillDelay = 30 * (gvDiffLVL or 1), PitchBurnerVatEmpty = {},
		PitchBurningDuration = 20, PitchBurningDamage = 50, PitchBurningRange = 800, PitchBurningDamageFactorToHeroes = 5, PitchBurningDamageFactorToVehicles = 4, PitchBurningDamageFactorToUnderlings = 3,
		FireEffectCasted = {},
		TriggerIDs = {},
		CreateTraps = function(_player, _x, _y, _range, _amount, _spacing)
			local t = CreateEntitiesInRectangle(Entities.XD_TrapHole1, _amount, _player, _x - _range, _x + _range, _y - _range, _y + _range, _spacing, "TrapHole")
			for i in t do
				table.insert(Siege.TrapPositions, t[i])
			end
			if not Siege.TriggerIDs.TrapControl then
				Siege.TriggerIDs.TrapControl = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_TrapControl", 1)
			end
		end,
		CreatePitchFields = function(_x, _y, _range, _length, _amount)
			for i = 1, table.getn(Siege.AttackerIDs) do
				Logic.SetDiplomacyState(Siege.AttackerIDs[i], Siege.PitchFieldDefaultPlayer, Diplomacy.Hostile)
			end
			local t = CreateEntityTrailsInRectangle(Entities.XD_Pitch, _amount, Siege.PitchFieldDefaultPlayer, _x - _range, _x + _range, _y - _range, _y + _range, _length, 200, 800, "PitchField")
			for i in t do
				table.insert(Siege.PitchFieldPositions, t[i])
			end
			if not Siege.TriggerIDs.PitchFieldControl then
				Siege.TriggerIDs.PitchFieldControl = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchFieldsControl", 1)
			end
		end,
		PitchBurnerInit = function()
			Siege.PitchBurners = Siege.PitchBurners or {}
			for eID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PU_PitchBurner), CEntityIterator.OfAnyPlayerFilter(unpack(Siege.DefenderIDs))) do
				table.insert(Siege.PitchBurners, eID)
				Siege.PitchBurnerVatEmpty[eID] = false
				Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchBurnerControl", 1, {}, {eID})
			end
		end,
		FireEffectOffsets = {{X = 0, Y = 0},
							{X = 300, Y = 0},
							{X = 300, Y = 300},
							{X = 0, Y = 300},
							{X = 600, Y = 0},
							{X = 600, Y = 300},
							{X = 600, Y = 600},
							{X = 0, Y = 600},
							{X = 300, Y = 600},
							{X = -300, Y = 0},
							{X = -300, Y = -300},
							{X = 0, Y = -300},
							{X = -600, Y = 0},
							{X = -600, Y = -300},
							{X = -600, Y = -600},
							{X = 0, Y = -600},
							{X = -300, Y = -600}},
		SearchForNearestBowman = function(_x, _y)
			for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(Siege.DefenderIDs)), CEntityIterator.OfCategoryFilter(EntityCategories.Bow)) do
				if Logic.IsLeader(eID) == 1 then
					local pos = GetPosition(eID)
					local range = GetEntityTypeMaxAttackRange(eID, Logic.EntityGetPlayer(eID))
					if GetDistance(pos, {X = _x, Y = _y}) <= range then
						return eID
					end
				end
			end
		end,
		Init = function()
			CMod.PushArchive("Balancing_Stuff_in_Dev\\music.bba")
			Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\localmusic_siege.lua")
			if not Siege.PitchBurners then
				Siege.PitchBurnerInit()
			end
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,"", "Siege_NoDamageToWallsAndGates", 1)
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,"", "Siege_EntityBurnedToDeathSounds", 1)
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,"", "Siege_TrapCalculateDamage", 1)
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED,"", "Siege_GateDestroyedControl", 1)
			if gvChallengeFlag then
				Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED,"", "Siege_EntityCreated", 1)
			end
		end,
		RamSounds = {Move = "Engineer_MRam", Select = "Engineer_SRam", Attack = {"Engineer_Ram1", "Engineer_AtkS1", "Engineer_AtkS2", "Engineer_AtkS3", "Engineer_AtkS4", "Engineer_AtkW1"}},
		DropOilSounds = {"Engineer_PourOil1", "Engineer_PourOil2", "Engineer_PourOil3", "Engineer_PourOil4", "Engineer_PourOil5", "Engineer_PourOil6", "Engineer_PourOil7", "Engineer_PourOil8", "Engineer_PourOil9"},
		BurnedToDeathSounds = {"Burn1", "Burn2", "Burn3", "Burn4", "Burn5", "Burn6", "Burn7", "Burn8", "Burn9", "Burn10"},
		DefeatSounds = {"Wf_Vict_01", "Wf_Vict_02", "Wf_Vict_03", "Wf_Vict_04"},
		VictorySounds = {"General_Victory1", "General_Victory2", "General_Victory3", "General_Victory4", "General_Victory5"}
		}

Siege_TrapControl = function()
	local max = table.getn(Siege.TrapPositions)
	for i = 1, max do
		if i <= max then
			local X, Y = Siege.TrapPositions[i].X, Siege.TrapPositions[i].Y
			local id = Logic.GetEntityAtPosition(X, Y)
			for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(Siege.AttackerIDs)),
			CEntityIterator.InCircleFilter(X, Y, Siege.TrapActivationRange),
			CEntityIterator.IsSettlerOrBuildingFilter()) do
				CEntity.DealDamageInArea(id, X, Y, Siege.TrapDamageRange, Siege.TrapDamage)
				ReplaceEntity(id, Entities.XD_TrapHole2)
				table.remove(Siege.TrapPositions, i)
				max = max - 1
				break
			end
		end
	end
	if not next(Siege.TrapPositions) then
		return true
	end
end
Siege_TrapCalculateDamage = function()
	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)
	if attype == Entities.XD_TrapHole1 then
		local target = Event.GetEntityID2()
		-- damage to heroes much higher
		if Logic.IsHero(target) == 1 then
			CEntity.TriggerSetDamage(round(CEntity.TriggerGetDamage() * Siege.PitchBurningDamageFactorToHeroes / (gvDiffLVL or 1)))
		end
		-- damage to cannons, catapults and rams also increased, but not as much as heroes
		if Logic.IsEntityInCategory(target, EntityCategories.Cannon) == 1 then
			CEntity.TriggerSetDamage(round(CEntity.TriggerGetDamage() * Siege.PitchBurningDamageFactorToVehicles / (gvDiffLVL or 1)))
		end
		-- damage to summoned entities, such as ari bandits, much higher
		if IsHeroSummonedEntity(target) then
			CEntity.TriggerSetDamage(round(CEntity.TriggerGetDamage() * Siege.PitchBurningDamageFactorToUnderlings / (gvDiffLVL or 1)))
		end
	end
end
Siege_NoDamageToWallsAndGates = function()
	local target = Event.GetEntityID2()
	if Logic.IsEntityInCategory(target, EntityCategories.Wall) == 1 or Logic.IsEntityInCategory(target, EntityCategories.Bridge) == 1 then
		local attacker = Event.GetEntityID1()
		if Logic.IsEntityInCategory(attacker, EntityCategories.Cannon) ~= 1 or Logic.GetEntityType(target) ~= Entities.XD_OSO_Wall_Gate_Slim_Closed2 then
			CEntity.TriggerSetDamage(0)
		end
	end
end
Siege_GateDestroyedControl = function()
	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.XD_OSO_Wall_Gate_Slim_Closed2 then
		local posX, posY = Logic.GetEntityPosition(entityID)
		local degree = Logic.GetEntityOrientation(entityID)
		for i = 1, table.getn(Siege.FireEffectOffsets) do
			Logic.CreateEffect(GGL_Effects.FXCrushBuildingLarge,
			posX + Siege.FireEffectOffsets[i].X + GenerateRandomWithSteps(-50, 50, 10),
			posY + Siege.FireEffectOffsets[i].Y + GenerateRandomWithSteps(-50, 50, 10))
		end
		Logic.CreateEntity(Entities.XD_Wall_Gate_Ruin, posX, posY, degree, 0)
		Sound.PlayGUISound(Sounds.Stronghold_General_Gatehouse, 152)
		return Logic.GetNumberOfEntitiesOfType(Entities.XD_OSO_Wall_Gate_Slim_Closed2) ~= 0
	end
end
Siege_EntityBurnedToDeathSounds = function()
	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)
	if attype == Entities.XD_Pitch or attype == Entities.PU_PitchBurner then
		local target = Event.GetEntityID2()
		local damage = CEntity.TriggerGetDamage()
		local health = Logic.GetEntityHealth(target)
		if damage >= health then
			Siege_BurnedToDeathSound = Siege_BurnedToDeathSound or {}
			if not Siege_BurnedToDeathSound[GUI.GetPlayerID()] then
				local x, y = Camera.ScrollGetLookAt()
				if GetDistance({X = x, Y = y}, GetPosition(target)) <= 5000 then
					Siege_BurnedToDeathSound[GUI.GetPlayerID()] = true
					Sound.PlayGUISound(Sounds["Military_".. Siege.BurnedToDeathSounds[1+XGUIEng.GetRandom(table.getn(Siege.BurnedToDeathSounds)-1)]], 152)
					StartCountdown(6, function() Siege_BurnedToDeathSound[GUI.GetPlayerID()] = false end, false)
				end
			end
		end
	end
end
Siege_EntityCreated = function()
	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.XD_TrapHole1 or entityType == Entities.XD_Pitch then
		local playerID = Logic.EntityGetPlayer(entityID)
		local PIDs = BS.GetAllEnemyPlayerIDs(playerID)
		for i = 1, table.getn(PIDs) do
			if PIDs[i] == GUI.GetPlayerID() then
				SetEntityVisibility(entityID, 0)
			end
		end
	end
end
Siege_PitchFieldsControl = function()
	for i = 1, table.getn(Siege.PitchFieldPositions) do
		if not Siege.PitchFieldAlreadyTargetted[i] then
			local centerindex = math.floor(table.getn(Siege.PitchFieldPositions[i])/2)
			local num = GetNumberOfPlayerUnitsInRange(Siege.AttackerIDs, Siege.PitchFieldPositions[i][centerindex], Siege.PitchFieldActivationRange)
			if num >= Siege.PitchFieldEnemyTreshold then
				local id = Siege.SearchForNearestBowman(Siege.PitchFieldPositions[i][centerindex].X, Siege.PitchFieldPositions[i][centerindex].Y)
				if id then
					local posX, posY = Logic.GetEntityPosition(id)
					local posX2, posY2 = Siege.PitchFieldPositions[i][centerindex].X, Siege.PitchFieldPositions[i][centerindex].Y
					local target = Logic.GetEntityAtPosition(posX2, posY2)
					local projectile = CUtil.CreateProjectile(GGL_Effects.FXHero14_Arrow, posX, posY, posX2, posY2, 0, 0, target, id, Logic.EntityGetPlayer(id))
					if not Siege_ArcherLightOilSound then
						Sound.PlayGUISound(Sounds.Stronghold_Arch_Light_Pitch1, 152)
						Siege_ArcherLightOilSound = true
						StartCountdown(5, function() Siege_ArcherLightOilSound = false end, false)
					end
					Siege.PitchFieldAlreadyTargetted[i] = true
					Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,"", "Siege_PitchFieldHitControl", 1, {}, {projectile, target, i})
				end
			end
		end
	end
end
Siege_PitchFieldHitControl = function(_projectile, _id, _index)
	if not CUtil.DoesEffectExist(_projectile) then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchFieldApplyDamage", 1, {}, {_id, _index})
		return true
	end
end
Siege_PitchFieldApplyDamage = function(_id, _index)
	if not Counter.Tick2("Siege_PitchFieldApplyDamage_" .. _index, Siege.PitchBurningDuration) then
		Siege.FireEffectCasted[_index] = Siege.FireEffectCasted[_index] or {}
		for i = 1, table.getn(Siege.PitchFieldPositions[_index]) do
			local X, Y = Siege.PitchFieldPositions[_index][i].X, Siege.PitchFieldPositions[_index][i].Y
			if not Siege.FireEffectCasted[_index][i] then
				for i = 1, table.getn(Siege.FireEffectOffsets) do
					Logic.CreateEffect(CatapultStoneOnHitEffects[math.random(1,4)],
					X + Siege.FireEffectOffsets[i].X + GenerateRandomWithSteps(-50, 50, 10),
					Y + Siege.FireEffectOffsets[i].Y + GenerateRandomWithSteps(-50, 50, 10))
				end
				Siege.FireEffectCasted[_index][i] = true
			end
			CEntity.DealDamageInArea(_id, X, Y, Siege.PitchBurningRange, Siege.PitchBurningDamage)
		end
	else
		for i = 1, table.getn(Siege.PitchFieldPositions[_index]) do
			DestroyEntity(Logic.GetEntityAtPosition(Siege.PitchFieldPositions[_index][i].X, Siege.PitchFieldPositions[_index][i].Y))
		end
		--Siege.PitchFieldAlreadyTargetted[_index] = false
		--table.remove(Siege.PitchFieldPositions, _index)
		return true
	end
end
Siege_PitchBurnerControl = function(_id)
	if not IsValid(_id) then
		return true
	end
	if not Siege.PitchBurnerVatEmpty[_id] then
		local player = Logic.EntityGetPlayer(_id)
		local pos = GetPosition(_id)
		local eID = GetNearestEnemyInRange(player, pos, Siege.PitchBurnerRange, false)
		if eID then
			local num, IDs = GetPlayerEntitiesByCatInRange(player, {EntityCategories.Leader, EntityCategories.Cannon}, pos, Siege.PitchBurnerRange)
			if num >= Siege.PitchBurnerEnemyTreshold then
				local t = {}
				for i = 1, num do
					t[i] = GetPosition(IDs[i])
				end
				local clump = GetPositionClump(t, Siege.PitchBurnerRange, 100)
				local angle = GetAngleBetween(pos, clump)
				Logic.RotateEntity(_id, angle)
				Logic.SetTaskList(_id, TaskLists.TL_PITCHBURNER_DROPOIL)
				--Logic.CreateEffect(GGL_Effects.FXDropOil, clump.X, clump.Y)
				Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchBurnerApplyDamage", 1, {}, {_id, clump.X, clump.Y})
				if not Siege_PitchBurnerDropOilSound then
					Sound.PlayGUISound(Sounds["Stronghold_" .. Siege.DropOilSounds[1+XGUIEng.GetRandom(table.getn(Siege.DropOilSounds)-1)]], 152)
					Siege_PitchBurnerDropOilSound = true
					StartCountdown(5, function() Siege_PitchBurnerDropOilSound = false end, false)
				end
				Siege.PitchBurnerVatEmpty[_id] = true
				Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchBurnerRefillVat", 1, {}, {_id})
			end
		end
	end
end
Siege_PitchBurnerRefillVat = function(_id)
	if not IsValid(_id) then
		return true
	end
	if Counter.Tick2("Siege_PitchBurnerRefillVat_Counter_" .. _id, Siege.PitchBurnerRefillDelay) then
		Siege.PitchBurnerVatEmpty[_id] = false
		return true
	end
end
Siege_PitchBurnerApplyDamage = function(_id, _x, _y)
	if not IsValid(_id) then
		return true
	end
	if not Counter.Tick2("Siege_PitchBurnerApplyDamage_Counter_" .. _id, Siege.PitchBurningDuration) then
		if not Siege.FireEffectCasted[_id] then
			for i = 1, table.getn(Siege.FireEffectOffsets) do
				Logic.CreateEffect(CatapultStoneOnHitEffects[math.random(1,4)],
				_x + Siege.FireEffectOffsets[i].X + GenerateRandomWithSteps(-50, 50, 10),
				_y + Siege.FireEffectOffsets[i].Y + GenerateRandomWithSteps(-50, 50, 10))
			end
			Siege.FireEffectCasted[_id] = true
		end
		CEntity.DealDamageInArea(_id, _x, _y, Siege.PitchBurningRange, Siege.PitchBurningDamage)
	else
		Siege.FireEffectCasted[_id] = false
		return true
	end
end
function Victory()
	if Logic.PlayerGetGameState(gvMission.PlayerID) == 1 then
		Logic.PlayerSetGameStateToWon(gvMission.PlayerID)
    end
	Sound.PlayGUISound(Sounds["Stronghold_" .. Siege.VictorySounds[1+XGUIEng.GetRandom(table.getn(Siege.VictorySounds)-1)]], 152)
end
function Defeat()
	if Logic.PlayerGetGameState(gvMission.PlayerID) == 1 then
		Logic.PlayerSetGameStateToLost(gvMission.PlayerID)
	end
	Trigger.DisableTriggerSystem(1)
	Sound.PlayGUISound(Sounds["Stronghold_" .. Siege.DefeatSounds[1+XGUIEng.GetRandom(table.getn(Siege.DefeatSounds)-1)]], 152)
end
GUIAction_ToggleMenuOrig = GUIAction_ToggleMenu
function GUIAction_ToggleMenu(_Menu, _Status)

	if _Menu == "MainMenuBoxQuitWindow" or _Menu == "MainMenuBoxQuitAppWindow" then
		Sound.PlayGUISound(Sounds.Stronghold_General_QuitGame, 152)
	end
	GUIAction_ToggleMenuOrig(_Menu, _Status)

end