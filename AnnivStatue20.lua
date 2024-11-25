gvAnnivStatue20 = gvAnnivStatue20 or {Range = 1200, CooldownPerEntity = 30, StaminaRefreshValue = 20}
for player = 1,17 do
	gvAnnivStatue20[player] = {Amount = 0, EntityLastTime = {}}
end
function OnAnnivStatue_Destroyed(_id)
	local entityID = Event.GetEntityID()
	if entityID == _id then
		local playerID = GetPlayer(entityID)
		gvAnnivStatue20[playerID].Amount = gvAnnivStatue20[playerID].Amount - 1
		Trigger.UnrequestTrigger(gvAnnivStatue20[playerID].TriggerID)
		gvAnnivStatue20[playerID].TriggerID = nil
		return true
	end
end

function AnnivStatue_Actions(_id, _playerID, _posX, _posY)
	if Logic.IsEntityDestroyed(_id) then
		return true
	end
	local time = Logic.GetTime()
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.IsSettlerFilter(),
		CEntityIterator.OfCategoryFilter(EntityCategories.Worker), CEntityIterator.InCircleFilter(_posX, _posY, gvAnnivStatue20.Range)) do
		if not gvAnnivStatue20[_playerID].EntityLastTime[eID] then
			gvAnnivStatue20[_playerID].EntityLastTime[eID] = 0
		end
		local TimePassed = math.floor(time - gvAnnivStatue20[_playerID].EntityLastTime[eID])
		if TimePassed >= gvAnnivStatue20.CooldownPerEntity then
			gvAnnivStatue20[_playerID].EntityLastTime[eID] = time
			AddStamina(eID, gvAnnivStatue20.StaminaRefreshValue)
			Logic.CreateEffect(GGL_Effects.FXSalimHeal, Logic.GetEntityPosition(eID))
		end
	end
end