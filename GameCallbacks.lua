GameCallback_GUI_SelectionChangedOrig = GameCallback_GUI_SelectionChanged;	
--GameCallback_GameSpeedChangedOrig = GameCallback_GameSpeedChanged;
GameCallback_OnTechnologyResearchedOrig = GameCallback_OnTechnologyResearched;	
GameCallback_OnBuildingConstructionCompleteOrig = GameCallback_OnBuildingConstructionComplete;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Selection 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function GameCallback_OnBuildingConstructionComplete(_BuildingID, _PlayerID)
	GameCallback_OnBuildingConstructionCompleteOrig(_BuildingID,_PlayerID)
	
	local eType = Logic.GetEntityType(_BuildingID)
	
	if eType == Entities.PB_Dome then
	
		StartCountdown(10*60,DomeVictory,true)
		
	elseif Scaremonger.MotiEffect[eType] then
	
		for j=1, 16, 1 do
			if Logic.GetDiplomacyState( _PlayerID, j) == Diplomacy.Hostile then			
				for eID in S5Hook.EntityIterator(Predicate.OfPlayer(j), Predicate.OfCategory(EntityCategories.Worker)) do
					local motivation = Logic.GetSettlersMotivation(eID) 
					S5Hook.SetSettlerMotivation(eID, motivation - Scaremonger.MotiEffect[eType] )
				end				
			end
		end
	end
	
end
function GameCallback_GUI_SelectionChanged()
	GameCallback_GUI_SelectionChangedOrig()
	
	-- Get selected entity
	local EntityId = GUI.GetSelectedEntity()
	local SelectedEntities = { GUI.GetSelectedEntities() }
	
	--	
	if EntityId == nil then
		return
	end
	
	-- Get entity type
	local EntityType = Logic.GetEntityType( EntityId )
	local EntityTypeName = Logic.GetEntityTypeName( EntityType )
	
	--Init Sounds
	local SelectionSound = Sounds.Selection_global
	local FunnyComment = 0
	local RandomSelectionSound = XGUIEng.GetRandom(4)
	-- Is selected entity a serf?
	if Logic.IsSerf( EntityId ) == 1 then		

			FunnyComment = Sounds.VoicesSerf_SERF_FunnyComment_rnd_01
			
			local OnlySerfsSelected = 1
			
			local i 
			for i=1, 20, 1 do
				local SerfEntityType = Logic.GetEntityType( SelectedEntities[i] )
				if SelectedEntities [i] == nil then
					break
				elseif SerfEntityType ~= Entities.PU_Serf then
					OnlySerfsSelected = 0
					break
				end
			end
			
			XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionSerf,OnlySerfsSelected)						
			XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "BuildingGroup")
			XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Selection_generic"),1)	
			--XGUIEng.ShowWidget(XGUIEng.GetWidgetID("DetailsAttackRange"),1)
			--XGUIEng.ShowWidget(XGUIEng.GetWidgetID("DetailsAttackSpeed"),1)
			--XGUIEng.ShowWidget(XGUIEng.GetWidgetID("DetailsMoveSpeed"),1)
			--XGUIEng.ShowWidget(XGUIEng.GetWidgetID("DetailsVisionRange"),1)
			--Set contrsuction menu as default and highlight the tab
			XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SerfMenus,0)		
			XGUIEng.ShowWidget(gvGUI_WidgetID.SerfConstructionMenu,1)
			XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "BuildingMenuGroup")
			XGUIEng.HighLightButton(gvGUI_WidgetID.ToSerfBeatificationMenu,1)
			XGUIEng.HighLightButton(XGUIEng.GetWidgetID("SerfToScaremongerMenu"),1)
		
	
	-- Is selected entity a building?
	elseif Logic.IsBuilding( EntityId ) == 1 then
	
		local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(EntityType)
		XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Selection_generic"),1)
		
		--XGUIEng.ShowWidget(XGUIEng.GetWidgetID("DetailsVisionRange"),1)	
		
		--Display building container
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionBuilding,1)
		
		
		
		--Check selected building Type
		if Logic.IsConstructionComplete( EntityId ) == 1 then
		
			local ButtonStem = ""
			
			--Is EntityType the Silvermine?
			if 	UpgradeCategory == UpgradeCategories.SilverMine then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Silvermine"),1)					
				ButtonStem =  "Upgrade_Silvermine"	

			--Is EntityType the Goldmine?
			elseif 	UpgradeCategory == UpgradeCategories.GoldMine then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Goldmine"),1)					
				ButtonStem =  "Upgrade_Goldmine"	
				
			elseif 	UpgradeCategory == UpgradeCategories.Beautification07 then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MechanicalClock"),1)					
			
			elseif 	UpgradeCategory == UpgradeCategories.VillageHall then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("VillageHall"),1)		
				
			--Is EntityType the Market?
			elseif 	UpgradeCategory == UpgradeCategories.Market then
			
				--You can only trade at market level 2
				if EntityType == Entities.PB_Market2 or EntityType == Entities.CB_Castle2 then
					XGUIEng.ShowWidget(gvGUI_WidgetID.Trade,1)
					--Trdae in progress?
					if Logic.GetTransactionProgress(EntityId) ~= 100 then

						XGUIEng.ShowWidget(gvGUI_WidgetID.TradeInProgress,1)
					else			
						XGUIEng.ShowWidget(gvGUI_WidgetID.TradeInProgress,0)
					end
				else
					XGUIEng.ShowWidget(gvGUI_WidgetID.Trade,0)
					XGUIEng.ShowWidget(gvGUI_WidgetID.TradeInProgress,0)
				end
				
				
				
				XGUIEng.ShowWidget(gvGUI_WidgetID.Market,1)					
				ButtonStem =  "Upgrade_Market"
				
				if EntityId ~= gvGUI.LastSelectedEntityID then
					GUIAction_MarketClearDeals()
				end
			
			
			elseif 	UpgradeCategory == UpgradeCategories.Outpost then
			
				XGUIEng.ShowWidget(gvGUI_WidgetID.DestroyBuilding,0)
				XGUIEng.ShowWidget(gvGUI_WidgetID.Outpost,1)					
				XGUIEng.ShowWidget(gvGUI_WidgetID.HQOutpostCommands,1)	
			
				
			--Is EntityType the Tavern?
			--[[elseif 	UpgradeCategory == UpgradeCategories.Tavern then
				XGUIEng.ShowWidget(gvGUI_WidgetID.Tavern,1)					
				ButtonStem =  "Upgrade_Tavern"
				-- max. 5 Diebe pro Spieler auf der Weihnachtsmap
				if gvXmasEventFlag == 1 then
					if Logic.GetNumberOfEntitiesOfTypeOfPlayer(GUI.GetPlayerID(),Entities.PU_Thief) >= 5 then
						--XGUIEng.DisableButton(XGUIEng.GetWidgetID("Buy_Thief"),1)
						XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Buy_Thief"),0)
						--GUI.DeselectEntity(EntityId)
						--GUI.SelectEntity(EntityId)
					else
						--XGUIEng.DisableButton(XGUIEng.GetWidgetID("Buy_Thief"),0)
						XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Buy_Thief"),1)
					end
				end]]
				
			--Is EntityType the weathermanipulator?
			elseif 	UpgradeCategory == UpgradeCategories.Weathermanipulator then				
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Weathermachine"),1)	
			--Is EntityType the Lighthouse?
			elseif 	UpgradeCategory == UpgradeCategories.Lighthouse then				
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Lighthouse"),1)	
				ButtonStem =  "Upgrade_Lighthouse"
			--Is EntityType the MercenaryTower?
			elseif 	UpgradeCategory == UpgradeCategories.Mercenary then				
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MercenaryTower"),1)	
			--Is EntityType the Silversmith?
			elseif 	UpgradeCategory == UpgradeCategories.Silversmith then				
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Silversmith"),1)	
				ButtonStem =  "Upgrade_Silversmith"
			end
			--Update Upgrade Buttons
			InterfaceTool_UpdateUpgradeButtons(EntityType, UpgradeCategory,ButtonStem)								
		end
	end
	
		
	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
		
end
gvGameSpeed = 1
gvBreakCheck = 0
gvSecondsDuringBreak = 0
function GameCallback_GameSpeedChanged( _Speed )
--GameCallback_GameSpeedChangedOrig(_Speed)
local Speed = _Speed * 1000
    if Speed == 0 then
		gvGameSpeed = 0
		if CNetwork then
			StartSimpleJob("RealBreakCheck")
		else
			local PauseScreenType = Logic.GetRandom(4) + 1
			XGUIEng.ShowWidget("PauseScreen"..PauseScreenType,1)
		end
		
        --GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_GamePaused" ) )
       
    else
    	--GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_GameContinues" ) )
		gvGameSpeed = _Speed
		gvBreakCheck = 0
		for i = 1,5 do
			XGUIEng.ShowWidget("PauseScreen"..i,0)   
		end
    end
end

function RealBreakCheck()

	if gvGameSpeed == 0 then
		gvBreakCheck = gvBreakCheck + 1
		gvSecondsDuringBreak = gvSecondsDuringBreak + 1
	else
		gvBreakCheck = 0
	return true
	end
	--mehr als 5 Sekunden pausiert (damit kurze Laggs nicht fälschlich als Pause erkannt werden)
	if gvBreakCheck >= 5 then						
	
		local PauseScreenType = Logic.GetRandom(4) + 1
		XGUIEng.ShowWidget("PauseScreen"..PauseScreenType,1)
		return true
	end
end

function GameCallback_OnTechnologyResearched( _PlayerID, _TechnologyType )
	GameCallback_OnTechnologyResearchedOrig(_PlayerID,_TechnologyType)
	
	if _TechnologyType == Technologies.T_HeavyThunder 
	then
	gvLightning.AdditionalStrikes = gvLightning.AdditionalStrikes + 2
		
	elseif _TechnologyType == Technologies.T_TotalDestruction 
	then
	gvLightning.DamageAmplifier = gvLightning.DamageAmplifier + 0.3
	--
	elseif _TechnologyType == Technologies.T_BarbarianCulture 
	then
		--GUIAction_BarbarianCultureResearched(PlayerID)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_KnightsCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BearmanCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BanditCulture,0)
		
	elseif _TechnologyType == Technologies.T_KnightsCulture 
	then
		--GUIAction_KnightsCultureResearched(_PlayerID)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BarbarianCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BearmanCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BanditCulture,0)
		
	elseif _TechnologyType == Technologies.T_BearmanCulture 
	then
		--GUIAction_BearmanCultureResearched(_PlayerID)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_KnightsCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BarbarianCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BanditCulture,0)
		
	elseif _TechnologyType == Technologies.T_BanditCulture 
	then
		--GUIAction_BanditCultureResearched(_PlayerID)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_KnightsCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BearmanCulture,0)
		Logic.SetTechnologyState(_PlayerID,Technologies.T_BarbarianCulture,0)
		
	elseif _TechnologyType == Technologies.T_Activate_Silversmith_Worker 
	then	
		GUIAction_Activate_Silversmith_Worker_Researched(_PlayerID,Logic.GetRandom(1,Logic.GetTimeMs()))
		
	end
	
	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
	
end
function GameCallback_RefinedResource(_entityID, _type, _amount)
        
    local playerID = Logic.EntityGetPlayer(_entityID);
        
    if _type == ResourceType.Gold then
        if Logic.GetTechnologyState(playerID, Technologies.T_BookKeeping) == 4 then
                
            local work = Logic.GetSettlersWorkBuilding(_entityID);
            _amount = (refined_resource_gold[Logic.GetEntityType(work)] or _amount)
        end;
    end;
        
    if GameCallback_RefinedResourceOrig then
        return GameCallback_RefinedResourceOrig(_entityID, _type, _amount);
    else
        return _entityID, _type, _amount;
    end;
end;

function GameCallback_GainedResourcesFromMine(_extractor, _e, _type, _amount)

	local playerID = Logic.EntityGetPlayer(_extractor);
	
	local work = Logic.GetSettlersWorkBuilding(_extractor)
	
	local resremain = Logic.GetResourceAmountBelowMine(work)
	
	--respective values "mine_running_low" sound is played
	local criticaltresholdsilver = 400
	
	local criticaltresholdgold = 2500
	
	--Sound nur abspielen, wenn die neuen Sounds nicht initialisiert wurden
	if Sounds.VoicesMentor_JOIN_Silversmith == nil then
		if _type == ResourceType.SilverRaw then
			if resremain <= criticaltresholdsilver and resremain > criticaltresholdsilver - _amount then
				Stream.Start("Sounds\\VoicesMentor\\mine_minerunninglowsilver.wav", 262)
			end
			if resremain <= _amount then
				Stream.Start("Sounds\\VoicesMentor\\mine_mineemptysilver.wav", 262)
			end
			
			
		elseif _type == ResourceType.GoldRaw then
			if resremain <= criticaltresholdgold and resremain > criticaltresholdgold - _amount then
				Stream.Start("Sounds\\VoicesMentor\\mine_minerunninglowgold.wav", 262)
			end
			if resremain <= _amount then
				Stream.Start("Sounds\\VoicesMentor\\mine_mineemptygold.wav", 262)
			end
		end
		else
	end
		
	if Logic.GetTechnologyState(playerID, Technologies.T_PickAxe) == 4 then
		if _e ~= nil then
									
			if 		_type == ResourceType.ClayRaw then
				_amount = (gained_resource_clay[Logic.GetEntityType(work)] or _amount)
							
			elseif 	_type == ResourceType.IronRaw then
				_amount = (gained_resource_iron[Logic.GetEntityType(work)] or _amount)
							
			elseif 	_type == ResourceType.StoneRaw then
				_amount = (gained_resource_stone[Logic.GetEntityType(work)] or _amount)
							
			elseif 	_type == ResourceType.SulfurRaw then
				_amount = (gained_resource_sulfur[Logic.GetEntityType(work)] or _amount)
				
			elseif 	_type == ResourceType.SilverRaw then
				_amount = (gained_resource_silver[Logic.GetEntityType(work)] or _amount)
				
			elseif 	_type == ResourceType.GoldRaw then
				_amount = (gained_resource_gold[Logic.GetEntityType(work)] or _amount)
							
			end
		
		end;   
       
		if GameCallback_GainedResourcesFromMineOrig then
            return GameCallback_GainedResourcesFromMineOrig(_extractor, _e, _type, _amount);
        end;
    end;

	return _extractor, _e, _type, _amount;
end

function GameCallback_ConstructBuilding(_csite, _nserfs, _amount)
	
	local playerID = Logic.EntityGetPlayer(_csite);
	if Logic.GetTechnologyState(playerID, Technologies.T_LightBricks) == 4 then
		if _nserfs == 0 then
			_amount = math.ceil(_amount *8/10) or _amount
		end;
	end;
	
	if GameCallback_ConstructBuildingOrig then
        return GameCallback_ConstructBuildingOrig(_csite, _nserfs, _amount);
    else
        return _amount;
    end;
end;
function GameCallback_PlaceBuildingAdditionalCheck(_ucat, _x, _y, _rotation, _isBuildOn)
    local allowed = true;
    if GameCallback_PlaceBuildingAdditionalCheckOrig then
        allowed = GameCallback_PlaceBuildingAdditionalCheckOrig(_ucat, _x, _y, _rotation, _isBuildOn)
        if allowed ~= false then
            allowed = true;
        end;
    end
    return allowed and (Logic.IsMapPositionExplored(GUI.GetPlayerID(), _x, _y) == 1)
end 

function GameCallback_ResearchProgress(_player, _research_building, _technology, _entity, _research_amount, _current_progress, _max)	
	
	local playerID = _player
	if _technology == Technologies.T_CityGuard then
		_research_amount = math.floor((_max + 0.5)/120) or _research_amount
	end
	
	if Logic.GetTechnologyState(playerID, Technologies.T_TownGuard) == 4 then
		_research_amount = math.ceil(_research_amount *1.2) or _research_amount
	end
			
	if GameCallback_ResearchProgressOrig then
		return GameCallback_ResearchProgressOrig(_player, _research_building, _technology, _entity, _research_amount, _current_progress, _max);
	else
		return  _research_amount
	end;
end
function GameCallback_PaydayPayed(_player,_amount)

	if CUtil.Payday_GetFrequency(_player) == 1200 and Logic.GetTechnologyState(_player,Technologies.T_Debenture) == 4 then		
		local frequency = math.floor((CUtil.Payday_GetFrequency(_player))*9/10)
		CUtil.Payday_SetFrequency(_player, frequency)		
	end
	if gvPresent then
		if gvPresent.SDPaydayFactor then
			_amount = round(_amount * gvPresent.SDPaydayFactor[_player])
		end
	end
	return _amount
end	