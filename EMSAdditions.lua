if EMS then
	-- load widgets
	WidgetHelper.AddPreCommitCallback(
	function()
		CWidget.Transaction_AddRawWidgetsFromFile("extra2/shr/maps/user/Balancing_Stuff_in_Dev/EMS_Menu.xml","Normal")
		CWidget.Transaction_AddRawWidgetsFromFile("extra2/shr/maps/user/Balancing_Stuff_in_Dev/EMS_Menu_Additions.xml","Normal")
		CWidget.Transaction_AddRawWidgetsFromFile("extra2/shr/maps/user/Balancing_Stuff_in_Dev/EMS_RuleOverview.xml","Normal")
	end)
	-- localizations and rule stuff
	EMS.GC.HeroKeys[Entities.PU_Hero13] = "Dovbar"
	EMS.RD.Rules["Dovbar"] = EMS.T.CopyTable(EMS.RD.Templates.StdHero)
	EMS.RD.Rules["Dovbar"].HeroID = 13
	EMS.RD.HeroKeys[13] = "Dovbar"

	EMS.GC.HeroKeys[Entities.PU_Hero14] = "Erebos"
	EMS.RD.Rules["Erebos"] = EMS.T.CopyTable(EMS.RD.Templates.StdHero)
	EMS.RD.Rules["Erebos"].HeroID = 14
	EMS.RD.HeroKeys[14] = "Erebos"

	EMS.L.MakeThunderstorm = "Unwetter"
	EMS.L.Castle = "Landsitze"
	EMS.L.CastleDescription = "Erlaubt oder verbietet den Bau von Landsitzen"
	EMS.L.CastleLevel = "Ausbaustufe Landsitze"
	EMS.L.CastleLevelDescription = "Legt die maximale Ausbaustufe fest, zu der ihr Landsitze ausbauen könnt!"
	EMS.L.CastleLevels = {
			"Landsitze",
			"Herrenhäuser",
			"Villen",
			"Schlösser",
			"Königsfesten"
		}
	EMS.L.Lighthouse = "Leuchttürme"
	EMS.L.LighthouseDescription = "Erlaubt oder verbietet den Bau von Leuchttürmen"
	EMS.L.LighthouseLevel = "Ausbaustufe Leuchttürme"
	EMS.L.LighthouseLevelDescription = "Legt die maximale Ausbaustufe fest, zu der ihr Leuchttürme ausbauen könnt!"
	EMS.L.LighthouseLevels = {
			"Verfallene Leuchttürme",
			"Leuchttürme"
		}
	EMS.L.Dome = "Dom"
	EMS.L.DomeDescription = "Erlaubt oder verbietet den Bau von Domen"
	EMS.L.Silversmith = "Silberschmelzen"
	EMS.L.SilversmithDescription = "Erlaubt oder verbietet den Bau von Silberschmelzen"
	EMS.L.SilversmithLevel = "Ausbaustufe Silberschmelzen"
	EMS.L.SilversmithLevelDescription = "Legt die maximale Ausbaustufe fest, zu der ihr Silberschmelzen ausbauen könnt!"
	EMS.L.SilversmithLevels = {
			"Silberschmelze",
			"Silbergießerei"
		}
	EMS.L.Mercenary = "Söldnertürme"
	EMS.L.MercenaryDescription = "Erlaubt oder verbietet den Bau von Söldnertürmen"
	EMS.L.Scaremonger = "Schreckensgebäude"
	EMS.L.ScaremongerDescription = "Erlaubt oder verbietet den Bau von Schreckensgebäuden"
	EMS.L.Heroes[13] = "Dovbar"
	EMS.L.Heroes[14] = "Erebos"


	EMS.GL.GUIUpdate["CastleLevel"] = EMS.GL.GUIUpdate_Units
	EMS.GL.GUIUpdate["LighthouseLevel"] = EMS.GL.GUIUpdate_Units
	EMS.GL.GUIUpdate["Dome"] = EMS.GL.GUIUpdate_Units
	EMS.GL.GUIUpdate["SilversmithLevel"] = EMS.GL.GUIUpdate_Units
	EMS.GL.GUIUpdate["Mercenary"] = EMS.GL.GUIUpdate_Units
	EMS.GL.GUIUpdate["Scaremonger"] = EMS.GL.GUIUpdate_Units
	EMS.GL.GUIUpdate["MakeThunderstorm"] = EMS.GL.GUIUpdate_GfxToggleButton
	EMS.GL.GUIUpdate["Dovbar"] = EMS.GL.GUIUpdate_GfxToggleButton
	EMS.GL.GUIUpdate["Erebos"] = EMS.GL.GUIUpdate_GfxToggleButton

	EMS.GL.MapRuleToGUIWidget["CastleLevel"] = {"EMSPU13Lvl",5}
	EMS.GL.MapRuleToGUIWidget["LighthouseLevel"] = {"EMSPU14Lvl",2}
	EMS.GL.MapRuleToGUIWidget["Dome"] = {"EMSPU15Lvl",1}
	EMS.GL.MapRuleToGUIWidget["SilversmithLevel"] = {"EMSPU16Lvl",3}
	EMS.GL.MapRuleToGUIWidget["Mercenary"] = {"EMSPU17Lvl",1}
	EMS.GL.MapRuleToGUIWidget["Scaremonger"] = {"EMSPU18Lvl",1}
	EMS.GL.MapRuleToGUIWidget["Dovbar"] = "EMSPH13N"
	EMS.GL.MapRuleToGUIWidget["Erebos"] = "EMSPH14N"
	EMS.GL.MapRuleToGUIWidget["MakeThunderstorm"] = "EMSPUGF3Value4"

	EMS.RD.Rules.MakeThunderstorm = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
	function EMS.RD.Rules.MakeThunderstorm:GetTitle()
		return EMS.L.MakeThunderstorm;
	end

	function EMS.RD.Rules.MakeThunderstorm:GetDescription()
		return EMS.GV.TooltipNormalColor1 .. EMS.L.MakeDescription1 .. EMS.GV.TooltipHighlightColor1 .. self:GetTitle() .. EMS.GV.TooltipNormalColor1 .. EMS.L.MakeDescription2;
	end

	function EMS.RD.Rules.MakeThunderstorm:Evaluate()
		if self.value == 0 then
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies.T_MakeThunderstorm, playerId);
			end
		end
	end
	EMS.RD.Rules.Dome = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
	function EMS.RD.Rules.Dome:GetRepresentative()
		if self.value == -1 then
			return EMS.L.Forbidden;
		elseif self.value == 0 then
			return EMS.L.Allowed;
		end
		return self.value;
	end

	function EMS.RD.Rules.Dome:GetTitle()
		return EMS.L.Dome;
	end

	function EMS.RD.Rules.Dome:GetDescription()
		return EMS.L.DomeDescription;
	end

	function EMS.RD.Rules.Dome:Evaluate()
		if self.value == 0 then
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies["B_Dome"], playerId);
			end
		end
	end
	EMS.RD.Rules.Mercenary = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
	function EMS.RD.Rules.Mercenary:GetRepresentative()
		if self.value == -1 then
			return EMS.L.Forbidden;
		elseif self.value == 0 then
			return EMS.L.Allowed;
		end
		return self.value;
	end

	function EMS.RD.Rules.Mercenary:GetTitle()
		return EMS.L.Mercenary;
	end

	function EMS.RD.Rules.Mercenary:GetDescription()
		return EMS.L.MercenaryDescription;
	end

	function EMS.RD.Rules.Mercenary:Evaluate()
		if self.value == 0 then
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies["B_Mercenary"], playerId);
			end
		end
	end
	EMS.RD.Rules.Scaremonger = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
	function EMS.RD.Rules.Scaremonger:GetRepresentative()
		if self.value == -1 then
			return EMS.L.Forbidden;
		elseif self.value == 0 then
			return EMS.L.Allowed;
		end
		return self.value;
	end

	function EMS.RD.Rules.Scaremonger:GetTitle()
		return EMS.L.Scaremonger;
	end

	function EMS.RD.Rules.Scaremonger:GetDescription()
		return EMS.L.ScaremongerDescription;
	end

	function EMS.RD.Rules.Scaremonger:Evaluate()
		if self.value == 0 then
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies["GT_Scaremonger"], playerId);
			end
		end
	end

	EMS.RD.Rules.CastleLevel = EMS.T.CopyTable(EMS.RD.StdMUnit);
	EMS.RD.Rules.CastleLevel.maxLevel = 5;
	EMS.RD.Rules.CastleLevel.Representatives =
	{
		[0] = EMS.L.Forbidden,
		EMS.L.CastleLevels[1],
		EMS.L.CastleLevels[2],
		EMS.L.CastleLevels[3],
		EMS.L.CastleLevels[4],
		EMS.L.CastleLevels[5],
	}

	function EMS.RD.Rules.CastleLevel:GetTitle()
		return EMS.L.CastleLevel;
	end

	function EMS.RD.Rules.CastleLevel:Evaluate()
		local utechs = {"B_Castle", "UP1_Castle", "UP2_Castle", "UP3_Castle", "UP4_Castle"}
		for i = self.maxLevel-1, self.value, -1 do
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies[utechs[i+1]], playerId);
			end
		end
	end

	EMS.RD.Rules.LighthouseLevel = EMS.T.CopyTable(EMS.RD.StdMUnit);
	EMS.RD.Rules.LighthouseLevel.maxLevel = 2;
	EMS.RD.Rules.LighthouseLevel.Representatives =
	{
		[0] = EMS.L.Forbidden,
		EMS.L.LighthouseLevels[1],
		EMS.L.LighthouseLevels[2]
	}

	function EMS.RD.Rules.LighthouseLevel:GetTitle()
		return EMS.L.LighthouseLevel;
	end

	function EMS.RD.Rules.LighthouseLevel:Evaluate()
		local utechs = {"B_Lighthouse", "UP1_Lighthouse"}
		for i = self.maxLevel-1, self.value, -1 do
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies[utechs[i+1]], playerId);
			end
		end
	end


	EMS.RD.Rules.SilversmithLevel = EMS.T.CopyTable(EMS.RD.StdMUnit);
	EMS.RD.Rules.SilversmithLevel.maxLevel = 2;
	EMS.RD.Rules.SilversmithLevel.Representatives =
	{
		[0] = EMS.L.Forbidden,
		EMS.L.SilversmithLevels[1],
		EMS.L.SilversmithLevels[2]
	}

	function EMS.RD.Rules.SilversmithLevel:GetTitle()
		return EMS.L.SilversmithLevel;
	end

	function EMS.RD.Rules.SilversmithLevel:Evaluate()
		local utechs = {"B_Silversmith", "UP1_Silversmith"}
		for i = self.maxLevel-1, self.value, -1 do
			for playerId, data in pairs(EMS.PlayerList) do
				ForbidTechnology(Technologies[utechs[i+1]], playerId);
			end
		end
	end
	EMS.RD.Config.CastleLevel = 5
	EMS.RD.Config.LighthouseLevel = 2
	EMS.RD.Config.Dome = 1
	EMS.RD.Config.SilversmithLevel = 2
	EMS.RD.Config.Mercenary = 1
	EMS.RD.Config.Scaremonger = 1
	EMS.RD.Config.MakeThunderstorm = 1
	EMS.RD.Config.Dovbar = 1
	EMS.RD.Config.Erebos = 1

	EMS.RD.Rules.CastleLevel.value = 5
	EMS.RD.Rules.LighthouseLevel.value = 2
	EMS.RD.Rules.Dome.value = 1
	EMS.RD.Rules.SilversmithLevel.value = 2
	EMS.RD.Rules.Mercenary.value = 1
	EMS.RD.Rules.Scaremonger.value = 1
	EMS.RD.Rules.MakeThunderstorm.value = 1
	EMS.RD.Rules["Dovbar"].value = 1
	EMS.RD.Rules["Erebos"].value = 1

	if EMS.QoL then

		EMS.QoL.NoOvertime[Entities.PB_Silversmith1] = true
		EMS.QoL.NoOvertime[Entities.PB_Silversmith2] = true
		EMS.QoL.NoOvertime[Entities.PB_Foundry1] = true
		EMS.QoL.NoOvertime[Entities.PB_Foundry2] = true

		function EMS.QoL.ActivateOvertime()

			local sel = GUI.GetSelectedEntity();
			local type = Logic.GetEntityType(sel);
			if Logic.IsBuilding(sel) == 0 then
				return;
			end
			if Logic.GetTechnologyState(GUI.GetPlayerID(),Technologies.GT_Laws) ~= 4 then
				return
			end
			if EMS.QoL.NoOvertime[type] then
				return;
			end
			if string.find(Logic.GetEntityTypeName(type), "Beautification" ,1,true) then
				return;
			end
			if Logic.IsConstructionComplete(sel) == 0 then
				return;
			end
			if Logic.GetOvertimeRechargeTimeAtBuilding(sel) ~= 0 then
				return
			end
			GUI.ToggleOvertimeAtBuilding(sel);
			if Logic.IsOvertimeActiveAtBuilding(sel) ~= 1 then
				if CNetwork then
					CNetwork.SendCommand("Ghoul_ForceSettlersToWorkPenalty", GUI.GetPlayerID());
				else
					GUIAction_ForceSettlersToWorkPenalty(GUI.GetPlayerID())
				end
			end
		end
	end
end
		-- Spectator Buttons and Widgets (Correct Icon shown)
if gvGUI_TechnologyButtonIDArray then
	gvGUI_TechnologyButtonIDArray[Technologies.T_ThunderStorm] = XGUIEng.GetWidgetID("Research_ThunderStorm");
	gvGUI_TechnologyButtonIDArray[Technologies.T_HeavyThunder] = XGUIEng.GetWidgetID("Research_HeavyThunder");
	gvGUI_TechnologyButtonIDArray[Technologies.T_TotalDestruction] = XGUIEng.GetWidgetID("Research_TotalDestruction");
	gvGUI_TechnologyButtonIDArray[Technologies.T_LightningInsurance] = XGUIEng.GetWidgetID("Research_LightningInsurance");
	gvGUI_TechnologyButtonIDArray[Technologies.T_Foresight] = XGUIEng.GetWidgetID("Research_Foresight");
	gvGUI_TechnologyButtonIDArray[Technologies.T_Alacricity] = XGUIEng.GetWidgetID("Research_Alacricity");
	gvGUI_TechnologyButtonIDArray[Technologies.T_BarbarianCulture] = XGUIEng.GetWidgetID("Research_BarbarianCulture");
	gvGUI_TechnologyButtonIDArray[Technologies.T_BanditCulture] = XGUIEng.GetWidgetID("Research_BanditCulture");
	gvGUI_TechnologyButtonIDArray[Technologies.T_BearmanCulture] = XGUIEng.GetWidgetID("Research_BearmanCulture");
	gvGUI_TechnologyButtonIDArray[Technologies.T_KnightsCulture] = XGUIEng.GetWidgetID("Research_KnightsCulture");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverPlateArmor] = XGUIEng.GetWidgetID("Research_SilverPlateArmor");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverArcherArmor] = XGUIEng.GetWidgetID("Research_SilverArcherArmor");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverArrows] = XGUIEng.GetWidgetID("Research_SilverArrows");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverSwords] = XGUIEng.GetWidgetID("Research_SilverSwords");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverLance] = XGUIEng.GetWidgetID("Research_SilverLance");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverBullets] = XGUIEng.GetWidgetID("Research_SilverBullets");
	gvGUI_TechnologyButtonIDArray[Technologies.T_SilverMissiles] = XGUIEng.GetWidgetID("Research_SilverMissiles");
	gvGUI_TechnologyButtonIDArray[Technologies.T_BloodRush] = XGUIEng.GetWidgetID("Research_BloodRush");
	gvGUI_TechnologyButtonIDArray[Technologies.T_Agility] = XGUIEng.GetWidgetID("Research_Agility");
	gvGUI_TechnologyButtonIDArray[Technologies.T_LeatherCoat] = XGUIEng.GetWidgetID("Research_LeatherCoat");
	gvGUI_TechnologyButtonIDArray[Technologies.GT_Taxation] = XGUIEng.GetWidgetID("Research_Taxation");
	gvGUI_TechnologyButtonIDArray[Technologies.GT_Laws] = XGUIEng.GetWidgetID("Research_Laws");
	gvGUI_TechnologyButtonIDArray[Technologies.GT_Banking] = XGUIEng.GetWidgetID("Research_Banking");
	gvGUI_TechnologyButtonIDArray[Technologies.GT_Gilds] = XGUIEng.GetWidgetID("Research_Gilds");
	gvGUI_TechnologyButtonIDArray[Technologies.T_LightBricks] = XGUIEng.GetWidgetID("Research_LightBricks");
	gvGUI_TechnologyButtonIDArray[Technologies.T_Debenture] = XGUIEng.GetWidgetID("Research_Debenture");
	gvGUI_TechnologyButtonIDArray[Technologies.T_BookKeeping] = XGUIEng.GetWidgetID("Research_BookKeeping");
	gvGUI_TechnologyButtonIDArray[Technologies.T_Scale] = XGUIEng.GetWidgetID("Research_Scale");
	gvGUI_TechnologyButtonIDArray[Technologies.T_Coinage] = XGUIEng.GetWidgetID("Research_Coinage");
	gvGUI_TechnologyButtonIDArray[Technologies.T_CropCycle] = XGUIEng.GetWidgetID("Research_CropCycle");
	gvGUI_TechnologyButtonIDArray[Technologies.T_CityGuard] = XGUIEng.GetWidgetID("Research_CityGuard");
	gvGUI_TechnologyButtonIDArray[Technologies.T_PickAxe] = XGUIEng.GetWidgetID("Research_PickAxe");
end
