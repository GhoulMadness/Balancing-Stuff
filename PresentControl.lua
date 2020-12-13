gvPresent = gvPresent or {}
--Geschenke-Funktionen initialisieren
--Trigger IDs
gvPresent.triggerIDTable = {
							Theft = {}, 
							Delivery = {}, 
							Kill = {},
							Created = {},
							Victory = {}
							}
gvPresent.SDPaydayFactor = {}
for i = 1,8 do
	gvPresent.SDPaydayFactor[i] = 1
end
function gvPresent.Init()

	if not gvPresent.Progress then
		gvPresent.Progress = gvPresent.Progress or {}
	end
	for i = 1,2 do
		gvPresent.Progress[i] = 3
		gvPresent.triggerIDTable.Theft[i] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,nil,"gvPresent_ThiefPresentStolenCheck", 1,nil,{i})
	end
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("PresentProgressScreen"),1)
	gvPresent.triggerIDTable.Created[1] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED,nil,"gvPresent_ThiefCreated", 1)
	gvPresent.ThiefIDTable = {}
	for i = 1,4,1 do
		gvPresent.ThiefIDTable[i] = {}
	end	
	gvPresent.triggerIDTable.Victory[1] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,nil,"gvPresent_VictoryJob", 1)
end
--Geschenke-Fortschritt-Anzeige updaten
function GUIUpdate_PresentProgress_Screen(_TID)

	if type(_TID) ~= "number" then 
		return
	end
	gvPresent.Progress[_TID] = math.abs(gvPresent.Progress[_TID])
	local pID1, pID2
	if _TID == 1 then
		pID1 = 1
		pID2 = 2
	elseif _TID == 2 then
		pID1 = 3
		pID2 = 4
	end
	if GUI.GetPlayerID() == pID1 or GUI.GetPlayerID() == pID2 then
		for i = 1,7,1 do
			XGUIEng.ShowWidget(XGUIEng.GetWidgetID("PresentProgress"..i-1),0)
		end
		XGUIEng.ShowWidget(XGUIEng.GetWidgetID("PresentProgress"..gvPresent.Progress[_TID]),1)
	end
end
	
--Alle Dieb-IDs in Table einfügen (Table aktuell ungenutzt)
function gvPresent_ThiefCreated()
    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)
    local playerID = Logic.EntityGetPlayer(entityID)
    if entityType == Entities.PU_Thief then
    
	table.insert(gvPresent.ThiefIDTable[playerID],entityID)
	end
end
-- Positionen der beiden Weihnachtsbäume
gvPresent.XmasTreePos =		{
								[1]={X=3300,Y=34800},
								[2]={X=51200,Y=34800}
							}							
-- Alle Geschenke-Typen. Beim erfolgreichen Klau wird zufällig eines davon erstellt
gvPresent.PresentTypes = {Entities.XD_Present1,Entities.XD_Present2,Entities.XD_Present3}
-- kritische Reichweite, in der ein Geschenk geklaut werden kann
gvPresent.XmasTreeCriticalRange = 500
-- Reichweite, in der um den Weihnachtsbaum keine Gebäude platziert werden können
gvPresent.XmasTreeBuildBlockRange = 3600
-- Check, ob ein Geschenk geklaut wurde
function gvPresent_ThiefPresentStolenCheck(_TID)	
	local pID1
	local pID2
	local eTID 
	if _TID == 1 then
		pID1 = 1
		pID2 = 2
		eTID = 2
	elseif _TID == 2 then
		pID1 = 3
		pID2 = 4
		eTID = 1
	else
		return
	end					
	local number1,eID1 = Logic.GetPlayerEntitiesInArea(pID1,Entities.PU_Thief, gvPresent.XmasTreePos[eTID].X, gvPresent.XmasTreePos[eTID].Y, gvPresent.XmasTreeCriticalRange, 10)
	local number2,eID2 = Logic.GetPlayerEntitiesInArea(pID2,Entities.PU_Thief, gvPresent.XmasTreePos[eTID].X, gvPresent.XmasTreePos[eTID].Y, gvPresent.XmasTreeCriticalRange, 10)
	local eID
	if eID1 ~= nil then
		eID = eID1
	elseif eID2 ~= nil then
		eID = eID2
	else
	end
	if eID ~= nil then
		local pID = Logic.EntityGetPlayer(eID)
		local resTyp,amount 
		resTyp,amount = Logic.GetStolenResourceInfo(eID)
		
		local pos = gvPresent.XmasTreePos[eTID]

		if amount ~= nil then
			if amount > 0 then
				DestroyEntity(Logic.GetEntityIDByName("T"..eTID.."_Present"..gvPresent.Progress[eTID]) )
				gvPresent.Progress[eTID] = math.abs(gvPresent.Progress[eTID] - 1)
				--amount = nil
				GUIUpdate_PresentProgress_Screen(eTID)			
				gvPresent.triggerIDTable.Delivery[_TID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "gvPresent_ThiefDeliveredPresentCheck", 1,nil,{eID,pID,pos.X,pos.Y,_TID})
				gvPresent.triggerIDTable.Kill[_TID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "gvPresent_ThiefKilledCheck", 1,nil,{eID,_TID})
				ChangePlayer(Logic.GetEntityIDByName("XmasTree"..eTID),7)
				Logic.SetModelAndAnimSet(Logic.GetEntityIDByName("XmasTree"..eTID),Models.XD_Xmastree1)
				CUtil.SetEntityDisplayName(Logic.GetEntityIDByName("XmasTree"..eTID), "Weihnachtsbaum")
				--Namen des Diebes zu "Geschenke-Dieb" ändern und unselektierbar machen
				Logic.SetEntitySelectableFlag(eID, 0)
				gvPresent.CheckForSelection(eID)
				Logic.SetEntityName(eID,"XmasThief".._TID)
				MemoryManipulation.SetSettlerOverheadWidget(eID,1)
				CUtil.SetEntityDisplayName(eID, "Geschenke-Dieb")
				--[[if cnTable then
					cnTable["XmasThief".._TID] = "Geschenke-Dieb" 
				end]]
				--Dieb zu Position des eigenen Weihnachtsbaums laufen lassen
				Move("XmasThief".._TID,"XmasTree".._TID)
				--Geschenke-Diebe sind 5% langsamer
				Logic.SetSpeedFactor(eID,0.95)
				return true
			end
		end
	end
end
function gvPresent.CheckForSelection(_eID)
	if GUI.GetSelectedEntity() == _eID then
		GUI.DeselectEntity(_eID)
	else
		return
	end
end
-- Check, ob der Dieb mit geklautem Geschenk angekommen ist 
function gvPresent_ThiefDeliveredPresentCheck(_eID,_pID,_posX,_posY,_TID)
	
	local enemyTID
	local ename = Logic.GetEntityName(_eID)
	local timeline = 0
	local thiefcurrentpos = {}
	if 	_TID == 1 then
		enemyTID = 2
		XmasEnemyID = 5
		
	elseif _TID == 2 then
		enemyTID = 1
		XmasEnemyID = 6
	else
		return
	end
	-- Zeigt die Position des Diebes dem Gegnerteam alle 5 Sekunden an
	if timeline >= 5 then
		if Logic.GetDiplomacyState(GUI.GetPlayerID(),_pID) ==  Diplomacy.Hostile then
			thiefcurrentpos.X,thiefcurrentpos.Y = Logic.GetEntityPosition(eID)
			GUI.ScriptSignal(thiefcurrentpos.X, thiefcurrentpos.Y, 1)
			timeline = 0
		end
	else	
		timeline = timeline + 1
	end
	--[[ Arbeitsverweigerung wird nicht toleriert:
	wenn der Dieb stehen bleibt - aus welchen Gründen auch immer - muss künstlich nachgeholfen werden ^^ ]]
	if Logic.GetCurrentTaskList(_eID) == "TL_THIEF_IDLE" then
		Move("XmasThief".._TID,"XmasTree".._TID)
	end
	-- überprüfen, ob der Dieb bereits angekommen ist
	if Logic.IsEntityAlive(_eID) then
		if IsNear(ename,"XmasTree".._TID,500) then
			gvPresent.Progress[_TID] = gvPresent.Progress[_TID] + 1
			GUIUpdate_PresentProgress_Screen(_TID)
			newID = ReplacingEntity(ename,Entities.PU_Thief)
			Logic.SetEntityName(newID,nil)
			local presentpos = {}
			presentpos.X,presentpos.Y = Logic.GetEntityPosition(Logic.GetEntityIDByName("T".._TID.."Present"..gvPresent.Progress[_TID]))
			PresentID = Logic.CreateEntity(gvPresent.PresentTypes[Logic.GetRandom(2)+1],presentpos.X,presentpos.Y,0,0)
			Logic.SetEntityName(PresentID,"T".._TID.."_Present"..gvPresent.Progress[_TID])
			ChangePlayer(Logic.GetEntityIDByName("XmasTree"..enemyTID),XmasEnemyID)
			Logic.SetModelAndAnimSet(Logic.GetEntityIDByName("XmasTree"..enemyTID),Models.XD_Xmastree1)
			CUtil.SetEntityDisplayName(Logic.GetEntityIDByName("XmasTree"..enemyTID), "Weihnachtsbaum")
			--cnTable["XmasThief".._TID] = nil
			Trigger.UnrequestTrigger(gvPresent.triggerIDTable.Kill[_TID])
			gvPresent.triggerIDTable.Theft[_TID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,nil,"gvPresent_ThiefPresentStolenCheck", 1,nil,{_TID})
			return true
		end
	end
end
-- Check, ob der Dieb getötet wurde
function gvPresent_ThiefKilledCheck(_eID,_TID)
	local enemyTID
	if 	_TID == 1 then
		enemyTID = 2
		XmasEnemyID = 5		
	elseif _TID == 2 then
		enemyTID = 1
		XmasEnemyID = 6
	else
		return
	end
	-- überprüfen, ob der Dieb überhaupt noch am Leben ist
	if Logic.IsEntityDestroyed(_eID) then
		gvPresent.Progress[enemyTID] = math.abs(gvPresent.Progress[enemyTID] + 1)
		GUIUpdate_PresentProgress_Screen(enemyTID)
		local presentpos = {}
		presentpos.X,presentpos.Y = Logic.GetEntityPosition(Logic.GetEntityIDByName("T"..enemyTID.."Present"..gvPresent.Progress[enemyTID]))
		ePresentID = Logic.CreateEntity(gvPresent.PresentTypes[Logic.GetRandom(2)+1],presentpos.X,presentpos.Y,0,0)
		Logic.SetEntityName(ePresentID,"T"..enemyTID.."_Present"..gvPresent.Progress[enemyTID])
		ChangePlayer(Logic.GetEntityIDByName("XmasTree"..enemyTID),XmasEnemyID)
		Logic.SetModelAndAnimSet(Logic.GetEntityIDByName("XmasTree"..enemyTID),Models.XD_Xmastree1)
		CUtil.SetEntityDisplayName(Logic.GetEntityIDByName("XmasTree"..enemyTID), "Weihnachtsbaum")
		--cnTable["XmasThief".._TID] = nil
		Trigger.UnrequestTrigger(gvPresent.triggerIDTable.Delivery[_TID])
		gvPresent.triggerIDTable.Theft[_TID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,nil,"gvPresent_ThiefPresentStolenCheck", 1,nil,{_TID})
		return true
	end
end
-- Siegesbedingung, wenn ein Team alle 6 Geschenke besitzt
function gvPresent_VictoryJob()

	if gvPresent.Progress[1] == 6 then
	gvPresent.CutsceneVictorious(1)
	return true
	end
	
	if gvPresent.Progress[2] == 6 then	
	gvPresent.CutsceneVictorious(2)
	return true
	end
end
function gvPresent.CutsceneVictorious(_TID)
	Display.SetRenderFogOfWar(0)
	GUI.MiniMap_SetRenderFogOfWar(0)
	local pos
	local pname1
	local pname2
	local pcolorr1,pcolorb1,pcolorg1
	local pcolorr2,pcolorb2,pcolorg2
	local PID1,PID2
	if _TID == 1 then
		PID1 = 1
		PID2 = 2
		pos = "XmasTree1"
		pname1 = XNetwork.GameInformation_GetLogicPlayerUserName(PID1)
		pname2 = XNetwork.GameInformation_GetLogicPlayerUserName(PID2)
		pcolorr1,pcolorb1,pcolorg1 = GUI.GetPlayerColor(PID1)
		pcolorr2,pcolorb2,pcolorg2 = GUI.GetPlayerColor(PID2)
	elseif _TID == 2 then
		PID1 = 3
		PID2 = 4
		pos = "XmasTree2"
		pname1 = XNetwork.GameInformation_GetLogicPlayerUserName(PID1)
		pname2 = XNetwork.GameInformation_GetLogicPlayerUserName(PID2)
		pcolorr1,pcolorg1,pcolorb1 = GUI.GetPlayerColor(PID1)
		pcolorr2,pcolorg2,pcolorb2 = GUI.GetPlayerColor(PID2)
	end
	if Logic.GetDiplomacyState(PID1,GUI.GetPlayerID()) == Diplomacy.Friendly then
		Stream.Start("Voice\\cm01_08_barmecia_txt\\notevictory.mp3",260)
	elseif Logic.GetDiplomacyState(PID1,GUI.GetPlayerID()) == Diplomacy.Hostile then
		Stream.Start("Sounds\\VoicesMentor\\vc_yourteamhaslost_rnd_02.wav",210)
	end
	local pos1 = {Logic.GetEntityPosition(Logic.GetEntityIDByName(pos))}
	local cutsceneTable = {
    StartPosition = {
	position = pos1, angle = 18, zoom = 3700, rotation = 90},
	Flights = 	{
					{
					position = pos1,
					angle = 18,
					zoom = 3700,
					rotation = -10,
					duration = 20,
					delay = 6,
					action 	=	function()
						StartCountdown(6,GameEnding,false)
								
					end,
					title = " @color:180,0,240 Mentor",
					text = " @color:230,0,0 Herzlichen Gl\195\188ckwunsch! @color:"..pcolorr1..","..pcolorg1..","..pcolorb1.." "..pname1.." @color:255,255,255 und @color:"..pcolorr2..","..pcolorb2..","..pcolorg2.." "..pname2.." @color:255,255,255 haben diese Partie für sich entschieden!",
					},				
			
			}	
    
	}
	Startcutscene(cutsceneTable)
	
end
function GameEnding()
	if gvPresent.Progress[1] == 6 then
		Logic.PlayerSetGameStateToWon(1)
		Logic.PlayerSetGameStateToWon(2)
		Logic.PlayerSetGameStateToLost(3)
		Logic.PlayerSetGameStateToLost(4)
	
	elseif gvPresent.Progress[2] == 6 then
	
	gvPresent.CutsceneVictorious(2)
		Logic.PlayerSetGameStateToWon(3)
		Logic.PlayerSetGameStateToWon(4)
		Logic.PlayerSetGameStateToLost(1)
		Logic.PlayerSetGameStateToLost(2)
	end
end

--Sudden Death Zahltag-Faktor-Änderung (aufgerufen vom Mapscript)
function gvPresent.SDPayday()

	local pID1,pID2
	if gvPresent.Progress[1] > gvPresent.Progress[2] then 
		pID1 = 1
		pID2 = 2
	elseif gvPresent.Progress[1] < gvPresent.Progress[2] then 
		pID1 = 3
		pID2 = 4
	else
		pID1 = 1
		pID2 = 2
	end
	
	--20% höherer Zahltag-Faktor pro Geschenke-Differenz (siehe GameCallback_PaydayPayed(_player,_amount) )
	local PresentDifferenceFactor = 1+ (math.sqrt((gvPresent.Progress[1]-gvPresent.Progress[2])^2)/5)
	
	gvPresent.SDPaydayFactor[pID1] = PresentDifferenceFactor
	gvPresent.SDPaydayFactor[pID2] = PresentDifferenceFactor
	
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------ CutsceneComforts ------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function Startcutscene(_Cutscene)
	
  local length = 0
  local i
  for i = 1, table.getn(_Cutscene.Flights) do
    length = length + _Cutscene.Flights[i].duration + (_Cutscene.Flights[i].delay or 0)
  end
	gvCutscene = {
    Page      = 1,
    Flights   = _Cutscene.Flights,
    EndTime   = Logic.GetTime() + length,
    Callback  = _Cutscene.Callback,
    Music     = Music.GetVolumeAdjustment()
    } 
	cutsceneIsActive = true
	--XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("CinematicBar02"), 0, 0, 0, 0, 100)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar00"), 0)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar01"), 0)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar02"), 0)
	Logic.SetGlobalInvulnerability(1)
	Interface_SetCinematicMode(1)
	Display.SetFarClipPlaneMinAndMax(0, 33000)	-- Standard: 14000
	Music.SetVolumeAdjustment(gvCutscene.Music * 0.6)
	Sound.PlayFeedbackSound(0,0)
	GUI.SetFeedbackSoundOutputState(0)
	--Sound.StartMusic(1,1)
	LocalMusic.SongLength = 0	-- !!!
	Camera.StopCameraFlight()
	Camera.ZoomSetDistance(_Cutscene.StartPosition.zoom)
	Camera.RotSetAngle(_Cutscene.StartPosition.rotation)
	Camera.ZoomSetAngle(_Cutscene.StartPosition.angle)
	Camera.ScrollSetLookAt(_Cutscene.StartPosition.position[1],_Cutscene.StartPosition.position[2])  
	Counter.SetLimit("Cutscene", -1)
	StartSimpleJob("ControlCutscene")
end

function ControlCutscene()
  if not gvCutscene then return true end
    if Logic.GetTime() >= gvCutscene.EndTime then
		CutsceneDone()
		return true
    else
		if Counter.Tick("Cutscene") then
			local page = gvCutscene.Flights[gvCutscene.Page]
			if not page then CutsceneDone() return true end
				Camera.InitCameraFlight()
				Camera.ZoomSetDistanceFlight(page.zoom, page.duration)
				Camera.RotFlight(page.rotation, page.duration)
				Camera.ZoomSetAngleFlight(page.angle, page.duration)
				Camera.FlyToLookAt(page.position[1], page.position[2], page.duration)
			 
            if page.title ~= nil then
               PrintBriefingHeadline("@color:255,250,200 " .. page.title)
            end
			
            if page.text ~= nil then
               PrintBriefingText(page.text)
            end
			
            if page.action ~= nil then
               page.action()
            end
			
			if (page.title ~= "") or (page.text ~= "") then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar00"), 0)
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar01"), 0)
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar02"), 1)
				XGUIEng.SetWidgetPositionAndSize("CinematicBar02", 0, 2400, 3200, 160)
				XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("CinematicBar02"), 0, 0, 0, 0, 160)
			else--if (page.title == "") and (page.text == "") then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar00"), 0)
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar01"), 0)
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CinematicBar02"), 0)
			end
			
            Counter.SetLimit("Cutscene", page.duration + (page.delay or 0))
            gvCutscene.Page = gvCutscene.Page + 1
        end
    end
end

function CutsceneDone()
	if not gvCutscene then return true end
    Logic.SetGlobalInvulnerability(0)
    Interface_SetCinematicMode(0)
   XGUIEng.ShowWidget("Cinematic_Headline", 0)
   XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("CinematicBar02"), 0, 0, 0, 0, 160)	-- ?
   Display.SetFarClipPlaneMinAndMax(0, 0)
   Music.SetVolumeAdjustment(gvCutscene.Music)
    GUI.SetFeedbackSoundOutputState(1)
    if gvCutscene.Callback ~= nil then
        gvCutscene.Callback()
    end
    Counter.Cutscene = nil
    gvCutscene = nil
    cutsceneIsActive = false
end
function MovieWindow(_Title,_Text)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Movie"),1)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Cinematic_Text"),0)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MovieBarTop"),0)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MovieBarBottom"),0)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("CreditsWindowLogo"),0)
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MovieInvisibleClickCatcher"),0)
	XGUIEng.SetText(XGUIEng.GetWidgetID("CreditsWindowTextTitle"),Umlaute(_Title))
	XGUIEng.SetText(XGUIEng.GetWidgetID("CreditsWindowText"),Umlaute(_Text))
end

function CloseMovieWindow()
	XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Movie"),0)
end