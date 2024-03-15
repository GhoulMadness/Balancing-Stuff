------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Tower Table ---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvTower = gvTower or {}

-- Blockreichweite in Siedler-cm, abhängig von der Fläche der Map
if gvEMSFlag then
	gvTower.BlockRange = 500 + math.floor(((Logic.WorldGetSize()/100)^2)/500)
	-- max. Anzahl erlaubter Türme
	gvTower.TowerLimit = 15
else
-- auf Koop-Karten Reichweite kleiner und mehr Türme erlaubt
	gvTower.BlockRange = 350 + math.floor(((Logic.WorldGetSize()/100)^2)/1000)
	gvTower.TowerLimit = 30
end
gvTower.StartTowersIDTable = {}
gvTower.PositionTable = {}
gvTower.AmountOfTowers = {}
local maxplayers = 8
if CNetwork then
	maxplayers = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()
end
for i = 1, maxplayers do
	gvTower.AmountOfTowers[i] = Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower1) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower2)
	+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Tower3) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_DarkTower1)
	+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_DarkTower2) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_DarkTower3)
	+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PU_Hero14_EvilTower)
end
for id in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(Entities.PB_Tower1, Entities.PB_Tower2, Entities.PB_Tower3, Entities.PB_DarkTower1,
	Entities.PB_DarkTower2, Entities.PB_DarkTower3, Entities.PU_Hero14_EvilTower)) do
	table.insert(gvTower.StartTowersIDTable, id)
end
for k = 1,table.getn(gvTower.StartTowersIDTable) do
	local posX,posY = Logic.GetEntityPosition(gvTower.StartTowersIDTable[k])
	local pos = {X = posX, Y = posY}
	table.insert(gvTower.PositionTable,pos)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- Trigger for Towers ------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnTowerCreated()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PB_Tower1 or entityType == Entities.PB_Tower2
	or entityType == Entities.PB_Tower3 or entityType == Entities.PB_DarkTower1
	or entityType == Entities.PB_DarkTower2 or entityType == Entities.PB_DarkTower3
	or entityType == Entities.PU_Hero14_EvilTower then

		local playerID = GetPlayer(entityID)
		local posX,posY = Logic.GetEntityPosition(entityID)
		local pos = {X = posX, Y = posY}
		table.insert(gvTower.PositionTable,pos)

		if gvTower.AmountOfTowers[playerID] then
			gvTower.AmountOfTowers[playerID] = gvTower.AmountOfTowers[playerID] + 1
		end

	end
end

function OnTowerDestroyed()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PB_Tower1 or entityType == Entities.PB_Tower2
	or entityType == Entities.PB_Tower3 or entityType == Entities.PB_DarkTower1
	or entityType == Entities.PB_DarkTower2 or entityType == Entities.PB_DarkTower3
	or entityType == Entities.PU_Hero14_EvilTower then

		local playerID = GetPlayer(entityID)
		local posX,posY = Logic.GetEntityPosition(entityID)
		local pos = {X = posX, Y = posY}
		removetablekeyvalue(gvTower.PositionTable,pos)

		if gvTower.AmountOfTowers[playerID] then
			gvTower.AmountOfTowers[playerID] = gvTower.AmountOfTowers[playerID] - 1
		end

	end
end
