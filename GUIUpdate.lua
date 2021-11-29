function GUIUpdate_AttackRange()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local EntityType = Logic.GetEntityType(EntityID)
	local PID = GUI.GetPlayerID()
	local RangeTechBonus = 0
	local BaseRange = round(GetEntityTypeBaseAttackRange(EntityType))
	--Check auf Technologie Modifikatoren
	if Logic.IsEntityInCategory(EntityID, EntityCategories.Bow) == 1 or Logic.IsEntityInCategory(EntityID, EntityCategories.CavalryLight) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_Fletching) == 4 then
			RangeTechBonus = 300
		else
			RangeTechBonus = 0
		end
	elseif  Logic.IsEntityInCategory(EntityID, EntityCategories.Rifle) == 1 then
		if Logic.GetTechnologyState(PID,Technologies.T_Sights) == 4 then
			RangeTechBonus = 300
		else
			RangeTechBonus = 0
		end		
	else
		RangeTechBonus = 0
	end
	XGUIEng.SetText( CurrentWidgetID," @ra "..BaseRange + RangeTechBonus )	
end
function GUIUpdate_VisionRange()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	-- range in settlers centimeter (rounded due to uncertainties in rain)
	local Range = round(Logic.GetEntityExplorationRange(EntityID)*100) 
	XGUIEng.SetText( CurrentWidgetID," @ra "..Range )	
end
function GUIUpdate_AttackSpeed()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local EntityType = Logic.GetEntityType(EntityID)
	-- Angriffe pro 1000 Sek.
	local BaseSpeed = round(1000000/GetEntityTypeBaseAttackSpeed(EntityType))
	-- Angriffe pro Sek.
	local SpeedAsString = string.format("%.3f",BaseSpeed/1000)
	
	XGUIEng.SetText( CurrentWidgetID, " @ra "..SpeedAsString )		
end
function GUIUpdate_MoveSpeed()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local EntityID = GUI.GetSelectedEntity()
	local PID = GUI.GetPlayerID()
	local SpeedTechBonus = 0
	local SpeedWeatherFactor = 1
	local BaseSpeed = round(GetSettlerBaseMovementSpeed(EntityID))
	--Check auf Wetter
	if Logic.GetWeatherState() == 1 then
		SpeedWeatherFactor = 1
	elseif Logic.GetWeatherState() == 2 then
		SpeedWeatherFactor = 1.05
	elseif Logic.GetWeatherState() == 3 then
		SpeedWeatherFactor = 0.8
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
			SpeedTechBonus = 100
		elseif Logic.GetTechnologyState(PID,Technologies.T_Agility) == 4 and Logic.GetTechnologyState(PID,Technologies.T_Chest_ThiefBuff) == 4 then
			SpeedTechBonus = 150	
		else
			SpeedTechBonus = 0
		end
	else
		SpeedTechBonus = 0
	
	end
	XGUIEng.SetText( CurrentWidgetID, " @ra "..round((BaseSpeed+SpeedTechBonus)*SpeedWeatherFactor) )	
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
	if PlayerID == 17 then
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end
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
	if PlayerID == 17 then
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end	
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
	local PID = Logic.EntityGetPlayer(eID)
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local eType = Logic.GetEntityType(eID)
	local TimePassed = 0
	local RechargeTime = gvLighthouse.cooldown
	
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
--[[function GUIUpdate_UpgradeButtonsNew(_Button, _Technology)
	
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
end]]
--------------------------------------------------------------------------------
-- Update Technology buttons that are depening on the Buildingtype
--------------------------------------------------------------------------------
--[[function GUIUpdate_TechnologyButtonsNew(_Button, _Technology, _BuildingType)
	
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
			if SelectedBuildingType == Entities.PB_Bank2 or SelectedBuildingType == Entities.PB_Bank3 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end 
		
		if _Technology == Technologies.T_Scale then
			if SelectedBuildingType == Entities.PB_Bank2 or SelectedBuildingType == Entities.PB_Bank3 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
	
			end
		end 

		if _Technology == Technologies.T_BookKeeping then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.T_Debenture)
			if SelectedBuildingType == Entities.PB_Bank3 and TechReq == 4 then
				XGUIEng.DisableButton(_Button,0)
			else 
				XGUIEng.DisableButton(_Button,1)
			end
		end
		if _Technology == Technologies.T_Coinage then
			local TechReq = Logic.GetTechnologyState(PlayerID, Technologies.T_Scale)
			if SelectedBuildingType == Entities.PB_Bank3 and TechReq == 4 then
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
end]]
--[[function GUIUpdate_BuildingButtonsNew(_Button, _Technology)
	
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
		if _Technology == Technologies.MU_Serf then
			XGUIEng.DisableButton(_Button,0)
		else
			XGUIEng.DisableButton(_Button,0)
		end
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
end]]
function GUIUpdate_SumOfTaxes()
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local PlayerID = GUI.GetPlayerID()

	local GrossPayday = Logic.GetPlayerPaydayCost(PlayerID)	
	
	local factor = 1
	local workers 
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}
			if workers[1] >= 3 then
				factor = factor + 0.015
			else
			end
		else
		end
	end
	if factor > 1.15 then 
		factor = 1.15
	end
	if gvPresent and PlayerID ~= 17 then			
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]
	end
	local TotalPayday = math.floor(GrossPayday * factor)
	XGUIEng.SetTextByValue( CurrentWidgetID, TotalPayday, 1 )
	
end
function GUIUpdate_TaxPaydayIncome()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local PlayerID = GUI.GetPlayerID()
	
	if PlayerID == 17 then
		if GUI.GetSelectedEntity() ~= nil and GUI.GetSelectedEntity() ~= 0 then
			PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
		end
	else
	
	end
	
	local GrossPayday = Logic.GetPlayerPaydayCost(PlayerID)
	local LeaderCosts = Logic.GetPlayerPaydayLeaderCosts(PlayerID)
		
	local TaxesPlayerWillGet = GrossPayday - LeaderCosts
	
	local factor = 1
	local workers 
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}
			if workers[1] >= 3 then
				factor = factor + 0.015
			else
			end
		else
		end
	end
	if factor > 1.15 then
		factor = 1.15
	end
	if gvPresent and PlayerID ~= 17 then		
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]
	end
	local TotalPayday = math.floor(TaxesPlayerWillGet * factor)
	local String
		
	if TaxesPlayerWillGet < 0 then
		String = "@color:255,100,100,255 @ra " .. TotalPayday
	else
		String = "@color:100,255,100,255 @ra +" .. TotalPayday
	end
			
	XGUIEng.SetText(CurrentWidgetID, String)	
		 		
	
end


function GUIUpdate_TaxSumOfTaxes()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local PlayerID = GUI.GetPlayerID()

	local TaxIncome = Logic.GetPlayerPaydayCost(PlayerID)	
	
	local factor = 1
	local workers 
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}
			if workers[1] >= 3 then
				factor = factor + 0.015
			else
			end
		else
		end
	end
	
	if factor > 1.15 then 
		factor = 1.15
	end
	if gvPresent and PlayerID ~= 17 then			
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]
	end
	local TotalIncome = math.floor(TaxIncome * factor)
	XGUIEng.SetText(CurrentWidgetID, TotalIncome)	
	
end
function GUIUpdate_TaxLeaderCosts()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local PlayerID = GUI.GetPlayerID()
	
	local LeaderCosts = -(Logic.GetPlayerPaydayLeaderCosts(PlayerID))
	
	local factor = 1
	local workers 
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}
			if workers[1] >= 3 then
				factor = factor + 0.015
			else
			end
		else
		end
	end
	factor = math.min(factor,1.15)
	if gvPresent and PlayerID ~= 17 then			
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]
	end
	local TotalCosts = math.floor(LeaderCosts * factor)
	XGUIEng.SetText(CurrentWidgetID, TotalCosts)	
	
end
function GUIUpdate_MintTaxBonus()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local PlayerID = GUI.GetPlayerID()
	if PlayerID == 17 then
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end
	local NumOfMints = 0
	local workers 
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}
			if workers[1] >= 3 then
				NumOfMints = NumOfMints + 1
			else
			end
		else
		end
	end
	NumOfMints = math.min(NumOfMints,10)
	local LeaderCosts = -math.floor((Logic.GetPlayerPaydayLeaderCosts(PlayerID))*(NumOfMints*0.015))
	local TaxIncome = math.floor((Logic.GetPlayerPaydayCost(PlayerID)*(NumOfMints*0.015)))
	local String = "@color:255,255,255,255 aktueller Bonus: @color:100,255,100,255 " .. NumOfMints*1.5 .. " % @color:255,255,255,255 erhöhter Zahltag  @cr @cr zusätzliche Taler/Zahltag: @color:100,230,100,255 " ..TaxIncome.. " @cr @color:255,255,255 erhöhter Sold/Zahltag: @color:210,20,20,255 "..LeaderCosts
	
	XGUIEng.SetText(CurrentWidgetID, String)	
end

function GUIUpdate_Hero13Ability(_Ability)
	local PlayerID = GUI.GetPlayerID()
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local ProgressBarWidget = 0
	
	local HeroID = GUI.GetSelectedEntity()
	
	local TimePassed = 0
	local cooldown = 0
	if _Ability == "StoneArmor" then
		cooldown = 150
		ProgressBarWidget = XGUIEng.GetWidgetID("Hero13_RechargeStoneArmor")
		TimePassed = math.floor(Logic.GetTime()- gvHero13.LastTimeStoneArmorUsed)
		if TimePassed < cooldown then
			XGUIEng.SetMaterialColor(ProgressBarWidget,1,214,44,24,189)
			XGUIEng.HighLightButton(CurrentWidgetID,0)	
			XGUIEng.DisableButton(CurrentWidgetID,1)
		else
			XGUIEng.SetMaterialColor(ProgressBarWidget,1,0,0,0,0)
			XGUIEng.DisableButton(CurrentWidgetID,0)
		end
		XGUIEng.SetProgressBarValues(ProgressBarWidget,TimePassed, cooldown)
	
	elseif _Ability == "DivineJudgment" then
		cooldown = 60
		ProgressBarWidget = XGUIEng.GetWidgetID("Hero13_RechargeDivineJudgment")
		TimePassed = math.floor(Logic.GetTime()- gvHero13.LastTimeDivineJudgmentUsed)
		if TimePassed < cooldown then
			XGUIEng.SetMaterialColor(ProgressBarWidget,1,214,44,24,189)
			XGUIEng.HighLightButton(CurrentWidgetID,0)	
			XGUIEng.DisableButton(CurrentWidgetID,1)
		else
			XGUIEng.SetMaterialColor(ProgressBarWidget,1,0,0,0,0)
			XGUIEng.DisableButton(CurrentWidgetID,0)
		end
		XGUIEng.SetProgressBarValues(ProgressBarWidget,TimePassed, cooldown)
	end	
end

function GUIUpdate_HeroButton()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	
	local EntityID = XGUIEng.GetBaseWidgetUserVariable(CurrentWidgetID, 0)
	
	
	
	local SourceButton
	
	if Logic.IsEntityInCategory(EntityID,EntityCategories.Hero1) == 1 then	
		SourceButton = "FindHeroSource1"
		XGUIEng.TransferMaterials(SourceButton, CurrentWidgetID)
		if Logic.SentinelGetUrgency(EntityID) == 1 then					
		
		if gvGUI.DarioCounter < 50 then
			
			XGUIEng.SetMaterialColor(CurrentWidgetID,0, 100,100,200,255)		
			gvGUI.DarioCounter = gvGUI.DarioCounter +1
		end		
		if gvGUI.DarioCounter >= 50 then			
			XGUIEng.SetMaterialColor(CurrentWidgetID,0, 255,255,255,255)		
			gvGUI.DarioCounter = gvGUI.DarioCounter +1
		end
		if gvGUI.DarioCounter == 100 then
			gvGUI.DarioCounter= 0
		end
		else	
			XGUIEng.SetMaterialColor(CurrentWidgetID,0, 255,255,255,255)		
		end
	else
		
		
		if Logic.IsEntityInCategory(EntityID,EntityCategories.Hero2) == 1 then
			SourceButton = "FindHeroSource2"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero3) == 1 then
			SourceButton = "FindHeroSource3"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero4) == 1 then
			SourceButton = "FindHeroSource4"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero5) == 1 then
			SourceButton = "FindHeroSource5"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero6) == 1 then
			SourceButton = "FindHeroSource6"
		elseif Logic.GetEntityType( EntityID )	== Entities.CU_BlackKnight then
			SourceButton = "FindHeroSource7"
		elseif Logic.GetEntityType( EntityID )	== Entities.CU_Mary_de_Mortfichet then
			SourceButton = "FindHeroSource8"
		elseif Logic.GetEntityType( EntityID )	== Entities.CU_Barbarian_Hero then
			SourceButton = "FindHeroSource9"
		
		--AddOn
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero10) == 1 then
			SourceButton = "FindHeroSource10"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero11) == 1 then
			SourceButton = "FindHeroSource11"
		elseif Logic.GetEntityType( EntityID )	== Entities.CU_Evil_Queen then
			SourceButton = "FindHeroSource12"
			
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero13) then
			SourceButton = "FindHeroSource13"
		
		else
			SourceButton = "FindHeroSource9"
		end
		
		XGUIEng.TransferMaterials(SourceButton, CurrentWidgetID)
	end
	
	
	
end