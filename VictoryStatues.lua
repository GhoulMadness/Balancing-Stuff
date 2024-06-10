---------------------------------------------------------------------------
------------------------------ Victory Statues ----------------------------
---------------------------------------------------------------------------
gvVStatue1 = gvVStatue1 or {}

-- max. amount statues allowed per player
gvVStatue1.Limit = 1
gvVStatue1.Amount = {}
for i = 1,16 do
	gvVStatue1.Amount[i] = 0
end
---------------------------------------------------------------------------
gvVStatue2 = gvVStatue2 or {}

-- max. amount statues allowed per player
gvVStatue2.Limit = 1
gvVStatue2.Amount = {}
for i = 1,16 do
	gvVStatue2.Amount[i] = 0
end
---------------------------------------------------------------------------
gvVStatue3 = gvVStatue3 or {}

gvVStatue3.BaseValue = 0.5
gvVStatue3.DecreaseValue = 0.1
gvVStatue3.MinimumValue = 0.1
gvVStatue3.Amount = {}
gvVStatue3.AmountConstructed = {}
for i = 1,16 do
	gvVStatue3.Amount[i] = 0
	gvVStatue3.AmountConstructed[i] = 0
end
---------------------------------------------------------------------------
gvVStatue4 = gvVStatue4 or {}

gvVStatue4.MaxRange = 1500
gvVStatue4.DamageFactor = 0.90
-- blocked range in scm, also depends on map size squared
gvVStatue4.BlockRange = 700 + math.floor(((Logic.WorldGetSize()/80)^2)/400)
-- max. amount statues allowed per player
gvVStatue4.Limit = 5
gvVStatue4.PositionTable = {}
gvVStatue4.Amount = {}
for i = 1,16 do
	gvVStatue4.Amount[i] = 0
end
function VStatue4_CalculateDamageTrigger(_EntityID, _PlayerID)

	if Logic.IsEntityDestroyed(_EntityID) then
		return true
	end

	local attacker = Event.GetEntityID1()
    local target = Event.GetEntityID2()
	local targetPID = Logic.EntityGetPlayer(target)
	local dipstate = Logic.GetDiplomacyState(Logic.EntityGetPlayer(attacker), targetPID)

	if dipstate == Diplomacy.Hostile then

		if targetPID == _PlayerID or Logic.GetDiplomacyState(_PlayerID, targetPID) == Diplomacy.Friendly then
			if GetDistance(GetPosition(_EntityID), GetPosition(attacker)) <= gvVStatue4.MaxRange then

				local dmg = CEntity.TriggerGetDamage()
				CEntity.TriggerSetDamage(math.ceil(dmg * gvVStatue4.DamageFactor))
			end
		end
	end
end
---------------------------------------------------------------------------
gvVStatue5 = gvVStatue5 or {}

-- max. amount statues allowed per player
gvVStatue5.Limit = 1
gvVStatue5.Amount = {}
for i = 1,16 do
	gvVStatue5.Amount[i] = 0
end
---------------------------------------------------------------------------
gvVStatue6 = gvVStatue6 or {}

gvVStatue6.MaxRange = 1800
gvVStatue6.ConeAngleMin = -30
gvVStatue6.ConeAngleMax = 30
gvVStatue6.Damage = 50
gvVStatue6.DamageRange = 500
gvVStatue6.TickDelayInSec = 5
-- blocked range in scm, also depends on map size squared
gvVStatue6.BlockRange = 700 + math.floor(((Logic.WorldGetSize()/80)^2)/400)
-- max. amount statues allowed per player
gvVStatue6.Limit = 5
gvVStatue6.PositionTable = {}
gvVStatue6.Amount = {}
for i = 1,16 do
	gvVStatue6.Amount[i] = 0
end
function VStatue6_ApplyDamageTrigger(_EntityID, _PlayerID)

	if Logic.IsEntityDestroyed(_EntityID) then
		return true
	end

	if Counter.Tick2("VStatue6_ApplyDamageTrigger_" .. _EntityID .. "_Counter", gvVStatue6.TickDelayInSec) then
		local pos = GetPosition(_EntityID)
		local enemy = GetNearestEnemyInRangeAndCone(_PlayerID, pos, math.mod(Logic.GetEntityOrientation(_EntityID) + 180, 360), gvVStatue6.ConeAngleMax, gvVStatue6.MaxRange)

		if enemy then
			local eposX, eposY = Logic.GetEntityPosition(enemy)
			CEntity.DealDamageInArea(_EntityID, eposX, eposY, gvVStatue6.DamageRange, gvVStatue6.Damage)
			-- TODO: create some effect?
		end
	end
end
---------------------------------------------------------------------------
gvVStatue7 = gvVStatue7 or {}

gvVStatue7.Range = 1200
gvVStatue7.FortressTypes = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3}
-- max. amount statues allowed per player
gvVStatue7.Limit = 1
gvVStatue7.Countdown = {}
gvVStatue7.Amount = {}
for i = 1,16 do
	gvVStatue7.Amount[i] = 0
end
gvVStatue7.IsPlacementAllowed = function(_player, _x, _y)
	local playerIDs = BS.GetAllEnemyPlayerIDs(_player)
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(playerIDs)),
	CEntityIterator.OfAnyTypeFilter(unpack(gvVStatue7.FortressTypes)),
	CEntityIterator.InCircleFilter(_x, _y, gvVStatue7.Range)) do
		return true
	end
	return false
end
gvVStatue7.VictoryTimer = function(_player)
	local enemies = BS.GetAllEnemyPlayerIDs(_player)
	local allies = BS.GetAllAlliedPlayerIDs(_player)
	table.insert(allies, _player)
	for i = 1, table.getn(enemies) do
		Logic.PlayerSetGameStateToLost(enemies[i])
	end
	for i = 1, table.getn(allies) do
		Logic.PlayerSetGameStateToWon(allies[i])
	end
end
gvVStatue7.Placed = function(_player, _x, _y)
	GUI.ScriptSignal(_x, _y, 1)
	GUI.CreateMinimapPulse(_x, _y, 1)

	local playerIDs = BS.GetAllEnemyPlayerIDs(_player)
	for i in playerIDs do
		local gvViewCenterID = {}
		gvViewCenterID[i] = Logic.CreateEntity(Entities.XD_ScriptEntity, _x - (i/100), _y - (i/100), playerIDs[i], 0)
		Logic.SetEntityExplorationRange(gvViewCenterID[i], 10)
	end
end
---------------------------------------------------------------------------
gvVStatue8 = gvVStatue8 or {}

gvVStatue8.MaxRange = 1200
gvVStatue8.DamageFactor = 1.05
-- blocked range in scm, also depends on map size squared
gvVStatue8.BlockRange = 700 + math.floor(((Logic.WorldGetSize()/80)^2)/400)
-- max. amount statues allowed per player
gvVStatue8.Limit = 5
gvVStatue8.PositionTable = {}
gvVStatue8.Amount = {}
for i = 1,16 do
	gvVStatue8.Amount[i] = 0
end
function VStatue8_CalculateDamageTrigger(_EntityID, _PlayerID)

	if Logic.IsEntityDestroyed(_EntityID) then
		return true
	end

	local attacker = Event.GetEntityID1()
    local target = Event.GetEntityID2()
	local attackerPID = Logic.EntityGetPlayer(attacker)
	local dipstate = Logic.GetDiplomacyState(Logic.EntityGetPlayer(attacker), targetPID)

	if dipstate == Diplomacy.Hostile then

		if attackerPID == _PlayerID or Logic.GetDiplomacyState(_PlayerID, attackerPID) == Diplomacy.Friendly then
			if GetDistance(GetPosition(_EntityID), GetPosition(target)) <= gvVStatue8.MaxRange then

				local dmg = CEntity.TriggerGetDamage()
				CEntity.TriggerSetDamage(math.ceil(dmg * gvVStatue8.DamageFactor))
			end
		end
	end
end
---------------------------------------------------------------------------
gvVStatue9 = gvVStatue9 or {}

gvVStatue9.ScareEffectivenessFactor = 0.9
-- max. amount statues allowed per player
gvVStatue9.Limit = 5
gvVStatue9.Amount = {}
gvVStatue9.AmountConstructed = {}
for i = 1,16 do
	gvVStatue9.Amount[i] = 0
	gvVStatue9.AmountConstructed[i] = 0
end
----------------------------------------------------------------------------
function OnVStatuesCreated()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType > 0 then
		local playerID = GetPlayer(entityID)
		local pos = GetPosition(entityID)

		if entityType == Entities.PB_VictoryStatue1 then
			gvVStatue1.Amount[playerID] = gvVStatue1.Amount[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue2 then
			gvVStatue2.Amount[playerID] = gvVStatue2.Amount[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue3 then
			gvVStatue3.AmountConstructed[playerID] = gvVStatue3.AmountConstructed[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue4 then
			table.insert(gvVStatue4.PositionTable,pos)
			gvVStatue4.Amount[playerID] = gvVStatue4.Amount[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue5 then
			gvVStatue5.Amount[playerID] = gvVStatue5.Amount[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue6 then
			table.insert(gvVStatue6.PositionTable,pos)
			gvVStatue6.Amount[playerID] = gvVStatue6.Amount[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue7 then
			gvVStatue7.Amount[playerID] = gvVStatue7.Amount[playerID] + 1
			gvVStatue7.Placed(playerID, pos.X, pos.Y)

		elseif entityType == Entities.PB_VictoryStatue8 then
			table.insert(gvVStatue8.PositionTable,pos)
			gvVStatue8.Amount[playerID] = gvVStatue8.Amount[playerID] + 1

		elseif entityType == Entities.PB_VictoryStatue9 then
			gvVStatue9.AmountConstructed[playerID] = gvVStatue9.AmountConstructed[playerID] + 1
		end
	end
end

function OnVStatuesDestroyed()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType > 0 then
		local playerID = GetPlayer(entityID)
		local pos = GetPosition(entityID)

		if entityType == Entities.PB_VictoryStatue1 then
			gvVStatue1.Amount[playerID] = gvVStatue1.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue2 then
			gvVStatue2.Amount[playerID] = gvVStatue2.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue3 then
			gvVStatue3.AmountConstructed[playerID] = gvVStatue3.AmountConstructed[playerID] - 1
			gvVStatue3.Amount[playerID] = gvVStatue3.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue4 then
			removetablekeyvalue(gvVStatue4.PositionTable,pos)
			gvVStatue4.Amount[playerID] = gvVStatue4.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue5 then
			gvVStatue5.Amount[playerID] = gvVStatue5.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue6 then
			removetablekeyvalue(gvVStatue6.PositionTable,pos)
			gvVStatue6.Amount[playerID] = gvVStatue6.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue7 then
			gvVStatue7.Amount[playerID] = gvVStatue7.Amount[playerID] - 1
			GUI.DestroyMinimapPulse(pos.X, pos.Y)
			StopCountdown(gvVStatue7.Countdown[playerID])

		elseif entityType == Entities.PB_VictoryStatue8 then
			removetablekeyvalue(gvVStatue8.PositionTable,pos)
			gvVStatue8.Amount[playerID] = gvVStatue8.Amount[playerID] - 1

		elseif entityType == Entities.PB_VictoryStatue9 then
			gvVStatue9.AmountConstructed[playerID] = gvVStatue9.AmountConstructed[playerID] - 1
			gvVStatue9.Amount[playerID] = gvVStatue9.Amount[playerID] - 1
		end
	end
end

