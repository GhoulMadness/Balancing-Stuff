--[["ä", "\195\164" 
    "ö", "\195\182" 
    "ü", "\195\188" 
    "ß", "\195\159" 
    "Ä", "\195\132" 
    "Ö", "\195\150" 
    "Ü", "\195\156" ]]		
------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Tables and misc Stuff --------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
if LocalMusic then
	LocalMusic.SetEvilBattle= 	{
								{ "43_Extra1_DarkMoor_Combat.mp3", 120 },									
								{ "05_CombatEvelance1.mp3", 117 },
								{ "03_CombatEurope1.mp3", 117 },
								{ "04_CombatMediterranean1.mp3", 113 }
								}
end
if not gvLastTimeLightningRodUsed then
	gvLastTimeLightningRodUsed = -240000
end
if GUI.GetPlayerID() == 17 then
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "HideGUI()", 2 )
end
if XNetwork.Manager_DoesExist() ~= 0 then
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		Logic.SetTechnologyState(i,Technologies.MU_Cannon5,0)
		Logic.SetTechnologyState(i,Technologies.MU_Cannon6,0)
		if gvXmasEventFlag or gvTutorialFlag then
			Logic.SetTechnologyState(i,Technologies.B_VillageHall,0) 
		end
			
	end
	Logic.SetTechnologyState(17,Technologies.GT_Tactics,3)
	
	-----------------------------------------------------------------------------------------------
	-- Added Outposts to win condition ------------------------------------------------------------
	-----------------------------------------------------------------------------------------------
	MultiplayerTools.EntityTableHeadquarters = {Entities.PB_Headquarters1,Entities.PB_Headquarters2,Entities.PB_Headquarters3,Entities.PB_Castle1,Entities.PB_Castle2,Entities.PB_Castle3,Entities.PB_Castle4,Entities.PB_Castle5}
		

else
	Logic.SetTechnologyState(1,Technologies.UP1_Lighthouse,3)
	Logic.SetTechnologyState(1,Technologies.MU_Cannon5,0)
	Logic.SetTechnologyState(1,Technologies.MU_Cannon6,0)
	if gvXmasEventFlag then
		Logic.SetTechnologyState(1,Technologies.B_VillageHall,0) 
	end
		
	XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer = function()
		return 1
	end
	MultiplayerTools.RemoveAllPlayerEntities = function( _PlayerID)
	end
	GUIUpdate_BuyHeroButton = function()	
		if Logic.GetNumberOfBuyableHerosForPlayer( GUI.GetPlayerID() ) > 0 then			
			XGUIEng.ShowWidget(XGUIEng.GetCurrentWidgetID(),1)	
		else		
			XGUIEng.ShowWidget(XGUIEng.GetCurrentWidgetID(),0)		
		end	
	end	
	GUIAction_ToggleMenu_Orig = GUIAction_ToggleMenu	
	GUIAction_ToggleMenu = function(_menu, _status)	
		if _menu == gvGUI_WidgetID.BuyHeroWindow then	
			XGUIEng.ShowWidget(gvGUI_WidgetID.BuyHeroWindow, 1)
		else	
			GUIAction_ToggleMenu_Orig(_menu, _status)	
		end	
		gvMission.singleplayerMode = true	
	end
end
	
if CUtil then
    GameCallback_RefinedResourceOrig = GameCallback_RefinedResource;
	GameCallback_GainedResourcesFromMineOrig = GameCallback_GainedResourcesFromMine;
	GameCallback_ConstructBuildingOrig = GameCallback_ConstructBuilding;
	GameCallback_PlaceBuildingAdditionalCheckOrig = GameCallback_PlaceBuildingAdditionalCheck;
	GameCallback_ResearchProgressOrig = GameCallback_ResearchProgress;	
	 
    
	refined_resource_gold = {
        [Entities.PB_Bank1] = 3;
        [Entities.PB_Bank2] = 3;
        [Entities.PB_Bank3] = 4;
		[Entities.CB_Mint1] = 3;
    };
	
	gained_resource_clay = {
	    [Entities.PB_ClayMine1] = 5;
		[Entities.PB_ClayMine2] = 7;
		[Entities.PB_ClayMine3] = 9;
	};
	
	gained_resource_iron = {		
		[Entities.PB_IronMine1] = 5;
		[Entities.PB_IronMine2] = 7;
		[Entities.PB_IronMine3] = 9;
	};
	
	gained_resource_stone = {
		[Entities.PB_StoneMine1] = 5;
		[Entities.PB_StoneMine2] = 7;
		[Entities.PB_StoneMine3] = 9;
	};
		
	gained_resource_sulfur = {
		[Entities.PB_SulfurMine1] = 5;
		[Entities.PB_SulfurMine2] = 7;
		[Entities.PB_SulfurMine3] = 9;
	};
	
	gained_resource_silver = {
		[Entities.PB_SilverMine1] = 2;
		[Entities.PB_SilverMine2] = 2;
		[Entities.PB_SilverMine3] = 3;
	};
	
	gained_resource_gold = {
		[Entities.PB_GoldMine1] = 5;
		[Entities.PB_GoldMine2] = 7;
		[Entities.PB_GoldMine3] = 9;
	};
	--Control Siversmith Grievance
	StartSimpleJob("ControlSiversmithGrievance")
end
--Silver added to resource window
if CNetwork then
	if MP_DiplomacyWindow.resource_to_name then
		MP_DiplomacyWindow.resource_to_name = {
			[ResourceType.GoldRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameMoney") .. " [R]";
			[ResourceType.ClayRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameClay") .. " [R]";
			[ResourceType.WoodRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameWood") .. " [R]";
			[ResourceType.StoneRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameStone") .. " [R]";
			[ResourceType.IronRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameIron") .. " [R]";
			[ResourceType.SulfurRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameSulfur") .. " [R]";
			[ResourceType.SilverRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameSilver") .. " [R]";
					
			[ResourceType.Gold] = "@color:184,182,90: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameMoney") .. " @color:255,255,255,255: ";
			[ResourceType.Clay] = "@color:115,66,34: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameClay") .. " @color:255,255,255,255: ";
			[ResourceType.Wood] = "@color:85,45,9: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameWood") .. " @color:255,255,255,255: ";
			[ResourceType.Stone] = "@color:147,147,136: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameStone") .. " @color:255,255,255,255: ";
			[ResourceType.Iron] = "@color:98,108,100: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameIron") .. " @color:255,255,255,255: ";
			[ResourceType.Sulfur] = "@color:234,240,68: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameSulfur") .. " @color:255,255,255,255: ";
			[ResourceType.Silver] =  " @color:198,208,200: " .. XGUIEng.GetStringTableText("ingamemessages/GUI_NameSilver") .. " @color:255,255,255,255: ";
		};
			
			
		MP_DiplomacyWindow.resource_to_next = {
			[ResourceType.Gold] = ResourceType.Clay;
			[ResourceType.Clay] = ResourceType.Wood;
			[ResourceType.Wood] = ResourceType.Stone;
			[ResourceType.Stone] = ResourceType.Iron;
			[ResourceType.Iron] = ResourceType.Sulfur;
			[ResourceType.Sulfur] = ResourceType.Silver;
			[ResourceType.Silver] = ResourceType.Gold;
				
			[ResourceType.GoldRaw] = ResourceType.ClayRaw;
			[ResourceType.ClayRaw] = ResourceType.WoodRaw;
			[ResourceType.WoodRaw] = ResourceType.StoneRaw;
			[ResourceType.StoneRaw] = ResourceType.IronRaw;
			[ResourceType.IronRaw] = ResourceType.SulfurRaw;
			[ResourceType.SulfurRaw] = ResourceType.SilverRaw;
			[ResourceType.SilverRaw] = ResourceType.Gold;
		};
			
		MP_DiplomacyWindow.resource_to_check = {
				
			[ResourceType.Gold] = { ResourceType.Gold, ResourceType.GoldRaw },
			[ResourceType.Clay] = { ResourceType.Clay, ResourceType.ClayRaw },
			[ResourceType.Wood] = { ResourceType.Wood, ResourceType.WoodRaw },
			[ResourceType.Stone] = { ResourceType.Stone, ResourceType.StoneRaw },
			[ResourceType.Iron] = { ResourceType.Iron, ResourceType.IronRaw },
			[ResourceType.Sulfur] = { ResourceType.Sulfur, ResourceType.SulfurRaw },
			[ResourceType.Silver] = { ResourceType.Silver, ResourceType.SilverRaw },
				
			[ResourceType.GoldRaw] = { ResourceType.GoldRaw },
			[ResourceType.ClayRaw] = { ResourceType.ClayRaw },
			[ResourceType.WoodRaw] = { ResourceType.WoodRaw },
			[ResourceType.StoneRaw] ={ ResourceType.StoneRaw },
			[ResourceType.IronRaw] = { ResourceType.IronRaw },
			[ResourceType.SulfurRaw] = { ResourceType.SulfurRaw },
		};
		if MP_DiplomacyWindow.allowed_resources then
		 MP_DiplomacyWindow.allowed_resources = {
			[ResourceType.Gold] = true;
			[ResourceType.Clay] = true;
			[ResourceType.Wood] = true;
			[ResourceType.Stone] = true;
			[ResourceType.Iron] = true;
			[ResourceType.Sulfur] = true;
			[ResourceType.Silver] = true;
		};
		end
		if MP_DiplomacyWindow.raw_resources_allowed then
			MP_DiplomacyWindow.allowed_resources[ResourceType.GoldRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.ClayRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.WoodRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.StoneRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.IronRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.SulfurRaw] = true;
			MP_DiplomacyWindow.allowed_resources[ResourceType.SilverRaw] = true;
				
			MP_DiplomacyWindow.resource_to_next[ResourceType.Silver] = ResourceType.GoldRaw;
			
		end;
	end
end
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

function removetablekeyvalue(_tid,_key)
	local tpos 
	if type(_key) == "string" then
		for i = 1, table.getn(_tid) do
			if string.find(table.getn[i],_key) ~= nil then
				tpos = i
			end
		end
	elseif type(_key) == "number" then
		for i = 1, table.getn(_tid) do
			if _tid[i] == _key then
				tpos = i
			end
		end	
	elseif type(_key) == "table" then
		for i = 1, table.getn(_tid) do
			for k = 1,table.getn(_tid[i]) do
				if _tid[i][k] == _key then
					tpos = i
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
function CreateWoodPile( _posEntity, _resources )
    assert( type( _posEntity ) == "string" );
    assert( type( _resources ) == "number" );
    gvWoodPiles = gvWoodPiles or {
        JobID = StartSimpleJob("ControlWoodPiles"),
    };
    local pos = {}
	pos.X,pos.Y = Logic.GetEntityPosition(Logic.GetEntityIDByName(_posEntity))
    local pile_id = Logic.CreateEntity( Entities.XD_Rock3, pos.X, pos.Y, 0, 0 );
	
    SetEntityName( pile_id, _posEntity.."_WoodPile" );
	
    local newE = ReplacingEntity( _posEntity, Entities.XD_ResourceTree );
	Logic.SetModelAndAnimSet(newE, Models.XD_SignalFire1);
    Logic.SetResourceDoodadGoodAmount( GetEntityId( _posEntity ), _resources*10 );
	Logic.SetModelAndAnimSet(pile_id, Models.Effects_XF_ChopTree);
    table.insert( gvWoodPiles, { ResourceEntity = _posEntity, PileEntity = _posEntity.."_WoodPile", ResourceLimit = _resources*9 } );
end

function ControlWoodPiles()
    for i = table.getn( gvWoodPiles ),1,-1 do
        if Logic.GetResourceDoodadGoodAmount( GetEntityId( gvWoodPiles[i].ResourceEntity ) ) <= gvWoodPiles[i].ResourceLimit then
            DestroyWoodPile( gvWoodPiles[i], i );
        end
    end
end
 
function DestroyWoodPile( _piletable, _index )
    local pos = GetPosition( _piletable.ResourceEntity );
    DestroyEntity( _piletable.ResourceEntity );
    DestroyEntity( _piletable.PileEntity );
    Logic.CreateEffect( GGL_Effects.FXCrushBuilding, pos.X, pos.Y, 0 );
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
    assert(type(_player1) == "number" and type(_player2) == "number" and _player1 <= 8 and _player2 <= 8 and _player1 >= 1 and _player2 >= 1);
    if _both == false then
        Logic.SetShareExplorationWithPlayerFlag(_player1, _player2, 1);
    else
        Logic.SetShareExplorationWithPlayerFlag(_player1, _player2, 1);
        Logic.SetShareExplorationWithPlayerFlag(_player2, _player1, 1);
    end
end

function IsMilitaryLeader(_entityID)
	if Logic.IsHero(_entityID) == 1 or Logic.IsSerf(_entityID) == 1 or Logic.IsEntityInCategory(_entityID, EntityCategories.Soldier) == 1 then
		return false
	else
		return true
	end
end

UniTechAmount = function(_PlayerID)
	local Player = _PlayerID
	local TechTable = {	Technologies.GT_Literacy,Technologies.GT_Trading,Technologies.GT_Printing,Technologies.GT_Library,
						Technologies.GT_Construction,Technologies.GT_GearWheel,Technologies.GT_ChainBlock,Technologies.GT_Architecture,
						Technologies.GT_Alchemy,Technologies.GT_Alloying,Technologies.GT_Metallurgy,Technologies.GT_Chemistry,
						Technologies.GT_Mercenaries,Technologies.GT_StandingArmy,Technologies.GT_Tactics,Technologies.GT_Strategies,
						Technologies.GT_Mathematics,Technologies.GT_Binocular,Technologies.GT_PulledBarrel,Technologies.GT_Matchlock,
						Technologies.GT_Taxation,Technologies.GT_Banking,Technologies.GT_Laws,Technologies.GT_Gilds}
	local amount = 0
	for i = 1,table.getn(TechTable) do
		if Logic.GetTechnologyState(Player, TechTable[i]) == 4 then
			amount = amount + 1
 
		end
	end
	return amount
end 
function GetEntityHealth( _entity )
	local entityID = Logic.GetEntityIDByName(_entity)
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
function Unmuting()
	GUI.SetFeedbackSoundOutputState(1)
	Music.SetVolumeAdjustment(Music.GetVolumeAdjustment() * 2)
end
function QuickTest()
	AddGold(1,1000000)
	AddStone(1,1000000)
	AddIron(1,1000000)
	AddWood(1,1000000)
	AddSulfur(1,1000000)
	AddClay(1,1000000)
	Logic.AddToPlayersGlobalResource(1,ResourceType.SilverRaw,1000000)
	ResearchAllUniversityTechnologiesExtra(1)
	Game.GameTimeSetFactor(6)
	Display.SetRenderFogOfWar(0)
	GUI.MiniMap_SetRenderFogOfWar(0)
end
function ResearchAllUniversityTechnologiesExtra(_PlayerID)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Mercenaries,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_StandingArmy,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Tactics,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Strategies,3)


	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Construction,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_ChainBlock,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_GearWheel,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Architecture,3)


	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Alchemy,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Alloying,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Metallurgy,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Chemistry,3)


	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Literacy,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Trading,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Printing,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Library,3)


	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Mathematics,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Binocular,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Matchlock,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_PulledBarrel,3)

	
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Taxation,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Banking,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Laws,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.GT_Gilds,3)
	
	Logic.SetTechnologyState(_PlayerID,Technologies.T_Coinage,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.T_Scale,3)
	Logic.SetTechnologyState(_PlayerID,Technologies.T_WeatherForecast,3)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function HideGUI()
	XGUIEng.ShowWidget("BackGround_BottomLeft",0)
	XGUIEng.ShowWidget("MiniMapOverlay",0) 
	XGUIEng.ShowWidget("MiniMap",0) 
	XGUIEng.ShowWidget("ResourceView",0) 
	XGUIEng.ShowWidget("MinimapButtons",0) 
	XGUIEng.ShowWidget("Top",0) 
	XGUIEng.ShowWidget("FindView",0) 
	XGUIEng.ShowWidget("Normal",0)
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "ShowGUI()", 2 )
end
function ShowGUI()
	XGUIEng.ShowWidget("BackGround_BottomLeft",1)
	XGUIEng.ShowWidget("MiniMapOverlay",1) 
	XGUIEng.ShowWidget("MiniMap",1) 
	XGUIEng.ShowWidget("ResourceView",1) 
	XGUIEng.ShowWidget("MinimapButtons",1) 
	XGUIEng.ShowWidget("Top",1) 
	XGUIEng.ShowWidget("FindView",1) 
	XGUIEng.ShowWidget("Normal",1)
	Input.KeyBindDown(Keys.ModifierAlt + Keys.G, "HideGUI()", 2 )
end
function GetCurrentWeatherGfxSet()
	return CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][11][10]:GetInt()
end
function IstDrin(_wert, _table)
	for i = 1, table.getn(_table) do
		if _table[i] == _wert then 
			return true 
		end 
	end
	return false
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
	
function IsPositionExplored(_pID,_x,_y,_range)
	if not _range then
		_range = 7000
	end
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
		t.LVL[i] = {Logic.GetPlayerEntities(playerID,_G["Entities.PB_Headquarters"..i],1)}
		table.remove(t.LVL[i],1)
		for k = 1,table.getn(t.LVL[i]) do
			table.insert(t,t.LVL[i][k])
		end
	end
	return GetPosition(t[1])	
end
-- comfort to let a group of given player IDs share the same diplomacy state
-- param1: table with player IDs
-- param2: diplomacy state
function SetPlayerDiplomacy(_PlayerID,_Diplomacy)
	assert(type(_PlayerID) == "table","first argument must be a table filled with valid player IDs");
	assert(type(_Diplomacy) == "number","second argument must be a number (either Diplomacy.XXX or ID of the given diplomacy state)");
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
	assert(type(_PlayerID) ~= "string","Argument must be either a valid player ID or a table filled with valid player IDs");
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
		_a = {Logic.GetEntityPosition(Logic.GetEntityIDByName(_a))}; 
	end
	if type(_b) ~= "table" then
		_b = {Logic.GetEntityPosition(Logic.GetEntityIDByName(_b))}; 
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
	if DeltaHealth > 0
	then
		Logic.HealEntity(_EntityID, DeltaHealth)
	elseif DeltaHealth < 0
	then	
	-- else hurt it	
		Logic.HurtEntity(_EntityID, -DeltaHealth)
	end
end
function CreateGroup(_PlayerID, _LeaderType, _SoldierAmount, _X , _Y ,_Orientation )
		
	if _LeaderType == nil or _LeaderType == 0 then
		LuaDebugger.Break()
		assert(_LeaderType ~= nil and _LeaderType ~= 0)
		return 0
	end
	
	-- Create leader
	local LeaderID = Logic.CreateEntity(_LeaderType, _X, _Y,_Orientation,_PlayerID)
	if LeaderID == 0 then
		LuaDebugger.Break()
		assert(LeaderID~=0)
		return 0
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
			LuaDebugger.Break()
			assert(SoldierID~=0)
			return 0
		end		
		Logic.LeaderGetOneSoldier( _LeaderID )					
	end
	
	-- Return number of soldiers
	return _SoldierAmount
	
end
function InterfaceTool_CreateCostString( _Costs )

	local PlayerID = GUI.GetPlayerID()
	
	local PlayerClay   = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Clay ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.ClayRaw)	
	local PlayerGold   = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Gold ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.GoldRaw)
	local PlayerSilver = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Silver ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.SilverRaw)
	local PlayerWood   = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Wood ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.WoodRaw)
	local PlayerIron   = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Iron ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.IronRaw)
	local PlayerStone  = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Stone ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.StoneRaw)
	local PlayerSulfur = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Sulfur ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.SulfurRaw)

	local CostString = ""
	
	if _Costs[ ResourceType.Gold ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney") .. ": " 
		if PlayerGold >= _Costs[ ResourceType.Gold ] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Gold ] .. " @color:255,255,255,255 @cr "
	end
	
	if _Costs[ ResourceType.Wood ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood") .. ": " 
		if PlayerWood >= _Costs[ ResourceType.Wood ] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Wood ] .. " @color:255,255,255,255 @cr "
	end
	
	if _Costs[ ResourceType.Silver ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameSilver") .. ": " 
		if PlayerSilver >= _Costs[ ResourceType.Silver ] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Silver ] .. " @color:255,255,255,255 @cr "
	end
		
	if _Costs[ ResourceType.Clay ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay") .. ": " 
		if PlayerClay >= _Costs[ ResourceType.Clay ] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Clay ] .. " @color:255,255,255,255 @cr "
	end
			
	if _Costs[ ResourceType.Stone ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone") .. ": " 
		if PlayerStone >= _Costs[ ResourceType.Stone] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Stone ] .. " @color:255,255,255,255 @cr "
	end
	
	if _Costs[ ResourceType.Iron ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron") .. ": " 
		if PlayerIron >= _Costs[ ResourceType.Iron ] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Iron ] .. " @color:255,255,255,255 @cr "
	end
		
	if _Costs[ ResourceType.Sulfur ] ~= 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur") .. ": " 
		if PlayerSulfur >= _Costs[ ResourceType.Sulfur ] then
			CostString = CostString .. " @color:255,255,255,255 "
		else
			CostString = CostString .. " @color:220,64,16,255 "
		end
		CostString = CostString .. _Costs[ ResourceType.Sulfur ] .. " @color:255,255,255,255 @cr "
	end

	return CostString

end
function InterfaceTool_HasPlayerEnoughResources_Feedback( _Costs )
	
	local PlayerID = GUI.GetPlayerID()
	
	
	local Clay = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Clay ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.ClayRaw)	
	local Wood = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Wood ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.WoodRaw)
	local Gold   = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Gold ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.GoldRaw)
	local Iron   = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Iron ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.IronRaw)
	local Stone  = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Stone ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.StoneRaw)
	local Sulfur = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Sulfur ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.SulfurRaw)
	local Silver = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Silver ) + Logic.GetPlayersGlobalResource( PlayerID, ResourceType.SilverRaw)


	local Message = ""
	
	if 	_Costs[ ResourceType.Sulfur ] ~= nil and Sulfur < _Costs[ ResourceType.Sulfur ] then		
		Message = _Costs[ ResourceType.Sulfur ] - Sulfur .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughSulfur")
		GUI.AddNote( Message )
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Sulfur, _Costs[ ResourceType.Sulfur ] - Sulfur )
	end
		
	if 	_Costs[ ResourceType.Silver ] ~= nil and Silver < _Costs[ ResourceType.Silver ] then		
		Message = _Costs[ ResourceType.Silver ] - Silver .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughSilver")
		GUI.AddNote( Message )
		--überprüfen, ob die neuen Sounds im Sounds Table vorhanden sind
		if Sounds.VoicesMentor_LEAVE_Silversmith == nil then
			Stream.Start("Sounds\\VoicesMentor\\INFO_notenoughsilver_rnd_0"..math.random(2)..".wav", 262)
		else
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Silver, _Costs[ ResourceType.Silver ] - Silver )
		end
	end
	
	if _Costs[ ResourceType.Iron ] ~= nil and Iron < _Costs[ ResourceType.Iron ] then		
		Message = _Costs[ ResourceType.Iron ] - Iron .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughIron")
		GUI.AddNote( Message )
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Iron, _Costs[ ResourceType.Iron ] - Iron )
	end
	
	if _Costs[ ResourceType.Stone ] ~= nil and Stone < _Costs[ ResourceType.Stone ] then		
		Message = _Costs[ ResourceType.Stone ] - Stone .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughStone")
		GUI.AddNote( Message )
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Stone, _Costs[ ResourceType.Stone ] - Stone )
	end
	
	if _Costs[ ResourceType.Clay ] ~= nil and Clay < _Costs[ ResourceType.Clay ]  then
		Message = _Costs[ ResourceType.Clay ] - Clay .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughClay")
		GUI.AddNote( Message )
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Clay, _Costs[ ResourceType.Clay ] - Clay )
	end
	
	
	if _Costs[ ResourceType.Wood ] ~= nil and Wood < _Costs[ ResourceType.Wood ]  then
		Message = _Costs[ ResourceType.Wood ] - Wood .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughWood")
		GUI.AddNote( Message )
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Wood, _Costs[ ResourceType.Wood ] - Wood )
	end
	
	if _Costs[ ResourceType.Gold ] ~= nil and Gold < _Costs[ ResourceType.Gold ]  
	and _Costs[ ResourceType.Gold ] ~= 0 then
		Message = _Costs[ ResourceType.Gold ] - Gold .. " " .. XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughMoney")
		GUI.AddNote( Message )
		GUI.SendNotEnoughResourcesFeedbackEvent( ResourceType.Gold, _Costs[ ResourceType.Gold ] - Gold )
	end

	-- Any message
	if Message ~= "" then
		return 0
	else
		return 1
	end
	
end


function InterfaceTool_UpdateUpgradeButtons(_EntityType, _UpgradeCategory, _ButtonNameStem )

	if _ButtonNameStem == "" then
		return
	end

	local Upgrades = {Logic.GetBuildingTypesInUpgradeCategory(_UpgradeCategory)}
	
	if Upgrades[1] == 2 then
		if _EntityType == Upgrades[2] then
			XGUIEng.ShowWidget(_ButtonNameStem .. 1,1)
		else
			XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
		end
	
	elseif Upgrades[1] == 3 then	
		local i
		for i = 1, Upgrades[1], 1
		do		
			if _EntityType == Upgrades[i+1] then
				
			 	if i == 1 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
				elseif i == 2 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,1)
				else
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
				end

			end
		end
	elseif Upgrades[1] == 5 then	
		local i
		for i = 1, Upgrades[1], 1
		do		
			if _EntityType == Upgrades[i+1] then
				
			 	if i == 1 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				elseif i == 2 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				elseif i == 3 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,1)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				elseif i == 4 then
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,1)
				else
					XGUIEng.ShowWidget(_ButtonNameStem .. 1,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 2,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 3,0)
					XGUIEng.ShowWidget(_ButtonNameStem .. 4,0)
				end
			end
		end
	end
end