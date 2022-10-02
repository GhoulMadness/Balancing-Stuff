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
------------------------------------ Trigger for Marys/Kalas Poison ----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvPoisonDoT = {}

--Heroes that are using poison (so these are relevant for the DoT effect)
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
--Range of poison
gvPoisonDoT.Range = 600

--Damage of poison (part of the max hp of the target per tick)
gvPoisonDoT.MaxHPDamagePerTick = 0.01

--maximum ticks (equals duration of the poison divided by 10[s])
gvPoisonDoT.MaxNumberOfTicks = 50

--current tick time
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
			
				-- if leader then...
				if Logic.IsLeader(eID) == 1 then
				
					local soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
					
					-- leader only gets hurt when no more soldiers attached
					if soldiers[1] == 0 then
					
						if GetEntityHealth(eID) <= gvPoisonDoT.MaxHPDamagePerTick and Logic.IsHero(eID) ~= 1 then
						
							BS.ManualUpdate_KillScore(_player, Logic.EntityGetPlayer(eID), "Settler")
						
							Logic.DestroyGroupByLeader(eID)
							
						else
						
							Logic.HurtEntity(eID, math.ceil(Logic.GetEntityMaxHealth(eID)*gvPoisonDoT.MaxHPDamagePerTick))
							
						end
						
					end
					
				-- when soldier, worker, etc., then...
				else 
					
					if GetEntityHealth(eID) <= gvPoisonDoT.MaxHPDamagePerTick then
					
						BS.ManualUpdate_KillScore(_player, Logic.EntityGetPlayer(eID), "Settler")
						
					end
				
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
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Yukis Shuriken -----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function YukiShurikenBonusDamage() 

	local attacker = Event.GetEntityID1()
	
    local target = Event.GetEntityID2()
	
	local attype = Logic.GetEntityType(attacker)
	
	local rotattacker = Logic.GetEntityOrientation(attacker)
	
	local rottarget = Logic.GetEntityOrientation(target)
	
	local cooldown = Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityInflictFear)
	
	local maxhp = Logic.GetEntityHealth(target)
	
    local dmg = CEntity.TriggerGetDamage()
	
	local ampdmg 
	
	local dmgtype = CEntity.HurtTrigger.GetDamageSourceType()
	
	if attype == Entities.PU_Hero11 and dmgtype ~= 0 then
	
		if cooldown <= 10 then
		
			if math.abs(rotattacker - rottarget) <= 45 then
			
				ampdmg = math.floor(dmg * 5)				
					
			else
			
				ampdmg = math.floor(dmg * 2)				
					
			end
			
			CEntity.TriggerSetDamage(ampdmg)
				
			if ampdmg >= maxhp then
			
				Logic.HeroSetAbilityChargeSeconds(attacker, Abilities.AbilityShuriken, math.min(Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityShuriken) + 15, Logic.HeroGetAbilityRechargeTime(attacker, Abilities.AbilityShuriken)))
			
			end
			
		end
		
	end
	
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Kerberos attacks ---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function KerberosAttackAdditions() 

	local attacker = Event.GetEntityID1()
	
    local target = Event.GetEntityID2()
	
	local attype = Logic.GetEntityType(attacker)
	
	local defattacker = Logic.GetEntityArmor(attacker)
	
	local deftarget	= Logic.GetEntityArmor(target) or 0 
	
	local defdiff = defattacker - math.max(deftarget, 0)
	
	local dmg = CEntity.TriggerGetDamage()
	
	local ampdmg 
	
	if attype == Entities.CU_BlackKnight and defattacker > deftarget then
	
		ampdmg = dmg * (1 + (0.2 * defdiff))
	
		if Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityInflictFear) ~= Logic.HeroGetAbilityRechargeTime(attacker, Abilities.AbilityInflictFear) then
		
			Logic.HeroSetAbilityChargeSeconds(attacker, Abilities.AbilityInflictFear, math.min(Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityInflictFear) + defdiff, Logic.HeroGetAbilityRechargeTime(attacker, Abilities.AbilityInflictFear)))
			
		end
		
		if Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityRangedEffect) ~= Logic.HeroGetAbilityRechargeTime(attacker, Abilities.AbilityRangedEffect) then
		
			Logic.HeroSetAbilityChargeSeconds(attacker, Abilities.AbilityRangedEffect, math.min(Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityRangedEffect) + (3 * defdiff), Logic.HeroGetAbilityRechargeTime(attacker, Abilities.AbilityRangedEffect)))
			
		end
		
		if Logic.GetEntityHealth(attacker) < Logic.GetEntityMaxHealth(attacker) then
		
			Logic.HealEntity(attacker, ampdmg - dmg)
			
			Logic.CreateEffect(GGL_Effects.FXSalimHeal,Logic.GetEntityPosition(attacker))
			
		end
		
		CEntity.TriggerSetDamage(ampdmg)
		
	end
	
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Catapult Stones ----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CatapultStoneOnHitEffects = {	[1] = GGL_Effects.FXFireTemp,
								[2] = GGL_Effects.FXFireMediumTemp,
								[3] = GGL_Effects.FXFireSmallTemp,
								[4] = GGL_Effects.FXFireLoTemp,
								[5] = GGL_Effects.FXCrushBuildingLarge,
								[6] = GGL_Effects.FXExplosion,
								[7] = GGL_Effects.FXExplosionPilgrim,
								[8] = GGL_Effects.FXExplosionShrapnel
							}

function CatapultStoneHitEffects() 

	local attacker = Event.GetEntityID1()
	
    local target = Event.GetEntityID2();
	
	local targetpos = GetPosition(target)
	
	local attype = Logic.GetEntityType(attacker)
	
	if attype == Entities.PV_Catapult then
	
		Logic.CreateEffect(CatapultStoneOnHitEffects[math.random(1,8)],targetpos.X,targetpos.Y)
		
	end;
	
end;
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
	
	if entityType == Entities.PB_Tower1 or entityType == Entities.PB_Tower2 or entityType == Entities.PB_Tower3 or entityType == Entities.PB_DarkTower1 or entityType == Entities.PB_DarkTower2 or entityType == Entities.PB_DarkTower3 then
		    
		local playerID = GetPlayer(entityID)	
		local posX,posY = Logic.GetEntityPosition(entityID)	
		local pos = {X = posX, Y = posY}
		
		table.insert(gvTower.PositionTable,pos)
		
		if gvTower.AmountOfTowers[playerID] then
		
			gvTower.AmountOfTowers[playerID] = gvTower.AmountOfTowers[playerID] + 1
			
		end
		
	end
	
end

function OnTowerDestroyed()

	local entityID = Event.GetEntityID()	
    local entityType = Logic.GetEntityType(entityID)	
	
	if entityType == Entities.PB_Tower1 or entityType == Entities.PB_Tower2 or entityType == Entities.PB_Tower3 or entityType == Entities.PB_DarkTower1 or entityType == Entities.PB_DarkTower2 or entityType == Entities.PB_DarkTower3 then   
		
		local playerID = GetPlayer(entityID)	
		local posX,posY = Logic.GetEntityPosition(entityID)	
		local pos = {X = posX, Y = posY}
		
		removetablekeyvalue(gvTower.PositionTable,pos)
		
		if gvTower.AmountOfTowers[playerID] then
		
			gvTower.AmountOfTowers[playerID] = gvTower.AmountOfTowers[playerID] - 1
			
		end
		
	end
	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------- Trigger for VStatue4 (global variables to be find in VictoryStatue4.lua) ----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnVStatue4Created()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
	if entityType == Entities.PB_VictoryStatue4 then
	
		local playerID = GetPlayer(entityID)	
		local posX,posY = Logic.GetEntityPosition(entityID)	
		local pos = {X = posX, Y = posY}
		
		table.insert(gvVStatue4.PositionTable,pos)
		
		if gvVStatue4.Amount[playerID] then
		
			gvVStatue4.Amount[playerID] = gvVStatue4.Amount[playerID] + 1
			
		else
		
			gvVStatue4.Amount[playerID] = 1
			
		end
	end		
end

function OnVStatue4Destroyed()

	local entityID = Event.GetEntityID()	
    local entityType = Logic.GetEntityType(entityID)
	
	if entityType == Entities.PB_VictoryStatue4 then   
	
		local playerID = GetPlayer(entityID)	
		local posX,posY = Logic.GetEntityPosition(entityID)	
		local pos = {X = posX, Y = posY}
	
		removetablekeyvalue(gvVStatue4.PositionTable,pos)
		
		if gvVStatue4.Amount[playerID] then
		
			gvVStatue4.Amount[playerID] = gvVStatue4.Amount[playerID] - 1
			
		end
		
	end
	
end

function VStatue4_CalculateDamageTrigger(_EntityID, _PlayerID)

	if Logic.IsEntityDestroyed(_EntityID) then
		return true
	end
	
	local attacker = Event.GetEntityID1()	
    local target = Event.GetEntityID2()	
	local targetPID = Logic.EntityGetPlayer(target)
	local dipstate = Logic.GetDiplomacyState(Logic.EntityGetPlayer(attacker), targetPID)
	
	if dipstate == Diplomacy.Hostile then
		
		if targetPID == _PlayerID or Logic.GetDiplomacyState(_PlayerID, targetPID) == Diplomacy.Friendly then
			if GetDistance(GetPosition(_EntityID), GetPosition(attacker)) <= gvVStatue4.MaxRange then
			
				local dmg = CEntity.TriggerGetDamage()				
				CEntity.TriggerSetDamage(math.ceil(dmg * gvVStatue4.DamageFactor))				
			end
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
		
	elseif targettype == Entities.PU_Hero14 and damage >= health then
	
		_G["Hero14_ResurrectionCheck_Player"..playerID.."_TriggerID"] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero14_ResurrectionCheck_Player"..playerID,1,{},{target})
		
	end
	
end

for i = 1,12 do

	_G["Hero13_ResurrectionCheck_Player"..i] = function(_EntityID)
	
		local playerID = Logic.EntityGetPlayer(_EntityID)
		
		if Logic.IsEntityAlive(_EntityID) then
		
			if GUI.GetPlayerID() == playerID then
			
				gvHero13.LastTimeStoneArmorUsed = Logic.GetTime()
				
				gvHero13.LastTimeDivineJudgmentUsed = Logic.GetTime()
				
			end	
			
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
	
	_G["Hero14_ResurrectionCheck_Player"..i] = function(_EntityID)
	
		local playerID = Logic.EntityGetPlayer(_EntityID)
		
		if Logic.IsEntityAlive(_EntityID) then
		
			if GUI.GetPlayerID() == playerID then
			
				gvHero14.CallOfDarkness.LastTimeUsed = Logic.GetTime()
				
				gvHero14.LifestealAura.LastTimeUsed = Logic.GetTime()
				
				gvHero14.RisingEvil.LastTimeUsed = Logic.GetTime()								
				
			end	
			
			if CNetwork then
				
				if gvHero14.CallOfDarkness.NextCooldown then
				
					if gvHero14.CallOfDarkness.NextCooldown[playerID] then
					
						gvHero14.CallOfDarkness.NextCooldown[playerID] = Logic.GetTime() + gvHero14.CallOfDarkness.Cooldown
						
					end
					
				end
				
				if gvHero14.LifestealAura.NextCooldown then
				
					if gvHero14.LifestealAura.NextCooldown[playerID] then
					
						gvHero14.LifestealAura.NextCooldown[playerID] = Logic.GetTime() + gvHero14.LifestealAura.Cooldown
						
					end
					
				end
				
				if gvHero14.RisingEvil.NextCooldown then
				
					if gvHero14.RisingEvil.NextCooldown[playerID] then
					
						gvHero14.RisingEvil.NextCooldown[playerID] = Logic.GetTime() + gvHero14.RisingEvil.Cooldown
						
					end
					
				end
				
			end
			
			_G["Hero14_ResurrectionCheck_Player"..playerID.."_TriggerID"] = nil
			
			return true
			
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
		
			GUI.AddNote("Durch das Maß erhaltet ihr "..Bonus.." zusätzliche/s "..Text.."!")
			
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
-- Trigger for scaremonger buildings destroyed
function OnScaremongerDestroyed()

    local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
    if Scaremonger.MotiEffect[entityType] then
	
		Scaremonger.MotiReset(playerID, entityType)
		
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
--------------------------------- Dovbar and Erebos Trigger ------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------	
Hero13_StoneArmor_Trigger = function(_heroID,_starttime)

	local attacker = Event.GetEntityID1()	
	local target = Event.GetEntityID2()	
	local player = Logic.EntityGetPlayer(target)	
	local posX,posY = Logic.GetEntityPosition(target)	
	local time = Logic.GetTimeMs()	
	-- Dauer der Fähigkeit in Millisekunden
	local duration = 1000*5	
	local dmg = CEntity.TriggerGetDamage()
	
	if time <= (_starttime + duration) then
	
		if target == _heroID then		
			CEntity.TriggerSetDamage(0)		
			Logic.CreateEffect(GGL_Effects.FXSalimHeal,posX,posY)	
			gvHero13.AbilityProperties.DamageStored[player] = (gvHero13.AbilityProperties.DamageStored[player] or 0) + dmg			
		end
		
	else
	
		if target == _heroID then
		
			CEntity.TriggerSetDamage(dmg + (gvHero13.AbilityProperties.DamageStored[player]*0.7))			
			Logic.CreateEffect(GGL_Effects.FXMaryDemoralize,posX,posY)			
			gvHero13.AbilityProperties.DamageStored[player] = 0			
			Trigger.UnrequestTrigger(gvHero13.TriggerIDs.StoneArmor[player])
			gvHero13.TriggerIDs.StoneArmor[player] = nil
		end		
	end	
end
	
Hero13_DMGBonus_Trigger = function(_heroID,_starttime)

	local attacker = Event.GetEntityID1()	
	local player = Logic.EntityGetPlayer(_heroID)	
	local time = Logic.GetTimeMs()	
	-- Dauer der Fähigkeit in Millisekunden
	local duration = gvHero13.AbilityProperties.DivineJudgment.DMGBonus.Duration
	local dmg = CEntity.TriggerGetDamage()
	
	if time <= (_starttime + duration) then
	
		if attacker == _heroID then		
			CEntity.TriggerSetDamage(dmg*gvHero13.AbilityProperties.DivineJudgment.DMGBonus.Multiplier)			
			Trigger.UnrequestTrigger(gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player])	
			gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] = nil
		end
		
	else	
		Trigger.UnrequestTrigger(gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player])
		gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] = nil
	end
end
	
Hero13_DivineJudgment_Trigger = function(_heroID, _origdmg, _posX, _posY, _starttime)
	
<<<<<<< Updated upstream
		local time = Logic.GetTimeMs()
		
		-- Dauer der Fähigkeit in Millisekunden (Zeitfenster für göttliche Bestrafung)
		local duration = 1000 * 3
		
		if time > (_starttime + duration) then
		
			if Logic.IsEntityAlive(_heroID) then
				
			else
				Logic.CreateEffect(GGL_Effects.FXLightning, _posX, _posY)
				
				for i = 1,10 do
				
					Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX - (100 * i), _posY - (100 * i))
					
					Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX - (100 * i), _posY)
					
					Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX, _posY - (100 * i))
					
				end
				
				-- Reichweite der Fähigkeit (in S-cm)
				local range = 1000
				
				local damage = _origdmg * 12
				
				for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerFilter(), CEntityIterator.InCircleFilter(_posX, _posY, range)) do
				
					-- wenn Leader, dann...
					if Logic.IsLeader(eID) == 1 and Logic.IsEntityAlive(eID) then
						local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
						if Soldiers[1] > 0 then
							local hurtleader = false
							for i = 2, Soldiers[1] + 1 do
								local soldierdmg = math.max(damage - ((i - 2) * damage/10), damage/5)
								local health = Logic.GetEntityHealth(Soldiers[i])
								if soldierdmg >= health then						
									BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(Soldiers[i]), "Settler")	
									if i == (Soldiers[1] + 1) then
										LuaDebugger.Break()
										hurtleader = true
									end
								end
								if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(Soldiers[i])) == Diplomacy.Hostile) then
									ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
									ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
									ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
								end								
								Logic.HurtEntity(Soldiers[i], soldierdmg)
								if hurtleader then
									if damage >= Logic.GetEntityHealth(eID) then						
										BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Settler")							
									end
									if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
										ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
										ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
										ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
									end								
									Logic.HurtEntity(eID, soldierdmg*3/4)
								end
							end
							
						else
=======
	local currtime = Logic.GetTimeMs()		
	-- Dauer der Fähigkeit in Millisekunden (Zeitfenster für göttliche Bestrafung)
	local duration = gvHero13.AbilityProperties.DivineJudgment.Judgment.Duration

	if not Logic.IsEntityAlive(_heroID) then
	
		if currtime <= (_starttime + duration) then
			local delay = (currtime - _starttime)
>>>>>>> Stashed changes
					
			Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX, _posY)
			-- Reichweite der Fähigkeit (in S-cm)
			local range = gvHero13.AbilityProperties.DivineJudgment.Judgment.BaseRange - (delay/gvHero13.AbilityProperties.DivineJudgment.Judgment.RangeDelayFalloff)			
			local damage = _origdmg ^ (gvHero13.AbilityProperties.DivineJudgment.Judgment.BaseExponent - (delay/gvHero13.AbilityProperties.DivineJudgment.Judgment.ExponentDelayFalloff))				
			for i = 1,gvHero13.AbilityProperties.DivineJudgment.Judgment.NumberOfLightningStrikes do
			
				Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX - (range/gvHero13.AbilityProperties.DivineJudgment.Judgment.NumberOfLightningStrikes * i), _posY - (range/gvHero13.AbilityProperties.DivineJudgment.Judgment.NumberOfLightningStrikes * i))					
				Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX - (range/gvHero13.AbilityProperties.DivineJudgment.Judgment.NumberOfLightningStrikes * i), _posY)					
				Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX, _posY - (range/gvHero13.AbilityProperties.DivineJudgment.Judgment.NumberOfLightningStrikes * i))					
			end

			for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerFilter(), CEntityIterator.InCircleFilter(_posX, _posY, range)) do
			
				-- wenn Leader, dann...
				if IsMilitaryLeader(eID) and Logic.IsEntityAlive(eID) then
					local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
					if Soldiers[1] > 0 then							
						for i = 2, table.getn(Soldiers) do
							local soldierdmg = math.max(damage - ((i - 2) * damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFalloff), damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.MinDamage)
							local health = Logic.GetEntityHealth(Soldiers[i])
							if soldierdmg >= health then						
								BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(Soldiers[i]), "Settler")	
							else
								break
							end
							if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(Soldiers[i])) == Diplomacy.Hostile) then
								ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
								ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
								ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
							end								
							Logic.HurtEntity(Soldiers[i], soldierdmg)
							if i == table.getn(Soldiers) then
								if soldierdmg >= Logic.GetEntityHealth(eID) then						
									BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Settler")							
								end
								if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
									ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
									ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
									ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
								end			
								Logic.HurtEntity(eID, round(soldierdmg))
								break
							end
						end

					else
				
						if damage >= Logic.GetEntityHealth(eID) then						
							BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Settler")							
						end
						if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
							ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
							ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
							ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
						end
						
						Logic.HurtEntity(eID, damage)
					end
					
				-- wenn Held, dann...
				elseif Logic.IsHero(eID) == 1 then		
					
					if (damage*gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Hero) >= Logic.GetEntityHealth(eID) then
					
						BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Settler")
						
					end
					if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Hero, Logic.GetEntityHealth(eID)))
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Hero, Logic.GetEntityHealth(eID)))
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
					end
					Logic.HurtEntity(eID, damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Hero)
					
				-- wenn Gebäude, dann...
				elseif Logic.IsBuilding(eID) == 1 then
				
					if (damage*gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Building) >= Logic.GetEntityHealth(eID) then
					
						BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Building")
						
					end
					if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToBuildings"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToBuildings"] + (math.min(damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Building, Logic.GetEntityHealth(eID)))
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Building, Logic.GetEntityHealth(eID)))
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
					end
				
					Logic.HurtEntity(eID, damage * gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactors.Building)
				
				-- wenn Leibi, dann...
				elseif Logic.IsSerf(eID) == 1 then
					
					if damage >= Logic.GetEntityHealth(eID) then
					
						BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Settler")
						
					end
					if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
						ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
					end
					Logic.HurtEntity(eID, damage)					
				end				
			end				
		end
		
		Trigger.UnrequestTrigger(gvHero13.TriggerIDs.DivineJudgment.Judgment[Logic.EntityGetPlayer(_heroID)])
		gvHero13.TriggerIDs.DivineJudgment.Judgment[Logic.EntityGetPlayer(_heroID)] = nil
		return true		
	end	
end
	
Hero14_Lifesteal_Trigger = function(_heroID,_starttime)	
	
	local heroplayer = Logic.EntityGetPlayer(_heroID)

	if not Logic.IsEntityAlive(_heroID) then
	
		gvHero14.LifestealAura.TriggerIDs[heroplayer] = nil
		
		return true
	
	else
	
		local attacker = Event.GetEntityID1()		
		local attackerplayer = Logic.EntityGetPlayer(attacker)		
		local heropos = GetPosition(_heroID)		
		local attackerpos = GetPosition(attacker)		
		local distance = GetDistance(heropos, attackerpos)		
		local cat = Logic.IsEntityInCategory(attacker, EntityCategories.EvilLeader)		
		local time = Logic.GetTime()	
		local duration = gvHero14.LifestealAura.Duration		
		local dmg = CEntity.TriggerGetDamage()		
		local maxhp = Logic.GetEntityMaxHealth(_heroID)		
		local currhp = Logic.GetEntityHealth(_heroID)		
		local daytimefactor = 1
		
		if IsNighttime() then
		
			daytimefactor = gvHero14.LifestealAura.NighttimeFactor
		
		end
		
		if time <= (_starttime + duration) then
	
			if attackerplayer == heroplayer then
			
				if distance <= gvHero14.LifestealAura.Range then
				
					if currhp < maxhp then
					
						if cat == 1 then
					
							Logic.HealEntity(attacker, math.ceil(dmg * gvHero14.LifestealAura.LifestealAmount * gvHero14.LifestealAura.FogPeopleBonusFactor * daytimefactor))							
							
						else
						
							Logic.HealEntity(attacker, math.floor(dmg * gvHero14.LifestealAura.LifestealAmount))
							
						end
						
						Logic.CreateEffect(GGL_Effects.FXSalimHeal, attackerpos.X, attackerpos.Y)
				
					end
				
				end
				
			end
			
		else
		
			gvHero14.LifestealAura.TriggerIDs[heroplayer] = nil
			
			return true
			
		end
		
	end
	
end
	
Hero14_MovementEffects_Player = function(_EntityID)
	
	if IsNighttime() then
	
		if Logic.IsEntityAlive(_EntityID) then
		
			local posX, posY = Logic.GetEntityPosition(_EntityID)
			
			local playerID = Logic.EntityGetPlayer(_EntityID)

			if Logic.GetCurrentTaskList(_EntityID) == "TL_HERO14_WALK" then
							
				Logic.CreateEffect(GGL_Effects.FXHero14_Lightning, posX, posY)
				
				Logic.CreateEffect(gvHero14.MovementEffects[math.random(1,4)], posX, posY)		

				gvHero14.NighttimeAura.TriggerIDs.BurnEffect[playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero14_BurnEffect_ApplyDamage",1,{},{_EntityID, playerID, posX, posY})
				
			elseif Logic.GetCurrentTaskList(_EntityID) == "TL_MILITARY_IDLE" or Logic.IsEntityMoving(_EntityID) == 0 then
			
				if Counter.Tick2("Hero14_MovementEffects_Player"..i.."_CounterID", 3) then
			
					Logic.CreateEffect(GGL_Effects.FXHero14_Fear, posX, posY)
					
				end
			
			end
			
			gvHero14.NighttimeAura.ApplyDamage(_EntityID)
			
		end
		
	end

end
	
Hero14_BurnEffect_ApplyDamage = function(_EntityID, _PlayerID, _posX, _posY)
	
	if Counter.Tick2("Hero14_BurnEffect_ApplyDamage".._EntityID.."_".._posX.."_".._posY.."_CounterID", gvHero14.NighttimeAura.MaxDuration) or not IsNighttime() then
	
		gvHero14.NighttimeAura.TriggerIDs.BurnEffect[_PlayerID] = nil		
		return true
	
	end
		
	gvHero14.NighttimeAura.ApplyDamage(_EntityID, _posX, _posY)			

end

function OnErebos_Created()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	if entityType == Entities.PU_Hero14 then    
	
		gvHero14.NighttimeAura.TriggerIDs.Start[playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero14_MovementEffects_Player",1,{},{entityID})
		
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
					
					local experience = CEntity.GetLeaderExperience(gvArchers_Tower.SlotData[_entity][_slot])
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entity][_slot], EntityCategories.Cannon) == 1 then
					
						newLeaderID = CreateEntity(_player,Logic.GetEntityType(gvArchers_Tower.SlotData[_entity][_slot]),{X = pos.X - offset.X, Y = pos.Y - offset.Y})
					
					else
						
						newLeaderID = CreateGroup(_player, Logic.GetEntityType(gvArchers_Tower.SlotData[_entity][_slot]), _soldiers, pos.X - offset.X, pos.Y - offset.Y, 0 , experience)
						
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
					
					local experience = CEntity.GetLeaderExperience(gvArchers_Tower.SlotData[_towerID][_slot])
					
					Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_towerID][_slot])
					
					local newLeaderID					
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_towerID][_slot], EntityCategories.Cannon) == 1 then
					
						newLeaderID = CreateEntity(_player,Logic.GetEntityType(gvArchers_Tower.SlotData[_towerID][_slot]),{X = pos.X - 5*math.random(10), Y = pos.Y - 5*math.random(10)})
						
					else						
						
						newLeaderID = CreateGroup(_player, entityType, _soldiers, pos.X , pos.Y , 0 , experience)
					
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

function OnArchers_Tower_OccupiedTroopAttacked()

	local attacker = Event.GetEntityID1()
	
	if Logic.GetEntityType(attacker) == Entities.PV_Cannon2 or Logic.GetEntityType(attacker) == Entities.PV_Cannon4 then
		
		local target = Event.GetEntityID2();
				
		local playerID = Logic.EntityGetPlayer(target)
		
		if gvArchers_Tower.AmountOfTowers[playerID] then
			
			if gvArchers_Tower.AmountOfTowers[playerID] > 0 then
			
				local posX,posY = Logic.GetEntityPosition(target)
				
				local towerID = ({Logic.GetEntitiesInArea(Entities.PB_Archers_Tower, posX, posY, gvArchers_Tower.OccupiedTroop.TowerSearchRange, 1)})[2]
				
				local soldiers = {}
				
				if towerID then
				
					for k,v in pairs(gvArchers_Tower.SlotData[towerID]) do
					
						soldiers[k] = {Logic.GetSoldiersAttachedToLeader(v)}

						table.remove(soldiers[k],1)
						
						for n,m in pairs(soldiers[k]) do
						
							if target == soldiers[k][n] then
							
								local dmg = CEntity.TriggerGetDamage();
								
								if dmg > gvArchers_Tower.OccupiedTroop.DamageTreshold then
								
									local attack = Logic.GetEntityDamage(attacker)
									
									local armor = Logic.GetEntityArmor(target)
									
									CEntity.TriggerSetDamage(math.max(math.ceil(attack*gvArchers_Tower.OccupiedTroop.AverageDamageFactor-armor),1))
									
								end
								
							end
							
						end
						
					end
					
				end
					
			end
			
		end
		
	end
		
end

function OnVictoryStatue3Destroyed()

	local entityID = Event.GetEntityID()
	
    local entityType = Logic.GetEntityType(entityID)
	
    local playerID = GetPlayer(entityID)
	
	if entityType == Entities.PB_VictoryStatue3 then    
	
		gvVictoryStatue3.Amount[playerID] = gvVictoryStatue3.Amount[playerID] - 1
		
	end
	
end