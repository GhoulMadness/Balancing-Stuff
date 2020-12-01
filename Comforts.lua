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
--Moti wird gesetzt in der GameCallbacks.lua
Scaremonger = {MotiEffect = {
	[Entities.PB_Scaremonger01] = 0.14,
	[Entities.PB_Scaremonger02] = 0.12,
	[Entities.PB_Scaremonger03] = 0.19,
	[Entities.PB_Scaremonger04] = 0.22, 
	[Entities.PB_Scaremonger05] = 0.40,
	[Entities.PB_Scaremonger06] = 0.18 
								}
}

if not gvLastTimeLightningRodUsed then
	gvLastTimeLightningRodUsed = -240000
end
	
if XNetwork.Manager_DoesExist() ~= 0 then
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		Logic.SetTechnologyState(i,Technologies.UP1_Lighthouse,3)
		Logic.SetTechnologyState(i,Technologies.MU_Cannon5,0)
		Logic.SetTechnologyState(i,Technologies.MU_Cannon6,0)
		Logic.SetTechnologyState(i,Technologies.B_VillageHall,0) 
			
	end
	if MP_DiplomacyWindow.resources_to_name then
		MP_DiplomacyWindow.resource_to_name = {
			[ResourceType.GoldRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameMoney") .. " [R]";
			[ResourceType.ClayRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameClay") .. " [R]";
			[ResourceType.WoodRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameWood") .. " [R]";
			[ResourceType.StoneRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameStone") .. " [R]";
			[ResourceType.IronRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameIron") .. " [R]";
			[ResourceType.SulfurRaw] = XGUIEng.GetStringTableText("ingamemessages/GUI_NameSulfur") .. " [R]";
				
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
			[ResourceType.SulfurRaw] = ResourceType.Gold;
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
		
		if MP_DiplomacyWindow.raw_resources_allowed then
			MP_DiplomacyWindow.resource_to_next[ResourceType.Silver] = ResourceType.GoldRaw;
		end;
	end
	
	MultiplayerTools.EntityTableHeadquarters = {Entities.PB_Headquarters1,Entities.PB_Headquarters2,Entities.PB_Headquarters3,Entities.PB_Outpost1}
		

else
	Logic.SetTechnologyState(1,Technologies.UP1_Lighthouse,3)
	Logic.SetTechnologyState(1,Technologies.MU_Cannon5,0)
	Logic.SetTechnologyState(1,Technologies.MU_Cannon6,0)
	Logic.SetTechnologyState(1,Technologies.B_VillageHall,0) 
		
	XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer = function()
		return 1
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
        [Entities.PB_Bank2] = 4;
        [Entities.CB_Mint1] = 5;
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
		[Entities.PB_SilverMine2] = 3;
		[Entities.PB_SilverMine3] = 4;
	};
	
	gained_resource_gold = {
		[Entities.PB_GoldMine1] = 5;
		[Entities.PB_GoldMine2] = 7;
		[Entities.PB_GoldMine3] = 9;
	};
	--Control Siversmith Grievance
	StartSimpleJob("ControlSiversmithGrievance")
end

-----------------------------------------------------------------------------------------------
-- Added Outposts to win condition ------------------------------------------------------------
-----------------------------------------------------------------------------------------------
function VC_Deathmatch()
	
	if XNetwork.Manager_DoesExist() == 0 then
		return
	end
	if MultiplayerTools.GameFinished == 1 then
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
---------------------------------------------------------------------------------------------------------------------------	
   
------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Lighthouse Comforts ----------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
gvLighthouse = { delay = 60 + Logic.GetRandom(30) , troopamount = 2 + Logic.GetRandom(4) , techlevel = 2 + Logic.GetRandom(1) , troops = {
	Entities.PU_LeaderSword1,
	Entities.PU_LeaderPoleArm1,
	Entities.PU_LeaderBow1,
	Entities.PU_LeaderRifle1,
	Entities.PU_LeaderCavalry1,
	Entities.PU_LeaderHeavyCavalry1,
	Entities.PU_LeaderSword2,
	Entities.PU_LeaderPoleArm2,
	Entities.PU_LeaderBow2,
	Entities.PU_LeaderSword3,
	Entities.PU_LeaderPoleArm3,
	Entities.PU_LeaderBow3,
	Entities.PU_LeaderSword4,
	Entities.PU_LeaderPoleArm4,
	Entities.PU_LeaderBow4,
	Entities.PU_LeaderRifle2,
	Entities.PU_LeaderCavalry2,
	Entities.PU_LeaderHeavyCavalry2
									} 
, soldieramount = 2 + Logic.GetRandom(10), soldiercavamount = 1 + Logic.GetRandom(5) , starttime = 0, cooldown = 300
	}

function Lighthouse_SpawnJob(_playerID,_eID)
	local _pos = {}
	_pos.X,_pos.Y = Logic.GetEntityPosition(_eID)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "Lighthouse_SpawnTroops",1,{},{_playerID,_pos.X,_pos.Y} )	
end
function Lighthouse_SpawnTroops(_pID,_posX,_posY)
	if Logic.GetTime() >= gvLighthouse.starttime + gvLighthouse.delay then
		for i = 1,gvLighthouse.troopamount do 
			CreateGroup(_pID,gvLighthouse.troops[Logic.GetRandom(17)+1],gvLighthouse.soldieramount,_posX - 800 ,_posY - 200,0)
		end
		GUI.AddNote("Verst\195\164rkungstruppen sind eingetroffen")
		Stream.Start("Voice\\cm_generictext\\supplytroopsarrive.mp3",110)
		return true
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Mercenary Tower Table -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvMercenaryTower = { LastTimeUsed = 0, Cooldown = {
	["BuyLeaderBarbarian"] = 22,
	["BuyLeaderElite"] = 180,
	["BuyLeaderBanditSword"] = 30,
	["BuyLeaderBanditBow"] = 10,
	["BuyLeaderBlackKnight"] = 8,
	["BuyLeaderEvilBear"] = 25,
	["BuyLeaderEvilSkir"] = 40
	}	, TechReq = {
	["BuyLeaderBarbarian"] = Technologies.T_BarbarianCulture,
	["BuyLeaderElite"] = Technologies.T_BarbarianCulture,
	["BuyLeaderBanditSword"] = Technologies.T_BanditCulture,
	["BuyLeaderBanditBow"] = Technologies.T_BanditCulture,
	["BuyLeaderBlackKnight"] = Technologies.T_KnightsCulture,
	["BuyLeaderEvilBear"] = Technologies.T_BearmanCulture,
	["BuyLeaderEvilSkir"] = Technologies.T_BearmanCulture
	} 	, RechargeButton = {
	["BuyLeaderBarbarian"] = "Barbarian_Recharge",
	["BuyLeaderElite"] = "Elite_Recharge",
	["BuyLeaderBanditSword"] = "BanditSword_Recharge",
	["BuyLeaderBanditBow"] = "BanditBow_Recharge",
	["BuyLeaderBlackKnight"] = "BlackKnight_Recharge",
	["BuyLeaderEvilBear"] = "EvilBear_Recharge",
	["BuyLeaderEvilSkir"] = "EvilSkir_Recharge"
	}
} 

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
end

-----------------------------------------------------------------------------------------------------------
--------------------------- Trading Infl/Defl Limitation and Scale Tech Bonus -----------------------------
-----------------------------------------------------------------------------------------------------------
function TransactionDetails()
	local eID = Event.GetEntityID()
	local TSellTyp = Event.GetSellResource()
	local TSum = Event.GetBuyAmount() 
	local TTyp = Event.GetBuyResource() 
	local Text = " "
	local PID = Logic.EntityGetPlayer(eID)
	local Bonus = 0
	if TTyp == ResourceType.Gold then Text = "Taler"
	elseif TTyp == ResourceType.Iron then Text = "Eisen"
	elseif TTyp == ResourceType.Clay then Text = "Lehm"
	elseif TTyp == ResourceType.Wood then Text = "Holz"
	elseif TTyp == ResourceType.Stone then Text = "Steine"
	elseif TTyp == ResourceType.Sulfur then Text = "Schwefel"
	else
	return
	end
	if Logic.GetTechnologyState(PID,Technologies.T_Scale) == 4 then
		local Bonus = math.ceil((TSum/10)+Logic.GetRandom((TSum/6)))
		Logic.AddToPlayersGlobalResource(PID, TTyp, Bonus )
		if GUI.GetPlayerID() == PID then
			GUI.AddNote("Durch das Ma\195\159 erhaltet ihr "..Bonus.." zus\195\164tzliche/s "..Text.."!")
		else
		end
	else
	end
	if Logic.GetCurrentPrice(PID,TSellTyp) > 1.3 then
		Logic.SetCurrentPrice(PID, TSellTyp, 1.3 )
	end
	if Logic.GetCurrentPrice(PID,TSellTyp) < 0.6 then
		Logic.SetCurrentPrice(PID, TSellTyp, 0.6 )
	end
	if Logic.GetCurrentPrice(PID,TTyp) > 1.7 then
		Logic.SetCurrentPrice(PID, TTyp, 1.7 )
	end
	if Logic.GetCurrentPrice(PID,TTyp) < 0.7 then
		Logic.SetCurrentPrice(PID, TTyp, 0.7 )
	end
end
--------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Blitzeinschläge & Unwetter ---------------------------------------
--------------------------------------------------------------------------------------------------------------------
gvLightning = { Range = 245, BaseDamage = 25, DamageAmplifier = 1, AdditionalStrikes = 0, 
	RecentlyDamaged = 
	{
		false, 
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	},
	
	RodProtected = 
	{
		false, 
		false, 
		false, 
		false, 
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	}	
, 	DamageProofBuildings = {
		[Entities.CB_OldKingsCastleRuin] = true,
		[Entities.CB_Mercenary] = true,
		[Entities.CB_Abbey01] = true,
		[Entities.CB_Abbey02] = true,
		[Entities.CB_Abbey03] = true,
		[Entities.CB_Abbey04] = true,
		[Entities.CB_BarmeciaCastle] = true,
		[Entities.CB_Bastille1] = true,
		[Entities.CB_Camp01] = true,
		[Entities.CB_Camp02] = true,
		[Entities.CB_Camp03] = true,
		[Entities.CB_Camp04] = true,
		[Entities.CB_Camp05] = true,
		[Entities.CB_Camp06] = true,
		[Entities.CB_Camp07] = true,
		[Entities.CB_Camp08] = true,
		[Entities.CB_Camp09] = true,
		[Entities.CB_Camp10] = true,
		[Entities.CB_Camp11] = true,
		[Entities.CB_Camp12] = true,
		[Entities.CB_Camp13] = true,
		[Entities.CB_Camp14] = true,
		[Entities.CB_Camp15] = true,
		[Entities.CB_Camp16] = true,
		[Entities.CB_Camp17] = true,
		[Entities.CB_Camp18] = true,
		[Entities.CB_Camp19] = true,
		[Entities.CB_Camp20] = true,
		[Entities.CB_Camp21] = true,
		[Entities.CB_Camp22] = true,
		[Entities.CB_Camp23] = true,
		[Entities.CB_Camp24] = true,
		[Entities.CB_Castle1] = true,
		[Entities.CB_CleycourtCastle] = true,
		[Entities.CB_CrawfordCastle] = true,
		[Entities.CB_DarkCastle] = true,
		[Entities.CB_DestroyAbleRuinHouse1] = true,
		[Entities.CB_DestroyAbleRuinMonastery1] = true,
		[Entities.CB_DestroyAbleRuinResidence1] = true,
		[Entities.CB_DestroyAbleRuinSmallTower1] = true,
		[Entities.CB_DestroyAbleRuinSmallTower3] = true,
		[Entities.CB_FolklungCastle] = true,
		[Entities.CB_HermitHut1] = true,
		[Entities.CB_InventorsHut1] = true,
		[Entities.CB_KaloixCastle] = true,
		[Entities.CB_MinerCamp1] = true,
		[Entities.CB_MinerCamp2] = true,
		[Entities.CB_MinerCamp3] = true,
		[Entities.CB_MinerCamp4] = true,
		[Entities.CB_MinerCamp5] = true,
		[Entities.CB_MinerCamp6] = true,
		[Entities.CB_MonasteryBuildingSite1] = true,
		[Entities.CB_OldKingsCastle] = true,
		[Entities.CB_SteamMashine] = true,
		[Entities.CB_TechTrader] = true,
		[Entities.XD_WallCorner] = true,
		[Entities.XD_WallDistorted] = true,
		[Entities.XD_WallStraight] = true,
		[Entities.XD_WallStraightGate] = true,
		[Entities.XD_WallStraightGate_Closed] = true,
		[Entities.XD_DarkWallCorner] = true,
		[Entities.XD_DarkWallDistorted] = true,
		[Entities.XD_DarkWallStraight] = true,
		[Entities.XD_DarkWallStraightGate] = true,
		[Entities.XD_DarkWallStraightGate_Closed] = true,
		[Entities.ZB_ConstructionSite1] = true, 
		[Entities.ZB_ConstructionSite2] = true,
		[Entities.ZB_ConstructionSite3] = true, 
		[Entities.ZB_ConstructionSite4] = true,
		[Entities.ZB_ConstructionSite5] = true,
		[Entities.ZB_ConstructionSiteArchery1] = true,
		[Entities.ZB_ConstructionSiteBarracks1] = true,
		[Entities.ZB_ConstructionSiteStables1] = true,
		[Entities.ZB_ConstructionSiteBlacksmith1] = true,
		[Entities.ZB_ConstructionSiteFarm1] = true,
		[Entities.ZB_ConstructionSiteResidence1] = true,
		[Entities.ZB_ConstructionSiteMarket1] = true,
		[Entities.ZB_ConstructionSiteMint1] = true,
		[Entities.ZB_ConstructionSiteMonastery1] = true,
		[Entities.ZB_ConstructionSiteIronMine1] = true,
		[Entities.ZB_ConstructionSiteStoneMine1] = true,
		[Entities.ZB_ConstructionSiteSulfurMine1] = true,
		[Entities.ZB_ConstructionSiteStonemason1] = true, 
		[Entities.ZB_ConstructionSiteTower1] = true,
		[Entities.ZB_ConstructionSiteUniversity1] = true,
		[Entities.ZB_ConstructionSiteVillageCenter1] = true,
		[Entities.ZB_ConstructionSiteDome1] = true
	}
}
function IsLightningProofBuilding(_entityID)
	return gvLightning.DamageProofBuildings[Logic.GetEntityType(_entityID)] 
end
function Unwetter() 
	local Mapsize = Logic.WorldGetSize()
	--Menge an Blitzen pro Sekunde abhängig von der Fläche der Map
	local Amount = round(((Mapsize/100)^2)/70000)
	--Blitzeinschläge nur bei Regen
	if Logic.GetWeatherState() == 2 then
		local range = gvLightning.Range + Logic.GetRandom(gvLightning.Range)
		local damage = gvLightning.BaseDamage + Logic.GetRandom(gvLightning.BaseDamage) 
		local buildingdamage = (((gvLightning.BaseDamage + Logic.GetRandom(gvLightning.BaseDamage))*3) + (S5Hook.GetRawMem(tonumber("0x85A3A0", 16))[0][11][10]:GetInt()*5))*gvLightning.DamageAmplifier
		
		local posTable = {X = {},Y = {} }		
		for i = 1,Amount do		
			table.insert(posTable.X,Logic.GetRandom(Mapsize))		
			table.insert(posTable.Y,Logic.GetRandom(Mapsize))
		
			Logic.Lightning(posTable.X[i],posTable.Y[i])
			Lightning_Damage(posTable.X[i],posTable.Y[i],range,damage,buildingdamage)
		end
		--noch mehr Blitze bei Unwetter (Gfx-Set 11)
		if S5Hook.GetRawMem(tonumber("0x85A3A0", 16))[0][11][10]:GetInt() == 11 then
			local posiTable = {X = {},Y = {} }		
			for i = 1,((Amount*2)+gvLightning.AdditionalStrikes) do		
				table.insert(posiTable.X,Logic.GetRandom(Mapsize))		
				table.insert(posiTable.Y,Logic.GetRandom(Mapsize))
			
				Logic.Lightning(posiTable.X[i],posiTable.Y[i])
				Lightning_Damage(posiTable.X[i],posiTable.Y[i],range,damage,buildingdamage)
			end
		end
		local pID = GUI.GetPlayerID()
		if gvLightning.RecentlyDamaged[pID] == true then
			Sound.PlayGUISound( Sounds.OnKlick_Select_varg, 152 ) 
			Sound.PlayGUISound( Sounds.OnKlick_PB_Tower3, 164 ) 
			Sound.PlayGUISound( Sounds.OnKlick_PB_PowerPlant1, 112 )
			Sound.PlayGUISound(Sounds.AmbientSounds_rainmedium,210)
			Stream.Start("Sounds\\Misc\\SO_buildingdestroymedium.wav",62)
			gvLightning.RecentlyDamaged[pID] = false
		end
    end	
end
function Lightning_Damage(_posX,_posY,_range,_damage,_buildingdamage)

    for eID in S5Hook.EntityIterator(Predicate.NotOfPlayer0(), Predicate.InCircle(_posX, _posY, _range)) do
	
		if Logic.IsHero(eID) == 1 or Logic.IsSerf(eID) == 1 or Logic.IsEntityInCategory(eID, EntityCategories.Cannon) == 1 then
			Logic.HurtEntity(eID, _damage)
			if GUI.GetPlayerID() == Logic.EntityGetPlayer(eID) then
				gvLightning.RecentlyDamaged[Logic.EntityGetPlayer(eID)] = true
				GUI.ScriptSignal(_posX, _posY, 0)
			end
		end
			
			if Logic.IsLeader(eID) == 1 then
				local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
					if Soldiers[1] >= 8 then
						for i = 2,4 do
							ChangeHealthOfEntity(Soldiers[i],0)
						end
					elseif Soldiers[1] >= 4 and Soldiers[1] <=7 then
						for i = 2,3 do
							ChangeHealthOfEntity(Soldiers[i],0)
						end
					elseif Soldiers[1] <= 3 then
						ChangeHealthOfEntity(Soldiers[2],0)
					elseif Soldiers[1] == 0 then
						Logic.HurtEntity(eID, _damage)
					end
				if GUI.GetPlayerID() == Logic.EntityGetPlayer(eID) then
					gvLightning.RecentlyDamaged[Logic.EntityGetPlayer(eID)] = true
					GUI.ScriptSignal(_posX, _posY, 0)
				end
			end
			
		if Logic.IsBuilding(eID) == 1 then 
			if IsLightningProofBuilding(eID) ~= true then
				if Logic.IsConstructionComplete(eID) == 1 then
					local PID = Logic.EntityGetPlayer(eID)
					if gvLightning.RodProtected[PID] == false then
						Logic.HurtEntity(eID, _buildingdamage)
						if Logic.GetTechnologyState(PID,Technologies.T_LightningInsurance) == 4 then
							if _buildingdamage ~= nil then
								local InsuranceCash = math.floor(_buildingdamage)
								Logic.AddToPlayersGlobalResource(PID,ResourceType.GoldRaw,InsuranceCash)
								if GUI.GetPlayerID() == PID then
									GUI.AddNote("Durch die abgeschlossene Blitzschlag-Versicherung erhaltet ihr ".. InsuranceCash .." zus\195\164tzliche Taler")
								end
							end
						end
						if GUI.GetPlayerID() == PID then
							gvLightning.RecentlyDamaged[Logic.EntityGetPlayer(eID)] = true
							GUI.ScriptSignal(_posX, _posY, 0)							
						end
					end
				end
			end
		end   	
	end
end
function ChangeToThunderstorm(_playerID,_EntityID)
	if Logic.GetEntityType(_EntityID) ~= Entities.PB_WeatherTower1 then
		return
	end
	Logic.AddWeatherElement(2,120,0,11,5,15)
	Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetEnergyRequiredForWeatherChange()))
	--in case the player still has energy left, bring him down to zero!
	if Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy ) > Logic.GetEnergyRequiredForWeatherChange() then
		Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy )))
	end
	GUI.DeselectEntity(_EntityID)
	GUI.SelectEntity(_EntityID)
end	
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------- DZ Trade Punishment --------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
gvDZTradeCheck = {PlayerDelay = {}, PlayerTime = {}, amount = 0.007 + Logic.GetRandom(0.008), factor = 1.1 + (Logic.GetRandom(5)/10), treshold = 15 + Logic.GetRandom(15), }
function DZTrade_Init()
	
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		gvDZTradeCheck.PlayerTime[i] = -1
		gvDZTradeCheck.PlayerDelay[i] = 60 + Logic.GetRandom(20)

	end
	StartSimpleJob("DZTradePunishmentJob")
	
end
function DZTradePunishmentJob()
	for player = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if Logic.GetPlayerAttractionUsage(player) >= (Logic.GetPlayerAttractionLimit(player) + gvDZTradeCheck.treshold) then
			if DZTradePunishmentProtected(player) == 0 then
				if gvDZTradeCheck.PlayerTime[player] == - 1 then
					gvDZTradeCheck.PlayerTime[player] = Logic.GetTime()	+ gvDZTradeCheck.PlayerDelay[player]
				end
			end
			gvDZTradeCheck.PlayerDelay[player] = gvDZTradeCheck.PlayerDelay[player] - 1	
			if gvDZTradeCheck.PlayerDelay[player] == 0 then
				local r,g,b = GUI.GetPlayerColor(player)
				GUI.AddNote(" @color:r,g,b "..UserTool_GetPlayerName(player).." @color:255,255,255 verf\195\188gt \195\188ber zu wenig Platz f\195\188r seine Siedler." )
				GUI.AddNote( "Dies wird den Siedlern nicht gefallen und sie werden die Siedlung bald verlassen!")
				Stream.Start("Sounds\\voicesmentor\\comment_badplay_rnd_06.wav",190)
			end
			if gvDZTradeCheck.PlayerDelay[player] <= 0 then
				DZTradePunishment(player)
			end
		else
		gvDZTradeCheck.PlayerTime[player] = - 1
		gvDZTradeCheck.PlayerDelay[player] = 60 + Logic.GetRandom(20)
		end
	end
end
function DZTradePunishment(_playerID)		
	local timepassed = math.floor((Logic.GetTime() - gvDZTradeCheck.PlayerTime[_playerID])/4)
	for eID in S5Hook.EntityIterator(Predicate.OfPlayer(_playerID), Predicate.OfCategory(EntityCategories.Worker)) do
		local motivation = Logic.GetSettlersMotivation(eID) 
		if motivation >= 0.29 then
		S5Hook.SetSettlerMotivation(eID, motivation - math.min(math.floor((gvDZTradeCheck.amount*(gvDZTradeCheck.factor^timepassed))*100)/100,0.08) )
		end
	end
end
function DZTradePunishmentProtected(_playerID)		
	local DZTable = {	Logic.GetPlayerEntities(_playerID, Entities.PB_VillageCenter3, 10)	}
	local HPTable = {}
	table.remove(DZTable,1)
	for i = 1,table.getn(DZTable) do 
		HPTable[i] = GetEntityHealth(DZTable[i]) 
		local minHP = math.min(HPTable[i],100)
		if minHP <= 80 or AreEntitiesOfDiplomacyStateInArea(_playerID,Logic.GetEntityPosition(DZTable[i]),3200,Diplomacy.Hostile) == true then
			return 1
		else
			return 0
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------ Trigger für Spezialgebäude ----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
function SpezEntityPlaced()

    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)
    local playerID = GetPlayer(entityID)
	local pos = {Logic.GetEntityPosition(Logic.GetEntityIDByName(entityID))}
    if entityType == Entities.PB_Dome then       
	
		GUI.ScriptSignal(pos[1],pos[2],1)
		GUI.CreateMinimapPulse(pos[1],pos[2],1)
		
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do 
		CreateEntity(i, Entities.XD_Explore10,pos)
	end
		DomePlaced(playerID,entityID,pos[1],pos[2])
	end
	if entityType == Entities.PU_Silversmith then
		--wenn neue Sounds vorhanden, wird das bereits über xml geregelt
		if Sounds.VoicesMentor_JOIN_Silversmith ~= nil then
			return
		end
		if Logic.GetNumberOfEntitiesOfTypeOfPlayer(playerID,entityType,10) == 1 then
			if playerID == GUI.GetPlayerID() then
				Sound.PlayFeedbackSound(0,0)
				GUI.SetFeedbackSoundOutputState(0)
				Music.SetVolumeAdjustment(Music.GetVolumeAdjustment() * 0.5)
				Stream.Start("Sounds\\VoicesMentor\\join_silversmith.wav", 262)
				StartCountdown(math.ceil(Stream.GetDuration()),Unmuting,false)
			end
		end
	end
end
function DomeFallen()

    local entityID = Event.GetEntityID()
    local entityTypeID = Logic.GetEntityTypeName(Logic.GetEntityType(entityID))
    local playerID = GetPlayer(entityID)
    if entityTypeID == "PB_Dome" then  
	
		Logic.PlayerSetGameStateToLost(playerID)
		for k = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
			if Logic.GetDiplomacyState(playerID, k) == Diplomacy.Friendly then
					
				Logic.PlayerSetGameStateToLost(k)					
			else 					
				Logic.PlayerSetGameStateToWon(k)					
			end
		end
	end
end
function DomePlaced(_pID,_eID,_posX,_posY)

	if Logic.IsConstructionComplete(_eID) == 1 then
		
		StartCountdown(10*60,DomeVictory,true)
	end
end

function DomeVictory()
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do 
		if Logic.GetNumberOfEntitiesOfTypeOfPlayer(i,Entities.PB_Dome) >= 1 then
			
			for k = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
				if Logic.GetDiplomacyState(i, k) == Diplomacy.Hostile then
					
						Logic.PlayerSetGameStateToLost(k)					
				else 					
						Logic.PlayerSetGameStateToWon(k)					
				end
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Silversmith Grievance Job ------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ControlSiversmithGrievance()
	-- Need to reset globals?
	if not gvSpeech then 
		return
	end
	if gvSpeech.ResetGlobalsFlag == 1 then
		Speech_Privat_InitGlobals()
		return
	end
	--not needed if the Sounds are already valid
	if Sounds.VoicesMentor_LEAVE_Silversmith ~= nil then
		return
	end
	
    -----------------------------------------------------------------------------------------------
    -- Get current game time
    local GameTimeMS = Logic.GetTimeMs()
    
    	
    -----------------------------------------------------------------------------------------------
    -- Get player ID
    local PlayerID = GUI.GetPlayerID()
	-----------------------------------------------------------------------------------------------
    -- System stuff
    
	-- Decrement wait counter; return when time to wait bigger than 0	
    if gvSpeech.SecondsToWait ~= 0 then
		gvSpeech.SecondsToWait = gvSpeech.SecondsToWait - 1
		if gvSpeech.SecondsToWait > 0 then
			return
        end
        gvSpeech.SecondsToWait = 0
	end
	

	--Don't play speeches during cinematics
	if gvInterfaceCinematicFlag == 1 then
		return
	end
	 -----------------------------------------------------------------------------------------------
    -- Settler grievance
    do
		-------------------------------------------------------------------------------------------
		-- No work
		
		-- Settler is leaving, because of no work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateLeaving, Feedback.SettlerReasonNoWork )
 			if LastGrievanceMS > gvSpeech.GrievanceLeavingNoWorkBanGameTimeMS then
				gvSpeech.GrievanceLeavingNoWorkBanGameTimeMS = GameTimeMS 
				gvSpeech.GrievanceAngryNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
		-- Settler is angry, because of no work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateAngry, Feedback.SettlerReasonNoWork )
 			if LastGrievanceMS > gvSpeech.GrievanceAngryNoWorkBanGameTimeMS then
				gvSpeech.GrievanceAngryNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
		-- Settler is sad, because of no work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateSad, Feedback.SettlerReasonNoWork )
 			if LastGrievanceMS > gvSpeech.GrievanceSadNoWorkBanGameTimeMS then
				gvSpeech.GrievanceSadNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
		-------------------------------------------------------------------------------------------
		-- Taxes
		
		-- Settler is leaving, because of taxes
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateLeaving, Feedback.SettlerReasonTaxes )
 			if LastGrievanceMS > gvSpeech.GrievanceLeavingTaxesBanGameTimeMS then
				gvSpeech.GrievanceLeavingTaxesBanGameTimeMS = GameTimeMS 
				gvSpeech.GrievanceAngryTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
	
		-- Settler is angry, because of taxes
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateAngry, Feedback.SettlerReasonTaxes )
 			if LastGrievanceMS > gvSpeech.GrievanceAngryTaxesBanGameTimeMS then
				gvSpeech.GrievanceAngryTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
		
		-- Settler is sad, because of taxes
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateSad, Feedback.SettlerReasonTaxes )
 			if LastGrievanceMS > gvSpeech.GrievanceSadTaxesBanGameTimeMS then
				gvSpeech.GrievanceSadTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
		-------------------------------------------------------------------------------------------
		-- Too much work
		
		-- Settler is leaving, because of too much work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateLeaving, Feedback.SettlerReasonTooMuchWork )
 			if LastGrievanceMS > gvSpeech.GrievanceLeavingTooMuchWorkBanGameTimeMS then
				gvSpeech.GrievanceLeavingTooMuchWorkBanGameTimeMS = GameTimeMS 
				gvSpeech.GrievanceAngryTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 262)
					----StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooMuchWork,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
	
		-- Settler is angry, because of too much work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateAngry, Feedback.SettlerReasonTooMuchWork )
 			if LastGrievanceMS > gvSpeech.GrievanceAngryTooMuchWorkBanGameTimeMS then
				gvSpeech.GrievanceAngryTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 262)
					----StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooMuchWork,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
		
		-- Settler is sad, because of too much work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateSad, Feedback.SettlerReasonTooMuchWork )
 			if LastGrievanceMS > gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS then
				gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 262)
					----StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooMuchWork,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
	end
end
--[[defined by grievance xml, not needed
function GrievanceReasonTooMuchWork()
	Sound.PlayQueuedFeedbackSound( Sounds.VoicesMentor_REASON_SettlerForcedToWork, 0 )	
	--Stream.Start("Sounds\\VoicesMentor\\REASON_SettlerForcedToWork", 100)
end
function GrievanceReasonTooHighTaxes()
	Sound.PlayQueuedFeedbackSound( Sounds.VoicesMentor_REASON_SettlerToHighTaxes, 0 )	
	--Stream.Start("Sounds\\VoicesMentor\\REASON_SettlerToHighTaxes", 100)
end]]
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NoTabAllowed()
	Message("Tab ist aus technischen Gr\195\188nden auf dieser Map funktionslos!")
end
function HideGUI()
	XGUIEng.ShowWidget("BackGround_BottomLeft",0)
	XGUIEng.ShowWidget("MiniMapOverlay",0) 
	XGUIEng.ShowWidget("MiniMap",0) 
	XGUIEng.ShowWidget("ResourceView",0) 
	XGUIEng.ShowWidget("MinimapButtons",0) 
	XGUIEng.ShowWidget("Top",0) 
	XGUIEng.ShowWidget("FindView",0) 
	XGUIEng.ShowWidget("Normal",0)
end
function WinterTheme()
	if Logic.GetWeatherState() == 3 then
		local SoundChance = Logic.GetRandom(30)
			if SoundChance == 10 then
			Sound.PlayGUISound(Sounds.AmbientSounds_winter_rnd1,270)
		end
	end
end
gvIngameTimeSec = 0
function IngameTimeJob()
	if gvGameSpeed ~= 0 then
		gvIngameTimeSec = gvIngameTimeSec + 1
	end
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
	for eID in S5Hook.EntityIterator(Predicate.OfPlayer(_pID), Predicate.InCircle(_x, _y, _range)) do
		if GetDistance({Logic.GetEntityPosition(Logic.GetEntityIDByName(eID))},{X=_x,Y=_y}) <= Logic.GetEntityExplorationRange(eID) then
			return 1
			else
			return 0
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