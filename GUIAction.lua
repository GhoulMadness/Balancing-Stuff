if gvXmasEventFlag == 1 then
	GUIAction_BuyMilitaryUnitOrig = GUIAction_BuyMilitaryUnit
	function GUIAction_BuyMilitaryUnit(_UpgradeCategory)
		if _UpgradeCategory == UpgradeCategories.Thief then
			if Logic.GetNumberOfEntitiesOfTypeOfPlayer(GUI.GetPlayerID(),Entities.PU_Thief) >= 4 then
				Message("Ihr habt das Diebe-Limit erreicht!")
				return
			else
				GUIAction_BuyMilitaryUnitOrig(_UpgradeCategory)
			end
		else
			GUIAction_BuyMilitaryUnitOrig(_UpgradeCategory)
		end
	end
end

function GUIAction_ChangeView(_mode)
	if _mode == 0 then
		--normale Sicht anzeigen
		gvCamera.DefaultFlag = 1
		gvCamera.ZoomAngleMin = 29
		gvCamera.ZoomAngleMax = 49
		Display.SetFarClipPlaneMinAndMax(0, 0)
		Display.SetRenderSky( 0 )
		Camera.RotSetAngle( -45 )
		Camera.RotSetFlipBack( 1 )
		Camera.ScrollUpdateZMode( 0 )
		Camera.ZoomSetDistance(3000)
		Camera.ZoomSetAngle(45)
		XGUIEng.ShowWidget("MinimapButtons_NormalView",0)
		XGUIEng.ShowWidget("MinimapButtons_RPGView",0)
		XGUIEng.ShowWidget("MinimapButtons_DownView",1)
	elseif _mode == 1 then
		--Draufsicht
		gvCamera.DefaultFlag = 1
		gvCamera.ZoomAngleMin = 70
		gvCamera.ZoomAngleMax = 88
		Display.SetRenderSky( 0 )
		Camera.RotSetAngle( -45 )
		Camera.RotSetFlipBack( 1 )
		Camera.ScrollUpdateZMode( 0 )
		Camera.ZoomSetAngle(85)
		XGUIEng.ShowWidget("MinimapButtons_DownView",0)
		XGUIEng.ShowWidget("MinimapButtons_NormalView",0)
		XGUIEng.ShowWidget("MinimapButtons_RPGView",1)
	elseif _mode == 2 then
		--RPG-Sichtmodus
		gvCamera.DefaultFlag = 1
		gvCamera.ZoomAngleMin = 4
		gvCamera.ZoomAngleMax = 16
		Display.SetFarClipPlaneMinAndMax(0, 33000)
		Display.SetRenderSky( 1 )
		GameCallback_Camera_CalculateZoom( 1 )
		Camera.ScrollUpdateZMode( 1 )
		Camera.ZoomSetDistance(1800)
		Camera.RotSetAngle(-45)
		Camera.RotSetFlipBack( 0 )
		Camera.ZoomSetAngle(8)
		XGUIEng.ShowWidget("MinimapButtons_DownView",0)
		XGUIEng.ShowWidget("MinimapButtons_RPGView",0)
		XGUIEng.ShowWidget("MinimapButtons_NormalView",1)
	end
end
function GUIAction_ShowLeaderDetails()
	XGUIEng.ShowWidget("DetailsAttackRange",1)
	XGUIEng.ShowWidget("DetailsVisionRange",1)
	XGUIEng.ShowWidget("DetailsAttackSpeed",1)
	XGUIEng.ShowWidget("DetailsMoveSpeed",1)
	XGUIEng.ShowWidget("DetailsExperiencePoints",1)
	XGUIEng.ShowWidget("LeaderDetailsOn",0)
	XGUIEng.ShowWidget("LeaderDetailsOff",1)
end
function GUIAction_LeaderDetailsOff()
	XGUIEng.ShowWidget("DetailsAttackRange",0)
	XGUIEng.ShowWidget("DetailsVisionRange",0)
	XGUIEng.ShowWidget("DetailsAttackSpeed",0)
	XGUIEng.ShowWidget("DetailsMoveSpeed",0)
	XGUIEng.ShowWidget("DetailsExperiencePoints",0)
	XGUIEng.ShowWidget("LeaderDetailsOn",1)
	XGUIEng.ShowWidget("LeaderDetailsOff",0)
end
function GUIAction_ShowResourceDetails()
	XGUIEng.ShowWidget("MinimapButtons_DetailedResourceView",0)
	XGUIEng.ShowWidget("MinimapButtons_NormalResourceView",1)
	XGUIEng.ShowWidget("ResourceDetailsBG",1)
	XGUIEng.ShowWidget("DetailsGold",1)
	XGUIEng.ShowWidget("DetailsClay",1)
	XGUIEng.ShowWidget("DetailsWood",1)
	XGUIEng.ShowWidget("DetailsStone",1)
	XGUIEng.ShowWidget("DetailsIron",1)
	XGUIEng.ShowWidget("DetailsSulfur",1)
	XGUIEng.ShowWidget("DetailsSilver",1)
	XGUIEng.ShowWidget("Faith",1)
	XGUIEng.ShowWidget("WeatherEnergy",1)
end
function GUIAction_NormalResourceView()
	XGUIEng.ShowWidget("MinimapButtons_DetailedResourceView",1)
	XGUIEng.ShowWidget("MinimapButtons_NormalResourceView",0)
	XGUIEng.ShowWidget("ResourceDetailsBG",0)
	XGUIEng.ShowWidget("DetailsGold",0)
	XGUIEng.ShowWidget("DetailsClay",0)
	XGUIEng.ShowWidget("DetailsWood",0)
	XGUIEng.ShowWidget("DetailsStone",0)
	XGUIEng.ShowWidget("DetailsIron",0)
	XGUIEng.ShowWidget("DetailsSulfur",0)
	XGUIEng.ShowWidget("DetailsSilver",0)
	XGUIEng.ShowWidget("Faith",0)
	XGUIEng.ShowWidget("WeatherEnergy",0)
end
function GUIAction_ExpelAll()
	local SelectedEntityIDs = {GUI.GetSelectedEntities()}
	GUIAction_LeaderDetailsOff()
	for i = 1,table.getn(SelectedEntityIDs) do
		if Logic.IsHero(SelectedEntityIDs[i]) == 1 then
			Sound.PlayFeedbackSound( Sounds.Leader_LEADER_NO_rnd_01, 0 )
			GUI.AddNote("Massenentlassung funktioniert nicht, wenn Helden selektiert sind!")
		elseif IsMilitaryLeader(SelectedEntityIDs[i]) then
			for j = 1,Logic.LeaderGetNumberOfSoldiers(SelectedEntityIDs[i]) +1 do
				GUI.ExpelSettler(SelectedEntityIDs[i])
			end
		elseif Logic.IsSerf(SelectedEntityIDs[i]) then
			GUI.ExpelSettler(SelectedEntityIDs[i])
		end
	end
end
function GUIAction_LightningRod()
	gvLastTimeLightningRodUsed = Logic.GetTimeMs()
    GUIUpdate_LightningRod()
	Sound.PlayGUISound(Sounds.OnKlick_Select_salim, 627)
	local PlayerID = GUI.GetPlayerID()
	if CNetwork then
        CNetwork.SendCommand("Ghoul_LightningRod_Protected", PlayerID)
    else
		LightningRod_Protected(PlayerID)
	end
end
function LightningRod_Protected(_PID)
	gvLightning.RodProtected[_PID] = true
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","LightningRod_UnProtected",1,{},{_PID})
end
function LightningRod_UnProtected(_PID,_SpecialTimer)
	_SpecialTimer = _SpecialTimer or 45
	if Counter.Tick2("Unprotected".._PID, _SpecialTimer) == true then
		gvLightning.RodProtected[_PID] = false
		return true
	end
end

function GUIAction_LevyTaxes()
	if Logic.GetNumberOfAttractedWorker(GUI.GetPlayerID()) == 0 then
		return
	end
    gvLastTimeButtonPressed = Logic.GetTimeMs()
    Sound.PlayGUISound(Sounds.OnKlick_Select_dario, 627)
    if CNetwork then
        CNetwork.SendCommand("Ghoul_LevyTaxes", GUI.GetPlayerID())
    else
		BS.LevyTax(GUI.GetPlayerID())
    end
end
function BS.LevyTax(_playerID)

	local TaxBonus = 1

	for i = 1, gvVStatue3.Amount[_playerID] do
		TaxBonus = TaxBonus + (math.max(gvVStatue3.BaseValue - (i - 1) * gvVStatue3.DecreaseValue, gvVStatue3.MinimumValue))
	end

	Logic.AddToPlayersGlobalResource(_playerID, ResourceType.GoldRaw, round(Logic.GetPlayerTaxIncome(_playerID) * TaxBonus))

	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
		local motivation = Logic.GetSettlersMotivation(eID)
		CEntity.SetMotivation(eID, motivation - 0.12)
	end

end

--------------------------------------------------------------------------------
-- Force Settlers to work
--------------------------------------------------------------------------------
function GUIAction_ForceSettlersToWork()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local BuildingID = GUI.GetSelectedEntity()

	if Logic.IsAlarmModeActive(BuildingID) == true then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_StoptAlarmFirst"))
		return
	end

	if Logic.GetRemainingUpgradeTimeForBuilding(BuildingID) ~= Logic.GetTotalUpgradeTimeForBuilding(BuildingID) then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_BuildingUnderConstruction"))
		return
	end

	local BuildingType =  Logic.GetEntityType(BuildingID)
	local BuildingCategory = Logic.GetUpgradeCategoryByBuildingType(BuildingType)
	local SettlersTable = {}

	--Force Settlers
	if BuildingCategory == UpgradeCategories.Residence then
		SettlersTable = {Logic.GetAttachedResidentsToBuilding(BuildingID)}

		for i= 1, SettlersTable[1], 1 do
			GUI.ForceSettlerToWork(SettlersTable[i+1])
		end

	elseif BuildingCategory == UpgradeCategories.Farm then
		SettlersTable = {Logic.GetAttachedEaterToBuilding(BuildingID)}

		for i= 1, SettlersTable[1], 1 do
			GUI.ForceSettlerToWork(SettlersTable[i+1])
		end

	elseif BuildingCategory == UpgradeCategories.Silversmith then
		GUI.AddNote("Eure Silberschmiede weigern sich. Sie werden keine Überstunden verrichten!")
		return
	else

		GUI.ToggleOvertimeAtBuilding(BuildingID)

		if Logic.IsOvertimeActiveAtBuilding(BuildingID) ~= 1 then
			if CNetwork then
				CNetwork.SendCommand("Ghoul_ForceSettlersToWorkPenalty", GUI.GetPlayerID())
			else
				GUIAction_ForceSettlersToWorkPenalty(GUI.GetPlayerID())
			end
		end

	end

end

function GUIAction_ForceSettlersToWorkPenalty(_playerID)

	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do
		local motivation = Logic.GetSettlersMotivation(eID)
		CEntity.SetMotivation(eID, motivation - 0.08)
	end

	CUtil.AddToPlayersMotivationHardcap(_playerID, - 0.02)

end

function GUIAction_LighthouseHireTroops()
	local eID = GUI.GetSelectedEntity()
	local pID = Logic.EntityGetPlayer(eID)

	if Logic.GetPlayerAttractionUsage(pID) >= Logic.GetPlayerAttractionLimit(pID) then
		GUI.SendPopulationLimitReachedFeedbackEvent(pID)
		return
	end
	if Logic.GetPlayerAttractionUsage(pID) + gvLighthouse.villageplacesneeded >= Logic.GetPlayerAttractionLimit(pID) then
		Message("Achtung: Ihr habt nur sehr wenig Plätze in Eurer Siedlung frei! @cr Die vollen Verstärkungstruppen treffen nur ein, wenn ihr über einige weitere freie Plätze verfügt!")
	end

	if gvLighthouse.CheckForResources(pID) then
		GUI.DeselectEntity(eID)
		GUI.SelectEntity(eID)
		if CNetwork then
			CNetwork.SendCommand("Ghoul_Lighthouse_SpawnJob", pID,eID)
		else
			gvLighthouse.PrepareSpawn(pID,eID)
		end
	else
		Sound.PlayFeedbackSound(Sounds.VoicesMentor_INFO_NotEnough,110)
	end
end
function GUIAction_MercenaryTower(_ucat)

	local MercID = GUI.GetSelectedEntity()

	if Logic.GetRemainingUpgradeTimeForBuilding(MercID ) ~= Logic.GetTotalUpgradeTimeForBuilding (MercID) then
		return
	end

	local PlayerID = GUI.GetPlayerID()

	-- Maximum number of settlers attracted?
	if Logic.GetPlayerAttractionUsage( PlayerID ) >= Logic.GetPlayerAttractionLimit( PlayerID ) then
		GUI.SendPopulationLimitReachedFeedbackEvent( PlayerID )
		return
	end

	--currently researching
	if Logic.GetTechnologyResearchedAtBuilding(MercID) ~= 0 then
		return
	end
	Logic.FillSoldierCostsTable( PlayerID, _ucat, InterfaceGlobals.CostTable )

	if InterfaceTool_HasPlayerEnoughResources_Feedback( InterfaceGlobals.CostTable ) == 1 then
		if _ucat ~= UpgradeCategories.LeaderElite then
			-- Yes
			GUI.BuyLeader(MercID, _ucat)
			gvMercenaryTower.LastTimeUsed = Logic.GetTime()
			GUI.DeselectEntity(MercID)
			GUI.SelectEntity(MercID)
		else

			if (Logic.GetPlayersGlobalResource(PlayerID,ResourceType.SilverRaw) + Logic.GetPlayersGlobalResource(PlayerID,ResourceType.Silver)) >= 80 then
				-- Yes
				GUI.BuyLeader(MercID, _ucat)
				gvMercenaryTower.LastTimeUsed = Logic.GetTime()
				GUI.DeselectEntity(MercID)
				GUI.SelectEntity(MercID)
			end
		end
	end
end
function GUIAction_ChangeToSpecialWeather(_weathertype,_EntityID)

	if Logic.IsWeatherChangeActive() == true then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_WeatherIsCurrentlyChanging"))
		return
	end
	if Logic.GetEntityType(_EntityID) ~= Entities.PB_WeatherTower1 then
		return
	end

	local PlayerID = GUI.GetPlayerID()
	local CurrentWeatherEnergy = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.WeatherEnergy )
	local NeededWeatherEnergy = Logic.GetEnergyRequiredForWeatherChange()

	if CurrentWeatherEnergy >= NeededWeatherEnergy then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_WeathermashineActivated"))
		if CNetwork then
			CNetwork.SendCommand("Ghoul_ChangeWeatherToThunderstorm", PlayerID, _EntityID)
		else
			GUIAction_ChangeToThunderstorm(PlayerID, _EntityID)
		end

	else
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_WeathermashineNotReady"))
	end
end
function GUIAction_ChangeToThunderstorm(_playerID, _EntityID)

	if Logic.GetEntityType(_EntityID) ~= Entities.PB_WeatherTower1 then
		return
	end

	Logic.AddWeatherElement(2,120,0,11,5,15)
	Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetEnergyRequiredForWeatherChange()))

	--in case the player still has energy left, bring him down to zero!
	if Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy ) > Logic.GetEnergyRequiredForWeatherChange() then
		Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy )))
	end

	if EMS then
		if EMS.RF.WLT.Job == nil then
			EMS.RF.WLT.Job = StartSimpleJob("EMS_RF_WLT_Counter");
		end
		EMS.RF.WLT.LockWeatherChange()
	end

	GUI.DeselectEntity(_EntityID)
	GUI.SelectEntity(_EntityID)

end
-----------------------------------------------------------------------------------------------------------------------------
function GUIAction_Hero6Sacrilege()
	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(),Entities.PU_Hero6,1)})[2]
	local player = Logic.EntityGetPlayer(heroID)
	local starttime = Logic.GetTime()
	gvHero6.LastTimeUsed.Sacrilege = starttime
	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero6Sacrilege",player,heroID)
	else
		if not gvHero6.TriggerIDs.Sacrilege[player] then
			gvHero6.TriggerIDs.Sacrilege[player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Hero6_Sacrilege_Trigger", 1, nil, {heroID,player,starttime})
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------
function GUIAction_Hero9CallWolfs()
	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(), Entities.CU_Barbarian_Hero,1)})[2]
	if not Logic.IsEntityAlive(heroID) then
		return
	end
	local player = Logic.EntityGetPlayer(heroID)
	GUI.SettlerSummon(heroID)
	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero9CallAdditionalWolfs", player, heroID)
	else
		gvHero9.SpawnAdditionalWolfs(player, heroID)
	end
end
function GUIAction_Hero9Plunder()
	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(), Entities.CU_Barbarian_Hero,1)})[2]
	if not Logic.IsEntityAlive(heroID) then
		return
	end
	local player = Logic.EntityGetPlayer(heroID)
	local starttime = Logic.GetTime()
	gvHero9.LastTimeUsed.Plunder = starttime
	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero9Plunder", player, heroID)
	else
		GUIAction_Hero9PlunderAction(heroID, player, starttime)
	end
end
function GUIAction_Hero9PlunderAction(_heroID, _playerID, _starttime)
	gvHero9.AbilityProperties.Plunder.Plundered[_heroID] = gvHero9.AbilityProperties.Plunder.Plundered[_heroID] or {}
	if not gvHero9.TriggerIDs.Plunder[_playerID] then
		gvHero9.TriggerIDs.Plunder[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero9_Plunder_Job", 1, nil, {_heroID, _starttime})
	end
	if not gvHero9.TriggerIDs.DiedCheck[_playerID] then
		gvHero9.TriggerIDs.DiedCheck[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero9_DiedCheck_Job", 1, nil, {_heroID})
	end
	if not gvHero9.TriggerIDs.NearOwnBuildingCheck[_playerID] then
		gvHero9.TriggerIDs.NearOwnBuildingCheck[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Hero9_NearOwnBuildingCheck_Job", 1, nil, {_heroID})
	end
end
-----------------------------------------------------------------------------------------------------------------------------
function GUIAction_Hero13StoneArmor()

	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(), Entities.PU_Hero13,1)})[2]
	local player = Logic.EntityGetPlayer(heroID)
	local starttime = Logic.GetTimeMs()
	gvHero13.LastTimeUsed.StoneArmor = starttime/1000

	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero13StoneArmor", player, heroID)
	else
		if not gvHero13.TriggerIDs.StoneArmor.DamageStoring[player] then
			gvHero13.TriggerIDs.StoneArmor.DamageStoring[player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_StoneArmor_StoreDamage", 1, nil, {heroID,starttime})
		end
		if not gvHero13.TriggerIDs.StoneArmor.DamageApply[player] then
			gvHero13.TriggerIDs.StoneArmor.DamageApply[player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_StoneArmor_ApplyDamage", 1, nil, {heroID,starttime})
		end
	end

end

function GUIAction_Hero13RegenAura()

	GUI.SettlerAffectUnitsInArea(GUI.GetSelectedEntity())

end

function GUIAction_Hero13DivineJudgment()

	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(),Entities.PU_Hero13,1)})[2]

	if heroID ~= nil then

		local player = Logic.EntityGetPlayer(heroID)
		local basedmg = Logic.GetEntityDamage(heroID)
		local starttime = Logic.GetTimeMs()
		local posX,posY = Logic.GetEntityPosition(heroID)
		gvHero13.LastTimeUsed.DivineJudgment = starttime/1000

		if CNetwork then
			CNetwork.SendCommand("Ghoul_Hero13DivineJudgment",GUI.GetPlayerID(),heroID)
		else

			Logic.CreateEffect(GGL_Effects.FXKerberosFear,posX,posY)

			if not gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] then
				gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_DMGBonus_Trigger", 1, nil, {heroID,starttime})
			end
			if not gvHero13.TriggerIDs.DivineJudgment.Judgment[player] then
				gvHero13.TriggerIDs.DivineJudgment.Judgment[player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_DivineJudgment_Trigger", 1, nil, {heroID,basedmg,posX,posY,starttime})
			end
		end

	end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------
function GUIAction_Hero14CallOfDarkness()

	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(),Entities.PU_Hero14,1)})[2]
	local starttime = Logic.GetTime()
	gvHero14.CallOfDarkness.LastTimeUsed = starttime

	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero14CallOfDarkness", heroID)
	else
		gvHero14.CallOfDarkness.SpawnTroops(heroID)
	end

end
function GUIAction_Hero14LifestealAura()

	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(),Entities.PU_Hero14,1)})[2]
	local player = Logic.EntityGetPlayer(heroID)
	local starttime = Logic.GetTime()
	gvHero14.LifestealAura.LastTimeUsed = starttime
	GUI.SettlerAffectUnitsInArea(GUI.GetSelectedEntity())

	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero14LifestealAura",GUI.GetPlayerID(),heroID)
	else
		gvHero14.LifestealAura.TriggerIDs[player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero14_Lifesteal_Trigger", 1, nil, {heroID,starttime})
	end

end
function GUIAction_Hero14RisingEvil()

	local heroID = GUI.GetSelectedEntity() or ({Logic.GetPlayerEntities(GUI.GetPlayerID(),Entities.PU_Hero14,1)})[2]
	local pos = GetPosition(heroID)
	local starttime = Logic.GetTime()

	if ({Logic.GetPlayerEntitiesInArea(GUI.GetPlayerID(), Entities.PB_Tower2, pos.X, pos.Y, gvHero14.RisingEvil.Range, 1)})[1] > 0 then
		gvHero14.RisingEvil.LastTimeUsed = starttime

		if CNetwork then
			CNetwork.SendCommand("Ghoul_Hero14RisingEvil",GUI.GetPlayerID(),heroID)
		else
			gvHero14.RisingEvil.SpawnEvilTower(heroID)
		end
	end

end
---------------------------------------------------------------------------------------------------------------------------------------------------------
function GUIAction_Archers_Tower_RemoveSlot(_slot)

	local entity = GUI.GetSelectedEntity()
	local player = Logic.EntityGetPlayer(entity) or GUI.GetPlayerID()

	if gvArchers_Tower.CurrentlyClimbing[entity] then
		return
	end

	if not _slot then
		if gvArchers_Tower.SlotData[entity][2] ~= nil then
			_slot = 2

		elseif gvArchers_Tower.SlotData[entity][1] ~= nil then
			_slot = 1

		else
			return

		end
	end

	if gvArchers_Tower.SlotData[entity][_slot] == nil then
		return
	end

	local soldierstable,soldiers

	if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[entity][_slot], EntityCategories.Cannon) ~= 1 then
		soldierstable = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[entity][_slot])}
		soldiers = soldierstable[1]
	else
		soldierstable = 0
		soldiers = 0
	end

	if not gvArchers_Tower.TriggerIDs.AddTroop[entity.."_".._slot] then

		if CNetwork then
			CNetwork.SendCommand("Ghoul_Archers_Tower_RemoveTroop", player, entity, _slot)
		else
			gvArchers_Tower.PrepareData.RemoveTroop(player, entity, _slot)
		end

		gvArchers_Tower.CurrentlyClimbing[entity] = true
	end

	GUI.DeselectEntity(entity)

end

function GUIAction_Archers_Tower_AddSlot()

	local entity = GUI.GetSelectedEntity()
	local player = Logic.EntityGetPlayer(entity) or GUI.GetPlayerID()

	if gvArchers_Tower.CurrentlyUsedSlots[entity] >= gvArchers_Tower.MaxSlots then
		return
	end

	if gvArchers_Tower.CurrentlyClimbing[entity] then
		return
	end

	local pos = GetPosition(entity)

	if AreEntitiesOfCategoriesAndDiplomacyStateInArea(player, gvArchers_Tower.RangedEnemySearchCategories, pos, gvArchers_Tower.RangedEnemySearchRange, Diplomacy.Hostile ) or AreEntitiesOfCategoriesAndDiplomacyStateInArea( player, gvArchers_Tower.MeleeEnemySearchCategories, pos, gvArchers_Tower.MeleeEnemySearchRange, Diplomacy.Hostile ) then
		Message("Der Feind ist Euch bereits zu nahe. Truppen können nicht den Turm hinauf, solange Feinde in der Nähe sind!")
		Sound.PlayFeedbackSound( Sounds.Leader_LEADER_NO_rnd_01, 0 )
		return
	end

	local offset = gvArchers_Tower.GetOffset_ByOrientation(entity)
	local position = {X = pos.X - offset.X, Y = pos.Y - offset.Y}
	local freeslot = gvArchers_Tower.GetFirstFreeSlot(entity)
	local soldierstable,soldiers

	if freeslot then

		for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(player), CEntityIterator.OfAnyTypeFilter(unpack(gvArchers_Tower.AllowedTypes)), CEntityIterator.InCircleFilter(position.X, position.Y, gvArchers_Tower.Troop_SearchRadius)) do

			local slot = (table_findvalue(gvArchers_Tower.SlotData[entity],eID) ~= 0)

			if not slot then
				if Logic.IsEntityInCategory(eID, EntityCategories.Cannon) ~= 1 then
					soldierstable = {Logic.GetSoldiersAttachedToLeader(eID)}
					soldiers = soldierstable[1]
				else
					soldierstable = 0
					soldiers = 0
				end

				if not gvArchers_Tower.TriggerIDs.AddTroop[entity.."_"..freeslot] then

					if CNetwork then
						CNetwork.SendCommand("Ghoul_Archers_Tower_AddTroop", player, entity, eID)
					else
						gvArchers_Tower.PrepareData.AddTroop(player, entity, eID)
					end

					gvArchers_Tower.CurrentlyClimbing[entity] = true
				end

			end

			break

		end
	end

	GUI.DeselectEntity(entity)

end
------------------------------------------------- Army Creator ---------------------------------------------------
function GUIAction_ArmyCreatorChangeAmount(_EntityType,_Modifier)

	local pID = GUI.GetPlayerID()

	if ArmyCreator.PlayerTroops[pID][_EntityType] + _Modifier >= 0 then

		if ArmyCreator.PlayerPoints >= (ArmyCreator.PointCosts[_EntityType] * _Modifier) then

			if ArmyCreator.TroopException[_EntityType] then

				if ArmyCreator.PlayerTroops[pID][_EntityType] + _Modifier <= 1 then
					ArmyCreator.PlayerPoints = ArmyCreator.PlayerPoints - (ArmyCreator.PointCosts[_EntityType] * _Modifier)
					ArmyCreator.PlayerTroops[pID][_EntityType] = ArmyCreator.PlayerTroops[pID][_EntityType] + _Modifier
				end

			else

				if ArmyCreator.PlayerTroops[pID][_EntityType] + _Modifier <= ArmyCreator.TroopLimit then
					ArmyCreator.PlayerPoints = ArmyCreator.PlayerPoints - (ArmyCreator.PointCosts[_EntityType] * _Modifier)
					ArmyCreator.PlayerTroops[pID][_EntityType] = ArmyCreator.PlayerTroops[pID][_EntityType] + _Modifier
				end

			end

		end

	end

end

function GUIAction_ArmyCreatorCheckForFinish()

	XGUIEng.ShowWidget("BS_ArmyCreator_Finished",0)
	XGUIEng.ShowWidget("BS_ArmyCreator_Finished_Yes",1)
	XGUIEng.ShowWidget("BS_ArmyCreator_Finished_No",1)

end

function GUIAction_ArmyCreatorBackToSetup()

	XGUIEng.ShowWidget("BS_ArmyCreator_Finished_Yes",0)
	XGUIEng.ShowWidget("BS_ArmyCreator_Finished_No",0)
	XGUIEng.ShowWidget("BS_ArmyCreator_Finished",1)

end

function GUIAction_ArmyCreatorFinishSetup()

	XGUIEng.ShowWidget("BS_ArmyCreator",0)

	if CNetwork then

		local toUnpack = {}
		for k,v in pairs(ArmyCreator.PlayerTroops[GUI.GetPlayerID()]) do
			table.insert(toUnpack,k)
			table.insert(toUnpack,v)
		end
		CNetwork.SendCommand("Ghoul_ArmyCreator_SpawnTroops",GUI.GetPlayerID(),unpack(toUnpack))

	else

		ArmyCreator.ReadyForTroopCreation(GUI.GetPlayerID(), ArmyCreator.PlayerTroops[1])

	end
	XGUIEng.ShowWidget("Normal",1)
end

function GUIAction_ScoutFindResources()
	gvScoutUsedPointToResources = true
	GUI.ScoutPointToResources(GUI.GetSelectedEntity())
end

--------------------------------------------------------------------------------
-- Buy a Leader
--------------------------------------------------------------------------------
function GUIAction_BuyMilitaryUnit(_EntityType)

	local BarracksID = GUI.GetSelectedEntity()
	local _UpgradeCategory = _EntityType + 2 ^ 16

	if Logic.GetRemainingUpgradeTimeForBuilding(BarracksID) ~= Logic.GetTotalUpgradeTimeForBuilding(BarracksID) then
		return
	end

	local PlayerID = GUI.GetPlayerID()

	-- Maximum number of settlers attracted?
	if Logic.GetPlayerAttractionUsage(PlayerID) >= Logic.GetPlayerAttractionLimit(PlayerID) then
		GUI.SendPopulationLimitReachedFeedbackEvent(PlayerID)
		return
	end

	--currently researching
	if Logic.GetTechnologyResearchedAtBuilding(BarracksID) ~= 0 then
		return
	end

	Logic.FillSoldierCostsTable(PlayerID, _UpgradeCategory, InterfaceGlobals.CostTable)

	if InterfaceTool_HasPlayerEnoughResources_Feedback( InterfaceGlobals.CostTable ) == 1 then
		-- Yes
		GUI.BuyLeader(BarracksID, _UpgradeCategory)
	end
end
--------------------------------------------------------------------------------
-- Buy a cannon
--------------------------------------------------------------------------------
function GUIAction_BuyCannon(_CannonType, _UpgradeCategory)

	-- Get barrack
	local FoundryID = GUI.GetSelectedEntity()

	if InterfaceTool_IsBuildingDoingSomething( FoundryID ) == true then
		return
	end

	local PlayerID = GUI.GetPlayerID()

	-- Maximum number of settlers attracted?
	if Logic.GetPlayerAttractionUsage( PlayerID ) >= Logic.GetPlayerAttractionLimit( PlayerID ) then
		GUI.SendPopulationLimitReachedFeedbackEvent( PlayerID )
		return
	end

	Logic.FillSoldierCostsTable( PlayerID, _UpgradeCategory, InterfaceGlobals.CostTable )

	if InterfaceTool_HasPlayerEnoughResources_Feedback( InterfaceGlobals.CostTable ) == 1 then
		-- Yes
		GUI.BuyCannon(FoundryID, _CannonType)
		XGUIEng.ShowWidget(gvGUI_WidgetID.CannonInProgress,1)
	end
end
-- Forester work pause/start button
function GUIAction_Forester_WorkChange(_id, _flag)
	if IsExisting(_id) then
		GUI.DeselectEntity(_id)
		if CNetwork then
			CNetwork.SendCommand("Ghoul_Forester_WorkChange", GUI.GetPlayerID(), _id, _flag)
		else
			Forester.WorkChange(_id, _flag)
		end
	end
end
-- Buy a hero
function BuyHeroWindow_Action_BuyHero(_HeroEntityType)

	local PlayerID = GUI.GetPlayerID()
	local BuildingID = GUI.GetSelectedEntity()
	if BuildingID ~= nil then
		if not gvHQTypeTable[Logic.GetEntityType(BuildingID)] then
			BuildingID = 0
		end
	end
	GUI.BuyHero(PlayerID, _HeroEntityType, BuildingID or 0)
	XGUIEng.ShowWidget(gvGUI_WidgetID.BuyHeroWindow, 0)
	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
end
function GUIAction_UpgradeLeader(_LeaderID)
	local entities = {GUI.GetSelectedEntities()}
	local etype, upetype, numsoldiers, soletype, upsoletype, t, BarracksID
	local PlayerID = GUI.GetPlayerID()

	if not entities[2] then
		BarracksID = Logic.LeaderGetNearbyBarracks(_LeaderID)
		if BarracksID == 0 then
			return
		end
		--currently upgrading
		if Logic.GetRemainingUpgradeTimeForBuilding(BarracksID) ~= Logic.GetTotalUpgradeTimeForBuilding(BarracksID) then
			Message(XGUIEng.GetStringTableText("ingamemessages/Note_TroopUpgradeNotPossibleBecauseOfUpgrade"))
			Sound.PlayFeedbackSound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_04, 130)
			return
		end
		--currently researching
		if Logic.GetTechnologyResearchedAtBuilding(BarracksID) ~= 0 then
			Message(XGUIEng.GetStringTableText("ingamemessages/Note_TroopUpgradeNotPossibleBecauseOfResearch"))
			Sound.PlayFeedbackSound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_03, 130)
			return
		end
		etype = Logic.GetEntityType(_LeaderID)
		upetype = etype + 1
		numsoldiers = Logic.LeaderGetNumberOfSoldiers(_LeaderID)
		soletype = Logic.LeaderGetSoldiersType(_LeaderID)
		upsoletype = soletype + 1
		t = CreateCostDifferenceTable(PlayerID, etype, upetype, soletype, upsoletype, numsoldiers)
		if InterfaceTool_HasPlayerEnoughResources_Feedback(t) == 1 then
			if CNetwork then
				CNetwork.SendCommand("Ghoul_UpgradeLeaderCommand", _LeaderID, PlayerID, unpack(t))
			else
				GUIAction_ActionUpgradeLeader(_LeaderID, PlayerID, unpack(t))
			end
		end
	else
		local temp_t = {}
		for i = 1, table.getn(entities) do
			local id = entities[i]
			if Logic.IsLeader(id) == 1 then
				etype = Logic.GetEntityType(id)
				local tech = UpgradeTechByEtype[etype]
				if tech then
					local techstate = Logic.GetTechnologyState(PlayerID, tech)
					if techstate == 4 then
						BarracksID = Logic.LeaderGetNearbyBarracks(id)
						if BarracksID ~= 0
						and Logic.GetRemainingUpgradeTimeForBuilding(BarracksID) == Logic.GetTotalUpgradeTimeForBuilding(BarracksID)
						and Logic.GetTechnologyResearchedAtBuilding(BarracksID) == 0 then
							local typename = Logic.GetEntityTypeName(Logic.GetEntityType(BarracksID))
							if tonumber(string.sub(typename, string.len(typename))) >= UpgradeBuildingLVLByEtype[etype] then
								upetype = etype + 1
								numsoldiers = Logic.LeaderGetNumberOfSoldiers(id)
								soletype = Logic.LeaderGetSoldiersType(id)
								upsoletype = soletype + 1
								temp_t[i] = CreateCostDifferenceTable(PlayerID, etype, upetype, soletype, upsoletype, numsoldiers)
							end
						end
					end
				end
			end
		end
		t = {}
		for i = 1, 17 do
			t[i] = 0
		end
		for k, v in pairs(temp_t) do
			for i = 1, table.getn(v) do
				t[i] = t[i] + v[i]
			end
		end
		if InterfaceTool_HasPlayerEnoughResources_Feedback(t) == 1 then
			for k, v in pairs(temp_t) do
				if CNetwork then
					CNetwork.SendCommand("Ghoul_UpgradeLeaderCommand", entities[k], PlayerID, unpack(v))
				else
					GUIAction_ActionUpgradeLeader(entities[k], PlayerID, unpack(v))
				end
			end
		end
	end
end
function GUIAction_ActionUpgradeLeader(_LeaderID, _PlayerID, ...)
	local soldiers = {Logic.GetSoldiersAttachedToLeader(_LeaderID)}
	if not Logic.IsEntityAlive(_LeaderID) then
		return
	end
	for i = 1, arg.n do
		Logic.SubFromPlayersGlobalResource(_PlayerID, i, arg[i])
	end
	for i = 1, soldiers[1] do
		Logic.DEBUG_UpgradeSettler(soldiers[i + 1])
	end
	Logic.DEBUG_UpgradeSettler(_LeaderID)
end
EntityTypesInCatString = {["Mercenary"] = {	Entities.CU_BanditLeaderBow1,
											Entities.CU_BanditLeaderSword1,
											Entities.CU_BanditLeaderSword2,
											Entities.CU_Barbarian_LeaderClub1,
											Entities.CU_Barbarian_LeaderClub2,
											Entities.CU_BlackKnight_LeaderMace1,
											Entities.CU_BlackKnight_LeaderMace2,
											Entities.CU_BlackKnight_LeaderSword3,
											Entities.CU_VeteranLieutenant},
							["Bearman"] = {	Entities.CU_Evil_LeaderBearman1,
											Entities.CU_Evil_LeaderSkirmisher1,
											Entities.PU_Hero14_Bearman1,
											Entities.PU_Hero14_Bearman2,
											Entities.PU_Hero14_BearmanElite,
											Entities.PU_Hero14_Skirmisher1,
											Entities.PU_Hero14_Skirmisher2,
											Entities.PU_Hero14_SkirmisherElite},
							   ["Ulan"] = { Entities.PU_LeaderUlan1}
							}
function GUIAction_SelectEntityInCategory(_catstring)
	-- Do not jump in cutscene!
	if gvInterfaceCinematicFlag == 1 then
		return
	end
	if not EntityTypesInCatString[_catstring] then
		return
	end
	local EntityTable = {}
	for i = 1, table.getn(EntityTypesInCatString[_catstring]) do
		local TempTable = {Logic.GetPlayerEntities(GUI.GetPlayerID(), EntityTypesInCatString[_catstring][i], 48)}
		local number = TempTable[1]
		for j = 1, number do
			table.insert(EntityTable,TempTable[j+1])
		end
	end

	if table.getn(EntityTable) == 0 then
		return
	end
	local counter = gvKeyBindings_LastSelectedEntityPos

	--Counter at the end of table?
	counter = counter + 1
	if counter >= table.getn(EntityTable) then
		counter = 0
	end

	gvKeyBindings_LastSelectedEntityPos = counter
	local EntityID = EntityTable[1 + counter]
	local IDPosX, IDPosY = Logic.GetEntityPosition(EntityID)
	Camera.ScrollSetLookAt(IDPosX, IDPosY)
	GUI.SetSelectedEntity(EntityID )
end
function KeyBindings_SelectCannons()

	local AllCannons = {}

	for eID in CEntityIterator.Iterator(CEntityIterator.OfCategoryFilter(EntityCategories.Cannon), CEntityIterator.OfPlayerFilter(GUI.GetPlayerID()), CEntityIterator.IsSettlerFilter()) do
		table.insert(AllCannons, eID)
	end

	if table.getn(AllCannons) == 0 then
		return
	end

	local counter = gvKeyBindings_LastSelectedEntityPos

	--Counter at the end of table?
	counter = counter + 1
	if counter >= table.getn(AllCannons) then
		counter = 0
	end

	gvKeyBindings_LastSelectedEntityPos = counter

	local EntityID = AllCannons[1 + counter]

	local X, Y = Logic.GetEntityPosition(EntityID)
	Camera.ScrollSetLookAt(X, Y)
	GUI.SetSelectedEntity(EntityID)

end
function GUIAction_ActivateCoalUsage(_flag)
	local player = GUI.GetPlayerID()
	local type = Logic.GetEntityType(GUI.GetSelectedEntity())
	if CNetwork then
		CNetwork.SendCommand("Ghoul_CoalUsageChange", _flag, player, type)
	else
		gvCoal.AdjustTypeList(_flag, player, type)
	end
end
