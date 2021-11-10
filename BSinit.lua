BS = BS or {}

BS.Version = 0.689

BS.CurrentMappoolTotalAmount = 0

BS.MapList = { 	[1] =	{
					},
				[2] =	{
					["(2) bs koop canyon"] = true,
					["(2) bs koop castrum"] = true,
					["(2) bs koop eisiger fjord"] = true,
					["(2) bs koop kerberos dunkle horden"] = true,
					["(2) bs koop vereinter widerstand"] = true,
					["(2) bs koop dunkelheit"] = true,
					["(2) bs koop kampf oder flucht"] = true,
					["(2) emsbs dunkelforst"] = true,
					["(2) emsbs kampf am kap"] = true,
					["(2) emsbs leichenfledderer"] = true,
					["(2) emsbs schnitters abenddaemmerung"] = true,
					["(2) emsbs schwefelwahn"] = true,
					["(2) emsbs skal"] = true,
					["(2) emsbs trommeln im moor"] = true,
					["(2) emsbs zerklueftete inseln"] = true,
					["(2) emsbs fort nogersund"] = true,
					["(2) emsbs grabenkampf"] = true,
					["(2) emsbs der taktiker"] = true,
					["(2) emsbs die alten imperien"] = true
					},
				[3] =	{
					["(3) bs koop kalas zorn"] = true,
					["(3) bs koop kerberos dunkle horden"] = true,
					["(3) bs koop marys verrat"] = true,
					["(3) bs koop schlacht um evelance"] = true,
					["(3) bs koop vereinter widerstand"] = true,
					["(3) bs koop dunkelheit"] = true,
					["(3) emsbs der lachende dritte"] = true,
					["(3) emsbs eingekesselt"] = true,
					["(3) emsbs hochland"] = true
					},
				[4] =	{
					["(4) bs koop angriff auf evelance"] = true,
					["(4) bs koop die smaragdebene"] = true,
					["(4) bs koop kalas giftnebel"] = true,
					["(4) bs koop marys intrige"] = true,
					["(4) bs koop die tore der stadt"] = true,
					["(4) emsbs battle isle"] = true,
					["(4) emsbs eklipse"] = true,
					["(4) emsbs grosser wald des daemmerlichts"] = true,
					["(4) emsbs kaloix"] = true,
					["(4) emsbs kaltenberg"] = true,
					["(4) emsbs nachtmahr"] = true,
					["(4) emsbs nebelberge"] = true,
					["(4) emsbs nebelsteppe"] = true,
					["(4) emsbs rotzzcana"] = true,
					["(4) emsbs schneetage"] = true,
					["(4) emsbs steppenkampf"] = true,
					["(4) emsbs tropensturm"] = true,
					["(4) emsbs die zusammenkunft"] = true,
					["(4) emsbs imperium"] = true,
					["(4) emsbs magic circle"] = true,
					["(4) emsbs sand cliffs"] = true,
					["(4) emsbs winterberge"] = true,
					["(4) emsbs verschneites moor"] = true,
					["(4) emsbs glc battlestar"] = true
					},
				[5] = 	{
					["(5) bs koop der grosse aufstand"] = true,
					["(5) bs koop kerberos dunkle horden"] = true,
					["(5) emsbs feste nuamyr"] = true,
					["(5) emsbs marys intrige"] = true,
					["(5) emsbs predominance"] = true
					},
				[6] =	{
					["(6) bs koop vargs raubzug"] = true,
					["(6) emsbs die zwei burgherrn"] = true,
					["(6) emsbs heldenschlacht"] = true,
					["(6) emsbs hochland"] = true,
					["(6) emsbs inseln der ahnen"] = true,
					["(6) emsbs tropensturm"] = true,
					["(6) emsbs schneetage"] = true,
					["(6) emsbs riffe"] = true
					},
				[7] = 	{
					["(7) emsbs blutmoor"] = true,
					["(7) emsbs wuesteninsel"] = true
					},
				[8] = 	{
					["(8) emsbs die kralberge"] = true,
					["(8) emsbs die zwei burgherrn"] = true,
					["(8) emsbs finsteres evelance"] = true,
					["(8) emsbs inferno"] = true,
					["(8) emsbs smaragdinseln"] = true,
					["(8) emsbs tropensturm"] = true,
					["(8) emsbs verrat"] = true,
					["(8) emsbs schneetage"] = true,
					["(8) emsbs death island"] = true,
					["(8) emsbs koenigreiche"] = true
					},
				[9] = 	{
					},
				[10] =	{
					["(10) emsbs goldrausch"] = true,
					["(10) emsbs tropensturm"] = true,
					["(10) emsbs kuestenlandschaft"] = true
					},
				[11] = 	{
					},
				[12] = 	{
					["(12) emsbs goldrausch"] = true,
					["(12) emsbs grabraeuber"] = true,
					["(12) emsbs tropensturm"] = true,
					["(12) emsbs wilde horden"] = true
					}
					
				
				}

-- counting total Map amount (currently not used, just for information purpose)				
do
	local i = table.getn(BS.MapList)
	
	while i > 0 do

		local count = 0
		for _ in pairs(BS.MapList[i]) do 
			count = count + 1 
		end

		BS.CurrentMappoolTotalAmount = BS.CurrentMappoolTotalAmount + count
	
		i = i - 1 
	end
	
end
function BS.ValidateMap()
	if XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() > 0 then
		return BS.MapList[XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()][Framework.GetCurrentMapName()]
	else
		return true
	end
end
if CNetwork then
	if BS.ValidateMap() ~= true then
		Framework.CloseGame()
	end
end
if gvXmasEventFlag == 1 then
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\PresentControl.lua")
end
-- Score stuff
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
--[[ Score points orig values
Score.WinPoints = 200
Score.ResearchPoints = 5
Score.UpgradePoints = 5
Score.BattleSettlersPoints = 2
Score.BattleBuildingPoints = 5
Score.SettlersPoints = 2 
Score.ResourcePoints  = 0.2
Score.ConstructionPoints = 5]]

Score.WinPoints = 1
Score.ResearchPoints = 50
Score.UpgradePoints = 25
Score.BattleSettlersPoints = 3
Score.BattleBuildingPoints = 50
Score.SettlersPoints = 5 
Score.ResourcePoints  = 0.05
Score.ConstructionPoints = 5

-- Spectator Buttons and Widgets (Correct Icon shown)
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
if EMS then
	if EMS.GC then
		if EMS.GC.HeroKeys then
			EMS.GC.HeroKeys[Entities.PU_Hero13] = "Dovbar"
			_G.EMS.RD.Rules["Dovbar"] = EMS.T.CopyTable(EMS.RD.Templates.StdHero)
			_G.EMS.RD.Rules["Dovbar"].HeroID = 13
			_G.EMS.RD.Rules["Dovbar"].value = 1
			EMS.L.Heroes[13] = "Dovbar"
			EMS.RD.Config.Dovbar = 1
		end
	end					
end

-- important Balancing_Stuff... Stuff ^^ ; do not change or even delete	
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\Weathersets.lua" )
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\CNetworkHandler.lua" )
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\Comforts.lua" )
	Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\GameCallbacks.lua" )	
	
	if not gvEMSFlag then
		Script.Load( "maps\\user\\Balancing_Stuff_in_Dev\\S5Hook.lua" )
		InstallS5Hook()
	end
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\MemoryManipulation.lua")
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\GUITooltips.lua")
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\GUIUpdate.lua")
	Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\GUIAction.lua")
	MemoryManipulation.CreateLibFuncs()	
	
	CUtil.DisableFoW()
	Camera.ZoomSetFactorMax(2)
	gvMission = {}
	gvMission.PlayerID = GUI.GetPlayerID()
	gvLastTimeButtonPressed = -240000 	
	
	--zusätzliche Taunts hinzugefügt
	BonusKeys()
	--Trigger für Handel
	Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "TransactionDetails", 1)
	--Trigger für Spez-Gebäude (Schreckensgebäude/Dom etc.)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SpezEntityPlaced", 1)
	--Trigger für Salim-Falle
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SalimTrapPlaced", 1)
	--Trigger für Schlösser
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnCastleCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCastleDestroyed", 1)
	--Trigger für Drake
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "drakedmg", 1);
	--Trigger für Leibeigene
	SerfIDTable = {Logic.GetEntities(Entities.PU_Serf,30)}
	table.remove(SerfIDTable,1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SerfCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "SerfDestroyed", 1)
	StartCountdown(5,SerfHPRegen,false)
	if CUtil then 
		for i = 1,16 do 
			CUtil.Payday_SetActive(i, true) 
		end 
	end
	StartSimpleJob("WinterTheme")
	StartSimpleJob("IngameTimeJob")
	StartSimpleJob("BloodRushCheck")
	StartSimpleJob("Lightning_Job")
	DZTrade_Init()
	StartCountdown(5*60,BeautiAnimCheck,false)
	if not gvEMSFlag then
		CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_GUI.xml")
	else
		CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_EMS_GUI.xml")
	end
	--Simis Rotation Widget nach links schieben, damit es visuell besser in die größere GUI passt
	XGUIEng.SetWidgetPosition("RotateBack",389, 4) 
