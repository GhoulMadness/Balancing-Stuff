Siege = {AttackerIDs = {}, DefenderIDs = {}, TrapPositions = {}, TrapActivationRange = 500, TrapDamage = 100, TrapDamageRange = 1200
		CreateTraps = function(_player, _x, _y, _range, _amount)
			Siege.TrapPositions = CreateEntitiesInRectangle(Entities.XD_TrapHole1, _amount, _player, _x - range, _x + range, _y - range, _y + range, 100, "TrapHole")
			Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "Siege_TrapControl",1)
		end,
		CreatePitchFields = function(_x, _y, _range, _length, _amount)
		end}
Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED,"", "Siege_TrapCreated")
Siege_TrapControl = function()
	for i = 1, table.getn(Siege.TrapPositions) do
		local X, Y = Siege.TrapPositions[i].X, Siege.TrapPositions[i].Y
		local id = Logic.GetEntityAtPosition(X, Y)
		for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(Siege.AttackerIDs),
		CEntityIterator.InCircleFilter(X, Y, Siege.TrapActivationRange),
		CEntityIterator.IsSettlerOrBuildingFilter()) do
			CEntity.DealDamageInArea(id, X, Y, Siege.TrapDamageRange, Siege.TrapDamage)
			ReplaceEntity(id, Entities.XD_TrapHole2)
			table.remove(Siege.TrapPositions, i)
			break
		end
	end
	if not next(Siege.TrapPositions) then
		return true
	end
end
Siege_TrapCreated = function()
	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.XD_TrapHole1 then
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
end
Siege_PitchBurnerControl = function()
end