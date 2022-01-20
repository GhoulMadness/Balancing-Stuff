---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Drakes Headshot ----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DrakeHeadshotDamage() 

	local attacker = Event.GetEntityID1()
	
	local attackerpos = GetPosition(attacker)
	
    local target = Event.GetEntityID2();
	
	local targetpos = GetPosition(target)
	
	local attype = Logic.GetEntityType(attacker)
	
	local task = Logic.GetCurrentTaskList(attacker)
	
	local cooldown = Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilitySniper)
	
    local max = Logic.GetEntityMaxHealth(target);
	
    local dmg = CEntity.TriggerGetDamage();
	
	local attackerdmg = Logic.GetEntityDamage(attacker)
	
	if attype == Entities.PU_Hero10 and task == "TL_SNIPE_SPECIAL" then
	
		if max == dmg then 
		
			if math.abs(GetDistance(attackerpos,targetpos)) >= 800 then
			
				CEntity.TriggerSetDamage(math.floor((max * 0.36) + (attackerdmg*4.8)));
				
			else
			
				CEntity.TriggerSetDamage(math.floor((max * 0.12) + (attackerdmg*1.6)));
				
			end
			
		end;
		
	end;
	
end;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Marys/Kalas Gift ----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvPoisonDoT = {}

--Helden, die Gift benutzen (und für den DoT infrage kommen)
gvPoisonDoT.PoisonUsers = {
						
							[Entities.CU_Mary_de_Mortfichet] = true,
	
							[Entities.CU_Evil_Queen] = true
							
							}
							
gvPoisonDoT.GetNeededTaskByEntityType = function(_type)

	local task = ""
	
	if _type == Entities.CU_Mary_de_Mortfichet then
	
		task = "TL_BATTLE_POISON"
		
	elseif _type == Entities.CU_Evil_Queen then
	
		task = "TL_BATTLE_SPECIAL"
		
	else
	
		task = ""
		
		LuaDebugger.Log(_type.." verwendet keinen Gift-Effekt. Task konnte nicht bestimmt werden!")
		
	end
	
	return task
	
end
--Reichweite des Gifts
gvPoisonDoT.Range = 600

--Schaden des Gifts (Anteil der HP des Ziels pro Tick)
gvPoisonDoT.MaxHPDamagePerTick = 0.01

--maximale Anzahl der Ticks (entspricht der Dauer des Gifts *10[s])
gvPoisonDoT.MaxNumberOfTicks = 50

--aktuelle Anzahl an Ticks 
gvPoisonDoT.CurrentTick = {}

function PoisonDamageCreateDoT() 

	local attacker = Event.GetEntityID1()
	
	local attackerpos = GetPosition(attacker)
	
	local attackerPID = Logic.EntityGetPlayer(attacker)
	
	local attype = Logic.GetEntityType(attacker)
	
	local task = Logic.GetCurrentTaskList(attacker)
	
	if gvPoisonDoT.PoisonUsers[attype] then

		if gvPoisonDoT.GetNeededTaskByEntityType(attype) == task then
		
			if not _G["PoisonDoT_Job_"..attackerPID.."_"..attype.."_ID"] then
			
				_G["PoisonDoT_Job_"..attackerPID.."_"..attype.."_ID"] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "PoisonDoT_Job_"..attackerPID, 1, {}, {attackerPID,attype,attackerpos.X,attackerpos.Y})
				
			end;
			
		end;
		
	end;
	
end;

for i = 1,12 do

	_G["PoisonDoT_Job_"..i] = function(_player,_type,_posX,_posY)
	
		if not gvPoisonDoT.CurrentTick[_player] then
			
			gvPoisonDoT.CurrentTick[_player] = 0
			
		end
	
		gvPoisonDoT.CurrentTick[_player] = gvPoisonDoT.CurrentTick[_player] + 1
	
		for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerFilter(), CEntityIterator.InCircleFilter(_posX, _posY, gvPoisonDoT.Range)) do
			
			if Logic.GetDiplomacyState(_player,Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile then
			
				-- wenn Leader, dann...
				if Logic.IsLeader(eID) == 1 then
				
					local soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
					
					-- Leader wird nur verwundet, wenn keine Soldaten (mehr)
					if soldiers[1] == 0 then
					
						if GetEntityHealth(eID) <= gvPoisonDoT.MaxHPDamagePerTick and Logic.IsHero(eID) ~= 1 then
						
							Logic.DestroyGroupByLeader(eID)
							
						else
						
							Logic.HurtEntity(eID, math.ceil(Logic.GetEntityMaxHealth(eID)*gvPoisonDoT.MaxHPDamagePerTick))
							
						end
						
					end
					
				-- wenn Soldier, Arbeiter, etc., dann...
				else 
				
					Logic.HurtEntity(eID, math.ceil(Logic.GetEntityMaxHealth(eID)*gvPoisonDoT.MaxHPDamagePerTick))
					
				end
				
			end
			
		end	
		
		if gvPoisonDoT.CurrentTick[_player] >= gvPoisonDoT.MaxNumberOfTicks then
		
			gvPoisonDoT.CurrentTick[_player] = nil
			
			_G["PoisonDoT_Job_".._player.."_".._type.."_ID"] = nil
		
			return true
			
		end
	
	end
	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Trigger for Castles (global variables to be find in Castle.lua) --------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnCastleCreated()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	local posX,posY = Logic.GetEntityPosition(entityID)
	
	local pos = {X = posX, Y = posY}
	
	if entityType == Entities.PB_Castle1 or entityType == Entities.PB_Castle2 or entityType == Entities.PB_Castle3 or entityType == Entities.PB_Castle4 or entityType == Entities.PB_Castle5 then    
	
		table.insert(gvCastle.PositionTable,pos)
		
		if gvCastle.AmountOfCastles[playerID] then
		
			gvCastle.AmountOfCastles[playerID] = gvCastle.AmountOfCastles[playerID] + 1
			
		end
		
	end
	
end

function OnCastleDestroyed()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	local posX,posY = Logic.GetEntityPosition(entityID)
	
	local pos = {X = posX, Y = posY}
	
	if entityType == Entities.PB_Castle1 or entityType == Entities.PB_Castle2 or entityType == Entities.PB_Castle3 or entityType == Entities.PB_Castle4 or entityType == Entities.PB_Castle5 then    
	
		removetablekeyvalue(gvCastle.PositionTable,pos)
		
		if gvCastle.AmountOfCastles[playerID] then
		
			gvCastle.AmountOfCastles[playerID] = gvCastle.AmountOfCastles[playerID] - 1
			
		end
		
	end
	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Trigger for Towers (global variables to be find in Tower.lua) ----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnTowerCreated()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	local posX,posY = Logic.GetEntityPosition(entityID)
	
	local pos = {X = posX, Y = posY}
	
	if entityType == Entities.PB_Tower1 or entityType == Entities.PB_Tower2 or entityType == Entities.PB_Tower3 or entityType == Entities.PB_DarkTower1 or entityType == Entities.PB_DarkTower2 or entityType == Entities.PB_DarkTower3 then
	
		table.insert(gvTower.PositionTable,pos)
		
		if gvTower.AmountOfTowers[playerID] then
		
			gvTower.AmountOfTowers[playerID] = gvTower.AmountOfTowers[playerID] + 1
			
		end
		
	end
	
end

function OnTowerDestroyed()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	local posX,posY = Logic.GetEntityPosition(entityID)
	
	local pos = {X = posX, Y = posY}
	
	if entityType == Entities.PB_Tower1 or entityType == Entities.PB_Tower2 or entityType == Entities.PB_Tower3 or entityType == Entities.PB_DarkTower1 or entityType == Entities.PB_DarkTower2 or entityType == Entities.PB_DarkTower3 then   
	
		removetablekeyvalue(gvTower.PositionTable,pos)
		
		if gvTower.AmountOfTowers[playerID] then
		
			gvTower.AmountOfTowers[playerID] = gvTower.AmountOfTowers[playerID] - 1
			
		end
		
	end
	
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Set correct cooldowns when Dovbar (and future heroes?) resurrects -----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnHeroDied()

	local attacker = Event.GetEntityID1()
	
    local target = Event.GetEntityID2();
	
	local targettype = Logic.GetEntityType(target)
	
	local health = Logic.GetEntityHealth(target)
	
	local damage = CEntity.TriggerGetDamage()
	
    local playerID = GetPlayer(target)
	
	if targettype == Entities.PU_Hero13 and damage >= health then
	
		_G["Hero13_ResurrectionCheck_Player"..playerID.."_TriggerID"] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero13_ResurrectionCheck_Player"..playerID,1,{},{target})
		
	end
	
end

for i = 1,12 do

	_G["Hero13_ResurrectionCheck_Player"..i] = function(_EntityID)
	
		local playerID = Logic.EntityGetPlayer(_EntityID)
		
		if Logic.IsEntityAlive(_EntityID) then
		
			if GUI.GetPlayerID() == playerID then
			
				gvHero13.LastTimeStoneArmorUsed = Logic.GetTime()
				
				gvHero13.LastTimeDivineJudgmentUsed = Logic.GetTime()
				
				if CNetwork then
				
					if gvHero13StoneArmor_NextCooldown then
					
						if gvHero13StoneArmor_NextCooldown[playerID] then
						
							gvHero13StoneArmor_NextCooldown[playerID] = Logic.GetTimeMs() + 2.5 * 60 * 1000;
							
						end
						
					end
					
					if gvHero13DivineJudgment_NextCooldown then
					
						if gvHero13DivineJudgment_NextCooldown[playerID] then
						
							gvHero13DivineJudgment_NextCooldown[playerID] = Logic.GetTimeMs() + 1 * 60 * 1000;
							
						end
						
					end
					
				end
				
				_G["Hero13_ResurrectionCheck_Player"..playerID.."_TriggerID"] = nil
				
				return true
				
			end	
			
		end
		
	end
	
end
---------------------------------------------------------------------------------------------------------------------------
-------------------------------- Trigger for Salims trap ------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
function SalimTrapPlaced()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local eplayerID = GetPlayer(entityID)
	
	local hplayerID = GUI.GetPlayerID()
	
	if entityType == Entities.PU_Hero3_Trap then
	
		if Logic.GetDiplomacyState(eplayerID, hplayerID) ~= Diplomacy.Friendly and eplayerID ~= hplayerID then
		
			--Model ändern und Overhead-Widget ausblenden, wenn nicht verbündet (Durch Eintrag in der models.xml gehandhabt)
			Logic.SetModelAndAnimSet(entityID,Models.SalimTrapEnemy)
			
		end	
		
	end
	
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
	
	if Logic.GetCurrentPrice(PID,TSellTyp) < 0.8 then
	
		Logic.SetCurrentPrice(PID, TSellTyp, 0.8 )
		
	end
	
	if Logic.GetCurrentPrice(PID,TTyp) > 1.3 then
	
		Logic.SetCurrentPrice(PID, TTyp, 1.3 )
		
	end
	
	if Logic.GetCurrentPrice(PID,TTyp) < 0.8 then
	
		Logic.SetCurrentPrice(PID, TTyp, 0.8 )
		
	end
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------ Trigger for Special Buildings (Dome and Silversmith) --------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
function SpezEntityPlaced()

    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = Logic.EntityGetPlayer(entityID)
	
	local pos = {Logic.GetEntityPosition(entityID)}
	
    if entityType == Entities.PB_Dome then     

		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "DomePlaced", 1,{},{pos[1],pos[2]})	
		
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
				
				Stream.Start("Sounds\\VoicesMentor\\join_silversmith.wav", 292)
				
				StartCountdown(math.ceil(Stream.GetDuration()),Unmuting,false)
				
			end
			
		end
		
	end
	
end

function DomeFallen()

    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
    if entityType == Entities.PB_Dome then  
	
		local MotiHardCap = CUtil.GetPlayersMotivationHardcap(playerID)
		
		CUtil.AddToPlayersMotivationHardcap(playerID, -1)
		
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

function DomeVision(_posX,_posY)

	GUI.ScriptSignal(_posX,_posY,1)
	
	GUI.CreateMinimapPulse(_posX,_posY,1)
		
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do 
	
		local gvViewCenterID = {}
		
		gvViewCenterID[i] = Logic.CreateEntity(Entities.XD_ScriptEntity,_posX-(i/100),_posY-(i/100),i,0)
		
		Logic.SetEntityExplorationRange(gvViewCenterID[i],22)
		
	end
	
end

function DomePlaced(_posX,_posY)

	DomeVision(_posX,_posY)
		
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "DomeFallen", 1)
	
	return true
	
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
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Beautification Animation Trigger -------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
function BeautiAnimCheck()

	for eID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PB_Beautification07)) do
	
		if eID  ~= nil then
		
			Logic.SetBuildingSubAnim(eID, 1, "PB_Beautification07_Clockwork_600")
			
		end
		
	end
	
	for eID in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PB_Beautification12)) do
	
		if eID  ~= nil then
		
			Logic.SetBuildingSubAnim(eID, 1, "PB_Beautification12_Turn_600")
			
		end
		
	end
	
	StartCountdown(2,BeautiAnimCheck,false)
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------ Trigger für Leibeigene ----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
SerfHPRegenAmount = 1

SerfHPRegenTime = 4

function SerfCreated()

    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	local pos = {Logic.GetEntityPosition(entityID)}
	
    if entityType == Entities.PU_Serf then       
	
		table.insert(SerfIDTable,entityID)
		
	end
	
end
function SerfDestroyed()

    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    if entityType == Entities.PU_Serf then       
	
		removetablekeyvalue(SerfIDTable,entityID)
		
	end
	
end
function SerfHPRegen()

	for i = 1,table.getn(SerfIDTable) do 
	
		Logic.HealEntity(SerfIDTable[i], SerfHPRegenAmount)
		
	end
	
	StartCountdown(SerfHPRegenTime,SerfHPRegen,false)
	
end
------------------------------------------------------------------------------------------------------------------------------
-------------------------------------- Trigger for Winter Sounds -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function WinterTheme()

	if Logic.GetWeatherState() == 3 or GetCurrentWeatherGfxSet() == 9 or GetCurrentWeatherGfxSet() == 13 then
	
		local SoundChance = Logic.GetRandom(28)
		
			if SoundChance == 10 then
			
			Sound.PlayGUISound(Sounds.AmbientSounds_winter_rnd_1,130)
			
		end
		
	end
	
end
------------------------------------------------------------------------------------------------------------------------------
gvIngameTimeSec = 0

function IngameTimeJob()

	if gvGameSpeed ~= 0 then
	
		gvIngameTimeSec = gvIngameTimeSec + 1
		
	end
	
end
------------------------------------------------------------------------------------------------------------------------------
--------------------------------- BloodRush (SilverTech) Trigger -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function BloodRushCheck()

	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
	
		if Score.GetPlayerScore(i, "battle") > 999 and Logic.GetTechnologyState(i,Technologies.T_UnlockBloodrush) ~= 4 then
		
			Logic.SetTechnologyState(i,Technologies.T_UnlockBloodrush,3)
			
		end
		
	end
	
end
------------------------------------------------------------------------------------------------------------------------------
--------------------------------- Dovbar Trigger -----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
for i = 1,12 do

	_G["gvHero13_DamageStored_"..i] = 0
	
	_G["Hero13_StoneArmor_Trigger_"..i] = function(_heroID,_starttime)
	
		local attacker = Event.GetEntityID1()
		
		local target = Event.GetEntityID2();
		
		local player = Logic.EntityGetPlayer(target)
		
		local posX,posY = Logic.GetEntityPosition(target)
		
		local time = Logic.GetTimeMs()
		
		-- Dauer der Fähigkeit in Millisekunden
		local duration = 1000*5
		
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
				
				for i = 1,8 do
				
					Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode,_posX-(100*i),_posY-(100*i))
					
					Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode,_posX-(100*i),_posY)
					
					Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode,_posX,_posY-(100*i))
					
				end
				
				-- Reichweite der Fähigkeit (in S-cm)
				local range = 800
				
				local damage = _origdmg * 12
				
				for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerFilter(), CEntityIterator.InCircleFilter(_posX, _posY, range)) do
				
					-- wenn Leader, dann...
					if Logic.IsLeader(eID) == 1 and Logic.IsHero(eID) == 0 and Logic.IsSettler(eID) == 1 then
					
						if damage >= Logic.GetEntityHealth(eID) then
						
							Logic.DestroyGroupByLeader(eID)
							
						else
						
							Logic.HurtEntity(eID, damage)
							
						end
						
					-- wenn Soldier, dann...
					elseif Logic.IsBuilding(eID) == 0 and Logic.GetEntityScriptingValue(eID,69) > 0 and Logic.GetEntityScriptingValue(eID,69) ~= eID then
					
						Logic.HurtEntity(eID, damage)
						
					-- wenn Held, dann...
					elseif Logic.IsHero(eID) == 1 then		
					
						Logic.HurtEntity(eID, damage*1.5)
						
					-- wenn alles andere (Leibi, Kanone, Gebäude), dann...
					else
					
						Logic.HurtEntity(eID, damage*2)
						
					end
					
				end	
				
			end
			
			Trigger.UnrequestTrigger(_G["Hero13JudgmentTriggerID_".._heroID])
			
			return true
			
		end
		
	end
	
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Archers Tower Trigger -----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
for i = 1,12 do

	for k = 1,2 do
	
		_G["Archers_Tower_RemoveTroop_"..i.."_"..k] = function(_slot,_entity,_soldiers,_player)
		
			if Counter.Tick2("Archers_Tower_RemoveTroop_Counter_".._entity.."_".._slot,gvArchers_Tower.ClimbUpTime) then
			
				Logic.ResumeEntity(gvArchers_Tower.SlotData[_entity][_slot])
				
				gvArchers_Tower.CurrentlyClimbing[_entity] = nil
			
				if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entity][_slot], EntityCategories.Cannon) ~= 1 then
			
					local soldiers = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_entity][_slot])}
					
					table.remove(soldiers,1)
					
					for i = 1,table.getn(soldiers) do
					
						Logic.ResumeEntity(soldiers[i])
					
					end
					
				end
				
				if IsExisting(_entity) then
				
					local pos = GetPosition(_entity)
					
					local offset = gvArchers_Tower.GetOffset_ByOrientation(_entity)
					
					local newLeaderID
					
					local expLVL = Logic.GetLeaderExperienceLevel(gvArchers_Tower.SlotData[_entity][_slot])
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entity][_slot], EntityCategories.Cannon) == 1 then
					
						newLeaderID = CreateEntity(_player,Logic.GetEntityType(gvArchers_Tower.SlotData[_entity][_slot]),{X = pos.X - offset.X, Y = pos.Y - offset.Y})
					
					else
						
						newLeaderID = AI.Entity_CreateFormation(_player, Logic.GetEntityType(gvArchers_Tower.SlotData[_entity][_slot]), 0, _soldiers, pos.X - offset.X, pos.Y - offset.Y, 0, 0, expLVL, 0)
						
					end
					
					Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_entity][_slot])
					
					gvArchers_Tower.SlotData[_entity][_slot] = nil
					
					gvArchers_Tower.CurrentlyUsedSlots[_entity] = gvArchers_Tower.CurrentlyUsedSlots[_entity] - 1
				
					for i = 1,4 do
					
						XGUIEng.SetMaterialTexture("Archers_Tower_Slot".._slot, i-1, gvArchers_Tower.EmptySlot_Icon)
						
					end				
					
					_G["Archers_Tower_RemoveTroopTriggerID_".._entity.."_".._slot] = nil
					
					return true
				
				else
				
					Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_entity][_slot])
					
					gvArchers_Tower.SlotData[_entity][_slot] = nil
					
					gvArchers_Tower.CurrentlyUsedSlots[_entity] = gvArchers_Tower.CurrentlyUsedSlots[_entity] - 1
					
					_G["Archers_Tower_RemoveTroopTriggerID_".._entity.."_".._slot] = nil
					
					return true
				
				end
				
			end
			
		end
	
		_G["Archers_Tower_AddTroop_"..i.."_"..k] = function(_slot,_soldiers,_player,_towerID)
			
			if Counter.Tick2("Archers_Tower_AddTroop_Counter_".._towerID.."_".._slot,gvArchers_Tower.ClimbUpTime) then
				
				Logic.ResumeEntity(gvArchers_Tower.SlotData[_towerID][_slot])
				
				gvArchers_Tower.CurrentlyClimbing[_towerID] = nil
				
				if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_towerID][_slot], EntityCategories.Cannon) ~= 1 then
			
					local soldiers = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_towerID][_slot])}
					
					table.remove(soldiers,1)
					
					for i = 1,table.getn(soldiers) do
					
						Logic.ResumeEntity(soldiers[i])
					
					end
				
				end
				
				if IsExisting(_towerID) then
				
					local pos = GetPosition(_towerID)
					
					local entityType = Logic.GetEntityType(gvArchers_Tower.SlotData[_towerID][_slot])
					
					local expLVL = Logic.GetLeaderExperienceLevel(gvArchers_Tower.SlotData[_towerID][_slot])
					
					Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_towerID][_slot])
					
					local newLeaderID					
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_towerID][_slot], EntityCategories.Cannon) == 1 then
					
						newLeaderID = CreateEntity(_player,Logic.GetEntityType(gvArchers_Tower.SlotData[_towerID][_slot]),{X = pos.X - 5*math.random(10), Y = pos.Y - 5*math.random(10)})
						
					else						
						
						newLeaderID = AI.Entity_CreateFormation(_player, entityType, 0, _soldiers, pos.X, pos.Y, 0, 0, expLVL, 0)
					
					end
					
					gvArchers_Tower.SlotData[_towerID][_slot] = newLeaderID
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_towerID][_slot], EntityCategories.Cannon) ~= 1 then
					
						local TroopIDs = {Logic.GetSoldiersAttachedToLeader(newLeaderID)}
						
						table.remove(TroopIDs,1)
						
						table.insert(TroopIDs,newLeaderID)
						
						for i = 1,table.getn(TroopIDs) do
							
							CEntity.SetDamage(TroopIDs[i],Logic.GetEntityDamage(TroopIDs[i])*gvArchers_Tower.DamageFactor)
							
							CEntity.SetArmor(TroopIDs[i],Logic.GetEntityArmor(TroopIDs[i])*gvArchers_Tower.ArmorFactor)
							
							CEntity.SetAttackRange(TroopIDs[i],GetEntityTypeMaxAttackRange((TroopIDs[i]),_player)*gvArchers_Tower.MaxRangeFactor)
						
						end
						
					else
					
						CEntity.SetDamage(newLeaderID,Logic.GetEntityDamage(newLeaderID)*gvArchers_Tower.DamageFactor)
						
						CEntity.SetArmor(newLeaderID,Logic.GetEntityArmor(newLeaderID)*gvArchers_Tower.ArmorFactor)
						
						CEntity.SetAttackRange(newLeaderID,GetEntityTypeMaxAttackRange(newLeaderID,_player)*gvArchers_Tower.MaxRangeFactor)
						
					end
				
					for i = 1,4 do
					
						XGUIEng.SetMaterialTexture("Archers_Tower_Slot".._slot, i-1, gvArchers_Tower.GetIcon_ByEntityCategory(newLeaderID))
						
					end
					
					_G["Archers_Tower_AddTroopTriggerID_".._towerID.."_".._slot] = nil
					
					return true
					
				else
					
					Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_towerID][_slot])
					
					gvArchers_Tower.SlotData[_towerID][_slot] = nil
					
					_G["Archers_Tower_AddTroopTriggerID_".._towerID.."_".._slot] = nil
					
					gvArchers_Tower.CurrentlyUsedSlots[_towerID] = gvArchers_Tower.CurrentlyUsedSlots[_towerID] - 1
					
					return true
					
				end
			
			end
			
		end
		
	end

end

function OnArchers_TowerDestroyed()
	
    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    if entityType == Entities.PB_Archers_Tower then       
		
		for i = 1,gvArchers_Tower.MaxSlots do
		
			if gvArchers_Tower.SlotData[entityID][i] ~= nil then
			
				Logic.ResumeEntity(gvArchers_Tower.SlotData[entityID][i])
			
				if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[entityID][i], EntityCategories.Cannon) ~= 1 then
				
					local soldiers = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[entityID][i])}
					
					table.remove(soldiers,1)					
					
					for k = 1,table.getn(soldiers) do
					
						Logic.ResumeEntity(soldiers[k])
					
					end
				
				end
				
				Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[entityID][i])
				
				if _G["Archers_Tower_RemoveTroopTriggerID_"..entityID.."_"..i] then
				
					Trigger.UnrequestTrigger(_G["Archers_Tower_RemoveTroopTriggerID_"..entityID.."_"..i])
				end
				
				if _G["Archers_Tower_AddTroopTriggerID_"..entityID.."_"..i] then
				
					Trigger.UnrequestTrigger(_G["Archers_Tower_AddTroopTriggerID_"..entityID.."_"..i])
				
				end
				
				if gvArchers_Tower.CurrentlyClimbing[entityID] then
				
					gvArchers_Tower.CurrentlyClimbing[entityID] = nil
					
				end
				
				gvArchers_Tower.SlotData[entityID][i] = nil
				
				gvArchers_Tower.CurrentlyUsedSlots[entityID] = nil
				
			end
		
		end
		
		gvArchers_Tower.SlotData[entityID] = nil
		
		gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] = gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] - 1
		
	end

end

function OnArchers_TowerCreated()
	
    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    if entityType == Entities.PB_Archers_Tower then       
		
		gvArchers_Tower.CurrentlyUsedSlots[entityID] = 0
		
		gvArchers_Tower.SlotData[entityID] = {}		
		
		gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] = gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] + 1
		
	end

end

function OnArchers_Tower_OccupiedTroopDied()

	local entityID = Event.GetEntityID()
	
	local playerID = Logic.EntityGetPlayer(entityID)
	
	local pos = GetPosition(entityID)
	
	if playerID ~= 0 then
	
		if CNetwork and XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(playerID) ~= 0 then
	
			if Logic.IsLeader(entityID) == 1 then
		
				if gvArchers_Tower.AmountOfTowers[playerID] > 0 then
					
					for k,v in pairs(gvArchers_Tower.SlotData) do
						
						local slot = table.findvalue(gvArchers_Tower.SlotData[k],entityID)
				
						if  slot ~= nil then
						
							gvArchers_Tower.SlotData[k][slot] = nil
							
							if gvArchers_Tower.CurrentlyUsedSlots[k] ~= nil then
								
								gvArchers_Tower.CurrentlyUsedSlots[k] = gvArchers_Tower.CurrentlyUsedSlots[k] - 1
								
							end
							
							if _G["Archers_Tower_RemoveTroopTriggerID_"..k.."_"..slot] then
							
								Trigger.UnrequestTrigger(_G["Archers_Tower_RemoveTroopTriggerID_"..k.."_"..slot])
								
							end
							
						end
						
					end
					
				end
				
			end
			
		else
		
			if playerID == 1 then
			
				if Logic.IsLeader(entityID) == 1 then
		
					if gvArchers_Tower.AmountOfTowers[playerID] > 0 then
					
						for k,v in pairs(gvArchers_Tower.SlotData) do
						
							local slot = table.findvalue(gvArchers_Tower.SlotData[k],entityID)
					
							if  slot ~= nil then
							
								gvArchers_Tower.SlotData[k][slot] = nil
								
								if gvArchers_Tower.CurrentlyUsedSlots[k] then
									
									gvArchers_Tower.CurrentlyUsedSlots[k] = gvArchers_Tower.CurrentlyUsedSlots[k] - 1
									
								end
								
								if _G["Archers_Tower_RemoveTroopTriggerID_"..k.."_"..slot] then
								
									Trigger.UnrequestTrigger(_G["Archers_Tower_RemoveTroopTriggerID_"..k.."_"..slot])
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end
		
		end
		
	end
	
end