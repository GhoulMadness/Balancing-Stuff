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
	DZTrade_Init()
	--FireMod.Init()
	--HurtProjectileFix.Init() --entspr. Hook Aufruf nicht von Simis Server unterstützt, Geschosse der Scharfis fehlen 
	CEntity.EnableDamageClassAoEDamage()
	if not gvEMSFlag then
		S5Hook.LoadGUI("maps\\user\\Balancing_Stuff_in_Dev\\BS_GUI.xml")
	else
		MCS = EMS
		S5Hook.LoadGUI("maps\\user\\Balancing_Stuff_in_Dev\\BS_EMS_GUI.xml")
		XGUIEng.ShowWidget(XGUIEng.GetWidgetID("EMSMPOptionsStart",0))
	end
