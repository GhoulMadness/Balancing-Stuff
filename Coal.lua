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
		ResourceNeeded = {	[Entities.CB_Mint1] = 6,
							[Entities.PB_Alchemist2] = 9,
							[Entities.PB_Blacksmith1] = 6,
							[Entities.PB_Blacksmith2] = 8,
							[Entities.PB_Blacksmith3] = 10,
							[Entities.PB_Brickworks2] = 6,
							[Entities.PB_GunsmithWorkshop1] = 6,
							[Entities.PB_GunsmithWorkshop2] = 8,
							[Entities.PB_Silversmith2] = 75},
		ResourceBonus = {	[Entities.CB_Mint1] = 2,
							[Entities.PB_Alchemist2] = 2,
							[Entities.PB_Blacksmith1] = 1,
							[Entities.PB_Blacksmith2] = 2,
							[Entities.PB_Blacksmith3] = 3,
							[Entities.PB_Brickworks2] = 2,
							[Entities.PB_GunsmithWorkshop1] = 1,
							[Entities.PB_GunsmithWorkshop2] = 2,
							[Entities.PB_Silversmith2] = 1},
		Usage = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}},
		AdjustTypeList = function(_flag, _player, _type)
			if _flag == 1 then
				gvCoal.Usage[_player][_type] = true
			else
				gvCoal.Usage[_player][_type] = false
			end
		end,
		Coalmaker = {EffectDuration = 10, CoalEarned = {}, WoodBurned = {},
		TooltipText = {Coal = {["de"] = "Kohle erhalten: ", ["en"] = "Coal earned: ", ["pl"] = "Coal earned: ", ["ru"] = "Coal earned: ", ["us"] = "Coal earned: ", ["gb"] = "Coal earned: "},
						Wood = {["de"] = "Holz verbrannt: ", ["en"] = "Wood burned: ", ["pl"] = "Wood burned: ", ["ru"] = "Wood burned: ", ["us"] = "Wood burned: ", ["gb"] = "Wood burned: "}},
		Cycle = {{TaskIndex = 16, ResourceAmount = 15},
				{TaskIndex = 19, ResourceAmount = 15},
				{TaskIndex = 21, ResourceAmount = 20}}},
		Mine = {Offset1 = {X = 0, Y = 0}, Offset2 = {X = 0, Y = 400}, Offset3 = {X = 0, Y = 1000}, SlopeHeightMin = 300, AmountMined = {},
		ResourceByLevel = {4, 6}, PickaxeFactor = 1.5, TooltipText = {["de"] = "Kohle gefördert: ", ["en"] = "Coal mined: ", ["pl"] = "Coal mined", ["ru"] = "Coal mined", ["us"] = "Coal mined", ["gb"] = "Coal mined"},
		Cycle = {Inside = {{TaskIndex = 4},
							{TaskIndex = 8}},
				Outside = {{TaskIndex = 15},
							{TaskIndex = 18},
							{TaskIndex = 23}}},
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
	for i = 1,16 do
		gvCoal.Usage[i][k] = false
	end
end
function Coalmaker_RemoveFireEffect(_id, ...)
	if Counter.Tick2("Coalmaker_RemoveFireEffect_".. _id, gvCoal.Coalmaker.EffectDuration) or Logic.IsEntityDestroyed(_id) then
		for i = 1, arg.n do
			Logic.DestroyEffect(arg[i])
		end
		return true
	end
end
function OnCoalmaker_Destroyed(_id)

	local entityID = Event.GetEntityID()
    if entityID == _id then
		gvCoal.Coalmaker.WoodBurned[entityID] = nil
		gvCoal.Coalmaker.CoalEarned[entityID] = nil
		return true
	end
end
function OnCoalmine_Destroyed(_id)

	local entityID = Event.GetEntityID()
    if entityID == _id then
		gvCoal.Mine.AmountMined[entityID] = nil
		return true
	end
end
for eID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PB_CoalmakersHut1)) do
	gvCoal.Coalmaker.WoodBurned[eID] = 0
	gvCoal.Coalmaker.CoalEarned[eID] = 0
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCoalmaker_Destroyed", 1,{},{eID})
end
for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(Entities.PB_CoalMine1, Entities.PB_CoalMine2)) do
	gvCoal.Mine.AmountMined[eID] = 0
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCoalmine_Destroyed", 1,{},{eID})
end