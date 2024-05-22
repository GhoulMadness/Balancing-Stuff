----------------- Scaremonger motivation effect values ---------------------
----------------------------------------------------------------------------
Scaremonger = {MotiEffect = {
	[Entities.PB_Scaremonger01] = 0.14,
	[Entities.PB_Scaremonger02] = 0.12,
	[Entities.PB_Scaremonger03] = 0.19,
	[Entities.PB_Scaremonger04] = 0.22,
	[Entities.PB_Scaremonger05] = 0.40,
	[Entities.PB_Scaremonger06] = 0.18,
	[Entities.PB_VictoryStatue2] = 0.20}
}
------------------- called in GameCallbacks.lua when building construction is finished ----------------------------------------
Scaremonger.MotiDebuff = function(_PlayerID, _eType)
	local baseamount = Scaremonger.MotiEffect[_eType]
	for j = 1, 16, 1 do
		if Logic.GetDiplomacyState(_PlayerID, j) == Diplomacy.Hostile then
			local amount = baseamount * (gvVStatue9.ScareEffectivenessFactor ^ gvVStatue9.Amount[_PlayerID])
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(j), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
				local motivation = Logic.GetSettlersMotivation(eID)
				if motivation > 0.4 then
					CEntity.SetMotivation(eID, math.max(0.4, motivation - amount))
				end
			end
			if	CUtil.GetPlayersMotivationHardcap(j) >= (0.4 + amount) then
				CUtil.AddToPlayersMotivationHardcap(j, - amount)
			else
				CUtil.AddToPlayersMotivationHardcap(j, - (CUtil.GetPlayersMotivationHardcap(j) - 0.4))
			end
			if CUtil.GetPlayersMotivationSoftcap(j) >= (0.4 + amount) then
				CUtil.AddToPlayersMotivationSoftcap(j, - amount)
			else
				CUtil.AddToPlayersMotivationSoftcap(j, - (CUtil.GetPlayersMotivationSoftcap(j) - 0.4))
			end
			-- AI resource debuff
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(j) == 0 and MapEditor_Armies and MapEditor_Armies[j] then
				local mot = Logic.GetAverageMotivation(j)
				if mot < 1 then
					local t = MapEditor_Armies[j].description.refresh
					AI.Player_SetResourceRefreshRates(
						j,
						round(t.gold * (mot ^ 2)),
						round(t.clay * (mot ^ 2)),
						round(t.iron * (mot ^ 2)),
						round(t.sulfur * (mot ^ 2)),
						round(t.stone * (mot ^ 2)),
						round(t.wood * (mot ^ 2)),
						t.updateTime
					)
				end
			end
		end
	end
end
------------------ reset motivation when building is destroyed ------------------------------------------------------------------
Scaremonger.MotiReset = function(_PlayerID, _eType)
	local baseamount = Scaremonger.MotiEffect[_eType]
	for j = 1, 16, 1 do
		if Logic.GetDiplomacyState(_PlayerID, j) == Diplomacy.Hostile then
			local amount = baseamount * (gvVStatue9.ScareEffectivenessFactor ^ gvVStatue9.Amount[_PlayerID])
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(j), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
				local motivation = Logic.GetSettlersMotivation(eID)
				CEntity.SetMotivation(eID, motivation + amount)
			end
			CUtil.AddToPlayersMotivationHardcap(j, amount)
			CUtil.AddToPlayersMotivationSoftcap(j, amount)
			-- AI resource debuff reset
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(j) == 0 and MapEditor_Armies and MapEditor_Armies[j] then
				local mot = Logic.GetAverageMotivation(j)
				local t = MapEditor_Armies[j].description.refresh
				if mot < 1 then
					AI.Player_SetResourceRefreshRates(
						j,
						round(t.gold * (mot ^ 2)),
						round(t.clay * (mot ^ 2)),
						round(t.iron * (mot ^ 2)),
						round(t.sulfur * (mot ^ 2)),
						round(t.stone * (mot ^ 2)),
						round(t.wood * (mot ^ 2)),
						t.updateTime
					)
				else
					AI.Player_SetResourceRefreshRates(
						j,
						t.gold,
						t.clay,
						t.iron,
						t.sulfur,
						t.stone,
						t.wood,
						t.updateTime
					)
				end
			end
		end
	end
end
-- Trigger for scaremonger buildings destroyed
function OnScaremongerDestroyed()

    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

    if Scaremonger.MotiEffect[entityType] then
		local playerID = GetPlayer(entityID)
		Scaremonger.MotiReset(playerID, entityType)
	end

end