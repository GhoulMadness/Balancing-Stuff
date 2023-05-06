AIEnemiesAC = AIEnemiesAC or {}
for _playerId = 2,12 do
	AIEnemiesAC[_playerId] = AIEnemiesAC[_playerId] or {}
	AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total or 0
	for i = 1,7 do
		AIEnemiesAC[_playerId][i] = AIEnemiesAC[_playerId][i] or {}
	end
end
MapEditor_SetupAI = function(_playerId, _strength, _range, _techlevel, _position, _aggressiveLevel, _peaceTime)

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
	if _techlevel == 3 then
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
		AI_InitChunks(_playerId)
	end
end
StartMapEditor_ArmyAttack = function(_playerId, _delay)

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
			range = math.max(MapEditor_Armies[_playerId].outerDefenseRange or 0, MapEditor_Armies[_playerId].rodeLength or 0)
		else
			range = MapEditor_Armies[_playerId].baseDefenseRange
		end
		if AreEntitiesOfDiplomacyStateInArea(_playerId, pos, range, Diplomacy.Hostile) then
			for i = 1, table.getn(MapEditor_Armies[_playerId].IDs) do
				local id = MapEditor_Armies[_playerId].IDs[i]
				if Logic.LeaderGetNumberOfSoldiers(id) < Logic.LeaderGetMaxNumberOfSoldiers(id) and Logic.LeaderGetNearbyBarracks(id) ~= 0 then
					(SendEvent or CSendEvent).BuySoldier(id)
				end
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					if GetDistance(GetPosition(id), pos) < 1200 + (300 * MapEditor_Armies[_playerId].aggressiveLVL) then
						ManualControl_AttackTarget(_playerId, nil, id)
					end
				end
				if MapEditor_Armies[_playerId][id] then
					if (MapEditor_Armies[_playerId][id].lasttime and (MapEditor_Armies[_playerId][id].lasttime + 3 < Logic.GetTime() ))
					or (MapEditor_Armies[_playerId][id].currenttarget and not Logic.IsEntityAlive(MapEditor_Armies[_playerId][id].currenttarget)) then
						ManualControl_AttackTarget(_playerId, nil, id)
					end
				end
			end
		else
			for i = 1, table.getn(MapEditor_Armies[_playerId].IDs) do
				local id = MapEditor_Armies[_playerId].IDs[i]
				if MapEditor_Armies[_playerId][id] and MapEditor_Armies[_playerId][id].lasttime then
					if GetDistance(GetPosition(id), pos) > 1200 + (300 * MapEditor_Armies[_playerId].aggressiveLVL) then
						local anchor = ArmyHomespots[_playerId].recruited[math.random(1, table.getn(ArmyHomespots[_playerId].recruited))]
						Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
					end
				else
					if Logic.LeaderGetNumberOfSoldiers(id) < Logic.LeaderGetMaxNumberOfSoldiers(id) then
						if not Logic.IsEntityMoving(id) then
							local barracks = GetNearestBarracks(_playerId, id)
							if GetDistance(id, barracks) > 1000 then
								Logic.MoveSettler(id, Logic.GetEntityPosition(barracks))
							end
						end
						if Logic.LeaderGetNearbyBarracks(id) ~= 0 then
							(SendEvent or CSendEvent).BuySoldier(id)
						end
					else
						if GetDistance(GetPosition(id), pos) > 1500 + (300 * MapEditor_Armies[_playerId].aggressiveLVL) then
							local anchor = ArmyHomespots[_playerId].recruited[math.random(1, table.getn(ArmyHomespots[_playerId].recruited))]
							Logic.MoveSettler(id, anchor.X, anchor.Y)
						end
					end
				end
			end
		end
	end
end
AI_InitChunks = function(_playerId)
	AIchunks[_playerId] = ChunkWrapper.new()
	AI_AddEnemiesToChunkData(_playerId)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnAIEnemyCreated", 1, {}, {_playerId})
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAIEnemyDestroyed", 1, {}, {_playerId})
	Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "OnAIDiplomacyChanged", 1, {}, {_playerId})
end
AI_AddEnemiesToChunkData = function(_playerId)

	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(BS.GetAllEnemyPlayerIDs(_playerId))), CEntityIterator.IsSettlerOrBuildingFilter()) do
		local etype = Logic.GetEntityType(eID)
		if IsMilitaryLeader(eID) or Logic.IsHero(eID) == 1 or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3
		or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 or etype == Entities.PU_Hero14_EvilTower then
			ChunkWrapper.AddEntity(AIchunks[_playerId], eID)
			table.insert(AIEnemiesAC[_playerId][GetEntityTypeArmorClass(etype)], eID)
			AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total + 1
		elseif (Logic.IsBuilding(eID) == 1 and Logic.IsEntityInCategory(eID, EntityCategories.Wall) == 0) or Logic.IsSerf(eID) == 1 then
			ChunkWrapper.AddEntity(AIchunks[_playerId], eID)
		end
	end
end
ReinitChunkData = function(_playerId)
	for k, v in pairs(AIchunks[_playerId].Entities) do
		ChunkWrapper.RemoveEntity(AIchunks[_playerId], k)
	end
	for i = 1, table.getn(AIEnemiesAC[_playerId]) do
		AIEnemiesAC[_playerId][i] = {}
		AIEnemiesAC[_playerId].total = 0
	end
	AI_AddEnemiesToChunkData(_playerId)
end
GetFirstFreeArmySlot = function(_player)
	if not (ArmyTable and ArmyTable[_player]) then
		return 0
	end
	local count
	for k, v in pairs(ArmyTable[_player]) do
		if not v or IsDead(v) then
			ArmyTable[_player][k] = nil
			ArmyHomespots[_player][k] = nil
			return k - 1
		end
		count = k - 1
	end
	return count + 1
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
	AI.Army_SetScatterTolerance(_army.player, _army.id, 0)
	AI.Army_SetSize(_army.player, _army.id, 0)
	if not AIchunks[_army.player] then
		AI_InitChunks(_army.player)
	end
end
EnlargeArmy = function(_army, _troop, _pos)

	if not ArmyTable[_army.player][_army.id + 1].IDs then
		ArmyTable[_army.player][_army.id + 1].IDs = {}
	end
	local anchor = _pos or ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
	--local id = AI.Entity_CreateFormation(_army.player, _troop.leaderType, 0, _troop.maxNumberOfSoldiers or LeaderTypeGetMaximumNumberOfSoldiers(_troop.leaderType), anchor.X, anchor.Y, 0, 0, _troop.experiencePoints or 0, _troop.minNumberOfSoldiers or 0)
	local id = CreateGroup(_army.player, _troop.leaderType, _troop.maxNumberOfSoldiers or LeaderTypeGetMaximumNumberOfSoldiers(_troop.leaderType), anchor.X, anchor.Y, 0, _troop.experiencePoints or 0)
	ConnectLeaderWithArmy(id, _army)
end
ConnectLeaderWithArmy = function(_id, _army)
	assert(IsValid(_id), "invalid leader id")
	assert(type(_army) == "table", "army must be a valid army table")
	table.insert(ArmyTable[_army.player][_army.id + 1].IDs, _id)
	if Logic.IsEntityInCategory(_id, EntityCategories.EvilLeader) ~= 1 then
		Logic.LeaderChangeFormationType(_id, math.random(1, 7))
	end
	ArmyTable[_army.player][_army.id + 1][_id] = ArmyTable[_army.player][_army.id + 1][_id] or {}
	ArmyTable[_army.player][_army.id + 1][_id].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_army.player, _id, _army.id})
end
Defend = function(_army)

	local pos = _army.position
	local range = math.max(_army.rodeLength, ArmyTable[_army.player][_army.id+1].rodeLength)
	local dist = GetNearestEnemyDistance(_army.player, pos, range)
	if dist then
		if dist <= math.min(2000, range) and not gvEMSFlag then
			Retreat(_army)
			return
		end
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
				if GetDistance(GetPosition(id), pos) < 1500 then
					ManualControl_AttackTarget(_army.player, _army.id + 1, id)
				end
			end
			if ArmyTable[_army.player][_army.id + 1][id] then
				if (ArmyTable[_army.player][_army.id + 1][id].lasttime and (ArmyTable[_army.player][_army.id + 1][id].lasttime + 3 < Logic.GetTime() ))
				or (ArmyTable[_army.player][_army.id + 1][id].currenttarget and not Logic.IsEntityAlive(ArmyTable[_army.player][_army.id + 1][id].currenttarget)) then
					ManualControl_AttackTarget(_army.player, _army.id + 1, id)
				end
			end
		end
	else
		Retreat(_army)
	end
end
Advance = function(_army)

	local enemyId = AI.Army_GetEntityIdOfEnemy(_army.player, _army.id)

	if enemyId > 0 then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetSector(id) == Logic.GetSector(enemyId) or GetNearestEnemyDistance(_army.player, GetPosition(id), _army.rodeLength) then
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					if GetDistance(GetPosition(id), _army.position) < 1500 then
						ManualControl_AttackTarget(_army.player, _army.id + 1, id)
					end
				end
				if ArmyTable[_army.player][_army.id + 1][id] then
					if (ArmyTable[_army.player][_army.id + 1][id].lasttime and (ArmyTable[_army.player][_army.id + 1][id].lasttime + 3 < Logic.GetTime() ))
					or (ArmyTable[_army.player][_army.id + 1][id].currenttarget and not Logic.IsEntityAlive(ArmyTable[_army.player][_army.id + 1][id].currenttarget)) then
						ManualControl_AttackTarget(_army.player, _army.id + 1 , id)
					end
				end
			end
		end
	else
		Retreat(_army)
	end
end
FrontalAttack = function(_army, _target)

	local enemyId = _target or AI.Army_GetEntityIdOfEnemy(_army.player, _army.id)

	if enemyId > 0 then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetSector(id) == Logic.GetSector(enemyId) then
				ArmyTable[_army.player][_army.id + 1][id] = ArmyTable[_army.player][_army.id + 1][id] or {}
				ArmyTable[_army.player][_army.id + 1][id].currenttarget = enemyId
				ArmyTable[_army.player][_army.id + 1][id].lasttime = Logic.GetTime()
				Logic.GroupAttack(id, enemyId)
			end
		end
	else
		Retreat(_army)
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
			if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE"
			or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" or Logic.GetCurrentTaskList(id) == "TL_LEADER_WALK"
			or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_DRIVE" then
				Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
			else
				Logic.MoveSettler(id, anchor.X, anchor.Y)
			end
		end
	end
end
Redeploy = function(_army, _position, _rodeLength)

	if _rodeLength then
		_army.rodeLength = _rodeLength
		ArmyTable[_army.player][_army.id + 1].rodeLength = _rodeLength
	end
	_army.position = _position
	ArmyTable[_army.player][_army.id + 1].position = _position
	ArmyHomespots[_army.player][_army.id + 1] = nil
	EvaluateArmyHomespots(_army.player, _position, _army.id + 1)
end
Synchronize = function(_army0, _army1)

	_army1.rodeLength = _army0.rodeLength
	ArmyTable[_army1.player][_army1.id + 1].rodeLength = ArmyTable[_army0.player][_army0.id + 1].rodeLength
	_army1.position = _army0.position
	ArmyTable[_army1.player][_army1.id + 1].position = ArmyTable[_army0.player][_army0.id + 1].position
	ArmyHomespots[_army1.player][_army1.id + 1] = nil
	EvaluateArmyHomespots(_army1.player, _army0.position, _army1.id + 1)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
SetupAITroopSpawnGenerator = function(_Name, _army)

	-- Setup trigger
	assert(_army.generatorID==nil, "There is already a generator registered")
	_army.generatorID = Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND,
					"AITroopSpawnGenerator_Condition",
					"AITroopSpawnGenerator_Action",
					1,
					{_Name, _army.player, _army.id},
					{_army.player, _army.id})
end
AITroopSpawnGenerator_Condition = function(_Name, _player, _id)

	local army = ArmyTable[_player][_id + 1]
	-- Not enough troops
	if Counter.Tick2(_Name,10) then

		-- First spawn done
		if army.firstSpawnDone == nil or army.firstSpawnDone == false then
			return true
		else

			if not army.IDs or (table.getn(army.IDs) < army.strength and (army.noEnemy == nil or army.noEnemy == false or GetClosestEntity(army, army.noEnemyDistance) == 0)) then
				return Counter.Tick2(_Name.."_Respawn", army.respawnTime/10)
			end
		end
	end
end
AITroopSpawnGenerator_Action = function(_player, _id)

	local army = ArmyTable[_player][_id + 1]
	-- Any current spawn index? No? Create one
	if army.spawnIndex == nil then
		army.spawnIndex = 1
	end

	-- Is any generator building there and dead...destroy this generator
	if army.spawnGenerator ~= nil and IsDead(army.spawnGenerator) then
		army.generatorID = nil
		return true
	end

	-- Get missing army count
	local missingTroops = army.strength
	if army.IDs then
		 missingTroops = army.strength - (table.getn(army.IDs) or 0)
	end

	-- Is max spawn amount set
	if army.firstSpawnDone ~= nil and army.maxSpawnAmount ~= nil then
		-- Set to max
		missingTroops = math.min(missingTroops, army.maxSpawnAmount)
	end

	-- Spawn missing army
	local i
	for i=1,missingTroops do

		-- Any data there
		if army.spawnTypes[army.spawnIndex] == nil then

			-- End of queue reached, destroy job or restart
			if army.endless ~= nil and army.endless then
				-- restart
				army.spawnIndex = 1

			else

				-- stop job
				army.generatorID = nil
				return true
			end
		end

		-- Min number...if should not refresh, number is zero
		local minNumber = army.spawnTypes[army.spawnIndex][2]
		if army.refresh ~= nil and not army.refresh then
			minNumber = 0
		end

		-- Enlarge army
		local troopDescription = {leaderType = army.spawnTypes[army.spawnIndex][1], maxNumberOfSoldiers = army.spawnTypes[army.spawnIndex][2], minNumberOfSoldiers = minNumber}
		EnlargeArmy(army, troopDescription, army.spawnPos)
		-- Next index
		army.spawnIndex = army.spawnIndex + 1

	end

	-- First spawn done
	army.firstSpawnDone = true
	return false

end
IsAITroopGeneratorDead = function(_army)
	-- Is army dead
	if IsDead(_army) then
		-- Is generator dead
		return Trigger.IsTriggerEnabled(_army.generatorID) == 0
	end
	return false
end
DestroyAITroopGenerator = function(_army)
	Trigger.UnrequestTrigger(_army.generatorID)
	_army.generatorID = nil
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	if newtarget and Logic.GetSector(newtarget) == Logic.GetSector(_id) then
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
	if Counter.Tick2(_Name.."Generator", 5 - _army.aggressiveLVL) == false or ((_army.ignoreAttack == nil or not _army.ignoreAttack) and _army.Attack)
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
						local pos = GetPosition(eID)
						if GetDistance(pos, anchor) > 500 then
							if string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(eID))), "cu") ~= nil then

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
AITroopGenerator_GetLeader = function(_player)

	local entityID = Event.GetEntityID()
	local playerID = Logic.EntityGetPlayer(entityID)

	if playerID == _player and IsMilitaryLeader(entityID) and AI.Entity_GetConnectedArmy(entityID) == -1 then
		if not ArmyTable or (ArmyTable and not ArmyTable[_player])
		or (ArmyTable and ArmyTable[_player] and table_findvalue(ArmyTable[_player], entityID) == 0) then
			Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "AITroopGenerator_CheckLeaderAttachedToBarracks", 1, {}, {_player, entityID})
		end
	end

end
AITroopGenerator_CheckLeaderAttachedToBarracks = function(_player, _id)
	if Logic.LeaderGetBarrack(_id) ~= 0 then
		table.insert(MapEditor_Armies[_player].IDs, _id)
		MapEditor_Armies[_player][_id] = MapEditor_Armies[_player][_id] or {}
		Logic.LeaderChangeFormationType(_id, math.random(1, 7))
		MapEditor_Armies[_player][_id].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_player, _id})
	end
	return true
end
AITroopGenerator_RemoveLeader = function(_player, _id, _army)

	local entityID = Event.GetEntityID()

	if entityID == _id then
		if _army then
			removetablekeyvalue(ArmyTable[_player][_army + 1].IDs, entityID)
			ArmyTable[_player][_army + 1][_id] = nil
		else
			removetablekeyvalue(MapEditor_Armies[_player].IDs, entityID)
			MapEditor_Armies[_player][_id] = nil
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