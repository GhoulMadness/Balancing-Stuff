	BS = BS or {}

	BS.Version = 0.709

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
					["(2) bs koop erste pruefung - kampfgeschick"] = true,
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
					["(2) emsbs die alten imperien"] = true,
					["(2) emsbs hasenjagd"] = true
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
					["(3) bs koop die grossen drei"] = true,
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
					["(4) emsbs im graben der verdammnis"] = true,
					["(4) emsbs tal rasha"] = true,
					["(4) emsbs hasenjagd"] = true
					},
				[5] = 	{
					["(5) bs koop der grosse aufstand"] = true,
					["(5) bs koop kerberos dunkle horden"] = true,
					["(5) emsbs feste nuamyr"] = true,
					["(5) emsbs marys intrige"] = true,
					["(5) emsbs predominance"] = true,
					["(5) emsbs hochland"] = true
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
	-- close game if map not validated
	function BS.ValidateMap()
		if XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() > 0 then
			return BS.MapList[XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()][Framework.GetCurrentMapName()]
		else
			return true
		end
	end
	
	function BS.ValidateTextureQuality()
	
		if GDB.IsKeyValid( "Config\\Display\\TextureResolution" ) then
		
			return GDB.GetValue( "Config\\Display\\TextureResolution" ) == 0
			
		else
		
			return false
			
		end
		
	end
	
	if CNetwork then
	
		if BS.ValidateTextureQuality() ~= true then
		
			local text
		
			if XNetworkUbiCom.Tool_GetCurrentLanguageShortName() == "de" or XNetworkUbiCom.Tool_GetCurrentLanguageShortName() == "DE" or XNetworkUbiCom.Tool_GetCurrentLanguageShortName() == "De" then
			
				text = "Bitte stellt Eure Texturqualität im Optionsmenü im Hauptmenü auf hoch und startet das Spiel neu!"
				
			else
			
				text = "Please visit the options menu in the main menu and change your texture quality settings to high! Afterwards, don't forget to restart your game!"
				
			end
			
			GUI.AddNote(text)
			
		end
			
		if BS.ValidateMap() ~= true then
		
			Framework.CloseGame()
			
		end
		
	else
	
		if BS.ValidateTextureQuality() ~= true then
		
			GUI.AddNote("Please visit the options menu in the main menu and change your texture quality settings to high! Afterwards, don't forget to restart your game!")
			
		end
		
	end
	
	--additionaly load this script if there are any presents to steal on the map
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
			"Archers_Tower",
			"Scaremonger",
			"Trigger",
			"Comforts",
			"CMod_Additions",
			"InterfaceTools",
			"GameCallbacks",
			"GUITooltips",
			"GUIUpdate",
			"GUIAction",
			"LocalMusic",
			"VersionCheck"
		};
		table.foreach(files,function(_,_value)Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\".._value..".lua")end);
	end
	
	--disables the creation of fow (needed for minimap)
	CUtil.DisableFoW()
	--larger zoom factor (default 1.0)
	Camera.ZoomSetFactorMax(2)
	gvMission = {}
	gvMission.PlayerID = GUI.GetPlayerID()
	--cooldown handling levy taxes
	gvLastTimeButtonPressed = -240000 	
	
	--zusätzliche Taunts hinzugefügt
	BonusKeys()
	
	------------------------------------ Trigger initialisieren -----------------------------------------------------
	--Trigger für Handel
	Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "TransactionDetails", 1)
	--Trigger für Spez-Entities (Dom/Silberschmied etc.)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SpezEntityPlaced", 1)
	--Trigger für Salim-Falle
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "SalimTrapPlaced", 1)
	--Trigger für Schlösser
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnCastleCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCastleDestroyed", 1)
	--Trigger für Türme
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnTowerCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnTowerDestroyed", 1)
	--Trigger für Drake (Kopfschuss)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "DrakeHeadshotDamage", 1);
	--Trigger für Gift (Mary,Kala)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "PoisonDamageCreateDoT", 1);
	--Trigger für Heldentod
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "OnHeroDied", 1)
	--Trigger für Schützentürme
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnArchers_TowerDestroyed", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "OnArchers_TowerCreated", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnArchers_Tower_OccupiedTroopDied", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "OnArchers_Tower_OccupiedTroopAttacked", 1);
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
	--Winter and Night sounds (wolfs howling, snowbird, etc.)
	StartSimpleJob("WinterTheme")
	--calculating ingame time (used for mechanical clock gui)
	StartSimpleJob("IngameTimeJob")
	--calculating player military score points (allow bloodrush if enough)
	StartSimpleJob("BloodRushCheck")
	--initializing lightning
	StartSimpleJob("Lightning_Job")
	--Control Siversmith Grievance
	StartSimpleJob("ControlSiversmithGrievance")
	--initializing dz trade punishment
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
		-- register AI in statistics
		local PIDs = GetAllAIs()
		for i = 1,table.getn(PIDs) do
			if gvPlayerName[PIDs[i]] then
				Logic.SetPlayerRawName(PIDs[i], gvPlayerName[PIDs[i]])
			else
				Logic.SetPlayerRawName(PIDs[i], "AI"..i)
			end
			Logic.PlayerSetIsHumanFlag(PIDs[i], 1)
			Logic.PlayerSetPlayerColor(PIDs[i], GUI.GetPlayerColor(PIDs[i]))
		end
	else
		CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_EMS_GUI.xml")
		Script.Load("maps\\user\\Balancing_Stuff_in_Dev\\EMSAdditions.lua")	
	end
	BS.VersionCheck.Setup()
	--Simis Rotation Widget nach links schieben, damit es visuell besser in die größere GUI passt
	XGUIEng.SetWidgetPosition("RotateBack",389, 4) 
	--Spieler die favorisierte Farbe geben (wenn auf Simis Server eingestellt)
	if not CNetwork then
		if GDB.IsKeyValid("Config\\SettlerServer\\ColorPlayer") then
			local PlayerColor = GDB.GetValue("Config\\SettlerServer\\ColorPlayer");
			Display.SetPlayerColorMapping(1, PlayerColor);
		end
	end;	