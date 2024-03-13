----------------------------------------------------------------------------------------------------------------------------
----------------------------------------- DZ Trade Punishment --------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
gvDZTradeCheck = {PlayerDelay = {}, PlayerTime = {}, amount = 0.007 + (math.random(8)/100), factor = 1.1 + (math.random(5)/10), treshold = 15 + math.random(15), PunishmentProtected = {CriticalRange = 3200}, AttractionOverhaulFactor = 1.2, MotivationValues = {Maximum = 0.29, AverageMaximum = 0.26, Minimum = 0.24}}
function DZTrade_Init()

	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		gvDZTradeCheck.PlayerTime[i] = -1
		gvDZTradeCheck.DelayDefaultValue = 60 + math.random(20)
		gvDZTradeCheck.PlayerDelay[i] = gvDZTradeCheck.DelayDefaultValue

	end
	StartSimpleJob("DZTrade_PunishmentJob")

end
function DZTrade_PunishmentJob()
	for player = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if Logic.GetNumberOfAttractedWorker(player) > 0 and Logic.GetPlayerAttractionUsage(player) >= (Logic.GetPlayerAttractionLimit(player) + gvDZTradeCheck.treshold) then
			if not gvDZTradeCheck.PunishmentProtected.Check(player) then
				if gvDZTradeCheck.PlayerTime[player] == - 1 then
					gvDZTradeCheck.PlayerTime[player] = Logic.GetTime()	+ gvDZTradeCheck.PlayerDelay[player]
				end
			end
			gvDZTradeCheck.PlayerDelay[player] = gvDZTradeCheck.PlayerDelay[player] - 1
			if gvDZTradeCheck.PlayerDelay[player] == 0 then
				local r,g,b = GUI.GetPlayerColor(player)
				GUI.AddNote(" @color:"..r..","..g..","..b.." "..UserTool_GetPlayerName(player).." @color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b.." verfügt über zu wenig Platz für seine Siedler." )
				GUI.AddNote( "Dies wird den Siedlern nicht gefallen und sie werden die Siedlung bald verlassen!")
				if GUI.GetPlayerID() == player then
					Sound.PlayFeedbackSound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_06, 138)
				end
			end
			if gvDZTradeCheck.PlayerDelay[player] <= 0 then
				gvDZTradeCheck.Punishment(player)
			end
		else
		gvDZTradeCheck.PlayerTime[player] = - 1
		gvDZTradeCheck.PlayerDelay[player] = gvDZTradeCheck.DelayDefaultValue
		end
	end
end
function gvDZTradeCheck.Punishment(_playerID)
	local timepassed = math.floor((Logic.GetTime() - gvDZTradeCheck.PlayerTime[_playerID])/4)
	local count = 0
	local maxvalue = (Logic.GetPlayerAttractionUsage(_playerID) - Logic.GetPlayerAttractionLimit(_playerID)) * gvDZTradeCheck.AttractionOverhaulFactor
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
		if count < maxvalue then
			local motivation = Logic.GetSettlersMotivation(eID)
			if motivation >= gvDZTradeCheck.MotivationValues.Maximum or Logic.GetAverageMotivation(_playerID) >= gvDZTradeCheck.MotivationValues.AverageMaximum then
				CEntity.SetMotivation(eID, motivation - math.max(math.min(math.floor((gvDZTradeCheck.amount*(gvDZTradeCheck.factor^timepassed))*100)/100, 0.06), 0.2))
			elseif motivation < gvDZTradeCheck.MotivationValues.Minimum then
				CEntity.SetMotivation(eID, gvDZTradeCheck.MotivationValues.Minimum)
			end
			count = count + 1
		else
			break
		end
	end
end
function gvDZTradeCheck.PunishmentProtected.Check(_playerID)
	local DZTable = {	Logic.GetPlayerEntities(_playerID, Entities.PB_VillageCenter3, 10)	}
	local HPTable = {}
	table.remove(DZTable,1)
	for i = 1,table.getn(DZTable) do
		HPTable[i] = GetEntityHealth(DZTable[i])
		local minHP = math.min(HPTable[i],100)
		local posX,posY = Logic.GetEntityPosition(DZTable[i])
		local pos = {X = posX,Y = posY}
		if minHP <= 80 or AreEntitiesOfDiplomacyStateInArea(_playerID,pos,gvDZTradeCheck.PunishmentProtected.CriticalRange,Diplomacy.Hostile) == true then
			return true
		else
			return false
		end
	end
end