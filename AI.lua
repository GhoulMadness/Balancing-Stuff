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
		
	SetupPlayerAi(_playerId, description)	
	EvaluateArmyHomespots(_playerId, position, nil)
	
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
	if MapEditor_Armies.controlerId == nil then
		MapEditor_Armies.controlerId = {}
	end
		
	MapEditor_Armies[_playerId] = {}	
	MapEditor_Armies[_playerId].prioritylist = {}
	MapEditor_Armies[_playerId].prioritylist_lastUpdate = 0		
	MapEditor_Armies[_playerId].player 				=	_playerId
	MapEditor_Armies[_playerId].id					=	0
	MapEditor_Armies[_playerId].strength			=	_strength * 15
	MapEditor_Armies[_playerId].position			=	position
	MapEditor_Armies[_playerId].rodeLength			=	_range
	MapEditor_Armies[_playerId].aggressiveLVL		=	_aggressiveLevel
	MapEditor_Armies[_playerId].baseDefenseRange	=	(_range*2)/3
	MapEditor_Armies[_playerId].outerDefenseRange	=	_range
	MapEditor_Armies[_playerId].techLVL 			= 	_techlevel
	MapEditor_Armies[_playerId].AttackAllowed		=	false
	MapEditor_Armies[_playerId].IDs					=	{}	
	MapEditor_Armies[_playerId].AllowedTypes		=	{ 	UpgradeCategories.LeaderBow,
															UpgradeCategories.LeaderSword,
															UpgradeCategories.LeaderPoleArm,
															UpgradeCategories.LeaderCavalry,
															UpgradeCategories.LeaderHeavyCavalry,
															UpgradeCategories.LeaderRifle,
															CannonEntityType1,
															CannonEntityType2
														}
			
	-- Spawn generator
	SetupAITroopGenerator("MapEditor_Armies_".._playerId, _playerId)
						
	Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND, nil, "StartMapEditor_ArmyAttack", 1, nil, {_playerId, _peaceTime})			
	if MapEditor_Armies.controlerId[_playerId] == nil then
		MapEditor_Armies.controlerId[_playerId] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "ControlMapEditor_Armies", 1, {}, {_playerId})
	end		

	SetHostile(1,_playerId)

	if not AIchunks[_playerId] then
		AIchunks[_playerId] = ChunkWrapper.new()
		AI_AddEnemiesToChunkData(_playerId)
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnAIEnemyCreated", 1, {}, {_playerId})
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAIEnemyDestroyed", 1, {}, {_playerId})
		Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "OnAIDiplomacyChanged", 1, {}, {_playerId})
	end
end
function StartMapEditor_ArmyAttack(_playerId, _delay)

	if Counter.Tick2("StartMapEditor_ArmyAttack".._playerId, _delay) then		
		MapEditor_Armies[_playerId].AttackAllowed = true		
		return true		
	end

end
ControlMapEditor_Armies = function(_playerId)
					
	if MapEditor_Armies[_playerId] ~= nil then	
		local pos = MapEditor_Armies[_playerId].position
		local range
		if MapEditor_Armies[_playerId].AttackAllowed then
			range = MapEditor_Armies[_playerId].outerDefenseRange
		else
			range = MapEditor_Armies[_playerId].baseDefenseRange
		end
		if AreEntitiesOfDiplomacyStateInArea(_playerId, pos, range, Diplomacy.Hostile) then
			for i = 1, table.getn(MapEditor_Armies[_playerId].IDs) do
				local id = MapEditor_Armies[_playerId].IDs[i]
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					if GetDistance(GetPosition(id), pos) < 1500 + (300 * MapEditor_Armies[_playerId].aggressiveLVL) then
						ManualControl_AttackTarget(_playerId, nil, id)
					end
				end
				if MapEditor_Armies[_playerId][id] then
					if (MapEditor_Armies[_playerId][id].lasttime and (MapEditor_Armies[_playerId][id].lasttime + 5 < Logic.GetTime() )) 
					or (MapEditor_Armies[_playerId][id].currenttarget and not Logic.IsEntityAlive(MapEditor_Armies[_playerId][id].currenttarget)) then
						ManualControl_AttackTarget(_playerId, nil, id)
					end
				end							
			end
		else
			for i = 1, table.getn(MapEditor_Armies[_playerId].IDs) do
				local id = MapEditor_Armies[_playerId].IDs[i]
				if MapEditor_Armies[_playerId][id] and MapEditor_Armies[_playerId][id].lasttime then
					if GetDistance(GetPosition(id), pos) > 1500 + (300 * MapEditor_Armies[_playerId].aggressiveLVL) then
						local anchor = ArmyHomespots[_playerId].recruited[math.random(1, table.getn(ArmyHomespots[_playerId].recruited))]
						Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
					end
				end
			end
		end	
	end			
end
AI_AddEnemiesToChunkData = function(_playerId)

	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(BS.GetAllEnemyPlayerIDs(_playerId))), CEntityIterator.IsSettlerOrBuildingFilter()) do
		local etype = Logic.GetEntityType(eID)
		if IsMilitaryLeader(eID) or Logic.IsHero(eID) == 1 or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3 or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 then
			ChunkWrapper.AddEntity(AIchunks[_playerId], eID)
			table.insert(AIEnemiesAC[_playerId][GetEntityTypeArmorClass(etype)], eID)
			AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total + 1
		elseif (Logic.IsBuilding(eID) == 1 and Logic.IsEntityInCategory(eID, EntityCategories.Wall) == 0) or Logic.IsSerf(eID) == 1 then
			ChunkWrapper.AddEntity(AIchunks[_playerId], eID)
		end
	end
end
ReinitChunkData = function(_playerId)
	local eIDs = ChunkWrapper.GetEntitiesInAreaInCMSorted(AIchunks[_playerId], Mapsize/2, Mapsize/2, Mapsize/2) 
	if eIDs and table.getn(eIDs) then
		for i = 1, table.getn(eIDs) do
			local etype = Logic.GetEntityType(eIDs[i])
			if IsMilitaryLeader(eIDs[i]) or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3 or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 then	
				ChunkWrapper.RemoveEntity(AIchunks[_playerId], eIDs[i])
				removetablekeyvalue(AIEnemiesAC[_playerId][GetEntityTypeArmorClass(etype)], eIDs[i])
				AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total - 1
			elseif (Logic.IsBuilding(eIDs[i]) == 1 and Logic.IsEntityInCategory(eIDs[i], EntityCategories.Wall) == 0 and not IsInappropiateBuilding(eIDs[i])) or Logic.IsSerf(eIDs[i]) == 1 then
				ChunkWrapper.RemoveEntity(AIchunks[_playerId], eIDs[i])	
			end
		end
		AI_AddEnemiesToChunkData(_playerId)
	end
end
SetupArmy = function(_army)
	
	if not ArmyTable then
		ArmyTable = {}
	end
	if not ArmyTable[_army.player] then
		ArmyTable[_army.player] = {}
	end
	ArmyTable[_army.player][_army.id + 1] = ArmyTable[_army.player][_army.id + 1] or _army
	EvaluateArmyHomespots(_army.player, _army.position, _army.id + 1)
	
	if not AIchunks[_army.player] then
		AIchunks[_army.player] = ChunkWrapper.new()
		AI_AddEnemiesToChunkData(_army.player)
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnAIEnemyCreated", 1, {}, {_army.player})
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAIEnemyDestroyed", 1, {}, {_army.player})
		Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "OnAIDiplomacyChanged", 1, {}, {_army.player})
	end	
end
EnlargeArmy = function(_army,_troop)

	if not ArmyTable[_army.player][_army.id + 1].IDs then
		ArmyTable[_army.player][_army.id + 1].IDs = {}
	end
	local anchor = ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
	local id = AI.Entity_CreateFormation(_army.player, _troop.leaderType, 0, _troop.maxNumberOfSoldiers or 0, anchor.X, anchor.Y, 0, 0, _troop.experiencePoints or 0, _troop.minNumberOfSoldiers or 0)
	table.insert(ArmyTable[_army.player][_army.id + 1].IDs, id)
	Logic.LeaderChangeFormationType(id, math.random(1, 7))
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_army.player, id, _army.id + 1})

end
Defend = function(_army)

	local pos = _army.position
	local range = _army.rodeLength
	if AreEntitiesOfDiplomacyStateInArea(_army.player, pos, range, Diplomacy.Hostile) then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
				if GetDistance(GetPosition(id), pos) < 1500 then
					ManualControl_AttackTarget(_army.player, _army.id + 1, id)
				end
			end
			if ArmyTable[_army.player][_army.id + 1][id] then
				if (ArmyTable[_army.player][_army.id + 1][id].lasttime and (ArmyTable[_army.player][_army.id + 1][id].lasttime + 5 < Logic.GetTime() )) 
				or (ArmyTable[_army.player][_army.id + 1][id].currenttarget and not Logic.IsEntityAlive(ArmyTable[_army.player][_army.id + 1][id].currenttarget)) then
					ManualControl_AttackTarget(_army.player, _army.id + 1, id)
				end
			end							
		end
	else
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if GetDistance(GetPosition(id), pos) > 1500 then
				local anchor = ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
				Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
			end
		end
	end		
end
Advance = function(_army)
	
	local enemyId = AI.Army_GetEntityIdOfEnemy(_army.player,_army.id)
	
	if enemyId ~= 0 then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetSector(id) == Logic.GetSector(enemyId) then
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					if GetDistance(GetPosition(id), _army.position) < 1500 then
						ManualControl_AttackTarget(_army.player, _army.id + 1, id)
					end
				end
				if ArmyTable[_army.player][_army.id + 1][id] then
					if (ArmyTable[_army.player][_army.id + 1][id].lasttime and (ArmyTable[_army.player][_army.id + 1][id].lasttime + 5 < Logic.GetTime() ))
					or (ArmyTable[_army.player][_army.id + 1][id].currenttarget and not Logic.IsEntityAlive(ArmyTable[_army.player][_army.id + 1][id].currenttarget)) then
						ManualControl_AttackTarget(_army.player, _army.id + 1 , id)
					end
				end
			end
		end
	end
end
FrontalAttack = function(_army, _target)

	local enemyId = _target or AI.Army_GetEntityIdOfEnemy(_army.player,_army.id)
	
	if enemyId ~= 0 then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetSector(id) == Logic.GetSector(enemyId) then
				ArmyTable[_army.player][_army.id + 1][id] = ArmyTable[_army.player][_army.id + 1][id] or {}
				ArmyTable[_army.player][_army.id + 1][id].currenttarget = enemyId
				ArmyTable[_army.player][_army.id + 1][id].lasttime = Logic.GetTime()
				Logic.GroupAttack(id, enemyId)
			end
		end
	end
end
Retreat = function(_army, _rodeLength)

	if _rodeLength then
		_army.rodeLength = _rodeLength
	end
	local pos = _army.position
	for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
		local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
		if GetDistance(GetPosition(id), pos) > 1500 then
			local anchor = ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
			Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
		end
	end
end
Redeploy = function(_army, _position, _rodeLength)

	if _rodeLength then
		_army.rodeLength = _rodeLength
	end
	_army.position = _position
	ArmyHomespots[_army.player][_army.id + 1] = nil
	EvaluateArmyHomespots(_army.player, _position, _army.id + 1)
	local pos = _army.position
	for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
		local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
		if GetDistance(GetPosition(id), pos) > 1500 then
			local anchor = ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
			Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
		end
	end
end
Synchronize = function(_army0, _army1)

	_army1.rodeLength = _army0.rodeLength
	_army1.position = _army0.position
	ArmyHomespots[_army1.player][_army1.id + 1] = nil
	EvaluateArmyHomespots(_army1.player, _army0.position, _army1.id + 1)
	local pos = _army1.position
	for i = 1, table.getn(ArmyTable[_army1.player][_army1.id + 1].IDs) do
		local id = ArmyTable[_army1.player][_army1.id + 1].IDs[i]
		if GetDistance(GetPosition(id), pos) > 1500 then
			local anchor = ArmyHomespots[_army1.player][_army1.id + 1][math.random(1, table.getn(ArmyHomespots[_army1.player][_army1.id + 1]))]
			Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
		end
	end
end
ManualControl_AttackTarget = function(_player, _armyId, _id)
	
	local tabname, range, target, newtarget
	if not _armyId then
		tabname = MapEditor_Armies[_player]
		range = tabname.baseDefenseRange
	else
		tabname = ArmyTable[_player][_armyId]
		range = tabname.rodeLength
	end
	if tabname[_id] and tabname[_id].currenttarget then
		target = tabname[_id].currenttarget
		newtarget = CheckForBetterTarget(_id, target, nil) or GetNearestTarget(_player, _id)
	else
		newtarget = CheckForBetterTarget(_id, nil, nil) or GetNearestTarget(_player, _id)
	end
	tabname[_id] = tabname[_id] or {}
	if newtarget then		
		tabname[_id].currenttarget = newtarget
		tabname[_id].lasttime = Logic.GetTime() 		
		Logic.GroupAttack(_id, newtarget)	
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
SetupAITroopGenerator = function(_Name, _player)
	-- Setup trigger
	assert(MapEditor_Armies[_player].generatorID==nil, "There is already a generator registered")
	MapEditor_Armies[_player].generatorID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "AITroopGenerator_Condition", "AITroopGenerator_Action", 1, {_Name, _player}, {_player})
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "AITroopGenerator_GetLeader", 1, {}, {_player})
end
AITroopGenerator_Condition = function(_Name, _player)

	local _army = MapEditor_Armies[_player]
	-- Already enough troops
	if 	Counter.Tick2(_Name.."Generator",5 - _army.aggressiveLVL) == false or ((_army.ignoreAttack == nil or not _army.ignoreAttack) and _army.Attack) 
		or
		table.getn(_army.IDs) >= _army.strength then
		return false
	end

	-- not enough troops
	if table.getn(_army.IDs) < _army.strength then
	
		local numBarr, numArch, numStab, numFoun = AI.Village_GetNumberOfMilitaryBuildings(_army.player)
		
		if numBarr + numArch + numStab + numFoun ~= 0 then
			-- Connect unemployed leader
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_army.player), CEntityIterator.IsSettlerFilter(), CEntityIterator.OfAnyCategoryFilter(EntityCategories.Leader, EntityCategories.Cannon)) do
				if Logic.IsEntityInCategory(eID, EntityCategories.MilitaryBuilding) ~= 1 then
					if AI.Entity_GetConnectedArmy(eID) == -1 and (Logic.GetCurrentTaskList(eID) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(eID) == "TL_VEHICLE_IDLE") then
						local anchor = ArmyHomespots[_army.player].recruited[math.random(1, table.getn(ArmyHomespots[_army.player].recruited))]
						if GetDistance(GetPosition(eID), anchor) > 500 then
							if string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(eID))), "cu") ~= nil then
								local pos = GetPosition(eID)
								if (({Logic.GetPlayerEntitiesInArea(_army.player, Entities.PB_Barracks1, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(_army.player, Entities.PB_Barracks2, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(_army.player, Entities.PB_Archery1, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(_army.player, Entities.PB_Archery2, pos.X, pos.Y, 1500, 1)})[1] + ({Logic.GetPlayerEntitiesInArea(_army.player, Entities.PB_MercenaryTower, pos.X, pos.Y, 1500, 1)})[1]) ~= 0 then
									Logic.GroupAttackMove(eID, anchor.X, anchor.Y, math.random(360))
								end
								if string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(eID))), "veteran") ~= nil then
									Logic.GroupAttackMove(eID, anchor.X, anchor.Y, math.random(360))
								end
							else
								local MilitaryBuildingID = Logic.LeaderGetNearbyBarracks(eID)
					
								if MilitaryBuildingID ~= 0	then		
									if Logic.IsConstructionComplete( MilitaryBuildingID ) == 1 then
										if Logic.IsEntityInCategory(eID, EntityCategories.Cannon) == 1 or (Logic.LeaderGetNumberOfSoldiers(eID) == Logic.LeaderGetMaxNumberOfSoldiers(eID)) then
											Logic.GroupAttackMove(eID, anchor.X, anchor.Y, math.random(360))
										end
									end
								end
							end
						end
					end
				end
			end
		else
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_army.player), CEntityIterator.IsSettlerFilter(), CEntityIterator.OfAnyCategoryFilter(EntityCategories.Leader, EntityCategories.Cannon)) do
				if Logic.IsEntityInCategory(eID, EntityCategories.MilitaryBuilding) ~= 1 then
					if AI.Entity_GetConnectedArmy(eID) == -1 and (Logic.GetCurrentTaskList(eID) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(eID) == "TL_VEHICLE_IDLE") then
						local anchor = ArmyHomespots[_army.player].recruited[math.random(1, table.getn(ArmyHomespots[_army.player].recruited))]
						if GetDistance(GetPosition(eID), anchor) > 1200 then
							Logic.GroupAttackMove(eID, anchor.X, anchor.Y, math.random(360))
						end
					end
				end
			end
		end

	end
	return table.getn(_army.IDs) < _army.strength

end
AITroopGenerator_Action = function(_player)

	local _army = MapEditor_Armies[_player]
	-- Get entityType/Category
	local eTyp = AITroopGenerator_EvaluateMilitaryBuildingsPriority(_player) or _army.AllowedTypes[math.random(table.getn(_army.AllowedTypes))]
	if _army.techLVL == 3 then
		if eTyp == Entities.PV_Cannon1 then
			eTyp = Entities.PV_Cannon3
		elseif eTyp == Entities.PV_Cannon2 then
			eTyp = Entities.PV_Cannon4
		end
	end
	if table.getn(_army.IDs) < _army.strength then
		AI.Army_BuyLeader(_player, _army.id, eTyp)
	end
	return false

end
function AITroopGenerator_GetLeader(_player)
	
	local entityID = Event.GetEntityID()		
	local playerID = Logic.EntityGetPlayer(entityID)
	
	if playerID == _player and IsMilitaryLeader(entityID) and AI.Entity_GetConnectedArmy(entityID) == -1 then
		if ArmyTable and ArmyTable[_player] then
			if table_findvalue(ArmyTable[_player], entityID) == 0 then			
				table.insert(MapEditor_Armies[_player].IDs, entityID)
				Logic.LeaderChangeFormationType(entityID, math.random(1, 7))
				Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_player, entityID})
			end
		else
			table.insert(MapEditor_Armies[_player].IDs, entityID)
			Logic.LeaderChangeFormationType(entityID, math.random(1, 7))
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_player, entityID})
		end
	end
	
end
function AITroopGenerator_RemoveLeader(_player, _id, _army)
	
	local entityID = Event.GetEntityID()		
	
	if entityID == _id then
		if _army then
			removetablekeyvalue(ArmyTable[_player][_army].IDs, entityID)		
		else
			removetablekeyvalue(MapEditor_Armies[_player].IDs, entityID)			
		end
		return true
	end
	
end
AITroopGenerator_EvaluateMilitaryBuildingsPriority = function(_player)
	
	local num = {}
	num.Barracks, num.Archery, num.Stables, num.Foundry = AI.Village_GetNumberOfMilitaryBuildings(_player)
	if MapEditor_Armies[_player].prioritylist_lastUpdate == 0 or Logic.GetTime() > MapEditor_Armies[_player].prioritylist_lastUpdate + 30 then
		local armorclasspercT = GetPercentageOfLeadersPerArmorClass(AIEnemiesAC[_player])
		for i = 1,7 do
			local bestdclass = BS.GetBestDamageClassByArmorClass(armorclasspercT[i].id)
			local ucat = GetUpgradeCategoryInDamageClass(bestdclass)
			for k,v in pairs(BS.CategoriesInMilitaryBuilding) do
				local tpos = table_findvalue(v, ucat)
				if tpos ~= 0 then
					if num[k] > 0 then						
						MapEditor_Armies[_player].prioritylist[i] = {name = k, typ = BS.CategoriesInMilitaryBuilding[k][tpos]}
					end
				end
			end
		end
		MapEditor_Armies[_player].prioritylist_lastUpdate = Logic.GetTime()
	end
	if num.Foundry > 0 and (MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(_player, Entities.PB_Foundry1, 1)})[2]) or MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(_player, Entities.PB_Foundry2, 1)})[2])) then
		return Entities["PV_Cannon".. math.random(1, 2)]
	end
	for k, v in pairs(MapEditor_Armies[_player].prioritylist) do
		local entity = ({Logic.GetPlayerEntities(_player, Entities["PB_"..v.name.."1"], 1)})[2] or ({Logic.GetPlayerEntities(_player, Entities["PB_"..v.name.."2"], 1)})[2]
		if entity then
			if MilitaryBuildingIsTrainingSlotFree(entity) then
				return v.typ
			end
		end
	end
end