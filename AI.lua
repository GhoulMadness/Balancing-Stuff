-- table to save player entity counts per armor class
AIEnemiesAC = AIEnemiesAC or {}
for _playerId = 1,16 do
	AIEnemiesAC[_playerId] = AIEnemiesAC[_playerId] or {}
	AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total or 0
	for i = 1,7 do
		AIEnemiesAC[_playerId][i] = AIEnemiesAC[_playerId][i] or {}
	end
end

-- initializes chunk data for a given player and starts triggers to keep data up to date
---@param _playerId integer player id
AI_InitChunks = function(_playerId)
	AIchunks[_playerId] = ChunkWrapper.new()
	AI_AddEnemiesToChunkData(_playerId)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnAIEnemyCreated", 1, {}, {_playerId})
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAIEnemyDestroyed", 1, {}, {_playerId})
	Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "OnAIDiplomacyChanged", 1, {}, {_playerId})
end

AIEnemies_ExcludedTypes = {	[Entities.PU_Forester] = true,
							[Entities.PU_WoodCutter] = true}
-- adds all appropiate entities to ai chunk data for a given player
---@param _playerId integer player id
AI_AddEnemiesToChunkData = function(_playerId)

	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(BS.GetAllEnemyPlayerIDs(_playerId))), CEntityIterator.IsSettlerOrBuildingFilter()) do
		local etype = Logic.GetEntityType(eID)
		if not AIEnemies_ExcludedTypes[etype] then
			if (IsMilitaryLeader(eID) or Logic.IsHero(eID) == 1 or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3
			or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 or etype == Entities.PU_Hero14_EvilTower) then
				ChunkWrapper.AddEntity(AIchunks[_playerId], eID)
				table.insert(AIEnemiesAC[_playerId][GetEntityTypeArmorClass(etype)], eID)
				AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total + 1
			elseif (Logic.IsBuilding(eID) == 1 and Logic.IsEntityInCategory(eID, EntityCategories.Wall) == 0)
			or Logic.IsSerf(eID) == 1 or etype == Entities.PU_Travelling_Salesman then
				ChunkWrapper.AddEntity(AIchunks[_playerId], eID)
			end
		end
	end
end

-- re-calculates chunk data used for ai player armies (automatically called when player diplomacy changes)
---@param _playerId integer player id
ReinitChunkData = function(_playerId)
	for k, v in pairs(AIchunks[_playerId].Entities) do
		ChunkWrapper.RemoveEntity(AIchunks[_playerId], k)
	end
	for i = 1, table.getn(AIEnemiesAC[_playerId]) do
		AIEnemiesAC[_playerId][i] = {}
	end
	AIEnemiesAC[_playerId].total = 0
	AI_AddEnemiesToChunkData(_playerId)
end

RemoveCurrentTargetData = function(_playerID)
	if ArmyTable and ArmyTable[_playerID] then
		for k, v in pairs(ArmyTable[_playerID]) do
			for k2, v2 in pairs(v) do
				if type(k2) == "number" then
					v2.currenttarget = nil
				end
			end
		end
	end
	if MapEditor_Armies and MapEditor_Armies[_playerID] then
		for k, v in pairs(MapEditor_Armies[_playerID].defensiveArmies) do
			if type(k) == "number" then
				v.currenttarget = nil
			end
		end
		for k, v in pairs(MapEditor_Armies[_playerID].offensiveArmies) do
			if type(k) == "number" then
				v.currenttarget = nil
			end
		end
	end
end

-- creates spawn army (just the initialization, no troops)
-- (.player: army player ID, .id: army ID (0 - n), .strength: army max number of troops, .position: army position,
-- .rodeLength: army max attack range .enemySearchPosition: search enemies near this position instead of army position (optional))
---@param _army table army table
SetupArmy = function(_army)

	if not ArmyTable then
		ArmyTable = {}
	end
	if not ArmyTable[_army.player] then
		ArmyTable[_army.player] = {}
	end
	ArmyTable[_army.player][_army.id + 1] = ArmyTable[_army.player][_army.id + 1] or _army
	-- in case army already exists, fuse with existing one instead of override
	if not IsDead(_army) then
		Fuse(_army, ArmyTable[_army.player][_army.id + 1])
	else
		EvaluateArmyHomespots(_army.player, _army.position, _army.id + 1)
		AI.Army_SetScatterTolerance(_army.player, _army.id, 0)
		AI.Army_SetSize(_army.player, _army.id, 0)
		if not AIchunks[_army.player] then
			AI_InitChunks(_army.player)
		end
	end
end

--TODO: can sometimes return already used slot?

-- returns first free/unused army slot/id of given player
---@param _player integer playerID
---@return integer
GetFirstFreeArmySlot = function(_player)
	if not (ArmyTable and ArmyTable[_player]) then
		return 0
	end
	local count
	for k, v in pairs(ArmyTable[_player]) do
		if not v then
			return k - 1
		end
		count = k
	end
	return count or 0
end

-- removes currently not used army slots/ids
---@param _player integer playerID
---@return integer number of removed slots
RemoveUnusedArmySlots = function(_player)
	local count = 0
	for k, v in pairs(ArmyTable[_player]) do
		if IsDead(v) then
			RemoveArmyByID(_player, k - 1)
			count = count + 1
		end
	end
	return count
end

-- removes army data by army id
---@param _player integer playerID
---@param _id army id
RemoveArmyByID = function(_player, _id)
	ArmyTable[_player][_id + 1] = nil
	ArmyHomespots[_player][_id + 1] = nil
end

-- creates troop for spawn army
---@param _army table army table
---@param _troop table troop description (.leaderType: leader entity type, [.maxNumberOfSoldiers: leader number of soldiers, .experiencePoints: leader experience (points not level))
---@param _pos table? troop spawn position (optional, default: random army homespot)
EnlargeArmy = function(_army, _troop, _pos)

	if not ArmyTable[_army.player][_army.id + 1].IDs then
		ArmyTable[_army.player][_army.id + 1].IDs = {}
	end
	local anchor = _pos or ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
	--local id = AI.Entity_CreateFormation(_army.player, _troop.leaderType, 0, _troop.maxNumberOfSoldiers or LeaderTypeGetMaximumNumberOfSoldiers(_troop.leaderType), anchor.X, anchor.Y, 0, 0, _troop.experiencePoints or 0, _troop.minNumberOfSoldiers or 0)
	local id = CreateGroup(_army.player, _troop.leaderType, _troop.maxNumberOfSoldiers or LeaderTypeGetMaximumNumberOfSoldiers(_troop.leaderType), anchor.X, anchor.Y, 0, _troop.experiencePoints or 0)
	ConnectLeaderWithArmy(id, _army)
end

-- connects a leader with an army (either spawn army or recruiting army)
---@param _id integer entity id
---@param _army table? army table (in case you want to connect a leader with a recruiting army, use nil)
---@param _type string? recruting army type (either offensiveArmies or defensiveArmies, only use in case you want to connect a leader with a recruiting army)
ConnectLeaderWithArmy = function(_id, _army, _type)
	assert(IsValid(_id), "invalid leader id")
	assert(type(_army) == "table" or type(_type) == "string", "invalid army")
	if _army then
		table.insert(ArmyTable[_army.player][_army.id + 1].IDs, _id)
		if Logic.IsEntityInCategory(_id, EntityCategories.EvilLeader) ~= 1 then
			Logic.LeaderChangeFormationType(_id, math.random(1, 7))
		end
		ArmyTable[_army.player][_army.id + 1][_id] = ArmyTable[_army.player][_army.id + 1][_id] or {}
		ArmyTable[_army.player][_army.id + 1][_id].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_army.player, _id, _army.id})
	else
		local _player = Logic.EntityGetPlayer(_id)
		table.insert(MapEditor_Armies[_player][_type].IDs, _id)
		MapEditor_Armies[_player][_type][_id] = MapEditor_Armies[_player][_type][_id] or {}
		Logic.LeaderChangeFormationType(_id, math.random(1, 7))
		MapEditor_Armies[_player][_type][_id].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_player, _id, _type})
		MapEditor_Armies[_player][_type][_id].HomespotIndex = math.random(1, table.getn(ArmyHomespots[_player].recruited))
		local anchor = ArmyHomespots[_player].recruited[MapEditor_Armies[_player][_type][_id].HomespotIndex]
		Logic.GroupAttackMove(_id, anchor.X, anchor.Y, math.random(360))
	end
end

-- sets spawn army behavior to defensive.
-- They'll attack any enemy within their range, but not above their range. In case no enemy is wihtin their range, they'll retreat to their home position
-- called as a simple job is highly recommended
---@param _army table army table
Defend = function(_army)

	local pos = _army.position
	local range = math.max(_army.rodeLength, ArmyTable[_army.player][_army.id+1].rodeLength)
	local dist, eID = GetNearestEnemyDistance(_army.player, pos, range)
	if dist then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if GetDistance(GetPosition(id), pos) > 1500
			and dist <= math.min(3000, range) and not gvEMSFlag and eID then
				Logic.GroupAttack(id, eID)
			else
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					ManualControl_AttackTarget(_army.player, _army.id + 1, id, nil, eID)
				end
				if ArmyTable[_army.player][_army.id + 1][id] then
					if (ArmyTable[_army.player][_army.id + 1][id].lasttime and (ArmyTable[_army.player][_army.id + 1][id].lasttime + 3 < Logic.GetTime() ))
					or (ArmyTable[_army.player][_army.id + 1][id].currenttarget and not Logic.IsEntityAlive(ArmyTable[_army.player][_army.id + 1][id].currenttarget)) then
						ManualControl_AttackTarget(_army.player, _army.id + 1, id, nil, eID)
					end
				end
			end
		end
	else
		Retreat(_army)
	end
end

-- sets spawn army behavior to offensive.
-- They'll attack any enemy within their range, but also above their range. In case no enemy is left to attack, they'll retreat to their home position
-- called as a simple job is highly recommended
---@param _army table army table
Advance = function(_army)

	local enemyId = AI.Army_GetEntityIdOfEnemy(_army.player, _army.id)
	local range = Logic.WorldGetSize()
	local pos = _army.position

	if enemyId == 0 or not IsValid(enemyId) or Logic.GetSector(enemyId) ~= CUtil.GetSector(round(pos.X/100), round(pos.Y/100)) then
		enemyId = GetNearestEnemyInRange(_army.player, pos, range)
	end
	if enemyId then
		for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
			local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
			if Logic.GetSector(id) == Logic.GetSector(enemyId) or GetNearestEnemyInRange(_army.player, GetPosition(id), range) then
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					ManualControl_AttackTarget(_army.player, _army.id + 1, id, nil, enemyId)
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

-- sets spawn army behavior to offensive.
-- They'll attack the enemy given in _target param or, if not assigned, the nearest enemy
-- _target param is optional, but highly recommended to assign
-- called as a simple job is highly recommended
---@param _army table army table
---@param _target integer? target entity id that should be attacked (optional)
FrontalAttack = function(_army, _target)

	local enemyId = _target or AI.Army_GetEntityIdOfEnemy(_army.player, _army.id)
	local range = Logic.WorldGetSize()

	if enemyId > 0 then
		assert(IsValid(enemyId), "invalid enemy entityID")
	else
		enemyId = GetNearestEnemyInRange(_army.player, _army.position, range)
	end
	if enemyId and enemyId > 0 and IsValid(enemyId) then
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

-- spawn army and all of its leader retreat to its/their home position
---@param _army table army table
---@param _rodeLength number? new max attack range (optional)
Retreat = function(_army, _rodeLength)

	if _rodeLength then
		_army.rodeLength = _rodeLength
	end
	local pos = _army.position
	local groupAttackRange = 2000
	for i = 1, table.getn(ArmyTable[_army.player][_army.id + 1].IDs) do
		local id = ArmyTable[_army.player][_army.id + 1].IDs[i]
		local dist = GetDistance(GetPosition(id), pos)
		if dist > 1500 then
			local anchor = ArmyHomespots[_army.player][_army.id + 1][math.random(1, table.getn(ArmyHomespots[_army.player][_army.id + 1]))]
			if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE"
			or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE"
			and dist < _army.rodeLength - groupAttackRange then
				Logic.GroupAttackMove(id, anchor.X, anchor.Y, math.random(360))
			else
				Logic.MoveSettler(id, anchor.X, anchor.Y)
			end
		end
	end
end

-- spawn army's home spots are re-calculated to a given position
---@param _army table army table
---@param _position table position table
---@param _rodeLength number? new max attack range (optional)
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

-- copies army max attack range and position to another army
---@param _army0 table army table of army data that should be copied
---@param _army1 table army table of army data that should be adjusted
Synchronize = function(_army0, _army1)

	_army1.rodeLength = _army0.rodeLength
	ArmyTable[_army1.player][_army1.id + 1].rodeLength = ArmyTable[_army0.player][_army0.id + 1].rodeLength
	_army1.position = _army0.position
	ArmyTable[_army1.player][_army1.id + 1].position = ArmyTable[_army0.player][_army0.id + 1].position
	ArmyHomespots[_army1.player][_army1.id + 1] = nil
	EvaluateArmyHomespots(_army1.player, _army0.position, _army1.id + 1)
end

-- fuses army data so army data can be extended and not be overwritten
---@param _army0 table army table of army data that should be fused into another army, will be equalized at end of process
---@param _army1 table army table of army data that should be extended
Fuse = function(_army0, _army1)

	assert(_army0.player == _army1.player, "both armies must belong to the same player!")
	_army1.rodeLength = _army0.rodeLength
	_army1.position = _army0.position
	_army1.strength = _army1.strength + _army0.strength
	if _army0.id ~= _army1.id and ArmyTable[_army0.player][_army0.id] then
		ArmyTable[_army1.player][_army1.id + 1].rodeLength = ArmyTable[_army0.player][_army0.id + 1].rodeLength
		ArmyTable[_army1.player][_army1.id + 1].position = ArmyTable[_army0.player][_army0.id + 1].position
	end
	if _army0.position.X ~= _army1.position.X or _army0.position.Y ~= _army1.position.Y then
		ArmyHomespots[_army1.player][_army1.id + 1] = nil
		EvaluateArmyHomespots(_army1.player, _army0.position, _army1.id + 1)
	end
	_army0 = _army1
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create ai troop generator: Spawn all troops at the beginning and refill every respawn
--
-- .strength = spawn up to this troops
--
-- .spawnTypes = Table of to spawn units,    one element { Leader Type, soldier amount }
-- .endless = restart at table start if end of list reached, else destroy generator
--
-- .spawnPos = Where should be the units spawned
-- .spawnGenerator = Which object is spawning units...optional
--
-- .respawnTime = time to respawn to full strength...spawn missing troops
--
-- .refresh = refresh soldiers to full strength if group is damaged...optional, true on default
-- .maxSpawnAmount = optional...if not given, all missings units respawned, will be ignored at first spawn
--
-- .noEnemy = if true it will spawn troops only if no enemy near...optional
-- .noEnemyDistance = check for enemies in this distance
--
---@param _Name string Counter tick name (should be unique)
---@param _army table army table
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
-- checks whether army troop generator is active or not (either recruitment army or spawn troops army)
---@param _army table army table
---@return boolean
IsAITroopGeneratorDead = function(_army)
	-- Is army dead
	if IsDead(_army) then
		-- Is generator dead
		return Trigger.IsTriggerEnabled(_army.generatorID) == 0
	end
	return false
end

-- removes a army troop generator (either recruitment army or spawn troops army)
---@param _army table army table
DestroyAITroopGenerator = function(_army)
	Trigger.UnrequestTrigger(_army.generatorID)
	_army.generatorID = nil
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- function to control armies' attack target and to give the respective command
ManualControl_AttackTarget = function(_player, _armyId, _id, _type, _target)

	local tabname, range, pos, newtarget, IsMelee, etype, dist
	etype = Logic.GetEntityType(_id)
	local f = function(_tab, _ntarget)
		if not _tab.currenttarget and _ntarget then
			_tab.currenttarget = _ntarget
		else
			if _tab.currenttarget and _tab.currenttarget ~= _ntarget and _ntarget then
				_tab.currenttarget = _ntarget
			end
		end
		_tab.lasttime = Logic.GetTime()
	end

	if not _armyId then
		tabname = MapEditor_Armies[_player][_type]
		range = tabname.baseDefenseRange
	else
		tabname = ArmyTable[_player][_armyId]
		range = tabname.rodeLength
	end
	pos = GetPosition(_id)
	newtarget = CheckForBetterTarget(_id, tabname[_id] and tabname[_id].currenttarget, nil)
				or GetNearestEnemyInRange(_player, pos, range - GetDistance(pos, tabname.enemySearchPosition or tabname.position))
				or GetNearestTarget(_player, _id)

	tabname[_id] = tabname[_id] or {}

	IsMelee = (Logic.IsEntityInCategory(_id, EntityCategories.Melee) == 1)
	IsAntiBuildingCannon = (gvAntiBuildingCannonsRange[etype] ~= nil)
	dist = GetDistance(_id, newtarget)

	if newtarget and newtarget > 0 then
		if IsMelee then
			if Logic.GetSector(newtarget) == Logic.GetSector(_id) then
				if dist > range then
					if _target then
						f(tabname[_id], _target)
						Logic.GroupAttack(_id, _target)
					end
				else
					f(tabname[_id], newtarget)
					Logic.GroupAttack(_id, newtarget)
				end
			end

		else
			if dist > range then
				if _target then
					f(tabname[_id], _target)
					Logic.GroupAttack(_id, _target)
				end
			else
				if IsAntiBuildingCannon then
					local maxrange = GetEntityTypeBaseAttackRange(etype)
					if dist > maxrange + 200 and dist < maxrange * 2 then
						if not Logic.IsEntityMoving(_id) then
							RetreatToMaxRange(_id, newtarget, maxrange * 9/10)
						end
					else
						Logic.GroupAttack(_id, newtarget)
					end
				else
					Logic.GroupAttack(_id, newtarget)
				end
				f(tabname[_id], newtarget)
			end
		end
	else
		if _target then
			f(tabname[_id], _target)
			Logic.GroupAttack(_id, _target)
		end
	end
end
--------------------------------------------------------------------------------------
-- function to initialize recruited armies for given playerID
-- army splits into offensive armies and defensive armies (roughly 5:1)
---@param _playerId integer playerID
---@param _strength integer army strength (1 - 3), affects troop limit, serf limit, start resources, resource refresh rates and rebuild delays
---@param _range number army maximum attack range
---@param _techlevel integer army techLVL (0 - 3), affects troop types recruited
---@param _position string entityID name defining army center position (any playerID must be nearby)
---@param _aggressiveLevel integer army aggressiveLVL (0 - 3), affects how close leader will gather near center pos and how fast troops are recruited
---@param _peaceTime integer time in seconds army will be more passive and has a smaller action range
---@param _multiTrain boolean? allows or forbids the player to recruit leader in multiple military buildings of the same type simultanously (optional, default: true)
---@param _defenseRange number? defines maximum attack range during army peace time and used for defense armies (optional, default: max range * 2/3)
---@param _attackPosition table? army will start searching enemies near this position instead of army position (optional)
MapEditor_SetupAI = function(_playerId, _strength, _range, _techlevel, _position, _aggressiveLevel, _peaceTime, _multiTrain, _defenseRange, _attackPosition)

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

	local CannonEntityType1, CannonEntityType2
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
		MapEditor_Armies.controlerId = {offensiveArmies = {}, defensiveArmies = {}}
	end
	if not MapEditor_Armies[_playerId] then
		MapEditor_Armies[_playerId] = {
			description = {

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
					gold				=	_strength*1300,
					clay				=	_strength*400,
					iron				=	_strength*1100,
					sulfur				=	_strength*550,
					stone				=	_strength*400,
					wood				=	_strength*750,
					updateTime			=	math.floor(30/_strength)
				},
				--------------------------------------------------
				constructing			=	true,
				--------------------------------------------------
				rebuild = {
					delay				=	30*(5-_strength),
					randomTime			=	15*(5-_strength)
				},
			},
			prioritylist = {},
			prioritylist_lastUpdate = 0,
			multiTraining = _multiTrain or true,
			player = _playerId,
			id = 0,
			techLVL = _techlevel,
			aggressiveLVL =	_aggressiveLevel,
			ForbiddenTypes = {},
			offensiveArmies = {strength	= _strength * 15,
								position = position,
								enemySearchPosition = _attackPosition,
								rodeLength = _range,
								baseDefenseRange = _defenseRange or (_range*2)/3,
								AttackAllowed =	false,
								IDs	= {}
								},
			defensiveArmies = {strength	= _strength * 3,
								position = position,
								baseDefenseRange = math.min(_range, _defenseRange or 5000),
								IDs	= {}
								}
		}
	end

	SetupPlayerAi(_playerId, MapEditor_Armies[_playerId].description)
	EvaluateArmyHomespots(_playerId, position, nil)

	-- troop recruitment generator
	SetupAITroopGenerator("MapEditor_Armies_".._playerId, _playerId)
	Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND, nil, "StartMapEditor_ArmyAttack", 1, nil, {_playerId, _peaceTime})
	if MapEditor_Armies.controlerId.offensiveArmies[_playerId] == nil then
		MapEditor_Armies.controlerId.offensiveArmies[_playerId] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "ControlMapEditor_Armies", 1, {}, {_playerId, "offensiveArmies"})
	end
	if MapEditor_Armies.controlerId.defensiveArmies[_playerId] == nil then
		MapEditor_Armies.controlerId.defensiveArmies[_playerId] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "ControlMapEditor_Armies", 1, {}, {_playerId, "defensiveArmies"})
	end
	if not AIchunks[_playerId] then
		AI_InitChunks(_playerId)
	end
end
StartMapEditor_ArmyAttack = function(_playerId, _delay)

	if Counter.Tick2("StartMapEditor_ArmyAttack".._playerId, _delay) then
		MapEditor_Armies[_playerId].offensiveArmies.AttackAllowed = true
		return true
	end

end
ControlMapEditor_Armies = function(_playerId, _type)

	if MapEditor_Armies[_playerId] and MapEditor_Armies[_playerId][_type] then
		local pos = MapEditor_Armies[_playerId][_type].position
		local range
		if MapEditor_Armies[_playerId][_type].AttackAllowed then
			range = MapEditor_Armies[_playerId][_type].rodeLength
		else
			range = MapEditor_Armies[_playerId][_type].baseDefenseRange
		end
		local dist, eID = GetNearestEnemyDistance(_playerId, pos, range)
		if dist and dist <= range then
			for i = 1, table.getn(MapEditor_Armies[_playerId][_type].IDs) do
				local id = MapEditor_Armies[_playerId][_type].IDs[i]
				local tab = MapEditor_Armies[_playerId][_type][id]
				local barracks = Logic.LeaderGetNearbyBarracks(id)
				if Logic.LeaderGetNumberOfSoldiers(id) < Logic.LeaderGetMaxNumberOfSoldiers(id) and barracks ~= 0 and MilitaryBuildingIsTrainingSlotFree(barracks) then
					(SendEvent or CSendEvent).BuySoldier(id)
				end
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					if GetDistance(GetPosition(id), pos) < 1500 + (100 * MapEditor_Armies[_playerId].aggressiveLVL)
					and (tab.RecruitmentComplete or Logic.IsHero(id) == 1 or Logic.IsEntityInCategory(id, EntityCategories.Cannon) == 1
					or IsVeteranLeader(id)) then
						ManualControl_AttackTarget(_playerId, nil, id, _type, eID)
						tab.HomespotReached = tab.HomespotReached or true
					end
				end
				if tab then
					if (tab.lasttime and (tab.lasttime + 3 < Logic.GetTime() ) and not Logic.IsEntityMoving(id))
					or (tab.lasttime and (tab.lasttime + 10 < Logic.GetTime() ))
					or (tab.currenttarget and not Logic.IsEntityAlive(tab.currenttarget)) then
						ManualControl_AttackTarget(_playerId, nil, id, _type, eID)
						tab.HomespotReached = tab.HomespotReached or true
					end
				end
			end
		else
			for i = 1, table.getn(MapEditor_Armies[_playerId][_type].IDs) do
				local id = MapEditor_Armies[_playerId][_type].IDs[i]
				local tab = MapEditor_Armies[_playerId][_type][id]
				if tab and tab.lasttime then
					if GetDistance(GetPosition(id), pos) > 1500 + (100 * MapEditor_Armies[_playerId].aggressiveLVL) then
						local anchor = ArmyHomespots[_playerId].recruited[tab.HomespotIndex]
						Logic.MoveSettler(id, anchor.X, anchor.Y)
						tab.HomespotReached = tab.HomespotReached or true
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
						if GetDistance(GetPosition(id), pos) > 1500 + (100 * MapEditor_Armies[_playerId].aggressiveLVL)
						and tab.RecruitmentComplete then
							local anchor = ArmyHomespots[_playerId].recruited[tab.HomespotIndex]
							Logic.MoveSettler(id, anchor.X, anchor.Y)
							tab.HomespotReached = tab.HomespotReached or true
						end
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- checks whether recruitment army is at or above troop limit
---@param _army table army table
---@return boolean
AITroopGenerator_IsAtTroopLimit = function(_army)
	local numtroops = table.getn(_army.offensiveArmies.IDs) + table.getn(_army.defensiveArmies.IDs)
	local maxstrength = _army.offensiveArmies.strength + _army.defensiveArmies.strength
	return numtroops >= maxstrength
end

-- checks whether recruitment army is below troop limit
---@param _army table army table
---@return boolean
AITroopGenerator_IsBelowTroopLimit = function(_army)
	return not AITroopGenerator_IsAtTroopLimit(_army)
end

-- initialize recruitment army jobs
SetupAITroopGenerator = function(_Name, _player)
	-- Setup trigger
	assert(MapEditor_Armies[_player].generatorID == nil, "There is already a generator registered")
	MapEditor_Armies[_player].generatorID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "AITroopGenerator_Condition", "AITroopGenerator_Action", 1, {_Name, _player}, {_player})
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "AITroopGenerator_GetLeader", 1, {}, {_player})
end

-- condition and action job for recruitment army troop recruiting
AITroopGenerator_Condition = function(_Name, _player)

	local _army = MapEditor_Armies[_player]
	-- Already enough troops?
	local limitreached = AITroopGenerator_IsAtTroopLimit(_army)
	if Counter.Tick2(_Name.."Generator", 5 - _army.aggressiveLVL) == false or ((_army.ignoreAttack == nil or not _army.ignoreAttack) and _army.Attack) then
		return false
	end
	return not limitreached

end
AITroopGenerator_Action = function(_player)

	local _army = MapEditor_Armies[_player]
	local belowlimit = AITroopGenerator_IsBelowTroopLimit(_army)
	if belowlimit then
		local silver = Logic.GetPlayersGlobalResource(_player, ResourceType.SilverRaw) + Logic.GetPlayersGlobalResource(_player, ResourceType.Silver)
		local coal = Logic.GetPlayersGlobalResource(_player, ResourceType.Knowledge)
		-- Get entityType/Category (cannon = etype; else ucat)
		local eTyp, id = AITroopGenerator_EvaluateMilitaryBuildingsPriority(_player, _army.ForbiddenTypes)

		if eTyp then
			if _army.techLVL == 3 then
				if eTyp == Entities.PV_Cannon1 then
					if silver >= 100 and coal >= 500 then
						eTyp = Entities.PV_Cannon5
					else
						eTyp = Entities.PV_Cannon3
					end
				elseif eTyp == Entities.PV_Cannon2 then
					if silver >= 150 and coal >= 500 then
						eTyp = Entities.PV_Cannon6
					else
						eTyp = Entities.PV_Cannon4
					end
				end
			end

			if _army.multiTraining and id then
				if IsCannonType(eTyp) then
					(SendEvent or CSendEvent).BuyCannon(id, eTyp)
				else
					Logic.BarracksBuyLeader(id, eTyp)
				end
			else
				AI.Army_BuyLeader(_player, _army.id, eTyp)
			end
		end
	end
	return false

end

-- entity created triggers for armies (delays for attachment check and idle check)
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
		local _type
		local tab = MapEditor_Armies[_player]
		if Logic.IsEntityInCategory(_id, EntityCategories.Cannon) == 1 then
			_type = "offensiveArmies"
		end
		if not _type then
			if table.getn(tab.defensiveArmies.IDs) < tab.defensiveArmies.strength then
				_type = "defensiveArmies"
			else
				_type = "offensiveArmies"
			end
		end
		table.insert(tab[_type].IDs, _id)
		tab[_type][_id] = tab[_type][_id] or {}
		Logic.LeaderChangeFormationType(_id, math.random(1, 7))
		tab[_type][_id].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_player, _id, _type})
		tab[_type][_id].IdleCheck = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "AITroopGenerator_CheckForIdle", 1, {}, {_player, _id, _type})
		tab[_type][_id].HomespotIndex = math.random(1, table.getn(ArmyHomespots[_player].recruited))
	end
	return true
end
AITroopGenerator_CheckForIdle = function(_player, _id, _spec)

	if not IsValid(_id) then
		return true
	end
	local tab = MapEditor_Armies[_player][_spec][_id]
	if tab.HomespotReached == true then
		return true
	end
	if Logic.GetCurrentTaskList(_id) == "TL_MILITARY_IDLE"
	or (Logic.GetCurrentTaskList(_id) == "TL_VEHICLE_IDLE" and not next(CEntity.GetReversedAttachedEntities(_id))) then

		local index = (tab and tab.HomespotIndex) or math.random(1, table.getn(ArmyHomespots[_player].recruited))
		local anchor = ArmyHomespots[_player].recruited[index]
		local pos = GetPosition(_id)
		local MilitaryBuildingID = Logic.LeaderGetNearbyBarracks(_id)

		if MilitaryBuildingID ~= 0 then
			if Logic.IsConstructionComplete(MilitaryBuildingID) == 1 then
				if Logic.IsEntityInCategory(_id, EntityCategories.Cannon) == 1
				or (Logic.LeaderGetNumberOfSoldiers(_id) == Logic.LeaderGetMaxNumberOfSoldiers(_id) and AreAllSoldiersOfLeaderDetachedFromMilitaryBuilding(_id)) then
					Logic.GroupAttackMove(_id, anchor.X, anchor.Y, math.random(360))
					tab.RecruitmentComplete = true
				end
			end
		end
		-- first attempt to reach homespot failed (e.g. due to enemies on the way)
		if tab.RecruitmentComplete and Counter.Tick2("AITroopGenerator_CheckForIdle_" .. _id, 5) then
			Logic.GroupAttackMove(_id, anchor.X, anchor.Y, math.random(360))
		end

	end
end

ControlMapEditor_Armies_Barracks = function(_barrackID)
	if not IsValid(_barrackID) then
		return true
	end
	local attach = CEntity.GetAttachedEntities(_barrackID)[42]
	if (attach and next(attach)) then
		for i = 1,table.getn(attach) do
			if Logic.IsLeader(attach[i]) == 0 then
				if Logic.GetEntityHealth(attach[i]) == 0 or not CEntity.GetAttachedEntities(attach[i])[31] then
					Logic.DestroyEntity(attach[i])
				end
			end
		end
	end
	local attach = CEntity.GetAttachedEntities(_barrackID)[9]
	if (attach and next(attach)) then
		for i = 1,table.getn(attach) do
			if Logic.IsLeader(attach[i]) == 0 then
				if Logic.GetEntityHealth(attach[i]) == 0 or not CEntity.GetAttachedEntities(attach[i])[31] then
					Logic.DestroyEntity(attach[i])
				end
			end
		end
	end
end

-- entity destroyed trigger to update respective army tables
AITroopGenerator_RemoveLeader = function(_player, _id, _spec)

	local entityID = Event.GetEntityID()

	if entityID == _id then
		if type(_spec) == "number" then
			removetablekeyvalue(ArmyTable[_player][_spec + 1].IDs, entityID)
			ArmyTable[_player][_spec + 1][_id] = nil
		else
			removetablekeyvalue(MapEditor_Armies[_player][_spec].IDs, entityID)
			MapEditor_Armies[_player][_spec][_id] = nil
		end
		return true
	end

end

-- updates and returns best counter measures (based on troop entity type) against enemy troop types
-- to evaluate which troop type should be recruited
-- obviously only for recruitment armies
---@param _player integer playerID
---@param _forbiddenTypes table? table filled with forbidden recruitment types (optional)
---@return integer entity type
---@return integer military building entity id (only when army has multi train activated, otherwise returns nil)
AITroopGenerator_EvaluateMilitaryBuildingsPriority = function(_player, _forbiddenTypes)

	local num = {}
	num.Barracks, num.Archery, num.Stable, num.Foundry = AI.Village_GetNumberOfMilitaryBuildings(_player)
	if MapEditor_Armies[_player].prioritylist_lastUpdate == 0 or Logic.GetTime() > MapEditor_Armies[_player].prioritylist_lastUpdate + 30 then
		local armorclasspercT = GetPercentageOfLeadersPerArmorClass(AIEnemiesAC[_player])
		for i = 1,7 do
			local bestdclass = BS.GetBestDamageClassByArmorClass(armorclasspercT[i].id)
			local ucat = GetUpgradeCategoryInDamageClass(bestdclass)
			for k,v in pairs(BS.CategoriesInMilitaryBuilding) do
				local tpos = table_findvalue(v, ucat)
				if tpos ~= 0 then
					if num[k] > 0 then
						if table_findvalue(_forbiddenTypes, v[tpos]) == 0 then
							MapEditor_Armies[_player].prioritylist[i] = {name = k, typ = v[tpos]}
						else
							table.remove(MapEditor_Armies[_player].prioritylist, i)
						end
					end
				end
			end
		end
		MapEditor_Armies[_player].prioritylist_lastUpdate = Logic.GetTime()
	end
	if MapEditor_Armies[_player].multiTraining then
		if num.Foundry > 0 then
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyTypeFilter(Entities.PB_Foundry1, Entities.PB_Foundry2)) do
				if MilitaryBuildingIsTrainingSlotFree(id) then
					local types = {Entities.PV_Cannon1, Entities.PV_Cannon2}
					for i = table.getn(types), 1, -1 do
						if table_findvalue(_forbiddenTypes, types[i]) > 0 then
							table.remove(types, i)
						end
					end
					return (next(types) and types[math.random(1, table.getn(types))]), id
				end
			end
		end
		for k, v in pairs(MapEditor_Armies[_player].prioritylist) do
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyTypeFilter(Entities["PB_"..v.name.."1"], Entities["PB_"..v.name.."2"])) do
				if MilitaryBuildingIsTrainingSlotFree(id) then
					return v.typ, id
				end
			end
		end
	else
		if num.Foundry > 0 and (MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(_player, Entities.PB_Foundry1, 1)})[2]) or MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(_player, Entities.PB_Foundry2, 1)})[2])) then
			local types = {Entities.PV_Cannon1, Entities.PV_Cannon2}
			for i = table.getn(types), 1, -1 do
				if table_findvalue(_forbiddenTypes, types[i]) > 0 then
					table.remove(types, i)
				end
			end
			return (next(types) and types[math.random(1, table.getn(types))])
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
end
--------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Triggers for general AI data --------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
gvAntiBuildingCannonsRange = {	[Entities.PV_Cannon2] = 0,
								[Entities.PV_Cannon4] = 0,
								[Entities.PV_Cannon6] = -2000,
								[Entities.PV_Catapult] = -1000}
for k,v in pairs(gvAntiBuildingCannonsRange) do
	gvAntiBuildingCannonsRange[k] = math.ceil(v + (GetEntityTypeBaseAttackRange(k)/3))
end

function OnAIEnemyCreated(_playerID)

	local entityID = Event.GetEntityID()
	local playerID = Logic.EntityGetPlayer(entityID)
	local etype = Logic.GetEntityType(entityID)
	local enemies = BS.GetAllEnemyPlayerIDs(_playerID)

	for i = 1, table.getn(enemies) do
		if playerID == enemies[i] then
			if not AIEnemies_ExcludedTypes[etype] then
				if (IsMilitaryLeader(entityID) or Logic.IsHero(entityID) == 1 or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3
				or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 or etype == Entities.PU_Hero14_EvilTower) then
					ChunkWrapper.AddEntity(AIchunks[_playerID], entityID)
					table.insert(AIEnemiesAC[_playerID][GetEntityTypeArmorClass(etype)], entityID)
					AIEnemiesAC[_playerID].total = AIEnemiesAC[_playerID].total + 1
					break
				elseif (Logic.IsBuilding(entityID) == 1 and Logic.IsEntityInCategory(entityID, EntityCategories.Wall) == 0 and not IsInappropiateBuilding(entityID))
				or Logic.IsSerf(entityID) == 1 or etype == Entities.PU_Travelling_Salesman then
					ChunkWrapper.AddEntity(AIchunks[_playerID], entityID)
					break
				end
			end
		end
	end
end
function OnAIEnemyDestroyed(_playerID)

	local entityID = Event.GetEntityID()
	local playerID = Logic.EntityGetPlayer(entityID)
	local etype = Logic.GetEntityType(entityID)
	local enemies = BS.GetAllEnemyPlayerIDs(_playerID)

	for i = 1, table.getn(enemies) do
		if playerID == enemies[i] then
			if not AIEnemies_ExcludedTypes[etype] then
				if (IsMilitaryLeader(entityID) or etype == Entities.PB_Tower2 or etype == Entities.PB_Tower3
				or etype == Entities.PB_DarkTower2 or etype == Entities.PB_DarkTower3 or etype == Entities.PU_Hero14_EvilTower) then
					ChunkWrapper.RemoveEntity(AIchunks[_playerID], entityID)
					removetablekeyvalue(AIEnemiesAC[_playerID][GetEntityTypeArmorClass(etype)], entityID)
					AIEnemiesAC[_playerID].total = AIEnemiesAC[_playerID].total - 1
					break
				elseif (Logic.IsBuilding(entityID) == 1 and Logic.IsEntityInCategory(entityID, EntityCategories.Wall) == 0 and not IsInappropiateBuilding(entityID))
				or Logic.IsSerf(entityID) == 1 or etype == Entities.PU_Travelling_Salesman then
					ChunkWrapper.RemoveEntity(AIchunks[_playerID], entityID)
					break
				end
			end
		end
	end
end
function OnAIDiplomacyChanged(_playerID)
	local p = Event.GetSourcePlayerID()
	local p2 = Event.GetTargetPlayerID()
	local state = Event.GetDiplomacyState()

	if p == _playerID or p2 == _playerID then
		ReinitChunkData(_playerID)
		RemoveCurrentTargetData(_playerID)
	end
end
function AITower_RedirectTarget()

	local attacker = Event.GetEntityID1()
	local target = Event.GetEntityID2()
	local playerID = Logic.EntityGetPlayer(attacker)

	if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(playerID) == 0 and AIchunks[playerID] then

		if Logic.IsEntityInCategory(attacker, EntityCategories.MilitaryBuilding) == 1 then
			local newtarget = CheckForBetterTarget(attacker, target)
			if newtarget and Logic.IsEntityAlive(newtarget) then
				Logic.GroupAttack(attacker, newtarget)
			end
		end
	end

end