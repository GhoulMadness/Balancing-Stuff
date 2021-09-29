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
	GUIAction_ForceSettlersToWorkOrig = GUIAction_ForceSettlersToWork
function GUIAction_ForceSettlersToWork()
	local BuildingID = GUI.GetSelectedEntity()
	local BuildingType =  Logic.GetEntityType( BuildingID )
	local BuildingCategory = Logic.GetUpgradeCategoryByBuildingType( BuildingType )
	if BuildingCategory == UpgradeCategories.Silversmith then
		GUI.AddNote("Eure Silberschmiede weigern sich. Sie werden keine \195\156berstunden verrichten!")
	else
		GUIAction_ForceSettlersToWorkOrig()
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
	XGUIEng.ShowWidget("LeaderDetailsOn",0)
	XGUIEng.ShowWidget("LeaderDetailsOff",1)
end
function GUIAction_LeaderDetailsOff()
	XGUIEng.ShowWidget("DetailsAttackRange",0)
	XGUIEng.ShowWidget("DetailsVisionRange",0)
	XGUIEng.ShowWidget("DetailsAttackSpeed",0)
	XGUIEng.ShowWidget("DetailsMoveSpeed",0)
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
	Sound.PlayGUISound( Sounds.OnKlick_Select_salim, 627 )
	local PlayerID = GUI.GetPlayerID()
	if CNetwork then
        CNetwork.SendCommand("Ghoul_LightningRod_Protected", PlayerID);
    else
	LightningRod_Protected(PlayerID)
	end
end
function LightningRod_Protected(_PID)
	gvLightning.RodProtected[_PID] = true
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","LightningRod_UnProtected",1,{},{_PID})
end
function LightningRod_UnProtected(_PID,_SpecialTimer)
	if _SpecialTimer == nil then
		_SpecialTimer = 45
	end
	if Counter.Tick2("Unprotected".._PID,_SpecialTimer) == true then
		gvLightning.RodProtected[_PID] = false
		return true
	end
end

function GUIAction_LevyTaxes()
    gvLastTimeButtonPressed = Logic.GetTimeMs()
    GUIUpdate_LevyTaxes()
    Sound.PlayGUISound( Sounds.OnKlick_Select_dario, 627 )
    if CNetwork then
        CNetwork.SendCommand("Ghoul_LevyTaxes", GUI.GetPlayerID());
    else
        GUI.LevyTax()
    end
end

function GUIAction_LighthouseHireTroops()
	local eID = GUI.GetSelectedEntity()
	local pID = Logic.EntityGetPlayer(eID)
	
	local Iron   = Logic.GetPlayersGlobalResource( pID, ResourceType.Iron ) + Logic.GetPlayersGlobalResource( pID, ResourceType.IronRaw)
	local Sulfur = Logic.GetPlayersGlobalResource( pID, ResourceType.Sulfur ) + Logic.GetPlayersGlobalResource( pID, ResourceType.SulfurRaw)
	
	if Logic.GetPlayerAttractionUsage(pID) >= Logic.GetPlayerAttractionLimit(pID) then
		GUI.SendPopulationLimitReachedFeedbackEvent(pID)
		return
	end
	if Iron >= 600 and Sulfur >= 400 then
		GUI.DeselectEntity(eID)
		GUI.SelectEntity(eID)
		if CNetwork then
			CNetwork.SendCommand("Ghoul_Lighthouse_SpawnJob", pID,eID);
		else
			Lighthouse_SpawnJob(pID,eID)
			gvLighthouse.starttime[1] = Logic.GetTime()
		end
	else
		Stream.Start("Sounds\\VoicesMentor\\INFO_notenough.wav",110)
	end
end
function GUIAction_MercenaryTower(_ucat)

	local MercID = GUI.GetSelectedEntity()
	
	if Logic.GetRemainingUpgradeTimeForBuilding(MercID ) ~= Logic.GetTotalUpgradeTimeForBuilding (MercID) then		
		return
	end
	
	local PlayerID = GUI.GetPlayerID()
	
	local VCThreshold = Logic.GetLogicPropertiesMotivationThresholdVCLock()
	local AverageMotivation = Logic.GetAverageMotivation(PlayerID)
	
	if AverageMotivation < VCThreshold then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_VillageCentersAreClosed"))		
		return
	end
	
	-- Maximum number of settlers attracted?
	if Logic.GetPlayerAttractionUsage( PlayerID ) >= Logic.GetPlayerAttractionLimit( PlayerID ) then
		GUI.SendPopulationLimitReachedFeedbackEvent( PlayerID )
		return
	end
		
	--currently researching
	if Logic.GetTechnologyResearchedAtBuilding(MercID) ~= 0 then
		return
	end	
	local SolTypesInUcat = {Logic.GetSettlerTypesInUpgradeCategory(_ucat)}
	if SolTypesInUcat[2] ~= nil then 
		local solType = SolTypesInUcat[2]
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
			CNetwork.SendCommand("Ghoul_ChangeWeatherToThunderstorm", PlayerID,_EntityID);
		else
			ChangeToThunderstorm(PlayerID,_EntityID)
		end
		
					
	else
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_WeathermashineNotReady"))
	end
	
end
gvHero13 = {LastTimeStoneArmorUsed = - 6000,LastTimeDivineJudgmentUsed = - 6000}
function GUIAction_Hero13StoneArmor()
	local heroID = GUI.GetSelectedEntity()
	local player = Logic.EntityGetPlayer(heroID)
	local starttime = Logic.GetTimeMs()
	gvHero13.LastTimeStoneArmorUsed = starttime/1000
	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero13StoneArmor",GUI.GetPlayerID(),heroID);
	else
		_G["Hero13TriggerID_"..player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_StoneArmor_Trigger_"..player, 1, nil, {heroID,starttime})
	end
end
function GUIAction_Hero13RegenAura()
	GUI.SettlerAffectUnitsInArea(GUI.GetSelectedEntity())	
end
function GUIAction_Hero13DivineJudgment()
	local heroID = GUI.GetSelectedEntity()
	local player = Logic.EntityGetPlayer(heroID)
	local basedmg = Logic.GetEntityDamage(heroID)
	local starttime = Logic.GetTimeMs()
	local posX,posY = Logic.GetEntityPosition(heroID)
	gvHero13.LastTimeDivineJudgmentUsed = starttime/1000
	if CNetwork then
		CNetwork.SendCommand("Ghoul_Hero13DivineJudgment",GUI.GetPlayerID(),heroID);
	else
		Logic.CreateEffect(GGL_Effects.FXKerberosFear,posX,posY)
		_G["Hero13DMGBonusTriggerID_"..player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_DMGBonus_Trigger_"..player, 1, nil, {heroID,starttime})
		_G["Hero13JudgmentTriggerID_"..player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_DivineJudgment_Trigger_"..player, 1, nil, {heroID,basedmg,posX,posY,starttime})
	end
end
for i = 1,12 do
	_G["gvHero13_DamageStored_"..i] = 0
	_G["Hero13_StoneArmor_Trigger_"..i] = function(_heroID,_starttime)
		local attacker = Event.GetEntityID1()
		local target = Event.GetEntityID2();
		local player = Logic.EntityGetPlayer(target)
		local posX,posY = Logic.GetEntityPosition(target)
		local time = Logic.GetTimeMs()
		-- Dauer der Fähigkeit in Millisekunden
		local duration = 1000*7
		local dmg = CEntity.TriggerGetDamage();
		if time <= (_starttime + duration) then
			if target == _heroID then
				CEntity.TriggerSetDamage(0);
				Logic.CreateEffect(GGL_Effects.FXSalimHeal,posX,posY)
				_G["gvHero13_DamageStored_"..player] = _G["gvHero13_DamageStored_"..player] + dmg
			end;
		else
			if target == _heroID then
				CEntity.TriggerSetDamage(dmg + (_G["gvHero13_DamageStored_"..player]*0.7))
				Logic.CreateEffect(GGL_Effects.FXMaryDemoralize,posX,posY)
				_G["gvHero13_DamageStored_"..player] = 0
				Trigger.UnrequestTrigger(_G["Hero13TriggerID_"..player])
			end
		end;
	end;
	_G["Hero13_DMGBonus_Trigger_"..i] = function(_heroID,_starttime)
		local attacker = Event.GetEntityID1()
		local player = Logic.EntityGetPlayer(_heroID)
		local time = Logic.GetTimeMs()
		-- Dauer der Fähigkeit in Millisekunden
		local duration = 1000*5
		local dmg = CEntity.TriggerGetDamage();
		if time <= (_starttime + duration) then
			if attacker == _heroID then
				CEntity.TriggerSetDamage(dmg*4);
				Trigger.UnrequestTrigger(_G["Hero13DMGBonusTriggerID_"..player])
			end;
		else
			Trigger.UnrequestTrigger(_G["Hero13DMGBonusTriggerID_"..player])
		end;
	end;
	_G["Hero13_DivineJudgment_Trigger_"..i] = function(_heroID,_origdmg,_posX,_posY,_starttime)
		local time = Logic.GetTimeMs()
		-- Dauer der Fähigkeit in Millisekunden (Zeitfenster für göttliche Bestrafung)
		local duration = 1000*3
		if time > (_starttime + duration) then
			if Logic.IsEntityAlive(_heroID) then
				
			else
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX,_posY)
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX-100,_posY-100)
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX-200,_posY-200)
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX+100,_posY+100)
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX+200,_posY+200)
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX+150,_posY-150)
				Logic.CreateEffect(GGL_Effects.FXLightning,_posX-150,_posY+150)
				-- Reichweite der Fähigkeit (in S-cm)
				local range = 900
				local damage = _origdmg * 12
				for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerFilter(), CEntityIterator.InCircleFilter(_posX, _posY, range)) do
					Logic.HurtEntity(eID, damage)
				end				
			end
			
			Trigger.UnrequestTrigger(_G["Hero13JudgmentTriggerID_".._heroID])
			return true
		end
	end
end
