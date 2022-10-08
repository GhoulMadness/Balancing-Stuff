-- default win condition comfort
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
PrepareBriefing = function(_briefing)

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
	assert(cutsceneIsActive ~= true)
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

gvPlayerName = gvPlayerName or {}

function SetPlayerName(_playerId, _name)

	local name = XGUIEng.GetStringTableText(_name)

	if name == nil then
		Logic.SetPlayerRawName(_playerId, _name)
	else
		Logic.SetPlayerName(_playerId, _name)
	end
	
	gvPlayerName[_playerId] = _name

end

function table.findvalue(_tid,_value)

	local tpos
	
	if type(_value) == "number" then	
		for i,val in pairs(_tid) do		
			if val == _value then			
				tpos = i				
			end			
		end	
		
	elseif type(_value) == "table" then	
		if type(_tid[1]) == "table" then	
			if _tid[1].X and _tid[1].Y then			
				for i,_ in pairs(_tid) do				
					if _tid[i].X == _value.X and _tid[i].Y == _value.Y then					
						tpos = i						
					end					
				end	
				
			else
			
				for i,_ in pairs(_tid) do				
					for k,_ in pairs(_tid[i]) do					
						if _tid[i][k] == _value then						
							tpos = i							
						end						
					end					
				end	
				
			end
				
		else
		
			for i,_ in pairs(_tid) do			
				if _tid[i] == _value then				
					tpos = i					
				end				
			end	
			
		end	
	
	end
	
	return tpos or 0

end

function removetablekeyvalue(_tid,_key)

	local tpos
	
	if type(_key) == "string" then	
		for i,_ in pairs(_tid) do		
			if string.find(_tid[i],_key) ~= nil then			
				tpos = i				
			end			
		end
		
	elseif type(_key) == "number" then	
		for i,_ in pairs(_tid) do		
			if _tid[i] == _key then			
				tpos = i				
			end			
		end	
		
	elseif type(_key) == "table" then	
		if type(_tid[1]) == "table" then	
			if _tid[1].X and _tid[1].Y then			
				for i,_ in pairs(_tid) do				
					if _tid[i].X == _key.X and _tid[i].Y == _key.Y then				
						tpos = i						
					end					
				end	
				
			else
			
				for i,_ in pairs(_tid) do				
					for k,_ in pairs(_tid[i]) do					
						if _tid[i][k] == _key then						
							tpos = i							
						end						
					end					
				end					
			end
				
		else
		
			for i,_ in pairs(_tid) do			
				if _tid[i] == _key then				
					tpos = i					
				end				
			end	
			
		end
		
	else
	
		LuaDebugger.Log("Invalid Input for removetablekeyvalue!")		
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
function CreateWoodPile( _posEntity, _resources )

    assert( type( _posEntity ) == "string" )
    assert( type( _resources ) == "number" )	
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

function ActivateShareExploration(_player1, _player2, _both)

    assert(type(_player1) == "number" and type(_player2) == "number" and _player1 <= 16 and _player2 <= 16 and _player1 >= 1 and _player2 >= 1)
	
    if _both == false then	
        Logic.SetShareExplorationWithPlayerFlag(_player1, _player2, 1)	
    else	
        Logic.SetShareExplorationWithPlayerFlag(_player1, _player2, 1)		
        Logic.SetShareExplorationWithPlayerFlag(_player2, _player1, 1)		
    end
	
end

function IsMilitaryLeader(_entityID)

	return Logic.IsHero(_entityID) == 0 and Logic.IsSerf(_entityID) == 0 and Logic.IsEntityInCategory(_entityID, EntityCategories.Soldier) == 0 and Logic.IsBuilding(_entityID) == 0 and Logic.IsWorker(_entityID) == 0 and string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(_entityID))), "soldier") == nil and Logic.IsLeader(_entityID) == 1
	
end

gvTechTable = {University = {	Technologies.GT_Literacy,Technologies.GT_Trading,Technologies.GT_Printing,Technologies.GT_Library,	
								Technologies.GT_Construction,Technologies.GT_GearWheel,Technologies.GT_ChainBlock,Technologies.GT_Architecture,						
								Technologies.GT_Alchemy,Technologies.GT_Alloying,Technologies.GT_Metallurgy,Technologies.GT_Chemistry,						
								Technologies.GT_Mercenaries,Technologies.GT_StandingArmy,Technologies.GT_Tactics,Technologies.GT_Strategies,						
								Technologies.GT_Mathematics,Technologies.GT_Binocular,Technologies.GT_PulledBarrel,Technologies.GT_Matchlock,						
								Technologies.GT_Taxation,Technologies.GT_Banking,Technologies.GT_Laws,Technologies.GT_Gilds},
			MercenaryTower = {	Technologies.T_KnightsCulture, Technologies.T_BearmanCulture, Technologies.T_BanditCulture, Technologies.T_BarbarianCulture},
			Special = {			Technologies.T_Coinage, Technologies.T_Scale, Technologies.T_WeatherForecast, Technologies.T_ChangeWeather, Technologies.T_CropCycle}
				}
				
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

function GetEntityHealth( _entity )

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

function AreEntitiesOfDiplomacyStateInArea( _player, _position, _range, _state )

	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do 	
		if Logic.GetDiplomacyState( _player, i) == _state then		
			if AreEntitiesInArea( i, 0, _position, _range, 1) then			
				return true				
			end			
		end		
	end
	
	return false
	
end

function AreEntitiesOfCategoriesAndDiplomacyStateInArea( _player, _entityCategories, _position, _range, _state )

	assert(type(_entityCategories) == "table")	
	local i
	
	if CNetwork then	
		i = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()		
	else	
		i = 8	
	end

	for i = 1,i do 	
		if Logic.GetDiplomacyState( _player, i) == _state then		
			local amount,bool = AreEntitiesOfTypeAndCategoryInArea( i, 0, _entityCategories, _position, _range, 1)	
			
			if bool then			
				return true				
			end
			
		end		
	end
	
	return false
	
end

function AreEntitiesOfTypeAndCategoryInArea(_player, _entityTypes, _entityCategories, _position, _range, _amount)
		
	local Data = {}	
	local Counter = 0	
	assert(type(_entityCategories) == "table")
	
	if type(_entityTypes) == "table" then	
		for i = 1,table.getn(_entityTypes) do			
			Data[i] = {	Logic.GetPlayerEntitiesInArea(	_player,
														_entityType[i],
														_position.X,
														_position.Y,
														_range,
														_amount)}

		
			for j=2, Data[i][1]+1 do			
				for k = 1,table.getn(_entityCategories) do
					if Logic.IsBuilding(Data[i][j]) == 1 then
						if Logic.IsConstructionComplete(Data[i][j]) == 1 then					
							if Logic.IsEntityInCategory(Data[i][j], _entityCategories[k]) == 1 then
								Counter = Counter + 1								
							end
						end
					else					
						if Logic.IsEntityAlive(Data[i][j]) then				
							if Logic.IsEntityInCategory(Data[i][j], _entityCategories[k]) == 1 then													
								Counter = Counter + 1								
							end							
						end
					end					
				end
			end
			
		end
	
	else
		
		Data = {	Logic.GetPlayerEntitiesInArea(	_player,
													_entityType,
													_position.X,
													_position.Y,
													_range,
													_amount)}
	
		for j=2, Data[1]+1 do		
			for k = 1,table.getn(_entityCategories) do
				if Logic.IsBuilding(Data[j]) == 1 then
					if Logic.IsConstructionComplete(Data[j]) == 1 then					
						if Logic.IsEntityInCategory(Data[j], _entityCategories[k]) == 1 then
							Counter = Counter + 1							
						end
					end
				else				
					if Logic.IsEntityAlive(Data[j]) then			
						if Logic.IsEntityInCategory(Data[j], _entityCategories[k]) == 1 then										
							Counter = Counter + 1							
						end						
					end
				end				
			end
		end
		
	end

	return Counter,(Counter >= _amount)

end

function Unmuting()

	GUI.SetFeedbackSoundOutputState(1)	
	Music.SetVolumeAdjustment(Music.GetVolumeAdjustment() * 2)
	
end

function QuickTest()

	local player = GUI.GetPlayerID()	
	local val = 1000000
	AddGold(player, val)	
	AddStone(player, val)	
	AddIron(player, val)	
	AddWood(player, val)	
	AddSulfur(player, val)	
	AddClay(player, val)	
	Logic.AddToPlayersGlobalResource(player, ResourceType.SilverRaw, val)	
	ResearchAllTechnologies(player, true, true, true)	
	Game.GameTimeSetFactor(6)	
	Display.SetRenderFogOfWar(0)	
	GUI.MiniMap_SetRenderFogOfWar(0)
	
	if Tools then	
		Tools.ExploreArea(-1, -1, val)		
	end
	
end

function ResearchAllTechnologies(_PlayerID, _UniTechsFlag, _MercTechsFlag, _SpecTechsFlag)
	
	_UniTechsFlag = _UniTechsFlag or false			
	_MercTechsFlag = _MercTechsFlag or false
	_SpecTechsFlag = _SpecTechsFlag or false
	
	if _MercTechsFlag then
		--needed to unlock all the techs properly
		gvMercTechsCheated = 1		
	end

	local tabletodo = {	University = _UniTechsFlag, 
						MercenaryTower = _MercTechsFlag,
						Special = _SpecTechsFlag}
						
	for k,v in pairs(tabletodo) do
		if v then
			for i,j in pairs(gvTechTable[k]) do
				Logic.SetTechnologyState(_PlayerID, j, 3)		
			end
		end
	end	
	--ToDo: add troop upgrades and defensive and offensive tech upgrades & silver techs (3 categories?)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function HideGUI()

	Game.GUIActivate(0)	
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "ShowGUI()", 2 )
	
end

function ShowGUI()

	Game.GUIActivate(1)	
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "HideGUI()", 2 )
	
end

function IstDrin(_wert, _table)

	for i = 1, table.getn(_table) do	
		if _table[i] == _wert then 		
			return true 			
		end 		
	end
	
	return false
	
end
------------------------------------------ Countdown Comfort --------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
StartCountdown = function (_Limit, _Callback, _Show, _Name)

	assert(type(_Limit) == "number")
	Counter.Index = (Counter.Index or 0) + 1

	if _Show and CountdownIsVisisble() then	
		if _Name then		
			LuaDebugger.Log("StartCountdown: A countdown is already visible. Countdown ticking to ".._Name.." is running but not shown!")	
		else
			LuaDebugger.Log("StartCountdown: A countdown is already visible. Countdown ticking to "..string.dump(_Callback).." is running but not shown!")			
		end
		
		_Show = false
		
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
--------------------------------------------------------------------------------------------------------------------------------------
function AddTribute( _tribute )

	assert( type( _tribute ) == "table", "Tribut muß ein Table sein" )
	assert( type( _tribute.text ) == "string", "Tribut.text muß ein String sein" )
	assert( type( _tribute.cost ) == "table", "Tribut.cost muß ein Table sein" )	
	assert( type( _tribute.pId or _tribute.playerId ) == "number", "Tribut.pId muß eine Nummer sein" )
	assert( not _tribute.Tribute , "Tribut.Tribute darf nicht vorbelegt sein")
	uniqueTributeCounter = uniqueTributeCounter or 1	
	_tribute.Tribute = uniqueTributeCounter
	uniqueTributeCounter = uniqueTributeCounter + 1
	local tResCost = {}
	
	for k, v in pairs( _tribute.cost ) do	
		assert( ResourceType[k] )		
		assert( type( v ) == "number" )		
		table.insert( tResCost, ResourceType[k] )	
		table.insert( tResCost, v )		
	end

	Logic.AddTribute( _tribute.playerId or _tribute.pId, _tribute.Tribute, 0, 0, _tribute.text, unpack( tResCost ) )
	SetupTributePaid( _tribute )
	return _tribute.Tribute
	
end
----------------------------------------------------------------------------------------------------------------------------------------	
function IsPositionExplored(_pID,_x,_y,_range)

	_range = _range or 7000		
	
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_pID), CEntityIterator.InCircleFilter(_x, _y, _range)) do	
		if GetDistance({Logic.GetEntityPosition(Logic.GetEntityIDByName(eID))},{X=_x,Y=_y}) <= Logic.GetEntityExplorationRange(eID) then		
			return 1		
		else			
			return 0			
		end		
	end
	
end
-- returns the start positions (HQ) of the current player as a table 
function GetPlayerStartPosition()

	local playerID = GUI.GetPlayerID()	
	local t = {}	
	t.LVL = {}
	
	-- search for all upgrade levels
	for i = 1,3 do			
		t.LVL[i] = {Logic.GetPlayerEntities(playerID, Entities["PB_Headquarters"..i],1)}		
		table.remove(t.LVL[i],1)	
		
		for k = 1,table.getn(t.LVL[i]) do		
			table.insert(t,t.LVL[i][k])			
		end		
		
	end
	
	return GetPosition(t[1])	
	
end

function GetAllAIs()

	local AITable = {}

	if CNetwork then	
		for i = 2,16 do	
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) == 0 then			
				if Score.Player[i].all > 0 then			
					table.insert(AITable,i)					
				end				
			end			
		end
		
	else
	
		for i = 2,8 do		
			if Score.Player[i].all > 0 then			
				table.insert(AITable,i)			
			end			
		end
	
	end
	
	return AITable

end
-- comfort to let a group of given player IDs share the same diplomacy state
-- param1: table with player IDs
-- param2: diplomacy state
function SetPlayerDiplomacy(_PlayerID,_Diplomacy)

	assert(type(_PlayerID) == "table","first argument must be a table filled with valid player IDs")	
	assert(type(_Diplomacy) == "number","second argument must be a number (either Diplomacy.XXX or ID of the given diplomacy state)")	
	local tablelength = table.getn(_PlayerID)
	
	for i = 1,tablelength,1 do	
		for k = 1,tablelength,-1 do		
			if _PlayerID[i] ~= _PlayerID[k] then			
				Logic.SetDiplomacyState(_PlayerID[i],_PlayerID[k],_Diplomacy)				
			end			
		end		
	end
	
end
-- comfort to set the diplomacy state between a player ID or a group of given player IDs and all AI player IDs on the map
-- param1: player ID or table with player IDs (optional, default: all humen player IDs on the map)
-- param2: diplomacy state (optional, default: hostile)
function SetHumanPlayerDiplomacyToAllAIs(_PlayerID,_Diplomacy)

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

GetDistance = function(_a, _b)

	if type(_a) ~= "table" then	
		_a = {Logic.GetEntityPosition(Logic.GetEntityIDByName(_a))}		
	end
	
	if type(_b) ~= "table" then	
		_b = {Logic.GetEntityPosition(Logic.GetEntityIDByName(_b))} 		
	end
	
	if _a.X ~= nil then	
		return math.sqrt((_a.X - _b.X)^2+(_a.Y - _b.Y)^2)		
	else	
		return math.sqrt((_a[1] - _b[1])^2+(_a[2] - _b[2])^2)		
	end
	
end

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

function CreateGroup(_PlayerID, _LeaderType, _SoldierAmount, _X , _Y ,_Orientation ,_Experience)
		
	if _LeaderType == nil or _LeaderType == 0 then		
		assert(_LeaderType ~= nil and _LeaderType ~= 0)		
		return 0		
	end	
	-- Create leader
	local LeaderID = Logic.CreateEntity(_LeaderType, _X, _Y,_Orientation,_PlayerID)
	
	if LeaderID == 0 then			
		assert(LeaderID~=0)	
		return 0	
	end
	
	if _Experience then	
		if _Experience > 0 then	
			CEntity.SetLeaderExperience(LeaderID,_Experience)			
		end		
	end
	
	CreateSoldiersForLeader( LeaderID, _SoldierAmount )	
	-- Return leader ID
	return LeaderID
	
end

function CreateSoldiersForLeader( _LeaderID, _SoldierAmount )
		
	-- Is a leader passed?
	if _LeaderID == 0 then	
		return 0		
	end
	
	if Logic.IsLeader( _LeaderID ) ~= 1 then	
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
		local SoldierID = Logic.CreateEntity( SoldierType, LeaderX, LeaderY, 0, LeaderPlayerID )
		
		if SoldierID == 0 then			
			assert(SoldierID~=0)			
			return 0			
		end	
		
		Logic.LeaderGetOneSoldier( _LeaderID )	
		
	end	
	-- Return number of soldiers
	return _SoldierAmount
	
end
-- returns the current weather gfx 
function GetCurrentWeatherGfxSet()

	return CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][11][10]:GetInt()
	
end

NighttimeGFXSets = {9,13,14,19,20,21,28}
function IsNighttime()
	
	return table.findvalue(NighttimeGFXSets, GetCurrentWeatherGfxSet()) ~= 0
	
end

function SetInternalClippingLimitMax(_val)

	assert(type(_val) == "number", "Clipping Limit needs to be a number")
	CUtilMemory.GetMemory(tonumber("0x77A7E8", 16))[0]:SetFloat(_val)
	
end

function SetInternalClippingLimitMin(_val)

	assert(type(_val) == "number", "Clipping Limit needs to be a number")
	CUtilMemory.GetMemory(tonumber("0x77A7F0", 16))[0]:SetFloat(_val)
	
end
-- returns the weather movement speed modifier
function GetWeatherSpeedModifier(_weatherstate)
	assert(_weatherstate > 0 and _weatherstate <= 3, "invalid weatherstate")
	if _weatherstate == 1 then
		return _weatherstate
	else
		return CUtilMemory.GetMemory(8758240)[0][36-3*_weatherstate]:GetFloat()
	end
end
-- returns the technology raw speed modifier and the operation (+/*), both defined in the respective xml
function GetTechnologySpeedModifier(_techID)
	return CUtilMemory.GetMemory(8758176)[0][13][1][_techID-1][56]:GetFloat(), math.mod(CUtilMemory.GetMemory(8758176)[0][13][1][_techID-1][58]:GetInt(), 256)-42
end
-- returns the technology raw attack range modifier and the operation (+/*), both defined in the respective xml
function GetTechnologyAttackRangeModifier(_techID)
	return CUtilMemory.GetMemory(8758176)[0][13][1][_techID-1][88]:GetFloat(), math.mod(CUtilMemory.GetMemory(8758176)[0][13][1][_techID-1][90]:GetInt(), 256)-42
end
-- returns settler base movement speed (not affected by weather or technologies, just the raw value defined in the respective xml)
function GetSettlerBaseMovementSpeed(_entityID)

	assert( IsValid(_entityID), "invalid entityID" )
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[31][1][5]:GetFloat()
	
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
function GetSettlerCurrentMovementSpeed(_entityID,_player)

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
function GetEntityTypeBaseAttackSpeed(_entityType)

	assert( _entityType ~= 0 , "invalid entityType" )
	local behavior_pos	
	if not BehaviorExceptionEntityTypeTable[_entityType] then		
		if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then		
			behavior_pos = 4			
		else		
			behavior_pos = 6			
		end		
	else	
		behavior_pos = 8		
	end
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][21]:GetInt()	
end
-- returns entity type base attack range (not affected by weather or technologies, just the raw value defined in the respective xml)
function GetEntityTypeBaseAttackRange(_entityType)

	assert( _entityType ~= 0 , "invalid entityType" )
	local behavior_pos
	if not BehaviorExceptionEntityTypeTable[_entityType] then	
		if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then		
			behavior_pos = 4			
		else		
			behavior_pos = 6			
		end		
	else	
		behavior_pos = 8				
	end
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][23]:GetFloat()	
end
function GetEntityTypeBaseMinAttackRange(_entityType)

	assert( _entityType ~= 0 , "invalid entityType" )
	local behavior_pos
	if not BehaviorExceptionEntityTypeTable[_entityType] then	
		if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then		
			behavior_pos = 4			
		else		
			behavior_pos = 6			
		end		
	else	
		behavior_pos = 8				
	end
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][24]:GetFloat()	
end
function GetEntityTypeMaxAttackRange(_entity,_player)

	local entityType = Logic.GetEntityType(_entity)	
	local RangeTechBonusFlat
	local RangeTechBonusMultiplier
	--Check auf Technologie Modifikatoren		
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
-- get the current task, logic cant return animal tasks, returns number, not string
function GetEntityCurrentTask(_entityID)

	assert( IsValid(_entityID) , "invalid entityID" )
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[36]:GetInt()	
end
-- set entity current task
function SetEntityCurrentTask(_entityID, _num)

	assert( IsValid(_entityID) , "invalid entityID" )
	assert( type(_num) == "number", "task needs to be a number")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[36]:SetInt(_num)	
end
-- get entity current task sub-index
function GetEntityCurrentTaskIndex(_entityID)

	assert( IsValid(_entityID) , "invalid entityID" )
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[37]:GetInt()	
end
-- set entity current task sub-index
function SetEntityCurrentTaskIndex(_entityID, _index)

	assert( IsValid(_entityID) , "invalid entityID" )
	assert( type(_index) == "number", "index needs to be a number")
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[37]:SetInt(_index)	
end

function GetEntitySize(_entityID)

	assert( IsValid(_entityID) , "invalid entityID" )
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[25]:GetFloat()	
end

function SetEntitySize(_entityID,_size)

	assert( IsValid(_entityID) , "invalid entityID" )
	assert( type(_size) == "number", "size needs to be a number")
	CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[25]:SetFloat(_size)	
end
gvVisibilityStates = {	[0] = 257,
						[1] = 65793
					}
-- get visibility of entity (0=invisible, 1=visible)
function GetEntityVisibility(_entityID)
	assert( IsValid(_entityID) , "invalid entityID" )
	for k,v in pairs(gvVisibilityStates) do
		if Logic.GetEntityScriptingValue(_entityID, -30) == v then	
			return k
		end
	end
end
-- changes visibility of entity (_flag: 0 = invisible, 1 = visible, -1 = toggle)
function SetEntityVisibility(_entityID, _flag)
	assert( IsValid(_entityID) , "invalid entityID" )
	assert( type(_flag) == "number" and _flag >= -1 and _flag <= 1, "visibility flag needs to be a number (either 0, 1 or -1")
	Logic.SetEntityScriptingValue(_entityID, -30, gvVisibilityStates[_flag] or math.abs(gvVisibilityStates[GetEntityVisibility(_entityID)]-1))		
end
-- gets entity type damage class
function GetEntityTypeDamageClass(_entityType)

	assert(_entityType ~= nil, "invalid entityType")
	local behavior_pos
	if not BehaviorExceptionEntityTypeTable[_entityType] then	
		if string.find(Logic.GetEntityTypeName(_entityType), "Soldier") ~= nil then		
			behavior_pos = 4			
		else		
			behavior_pos = 6			
		end		
	else	
		behavior_pos = 8				
	end
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][13]:GetInt()	
end
-- gets entity type armor class
function GetEntityTypeArmorClass(_entityType)
	assert(_entityType ~= nil , "invalid entityType")
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType * 8 + 2][60]:GetInt()
end
-- gets damage factor related to the damageclass/armorclass
function GetDamageFactor(_damageclass, _armorclass)
	assert(_damageclass > 0 and _damageclass <= 9, "invalid damageclass")
	assert(_armorclass > 0 and _armorclass <= 7, "invalid armorclass")
	return CUtilMemory.GetMemory(8758236)[0][2][_damageclass][_armorclass]:GetFloat()
end
function GetAttractionPlacesProvided(_entityType)
	assert(_entityType ~= nil , "invalid entityType")
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType * 8 + 2][44]:GetInt()
end
-- Rundungs-Comfort
function round( _n )

	assert(type(_n) == "number", "size needs to be a number")
	return math.floor( _n + 0.5 )	
end

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

function RecreateVillageCenters()
	local vcdata, eId
	for i = 1,3 do
		for j = 1, table.getn(StartVillageCenters[i]) do
			vcdata = StartVillageCenters[i][j]
			SetEntityName(Logic.CreateEntity(vcdata.EntityType, vcdata.Position.X, vcdata.Position.Y, vcdata.Rotation, vcdata.PlayerId), vcdata.Name)
		end
	end
end

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

function SetPlayerEntitiesSelectable()
	for k = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		StartAllPlayerEntities[k] = GetPlayerEntities(k)
		for i = 1, table.getn(StartAllPlayerEntities[k]) do
			Logic.SetEntitySelectableFlag(StartAllPlayerEntities[k][i], 1)
		end
	end
end

function BS.ManualUpdate_KillScore(_attackerPID, _targetPID, _scoretype)	
	if Logic.GetDiplomacyState(_attackerPID, _targetPID) == Diplomacy.Hostile then
		if _scoretype == "Settler" then
			GameCallback_SettlerKilled(_attackerPID, _targetPID)
			if ExtendedStatistics then
				if _attackerPID > 0 and _targetPID > 0 then
					ExtendedStatistics.Players[_attackerPID].Kills = ExtendedStatistics.Players[_attackerPID].Kills + 1
					ExtendedStatistics.Players[_targetPID].Losses = ExtendedStatistics.Players[_targetPID].Losses + 1
				end
			end
		elseif _scoretype == "Building" then
			GameCallback_BuildingDestroyed(_attackerPID, _targetPID)
		end
	end
end

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

BS.CheckForNearestHostileBuildingInAttackRange = function(_entity, _range)

	if not Logic.IsEntityAlive(_entity) then	
		return
	end
	
	local playerID = Logic.EntityGetPlayer(_entity)
	local posX, posY = Logic.GetEntityPosition(_entity)
	local distancepow2table	= {}
	
	for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(BS.GetAllEnemyPlayerIDs(playerID))), CEntityIterator.IsBuildingFilter(), CEntityIterator.InCircleFilter(posX, posY, _range)) do
		local _X, _Y = Logic.GetEntityPosition(eID)	
		local distancepow2 = (_X - posX)^2 + (_Y - posY)^2		
		table.insert(distancepow2table, {id = eID, dist = distancepow2})
	end
			
	table.sort(distancepow2table, function(p1, p2)
		return p1.dist < p2.dist
	end)
	
	if distancepow2table[1] then
		return distancepow2table[1].id 
	end
end

BS.GetTableStrByHeroType = function(_type)
	
	local typename = Logic.GetEntityTypeName(_type)
	local s, e = string.find(typename, "Hero")	
	return string.sub(typename, s)
end
gvHQTypeTable = {	[Entities.PB_Headquarters1] = true,
					[Entities.PB_Headquarters2] = true,
					[Entities.PB_Headquarters3] = true,
					[Entities.PB_Castle1] = true,
					[Entities.PB_Castle2] = true,
					[Entities.PB_Castle3] = true,
					[Entities.PB_Castle4] = true,
					[Entities.PB_Castle5] = true
				}