------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- Coal Table -----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvCoal = { AllowedTypes = {	[Entities.CB_Mint1] = true,
							[Entities.PB_Alchemist2] = true,
							[Entities.PB_Blacksmith1] = true,
							[Entities.PB_Blacksmith2] = true,
							[Entities.PB_Blacksmith3] = true,
							[Entities.PB_Brickworks2] = true,
							[Entities.PB_GunsmithWorkshop1] = true,
							[Entities.PB_GunsmithWorkshop2] = true,
							[Entities.PB_Silversmith2] = true},
		ResourceNeeded = {	[Entities.CB_Mint1] = 8,
							[Entities.PB_Alchemist2] = 12,
							[Entities.PB_Blacksmith1] = 8,
							[Entities.PB_Blacksmith2] = 10,
							[Entities.PB_Blacksmith3] = 12,
							[Entities.PB_Brickworks2] = 8,
							[Entities.PB_GunsmithWorkshop1] = 8,
							[Entities.PB_GunsmithWorkshop2] = 10,
							[Entities.PB_Silversmith2] = 100},
		ResourceBonus = {	[Entities.CB_Mint1] = 2,
							[Entities.PB_Alchemist2] = 2,
							[Entities.PB_Blacksmith1] = 1,
							[Entities.PB_Blacksmith2] = 2,
							[Entities.PB_Blacksmith3] = 3,
							[Entities.PB_Brickworks2] = 2,
							[Entities.PB_GunsmithWorkshop1] = 1,
							[Entities.PB_GunsmithWorkshop2] = 2,
							[Entities.PB_Silversmith2] = 1},
		Usage = {{},{},{},{},{},{},{},{},{},{},{},{}},
		AdjustTypeList = function(_flag, _player, _type)
			if _flag == 1 then
				gvCoal.Usage[_player][_type] = true
			else
				gvCoal.Usage[_player][_type] = false
			end
		end,
		CoalmakerEffectDuration = 10,
		Mine = {Offset1 = {X = 0, Y = 0}, Offset2 = {X = 0, Y = 400}, Offset3 = {X = 0, Y = 1000}, SlopeHeightMin = 300,
		AllowedTextures = {	[12] = true,
							[15] = true,
							[28] = true,
							[29] = true,
							[30] = true,
							[31] = true,
							[74] = true,
							[80] = true,
							[107] = true,
							[108] = true,
							[133] = true,
							[134] = true,
							[148] = true,
							[149] = true,
							[150] = true,
							[151] = true,
							[157] = true,
							[158] = true,
							[163] = true,
							[165] = true,
							[166] = true,
							[167] = true,
							[168] = true,
							[169] = true,
							[212] = true,
							[213] = true,
							[215] = true,
							[216] = true,
							[217] = true,
							[218] = true,
							[219] = true,
							[220] = true,
							[221] = true,
							[222] = true,
							[265] = true,
							[266] = true,
							[267] = true,
							[268] = true,
							[269] = true,
							[270] = true
						},
		PlacementCheck = function(_x, _y, _rot)
			local offX1, offY1 = RotateOffset(gvCoal.Mine.Offset1.X, gvCoal.Mine.Offset1.Y, _rot)
			local offX2, offY2 = RotateOffset(gvCoal.Mine.Offset2.X, gvCoal.Mine.Offset2.Y, _rot)
			local offX3, offY3 = RotateOffset(gvCoal.Mine.Offset3.X, gvCoal.Mine.Offset3.Y, _rot)
			local posX1, posY1, posX2, posY2, posX3, posY3 = _x + offX1, _y + offY1, _x + offX2, _y + offY2, _x + offX3, _y + offY3
			local height1 = CUtil.GetTerrainNodeHeight(posX1/100, posY1/100)
			local height2, blockingtype2, sector2, terrType2 = CUtil.GetTerrainInfo(posX2, posY2)
			local height3, blockingtype3, sector3, terrType3 = CUtil.GetTerrainInfo(posX3, posY3)
			return ((height2 - height1 >= gvCoal.Mine.SlopeHeightMin/2) and sector2 == 0 and gvCoal.Mine.AllowedTextures[terrType2]) 
			or((height3 - height1 >= gvCoal.Mine.SlopeHeightMin) and sector3 == 0 and gvCoal.Mine.AllowedTextures[terrType3])
		end}
}
for k,_ in pairs(gvCoal.AllowedTypes) do
	for i = 1,12 do
		gvCoal.Usage[i][k] = false
	end
end
function Coalmaker_RemoveFireEffect(_id, ...)
	if Counter.Tick2("Coalmaker_RemoveFireEffect_".. _id, gvCoal.CoalmakerEffectDuration) or Logic.IsEntityDestroyed(_id) then
		for i = 1, arg.n do
			Logic.DestroyEffect(arg[i])
		end
		return true
	end
end