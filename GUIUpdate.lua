BS.SpectatorPID = 17
BS.DefaultColorValues = {RechargeButton = {r = 214, g = 44, b = 24, a = 189},
						White = {r = 255, g = 255, b = 255, a = 255},
						Red = {r = 255, g = 0, b = 0, a = 255},
						BrightRed = {r = 255, g = 100, b = 100, a = 255},
						BrightGreen = {r = 100, g = 255, b = 100, a = 255},
						Space = {r = 0, g = 0, b = 0, a = 0},
						GrayedOut = {r = 210, g = 210, b = 210, a = 210}
						}
function GUIUpdate_AttackRange()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()		
	local EntityID = GUI.GetSelectedEntity()	
	local PID = GUI.GetPlayerID()	
	local Range = round(GetEntityTypeMaxAttackRange(EntityID,PID))	
	local pos = GetPosition(EntityID)	
	local num,towerID = Logic.GetPlayerEntitiesInArea(PID, Entities.PB_Archers_Tower, pos.X, pos.Y, 600, 1)	
	local factor
	
	if gvArchers_Tower.SlotData[towerID] then	
		factor = gvArchers_Tower.MaxRangeFactor		
	end
	
	XGUIEng.SetText( CurrentWidgetID," @ra "..Range * (factor or 1))	
	
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
	local BaseSpeed = 1000/GetEntityTypeBaseAttackSpeed(EntityType)	
	-- Angriffe pro Sek.
	local SpeedAsString = string.format("%.3f",BaseSpeed)	
	XGUIEng.SetText( CurrentWidgetID, " @ra "..SpeedAsString )		
	
end

function GUIUpdate_MoveSpeed()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()		
	local EntityID = GUI.GetSelectedEntity()	
	local PID = GUI.GetPlayerID()	
	local Speed = round(GetSettlerCurrentMovementSpeed(EntityID,PID))			
	XGUIEng.SetText( CurrentWidgetID, " @ra "..Speed)	
	
end

BS.ExperienceLevels = {	[0] = 0,
						[1] = 184,
						[2] = 328,
						[3] = 470,
						[4] = 629,
						[5] = 846
						}
						
function GUIUpdate_Experience()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()		
	local EntityID = GUI.GetSelectedEntity()	
	local PID = GUI.GetPlayerID()	
	local XP = math.min(CEntity.GetLeaderExperience(EntityID), 1000)	
	local LVL
	
	for k,v in pairs(BS.ExperienceLevels) do
		if XP >= v then		
			LVL = k
			break
		end
	end
			
	XGUIEng.SetText( CurrentWidgetID, " @ra ".. XP .." (LVL ".. LVL ..")")	
	
end

BS.Time = {DefaultValues = {secondsperday = 1440, daytimebegin = 8, tutorialoffset = 34}, calculation = {dayinsec = 60*60*24, hourinminutes = 60*60}, IngameTimeSec = 0}
function GUIUpdate_Time()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()		
	--Spielzeit in sec
	local secondsperday = gvDayTimeSeconds or BS.Time.DefaultValues.secondsperday	
	local daytimefactor = secondsperday/BS.Time.calculation.dayinsec	
	local GameTime = Logic.GetTime() - (gvDayCycleStartTime or 0)
	
	if gvTutorialFlag ~= nil then	
		GameTime = BS.Time.IngameTimeSec - BS.Time.DefaultValues.tutorialoffset		
	end
	
	local TimeMinutes = math.floor(GameTime/(BS.Time.calculation.hourinminutes*daytimefactor))	
	--Tag startet um 8 Uhr morgens	
	local TimeHours = BS.Time.DefaultValues.daytimebegin			
	local TimeMinutesText = ""	
	local TimeHoursText = ""	
	while TimeMinutes > 59 do 
	
		TimeMinutes = TimeMinutes-60		
		TimeHours = TimeHours + 1
		
	end
	
	while TimeHours > 23 do
	
		local TimeDif = TimeHours - 24
		
		if TimeDif ~= 0 then			
			TimeHours = 0 + TimeDif				
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
	
	if PlayerID == BS.SpectatorPID then	
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())		
	end
	
	local Amount = round(Logic.GetPlayersGlobalResource( PlayerID, _ResourceType ))		
	local RawResourceType = Logic.GetRawResourceType( _ResourceType )	
	local RawResourceAmount = round(Logic.GetPlayersGlobalResource( PlayerID, RawResourceType ))	
	local String = " "	
	--local procent = math.floor((Amount/(Amount + RawResourceAmount))*100)
	XGUIEng.SetText( CurrentWidgetID, "@color:"..BS.DefaultColorValues.Red.r..","..BS.DefaultColorValues.Red.g..","..BS.DefaultColorValues.Red.b.." "..RawResourceAmount.." @color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b.." / @color:10,170,160 "..Amount.." ")	
	
end
BS.Faith = {MaxValue = 5000, colorsteps = {	[0] = {r = 255, g = 0, b = 0},
											[20] = {r = 255, g = 165, b = 0},
											[40] = {r = 255, g = 255, b = 0},
											[60] = {r = 153, g = 225, b = 47},
											[80] = {r = 50, g = 205, b = 50}
											},
							defaultcol = {r = 255, g = 255, b = 255}
			}
function GUIUpdate_SpecialResourceAmount(_ResourceType)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local PlayerID = GUI.GetPlayerID()
	
	if PlayerID == BS.SpectatorPID then	
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())		
	end	
	
	local Amount = Logic.GetPlayersGlobalResource(PlayerID,_ResourceType)		
	local WeatherEnergyMax = Logic.GetEnergyRequiredForWeatherChange()	
	local FaithMax = BS.Faith.MaxValue	
	local procent, maxvalue
	
	if _ResourceType == ResourceType.Faith then	
		maxvalue = FaithMax		
	else	
		maxvalue = WeatherEnergyMax				
	end
	
	procent = math.min(math.floor((Amount/maxvalue)*100), 100)
	
	for k,v in pairs(BS.Faith.colorsteps) do
		if procent >= k then		
			XGUIEng.SetText( CurrentWidgetID, "@color:"..v.r..","..v.g..","..v.b.." "..(procent or 0).." @color:"..BS.Faith.defaultcol.r..","..BS.Faith.defaultcol.g..","..BS.Faith.defaultcol.b.." % ")				
			break
		end
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
		XGUIEng.SetMaterialColor(CurrentWidgetID,1,BS.DefaultColorValues.GrayedOut.r,BS.DefaultColorValues.GrayedOut.g,BS.DefaultColorValues.GrayedOut.b,BS.DefaultColorValues.GrayedOut.a)		
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"),1,BS.DefaultColorValues.GrayedOut.r,BS.DefaultColorValues.GrayedOut.g,BS.DefaultColorValues.GrayedOut.b,BS.DefaultColorValues.GrayedOut.a)	
	else
		
		if TimePassed >= RechargeTime then			
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"),1,BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
			XGUIEng.DisableButton(CurrentWidgetID,0)	
		else 		
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lightning_Rod_Recharge"), 1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)			
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
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Levy_Duties_Recharge"), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)		
	else

		if TimePassed < RechargeTime then	
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Levy_Duties_Recharge"), 1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)		
			XGUIEng.HighLightButton(CurrentWidgetID,0)				
			XGUIEng.DisableButton(CurrentWidgetID,1)			
		else
		
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Levy_Duties_Recharge"), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
			XGUIEng.DisableButton(CurrentWidgetID,0)			
		end			
	end
	
	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID("Levy_Duties_Recharge"),TimePassed, RechargeTime)
	
end

function GUIUpdate_OvertimesButtons()
	
	local BuildingID = GUI.GetSelectedEntity()	
	local RemainingOvertimeTimeInPercent = Logic.GetOvertimeRechargeTimeAtBuilding(BuildingID)	
	local ProgressBarWidget = XGUIEng.GetWidgetID( "OvertimesButton_Recharge" );

	if Logic.IsOvertimeActiveAtBuilding(BuildingID) == 1 then	
		XGUIEng.ShowWidget(gvGUI_WidgetID.QuitOvertimes, 1)			
		XGUIEng.ShowWidget(gvGUI_WidgetID.ActivateOvertimes, 0)			
		XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
	else
	
		if Logic.GetTechnologyState(GUI.GetPlayerID(),Technologies.GT_Laws) == 4 then		
			XGUIEng.DisableButton(XGUIEng.GetCurrentWidgetID(),0)		
			XGUIEng.ShowWidget(gvGUI_WidgetID.QuitOvertimes  ,0)				
			XGUIEng.ShowWidget(gvGUI_WidgetID.ActivateOvertimes  ,1)				
			XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)		
			
			if RemainingOvertimeTimeInPercent == 0 then			
				XGUIEng.DisableButton(gvGUI_WidgetID.ActivateOvertimes, 0)				
			else			
				XGUIEng.DisableButton(gvGUI_WidgetID.ActivateOvertimes, 1)				
			end
		
		else		
			XGUIEng.DisableButton(XGUIEng.GetCurrentWidgetID(),1)		
		end				
	end

	XGUIEng.SetProgressBarValues(ProgressBarWidget, RemainingOvertimeTimeInPercent, 100)
	
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
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lighthouse_Recharge"), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)		
	else
	
		if TimePassed < RechargeTime then		
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lighthouse_Recharge"),1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)			
			XGUIEng.HighLightButton(CurrentWidgetID,0)				
			XGUIEng.DisableButton(CurrentWidgetID,1)			
		else
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID("Lighthouse_Recharge"), BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
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
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)
	else
	
		if TimePassed < RechargeTime then		
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]), 1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)			
			XGUIEng.HighLightButton(CurrentWidgetID,0)				
			XGUIEng.DisableButton(CurrentWidgetID,1)			
		else		
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
			XGUIEng.DisableButton(CurrentWidgetID,0)			
		end		
	end
		
	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID(gvMercenaryTower.RechargeButton[_button]),TimePassed, RechargeTime)
	
end
BS.MintValues = {WorkersNeeded = 3, BonusPerMint = 0.015, MaxBonus = 0.15}
BS.MintValues.MaxTotalFactor = 1 + BS.MintValues.MaxBonus
BS.MintValues.MaxNumberOfMints = math.ceil(BS.MintValues.MaxBonus / BS.MintValues.BonusPerMint)
BS.MintValues.BonusInPercent = BS.MintValues.BonusPerMint * 100
function GUIUpdate_SumOfTaxes()
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local PlayerID = GUI.GetPlayerID()
	local GrossPayday = Logic.GetPlayerPaydayCost(PlayerID)		
	local factor = 1	
	local workers 
	
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then	
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}		
			if workers[1] >= BS.MintValues.WorkersNeeded then			
				factor = factor + BS.MintValues.BonusPerMint							
			end
		end		
	end
	
	factor = math.min(factor, BS.MintValues.MaxTotalFactor)		
	
	if gvPresent and PlayerID ~= BS.SpectatorPID then	
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]		
	end
	
	local TotalPayday = math.floor(GrossPayday * factor)	
	XGUIEng.SetTextByValue( CurrentWidgetID, TotalPayday, 1 )
	
end

function GUIUpdate_TaxPaydayIncome()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local PlayerID = GUI.GetPlayerID()
	
	if PlayerID == BS.SpectatorPID then	
		if GUI.GetSelectedEntity() ~= nil and GUI.GetSelectedEntity() ~= 0 then		
			PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())			
		end
	end
	
	local GrossPayday = Logic.GetPlayerPaydayCost(PlayerID)	
	local LeaderCosts = Logic.GetPlayerPaydayLeaderCosts(PlayerID)		
	local TaxesPlayerWillGet = GrossPayday - LeaderCosts	
	local factor = 1	
	local workers 
	
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID),CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then		
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}			
			if workers[1] >= BS.MintValues.WorkersNeeded then			
				factor = factor + BS.MintValues.BonusPerMint		
			end			
		end		
	end
	
	factor = math.min(factor, BS.MintValues.MaxTotalFactor)	
	
	if gvPresent and PlayerID ~= BS.SpectatorPID then		
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]		
	end
	
	local TotalPayday = math.floor(TaxesPlayerWillGet * factor)	
	local String
		
	if TaxesPlayerWillGet < 0 then	
		String = "@color:"..BS.DefaultColorValues.BrightRed.r..","..BS.DefaultColorValues.BrightRed.g..","..BS.DefaultColorValues.BrightRed.b..","..BS.DefaultColorValues.BrightRed.a.." @ra " .. TotalPayday		
	else	
		String = "@color:"..BS.DefaultColorValues.BrightGreen.r..","..BS.DefaultColorValues.BrightGreen.g..","..BS.DefaultColorValues.BrightGreen.b..","..BS.DefaultColorValues.BrightRed.a.." @ra +" .. TotalPayday		
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
			if workers[1] >= BS.MintValues.WorkersNeeded then			
				factor = factor + BS.MintValues.BonusPerMint				
			end
		end		
	end
	
	factor = math.min(factor, BS.MintValues.MaxTotalFactor)
	
	if gvPresent and PlayerID ~= BS.SpectatorPID then		
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
			if workers[1] >= BS.MintValues.WorkersNeeded then			
				factor = factor + BS.MintValues.BonusPerMint				
			end
		end		
	end
	
	factor = math.min(factor, BS.MintValues.MaxTotalFactor)
	
	if gvPresent and PlayerID ~= BS.SpectatorPID then	
		factor = factor * gvPresent.SDPaydayFactor[PlayerID]
	end
	
	local TotalCosts = math.floor(LeaderCosts * factor)	
	XGUIEng.SetText(CurrentWidgetID, TotalCosts)	
	
end

function GUIUpdate_MintTaxBonus()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local PlayerID = GUI.GetPlayerID()
	
	if PlayerID == BS.SpectatorPID then	
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())		
	end
	
	local NumOfMints = 0	
	local workers 
	
	for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(PlayerID), CEntityIterator.OfTypeFilter(Entities.CB_Mint1)) do		
		if Logic.IsConstructionComplete(eID) == 1 then		
			workers = {Logic.GetAttachedWorkersToBuilding(eID)}			
			if workers[1] >= BS.MintValues.WorkersNeeded then			
				NumOfMints = NumOfMints + 1				
			end
		end		
	end
	
	NumOfMints = math.min(NumOfMints, BS.MintValues.MaxNumberOfMints)	
	local LeaderCosts = -math.floor((Logic.GetPlayerPaydayLeaderCosts(PlayerID))*(NumOfMints*BS.MintValues.BonusPerMint))	
	local TaxIncome = math.floor((Logic.GetPlayerPaydayCost(PlayerID)*(NumOfMints*BS.MintValues.BonusPerMint)))	
	local String = "@color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b..","..BS.DefaultColorValues.White.a.." aktueller Bonus: @color:"..BS.DefaultColorValues.BrightGreen.r..","..BS.DefaultColorValues.BrightGreen.g..","..BS.DefaultColorValues.BrightGreen.b..","..BS.DefaultColorValues.BrightGreen.a.." " .. NumOfMints*BS.MintValues.BonusInPercent .. " % @color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b..","..BS.DefaultColorValues.White.a.." erhöhter Zahltag  @cr @cr zusätzliche Taler/Zahltag: @color:100,230,100,255 " ..TaxIncome.. " @cr @color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b..","..BS.DefaultColorValues.White.a.." erhöhter Sold/Zahltag: @color:210,20,20,255 "..LeaderCosts	
	XGUIEng.SetText(CurrentWidgetID, String)	
	
end

function GUIUpdate_Hero13Ability(_Ability)

	local PlayerID = GUI.GetPlayerID()	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local ProgressBarWidget = gvHero13.GetRechargeButtonByAbilityName(_Ability)	
	local HeroID = GUI.GetSelectedEntity()	
	local TimePassed = math.floor(Logic.GetTime()- gvHero13.LastTimeUsed[_Ability])	
	local cooldown = gvHero13.Cooldown[_Ability]

	if TimePassed < cooldown then		
		XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)			
		XGUIEng.HighLightButton(CurrentWidgetID,0)				
		XGUIEng.DisableButton(CurrentWidgetID,1)			
	else		
		XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
		XGUIEng.DisableButton(CurrentWidgetID,0)		
	end
	
	XGUIEng.SetProgressBarValues(ProgressBarWidget,TimePassed, cooldown)	
	
end
function GUIUpdate_Hero14Ability(_Ability)

	local PlayerID = GUI.GetPlayerID()	
	local HeroID = GUI.GetSelectedEntity()	
	local pos = GetPosition(HeroID)	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()	
	local ProgressBarWidget = gvHero14.GetRechargeButtonByAbilityName(_Ability)	
	local TimePassed = math.floor(Logic.GetTime()- gvHero14[_Ability].LastTimeUsed)	
	local cooldown = gvHero14[_Ability].Cooldown
	
	if _Ability == "RisingEvil" then
		
		if TimePassed >= cooldown and ({Logic.GetPlayerEntitiesInArea(PlayerID, Entities.PB_Tower2, pos.X, pos.Y, gvHero14.RisingEvil.Range)})[1] == 0 then		
			XGUIEng.HighLightButton(CurrentWidgetID,0)			
			XGUIEng.DisableButton(CurrentWidgetID,1)			
			XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)			
			return			
		end				
	end
		
	if TimePassed < cooldown then	
		XGUIEng.SetMaterialColor(ProgressBarWidget,1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)		
		XGUIEng.HighLightButton(CurrentWidgetID,0)			
		XGUIEng.DisableButton(CurrentWidgetID,1)		
	else	
		XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)		
		XGUIEng.DisableButton(CurrentWidgetID,0)		
	end
	
	XGUIEng.SetProgressBarValues(ProgressBarWidget,TimePassed, cooldown)
	
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
				XGUIEng.SetMaterialColor(CurrentWidgetID, 0, BS.DefaultColorValues.White.r, BS.DefaultColorValues.White.g, BS.DefaultColorValues.White.b, BS.DefaultColorValues.White.a)					
				gvGUI.DarioCounter = gvGUI.DarioCounter +1		
			end
		
			if gvGUI.DarioCounter == 100 then		
				gvGUI.DarioCounter= 0				
			end
		
		else			
			XGUIEng.SetMaterialColor(CurrentWidgetID, 0, BS.DefaultColorValues.White.r, BS.DefaultColorValues.White.g, BS.DefaultColorValues.White.b, BS.DefaultColorValues.White.a)				
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
		elseif Logic.GetEntityType(EntityID) == Entities.PU_Hero13 then		
			SourceButton = "FindHeroSource13"			
		elseif Logic.GetEntityType(EntityID) == Entities.PU_Hero14 then		
			SourceButton = "FindHeroSource14"		
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
	
	if gvArchers_Tower.CurrentlyClimbing[EntityID] then				
		XGUIEng.DisableButton(CurrentWidgetID, 1)
	else
	
		if gvArchers_Tower.CurrentlyUsedSlots[EntityID] >= gvArchers_Tower.MaxSlots or table.getn(gvArchers_Tower.SlotData[EntityID]) >= gvArchers_Tower.MaxSlots then	
			XGUIEng.DisableButton(CurrentWidgetID, 1)			
		else			
			XGUIEng.DisableButton(CurrentWidgetID, 0)			
		end		
	end	
end

function GUIUpdate_Archers_Tower_RemoveSlot(_slot)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()		
	local EntityID = GUI.GetSelectedEntity()
	
	if gvArchers_Tower.CurrentlyClimbing[EntityID] then				
		XGUIEng.DisableButton(CurrentWidgetID, 1)
	else
	
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
end
------------------------------------- Army Creator ---------------------------------------------
function GUIUpdate_ArmyCreatorPoints(_playerID)

	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), " @center "..ArmyCreator.PlayerPoints.." / "..ArmyCreator.BasePoints * (gvDiffLVL) )

end
function GUIUpdate_ArmyCreatorTroopAmount(_playerID,_entityType)
	
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), " @center "..ArmyCreator.PlayerTroops[_playerID][_entityType])
	
end
function GUIUpdate_SelectionName()
	
	local EntityId = GUI.GetSelectedEntity()	
	local EntityType = Logic.GetEntityType( EntityId )
	local EntityTypeName = Logic.GetEntityTypeName( EntityType )
	
	if EntityTypeName == nil then
		return
	end
	
	local StringKey = "names/" .. EntityTypeName		
	local String = XGUIEng.GetStringTableText( StringKey )
	if string.len(String) >= 25 then
		XGUIEng.SetTextKeyName(gvGUI_WidgetID.SelectionName, StringKey)
	else
		XGUIEng.SetText(gvGUI_WidgetID.SelectionName, "@center " .. string.gsub(String, " @bs ", "")	)
	end	
	
end
function GUIUpdate_MultiSelectionButton()
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local MotherContainer= XGUIEng.GetWidgetsMotherID(CurrentWidgetID)	
	local EntityID = XGUIEng.GetBaseWidgetUserVariable(MotherContainer, 0)			
	local SelectedHeroID = HeroSelection_GetCurrentSelectedHeroID()	
	local SourceButton
	
	if Logic.IsEntityInCategory(EntityID,EntityCategories.Hero1) == 1 then	
		SourceButton = "MultiSelectionSource_Hero1"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero2) == 1 then
		SourceButton = "MultiSelectionSource_Hero2"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero3) == 1 then
		SourceButton = "MultiSelectionSource_Hero3"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero4) == 1 then
		SourceButton = "MultiSelectionSource_Hero4"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero5) == 1 then
		SourceButton = "MultiSelectionSource_Hero5"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero6) == 1 then
		SourceButton = "MultiSelectionSource_Hero6"
	elseif Logic.GetEntityType( EntityID )	== Entities.CU_BlackKnight then
		SourceButton = "MultiSelectionSource_Hero7"
	elseif Logic.GetEntityType( EntityID )	== Entities.CU_Mary_de_Mortfichet then
		SourceButton = "MultiSelectionSource_Hero8"
	elseif Logic.GetEntityType( EntityID )	== Entities.CU_Barbarian_Hero then
		SourceButton = "MultiSelectionSource_Hero9"
	elseif Logic.GetEntityType( EntityID ) == Entities.PU_Serf then
		SourceButton = "MultiSelectionSource_Serf"	
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Sword) == 1 then
		SourceButton = "MultiSelectionSource_Sword"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Bow) == 1 then
		SourceButton = "MultiSelectionSource_Bow"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Spear) == 1 then
		SourceButton = "MultiSelectionSource_Spear"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Cannon) == 1 then
		SourceButton = "MultiSelectionSource_Cannon"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.CavalryHeavy) == 1 then
		SourceButton = "MultiSelectionSource_HeavyCav"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.CavalryLight) == 1 then
		SourceButton = "MultiSelectionSource_LightCav"	
		
	--AddOn
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Rifle) == 1 
	and Logic.IsEntityInCategory(EntityID,EntityCategories.Hero10) == 0 then
		SourceButton = "MultiSelectionSource_Rifle"	
	
	elseif Logic.GetEntityType( EntityID )	== Entities.PU_Scout then
		SourceButton = "MultiSelectionSource_Scout"			
	elseif Logic.GetEntityType( EntityID )	== Entities.PU_Thief then
		SourceButton = "MultiSelectionSource_Thief"		
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero10) == 1 then
		SourceButton = "MultiSelectionSource_Hero10"
	elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero11) == 1 then
		SourceButton = "MultiSelectionSource_Hero11"
	elseif Logic.GetEntityType( EntityID )	== Entities.CU_Evil_Queen then
		SourceButton = "MultiSelectionSource_Hero12"
	elseif Logic.GetEntityType( EntityID )	== Entities.PU_Hero13 then
		SourceButton = "MultiSelectionSource_Hero13"	
	elseif Logic.GetEntityType( EntityID )	== Entities.PU_Hero14 then
		SourceButton = "MultiSelectionSource_Hero14"		
			
	else
		SourceButton = "MultiSelectionSource_Sword"
	end
		
	XGUIEng.TransferMaterials(SourceButton, CurrentWidgetID)	
	-- set color when hero is selected
	if SelectedHeroID == EntityID then		
		for i=0, 4,1
		do
			XGUIEng.SetMaterialColor(SourceButton,i, 255,177,0,255)
		end		
	else	
		for i=0, 4,1
		do
			XGUIEng.SetMaterialColor(SourceButton,i, BS.DefaultColorValues.White.r, BS.DefaultColorValues.White.g, BS.DefaultColorValues.White.b, BS.DefaultColorValues.White.a)
		end	
	end
end
function GUIUpdate_Forester_WorkChange(_flag)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()		
	local EntityID = GUI.GetSelectedEntity()
	
	if _flag == 0 then
	
		if Forester.WorkActiveState[EntityID] == nil then
				
			XGUIEng.ShowWidget(CurrentWidgetID, 1)
		
		elseif Forester.WorkActiveState[EntityID] == 0 then
		
			XGUIEng.ShowWidget(CurrentWidgetID, 0)
			
		elseif Forester.WorkActiveState[EntityID] == 1 then
		
			XGUIEng.ShowWidget(CurrentWidgetID, 1)
		
		end
	
	elseif _flag == 1 then
	
		if Forester.WorkActiveState[EntityID] == nil then
				
			XGUIEng.ShowWidget(CurrentWidgetID, 0)
		
		elseif Forester.WorkActiveState[EntityID] == 0 then
		
			XGUIEng.ShowWidget(CurrentWidgetID, 1)
			
		elseif Forester.WorkActiveState[EntityID] == 1 then
		
			XGUIEng.ShowWidget(CurrentWidgetID, 0)
		
		end
		
	end
	
end