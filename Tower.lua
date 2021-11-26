------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Tower Table ---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
	gvTower = gvTower or {}

	-- Blockreichweite in Siedler-cm, abhängig von der Fläche der Map
	gvTower.BlockRange = 500 + math.floor(((Logic.WorldGetSize()/100)^2)/500)
	-- max. Anzahl erlaubter Türme
	gvTower.TowerLimit = 15
	gvTower.StartTowersIDTable = {}
	gvTower.PositionTable = {}
	gvTower.AmountOfTowers = {}
	if CNetwork then
		for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do 
			gvTower.AmountOfTowers[i] = Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower1) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower2) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower3)
		end
	else
		for i = 1,8 do
			gvTower.AmountOfTowers[i] = Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower1) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower2) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower3)
		end
	end
	for id in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(Entities.PB_Tower1,Entities.PB_Tower2,Entities.PB_Tower3)) do
		table.insert(gvTower.StartTowersIDTable, id);
	end;
	for k = 1,table.getn(gvTower.StartTowersIDTable) do
		table.insert(gvTower.PositionTable,{Logic.GetEntityPosition(gvTower.StartTowersIDTable[k])})
	end
	