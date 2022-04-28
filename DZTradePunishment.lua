----------------------------------------------------------------------------------------------------------------------------
----------------------------------------- DZ Trade Punishment --------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
gvDZTradeCheck = {PlayerDelay = {}, PlayerTime = {}, amount = 0.007 + Logic.GetRandom(0.008), factor = 1.1 + (Logic.GetRandom(5)/10), treshold = 15 + Logic.GetRandom(15), }
function DZTrade_Init()
	
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		gvDZTradeCheck.PlayerTime[i] = -1
		gvDZTradeCheck.PlayerDelay[i] = 60 + Logic.GetRandom(20)

	end
	StartSimpleJob("DZTrade_PunishmentJob")
	
end
function DZTrade_PunishmentJob()
	for player = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if Logic.GetNumberOfAttractedWorker(player) > 0 and Logic.GetPlayerAttractionUsage(player) >= (Logic.GetPlayerAttractionLimit(player) + gvDZTradeCheck.treshold) then
			if gvDZTradeCheck.PunishmentProtected(player) == 0 then
				if gvDZTradeCheck.PlayerTime[player] == - 1 then
					gvDZTradeCheck.PlayerTime[player] = Logic.GetTime()	+ gvDZTradeCheck.PlayerDelay[player]
				end
			end
			gvDZTradeCheck.PlayerDelay[player] = gvDZTradeCheck.PlayerDelay[player] - 1	
			if gvDZTradeCheck.PlayerDelay[player] == 0 then
				local r,g,b = GUI.GetPlayerColor(player)
				GUI.AddNote(" @color:"..r..","..g..","..b.." "..UserTool_GetPlayerName(player).." @color:255,255,255 verfügt über zu wenig Platz für seine Siedler." )
				GUI.AddNote( "Dies wird den Siedlern nicht gefallen und sie werden die Siedlung bald verlassen!")
				if GUI.GetPlayerID() == player then
					Stream.Start("Sounds\\voicesmentor\\comment_badplay_rnd_06.wav",150)
				end
			end
			if gvDZTradeCheck.PlayerDelay[player] <= 0 then
				gvDZTradeCheck.Punishment(player)
			end
		else
		gvDZTradeCheck.PlayerTime[player] = - 1
		gvDZTradeCheck.PlayerDelay[player] = 60 + Logic.GetRandom(20)
		end
	end
end
function gvDZTradeCheck.Punishment(_playerID)		
	local timepassed = math.floor((Logic.GetTime() - gvDZTradeCheck.PlayerTime[_playerID])/4)
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
		local motivation = Logic.GetSettlersMotivation(eID) 
		if motivation >= 0.29 or Logic.GetAverageMotivation(_playerID) >= 0.26 then
			CEntity.SetMotivation(eID, motivation - math.max(math.min(math.floor((gvDZTradeCheck.amount*(gvDZTradeCheck.factor^timepassed))*100)/100, 0.06), 0.2))
		elseif motivation < 0.24 then
			CEntity.SetMotivation(eID, 0.24 )
		end
	end
end
function gvDZTradeCheck.PunishmentProtected(_playerID)		
	local DZTable = {	Logic.GetPlayerEntities(_playerID, Entities.PB_VillageCenter3, 10)	}
	local HPTable = {}
	table.remove(DZTable,1)
	for i = 1,table.getn(DZTable) do 
		HPTable[i] = GetEntityHealth(DZTable[i]) 
		local minHP = math.min(HPTable[i],100)
		local posX,posY = Logic.GetEntityPosition(DZTable[i])
		local pos = {X = posX,Y = posY}
		if minHP <= 80 or AreEntitiesOfDiplomacyStateInArea(_playerID,pos,3200,Diplomacy.Hostile) == true then
			return 1
		else
			return 0
		end
	end
end