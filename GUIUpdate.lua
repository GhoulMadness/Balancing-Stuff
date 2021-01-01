function GUIUpdate_AttackRange()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local Range = MemoryManipulation.GetEntityMaxRange(EntityID)
	XGUIEng.SetTextByValue( CurrentWidgetID, Range, 1 )	
end
function GUIUpdate_VisionRange()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local Range = (Logic.GetEntityExplorationRange(EntityID)	* 100)
	XGUIEng.SetTextByValue( CurrentWidgetID, Range, 1 )	
end
function GUIUpdate_AttackSpeed()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local EntityType = Logic.GetEntityType(EntityID)
	-- Angriffe pro 1000 Sek.
	local Speed = math.floor(1000000/(MemoryManipulation.GetSettlerTypeBattleWaitUntil(EntityType)))
	local SpeedAsString = string.format(Speed/1000,"%.2f")
	
	XGUIEng.SetTextByValue( CurrentWidgetID, Speed, 1 )		
end
function GUIUpdate_MoveSpeed()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local PID = GUI.GetPlayerID()
	local SpeedTechBonus = 0
	local SpeedWeatherFactor = 1
	local BaseSpeed = round(MemoryManipulation.GetSettlerMovementSpeed(EntityID)) 
	--Check auf Wetter
	if Logic.GetWeatherState() == 1 then
		SpeedWeatherFactor = 1
	elseif Logic.GetWeatherState() == 2 then
		SpeedWeatherFactor = 1.1
	elseif Logic.GetWeatherState() == 3 then
		SpeedWeatherFactor = 0.75
	else
		return
	end
	--Check auf Technologie Modifikatoren
	if Logic.IsSerf(EntityID) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_Shoes) == 4 and Logic.GetTechnologyState(PID,Technologies.T_Alacricity) ~= 4 then
			SpeedTechBonus = 20
		elseif Logic.GetTechnologyState(PID,Technologies.T_Alacricity) == 4 and Logic.GetTechnologyState(PID,Technologies.T_Shoes) ~= 4 then
			SpeedTechBonus = 40
		elseif Logic.GetTechnologyState(PID,Technologies.T_Alacricity) == 4 and Logic.GetTechnologyState(PID,Technologies.T_Shoes) == 4 then
			SpeedTechBonus = 60
		else
			SpeedTechBonus = 0
		end		
	elseif Logic.IsEntityInCategory(EntityID, EntityCategories.Bow) == 1 or Logic.IsEntityInCategory(EntityID, EntityCategories.Rifle) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_BetterTrainingArchery) == 4 then
			SpeedTechBonus = 40
		else
			SpeedTechBonus = 0
		end
	elseif Logic.IsEntityInCategory(EntityID, EntityCategories.Sword) == 1 or Logic.IsEntityInCategory(EntityID, EntityCategories.Spear) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_BetterTrainingBarracks) == 4 then
			SpeedTechBonus = 30
		else
			SpeedTechBonus = 0
		end
	elseif Logic.IsEntityInCategory(EntityID, EntityCategories.CavalryLight) == 1 or Logic.IsEntityInCategory(EntityID, EntityCategories.CavalryHeavy) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_Shoeing) == 4 then
			SpeedTechBonus = 50
		else
			SpeedTechBonus = 0
		end		
	elseif Logic.IsEntityInCategory(EntityID, EntityCategories.Cannon) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_BetterChassis) == 4 then
			SpeedTechBonus = 30
		else
			SpeedTechBonus = 0
		end	
	elseif Logic.IsEntityInCategory(EntityID, EntityCategories.Thief) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_Agility) == 4 and Logic.GetTechnologyState(PID,Technologies.T_Chest_ThiefBuff) ~= 4 then
			SpeedTechBonus = 50
		elseif Logic.GetTechnologyState(PID,Technologies.T_Agility) ~= 4 and Logic.GetTechnologyState(PID,Technologies.T_Chest_ThiefBuff) == 4 then
			SpeedTechBonus = 60
		elseif Logic.GetTechnologyState(PID,Technologies.T_Agility) == 4 and Logic.GetTechnologyState(PID,Technologies.T_Chest_ThiefBuff) == 4 then
			SpeedTechBonus = 110	
		else
			SpeedTechBonus = 0
		end
	else
		SpeedTechBonus = 0
	
	end
	XGUIEng.SetTextByValue( CurrentWidgetID, round((BaseSpeed+SpeedTechBonus)*SpeedWeatherFactor), 1 )	
end
function GUIUpdate_Time()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	--Spielzeit in sec
	local secondsperday = gvDayTimeSeconds or 1440
	local daytimefactor = secondsperday/86400
	local GameTime = gvIngameTimeSec - gvSecondsDuringBreak --besser GUI.GetTime() oder XGUIEng.GetSystemTime(); beide laufen während Spielpause weiter..?
	if gvTutorialFlag ~= nil then
		GameTime = gvIngameTimeSec - gvSecondsDuringBreak - 34
	end
	
	local TimeMinutes = math.floor(GameTime/(3600*daytimefactor))
	--Tag startet um 8 Uhr morgens
	local TimeHours = 8						
	local TimeMinutesText = ""
	local TimeHoursText = ""
	while TimeMinutes > 59 do 
		TimeMinutes = TimeMinutes-60
		TimeHours = TimeHours + 1
	end
	while TimeHours > 23 do
		local TimeDif = TimeHours - 24
			if TimeDif ~= 0 then
				TimeHours = 0+TimeDif
			else
				TimeHours = 0
			end
	end
	if TimeMinutes <10 then
		TimeMinutesText = "0"..TimeMinutes
	else
		TimeMinutesText = TimeMinutes
	end
	if TimeHours <10 then
		TimeHoursText = "0"..TimeHours
	else
		TimeHoursText = TimeHours
	end
	XGUIEng.SetText( CurrentWidgetID, TimeHoursText..":"..TimeMinutesText, 1 )	
end
function GUIUpdate_ResourceAmountRawAndRefined( _ResourceType )

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local PlayerID = GUI.GetPlayerID()
	
	local Amount = round(Logic.GetPlayersGlobalResource( PlayerID, _ResourceType ))	
	
	local RawResourceType = Logic.GetRawResourceType( _ResourceType )
	local RawResourceAmount = round(Logic.GetPlayersGlobalResource( PlayerID, RawResourceType ))
	
	local String = " "
	
	--local procent = math.floor((Amount/(Amount + RawResourceAmount))*100)
	XGUIEng.SetText( CurrentWidgetID, "@color:255,0,0 "..RawResourceAmount.." @color:255,255,255 / @color:10,170,160 "..Amount.." ")				
end
function GUIUpdate_SpecialResourceAmount(_ResourceType)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local PlayerID = GUI.GetPlayerID()	
	local Amount = Logic.GetPlayersGlobalResource(PlayerID,_ResourceType)	
	local WeatherEnergyMax = Logic.GetEnergyRequiredForWeatherChange()
	local FaithMax = 5000
	local procent = 0
	
	if _ResourceType == ResourceType.Faith then
		procent = math.floor((Amount/FaithMax)*100)
		if procent > 100 then 
			procent = 100
		end
	else
		procent = math.floor((Amount/WeatherEnergyMax)*100)
		if procent > 100 then
			procent = 100
		end
	end
	if procent <= 20 then
		XGUIEng.SetText( CurrentWidgetID, "@color:255,0,0 "..procent.." @color:255,255,255 % ")		
	elseif procent > 20 and procent <= 40 then
		XGUIEng.SetText( CurrentWidgetID, "@color:255,165,0 "..procent.." @color:255,255,255 % ")	
	elseif procent > 40 and procent <= 60 then
		XGUIEng.SetText( CurrentWidgetID, "@color:255,255,0 "..procent.." @color:255,255,255 % ")	
	elseif procent > 60 and procent <= 80 then
		XGUIEng.SetText( CurrentWidgetID, "@color:153,225,47 "..procent.." @color:255,255,255 % ")	
	elseif procent > 80 then
		XGUIEng.SetText( CurrentWidgetID, "@color:50,205,50 "..procent.." @color:255,255,255 % ")		
	end		
end
function GUIUpdate_LightningRod()
	local PlayerID = GUI.GetPlayerID()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local BuildingID = GUI.GetSelectedEntity()
	
	local TimePassed = math.floor((Logic.GetTimeMs()- gvLastTimeLightningRodUsed)/2400)
	local RechargeTime = 100

	if	Logic.GetTechnologyState(PlayerID,Technologies.GT_Chemistry) ~= 4 then
		XGUIEng.DisableButton(CurrentWidgetID,1)
		XGUIEng.SetMaterialColor(CurrentWidgetID,1,210,210,210,210)
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"),1,210,210,210,210)
	else
		
		if TimePassed >= RechargeTime then	
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"),1,0,0,0,0)
			XGUIEng.DisableButton(CurrentWidgetID,0)
	
		else 
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"),1,214,44,24,189)
			XGUIEng.HighLightButton(CurrentWidgetID,0)	
			XGUIEng.DisableButton(CurrentWidgetID,1)
		end
	
	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"),TimePassed, RechargeTime)
	end
	
end
function GUIUpdate_LevyTaxes()

	local PlayerID = GUI.GetPlayerID()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local BuildingID = GUI.GetSelectedEntity()
	
	local TimePassed = math.floor((Logic.GetTimeMs()- gvLastTimeButtonPressed)/2400)

	
	local RechargeTime = 100

	if 	Logic.GetTechnologyState(PlayerID,Technologies.GT_Taxation) ~= 4 then
		XGUIEng.DisableButton(CurrentWidgetID,1)
		XGUIEng.HighLightButton(CurrentWidgetID,0)	
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Levy_Duties_Recharge"),1,0,0,0,0)
	else

		if TimePassed < RechargeTime then
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Levy_Duties_Recharge"),1,214,44,24,189)
			XGUIEng.HighLightButton(CurrentWidgetID,0)	
			XGUIEng.DisableButton(CurrentWidgetID,1)
		else
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Levy_Duties_Recharge"),1,0,0,0,0)
			XGUIEng.DisableButton(CurrentWidgetID,0)
		end		
	end
	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID("Levy_Duties_Recharge"),TimePassed, RechargeTime)
	
end
function GUIUpdate_LighthouseTroops()

	local eID = GUI.GetSelectedEntity()
	local PID = GUI.GetPlayerID()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local eType = Logic.GetEntityType(eID)
	local TimePassed = 0
	local RechargeTime = gvLighthouse.cooldown
	if GUI.GetPlayerID() == 17 then
		PID = Logic.EntityGetPlayer(eID)
	end
	
	TimePassed = math.floor(Logic.GetTime()- gvLighthouse.starttime[PID])

	if eType ~= Entities.CB_LighthouseActivated then
		XGUIEng.DisableButton(CurrentWidgetID,1)
		XGUIEng.HighLightButton(CurrentWidgetID,0)	
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lighthouse_Recharge"),1,0,0,0,0)
	else
		if TimePassed < RechargeTime then
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lighthouse_Recharge"),1,214,44,24,189)
			XGUIEng.HighLightButton(CurrentWidgetID,0)	
			XGUIEng.DisableButton(CurrentWidgetID,1)
		else
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lighthouse_Recharge"),1,0,0,0,0)
			XGUIEng.DisableButton(CurrentWidgetID,0)
		end		
	
	end
	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID("Lighthouse_Recharge"),TimePassed, RechargeTime)

end
function GUIUpdate_MercenaryTower(_button)

	local PlayerID = GUI.GetPlayerID()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local BuildingID = GUI.GetSelectedEntity()
	
	local TimePassed = math.floor(Logic.GetTime()- gvMercenaryTower.LastTimeUsed)

	local RechargeTime = gvMercenaryTower.Cooldown[_button]

	if	Logic.GetTechnologyState(PlayerID,gvMercenaryTower.TechReq[_button]) ~= 4 then
		
		XGUIEng.DisableButton(CurrentWidgetID,1)		
		XGUIEng.HighLightButton(CurrentWidgetID,0)	
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]),1,0,0,0,0)

	else
		if TimePassed < RechargeTime then
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]),1,214,44,24,189)
			XGUIEng.HighLightButton(CurrentWidgetID,0)	
			XGUIEng.DisableButton(CurrentWidgetID,1)
		else
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]),1,0,0,0,0)
			XGUIEng.DisableButton(CurrentWidgetID,0)
		end

		
	end
	
	
	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]),TimePassed, RechargeTime)
	
end
function GUIUpdate_UpgradeButtonsNew(_Button, _Technology)
	
	local PlayerID = GUI.GetPlayerID()
	if _Button == "Upgrade_Bank2" then
		local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Gilds)
	
		--Upgarde is interdicted
		if TechReq ~= 4 then	
			XGUIEng.DisableButton(_Button,1)

		else 
			XGUIEng.DisableButton(_Button,0)		
				
	
		end
	end
	if _Button == "Upgrade_Market2" then
		local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.T_Coinage)
	
		--Upgarde is interdicted
		if TechReq ~= 4 then	
			XGUIEng.DisableButton(_Button,1)

		else 
			XGUIEng.DisableButton(_Button,0)		
				
	
		end
	end
	if _Button == "Upgrade_Bank1" then
		local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Laws)
		if TechReq ~= 4 then	
			XGUIEng.DisableButton(_Button,1)

		else 
			XGUIEng.DisableButton(_Button,0)
		end
	end
end
--------------------------------------------------------------------------------
-- Update Technology buttons that are depening on the Buildingtype
--------------------------------------------------------------------------------
function GUIUpdate_TechnologyButtonsNew(_Button, _Technology, _BuildingType)
	
	local PlayerID = GUI.GetPlayerID()
	local SelectedBuildingID = GUI.GetSelectedEntity()
	local SelectedBuildingType = Logic.GetEntityType( SelectedBuildingID )
	local TechState = Logic.GetTechnologyState(PlayerID, _Technology)
		
		
--Technology is not researched yet
	if 	TechState ~= 0 and TechState ~= 3 then			

		if _Technology == Technologies.GT_Taxation then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Literacy)
			local BuildingReq = (Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_Headquarters2) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_Headquarters3))
			if	TechReq == 4 and BuildingReq >= 1 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end			
		end	
	
		if _Technology == Technologies.GT_Banking then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Taxation)
			local BuildingReq = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_University2) 
			if	TechReq == 4 and BuildingReq >= 1 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)

			end	
		end		
	
		if _Technology == Technologies.GT_Laws then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Banking)
			local BuildingReq = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_Headquarters3) 
			if	TechReq == 4 and BuildingReq >= 1 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)

			end
		end

		if _Technology == Technologies.GT_Gilds then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Laws)
			local MiscReq = UniTechAmount(PlayerID) 
			if	TechReq == 4 and MiscReq >= 20 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)

			end
		end
		
		if _Technology == Technologies.T_TownGuard then
			local BuildingReq1 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_VillageCenter3) 
			local BuildingReq2 = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_University2) 
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.T_Shoes)
			if	BuildingReq1 >= 1 and BuildingReq2 >= 1 and TechReq == 4 and SelectedBuildingType == Entities.PB_VillageCenter3 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)

			end
		end
		
		if _Technology == Technologies.T_Debenture then
			if SelectedBuildingType == Entities.PB_Bank2 or SelectedBuildingType == Entities.CB_Mint1 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end 
		
		if _Technology == Technologies.T_Scale then
			if SelectedBuildingType == Entities.PB_Bank2 or SelectedBuildingType == Entities.CB_Mint1 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
	
			end
		end 

		if _Technology == Technologies.T_BookKeeping then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.T_Debenture)
			if SelectedBuildingType == Entities.CB_Mint1 and TechReq == 4 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		if _Technology == Technologies.T_Coinage then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.T_Scale)
			if SelectedBuildingType == Entities.CB_Mint1 and TechReq == 4 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end

		if _Technology == Technologies.T_PickAxe then
			if SelectedBuildingType == Entities.PB_ClayMine3 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end

		if _Technology == Technologies.T_LightBricks then
			if SelectedBuildingType == Entities.PB_Brickworks2 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		
		if _Technology == Technologies.T_MakeThunderStorm then
			if SelectedBuildingType == Entities.PB_Weathermachine and Logic.GetTechnologyState(PlayerID, Technologies.T_ThunderStorm) == 4 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		
		if _Technology == Technologies.T_BloodRush then
			if SelectedBuildingType == _BuildingType and Score.GetPlayerScore(PlayerID, "battle") > 1999 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
	else
	XGUIEng.DisableButton(_Button,0)
	end
	
	if TechState == 4 then		--Technologie ist bereits erforscht
		XGUIEng.DisableButton(_Button,0)
		XGUIEng.HighLightButton(_Button,1)
		return
	end
	if TechState == 0 then
		XGUIEng.DisableButton(_Button,1)
		XGUIEng.HighLightButton(_Button,0)
		return
	end
end
function GUIUpdate_BuildingButtonsNew(_Button, _Technology)
	
	local PlayerID = GUI.GetPlayerID()
	local TechState = Logic.GetTechnologyState(PlayerID, _Technology)
	
	if 	TechState ~= 0 and TechState ~= 3 then	
			
		if _Technology == Technologies.B_Bank then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Banking)
			if	TechReq == 4  then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		if _Technology == Technologies.B_Outpost then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Laws)
			if	TechReq == 4  then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		--[[if _Technology == Technologies.MU_Serf then
			XGUIEng.DisableButton(_Button,0)
		else
			XGUIEng.DisableButton(_Button,0)
		end]]
		if _Technology == Technologies.B_Lighthouse then
			local TechReq1 = Logic.GetTechnologyState(PlayerID, Technologies.GT_Architecture)
			local TechReq2 = Logic.GetTechnologyState(PlayerID, Technologies.GT_Binocular)
			if	TechReq1 == 4 and TechReq2 == 4 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
			if (Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID,Entities.CB_Lighthouse) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID,Entities.CB_LighthouseActivated)) >= 1 then
				XGUIEng.DisableButton(_Button,1)
			end
		end
		if _Technology == Technologies.B_Weathermanipulator then
			local TechReq1 = Logic.GetTechnologyState(PlayerID, Technologies.GT_Chemistry)
			local TechReq2 = Logic.GetTechnologyState(PlayerID, Technologies.T_WeatherForecast)
			if	TechReq1 == 4 and TechReq2 == 4  then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		if _Technology == Technologies.B_Mercenary then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.GT_Tactics)
			if	TechReq == 4  then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		if _Technology == Technologies.B_Dome then
			local TechReq = UniTechAmount(PlayerID)
			if	TechReq >= 24  then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
	end
	if TechState == 4 then		--Technologie ist bereits erforscht
		XGUIEng.DisableButton(_Button,0)
		XGUIEng.HighLightButton(_Button,1)
		return
	end
end
