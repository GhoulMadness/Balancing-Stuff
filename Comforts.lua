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

	return Logic.IsHero(_entityID) == 0 and Logic.IsSerf(_entityID) == 0 and Logic.IsEntityInCategory(_entityID, EntityCategories.Soldier) == 0 and Logic.IsBuilding(_entityID) == 0 and Logic.IsWorker(_entityID) == 0 and string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(_entityID))), "soldier") == nil and Logic.IsLeader(_entityID) == 1 and Logic.IsEntityInCategory(_entityID, EntityCategories.MilitaryBuilding) == 0
	
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
	
	local maxplayers = 8
	if CNetwork then
		maxplayers = 16
	end
	for i = 1, maxplayers do 	
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

ResumeEntityOrig = Logic.ResumeEntity
Logic.ResumeEntity = function(_id)
	ResumeEntityOrig(_id)
	if Logic.IsHero(_id) == 1 or Logic.IsLeader(_id) == 1 or Logic.IsSerf(_id) == 1 or Logic.IsEntityInCategory(_id, EntityCategories.Cannon) == 1 or Logic.IsWorker(_id) == 1 then
		Logic.SetEntityScriptingValue(_id, 72, 1)
	end
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
		_a = {Logic.GetEntityPosition(GetID(_a))}		
	end
	
	if type(_b) ~= "table" then	
		_b = {Logic.GetEntityPosition(GetID(_b))} 		
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

NighttimeGFXSets = {[1] = {9, 19},
					[2] = {13, 20, 28},
					[3] = {14, 21}}
function IsNighttime()
	
	local found = 0
	for i = 1, table.getn(NighttimeGFXSets) do
		found = table.findvalue(NighttimeGFXSets[i], GetCurrentWeatherGfxSet()) 
		if found ~= 0 then
			return true
		end
	end
	return found ~= 0
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
		return GetLogicPropertiesPointer[36-3*_weatherstate]:GetFloat()
	end
end
-- returns the technology raw speed modifier and the operation (+/*), both defined in the respective xml
function GetTechnologySpeedModifier(_techID)
	return GetTechnologyPointer(_techID)[56]:GetFloat(), CUtilBit32.BitAnd(GetTechnologyPointer(_techID)[58]:GetInt(), 2^8-1)-42
end
-- returns the technology raw attack range modifier and the operation (+/*), both defined in the respective xml
function GetTechnologyAttackRangeModifier(_techID)
	return GetTechnologyPointer(_techID)[88]:GetFloat(), CUtilBit32.BitAnd(GetTechnologyPointer(_techID)[90]:GetInt(), 2^8-1)-42
end
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
-- returns settler base movement speed (not affected by weather or technologies, just the raw value defined in the respective xml)
function GetSettlerBaseMovementSpeed(_entityID)

	assert( IsValid(_entityID), "invalid entityID" )
	return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[31][1][5]:GetFloat()
	
end
function SetSettlerBaseMovementSpeed(_entityID, _val)

	assert( IsValid(_entityID), "invalid entityID" )
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
		elseif string.find(string.lower(Logic.GetEntityTypeName(_entityType)), "tower") ~= nil then	
			behavior_pos = 0
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
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][23]:GetFloat()	
end
function GetEntityTypeBaseMinAttackRange(_entityType)

	assert( _entityType ~= 0 , "invalid entityType" )
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
--[[GetMilitaryBuildingMaxTrainSlots
CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_entityID))[31][2][3][7]:GetInt()]]

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
-- gets entity type damage range (only use for types with given damage range!)
function GetEntityTypeDamageRange(_entityType)

	assert(_entityType ~= nil, "invalid entityType")
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
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][16]:GetFloat()	
end
-- gets entity type damage class
function GetEntityTypeDamageClass(_entityType)

	assert(_entityType ~= nil, "invalid entityType")
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
	
	return CUtilMemory.GetMemory(9002416)[0][16][_entityType*8+5][behavior_pos][13]:GetInt()	
end
-- gets entity type armor class
function GetEntityTypeArmorClass(_entityType)
	assert(_entityType ~= nil , "invalid entityType")
	local pointer = GetEntityTypePointer(_entityType)
	local behpos
	if pointer[0]:GetInt() == tonumber("76EC78", 16) then
		behpos = 102
	elseif pointer[0]:GetInt() == tonumber("76E498", 16) then
		behpos = 60
	elseif pointer[0]:GetInt() == tonumber("778148", 16) then
		behpos = 102
	end
	return pointer[behpos]:GetInt()	
end
-- gets damage factor related to the damageclass/armorclass
function GetDamageFactor(_damageclass, _armorclass)
	assert(_damageclass > 0 and _damageclass <= 9, "invalid damageclass")
	assert(_armorclass > 0 and _armorclass <= 7, "invalid armorclass")
	return GetDamageModifierPointer()[_damageclass][_armorclass]:GetFloat()
end
function GetAttractionPlacesProvided(_entityType)
	assert(_entityType ~= nil , "invalid entityType")
	return GetEntityTypePointer(_entityType)[44]:GetInt()
end
-- gets player kill statistics (0: settlers killed, 1: settlers lost, 2: buildings destroyed, 3: buildings lost)
function GetPlayerKillStatisticsProperties(_playerID, _statistic)
	assert(type(_playerID) == "number", "PlayerID needs to be a number")
	assert(_playerID > 0 and _playerID < 17, "invalid PlayerID")
	assert(type(_statistic) == "number", "Statistic type needs to be a number")
	assert(_statistic >= 0 and _statistic <= 3, "invalid statistic type")
	return GetPlayerStatusPointer(_playerID)[82 + _statistic]:GetInt()
end			
-- sets player kill statistics (0: settlers killed, 1: settlers lost, 2: buildings destroyed, 3: buildings lost)
function SetPlayerKillStatisticsProperties(_playerID, _statistic, _value)
	assert(type(_playerID) == "number", "PlayerID needs to be a number")
	assert(_playerID > 0 and _playerID < 17, "invalid PlayerID")
	assert(type(_statistic) == "number", "Statistic type needs to be a number")
	assert(_statistic >= 0 and _statistic <= 3, "invalid statistic type")
	assert(type(_value) == "number", "Value needs to be a number")
	return GetPlayerStatusPointer(_playerID)[82 + _statistic]:SetInt(_value)
end
-- adds value to respective player kill statistic (0: settlers killed, 1: settlers lost, 2: buildings destroyed, 3: buildings lost)
function AddValueToPlayerKillStatistic(_playerID, _statistic, _value)
	assert(type(_playerID) == "number", "PlayerID needs to be a number")
	assert(_playerID > 0 and _playerID < 17, "invalid PlayerID")
	assert(type(_statistic) == "number", "Statistic type needs to be a number")
	assert(_statistic >= 0 and _statistic <= 3, "invalid statistic type")
	assert(type(_value) == "number", "Value needs to be a number")
	local currstat = GetPlayerKillStatisticsProperties(_playerID, _statistic)
	SetPlayerKillStatisticsProperties(_playerID, _statistic, currstat + _value)
end
-- gets building type blocking properties, returns Blocked1X, Blocked1Y, Blocked2X, Blocked2Y
function GetBuildingTypeBlockingArea(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	local tab = {}
	for i = 1,4 do
		table.insert(tab, GetEntityTypePointer(_entityType)[35][i-1]:GetFloat())
	end
	return unpack(tab)
end
-- gets building type terrain pos properties, returns TerrainPos1X, TerrainPos1Y, TerrainPos2X, TerrainPos2Y
function GetBuildingTypeTerrainPosArea(_entityType)
	assert(_entityType ~= 0, "invalid entity type")
	local tab = {}
	for i = 1,4 do
		table.insert(tab, GetEntityTypePointer(_entityType)[37 + i]:GetFloat())
	end
	return unpack(tab)
end
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
--[[armyobj_vtable:tonumber("0x766A70", 16)
0 vtable
3 lfd army ID
5 = 11 Bitfield?
6 Pos?
7 = ~15-20 float?
11 = -1.0 float?
12 Army PosX (Siedler-Meter)
13 Army PosY (Siedler-Meter)
14 = -1.0 bis 1.0 float?
15 = -1.0 bis 1.0 float?
19 = 0.0 - 1.0 float? (0.25 steps?)
20 = 30.0 float?
23 Target PosX (Siedler-Meter)
24 Target PosY (Siedler-Meter)
26 Pos?
27 = 0.25 float?
29 Target ID
38 = 15 Bitfield?
50 id slot 1
51 id slot 2
56 id slot 3
57 id slot 4
62 id slot 5
63 id slot 6
65 = 2 Bitfield?
68 id slot 7
69 id slot 8
71 Target PID
72 anzahl belegte slots
73 anzahl alive slots
76 PosX?
77 PosY?
78 = 1.0 float?	
]]
--AI.Army_GetOccupancyRate(_player, _armyId) %-Wert alive-slots/gesamt-slots
function AI.Army_GetNextFreeSlot(_playerID)
	local slot
	for i = 9, 1, -1 do
		if AI.Army_GetOccupancyRate(_playerID, i - 1) < 100 then
			if MapEditor_Armies[_playerID][i] and MapEditor_Armies[_playerID][i].id then
				slot = i - 1
				break
			end
		end
	end
	return slot or false
end

function AI.Army_GetLeaderIDs(_playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0)
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
function AI.Entity_RemoveFromArmy(_id, _playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0)
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
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
end
function AI.Entity_AddToArmy(_id, _playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0)
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
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
end
function AI.Army_GetInternalID(_playerID, _armyID)
	assert(XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerID) == 0)
	assert(_armyID >= 0 and _armyID <= 8, "invalid armyID")
	local adress = GetArmyObjectPointer()
	local playerOffset = GetArmyPlayerObjectOffset(_playerID)
	return adress[playerOffset][40 + 3 + (_armyID *84)]:GetInt()
end
---------------------------------------------------------------------------------------------------------------------------------
-- Rundungs-Comfort
function round( _n )
	assert(type(_n) == "number", "round val needs to be a number")
	return math.floor( _n + 0.5 )	
end
function dekaround(_n)
	assert(type(_n) == "number", "round val needs to be a number")
	return math.floor( _n / 100 + 0.5 ) * 100	
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
function BS.ManualUpdate_DamageDealt(_heroID, _damage, _maxdmg, _scoretype)	
	local playerID = Logic.EntityGetPlayer(_heroID)
	ExtendedStatistics.Players[playerID][_scoretype] = ExtendedStatistics.Players[playerID][_scoretype] + (math.min(_damage, _maxdmg))
	ExtendedStatistics.Players[player]["Damage"] = ExtendedStatistics.Players[player]["Damage"] + (math.min(_damage, _maxdmg))
	ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(_damage, _maxdmg))
	ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage, ExtendedStatistics.Players[playerID].MostDeadlyEntityDamage_T[_heroID])	
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
		if Logic.GetFoundationTop(eID) ~= 0 then
			distancepow2 = distancepow2 / 2
		end
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

function GetApprTimeNeededToReachPos(_eID, _posX, _posY)

	local height, blockingtype, sector, tempterrType = CUtil.GetTerrainInfo(_posX, _posY)
    if sector == 0 or blockingtype ~= 0 then
		LuaDebugger.Log("Position blocked; not reachable")
		return 0
	end
	if (height <= CUtil.GetWaterHeight(_posX/100, _posY/100)) and Logic.GetWeatherState() ~= 3 then
		LuaDebugger.Log("Position at water; not reachable")
		return 0
	end
	local fakeetype = Entities.CU_Merchant
	local starttime = Logic.GetTimeMs()
	local posX, posY = Logic.GetEntityPosition(_eID)
	local fakeID = Logic.CreateEntity(fakeetype, posX, posY, 0, Logic.EntityGetPlayer(_eID))
	SetSettlerBaseMovementSpeed(fakeID, 10000)	
	Logic.MoveSettler(fakeID, _posX, _posY)
	local trID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "ReachPos_Job", 1, {}, {_eID, fakeID, starttime, _posX, _posY})		
	
	--[[while GetDistance(GetPosition(fakeID), {X = _posX, Y = _posY}) > 100 do
		if Logic.IsEntityMoving(fakeID) == 0 then
			Logic.MoveSettler(fakeID, _posX, _posY)
		end
		if Logic.GetTimeMs() - starttime > 200 then
			LuaDebugger.Log("Position either not reachable or too far away")
			break
		end
	end]]
	local fakespeed = GetSettlerCurrentMovementSpeed(fakeID)
	Logic.DestroyEntity(fakeID)
	local realspeed = GetSettlerCurrentMovementSpeed(_eID)
	return (Logic.GetTimeMs() - starttime) * (fakespeed/realspeed)
end		
function ReachPos_Job(_eID, _fakeID, _starttime, _posX, _posY)
	if GetDistance(GetPosition(_fakeID), {X = _posX, Y = _posY}) > 100 then
		if Logic.IsEntityMoving(_fakeID) == 0 then
			Logic.MoveSettler(_fakeID, _posX, _posY)
		end
		if Logic.GetTimeMs() - _starttime > 200 then
			LuaDebugger.Log("Position either not reachable or too far away")
			return true
		end
	end
	local fakespeed = GetSettlerCurrentMovementSpeed(_fakeID)
	Logic.DestroyEntity(_fakeID)
	local realspeed = GetSettlerCurrentMovementSpeed(_eID)
	return GetApprTimeNeededToReachPos(_eID, _posX, _posY, (Logic.GetTimeMs() - _starttime) * (fakespeed/realspeed))
end	
DamageFactorToArmorClass = {}
for i = 1,9 do
	DamageFactorToArmorClass[i] = {}
	for k = 1,7 do
		DamageFactorToArmorClass[i][k] = GetDamageFactor(i, k)
	end
end
function GetNearestTarget(_player, _id)
	if not Logic.IsEntityAlive(_id) then
		return
	end
	local posX, posY = Logic.GetEntityPosition(_id)	
	local range = 5000
	local maxrange = ({Logic.WorldGetSize()})[1]
	local sector = Logic.GetSector(_id)
	local currtime = Logic.GetTimeMs()
	if AIchunks.time[_player] ~= currtime then
		AIchunks[_player]:UpdatePositions()
		AIchunks.time[_player] = Logic.GetTimeMs()
	end
	repeat		
		local entities = AIchunks[_player]:GetEntitiesInAreaInCMSorted(posX, posY, range)
		for i = 1, table.getn(entities) do
			if entities[i] and Logic.IsEntityAlive(entities[i]) and Logic.GetSector(entities[i]) == sector and Logic.GetDiplomacyState(_player, Logic.EntityGetPlayer(entities[i])) == Diplomacy.Hostile then
				return entities[i]
			end
		end
		range = range + 3000
	until range >= maxrange
	for i = 9, 1, -1 do
		local target = AI.Army_GetEntityIdOfEnemy(_player, i - 1)
		if target ~= nil and target > 0 and Logic.IsEntityAlive(target) and Logic.GetSector(target) == sector then
			return target
		end
	end
	do
		local enemies = BS.GetAllEnemyPlayerIDs(_player)
		for i = 1, table.getn(enemies) do
			IDs = {Logic.GetPlayerEntities(enemies[i], 0, 16)}
			for k = 1, IDs[1] do
				if Logic.IsBuilding(IDs[k]) == 1 and Logic.GetSector(IDs[k]) == sector then
					return IDs[k]
				end
			end
		end
	end
	do
		local slot = AI.Army_GetNextFreeSlot(_player)
		if slot then
			AI.Entity_AddToArmy(_id, _player, slot)
		end
	end
	return false
end
function CheckForBetterTarget(_eID, _target, _range)
	
	if not Logic.IsEntityAlive(_eID) then
		return
	end

	local currtime = Logic.GetTimeMs()
	local player = Logic.EntityGetPlayer(_eID)
	if AIchunks.time[player] ~= currtime then
		AIchunks[player]:UpdatePositions()
		AIchunks.time[player] = Logic.GetTimeMs()
	end
	local etype = Logic.GetEntityType(_eID)	
	local IsTower = (Logic.IsEntityInCategory(_eID, EntityCategories.MilitaryBuilding) == 1 and Logic.GetFoundationTop(_eID) ~= 0)
	local IsMelee = (Logic.IsEntityInCategory(_eID, EntityCategories.Melee) == 1)
	local posX, posY = Logic.GetEntityPosition(_eID)	
	local maxrange = GetEntityTypeMaxAttackRange(_eID, player)
	local damageclass = GetEntityTypeDamageClass(etype)
	local damagerange = GetEntityTypeDamageRange(etype)
	local calcT = {}
	
	if _target then
		if gvAntiBuildingCannonsRange[etype] then
			if Logic.IsBuilding(_target) == 0 then
				return BS.CheckForNearestHostileBuildingInAttackRange(_eID, (_range or maxrange) + gvAntiBuildingCannonsRange[etype])
			end		
		end
		if Logic.IsEntityAlive(_target) then
			calcT[1] = {id = _target, factor = DamageFactorToArmorClass[damageclass][GetEntityTypeArmorClass(Logic.GetEntityType(_target))], dist = GetDistance(_eID, _target)}
		end
	else
		if gvAntiBuildingCannonsRange[etype] then
			return BS.CheckForNearestHostileBuildingInAttackRange(_eID, (_range or maxrange) + gvAntiBuildingCannonsRange[etype])
		end
	end
	
	local postable = {}	
	local clumpscore
	local attach
	local entities = AIchunks[player]:GetEntitiesInAreaInCMSorted(posX, posY, (_range or maxrange) + 500)
	
	if not entities[1] then
		return _target
	end
	for i = 1, table.getn(entities) do
		if Logic.IsEntityAlive(entities[i]) then
			local ety = Logic.GetEntityType(entities[i])
			local threatbonus
			if Logic.GetFoundationTop(entities[i]) ~= 0 or GetEntityTypeDamageRange(ety) > 0 then
				threatbonus = 1
			end
			attach = CEntity.GetAttachedEntities(entities[i])[37]
			local damagefactor = DamageFactorToArmorClass[damageclass][GetEntityTypeArmorClass(ety)]	
			local mul = (({Logic.GetSoldiersAttachedToLeader(entities[i])})[1] or 0) + 1
			if damagerange > 0 and not gvAntiBuildingCannonsRange[etype] then
				table.insert(postable, {pos = GetPosition(entities[i]), factor = damagefactor * mul + (threatbonus or 0)})	
			end						
			table.insert(calcT, {id = entities[i], factor = damagefactor * mul + (threatbonus or 0), dist = GetDistance(_eID, entities[i])})	
		end
	end
	local attachN = attach and table.getn(attach) or 0
	if damagerange > 0 and not gvAntiBuildingCannonsRange[etype] then
		if postable[1] then
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
			return (p1.factor * 10 - distval(p1.dist, maxrange) - attachN / 2) > (p2.factor * 10 - distval(p2.dist, maxrange) - attachN / 2)
		end
	end)
	if calcT[1] then
		return calcT[1].id
	end
	return _target
end
function GetPositionClump(_postable, _infrange, _step)
	assert(type(_postable) == "table", "first input param type must be a table")
	assert(type(_infrange) == "number", "second input param type must be a number")
	assert(type(_step) == "number", "third input param type must be a number")
	local tab = {}
	for k, v in pairs(_postable) do
		v.pos.X = dekaround(v.pos.X)
		for i = v.pos.X - _infrange, v.pos.X + _infrange, _step do
			tab[i] = {}
			v.pos.Y = dekaround(v.pos.Y)
			for j = v.pos.Y - _infrange, v.pos.Y + _infrange, _step do
				if not tab[i][j] then
					tab[i][j] = 0
				end
				tab[i][j] = tab[i][j] + v.factor
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
BS.GetUpgradeCategoryByDamageClass = {	[1] = {UpgradeCategories.LeaderSword, Entities.PV_Cannon1},
										[2] = UpgradeCategories.LeaderBow,
										[3] = UpgradeCategories.LeaderHeavyCavalry,
										[4] = Entities.PV_Cannon2,
										[5] = UpgradeCategories.LeaderElite,
										[6] = {UpgradeCategories.Evil_LeaderBearman, UpgradeCategories.Evil_LeaderSkirmisher},
										[7] = UpgradeCategories.LeaderRifle,
										[8] = UpgradeCategories.LeaderPoleArm,
										[9] = UpgradeCategories.LeaderCavalry
										}
BS.CategoriesInMilitaryBuilding = {	["Barracks"] = {UpgradeCategories.LeaderSword, UpgradeCategories.LeaderPoleArm},
									["Archery"] = {UpgradeCategories.LeaderBow, UpgradeCategories.LeaderRifle},
									["Stables"] = {UpgradeCategories.LeaderCavalry, UpgradeCategories.LeaderHeavyCavalry},
									["Foundry"] = {Entities.PV_Cannon1, Entities.PV_Cannon2, Entities.PV_Cannon3, Entities.PV_Cannon4}
									}
GetUpgradeCategoryInDamageClass = function(_dclass)
	if type(BS.GetUpgradeCategoryByDamageClass[_dclass]) == "table" then
		return BS.GetUpgradeCategoryByDamageClass[_dclass][math.random(table.getn(BS.GetUpgradeCategoryByDamageClass[_dclass]))]
	else
		return BS.GetUpgradeCategoryByDamageClass[_dclass]
	end
end
MilitaryBuildingIsTrainingSlotFree = function(_id)
	if not _id or not Logic.IsEntityAlive(_id) then
		return
	end
	local slots
	local IsFoundry = (Logic.GetEntityType(_id) == Entities.PB_Foundry1 or Logic.GetEntityType(_id) == Entities.PB_Foundry2)
	if IsFoundry then
		return Logic.GetCannonProgress(_id) == 100
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
		return count < 3
	end
end
	 
RotateOffset = function(_x, _y, _rot)
	
	_rot = math.rad(_rot)
	return _x * math.cos(_rot) - _y * math.sin(_rot), _x * math.sin(_rot) + _y * math.cos(_rot)
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
										[Entities.PB_PowerPlant1] = {	[0] = {X = 260, Y = 320},
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
										[Entities.PB_StoneMason1] = {	[0] = {X = 480, Y = 470},
																		[90] = {X = 450, Y = 400},
																		[180] = {X = -70, Y = 480},
																		[270] = {X = 480, Y = -50}},
										[Entities.PB_StoneMason2] = {X = 510, Y = 230},
										[Entities.PB_SulfurMine2] = {X = 245, Y = 790},
										[Entities.PB_SulfurMine3] = {X = 245, Y = 790},
										[Entities.PB_Tavern1] = {X = 520, Y = 520},
										[Entities.PB_Tavern2] = {X = 520, Y = 520},
										[Entities.PB_University1] = {X = 780, Y = 190},
										[Entities.PB_University2] = {X = 780, Y = 190},
										[Entities.PB_WeatherTower1] = {X = 280, Y = 230},
										[Entities.PB_VillageCenter1] = {X = 260, Y = 700},
										[Entities.PB_VillageCenter2] = {X = 260, Y = 700},
										[Entities.PB_VillageCenter3] = {X = 260, Y = 700},
										[Entities.CB_Abbey01] = {X = 510, Y = 410},
										[Entities.CB_Abbey02] = {X = 190, Y = 130},
										[Entities.CB_Abbey03] = {X = 160, Y = 150},
										[Entities.CB_Abbey04] = {X = 160, Y = 50},
										[Entities.CB_BarmeciaCastle] = {X = 780, Y = 440},
										[Entities.CB_Bastille1] = {X = 380, Y = 370},
										[Entities.CB_Camp15] = {X = 280, Y = 190},
										[Entities.CB_Camp22] = {X = 140, Y = 90},
										[Entities.CB_Castle1] = {X = 670, Y = 410},
										[Entities.CB_Castle2] = {X = 650, Y = 540},
										[Entities.CB_CleycourtCastle] = {X = 280, Y = 790},
										[Entities.CB_CrawfordCastle] = {X = 530, Y = 590},
										[Entities.CB_DarkCastle] = {X = 930, Y = 830},			
										[Entities.CB_DestroyAbleRuinFarm1] = {X = 240, Y = 610},
										[Entities.CB_DestroyAbleRuinHouse1] = {X = 270, Y = 130},
										[Entities.CB_DestroyAbleRuinMonastery1] = {X = 700, Y = 180},
										[Entities.CB_DestroyAbleRuinResidence1] = {X = 260, Y = 230},
										[Entities.CB_FolklungCastle] = {X = 850, Y = 940},
										[Entities.CB_KaloixCastle] = {X = 910, Y = 630},
										[Entities.CB_MinerCamp2] = {X = 240, Y = 220},
										[Entities.CB_MinerCamp3] = {X = 240, Y = 220},
										[Entities.CB_Mint1] = {X = 360, Y = 480},
										[Entities.CB_OldKingsCastle] = {X = 1170, Y = 580},
										[Entities.CB_OldKingsCastleRuin] = {X = 1170, Y = 580},
										[Entities.CB_RobberyTower1] = {X = 410, Y = 260},
										[Entities.CB_Tower1] = {X = 350, Y = 220}
										}
for k,v in pairs(Entities) do
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
ChestRandomPositions.OpenedSound = {Type = Sounds.Misc_Chat2, Volume = 100}
-- created chest entity type
ChestRandomPositions.ChestType = Entities.XD_ChestGold
-- default script name given to created chests
ChestRandomPositions.ScriptNamePattern = "RandomPosChest"
ChestRandomPositions.GetRandomPositions = function(_amount)
    local chunks = CUtil.Chunks.new()
    for id in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(unpack(ChestRandomPositions.AllowedTypes))) do
        chunks:AddEntity(id)
    end
    chunks:UpdatePositions()
    local sizeX, sizeY = Logic.WorldGetSize()
    local postable = {}
    while table.getn(postable) < _amount do
        local X, Y = math.random(sizeX), math.random(sizeY)
        local entities = chunks:GetEntitiesInAreaInCMSorted(X, Y, ChestRandomPositions.SearchRange)
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
            local height, blockingtype, sector, tempterrType = CUtil.GetTerrainInfo(_X, _Y)
                
            if sector > 0 and blockingtype == 0 and (height > CUtil.GetWaterHeight(_X/100, _Y/100)) then
                local distcheck = true
                for k,v in pairs(postable) do
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
		
ChestRandomPositions_ChestControl = function(...)

	if not cutsceneIsActive and not briefingIsActive then
		local entities, pos, randomEventAmount
		for i = 1, arg.n do	
			if ChestRandomPositions.ActiveState[i] then				
				pos = GetPosition(arg[i])
				for j = 1, XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
					entities = {Logic.GetPlayerEntitiesInArea(j, 0, pos.X, pos.Y, ChestRandomPositions.ChestOpenerRange, 1)}
					if entities[1] > 0 then
						if Logic.IsHero(entities[2]) == 1 then
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
							Sound.PlayGUISound(ChestRandomPositions.OpenedSound.Type, ChestRandomPositions.OpenedSound.Volume)
							ChestRandomPositions.ActiveState[i] = false
							ChestRandomPositions.OpenedCount = ChestRandomPositions.OpenedCount + 1
							ReplaceEntity(arg[i], Entities.XD_ChestOpen)
						end
					end
				end
			end
		end
		return ChestRandomPositions.OpenedCount == arg.n
	end
end