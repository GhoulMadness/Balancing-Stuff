------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Castle Table -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvCastle = gvCastle or {}

-- Blockreichweite in Siedler-cm, abhängig von der Fläche der Map
gvCastle.BlockRange = 4000 + math.floor(((Logic.WorldGetSize()/100)^2)/110)
-- max. Anzahl erlaubter Schlösser
gvCastle.CastleLimit = 2
gvCastle.HQIDTable = {}
gvCastle.PositionTable = {}
gvCastle.AmountOfCastles = {}
if CNetwork then
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		gvCastle.AmountOfCastles[i] = 0
		gvCastle.HQIDTable = {Logic.GetEntities(Entities.PB_Headquarters1,i)}
		table.remove(gvCastle.HQIDTable,1)
		for k = 1,table.getn(gvCastle.HQIDTable) do
			local posX, posY = Logic.GetEntityPosition(gvCastle.HQIDTable[k])
			gvCastle.PositionTable[k]={X = posX, Y = posY}
		end
	end
else
	gvCastle.AmountOfCastles[1] = 0
	gvCastle.HQIDTable = {Logic.GetEntities(Entities.PB_Headquarters1,16)}
	table.remove(gvCastle.HQIDTable,1)
	for k = 1,table.getn(gvCastle.HQIDTable) do
		local posX,posY = Logic.GetEntityPosition(gvCastle.HQIDTable[k])
		gvCastle.PositionTable[k]={X = posX, Y = posY}
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------- Trigger for Castles ----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnCastleCreated()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PB_Castle1 or entityType == Entities.PB_Castle2 or entityType == Entities.PB_Castle3 or entityType == Entities.PB_Castle4 or entityType == Entities.PB_Castle5 then
		local playerID = GetPlayer(entityID)
		local posX,posY = Logic.GetEntityPosition(entityID)
		local pos = {X = posX, Y = posY}
		table.insert(gvCastle.PositionTable,pos)

		if gvCastle.AmountOfCastles[playerID] then
			gvCastle.AmountOfCastles[playerID] = gvCastle.AmountOfCastles[playerID] + 1
		end

	end
end

function OnCastleDestroyed()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PB_Castle1 or entityType == Entities.PB_Castle2 or entityType == Entities.PB_Castle3 or entityType == Entities.PB_Castle4 or entityType == Entities.PB_Castle5 then
		local playerID = GetPlayer(entityID)
		local posX,posY = Logic.GetEntityPosition(entityID)
		local pos = {X = posX, Y = posY}
		removetablekeyvalue(gvCastle.PositionTable,pos)

		if gvCastle.AmountOfCastles[playerID] then
			gvCastle.AmountOfCastles[playerID] = gvCastle.AmountOfCastles[playerID] - 1
		end

	end
end