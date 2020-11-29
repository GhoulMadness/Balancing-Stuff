if CNetwork then
gvMaxPlayers = 16
else
gvMaxPlayers = 8
end
function Initialisierung()

	-- Einige Mapinfos wie sie oben links erscheinen	
	MPC_Initialize()
    MPC_Start()

	mpc_Rules.TowersNotSellable = true
	mpc_Rules.TowersIndestructable = false
	-- **** Wartezeit nach Einstellung ***
    mpc_GameStartDelay = 15
    -- **** Friedenszeiten ***
    -- Falls nicht auswaehlbar sel: false
	mpc_Rules.WS = {0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 90, 120}
	mpc_Rules.WS.Cur = 11
	mpc_Rules.WS.Sel = true	
    -- **** Standardeinstellungen Regeln ****
    -- Einheiten:
    -- Schwere Kavallerie - Leichte Kavallerie - Schwere Kanonen - Leichte Kanonen - Scharfschuetzen - Diebe
    mpc_Rules[1].Act = {true, true, true, true, true, true} -- Default Einheiten
    mpc_Rules[1].Sel = {true, true, true, true, true, true} -- Auswaehlbare Einheiten

    -- Gebaeude:
    -- Kanonentuerme, Balistatuerme, Marktplaetze, Reserve, Reserve, Reserve
    mpc_Rules[2].Act = {true, true, true} -- Default Gebaeude
    mpc_Rules[2].Sel = {true, true, true} -- Auswaehlbare Gebaeude
    -- Wetter:
    -- Winter, Regen, Sommer
    mpc_Rules[3].Act = {true, true, true} -- Default Wetter
    mpc_Rules[3].Sel = {true, true, true} -- Auswaehlbare Wetter
    -- Spezialregeln:
    -- Anti-Abreiss, Segnungsbeschränkung, Dz-Zuordnung(Team), Dz-Zuordnung(Spieler), Anti-Rush
    mpc_Rules[4].Act = {true, true, false, false, true} -- Default Specials
    mpc_Rules[4].Sel = {true, true, true, true, true} -- Auswaehlbare Specials
	mpc_Rules[4].TimeBetweenBlessings = 120

	mpc_Rules.TradeLimit = {g_MC_Loc[1].Deactivated,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,15000}
	mpc_Rules.TradeLimit.Cur = 2
	mpc_Rules.TradeLimit.Sel = true	
	
	mpc_Rules.FastGame = {false}
	mpc_Rules.FastGame.Multiplicator = 2
	mpc_Rules.FastGame.Sel = true	
	-- **** Heldeneinstellungen ****
	mpc_Rules.MaxHeroes = {0,1,2,3,4,5,6,7,8,9,10,11,12}
	mpc_Rules.MaxHeroes.Cur = 2
	mpc_Rules.MaxHeroes.Sel = true		
    -- Dario Ari Erec Salim Pilgrim Helias Drake Yuki Mary Kerberos Varg Kala
    mpc_Rules[6].Act = {true, true, true, true, true, true, true, true, true, true, true, true} -- Erlaubte Helden
    mpc_Rules[6].Sel = {true, true, true, true, true, true, true, true, true, true, true, true} -- Auswaehlbare Helden
    -- *** Sonstige Einstellungen ***
	lang = 1 -- Standardsprache Quickstart: Deutsch
	
	SpecialMapInitialization()
	-- Rulesetauswahl starten (falls 0 gelten direkt Standardeinstellungen!!!)
	SetupRuleSets(99)
	SetupLocalization()
	-- Zeigt direkt anfangs für Spieler eins das Tributfenster
	GUIAction_ToggleMenu( "TradeWindow", 1)	
	Setup_GUIHacks()
	
	--Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_CREATED, "", "ActionOnEntityCreated", 1)
	--Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "ActionOnEntityDestroyed", 1)

	for i = 1,8 do
		mpc_Rules.BlessTimer[i] = {}
		for u = 1,5 do
			mpc_Rules.BlessTimer[i][u] = -1 * mpc_Rules[4].TimeBetweenBlessings
		end
	end	
	-- Zufallsregelngenerator Einstellungen
	mpc_Rules.random.Sel = true
	mpc_Rules.random.WS = {0.03,0.13,0.93,0.98,1.00}
	mpc_Rules.random.MaxHeroes = {0.25,0.4,0.7,0.9,0.98,0.99,1.00}
	mpc_Rules.random[1] = {0.6, 0.3, 0.6, 0.6, 0.1, 0.3}
	mpc_Rules.random[2] = {0.9, 0.75, 0.5}
	mpc_Rules.random[3] = {0.2, 0.2, 0.2}
	mpc_Rules.random[4] = {0, 0.03, 0.15,0.4,0.07}
	mpc_Rules.random[5] = {}
	mpc_Rules.random[6] = {0.1, 0.1, 0.25,0.1,0.1,0.25,0.25,0.1,0.2,0.25,0.1,0.1}	

end

function LoadComforts()
	-- Laden der benötigten Comforts
	Countdown_and_Peacetime()
	Comfort_TrackEntitysIni()
	Tribute_Comforts()
	Globale_Hilfsvariablen()
	MovieFensterTooltip()
	
end

-- FOLGENDEN CODE NICHT VERAENDERN => COMFORTS

function Countdown_and_Peacetime()
	
	PeacetimeEnd = function()
		-- sämtliche Aktionen bei Ende der Friedenszeit
		MultiplayerTools.SetUpDiplomacyOnMPGameConfig()
		-- Sound bei Ende der Friedenszeit
		Sound.PlayGUISound( Sounds.VoicesMentor_MP_PeaceTimeOver_rnd_01, 127)
		-- Nachricht bei Ende der Friedenszeit
		Message( "@color:255,255,0 "..g_MC_Loc[lang].Wartimemsg );
		PeaceTimeEndActions()
	end

	SetPeacetime = function ( _seconds )
		---hier wird die Funktion special peacetime gestartet
		SpecialPeacetime();
		StartCountdown( _seconds, PeacetimeEnd, true );
		StartCountdown( _seconds*12/13, Warnung, false);
		
		
		if SpecialMapKey ~= nil then
		StartCountdown( _seconds*9/10, DuerreStart, false );
	end
end
	SpecialPeacetime = function()
		-- Anzahl der menschlichen Spieler wird hier ermittelt
		local _humenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()
		-- Abfrage ob Standardsituation gegeben ist das jeder sich  mit jedem  verbünden kann
		if XNetwork.GameInformation_GetFreeAlliancesFlag() == 1 then
			-- Feststellung wer mit wem verbündet ist und Festlegung des DiplomatiST für die Peacetime
			if _humenPlayer > 1 then
				for _teampId = 1, _humenPlayer do
					local _teamplayer = XNetwork.GameInformation_GetLogicPlayerTeam( _teampId )
					for _oppopId = 1, _humenPlayer do
						if _teampId ~= OppoPlayer then
							local _oppoPlayer = XNetwork.GameInformation_GetLogicPlayerTeam( _oppopId )
							if _teamplayer == _oppoPlayer then
								Logic.SetDiplomacyState( _oppopId, _teampId, Diplomacy.Friendly )
							else
								Logic.SetDiplomacyState( _oppopId, _teampId, Diplomacy.Neutral )
							end
						end
					end
				end
			end
		end
	end

	StartCountdown = function (_Limit, _Callback, _Show)
		assert(type(_Limit) == "number")

		Counter.Index = (Counter.Index or 0) + 1

		if _Show and CountdownIsVisisble() then
			assert(false, "StartCountdown: A countdown is already visible")
		end

		Counter["counter" .. Counter.Index] = {Limit = _Limit, TickCount = 0, Callback = _Callback, Show = _Show, Finished = false}

		if _Show then
			MapLocal_StartCountDown(_Limit)
		end

		if Counter.JobId == nil then
			Counter.JobId = StartSimpleJob("CountdownTick")
		end

		return Counter.Index
	end

	StopCountdown = function(_Id)
		if Counter.Index == nil then
			return
		end

		if _Id == nil then
			for i = 1, Counter.Index do
				if Counter.IsValid("counter" .. i) then
					if Counter["counter" .. i].Show then
						MapLocal_StopCountDown()
					end
					Counter["counter" .. i] = nil
				end
			end
		else
			if Counter.IsValid("counter" .. _Id) then
				if Counter["counter" .. _Id].Show then
					MapLocal_StopCountDown()
				end
				Counter["counter" .. _Id] = nil
			end
		end
	end

	CountdownTick = function()
		local empty = true
		for i = 1, Counter.Index do
			if Counter.IsValid("counter" .. i) then
				if Counter.Tick("counter" .. i) then
					Counter["counter" .. i].Finished = true
				end

				if Counter["counter" .. i].Finished and not IsBriefingActive() then
					if Counter["counter" .. i].Show then
						MapLocal_StopCountDown()
					end

					-- callback function
					if type(Counter["counter" .. i].Callback) == "function" then
						Counter["counter" .. i].Callback()
					end

					Counter["counter" .. i] = nil
				end

				empty = false
			end
		end

		if empty then
			Counter.JobId = nil
			Counter.Index = nil
			return true
		end
	end

	CountdownIsVisisble = function()
		for i = 1, Counter.Index do
			if Counter.IsValid("counter" .. i) and Counter["counter" .. i].Show then
				return true
			end
		end
		return false
	end
	
end
function Warnung()
Sound.PlayGUISound( Sounds.VoicesMentor_VC_OnlySomeMinutesLeft_rnd_01,127)
end
function Comfort_TrackEntitysIni()	
	
	Track_Entity_Table = {}
	for i = 1,gvMaxPlayers do
		Track_Entity_Table[i] = {}
	end	
	Comfort_TrackEntityIni = function(_pId,_eType)	
		local temp = {Logic.GetPlayerEntities(_pId, _eType,1)}
		local count = 0
		Track_Entity_Table[_pId][_eType] = {}
		Track_Entity_Table[_pId][_eType].tracked = true
		Track_Entity_Table[_pId][_eType].count = 0
		if temp[1] > 0 then
			local latestEntity = temp[2]
			
				
			for u = 1, Logic.GetNumberOfEntitiesOfTypeOfPlayer(_pId, _eType) do

				if latestEntity ~= 0 then
					table.insert(Track_Entity_Table[_pId][_eType], latestEntity)
					count = count + 1
				end		
				latestEntity = Logic.GetNextEntityOfPlayerOfType(latestEntity);
			end
			Track_Entity_Table[_pId][_eType].count = count
		end	
	end
	
	Comfort_TrackEntity_Created = function(_eId)
		local _pId = GetPlayer(_eId)	
		local _eType = Logic.GetEntityType(_eId)
		if Comfort_TrackEntity_IsTracked(_pId,_eType) then
			if Track_Entity_Table[_pId][_eType].tracked then
				table.insert(Track_Entity_Table[_pId][_eType], _eId)
				Track_Entity_Table[_pId][_eType].count = Track_Entity_Table[_pId][_eType].count + 1
			end
		end
	end
	
	Comfort_TrackEntity_Destroyed = function(_eId)
		local _pId = GetPlayer(_eId)
		local _eType = Logic.GetEntityType(_eId)	
		if Comfort_TrackEntity_IsTracked(_pId,_eType) then					
			for i = 1, Track_Entity_Table[_pId][_eType].count do
				if _eId == Track_Entity_Table[_pId][_eType][i] then
					table.remove(Track_Entity_Table[_pId][_eType], i)
					break
				end
			end
		end	
	end	
	
	Comfort_TrackEntity_IsTracked = function(_pId, _eType, _TypeOrId)
		if _TypeOrId == false then _eType = Logic.GetEntityType(_eTypeOrId) end
		if type(Track_Entity_Table[_pId]) == "table" then
			if type(Track_Entity_Table[_pId][_eType]) == "table" then
			else return false
			end
		else return false
		end
		return Track_Entity_Table[_pId][_eType].tracked	
	end
	
	Comfort_TrackEntity_RemoveTracking = function(_pId, _eType)
		Track_Entity_Table[_pId][_eType] = {}
		Track_Entity_Table[_pId][_eType].tracked = false
		Track_Entity_Table[_pId][_eType].count = -1	
	end	
	
end

function Tribute_Comforts()

	AddTribute = function( _tribute )
		assert( type( _tribute ) == "table", "Tribut muß ein Table sein" );
		assert( type( _tribute.text ) == "string", "Tribut.text muß ein String sein" );
		assert( type( _tribute.cost ) == "table", "Tribut.cost muß ein Table sein" );
		assert( type( _tribute.pId ) == "number", "Tribut.pId muß eine Nummer sein" );
		assert( not _tribute.Tribute , "Tribut.Tribute darf nicht vorbelegt sein");

		uniqueTributeCounter = uniqueTributeCounter or 1;
		_tribute.Tribute = uniqueTributeCounter;
		uniqueTributeCounter = uniqueTributeCounter + 1;

		local tResCost = {};
		for k, v in pairs( _tribute.cost ) do
			assert( ResourceType[k] );
			assert( type( v ) == "number" );
			table.insert( tResCost, ResourceType[k] );
			table.insert( tResCost, v );
		end

		Logic.AddTribute( _tribute.pId, _tribute.Tribute, 0, 0, _tribute.text, unpack( tResCost ) );
		SetupTributePaid( _tribute );
		return _tribute.Tribute;
	end

	CreateATribute = function(_pId, _text, _cost, _callback)
		local tribute =  {};
		tribute.pId = _pId;
		tribute.text = _text;
		tribute.cost = _cost;
		tribute.Callback = _callback;
		return tribute
	end

	GameCallback_FulfillTribute = function()
		return 1
	end


end

function Mission_InitLocalResources()
	--Add Players Resources
	local i
	for i=1,gvMaxPlayers,1 do
       Tools.GiveResouces(i, g_MC_StR.Gold , g_MC_StR.Clay, g_MC_StR.Wood, g_MC_StR.Stone, g_MC_StR.Iron, g_MC_StR.Sulfur)
    end
end

function MapVersion_InitMapInfoButton( _text)
    if type(_text) == "string" then
        XGUIEng.SetText( "TopMainMenuTextButton", "@color:0,0,0,0: ....... @color:255,255,255 MenÃ¼ @cr @cr ".._text)
    else
        XGUIEng.SetText( "TopMainMenuTextButton", "@color:0,0,0,0: ....... @color:255,255,255 MenÃ¼ @cr @cr Hier die Mapversion und sonstige Infos einfügen")
    end
end

function MapVersion_Write_Comfort(_mapname, _mapper, _version, _specialtext)
    local _text = "@color:180,0,240 @cr Mapname @cr ".._mapname.." by ".._mapper.." @cr @cr Version: ".._version.." @cr @cr ".._specialtext
	MapVersion_InitMapInfoButton( _text )
end

function Globale_Hilfsvariablen()

gv_guipId = GUI.GetPlayerID()

gvCol = {
	weiss = "@color:255,255,255",
	schwarz = "@color:0,0,0",
	rot = "@color:255,0,0",
	gelb = "@color:255,232,0",
	gruen = "@color:0,255,0",
	dunkelgruen = "@color:0,100,0",
	blau = "@color:0,0,255",
	lila = "@color:200,0,200",
	grau = "@color:150,150,150",
	tuerkis = "@color:0,180,180",
	orange = "@color:255,130,0",
	beige = "@color:190,190,150",
	hellgrau = "@color:170,170,170",
	dunkelgrau = "@color:120,120,120",
	TTgelb = "@color:255,200,0",
	TTrot = "@color:200,60,0",
	TUTgruen = "@color:90,190,20",
	space = "@color:0,0,0,0",
}

end

function MovieFensterTooltip()
	-- aus ItM by Noigi
	MovieFenster = function( _title, _text, _WPinternal )
		if gvWP then
			if _WPinternal then -- MovieFenster wird vom Itm-Skript aufgerufen
				gvWP.MF.internalUse = true;
				MovieFensterCore( _title, _text );
			else -- ... vom Mapper
				gvWP.MF.externalUse = true;
				gvWP.MF.BACKUPextTitle = _title;
				gvWP.MF.BACKUPextText = _text;
				if not gvWP.MF.internalUse then
					MovieFensterCore( _title, _text );
				end
			end
		else
			MovieFensterCore( _title, _text );
		end
	end

	MovieFensterCore = function( _title, _text )
		XGUIEng.ShowWidget( "Movie", 1 );
		XGUIEng.ShowWidget( "Cinematic_Text", 0 );
		XGUIEng.ShowWidget( "MovieBarTop", 0 );
		XGUIEng.ShowWidget( "MovieBarBottom", 0 );
		XGUIEng.ShowWidget( "MovieInvisibleClickCatcher", 0 );
		XGUIEng.ShowWidget( "CreditsWindowLogo", 0 );
		XGUIEng.SetText( "CreditsWindowTextTitle", _title );
		XGUIEng.SetText( "CreditsWindowText", _text );
	end

	HideMovieFenster = function( _WPinternal )
		if gvWP then
			if _WPinternal then -- HideMovieFenster wird vom Itm-Skript aufgerufen
				gvWP.MF.internalUse = false;
				if gvWP.MF.externalUse then
					MovieFensterCore( gvWP.MF.BACKUPextTitle, gvWP.MF.BACKUPextText );
				else
					HideMovieFensterCore();
				end
			else -- ... vom Mapper
				gvWP.MF.externalUse = false;
				if not gvWP.MF.internalUse then
					HideMovieFensterCore();
				end
			end
		else
			HideMovieFensterCore();
		end
	end

	HideMovieFensterCore = function()
		XGUIEng.ShowWidget( "Movie", 0 );
	end

	
	WPUpdateFeedback = function()
		-- Funktion aus ItM made by Noigi
		g_MC_RulesTextForDisplay = ""
		
		if not (gvStartJobID == 0)then
			local GameStartCounterColor
			if mpc_GameStartDelay > -1 then GameStartCounterColor = gvCol.rot end
			if mpc_GameStartDelay > 5 then GameStartCounterColor = gvCol.gelb end
			if mpc_GameStartDelay > 10 then GameStartCounterColor = gvCol.gruen end
			
			g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.weiss.." "..g_MC_Loc[lang].GameStarts.." "
			if mpc_Rules.FastGame[1] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.gelb.." "..g_MC_Loc[lang].AsFastGame.." "..gvCol.weiss end
			g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." in "..GameStartCounterColor.." "..mpc_GameStartDelay.." "..g_MC_Loc[lang].Seconds.." @cr @cr "
		end
		

		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.tuerkis.." "..g_MC_Loc[lang].Rule["WS"].Name..": "..gvCol.orange.." "..mpc_Rules.WS[mpc_Rules.WS.Cur].." @cr "
		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.tuerkis.." "..g_MC_Loc[lang].Rule["MaxHeroes"].Name..": "..gvCol.orange.." "..mpc_Rules.MaxHeroes[mpc_Rules.MaxHeroes.Cur].." @cr "
		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.tuerkis.." "..g_MC_Loc[lang].Rule["TradeLimit"].Name..": "..gvCol.orange.." "..mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur].." @cr "

		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.tuerkis.." "..g_MC_Loc[lang].Rule[4].Name.." "..gvCol.orange
		-- Regenset String:
	    if mpc_Rules[4].Act[1] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[4][1]; end
	    if mpc_Rules[4].Act[2] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[4][2]; end
		if mpc_Rules[4].Act[4] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[4][4]; 
		elseif mpc_Rules[4].Act[3] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[4][3];
		end		
		if mpc_Rules[4].Act[5] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[4][5]; end
		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." @cr "
		
		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay..gvCol.tuerkis.." "..g_MC_Loc[lang].ForbittenUnits..": "..gvCol.orange
		-- Regenset String:
	    if not mpc_Rules[1].Act[1] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[1][1]; end
	    if not mpc_Rules[1].Act[2] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[1][2]; end
	    if not mpc_Rules[1].Act[3] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[1][3]; end
	    if not mpc_Rules[1].Act[4] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[1][4]; end
	    if not mpc_Rules[1].Act[5] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[1][5]; end
	    if not mpc_Rules[1].Act[6] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[1][6]; end
	    if not mpc_Rules[2].Act[2] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[2][2]; end
	    if not mpc_Rules[2].Act[1] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[2][1]; end
	    if not mpc_Rules[2].Act[3] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[2][3]; end
	    if not mpc_Rules[3].Act[1] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[3][1]; end
	    if not mpc_Rules[3].Act[2] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[3][2]; end
		for i = 1,12 do
	    if not mpc_Rules[3].Act[3] then g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[3][3]; end
			if not (mpc_Rules[6].Act[i] == true) then
				g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." "..g_MC_Loc[lang].Rule[6][i];
			end
		end
		g_MC_RulesTextForDisplay = g_MC_RulesTextForDisplay.." @cr "
		MovieFenster(gvCol.space..": ....... "..gvCol.beige.." "..g_MC_Loc[lang].Rules.." ",g_MC_RulesTextForDisplay,true);		
	end

end


-- ****************************************************************
-- **************  RulesetAuswahl Comfortfunktion       ***********
-- **************  Author: Anarki                       ***********
-- **************  Veroeffentlicht: www.siedler-maps.de ***********
-- ****************************************************************


function MPC_Start()
	
	Logic.SuspendAllEntities()
	


	mpc_RulesActCheck = {true, true, true, true, true, true, true, true}


	mpc_CurStep = {}
	mpc_CurStep = {1,1,1,1,1,1}
	mpc_CurRule = 1
	
	mpc_Rules = {}
	for i = 1,10 do
		mpc_Rules[i] = {}
		mpc_Rules[i].Act = {}
		mpc_Rules[i].Sel = {}
	end
	
	mpc_Rules.TowersNotSellable = true
	mpc_Rules.TowersIndestructable = false
	
	mpc_Rules.WS = {0, 15, 30, 40, 60}
	mpc_Rules.WS.Cur = 3
	mpc_Rules.WS.Sel = true	

	mpc_Rules.MaxHeroes = {0,1,2,3,4,5,6,7,8,9,10,11,12}
	mpc_Rules.MaxHeroes.Cur = 3
	mpc_Rules.MaxHeroes.Sel = true	

	mpc_Rules.TradeLimit = {"Deaktiviert",1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,15000}
	mpc_Rules.TradeLimit.Cur = 4
	mpc_Rules.TradeLimit.Sel = true	
	
	mpc_Rules[1].Act = {true, true, true, true, true, true}
	mpc_Rules[1].Sel = {true, true, true, true, true, true}

	mpc_Rules[2].Act = {true, true, true, true, true, true}
	mpc_Rules[2].Sel = {true, true, true, true, true, true}

	mpc_Rules[3].Act = {true, true, true}
	mpc_Rules[3].Sel = {true, true, true}
	
	
    mpc_Rules[4].Act = {true, true, true, true, true} -- Default Specials
    mpc_Rules[4].Sel = {true, true, true, true, true} -- Auswaehlbare Specials
	mpc_Rules[4].TimeBetweenBlessings = 60
	mpc_Rules.HQInv = {false, false, false, false, false, false, false, false}
	mpc_Rules.BlessTimer = {}
	for i = 1,8 do
		mpc_Rules.BlessTimer[i] = {}
		mpc_Rules.BlessTimer[i][5] = -1 * mpc_Rules[4].TimeBetweenBlessings
		mpc_Rules.BlessTimer[i][1] = -1 * mpc_Rules[4].TimeBetweenBlessings
		mpc_Rules.BlessTimer[i][2] = -1 * mpc_Rules[4].TimeBetweenBlessings
		mpc_Rules.BlessTimer[i][3] = -1 * mpc_Rules[4].TimeBetweenBlessings
		mpc_Rules.BlessTimer[i][4] = -1 * mpc_Rules[4].TimeBetweenBlessings	
	end	
	
	mpc_Rules[6].Act = {true, true, true, true, true, true, true, true, true, true, true, true}
	mpc_Rules[6].Sel = {true, true, true, true, true, true, true, true, true, true, true, true}

	mpc_Rules.FastGame = {false}
	mpc_Rules.FastGame.Multiplicator = 2
	mpc_Rules.FastGame.Sel = true
	
	mpc_GameStartDelay = 10
	gvStartJobID = 0
	
	g_MC_StR = { Gold = 500,
					Clay = 1500,
					Wood = 1200,
					Stone = 1000,
					Iron = 0,
					Sulfur = 0 }
	
	mpc_Rules.lang = {}
	mpc_Rules.lang.TribId = {0,0,0,0,0,0,0,0}
	mpc_Rules.lang.notSel = {g_MC_Loc.Lang.notSel[1], g_MC_Loc.Lang.notSel[2], g_MC_Loc.Lang.notSel[3]}
	mpc_Rules.lang.Sel = {g_MC_Loc.Lang.Sel[1],g_MC_Loc.Lang.Sel[2],g_MC_Loc.Lang.Sel[3]}
	mpc_Rules.lang.Cur = {2,2,2,2,2,2,2,2}
	lang = 1
	for i = 1,12 do
		GUIAction_ToggleMenu("BuyHeroWindowBuyHero"..i, 0)
	end
	gvRuleDisplayJob = StartSimpleHiResJob("WPUpdateFeedback")
	
	mpc_Rules.random = {}
	mpc_Rules.random.Sel = true
	mpc_Rules.random.WS = {0.03,0.13,0.93,0.98,1.00}
	mpc_Rules.random.MaxHeroes = {0.25,0.4,0.7,0.9,0.98,0.99,1.00}
	mpc_Rules.random[1] = {0.6, 0.3, 0.6, 0.6, 0.1, 0.3}
	mpc_Rules.random[2] = {0.9, 0.75, 0.5}
	mpc_Rules.random[3] = {0.2, 0.2, 0.2}
	mpc_Rules.random[4] = {0, 0.03, 0.15,0.4,0.07}
	mpc_Rules.random[5] = {}
	mpc_Rules.random[6] = {0.1, 0.1, 0.25,0.1,0.1,0.25,0.25,0.1,0.2,0.25,0.1,0.1}	
		
	gv_MC_imdead = {}
	gv_MC_NoDZReplaceJob = 0
	gv_MC_NoDZReplaceTimer = 0
	Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_CREATED, "", "ActionOnEntityCreated", 1)
	Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "ActionOnEntityDestroyed", 1)
	ClearAllPlayerVillageCenters()
end


function MPC_Initialize()

	mpc_TRIB = {}
   
 	mpc_TRIB_PT = function(_peacetimeId)
		--	mpc_Rules.WS = {0, 15, 30, 40, 60}
		mpc_Rules.WS.Cur = mpc_Rules.WS[_peacetimeId]; RulesetChoosen(1)
		--g_MC_RS.Peacetime = g_MC_RS.Peacetimes[_peacetimeId]; RulesetChoosen(1)
	end
	
	mpc_TRIB_SelectSingleChoiceRule = function (_step, _rule)
		local _countRules = table.getn( mpc_Rules[_rule] )	
		mpc_Rules[_rule].Cur = mpc_Rules[_rule].Cur + 1; 
		if mpc_Rules[_rule].Cur > _countRules then 
			mpc_Rules[_rule].Cur = 1 
		end
		RulesetChoosen(_step)			
	end
	mpc_TRIB_SelectLangChoiceRule = function (_step, _player)
		local _pId = _player
		if _player == 9 then _player = 1 end
		local _countRules = table.getn( mpc_Rules.lang.Sel )	
		mpc_Rules.lang.Cur[_player] = mpc_Rules.lang.Cur[_player] + 1; 
		if mpc_Rules.lang.Cur[_player] > _countRules then 
			mpc_Rules.lang.Cur[_player] = 1
		end
		if gv_guipId == _player then lang = mpc_Rules.lang.Cur[_player] - 1 end
		if _pId < 9 then
			LangChoosen(_pId)
		else
			RulesetChoosen(99)
		end
	end
	
	mpc_TRIB_SelectRule = function(_step,_rule)
		mpc_CurRule = _rule
		local _countRules = table.getn(mpc_Rules[_rule].Act)
		while true do			
			mpc_CurStep[_rule] = mpc_CurStep[_rule] + 1; 
			if mpc_CurStep[_rule] > _countRules then 
				mpc_CurStep[_rule] = 1 
				break
			end
			if mpc_Rules[_rule].Sel[mpc_CurStep[_rule]] == true then
				break
			end
		end
		RulesetChoosen(_step)
	end
		
	mpc_TRIB_ChangeRule = function(_step)		
		if mpc_Rules[mpc_CurRule].Sel[mpc_CurStep[mpc_CurRule]] then 
			mpc_Rules[mpc_CurRule].Act[ mpc_CurStep[mpc_CurRule] ] = not( mpc_Rules[mpc_CurRule].Act[ mpc_CurStep[mpc_CurRule] ] ) 
		end 
		RulesetChoosen(_step)
	end
	
	LangChoosen = function(_player) mpc_CreateLanguageChoiceTributes(_player) end
	
	RemoveAllmpc_TRIB = function() for i = 1,6 do Logic.RemoveTribute( 1, mpc_TRIB[i]); end end
	
	RulesetChoosen = function(_NextStep) RemoveAllmpc_TRIB(); SetupRuleSets(_NextStep) end
	
	mpc_StepFunc = {}
	mpc_StepFunc[99]= {}
	mpc_StepFunc[99][1] = function() RulesetChoosen(99) end
	mpc_StepFunc[99][3] = function() mpc_randomrulegenerator(); RemoveAllmpc_TRIB(); SetupRuleSets(99) end
	mpc_StepFunc[99][6] = function() RulesetChoosen(0) end
	
	mpc_TRIBRuleFunc = {}
	mpc_TRIBRuleFunc.WS = function() mpc_TRIB_SelectSingleChoiceRule(1, "WS") end 
	mpc_TRIBRuleFunc.MaxHeroes = function() mpc_TRIB_SelectSingleChoiceRule(1, "MaxHeroes") end	
	mpc_TRIBRuleFunc.TradeLimit = function() mpc_TRIB_SelectSingleChoiceRule(2, "TradeLimit") end
	mpc_TRIBRuleFunc.lang = {}
	mpc_TRIBRuleFunc.lang[9] = function() mpc_TRIB_SelectLangChoiceRule(1, 9) end
	mpc_TRIBRuleFunc.lang[1] = function() mpc_TRIB_SelectLangChoiceRule(1, 1) end
	mpc_TRIBRuleFunc.lang[2] = function() mpc_TRIB_SelectLangChoiceRule(1, 2) end
	mpc_TRIBRuleFunc.lang[3] = function() mpc_TRIB_SelectLangChoiceRule(1, 3) end
	mpc_TRIBRuleFunc.lang[4] = function() mpc_TRIB_SelectLangChoiceRule(1, 4) end
	mpc_TRIBRuleFunc.lang[5] = function() mpc_TRIB_SelectLangChoiceRule(1, 5) end
	mpc_TRIBRuleFunc.lang[6] = function() mpc_TRIB_SelectLangChoiceRule(1, 6) end
	mpc_TRIBRuleFunc.lang[7] = function() mpc_TRIB_SelectLangChoiceRule(1, 7) end
	mpc_TRIBRuleFunc.lang[8] = function() mpc_TRIB_SelectLangChoiceRule(1, 8) end
	
	
	mpc_TRIBRuleFunc[1] = function() mpc_TRIB_SelectRule(2,1) end
	mpc_TRIBRuleFunc[2] = function() mpc_TRIB_SelectRule(1,2) end
	mpc_TRIBRuleFunc[3] = function() mpc_TRIB_SelectRule(2,3) end
	mpc_TRIBRuleFunc[4] = function() mpc_TRIB_SelectRule(2,4) end
	mpc_TRIBRuleFunc[5] = function() mpc_TRIB_SelectRule(1,5) end
	mpc_TRIBRuleFunc[6] = function() mpc_TRIB_SelectRule(1,6) end

	mpc_TRIBChangeRuleFunc = {}	
	mpc_TRIBChangeRuleFunc[1] = function() mpc_TRIB_ChangeRule(1) end
	mpc_TRIBChangeRuleFunc[2] = function() mpc_TRIB_ChangeRule(2) end
	mpc_TRIBChangeRuleFunc[3] = function() mpc_TRIB_ChangeRule(3) end
	mpc_TRIBChangeRuleFunc[4] = function() mpc_TRIB_ChangeRule(4) end
	mpc_TRIBChangeRuleFunc[5] = function() mpc_TRIB_ChangeRule(5) end
	
	mpc_TRIBGoOn = {}
	mpc_TRIBGoOn[1] = function() mpc_CurRule = 1; RulesetChoosen(2) end 
	mpc_TRIBGoOn[2] = function() RulesetChoosen(98) end
	mpc_TRIBGoOn[3] = function() RulesetChoosen(4) end
	mpc_TRIBGoOn[4] = function() RulesetChoosen(5) end
	mpc_TRIBGoOn[5] = function() RulesetChoosen(6) end
	mpc_TRIBGoOn[99] = function() mpc_CurRule = 1; RulesetChoosen(1) end
	
	mpc_StepFunc[98] = {}
	mpc_StepFunc[98][1] = function() RulesetChoosen(0) end
	mpc_StepFunc[98][2] = function() RulesetChoosen(1) end
	mpc_StepFunc[98][3] = function() mpc_Rules.FastGame[1] = true; RulesetChoosen(0) end
	
	mpc_CreateChoiceTributes = function(_rule, _tribNr)
		local _countRules = table.getn(mpc_Rules[_rule].Act)
		local Color
		local _text = "@color:255,255,255 "..g_MC_Loc[lang].Rule[_rule].Name..": "
		for i = 1, _countRules do
			if mpc_Rules[_rule].Sel[i] then
				if mpc_CurStep[_rule] == i and mpc_CurRule == _rule then
					if mpc_Rules[_rule].Act[i] then Color = "@color:200,255,200 *"
					else Color = "@color:255,200,200 *"
					end
				else
					if mpc_Rules[_rule].Act[i] then Color = "@color:0,255,0 "
					else Color = "@color:255,0,0 "
					end
				end
			else
				if mpc_Rules[_rule].Act[i] then Color = "@color:0,128,0 "
				else Color = "@color:128,0,0 "
				end
			end		
			_text = _text..Color..g_MC_Loc[lang].Rule[_rule][i].." - ";
		end
		mpc_TRIB[_tribNr] = AddTribute( CreateATribute(1, _text, { Gold = 0}, mpc_TRIBRuleFunc[_rule] ) )	
	end
	
	mpc_CreateSingleChoiceTributes = function(_rule, _tribNr)
		local _countRules = table.getn(mpc_Rules[_rule])
		local Color
		local _text = "@color:255,255,255 "..g_MC_Loc[lang].Rule[_rule].Name..": "
        for i = 1, _countRules do
			if mpc_Rules[_rule].Cur == i then Color = "@color:0,255,0 "
			else Color = "@color:255,0,0 "
			end
			_text = _text..Color..mpc_Rules[_rule][i].." - ";
		end
		mpc_TRIB[_tribNr] = AddTribute( CreateATribute(1, _text, { Gold = 0}, mpc_TRIBRuleFunc[_rule] ) )
	end	

	mpc_CreateLanguageChoiceTributes = function(_player)
		local _countRules = table.getn(mpc_Rules.lang.Sel)
		local _pId = _player
		local _text = ""
		if _player == 9 then _player = 1 end
		local _text = ""
        for i = 1, _countRules do
			if mpc_Rules.lang.Cur[_player] == i then _text = _text..gvCol.weiss.." ( "..g_MC_Loc.Lang.Sel[i].." "..gvCol.weiss.." ) - "
			else _text = _text..g_MC_Loc.Lang.notSel[i].." - "
			end
		end		
		return AddTribute( CreateATribute(_player, _text, { Gold = 0}, mpc_TRIBRuleFunc.lang[_pId] ) )	
	end	
	
	mpc_randomrulegenerator = function()
		local _randomnr
		_randomnr = GetRandom(101) / 100
		for i = 1,6 do
			if _randomnr <= mpc_Rules.random.WS[i] then
				mpc_Rules.WS.Cur = i
				break
			end
		end
		_randomnr = GetRandom(101) / 100
		for i = 1,7 do
			if _randomnr <= mpc_Rules.random.MaxHeroes[i] then
				mpc_Rules.MaxHeroes.Cur = i
				break
			end
		end
		for _rule = 1,6 do
			for i = 1, table.getn(mpc_Rules.random[_rule]) do
				_randomnr = GetRandom(101) / 100
				if _randomnr <= mpc_Rules.random[_rule][i] then
					mpc_Rules[_rule].Act[i] = false
				else
					mpc_Rules[_rule].Act[i] = true
				end
			end
		end		

	end
	
	SetupRulesetComfort_Localization = function()
	   g_MC_Loc = {}
	   g_MC_Loc.Lang = {}
	   g_MC_Loc.Lang.notSel = {}
	   g_MC_Loc.Lang.notSel[1] = "@color:100,0,0 Eng @color:100,100,100 li @color:0,0,100 sh"
	   g_MC_Loc.Lang.notSel[2] = "@color:0,0,0 Deu @color:100,0,0 ts @color:100,100,0 ch"
	   g_MC_Loc.Lang.notSel[3] = "@color:100,0,0 Pol @color:100,100,100 ski"
	   --g_MC_Loc.Lang.notSel[4] = "@color:100,100,100 @color:0,0,100 ski @color:100,0,0 "
	   g_MC_Loc.Lang.Sel = {}
	   g_MC_Loc.Lang.Sel[1] = "@color:255,0,0 Eng @color:255,255,255 li @color:0,0,255 sh"
	   g_MC_Loc.Lang.Sel[2] = "@color:0,0,0 Deu @color:255,0,0 ts @color:255,255,0 ch"
	   g_MC_Loc.Lang.Sel[3] = "@color:255,0,0 Pol @color:255,255,255 ski"
	   --g_MC_Loc.Lang.notSel[4] = "@color:100,100,0 Pol @color:100,100,100 ski"
	   -- ENGLISH
	   g_MC_Loc[0] = {}
	   
	   g_MC_Loc[0].Peacetime = "Peacetime"
	   g_MC_Loc[0].Wartimemsg = "Lets fight!"
	   g_MC_Loc[0].Minutes = "Minutes"
	   g_MC_Loc[0].Selected = "Selected!"
	   g_MC_Loc[0].GoOn = "Next"
	   g_MC_Loc[0].Back = "Back"
	   g_MC_Loc[0].Allowed = "allowed"
	   g_MC_Loc[0].Forbitten = "forbidden"
	   g_MC_Loc[0].ForbittenUnits = "Forbitten as rule"
	   g_MC_Loc[0].Yes = "Yes"
	   g_MC_Loc[0].No = "No"
	   g_MC_Loc[0].StartGame = "Start Game"
	   g_MC_Loc[0].GameStarts = "Game Starts"
	   g_MC_Loc[0].AsFastGame = "as Fast Game"
	   g_MC_Loc[0].In = "in"
	   g_MC_Loc[0].Seconds = "Seconds"
	   g_MC_Loc[0].ChangeStatus = "Change Status"
	   g_MC_Loc[0].Weather = "Weather"
	   g_MC_Loc[0].Special = "Special rules"
	   g_MC_Loc[0].Buildings = "Buildings"
	   g_MC_Loc[0].Units = "Units"
	   g_MC_Loc[0].Rules = "Rules"
	   g_MC_Loc[0].Activate = "Activate"
	   g_MC_Loc[0].Deactivate = "Deactivate"
	   g_MC_Loc[0].Deactivated = "Deactivated"
	   g_MC_Loc[0].Showrules = "showing rules"
	   g_MC_Loc[0].ClericMsg = "clerics are above the laws and will not work overtime"
	   g_MC_Loc[0].ClericMsgFix = "clerics will only bless once a holy time! Next possible bless in "
	   g_MC_Loc[0].AntiSellBug = "Building in progress of Destruction already"
	   g_MC_Loc[0].NotBuildRule = "No Village Center stealing! Ressources are wasted!"
	   g_MC_Loc[0].WinMsg = "@color:0,255,0 You have won the game!"
	   g_MC_Loc[0].LooseMsg = "Your settlement has been @color:255,0,0 wiped out @color:255,255,255 ."
	   g_MC_Loc[0].LooseMsgWin = "@color:0,255,0 Your team swung the result! Your team has won!"
	   g_MC_Loc[0].LooseMsgTotal = "@color:255,0,0 You have lost the game!"
	   g_MC_Loc[0].FastGameSelection = "Start as Fast Game (multiple Ressources)"
	   g_MC_Loc[0].HQInv = "Players "
	   g_MC_Loc[0].HQInv_Invul = " Headquarter is indestructable now"
	   g_MC_Loc[0].HQInv_Vul = " Headquarter is attackable now"
	   g_MC_Loc[0].TowersNotSellable = "Start Towers not sellable in this Map"
	   g_MC_Loc[0].Random = "Random Rule Generator"
	   
	   --Loc_RulesetStep = {}
	   g_MC_Loc[0].Rule = {}
	   for i = 1, 9 do
		g_MC_Loc[0].Rule[i] = {}
	   end
	   g_MC_Loc[0].Rule["WS"] = {}
	   g_MC_Loc[0].Rule["WS"].Name = "Peacetime"

	   g_MC_Loc[0].Rule["MaxHeroes"] = {}
	   g_MC_Loc[0].Rule["MaxHeroes"].Name = "Max. Heroes"
	   
	   g_MC_Loc[0].Rule["TradeLimit"] = {}
	   g_MC_Loc[0].Rule["TradeLimit"].Name = "Limit Single Trade"
	   	   
	   g_MC_Loc[0].Rule[1].Name = "Units"
	   g_MC_Loc[0].Rule[1][1] = "Heavy Cavalry";
	   g_MC_Loc[0].Rule[1][2] = "Light Cavalry";
	   g_MC_Loc[0].Rule[1][3] = "Heavy Canons";
	   g_MC_Loc[0].Rule[1][4] = "Light Canons";
	   g_MC_Loc[0].Rule[1][5] = "Marksman";
	   g_MC_Loc[0].Rule[1][6] = "Thief";

	   g_MC_Loc[0].Rule[2].Name = "Buildings"   
	   g_MC_Loc[0].Rule[2][1] = "Canon Tower";
	   g_MC_Loc[0].Rule[2][2] = "Ballista Tower";
	   g_MC_Loc[0].Rule[2][3] = "Market Place";
	   g_MC_Loc[0].Rule[2][4] = "-";
	   g_MC_Loc[0].Rule[2][5] = "-";
	   g_MC_Loc[0].Rule[2][6] = "-";

	   g_MC_Loc[0].Rule[3].Name = "Weather"   
	   g_MC_Loc[0].Rule[3][1] = "Winter";
	   g_MC_Loc[0].Rule[3][2] = "Rain";
	   g_MC_Loc[0].Rule[3][3] = "Summer";

	   g_MC_Loc[0].Rule[4].Name = "Special:"     
	   g_MC_Loc[0].Rule[4][1] = "Anti-Destroy-Bug";
	   g_MC_Loc[0].Rule[4][2] = "Bless Limit";
	   g_MC_Loc[0].Rule[4][3] = "VC assigned (team)";	   
	   g_MC_Loc[0].Rule[4][4] = "VC assigned (players)";
	   g_MC_Loc[0].Rule[4][5] = "Anti-HQRush";
	   
	   g_MC_Loc[0].Rule[5].Name = "Maximal Heroes" 
	   g_MC_Loc[0].Rule[5][1] = "Forbidden Heroes";

	   g_MC_Loc[0].Rule[6].Name = "Allow/Forbid Hero" 
	   g_MC_Loc[0].Rule[6][1] = "Dario"
	   g_MC_Loc[0].Rule[6][2] = "Ari"
	   g_MC_Loc[0].Rule[6][3] = "Erec"
	   g_MC_Loc[0].Rule[6][4] = "Salim"
	   g_MC_Loc[0].Rule[6][5] = "Pilgrim"
	   g_MC_Loc[0].Rule[6][6] = "Helias"
	   g_MC_Loc[0].Rule[6][7] = "Mary"
	   g_MC_Loc[0].Rule[6][8] = "Kerberos"
	   g_MC_Loc[0].Rule[6][9] = "Varg"
	   g_MC_Loc[0].Rule[6][10] = "Drake"
	   g_MC_Loc[0].Rule[6][11] = "Yuki"	   	   
	   g_MC_Loc[0].Rule[6][12] = "Kala"
	 
	   
	   
	   -- GERMAN
	   g_MC_Loc[1] = {}
	   g_MC_Loc[1].Peacetime = "Friedenszeit"
	   g_MC_Loc[1].Wartimemsg = "Jetzt wird gek\195\164mpft!"
	   g_MC_Loc[1].Minutes = "Minuten"
	   g_MC_Loc[1].Selected = "Ausgew\195\164hlt!"
	   g_MC_Loc[1].GoOn = "Weiter"
	   g_MC_Loc[1].Back = "Zur\195\188ck"
	   g_MC_Loc[1].Allowed = "erlaubt"
	   g_MC_Loc[1].Forbitten = "verboten"
	   g_MC_Loc[1].ForbittenUnits = "Nach Regeln verboten"
	   g_MC_Loc[1].Yes = "Ja"
	   g_MC_Loc[1].No = "Nein"
	   g_MC_Loc[1].StartGame = "Spiel starten"
	   g_MC_Loc[1].GameStarts = "Spiel beginnt"
	   g_MC_Loc[1].AsFastGame = "als Fastgame"
	   g_MC_Loc[1].In = "in"
	   g_MC_Loc[1].Seconds = "Sekunden"
	   g_MC_Loc[1].ChangeStatus = "\195\132ndere Status"
	   g_MC_Loc[1].Weather = "Wetter"
	   g_MC_Loc[1].Special = "Spezialregeln"
	   g_MC_Loc[1].Buildings = "Geb\195\164ude"
	   g_MC_Loc[1].Units = "Einheiten"
	   g_MC_Loc[1].Rules = "Regeln"
	   g_MC_Loc[1].Activate = "Aktivieren"
	   g_MC_Loc[1].Deactivate = "Deaktivieren"
	   g_MC_Loc[1].Deactivated = "Deaktiviert"
	   g_MC_Loc[1].Showrules = "Regelanzeige"
	   g_MC_Loc[1].ClericMsg = "Prieser stehen \195\188ber dem Gesetz und werden keine \195\156berstunden schieben"
	   g_MC_Loc[1].ClericMsgFix = "Eure Priester werden nur einmal alle Zeiten die heiligen Glocken l\195\164uten! N\195\164chste Moeglichkeit in "
	   g_MC_Loc[1].AntiSellBug = "Geb\195\164ude wird bereits zerst\195\182rt"
	   g_MC_Loc[1].NotBuildRule = "Kein DZ-Klau! Ressourcen verschwendet!"
	   g_MC_Loc[1].WinMsg = "@color:0,255,0 Du hast das Spiel gewonnen!"
	   g_MC_Loc[1].LooseMsg = "Deine Siedlung wurde @color:255,0,0 ausgel\195\182scht @color:255,255,255 ."
	   g_MC_Loc[1].LooseMsgWin = "@color:0,255,0 Dein Team hat es herumgerissen! Dein Team hat gewonnen!"
	   g_MC_Loc[1].LooseMsgTotal = "@color:255,0,0 Du hast das Spiel endg\195\188ltig verloren!"
	   g_MC_Loc[1].FastGameSelection = "Starten als Fast Game (vielfache Ressourcen)"
	   g_MC_Loc[1].HQInv = "Das Hauptquartier von Spieler "
	   g_MC_Loc[1].HQInv_Invul = " ist nun unverwundbar"
	   g_MC_Loc[1].HQInv_Vul = " ist nun angreifbar"
	   g_MC_Loc[1].TowersNotSellable = "Start-T\195\188rme auf dieser Map nicht verkaufbar"
	   g_MC_Loc[1].Random = "Zufallsregelngenerator"
	   --Loc_RulesetStep = {}
	   g_MC_Loc[1].Rule = {}
	   for i = 1, 9 do
		g_MC_Loc[1].Rule[i] = {}
	   end
	   g_MC_Loc[1].Rule["WS"] = {}
	   g_MC_Loc[1].Rule["WS"].Name = "Friedenszeit"

	   g_MC_Loc[1].Rule["MaxHeroes"] = {}
	   g_MC_Loc[1].Rule["MaxHeroes"].Name = "Max. Helden"
	   
	   g_MC_Loc[1].Rule["TradeLimit"] = {}
	   g_MC_Loc[1].Rule["TradeLimit"].Name = "Limit Einzelhandel Marktplatz"
	   
	   g_MC_Loc[1].Rule[1].Name = "Einheiten"
	   g_MC_Loc[1].Rule[1][1] = "Schwere Kavallerie";
	   g_MC_Loc[1].Rule[1][2] = "Leichte Kavallerie";
	   g_MC_Loc[1].Rule[1][3] = "Schwere Kanonen";
	   g_MC_Loc[1].Rule[1][4] = "Leichte Kanonen";
	   g_MC_Loc[1].Rule[1][5] = "Scharfsch\195\188tzen";
	   g_MC_Loc[1].Rule[1][6] = "Diebe";

	   g_MC_Loc[1].Rule[2].Name = "Geb\195\164ude"   
	   g_MC_Loc[1].Rule[2][1] = "Kanonent\195\188rme";
	   g_MC_Loc[1].Rule[2][2] = "Ballistat\195\188rme";
	   g_MC_Loc[1].Rule[2][3] = "Marktpl\195\164tze";
	   g_MC_Loc[1].Rule[2][4] = "-";
	   g_MC_Loc[1].Rule[2][5] = "-";
	   g_MC_Loc[1].Rule[2][6] = "-";

	   g_MC_Loc[1].Rule[3].Name = "Wetter"   
	   g_MC_Loc[1].Rule[3][1] = "Winter";
	   g_MC_Loc[1].Rule[3][2] = "Regen";
	   g_MC_Loc[1].Rule[3][3] = "Sommer";

	   g_MC_Loc[1].Rule[4].Name = "Spezial:"     
	   g_MC_Loc[1].Rule[4][1] = "Anti-Abreissbug";
	   g_MC_Loc[1].Rule[4][2] = "Segnenlimit";
	   g_MC_Loc[1].Rule[4][3] = "DZ zugeordnet (team)";
	   g_MC_Loc[1].Rule[4][4] = "DZ zugeordnet (spieler)";
	   g_MC_Loc[1].Rule[4][5] = "Anti-Burgrush";
	   
	   g_MC_Loc[1].Rule[5].Name = "Maximale Helden" 
	   
	   g_MC_Loc[1].Rule[6].Name = "Erlaubte Helden" 
	   g_MC_Loc[1].Rule[6][1] = "Dario"
	   g_MC_Loc[1].Rule[6][2] = "Ari"
	   g_MC_Loc[1].Rule[6][3] = "Erec"
	   g_MC_Loc[1].Rule[6][4] = "Salim"
	   g_MC_Loc[1].Rule[6][5] = "Pilgrim"
	   g_MC_Loc[1].Rule[6][6] = "Helias"
	   g_MC_Loc[1].Rule[6][7] = "Mary"
	   g_MC_Loc[1].Rule[6][8] = "Kerberos"
	   g_MC_Loc[1].Rule[6][9] = "Varg"
	   g_MC_Loc[1].Rule[6][10] = "Drake"
	   g_MC_Loc[1].Rule[6][11] = "Yuki"	   	   
	   g_MC_Loc[1].Rule[6][12] = "Kala"
		-- polnisch
		g_MC_Loc[2] = {}
		g_MC_Loc[2].Peacetime = "Czas Pokoju"
		g_MC_Loc[2].Wartimemsg = "Walczmy!"
		g_MC_Loc[2].Minutes ="Minuty"
		g_MC_Loc[2].Selected = "Wybrany"
		g_MC_Loc[2].GoOn = "Dalej"
		g_MC_Loc[2].Back = "Wroc"
		g_MC_Loc[2].Allowed = "Dozwolone"
		g_MC_Loc[2].Forbitten = "Zabronione"
		g_MC_Loc[2].ForbittenUnits = "Jednostki Zabronione"
		g_MC_Loc[2].Yes = "Tak"
		g_MC_Loc[2].No = "Nie"
		g_MC_Loc[2].StartGame = "Poczatek Gry"
		g_MC_Loc[2].GameStarts = "Gra rozpoczela sie"
		g_MC_Loc[2].AsFastGame = "Jako szybka gra"
		g_MC_Loc[2].In = "w"
		g_MC_Loc[2].Seconds = "Sekundy"
		g_MC_Loc[2].ChangeStatus = "Zmiana Statusu"
		g_MC_Loc[2].Weather = "Pogoda"
		g_MC_Loc[2].Special = "Dodatkowe Zasady"
		g_MC_Loc[2].Buildings = "Budynki"
		g_MC_Loc[2].Units = "Jednostki"
		g_MC_Loc[2].Rules = "Zasady"
		g_MC_Loc[2].Activate = "Aktywowane"
		g_MC_Loc[2].Deactivate = "Deaktywowac"
		g_MC_Loc[2].Deactivated = "Nieaktywne"
		g_MC_Loc[2].Showrules = "Pokaz Zasady"
		g_MC_Loc[2].ClericMsg = "Duchownych nie obowiazuje prawo-nie odpracowuja godzin nadliczbowych"
		g_MC_Loc[2].ClericMsgFix = "(sry no translation yet) clerics will only bless special people once a holy time! Next possible bless in "
		g_MC_Loc[2].AntiSellBug = "Budynek jest w czasie burzenia"
		g_MC_Loc[2].NotBuildRule = "Nie kradnij Osrodka Wiejskiego!Surowce sa wyczerpane!"
		g_MC_Loc[2].WinMsg = "@color:0,255,0 Wygrales Gre"
		g_MC_Loc[2].LooseMsg = "Twoja osada zostala @color:255,0,0 zniszczona @color:255,255,255 ."
		g_MC_Loc[2].LooseMsgWin = "@color:0,255,0 Twoj zespol odwrocil losy rozgrywki!Twoja druzyna wygrala!"
		g_MC_Loc[2].LooseMsgTotal = "Przegrales Gre!"
		g_MC_Loc[2].FastGameSelection = "Rozpocznij Szybka Gre (wiecej surowcow)"
		g_MC_Loc[2].HQInv = "gracz "
		g_MC_Loc[2].HQInv_Invul = " - niezniszczalny zamek obecnie"
		g_MC_Loc[2].HQInv_Vul = " - zniszczalny zamek obecnie"
		g_MC_Loc[2].TowersNotSellable = "Poczatkowy Wieza nie sprzedac"
		g_MC_Loc[2].Random = "(sry no translation yet) Random Rule Generator"
		--Loc_RulesetStep = {}
		g_MC_Loc[2].Rule = {}
		for i = 1, 9 do
		g_MC_Loc[2].Rule[i] = {}
		end
		g_MC_Loc[2].Rule["WS"] = {}
		g_MC_Loc[2].Rule["WS"].Name = "Czas Pokoju"

		g_MC_Loc[2].Rule["MaxHeroes"] = {}
		g_MC_Loc[2].Rule["MaxHeroes"].Name = "Maksymalna ilosc bohaterow"

		g_MC_Loc[2].Rule["TradeLimit"] = {}
		g_MC_Loc[2].Rule["TradeLimit"].Name = "Limit pojedynczego handlu"

		g_MC_Loc[2].Rule[1].Name = "Jednostki"
		g_MC_Loc[2].Rule[1][1] = "Ciezka Kawaleria";
		g_MC_Loc[2].Rule[1][2] = "Lekka Kawaleria";
		g_MC_Loc[2].Rule[1][3] = "Ciezkie Dziala";
		g_MC_Loc[2].Rule[1][4] = "Lekkie Dziala";
		g_MC_Loc[2].Rule[1][5] = "Strzelec Wyborowy";
		g_MC_Loc[2].Rule[1][6] = "Zlodziej";

		g_MC_Loc[2].Rule[2].Name = "Budynki"
		g_MC_Loc[2].Rule[2][1] = "Wieza z dzialem ";
		g_MC_Loc[2].Rule[2][2] = "Wieza z balista";
		g_MC_Loc[2].Rule[2][3] = "Targowisko";
		g_MC_Loc[2].Rule[2][4] = "-";
		g_MC_Loc[2].Rule[2][5] = "-";
		g_MC_Loc[2].Rule[2][6] = "-";

		g_MC_Loc[2].Rule[3].Name = "Pogoda"
		g_MC_Loc[2].Rule[3][1] = "Zima";
		g_MC_Loc[2].Rule[3][2] = "Deszcz";
		g_MC_Loc[2].Rule[3][3] = "Lato";

		g_MC_Loc[2].Rule[4].Name = "Dodatkowo:"
		g_MC_Loc[2].Rule[4][1] = "Bez Bug-a Surowcowego";
		g_MC_Loc[2].Rule[4][2] = "Kler bez nadgodzin";
		g_MC_Loc[2].Rule[4][3] = "Przydzielono Osrodki Wiejskie (zespol)";
		g_MC_Loc[2].Rule[4][4] = "Przydzielono Osrodki Wiejskie (gracz)";
		g_MC_Loc[2].Rule[4][5] = "Anti-HQ-Rush";
		g_MC_Loc[2].Rule[5].Name = "Maksimum bohaterow"
		g_MC_Loc[2].Rule[5][1] = "Niedozwoleni bohaterowie";

		g_MC_Loc[2].Rule[6].Name = "Dozwoleni/Zabronieni bohaterowie"
		g_MC_Loc[2].Rule[6][1] = "Dario"
		g_MC_Loc[2].Rule[6][2] = "Ari"
		g_MC_Loc[2].Rule[6][3] = "Erec"
		g_MC_Loc[2].Rule[6][4] = "Salim"
		g_MC_Loc[2].Rule[6][5] = "Pielgrzym"
		g_MC_Loc[2].Rule[6][6] = "Heliasz"
		g_MC_Loc[2].Rule[6][7] = "Mary"
		g_MC_Loc[2].Rule[6][8] = "Cerber"
		g_MC_Loc[2].Rule[6][9] = "Varg"
		g_MC_Loc[2].Rule[6][10] = "Drake"
		g_MC_Loc[2].Rule[6][11] = "Yuki"
		g_MC_Loc[2].Rule[6][12] = "Kala" 	   
		
	end

	SetupLocalization = function()
		for i = 2, gvMaxPlayers do mpc_CreateLanguageChoiceTributes(i)	end
	end
	
	SetupRuleSets = function(_Step)
		   local _text
		   local _text2
		   
		   if _Step == 99 then
				mpc_TRIB[1] = AddTribute( CreateATribute(1, "@color:255,255,0 "..g_MC_Loc[lang].GoOn..":", { Gold = 0}, mpc_TRIBGoOn[_Step] ) )
				mpc_TRIB[2] = mpc_CreateLanguageChoiceTributes(9)
				if 	mpc_Rules.random.Sel then
					mpc_TRIB[3] = AddTribute( CreateATribute(1, "@color:255,255,0 "..g_MC_Loc[lang].Random, { Gold = 0}, mpc_StepFunc[99][3] ) )
				end
				mpc_TRIB[6] = AddTribute( CreateATribute(1, "QUICKSTART", { Gold = 0}, mpc_StepFunc[99][6] ) )
		   end
		   
		if _Step == 1 then
			mpc_RulesActCheck[1] = false 
			mpc_RulesActCheck[2] = false			
			for i = 1, table.getn(mpc_Rules[4].Sel) do
				if mpc_Rules[1].Sel[i] == true then mpc_RulesActCheck[1] = true end break
			end
			for i = 1, table.getn(mpc_Rules[2].Sel) do
				if mpc_Rules[1].Sel[i] == true then mpc_RulesActCheck[2] = true end break
			end				
			if mpc_RulesActCheck[1] == true or mpc_RulesActCheck[2] == true or mpc_RulesActCheck[3] == true or mpc_Rules.WS.Sel == true then
				mpc_TRIB[1] = AddTribute( CreateATribute(1, "@color:255,255,0 "..g_MC_Loc[lang].GoOn..":", { Gold = 0}, mpc_TRIBGoOn[_Step] ) )
				if mpc_Rules.WS.Sel == true then
					mpc_CreateSingleChoiceTributes("WS", 2)
				end
				if mpc_Rules.MaxHeroes.Sel == true then
					mpc_CreateSingleChoiceTributes("MaxHeroes", 3)
				end				
				if mpc_RulesActCheck[1] == true then
					mpc_CreateChoiceTributes(6, 4)
				end
				if mpc_RulesActCheck[2] == true then
					mpc_CreateChoiceTributes(2, 5)
				end
				_text = "@color:255,0,255 "..g_MC_Loc[lang].ChangeStatus;
				mpc_TRIB[6] = AddTribute( CreateATribute(1, _text, { Gold = 0}, mpc_TRIBChangeRuleFunc[_Step] ) )					
			else
				SetupRuleSets(2); return		
			end			
		end
		
		if _Step == 2 then
			mpc_RulesActCheck[1] = false 
			mpc_RulesActCheck[2] = false
			mpc_RulesActCheck[3] = false 			
	
			for i = 1, table.getn(mpc_Rules[1].Sel) do
				if mpc_Rules[1].Sel[i] == true then mpc_RulesActCheck[1] = true end break
			end
			for i = 1, table.getn(mpc_Rules[3].Sel) do
				if mpc_Rules[1].Sel[i] == true then mpc_RulesActCheck[2] = true end break
			end		
			for i = 1, table.getn(mpc_Rules[4].Sel) do
				if mpc_Rules[1].Sel[i] == true then mpc_RulesActCheck[3] = true end break
			end	
			
			if mpc_Rules.TradeLimit.Sel == true or mpc_RulesActCheck[1] == true or mpc_RulesActCheck[2] == true or mpc_RulesActCheck[3] == true or mpc_RulesActCheck[4] == true then
				mpc_TRIB[1] = AddTribute( CreateATribute(1, "@color:255,255,0 "..g_MC_Loc[lang].GoOn..":", { Gold = 0}, mpc_TRIBGoOn[_Step] ) )			
				if mpc_Rules.TradeLimit.Sel == true then
					mpc_CreateSingleChoiceTributes("TradeLimit", 2)
				end		
				if mpc_RulesActCheck[1] == true then
					mpc_CreateChoiceTributes(1, 3)
				end
				if mpc_RulesActCheck[2] == true then
					mpc_CreateChoiceTributes(3, 4)
				end
				if mpc_RulesActCheck[3] == true then
					mpc_CreateChoiceTributes(4, 5)
				end

				_text = "@color:255,0,255 "..g_MC_Loc[lang].ChangeStatus;
				mpc_TRIB[6] = AddTribute( CreateATribute(1, _text, { Gold = 0}, mpc_TRIBChangeRuleFunc[_Step] ) )					
			else
				SetupRuleSets(3); return		
			end		
		end
		
		if _Step == 98 then
			mpc_TRIB[1] = AddTribute( CreateATribute(1, "@color:0,255,0 "..g_MC_Loc[lang].StartGame, { Gold = 0}, mpc_StepFunc[_Step][1] ) )
			mpc_TRIB[2] = AddTribute( CreateATribute(1, "@color:255,0,0 "..g_MC_Loc[lang].Back, { Gold = 0}, mpc_StepFunc[_Step][2] ) )
			if mpc_Rules.FastGame.Sel then mpc_TRIB[3] = AddTribute( CreateATribute(1, gvCol.gelb.." "..g_MC_Loc[lang].FastGameSelection, { Gold = 0}, mpc_StepFunc[_Step][3] ) ) end
		end
		
		if _Step == 0 then
			mpc_CreateLanguageChoiceTributes(1)
			GUIAction_ToggleMenu( "TradeWindow", 0)
			VerifyRulesets()
		end
		
	end

	VerifyRulesets = function()
		
		if mpc_Rules.FastGame[1] then
			local mal = mpc_Rules.FastGame.Multiplicator
			g_MC_StR = { Gold = g_MC_StR.Gold * mal, Clay = g_MC_StR.Clay * mal, Wood = g_MC_StR.Wood * mal,
						Stone = g_MC_StR.Stone * mal, Iron = g_MC_StR.Iron * mal, Sulfur = g_MC_StR.Sulfur * mal }
		end
		
		for i = 1,gvMaxPlayers do
			if not mpc_Rules[1].Act[1] then ForbidTechnology(Technologies.MU_LeaderHeavyCavalry, i); end
			if not mpc_Rules[1].Act[2] then ForbidTechnology(Technologies.MU_LeaderLightCavalry, i); end
			if not mpc_Rules[1].Act[3] then ForbidTechnology(Technologies.MU_Cannon2, i); ForbidTechnology(Technologies.MU_Cannon4, i); end
			if not mpc_Rules[1].Act[4] then ForbidTechnology(Technologies.MU_Cannon1, i); ForbidTechnology(Technologies.MU_Cannon3, i); end
			if not mpc_Rules[1].Act[5] then ForbidTechnology(Technologies.B_GunsmithWorkshop, i); end
			if not mpc_Rules[1].Act[6] then ForbidTechnology(Technologies.MU_Thief, i); end
			if not mpc_Rules[2].Act[2] then ForbidTechnology(Technologies.UP1_Tower, i); end
			if not mpc_Rules[2].Act[1] then ForbidTechnology(Technologies.UP2_Tower, i); end
			if not mpc_Rules[2].Act[3] then ForbidTechnology(Technologies.UP1_Market, i); end
			if not mpc_Rules[3].Act[1] then ForbidTechnology(Technologies.T_MakeSnow, i); end
			if not mpc_Rules[3].Act[2] then ForbidTechnology(Technologies.T_MakeRain, i); end
			if not mpc_Rules[3].Act[3] then ForbidTechnology(Technologies.T_MakeSummer, i); end
		end
		gvStartJobID = StartSimpleJob("GameStart")
	end

	GameStart = function()
		
		if mpc_GameStartDelay == 0 then
			Message("@color:0,255,0 "..g_MC_Loc[lang].GameStarts.."!")
			EndJob(gvStartJobID)
			EndJob(gvRuleDisplayJob)
			HideMovieFenster(true)
			SetPeacetime( mpc_Rules.WS[mpc_Rules.WS.Cur]*60 )
			Mission_InitLocalResources()
			if mpc_Rules[4].Act[5] then
				NoRushRuleInitialize()
			end
			if mpc_Rules.TowersNotSellable then
				
				for i = 1,gvMaxPlayers do
					Comfort_TrackEntityIni(i,Entities.PB_Tower1)
					Comfort_TrackEntityIni(i,Entities.PB_Tower2)
					Comfort_TrackEntityIni(i,Entities.PB_Tower3)		
				end
				local _temp = {Entities.PB_Tower1, Entities.PB_Tower2, Entities.PB_Tower3}
				mpc_towers = {}
				for i = 1,gvMaxPlayers do
					mpc_towers[i] = {} 
					for v = 1,3 do
						mpc_towers[i][v] = {}
						for u = 1, table.getn( Track_Entity_Table[i][ _temp[v] ] ) do
							mpc_towers[i][v][u] = Track_Entity_Table[i][ _temp[v] ][u]
						end
					end		
				end				
			end
			ReBuildAllPlayerVillageCenters()
			Logic.ResumeAllEntities()
			MultiplayerTools.GiveBuyableHerosToHumanPlayer( mpc_Rules.MaxHeroes[mpc_Rules.MaxHeroes.Cur] )		
			Sound.PlayGUISound( Sounds.fanfare, 127 )
			for i = 1,12 do
			  if mpc_Rules[6].Act[i] then
				 GUIAction_ToggleMenu("BuyHeroWindowBuyHero"..i, 1)
			  end
			end
			gv_MC_GameStateJob = StartSimpleJob("PlayerGameStateCheck")
			
		end
		mpc_GameStartDelay = mpc_GameStartDelay - 1

	end

	ReBuildAllPlayerVillageCenters = function()   
		for i = 1, gvMaxPlayers do
			v = 0
			while true do
				v = v + 1
				if not (type (mpc_villageCenters[i][1][v]) == "table") then
					v = v - 1
					break
				end
				
			end
			for u = 1,table.getn(mpc_villageCenters[i][1]) do
				Logic.CreateEntity( Entities.PB_VillageCenter1, mpc_villageCenters[i][1][u].pos.X, mpc_villageCenters[i][1][u].pos.Y, 0, i )
			end
		end
	end

	ClearAllPlayerVillageCenters = function()
		for i = 1,gvMaxPlayers do
			Comfort_TrackEntityIni(i,Entities.PB_VillageCenter1)
			Comfort_TrackEntityIni(i,Entities.PB_VillageCenter2)
			Comfort_TrackEntityIni(i,Entities.PB_VillageCenter3)		
		end
		local _temp = {Entities.PB_VillageCenter1, Entities.PB_VillageCenter2, Entities.PB_VillageCenter3}
		mpc_villageCenters = {}
		for i = 1,gvMaxPlayers do
			mpc_villageCenters[i] = {} 
			for v = 1,3 do
				mpc_villageCenters[i][v] = {}
				local w = 0
				for u = 1, table.getn( Track_Entity_Table[i][ _temp[v] ] ) do
					mpc_villageCenters[i][v][u] = {}
					mpc_villageCenters[i][v][u].id = Track_Entity_Table[i][ _temp[v] ][u-w]
					mpc_villageCenters[i][v][u].pos = GetPosition ( Track_Entity_Table[i][ _temp[v] ][u-w] )
					DestroyEntity ( Track_Entity_Table[i][ _temp[v] ][u-w] )
					w = w + 1
				end
			end		
		end
	end

	PlayerGameStateCheck = function()
		for i = 1,gvMaxPlayers do		
			if Logic.PlayerGetGameState( i ) == 3 and gv_MC_imdead[i] == nil then
				if i == gv_guipId then	
					GUI.AddStaticNote(g_MC_Loc[lang].LooseMsg)
					GUIAction_ToggleMenu(600,0)
	
				end
	
				gv_MC_imdead[i] = 1
			end
			if Logic.PlayerGetGameState( i ) == 2 then
				if XNetwork.GameInformation_GetLogicPlayerTeam(i) == XNetwork.GameInformation_GetLogicPlayerTeam( gv_guipId ) then
					if gv_MC_imdead[gv_guipId] == nil then
				
						GUI.AddStaticNote(g_MC_Loc[lang].WinMsg)
					else 
						GUI.AddStaticNote(g_MC_Loc[lang].LooseMsgWin)
					end
				else
				
					GUI.AddStaticNote(g_MC_Loc[lang].LooseMsgTotal)
				end
				for u = 1,gvMaxPlayers do
					if gv_MC_imdead[u] == nil then
						PlayerEndGame(u)
					end
				end
				GUIAction_ToggleMenu(600,0)
				EndJob(gv_MC_GameStateJob)
				break
			end
		end
	end

	Max_Tradevalue_Limiting = function()
		_limitcheck = {gvGUI.MarketMoneyToBuy, gvGUI.MarketClayToBuy, gvGUI.MarketWoodToBuy, gvGUI.MarketStoneToBuy, gvGUI.MarketIronToBuy, gvGUI.MarketSulfurToBuy}
		if (_limitcheck[1] > mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur]) then gvGUI.MarketMoneyToBuy = mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur] end
		if (_limitcheck[2] > mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur]) then gvGUI.MarketClayToBuy = mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur] end	
		if (_limitcheck[3] > mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur]) then gvGUI.MarketWoodToBuy= mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur] end	
		if (_limitcheck[4] > mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur]) then gvGUI.MarketStoneToBuy = mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur] end	
		if (_limitcheck[5] > mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur]) then gvGUI.MarketIronToBuy = mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur] end	
		if (_limitcheck[6] > mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur]) then gvGUI.MarketSulfurToBuy = mpc_Rules.TradeLimit[mpc_Rules.TradeLimit.Cur] end	
		
		--[[if (_limitcheck[1] < 500) then GUIAction_MarketToggleResource(500, 0) end
		if (_limitcheck[2] < 500) then GUIAction_MarketToggleResource(500, 0) end
		if (_limitcheck[3] < 500) then GUIAction_MarketToggleResource(500, 0) end
		if (_limitcheck[4] < 500) then GUIAction_MarketToggleResource(500, 0) end
		if (_limitcheck[5] < 500) then GUIAction_MarketToggleResource(500, 0) end
		if (_limitcheck[6] < 500) then GUIAction_MarketToggleResource(500, 0) end ]]--
	end

	CheckAllVillageCenterNoReplaceMent = function ()		
		for i = 1,gvMaxPlayers do
			for z = 1,gvMaxPlayers do
				for w = 1, table.getn( Track_Entity_Table[z][ Entities.PB_VillageCenter1 ] ) do
					local _vcId = Track_Entity_Table[z][ Entities.PB_VillageCenter1 ][w]
					local _vcId_pos = GetPosition(_vcId)
					for v = 1,3 do						
						for u = 1, table.getn( mpc_villageCenters[i][v] ) do					
							if _vcId_pos.X == mpc_villageCenters[i][v][u].pos.X and _vcId_pos.Y == mpc_villageCenters[i][v][u].pos.Y then

								if mpc_Rules[4].Act[4] then
									if not ( GetPlayer( _vcId ) == i )then
										if gv_guipId == GetPlayer(_vcId) then
											Message(g_MC_Loc[lang].NotBuildRule)
										end
										DestroyEntity ( _vcId )
									end	
								else
									if not ( XNetwork.GameInformation_GetLogicPlayerTeam( GetPlayer( _vcId ) ) == XNetwork.GameInformation_GetLogicPlayerTeam(i) )then
										if gv_guipId == GetPlayer(_vcId) then
											Message(g_MC_Loc[lang].NotBuildRule)
										end
										DestroyEntity ( _vcId )
									end								
								end
							end
						end
					end
				end
			end
		end			
	end
	VillageCenterAssignedJob = function()		
		gv_MC_NoDZReplaceTimer = gv_MC_NoDZReplaceTimer - 1
		if gv_MC_NoDZReplaceTimer <= 0 then
			CheckAllVillageCenterNoReplaceMent()
			EndJob(gv_MC_NoDZReplaceJob)
		end
	end
	NoRushRuleCheck = function(_pId)
		local _temp = {Entities.PB_VillageCenter1, Entities.PB_VillageCenter2, Entities.PB_VillageCenter3}
		for i = 1,3 do
			for w = 1, table.getn( Track_Entity_Table[_pId][ _temp[i] ] ) do
				if not mpc_Rules.HQInv[_pId] then
					MakeInvulnerable( Logic.GetEntityAtPosition( mpc_HQsLocations[_pId].X, mpc_HQsLocations[_pId].Y ) )
					mpc_Rules.HQInv[_pId] = true
					Message(g_MC_Loc[lang].HQInv.._pId.." "..gvCol.gruen..g_MC_Loc[lang].HQInv_Invul)
				end
				return
			end
		end
		if mpc_Rules.HQInv[_pId] then
			MakeVulnerable( Logic.GetEntityAtPosition( mpc_HQsLocations[_pId].X, mpc_HQsLocations[_pId].Y ) ) 
			mpc_Rules.HQInv[_pId] = false
			Message(g_MC_Loc[lang].HQInv.._pId.." "..gvCol.rot..g_MC_Loc[lang].HQInv_Vul)
		end
	end
	NoRushRuleInitialize = function()
		local _temp = {Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3}
		mpc_HQsLocations = {}
		for i = 1,gvMaxPlayers do
			for u = 1,3 do
				local temp = {Logic.GetPlayerEntities(i, _temp[u],1)}
				if temp[1] > 0 then
					mpc_HQsLocations[i] = GetPosition( temp[2] )
					break
				end					
			end
		end
	end
	
	SetupRulesetComfort_Localization()
end

function ActionOnGoodsTraded()
	_player = GetPlayer( Event.GetEntityID() )
	_ressourcesell = Event.GetSellResource()
	_ressourcebuy = Event.GetBuyResource()
	if Logic.GetCurrentPrice(_player,_ressourcesell) > 1.3 then
			   Logic.SetCurrentPrice( _player, _ressourcesell, 1.3 )
	end
	if Logic.GetCurrentPrice(_player,_ressourcesell) < 0.7 then
			   Logic.SetCurrentPrice( _player, _ressourcesell, 0.7 )
	end
	if Logic.GetCurrentPrice(_player,_ressourcebuy) > 1.3 then
			   Logic.SetCurrentPrice( _player, _ressourcebuy, 1.3 )
	end
	if Logic.GetCurrentPrice(_player,_ressourcebuy) < 0.7 then
				Logic.SetCurrentPrice( _player, _ressourcebuy, 0.7 )
	end
end

function ActionOnEntityCreated()
	local _eId = Event.GetEntityID()
	local _eType = Logic.GetEntityType( _eId )
	Comfort_TrackEntity_Created(_eId)
	if _eType == Entities.PB_VillageCenter1 then		
		if gv_MC_NoDZReplaceTimer <= 0 and (mpc_Rules[4].Act[3] or mpc_Rules[4].Act[4]) then
			gv_MC_NoDZReplaceTimer = 3
			gv_MC_NoDZReplaceJob = StartSimpleJob("VillageCenterAssignedJob")
		end
		if mpc_Rules[4].Act[5] then
			local _pId = GetPlayer(_eId)
			if not mpc_Rules.HQInv[_pId] then
				NoRushRuleCheck(_pId)
			end	
		end
	end
end

function ActionOnEntityDestroyed()
	local _eId = Event.GetEntityID()
	local _eType = Logic.GetEntityType( _eId )
	Comfort_TrackEntity_Destroyed(_eId)	
	if mpc_Rules[4].Act[5] then
		local _pId = GetPlayer(_eId)
		if mpc_Rules.HQInv[_pId] and ( _eType == Entities.PB_VillageCenter1 or _eType == Entities.PB_VillageCenter2 or _eType == Entities.PB_VillageCenter3 ) then
			NoRushRuleCheck(_pId)
		end
	end
end


function Setup_GUIHacks()
 
    GameCallback_GUI_SelectionChanged_OrigProtected = GameCallback_GUI_SelectionChanged;
    GameCallback_GUI_SelectionChanged = function()
			GameCallback_GUI_SelectionChanged_OrigProtected()
			if mpc_GameStartDelay > 0 then
				XGUIEng.ShowWidget( gvGUI_WidgetID.DestroyBuilding, 0 );
            end					
			EndJob( gvTradeLimitJob )
			if mpc_Rules.TradeLimit.Cur > 1 then
				if Logic.GetEntityType( GUI.GetSelectedEntity() ) == 37 then
					gvTradeLimitJob = StartSimpleHiResJob( "Max_Tradevalue_Limiting" )
				end			
			end
    end	

    --GUIUpdate_BuyHeroButton_OrigProtected = GUIUpdate_BuyHeroButton;
    --GUIUpdate_BuyHeroButton = function()
    --    GUIUpdate_BuyHeroButton_OrigProtected()
	--	GUIAction_ToggleMenu( "BuyHeroWindow", -1)
    --end
	
	gvAlreadyDestructed = {}
    for i=1,gvMaxPlayers do
        gvAlreadyDestructed[i] = 0
    end
	
	GUI.SellBuilding_OrigProtected = GUI.SellBuilding;
    GUI.SellBuilding = function()
		if mpc_Rules.TowersNotSellable then
			for v = 1,3 do
				for u = 1, table.getn( mpc_towers[gv_guipId][ v ] ) do
					if GUI.GetSelectedEntity() == mpc_towers[gv_guipId][ v ][u] then
						Message(g_MC_Loc[lang].TowersNotSellable)
						return
					end
				end
			end			
		end
		if mpc_Rules[4].Act[1] then
			if gvAlreadyDestructed[gv_guipId] == GUI.GetSelectedEntity() then
				Message(g_MC_Loc[lang].AntiSellBug)
				Sound.PlayGUISound( Sounds.VoicesMentor_COMMENT_no_rnd_01, 127 )
			else
				gvAlreadyDestructed[gv_guipId] = GUI.GetSelectedEntity()		
				GUI.SellBuilding_OrigProtected(GUI.GetSelectedEntity())
			end
		else
			GUI.SellBuilding_OrigProtected(GUI.GetSelectedEntity())
		end
		
    end
	
	--GUI.ToggleOvertimeAtBuildingOrig = GUI.ToggleOvertimeAtBuilding;
    --GUI.ToggleOvertimeAtBuilding = function( _id )
    --    DisallowClericOvertime_func( _id, GUI.ToggleOvertimeAtBuildingOrig );		
    --end
    
    --GUI.ForceSettlerToWorkOrig = GUI.ForceSettlerToWork;
    --GUI.ForceSettlerToWork = function( _id )	
    --    DisallowClericOvertime_func( _id, GUI.ToggleOvertimeAtBuildingOrig );		
    --end
    
	GUIAction_BlessSettlersOrig = GUIAction_BlessSettlers
	GUIAction_BlessSettlers = function(_BlessCategory)
		if mpc_Rules[4].Act[2] then		
			--mpc_Rules.BlessTimer
			if mpc_Rules.BlessTimer[gv_guipId][_BlessCategory] > (Logic.GetTime() - mpc_Rules[4].TimeBetweenBlessings) then		
				if Logic.GetPlayersGlobalResource(gv_guipId,ResourceType.Faith) >= 5000 then
					Message( g_MC_Loc[lang].ClericMsgFix..gvCol.rot.." "..math.floor(-1*(Logic.GetTime() - mpc_Rules[4].TimeBetweenBlessings - mpc_Rules.BlessTimer[gv_guipId][_BlessCategory])).." "..g_MC_Loc[lang].Seconds )
				else
					GUIAction_BlessSettlersOrig(_BlessCategory)
				end
			else
				GUIAction_BlessSettlersOrig(_BlessCategory)
				local _blockbless = math.floor(Logic.GetTime()+0.5)
				if Logic.GetPlayersGlobalResource(gv_guipId,ResourceType.Faith) >= 5000 then
					if BlessCategories.Canonisation == _BlessCategory then
						mpc_Rules.BlessTimer[gv_guipId][BlessCategories.Construction] = _blockbless
						mpc_Rules.BlessTimer[gv_guipId][BlessCategories.Research] = _blockbless
						mpc_Rules.BlessTimer[gv_guipId][BlessCategories.Weapons] = _blockbless
						mpc_Rules.BlessTimer[gv_guipId][BlessCategories.Financial] = _blockbless
					else
						mpc_Rules.BlessTimer[gv_guipId][_BlessCategory] = _blockbless
					end
					mpc_Rules.BlessTimer[gv_guipId][BlessCategories.Canonisation] = _blockbless
				end
			end
		else
			GUIAction_BlessSettlersOrig(_BlessCategory)
		end
	end

    --DisallowClericOvertime_func = function( _id, _func )
    --   local _var = Logic.GetEntityType( GUI.GetSelectedEntity() )
	--	if mpc_Rules[4].Act[2] and (_var == 42 or _var == 41 or _var == 40) then
	--		Sound.PlayGUISound( Sounds.Misc_Chat, 127 )
	--		Message( g_MC_Loc[lang].ClericMsg );
	--	else
	--		_func( _id );
	--	end
	--	
    --end 
	
end

