function InterfaceTool_CreateCostString(_Costs)

	local PlayerID = GUI.GetPlayerID()

	local PlayerClay   = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Clay) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.ClayRaw)
	local PlayerGold   = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Gold) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.GoldRaw)
	local PlayerSilver = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Silver) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.SilverRaw)
	local PlayerWood   = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Wood) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.WoodRaw)
	local PlayerIron   = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Iron) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.IronRaw)
	local PlayerStone  = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Stone) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.StoneRaw)
	local PlayerSulfur = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Sulfur) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.SulfurRaw)
	local PlayerCoal   = Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Knowledge)

	local CostString = ""

	if _Costs[ResourceType.Gold] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney") .. ": "
		if PlayerGold >= _Costs[ResourceType.Gold] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Gold] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Wood] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood") .. ": "
		if PlayerWood >= _Costs[ResourceType.Wood] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Wood] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Silver] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameSilver") .. ": "
		if PlayerSilver >= _Costs[ResourceType.Silver] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Silver] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Clay] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay") .. ": "
		if PlayerClay >= _Costs[ResourceType.Clay] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Clay] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Stone] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone") .. ": "
		if PlayerStone >= _Costs[ResourceType.Stone] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Stone] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Iron] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron") .. ": "
		if PlayerIron >= _Costs[ResourceType.Iron] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Iron] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Sulfur] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur") .. ": "
		if PlayerSulfur >= _Costs[ResourceType.Sulfur] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Sulfur] .. " @color:255,255,255,255 @cr "
	end

	if _Costs[ResourceType.Knowledge] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameCoal") .. ": "
		if PlayerCoal >= _Costs[ResourceType.Knowledge] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ResourceType.Knowledge] .. " @color:255,255,255,255 @cr "
	end

	return CostString

end
function InterfaceTool_HasPlayerEnoughResources_Feedback(_Costs)

	local PlayerID = GUI.GetPlayerID()

	local Clay = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Clay) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.ClayRaw))
	local Wood = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Wood) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.WoodRaw))
	local Gold   = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Gold) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.GoldRaw))
	local Iron   = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Iron) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.IronRaw))
	local Stone  = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Stone) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.StoneRaw))
	local Sulfur = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Sulfur) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.SulfurRaw))
	local Silver = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Silver) + Logic.GetPlayersGlobalResource(PlayerID, ResourceType.SilverRaw))
	local Coal = math.floor(Logic.GetPlayersGlobalResource(PlayerID, ResourceType.Knowledge))

	local Message = ""

	if 	_Costs[ResourceType.Sulfur] ~= nil and Sulfur < _Costs[ResourceType.Sulfur] then
		Message = _Costs[ResourceType.Sulfur] - Sulfur .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughSulfur")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Sulfur, _Costs[ResourceType.Sulfur] - Sulfur)
	end

	if 	_Costs[ResourceType.Silver] ~= nil and Silver < _Costs[ResourceType.Silver] then
		Message = _Costs[ResourceType.Silver] - Silver .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughSilver")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Silver, _Costs[ResourceType.Silver] - Silver)
	end

	if _Costs[ResourceType.Iron] ~= nil and Iron < _Costs[ResourceType.Iron] then
		Message = _Costs[ResourceType.Iron] - Iron .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughIron")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Iron, _Costs[ResourceType.Iron] - Iron)
	end

	if _Costs[ResourceType.Stone] ~= nil and Stone < _Costs[ResourceType.Stone] then
		Message = _Costs[ResourceType.Stone] - Stone .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughStone")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Stone, _Costs[ResourceType.Stone] - Stone)
	end

	if _Costs[ResourceType.Clay] ~= nil and Clay < _Costs[ResourceType.Clay]  then
		Message = _Costs[ResourceType.Clay] - Clay .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughClay")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Clay, _Costs[ResourceType.Clay] - Clay)
	end

	if _Costs[ResourceType.Wood] ~= nil and Wood < _Costs[ResourceType.Wood]  then
		Message = _Costs[ResourceType.Wood] - Wood .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughWood")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Wood, _Costs[ResourceType.Wood] - Wood)
	end

	if _Costs[ResourceType.Gold] ~= nil and Gold < _Costs[ResourceType.Gold]
	and _Costs[ResourceType.Gold] ~= 0 then
		Message = _Costs[ResourceType.Gold] - Gold .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughMoney")
		GUI.AddNote(Message)
		GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Gold, _Costs[ResourceType.Gold] - Gold)
	end
	
	if _Costs[ResourceType.Knowledge] ~= nil and Coal < _Costs[ResourceType.Knowledge]  then
		Message = _Costs[ResourceType.Knowledge] - Coal .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughCoal")
		GUI.AddNote(Message)
		--GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Knowledge, _Costs[ResourceType.Knowledge] - Coal)
	end

	-- Any message
	if Message ~= "" then
		return 0
	else
		return 1
	end

end

function InterfaceTool_UpdateUpgradeButtons(_EntityType, _UpgradeCategory, _ButtonNameStem)

	if _ButtonNameStem == "" then
		return
	end

	local Upgrades = {Logic.GetBuildingTypesInUpgradeCategory(_UpgradeCategory)}

	if Upgrades[1] == 2 then
		if _EntityType == Upgrades[2] then
			XGUIEng.ShowWidget(_ButtonNameStem .. 1,1)
		else
			XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
		end

	elseif Upgrades[1] == 3 then
		local i
		for i = 1, Upgrades[1], 1
		do
			if _EntityType == Upgrades[i+1] then

			 	if i == 1 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
				elseif i == 2 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,1)
				else
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
				end
			end
		end
	elseif Upgrades[1] == 5 then
		local i
		for i = 1, Upgrades[1], 1
		do
			if _EntityType == Upgrades[i+1] then

			 	if i == 1 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				elseif i == 2 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				elseif i == 3 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				elseif i == 4 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,1)
				else
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				end
			end
		end
	end
end