	BS = BS or {}

	BS.Version = 0.699

	BS.CurrentMappoolTotalAmount = 0

	BS.MapList = {
				[1] =	{
					},
				[2] =	{
					["(2) bs koop canyon"] = true,
					["(2) bs koop castrum"] = true,
					["(2) bs koop eisiger fjord"] = true,
					["(2) bs koop kerberos dunkle horden"] = true,
					["(2) bs koop vereinter widerstand"] = true,
					["(2) bs koop dunkelheit"] = true,
					["(2) bs koop kampf oder flucht"] = true,
					["(2) bs koop schlacht um evelance"] = true,
					["(2) bs koop vargs bergfestung"] = true,
					["(2) bs koop bergpass"] = true,
					["(2) bs koop alte zeiten"] = true,
					["(2) bs koop evelance schrecken"] = true,
					["(2) bs koop helft halberstaedt"] = true,
					["(2) bs koop silbertal"] = true,
					["(2) bs koop trockenzeit"] = true,
					["(2) bs koop winterplateau"] = true,
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
					["(3) bs koop vargs bergfestung"] = true,
					["(3) bs koop canyon"] = true,
					["(3) emsbs der lachende dritte"] = true,
					["(3) emsbs eingekesselt"] = true,
					["(3) emsbs hochland"] = true,
					["(3) emsbs gestrandet"] = true
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
					["(4) emsbs winterliche bergpaesse"] = true,
					["(4) emsbs verschneites moor"] = true,
					["(4) emsbs glc battlestar"] = true,
					["(4) emsbs im graben der verdammnis"] = true
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
					["(7) bs koop vargs raubzug"] = true,
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

	Score.WinPoints = 1
	Score.ResearchPoints = 50
	Score.UpgradePoints = 25
	Score.BattleSettlersPoints = 3
	Score.BattleBuildingPoints = 50
	Score.SettlersPoints = 5 
	Score.ResourcePoints  = 0.05
	Score.ConstructionPoints = 5
	-----------------------------------------------------------------------------------------------------------------------------
	-------------------- important Balancing_Stuff... Stuff ^^ ; do not change or even delete -----------------------------------
	-----------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------- loading scripts --------------------------------------------------------------
	do
		local files = {
			"Weathersets",
			"CNetworkHandler",
			"Lighthouse",
			"MercenaryTower",
			"Lightning",
			"DZTradePunishment",
			"SilversmithGrievance",
			"AI",
			"Castle",
			"Tower",
			"Scaremonger",
			"Trigger",
			"Comforts",
			"InterfaceTools",
			"GameCallbacks",
			"GUITooltips",
			"GUIUpdate",
			"GUIAction",
			"VersionCheck"
		};
		table.foreach(files,function(_,_value)Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\".._value..".lua")end);
	end
	
	CUtil.DisableFoW()
	Camera.ZoomSetFactorMax(2)
	gvMission = {}
	gvMission.PlayerID = GUI.GetPlayerID()
	gvLastTimeButtonPressed = -240000 	
	
	--zusätzliche Taunts hinzugefügt
	BonusKeys()
	
	------------------------------------ Trigger initialisieren -----------------------------------------------------
	--Trigger für Handel
	Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "TransactionDetails", 1)
	--Trigger für Spez-Gebäude (Schreckensgebäude/Dom etc.)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SpezEntityPlaced", 1)
	--Trigger für Salim-Falle
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SalimTrapPlaced", 1)
	--Trigger für Schlösser
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnCastleCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCastleDestroyed", 1)
	--Trigger für Türme
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnTowerCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnTowerDestroyed", 1)
	--Trigger für Drake
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "DrakeHeadshotDamage", 1);
	--Trigger für Heldentod
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "OnHeroDied", 1)
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
	----------------------------------- GUI und spezielle Scripte laden (verschiedene für EMS und Koop Karten ----------------------------------
	if not gvEMSFlag then
		CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_GUI.xml")
		Script.Load("maps\\user\\EMS\\tools\\Sync.lua")	
		function Sync.Send(_str)
			if CNetwork then
				XNetwork.Chat_SendMessageToAll(_str)
			else
				MPGame_ApplicationCallback_ReceivedChatMessage(_str, 0, GUI.GetPlayerID())
			end
		end
		Sync.Init()
	else
		CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_EMS_GUI.xml")
		Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\EMSAdditions.lua")	
	end
	BS.VersionCheck.Setup()
	--Simis Rotation Widget nach links schieben, damit es visuell besser in die größere GUI passt
	XGUIEng.SetWidgetPosition("RotateBack",389, 4) 
