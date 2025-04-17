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
	local PID = Logic.EntityGetPlayer(EntityID)
	local Range = round(GetEntityTypeMaxAttackRange(EntityID,PID))
	local pos = GetPosition(EntityID)
	local num,towerID = Logic.GetPlayerEntitiesInArea(PID, Entities.PB_Archers_Tower, pos.X, pos.Y, 600, 1)
	local bonus

	if gvArchers_Tower.SlotData[towerID]
	and (gvArchers_Tower.SlotData[towerID][1] == EntityID or gvArchers_Tower.SlotData[towerID][2] == EntityID) then
		bonus = gvArchers_Tower.MaxRangeBonus
	end

	XGUIEng.SetText( CurrentWidgetID," @ra "..Range + (bonus or 0))

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
	local PID = Logic.EntityGetPlayer(EntityID)
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
	local XP = math.min(CEntity.GetLeaderExperience(EntityID), 1000)
	local LVL = 0

	for i = 0, table.getn(BS.ExperienceLevels) do
		if XP >= BS.ExperienceLevels[i] then
			LVL = i
		else
			break
		end
	end

	XGUIEng.SetText( CurrentWidgetID, " @ra "..XP .." (LVL ".. LVL ..")")

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
											[80] = {r = 50, g = 205, b = 50},
											[100] = {r = 0, g = 255, b = 0}
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
	if procent == 100 then
		col = BS.Faith.colorsteps[procent]
	else
		for k,v in pairs(BS.Faith.colorsteps) do
			if procent >= k and procent < k + 20 then
				col = v
				break
			end
		end
	end
	XGUIEng.SetText( CurrentWidgetID, "@color:"..col.r..","..col.g..","..col.b.." "..(procent or 0).." @color:"..BS.Faith.defaultcol.r..","..BS.Faith.defaultcol.g..","..BS.Faith.defaultcol.b.." % ")
end

function GUIUpdate_LightningRod()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local BuildingID = GUI.GetSelectedEntity()
	local PlayerID = Logic.EntityGetPlayer(BuildingID)
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

--cooldown handling levy taxes
gvLastTimeButtonPressed = gvLastTimeButtonPressed or -240000
function GUIUpdate_LevyTaxes()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local BuildingID = GUI.GetSelectedEntity()
	local PlayerID = Logic.EntityGetPlayer(BuildingID)
	local TimePassed = math.floor((Logic.GetTimeMs() - gvLastTimeButtonPressed)/2400)
	local RechargeTime = 100
	local button = GetRechargeWidgetByButtonAndEntityType("LevyTaxes", Logic.GetEntityType(BuildingID))

	if 	Logic.GetTechnologyState(PlayerID, Technologies.GT_Taxation) ~= 4 then
		XGUIEng.DisableButton(CurrentWidgetID, 1)
		XGUIEng.HighLightButton(CurrentWidgetID, 0)
		XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(button), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)
	else

		if TimePassed < RechargeTime then
			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(button), 1, BS.DefaultColorValues.RechargeButton.r, BS.DefaultColorValues.RechargeButton.g, BS.DefaultColorValues.RechargeButton.b, BS.DefaultColorValues.RechargeButton.a)
			XGUIEng.HighLightButton(CurrentWidgetID, 0)
			XGUIEng.DisableButton(CurrentWidgetID, 1)
		else

			XGUIEng.SetMaterialColor(XGUIEng.GetWidgetID(button), 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)
			XGUIEng.DisableButton(CurrentWidgetID, 0)
		end
	end

	XGUIEng.SetProgressBarValues(XGUIEng.GetWidgetID(button), TimePassed, RechargeTime)

end

function GUIUpdate_OvertimesButtons()

	local BuildingID = GUI.GetSelectedEntity()
	local RemainingOvertimeTimeInPercent = Logic.GetOvertimeRechargeTimeAtBuilding(BuildingID)
	local ProgressBarWidget = XGUIEng.GetWidgetID( "OvertimesButton_Recharge" )

	if Logic.IsOvertimeActiveAtBuilding(BuildingID) == 1 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.QuitOvertimes, 1)
		XGUIEng.ShowWidget(gvGUI_WidgetID.ActivateOvertimes, 0)
		XGUIEng.SetMaterialColor(ProgressBarWidget, 1, BS.DefaultColorValues.Space.r, BS.DefaultColorValues.Space.g, BS.DefaultColorValues.Space.b, BS.DefaultColorValues.Space.a)
	else

		if Logic.GetTechnologyState(GUI.GetPlayerID(), Technologies.GT_Laws) == 4 then
			XGUIEng.DisableButton(XGUIEng.GetCurrentWidgetID(), 0)
			XGUIEng.ShowWidget(gvGUI_WidgetID.QuitOvertimes, 0)
			XGUIEng.ShowWidget(gvGUI_WidgetID.ActivateOvertimes, 1)
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
	TimePassed = math.floor(Logic.GetTime() - (gvLighthouse.starttime[PID] or 0))

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

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local BuildingID = GUI.GetSelectedEntity()
	local PlayerID = Logic.EntityGetPlayer(BuildingID)
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
BS.MintValues = {WorkersNeeded = 3, BonusPerMint = 0.02, MaxBonus = 0.2}
BS.MintValues.MaxTotalFactor = 1 + BS.MintValues.MaxBonus
BS.MintValues.MaxNumberOfMints = math.ceil(BS.MintValues.MaxBonus / BS.MintValues.BonusPerMint)
BS.MintValues.BonusInPercent = BS.MintValues.BonusPerMint * 100
function GUIUpdate_SumOfTaxes()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local PlayerID = GUI.GetPlayerID()
	if PlayerID == BS.SpectatorPID then
		if GUI.GetSelectedEntity() ~= nil and GUI.GetSelectedEntity() ~= 0 then
			PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
		end
	end
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
	if PlayerID == BS.SpectatorPID then
		if GUI.GetSelectedEntity() ~= nil and GUI.GetSelectedEntity() ~= 0 then
			PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
		end
	end
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
	if PlayerID == BS.SpectatorPID then
		if GUI.GetSelectedEntity() ~= nil and GUI.GetSelectedEntity() ~= 0 then
			PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
		end
	end
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
		if GUI.GetSelectedEntity() ~= nil and GUI.GetSelectedEntity() ~= 0 then
			PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
		end
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
	local Text1, Text2, Text3, Text4
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text1 = "aktueller Bonus"
		Text2 = "erhöhter Zahltag"
		Text3 = "zusätzliche Taler/Zahltag"
		Text4 = "erhöhter Sold/Zahltag"
	else
		Text1 = "current bonus"
		Text2 = "increased payday"
		Text3 = "additional thalers/payday"
		Text4 = "increased pay/payday"
	end
	local String = "@color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b..","..BS.DefaultColorValues.White.a.." " .. Text1 .. ": @color:"..BS.DefaultColorValues.BrightGreen.r..","..BS.DefaultColorValues.BrightGreen.g..","..BS.DefaultColorValues.BrightGreen.b..","..BS.DefaultColorValues.BrightGreen.a.." " .. NumOfMints*BS.MintValues.BonusInPercent .. " % @color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b..","..BS.DefaultColorValues.White.a.." " .. Text2 .. " @cr @cr " .. Text3 .. ": @color:100,230,100,255 " ..TaxIncome.. " @cr @color:"..BS.DefaultColorValues.White.r..","..BS.DefaultColorValues.White.g..","..BS.DefaultColorValues.White.b..","..BS.DefaultColorValues.White.a.." " .. Text4 .. ": @color:210,20,20,255 "..LeaderCosts
	XGUIEng.SetText(CurrentWidgetID, String)

end

function GUIUpdate_Hero6Ability(_Ability)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local ProgressBarWidget = gvHero6.GetRechargeButtonByAbilityName(_Ability)
	local HeroID = GUI.GetSelectedEntity()
	local TimePassed = math.floor(Logic.GetTime()- gvHero6.LastTimeUsed[_Ability])
	local cooldown = gvHero6.Cooldown[_Ability]

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
function GUIUpdate_Hero9Ability(_Ability)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local ProgressBarWidget = gvHero9.GetRechargeButtonByAbilityName(_Ability)
	local HeroID = GUI.GetSelectedEntity()
	local TimePassed = math.floor(Logic.GetTime()- gvHero9.LastTimeUsed[_Ability])
	local cooldown = gvHero9.Cooldown[_Ability]

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
function GUIUpdate_Hero13Ability(_Ability)

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
	if PlayerID == BS.SpectatorPID then
		PlayerID = Logic.EntityGetPlayer(HeroID)
	end
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
				for i = 1,4 do
					XGUIEng.SetMaterialTexture("Archers_Tower_Slot".._slot, i-1, gvArchers_Tower.GetIcon_ByEntityCategory(gvArchers_Tower.SlotData[EntityID][_slot]))
				end
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
-------------------------------------------------------------------------------------------------
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
function GUIUpdate_TroopOffer(_SlotIndex)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local AmountOfOffers = Logic.GetNumerOfMerchantOffers(SelectedTroopMerchantID)
	local LeaderType, Amount = Logic.GetMercenaryOffer(SelectedTroopMerchantID,_SlotIndex, InterfaceGlobals.CostTable)
    local SourceButton

	if LeaderType == Entities.CU_VeteranLieutenant then
		SourceButton = "BuyLeaderElite"
	elseif LeaderType == Entities.CU_BanditLeaderBow1 then
		SourceButton = "BuyLeaderBanditBow"
	elseif LeaderType == Entities.CU_BanditLeaderSword1 or LeaderType == Entities.CU_BanditLeaderSword2 then
		SourceButton = "BuyLeaderBanditSword"
	elseif LeaderType == Entities.CU_Barbarian_LeaderClub1 or LeaderType == Entities.CU_Barbarian_LeaderClub2 then
		SourceButton = "BuyLeaderBarbarian"
	elseif LeaderType == Entities.CU_BlackKnight_LeaderMace1 or LeaderType == Entities.CU_BlackKnight_LeaderMace2 then
		SourceButton = "BuyLeaderBlackKnight"
	elseif LeaderType == Entities.CU_BlackKnight_LeaderSword3 then
		SourceButton = "BuyLeaderBlackSword"
	elseif LeaderType == Entities.CU_Evil_LeaderBearman1 then
		SourceButton = "BuyLeaderEvilBear"
	elseif LeaderType == Entities.CU_Evil_LeaderSkirmisher1 then
		SourceButton = "BuyLeaderEvilSkir"
	elseif LeaderType == Entities.PV_Catapult then
		SourceButton = "Buy_Catapult"
	elseif Logic.IsEntityTypeInCategory(LeaderType,EntityCategories.Bow) == 1 then
		SourceButton = "Buy_LeaderBow1"
	elseif Logic.IsEntityTypeInCategory(LeaderType,EntityCategories.Spear)== 1 then
		SourceButton = "Buy_LeaderSpear1"
	elseif Logic.IsEntityTypeInCategory(LeaderType,EntityCategories.Sword)== 1 then
		SourceButton = "Buy_LeaderSword1"
	elseif Logic.IsEntityTypeInCategory(LeaderType,EntityCategories.CavalryHeavy)== 1 then
		SourceButton = "Buy_LeaderCavalryHeavy1"
	elseif Logic.IsEntityTypeInCategory(LeaderType,EntityCategories.CavalryLight) == 1 then
		SourceButton = "Buy_LeaderCavalryLight1"
	elseif Logic.IsEntityTypeInCategory(LeaderType,EntityCategories.Rifle) == 1 then
		SourceButton = "Buy_LeaderRifle1"
	elseif LeaderType == Entities.PV_Cannon1 then
		SourceButton = "Buy_Cannon1"
	elseif LeaderType == Entities.PV_Cannon2 then
		SourceButton = "Buy_Cannon2"
	elseif LeaderType == Entities.PV_Cannon3 then
		SourceButton = "Buy_Cannon3"
	elseif LeaderType == Entities.PV_Cannon4 then
		SourceButton = "Buy_Cannon4"
	elseif LeaderType == Entities.PV_Cannon5 then
		SourceButton = "Buy_Cannon5"
	elseif LeaderType == Entities.PV_Cannon6 or LeaderType == Entities.PV_Cannon6_2	then
		SourceButton = "Buy_Cannon6"
	elseif LeaderType == Entities.PU_Serf then
		SourceButton = "Buy_Serf"
	elseif LeaderType == Entities.PU_Thief then
		SourceButton = "Buy_Thief"
	elseif LeaderType == Entities.PU_Scout then
		SourceButton = "Buy_Scout"
	else
		SourceButton = "OnlineHelpButton"
	end

	XGUIEng.TransferMaterials(SourceButton, CurrentWidgetID)

	if Amount == -1 then
		Amount = "00"
	end

	XGUIEng.SetText(gvGUI_WidgetID.TroopMerchantOfferAmount[_SlotIndex], "@ra " .. Amount)

end
function GUIUpdate_MerchantOffers(_WidgetTable)

	local PlayerID = GUI.GetPlayerID()

	if PlayerID ~= BS.SpectatorPID and Logic.IsMerchantOpened(SelectedTroopMerchantID, PlayerID) == false then
		GUI.ClearSelection()
	else
		local AmountOfOffers = Logic.GetNumerOfMerchantOffers(SelectedTroopMerchantID)

		XGUIEng.ShowAllSubWidgets(_WidgetTable[0],0)

		for i=1,AmountOfOffers,1
		do
			XGUIEng.ShowWidget(_WidgetTable[i],1)
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
function HeroWidgetUpdate_ShowHeroWidget(EntityId)

	local EntityType = Logic.GetEntityType(EntityId)

	if EntityType == Entities.PU_Hero13 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionHero,1)
		XGUIEng.DisableButton(gvGUI_WidgetID.ExpelSettler,1)
		XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SelectionHero,0)
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionHeroGeneric,1)
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionLeader,0)
		XGUIEng.ShowWidget(XGUIEng.GetWidgetID( "Selection_Hero13" ) ,1)

	elseif EntityType == Entities.PU_Hero14 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionHero,1)
		XGUIEng.DisableButton(gvGUI_WidgetID.ExpelSettler,1)
		XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SelectionHero,0)
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionHeroGeneric,1)
		XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionLeader,0)
		XGUIEng.ShowWidget(XGUIEng.GetWidgetID( "Selection_Hero14" ) ,1)

	else
		HeroWidgetUpdate_ShowHeroWidgetOrig(EntityId)

	end
end
function GUIUpdate_BuyMilitaryUnitButtons(_Button, _Technology, _BuildingType)

	local PlayerID = GUI.GetPlayerID()
	local SelectedBuildingType = Logic.GetEntityType(GUI.GetSelectedEntity())
	local TechState = Logic.GetTechnologyState(PlayerID, _Technology)
	local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(_BuildingType)
	local EntityTypes = {Logic.GetBuildingTypesInUpgradeCategory(UpgradeCategory)}
	local PositionOfSelectedEntityInTable, PositionOfNeededEntityInTable = 0, 0

	for i = 1, EntityTypes[1] do
		if EntityTypes[i+1] == SelectedBuildingType then
			PositionOfSelectedEntityInTable = i + 1
		end
		if EntityTypes[i+1] == _BuildingType then
			PositionOfNeededEntityInTable = i + 1
		end
	end
	--Unit type is interdicted
	if TechState == 0 then
		XGUIEng.DisableButton(_Button,1)

	elseif TechState == 1 then
		XGUIEng.DisableButton(_Button,1)

	elseif TechState == 2 then
		if _Technology == Technologies.MU_LeaderSword or _Technology == Technologies.MU_LeaderSpear or _Technology == Technologies.MU_LeaderBow
			or _Technology == Technologies.MU_LeaderRifle or _Technology == Technologies.MU_LeaderLightCavalry or _Technology == Technologies.MU_LeaderHeavyCavalry
			or _Technology == Technologies.MU_Scout or _Technology == Technologies.MU_Thief then
			XGUIEng.DisableButton(_Button,0)
		else
			XGUIEng.DisableButton(_Button,1)
		end

	--Technology is researched
	elseif TechState == 4 then
		XGUIEng.DisableButton(_Button,0)

	--Technology is in reserach or too far in the future
	elseif TechState == 3 or TechState == 5 then
		XGUIEng.DisableButton(_Button,1)
	end
	if PositionOfNeededEntityInTable > PositionOfSelectedEntityInTable then
		XGUIEng.DisableButton(_Button,1)
	end
	if _Button == "Buy_LeaderRifle2" and Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PB_GunsmithWorkshop2) < 1 then
		XGUIEng.DisableButton(_Button,1)
	end
end
function GUIUpdate_SettlersUpgradeButtons(_Button, _TechnologyType, _BuildingType)

	local PlayerID = GUI.GetPlayerID()
	local SelectedBuildingType = Logic.GetEntityType(GUI.GetSelectedEntity())
	local TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)
	local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(_BuildingType)
	local EntityTypes = {Logic.GetBuildingTypesInUpgradeCategory(UpgradeCategory)}
	local PositionOfSelectedEntityInTable, PositionOfNeededEntityInTable = 0, 0

	for i = 1, EntityTypes[1] do
		if EntityTypes[i+1] == SelectedBuildingType then
			PositionOfSelectedEntityInTable = i + 1
		end
		if EntityTypes[i+1] == _BuildingType then
			PositionOfNeededEntityInTable = i + 1
		end
	end
	--Upgrade is interdicted
	if TechState == 0 then
		XGUIEng.ShowWidget(_Button,0)

	--Upgrade is enabled and visible
	elseif TechState == 2 or TechState == 3 then
		XGUIEng.ShowWidget(_Button,1)
		XGUIEng.DisableButton(_Button,0)

	--Upgrade is already researched
	elseif TechState == 4 then
		XGUIEng.ShowWidget(_Button,0)

	--Upgrade is too far in the future
	elseif TechState == 1 or TechState == 5 then
		XGUIEng.ShowWidget(_Button,1)
		XGUIEng.DisableButton(_Button,1)
	end
	if PositionOfNeededEntityInTable > PositionOfSelectedEntityInTable then
		XGUIEng.ShowWidget(_Button,1)
		XGUIEng.DisableButton(_Button,1)
	end
end
UpgradeTechByEtype = {	[Entities.PU_LeaderBow1] = Technologies.T_UpgradeBow1,
						[Entities.PU_LeaderBow2] = Technologies.T_UpgradeBow2,
						[Entities.PU_LeaderBow3] = Technologies.T_UpgradeBow3,
						[Entities.PU_LeaderRifle1] = Technologies.T_UpgradeRifle1,
						[Entities.PU_LeaderSword1] = Technologies.T_UpgradeSword1,
						[Entities.PU_LeaderSword2] = Technologies.T_UpgradeSword2,
						[Entities.PU_LeaderSword3] = Technologies.T_UpgradeSword3,
						[Entities.PU_LeaderPoleArm1] = Technologies.T_UpgradeSpear1,
						[Entities.PU_LeaderPoleArm2] = Technologies.T_UpgradeSpear2,
						[Entities.PU_LeaderPoleArm3] = Technologies.T_UpgradeSpear3,
						[Entities.PU_LeaderCavalry1] = Technologies.T_UpgradeLightCavalry1,
						[Entities.PU_LeaderHeavyCavalry1] = Technologies.T_UpgradeHeavyCavalry1
					}
UpgradeBuildingLVLByEtype = {[Entities.PU_LeaderBow1] = 1,
							[Entities.PU_LeaderBow2] = 2,
							[Entities.PU_LeaderBow3] = 2,
							[Entities.PU_LeaderRifle1] = 2,
							[Entities.PU_LeaderSword1] = 1,
							[Entities.PU_LeaderSword2] = 2,
							[Entities.PU_LeaderSword3] = 2,
							[Entities.PU_LeaderPoleArm1] = 1,
							[Entities.PU_LeaderPoleArm2] = 2,
							[Entities.PU_LeaderPoleArm3] = 2,
							[Entities.PU_LeaderCavalry1] = 2,
							[Entities.PU_LeaderHeavyCavalry1] = 2
}

function GUIUpdate_UpgradeLeader(_LeaderID)
	local button = XGUIEng.GetCurrentWidgetID()
	local player = GUI.GetPlayerID()
	local entities = {GUI.GetSelectedEntities()}
	if not entities[2] then
		local etype = Logic.GetEntityType(_LeaderID)
		local tech = UpgradeTechByEtype[etype]
		if not tech then
			XGUIEng.DisableButton(button, 1)
			XGUIEng.ShowWidget(button, 0)
			return
		end
		local techstate = Logic.GetTechnologyState(player, tech)
		if techstate == 4 then
			XGUIEng.ShowWidget(button, 1)
			local barracks = Logic.LeaderGetNearbyBarracks(_LeaderID)
			if barracks ~= 0 and Logic.IsConstructionComplete(barracks) == 1 then
				local typename = Logic.GetEntityTypeName(Logic.GetEntityType(barracks))
				if tonumber(string.sub(typename, string.len(typename))) >= UpgradeBuildingLVLByEtype[etype] then
					XGUIEng.DisableButton(button, 0)
				else
					XGUIEng.DisableButton(button, 1)
				end
			else
				XGUIEng.DisableButton(button, 1)
			end
		else
			XGUIEng.ShowWidget(button, 0)
			XGUIEng.DisableButton(button, 1)
		end
	else
		for i = 1, table.getn(entities) do
			local id = entities[i]
			local etype = Logic.GetEntityType(id)
			local tech = UpgradeTechByEtype[etype]
			if tech then
				local techstate = Logic.GetTechnologyState(player, tech)
				if techstate == 4 then
					local barracks = Logic.LeaderGetNearbyBarracks(id)
					if barracks ~= 0 and Logic.IsConstructionComplete(barracks) == 1 then
						local typename = Logic.GetEntityTypeName(Logic.GetEntityType(barracks))
						if tonumber(string.sub(typename, string.len(typename))) >= UpgradeBuildingLVLByEtype[etype] then
							XGUIEng.ShowWidget(button, 1)
							XGUIEng.DisableButton(button, 0)
							return
						end
					end
				end
			end
		end
		XGUIEng.DisableButton(button, 1)
	end
end

GUIUpdate_FindView = function()

	local PlayerID = GUI.GetPlayerID()
	if PlayerID == BS.SpectatorPID and GUI.GetSelectedEntity() then
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end
	-- Serfs
	local SerfAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Serf)
	if SerfAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindIdleSerf, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindIdleSerf, 0)
	end
	-- Swordsmen
	local PlayerSwordmenAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderSword1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderSword2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderSword3)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderSword4)
	if PlayerSwordmenAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindSwordLeader, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindSwordLeader, 0)
	end
	-- Spearmen
	local PlayerSpearmenAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderPoleArm1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderPoleArm2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderPoleArm3)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderPoleArm4)
	if PlayerSpearmenAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindSpearLeader, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindSpearLeader, 0)
	end
	-- Bowmen
	local PlayerBowmenAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderBow1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderBow2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderBow3)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderBow4)
	if PlayerBowmenAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindBowLeader, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindBowLeader, 0)
	end
	-- light Cavalry
	local PlayerCavalryAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderCavalry1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderCavalry2)
	if PlayerCavalryAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindLightCavalryLeader, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindLightCavalryLeader, 0)
	end
	-- heavy Cavalry
	local PlayerHeavyCavalryAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderHeavyCavalry1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderHeavyCavalry2)
	if PlayerHeavyCavalryAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindHeavyCavalryLeader, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindHeavyCavalryLeader, 0)
	end
	-- cannon
	local CannonAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon3)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon4)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon5)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon6)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Cannon6_2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PV_Catapult)
	if CannonAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindCannon, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindCannon, 0)
	end
	-- riflemen
	local PlayerRifleAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderRifle1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderRifle2)
	if PlayerRifleAmount > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindRifleLeader, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindRifleLeader, 0)
	end
	-- Scout
	local Scout = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Scout)
	if Scout > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindScout, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindScout, 0)
	end
	-- Thief
	local Thief = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Thief)
	if Thief > 0 then
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindThief, 1)
	else
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindThief, 0)
	end
	-- Mercenary
	local PlayerMercAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_BlackKnight_LeaderMace1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_BlackKnight_LeaderMace2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_BlackKnight_LeaderSword3)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_BanditLeaderSword1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_BanditLeaderSword2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_Barbarian_LeaderClub1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_Barbarian_LeaderClub2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_BanditLeaderBow1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_VeteranLieutenant)
	if PlayerMercAmount > 0 then
		XGUIEng.ShowWidget("FindMercenary", 1)
	else
		XGUIEng.ShowWidget("FindMercenary", 0)
	end
	-- Bearmen
	local PlayerBearmenAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_Evil_LeaderBearman1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.CU_Evil_LeaderSkirmisher1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Hero14_Bearman1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Hero14_Bearman2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Hero14_BearmanElite)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Hero14_Skirmisher1)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Hero14_Skirmisher2)
		+ Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Hero14_SkirmisherElite)
	if PlayerBearmenAmount > 0 then
		XGUIEng.ShowWidget("FindBearman", 1)
	else
		XGUIEng.ShowWidget("FindBearman", 0)
	end
	-- Ulan
	local PlayerUlanAmount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_LeaderUlan1)
	if PlayerUlanAmount > 0 then
		XGUIEng.ShowWidget("FindUlan", 1)
	else
		XGUIEng.ShowWidget("FindUlan", 0)
	end

end
function GUIUpdate_DisplayButtonOnlyInMode(_ModeFlag)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()

	--_ModeFlag 0 = SP
	--_ModeFlag 1 = MP
	--_ModeFlag 2 = Campaign (used for tipps button)

	if _ModeFlag == 2 then
		local NameType = {Framework.GetCurrentMapTypeAndCampaignName()}
		local Type = NameType[1]

		if Type == -1 then
			if Logic.PlayerGetGameState(GUI.GetPlayerID()) == 3
			or Logic.PlayerGetGameState(GUI.GetPlayerID()) == 2 then

				XGUIEng.DisableButton(CurrentWidgetID, 0)
			else
				XGUIEng.DisableButton(CurrentWidgetID, 1)
			end
		end
		return
	end

	if CNetwork then
		if CurrentWidgetID ~= XGUIEng.GetWidgetID("MainMenuWindow_RestartGame")
		or CurrentWidgetID ~= XGUIEng.GetWidgetID("GameEndScreen_WindowRestartGame") then
			XGUIEng.DisableButton(CurrentWidgetID, 1)
		else
			if Logic.PlayerGetGameState(GUI.GetPlayerID()) ~= 3 then
				XGUIEng.DisableButton(CurrentWidgetID, 0)
			else
				XGUIEng.DisableButton(CurrentWidgetID, 1)
			end
		end
	else
		if Logic.PlayerGetGameState(GUI.GetPlayerID()) ~= 3 then
			XGUIEng.DisableButton(CurrentWidgetID ,0)
		else
			XGUIEng.DisableButton(CurrentWidgetID, 1)
		end
	end

end

function GUIUpdate_TaxesButtons()

	local PlayerID = GUI.GetPlayerID()
	local TaxLevel = Logic.GetTaxLevel(PlayerID)

	XGUIEng.UnHighLightGroup(gvGUI_WidgetID.InGame, "taxesgroup")
	XGUIEng.HighLightButton(gvGUI_WidgetID.TaxesButtons[TaxLevel] ,1)
	XGUIEng.HighLightButton(gvGUI_WidgetID.TaxesButtonsOP[TaxLevel] ,1)

end

function GUIUpdate_CoalUsage()

	local PlayerID = GUI.GetPlayerID()
	local type = Logic.GetEntityType(GUI.GetSelectedEntity())
	if PlayerID == BS.SpectatorPID then
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end
	if gvCoal.Usage[PlayerID][type] == true then
		XGUIEng.ShowWidget("Activate_CoalUsage", 0)
		XGUIEng.ShowWidget("Deactivate_CoalUsage", 1)
	else
		XGUIEng.ShowWidget("Activate_CoalUsage", 1)
		XGUIEng.ShowWidget("Deactivate_CoalUsage", 0)
	end
end

function GUIUpdate_CoalMineAmount()

	local id = GUI.GetSelectedEntity()
	local amount = gvCoal.Mine.AmountMined[id] or 0
	local pretext = gvCoal.Mine.TooltipText[string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName())]
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), pretext .. amount)
end
function GUIUpdate_CoalMakerCoalAmount()

	local id = GUI.GetSelectedEntity()
	local amount = gvCoal.Coalmaker.CoalEarned[id] or 0
	local pretext = gvCoal.Coalmaker.TooltipText.Coal[string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName())]
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), pretext .. amount)
end

function GUIUpdate_CoalMakerWoodAmount()

	local id = GUI.GetSelectedEntity()
	local amount = gvCoal.Coalmaker.WoodBurned[id] or 0
	local pretext = gvCoal.Coalmaker.TooltipText.Wood[string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName())]
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), pretext .. amount)
end
function GUIUpdate_WoodcutterAmount()

	local id = WCutter.GetWorkerIDByBuildingID(GUI.GetSelectedEntity())
	local amount = WCutter.WoodEarned[id] or 0
	local pretext = WCutter.TooltipText[string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName())]
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), pretext .. amount)
end