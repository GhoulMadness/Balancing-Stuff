----------------- Scaremonger motivation effect values ---------------------
----------------------------------------------------------------------------
Scaremonger = {MotiEffect = {
	[Entities.PB_Scaremonger01] = 0.14,
	[Entities.PB_Scaremonger02] = 0.12,
	[Entities.PB_Scaremonger03] = 0.19,
	[Entities.PB_Scaremonger04] = 0.22, 
	[Entities.PB_Scaremonger05] = 0.40,
	[Entities.PB_Scaremonger06] = 0.18,
	[Entities.PB_VictoryStatue2] = 0.20
								}
}
------------------- called in GameCallbacks.lua when building construction is finished ----------------------------------------
Scaremonger.MotiDebuff = function(_PlayerID,_eType)
	local amount = Scaremonger.MotiEffect[_eType]
	for j=1, 16, 1 do
		if Logic.GetDiplomacyState( _PlayerID, j) == Diplomacy.Hostile then			
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(j), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
				local motivation = Logic.GetSettlersMotivation(eID) 
				if motivation > 0.4 then
					CEntity.SetMotivation(eID, math.max(0.4,motivation - amount ))
				end
			end			
			if	CUtil.GetPlayersMotivationHardcap(j) >= (0.4 + amount) then
				CUtil.AddToPlayersMotivationHardcap(j, - amount)
			else
				CUtil.AddToPlayersMotivationHardcap(j, - (CUtil.GetPlayersMotivationHardcap(j)-0.4))
			end
			if CUtil.GetPlayersMotivationSoftcap(j) >= (0.4 + amount) then
				CUtil.AddToPlayersMotivationSoftcap(j, - amount)
			else
				CUtil.AddToPlayersMotivationSoftcap(j, - (CUtil.GetPlayersMotivationSoftcap(j)-0.4))
			end
		end
	end
end
------------------ called in Trigger.lua when building is destroyed ------------------------------------------------------------------
Scaremonger.MotiReset = function(_PlayerID,_eType)
	local amount = Scaremonger.MotiEffect[_eType]
	for j=1, 16, 1 do
		if Logic.GetDiplomacyState( _PlayerID, j) == Diplomacy.Hostile then			
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(j), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
				local motivation = Logic.GetSettlersMotivation(eID) 
				CEntity.SetMotivation(eID, motivation + amount )
			end			
			CUtil.AddToPlayersMotivationHardcap(j, amount)
			CUtil.AddToPlayersMotivationSoftcap(j, amount)			
		end
	end
end