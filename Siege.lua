Siege = {AttackerIDs = {}, DefenderIDs = {}, TrapPositions = {}, TrapActivationRange = 300, TrapDamage = 100, TrapDamageRange = 800,
		PitchFieldPositions = {}, PitchFieldDefaultPlayer = 8, PitchFieldEnemyTreshold = 10, PitchFieldActivationRange = 500, PitchFieldAlreadyTargetted = {},
		PitchBurnerRange = 500, PitchBurnerEnemyTreshold = 15,
		PitchBurningDuration = 20, PitchBurningDamage = 50, PitchBurningRange = 800,
		CreateTraps = function(_player, _x, _y, _range, _amount)
			Siege.TrapPositions = CreateEntitiesInRectangle(Entities.XD_TrapHole1, _amount, _player, _x - _range, _x + _range, _y - _range, _y + _range, 500, "TrapHole")
			Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_TrapControl",1)
		end,
		CreatePitchFields = function(_x, _y, _range, _length, _amount)
			Siege.PitchFieldPositions = CreateEntityTrailsInRectangle(Entities.XD_Pitch, _amount, Siege.PitchFieldDefaultPlayer, _x - _range, _x + _range, _y - _range, _y + _range, _length, 200, 800, "PitchField")
			Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchFieldsControl",1)
		end,
		PitchBurnerInit = function()
			Siege.PitchBurners = Siege.PitchBurners or {}
			for eID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PU_PitchBurner), CEntityIterator.OfAnyPlayerFilter(unpack(Siege.DefenderIDs))) do
				table.insert(Siege.PitchBurners, eID)
				Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_PitchBurnerControl",1,{},{eID})
			end
		end,
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
		end}
if not Siege.PitchBurners then
	Siege.PitchBurnerInit()
end
Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED,"", "Siege_EntityCreated")
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
			local centerindex = math.floor(table.getn(Siege.PitchFieldPositions[i]))
			local num = GetNumberOfPlayerUnitsInRange(Siege.AttackerIDs, Siege.PitchFieldPositions[i][centerindex], Siege.PitchFieldActivationRange)
			if num >= Siege.PitchFieldEnemyTreshold then
				local id = Siege.SearchForNearestBowman(Siege.PitchFieldPositions[i][centerindex].X, Siege.PitchFieldPositions[i][centerindex].Y)
				if id then
					local posX, posY = Logic.GetEntityPosition(id)
					local posX2, posY2 = Siege.PitchFieldPositions[i][centerindex].X, Siege.PitchFieldPositions[i][centerindex].Y
					local target = Logic.GetEntityAtPosition(posX2, posY2)
					local projectile = CUtil.CreateProjectile(GGL_Effects.FXHero14_Arrow, posX, posY, posX2, posY2, 1, 300, target, id, Logic.EntityGetPlayer(id))
					Siege.PitchFieldAlreadyTargetted[i] = true
					Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,"", "Siege_PitchFieldHitControl",1,{},{projectile, target, i})
				end
			end
		end
	end
end
Siege_PitchFieldHitControl = function(_projectile, _id, _index)
	local target = Event.GetEntityID2()
	if target == _id then
		local projectile = CEntity.HurtTrigger.GetProjectileID()
		if projectile == _projectile then
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_EVERY_TURN,"", "Siege_PitchFieldApplyDamage",1,{},{_id, _index})
			return true
		end
	end
end
Siege_PitchFieldApplyDamage = function(_id, _index)
	if Counter.Tick2("Siege_PitchFieldApplyDamage_" .. _index) <= Siege.PitchBurningDuration then
		for i = 1, table.getn(Siege.PitchFieldPositions[_index]) do
			local X, Y = Siege.PitchFieldPositions[_index][i].X, Siege.PitchFieldPositions[_index][i].Y
			Logic.CreateEffect(CatapultStoneOnHitEffects[math.random(1,4)], X, Y)
			CEntity.DealDamageInArea(_id, X, Y, Siege.PitchBurningRange, Siege.PitchBurningDamage)
		end
	else
		for i = 1, table.getn(Siege.PitchFieldPositions[_index]) do
			DestroyEntity(Logic.GetEntityAtPosition(Siege.PitchFieldPositions[_index][i].X, Siege.PitchFieldPositions[_index][i].Y))
		end
		Siege.PitchFieldAlreadyTargetted[_index] = false
		table.remove(Siege.PitchFieldPositions, _index)
		return true
	end
end
Siege_PitchBurnerControl = function(_id)
	if not IsValid(_id) then
		return true
	end
	local player = Logic.EntityGetPlayer(_id)
	local pos = GetPosition(_id)
	local dist, eID = GetNearestEnemyDistance(player, pos, Siege.PitchBurnerRange)
	if eID then
		local num, IDs = GetPlayerEntitiesByCatInRange(player, {EntityCategories.Leader}, pos, Siege.PitchBurnerRange)
		if num >= Siege.PitchBurnerEnemyTreshold then
			local t = {}
			for i = 1, num do
				t[i] = GetPosition(IDs[i])
			end
			local clump = GetPositionClump(t, Siege.PitchBurnerRange, 100)
			local angle = GetAngleBetween(pos, clump)
			Logic.RotateEntity(_id, angle)
			Logic.SetTaskList(_id, TaskLists.TL_PITCHBURNER_DROPOIL)
			Logic.CreateEffect(GGL_Effects.FX_DropOil, clump.X, clump.Y)
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_EVERY_TURN,"", "Siege_PitchBurnerApplyDamage",1,{},{_id, clump.X, clump.Y})
			return true
		end
	end
end
function Siege_PitchBurnerApplyDamage(_id, _x, _y)
	if not IsValid(_id) then
		return true
	end
	if Counter.Tick2("Siege_PitchBurnerApplyDamage_" .. _id) <= Siege.PitchBurningDuration then
		Logic.CreateEffect(CatapultStoneOnHitEffects[math.random(1,4)], _x, _y)
		CEntity.DealDamageInArea(_id, _x, _y, Siege.PitchBurningRange, Siege.PitchBurningDamage)
	else
		return true
	end
end