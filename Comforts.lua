-- default win condition comfort override
function VC_Deathmatch()

	if XNetwork.Manager_DoesExist() == 0 then
		return
	end
	if MultiplayerTools.GameFinished == 1 then
		return
	end
	if KoopFlag == 1 then
		return
	end

	-- Get number of humen player
	local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()
	local LocalPlayer = GUI.GetPlayerID()

	-- Check loose condition: Player did loose his Headquarter
	local 	CurrentPlayerID
	for CurrentPlayerID = 1, HumenPlayer, 1
	do
		-- Check if HQ exists
		local 	ConditionFlag = 0
		local 	i
		for i= 1, table.getn(MultiplayerTools.EntityTableHeadquarters) do
			-- check all upgrades
			if ConditionFlag == 0 then
				if 	Logic.GetNumberOfEntitiesOfTypeOfPlayer(CurrentPlayerID, MultiplayerTools.EntityTableHeadquarters[i]) ~= 0 then
					ConditionFlag = 1
				end
			end
		end

		-- No headquarter exists
		if ConditionFlag == 0 then

			-- Mark player as looser
			if Logic.PlayerGetGameState(CurrentPlayerID) == 1 then

				Logic.PlayerSetGameStateToLost(CurrentPlayerID)
				MultiplayerTools.RemoveAllPlayerEntities( CurrentPlayerID )

				if LocalPlayer == CurrentPlayerID then
					GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerLostGame" ) )
					XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerLostGame" ) .. "\n"  )
				else
					local PlayerName = UserTool_GetPlayerName( CurrentPlayerID )
					GUI.AddNote( PlayerName .. XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerXLostGame" ),10 )
					XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", PlayerName .. XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerXLostGame" ) .. "\n"  )
				end

			end

		end
	end

	-- Check win condition
	for j=1, 16, 1
	do
		if MultiplayerTools.Teams[ j ] ~= nil then


			local AmountOfPlayersInTeam = table.getn(MultiplayerTools.Teams [ j ])


			-- Count player lost in team
			local AmountOfPlayersLostInTeam = 0
			do
				for k= 1,AmountOfPlayersInTeam ,1
				do
					if 		Logic.PlayerGetGameState(MultiplayerTools.Teams [ j ] [ k ]) == 3
						or	Logic.PlayerGetGameState(MultiplayerTools.Teams [ j ] [ k ]) == 4
				  	then
						AmountOfPlayersLostInTeam = AmountOfPlayersLostInTeam + 1
					end
				end
			end

			do

				--Set lost teams
				if AmountOfPlayersLostInTeam == AmountOfPlayersInTeam then

					-- Team has lost!!!

					if MultiplayerTools.TeamLostTable[ j ] == nil
					or MultiplayerTools.TeamLostTable[ j ] == 0 then


						-- Has the team more that 1 player -- ThHa: must print even for 1 player opponent teams...
						if true then -- AmountOfPlayersInTeam > 1 then
							for k= 1,AmountOfPlayersInTeam ,1
							do
								if LocalPlayer == MultiplayerTools.Teams [ j ] [ k ] then
									GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerTeamLost" ) )
									XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerTeamLost" .. "\n" ) )
								else
									GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_TeamX" )  .. j .. XGUIEng.GetStringTableText( "InGameMessages/Note_TeamXHasLostGame" ))
									XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", XGUIEng.GetStringTableText( "InGameMessages/Note_TeamX" )  .. j .. XGUIEng.GetStringTableText( "InGameMessages/Note_TeamXHasLostGame" ) .. "\n"  )
								end
							end

						end

						MultiplayerTools.TeamLostTable[ j ] = 1
						MultiplayerTools.AmountOfLooserTeams = MultiplayerTools.AmountOfLooserTeams + 1

					end

				end

				if MultiplayerTools.AmountOfLooserTeams  > 0 then

					local NumberOfTeams = MultiplayerTools.TeamCounter

					--only one team is left:mark players as winner
					if MultiplayerTools.AmountOfLooserTeams == ( NumberOfTeams - 1) then

						for TempPlayerID = 1, HumenPlayer, 1
						do
							if Logic.PlayerGetGameState(TempPlayerID) == 1 then
								Logic.PlayerSetGameStateToWon(TempPlayerID)
							end
						end

						MultiplayerTools.GameFinished = 1

					end
				end

			end

		end

	end

end

gvBriefingStopLeaderMovementsIgnoreETypesList = {[Entities.PU_Forester] = true, [Entities.PU_WoodCutter] = true}
-- briefing function override, so player military units can't move during briefings to get tactical advantages
---@param _briefing table briefingData
PrepareBriefing = function(_briefing)

	-- stop humen players leaders from moving
	local player = GetAllHumenPlayer()
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(player)), CEntityIterator.IsSettlerFilter(), CEntityIterator.OfAnyCategoryFilter(EntityCategories.Leader, EntityCategories.Hero)) do
		if Logic.IsEntityAlive(eID) and Logic.IsEntityMoving(eID) and not string.find(Logic.GetCurrentTaskList(eID), "TRAIN") and not string.find(Logic.GetCurrentTaskList(eID), "LEAVE") then
			-- ignore this for forester and woodcutter (no workers due to technical issues)
			if not gvBriefingStopLeaderMovementsIgnoreETypesList[Logic.GetEntityType(eID)] then
				Logic.GroupDefend(eID)
			end
		end
	end
	local num, id = Logic.GetEntities(Entities.PB_Dome, 1)
	if num > 0 and Logic.IsConstructionComplete(id) == 1 then
	-- dome is finished, timer runs: add some extra time when triggering a briefing
		for i = 1,999 do
			if Counter["counter"..i] then
				if Counter["counter"..i].Show then
					Counter["counter"..i].Limit = Counter["counter"..i].Limit + 180
					break
				end
			end
		end
	end
	--	prepare camera
	GUIAction_GoBackFromHawkViewInNormalView()
	Interface_SetCinematicMode(1)
	Camera.StopCameraFlight()
	Camera.ScrollUpdateZMode(0)
	Camera.RotSetAngle(-45)
	-- toggle FoW
	Display.SetRenderFogOfWar(0)
	GUI.MiniMap_SetRenderFogOfWar(0)
	--	sound
	--	backup
	briefingState.Effect = Sound.GetVolumeAdjustment(3)
	briefingState.Ambient = Sound.GetVolumeAdjustment(5)
	briefingState.Music = Music.GetVolumeAdjustment()
	--	half volume
	Sound.SetVolumeAdjustment(3, briefingState.Effect * 0.5)
	Sound.SetVolumeAdjustment(5, briefingState.Ambient * 0.5)
	Music.SetVolumeAdjustment(briefingState.Music * 0.5)
	--	stop feedback sounds
	Sound.PlayFeedbackSound(0,0)
	--	enable cutscene key mode
	Input.CutsceneMode()
	--	forbid feedback sounds
	GUI.SetFeedbackSoundOutputState(0)
	--start briefing music
	LocalMusic.SongLength = 0
	XGUIEng.ShowWidget("CinematicMiniMapContainer",1)

end
-------------------------------------------------------------------------------------------------------
------------------------------- Pages briefing comfort ------------------------------------------------
-------------------------------------------------------------------------------------------------------
---@param _briefing table briefingData
---@return table briefingData
function AddPages(_briefing)
    local AP = function(_page)
		table.insert(_briefing, _page)
		return _page
	end
    local ASP = function(_entity, _title, _text, _dialog, _explore)
		return AP(CreateShortPage(_entity, _title, _text, _dialog, _explore))
	end
    return AP, ASP
end
--**
-- function to create short pages
---@param _entity string|entityID entityName or entityID
---@param _title string pageTitle
---@param _text string pageText
---@param _dialog boolean CameraZoom
---@param _explore number ExploreArea
---@return table pageData
function CreateShortPage(_entity, _title, _text, _dialog, _explore)
    local page = {
        title = _title,
        text = _text,
        position = GetPosition(_entity),
		action = function()
		end
    }
    if _dialog then
		if type(_dialog) == "boolean" then
			page.dialogCamera = true
		elseif type(_dialog) == "number" then
			page.explore = _dialog
		end
      end
    if _explore then
		if type(_explore) == "boolean" then
			page.dialogCamera = true
		elseif type(_explore) == "number" then
			page.explore = _explore
		end
    end
    return page
end
function ActivateBriefingsExpansion()
    if not unpack{true} then
        local unpack2
        unpack2 = function(_table, i)
			i = i or 1
			assert(type(_table) == "table")
			if i <= table.getn(_table) then
				return _table[i], unpack2(_table, i)
			end
		end
        unpack = unpack2
    end

    Briefing_ExtraOrig = Briefing_Extra

    Briefing_Extra = function(_v1, _v2)
		for i = 1, 2 do
			local theButton = "CinematicMC_Button" .. i
			XGUIEng.DisableButton(theButton, 1)
			XGUIEng.DisableButton(theButton, 0)
		end

		if _v1.action then
			assert(type(_v1.action) == "function")
			if type(_v1.parameters) == "table" then
				_v1.action(unpack(_v1.parameters))
			else
				_v1.action(_v1.parameters)
			end
		end

    Briefing_ExtraOrig(_v1, _v2)
	end

end

-- override cutscene comfort
---@param _Name string CutsceneName, must be defined in cutscenes.xml in data/externalmap
---@param _Callback function Called when cutscene is done
StartCutscene = function(_Name, _Callback)

	GameCallback_EscapeOrig = GameCallback_Escape
	GameCallback_Escape = function() end
	-- Remember callback
	CutsceneCallback = _Callback
	-- Invulnerability for all entities
	Logic.SetGlobalInvulnerability(1)
	--	forbid feedback sounds
	GUI.SetFeedbackSoundOutputState(0)
	-- no shapes during cutscene
	Display.SetProgramOptionRenderOcclusionEffect(0)
	-- cutscene input mode
	Input.CutsceneMode()
	-- Start cutscene
	Cutscene.Start(_Name)
	assert(cutsceneIsActive ~= true, "another cutscene is already/still active")
	cutsceneIsActive = true
	LocalMusic_UpdateMusic()
	--	backup
	Cutscene.Effect = Sound.GetVolumeAdjustment(3)
	Cutscene.Ambient = Sound.GetVolumeAdjustment(5)
	Cutscene.Music = Music.GetVolumeAdjustment()
	--	half volume
	Sound.SetVolumeAdjustment(3, Cutscene.Effect * 0.5)
	Sound.SetVolumeAdjustment(5, Cutscene.Ambient * 0.5)
	Music.SetVolumeAdjustment(Cutscene.Music * 0.5)
	--	stop feedback sounds
	Sound.PlayFeedbackSound(0,0)
end
CutsceneDone = function()

	GameCallback_Escape = GameCallback_EscapeOrig
	-- Vulnerability for all entities
	Logic.SetGlobalInvulnerability(0)
	--	allow feedback sounds
	GUI.SetFeedbackSoundOutputState(1)
	-- show shapes after cutscene
	Display.SetProgramOptionRenderOcclusionEffect(1)
	-- game input mode
	Input.GameMode()
	--	full volume
	Sound.SetVolumeAdjustment(3, Cutscene.Effect)
	Sound.SetVolumeAdjustment(5, Cutscene.Ambient)
	Music.SetVolumeAdjustment(Cutscene.Music)
	--	stop speech
	Stream.Stop()
	cutsceneIsActive = false
	-- Back to game control
	if CutsceneCallback ~= nil then
		CutsceneCallback()
	end

end

-- get difficulty string to translate diff lvl (sp campaign) to shown string
---@param _lvl integer
---@return string
DiffLVLToString = function(_lvl)
	if _lvl == 1 then
		return "Schwer"
	elseif _lvl == 2 then
		return "Normal"
	else
		return "Leicht"
	end
end

-- returns number of human playing player, in SP always 1
---@return integer
function GetNumberOfPlayingHumanPlayer()

	if not CNetwork then
		return 1
	end

	local count = 0

	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) ~= 0 then
			count = count + 1
		end
	end

	return count

end
-- player name override to show name in statistics
gvPlayerName = gvPlayerName or {}
-- sets playerName into the GUI
---@param _playerId integer playerID
---@param _name string playerName
function SetPlayerName(_playerId, _name)

	local name = XGUIEng.GetStringTableText(_name)

	if name == nil then
		Logic.SetPlayerRawName(_playerId, _name)
	else
		Logic.SetPlayerName(_playerId, _name)
	end

	gvPlayerName[_playerId] = _name

end

SetPlayerColorMappingOrig = Display.SetPlayerColorMapping
function Display.SetPlayerColorMapping(_player, _colorID)
	SetPlayerColorMappingOrig(_player, _colorID)
	Logic.PlayerSetPlayerColor(_player, GUI.GetPlayerColor(_player))
end

-- returns if a value is found inside an array or not
---@param _wert any value to search
---@param _table array to search within
---@return boolean
function IstDrin(_wert, _table)

	for i = 1, table.getn(_table) do
		if _table[i] == _wert then
			return true
		end
	end

	return false

end

-- find numeric indexed table holes
-- returns table with holes indexes or, if no holes were found, false
---@param _t table table of any iteration
---@return table table filled with table holes
function table_findholes(_t)
	assert(type(_t) == "table", "input type must be a table")
	local last, holes = nil, {}
	for k, _ in pairs(_t) do
		if k ~= 1 and not next(holes) then
			for i = 1, k - 1 do
				table.insert(holes, i)
			end
		else
			if last and last + 1 ~= k then
				for i = last, k - 1 do
					table.insert(holes, i)
				end
			end
		end
		last = k
	end

	if next(holes) then
		return holes
	end
	return false
end

-- returns position of value in table, or if not found 0
---@param _tid table table of any iteration
---@param _value any
---@return integer|0 table position
function table_findvalue(_tid, _value)

	local tpos

	if type(_value) ~= "table" then
		for i,val in pairs(_tid) do
			if type(val) == "table" then
				for k, v in pairs(val) do
					if v == _value then
						tpos = k
						break
					end
				end
			else
				if val == _value then
					tpos = i
					break
				end
			end
		end

	elseif type(_value) == "table" then
		if type(_tid[1]) == "table" then
			if _tid[1].X and _tid[1].Y then
				for i,_ in pairs(_tid) do
					if _tid[i].X == _value.X and _tid[i].Y == _value.Y then
						tpos = i
						break
					end
				end

			else

				for i,_ in pairs(_tid) do
					for k,_ in pairs(_tid[i]) do
						if _tid[i][k] == _value then
							tpos = i
							break
						end
					end
				end

			end

		else

			for i,_ in pairs(_tid) do
				if _tid[i] == _value then
					tpos = i
					break
				end
			end

		end

	end

	return tpos or 0

end

-- remove table entry by value (in case you don't know the position in table)
---@param _tid table table of any iteration
---@param _key string|number|table
---@return string|number|table
function removetablekeyvalue(_tid, _key)

	local tpos

	if type(_key) == "string" then
		for i,_ in pairs(_tid) do
			if string.find(_tid[i],_key) ~= nil then
				tpos = i
				break
			end
		end

	elseif type(_key) == "number" then
		for i,_ in pairs(_tid) do
			if _tid[i] == _key then
				tpos = i
				break
			end
		end

	elseif type(_key) == "table" then
		if type(_tid[1]) == "table" then
			if _tid[1].X and _tid[1].Y then
				for i,_ in pairs(_tid) do
					if _tid[i].X == _key.X and _tid[i].Y == _key.Y then
						tpos = i
						break
					end
				end

			else

				for i,_ in pairs(_tid) do
					for k,_ in pairs(_tid[i]) do
						if _tid[i][k] == _key then
							tpos = i
							break
						end
					end
				end
			end

		else

			for i,_ in pairs(_tid) do
				if _tid[i] == _key then
					tpos = i
					break
				end
			end

		end

	else
		return
	end

	table.remove(_tid,tpos)
    return _key

end
-------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- MP Key Sounds added -----------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
function BonusKeys()

	Input.KeyBindDown(Keys.ModifierControl + Keys.NumPad9, "ExtraTaunt(GUI.GetPlayerID(),1)", 2) --funny comments
	Input.KeyBindDown(Keys.ModifierControl + Keys.Y, "ExtraTaunt(GUI.GetPlayerID(),2)", 2) --verloren
	Input.KeyBindDown(Keys.ModifierControl + Keys.X, "ExtraTaunt(GUI.GetPlayerID(),3)", 2) --verloren
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad0, "ExtraTaunt(GUI.GetPlayerID(),4)", 2) --schlechter Spielstil
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad1, "ExtraTaunt(GUI.GetPlayerID(),5)", 2) --Yippih
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad2, "ExtraTaunt(GUI.GetPlayerID(),6)", 2) --funny comment worker
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad3, "ExtraTaunt(GUI.GetPlayerID(),7)", 2) --funny comment varg
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad4, "ExtraTaunt(GUI.GetPlayerID(),8)", 2) --funny comment mary
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad5, "ExtraTaunt(GUI.GetPlayerID(),9)", 2) --funny comment kerberos
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad6, "ExtraTaunt(GUI.GetPlayerID(),10)", 2) --funny comment helias
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad7, "ExtraTaunt(GUI.GetPlayerID(),11)", 2) --funny comment ari
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad8, "ExtraTaunt(GUI.GetPlayerID(),12)", 2) --funny comment erec
	Input.KeyBindDown(Keys.ModifierAlt + Keys.NumPad9, "ExtraTaunt(GUI.GetPlayerID(),13)", 2) --funny comment salim
	Input.KeyBindDown(Keys.ModifierAlt + Keys.D1, "ExtraTaunt(GUI.GetPlayerID(),14)", 2) --funny comment pilgrim
	Input.KeyBindDown(Keys.ModifierAlt + Keys.D2, "ExtraTaunt(GUI.GetPlayerID(),15)", 2) --funny comment dario
	Input.KeyBindDown(Keys.ModifierAlt + Keys.D3, "ExtraTaunt(GUI.GetPlayerID(),16)", 2) --funny comment drake
	Input.KeyBindDown(Keys.ModifierAlt + Keys.D4, "ExtraTaunt(GUI.GetPlayerID(),17)", 2) --funny comment yuki
	Input.KeyBindDown(Keys.ModifierAlt + Keys.D5, "ExtraTaunt(GUI.GetPlayerID(),18)", 2) --funny comment kala
	Input.KeyBindDown(Keys.ModifierAlt + Keys.C, "ExtraTaunt(GUI.GetPlayerID(),999)", 2) --Sonderabgaben

end
function ExtraTaunt(_SenderPlayerID,_key)

	if _SenderPlayerID ~= -1 then

		local UserName = XNetwork.GameInformation_GetLogicPlayerUserName( _SenderPlayerID )
		local ColorR, ColorG, ColorB = GUI.GetPlayerColor( _SenderPlayerID )
    	local PreMessage = "@color:" .. ColorR .. "," .. ColorG .. "," .. ColorB .. " " .. UserName .. " @color:255,255,255 > "

		if _key == 1 then
			Sound.PlayGUISound( Sounds.VoicesMentor_MP_TauntFunny05,127)
			local Message = PreMessage .. "Psst, Du...ja, genau Du. Dein Haus brennt!"
			XNetwork.Chat_SendMessageToAll( Message )

		elseif _key == 2 then
			Sound.PlayGUISound(Sounds.VoicesMentor_VC_YouHaveLost_rnd_01,127)
			local Message = PreMessage .. "Ihr habt verloren!"
			XNetwork.Chat_SendMessageToAll( Message )

		elseif _key == 3 then
			Sound.PlayGUISound(Sounds.VoicesMentor_VC_YourTeamHasLost_rnd_01,127)
			local Message = PreMessage .. "Euer Team hat verloren!"
			XNetwork.Chat_SendMessageToAll( Message )

		elseif _key == 4 then
			Sound.PlayGUISound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_01,127)
			local Message = PreMessage .. "Euer Spiel ist miserabel!"
			XNetwork.Chat_SendMessageToAll( Message )

		elseif _key == 5 then
			Sound.PlayGUISound(Sounds.Misc_Chat2,127)
			local Message = PreMessage .. "yippie!"
			XNetwork.Chat_SendMessageToAll( Message )

		elseif _key == 6 then
			Sound.PlayGUISound(Sounds.VoicesWorker_WORKER_FunnyComment_rnd_01,127)

		elseif _key == 7 then
			Sound.PlayGUISound(Sounds.VoicesHero9_HERO9_FunnyComment_rnd_01,127)

		elseif _key == 8 then
			Sound.PlayGUISound(Sounds.VoicesHero8_HERO8_FunnyComment_rnd_01,127)

		elseif _key == 9 then
			Sound.PlayGUISound(Sounds.VoicesHero7_HERO7_FunnyComment_rnd_01,127)

		elseif _key == 10 then
			Sound.PlayGUISound(Sounds.VoicesHero6_HERO6_FunnyComment_rnd_01,127)

		elseif _key == 11 then
			Sound.PlayGUISound(Sounds.VoicesHero5_HERO5_FunnyComment_rnd_01,127)

		elseif _key == 12 then
			Sound.PlayGUISound(Sounds.VoicesHero4_HERO4_FunnyComment_rnd_01,127)

		elseif _key == 13 then
			Sound.PlayGUISound(Sounds.VoicesHero3_HERO3_FunnyComment_rnd_01,127)

		elseif _key == 14 then
			Sound.PlayGUISound(Sounds.VoicesHero2_HERO2_FunnyComment_rnd_01,127)

		elseif _key == 15 then
			Sound.PlayGUISound(Sounds.VoicesHero1_HERO1_FunnyComment_rnd_01,127)

		elseif _key == 16 then
			Sound.PlayGUISound(Sounds.AOVoicesHero10_HERO10_FunnyComment_rnd_01,127)

		elseif _key == 17 then
			Sound.PlayGUISound(Sounds.AOVoicesHero11_HERO11_FunnyComment_rnd_01,127)

		elseif _key == 18 then
			Sound.PlayGUISound(Sounds.AOVoicesHero12_HERO12_FunnyComment_rnd_01,127)

		elseif _key == 999 then
			Sound.PlayGUISound(Sounds.VoicesMentorHelp_ACTION_ExtraDuties,127)
			local Message = PreMessage .. "Hinweise zu Sonderabgaben!"
			XNetwork.Chat_SendMessageToAll( Message )
		end

	end

end

-------------------------------------------------------------------------------------------------------
--------------------------- Misc Comforts -------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- author:Flodder
-- Berechnet einen winkel zwischen 2 positionen
---@param _Pos1 integer|string|table entityID or entityName or positionTable
---@param _Pos2 integer|string|table entityID or entityName or positionTable
---@return number angle
function GetAngleBetween(_Pos1,_Pos2)
	local delta_X = 0
	local delta_Y = 0
	local alpha   = 0
	if type (_Pos1) == "string" or type (_Pos1) == "number" then
		_Pos1 = GetPosition(GetEntityId(_Pos1))
	end
	if type (_Pos2) == "string" or type (_Pos2) == "number" then
		_Pos2 = GetPosition(GetEntityId(_Pos2))
	end
	delta_X = _Pos1.X - _Pos2.X
	delta_Y = _Pos1.Y - _Pos2.Y
	if delta_X == 0 and delta_Y == 0 then
		return 0
	end
	alpha = math.deg(math.asin(math.abs(delta_X)/(math.sqrt(__pow(delta_X, 2)+__pow(delta_Y, 2)))))
	if delta_X >= 0 and delta_Y > 0 then
		alpha = 270 - alpha
	elseif delta_X < 0 and delta_Y > 0 then
		alpha = 270 + alpha
	elseif delta_X < 0 and delta_Y <= 0 then
		alpha = 90  - alpha
	elseif delta_X >= 0 and delta_Y <= 0 then
		alpha = 90  + alpha
	end
	return alpha
end

-------------------------------------------------------------------------------------------------------
-- Wood piles -----------------------------------------------------------------------------------------
---@param _posEntity string|integer entityName or entityID
---@param _resources integer NumResources
function CreateWoodPile(_posEntity, _resources)

    assert(type(_posEntity) == "string" or (type(_posEntity) == "number" and _posEntity > 0), "invalid entity param, needs to be either an entity ID or entity scripting name")
    assert(type(_resources) == "number", "invalid resource amount")
    gvWoodPiles = gvWoodPiles or {
        JobID = StartSimpleJob("ControlWoodPiles"),
    }
    local pos = {}
	pos.X,pos.Y = Logic.GetEntityPosition(Logic.GetEntityIDByName(_posEntity))
    local pile_id = Logic.CreateEntity( Entities.XD_Rock3, pos.X, pos.Y, 0, 0 )
    SetEntityName( pile_id, _posEntity.."_WoodPile" )
    local newE = ReplacingEntity( _posEntity, Entities.XD_ResourceTree )
	Logic.SetModelAndAnimSet(newE, Models.XD_SignalFire1)
    Logic.SetResourceDoodadGoodAmount( GetEntityId( _posEntity ), _resources*10 )
	Logic.SetModelAndAnimSet(pile_id, Models.Effects_XF_ChopTree)
    table.insert( gvWoodPiles, { ResourceEntity = _posEntity, PileEntity = _posEntity.."_WoodPile", ResourceLimit = _resources*9 } )

end

function ControlWoodPiles()

    for i = table.getn( gvWoodPiles ),1,-1 do
        if Logic.GetResourceDoodadGoodAmount( GetEntityId( gvWoodPiles[i].ResourceEntity ) ) <= gvWoodPiles[i].ResourceLimit then
            DestroyWoodPile( gvWoodPiles[i], i )
        end
    end

end

function DestroyWoodPile( _piletable, _index )

    local pos = GetPosition( _piletable.ResourceEntity )
    DestroyEntity( _piletable.ResourceEntity )
    DestroyEntity( _piletable.PileEntity )
    Logic.CreateEffect( GGL_Effects.FXCrushBuilding, pos.X, pos.Y, 0 )
    table.remove( gvWoodPiles, _index )

end
---------------------------------------------------------------------------------------------------------
-- ReplaceEntity comfort, pretty much only different name given ---------------------------------------
---@param _Entity string|integer entityName or entityID
---@param _EntityType integer entityType
---@return integer entityID
function ReplacingEntity(_Entity, _EntityType)

	local entityId      = Logic.GetEntityIDByName(_Entity)
	local pos 			= {}
	pos.X,pos.Y  		= Logic.GetEntityPosition(entityId)
	local name 			= Logic.GetEntityName(entityId)
	local player 		= Logic.EntityGetPlayer(entityId)
	local orientation 	= Logic.GetEntityOrientation(entityId)
	local wasSelected	= IsEntitySelected(_Entity)

	if wasSelected then
		GUI.DeselectEntity(entityId)
    end

	DestroyEntity(_Entity)
	local newEntityId = Logic.CreateEntity(_EntityType,pos.X,pos.Y,orientation,player)
	Logic.SetEntityName(newEntityId, name)

	if wasSelected then
		GUI.SelectEntity(newEntityId)
    end

	GroupSelection_EntityIDChanged(entityId, newEntityId)
	return newEntityId

end

-- activating exploration between two players comfort, param _both optional
---@param _player1 integer playerID
---@param _player2 integer playerID
---@param _both boolean?
function ActivateShareExploration(_player1, _player2, _both)

    assert(type(_player1) == "number" and type(_player2) == "number" and _player1 <= 16 and _player2 <= 16 and _player1 >= 1 and _player2 >= 1, "invalid player IDs input")

    if _both == false then
        Logic.SetShareExplorationWithPlayerFlag(_player1, _player2, 1)
    else
        Logic.SetShareExplorationWithPlayerFlag(_player1, _player2, 1)
        Logic.SetShareExplorationWithPlayerFlag(_player2, _player1, 1)
    end

end

-- comfort to check if an entityID is really a military leader (e.g. not a hero or top of a tower)
---@param _entityID integer entityID
---@return boolean
function IsMilitaryLeader(_entityID)

	return Logic.IsHero(_entityID) == 0 and Logic.IsSerf(_entityID) == 0 and Logic.IsEntityInCategory(_entityID, EntityCategories.Soldier) == 0 and Logic.IsBuilding(_entityID) == 0 and Logic.IsWorker(_entityID) == 0 and string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(_entityID))), "soldier") == nil and Logic.IsLeader(_entityID) == 1 and Logic.IsEntityInCategory(_entityID, EntityCategories.MilitaryBuilding) == 0

end

-- Gets current health percentage of entityID
---@param _entity integer entityID
---@return number percentage health
function GetEntityHealth(_entity)

	local entityID

	if type(_entity) ~= "number" then
		entityID = Logic.GetEntityIDByName(_entity)
	else
		entityID = _entity
	end

    if not Tools.IsEntityAlive( entityID ) then
        return 0
    end

    local MaxHealth = Logic.GetEntityMaxHealth( entityID )
    local Health = Logic.GetEntityHealth( entityID )
    return ( Health / MaxHealth ) * 100

end

-- comfort to generate random value with defined step offset
---@param _min number lower limit
---@param _max number upper limit
---@param _step number offset for steps
---@return number
function GenerateRandomWithSteps(_min, _max, _step)
	local steps = math.ceil((_max - _min) / _step)
	local rand = math.random(0, steps)
	return _min + rand * _step
end

-- function to get nearest other entityID of same entityType
---@param _x number	positionX
---@param _y number positionY
---@param _entityType integer entityType
---@return integer
function GetNearestEntityOfType(_x, _y, _entityType)
	local range = Logic.WorldGetSize()
	local num, id = Logic.GetEntitiesInArea(_entityType, _x, _y, range, 1)
	return id
end

-- function to get the nearest entity of bridge category
---@param _x number	positionX
---@param _y number positionY
---@param _range number? search range (optional, default: map size)
---@return integer
function GetNearestBridge(_x, _y, _range)

	local bt = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfCategoryFilter(EntityCategories.Bridge), CEntityIterator.InCircleFilter(_x, _y, _range or Logic.WorldGetSize())) do
		table.insert(bt, {id = eID, dist = GetDistance(eID, {X = _x, Y = _y})})
	end
	table.sort(bt, function(p1, p2)
		return p1.dist < p2.dist
	end)
	return (bt[1] and bt[1].id)
end

-- comfort to evaluate if number of entities of given playerID are in range of given Position
---@param _player integer playerID
---@param _entityType integer entityType
---@param _position table positionTable
---@param _range number search range
---@param _amount integer needed amount of entities
---@return boolean
function AreEntitiesInArea(_player, _entityType, _position, _range, _amount)

	local sector = CUtil.GetSector(_position.X /100, _position.Y /100)
	if sector == 0 then
		sector = EvaluateNearestUnblockedSector(_position.X, _position.Y, 1000, 100)
	end
	local Count = 0
	if type(_entityType) == "number" then
		if _entityType > 0 then
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfTypeFilter(_entityType), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
				if Logic.GetSector(id) == sector then
					if Logic.IsBuilding(id) == 1 then
						if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
							Count = Count + 1
						end

					elseif Logic.IsHero(id) == 1 then
						if Logic.IsEntityAlive(id) then
							Count = Count + 1
						end
					end
				end
				if Count >= _amount then
					break
				end
			end
		else
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.IsSettlerOrBuildingFilter(), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
				if Logic.GetSector(id) == sector then
					if Logic.IsBuilding(id) == 1 then
						if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
							Count = Count + 1
						end

					elseif Logic.IsHero(id) == 1 then
						if Logic.IsEntityAlive(id) then
							Count = Count + 1
						end
					else
						if not string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(id))), "xd") and not string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(id))), "xs") then
							Count = Count + 1
						end
					end
				end
				if Count >= _amount then
					break
				end
			end
		end
	elseif type(_entityType) == "table" then
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyTypeFilter(unpack(_entityType)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
			if Logic.GetSector(id) == sector then
				if Logic.IsBuilding(id) == 1 then
					if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
						Count = Count + 1
					end

				elseif Logic.IsHero(id) == 1 then
					if Logic.IsEntityAlive(id) then
						Count = Count + 1
					end
				end
			end
			if Count >= _amount then
				break
			end
		end
	end

	return Count >= _amount

end

-- Comfort to evaluate if entities of given player and diplomacy state are in range of given position
---@param _player integer playerID
---@param _position table positionTable
---@param _range number search range
---@param _state integer DiplomacyState
---@return boolean
function AreEntitiesOfDiplomacyStateInArea(_player, _position, _range, _state)

	local maxplayers = 8
	if CNetwork then
		maxplayers = 16
	end
	local flag = false
	for i = 1, maxplayers do
		if Logic.GetDiplomacyState(_player, i) == _state then
			flag = AreEntitiesInArea(i, 0, _position, _range, 1)
			if flag then
				return true
			end
		end
	end

	return false

end

-- Comfort to evaluate if entities of given player, entity categories and diplomacy state are in range of given position
---@param _player integer playerID
---@param _entityCategories table entityCategories
---@param _position table positionTable
---@param _range number search range
---@param _state integer DiplomacyState
---@return boolean
function AreEntitiesOfCategoriesAndDiplomacyStateInArea(_player, _entityCategories, _position, _range, _state)

	assert(type(_entityCategories) == "table", "entityCategories param must be a table")
	local i

	if CNetwork then
		i = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()
	else
		i = 8
	end
	local bool
	for i = 1,i do
		if Logic.GetDiplomacyState( _player, i) == _state then
			bool = AreEntitiesOfTypeAndCategoryInArea(i, 0, _entityCategories, _position, _range, 1)
			if bool then
				return true
			end

		end
	end

	return false

end

-- Comfort to evaluate if entities of given player, entity categories or entity types and diplomacy state are in range of given position
---@param _player integer playerID
---@param _entityTypes table|integer entityType(s)
---@param _entityCategories table|integer entityCategories
---@param _position table positionTable
---@param _range number search range
---@param _amount integer needed amount of entities
---@return boolean
function AreEntitiesOfTypeAndCategoryInArea(_player, _entityTypes, _entityCategories, _position, _range, _amount)

	local sector = CUtil.GetSector(_position.X /100, _position.Y /100)
	if sector == 0 then
		sector = EvaluateNearestUnblockedSector(_position.X, _position.Y, 1000, 100)
	end
	local Count = 0
	if type(_entityTypes) == "number" and _entityTypes > 0 then
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfTypeFilter(_entityTypes), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
			if Logic.GetSector(id) == sector then
				if Logic.IsBuilding(id) == 1 then
					if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
						Count = Count + 1
					end

				elseif Logic.IsHero(id) == 1 then
					if Logic.IsEntityAlive(id) then
						Count = Count + 1
					end
				end
			end
			if Count >= _amount then
				break
			end
		end
	elseif type(_entityTypes) == "table" then
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyTypeFilter(unpack(_entityTypes)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
			if Logic.GetSector(id) == sector then
				if Logic.IsBuilding(id) == 1 then
					if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
						Count = Count + 1
					end

				elseif Logic.IsHero(id) == 1 then
					if Logic.IsEntityAlive(id) then
						Count = Count + 1
					end
				end
			end
			if Count >= _amount then
				break
			end
		end
	elseif type(_entityCategories) == "number" then
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfCategoryFilter(_entityCategories), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
			if Logic.GetSector(id) == sector then
				if Logic.IsBuilding(id) == 1 then
					if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
						Count = Count + 1
					end

				elseif Logic.IsHero(id) == 1 then
					if Logic.IsEntityAlive(id) then
						Count = Count + 1
					end
				else
					if not string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(id))), "xd") and not string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(id))), "xs") then
						Count = Count + 1
					end
				end
			end
			if Count >= _amount then
				break
			end
		end
	elseif type(_entityCategories) == "table" then
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyCategoryFilter(unpack(_entityCategories)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
			if Logic.GetSector(id) == sector then
				if Logic.IsBuilding(id) == 1 then
					if Logic.IsConstructionComplete(id) == 1 and not IsInappropiateBuilding(id) and Logic.IsEntityInCategory(id, EntityCategories.Wall) == 0 then
						Count = Count + 1
					end

				elseif Logic.IsHero(id) == 1 then
					if Logic.IsEntityAlive(id) then
						Count = Count + 1
					end
				else
					if not string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(id))), "xd") and not string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(id))), "xs") then
						Count = Count + 1
					end
				end
			end
			if Count >= _amount then
				break
			end
		end
	end

	return Count >= _amount

end

-- Comfort to evaluate if any building of given player is in range of given position
---@param _player integer playerID
---@param _x number positionX
---@param _y number positionY
---@param _range number search range
---@return boolean
function ArePlayerBuildingsInArea(_player, _x, _y, _range)
	local count = 0
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.IsBuildingFilter(), CEntityIterator.InCircleFilter(_x, _y, _range)) do
		if Logic.IsConstructionComplete(eID) == 1 then
			count = count + 1
			break
		end
	end
	return count > 0
end

-- Comfort to evaluate if wounded settler are near a given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@param _treshold number percentage health below units count as wounded
---@param _diplstate string? optional, default: check for allied units
---@return table entity IDs
function AreWoundedEntitiesNearby(_player, _ecats, _position, _range, _treshold, _diplstate)
	local PIDs = {}
	if not _diplstate or _diplstate == "Allies" then
		PIDs = BS.GetAllAlliedPlayerIDs(_player)
	end
	local t = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(_player, unpack(PIDs)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.OfAnyCategoryFilter(unpack(_ecats))) do
		if GetEntityHealth(eID) < _treshold then
			return true
		end
	end
	return false
end

-- Comfort to get all entities friendly to given playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return table entity IDs
function GetAlliesInRange(_player, _ecats, _position, _range)
	assert(type(_player) == "number" and _player > 0 and _player < 17, "invalid player ID")
	assert(type(_ecats) == "table", "entity categories param must be a table")
	assert(type(_position) == "table" and _position.X and _position.Y, "position param must be a table")
	assert(type(_range) == "number" and _range > 0, "invalid range")
	local allies = BS.GetAllAlliedPlayerIDs(_player)
	local t = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(_player, unpack(allies)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.OfAnyCategoryFilter(unpack(_ecats))) do
		table.insert(t, eID)
	end
	return t
end

-- Comfort to get the amount of entities friendly to given playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return integer
function GetNumberOfAlliesInRange(_player, _ecats, _position, _range)
	local t = GetAlliesInRange(_player, _ecats, _position, _range)
	if t and next(t) then
		return table.getn(t)
	end
	return 0
end

-- Comfort to get all entities hostile to given playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return table entity IDs
function GetEnemiesInRange(_player, _ecats, _position, _range)
	assert(type(_player) == "number" and _player > 0 and _player < 17, "invalid player ID")
	assert(type(_ecats) == "table", "entity categories param must be a table")
	assert(type(_position) == "table" and _position.X and _position.Y, "position param must be a table")
	assert(type(_range) == "number" and _range > 0, "invalid range")
	local enemies = BS.GetAllEnemyPlayerIDs(_player)
	local t = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(enemies)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.OfAnyCategoryFilter(unpack(_ecats))) do
		table.insert(t, eID)
	end
	return t
end

-- Comfort to get all positions of entities hostile to given playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return table entity IDs
function GetEnemiesPositionTableInRange(_player, _ecats, _position, _range)
	assert(type(_player) == "number" and _player > 0 and _player < 17, "invalid player ID")
	assert(type(_ecats) == "table", "entity categories param must be a table")
	assert(type(_position) == "table" and _position.X and _position.Y, "position param must be a table")
	assert(type(_range) == "number" and _range > 0, "invalid range")
	local enemies = BS.GetAllEnemyPlayerIDs(_player)
	local t = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(enemies)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.OfAnyCategoryFilter(unpack(_ecats))) do
		table.insert(t, GetPosition(eID))
	end
	return t
end

-- Comfort to get the amount of entities hostile to given playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return integer
function GetNumberOfEnemiesInRange(_player, _ecats, _position, _range)
	local t = GetEnemiesInRange(_player, _ecats, _position, _range)
	if t and next(t) then
		return table.getn(t)
	end
	return 0
end

-- Comfort to get the amount of entities of playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return integer
function GetNumberOfPlayerEntitiesByCatInRange(_player, _ecats, _position, _range)
	assert(type(_player) == "number" and _player > 0 and _player < 17, "invalid player ID")
	assert(type(_ecats) == "table", "entity categories param must be a table")
	assert(type(_position) == "table" and _position.X and _position.Y, "position param must be a table")
	assert(type(_range) == "number" and _range > 0, "invalid range")
	local count = 0
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.OfAnyCategoryFilter(unpack(_ecats))) do
		count = count + 1
	end
	return count
end

-- Comfort to get the amount and entityIDs of entities of playerID based off entityCategories and range to given position
---@param _player integer playerID
---@param _ecats table entityCategories
---@param _position table positionTable
---@param _range number search range
---@return integer amount found entities
---@return table table with entityIDs
function GetPlayerEntitiesByCatInRange(_player, _ecats, _position, _range)
	assert(type(_player) == "number" and _player > 0 and _player < 17, "invalid player ID")
	assert(type(_ecats) == "table", "entity categories param must be a table")
	assert(type(_position) == "table" and _position.X and _position.Y, "position param must be a table")
	assert(type(_range) == "number" and _range > 0, "invalid range")
	local t = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.OfAnyCategoryFilter(unpack(_ecats))) do
		table.insert(t, eID)
	end
	return table.getn(t), t
end

-- Comfort to get the amount of entities of playerIDs based off range to given position
---@param _player table playerIDs
---@param _position table positionTable
---@param _range number search range
---@return integer
function GetNumberOfPlayerUnitsInRange(_player, _position, _range)
	assert(type(_player) == "table", "invalid player IDs")
	assert(type(_position) == "table" and _position.X and _position.Y, "position param must be a table")
	assert(type(_range) == "number" and _range > 0, "invalid range")
	local count = 0
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(_player)), CEntityIterator.InCircleFilter(_position.X, _position.Y, _range), CEntityIterator.IsSettlerFilter()) do
		count = count + 1
	end
	return count
end

-- Comfort to get the distance and the entityID of the nearest enemy to a given player, position and range
-- player needs active armies!
---@param _player integer playerID
---@param _position table positionTable
---@param _range number search range
---@return number distance to enemy
---@return integer entityID of nearest enemy
function GetNearestEnemyDistance(_player, _position, _range)
	local id = GetNearestEnemyInRange(_player, _position, _range)
	if id then
		return GetDistance(id, _position), id
	end
	return false
end

-- Comfort to get the entityID of the nearest enemy to a given player, position and range
-- player needs active armies!
---@param _player integer playerID
---@param _position table positionTable
---@param _range number search range
---@param _seccheck boolean? should sector be checked? (optional, true by default)
---@return integer entityID of nearest enemy
function GetNearestEnemyInRange(_player, _position, _range, _seccheck)
	if _seccheck == nil then
		_seccheck = true
	end
	ChunkWrapper.UpdatePositions(AIchunks[_player])
	local entities = ChunkWrapper.GetEntitiesInAreaInCMSorted(AIchunks[_player], _position.X, _position.Y, _range)
	if next(entities) then
		local sector
		if _seccheck then
			sector = CUtil.GetSector(round(_position.X/100), round(_position.Y/100))
			local eID = Logic.GetEntityAtPosition(_position.X, _position.Y)
			if eID > 0 then
				sector = Logic.GetSector(eID)
			end
		end
		for i = 1, table.getn(entities) do
			local id = entities[i]
			if Logic.IsEntityAlive(id) and (not _seccheck or (_seccheck and Logic.GetSector(id) == sector)) then
				return entities[i]
			end
		end
		return false
	end
	return false
end

-- Comfort to get the entityID of the nearest enemy to a given player, position, range and cone
---@param _player integer playerID
---@param _position table positionTable of cone
---@param _centerAngle number center angle cone is facing
---@param _spreadAngle maximum spread angle of cone
---@param _range number search range
---@return integer entityID of nearest enemy
function GetNearestEnemyInRangeAndCone(_player, _position, _centerAngle, _spreadAngle, _range)

	local enemies = BS.GetAllEnemyPlayerIDs(_player)
	local t = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(enemies)),
	CEntityIterator.IsSettlerOrBuildingFilter(),
	CEntityIterator.InCircleFilter(_position.X, _position.Y, _range)) do
		if Logic.IsEntityAlive(eID) then
			if IsInCone(GetPosition(eID), _position, _centerAngle, _spreadAngle) then
				table.insert(t, {id = eID, dist = GetDistance(eID, _position)})
			end
		end
	end
	table.sort(t, function(p1, p2)
		return p1.dist < p2.dist
	end)
	return (t[1] and t[1].id)
end

-- override so the OSI of the entity is shown again after resuming (workaround for ubi bug)
ResumeEntityOrig = Logic.ResumeEntity
Logic.ResumeEntity = function(_id)
	ResumeEntityOrig(_id)
	if Logic.IsHero(_id) == 1 or Logic.IsLeader(_id) == 1 or Logic.IsSerf(_id) == 1 or Logic.IsEntityInCategory(_id, EntityCategories.Cannon) == 1 or Logic.IsWorker(_id) == 1 then
		Logic.SetEntityScriptingValue(_id, 72, 1)
	end
end

-- added some assertion so we don't get a crash
GetFoundationTopOrig = Logic.GetFoundationTop
Logic.GetFoundationTop = function(_id)
	assert(IsValid(_id), "invalid entityID")
	return GetFoundationTopOrig(_id)
end

-- added some assertion so we don't get a crash
GetAttachedEntitiesOrig = CEntity.GetAttachedEntities
CEntity.GetAttachedEntities = function(_id)
	assert(IsValid(_id), "invalid entityID")
	return GetAttachedEntitiesOrig(_id)
end

-- added some assertion so we don't get a crash; function allows only armyIDs between -1 and 8
Entity_ConnectLeaderOrig = AI.Entity_ConnectLeader
AI.Entity_ConnectLeader = function(_id, _armyID)
	assert(IsValid(_id), "invalid entityID")
	assert(_armyID >= -1 and _armyID <= 8)
	return Entity_ConnectLeaderOrig(_id, _armyID)
end

-- added some assertion so we don't get a crash
GroupAttackOrig = Logic.GroupAttack
Logic.GroupAttack = function(_id, _target)
	assert(IsValid(_id), "invalid attacker entityID")
	assert(IsValid(_target), "invalid target entityID")
	return GroupAttackOrig(_id, _target)
end

-- added some assertion so we don't get a crash; additionaly start to trigger to check if units' stand command was aborted
GroupStandOrig = Logic.GroupStand
Logic.GroupStand = function(_id)
	assert(IsValid(_id), "invalid entityID")
	if not GetArmyByLeaderID(_id) and not gvCommandCheck[_id] then
		gvCommandCheck[_id] = {TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "CheckForCommandAbortedJob", 1, {}, {_id, 7})}
	end
	return GroupStandOrig(_id)
end

GroupAddPatrolPointOrig = Logic.GroupAddPatrolPoint
Logic.GroupAddPatrolPoint = function(_id, _posX, _posY)
	assert(IsValid(_id), "invalid entityID")
	gvCommandCheck[_id] = gvCommandCheck[_id] or {}
	gvCommandCheck[_id].PatrolPoints = gvCommandCheck[_id].PatrolPoints or {}
	table.insert(gvCommandCheck[_id].PatrolPoints, {X = _posX, Y = _posY})
	return GroupAddPatrolPointOrig(_id, _posX, _posY)
end

-- added some assertion so we don't get a crash; additionaly start to trigger to check if units' patrol command was aborted
GroupPatrolOrig = Logic.GroupPatrol
Logic.GroupPatrol = function(_id, _posX, _posY)
	if type(_id) == "string" then
		_id = GetID(_id)
	end
	assert(IsValid(_id), "invalid entityID")
	if not GetArmyByLeaderID(_id) and (not gvCommandCheck[_id] or gvCommandCheck[_id] and not gvCommandCheck[_id].TriggerID) then
		gvCommandCheck[_id] = gvCommandCheck[_id] or {}
		gvCommandCheck.TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "CheckForCommandAbortedJob", 1, {}, {_id, 4, _posX, _posY})
	end
	return GroupPatrolOrig(_id, _posX, _posY)
end

-- function allows only armyIDs between -1 and 8
Army_GetEntityIdOfEnemyOrig = AI.Army_GetEntityIdOfEnemy
AI.Army_GetEntityIdOfEnemy = function(_player, _id)
	if _id >= 0 and _id <= 8 then
		return Army_GetEntityIdOfEnemyOrig(_player, _id)
	else
		return Army_GetEntityIdOfEnemyOrig(_player, 0)
	end
end

-- function allows only armyIDs between -1 and 8
Army_SetScatterToleranceOrig = AI.Army_SetScatterTolerance
AI.Army_SetScatterTolerance = function(_player, _id, _val)
	if _id >= 0 and _id <= 8 then
		Army_SetScatterToleranceOrig(_player, _id, _val)
	end
end

-- function allows only armyIDs between -1 and 8
Army_SetSizeOrig = AI.Army_SetSize
AI.Army_SetSize = function(_player, _id, _val)
	if _id >= 0 and _id <= 8 then
		Army_SetSizeOrig(_player, _id, _val)
	end
end

-- Comfort to get the armyID by leaderID
--player needs active armies!
---@param _id integer leaderID
---@return integer armyID
GetArmyByLeaderID = function(_id)
	assert(IsValid(_id), "invalid entityID")
	assert(Logic.IsLeader(_id) == 1, "entityID must be a leader")
	local player = Logic.EntityGetPlayer(_id)
	--assert((ArmyTable and ArmyTable[player]) or (MapEditor_Armies and MapEditor_Armies[player]), "player ID ".. player .." has no armies")
	if ArmyTable and ArmyTable[player] then
		for k, v in pairs(ArmyTable[player]) do
			if v.IDs and table.getn(v.IDs) and table.getn(v.IDs) > 0 then
				if table_findvalue(v.IDs, _id) ~= 0 then
					return k - 1
				end
			end
		end
	end
	if MapEditor_Armies and MapEditor_Armies[player] then
		for k, v in pairs(MapEditor_Armies[player].defensiveArmies) do
			if k == "IDs" and table.getn(v) and table.getn(v) > 0 then
				if table_findvalue(v, _id) ~= 0 then
					return "defensiveArmies"
				end
			end
		end
		for k, v in pairs(MapEditor_Armies[player].offensiveArmies) do
			if k == "IDs" and table.getn(v) and table.getn(v) > 0 then
				if table_findvalue(v, _id) ~= 0 then
					return "offensiveArmies"
				end
			end
		end
	end
end

-- Comfort to evaluate if entity or army is dead ~= not existing (e.g. heroes)
---@param _name integer|string|table leaderID or leaderName or armyTable
---@return boolean
IsDead = function(_name)

	if type(_name) == "table" then

		if ArmyTable and ArmyTable[_name.player] and ArmyTable[_name.player][_name.id + 1] then
			if ArmyTable[_name.player][_name.id + 1].IDs and type(ArmyTable[_name.player][_name.id + 1].IDs) == "table" then
				return table.getn(ArmyTable[_name.player][_name.id + 1].IDs) == 0
			else
				return true
			end
		else
			return AI.Army_GetNumberOfTroops(_name.player, _name.id) <= 0
		end
	end

	local entityId = 0

	if type(_name) == "string" then

		if Logic.IsEntityDestroyed(_name) then
			return true
		end
		entityId = Logic.GetEntityIDByName(_name)

	else
		entityId = _name
	end

	if entityId == 0 then
		return true
	end

	if AI.Entity_IsDead(entityId) == 1 then
		return true
	end

	return false

end

-- Comfort to evaluate if given army is at or above full strength
---@param _army table armyTable
---@return boolean
HasFullStrength = function(_army)

	if ArmyTable and ArmyTable[_army.player] and ArmyTable[_army.player][_army.id + 1] then
		return table.getn(ArmyTable[_army.player][_army.id + 1].IDs) >= _army.strength
	else
		return AI.Army_GetNumberOfTroops(_army.player,_army.id) >= _army.strength
	end
	return false

end

-- Comfort to evaluate if given army is below full strength
---@param _army table armyTable
---@return boolean
IsWeak = function(_army)

	if ArmyTable and ArmyTable[_army.player] and ArmyTable[_army.player][_army.id + 1] then
		return table.getn(ArmyTable[_army.player][_army.id + 1].IDs) < _army.strength
	else
		return AI.Army_GetNumberOfTroops(_army.player,_army.id) < _army.strength
	end

end

-- Comfort to evaluate if given army is below a third of full strength
---@param _army table armyTable
---@return boolean
IsVeryWeak = function(_army)

	return IsBelowTreshold(_army, 3, 5)
end

-- Comfort to evaluate if given army is below a certain treshold
---@param _army table armyTable
---@param _leaderratio number if army strength is below max army strength divided by this value, it is considered as weak
---@param _soldierratio number if army soldier amount is below max army soldier amount divided by this value, it is considered as weak
---@return boolean
IsBelowTreshold = function(_army, _leaderratio, _soldierratio)

	if ArmyTable and ArmyTable[_army.player] and ArmyTable[_army.player][_army.id + 1] then
		return (table.getn(ArmyTable[_army.player][_army.id + 1].IDs) < (_army.strength / _leaderratio)
		or GetNumberOfSoldiersAttachedToArmy(_army.player, _army.id) < (GetMaxNumberOfSoldiersAttachedToArmy(_army.player, _army.id) / _soldierratio))
	else
		return AI.Army_GetNumberOfTroops(_army.player,_army.id) < (_army.strength / _leaderratio)
	end
end

-- Comfort to get the number of soldiers attached to given army
---@param _player integer playerID
---@param _id integer armyID
---@param _spec string recruitedArmy type
---@return integer
GetNumberOfSoldiersAttachedToArmy = function(_player, _id, _spec)

	local army
	if _id then
		army = ArmyTable[_player][_id + 1]
	elseif _spec then
		army = MapEditor_Armies[_player][_spec]
	end
	local count = 0
	for i = 1, table.getn(army.IDs) do
		count = count + Logic.LeaderGetNumberOfSoldiers(army.IDs[i])
	end
	return count
end

--- Comfort to get the total number of entities currently attached to given army (leaders+soldiers)
---@param _player integer playerID
---@param _id integer armyID
---@param _spec string recruitedArmy type
---@return integer
GetNumberOfEntitiesAttachedToArmy = function(_player, _id, _spec)

	local army
	if _id then
		army = ArmyTable[_player][_id + 1]
	elseif _spec then
		army = MapEditor_Armies[_player][_spec]
	end
	local count = 0
	for i = 1, table.getn(army.IDs) do
		count = count + Logic.LeaderGetNumberOfSoldiers(army.IDs[i]) + 1
	end
	return count
end

--- Comfort to get the number of soldiers that can be attached (maximum possible) to given army
---@param _player integer playerID
---@param _id integer armyID
---@param _spec string recruitedArmy type
---@return integer
GetMaxNumberOfSoldiersAttachedToArmy = function(_player, _id, _spec)

	local army
	if _id then
		army = ArmyTable[_player][_id + 1]
	elseif _spec then
		army = MapEditor_Armies[_player][_spec]
	end
	local count = 0
	local numLeader = table.getn(army.IDs)
	for i = 1, numLeader do
		local id = army.IDs[i]
		if Logic.IsHero(id) == 0 then
			count = count + Logic.LeaderGetMaxNumberOfSoldiers(army.IDs[i])
		end
	end
	if numLeader < army.strength then
		count = count * army.strength / numLeader
	end
	return count
end

--- Comfort to get the number of entities that can be attached (maximum possible) to given army (leaders+soldiers)
---@param _player integer playerID
---@param _id integer armyID
---@param _spec string recruitedArmy type
---@return integer
GetMaxNumberOfEntitiesAttachedToArmy = function(_player, _id, _spec)

	local army
	if _id then
		army = ArmyTable[_player][_id + 1]
	elseif _spec then
		army = MapEditor_Armies[_player][_spec]
	end
	local count = 0
	local numLeader = table.getn(army.IDs)
	for i = 1, numLeader do
		count = count + 1
		local id = army.IDs[i]
		if Logic.IsHero(id) == 0 then
			count = count + Logic.LeaderGetMaxNumberOfSoldiers(army.IDs[i])
		end
	end
	if numLeader < army.strength then
		count = count * army.strength / numLeader
	end
	return count
end

-- table with maximum soldiers based off leader type
MaxSoldiersByLeaderType = {	[Entities.PU_LeaderSword1] = 4,
							[Entities.PU_LeaderSword2] = 4,
							[Entities.PU_LeaderSword3] = 8,
							[Entities.PU_LeaderSword4] = 12,
							[Entities.PU_LeaderPoleArm1] = 4,
							[Entities.PU_LeaderPoleArm2] = 4,
							[Entities.PU_LeaderPoleArm3] = 8,
							[Entities.PU_LeaderPoleArm4] = 12,
							[Entities.PU_LeaderBow1] = 4,
							[Entities.PU_LeaderBow2] = 4,
							[Entities.PU_LeaderBow3] = 8,
							[Entities.PU_LeaderBow4] = 12,
							[Entities.PU_LeaderRifle1] = 3,
							[Entities.PU_LeaderRifle2] = 6,
							[Entities.PU_LeaderCavalry1] = 3,
							[Entities.PU_LeaderCavalry2] = 6,
							[Entities.PU_LeaderHeavyCavalry1] = 3,
							[Entities.PU_LeaderHeavyCavalry2] = 4,
							[Entities.PU_LeaderUlan1] = 4,
							[Entities.PU_Scout] = 0,
							[Entities.PU_Thief] = 0,
							[Entities.PV_Cannon1] = 0,
							[Entities.PV_Cannon2] = 0,
							[Entities.PV_Cannon3] = 0,
							[Entities.PV_Cannon4] = 0,
							[Entities.PV_Cannon5] = 0,
							[Entities.PV_Cannon6] = 0,
							[Entities.PV_Catapult] = 0,
							[Entities.CU_AggressiveWolf] = 0,
							[Entities.CU_BanditLeaderSword1] = 10,
							[Entities.CU_BanditLeaderSword2] = 8,
							[Entities.CU_BanditLeaderBow1] = 10,
							[Entities.CU_Barbarian_LeaderClub1] = 8,
							[Entities.CU_Barbarian_LeaderClub2] = 8,
							[Entities.CU_BlackKnight_LeaderMace1] = 4,
							[Entities.CU_BlackKnight_LeaderMace2] = 4,
							[Entities.CU_BlackKnight_LeaderSword3] = 6,
							[Entities.CU_Evil_LeaderBearman1] = 16,
							[Entities.CU_Evil_LeaderSkirmisher1] = 16,
							[Entities.CU_VeteranCaptain] = 0,
							[Entities.CU_VeteranLieutenant] = 2,
							[Entities.CU_VeteranMajor] = 2}

-- Comfort to get the maximum number of soldiers by leader type
---@param _type integer entityType of leader
---@return integer maximum number of soldiers
function LeaderTypeGetMaximumNumberOfSoldiers(_type)
	return MaxSoldiersByLeaderType[_type] or 0
end

function IsVeteranLeader(_id)
	assert(IsValid(_id), "invalid entity id")
	local type = Logic.GetEntityType(_id)
	return (type == Entities.CU_VeteranCaptain or type == Entities.CU_VeteranLieutenant or type == Entities.CU_VeteranMajor)
end

-- comfort to unmute game feedback and the mentor
function Unmuting()

	GUI.SetFeedbackSoundOutputState(1)
	Music.SetVolumeAdjustment(Music.GetVolumeAdjustment() * 2)

end

-- technologies sorted by categories; view UniTechAmount or QuickTest
gvTechTable = {University = {	Technologies.GT_Literacy,Technologies.GT_Trading,Technologies.GT_Printing,Technologies.GT_Library,
								Technologies.GT_Construction,Technologies.GT_GearWheel,Technologies.GT_ChainBlock,Technologies.GT_Architecture,
								Technologies.GT_Alchemy,Technologies.GT_Alloying,Technologies.GT_Metallurgy,Technologies.GT_Chemistry,
								Technologies.GT_Mercenaries,Technologies.GT_StandingArmy,Technologies.GT_Tactics,Technologies.GT_Strategies,
								Technologies.GT_Mathematics,Technologies.GT_Binocular,Technologies.GT_PulledBarrel,Technologies.GT_Matchlock,
								Technologies.GT_Taxation,Technologies.GT_Banking,Technologies.GT_Laws,Technologies.GT_Gilds},
			MercenaryTower = {	Technologies.T_KnightsCulture, Technologies.T_BearmanCulture, Technologies.T_BanditCulture, Technologies.T_BarbarianCulture},
			Special = {			Technologies.T_Coinage, Technologies.T_Scale, Technologies.T_WeatherForecast, Technologies.T_ChangeWeather, Technologies.T_CropCycle},
			TroopUpgrades = {	Technologies.T_SoftArcherArmor, Technologies.T_LeatherMailArmor, Technologies.T_BetterTrainingBarracks, Technologies.T_BetterTrainingArchery,
								Technologies.T_Shoeing, Technologies.T_BetterChassis, Technologies.T_WoodAging, Technologies.T_Turnery, Technologies.T_MasterOfSmithery,
								Technologies.T_IronCasting, Technologies.T_Fletching, Technologies.T_BodkinArrow, Technologies.T_EnhancedGunPowder, Technologies.T_BlisteringCannonballs,
								Technologies.T_PaddedArcherArmor, Technologies.T_LeatherArcherArmor, Technologies.T_ChainMailArmor, Technologies.T_PlateMailArmor,
								Technologies.T_FleeceArmor, Technologies.T_FleeceLinedLeatherArmor, Technologies.T_LeadShot, Technologies.T_Sights},
			SilverTechs = 	{	Technologies.T_SilverPlateArmor, Technologies.T_SilverArcherArmor, Technologies.T_SilverArrows, Technologies.T_SilverSwords,
								Technologies.T_SilverLance, Technologies.T_SilverBullets, Technologies.T_SilverMissiles, Technologies.T_BloodRush}
				}

-- Gets amount of university technologies already researched by playerID
---@param _PlayerID integer playerID
---@return integer
UniTechAmount = function(_PlayerID)

	local Player = _PlayerID
	local amount = 0

	for i = 1,table.getn(gvTechTable.University) do
		if Logic.GetTechnologyState(Player, gvTechTable.University[i]) == 4 then
			amount = amount + 1
		end
	end

	return amount

end

-- Comfort for quick testing. Gives large amounts of resources, speeds up the game, researches technologies and more
---@param _val number? optional, number of resources to provide and range to explore
function QuickTest(_val)

	local player = GUI.GetPlayerID()
	local val = _val or 1000000
	AddGold(player, val)
	AddStone(player, val)
	AddIron(player, val)
	AddWood(player, val)
	AddSulfur(player, val)
	AddClay(player, val)
	Logic.AddToPlayersGlobalResource(player, ResourceType.SilverRaw, val)
	Logic.AddToPlayersGlobalResource(player, ResourceType.Knowledge, val)
	ResearchAllTechnologies(player, true, true, true, true, true)
	Display.SetRenderFogOfWar(0)
	GUI.MiniMap_SetRenderFogOfWar(0)
	Sel = GUI.GetSelectedEntity
	Game.ShowFPS(1)
	Input.KeyBindDown(Keys.T, "LuaDebugger.Log(CUtil.GetTargetedEntity())", 2 )

	if Tools then
		Tools.ExploreArea(-1, -1, val)
	end
	if not CNetwork then
		Game.GameTimeSetFactor(6)
	end
end

-- Comfort to research technologies by technology categories for a player
---@param _PlayerID integer playerID
---@param _UniTechsFlag boolean? Should University Technologies be researched?
---@param _MercTechsFlag boolean? Should MercenaryTower Technologies be researched?
---@param _SpecTechsFlag boolean? Should Special Technologies be researched (e.g. weather, tech requirements for mint, tradepost and veggie plantation etc.)?
---@param _TroopTechsFlag boolean? Should Troop Technologies be researched?
---@param _SilverTechsFlag boolean? Should Silver Technologies be researched?
function ResearchAllTechnologies(_PlayerID, _UniTechsFlag, _MercTechsFlag, _SpecTechsFlag, _TroopTechsFlag, _SilverTechsFlag)

	_UniTechsFlag = _UniTechsFlag or false
	_MercTechsFlag = _MercTechsFlag or false
	_SpecTechsFlag = _SpecTechsFlag or false
	_TroopTechsFlag = _TroopTechsFlag or false
	_SilverTechsFlag = _SilverTechsFlag or false

	if _MercTechsFlag then
		--needed to unlock all the techs properly
		gvMercTechsCheated = 1
	end

	local tabletodo = {	University = _UniTechsFlag,
						MercenaryTower = _MercTechsFlag,
						Special = _SpecTechsFlag,
						TroopUpgrades = _TroopTechsFlag,
						SilverTechs = _SilverTechsFlag}
	for k,v in pairs(tabletodo) do
		if v then
			for i,j in pairs(gvTechTable[k]) do
				Logic.SetTechnologyState(_PlayerID, j, 3)
			end
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- comfort to completely hide the GUI
function HideGUI()

	Game.GUIActivate(0)
	Display.SetRenderDecalsSelections(0)
	Mouse.CursorHide()
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "ShowGUI()", 2 )

end

-- comfort to show the GUI
function ShowGUI()

	Game.GUIActivate(1)
	Display.SetRenderDecalsSelections(1)
	Mouse.CursorShow()
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "HideGUI()", 2 )

end
------------------------------------------ Countdown Comfort --------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- Comfort to start an delayed action
---@param _Limit integer TimeLimit for the countdown, when reaching zero, callback function is called
---@param _Callback function Callback function when counter reaches zero
---@param _Show boolean? Should the remaining time be displayed? Only 1 timer at the same time possible
---@param _Name string? optional parameter to display the function name at a message when countdown can't be shown
---@param ... any? parameters for the Callback function
---@return integer Index of the Counter
StartCountdown = function (_Limit, _Callback, _Show, _Name, ...)

	assert(type(_Limit) == "number" and _Limit > 0, "Limit param must be a number greater than 0")
	Counter.Index = (Counter.Index or 0) + 1

	if _Show and CountdownIsVisisble() then
		if _Name then
			LuaDebugger.Log("StartCountdown: A countdown is already visible. Countdown ticking to ".._Name.." is running but not shown!")
		else
			LuaDebugger.Log("StartCountdown: A countdown is already visible. Countdown ticking to "..string.dump(_Callback).." is running but not shown!")
		end

		_Show = false

	end

	Counter["counter" .. Counter.Index] = {Limit = _Limit, TickCount = 0, Callback = _Callback, Show = _Show, Finished = false, Params = arg}

	if _Show then
		MapLocal_StartCountDown(_Limit)
	end

	if Counter.JobId == nil then
		Counter.JobId = StartSimpleJob("CountdownTick")
	end

	return Counter.Index

end

-- Comfort to stop a countdown
---@param _Id integer Counter Index
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
					if Counter["counter" .. i].Params then
						Counter["counter" .. i].Callback(unpack(Counter["counter" .. i].Params))
					else
						Counter["counter" .. i].Callback()
					end
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

-- comfort to evaluate if a counter is currently shown or not
---@return boolean
CountdownIsVisisble = function()

	for i = 1, Counter.Index do
		if Counter.IsValid("counter" .. i) and Counter["counter" .. i].Show then
			return true
		end
	end

	return false

end
--------------------------------------------------------------------------------------------------------------------------------------
-- Comfort to add a tribute
---@param _tribute table Table filled with tribute data (e.g. tribute = {text ="", cost={resourceType, costs}, pId or playerId})
---@return integer Tribute ID
function AddTribute(_tribute)

	assert(type(_tribute) == "table", "Tribute must be a table")
	assert(type(_tribute.text) == "string", "Tribute.text must be a string")
	assert(type(_tribute.cost) == "table", "Tribute.cost must be a table")
	assert(type(_tribute.pId or _tribute.playerId) == "number", "Tribut.pId must be a number")
	assert(not _tribute.Tribute , "Tribut.Tribute already in use")
	uniqueTributeCounter = uniqueTributeCounter or 1
	_tribute.Tribute = uniqueTributeCounter
	uniqueTributeCounter = uniqueTributeCounter + 1
	local tResCost = {}

	for k, v in pairs(_tribute.cost) do
		assert(ResourceType[k], "invalid resource type")
		assert(type(v) == "number", "invalid resource costs")
		table.insert(tResCost, ResourceType[k])
		table.insert(tResCost, v)
	end

	Logic.AddTribute(_tribute.playerId or _tribute.pId, _tribute.Tribute, 0, 0, _tribute.text, unpack(tResCost))
	SetupTributePaid(_tribute)
	return _tribute.Tribute

end
----------------------------------------------------------------------------------------------------------------------------------------
-- Comfort to check whether a position is explored; deprecated
---@param _pID integer playerID
---@param _x number positionX
---@param _y number positionY
---@param _range number Range to check for playerEntities
---@return integer flag
function IsPositionExplored(_pID, _x, _y, _range)

	_range = _range or 7000

	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_pID), CEntityIterator.InCircleFilter(_x, _y, _range)) do
		if GetDistance({Logic.GetEntityPosition(Logic.GetEntityIDByName(eID))},{X=_x,Y=_y}) <= Logic.GetEntityExplorationRange(eID) then
			return 1
		else
			return 0
		end
	end

end

-- returns the start positions (HQ) of the given or current player as a table
---@param _player integer? playerID (Optional)
---@return table positionTable of current player's first HQ found
function GetPlayerStartPosition(_player)

	local playerID = _player or GUI.GetPlayerID()
	if playerID == BS.SpectatorPID then
		playerID = 1
	end
	local t = {LVL = {}}

	-- search for all upgrade levels
	for i = 1,3 do
		t.LVL[i] = {Logic.GetPlayerEntities(playerID, Entities["PB_Headquarters"..i], 1)}
		table.remove(t.LVL[i], 1)

		for k = 1,table.getn(t.LVL[i]) do
			table.insert(t, t.LVL[i][k])
		end

	end

	return GetPosition(t[1])

end

-- Comfort to get all AI playerIDs
---@return table AI playerID table
function GetAllAIs()

	local AITable = {}

	if CNetwork then
		for i = 2, 16 do
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) == 0 then
				if Score.Player[i].all > 0 then
					table.insert(AITable, i)
				end
			end
		end

	else

		for i = 2, 8 do
			if Score.Player[i].all > 0 then
				table.insert(AITable, i)
			end
		end

	end
	return AITable
end

-- Comfort to check whether a given player is human or not
---@param _player integer playerID
---@return boolean
function IsPlayerHuman(_player)
	if CNetwork then
		return XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_player) == 1
	else
		return _player == 1
	end
end

-- Comfort to get all humen player IDs
---@return table
function GetAllHumenPlayer()
	local t = {}
	local max
	if CNetwork then
		max = 16
	else
		return {1}
	end
	for i = 1, max do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) == 1 then
			table.insert(t, i)
		end
	end
	return t
end

-- comfort to let a group of given player IDs share the same diplomacy state
---@param _PlayerID table with player IDs
---@param _Diplomacy integer diplomacy state
function SetPlayerDiplomacy(_PlayerID, _Diplomacy)

	assert(type(_PlayerID) == "table","first argument must be a table filled with valid player IDs")
	assert(type(_Diplomacy) == "number","second argument must be a number (either Diplomacy.XXX or ID of the given diplomacy state)")
	local tablelength = table.getn(_PlayerID)

	for i = 1,tablelength,1 do
		for k = tablelength,1,-1 do
			if _PlayerID[i] ~= _PlayerID[k] then
				Logic.SetDiplomacyState(_PlayerID[i],_PlayerID[k],_Diplomacy)
			end
		end
	end

end

-- comfort to set the diplomacy state between a player ID or a group of given player IDs and all AI player IDs on the map
---@param _PlayerID integer|table player ID or table with player IDs (optional, default: all humen player IDs on the map)
---@param _Diplomacy integer? diplomacy state (optional, default: hostile)
function SetHumanPlayerDiplomacyToAllAIs(_PlayerID, _Diplomacy)

	assert(type(_PlayerID) ~= "string","Argument must be either a valid player ID or a table filled with valid player IDs")

	if not CNetwork then
		for i = 2,8 do
			Logic.SetDiplomacyState(1, i, (_Diplomacy or Diplomacy.Hostile))
		end
	end

	if not _PlayerID then
		_PlayerID = {}

		for i = 1,16 do
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) == 1 then
				table.insert(_PlayerID,i)
			end
		end

	end

	if not _Diplomacy then
		_Diplomacy = Diplomacy.Hostile
	end

	local AITable = {}

	for i = 2,16 do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) == 0 then
			table.insert(AITable,i)
		end
	end

	if type(_PlayerID) == "number" then
		for k,v in pairs(AITable) do
			Logic.SetDiplomacyState(_PlayerID,v,_Diplomacy)
		end

	elseif type(_PlayerID) == "table" then
		for i = 1,table.getn(_PlayerID) do
			for k,v in pairs(AITable) do
				Logic.SetDiplomacyState(_PlayerID[i],v,_Diplomacy)
			end
		end

	end

end

-- returns the distance between two points
---@param _a integer|string|table entityID or entityName or positionTable
---@param _b integer|string|table entityID or entityName or positionTable
---@return number distance
GetDistance = function(_a, _b)

	if type(_a) ~= "table" then
		_a = GetPosition(_a)
	end

	if type(_b) ~= "table" then
		_b = GetPosition(_b)
	end

	if _a.X ~= nil then
		return math.sqrt((_a.X - _b.X)^2+(_a.Y - _b.Y)^2)
	else
		return math.sqrt((_a[1] - _b[1])^2+(_a[2] - _b[2])^2)
	end

end

--- author:mcb
-- checks if a position is in a cone originating from another position.
-- imagine it as checking if an entity at the position center, looking at direction middleAlpha
-- and a field of view of betaAvailable to either side can see pos.
-- (assumes being able to look through any other object and having infinite vision range).
-- (the angle of the entire cone is betaAvaiable * 2, its outer birders are at middleAlpha+betaAvaiable and middleAlpha-betaAvaiable).
-- (depending on the circumstances, should be coupled by a distance check via GetDistance).
---@param _pos table positionTable
---@param _center table positionTable of center of cone
---@param _middleAlpha number center angle cone should be facing
---@param _betaAvaiable number max spread angle
---@return boolean
function IsInCone(_pos, _center, _middleAlpha, _betaAvaiable)
	local a = GetAngleBetween(_center, _pos)
	local lb = _middleAlpha - _betaAvaiable
	local hb = _middleAlpha + _betaAvaiable
	if a >= lb and a <= hb then
		return true
	end
	a = math.mod((a + 180), 360)
	lb = math.mod((lb + 180), 360)
	hb = math.mod((hb + 180), 360)
	if a >= lb and a <= hb then
		return true
	end
end

-- evaluates whether a position is unblocked or not
---@param _x table positionTable
---@param _y table positionTable
---@return boolean
function IsPositionUnblocked(_x, _y)
	local height, blockingtype, sector, terrType = CUtil.GetTerrainInfo(_x, _y)
	return (sector ~= 0 and math.mod(blockingtype, 2) == 0 and (height > CUtil.GetWaterHeight(round(_x/100), round(_y/100))))
end

-- sets the health of an entity to a given percentage
---@param _EntityID integer entityID
---@param _HealthInPercent number Health percentage
function ChangeHealthOfEntity(_EntityID, _HealthInPercent)

	if Logic.IsEntityAlive(_EntityID) == false then
		return
	end

	-- Get max health of entity
	local Health = Logic.GetEntityMaxHealth(_EntityID)
	-- Calculate new Health
	Health = (Health * _HealthInPercent)/100
	-- Get current health of entity and create delta
	local DeltaHealth = Logic.GetEntityHealth(_EntityID)
	DeltaHealth = Health - DeltaHealth
	-- Is Positive Value, heal entity
	if DeltaHealth > 0 then
		Logic.HealEntity(_EntityID, DeltaHealth)
	elseif DeltaHealth < 0 then
	-- else hurt it
		Logic.HurtEntity(_EntityID, -DeltaHealth)
	end

end

-- creates a military group
---@param _PlayerID integer playerID
---@param _LeaderType integer entityType of leader
---@param _SoldierAmount integer amount of soldiers for leader
---@param _X number positionX
---@param _Y number positionY
---@param _Orientation number leader rotation
---@param _Experience integer? leader experience points (optional)
---@return integer EntityID of leader
function CreateGroup(_PlayerID, _LeaderType, _SoldierAmount, _X, _Y, _Orientation, _Experience)

	if _LeaderType == nil or _LeaderType == 0 then
		assert(_LeaderType ~= nil and _LeaderType ~= 0, "invalid leader type")
		return 0
	end
	-- Create leader
	local LeaderID = Logic.CreateEntity(_LeaderType, _X, _Y, _Orientation, _PlayerID)

	if LeaderID == 0 then
		assert(LeaderID ~= 0, "leader creation failed. Aborting")
		return 0
	end

	if _Experience and _Experience > 0 then
		CEntity.SetLeaderExperience(LeaderID, _Experience)
	end

	CreateSoldiersForLeader(LeaderID, _SoldierAmount)
	-- Return leader ID
	return LeaderID

end

-- creates soldiers for a leader
---@param _LeaderID integer entityID of leader
---@param _SoldierAmount integer amount of soldiers for leader
---@return integer amount of soldiers
function CreateSoldiersForLeader(_LeaderID, _SoldierAmount)

	-- Is a leader passed?
	assert(_LeaderID ~= nil and type(_LeaderID) == "number" and _LeaderID > 0, "invalid leader id")
	if _LeaderID == 0 then
		return 0
	end

	if Logic.IsLeader(_LeaderID) ~= 1 then
		return 0
	end

	-- Get soldier type ok for leader
	local SoldierType = Logic.LeaderGetSoldiersType(_LeaderID)
	-- Get maximum amount of soldier this leader can lead and change soldier amount if more soldiers should be attached than allowed
	local MaxSoldiers = Logic.LeaderGetMaxNumberOfSoldiers( _LeaderID )

	if _SoldierAmount > MaxSoldiers then
		_SoldierAmount = MaxSoldiers
	end

	-- Get leader data
	local LeaderX, LeaderY = Logic.GetEntityPosition( _LeaderID )
	local LeaderPlayerID = Logic.EntityGetPlayer( _LeaderID )
	-- Create soldiers
	local Counter

	for Counter=1, _SoldierAmount, 1 do
		local SoldierID = Logic.CreateEntity(SoldierType, LeaderX, LeaderY, 0, LeaderPlayerID)

		if SoldierID == 0 then
			assert(SoldierID ~= 0, "soldier creation failed. Aborting")
			return 0
		end

		Logic.LeaderGetOneSoldier(_LeaderID)

	end
	-- Return number of soldiers
	return _SoldierAmount

end
----------------------------------------------------------------------------------------------------------
PlayerEntitiesInvulnerable_IsActive = {}
-- makes all settlers and buildings of a given player invulnerable for a given amount of time
-- start as SimpleJob or HiResJob
---@param _PlayerID integer playerID
---@param _Timelimit integer timeLimit in seconds (SimpleJob) or ticks (HiResJob)
function MakePlayerEntitiesInvulnerableLimitedTime(_PlayerID, _Timelimit)
	_Timelimit = round(_Timelimit)
	if not Counter.Tick2("MakePlayerEntitiesInvulnerableLimitedTime_Ticker".. _PlayerID, _Timelimit) then
		if not PlayerEntitiesInvulnerable_IsActive[_PlayerID] then
			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_PlayerID), CEntityIterator.IsSettlerOrBuildingFilter()) do
				if Logic.IsEntityAlive(eID) then
					MakeInvulnerable(eID)
				end
			end
		PlayerEntitiesInvulnerable_IsActive[_PlayerID] = true
		end
	else
		for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_PlayerID), CEntityIterator.IsSettlerOrBuildingFilter()) do
			if Logic.IsEntityAlive(eID) then
				MakeVulnerable(eID)
			end
		end
		PlayerEntitiesInvulnerable_IsActive[_PlayerID] = nil
		return true
	end
end
----------------------------------------------------------------------------------------------------------
-- creates entities of type in a given area (shape = rectangle)
---@param _entityType integer entityType
---@param _amount integer number of entities to be created
---@param _player integer playerID
---@param _minX number lower limit positionX
---@param _maxX number upper limit positionX
---@param _minY number lower limit positionY
---@param _maxY number upper limit positionY
---@param _step number? minimum distance between any entities to be created (optional)
---@param _name string? entityName pattern created entities receive (optional)
---@return table positionTable
function CreateEntitiesInRectangle(_entityType, _amount, _player, _minX, _maxX, _minY, _maxY, _step, _name)
	local count = 0
	local t = {}
	local x_, y_
	while count < _amount do
		local check = true
		x_ = math.random(_minX, _maxX)
		y_ = math.random(_minY, _maxY)
		if IsPositionUnblocked(x_, y_) then
			if _step then
				for k, v in pairs(t) do
					if GetDistance(v, {X = x_, Y = y_}) < _step then
						check = false
					end
				end
			end
			if check then
				table.insert(t, {X = x_, Y = y_})
				count = count + 1
				local id = Logic.CreateEntity(_entityType, x_, y_, 0, _player)
				if _name then
					Logic.SetEntityName(id, _name .. "_" .. _player .. "_" .. count)
				end
			end
		end
	end
	return t
end

-- creates entity trails of type in a given area
---@param _entityType integer entityType
---@param _amount integer number of entities to be created
---@param _player integer playerID
---@param _minX number lower limit positionX
---@param _maxX number upper limit positionX
---@param _minY number lower limit positionY
---@param _maxY number upper limit positionY
---@param _length integer length of entity trails created
---@param _sizeOffset number position offset between two entities in the same trail
---@param _step number? minimum distance between any entities of another trail to be created (optional)
---@param _name string? entityName pattern created entities receive (optional)
---@return table positionTable by trail index and created entity index, respectively
function CreateEntityTrailsInRectangle(_entityType, _amount, _player, _minX, _maxX, _minY, _maxY, _length, _sizeOffset, _step, _name)
	assert(_entityType > 0, "invalid entity type. Aborting")
	assert(_length > 1, "entity trails length must be larger than 1, otherwise no trail creation possible")
	local t = CreateEntitiesInRectangle(_entityType, _amount, _player, _minX, _maxX, _minY, _maxY, _step, _name)
	local t2 = {}
	for i = 1, table.getn(t) do
		local len = 1
		local x_, y_ = t[i].X, t[i].Y
		while len < _length do
			local x__, y__
			local check = true
			x__ = x_ + GenerateRandomWithSteps(-_sizeOffset, _sizeOffset, _sizeOffset)
			y__ = y_ + GenerateRandomWithSteps(-_sizeOffset, _sizeOffset, _sizeOffset)
			if IsPositionUnblocked(x__, y__) then
				if (x__ == x_ and y__ == y_) or (table_findvalue(t[i], x__) ~= 0 and table_findvalue(t[i], y__) ~= 0) then
					check = false
				end
				if check then
					t2[i] = t2[i] or {}
					table.insert(t2[i], {X = x__, Y = y__})
					local id = Logic.CreateEntity(_entityType, x__, y__, 0, _player)
					if _name then
						Logic.SetEntityName(id, _name .. "_" .. _player .. "_" .. i .. "_" .. len)
					end
					x_, y_ = x__, y__
					len = len + 1
				end
			end
		end
		table.insert(t2[i], t[i])
	end
	return t2
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Mem reading/writing --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
BS.MemValues = BS.MemValues or {}
-------------------------------------------------- pointer --------------------------------------------------------------------------------------
function GetEntityTypePointer(_entityType)
	return CUtilMemory.GetMemory(tonumber("0x895DB0", 16))[0][16][_entityType * 8 + 2]
end
function GetPlayerStatusPointer(_playerID)
	return CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][10][_playerID*2+1]
end
function GetDamageModifierPointer()
	return CUtilMemory.GetMemory(tonumber("0x85A3DC", 16))[0][2]
end
function GetTechnologyPointer(_techID)
	return CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][13][1][_techID-1]
end
function GetLogicPropertiesPointer()
	return CUtilMemory.GetMemory(tonumber("0x85A3E0", 16))[0]
end
function GetArmyObjectPointer()
	return CUtilMemory.GetMemory(tonumber("0x8539D4", 16))[0][1][1]
end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- misc -----------------------------------------------------------------------------------------
-- returns the current weather gfx
---@return integer
function GetCurrentWeatherGfxSet()

	return CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][11][10]:GetInt()

end

NighttimeGFXSets = {[1] = {9, 19},
					[2] = {13, 20, 28},
					[3] = {14, 21}}
-- returns whether it's currently night or not
---@return boolean
function IsNighttime()

	local found = 0
	for i = 1, table.getn(NighttimeGFXSets) do
		found = table_findvalue(NighttimeGFXSets[i], GetCurrentWeatherGfxSet())
		if found ~= 0 then
			return true
		end
	end
	return found ~= 0
end

-- overrides internal clipping limit maximum (Display.SetFarClipPlaneMinAndMax(_min, _max) is internally capped at some values)
---@param _val integer new clipping limit maximum
function SetInternalClippingLimitMax(_val)

	assert(type(_val) == "number", "Clipping Limit needs to be a number")
	CUtilMemory.GetMemory(tonumber("0x77A7E8", 16))[0]:SetFloat(_val)

end

-- overrides internal clipping limit minimum (Display.SetFarClipPlaneMinAndMax(_min, _max) is internally capped at some values)
---@param _val integer new clipping limit minimum
function SetInternalClippingLimitMin(_val)

	assert(type(_val) == "number", "Clipping Limit needs to be a number")
	CUtilMemory.GetMemory(tonumber("0x77A7F0", 16))[0]:SetFloat(_val)

end

-- returns the weather movement speed modifier
---@param _weatherstate integer weather state (1 summer, 2 rain, 3 winter)
---@return number speed modifier
function GetWeatherSpeedModifier(_weatherstate)
	assert(_weatherstate > 0 and _weatherstate <= 3, "invalid weatherstate")
	if _weatherstate == 1 then
		return _weatherstate
	else
		if not BS.MemValues.WeatherSpeedModifier then
			BS.MemValues.WeatherSpeedModifier = {}
		end
		if not BS.MemValues.WeatherSpeedModifier[_weatherstate] then
			BS.MemValues.WeatherSpeedModifier[_weatherstate] = GetLogicPropertiesPointer()[36-3*_weatherstate]:GetFloat()
		end
		return BS.MemValues.WeatherSpeedModifier[_weatherstate]
	end
end

-- returns the technology raw speed modifier and the operation (+/*), both defined in the respective xml
---@param _techID integer technology ID (Technologies.XXX)
---@return number speed modifier
---@return string technology math operation (+/*)
function GetTechnologySpeedModifier(_techID)
	if not BS.MemValues.TechnologySpeedModifier then
		BS.MemValues.TechnologySpeedModifier = {}
	end
	if not BS.MemValues.TechnologySpeedModifier[_techID] then
		BS.MemValues.TechnologySpeedModifier[_techID] = GetTechnologyPointer(_techID)[56]:GetFloat(), CUtilBit32.BitAnd(GetTechnologyPointer(_techID)[58]:GetInt(), 2^8-1)-42
	end
	return BS.MemValues.TechnologySpeedModifier[_techID]
end

-- returns the technology raw attack range modifier and the operation (+/*), both defined in the respective xml
---@param _techID integer technology ID (Technologies.XXX)
---@return number attack range modifier
---@return string technology math operation (+/*)
function GetTechnologyAttackRangeModifier(_techID)
	if not BS.MemValues.TechnologyAttackRangeModifier then
		BS.MemValues.TechnologyAttackRangeModifier = {}
	end
	if not BS.MemValues.TechnologyAttackRangeModifier[_techID] then
		BS.MemValues.TechnologyAttackRangeModifier[_techID] = GetTechnologyPointer(_techID)[88]:GetFloat(), CUtilBit32.BitAnd(GetTechnologyPointer(_techID)[90]:GetInt(), 2^8-1)-42
	end
	return BS.MemValues.TechnologyAttackRangeModifier[_techID]
end
--------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ entity Type related -----------------------------------------------------------------------------
-- table with entityTypes with leaderBehavior two places further (index 8 instead of 6)
BehaviorExceptionEntityTypeTable = { 	[Entities.PU_Hero1]  = true,
										[Entities.PU_Hero1a] = true,
										[Entities.PU_Hero1b] = true,
										[Entities.PU_Hero1c] = true,
										[Entities.PU_Hero11] = true,
										[Entities.PU_Hero13] = true,
										[Entities.CU_Mary_de_Mortfichet] = true,
										[Entities.PU_Serf] = true
									}

-- returns entity type base attack speed (not affected by technologies (if there'd be any), just the raw value defined in the respective xml)
---@param _entityType integer entityType
---@return integer attack speed (battle wait until)
function GetEntityTypeBaseAttackSpeed(_entityType)

	assert(_entityType ~= 0 , "invalid entityType")
	if not BS.MemValues.EntityTypeBaseAttackSpeed then
		BS.MemValues.EntityTypeBaseAttackSpeed = {}
	end
	if BS.MemValues.EntityTypeBaseAttackSpeed[_entityType] then
		return BS.MemValues.EntityTypeBaseAttackSpeed[_entityType]
	else
		local behavior_pos
		if not BehaviorExceptionEntityTypeTable[_entityType] then
			if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then
				behavior_pos = 4
			elseif string.find(string.lower(Logic.GetEntityTypeName(_entityType)), "tower") ~= nil then
				behavior_pos = 0
			else
				behavior_pos = 6
			end
		else
			behavior_pos = 8
		end
		BS.MemValues.EntityTypeBaseAttackSpeed[_entityType] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][21]:GetInt()
		return BS.MemValues.EntityTypeBaseAttackSpeed[_entityType]
	end
end

-- returns entity type base attack range (not affected by weather or technologies, just the raw value defined in the respective xml)
---@param _entityType integer entityType
---@return number base attack range
function GetEntityTypeBaseAttackRange(_entityType)

	assert(_entityType ~= 0 , "invalid entityType")
	if not BS.MemValues.EntityTypeBaseAttackRange then
		BS.MemValues.EntityTypeBaseAttackRange = {}
	end
	if BS.MemValues.EntityTypeBaseAttackRange[_entityType] then
		return BS.MemValues.EntityTypeBaseAttackRange[_entityType]
	else
		local behavior_pos
		if not BehaviorExceptionEntityTypeTable[_entityType] then
			if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then
				behavior_pos = 4
			elseif string.find(string.lower(Logic.GetEntityTypeName(_entityType)), "tower") ~= nil then
				behavior_pos = 0
				if CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][0]:GetInt() == tonumber("778CD4", 16) then
					return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][11]:GetFloat()
				end
			else
				behavior_pos = 6
			end
		else
			behavior_pos = 8
		end
		BS.MemValues.EntityTypeBaseAttackRange[_entityType] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][23]:GetFloat()
		return BS.MemValues.EntityTypeBaseAttackRange[_entityType]
	end
end

-- returns entity type min attack range (not affected by weather or technologies, just the raw value defined in the respective xml)
---@param _entityType integer entityType
---@return number min attack range
function GetEntityTypeBaseMinAttackRange(_entityType)

	assert(_entityType ~= 0 , "invalid entityType")
	if not BS.MemValues.EntityTypeBaseMinAttackRange then
		BS.MemValues.EntityTypeBaseMinAttackRange = {}
	end
	if BS.MemValues.EntityTypeBaseMinAttackRange[_entityType] then
		return BS.MemValues.EntityTypeBaseMinAttackRange[_entityType]
	else
		local behavior_pos
		if not BehaviorExceptionEntityTypeTable[_entityType] then
			if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then
				behavior_pos = 4
			elseif string.find(string.lower(Logic.GetEntityTypeName(_entityType)), "tower") ~= nil then
				behavior_pos = 0
				if CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][0]:GetInt() == tonumber("778CD4", 16) then
					return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][12]:GetFloat()
				end
			else
				behavior_pos = 6
			end
		else
			behavior_pos = 8
		end
		BS.MemValues.EntityTypeBaseMinAttackRange[_entityType] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][24]:GetFloat()
		return BS.MemValues.EntityTypeBaseMinAttackRange[_entityType]
	end
end

-- returns entity type max attack range (affected by weather and technologies)
---@param _entity integer entityID
---@param _player integer playerID
---@return number attack range
function GetEntityTypeMaxAttackRange(_entity, _player)

	local entityType = Logic.GetEntityType(_entity)
	local RangeTechBonusFlat
	local RangeTechBonusMultiplier
	--check technology modifiers
	for k,v in pairs(BS.EntityCatModifierTechs.AttackRange) do
		if Logic.IsEntityInCategory(_entity, k) == 1 then
			RangeTechBonusFlat = 0
			RangeTechBonusMultiplier = 1
			for i = 1,table.getn(v) do
				if Logic.GetTechnologyState(_player,v[i]) == 4 then
					local val, op = GetTechnologyAttackRangeModifier(v[i])
					if op == 0 then
						RangeTechBonusMultiplier = RangeTechBonusMultiplier + (val -1)
					elseif op == 1 then
						RangeTechBonusFlat = RangeTechBonusFlat + val
					end
				end
			end
		end
	end

	return GetEntityTypeBaseAttackRange(entityType) + (RangeTechBonusFlat or 0) * (RangeTechBonusMultiplier or 1)
end

-- gets entity type damage range (only use for types with given damage range!)
---@param _entityType integer entityType
---@return number damage range
function GetEntityTypeDamageRange(_entityType)

	assert(_entityType ~= nil, "invalid entityType")
	if not BS.MemValues.EntityTypeDamageRange then
		BS.MemValues.EntityTypeDamageRange = {}
	end
	if BS.MemValues.EntityTypeDamageRange[_entityType] then
		return BS.MemValues.EntityTypeDamageRange[_entityType]
	else
		local behavior_pos
		if not BehaviorExceptionEntityTypeTable[_entityType] then
			if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then
				behavior_pos = 4
			elseif string.find(Logic.GetEntityTypeName(_entityType), "Tower") ~= nil then
				behavior_pos = 0
				if CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][0]:GetInt() == tonumber("778CD4", 16) then
					return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][15]:GetFloat()
				end
			else
				behavior_pos = 6
			end
		else
			behavior_pos = 8
		end
		BS.MemValues.EntityTypeDamageRange[_entityType] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][16]:GetFloat()
		return BS.MemValues.EntityTypeDamageRange[_entityType]
	end
end

-- gets entity type damage class
---@param _entityType integer entityType
---@return integer damage class
function GetEntityTypeDamageClass(_entityType)

	assert(_entityType ~= nil, "invalid entityType")
	if not BS.MemValues.EntityTypeDamageClass then
		BS.MemValues.EntityTypeDamageClass = {}
	end
	if BS.MemValues.EntityTypeDamageClass[_entityType] then
		return BS.MemValues.EntityTypeDamageClass[_entityType]
	else
		local behavior_pos
		if not BehaviorExceptionEntityTypeTable[_entityType] then
			if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then
				behavior_pos = 4
			elseif string.find(string.lower(Logic.GetEntityTypeName(_entityType)), "tower") ~= nil then
				behavior_pos = 0
			else
				behavior_pos = 6
			end
		else
			behavior_pos = 8
		end
		BS.MemValues.EntityTypeDamageClass[_entityType] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][13]:GetInt()
		return BS.MemValues.EntityTypeDamageClass[_entityType]
	end
end

-- gets entity type armor class
---@param _entityType integer entityType
---@return integer armor class
function GetEntityTypeArmorClass(_entityType)
	assert(_entityType ~= nil , "invalid entityType")
	if not BS.MemValues.EntityTypeArmorClass then
		BS.MemValues.EntityTypeArmorClass = {}
	end
	if BS.MemValues.EntityTypeArmorClass[_entityType] then
		return BS.MemValues.EntityTypeArmorClass[_entityType]
	else
		local pointer = GetEntityTypePointer(_entityType)
		local behpos
		if pointer[0]:GetInt() == tonumber("76EC78", 16) then
			behpos = 102
		elseif pointer[0]:GetInt() == tonumber("76E498", 16) then
			behpos = 60
		elseif pointer[0]:GetInt() == tonumber("778148", 16) then
			behpos = 102
		end
		BS.MemValues.EntityTypeArmorClass[_entityType] = pointer[behpos]:GetInt()
		return BS.MemValues.EntityTypeArmorClass[_entityType]
	end
end

-- gets damage factor related to the damageclass/armorclass
---@param _damageclass integer damage class
---@param _armorclass integer armor class
---@return number damage factor
function GetDamageFactor(_damageclass, _armorclass)
	assert(_damageclass > 0 and _damageclass <= 9, "invalid damageclass")
	assert(_armorclass > 0 and _armorclass <= 7, "invalid armorclass")
	return GetDamageModifierPointer()[_damageclass][_armorclass]:GetFloat()
end

-- gets entityType attraction places provided (e.g. village center)
---@param _entityType integer entityType
---@return integer attraction places provided
function GetAttractionPlacesProvided(_entityType)
	assert(_entityType ~= nil , "invalid entityType")
	if not BS.MemValues.EntityTypeAttractionPlacesProvided then
		BS.MemValues.EntityTypeAttractionPlacesProvided = {}
	end
	if BS.MemValues.EntityTypeAttractionPlacesProvided[_entityType] then
		return BS.MemValues.EntityTypeAttractionPlacesProvided[_entityType]
	else
		BS.MemValues.EntityTypeAttractionPlacesProvided[_entityType] = GetEntityTypePointer(_entityType)[44]:GetInt()
		return BS.MemValues.EntityTypeAttractionPlacesProvided[_entityType]
	end
end

-- gets building type blocking properties, returns Blocked1X, Blocked1Y, Blocked2X, Blocked2Y
---@param _entityType integer entityType
---@return table blocking area {X1, Y1, X2, Y2}
function GetBuildingTypeBlockingArea(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.BuildingTypeBlockingArea then
		BS.MemValues.BuildingTypeBlockingArea = {}
	end
	if BS.MemValues.BuildingTypeBlockingArea[_entityType] then
		return unpack(BS.MemValues.BuildingTypeBlockingArea[_entityType])
	else
		BS.MemValues.BuildingTypeBlockingArea[_entityType] = {}
		for i = 1,4 do
			table.insert(BS.MemValues.BuildingTypeBlockingArea[_entityType], GetEntityTypePointer(_entityType)[35][i-1]:GetFloat())
		end
		return unpack(BS.MemValues.BuildingTypeBlockingArea[_entityType])
	end
end

-- gets building type terrain pos properties, returns TerrainPos1X, TerrainPos1Y, TerrainPos2X, TerrainPos2Y
---@param _entityType integer entityType
---@return table terrain pos area {X1, Y1, X2, Y2}
function GetBuildingTypeTerrainPosArea(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.BuildingTypeTerrainPosArea then
		BS.MemValues.BuildingTypeTerrainPosArea = {}
	end
	if BS.MemValues.BuildingTypeTerrainPosArea[_entityType] then
		return unpack(BS.MemValues.BuildingTypeTerrainPosArea[_entityType])
	else
		local pointer = GetEntityTypePointer(_entityType)
		local behpos
		if pointer[0]:GetInt() == tonumber("76EC78", 16) then
			behpos = 37
		elseif pointer[0]:GetInt() == tonumber("76E498", 16) then
			behpos = 37
		elseif pointer[0]:GetInt() == tonumber("778148", 16) then
			behpos = 29
		end
		BS.MemValues.BuildingTypeTerrainPosArea[_entityType] = {}
		for i = 1,4 do
			table.insert(BS.MemValues.BuildingTypeTerrainPosArea[_entityType], pointer[behpos + i]:GetFloat())
		end
		return unpack(BS.MemValues.BuildingTypeTerrainPosArea[_entityType])
	end
end

-- gets building type door pos properties, returns DoorPosX, DoorPosY
---@param _entityType integer entityType
---@return table door pos node {X, Y}
function GetBuildingTypeDoorPos(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.BuildingTypeDoorPos then
		BS.MemValues.BuildingTypeDoorPos = {}
	end
	if BS.MemValues.BuildingTypeDoorPos[_entityType] then
		return unpack(BS.MemValues.BuildingTypeDoorPos[_entityType])
	else
		local pointer = GetEntityTypePointer(_entityType)
		local behpos
		if pointer[0]:GetInt() == tonumber("76EC78", 16) then
			behpos = 45
		elseif pointer[0]:GetInt() == tonumber("76E498", 16) then
			behpos = 45
		elseif pointer[0]:GetInt() == tonumber("778148", 16) then
			behpos = 37
		end
		BS.MemValues.BuildingTypeDoorPos[_entityType] = {}
		for i = 1,2 do
			table.insert(BS.MemValues.BuildingTypeDoorPos[_entityType], pointer[behpos + i]:GetFloat())
		end
		return unpack(BS.MemValues.BuildingTypeDoorPos[_entityType])
	end
end

-- gets building type leave pos properties, returns LeavePosX, LeavePosY
---@param _entityType integer entityType
---@return table leave pos node {X, Y}
function GetBuildingTypeLeavePos(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.BuildingTypeLeavePos then
		BS.MemValues.BuildingTypeLeavePos = {}
	end
	if BS.MemValues.BuildingTypeLeavePos[_entityType] then
		return unpack(BS.MemValues.BuildingTypeLeavePos[_entityType])
	else
		local pointer = GetEntityTypePointer(_entityType)
		local behpos
		if pointer[0]:GetInt() == tonumber("76EC78", 16) then
			behpos = 47
		elseif pointer[0]:GetInt() == tonumber("76E498", 16) then
			behpos = 47
		elseif pointer[0]:GetInt() == tonumber("778148", 16) then
			behpos = 39
		end
		BS.MemValues.BuildingTypeLeavePos[_entityType] = {}
		for i = 1,2 do
			table.insert(BS.MemValues.BuildingTypeLeavePos[_entityType], pointer[behpos + i]:GetFloat())
		end
		return unpack(BS.MemValues.BuildingTypeLeavePos[_entityType])
	end
end

-- gets entity type num blocked points value (block field in s-m x and y)
---@param _entityType integer entityType
---@return integer number blocked points (s-m/grids)
function GetEntityTypeNumBlockedPoints(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.EntityTypeNumBlockedPoints then
		BS.MemValues.EntityTypeNumBlockedPoints = {}
	end
	if BS.MemValues.EntityTypeNumBlockedPoints[_entityType] then
		return BS.MemValues.EntityTypeNumBlockedPoints[_entityType]
	else
		BS.MemValues.EntityTypeNumBlockedPoints[_entityType] = GetEntityTypePointer(_entityType)[22]:GetInt()
		return BS.MemValues.EntityTypeNumBlockedPoints[_entityType]
	end
end

-- gets building type bridge area properties, returns Blocked1X, Blocked1Y, Blocked2X, Blocked2Y
---@param _entityType integer entityType
---@return table blocking area {X1, Y1, X2, Y2}
function GetBuildingTypeBridgeArea(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.BuildingTypeBridgeArea then
		BS.MemValues.BuildingTypeBridgeArea = {}
	end
	if BS.MemValues.BuildingTypeBridgeArea[_entityType] then
		return unpack(BS.MemValues.BuildingTypeBridgeArea[_entityType])
	else
		BS.MemValues.BuildingTypeBridgeArea[_entityType] = {}
		for i = 1,4 do
			table.insert(BS.MemValues.BuildingTypeBridgeArea[_entityType], GetEntityTypePointer(_entityType)[126][i-1]:GetFloat())
		end
		return unpack(BS.MemValues.BuildingTypeBridgeArea[_entityType])
	end
end

-- gets building type bridge height
---@param _entityType integer entityType
---@return integer height
function GetBuildingTypeBridgeHeight(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	if not BS.MemValues.BuildingTypeBridgeHeight then
		BS.MemValues.BuildingTypeBridgeHeight = {}
	end
	if BS.MemValues.BuildingTypeBridgeHeight[_entityType] then
		return BS.MemValues.BuildingTypeBridgeHeight[_entityType]
	else
		BS.MemValues.BuildingTypeBridgeHeight[_entityType] = GetEntityTypePointer(_entityType)[129]:GetInt()
		return BS.MemValues.BuildingTypeBridgeHeight[_entityType]
	end
end

-- gets ability duration (ability must be supported)
-- currently only for ranged effect abilities ((de-)buffs)
---@param _entityType integer entityType
---@param _ability integer AbilityCategory (Abilities.XXX)
---@return integer ability duration in seconds
function GetAbilityDuration(_entityType, _ability)
	assert(_entityType ~= 0, "invalid entity type")
	assert(_ability == Abilities.AbilityRangedEffect, "currently only supports ranged effects e.g. buffs and debuffs")
	if not BS.MemValues.EntityTypeAbilityDuration then
		BS.MemValues.EntityTypeAbilityDuration = {}
	end
	if not BS.MemValues.EntityTypeAbilityDuration[_entityType] then
		BS.MemValues.EntityTypeAbilityDuration[_entityType] = {}
	end
	if BS.MemValues.EntityTypeAbilityDuration[_entityType][_ability] then
		return BS.MemValues.EntityTypeAbilityDuration[_entityType][_ability]
	else
		for i = 2, 10, 2 do
			if CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][8+i][0]:GetInt() == BS.MemValues.VTableByAbility[_ability] then
				BS.MemValues.EntityTypeAbilityDuration[_entityType][_ability] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][8+i][8]:GetInt()
				return BS.MemValues.EntityTypeAbilityDuration[_entityType][_ability]
			end
		end
	end
end

-- gets ability range (ability must be supported)
---@param _entityType integer entityType
---@param _ability integer AbilityCategory (Abilities.XXX)
---@return number ability range in s-cm
function GetAbilityRange(_entityType, _ability)
	assert(_entityType ~= 0, "invalid entity type")
	if _ability == Abilities.AbilityPlaceBomb or _ability == Abilities.AbilityBuildCannon then
		return
	end
	if not BS.MemValues.EntityTypeAbilityRange then
		BS.MemValues.EntityTypeAbilityRange = {}
	end
	if not BS.MemValues.EntityTypeAbilityRange[_entityType] then
		BS.MemValues.EntityTypeAbilityRange[_entityType] = {}
	end
	if BS.MemValues.EntityTypeAbilityRange[_entityType][_ability] then
		return BS.MemValues.EntityTypeAbilityRange[_entityType][_ability]
	else
		local off
		local index = BS.MemValues.IndexByAbility[_ability].Range
		for i = 2, 10, 2 do
			if CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][8+i][0]:GetInt() == BS.MemValues.VTableByAbility[_ability] then
				BS.MemValues.EntityTypeAbilityRange[_entityType][_ability] = CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][8+i][index]:GetFloat()
				return BS.MemValues.EntityTypeAbilityRange[_entityType][_ability]
			end
		end
	end
end
BS.MemValues.IndexByAbility = {	[Abilities.AbilityRangedEffect] = {AffectsDiplomacy = 5, AffectsCat = 6, Range = 7, Duration = 8, DamageFactor = 9, ArmorFactor = 10, HealthRecoveryFactor = 11, Effect = 12, HealEffect = 13},
								[Abilities.AbilityCircularAttack] = {TaskList = 5, Animation = 6, DamageClass = 7, Damage = 8, Range = 9, Effect = 10},
								[Abilities.AbilityInflictFear] = {TaskList = 5, Animation = 6, FlightDuration = 7, Range = 8, FlightRange = 9}}
BS.MemValues.VTableByAbility = {[Abilities.AbilityRangedEffect] = tonumber("774E9C", 16),
								[Abilities.AbilityCircularAttack] = tonumber("7774A0", 16),
								[Abilities.AbilityInflictFear] = tonumber("776674", 16),
								[Abilities.AbilityPlaceBomb] = tonumber("7783D8", 16),
								[Abilities.AbilityBuildCannon] = tonumber("777510", 16)
								}
------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- entity id related --------------------------------------------------------------------------
-- returns settler base movement speed (not affected by weather or technologies, just the raw value defined in the respective xml)
---@param _entityID integer entityID
---@return number settler base movement speed
function GetSettlerBaseMovementSpeed(_entityID)

	assert(IsValid(_entityID), "invalid entityID")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[31][1][5]:GetFloat()

end

-- sets settler base movement speed (not affected by weather or technologies, just the raw value defined in the respective xml)
---@param _entityID integer entityID
---@param _val number base movement speed
---@return number settler base movement speed
function SetSettlerBaseMovementSpeed(_entityID, _val)

	assert(IsValid(_entityID), "invalid entityID")
	assert(type(_val) == "number", "value input needs to be a number")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[31][1][5]:SetFloat(_val)

end
BS.EntityCatModifierTechs = {["Speed"] = {	[EntityCategories.Hero] = {Technologies.T_HeroicShoes},
											[EntityCategories.Serf] = {Technologies.T_Shoes, Technologies.T_Alacricity},
											[EntityCategories.Bow] = {Technologies.T_BetterTrainingArchery},
											[EntityCategories.Rifle] = {Technologies.T_BetterTrainingArchery},
											[EntityCategories.Sword] = {Technologies.T_BetterTrainingBarracks},
											[EntityCategories.Spear] = {Technologies.T_BetterTrainingBarracks},
											[EntityCategories.CavalryHeavy] = {Technologies.T_Shoeing},
											[EntityCategories.CavalryLight] = {Technologies.T_Shoeing},
											[EntityCategories.Cannon] = {Technologies.T_BetterChassis},
											[EntityCategories.Thief] = {Technologies.T_Agility, Technologies.T_Chest_ThiefBuff}
											},
							["AttackRange"] = {	[EntityCategories.Bow] = {Technologies.T_Fletching},
												[EntityCategories.CavalryLight] = {Technologies.T_Fletching},
												[EntityCategories.Rifle] = {Technologies.T_Sights}
												}
							}

-- return settler movement speed
---@param _entityID integer entityID
---@param _player integer playerID
---@return number settler current movement speed
function GetSettlerCurrentMovementSpeed(_entityID, _player)

	local BaseSpeed = round(GetSettlerBaseMovementSpeed(_entityID))
	local SpeedTechBonus, SpeedHeroMultiplier
	local SpeedWeatherFactor = GetWeatherSpeedModifier(Logic.GetWeatherState())

	--Check auf Technologie Modifikatoren
	for k,v in pairs(BS.EntityCatModifierTechs.Speed) do

		if Logic.IsEntityInCategory(_entityID, k) == 1 then
			SpeedTechBonus = 0
			SpeedHeroMultiplier = 1
			for i = 1,table.getn(v) do

				if Logic.GetTechnologyState(_player,v[i]) == 4 then

					local val, op = GetTechnologySpeedModifier(v[i])
					if op == 0 then
						SpeedHeroMultiplier = SpeedHeroMultiplier + (val -1)
					elseif op == 1 then
						SpeedTechBonus = SpeedTechBonus + val
					end
				end
			end
		end
	end
	return (BaseSpeed + (SpeedTechBonus or 0)) * (SpeedWeatherFactor or 1) * (SpeedHeroMultiplier or 1)
end

-- get the current task, logic cant return animal tasks, returns number, not string
---@param _entityID integer entityID
---@return integer entity current tasklist
function GetEntityCurrentTask(_entityID)
	assert(IsValid(_entityID) , "invalid entityID")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[36]:GetInt()
end

-- set entity current task
---@param _entityID integer entityID
---@param _num integer tasklist ID
---@return integer entity current tasklist
function SetEntityCurrentTask(_entityID, _num)
	assert(IsValid(_entityID) , "invalid entityID")
	assert(type(_num) == "number", "task needs to be a number")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[36]:SetInt(_num)
end

-- get entity current task sub-index
---@param _entityID integer entityID
---@return integer entity current task index
function GetEntityCurrentTaskIndex(_entityID)
	assert(IsValid(_entityID) , "invalid entityID" )
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[37]:GetInt()
end

-- set entity current task sub-index
---@param _entityID integer entityID
---@param _index integer task index
---@return integer entity current task index
function SetEntityCurrentTaskIndex(_entityID, _index)
	assert(IsValid(_entityID) , "invalid entityID")
	assert(type(_index) == "number", "index needs to be a number")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[37]:SetInt(_index)
end

-- get entity size (relative to 1)
---@param _entityID integer entityID
---@return number entity size (factor relative to 1)
function GetEntitySize(_entityID)
	assert(IsValid(_entityID) , "invalid entityID")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[25]:GetFloat()
end

-- set entity size (relative to 1)
---@param _entityID integer entityID
---@param _size entity size
function SetEntitySize(_entityID, _size)
	assert(IsValid(_entityID) , "invalid entityID")
	assert(type(_size) == "number", "size needs to be a number")
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[25]:SetFloat(_size)
end

-- gets entity current used model
---@param _entityID integer entityID
---@return integer model id
function GetEntityModel(_entityID)
	assert(IsValid(_entityID) , "invalid entityID")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[5]:GetInt()
end

-- set entity model (gets resetted when task changes)
---@param _entityID integer entityID
---@param _id model id
function SetEntityModel(_entityID, _id)
	assert(IsValid(_entityID) , "invalid entityID")
	assert(type(_id) == "number", "model id needs to be a number")
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[5]:SetInt(_id)
end

-- get max number of military building train slots (default 3)
---@param _entityID integer entityID
---@return integer train slots
function GetMilitaryBuildingMaxTrainSlots(_entityID)
	assert(IsValid(_entityID) , "invalid entityID")
	assert(Logic.IsEntityInCategory(_entityID, EntityCategories.MilitaryBuilding) == 1, "entity is no military building")
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[31][2][3][7]:GetInt()
end

gvVisibilityStates = {	[0] = 257,
						[1] = 513,
						[2] = 65793,
						[3] = 65792
					}
-- get visibility of entity (0=invisible, 1=invisible and suspended, 2=visible, 3 = visible and suspended?)
---@param _entityID integer entityID
---@return integer visibility state
function GetEntityVisibility(_entityID)
	assert(IsValid(_entityID) , "invalid entityID")
	for k,v in pairs(gvVisibilityStates) do
		if Logic.GetEntityScriptingValue(_entityID, -30) == v then
			return k
		end
	end
end

-- changes visibility of entity (_flag: 0 = invisible, 1 = visible, -1 = toggle)
---@param _entityID integer entityID
---@param _flag integer visibility state
function SetEntityVisibility(_entityID, _flag)
	assert(IsValid(_entityID) , "invalid entityID")
	assert(type(_flag) == "number" and _flag >= -1 and _flag <= 3, "visibility flag needs to be a number (either 0, 1 or -1")
	Logic.SetEntityScriptingValue(_entityID, -30, gvVisibilityStates[_flag] or math.abs(gvVisibilityStates[GetEntityVisibility(_entityID)]-1))
end

-- get mercenary camp offers left by slot
---@param _id integer mercenary camp entityID
---@param _slot integer offer slot (0-3)
---@return integer offers left
function GetMercenaryOfferLeft(_id, _slot)
    assert(IsValid(_id), "invalid entityID")
    local sv = CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_id))
    local vtable = tonumber("7782C0", 16)
    local number = (sv[32]:GetInt() - sv[31]:GetInt()) / 4
    for i=0,number-1 do
        if sv[31][i]:GetInt()>0 and sv[31][i][0]:GetInt()==vtable then
            local sv2 = sv[31][i]
            local number2 = (sv2[8]:GetInt() - sv2[7]:GetInt()) / 4
            assert(number2 >= _slot, "slot invalid")
            return sv2[7][_slot][19]:GetInt()
        end
    end
    assert(false, "behavior not found")
end

-- set mercenary camp offers left by slot
---@param _id integer mercenary camp entityID
---@param _slot integer offer slot (0-3)
---@param _left integer offers left
function SetMercenaryOfferLeft(_id, _slot, _left)
    assert(IsValid(_id), "invalid entityID")
    local sv = CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_id))
    local vtable = tonumber("7782C0", 16)
    local number = (sv[32]:GetInt() - sv[31]:GetInt()) / 4
    for i=0,number-1 do
        if sv[31][i]:GetInt()>0 and sv[31][i][0]:GetInt()==vtable then
            local sv2 = sv[31][i]
            local number2 = (sv2[8]:GetInt() - sv2[7]:GetInt()) / 4
            assert(number2 >= _slot, "slot invalid")
            sv2[7][_slot][19]:SetInt(_left)
            return
        end
    end
    assert(false, "behavior not found")
end

-- gets entityID BattleWaitUntil remaining
---@param _id integer entityID
---@return integer BattleWaitUntil remaining
function GetEntityBattleWaitUntilRemaining(_id)
	assert(IsValid(_id), "invalid entityID")
	local beh = CUtil.GetBehaviour(_id, tonumber("7761E0", 16))
	local num = CUtilMemory.GetMemory(tonumber(beh,16))[21]:GetInt()
	return num
end

-- gets entityID Stamina remaining
---@param _id integer entityID (must be a worker)
---@return integer Stamina remaining
function GetStamina(_id)
	assert(IsValid(_id) and Logic.IsEntityInCategory(_id, EntityCategories.Worker) == 1, "entityID must be a worker")
	return CEntity.GetCurrentStamina(_id)
end

-- sets entityID Stamina remaining
---@param _id integer entityID (must be a worker)
---@param _val integer Stamina remaining
function SetStamina(_id, _val)
	assert(IsValid(_id) and Logic.IsEntityInCategory(_id, EntityCategories.Worker) == 1, "entityID must be a worker")
	assert(type(_val) == "number" and _val > 0, "stamina value must be a non-negative number")
	--GGL_CWorkerBehavior
	local beh = CUtil.GetBehaviour(_id, tonumber("772B30", 16))
	local stam = CUtilMemory.GetMemory(tonumber(beh,16))[4]:SetInt(_val)
end

-- adds value to entityIDs Stamina remaining
---@param _id integer entityID (must be a worker)
---@param _val integer Stamina to be added
function AddStamina(_id, _val)
	assert(IsValid(_id) and Logic.IsEntityInCategory(_id, EntityCategories.Worker) == 1, "entityID must be a worker")
	assert(type(_val) == "number", "stamina value must be a number")
	SetStamina(_id, math.max(0, GetStamina(_id) + _val))
end

-- gets ability convert settler target (e.g. Helias)
---@param _heroID integer entityID
---@return integer target entityID
function GetConvertSettlersTarget(_heroID)
	local t = CEntity.GetReversedAttachedEntities(_heroID)
	return (next(t) and t[62] and t[62][1])
end

-- gets entity's current attack target
---@param _id integer entityID
---@return integer target entityID
function GetEntityCurrentTarget(_id)
	assert(IsValid(_id), "invalid entityID")
	local t = CEntity.GetReversedAttachedEntities(_id)
	if next(t) then
		return (t[32] and t[32][1]) or (t[35] and t[35][1]) or (t[51] and t[51][1])
	end
end

-- gets entity's current attack target based off army data
-- entityID needs to be a leader and part of an active army
---@param _id integer entityID
---@return integer target entityID
function GetEntityTargetByAIData(_id)
	assert(IsValid(_id), "invalid entityID")
	local player = Logic.EntityGetPlayer(_id)
	local army = GetArmyByLeaderID(_id)
	assert(army ~= nil, "entity is not part of an army. Aborting")
	local tab
	if type(army) == "string" then
		tab = MapEditor_Armies[player][army]
	elseif type(army) == "number" then
		tab = ArmyTable[player][army]
	end
	local target = tab[_id].currenttarget
	if target and IsValid(target) then
		local t = CEntity.GetAttachedEntities(target)
		if table_findvalue(t, _id) ~= 0 then
			return target
		end
	end
end

function TeleportSettler(_id, _posX, _posY)
	assert(IsValid(_id) and Logic.IsSettler(_id) == 1, "invalid entityID")
	--[[ set current position
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_id))[22]:SetFloat(_posX)
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_id))[23]:SetFloat(_posY)
	-- set target position
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_id))[66]:SetFloat(_posX)
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_id))[67]:SetFloat(_posY)]]
	CUtil.EntitySetPosition(_id, _posX, _posY)
	if not Logic.IsEntityAlive(_id) then
		--GGL_CLeaderMovement; set "last turn pos" to port pos
		local beh = tonumber(CUtil.GetBehaviour(_id, tonumber("775ED4", 16)), 16)
		CUtilMemory.GetMemory(beh)[12]:SetFloat(_posX)
		CUtilMemory.GetMemory(beh)[13]:SetFloat(_posY)
		--Logic.SuspendEntity(_id)
		--Logic.ResumeEntity(_id)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- statistics -----------------------------------------------------------------------------
-- gets player kill statistics (0: settlers killed, 1: settlers lost, 2: buildings destroyed, 3: buildings lost)
---@param _playerID integer playerID
---@param _statistic integer statistic type
---@return integer statistic points
function GetPlayerKillStatisticsProperties(_playerID, _statistic)
	assert(type(_playerID) == "number", "PlayerID needs to be a number")
	assert(_playerID > 0 and _playerID < 17, "invalid PlayerID")
	assert(type(_statistic) == "number", "Statistic type needs to be a number")
	assert(_statistic >= 0 and _statistic <= 3, "invalid statistic type")
	return GetPlayerStatusPointer(_playerID)[82 + _statistic]:GetInt()
end

-- sets player kill statistics (0: settlers killed, 1: settlers lost, 2: buildings destroyed, 3: buildings lost)
---@param _playerID integer playerID
---@param _statistic integer statistic type
---@param _value integer statistic points
---@return integer statistic points
function SetPlayerKillStatisticsProperties(_playerID, _statistic, _value)
	assert(type(_playerID) == "number", "PlayerID needs to be a number")
	assert(_playerID > 0 and _playerID < 17, "invalid PlayerID")
	assert(type(_statistic) == "number", "Statistic type needs to be a number")
	assert(_statistic >= 0 and _statistic <= 3, "invalid statistic type")
	assert(type(_value) == "number", "Value needs to be a number")
	return GetPlayerStatusPointer(_playerID)[82 + _statistic]:SetInt(_value)
end

-- adds value to respective player kill statistic (0: settlers killed, 1: settlers lost, 2: buildings destroyed, 3: buildings lost)
---@param _playerID integer playerID
---@param _statistic integer statistic type
---@param _value integer statistic points
---@return integer statistic points
function AddValueToPlayerKillStatistic(_playerID, _statistic, _value)
	assert(type(_playerID) == "number", "PlayerID needs to be a number")
	assert(_playerID > 0 and _playerID < 17, "invalid PlayerID")
	assert(type(_statistic) == "number", "Statistic type needs to be a number")
	assert(_statistic >= 0 and _statistic <= 3, "invalid statistic type")
	assert(type(_value) == "number", "Value needs to be a number")
	local currstat = GetPlayerKillStatisticsProperties(_playerID, _statistic)
	return SetPlayerKillStatisticsProperties(_playerID, _statistic, currstat + _value)
end
---------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------- army related ----------------------------------------------------------------------
function GetArmyPlayerObjectLength()
	local vstart = CUtilMemory.GetMemory(tonumber("0x8539D4", 16))[0][1][1]:GetInt()
	local vend = CUtilMemory.GetMemory(tonumber("0x8539D4", 16))[0][1][2]:GetInt()
	return (vend - vstart) / 4
end
function GetArmyPlayerObjectOffset(_playerID)
	local adress = GetArmyObjectPointer()
	local playerOffset
	for i = 1, GetArmyPlayerObjectLength() do
		if adress[i-1][5]:GetInt() == _playerID then
			playerOffset = i-1
			break
		end
	end
	return playerOffset
end

-- sets entity attached to army active flag (default activated anyway)
---@param _id integer entityID
---@param _flag integer active flag (0 = deactivated, 1 = activated)
function AI.Army_SetEntityActiveFlag(_id, _flag)
	assert(IsValid(_id))
	assert(_flag == 0 or _flag == 1)
	local adress = CUtilMemory.GetMemory(tonumber("0x8539D4", 16))[0][1][6]
	for i = 1, 10 do
		if adress[i-1]:GetInt() ~= 0 then
			for k = 1, 20 do
				if adress[i-1][0+(48*(k-1))]:GetInt() == tonumber("0x766A70", 16) and adress[i-1][1+(48*(k-1))]:GetInt() == tonumber("0x853B74", 16) then
					LuaDebugger.Break()
					if adress[i-1][4+(48*(k-1))]:GetInt() == _id then
						adress[i-1][13+(48*(k-1))]:SetInt(_flag)
						return
					end
				end
			end
		end
	end
end

--AI.Army_GetOccupancyRate(_player, _armyId) %-Wert alive-slots/gesamt-slots
-- gets first army slot of player with free troop slots
---@param _playerID integer playerID
---@return integer AI army slot
function AI.Army_GetNextFreeSlot(_playerID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0, "player is human. Aborting")
	local slot
	local tabname = MapEditor_Armies[_playerID] or ArmyTable[_playerID]
	for i = 9, 1, -1 do
		if AI.Army_GetOccupancyRate(_playerID, i - 1) < 100 then
			if tabname[i] and tabname[i].id then
				slot = i - 1
				break
			end
		end
	end
	return slot or false
end

-- gets all leader IDs in AI army
---@param _playerID integer playerID
---@param _armyID integer armyID
---@return table entity IDs table
function AI.Army_GetLeaderIDs(_playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0, "player is human. Aborting")
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
	local offsets = {50, 51, 56, 57, 62, 63, 68, 69}
	local adress = GetArmyObjectPointer()
	local tab = {}
	local playerOffset = GetArmyPlayerObjectOffset(_playerID)

	for k = 1, table.getn(offsets) do
		local id = adress[playerOffset][40 + offsets[k] + (_armyID *84)]:GetInt()
		if id > 0 then
			table.insert(tab, id)
		end
	end
	return tab
end

-- remove leader from army
---@param _id integer entityID
---@param _playerID integer playerID
---@param _armyID integer armyID
function AI.Entity_RemoveFromArmy(_id, _playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0, "player is human. Aborting")
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
	assert(IsValid(_id), "invalid entityID")
	local offsets = {50, 51, 56, 57, 62, 63, 68, 69}
	local adress = GetArmyObjectPointer()
	local playerOffset = GetArmyPlayerObjectOffset(_playerID)

	for k = 1, table.getn(offsets) do
		local id = adress[playerOffset][40 + offsets[k] + (_armyID *84)]:GetInt()
		if id == _id then
			adress[playerOffset][40 + offsets[k] + (_armyID *84)]:SetInt(0)
			break
		end
	end
	AI.Entity_ConnectLeader(_id, -1)
	AI.Army_SetEntityActiveFlag(_id, 0)
end

-- add leader to army
---@param _id integer entityID
---@param _playerID integer playerID
---@param _armyID integer armyID
function AI.Entity_AddToArmy(_id, _playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0, "player is human. Aborting")
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
	assert(IsValid(_id), "invalid entityID")
	local offsets = {50, 51, 56, 57, 62, 63, 68, 69}
	local adress = GetArmyObjectPointer()
	local playerOffset = GetArmyPlayerObjectOffset(_playerID)

	for k = 1, table.getn(offsets) do
		local id = adress[playerOffset][40 + offsets[k] + (_armyID *84)]:GetInt()
		if id == 0 then
			adress[playerOffset][40 + offsets[k] + (_armyID *84)]:SetInt(_id)
			break
		end
	end
	AI.Entity_ConnectLeader(_id, _armyID)
end

-- get army's internal ID
---@param _playerID integer playerID
---@param _armyID integer armyID
---@return integer internal armyID
function AI.Army_GetInternalID(_playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0, "player is human. Aborting")
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
	local adress = GetArmyObjectPointer()
	local playerOffset = GetArmyPlayerObjectOffset(_playerID)
	return adress[playerOffset][40 + 3 + (_armyID *84)]:GetInt()
end
---------------------------------------------------------------------------------------------------------------------------------
-- calculate estimated damage dealt by attacker to target by damageclass/armorclass (does not include random damage)
---@param _attacker integer attacker entityID
---@param _target integer target entityID
---@return number damage
function CalculateTotalDamage(_attacker, _target)
	local base = Logic.GetEntityDamage(_attacker)
	local armor = Logic.GetEntityArmor(_target)
	local atype, ttype = Logic.GetEntityType(_attacker), Logic.GetEntityType(_target)
	local dclass = GetEntityTypeDamageClass(atype)
	local aclass = GetEntityTypeArmorClass(ttype)
	local factor = GetDamageFactor(dclass, aclass)
	return math.max(round(base * factor) - armor, 1)
end

-- rounding comfort
---@param _n number number to be rounded
---@return number number
function round(_n)
	assert(type(_n) == "number", "round val needs to be a number")
	return math.floor( _n + 0.5 )
end

-- rounding comfort to next 100 step
---@param _n number number to be rounded
---@return number number
function dekaround(_n)
	assert(type(_n) == "number", "round val needs to be a number")
	return math.floor( _n / 100 + 0.5 ) * 100
end

-- creating cost table for leaders to be upgraded
---@param _player integer playerID
---@param _ltype1 integer lower leaderType to be upgraded
---@param _ltype2 integer upper leaderType (upgraded)
---@param _stype1 integer lower soldierType to be upgraded
---@param _stype2 integer upper soldierType (upgraded)
---@param _numsol integer total number of soldiers
---@return number number
function CreateCostDifferenceTable(_player, _ltype1, _ltype2, _stype1, _stype2, _numsol)
	local lcost, solcost, uplcost, upsolcost = {},{},{},{}
	local cost = {}
	for i = 1, 17 do
		cost[i] = 0
	end
	Logic.FillLeaderCostsTable(_player, _ltype1 + 2 ^ 16, lcost)
	Logic.FillLeaderCostsTable(_player, _ltype2 + 2 ^ 16, uplcost)
	Logic.FillSoldierCostsTable(_player, _stype1 + 2 ^ 16, solcost)
	Logic.FillSoldierCostsTable(_player, _stype2 + 2 ^ 16, upsolcost)
	for i = 1, 17 do
		if lcost[i] > 0 or uplcost[i] > 0 or solcost[i] > 0 or upsolcost[i] > 0 then
			cost[i] = uplcost[i] - lcost[i] + ((upsolcost[i] - solcost[i]) * _numsol)
			cost[i] = math.max(cost[i], 0)
		end
	end
	return cost
end

-- get entity ID's nearest appropiate military building
---@param _playerId integer playerID
---@param _id integer entityID
---@return integer entityID
function GetNearestBarracks(_playerId, _id)
	local ucat = GetUpgradeCategoryByEntityID(_id)
	local btype
	for k, v in pairs(BS.CategoriesInMilitaryBuilding) do
		for i = 1, table.getn(v) do
			if v[i] == ucat then
				btype = k
				break
			end
		end
	end
	if not btype then
		return 0
	end
	local bt = {}
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId), CEntityIterator.OfAnyTypeFilter(Entities["PB_".. btype .."1"], Entities["PB_".. btype .."2"])) do
		table.insert(bt, {id = eID, dist = GetDistance(_id, eID)})
	end
	table.sort(bt, function(p1, p2)
		return p1.dist < p2.dist
	end)
	if bt[1] and bt[1].id then
		return bt[1].id
	else
		return 0
	end
end
BS.UCatByType = {}

-- gets upgrade category by entity type
---@param _type integer EntityType
---@param _flag boolean is EntityType a building? (true for building, false for settler)
---@return integer upgradeCategory
function GetUpgradeCategoryByEntityType(_type, _flag)
	if _flag then
		return Logic.GetUpgradeCategoryByBuildingType(_type)
	end
	if not BS.UCatByType[_type] then
		for k, v in pairs(UpgradeCategories) do
			local t = {Logic.GetSettlerTypesInUpgradeCategory(v)}
			for i = 2, t[1]+1 do
				BS.UCatByType[t[i]] = v
			end
		end
	end
	return BS.UCatByType[_type]
end

-- gets upgrade category by entityID
---@param _id integer entityID
---@return integer upgradeCategory
function GetUpgradeCategoryByEntityID(_id)
	local building = (Logic.IsBuilding(_id) == 1)
	local type = Logic.GetEntityType(_id)
	return GetUpgradeCategoryByEntityType(type, building)
end

-- gets upgrade category by leaderID
---@param _id integer leader entityID
---@return integer upgradeCategory
function GetUpgradeCategoryByLeaderID(_id)
	local soldiertype = Logic.LeaderGetSoldiersType(_id)
	return Logic.LeaderGetUpgradeCategoryFromSoldierType(Logic.EntityGetPlayer(_id), soldiertype) - 1
end

CategoriesOfEntities = {}

-- gets all entityCategories of given entityID
---@param _id integer entityID
---@return table table filled with entityCategories
function GetAllCategoriesOfEntity(_id)
    local type = Logic.GetEntityType(_id)
    if not CategoriesOfEntities[type] then
        local cats = {}
        for k, v in pairs(EntityCategories) do
            if Logic.IsEntityInCategory(_id, v) == 1 then
                cats[v] = true
            end
        end
        CategoriesOfEntities[type] = cats
    end

    return CategoriesOfEntities[type]
end

-- gets all entity types in given entityCategory
---@param _entityCat integer entityCategory
---@return table table filled with entity types
GetAllEntityTypesInEntityCategory = function(_entityCat)
	local tab = {}
	for k, v in pairs(Entities) do
		if Logic.IsEntityTypeInCategory(v, _entityCat) == 1 then
			table.insert(tab, v)
		end
	end
	return tab
end

-- gets all player entities in given entityCategory
---@param _playerID integer playerID
---@param _entityCat integer entityCategory
---@return table table filled with entity IDs
GetAllPlayerEntitiesOfCategory = function(_playerID, _entityCat)
	local eTypes = GetAllEntityTypesInEntityCategory(_entityCat)
	local playerEntities = {}
	for i = 1, table.getn(eTypes) do
		local n,eID = Logic.GetPlayerEntities(_playerID, eTypes[i], 1)
		if (n > 0) then
			local firstEntity = eID
			repeat
				table.insert(playerEntities,eID)
				eID = Logic.GetNextEntityOfPlayerOfType(eID)
			until (firstEntity == eID)
		end
	end
	return playerEntities
end

-- gets entities of player (optional filtered by entityType)
---@param _playerID integer playerID
---@param _entityType integer? entityType (optional)
---@return table table filled with entity IDs
function GetPlayerEntities(_playerID, _entityType)
	local playerEntities = {}
	if _entityType ~= nil then
		local n,eID = Logic.GetPlayerEntities(_playerID, _entityType, 1)
		if (n > 0) then
			local firstEntity = eID
			repeat
				table.insert(playerEntities,eID)
				eID = Logic.GetNextEntityOfPlayerOfType(eID)
			until (firstEntity == eID)
		end
		return playerEntities
	else
		for k,v in pairs(Entities) do
			if not string.find(tostring(k), "XD_", 1, true) and
			not string.find(tostring(k), "XA_", 1, true) and
			not string.find(tostring(k), "XS_", 1, true) then
			local n,eID = Logic.GetPlayerEntities(_playerID, v, 1)
				if (n > 0) then
					local firstEntity = eID
					repeat
						table.insert(playerEntities,eID)
						eID = Logic.GetNextEntityOfPlayerOfType(eID)
					until (firstEntity == eID)
				end
			end
		end
		return playerEntities
	end
end

-- comfort to remove village centers and save data into a table
function RemoveVillageCenters()
	StartVillageCenters = {{},{},{}}
	local vcId
	local entities
	for i = 1,3 do
		for k = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
			entities = GetPlayerEntities(k, Entities["PB_VillageCenter"..i])
			for x = 1, table.getn(entities) do
				table.insert(StartVillageCenters[i], entities[x])
			end
		end
		for j = 1, table.getn(StartVillageCenters[i]) do
			vcId = StartVillageCenters[i][j]
			StartVillageCenters[i][j] = {
				EntityType = Logic.GetEntityType(vcId),
				Position = GetPosition(vcId),
				playerId = GetPlayer(vcId),
				Rotation = Logic.GetEntityOrientation(vcId),
				Name = Logic.GetEntityName(vcId),
			}
			DestroyEntity(vcId)
		end
	end
end

-- comfort to recreate village centers (also look at RemoveVillageCenters())
function RecreateVillageCenters()
	local vcdata, eId
	for i = 1,3 do
		for j = 1, table.getn(StartVillageCenters[i]) do
			vcdata = StartVillageCenters[i][j]
			SetEntityName(Logic.CreateEntity(vcdata.EntityType, vcdata.Position.X, vcdata.Position.Y, vcdata.Rotation, vcdata.PlayerId), vcdata.Name)
		end
	end
end

-- comfort to make all player entities non selectable
function SetPlayerEntitiesNonSelectable()
	StartAllPlayerEntities = {}
	local eId
	local IsHeadquarter = function(_eId)
		local eType = Logic.GetEntityType(_eId)
		return eType == Entities.PB_Headquarters1 or
			   eType == Entities.PB_Headquarters2 or
			   eType == Entities.PB_Headquarters3
	end
	for k = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		StartAllPlayerEntities[k] = GetPlayerEntities(k)
		for i = 1, table.getn(StartAllPlayerEntities[k]) do
			eId = StartAllPlayerEntities[k][i]
			if not IsHeadquarter(eId) then
				Logic.SetEntitySelectableFlag(StartAllPlayerEntities[k][i], 0)
			end
		end
	end
end

-- comfort to make all player entities non selectable (also look at SetPlayerEntitiesNonSelectable())
function SetPlayerEntitiesSelectable()
	for k = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		StartAllPlayerEntities[k] = GetPlayerEntities(k)
		for i = 1, table.getn(StartAllPlayerEntities[k]) do
			Logic.SetEntitySelectableFlag(StartAllPlayerEntities[k][i], 1)
		end
	end
end

-- comfort to increase kill statistic by 1
---@param _attackerPID integer playerID of attacker
---@param _targetPID integer playerID of target
---@param _scoretype string "Settler" in case settler was killed; "Building" in case building was destroyed
function BS.ManualUpdate_KillScore(_attackerPID, _targetPID, _scoretype)
	if Logic.GetDiplomacyState(_attackerPID, _targetPID) == Diplomacy.Hostile then
		if _scoretype == "Settler" then
			GameCallback_SettlerKilled(_attackerPID, _targetPID)
			AddValueToPlayerKillStatistic(_attackerPID, 0, 1)
			AddValueToPlayerKillStatistic(_targetPID, 1, 1)
			if ExtendedStatistics then
				if _attackerPID > 0 and _targetPID > 0 then
					ExtendedStatistics.Players[_attackerPID].Kills = ExtendedStatistics.Players[_attackerPID].Kills + 1
					ExtendedStatistics.Players[_targetPID].Losses = ExtendedStatistics.Players[_targetPID].Losses + 1
				end
			end
		elseif _scoretype == "Building" then
			GameCallback_BuildingDestroyed(_attackerPID, _targetPID)
			AddValueToPlayerKillStatistic(_attackerPID, 2, 1)
			AddValueToPlayerKillStatistic(_targetPID, 3, 1)
		end
	end
end

-- comfort to increase entity max damage dealt
---@param _heroID integer entityID of hurter
---@param _damage number damage dealt
---@param _maxdmg number upper limit for damage dealt
---@param _scoretype string "Settler" in case settler was killed; "Building" in case building was destroyed
function BS.ManualUpdate_DamageDealt(_heroID, _damage, _maxdmg, _scoretype)
	local playerID = Logic.EntityGetPlayer(_heroID)
	ExtendedStatistics.Players[playerID][_scoretype] = ExtendedStatistics.Players[playerID][_scoretype] + (math.min(_damage, _maxdmg))
	ExtendedStatistics.Players[playerID]["Damage"] = ExtendedStatistics.Players[playerID]["Damage"] + (math.min(_damage, _maxdmg))
	ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(_damage, _maxdmg))
	ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage, ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage_T[_heroID])
end

-- gets all playerIDs hostile to given playerID
---@param _playerID integer playerID
---@return table table filled with playerIDs
BS.GetAllEnemyPlayerIDs = function(_playerID)

	local playerIDTable = {}
	local maxplayers

	if CNetwork then
		maxplayers = 16
	else
		maxplayers = 8
	end

	for i = 1, maxplayers do
		if Logic.GetDiplomacyState(i, _playerID) == Diplomacy.Hostile then
			table.insert(playerIDTable, i)
		end
	end

	return playerIDTable

end

-- gets all playerIDs friendly to given playerID
---@param _playerID integer playerID
---@return table table filled with playerIDs
BS.GetAllAlliedPlayerIDs = function(_playerID)

	local playerIDTable = {}
	local maxplayers

	if CNetwork then
		maxplayers = 16
	else
		maxplayers = 8
	end

	for i = 1, maxplayers do
		if Logic.GetDiplomacyState(i, _playerID) == Diplomacy.Friendly then
			table.insert(playerIDTable, i)
		end
	end

	return playerIDTable

end

-- gets nearest hostile building in given range of given entity
---@param _entity integer entityID
---@param _range number maximum search range (should be equal or lower than entity's attack range)
---@return integer entityID of nearest hostile building
BS.CheckForNearestHostileBuildingInAttackRange = function(_entity, _range)

	if not Logic.IsEntityAlive(_entity) then
		return
	end

	local playerID = Logic.EntityGetPlayer(_entity)
	local posX, posY = Logic.GetEntityPosition(_entity)
	local distancepow2table	= {}

	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(BS.GetAllEnemyPlayerIDs(playerID))), CEntityIterator.IsBuildingFilter(), CEntityIterator.InCircleFilter(posX, posY, _range)) do
		if Logic.IsEntityInCategory(eID, EntityCategories.Wall) == 0 and not IsInappropiateBuilding(eID) then
			local _X, _Y = Logic.GetEntityPosition(eID)
			local distancepow2 = (_X - posX)^2 + (_Y - posY)^2
			if Logic.GetFoundationTop(eID) ~= 0 or Logic.IsEntityInCategory(eID, EntityCategories.Bridge) == 1 then
				distancepow2 = distancepow2 / 2
			end
			table.insert(distancepow2table, {id = eID, dist = distancepow2})
		end
	end

	table.sort(distancepow2table, function(p1, p2)
		return p1.dist < p2.dist
	end)

	return (distancepow2table[1] and distancepow2table[1].id)

end
BS.GetTableStrByHeroType = function(_type)

	local typename = Logic.GetEntityTypeName(_type)
	local s, e = string.find(typename, "Hero")
	if s and e ~= string.len(typename) then
		return string.sub(typename, s)
	else
		return "Hero9"
	end
end
gvHQTypeTable = {	[Entities.PB_Headquarters1] = true,
					[Entities.PB_Headquarters2] = true,
					[Entities.PB_Headquarters3] = true,
					[Entities.PB_Outpost1] = true,
					[Entities.PB_Outpost2] = true,
					[Entities.PB_Outpost3] = true,
					[Entities.PB_Castle1] = true,
					[Entities.PB_Castle2] = true,
					[Entities.PB_Castle3] = true,
					[Entities.PB_Castle4] = true,
					[Entities.PB_Castle5] = true
				}

-- returns if building id is either a hero ability building (e.g. salim trap) or a construction site and thus inappropiate for certain purposes
---@param _id integer entityID of building
---@return boolean
function IsInappropiateBuilding(_id)
	local str = string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(_id)))
	return (string.find(str, "hero") ~= nil or string.find(str, "zb") ~= nil)
end

-- table to save damage factor data
DamageFactorToArmorClass = {}
for i = 1,9 do
	DamageFactorToArmorClass[i] = {}
	for k = 1,7 do
		DamageFactorToArmorClass[i][k] = GetDamageFactor(i, k)
	end
end

-- creates randomly generated gathering spots for leaders of a certain army
---@param _player integer playerID
---@param _pos table positionTable
---@param _army integer? armyID + 1 (only needed for spawn armies; nil for recruiting armies)
EvaluateArmyHomespots = function(_player, _pos, _army)
	assert(type(_pos) == "table" and _pos.X and _pos.Y, "pos param needs to be a table filled with X and Y pos")
	if not ArmyHomespots then
		ArmyHomespots = {}
	end
	if not ArmyHomespots[_player] then
		ArmyHomespots[_player] = {}
	end
	_pos.X, _pos.Y = dekaround(_pos.X), dekaround(_pos.Y)
	local sec, id = 0, Logic.GetEntityAtPosition(_pos.X, _pos.Y)
	if id > 0 then
		sec = Logic.GetSector(id)
	else
		sec = CUtil.GetSector(_pos.X/100, _pos.Y/100)
	end
	if sec == 0 then
		sec = EvaluateNearestUnblockedSector(_pos.X, _pos.Y, 5000, 100)
	end
	local size = Logic.WorldGetSize()
	local steps = (ArmyTable and ArmyTable[_player] and ArmyTable[_player][_army] and ArmyTable[_player][_army].ScatterSteps) or 10
	local scatter = (ArmyTable and ArmyTable[_player] and ArmyTable[_player][_army] and ArmyTable[_player][_army].ScatterSize) or 100
	local calcP = function(_XY)
		return dekaround(math.max(math.min(_XY + (steps * math.random(-scatter, scatter)), size - 1), 1))
	end
	local stepcount = 0
	local spots = (ArmyTable and ArmyTable[_player] and ArmyTable[_player][_army] and ArmyTable[_player][_army].MaxHomespots) or 20
	local name = _army or "recruited"
	if not ArmyHomespots[_player][name] then
		ArmyHomespots[_player][name] = {}
	end
	while (table.getn(ArmyHomespots[_player][name]) < spots and stepcount < 1000) do
		local X, Y = calcP(_pos.X), calcP(_pos.Y)
		local nsec = CUtil.GetSector(X/100, Y/100)
		if nsec ~= 0 and nsec == sec and table_findvalue(ArmyHomespots[_player][name], {X = X, Y = Y}) == 0 then
			table.insert(ArmyHomespots[_player][name], {X = X, Y = Y})
		end
		stepcount = stepcount + 1
	end
end

-- checks whether all army homespots of a given player are unblocked or not
-- returns true when there are no blocked homespots and false, table when there are blocked spots
---@param _player integer playerID
---@return boolean
---@return table table filled with army id and homespot index
function CheckArmyHomespotsBlocked(_player)
	assert(ArmyTable and ArmyTable[_player] and ArmyHomespots and ArmyHomespots[_player], "player has no active armies")
	local t = {}
	for k, v in pairs(ArmyHomespots[_player]) do
		for i = 1, table.getn(v) do
			if not IsPositionUnblocked(v[i].X, v[i].Y) then
				table.insert(t, {army = (type(k) == "number" and k-1) or k, index = i})
			end
		end
	end
	if not next(t) then
		return false
	else
		return true, t
	end
end

-- comfort to search the nearest valid target for a given leader ID
-- player of leader needs to have active armies
---@param _player integer playerID
---@param _id integer entityID of leader
---@return integer entityID of nearest enemy
function GetNearestTarget(_player, _id)
	if not Logic.IsEntityAlive(_id) then
		return
	end
	local posX, posY = Logic.GetEntityPosition(_id)
	local range = 5000
	local maxrange = Logic.WorldGetSize()
	local sector = Logic.GetSector(_id)
	ChunkWrapper.UpdatePositions(AIchunks[_player])
	repeat
		local entities = ChunkWrapper.GetEntitiesInAreaInCMSorted(AIchunks[_player], posX, posY, range)
		for i = 1, table.getn(entities) do
			if entities[i] and Logic.IsEntityAlive(entities[i]) and Logic.GetSector(entities[i]) == sector then
				return entities[i]
			end
		end
		range = range + 5000
	until range >= maxrange
	do
		local enemies = BS.GetAllEnemyPlayerIDs(_player)
		local IDs
		for i = 1, table.getn(enemies) do
			IDs = {Logic.GetPlayerEntities(enemies[i], 0, 16)}
			for k = 1, IDs[1] do
				if Logic.IsBuilding(IDs[k]) == 1 and Logic.GetSector(IDs[k]) == sector and Logic.IsEntityInCategory(IDs[k], EntityCategories.Wall) == 0 and not IsInappropiateBuilding(IDs[k]) then
					return IDs[k]
				end
			end
		end
	end
	return false
end

-- comfort to evaluate and measure if a better suited target for a given leader ID is nearby
-- player of leader needs to have active armies
---@param _eID integer entityID of leader
---@param _target integer? entityID of preferred target (optional)
---@param _range number? base value of search range for a better target (optional)
---@return integer entityID of better target
function CheckForBetterTarget(_eID, _target, _range)

	if not Logic.IsEntityAlive(_eID) then
		return
	end

	local sector = Logic.GetSector(_eID)
	local player = Logic.EntityGetPlayer(_eID)
	local etype = Logic.GetEntityType(_eID)
	local IsTower = (Logic.IsEntityInCategory(_eID, EntityCategories.MilitaryBuilding) == 1 and Logic.GetFoundationTop(_eID) ~= 0)
	local IsMelee = (Logic.IsEntityInCategory(_eID, EntityCategories.Melee) == 1)
	local IsHero = (Logic.IsEntityInCategory(_eID, EntityCategories.Hero) == 1)
	local posX, posY = Logic.GetEntityPosition(_eID)
	local maxrange = GetEntityTypeMaxAttackRange(_eID, player)
	local bonusRange = 500
	local damageclass = GetEntityTypeDamageClass(etype)
	local damagerange = GetEntityTypeDamageRange(etype)
	local calcT = {}
	if IsMelee then
		bonusRange = bonusRange * 3
	end
	if IsHero then
		local flag = gvHeroAbilities.HeroAbilityControl(_eID)
		if flag then
			return -1
		end
	end
	if gvAntiBuildingCannonsRange[etype] then
		local res
		local target_eval = function(_target1, _target2)
			if _target1 and Logic.IsBuilding(_target1) == 0 and IsValid(_target2) then
				return _target2
			elseif _target1 and Logic.IsBuilding(_target1) == 1 then
				if _target2 and Logic.IsBuilding(_target2) == 1 then
					return _target2
				else
					if IsValid(_target1) then
						return _target1
					end
				end
			elseif not _target1 and IsValid(_target2) then
				return _target2
			end
		end
		local target = BS.CheckForNearestHostileBuildingInAttackRange(_eID, (_range or maxrange) + gvAntiBuildingCannonsRange[etype])
		local army = GetArmyByLeaderID(_eID)
		if army then
			local tab
			if type(army) == "string" then
				tab = MapEditor_Armies[player][army]
			else
				tab = ArmyTable[player][army+1]
			end
			if target
			and target == tab[_eID].currenttarget
			and GetDistance(_eID, target) > maxrange
			and Logic.GetTime() < tab[_eID].lasttime + 10 then
			else
				res = target_eval(_target, target)
			end
		else
			res = target_eval(_target, target)
		end
		if res then
			return res
		end
	end
	if _target and Logic.IsEntityAlive(_target)
	and (IsMelee and sector == Logic.GetSector(_target)
	or not IsMelee) then
		calcT[1] = {id = _target, factor = DamageFactorToArmorClass[damageclass][GetEntityTypeArmorClass(Logic.GetEntityType(_target))], dist = GetDistance(_eID, _target)}
	end

	local postable = {}
	local clumpscore
	local attach
	ChunkWrapper.UpdatePositions(AIchunks[player])
	local entities = ChunkWrapper.GetEntitiesInAreaInCMSorted(AIchunks[player], posX, posY, _range or maxrange + bonusRange)

	if not next(entities) then
		return
	end
	for i = 1, table.getn(entities) do
		if Logic.IsEntityAlive(entities[i]) then
			local IsHero = (Logic.IsHero(entities[i]) == 1)
			local ety = Logic.GetEntityType(entities[i])
			local threatbonus
			if Logic.GetFoundationTop(entities[i]) ~= 0 or (Logic.IsBuilding(entities[i]) == 0 and GetEntityTypeDamageRange(ety) > 0)
			or (IsHero and not IsMelee)
			or Logic.IsEntityInCategory(entities[i], EntityCategories.Cannon) == 1 then
				if IsHero then
					threatbonus = gvHeroTarget.EvaluateThreatFactor(_eID, entities[i])
				else
					threatbonus = 1
				end
			end
			-- something very dangerous is nearby, retreat as long as you can, then finish this foe!
			if threatbonus and threatbonus < 0 then
				return RetreatToMaxRange(_eID, entities[i], maxrange)
			end
			attach = CEntity.GetAttachedEntities(entities[i])[37]
			local damagefactor = DamageFactorToArmorClass[damageclass][GetEntityTypeArmorClass(ety)]
			if damagerange > 0 and (not gvAntiBuildingCannonsRange[etype] or etype == Entities.PV_Cannon6) then
				local mul = 1
				if Logic.IsLeader(entities[i]) == 1 then
					mul = 1 + Logic.LeaderGetNumberOfSoldiers(entities[i])
				end
				table.insert(postable, {pos = GetPosition(entities[i]), factor = damagefactor * mul + (threatbonus or 0)})
			end
			table.insert(calcT, {id = entities[i], factor = damagefactor + (threatbonus or 0), dist = GetDistance(_eID, entities[i])})
		end
	end
	local attachN = attach and table.getn(attach) or 0
	if damagerange > 0 and (not gvAntiBuildingCannonsRange[etype] or etype == Entities.PV_Cannon6) then
		if next(postable) then
			clumppos, score = GetPositionClump(postable, damagerange, 100)
			for i = 1, table.getn(calcT) do
				if IsTower then
					calcT[i].clumpscore = score
				else
					calcT[i].clumpscore = score / GetDistance(clumppos, GetPosition(calcT[i].id))
				end
			end
		end
	end
	local distval = function(_dist, _range)
		if _dist > _range then
			if IsMelee then
				return (_dist - _range) / _range
			else
				return math.sqrt((_dist - _range) / _range)
			end
		else
			return 0
		end
	end
	table.sort(calcT, function(p1, p2)
		if p1.clumpscore then
			if IsTower then
				return p1.clumpscore > p2.clumpscore
			else
				return p1.clumpscore + p1.factor - distval(p1.dist, maxrange) > p2.clumpscore + p2.factor - distval(p2.dist, maxrange)
			end
		else
			return (p1.factor * 10 - distval(p1.dist, maxrange) - attachN) > (p2.factor * 10 - distval(p2.dist, maxrange) - attachN)
		end
	end)
	if next(calcT) then
		if IsMelee then
			for i = 1, table.getn(calcT) do
				if sector == Logic.GetSector(calcT[i].id) then
					return calcT[i].id
				end
			end
		else
			return calcT[1].id
		end
	end
end

-- lets a leader retreat to a given distance relative to a target
---@param _id integer entityID of leader
---@param _target integer entityID of target
---@param _dist
---@return integer always -1, see ManualControlAttackTarget in AI.lua
RetreatToMaxRange = function(_id, _target, _dist)
	local pos1 = GetPosition(_id)
	local pos2 = GetPosition(_target)
	local dist_12 = GetDistance(pos1, pos2)
	local angle = GetAngleBetween(pos1, pos2)

	local yoff = math.abs(dist_12 - _dist) * math.sin(math.rad(angle))
	local xoff = math.abs(dist_12 - _dist) * math.cos(math.rad(angle))
	local posX, posY = dekaround(pos1.X + xoff), dekaround(pos1.Y + yoff)
	local sec1 = Logic.GetSector(_id)
	local sec2 = CUtil.GetSector(posX/100, posY/100)
	if sec2 == 0 or sec2 ~= sec1 then
		posX, posY = EvaluateNearestUnblockedPositionWithinDistanceOfNode(posX, posY, 2000, 100, pos2.X, pos2.Y, _dist, sec1)
	end
	Logic.MoveSettler(_id, posX, posY)
	return -1
end

-- creates a height map with given positions (via position interferences)
-- returns position with most other positions nearby (by highscore or numeric count)
---@param _postable table table filled with positions. Optional: use key factor to get individual inteference count results
---@param _infrange integer range used for interference. Each position given creates an inteference at any position within this range
---@param _step integer limits the steps made for interference creation. FYI: Larger steps increase performance significantly, but also reduce output quality
---@return table positionTable
---@return integer|number highscore value of clump; if individual factor was assigned, returns float, not integer
function GetPositionClump(_postable, _infrange, _step)
	assert(type(_postable) == "table", "first input param type must be a table")
	assert(type(_infrange) == "number", "second input param type must be a number")
	assert(type(_step) == "number", "third input param type must be a number")
	local tab = {}
	for k, v in pairs(_postable) do
		if v.pos then
			v.X = v.pos.X
			v.Y = v.pos.Y
		end
		v.X = dekaround(v.X)
		for i = v.X - _infrange, v.X + _infrange, _step do
			tab[i] = {}
			v.Y = dekaround(v.Y)
			for j = v.Y - _infrange, v.Y + _infrange, _step do
				if not tab[i][j] then
					tab[i][j] = 0
				end
				tab[i][j] = tab[i][j] + (v.factor or 1)
			end
		end
	end
	local highscore = 0
	local clumppos = {}
	for _X, v in pairs(tab) do
		for _Y, x in pairs(v) do
			if x > highscore then
				highscore = x
				clumppos.X = _X
				clumppos.Y = _Y
			end
		end
	end
	return clumppos, highscore
end

function GetNodesInCircleAndRange(_pos, _range)
	_range = dekaround(_range)
	local t = {}
	for x = _pos.X - _range, _pos.X + _range, 100 do
		for y = _pos.Y - _range, _pos.Y + _range, 100 do
			table.insert(t, {X = x, Y = y})
		end
	end
	return t
end

function GetPercentageOfLeadersPerArmorClass(_table)
	assert(type(_table) == "table", "input type must be a table")
	assert(_table.total ~= nil, "invalid input")
	local perctable = {}
	for i = 1,7 do
		perctable[i] = {id = i, count = table.getn(_table[i]) * 100 / _table.total}
	end
	table.sort(perctable, function(p1, p2)
		return p1.count > p2.count
	end)
	return perctable
end
BS.GetBestDamageClassesByArmorClass = {	[1] = {{id = 2, val = 6}, {id = 7, val = 2}, {id = 1, val = 2}},
										[2] = {{id = 7, val = 6}, {id = 1, val = 4}},
										[3] = {{id = 3, val = 3}, {id = 1, val = 3}, {id = 8, val = 2}, {id = 9, val = 2}},
										[4] = {{id = 8, val = 4}, {id = 9, val = 3}, {id = 2, val = 2}, {id = 3, val = 1}},
										[5] = {{id = 4, val = 10}},
										[6] = {{id = 8, val = 5}, {id = 9, val = 5}},
										[7] = {{id = 7, val = 8}, {id = 9, val = 2}}
										}
BS.GetBestDamageClassByArmorClass = function(_ACid)
	local rand = math.random(1, 10)
	if not BS.GetBestDamageClassesByArmorClass[_ACid][2] then
		return BS.GetBestDamageClassesByArmorClass[_ACid][1].id
	elseif table.getn(BS.GetBestDamageClassesByArmorClass[_ACid]) == 2 then
		if rand <= BS.GetBestDamageClassesByArmorClass[_ACid][1].val then
			return BS.GetBestDamageClassesByArmorClass[_ACid][1].id
		else
			return BS.GetBestDamageClassesByArmorClass[_ACid][2].id
		end
	elseif table.getn(BS.GetBestDamageClassesByArmorClass[_ACid]) == 3 then
		if rand <= BS.GetBestDamageClassesByArmorClass[_ACid][1].val then
			return BS.GetBestDamageClassesByArmorClass[_ACid][1].id
		elseif rand > BS.GetBestDamageClassesByArmorClass[_ACid][1].val and rand <= BS.GetBestDamageClassesByArmorClass[_ACid][1].val + BS.GetBestDamageClassesByArmorClass[_ACid][2].val then
			return BS.GetBestDamageClassesByArmorClass[_ACid][2].id
		else
			return BS.GetBestDamageClassesByArmorClass[_ACid][3].id
		end
	else
		if rand <= BS.GetBestDamageClassesByArmorClass[_ACid][1].val then
			return BS.GetBestDamageClassesByArmorClass[_ACid][1].id
		elseif rand > BS.GetBestDamageClassesByArmorClass[_ACid][1].val and rand <= BS.GetBestDamageClassesByArmorClass[_ACid][1].val + BS.GetBestDamageClassesByArmorClass[_ACid][2].val then
			return BS.GetBestDamageClassesByArmorClass[_ACid][2].id
		elseif rand > BS.GetBestDamageClassesByArmorClass[_ACid][1].val + BS.GetBestDamageClassesByArmorClass[_ACid][2].val and rand <= BS.GetBestDamageClassesByArmorClass[_ACid][1].val + BS.GetBestDamageClassesByArmorClass[_ACid][2].val + BS.GetBestDamageClassesByArmorClass[_ACid][3].val then
			return BS.GetBestDamageClassesByArmorClass[_ACid][3].id
		else
			return BS.GetBestDamageClassesByArmorClass[_ACid][4].id
		end
	end
end
-- table filled with upgrade categories in respective damageclass
BS.GetUpgradeCategoryByDamageClass = {	[1] = {UpgradeCategories.LeaderSword, Entities.PV_Cannon1},
										[2] = UpgradeCategories.LeaderBow,
										[3] = UpgradeCategories.LeaderHeavyCavalry,
										[4] = Entities.PV_Cannon2,
										[5] = UpgradeCategories.LeaderElite,
										[6] = {UpgradeCategories.Evil_LeaderBearman, UpgradeCategories.Evil_LeaderSkirmisher},
										[7] = UpgradeCategories.LeaderRifle,
										[8] = UpgradeCategories.LeaderPoleArm,
										[9] = {UpgradeCategories.LeaderCavalry, UpgradeCategories.LeaderUlan}
										}
-- table filled with upgrade categories by barrack building type string key
BS.CategoriesInMilitaryBuilding = {	["Barracks"] = {UpgradeCategories.LeaderSword, UpgradeCategories.LeaderPoleArm, UpgradeCategories.LeaderElite, UpgradeCategories.BlackKnightLeaderSword3, UpgradeCategories.BlackKnightLeaderMace1, UpgradeCategories.LeaderBandit, UpgradeCategories.LeaderBarbarian},
									["Archery"] = {UpgradeCategories.LeaderBow, UpgradeCategories.LeaderRifle, UpgradeCategories.LeaderBanditBow},
									["Stable"] = {UpgradeCategories.LeaderCavalry, UpgradeCategories.LeaderHeavyCavalry, UpgradeCategories.LeaderUlan},
									["Foundry"] = {Entities.PV_Cannon1, Entities.PV_Cannon2, Entities.PV_Cannon3, Entities.PV_Cannon4},
									["MercenaryTower"] = {Entities.CU_VeteranLieutenant, Entities.CU_VeteranMajor}
									}
GetUpgradeCategoryInDamageClass = function(_dclass)
	if type(BS.GetUpgradeCategoryByDamageClass[_dclass]) == "table" then
		return BS.GetUpgradeCategoryByDamageClass[_dclass][math.random(table.getn(BS.GetUpgradeCategoryByDamageClass[_dclass]))]
	else
		return BS.GetUpgradeCategoryByDamageClass[_dclass]
	end
end

-- returns true when there's a free training slot in military building or false if not (3 slots in general, 1 for foundries)
---@param _id integer entityID
---@return boolean
MilitaryBuildingIsTrainingSlotFree = function(_id)
	if not _id or not Logic.IsEntityAlive(_id) then
		return
	end
	local IsFoundry = (Logic.GetEntityType(_id) == Entities.PB_Foundry1 or Logic.GetEntityType(_id) == Entities.PB_Foundry2)
	if IsFoundry then
		--auf Kanonenfortschritt prüfen und, ob Arbeiter nicht vorhanden oder nicht vor Ort (Progress startet erst, wenn dieser vor Ort ist)
		return Logic.GetCannonProgress(_id) == 100 and CEntity.GetAttachedEntities(_id) and CEntity.GetAttachedEntities(_id)[23] and Logic.GetCurrentTaskList(CEntity.GetAttachedEntities(_id)[23][1]) == "TL_SMELTER_WORK1_WAIT"
	else
		local count = 0
		local attach = CEntity.GetAttachedEntities(_id)[42]
		if attach and attach[1] then
			for i = 1, table.getn(attach) do
				if Logic.IsEntityInCategory(attach[i], EntityCategories.Soldier) == 0 then
					count = count + 1
				end
			end
		else
			return true
		end
		return (count < 3 and table.getn(attach) < 14)
	end
end

AreAllSoldiersOfLeaderDetachedFromMilitaryBuilding = function(_id)
	local sol = {Logic.GetSoldiersAttachedToLeader(_id)}
	for i = 2, sol[1] + 1 do
		if CEntity.GetReversedAttachedEntities(sol[i])[42] then
			return false
		end
	end
	return true
end

-- returns number of currently training leader IDs in military building
---@param _id integer entityID
---@return integer count training leader
GetLeadersTrainingAtMilitaryBuilding = function(_id)
	if not _id or not Logic.IsEntityAlive(_id) then
		return
	end
	local IsFoundry = (Logic.GetEntityType(_id) == Entities.PB_Foundry1 or Logic.GetEntityType(_id) == Entities.PB_Foundry2)
	if IsFoundry then
		if Logic.GetCannonProgress(_id) == 100 then
			return 0
		else
			return 1
		end
	else
		local count = 0
		local attach = CEntity.GetAttachedEntities(_id)[42]
		if attach and attach[1] then
			for i = 1, table.getn(attach) do
				if Logic.IsEntityInCategory(attach[i], EntityCategories.Soldier) == 0 then
					count = count + 1
				end
			end
		end
		return count
	end
end

-- returns true if entity is a cannon or false if not
---@param _type integer entityType
---@return boolean
function IsCannonType(_type)
	assert(type(_type) == "number" and _type > 0, "invalid entity type")
	if _type == Entities.PV_Cannon1 or _type == Entities.PV_Cannon2 or _type == Entities.PV_Cannon3
	or _type == Entities.PV_Cannon4 or _type == Entities.PV_Cannon5 or _type == Entities.PV_Cannon6
	or _type == Entities.PV_Catapult then
		return true
	end
	return false
end

-- returns hero id by summoned entity id
---@param _id integer summoned entity id
---@return integer hero id or nil
function GetSummonedEntityHero(_id)
	assert(IsValid(_id), "invalid entityID")
	if Logic.IsEntityInCategory(_id, EntityCategories.Soldier) == 1 then
		_id = (CEntity.GetAttachedEntities(_id)[31] and CEntity.GetAttachedEntities(_id)[31][1]) or _id
	end
	return (CEntity.GetAttachedEntities(_id) and CEntity.GetAttachedEntities(_id)[54] and CEntity.GetAttachedEntities(_id)[54][1])
end

-- checks whether entity id was summoned by hero or not
---@param _id integer summoned entity id
---@return boolean
function IsHeroSummonedEntity(_id)
	assert(IsValid(_id), "invalid entityID")
	return GetSummonedEntityHero(_id) ~= nil
end

-- returns remaining lifetime of summoned leader
---@param _id integer summoned leader entity id
---@return integer lifetime left in seconds
function GetSummonedEntityLifetimeLeft(_id)
	assert(IsValid(_id), "invalid entityID")
	assert(IsHeroSummonedEntity(_id), "entity is no summoned leader. Aborting")
	local beh = CUtil.GetBehaviour(_id, tonumber("775D9C", 16))
	local time = CUtilMemory.GetMemory(tonumber(beh,16))[5]:GetInt()
	return time or 0
end

-- returns blocking type of a given position
-- 0 = unblocked, 1 = hard blocked by entity or terrain type(red, no placement or movement allowed), 2 = bridge area, 3 = bridge area + hard blocked (2+1),
-- 4 = soft blocked/terrain pos area (green, no placement allowed), 5 = within blocking area (buildings, pits, etc., 1+4 overlapping), 6 = bridge + terrain pos (2+4),
-- 8 = unblocked slope (only below water surface), 9 = hard blocked by slope (8+1)
---@param _x number positionX
---@param _y number positionY
---@return integer blocking type
function GetPositionBlockingType(_x, _y)
	assert(type(_x) == "number" and type(_y) == "number", "invalid position input")
	local max = Logic.WorldGetSize()
	assert(_x <= max and _y <= max and _x >= 0 and _y >= 0, "invalid position; not within map size")
	return CUtil.GetBlocking100(_x, _y)
end

-- checks whether given position is affected by bridge entity category height
---@param _x number positionX
---@param _y number positionY
---@return boolean
function IsPositionAffectedByBridgeHeight(_x, _y)
	return (GetPositionBlockingType(_x, _y) == 2 or GetPositionBlockingType(_x, _y) == 6)
end

-- rotates a given offset
---@param _x number positionX
---@param _y number positionY
---@param _rot number rotation angle in degree
---@return number positionX
---@return number positionY
RotateOffset = function(_x, _y, _rot)

	_rot = math.rad(_rot)
	return _x * math.cos(_rot) - _y * math.sin(_rot), _x * math.sin(_rot) + _y * math.cos(_rot)
end

-- gets nearest unblocked position near a possibly blocked position
---@param _posX number positionX
---@param _posY number positionY
---@param _offset integer maximum search range near position
---@param _step integer limits max loop counts, thus higher value increases performance but lowers result quality
---@param _noterrpos boolean? optional; should build block be ignored as blocked position? default: true
---@return number positionX
---@return number positionY
EvaluateNearestUnblockedPosition = function(_posX, _posY, _offset, _step, _noterrpos)
	if _noterrpos == nil then
		_noterrpos = true
	end
	local xmax, ymax = Logic.WorldGetSize()
	local dmin, xspawn, yspawn
	local f = IsPositionUnblocked
	local res = true
	if not _noterrpos then
		f = CUtil.GetBlocking100
		res = 0
	end

	for y_ = _posY - _offset, _posY + _offset, _step do
		for x_ = _posX - _offset, _posX + _offset, _step do
			if y_ > 0 and x_ > 0 and x_ < xmax and y_ < ymax then

				local d = (x_ - _posX)^2 + (y_ - _posY)^2

				if f(x_, y_) == res then
					if not dmin or dmin > d then
						dmin = d
						xspawn = x_
						yspawn = y_
					end
				end

			end
		end
	end
	return xspawn, yspawn
end

EvaluateNearestUnblockedPositionWithinDistanceOfNode = function(_posX, _posY, _offset, _step, _nodeX, _nodeY, _distance, _sector)

	local xmax, ymax = Logic.WorldGetSize()
	local dmin, xspawn, yspawn
	local f = CUtil.GetBlocking100
	local res = 0

	for y_ = _posY - _offset, _posY + _offset, _step do
		for x_ = _posX - _offset, _posX + _offset, _step do
			if y_ > 0 and x_ > 0 and x_ < xmax and y_ < ymax then

				local d = (x_ - _posX)^2 + (y_ - _posY)^2

				if f(x_, y_) == res and GetDistance({X = x_, Y = y_}, {X = _nodeX, Y = _nodeY}) <= _distance
				and CUtil.GetSector(x_/100, y_/100) == _sector then
					if not dmin or dmin > d then
						dmin = d
						xspawn = x_
						yspawn = y_
					end
				end

			end
		end
	end
	if xspawn and yspawn then
		return xspawn, yspawn
	else
		return _nodeX, _nodeY
	end
end

-- gets nearest unblocked sector near a given position
---@param _posX number positionX
---@param _posY number positionY
---@param _offset integer maximum search range near position
---@param _step integer limits max loop counts, thus higher value increases performance but lowers result quality
---@return integer sector, or if not any unblocked sector found, returns 0
EvaluateNearestUnblockedSector = function(_posX, _posY, _offset, _step)
	local xmax, ymax = Logic.WorldGetSize()
	local dmin, xspawn, yspawn

	for y_ = _posY - _offset, _posY + _offset, _step do
		for x_ = _posX - _offset, _posX + _offset, _step do
			if y_ > 0 and x_ > 0 and x_ < xmax and y_ < ymax then

				local d = (x_ - _posX)^2 + (y_ - _posY)^2
				local sector = CUtil.GetSector(x_ /100, y_ /100)
				if sector > 0 then
					return sector
				end
			end
		end
	end
	return 0
end
RechargeWidgetByEntityType = {["LevyTaxes"] = {	[Entities.PB_Headquarters1] = "Levy_Duties_Recharge",
												[Entities.PB_Headquarters2] = "Levy_Duties_Recharge",
												[Entities.PB_Headquarters3] = "Levy_Duties_Recharge",
												[Entities.PB_Outpost1] = "Levy_Duties_Recharge_OP",
												[Entities.PB_Outpost2] = "Levy_Duties_Recharge_OP",
												[Entities.PB_Outpost3] = "Levy_Duties_Recharge_OP",
												[Entities.PB_Castle1] = "Levy_Duties_Recharge_Castle",
												[Entities.PB_Castle2] = "Levy_Duties_Recharge_Castle",
												[Entities.PB_Castle3] = "Levy_Duties_Recharge_Castle",
												[Entities.PB_Castle4] = "Levy_Duties_Recharge_Castle",
												[Entities.PB_Castle5] = "Levy_Duties_Recharge_Castle"}
								}
function GetRechargeWidgetByButtonAndEntityType(_button, _etype)
	return RechargeWidgetByEntityType[_button][_etype]
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- RANDOM CHESTS ---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
ChestRandomPositions = ChestRandomPositions or {}
ChestRandomPositions.AllowedTypes = ChestRandomPositions.AllowedTypes or {}
ChestRandomPositions.OffsetByType = {	[Entities.XD_Fir1] = {X = 80, Y = 80},
										[Entities.XD_Fir1_small] = {X = 70, Y = 30},
										[Entities.XD_CherryTree] = {X = 110, Y = 60},
										[Entities.XD_CliffBright1] = {X = 190, Y = 130},
										[Entities.XD_CliffBright3] = {X = 330, Y = 260},
										[Entities.XD_CliffBright4] = {X = 300, Y = 200},
										[Entities.XD_CliffBright5] = {X = 470, Y = 240},
										[Entities.XD_CliffDesert1] = {X = 190, Y = 130},
										[Entities.XD_CliffDesert3] = {X = 330, Y = 260},
										[Entities.XD_CliffDesert4] = {X = 300, Y = 200},
										[Entities.XD_CliffDesert5] = {X = 470, Y = 240},
										[Entities.XD_CliffEvelance1] = {X = 470, Y = -30},
										[Entities.XD_CliffEvelance2] = {X = 140, Y = 180},
										[Entities.XD_CliffEvelance3] = {X = 160, Y = 120},
										[Entities.XD_CliffMoor1] = {X = 450, Y = -80},
										[Entities.XD_CliffMoor2] = {X = 140, Y = 180},
										[Entities.XD_CliffMoor3] = {X = 170, Y = 130},
										[Entities.XD_CliffTideland1] = {X = 1450, Y = 580},
										[Entities.XD_CliffTideland2] = {X = 660, Y = 420},
										[Entities.XD_CliffTideland3] = {X = 540, Y = 550},
										[Entities.XD_CliffTidelandShadows1] = {X = 1460, Y = 700},
										[Entities.XD_CliffTidelandShadows2] = {X = 700, Y = 450},
										[Entities.XD_CliffTidelandShadows3] = {X = 460, Y = 580},
										[Entities.XD_Cypress1] = {X = 90, Y = 80},
										[Entities.XD_DeadTreeEvelance3] = {X = 100, Y = 100},
										[Entities.XD_DeadTreeMoor2] = {X = 110, Y = 80},
										[Entities.XD_DeadTreeMoor3] = {X = 130, Y = 90},
										[Entities.XD_GreeneryBushHigh4] = {X = 50, Y = 60},
										[Entities.XD_MiscTent1] = {X = 130, Y = 120},
										[Entities.XD_OliveTree1] = {X = 80, Y = 70},
										[Entities.XD_OliveTree2] = {X = 140, Y = 120},
										[Entities.XD_OrangeTree1] = {X = 290, Y = 260},
										[Entities.XD_PineNorth1] = {X = 90, Y = 180},
										[Entities.XD_PineNorth2] = {X = 100, Y = 90},
										[Entities.XD_RuinFarm1] = {X = 300, Y = 200},
										[Entities.XD_RuinHouse1] = {X = 280, Y = 260},
										[Entities.XD_RuinHouse2] = {X = 360, Y = 200},
										[Entities.XD_RuinMonastery1] = {X = 770, Y = 60},
										[Entities.XD_RuinMonastery2] = {X = 770, Y = 60},
										[Entities.XD_RuinResidence1] = {X = 270, Y = 210},
										[Entities.XD_RuinResidence2] = {X = 270, Y = 210},
										[Entities.XD_RuinSmallTower1] = {X = 160, Y = 160},
										[Entities.XD_RuinSmallTower2] = {X = 160, Y = 160},
										[Entities.XD_RuinTower1] = {X = 210, Y = 190},
										[Entities.XD_RuinTower2] = {X = 210, Y = 190},
										[Entities.XD_RuinWall5] = {X = 320, Y = 130},
										[Entities.XD_RuinWall6] = {X = 320, Y = 130},
										[Entities.XD_Tree1] = {X = 80, Y = 130},
										[Entities.XD_Tree1_small] = {X = 150, Y = 120},
										[Entities.XD_Tree2] = {X = 120, Y = 130},
										[Entities.XD_Tree2_small] = {X = 130, Y = 120},
										[Entities.XD_Tree3] = {X = 120, Y = 190},
										[Entities.XD_Tree3_small] = {X = 130, Y = 160},
										[Entities.XD_Tree5] = {X = 200, Y = 240},
										[Entities.XD_Tree6] = {X = 100, Y = 110},
										[Entities.XD_Tree8] = {X = 120, Y = 120},
										[Entities.XD_TreeEvelance1] = {X = 130, Y = 140},
										[Entities.XD_TreeMoor1] = {X = 110, Y = 110},
										[Entities.XD_TreeMoor2] = {X = 170, Y = 170},
										[Entities.XD_TreeMoor3] = {X = 230, Y = 140},
										[Entities.XD_TreeMoor4] = {X = 190, Y = 140},
										[Entities.XD_TreeMoor5] = {X = 170, Y = 110},
										[Entities.XD_TreeMoor6] = {X = 230, Y = 160},
										[Entities.XD_Umbrella1] = {X = 120, Y = 200},
										[Entities.XD_Umbrella2] = {X = 170, Y = 200},
										[Entities.XD_Umbrella3] = {X = 140, Y = 330},
										[Entities.XD_Willow1] = {X = 140, Y = 140},
										[Entities.PB_Alchemist1] = {[0] = {X = 370, Y = 290},
																	[90] = {X = 370, Y = 290},
																	[180] = {X = 300, Y = 700},
																	[270] = {X = 690, Y = 330}},
										[Entities.PB_Alchemist2] = {[0] = {X = 370, Y = 290},
																	[90] = {X = 370, Y = 290},
																	[180] = {X = 300, Y = 700},
																	[270] = {X = 690, Y = 330}},
										[Entities.PB_Archers_Tower] = {X = 650, Y = 530},
										[Entities.PB_Archery1] = {	[0] = {X = 780, Y = 670},
																	[90] = {X = -260, Y = 720},
																	[180] = {X = -480, Y = 730},
																	[270] = {X = 750, Y = -180}},
										[Entities.PB_Archery2] = {	[0] = {X = 780, Y = 670},
																	[90] = {X = -260, Y = 720},
																	[180] = {X = -480, Y = 730},
																	[270] = {X = 750, Y = -180}},
										[Entities.PB_Bank3] = {	[0] = {X = 740, Y = 520},
																[90] = {X = 470, Y = 590},
																[180] = {X = 420, Y = 440},
																[270] = {X = 460, Y = 360}},
										[Entities.PB_Barracks1] = {	[0] = {X = 730, Y = 90},
																	[90] = {X = 430, Y = 680},
																	[180] = {X = 570, Y = 690},
																	[270] = {X = 690, Y = -310}},
										[Entities.PB_Barracks2] = {	[0] = {X = 730, Y = 90},
																	[90] = {X = 430, Y = 680},
																	[180] = {X = 570, Y = 690},
																	[270] = {X = 690, Y = -310}},
										[Entities.PB_Beautification11] = {X = 220, Y = 200},
										[Entities.PB_Blacksmith3] = {	[0] = {X = 480, Y = -20},
																		[90] = {X = 370, Y = 330},
																		[180] = {X = 470, Y = 0},
																		[270] = {X = 310, Y = 370}},
										[Entities.PB_Brickworks2] = {	[0] = {X = 360, Y = 480},
																		[90] = {X = -80, Y = 280},
																		[180] = {X = 110, Y = 600},
																		[270] = {X = 470, Y = 240}},
										[Entities.PB_Castle4] = {	[0] = {X = 1710, Y = 450},
																	[90] = {X = 760, Y = 1580},
																	[180] = {X = -560, Y = 1970},
																	[270] = {X = 2000, Y = -640}},
										[Entities.PB_Castle5] = {	[0] = {X = 1710, Y = 450},
																	[90] = {X = 760, Y = 1580},
																	[180] = {X = 280, Y = 1980},
																	[270] = {X = 1980, Y = -370}},
										[Entities.PB_Dome] = {	[0] = {X = 2400, Y = 1340},
																[90] = {X = 400, Y = 2270},
																[180] = {X = 2060, Y = 1200},
																[270] = {X = 2000, Y = 1520}},
										[Entities.CB_RuinDome] = {X = -670, Y = 2100},
										[Entities.PB_Farm2] = {	[0] = {X = 350, Y = 250},
																[90] = {X = 270, Y = 270},
																[180] = {X = 270, Y = -420},
																[270] = {X = 470, Y = 280}},
										[Entities.PB_Farm3] = {	[0] = {X = 350, Y = 600},
																[90] = {X = 300, Y = 300},
																[180] = {X = 270, Y = -240},
																[270] = {X =  580, Y = 190}},
										[Entities.PB_ForestersHut1] = {	[0] = {X = 350, Y = 340},
																		[90] = {X = 360, Y = 240},
																		[180] = {X = 180, Y = 350},
																		[270] = {X = 420, Y = 120}},
										[Entities.PB_Foundry1] = {	[0] = {X = 860, Y = 350},
																	[90] = {X = 550, Y = 850},
																	[180] = {X = 680, Y = -200},
																	[270] = {X = 580, Y = 460}},
										[Entities.PB_Foundry2] = {	[0] = {X = 860, Y = 350},
																	[90] = {X = 550, Y = 850},
																	[180] = {X = 680, Y = -200},
																	[270] = {X = 580, Y = 460}},
										[Entities.PB_GoldMine2] = {	[0] = {X = 280, Y = 710},
																	[90] = {X = 480, Y = 570},
																	[180] = {X = 580, Y = -230},
																	[270] = {X = 650, Y = 320}},
										[Entities.PB_GoldMine3] = {	[0] = {X = 280, Y = 710},
																	[90] = {X = 480, Y = 570},
																	[180] = {X = 580, Y = -230},
																	[270] = {X = 650, Y = 320}},
										[Entities.PB_GunsmithWorkshop1] = {	[0] = {X = -100, Y = 570},
																			[90] = {X = 450, Y = 400},
																			[180] = {X = -10, Y = 500},
																			[270] = {X = 530, Y = 420}},
										[Entities.PB_GunsmithWorkshop2] = {	[0] = {X = -100, Y = 570},
																			[90] = {X = 450, Y = 400},
																			[180] = {X = -10, Y = 500},
																			[270] = {X = 530, Y = 420}},
										[Entities.PB_Headquarters1] = {	[0] = {X = 640, Y = 640},
																		[90] = {X = 90, Y = 640},
																		[180] = {X = 600, Y = 300},
																		[270] = {X = 610, Y = -180}},
										[Entities.PB_Headquarters2] = {	[0] = {X = 640, Y = 640},
																		[90] = {X = 90, Y = 640},
																		[180] = {X = 600, Y = 300},
																		[270] = {X = 610, Y = -180}},
										[Entities.PB_Headquarters3] = {	[0] = {X = 640, Y = 640},
																		[90] = {X = 90, Y = 640},
																		[180] = {X = 600, Y = 300},
																		[270] = {X = 610, Y = -180}},
										[Entities.PB_Outpost1] = {	[0] = {X = 640, Y = 640},
																	[90] = {X = 90, Y = 640},
																	[180] = {X = 600, Y = 300},
																	[270] = {X = 610, Y = -180}},
										[Entities.PB_Outpost2] = {	[0] = {X = 640, Y = 640},
																	[90] = {X = 90, Y = 640},
																	[180] = {X = 600, Y = 300},
																	[270] = {X = 610, Y = -180}},
										[Entities.PB_Outpost3] = {	[0] = {X = 640, Y = 640},
																	[90] = {X = 90, Y = 640},
																	[180] = {X = 600, Y = 300},
																	[270] = {X = 610, Y = -180}},
										[Entities.PB_Market1] = {	[0] = {X = 590, Y = 660},
																	[90] = {X = 500, Y = 650},
																	[180] = {X = 340, Y = 580},
																	[270] = {X = 590, Y = 240}},
										[Entities.PB_Market2] = {	[0] = {X = 590, Y = 660},
																	[90] = {X = 500, Y = 650},
																	[180] = {X = 340, Y = 580},
																	[270] = {X = 590, Y = 240}},
										[Entities.PB_Market3] = {	[0] = {X = 870, Y = 710},
																	[90] = {X = 790, Y = -350},
																	[180] = {X = 720, Y = 670},
																	[270] = {X = 830, Y = -610}},
										[Entities.PB_MasterBuilderWorkshop] = {	[0] = {X = 340, Y = 360},
																				[90] = {X = 480, Y = 330},
																				[180] = {X = 200, Y = 490},
																				[270] = {X = 270, Y = 220}},
										[Entities.PB_MercenaryTower] = {[0] = {X = 400, Y = 250},
																		[90] = {X = 310, Y = 300},
																		[180] = {X = 400, Y = -10},
																		[270] = {X = 300, Y = 270}},
										[Entities.PB_Monastery1] = {[0] = {X = 790, Y = 620},
																	[90] = {X = 100, Y = 680},
																	[180] = {X = 600, Y = 90},
																	[270] = {X = 700, Y = -230}},
										[Entities.PB_Monastery2] = {[0] = {X = 790, Y = 620},
																	[90] = {X = 100, Y = 680},
																	[180] = {X = 600, Y = 90},
																	[270] = {X = 700, Y = -230}},
										[Entities.PB_Monastery3] = {[0] = {X = 790, Y = 620},
																	[90] = {X = 100, Y = 680},
																	[180] = {X = 600, Y = 90},
																	[270] = {X = 700, Y = -230}},
										[Entities.PB_PowerPlant1] = {[0] = {X = 260, Y = 320},
																	[90] = {X = 200, Y = 100},
																	[180] = {X = 300, Y = 110},
																	[270] = {X = 300, Y = 220}},
										[Entities.PB_Residence1] = {[0] = {X = 300, Y = 210},
																	[90] = {X = 300, Y = 140},
																	[180] = {X = 200, Y = 180},
																	[270] = {X = 200, Y = 140}},
										[Entities.PB_Residence2] = {[0] = {X = 300, Y = 210},
																	[90] = {X = 300, Y = 140},
																	[180] = {X = 200, Y = 180},
																	[270] = {X = 200, Y = 140}},
										[Entities.PB_Residence3] = {[0] = {X = 300, Y = 210},
																	[90] = {X = 300, Y = 140},
																	[180] = {X = 200, Y = 180},
																	[270] = {X = 200, Y = 140}},
										[Entities.PB_Sawmill1] = {	[0] = {X = 490, Y = 720},
																	[90] = {X = 770, Y = 280},
																	[180] = {X = -100, Y = 830},
																	[270] = {X = 760, Y = -100}},
										[Entities.PB_Sawmill2] = {	[0] = {X = 490, Y = 720},
																	[90] = {X = 770, Y = 280},
																	[180] = {X = -100, Y = 830},
																	[270] = {X = 760, Y = -100}},
										[Entities.PB_SilverMine2] = {X = 520, Y = 680},
										[Entities.PB_SilverMine3] = {X = 600, Y = 610},
										[Entities.PB_StoneMason1] = {[0] = {X = 480, Y = 470},
																	[90] = {X = 450, Y = 400},
																	[180] = {X = -70, Y = 480},
																	[270] = {X = 480, Y = -50}},
										[Entities.PB_StoneMason2] = {[0] = {X = 510, Y = 230},
																	[90] = {X = 400, Y = 420},
																	[180] = {X = -70, Y = 480},
																	[270] = {X = 480, Y = -50}},
										[Entities.PB_SulfurMine2] = {[0] = {X = 245, Y = 790},
																	[90] = {X = -500, Y = 650},
																	[180] = {X = 400, Y = -450},
																	[270] = {X = 650, Y = -300}},
										[Entities.PB_SulfurMine3] = {[0] = {X = 245, Y = 790},
																	[90] = {X = -500, Y = 650},
																	[180] = {X = 400, Y = -450},
																	[270] = {X = 650, Y = -300}},
										[Entities.PB_Tavern1] = {[0] = {X = 520, Y = 520},
																[90] = {X = -160, Y = 400},
																[180] = {X = 480, Y = -220},
																[270] = {X = 560, Y = 400}},
										[Entities.PB_Tavern2] = {[0] = {X = 520, Y = 520},
																[90] = {X = -160, Y = 400},
																[180] = {X = 480, Y = -220},
																[270] = {X = 560, Y = 400}},
										[Entities.PB_University1] = {[0] = {X = 780, Y = 190},
																	[90] = {X = 330, Y = 700},
																	[180] = {X = 630, Y = -400},
																	[270] = {X = 780, Y = 600}},
										[Entities.PB_University2] = {[0] = {X = 780, Y = 190},
																	[90] = {X = 330, Y = 700},
																	[180] = {X = 630, Y = -400},
																	[270] = {X = 780, Y = 600}},
										[Entities.PB_WeatherTower1] = {X = 280, Y = 230},
										[Entities.PB_VillageCenter1] = {[0] = {X = 260, Y = 700},
																		[90] = {X = 200, Y = 660},
																		[180] = {X = 700, Y = 180},
																		[270] = {X = 600, Y = 300}},
										[Entities.PB_VillageCenter2] = {[0] = {X = 260, Y = 700},
																		[90] = {X = 200, Y = 660},
																		[180] = {X = 700, Y = 180},
																		[270] = {X = 600, Y = 300}},
										[Entities.PB_VillageCenter3] = {[0] = {X = 260, Y = 700},
																		[90] = {X = 200, Y = 660},
																		[180] = {X = 700, Y = 180},
																		[270] = {X = 600, Y = 300}},
										[Entities.CB_Abbey01] = {[0] = {X = 510, Y = 410},
																[90] = {X = 300, Y = 400},
																[180] = {X = 570, Y = 200},
																[270] = {X = 350, Y = 600}},
										[Entities.CB_Abbey02] = {[0] = {X = 190, Y = 130},
																[90] = {X = 130, Y = 100},
																[180] = {X = 130, Y = 200},
																[270] = {X = 130, Y = 200}},
										[Entities.CB_Abbey03] = {[0] = {X = 160, Y = 150},
																[90] = {X = 210, Y = 160},
																[180] = {X = 170, Y = 110},
																[270] = {X = 140, Y = 160}},
										[Entities.CB_Abbey04] = {X = 160, Y = 50},
										[Entities.CB_BarmeciaCastle] = {[0] = {X = 780, Y = 440},
																		[90] = {X = 770, Y = 300},
																		[180] = {X = -200, Y = 800},
																		[270] = {X = 870, Y = -400}},
										[Entities.CB_Bastille1] = {	[0] = {X = 380, Y = 370},
																	[90] = {X = 370, Y = 160},
																	[180] = {X = 400, Y = 330},
																	[270] = {X = 310, Y = 300}},
										[Entities.CB_Camp15] = {[0] = {X = 280, Y = 190},
																[90] = {X = 190, Y = 240},
																[180] = {X = 190, Y = 150},
																[270] = {X = 190, Y = 140}},
										[Entities.CB_Camp22] = {[0] = {X = 140, Y = 90},
																[90] = {X = 190, Y = 130},
																[180] = {X = 180, Y = 0},
																[270] = {X = 280, Y = 160}},
										[Entities.CB_Castle1] = {[0] = {X = 670, Y = 410},
																[90] = {X = 600, Y = 290},
																[180] = {X = 500, Y = -30},
																[270] = {X = 160, Y = 500}},
										[Entities.CB_Castle2] = {[0] = {X = 650, Y = 540},
																[90] = {X = 600, Y = 310},
																[180] = {X = 500, Y = -30},
																[270] = {X = 600, Y = 300}},
										[Entities.CB_CleycourtCastle] = {[0] = {X = 280, Y = 790},
																		[90] = {X = -20, Y = 900},
																		[180] = {X = 900, Y = -90},
																		[270] = {X = 700, Y = 290}},
										[Entities.CB_CrawfordCastle] = {[0] = {X = 530, Y = 590},
																		[90] = {X = 280, Y = 680},
																		[180] = {X = 80, Y = 620},
																		[270] = {X = 560, Y = 210}},
										[Entities.CB_DarkCastle] = {[0] = {X = 930, Y = 830},
																	[90] = {X = 930, Y = 480},
																	[180] = {X = 100, Y = 910},
																	[270] = {X = 800, Y = 100}},
										[Entities.CB_DestroyAbleRuinFarm1] = {	[0] = {X = 240, Y = 700},
																				[90] = {X = -150, Y = 300},
																				[180] = {X = 300, Y = -280},
																				[270] = {X = 600, Y = 230}},
										[Entities.CB_DestroyAbleRuinHouse1] = {	[0] = {X = 300, Y = 130},
																				[90] = {X = 200, Y = 220},
																				[180] = {X = 230, Y = 160},
																				[270] = {X = 220, Y = 150}},
										[Entities.CB_DestroyAbleRuinMonastery1] = {	[0] = {X = 700, Y = 180},
																					[90] = {X = 370, Y = 600},
																					[180] = {X = -280, Y = 410},
																					[270] = {X = 360, Y = 600}},
										[Entities.CB_DestroyAbleRuinResidence1] = {	[0] = {X = 100, Y = 330},
																					[90] = {X = 220, Y = 160},
																					[180] = {X = 200, Y = 160},
																					[270] = {X = 220, Y = 140}},
										[Entities.CB_FolklungCastle] = {[0] = {X = 900, Y = 940},
																		[90] = {X = -500, Y = 800},
																		[180] = {X = 900, Y = -600},
																		[270] = {X = 1000, Y = 900}},
										[Entities.CB_KaloixCastle] = {	[0] = {X = 910, Y = 630},
																		[90] = {X = 540, Y = 800},
																		[180] = {X = 320, Y = 1000},
																		[270] = {X = 1000, Y = -290}},
										[Entities.CB_MinerCamp2] = {[0] = {X = 200, Y = 280},
																	[90] = {X = 150, Y = 200},
																	[180] = {X = 140, Y = 300},
																	[270] = {X = 180, Y = 200}},
										[Entities.CB_MinerCamp3] = {[0] = {X = 160, Y = 300},
																	[90] = {X = 140, Y = 200},
																	[180] = {X = 140, Y = 300},
																	[270] = {X = 210, Y = 160}},
										[Entities.CB_Mint1] = {	[0] = {X = 400, Y = 480},
																[90] = {X = -130, Y = 300},
																[180] = {X = 10, Y = 600},
																[270] = {X = 520, Y = 100}},
										[Entities.CB_OldKingsCastle] = {[0] = {X = 1200, Y = 580},
																		[90] = {X = 600, Y = 1120},
																		[180] = {X = -220, Y = 900},
																		[270] = {X = 900, Y = -380}},
										[Entities.CB_OldKingsCastleRuin] = {[0] = {X = 1200, Y = 580},
																			[90] = {X = 600, Y = 1120},
																			[180] = {X = -220, Y = 900},
																			[270] = {X = 900, Y = -380}},
										[Entities.CB_RobberyTower1] = {	[0] = {X = 410, Y = 260},
																		[90] = {X = 300, Y = 300},
																		[180] = {X = 200, Y = 300},
																		[270] = {X = 350, Y = 320}},
										[Entities.CB_Tower1] = {X = 350, Y = 220}
										}
for _, v in pairs(Entities) do
	if ChestRandomPositions.OffsetByType[v] then
		table.insert(ChestRandomPositions.AllowedTypes, v)
	end
end
-- search range for random pos (smaller range: better results, but worse performance, larger range: worse results but better performance scales square!)
ChestRandomPositions.SearchRange = 200
-- minimum distance between chests
ChestRandomPositions.MinDistance = 1000
-- exponent to calculate default num of chests scaling with mapsize (mapsize is square so 2 is only logical)
ChestRandomPositions.DefValueExponent = 2
-- quotient to calculate default num of chests scaling with mapsize
ChestRandomPositions.DefValueQuotient = 30000
-- max range in which heroes can open chests
ChestRandomPositions.ChestOpenerRange = 400
-- chest resource dependent values
ChestRandomPositions.Resources = {Gold = {BaseAmount = 600, RandomBonus = 200, TimeQuotient = 5, Chance = -1}, Silver = {BaseAmount = 150, RandomBonus = 50, TimeQuotient = 15, Chance = 50}}
-- needed for the message to players
ChestRandomPositions.TypeToName = {Gold = "Taler", Silver = "Silber"}
ChestRandomPositions.TypeToPretext = {Gold = "hat eine Schatztruhe geplündert.", Silver = "hat einen besonders wertvollen Schatz gefunden."}
-- played sound and its volume when chest was opened
ChestRandomPositions.OpenedSound = {Type = Sounds.Misc_Chat2, Volume = 125}
-- created chest entity type
ChestRandomPositions.ChestType = Entities.XD_ChestGold
-- default script name given to created chests
ChestRandomPositions.ScriptNamePattern = "RandomPosChest"

-- comfort to create random positions for random chests
---@param _amount integer amount of positions to be raffled
---@return table table filled with positionTables
ChestRandomPositions.GetRandomPositions = function(_amount)
    local chunks = ChunkWrapper.new()
    for id in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(unpack(ChestRandomPositions.AllowedTypes))) do
        ChunkWrapper.AddEntity(chunks, id)
    end
    ChunkWrapper.UpdatePositions(chunks)
    local sizeX, sizeY = Logic.WorldGetSize()
    local postable = {}
    while table.getn(postable) < _amount do
        local X, Y = math.random(sizeX), math.random(sizeY)
        local entities = ChunkWrapper.GetEntitiesInAreaInCMSorted(chunks, X, Y, ChestRandomPositions.SearchRange)
        -- shuffle
        for i = table.getn(entities), 2, - 1 do
            local j = math.random(i)
            entities[i], entities[j] = entities[j], entities[i]
        end
        --
        for _, eID in entities do
            local offX, offY
            if Logic.IsBuilding(eID) == 1 then
                local r = round(Logic.GetEntityOrientation(eID))
                if ChestRandomPositions.OffsetByType[Logic.GetEntityType(eID)][r] then
                    offX, offY = ChestRandomPositions.OffsetByType[Logic.GetEntityType(eID)][r].X, ChestRandomPositions.OffsetByType[Logic.GetEntityType(eID)][r].Y
                end
            end
            if not offX then
                offX, offY = ChestRandomPositions.OffsetByType[Logic.GetEntityType(eID)].X, ChestRandomPositions.OffsetByType[Logic.GetEntityType(eID)].Y
            end
            local _X, _Y = GetPosition(eID).X + offX, GetPosition(eID).Y + offY
            if IsPositionUnblocked(_X, _Y) then
                local distcheck = true
                for _, v in pairs(postable) do
                    if GetDistance(v, {X = _X, Y = _Y}) < ChestRandomPositions.MinDistance then
                        distcheck = false
						break
                    end
                end
                if distcheck then
                    table.insert(postable, {X = _X, Y = _Y})
                    break
                end
            end
        end
    end
    return postable
end
ChestRandomPositions.ActiveState = {}

-- comfort to create chests with random positions and random content
-- chests can by opened by any hero. Content amount increases per time
-- chests mostly contain thalers, but can also contain silver with a small chance instead
---@param _amount integer? amount of chests to be created (optional, if not assigned calculates amount by total map area size
---@return table table filled with chest IDs
ChestRandomPositions.CreateChests = function(_amount)

	_amount = _amount or round(((Mapsize/100)^ChestRandomPositions.DefValueExponent)/ChestRandomPositions.DefValueQuotient)
	local postable = ChestRandomPositions.GetRandomPositions(_amount)
	local chestIDtable = {}
	for k,v in pairs(postable) do
		chestIDtable[k] = Logic.CreateEntity(ChestRandomPositions.ChestType, v.X, v.Y, 0, 0)
		Logic.SetEntityName(chestIDtable[k], ChestRandomPositions.ScriptNamePattern..""..k)
	end
	for i = 1,table.getn(chestIDtable) do
		ChestRandomPositions.ActiveState[i] = true
	end
	ChestRandomPositions.OpenedCount = 0
	return chestIDtable
end

-- job to control random chests
---@param ... integer all chest entity IDs that should be controlled
ChestRandomPositions_ChestControl = function(...)

	if not cutsceneIsActive and not briefingIsActive then
		local entities, pos, randomEventAmount
		for i = 1, arg.n do
			if ChestRandomPositions.ActiveState[i] then
				pos = GetPosition(arg[i])
				for j = 1, XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
					entities = {Logic.GetPlayerEntitiesInArea(j, 0, pos.X, pos.Y, ChestRandomPositions.ChestOpenerRange, 1)}
					if entities[1] > 0 then
						if Logic.IsHero(entities[2]) == 1 or Logic.GetEntityType(entities[2]) == Entities.CU_VeteranCaptain then
							local res
							local randomval = math.random(1, ChestRandomPositions.Resources.Silver.Chance + i)
							if randomval <= ChestRandomPositions.Resources.Silver.Chance then
								res = "Gold"
							else
								res = "Silver"
							end
							randomEventAmount = round((ChestRandomPositions.Resources[res].BaseAmount + math.random(ChestRandomPositions.Resources[res].RandomBonus) + Logic.GetTime()/ChestRandomPositions.Resources[res].TimeQuotient) * (gvDiffLVL or 1))
							Logic.AddToPlayersGlobalResource(j,ResourceType[res],randomEventAmount)
							Message("@color:0,255,255 " .. UserTool_GetPlayerName(j) ..  " " .. ChestRandomPositions.TypeToPretext[res] .. " Inhalt: " .. randomEventAmount .." " .. ChestRandomPositions.TypeToName[res])
							if ExtendedStatistics then
								ExtendedStatistics.Players[j][res] = ExtendedStatistics.Players[j][res] + randomEventAmount
							end
							--
							ChestRandomPositions.ActiveState[i] = false
							ChestRandomPositions.OpenedCount = ChestRandomPositions.OpenedCount + 1
							ReplaceEntity(arg[i], Entities.XD_ChestOpen)
							if GUI.GetPlayerID() == j then
								Sound.PlayGUISound(ChestRandomPositions.OpenedSound.Type, ChestRandomPositions.OpenedSound.Volume)
							end
							break
						end
					end
				end
			end
		end
		return ChestRandomPositions.OpenedCount == arg.n
	end
end