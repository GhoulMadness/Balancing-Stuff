local BridgeTypes = {Entities.PB_Archers_Tower,
					Entities.PB_Bridge1,
					Entities.PB_Bridge2,
					Entities.PB_Bridge3,
					Entities.PB_Bridge4,
					Entities.PB_DrawBridgeClosed1,
					Entities.PB_DrawBridgeClosed2,
					Entities.XD_OSO_Wall_Block2,
					Entities.XD_OSO_Wall_Straight2,
					Entities.XD_OSO_Wall_Straight2_90,
					Entities.XD_OSO_Wall_Straight2_180,
					Entities.XD_OSO_Wall_Straight2_270,
					Entities.XD_OSO_Wall_Tower2,
					Entities.XD_OSO_Wall_Tower2_90,
					Entities.XD_OSO_Wall_Tower2_180,
					Entities.XD_OSO_Wall_Tower2_270,
					Entities.XD_OSO_Wall_Tower3,
					Entities.XD_OSO_Wall_Gate_Slim_Closed2
					}
local BridgeHeightByType = {}
for i = 1, table.getn(BridgeTypes) do
	local type = BridgeTypes[i]
	BridgeHeightByType[type] = GetBuildingTypeBridgeHeight(type)
end
for eID in CEntityIterator.Iterator(CEntityIterator.OfCategoryFilter(EntityCategories.Bridge)) do
	local btype = Logic.GetEntityType(eID)
	local posX, posY, posZ = Logic.EntityGetPos(eID)
	local areaX, areaY = {}, {}
	areaX[1], areaY[1], areaX[2], areaY[2] = GetBuildingTypeBridgeArea(btype)
	table.sort(areaX, function(p1, p2)
		return p1 < p2
	end)
	table.sort(areaY, function(p1, p2)
		return p1 < p2
	end)
	local bheight = BridgeHeightByType[btype] or 0
	local height = posZ + bheight
	CUtil.OverrideTerrainEntityHeight(round(posX/100), round(posY/100), height)
	for x = posX + areaX[1], posX + areaX[2], 100 do
		for y = posY + areaY[1], posY + areaY[2], 100 do
			CUtil.OverrideTerrainEntityHeight(round(x/100), round(y/100), height)
		end
	end
end