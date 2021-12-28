function GUIUpdate_AttackRange()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	
	local EntityID = GUI.GetSelectedEntity()
	
	local PID = GUI.GetPlayerID()
	
	local Range = round(GetEntityTypeMaxAttackRange(EntityID,PID))
	
	local pos = GetPosition(EntityID)
	
	local num,towerID = Logic.GetPlayerEntitiesInArea(PID, Entities.PB_Archers_Tower, pos.X, pos.Y, 600, 1)
	
	local factor = 1
	
	if not gvArchers_Tower.SlotData[towerID] then
	
		factor = 1
		
	else
	
		factor = gvArchers_Tower.MaxRangeFactor
		
	end
	
	XGUIEng.SetText( CurrentWidgetID," @ra "..Range * factor )	
	
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
	
	local Speed = round(GetSettlerCurrentMovementSpeed(EntityID,PID))
			
	XGUIEng.SetText( CurrentWidgetID, " @ra "..Speed)	
	
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
-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------ Archers Tower ----------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
function GUIUpdate_Archers_Tower_AddSlot()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	
	local EntityID = GUI.GetSelectedEntity()
	
	if gvArchers_Tower.CurrentlyUsedSlots[EntityID] >= gvArchers_Tower.MaxSlots or table.getn(gvArchers_Tower.SlotData[EntityID]) >= 2 then
	
		XGUIEng.DisableButton(CurrentWidgetID, 1)
		
	else
		
		XGUIEng.DisableButton(CurrentWidgetID, 0)
		
	end
	
end

function GUIUpdate_Archers_Tower_RemoveSlot(_slot)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	
	local EntityID = GUI.GetSelectedEntity()
	
	if _slot then
	
		if gvArchers_Tower.SlotData[EntityID][_slot] ~= nil then
			
			XGUIEng.DisableButton(CurrentWidgetID, 0)
			
		else
			
			XGUIEng.DisableButton(CurrentWidgetID, 1)
			
			for i = 1,4 do
					
				XGUIEng.SetMaterialTexture("Archers_Tower_Slot".._slot, i-1, gvArchers_Tower.EmptySlot_Icon)
						
			end
			
		end
		
	else
	
		if gvArchers_Tower.SlotData[EntityID][1] == nil and gvArchers_Tower.SlotData[EntityID][2] == nil then
		
			XGUIEng.DisableButton(CurrentWidgetID, 1)
			
		else
		
			XGUIEng.DisableButton(CurrentWidgetID, 0)
			
		end
							
	end
	
end

