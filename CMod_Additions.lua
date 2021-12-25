------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Tables and misc Stuff --------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
if XNetwork.Manager_DoesExist() ~= 0 then
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		Logic.SetTechnologyState(i,Technologies.MU_Cannon5,0)
		Logic.SetTechnologyState(i,Technologies.MU_Cannon6,0)
		if gvXmasEventFlag or gvTutorialFlag then
			Logic.SetTechnologyState(i,Technologies.B_VillageHall,0) 
		end
			
	end
	if GUI.GetPlayerID() == 17 then
		Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "HideGUI()", 2 )
	end
	Logic.SetTechnologyState(17,Technologies.GT_Tactics,3)
	
	-----------------------------------------------------------------------------------------------
	-- Added Castles to win condition ------------------------------------------------------------
	-----------------------------------------------------------------------------------------------
	MultiplayerTools.EntityTableHeadquarters = {Entities.PB_Headquarters1,Entities.PB_Headquarters2,Entities.PB_Headquarters3,Entities.PB_Castle1,Entities.PB_Castle2,Entities.PB_Castle3,Entities.PB_Castle4,Entities.PB_Castle5}
		

else
	Logic.SetTechnologyState(1,Technologies.UP1_Lighthouse,3)
	Logic.SetTechnologyState(1,Technologies.MU_Cannon5,0)
	Logic.SetTechnologyState(1,Technologies.MU_Cannon6,0)
	if gvXmasEventFlag then
		Logic.SetTechnologyState(1,Technologies.B_VillageHall,0) 
	end
		
	XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer = function()
		return 1
	end
	MultiplayerTools.RemoveAllPlayerEntities = function( _PlayerID)
	end
	GUIUpdate_BuyHeroButton = function()	
		if Logic.GetNumberOfBuyableHerosForPlayer( GUI.GetPlayerID() ) > 0 then			
			XGUIEng.ShowWidget(XGUIEng.GetCurrentWidgetID(),1)	
		else		
			XGUIEng.ShowWidget(XGUIEng.GetCurrentWidgetID(),0)		
		end	
	end	
	GUIAction_ToggleMenu_Orig = GUIAction_ToggleMenu	
	GUIAction_ToggleMenu = function(_menu, _status)	
		if _menu == gvGUI_WidgetID.BuyHeroWindow then	
			XGUIEng.ShowWidget(gvGUI_WidgetID.BuyHeroWindow, 1)
		else	
			GUIAction_ToggleMenu_Orig(_menu, _status)	
		end	
		gvMission.singleplayerMode = true	
	end
end
	
if CUtil then
      
	refined_resource_gold = {
        [Entities.PB_Bank1] = 3;
        [Entities.PB_Bank2] = 3;
        [Entities.PB_Bank3] = 4;
		[Entities.CB_Mint1] = 3;
    };
	
	gained_resource_clay = {
	    [Entities.PB_ClayMine1] = 5;
		[Entities.PB_ClayMine2] = 7;
		[Entities.PB_ClayMine3] = 9;
	};
	
	gained_resource_iron = {		
		[Entities.PB_IronMine1] = 5;
		[Entities.PB_IronMine2] = 7;
		[Entities.PB_IronMine3] = 9;
	};
	
	gained_resource_stone = {
		[Entities.PB_StoneMine1] = 5;
		[Entities.PB_StoneMine2] = 7;
		[Entities.PB_StoneMine3] = 9;
	};
		
	gained_resource_sulfur = {
		[Entities.PB_SulfurMine1] = 5;
		[Entities.PB_SulfurMine2] = 7;
		[Entities.PB_SulfurMine3] = 9;
	};
	
	gained_resource_silver = {
		[Entities.PB_SilverMine1] = 2;
		[Entities.PB_SilverMine2] = 2;
		[Entities.PB_SilverMine3] = 3;
	};
	
	gained_resource_gold = {
		[Entities.PB_GoldMine1] = 5;
		[Entities.PB_GoldMine2] = 7;
		[Entities.PB_GoldMine3] = 9;
	};

end
--Silver added to resource window
if CNetwork then
	if MP_DiplomacyWindow.resource_to_name then
		MP_DiplomacyWindow.resource_to_name = {
			[ResourceType.GoldRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameMoney") .. " [R]";
			[ResourceType.ClayRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameClay") .. " [R]";
			[ResourceType.WoodRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameWood") .. " [R]";
			[ResourceType.StoneRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameStone") .. " [R]";
			[ResourceType.IronRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameIron") .. " [R]";
			[ResourceType.SulfurRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameSulfur") .. " [R]";
			[ResourceType.SilverRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameSilver") .. " [R]";
					
			[ResourceType.Gold] = "@color:184,182,90: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameMoney") .. " @color:255,255,255,255: ";
			[ResourceType.Clay] = "@color:115,66,34: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameClay") .. " @color:255,255,255,255: ";
			[ResourceType.Wood] = "@color:85,45,9: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameWood") .. " @color:255,255,255,255: ";
			[ResourceType.Stone] = "@color:147,147,136: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameStone") .. " @color:255,255,255,255: ";
			[ResourceType.Iron] = "@color:98,108,100: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameIron") .. " @color:255,255,255,255: ";
			[ResourceType.Sulfur] = "@color:234,240,68: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameSulfur") .. " @color:255,255,255,255: ";
			[ResourceType.Silver] =  " @color:198,208,200: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameSilver") .. " @color:255,255,255,255: ";
		};
			
			
		MP_DiplomacyWindow.resource_to_next = {
			[ResourceType.Gold] = ResourceType.Clay;
			[ResourceType.Clay] = ResourceType.Wood;
			[ResourceType.Wood] = ResourceType.Stone;
			[ResourceType.Stone] = ResourceType.Iron;
			[ResourceType.Iron] = ResourceType.Sulfur;
			[ResourceType.Sulfur] = ResourceType.Silver;
			[ResourceType.Silver] = ResourceType.Gold;
				
			[ResourceType.GoldRaw] = ResourceType.ClayRaw;
			[ResourceType.ClayRaw] = ResourceType.WoodRaw;
			[ResourceType.WoodRaw] = ResourceType.StoneRaw;
			[ResourceType.StoneRaw] = ResourceType.IronRaw;
			[ResourceType.IronRaw] = ResourceType.SulfurRaw;
			[ResourceType.SulfurRaw] = ResourceType.SilverRaw;
			[ResourceType.SilverRaw] = ResourceType.Gold;
		};
			
		MP_DiplomacyWindow.resource_to_check = {
				
			[ResourceType.Gold] = { ResourceType.Gold, ResourceType.GoldRaw },
			[ResourceType.Clay] = { ResourceType.Clay, ResourceType.ClayRaw },
			[ResourceType.Wood] = { ResourceType.Wood, ResourceType.WoodRaw },
			[ResourceType.Stone] = { ResourceType.Stone, ResourceType.StoneRaw },
			[ResourceType.Iron] = { ResourceType.Iron, ResourceType.IronRaw },
			[ResourceType.Sulfur] = { ResourceType.Sulfur, ResourceType.SulfurRaw },
			[ResourceType.Silver] = { ResourceType.Silver, ResourceType.SilverRaw },
				
			[ResourceType.GoldRaw] = { ResourceType.GoldRaw },
			[ResourceType.ClayRaw] = { ResourceType.ClayRaw },
			[ResourceType.WoodRaw] = { ResourceType.WoodRaw },
			[ResourceType.StoneRaw] ={ ResourceType.StoneRaw },
			[ResourceType.IronRaw] = { ResourceType.IronRaw },
			[ResourceType.SulfurRaw] = { ResourceType.SulfurRaw },
		};
		if MP_DiplomacyWindow.allowed_resources then
		 MP_DiplomacyWindow.allowed_resources = {
			[ResourceType.Gold] = true;
			[ResourceType.Clay] = true;
			[ResourceType.Wood] = true;
			[ResourceType.Stone] = true;
			[ResourceType.Iron] = true;
			[ResourceType.Sulfur] = true;
			[ResourceType.Silver] = true;
		};
		end
		if MP_DiplomacyWindow.raw_resources_allowed then
			MP_DiplomacyWindow.allowed_resources[ResourceType.GoldRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.ClayRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.WoodRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.StoneRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.IronRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.SulfurRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.SilverRaw] = true;
				
			MP_DiplomacyWindow.resource_to_next[ResourceType.Silver] = ResourceType.GoldRaw;
			
		end;
	end
end