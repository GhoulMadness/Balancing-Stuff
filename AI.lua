AIEnemiesAC = AIEnemiesAC or {}
for _playerId = 2,12 do
	AIEnemiesAC[_playerId] = AIEnemiesAC[_playerId] or {}
	AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total or 0
	for i = 1,7 do
		AIEnemiesAC[_playerId][i] = AIEnemiesAC[_playerId][i] or {}
	end
end
function MapEditor_SetupAI(_playerId, _strength, _range, _techlevel, _position, _aggressiveLevel, _peaceTime)

	-- Valid
	if 	_strength == 0 or _strength > 3 or
		_techlevel < 0 or _techlevel > 3 or 
		_playerId < 1 or _playerId > 16 or
		_aggressiveLevel < 0 or _aggressiveLevel > 3 or
		type(_position) ~= "string" then
		return
	end

	-- get position
	local position = GetPosition(_position)

	-- check for buildings
	if Logic.GetPlayerEntitiesInArea(_playerId, 0, position.X, position.Y, 0, 1, 8) == 0 then
		return
	end
	
	--	set up default information
	local description = {
	
		serfLimit				=	(_strength^2)+2,
		--------------------------------------------------
		extracting				=	false,
		--------------------------------------------------
		resources = {
			gold				=	_strength*15000,
			clay				=	_strength*12500,
			iron				=	_strength*12500,
			sulfur				=	_strength*12500,
			stone				=	_strength*12500,
			wood				=	_strength*12500
		},
		--------------------------------------------------
		refresh = {
			gold				=	_strength*2000,
			clay				=	_strength*500,
			iron				=	_strength*1500,
			sulfur				=	_strength*700,
			stone				=	_strength*500,
			wood				=	_strength*1000,
			updateTime			=	math.floor(30/_strength)
		},
		--------------------------------------------------
		constructing			=	true,
		--------------------------------------------------
		rebuild = {
			delay				=	30*(5-_strength),
			randomTime			=	15*(5-_strength)
		},
	}
		
	SetupPlayerAi(_playerId,description)
	
	local CannonEntityType1
	local CannonEntityType2
	-- Tech level
	if _techlevel <= 2 then		
		CannonEntityType1 = Entities.PV_Cannon1
		CannonEntityType2 = Entities.PV_Cannon2
	elseif _techlevel == 3 then
		CannonEntityType1 = Entities.PV_Cannon3
		CannonEntityType2 = Entities.PV_Cannon4
	end
	-- Upgrade entities
	for i=1,_techlevel do
		Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderBow, _playerId)
		Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderSword, _playerId)
		Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderPoleArm, _playerId)
	end
	for i=2, ((_techlevel+1)/2) do
		Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderCavalry, _playerId)
		Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderHeavyCavalry, _playerId)
		Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderRifle, _playerId)
	end

	-- army
	if MapEditor_Armies == nil then
		MapEditor_Armies = {}
	end
		
	MapEditor_Armies[_playerId] = {}
	
	MapEditor_Armies[_playerId].prioritylist = {}
	MapEditor_Armies[_playerId].prioritylist_lastUpdate = 0
	
	if MapEditor_Armies.controlerId == nil then
		MapEditor_Armies.controlerId = {}
		for i = 2,16 do
			MapEditor_Armies.controlerId[i] = {}
		end
	end
	
	for i=1, (_strength+6) do
		
		MapEditor_Armies[_playerId][i] 						=	{}
		MapEditor_Armies[_playerId][i].player 				=	_playerId
		MapEditor_Armies[_playerId][i].id					=	i - 1
		MapEditor_Armies[_playerId][i].strength				=	_strength+5
		MapEditor_Armies[_playerId][i].position				=	GetPosition(_position)
		local offset = (math.mod((i-1),3)-1)
		MapEditor_Armies[_playerId][i].position.X			=	MapEditor_Armies[_playerId][i].position.X + offset*1000
		MapEditor_Armies[_playerId][i].position.Y			=	MapEditor_Armies[_playerId][i].position.Y + (math.floor((i-1)/3)*1000)
		MapEditor_Armies[_playerId][i].rodeLength			=	(_range*2)/3
		MapEditor_Armies[_playerId][i].retreatStrength		=	0
		MapEditor_Armies[_playerId][i].baseDefenseRange		=	(_range)/3
		MapEditor_Armies[_playerId][i].outerDefenseRange	=	_range
		MapEditor_Armies[_playerId][i].manualControlRange 	= 	3200
		MapEditor_Armies[_playerId][i].techLVL 				= 	_techlevel
		MapEditor_Armies[_playerId][i].AttackAllowed		=	false
		
		MapEditor_Armies[_playerId][i].AllowedTypes			=	{ 	UpgradeCategories.LeaderBow,
																	UpgradeCategories.LeaderSword,
																	UpgradeCategories.LeaderPoleArm,
																	UpgradeCategories.LeaderCavalry,
																	UpgradeCategories.LeaderHeavyCavalry,
																	UpgradeCategories.LeaderRifle,
																	CannonEntityType1,
																	CannonEntityType2
																	}
		
		AI.Army_BeAlwaysAggressive(_playerId, MapEditor_Armies[_playerId][i].id)
		AI.Army_SetScatterTolerance(_playerId, MapEditor_Armies[_playerId][i].id,4)		
		--AI.Army_SetSize(_playerId, MapEditor_Armies[_playerId][i].id, 1)
		-- Spawn generator
		SetupAITroopGenerator("MapEditor_Armies_".._playerId.."_"..i, MapEditor_Armies[_playerId][i])
				
		if math.ceil((_aggressiveLevel^2*_strength)/3) >= i then			
			Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND, nil, "StartMapEditor_ArmyAttack", 1, nil, {_playerId, i-1, _peaceTime})			
		end
		Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_TURN, "", "StartMapEditor_Controller", 1, {}, {_playerId, i})		
	end	
	SetHostile(1,_playerId)
	--[[local enemies = BS.GetAllEnemyPlayerIDs(_playerId)
	if gvTower.StartTowersIDTable and gvTower.StartTowersIDTable[1] then
		for i = 1, table.getn(gvTower.StartTowersIDTable) do			
			for k = 1, table.getn(enemies) do
				if Logic.EntityGetPlayer(gvTower.StartTowersIDTable[i]) == enemies[k] and Logic.GetUpgradeLevelForBuilding(gvTower.StartTowersIDTable[i]) == 2 then
					table.insert(AIEnemiesAC[_playerId][5], gvTower.StartTowersIDTable[i])
					AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total + 1
				end
			end
		end
	end]]
	if not AIchunks[_playerId] then
		AIchunks[_playerId] = CUtil.Chunks.new()
		AI_AddEnemiesToChunkData(_playerId)
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnAIEnemyCreated", 1, {}, {_playerId})
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAIEnemyDestroyed", 1, {}, {_playerId})
	end
end
function StartMapEditor_Controller(_playerId,_armycount)

	if Counter.Tick2("StartMapEditor_Controller_Ticker",_armycount) then		
		if MapEditor_Armies.controlerId[_playerId][_armycount] == nil then
			MapEditor_Armies.controlerId[_playerId][_armycount] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "ControlMapEditor_Armies", 1, {}, {_playerId, _armycount})
		end
		return true
	end
end
function StartMapEditor_ArmyAttack(_playerId,_armyId,_delay)

	if Counter.Tick2("StartMapEditor_ArmyAttack".._playerId.."_".._armyId, _delay) then		
		MapEditor_Armies[_playerId][_armyId+1].AttackAllowed = true		
		return true		
	end

end

ControlMapEditor_Armies = function(_playerId,_armycount)
	
	if Counter.Tick2("ControlMapEditor_Armies_".._playerId.."_".._armycount,3) then
				
		if MapEditor_Armies[_playerId] ~= nil and MapEditor_Armies[_playerId][_armycount] ~= nil then							
			TickOffensiveAIController(MapEditor_Armies[_playerId][_armycount])												
		end	
		
	end			
end
		
TickOffensiveAIController = function(_army)
	---
	--- collect important information
	---------------------------------		
	local army				= _army.id
	local player			= _army.player
	local numberOfTroops	= AI.Army_GetNumberOfTroops(player,army)	
	local position			= _army.position

-------------------------------------------------------------
-- Init
-------------------------------------------------------------
	if _army.offensiveAIControllerState == nil then
		
	    Retreat(_army,_army.outerDefenseRange)				
		_army.rodeLength = _army.outerDefenseRange
		_army.offensiveAIControllerState = 0
	end


-------------------------------------------------------------
-- Defensive
-------------------------------------------------------------
	if _army.offensiveAIControllerState == 0 then

		-- enough soldiers
		if numberOfTroops > _army.retreatStrength and not AI.Army_IsRefreshing(player, army) then
			
			_army.offensiveAIControllerState = 1
			_army.rodeLength = _army.outerDefenseRange
			AI.Army_SetAnchorRodeLength(player, army, _army.rodeLength)
		
		else
		
			AIController_Defensive( _army, _army.baseDefenseRange )
	
		end
-------------------------------------------------------------
-- Offensive Defense
-------------------------------------------------------------	
	elseif _army.offensiveAIControllerState == 1 then
		
		if numberOfTroops <= _army.retreatStrength then
			
			_army.offensiveAIControllerState = 0			
			_army.rodeLength = _army.baseDefenseRange
			AI.Army_SetAnchorRodeLength(player, army, _army.rodeLength)
		
		elseif AI.Army_GetOccupancyRate(player, army) >= 75 and _army.AttackAllowed and not AI.Army_IsRefreshing(player, army) then

			_army.offensiveAIControllerState = 2
		
			if _army.AttackPos ~= nil then
		
				if table.getn(_army.AttackPos) ~= 0 then
					
					local Index = Logic.GetRandom(table.getn(_army.AttackPos))+1						
					AI.Army_SetAnchor(player, army, _army.AttackPos[Index].X, _army.AttackPos[Index].Y, 0)
					
				else
					
					AI.Army_SetAnchor(player, army, _army.AttackPos.X, _army.AttackPos.Y, 0)
					
				end
			end
			
			_army.Attack = true
				
		else

			AIController_Defensive( _army, _army.outerDefenseRange )
					
		end
-------------------------------------------------------------
-- Attack
-------------------------------------------------------------
	elseif _army.offensiveAIControllerState == 2 then

		if numberOfTroops <= _army.retreatStrength then
			
			_army.offensiveAIControllerState = 0			
			_army.Attack = false			 
			 Retreat(_army,_army.baseDefenseRange)				
			_army.rodeLength = _army.baseDefenseRange
			
		elseif not _army.AttackAllowed then
			
			_army.offensiveAIControllerState = 1			 
			 _army.Attack = false			 
			 Retreat(_army,_army.outerDefenseRange)				
			_army.rodeLength = _army.outerDefenseRange
			
		else
			
			if AI.Army_GetDistanceBetweenAnchorAndEnemy(player, army) < _army.manualControlRange then
				AI_StartManualControl(player, _army, 0)
			else
				Advance(_army, 0)
			end
		end

		
	end	
end

AIController_Defensive = function(_army, _range)

	if AI.Army_GetAnchorRodeLength(_army.player, _army.id) > _range then								
		Retreat(_army,_range)				
		_army.rodeLength = _range
	else		
		Defend(_army)		
	end
	
end
AI_AddEnemiesToChunkData = function(_playerId)

	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(BS.GetAllEnemyPlayerIDs(_playerId))), CEntityIterator.IsSettlerOrBuildingFilter()) do
		local etype = Logic.GetEntityType(eID)
		if IsMilitaryLeader(eID) or Logic.IsHero(eID) == 1 or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3 or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 then
			AIchunks[_playerId]:AddEntity(eID)
			table.insert(AIEnemiesAC[_playerId][GetEntityTypeArmorClass(etype)], eID)
			AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total + 1
		elseif (Logic.IsBuilding(eID) == 1 and Logic.IsEntityInCategory(eID, EntityCategories.Wall) == 0) or Logic.IsSerf(eID) == 1 then
			AIchunks[_playerId]:AddEntity(eID)
		end
	end
end
SetupArmy = function(_army)
	
	if not ArmyTable then
		ArmyTable = {}
	end
	if not ArmyTable[_army.player] then
		ArmyTable[_army.player] = {}
	end
	ArmyTable[_army.player][_army.id + 1] = ArmyTable[_army.player][_army.id + 1] or {}
	AI.Army_SetAnchor(
		_army.player,
		_army.id,
		_army.position.X,
		_army.position.Y,
		_army.rodeLength
	)
	
	AI.Army_SetScatterTolerance(
		_army.player,
		_army.id,
		4
	)		
	
	if _army.beAgressive ~= nil then
	
		AI.Army_BeAlwaysAggressive(_army.player,_army.id)
		
	end
	
	if not AIchunks[_army.player] then
		AIchunks[_army.player] = CUtil.Chunks.new()
		AI_AddEnemiesToChunkData(_army.player)
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnAIEnemyCreated", 1, {}, {_army.player})
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAIEnemyDestroyed", 1, {}, {_army.player})
	end	
end
Advance = function(_army, _flag)

	local distanceToEnemy = AI.Army_GetDistanceBetweenAnchorAndEnemy(_army.player,_army.id)
	AI.Army_SetAnchorRodeLength(_army.player,_army.id,distanceToEnemy)
	if not _flag and distanceToEnemy <= _army.rodeLength then
		AI_StartManualControl(_army.player, _army, 1)
	end
end	
AI_StartManualControl = function(_player, _army, _flag)
	
	local target, newtarget, tabname, range
	local leaderIDs = AI.Army_GetLeaderIDs(_player, _army.id)
	if _flag == 0 then
		tabname = MapEditor_Armies[_player][_army.id + 1]
		range = tabname.manualControlRange 		
	elseif _flag == 1 then
		tabname = _army or MapEditor_Armies[_player][_army.id + 1]
		range = math.min(tabname.rodeLength or tabname.manualControlRange, 5000)
	end
	if leaderIDs[1] then
		for i = 1,table.getn(leaderIDs) do
			if tabname[leaderIDs[i]] and tabname[leaderIDs[i]].currenttarget then
				target = tabname[leaderIDs[i]].currenttarget
				newtarget = CheckForBetterTarget(leaderIDs[i], target, range)
			else
				newtarget = CheckForBetterTarget(leaderIDs[i], nil, range)
			end
			if newtarget and newtarget ~= target then
				tabname[leaderIDs[i]] = tabname[leaderIDs[i]] or {}
				tabname[leaderIDs[i]].currenttarget = newtarget
				tabname[leaderIDs[i]].lasttime = Logic.GetCurrentTurn() 
				AI.Army_EnableLeaderAi(leaderIDs[i], 0)
				AI.Entity_RemoveFromArmy(leaderIDs[i], _player, _army.id)
				Logic.GroupAttack(leaderIDs[i], newtarget)
				Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ManualControl_AttackTarget", 1, {}, {_player, _flag, _army.id, leaderIDs[i]})
			else
				Advance(_army, 0)
			end
		end
	end
end
ManualControl_AttackTarget = function(_player, _flag, _armyId, _id)
	
	local tabname, range
	if _flag == 0 then
		tabname = MapEditor_Armies[_player][_armyId + 1]
		range = tabname.manualControlRange + 500 		
	elseif _flag == 1 then
		tabname = ArmyTable[_player][_armyId + 1]
		range = math.min(tabname.rodeLength, 5000)
	end
	if not Logic.IsEntityAlive(_id) then
		tabname[_id] = nil
		return true
	end
	local target = tabname[_id].currenttarget
	local time = tabname[_id].lasttime
	local delay = 5 + (Logic.IsEntityInCategory(_id, EntityCategories.Melee) * 20)
	local posX, posY = Logic.GetEntityPosition(_id)
	local currtime = Logic.GetTimeMs()
	if AIchunks.time[_player] ~= currtime then
		AIchunks[_player]:UpdatePositions()
		AIchunks.time[_player] = Logic.GetTimeMs()
	end
	local entities = AIchunks[_player]:GetEntitiesInAreaInCMSorted(posX, posY, range)
	if not entities[1] then
		local newtarget = GetNearestTarget(_player, _id)
		if newtarget and newtarget ~= target then
			if not Logic.IsEntityAlive(target) then 
				tabname[_id].currenttarget = newtarget
				tabname[_id].lasttime = Logic.GetCurrentTurn()
				Logic.GroupAttack(_id, newtarget)		
			else
				if Logic.GetCurrentTurn() > time + delay then
					tabname[_id].currenttarget = newtarget
					tabname[_id].lasttime = Logic.GetCurrentTurn()
					Logic.GroupAttack(_id, newtarget)		
				end
			end
		end
	else
		local count = 0
		for i = 1, table.getn(entities) do
			if count > 0 then
				break
			end
			if Logic.IsEntityAlive(entities[i]) then
				count = count + 1
			end
		end
		if count == 0 then
			local newtarget = GetNearestTarget(_player, _id)
			if newtarget and newtarget ~= target then
				if not Logic.IsEntityAlive(target) then 
					tabname[_id].currenttarget = newtarget
					tabname[_id].lasttime = Logic.GetCurrentTurn()
					Logic.GroupAttack(_id, newtarget)		
				else
					if Logic.GetCurrentTurn() > time + delay then
						tabname[_id].currenttarget = newtarget
						tabname[_id].lasttime = Logic.GetCurrentTurn()
						Logic.GroupAttack(_id, newtarget)		
					end
				end
			end				
		else		
			local newtarget = CheckForBetterTarget(_id, target, range)
			if newtarget and newtarget ~= target then
				if not Logic.IsEntityAlive(target) then 
					tabname[_id].currenttarget = newtarget
					tabname[_id].lasttime = Logic.GetCurrentTurn()
					Logic.GroupAttack(_id, newtarget)
				else
					if Logic.GetCurrentTurn() > time + delay then
						tabname[_id].currenttarget = newtarget
						tabname[_id].lasttime = Logic.GetCurrentTurn()
						Logic.GroupAttack(_id, newtarget)		
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
SetupAITroopGenerator = function(_Name, _army)

	local Index = AddData(_army)
	-- Setup trigger
	assert(_army.generatorID==nil, "There is already a generator registered")
	_army.generatorID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "AITroopGenerator_Condition", "AITroopGenerator_Action", 1, {_Name, Index}, {Index})

end
AITroopGenerator_Condition = function(_Name, _Index)

	-- Already enough troops
	if 	Counter.Tick2(_Name.."Generator",4) == false or ((DataTable[_Index].ignoreAttack == nil or not DataTable[_Index].ignoreAttack) and DataTable[_Index].Attack) 
		or
		AI.Player_GetNumberOfLeaders(DataTable[_Index].player) >= table.getn(MapEditor_Armies[DataTable[_Index].player]) *DataTable[_Index].strength then
		return false
	end

	-- not enough troops
	if AI.Army_GetNumberOfTroops(DataTable[_Index].player, DataTable[_Index].id) < DataTable[_Index].strength then
	
		local numBarr, numArch, numStab, numFoun = AI.Village_GetNumberOfMilitaryBuildings(DataTable[_Index].player)
		
		if numBarr + numArch + numStab + numFoun ~= 0 then
			-- Connect unemployed leader
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(DataTable[_Index].player), CEntityIterator.IsSettlerFilter(), CEntityIterator.OfAnyCategoryFilter(EntityCategories.Leader, EntityCategories.Cannon)) do
				if Logic.IsEntityInCategory(eID, EntityCategories.MilitaryBuilding) ~= 1 then
					if AI.Entity_GetConnectedArmy(eID) == -1 then
						if string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(eID))), "cu") ~= nil then
							local pos = GetPosition(eID)
							if (({Logic.GetPlayerEntitiesInArea(DataTable[_Index].player, Entities.PB_Barracks1, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(DataTable[_Index].player, Entities.PB_Barracks2, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(DataTable[_Index].player, Entities.PB_Archery1, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(DataTable[_Index].player, Entities.PB_Archery2, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(DataTable[_Index].player, Entities.PB_MercenaryTower, pos.X, pos.Y, 1500, 1)})[1]) ~= 0 then
								AI.Entity_ConnectWithArmy(eID, DataTable[_Index].id)
							end
							if string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(eID))), "veteran") ~= nil then
								AI.Entity_ConnectWithArmy(eID, DataTable[_Index].id)
							end
						else
							local MilitaryBuildingID = Logic.LeaderGetNearbyBarracks(eID)
				
							if MilitaryBuildingID ~= 0	then		
								if Logic.IsConstructionComplete( MilitaryBuildingID ) == 1 then
									AI.Entity_ConnectWithArmy(eID, DataTable[_Index].id)
								end
							end
						end
					end
				end
			end
		else
			AI.Entity_ConnectUnemployedLeader(DataTable[_Index].player, 6)
		end

	end
	return AI.Army_GetNumberOfTroops(DataTable[_Index].player, DataTable[_Index].id) < DataTable[_Index].strength

end
AITroopGenerator_Action = function(_Index)

	-- Get entityType/Category
	local eTyp = AITroopGenerator_EvaluateMilitaryBuildingsPriority(_Index) or DataTable[_Index].AllowedTypes[math.random(table.getn(DataTable[_Index].AllowedTypes))]
	if eTyp == Entities.PV_Cannon1 and DataTable[_Index].techLVL == 3 then
		eTyp = Entities.PV_Cannon3
	elseif eTyp == Entities.PV_Cannon2 and DataTable[_Index].techLVL == 3 then
		eTyp = Entities.PV_Cannon4
	end
	if AI.Player_GetNumberOfLeaders(DataTable[_Index].player) < table.getn(MapEditor_Armies[DataTable[_Index].player]) * DataTable[_Index].strength * 3/4 then
		AI.Army_BuyLeader(DataTable[_Index].player, DataTable[_Index].id, eTyp)
	end
	return false

end
AITroopGenerator_EvaluateMilitaryBuildingsPriority = function(_Index)
	
	local player = DataTable[_Index].player
	if MapEditor_Armies[player].prioritylist_lastUpdate == 0 or Logic.GetTime() > MapEditor_Armies[player].prioritylist_lastUpdate + 30 then
		local num = {}
		num.Barracks, num.Archery, num.Stables, num.Foundry = AI.Village_GetNumberOfMilitaryBuildings(player)
		if num.Foundry > 0 and (MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(player, Entities.PB_Foundry1, 1)})[2]) or MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(player, Entities.PB_Foundry2, 1)})[2])) then
			return Entities["PV_Cannon"..math.min(math.random(1, 3), 2)]
		end
		local armorclasspercT = GetPercentageOfLeadersPerArmorClass(AIEnemiesAC[player])
		for i = 1,7 do
			local bestdclass = BS.GetBestDamageClassByArmorClass(armorclasspercT[i].id)
			local ucat = GetUpgradeCategoryInDamageClass(bestdclass)
			for k,v in pairs(BS.CategoriesInMilitaryBuilding) do
				local tpos = table.findvalue(v, ucat)
				if tpos ~= 0 then
					if num[k] > 0 then						
						MapEditor_Armies[player].prioritylist[i] = {name = k, typ = BS.CategoriesInMilitaryBuilding[k][tpos]}
					end
				end
			end
		end
		MapEditor_Armies[player].prioritylist_lastUpdate = Logic.GetTime()
	end
	for k, v in pairs(MapEditor_Armies[player].prioritylist) do
		local entity = ({Logic.GetPlayerEntities(player, Entities["PB_"..v.name.."1"], 1)})[2] or ({Logic.GetPlayerEntities(player, Entities["PB_"..v.name.."2"], 1)})[2]
		if entity then
			if MilitaryBuildingIsTrainingSlotFree(entity) then
				return v.typ
			end
		end
	end
end
--[[AITroopGenerator_CheckForPriority = function(_Index)
	local copy = DataTable[_Index].AllowedTypes
	local eTyp, UpgradeCategoryIndex
	local numBarr, numArch, numStab, numFoun = AI.Village_GetNumberOfMilitaryBuildings(DataTable[_Index].player)
	local armorclasspercT = GetPercentageOfLeadersPerArmorClass(AIEnemiesAC[DataTable[_Index].player])
	if armorclasspercT[1].count > 50 then		
		for i = 1, 7 do
			for k = 1, math.max(round(armorclasspercT[i].count/5), 1) do
				local bestdclass = BS.GetBestDamageClassesByArmorClass[armorclasspercT[i].id]
				local ucat = GetUpgradeCategoryInDamageClass(bestdclass)
				table.insert(copy, ucat)
			end
		end
		
		if numBarr == 0 then
			for i = 1, table.getn(copy) do
				if copy[i] == UpgradeCategories.LeaderSword or copy[i] == UpgradeCategories.LeaderPoleArm then
					table.remove(copy, i)
				end
			end
		end
		if numArch == 0 then
			for i = 1, table.getn(copy) do
				if copy[i] == UpgradeCategories.LeaderBow or copy[i] == UpgradeCategories.LeaderRifle then
					table.remove(copy, i)
				end
			end
		end
		if numStab == 0 then
			for i = 1, table.getn(copy) do
				if copy[i] == UpgradeCategories.LeaderCavalry or copy[i] == UpgradeCategories.LeaderHeavyCavalry then
					table.remove(copy, i)
				end
			end
		end
		if numFoun == 0 then
			for i = 1, table.getn(copy) do
				if copy[i] == Entities.PV_Cannon2 or copy[i] == Entities.PV_Cannon4 then
					table.remove(copy, i)
				end
			end		
		end
	end

	local UpgradeCategoryCount = table.getn(copy)	
	return copy[math.random(UpgradeCategoryCount)]
end]]