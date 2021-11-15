----------------- Scaremonger motivation effect values ---------------------
-- Moti is set in GameCallbacks.lua ----------------------------------------
----------------------------------------------------------------------------
Scaremonger = {MotiEffect = {
	[Entities.PB_Scaremonger01] = 0.14,
	[Entities.PB_Scaremonger02] = 0.12,
	[Entities.PB_Scaremonger03] = 0.19,
	[Entities.PB_Scaremonger04] = 0.22, 
	[Entities.PB_Scaremonger05] = 0.40,
	[Entities.PB_Scaremonger06] = 0.18 
								}
}
Scaremonger.MotiDebuff = function(_PlayerID,_eType)
	local amount = Scaremonger.MotiEffect[_eType]
	for j=1, 16, 1 do
		if Logic.GetDiplomacyState( _PlayerID, j) == Diplomacy.Hostile then			
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(j), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
				local motivation = Logic.GetSettlersMotivation(eID) 
				if motivation > 0.4 then
					CEntity.SetMotivation(eID, math.min(0.4,motivation - amount ))
				end
			end			
			if	GetPlayersMotivationHardcap(j) >= (0.4 + amount) then
				CUtil.AddToPlayersMotivationHardcap(j, - amount)
			else
				CUtil.AddToPlayersMotivationHardcap(j, - (GetPlayersMotivationHardcap(j)-0.4))
			end
			if GetPlayersMotivationSoftcap(j) >= (0.4 + amount) then
				CUtil.AddToPlayersMotivationSoftcap(j, - amount)
			else
				CUtil.AddToPlayersMotivationSoftcap(j, - (GetPlayersMotivationSoftcap(j)-0.4))
			end
		end
	end
end