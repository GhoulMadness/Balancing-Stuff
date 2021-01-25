BS = BS or {}

BS.Version = 0.615

if gvXmasEventFlag == 1 then
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\PresentControl.lua")
end

-- needed for SWFire Mod
if not Score.Player[0] then
	Score.Player[0] = {
        battle = 0,
        buildings = 0,
        settlers = 2,
        all = 2,
        resources = 0,
        technology = 0,
	};
end	
if 	gvGUI_TechnologyButtonIDArray then
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
-- important Balancing_Stuff... Stuff ^^ ; do not change or even delete	
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\Weathersets.lua" )
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\CNetworkHandler.lua" )
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\Comforts.lua" )
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\GameCallbacks.lua" )	
	--Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\SWFire.lua")
	if not gvEMSFlag then
		Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\S5Hook.lua" )
		InstallS5Hook()
	end
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\MemoryManipulation.lua")
	--Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\mcbProjectileFix.lua")
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\GUITooltips.lua")
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\GUIUpdate.lua")
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\GUIAction.lua")
	MemoryManipulation.CreateLibFuncs()	
	--kann aktuell noch Desyncs verursachen...
	--CUtil.DisableFoW()
	Camera.ZoomSetFactorMax(2)
	gvMission = {}
	gvMission.PlayerID = GUI.GetPlayerID()
	gvLastTimeButtonPressed = -240000 	
	--[[ not needed anymore; already fixed/defined in the names.xml; mode can´t be played on instances other than Simis Server anyway
	if CUtil then
		CUtil.SetStringTableText("names/PB_GunsmithWorkshop1", "B\195\188chsen @bs macherei")
		CUtil.SetStringTableText("names/CB_Castle2", "Handelsposten")
		CUtil.SetStringTableText("names/CB_OldKingsCastleRuin", "Nebelburg")  
	else
		S5Hook.ChangeString("names/pb_gunsmithworkshop1", "Büchsen @bs macherei")
		S5Hook.ChangeString("names/cb_castle2", "Handelsposten")	  
    end ]]
	--zusätzliche Taunts hinzugefügt
	BonusKeys()
	--Trigger für Handel
	Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "TransactionDetails", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SpezEntityPlaced", 1)
	if CUtil then 
		for i = 1,16 do 
			CUtil.Payday_SetActive(i, true) 
		end 
	end
	StartSimpleJob("WinterTheme")
	StartSimpleJob("Unwetter")
	StartSimpleJob("IngameTimeJob")
	StartSimpleJob("BloodRushCheck")
	DZTrade_Init()
	StartCountdown(10*60,BeautiAnimCheck,false)
	
	if not gvEMSFlag then
		S5Hook.LoadGUI("maps\\user\\Balancing_Stuff_in_Dev\\BS_GUI.xml")
	else
		S5Hook.LoadGUI("maps\\user\\Balancing_Stuff_in_Dev\\BS_EMS_GUI.xml")
	end
