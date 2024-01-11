GameCallback_RefinedResourceOrig = GameCallback_RefinedResource
GameCallback_GainedResourcesFromMineOrig = GameCallback_GainedResourcesFromMine
GameCallback_ConstructBuildingOrig = GameCallback_ConstructBuilding
GameCallback_PlaceBuildingAdditionalCheckOrig = GameCallback_PlaceBuildingAdditionalCheck
GameCallback_ResearchProgressOrig = GameCallback_ResearchProgress
GameCallback_GUI_SelectionChangedOrig = GameCallback_GUI_SelectionChanged
GameCallback_OnTechnologyResearchedOrig = GameCallback_OnTechnologyResearched
GameCallback_OnBuildingConstructionCompleteOrig = GameCallback_OnBuildingConstructionComplete
HeroWidgetUpdate_ShowHeroWidgetOrig = HeroWidgetUpdate_ShowHeroWidget
GameCallback_GUI_EntityIDChangedOrig = GameCallback_GUI_EntityIDChanged
GameCallback_UnknownTaskOrig = GameCallback_UnknownTask
Mission_OnSaveGameLoadedOrig = Mission_OnSaveGameLoaded
GameCallback_ResourceTakenOrig = GameCallback_ResourceTaken

function Mission_OnSaveGameLoaded()
	Mission_OnSaveGameLoadedOrig()
	MultiplayerTools.OnSaveGameLoaded = function()
	end
	if SendEvent and not next(SendEvent) then
		SendEvent = nil
	end
	CUtil.EnableEntityTypeAsUgradeCategory()
	BS.GfxInit()
	CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_GUI.xml")
	if not CNetwork then
		if GDB.IsKeyValid("Config\\SettlerServer\\ColorPlayer") then
			local PlayerColor = GDB.GetValue("Config\\SettlerServer\\ColorPlayer")
			Display.SetPlayerColorMapping(1, PlayerColor)
		end
	end
	for i = 1,16 do
		CUtil.Payday_SetActive(i, true)
	end
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
	for i = 1, XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		Display.SetPlayerColorMapping(i, XNetwork.GameInformation_GetLogicPlayerColor(i))
	end
	gvGUI_WidgetID.TaxesButtonsOP = {}
	gvGUI_WidgetID.TaxesButtonsOP[0] = 	"SetVeryLowTaxes_OP"
	gvGUI_WidgetID.TaxesButtonsOP[1] = 	"SetLowTaxes_OP"
	gvGUI_WidgetID.TaxesButtonsOP[2] = 	"SetNormalTaxes_OP"
	gvGUI_WidgetID.TaxesButtonsOP[3] = 	"SetHighTaxes_OP"
	gvGUI_WidgetID.TaxesButtonsOP[4] = 	"SetVeryHighTaxes_OP"

	ResumeEntityOrig = Logic.ResumeEntity
	Logic.ResumeEntity = function(_id)
		ResumeEntityOrig(_id)
		if Logic.IsHero(_id) == 1 or Logic.IsLeader(_id) == 1 or Logic.IsSerf(_id) == 1 or Logic.IsEntityInCategory(_id, EntityCategories.Cannon) == 1 or Logic.IsWorker(_id) == 1 then
			Logic.SetEntityScriptingValue(_id, 72, 1)
		end
	end

	GetFoundationTopOrig = Logic.GetFoundationTop
	Logic.GetFoundationTop = function(_id)
		assert(IsValid(_id))
		return GetFoundationTopOrig(_id)
	end

	GetAttachedEntitiesOrig = CEntity.GetAttachedEntities
	CEntity.GetAttachedEntities = function(_id)
		assert(IsValid(_id))
		return GetAttachedEntitiesOrig(_id)
	end

	Entity_ConnectLeaderOrig = AI.Entity_ConnectLeader
	AI.Entity_ConnectLeader = function(_id, _armyID)
		assert(IsValid(_id))
		assert(_armyID >= -1 and _armyID <= 8)
		return Entity_ConnectLeaderOrig(_id, _armyID)
	end

	GroupAttackOrig = Logic.GroupAttack
	Logic.GroupAttack = function(_id, _target)
		assert(IsValid(_id))
		assert(IsValid(_target))
		return GroupAttackOrig(_id, _target)
	end

	Army_GetEntityIdOfEnemyOrig = AI.Army_GetEntityIdOfEnemy
	AI.Army_GetEntityIdOfEnemy = function(_player, _id)
		if _id >= 0 and _id <= 8 then
			return Army_GetEntityIdOfEnemyOrig(_player, _id)
		else
			return Army_GetEntityIdOfEnemyOrig(_player, 0)
		end
	end

	Army_SetScatterToleranceOrig = AI.Army_SetScatterTolerance
	AI.Army_SetScatterTolerance = function(_player, _id, _val)
		if _id >= 0 and _id <= 8 then
			Army_SetScatterToleranceOrig(_player, _id, _val)
		end
	end

	Army_SetSizeOrig = AI.Army_SetSize
	AI.Army_SetSize = function(_player, _id, _val)
		if _id >= 0 and _id <= 8 then
			Army_SetSizeOrig(_player, _id, _val)
		end
	end
end
-- 3 thiefs max. on xmas-tree related maps
if gvXmasEventFlag == 1 then
	function GameCallback_PreBuyLeader(_buildingID, _uCat)
		local player = Logic.EntityGetPlayer(_buildingID)

		if _uCat == UpgradeCategories.Thief then
			local nthiefs = Logic.GetNumberOfEntitiesOfTypeOfPlayer(player, Entities.PU_Thief)
			if nthiefs >= 3 then
				return false
			end
		end
		return true
	end
end

function GameCallback_OnBuildingConstructionComplete(_BuildingID, _PlayerID)
	GameCallback_OnBuildingConstructionCompleteOrig(_BuildingID,_PlayerID)

	local eType = Logic.GetEntityType(_BuildingID)

	if eType == Entities.PB_Dome then
		local MotiHardCap = CUtil.GetPlayersMotivationHardcap(_PlayerID)
		CUtil.AddToPlayersMotivationHardcap(_PlayerID, 1)
		StartCountdown(10*60,DomeVictory,true,"Dome_Victory")
	elseif eType == Entities.PB_ForestersHut1 then
		OnForester_Created(_BuildingID)
	elseif eType == Entities.PB_WoodcuttersHut1 then
		OnWCutter_Created(_BuildingID)
	elseif Scaremonger.MotiEffect[eType] then
		Scaremonger.MotiDebuff(_PlayerID,eType)
	elseif eType == Entities.PB_Beautification13 then
		CUtil.AddToPlayersMotivationHardcap(_PlayerID, 0.25)

		for j=1, 16, 1 do
			if Logic.GetDiplomacyState(_PlayerID, j) == Diplomacy.Friendly then
				CUtil.AddToPlayersMotivationHardcap(j, 0.25)
				CUtil.AddToPlayersMotivationSoftcap(j, 0.25)
				for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(j), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
					local motivation = Logic.GetSettlersMotivation(eID)
					CEntity.SetMotivation(eID, motivation + 0.25 )
				end
			end
		end

	elseif eType == Entities.PB_VictoryStatue1 then
		gvVStatue1.Amount[_PlayerID] = gvVStatue1.Amount[_PlayerID] + 1
		if CUtil.GetPlayersMotivationSoftcap(_PlayerID) < (2.0) then
			CUtil.AddToPlayersMotivationSoftcap(_PlayerID, 2.0 - CUtil.GetPlayersMotivationSoftcap(_PlayerID))

			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_PlayerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
				CEntity.SetMotivation(eID, 2.0)
			end
		end

	elseif eType == Entities.PB_VictoryStatue3 then
		gvVStatue3.Amount[_PlayerID] = gvVStatue3.Amount[_PlayerID] + 1

	elseif eType == Entities.PB_VictoryStatue4 then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "VStatue4_CalculateDamageTrigger", 1, {}, {_BuildingID, _PlayerID})

	elseif eType == Entities.PB_VictoryStatue5 then
		local players = BS.GetAllEnemyPlayerIDs(_PlayerID)
		for i = 1, table.getn(players) do
			if CUtil.GetPlayersMotivationSoftcap(players[i]) > (2.75) then
				CUtil.AddToPlayersMotivationSoftcap(players[i], 2.75 - CUtil.GetPlayersMotivationSoftcap(players[i]))
			end
		end
		for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(players)), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
			CEntity.SetMotivation(eID, 2.75)
		end

	elseif eType == Entities.PB_VictoryStatue6 then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "VStatue6_ApplyDamageTrigger", 1, {}, {_BuildingID, _PlayerID})

	elseif eType == Entities.PB_VictoryStatue7 then
		gvVStatue7.Countdown[_PlayerID] = StartCountdown(10*60, gvVStatue7.VictoryTimer, true, "VStatue7_Victory_".. _PlayerID, _PlayerID)

	elseif eType == Entities.PB_VictoryStatue8 then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "VStatue8_CalculateDamageTrigger", 1, {}, {_BuildingID, _PlayerID})

	elseif eType == Entities.PB_VictoryStatue9 then
		gvVStatue9.Amount[_PlayerID] = gvVStatue9.Amount[_PlayerID] + 1
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Selection
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
			for i = 1, 20, 1 do
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

		--Display building container
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionBuilding,1)

		--Check selected building Type
		if Logic.IsConstructionComplete( EntityId ) == 1 then

			--Check for Coal button
			if gvCoal.AllowedTypes[EntityType] then
				XGUIEng.ShowWidget("ToggleCoalUsage",1)
			else
				XGUIEng.ShowWidget("ToggleCoalUsage",0)
			end

			local ButtonStem = ""

			--Is EntityType the Silvermine?
			if UpgradeCategory == UpgradeCategories.SilverMine then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Silvermine"),1)
				ButtonStem = "Upgrade_Silvermine"
			--Is Entity a outpost?
			elseif UpgradeCategory == UpgradeCategories.Outpost then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Outpost"),1)
				XGUIEng.ShowWidget(gvGUI_WidgetID.DestroyBuilding,0)
				ButtonStem = "Upgrade_Outpost"
			--Is EntityType the Goldmine?
			elseif UpgradeCategory == UpgradeCategories.GoldMine then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Goldmine"),1)
				ButtonStem =  "Upgrade_Goldmine"
			--Is EntityType the Coalmine?
			elseif UpgradeCategory == UpgradeCategories.Coalmine then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Coalmine"),1)
				ButtonStem =  "Upgrade_Coalmine"

			elseif UpgradeCategory == UpgradeCategories.Beautification07 then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MechanicalClock"),1)

			elseif UpgradeCategory == UpgradeCategories.VillageHall then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("VillageHall"),1)

			elseif UpgradeCategory == UpgradeCategories.Archers_Tower then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Archers_Tower"),1)

			--Is EntityType the Market?
			elseif UpgradeCategory == UpgradeCategories.Market then

				--You can only trade at market level 2 or higher
				if EntityType == Entities.PB_Market2 or EntityType == Entities.PB_Market3 then
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

			elseif UpgradeCategory == UpgradeCategories.Castle then

				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Castle"),1)
				XGUIEng.ShowWidget(gvGUI_WidgetID.DestroyBuilding,0)
				ButtonStem =  "Upgrade_Castle"

			--Is EntityType the weathermanipulator?
			elseif UpgradeCategory == UpgradeCategories.Weathermanipulator then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Weathermachine"),1)
			--Is EntityType the Lighthouse?
			elseif UpgradeCategory == UpgradeCategories.Lighthouse then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Lighthouse"),1)
				ButtonStem =  "Upgrade_Lighthouse"
			--Is EntityType the MercenaryTower?
			elseif UpgradeCategory == UpgradeCategories.Mercenary then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("MercenaryTower"),1)
			--Is EntityType the Mint?
			elseif UpgradeCategory == UpgradeCategories.Mint then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Mint"),1)
			--Is EntityType the Silversmith?
			elseif UpgradeCategory == UpgradeCategories.Silversmith then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Silversmith"),1)
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("OvertimesButtonEnable"),0)
				ButtonStem =  "Upgrade_Silversmith"
			--Is EntityType the Forester?
			elseif UpgradeCategory == UpgradeCategories.Forester then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Forester"),1)
			--Is EntityType the Woodcutter?
			elseif UpgradeCategory == UpgradeCategories.Woodcutter then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Woodcutter"),1)
			--Is EntityType the Coalmaker?
			elseif UpgradeCategory == UpgradeCategories.Coalmaker then
				XGUIEng.ShowWidget(XGUIEng.GetWidgetID("Coalmaker"),1)
			end
			--Update Upgrade Buttons
			InterfaceTool_UpdateUpgradeButtons(EntityType, UpgradeCategory,ButtonStem)
		end

	elseif EntityType == Entities.PU_BattleSerf then
			XGUIEng.ShowWidget("Commands_Leader", 1)
			XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionLeader, 0)

	elseif Logic.IsLeader( EntityId ) == 1 then
		XGUIEng.ShowWidget("LeaderUpgrade", 1)
		if Logic.IsEntityInCategory(EntityId,EntityCategories.CavalryHeavy) == 1
		or Logic.IsEntityInCategory(EntityId,EntityCategories.CavalryLight) == 1 then
			XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionLeader, 1)
		end
		if EntityType == Entities.PV_Ram then
			if not RamSelectionSoundActive and not RamMoveSoundActive and not RamAttackSoundActive then
				RamSelectionSoundActive = true
				Sound.PlayFeedbackSound(Sounds["Stronghold_" .. Siege.RamSounds.Select], 152)
				StartCountdown(3, function() RamSelectionSoundActive = nil end, false)
			end
		end
	end

	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
end
gvGameSpeed = 1
function GameCallback_GameSpeedChanged( _Speed )
	local Speed = _Speed * 1000
    if Speed == 0 then
		gvGameSpeed = 0
		if not CNetwork then
			local PauseScreenType = math.random(5)
			XGUIEng.ShowWidget("PauseScreen"..PauseScreenType,1)
		end

    else

		gvGameSpeed = _Speed
		for i = 1,5 do
			XGUIEng.ShowWidget("PauseScreen"..i,0)
		end
    end
end

function GameCallback_OnTechnologyResearched(_PlayerID, _TechnologyType)

	--Update Techs for Tech Race game mode in MP
	if XNetwork ~= nil
	and XNetwork.GameInformation_GetMPFreeGameMode() == 2 then
		VC_OnTechnologyResearched( _PlayerID, _TechnologyType )
	end

	--calculate score
	if Score ~= nil then
		Score.CallBackResearched( _PlayerID, _TechnologyType )
	end

	if Statistics_OnTechnologyResearched then
		Statistics_OnTechnologyResearched(_PlayerID, _TechologyType)
	end

	if _TechnologyType == Technologies.T_HeavyThunder then
		gvLightning.AdditionalStrikes = gvLightning.AdditionalStrikes + 3

	elseif _TechnologyType == Technologies.T_TotalDestruction then
		gvLightning.DamageAmplifier = gvLightning.DamageAmplifier + 0.3

	end

	local PlayerID = GUI.GetPlayerID()
	if PlayerID ~= _PlayerID then
		return
	end

	local BuildingID = GUI.GetSelectedEntity()
	if BuildingID ~= 0 then
		local TechnologyAtBuilding = Logic.GetTechnologyResearchedAtBuilding(BuildingID)
		if  TechnologyAtBuilding == 0 then
			XGUIEng.ShowWidget(gvGUI_WidgetID.ResearchInProgress,0)
		end
	end

	if not gvMercTechsCheated then

		if _TechnologyType == Technologies.T_BarbarianCulture then
			Logic.SetTechnologyState(_PlayerID,Technologies.T_KnightsCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BearmanCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BanditCulture,0)

		elseif _TechnologyType == Technologies.T_KnightsCulture then
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BarbarianCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BearmanCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BanditCulture,0)

		elseif _TechnologyType == Technologies.T_BearmanCulture then
			Logic.SetTechnologyState(_PlayerID,Technologies.T_KnightsCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BarbarianCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BanditCulture,0)

		elseif _TechnologyType == Technologies.T_BanditCulture then
			Logic.SetTechnologyState(_PlayerID,Technologies.T_KnightsCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BearmanCulture,0)
			Logic.SetTechnologyState(_PlayerID,Technologies.T_BarbarianCulture,0)
		end

	end

	--Do not play sound on begin of the map
	local GameTimeMS = Logic.GetTimeMs()
	if GameTimeMS == 0 then
		return
	end

	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
end

function GameCallback_RefinedResource(_entityID, _type, _amount)

    local playerID = Logic.EntityGetPlayer(_entityID)
	local etype = Logic.GetEntityType(Logic.GetSettlersWorkBuilding(_entityID))

    if _type == ResourceType.Gold then

        if Logic.GetTechnologyState(playerID, Technologies.T_BookKeeping) == 4 then
            _amount = _amount + 1
        end

    end

	if gvCoal.Usage[playerID][etype] then
		if Logic.GetPlayersGlobalResource(playerID, ResourceType.Knowledge) >= gvCoal.ResourceNeeded[etype] then
			Logic.SubFromPlayersGlobalResource(playerID, ResourceType.Knowledge, gvCoal.ResourceNeeded[etype])
			_amount = _amount + gvCoal.ResourceBonus[etype]
		end
	end

    if GameCallback_RefinedResourceOrig then
        return GameCallback_RefinedResourceOrig(_entityID, _type, _amount)

    else
        return _entityID, _type, _amount

    end
end

function GameCallback_GainedResourcesFromMine(_extractor, _e, _type, _amount)

	local playerID = Logic.EntityGetPlayer(_extractor)
	local work = Logic.GetSettlersWorkBuilding(_extractor)

	if Logic.GetTechnologyState(playerID, Technologies.T_PickAxe) == 4 then
		if _e ~= nil then

			if _type == ResourceType.ClayRaw then
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

		end

	else

		if gvChallengeFlag then

			if _type == ResourceType.ClayRaw then
				_amount = (gained_resource_clay[Logic.GetEntityType(work)]-1 or _amount)
			elseif 	_type == ResourceType.IronRaw then
				_amount = (gained_resource_iron[Logic.GetEntityType(work)]-1 or _amount)
			elseif 	_type == ResourceType.StoneRaw then
				_amount = (gained_resource_stone[Logic.GetEntityType(work)]-1 or _amount)
			elseif 	_type == ResourceType.SulfurRaw then
				_amount = (gained_resource_sulfur[Logic.GetEntityType(work)]-1 or _amount)
			elseif 	_type == ResourceType.SilverRaw then
				_amount = (gained_resource_silver[Logic.GetEntityType(work)]-1 or _amount)
			elseif 	_type == ResourceType.GoldRaw then
				_amount = ((gained_resource_gold[Logic.GetEntityType(work)]/2.5)+2 or _amount)
			end

		end

    end
	if GameCallback_GainedResourcesFromMineOrig then
		return GameCallback_GainedResourcesFromMineOrig(_extractor, _e, _type, _amount)
    end
	return _extractor, _e, _type, _amount
end
function GameCallback_ConstructBuilding(_csite, _nserfs, _amount)

	local playerID = Logic.EntityGetPlayer(_csite)
	if Logic.GetTechnologyState(playerID, Technologies.T_LightBricks) == 4 then
		_amount = (_amount *1.2) or _amount
	end

	if GameCallback_ConstructBuildingOrig then
        return GameCallback_ConstructBuildingOrig(_csite, _nserfs, _amount)
    else
        return _amount
    end
end
function GameCallback_PlaceBuildingAdditionalCheck(_eType, _x, _y, _rotation, _isBuildOn)

    local allowed = true

	while _rotation < 0 do
		_rotation = _rotation + 360
	end

    if GameCallback_PlaceBuildingAdditionalCheckOrig then

        allowed = GameCallback_PlaceBuildingAdditionalCheckOrig(_eType, _x, _y, _rotation, _isBuildOn)

        if allowed ~= false then
            allowed = true
        end

    end

	local player = GUI.GetPlayerID()
	local IsExplored = (Logic.IsMapPositionExplored(player, _x, _y) == 1)

	if _eType == Entities.PB_CoalMine1 then

		return gvCoal.Mine.PlacementCheck(_x, _y, _rotation) and IsExplored

	elseif _eType == Entities.PB_Archers_Tower and not gvXmas2021ExpFlag and not gvXmasEventFlag then

		local checkorientation = true

		if _rotation == 0 or _rotation == 90 or _rotation == 180 or _rotation == 270 or _rotation == 360 then
			checkorientation = true
		else
			checkorientation = false
		end

		return allowed and checkorientation and (gvArchers_Tower.AmountOfTowers[player] < gvArchers_Tower.TowerLimit) and IsExplored

	elseif _eType == Entities.PB_ForestersHut1 then

		local checkorientation = true

		if _rotation == 0 or _rotation == 360 then
			checkorientation = true
		else
			checkorientation = false
		end

		return allowed and checkorientation and IsExplored and (Logic.GetPlayerAttractionLimit(player) > 0)

	elseif _eType == Entities.PB_WoodcuttersHut1 then

		local checkorientation = true

		if _rotation == 0 or _rotation == 360 then
			checkorientation = true
		else
			checkorientation = false
		end

		return allowed and checkorientation and IsExplored and (Logic.GetPlayerAttractionLimit(player) > 0)

	elseif _eType == Entities.PB_Castle1 then

		local checkpos = true

		-- castles are not allowed to be placed near each other (also not near existing hq's)
		for _,v in pairs(gvCastle.PositionTable) do

			if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvCastle.BlockRange then
				checkpos = false
			end

		end

		return allowed and checkpos and (gvCastle.AmountOfCastles[player] < gvCastle.CastleLimit) and IsExplored

	elseif _eType == Entities.PB_Tower1 and not gvXmas2021ExpFlag and not gvXmasEventFlag then

		local checkpos = true

		-- towers are not allowed to be placed near each other
		for _,v in pairs(gvTower.PositionTable) do

			if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvTower.BlockRange then
				checkpos = false
			end

		end

		return allowed and checkpos and (gvTower.AmountOfTowers[player] < gvTower.TowerLimit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue1 then

		return allowed and (gvVStatue1.Amount[player] < gvVStatue1.Limit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue2 then

		return allowed and (gvVStatue2.Amount[player] < gvVStatue2.Limit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue4 then

		local checkpos = true

		for _,v in pairs(gvVStatue4.PositionTable) do

			if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvVStatue4.BlockRange then
				checkpos = false
			end

		end

		return allowed and checkpos and (gvVStatue4.Amount[player] < gvVStatue4.Limit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue5 then

		return allowed and (gvVStatue5.Amount[player] < gvVStatue5.Limit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue6 then

		local checkpos = true

		for _,v in pairs(gvVStatue6.PositionTable) do

			if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvVStatue6.BlockRange then
				checkpos = false
			end

		end

		return allowed and checkpos and (gvVStatue6.Amount[player] < gvVStatue6.Limit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue7 then

		return allowed and (gvVStatue7.Amount[player] < gvVStatue7.Limit) and gvVStatue7.IsPlacementAllowed(player, _x, _y) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue8 then

		local checkpos = true

		for _,v in pairs(gvVStatue8.PositionTable) do

			if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvVStatue8.BlockRange then
				checkpos = false
			end

		end

		return allowed and checkpos and (gvVStatue8.Amount[player] < gvVStatue8.Limit) and IsExplored

	elseif _eType == Entities.PB_VictoryStatue9 then

		return allowed and (gvVStatue9.AmountConstructed[player] < gvVStatue9.Limit) and IsExplored

	else

		if not gvXmasEventFlag and not gvXmas2021ExpFlag then

			return allowed and IsExplored

		-- on winter maps with xmas-tree mechanic no building placements allowed near trees
		elseif gvXmasEventFlag and gvPresent then

			local checktree1
			local checktree2

			if math.sqrt((_x - gvPresent.XmasTreePos[1].X)^2+(_y - gvPresent.XmasTreePos[1].Y)^2) >= gvPresent.XmasTreeBuildBlockRange then
				checktree1 = true
			else
				checktree1 = false
			end
			if math.sqrt((_x - gvPresent.XmasTreePos[2].X)^2+(_y - gvPresent.XmasTreePos[2].Y)^2) >= gvPresent.XmasTreeBuildBlockRange then
				checktree2 = true
			else
				checktree2 = false
			end

			if _eType == Entities.PB_Tower1 then

				local checktowerpos = true

				-- towers are not allowed to be placed near other towers (on winter maps with xmas-tree mechanic also not near the trees)
				for _,v in pairs(gvTower.PositionTable) do

					if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvTower.BlockRange then
						checktowerpos = false
					end

				end

				return allowed and checktowerpos and (checktree1 == checktree2) and (gvTower.AmountOfTowers[player] < gvTower.TowerLimit)  and IsExplored

			elseif _eType == Entities.PB_Archers_Tower then

				return allowed and (gvArchers_Tower.AmountOfTowers[player] < gvArchers_Tower.TowerLimit) and (checktree1 == checktree2) and IsExplored

			else
				return allowed and (checktree1 == checktree2) and IsExplored
			end

		-- on WT21 Map only Dario Statues allowed near the center
		elseif gvXmas2021ExpFlag and WT21 then

			local checkpos = true
			local pos = GetPosition("center")

			if _eType ~= Entities.PB_Beautification01 and _eType ~= Entities.PB_Tower1 then

				if math.sqrt((_x - pos.X)^2+(_y - pos.Y)^2) <= WT21.CenterBlockRange then

					checkpos = false

				end

				if _eType == Entities.PB_Archers_Tower then

					local checktower = (gvArchers_Tower.AmountOfTowers[player] < gvArchers_Tower.TowerLimit)

					return allowed and checktower and checkpos and IsExplored

				elseif _eType == Entities.PB_Tower1 then

					local checktowerpos = true

					-- towers are not allowed to be placed near other towers (on WT21 Map also not near the center of the map)
					for _,v in pairs(gvTower.PositionTable) do

						if math.sqrt((_x - v.X)^2+(_y - v.Y)^2) <= gvTower.BlockRange then

							checktowerpos = false

						end

						if math.sqrt((_x - pos.X)^2+(_y - pos.Y)^2) <= WT21.CenterBlockRange then
							checkpos = false
						end
					end
					return allowed and checkpos and checktowerpos and (gvTower.AmountOfTowers[player] < gvTower.TowerLimit)  and IsExplored
				else
					return allowed and checkpos and IsExplored
				end
			end
		end
	end
end

function GameCallback_ResearchProgress(_player, _research_building, _technology, _entity, _research_amount, _current_progress, _max)

	if _technology == Technologies.T_CityGuard then
		_research_amount = math.floor((_max + 0.5)/120) or _research_amount
	end

	if Logic.GetTechnologyState(_player, Technologies.T_TownGuard) == 4 then
		_research_amount = math.ceil(_research_amount *1.2) or _research_amount
	end

	if GameCallback_ResearchProgressOrig then
		return GameCallback_ResearchProgressOrig(_player, _research_building, _technology, _entity, _research_amount, _current_progress, _max)
	else
		return  _research_amount
	end
end

function GameCallback_PaydayPayed(_player,_amount)

	if _amount ~= nil then

		if CUtil.Payday_GetFrequency(_player) == 1200 and Logic.GetTechnologyState(_player,Technologies.T_Debenture) == 4 then
			local frequency = math.floor((CUtil.Payday_GetFrequency(_player))*9/10)
			CUtil.Payday_SetFrequency(_player, frequency)
		end

		-- Zahltag pro Münzstätte um 1.5% erhöht, max 15%
		local factor = 1
		local workers

		for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do
			if Logic.IsConstructionComplete(eID) == 1 then
				workers = {Logic.GetAttachedWorkersToBuilding(eID)}

				if workers[1] >= BS.MintValues.WorkersNeeded then
					factor = math.min(factor + BS.MintValues.BonusPerMint, BS.MintValues.MaxTotalFactor)
				end

			end
		end

		_amount = math.floor(_amount*factor)

		--KI bekommt 5fachen Zahltag
		if CNetwork and XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(_player) == 0 then

			if _amount > 0 then
				_amount = _amount * 5
			else
				--KI kann keinen negativen Zahltag haben
				_amount = 0
			end

		else
		-- Sudden Death auf der Weihnachtsmap

			if gvXmasEventFlag then
				if gvPresent.SDPaydayFactor then
					_amount = math.floor(_amount * gvPresent.SDPaydayFactor[_player])
				end
			end

		end

		return _amount

	else
		LuaDebugger.Break()
		return 0
	end
end
--------------------------------------------------------------------------------
-- Function that is called when an entity ID changes (upgrade, ...)
--------------------------------------------------------------------------------
function GameCallback_GUI_EntityIDChanged(_OldID, _NewID)

	local player = Logic.EntityGetPlayer(_OldID)
	--[[ needed when troop on top of the archers tower is upgraded
	currently deprecated, because troops do not upgrade anymore when research is done ]]
	for k,v in pairs(gvArchers_Tower.SlotData) do

		local slot = table_findvalue(gvArchers_Tower.SlotData[k],_OldID)

		if slot ~= 0 then
			gvArchers_Tower.SlotData[k][slot] = _NewID
			gvArchers_Tower.CurrentlyUsedSlots[k] = gvArchers_Tower.CurrentlyUsedSlots[k] + 1
			local TroopIDs = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[k][slot])}
			table.remove(TroopIDs,1)
			table.insert(TroopIDs,gvArchers_Tower.SlotData[k][slot])

			for i = 1,table.getn(TroopIDs) do
				CEntity.SetDamage(TroopIDs[i], Logic.GetEntityDamage(TroopIDs[i])*gvArchers_Tower.DamageFactor)
				CEntity.SetArmor(TroopIDs[i], Logic.GetEntityArmor(TroopIDs[i])*gvArchers_Tower.ArmorFactor)
				CEntity.SetAttackRange(TroopIDs[i],GetEntityTypeMaxAttackRange((TroopIDs[i]), player)*gvArchers_Tower.MaxRangeFactor)
			end

		end
	end
	--[[ update AI data when troops upgrade
	note: troop upgrade timing order: GameCallback_GUI_EntityIDChanged -> DestroyedTrigger -> CreatedTrigger]]
	if ArmyTable and ArmyTable[player] then
		for k, v in pairs(ArmyTable[player]) do
			local tpos = table_findvalue(v.IDs, _OldID)
			if tpos ~= 0 then
				Trigger.UnrequestTrigger(v[_OldID].TriggerID)
				v.IDs[tpos] = _NewID
				v[_NewID] = v[_OldID]
				v[_OldID] = nil
				v[_NewID].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {player, _NewID, k})
				local enemies = BS.GetAllEnemyPlayerIDs(player)
				for i = 1, table.getn(enemies) do
					if AIchunks[enemies[i]] then
						ChunkWrapper.RemoveEntity(AIchunks[enemies[i]], _OldID)
						ChunkWrapper.AddEntity(AIchunks[enemies[i]], _NewID)
					end
				end
				break
			end
		end
	end
	if MapEditor_Armies and MapEditor_Armies[player] then
		local tpos = table_findvalue(MapEditor_Armies[player].offensiveArmies.IDs, _OldID)
		if tpos ~= 0 then
			Trigger.UnrequestTrigger(MapEditor_Armies[player].offensiveArmies[_OldID].TriggerID)
			MapEditor_Armies[player].offensiveArmies.IDs[tpos] = _NewID
			MapEditor_Armies[player].offensiveArmies[_NewID] = MapEditor_Armies[player].offensiveArmies[_OldID]
			MapEditor_Armies[player].offensiveArmies[_OldID] = nil
			MapEditor_Armies[player].offensiveArmies[_NewID].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {player, _NewID, "offensiveArmies"})
			local enemies = BS.GetAllEnemyPlayerIDs(player)
			for k = 1, table.getn(enemies) do
				if AIchunks[enemies[k]] then
					ChunkWrapper.RemoveEntity(AIchunks[enemies[k]], _OldID)
					ChunkWrapper.AddEntity(AIchunks[enemies[k]], _NewID)
				end
			end
		else
			tpos = table_findvalue(MapEditor_Armies[player].defensiveArmies.IDs, _OldID)
			if tpos ~= 0 then
				Trigger.UnrequestTrigger(MapEditor_Armies[player].defensiveArmies[_OldID].TriggerID)
				MapEditor_Armies[player].defensiveArmies.IDs[tpos] = _NewID
				MapEditor_Armies[player].defensiveArmies[_NewID] = MapEditor_Armies[player].defensiveArmies[_OldID]
				MapEditor_Armies[player].defensiveArmies[_OldID] = nil
				MapEditor_Armies[player].defensiveArmies[_NewID].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {player, _NewID, "defensiveArmies"})
				local enemies = BS.GetAllEnemyPlayerIDs(player)
				for k = 1, table.getn(enemies) do
					if AIchunks[enemies[k]] then
						ChunkWrapper.RemoveEntity(AIchunks[enemies[k]], _OldID)
						ChunkWrapper.AddEntity(AIchunks[enemies[k]], _NewID)
					end
				end
			end
		end
	end
	GameCallback_GUI_EntityIDChangedOrig(_OldID, _NewID)
end

function GameCallback_ResourceTaken(_id, _type, _amount)

	local etype = Logic.GetEntityType(_id)

	if etype == Entities.PU_CoalMaker then
		local work = Logic.GetSettlersWorkBuilding(_id)
		local tab = gvCoal.Coalmaker.WoodBurned
		tab[work] = tab[work] + _amount
	end

	if GameCallback_ResourceTakenOrig then
		return GameCallback_ResourceTakenOrig(_id, _type, _amount)
	else
		return _id, _type, _amount
	end
end

GameCallback_UnknownTask = function(_id)

--[[0: weiter sofort
	1: weiter nächster Tick
	2: bleiben
]]
	local etype = Logic.GetEntityType(_id)
	local player = Logic.EntityGetPlayer(_id)
	local work = Logic.GetSettlersWorkBuilding(_id)

	if etype == Entities.PU_CoalMaker then
		local tab = gvCoal.Coalmaker
		if GetEntityCurrentTaskIndex(_id) == 15 then
			local posX, posY = Logic.GetEntityPosition(_id)
			local eff1 = Logic.CreateEffect(GGL_Effects.FXFire, posX, posY - 150)
			local eff2 = Logic.CreateEffect(GGL_Effects.FXFireLo, posX, posY - 150)
			local eff3 = Logic.CreateEffect(GGL_Effects.FXFireMedium, posX, posY - 150)
			Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Coalmaker_RemoveFireEffect",1,{},{work, eff1, eff2, eff3})
			return 1
		end
		for i = 1, table.getn(tab.Cycle) do
			if GetEntityCurrentTaskIndex(_id) == tab.Cycle[i].TaskIndex then
				Logic.AddToPlayersGlobalResource(player, ResourceType.Knowledge, tab.Cycle[i].ResourceAmount)
				tab.CoalEarned[work] = tab.CoalEarned[work] + tab.Cycle[i].ResourceAmount
				return 0
			end
		end
	elseif etype == Entities.PU_Miner then
		local tab = gvCoal.Mine
		local task = Logic.GetCurrentTaskList(_id)
		local factor = (Logic.GetTechnologyState(player, Technologies.T_PickAxe) == 4 and tab.PickaxeFactor) or 1
		local res = tab.ResourceByLevel[Logic.GetUpgradeLevelForBuilding(work) + 1]
		if task == "TL_MINER_COALMINE_WORK1" then
			for i = 1, table.getn(tab.Cycle.Outside) do
				if GetEntityCurrentTaskIndex(_id) == tab.Cycle.Outside[i].TaskIndex then
					Logic.AddToPlayersGlobalResource(player, ResourceType.Knowledge, round(res * factor))
					tab.AmountMined[work] = tab.AmountMined[work] + round(res * factor)
					return 0
				end
			end
		elseif task == "TL_MINER_COALMINE_WORK_INSIDE" then
			for i = 1, table.getn(tab.Cycle.Inside) do
				if GetEntityCurrentTaskIndex(_id) == tab.Cycle.Inside[i].TaskIndex then
					Logic.AddToPlayersGlobalResource(player, ResourceType.Knowledge, round(res * factor))
					tab.AmountMined[work] = tab.AmountMined[work] + round(res * factor)
					return 0
				end
			end
		end
	elseif etype == Entities.PV_Cannon5 then
		for k, v in pairs(Cannon5.TaskIndexes) do
			if GetEntityCurrentTaskIndex(_id) == k then
				local posX, posY = Logic.GetEntityPosition(_id)
				local target = GetEntityCurrentTarget(_id)
				if not target or target == 0 then
					if (AITable and AITable[player]) or (MapEditor_Armies and MapEditor_Armies[player]) then
						target = GetEntityTargetByAIData(_id)
						if not target then
							return 0
						end
					else
						return 0
					end
				end
				local posX2, posY2 = Logic.GetEntityPosition(target)
				local damage = CalculateTotalDamage(_id, target)
				local offX, offY = RotateOffset(v.Offset.X, v.Offset.Y, Logic.GetEntityOrientation(_id))
				local effID = v.Effect
				-- is entity on bridge attacking entity on "normal" ground?
				if IsPositionAffectedByBridgeHeight(posX, posY) then
					local btype = ProjectileHeightCheck.GetBridgeEntityTypeEntityStandsOn(_id)
					if btype then
						effID = ProjectileHeightCheck.GetGatlingProjectileEffectByEffectAndBridgeEntity(effID, btype, "At")
					end
				-- is entity on "normal" ground attacking entity standing on bridge?
				elseif IsPositionAffectedByBridgeHeight(posX2, posY2) and Logic.IsBuilding(target) == 0 then
					local btype = ProjectileHeightCheck.GetBridgeEntityTypeEntityStandsOn(target)
					if btype then
						effID = ProjectileHeightCheck.GetGatlingProjectileEffectByEffectAndBridgeEntity(effID, btype, "To")
					end
				end
				CUtil.CreateProjectile(GGL_Effects[effID], posX + offX, posY + offY, posX2, posY2, damage, GetEntityTypeDamageRange(etype), target, _id, player)
				--Logic.SpawnParticleEffect(_id, v.EffectIndex, GGL_Effects.FXCannonFireShort)
				--CEntity.DealDamageInArea(_id, posX2, posY2, GetEntityTypeDamageRange(etype), damage)
				return 0
			end
		end
		return 0
	elseif etype == Entities.PV_Ram then
		if GUI.GetPlayerID() == player then
			local task = Logic.GetCurrentTaskList(_id)
			if task == "TL_RAM_DRIVE" then
				if not RamMoveSoundActive and not RamAttackSoundActive and not RamSelectionSoundActive then
					Sound.PlayFeedbackSound(Sounds["Stronghold_" .. Siege.RamSounds.Move], 152)
					RamMoveSoundActive = true
					StartCountdown(5, function() RamMoveSoundActive = false end, false)
				end
			elseif task == "TL_BATTLE_RAM" then
				if not RamMoveSoundActive and not RamAttackSoundActive and not RamSelectionSoundActive then
					Sound.PlayFeedbackSound(Sounds["Stronghold_" .. Siege.RamSounds.Attack[1+XGUIEng.GetRandom(5)]], 152)
					RamMoveSoundActive = true
					StartCountdown(10, function() RamMoveSoundActive = false end, false)
				end
			end
		end
		return 0
	else
		local task = Logic.GetCurrentTaskList(_id)
		if ProjectileHeightCheck.TaskLists[task] then
			local target = GetEntityCurrentTarget(_id)
			local posX, posY = Logic.GetEntityPosition(_id)
			local posX2, posY2 = Logic.GetEntityPosition(target)
			-- is entity on bridge attacking entity on "normal" ground?
			if IsPositionAffectedByBridgeHeight(posX, posY) then
				local btype = ProjectileHeightCheck.GetBridgeEntityTypeEntityStandsOn(_id)
				if btype then
					local damage = CalculateTotalDamage(_id, target)
					local effID = ProjectileHeightCheck.GetProjectileEffectByEntityTypeAndBridgeEntity(etype, btype, "At")
					CUtil.CreateProjectile(GGL_Effects[effID], posX, posY, posX2, posY2, damage, GetEntityTypeDamageRange(etype), target, _id, player)
					SetEntityCurrentTaskIndex(_id, GetEntityCurrentTaskIndex(_id)+2)
					return 2
				else
					return 0
				end
			-- is entity on "normal" ground attacking entity standing on bridge?
			elseif IsPositionAffectedByBridgeHeight(posX2, posY2) and Logic.IsBuilding(target) == 0 then
				local btype = ProjectileHeightCheck.GetBridgeEntityTypeEntityStandsOn(target)
				if btype then
					local damage = CalculateTotalDamage(_id, target)
					local effID = ProjectileHeightCheck.GetProjectileEffectByEntityTypeAndBridgeEntity(etype, btype, "To")
					CUtil.CreateProjectile(GGL_Effects[effID], posX, posY, posX2, posY2, damage, GetEntityTypeDamageRange(etype), target, _id, player)
					SetEntityCurrentTaskIndex(_id, GetEntityCurrentTaskIndex(_id)+2)
					return 2
				else
					return 0
				end
			-- TODO: check if entity on bridge is attacking another entity on bridge is missing. Rare case, worth the effort?
			else
				return 0
			end
		else
			return 0
		end
	end
end
-- adjusted, so feedback message is only received by player clicking the button, not all players
function GameCallback_OnPointToResource(_foundPos, _unused)

	if gvScoutUsedPointToResources then
		if _foundPos == 0 then
			GUI.AddNote( XGUIEng.GetStringTableText("InGameMessages/shortmessage_noresourceclose") )
		else
			GUI.AddNote( XGUIEng.GetStringTableText("InGameMessages/shortmessage_pointtoresource") )
		end
		gvScoutUsedPointToResources = nil
	end
end
-- weather energy infinite resources fix
GameCallback_ResourceChanged = function(_player, _type, _amount)
	if _player > 0 and _player < 17 and _amount > 0 then
		if _type == ResourceType.WeatherEnergy then
			if Logic.GetPlayersGlobalResource(_player, _type) > Logic.GetEnergyRequiredForWeatherChange() then
				Logic.SubFromPlayersGlobalResource(_player, _type, Logic.GetPlayersGlobalResource(_player, _type) - Logic.GetEnergyRequiredForWeatherChange())
			end
		elseif _type == ResourceType.Faith then
			if Logic.GetPlayersGlobalResource(_player, _type) > Logic.GetMaximumFaith() then
				Logic.SubFromPlayersGlobalResource(_player, _type, Logic.GetPlayersGlobalResource(_player, _type) - Logic.GetMaximumFaith())
			end
			-- helias sacrilege resource redirect
			local enemies = BS.GetAllEnemyPlayerIDs(_player)
			for i = 1,table.getn(enemies) do
				if gvHero6.Sacrilege.Active[enemies[i]] then
					if _amount > 0 and not gvHero6.Sacrilege.Active[_player] then
						Logic.AddToPlayersGlobalResource(enemies[i], _type, _amount)
						Logic.SubFromPlayersGlobalResource(_player, _type, _amount)
					end
				end
			end
		elseif _type == ResourceType.Knowledge then
			if ExtendedStatistics then
				ExtendedStatistics.Players[_player].Coal = ExtendedStatistics.Players[_player].Coal + _amount
			end
		end
	end
end