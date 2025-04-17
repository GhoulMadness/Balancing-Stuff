---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Drakes Headshot ----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvHero10 = {SnipeAbilityValues = {CriticalRange = 800, AboveCriticalRange = {MaxHealthDMG = 0.36, DMGMultiplier = 4.8}, BelowCriticalRange = {MaxHealthDMG = 0.12, DMGMultiplier = 1.6}},
			GetCriticalStateByDistance = function(_distance)
				if _distance >= gvHero10.SnipeAbilityValues.CriticalRange then
					return "AboveCriticalRange"
				else
					return "BelowCriticalRange"
				end
			end}
function DrakeHeadshotDamage()

	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)

	if attype == Entities.PU_Hero10 then
		local attackerpos = GetPosition(attacker)
		local target = Event.GetEntityID2()
		local targetpos = GetPosition(target)
		local task = Logic.GetCurrentTaskList(attacker)
		local cooldown = Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilitySniper)
		local max = Logic.GetEntityMaxHealth(target)
		local dmg = CEntity.TriggerGetDamage()
		local attackerdmg = Logic.GetEntityDamage(attacker)
		if task == "TL_SNIPE_SPECIAL" then
			if max == dmg then
				local distance = math.abs(GetDistance(attackerpos,targetpos))
				local str = gvHero10.GetCriticalStateByDistance(distance)
				CEntity.TriggerSetDamage(math.floor((max * gvHero10.SnipeAbilityValues[str].MaxHealthDMG) + (attackerdmg*gvHero10.SnipeAbilityValues[str].DMGMultiplier)))
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Marys/Kalas Poison ----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvPoisonDoT = {}
--Heroes that are using poison (so these are relevant for the DoT effect)
gvPoisonDoT.PoisonUsers = {	[Entities.CU_Mary_de_Mortfichet] = true,
							[Entities.CU_Evil_Queen] = true	}

gvPoisonDoT.GetNeededTaskByEntityType = function(_type)

	local task = ""

	if _type == Entities.CU_Mary_de_Mortfichet then
		task = "TL_BATTLE_POISON"
	elseif _type == Entities.CU_Evil_Queen then
		task = "TL_BATTLE_SPECIAL"
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
--trigger IDs
gvPoisonDoT.TriggerIDs = {}

function PoisonDamageCreateDoT()

	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)

	if gvPoisonDoT.PoisonUsers[attype] then
		local attackerpos = GetPosition(attacker)
		local attackerPID = Logic.EntityGetPlayer(attacker)
		local task = Logic.GetCurrentTaskList(attacker)
		if gvPoisonDoT.GetNeededTaskByEntityType(attype) == task then
			if not gvPoisonDoT.TriggerIDs[attacker] then
				gvPoisonDoT.TriggerIDs[attacker] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "PoisonDoT_Job", 1, {}, {attacker,attackerPID,attype,attackerpos.X,attackerpos.Y})
			end
		end
	end
end

PoisonDoT_Job = function(_entity, _player, _type, _posX, _posY)

	if not gvPoisonDoT.CurrentTick[_player] then
		gvPoisonDoT.CurrentTick[_player] = 0
	end

	gvPoisonDoT.CurrentTick[_player] = gvPoisonDoT.CurrentTick[_player] + 1

	for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerFilter(), CEntityIterator.InCircleFilter(_posX, _posY, gvPoisonDoT.Range)) do
		-- need to check whether the id is alive or not, because the spells base dmg is applied b4 this trigger
		if IsAlive(eID) then
			if Logic.GetDiplomacyState(_player,Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile then
				-- if leader then...
				if Logic.IsLeader(eID) == 1 then
					local soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
					-- leader only gets hurt when no more soldiers attached
					if soldiers[1] == 0 then
						if GetEntityHealth(eID)/100 <= gvPoisonDoT.MaxHPDamagePerTick and Logic.IsHero(eID) ~= 1 then
							BS.ManualUpdate_KillScore(_player, Logic.EntityGetPlayer(eID), "Settler")
							Logic.DestroyGroupByLeader(eID)
						else
							Logic.HurtEntity(eID, math.ceil(Logic.GetEntityMaxHealth(eID)*gvPoisonDoT.MaxHPDamagePerTick))
						end
					end

				-- when soldier, worker, etc., then...
				else
					if GetEntityHealth(eID)/100 <= gvPoisonDoT.MaxHPDamagePerTick then
						BS.ManualUpdate_KillScore(_player, Logic.EntityGetPlayer(eID), "Settler")
					end

					Logic.HurtEntity(eID, math.ceil(Logic.GetEntityMaxHealth(eID)*gvPoisonDoT.MaxHPDamagePerTick))
				end
			end
		end
	end

	if gvPoisonDoT.CurrentTick[_player] >= gvPoisonDoT.MaxNumberOfTicks then
		gvPoisonDoT.CurrentTick[_player] = nil
		gvPoisonDoT.TriggerIDs[_entity] = nil
		return true
	end

end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Yukis Shuriken -----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvHero11 = {ShurikenValues = {CriticalAngle = 45, DMGMultiplier = 2, AmpDMGMultiplier = 5, MaxDelay = 10, CooldownReset = 15}}
function YukiShurikenBonusDamage()

	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)

	if attype == Entities.PU_Hero11 then
		local target = Event.GetEntityID2()
		local rotattacker = Logic.GetEntityOrientation(attacker)
		local rottarget = Logic.GetEntityOrientation(target)
		local cooldown = Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityInflictFear)
		local maxhp = Logic.GetEntityHealth(target)
		local dmg = CEntity.TriggerGetDamage()
		local ampdmg
		local dmgtype = CEntity.HurtTrigger.GetDamageSourceType()
		if dmgtype ~= 0 then
			if cooldown <= gvHero11.ShurikenValues.MaxDelay then
				if math.abs(rotattacker - rottarget) <= gvHero11.ShurikenValues.CriticalAngle then
					ampdmg = math.floor(dmg * gvHero11.ShurikenValues.AmpDMGMultiplier)
				else
					ampdmg = math.floor(dmg * gvHero11.ShurikenValues.DMGMultiplier)
				end

				CEntity.TriggerSetDamage(ampdmg)

				if ampdmg >= maxhp then
					Logic.HeroSetAbilityChargeSeconds(attacker, Abilities.AbilityShuriken, math.min(Logic.HeroGetAbiltityChargeSeconds(attacker, Abilities.AbilityShuriken) + gvHero11.ShurikenValues.CooldownReset, Logic.HeroGetAbilityRechargeTime(attacker, Abilities.AbilityShuriken)))
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Kerberos attacks ---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvHero7 = {ArmorDiffPassive = {DMGMultiplierAddPerDiff = 0.2, CooldownResetPerDiff = {	[Abilities.AbilityInflictFear] = 1,
																						[Abilities.AbilityRangedEffect] = 3}},
			Abilities = {Abilities.AbilityInflictFear, Abilities.AbilityRangedEffect}}
function KerberosAttackAdditions()

	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)
	if attype == Entities.CU_BlackKnight then
		local target = Event.GetEntityID2()
		local defattacker = Logic.GetEntityArmor(attacker)
		local deftarget	= Logic.GetEntityArmor(target) or 0
		local defdiff = defattacker - math.max(deftarget, 0)
		local dmg = CEntity.TriggerGetDamage()
		local ampdmg

		if defattacker > deftarget then
			ampdmg = dmg * (1 + (gvHero7.ArmorDiffPassive.DMGMultiplierAddPerDiff * defdiff))

			for k, v in pairs(gvHero7.Abilities) do
				if Logic.HeroGetAbiltityChargeSeconds(attacker, v) ~= Logic.HeroGetAbilityRechargeTime(attacker, v) then
					Logic.HeroSetAbilityChargeSeconds(attacker, v, math.min(Logic.HeroGetAbiltityChargeSeconds(attacker, v) + (defdiff * gvHero7.ArmorDiffPassive.CooldownResetPerDiff[v]), Logic.HeroGetAbilityRechargeTime(attacker, v)))
				end
			end

			if Logic.GetEntityHealth(attacker) < Logic.GetEntityMaxHealth(attacker) then
				Logic.HealEntity(attacker, ampdmg - dmg)
				Logic.CreateEffect(GGL_Effects.FXSalimHeal,Logic.GetEntityPosition(attacker))
			end

			CEntity.TriggerSetDamage(ampdmg)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Helias -------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnHeliasCreated()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PU_Hero6 then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "HeliasDamageReduction", 1, {}, {entityID})
	end
end
function HeliasDamageReduction(_id)

	if Logic.IsEntityAlive(_id) then
		local target = Event.GetEntityID2()
		local cooldown = Logic.HeroGetAbiltityChargeSeconds(_id, Abilities.AbilityRangedEffect)
		local player = Logic.EntityGetPlayer(_id)
		local dmg = CEntity.TriggerGetDamage()
		local posX, posY = Logic.GetEntityPosition(target)
		local tab = gvHero6.AbilityProperties.Bless
		if cooldown > tab.Duration and cooldown < Logic.HeroGetAbilityRechargeTime(_id, Abilities.AbilityRangedEffect) then
			if target == _id and Logic.GetPlayersGlobalResource(player, ResourceType.Faith) >= Logic.GetMaximumFaith(player) then
				local newdmg = math.max(math.ceil(dmg * tab.DamageReductionFactor), 1)
				CEntity.TriggerSetDamage(newdmg)
				Logic.CreateEffect(GGL_Effects.FXNephilimFlowerDestroy, posX, posY)
			end
		elseif cooldown < tab.Duration then
			local p2 = Logic.EntityGetPlayer(target)
			if player == p2 or Logic.GetDiplomacyState(player, p2) == Diplomacy.Friendly then
				if GetDistance(_id, target) <= tab.MaxRange and target ~= _id then
					local newdmg = math.max(math.ceil(dmg * tab.DamageReductionFactor), 1)
					local diff = dmg - newdmg
					if Logic.GetPlayersGlobalResource(player, ResourceType.Faith) >= diff then
						Logic.SubFromPlayersGlobalResource(player, ResourceType.Faith, diff)
						CEntity.TriggerSetDamage(newdmg)
						Logic.CreateEffect(GGL_Effects.FXNephilimFlowerDestroy, posX, posY)
					end
				end
			end
		end
	end
end
function Hero6_Sacrilege_Trigger(_id, _player, _starttime)

	local time = Logic.GetTime()
	local duration = gvHero6.AbilityProperties.Sacrilege.Duration

	if time > (_starttime + duration) or not Logic.IsEntityAlive(_id) then
		gvHero6.Sacrilege.Active[_player] = false
		gvHero6.TriggerIDs.Sacrilege[_player] = nil
		return true
	end

	gvHero6.Sacrilege.Active[_player] = true
	local posX, posY = Logic.GetEntityPosition(_id)
	Logic.CreateEffect(GGL_Effects.FXExtractStone, posX, posY)
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Ari ----------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gvHero5 = {AbilityProperties = {Summon = {NumSoldiersPerTroop = 7, Duration = 60}}}
function OnAriTroopCreated()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PU_Hero5_Outlaw then
		local player = Logic.EntityGetPlayer(entityID)
		local posX, posY = Logic.GetEntityPosition(entityID)
		for i = 1, gvHero5.AbilityProperties.Summon.NumSoldiersPerTroop do
			Logic.CreateEntity(Entities.PU_Hero5_OutlawSoldier, posX, posY, 0, player)
			Logic.LeaderGetOneSoldier(entityID)
		end
		local IDs = {Logic.GetSoldiersAttachedToLeader(entityID)}
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAriTroopDied", 1, {}, {entityID, unpack(IDs)})
	end
end
function OnAriTroopDied(_id, _num, ...)

	local entityID = Event.GetEntityID()
	if entityID == _id then
		if _num > 0 then
			for i = 1, _num do
				SetHealth(arg[i], 0)
			end
		end
		return true
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
	local attype = Logic.GetEntityType(attacker)

	if attype == Entities.PV_Catapult then
		local target = Event.GetEntityID2()
		local targetpos = GetPosition(target)
		Logic.CreateEffect(CatapultStoneOnHitEffects[math.random(1, table.getn(CatapultStoneOnHitEffects))],targetpos.X,targetpos.Y)
	end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------- Set correct cooldowns when Helias, Dovbar and Erebos resurrects -------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function OnHeroDied()

    local target = Event.GetEntityID2()
	local targettype = Logic.GetEntityType(target)

	if (targettype == Entities.PU_Hero6 or targettype == Entities.PU_Hero13 or targettype == Entities.PU_Hero14 or targettype == Entities.CU_Barbarian_Hero) then
		local health = Logic.GetEntityHealth(target)
		local damage = CEntity.TriggerGetDamage()
		if damage >= health then
			OnHeroDied_Action(target)
		end
	end
end
function OnHeroDied_Action(_id)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", "DelayedCheck_IsHeroDead",1,{},{_id})
end

function DelayedCheck_IsHeroDead(_id)
	if not Logic.IsEntityAlive(_id) then
		local etype = Logic.GetEntityType(_id)
		local playerID = GetPlayer(_id)
		local str = BS.GetTableStrByHeroType(etype)
		_G["gv"..str].TriggerIDs.Resurrection[playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"", str.."_ResurrectionCheck",1,{},{_id})
	end
	return true
end

Hero6_ResurrectionCheck = function(_EntityID)

	if Logic.IsEntityAlive(_EntityID) then

		local playerID = Logic.EntityGetPlayer(_EntityID)

		if GUI.GetPlayerID() == playerID then
			gvHero6.LastTimeUsed.Sacrilege = Logic.GetTime()
		end

		if CNetwork then

			if gvHero6.Sacrilege.NextCooldown then
				if gvHero6.Sacrilege.NextCooldown[playerID] then
					gvHero6.Sacrilege.NextCooldown[playerID] = Logic.GetTime() + (gvHero6.Cooldown.Sacrilege)
				end
			end

		end

		gvHero6.TriggerIDs.Resurrection[playerID] = nil
		return true

	end
end

Hero9_ResurrectionCheck = function(_EntityID)

	if Logic.IsEntityAlive(_EntityID) then

		local playerID = Logic.EntityGetPlayer(_EntityID)

		if GUI.GetPlayerID() == playerID then
			gvHero9.LastTimeUsed.Plunder = Logic.GetTime()
		end

		if CNetwork then

			if gvHero9.Plunder.NextCooldown then
				if gvHero9.Plunder.NextCooldown[playerID] then
					gvHero9.Plunder.NextCooldown[playerID] = Logic.GetTime() + (gvHero9.Cooldown.Plunder)
				end
			end

		end

		gvHero9.TriggerIDs.Resurrection[playerID] = nil
		return true

	end
end

Hero13_ResurrectionCheck = function(_EntityID)

	if Logic.IsEntityAlive(_EntityID) then

		local playerID = Logic.EntityGetPlayer(_EntityID)

		if GUI.GetPlayerID() == playerID then
			gvHero13.LastTimeUsed.StoneArmor = Logic.GetTime()
			gvHero13.LastTimeUsed.DivineJudgment = Logic.GetTime()
		end

		if CNetwork then

			if gvHero13.StoneArmor.NextCooldown then
				if gvHero13.StoneArmor.NextCooldown[playerID] then
					gvHero13.StoneArmor.NextCooldown[playerID] = Logic.GetTimeMs() + (gvHero13.Cooldown.StoneArmor * 1000)
				end
			end

			if gvHero13.DivineJudgment.NextCooldown then
				if gvHero13.DivineJudgment.NextCooldown[playerID] then
					gvHero13.DivineJudgment.NextCooldown[playerID] = Logic.GetTimeMs() + (gvHero13.Cooldown.DivineJudgment * 1000)
				end
			end

		end

		gvHero13.TriggerIDs.Resurrection[playerID] = nil
		return true

	end
end

Hero14_ResurrectionCheck = function(_EntityID)

	if Logic.IsEntityAlive(_EntityID) then

		local playerID = Logic.EntityGetPlayer(_EntityID)

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

		gvHero14.TriggerIDs.Resurrection[playerID] = nil
		return true

	end
end
---------------------------------------------------------------------------------------------------------------------------
-------------------------------- Trigger for Salims trap ------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
function SalimTrapPlaced()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PU_Hero3_Trap then
		local eplayerID = GetPlayer(entityID)
		local hplayerID = GUI.GetPlayerID()
		if Logic.GetDiplomacyState(eplayerID, hplayerID) ~= Diplomacy.Friendly and eplayerID ~= hplayerID then
			--Model ändern und Overhead-Widget ausblenden, wenn nicht verbündet (Durch Eintrag in der models.xml gehandhabt)
			Logic.SetModelAndAnimSet(entityID, Models.SalimTrapEnemy)
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

	end

	if Logic.GetTechnologyState(PID,Technologies.T_Scale) == 4 then
		local Bonus = math.ceil((TSum/10) + math.random((TSum/6)))
		Logic.AddToPlayersGlobalResource(PID, TTyp, Bonus )

		if GUI.GetPlayerID() == PID then
			GUI.AddNote("Durch das Maß erhaltet ihr "..Bonus.." zusätzliche/s "..Text.."!")
		end

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

    if entityType == Entities.PB_Dome then
		local pos = {Logic.GetEntityPosition(entityID)}
		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "DomePlaced", 1,{},{pos[1],pos[2]})
	end

	if entityType == Entities.PB_CoalmakersHut1 then
		gvCoal.Coalmaker.WoodBurned[entityID] = 0
		gvCoal.Coalmaker.CoalEarned[entityID] = 0
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCoalmaker_Destroyed", 1,{},{entityID})
	end

	if entityType == Entities.PB_CoalMine1 or entityType == Entities.PB_CoalMine2 then
		gvCoal.Mine.AmountMined[entityID] = 0
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnCoalmine_Destroyed", 1,{},{entityID})
	end

	if entityType == Entities.PB_Beautification_Anniversary20 then
		gvAnnivStatue20[playerID].Amount = gvAnnivStatue20[playerID].Amount + 1
		Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "OnAnnivStatue_Destroyed", 1,{},{entityID})
	end

end
----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------ Dome Trigger --------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
function DomeFallen()

    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

    if entityType == Entities.PB_Dome then
		local playerID = GetPlayer(entityID)
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

	for i = 1, XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Dome) >= 1 then
			for k = 1, XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
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
gvBeautiAnim = {IDs = {}, AnimByType = {[Entities.PB_Beautification07] = "PB_Beautification07_Clockwork_600",
										[Entities.PB_Beautification12] = "PB_Beautification12_Turn_600"},
										Delay = 2}
function OnSpecBeautiCreated()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if gvBeautiAnim.AnimByType[entityType] then
		table.insert(gvBeautiAnim.IDs, entityID)
	end

end
function BeautiAnimCheck()

    for i = table.getn(gvBeautiAnim.IDs), 1, -1 do
		local id = gvBeautiAnim.IDs[i]
		if Logic.IsConstructionComplete(id) == 1 then
			CUtil.SetBuildingSubAnimExtended(id, 1, gvBeautiAnim.AnimByType[Logic.GetEntityType(id)], false, true)
			table.remove(gvBeautiAnim.IDs, i)
		end
	end
	StartCountdown(gvBeautiAnim.Delay, BeautiAnimCheck, false)

end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Trigger for serfs ----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
SerfIDTable = {Logic.GetEntities(Entities.PU_Serf,30)}
table.remove(SerfIDTable,1)
SerfHPRegenVal = {Amount = 1, Time = 4}

function SerfCreated()

    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

    if entityType == Entities.PU_Serf then
		table.insert(SerfIDTable, entityID)
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
		Logic.HealEntity(SerfIDTable[i], SerfHPRegenVal.Amount)
	end

	StartCountdown(SerfHPRegenVal.Time,SerfHPRegen,false)

end
------------------------------------------------------------------------------------------------------------------------------
-------------------------------------- Trigger for Winter Sounds -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
gvWinterTheme = {GfxSets = {3, 9, 13}, WeatherState = 3, Chance = 1/28, Volume = 130,
				IsCurrentWeatherSuited = function()
					if Logic.GetWeatherState() == gvWinterTheme.WeatherState then
						return true
					end
					for k,v in pairs(gvWinterTheme.GfxSets) do
						if GetCurrentWeatherGfxSet() == v then
							return true
						end
					end
					return false
				end}
function WinterTheme()

	if gvWinterTheme.IsCurrentWeatherSuited() then
		local SoundChance = math.random(1/gvWinterTheme.Chance)
		if SoundChance == 1 then
			Sound.PlayGUISound(Sounds.AmbientSounds_winter_rnd_1, gvWinterTheme.Volume)
		end
	end

end
------------------------------------------------------------------------------------------------------------------------------
function IngameTimeJob()

	if gvGameSpeed ~= 0 then
		BS.Time.IngameTimeSec = BS.Time.IngameTimeSec + 1
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
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------ Trigger for Varg ---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Hero9_Died(_heroID)

	local target = Event.GetEntityID2()

	if target == _heroID then

		local health = Logic.GetEntityHealth(target)
		local damage = CEntity.TriggerGetDamage()
		if damage >= health then

			local player = Logic.EntityGetPlayer(_heroID)
			if gvHero9.WolfIDs and gvHero9.WolfIDs[player] then
				for i = 1, table.getn(gvHero9.WolfIDs[player]) do
					SetHealth(gvHero9.WolfIDs[player][i], 0)
				end
				gvHero9.WolfIDs[player] = {}
			end

			return true

		end

	end

end
Hero9_DiedCheck_Job = function(_heroID)

	local target = Event.GetEntityID2()

	if target == _heroID then

		local health = Logic.GetEntityHealth(target)
		local damage = CEntity.TriggerGetDamage()
		if damage >= health then
			local tab = gvHero9.AbilityProperties.Plunder
			if tab.Plundered[target] and next(tab.Plundered[target]) then
				for k, v in pairs(tab.Plundered[target]) do
					if v > 0 then
						tab.Plundered[target][k] = nil
					end
				end
			end
			local player = Logic.EntityGetPlayer(target)
			gvHero9.TriggerIDs.DiedCheck[player] = nil
			return true

		end

	end

end
Hero9_NearOwnBuildingCheck_Job = function(_heroID)
	local player = Logic.EntityGetPlayer(_heroID)
	if not Logic.IsEntityAlive(_heroID) then
		gvHero9.TriggerIDs.NearOwnBuildingCheck[player] = nil
		return true
	end
	local posX, posY = Logic.GetEntityPosition(_heroID)
	local tab = gvHero9.AbilityProperties.Plunder
	if tab.Plundered[_heroID] and next(tab.Plundered[_heroID]) then
		if ArePlayerBuildingsInArea(player, posX, posY, tab.Range) then
			local any = false
			for k, v in pairs(tab.Plundered[_heroID]) do
				if v > 0 then
					any = true
					Logic.AddToPlayersGlobalResource(player, k, v)
					tab.Plundered[_heroID][k] = nil
				end
			end
			if any and GUI.GetPlayerID() == player then
				GUI.AddNote(XGUIEng.GetStringTableText("MenuHero9/note_plunder_success"))
			end
		end
	end
end
Hero9_Plunder_Job = function(_heroID, _starttime)

	local player = Logic.EntityGetPlayer(_heroID)
	if not Logic.IsEntityAlive(_heroID) then
		gvHero9.TriggerIDs.Plunder[player] = nil
		return true
	end
	local time = Logic.GetTime()
	local tab = gvHero9.AbilityProperties.Plunder
	local duration = tab.Duration
	if time <= (_starttime + duration) then
		local attacker = Event.GetEntityID1()
		local target = Event.GetEntityID2()
		if Logic.IsBuilding(target) == 1 and Logic.IsConstructionComplete(target) then
			if Logic.EntityGetPlayer(attacker) == player then
				local etype = Logic.GetEntityType(attacker)
				if table_findvalue(tab.AllowedTypes, etype) ~= 0 then
					local posH = GetPosition(_heroID)
					local posA = GetPosition(attacker)
					if GetDistance(posH, posA) <= tab.Range then
						local rtype = gvHero9.GetPlunderedResourceTypeByTarget(target)
						tab.Plundered[_heroID][rtype] = (tab.Plundered[_heroID][rtype] or 0) + (tab.ResPerHit[rtype] or tab.ResPerHit.default)
						Logic.CreateEffect(GGL_Effects.FXDestroyTree, posA.X, posA.Y)
					end
				end
			end
		end
	else
		gvHero9.TriggerIDs.Plunder[player] = nil
		return true
	end
end
------------------------------------------------------------------------------------------------------------------------------
--------------------------------- Dovbar and Erebos Trigger ------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
Hero13_StoneArmor_StoreDamage = function(_heroID, _starttime)

	local target = Event.GetEntityID2()
	local time = Logic.GetTimeMs()
	local duration = gvHero13.AbilityProperties.StoneArmor.Duration

	if time <= (_starttime + duration) then

		local player = Logic.EntityGetPlayer(target)
		local posX,posY = Logic.GetEntityPosition(target)
		local dmg = CEntity.TriggerGetDamage()

		if target == _heroID then
			CEntity.TriggerSetDamage(0)
			Logic.CreateEffect(GGL_Effects.FXSalimHeal,posX,posY)
			gvHero13.AbilityProperties.StoneArmor.DamageStored[player] = (gvHero13.AbilityProperties.StoneArmor.DamageStored[player] or 0) + dmg
		end

	end

end
Hero13_StoneArmor_ApplyDamage = function(_heroID, _starttime)

	local player = Logic.EntityGetPlayer(_heroID)

	if not Logic.IsEntityAlive(_heroID) then
		gvHero13.AbilityProperties.StoneArmor.DamageStored[player] = 0
		gvHero13.TriggerIDs.StoneArmor.DamageApply[player] = nil
		return true
	end

	local time = Logic.GetTimeMs()
	local duration = gvHero13.AbilityProperties.StoneArmor.Duration

	if time > (_starttime + duration) then
		local posX,posY = Logic.GetEntityPosition(_heroID)
		Logic.CreateEffect(GGL_Effects.FXMaryDemoralize,posX,posY)
		if gvHero13.AbilityProperties.StoneArmor.DamageStored and gvHero13.AbilityProperties.StoneArmor.DamageStored[player] then
			Logic.HurtEntity(_heroID, gvHero13.AbilityProperties.StoneArmor.DamageStored[player]*gvHero13.AbilityProperties.StoneArmor.DamageFactor)
			gvHero13.AbilityProperties.StoneArmor.DamageStored[player] = 0
		end
		gvHero13.TriggerIDs.StoneArmor.DamageApply[player] = nil
		Trigger.UnrequestTrigger(gvHero13.TriggerIDs.StoneArmor.DamageStoring[player])
		gvHero13.TriggerIDs.StoneArmor.DamageStoring[player] = nil
		return true
	end

end
Hero13_DMGBonus_Trigger = function(_heroID,_starttime)

	local attacker = Event.GetEntityID1()
	local time = Logic.GetTimeMs()
	-- Dauer der Fähigkeit in Millisekunden
	local duration = gvHero13.AbilityProperties.DivineJudgment.DMGBonus.Duration
	local player = Logic.EntityGetPlayer(_heroID)

	if time <= (_starttime + duration) then

		if attacker == _heroID then
			local dmg = CEntity.TriggerGetDamage()
			CEntity.TriggerSetDamage(dmg*gvHero13.AbilityProperties.DivineJudgment.DMGBonus.Multiplier)
			gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] = nil
			return true
		end

	else
		gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] = nil
		return true
	end
end

Hero13_DivineJudgment_Trigger = function(_heroID, _origdmg, _posX, _posY, _starttime)

	if not Logic.IsEntityAlive(_heroID) then

		local currtime = Logic.GetTimeMs()
		local tab = gvHero13.AbilityProperties.DivineJudgment.Judgment
		-- Dauer der Fähigkeit in Millisekunden (Zeitfenster für göttliche Bestrafung)
		local duration = tab.Duration
		local player = Logic.EntityGetPlayer(_heroID)

		if currtime <= (_starttime + duration) then

			tab.TimesUsed[player] = tab.TimesUsed[player] + 1
			local delay = (currtime - _starttime)
			Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX, _posY)
			-- zeitlich basierte Boni
			local DamageFactorBonus = tab.DamageFactorBonus[player]
			local RangeFactorBonus = tab.RangeFactorBonus[player]
			-- Reichweite der Fähigkeit (in S-cm)
			local range = math.max(tab.BaseRange - (delay/tab.RangeDelayFalloff) - (tab.TimesUsed[player] * tab.RangeFalloffPerCast) * (1 + RangeFactorBonus),
				tab.MinRange)
			local damage = math.max(_origdmg ^ (tab.BaseExponent - (math.sqrt(delay)/tab.ExponentDelayFalloff)) * (1 + DamageFactorBonus),
				_origdmg * tab.MinAttackDamageFactor)

			for i = 1, math.min(tab.NumberOfLightningStrikes, round(damage/80)) do
				Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX - (range/tab.NumberOfLightningStrikes * i), _posY - (range/tab.NumberOfLightningStrikes * i))
				Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX - (range/tab.NumberOfLightningStrikes * i), _posY)
				Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, _posX, _posY - (range/tab.NumberOfLightningStrikes * i))
			end
			local alliescount = GetNumberOfAlliesInRange(player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, range)
			local enemiescount = GetNumberOfEnemiesInRange(player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, range)

			for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerOrBuildingFilter(), CEntityIterator.InCircleFilter(_posX, _posY, range)) do

				local player2 = Logic.EntityGetPlayer(eID)
				if player == player2 or Logic.GetDiplomacyState(player, player2) ~= Diplomacy.Neutral then
					-- wenn Leader, dann...
					if IsMilitaryLeader(eID) and Logic.IsEntityAlive(eID) then
						local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
						if Soldiers[1] > 0 then
							for i = 2, table.getn(Soldiers) do
								local soldierdmg = math.max(damage - ((i - 2) * damage * tab.DamageFalloff), damage * tab.MinDamage)
								local health = Logic.GetEntityHealth(Soldiers[i])
								if soldierdmg >= health then
									BS.ManualUpdate_KillScore(player, Logic.EntityGetPlayer(Soldiers[i]), "Settler")
									if tab.DamageFactorBonus[player] >= 1 then
										local posX, posY = Logic.GetEntityPosition(Soldiers[i])
										CEntity.DealDamageInArea(eID, posX, posY, 300, Logic.GetEntityDamage(Soldiers[i]))
										Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, posX, posY)
									end
								else
									break
								end
								if ExtendedStatistics and (Logic.GetDiplomacyState(player, Logic.EntityGetPlayer(Soldiers[i])) == Diplomacy.Hostile) then
									BS.ManualUpdate_DamageDealt(_heroID, soldierdmg, Logic.GetEntityHealth(Soldiers[i]), "DamageToUnits")
								end
								Logic.HurtEntity(Soldiers[i], soldierdmg)
								if i == table.getn(Soldiers) then
									if soldierdmg >= Logic.GetEntityHealth(eID) then
										BS.ManualUpdate_KillScore(player, player2, "Settler")
										if tab.DamageFactorBonus[player] >= 1 then
											local posX, posY = Logic.GetEntityPosition(eID)
											CEntity.DealDamageInArea(eID, posX, posY, 300, Logic.GetEntityDamage(eID))
											Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, posX, posY)
										end
									end
									if ExtendedStatistics and (Logic.GetDiplomacyState(player, player2) == Diplomacy.Hostile) then
										BS.ManualUpdate_DamageDealt(_heroID, soldierdmg, Logic.GetEntityHealth(eID), "DamageToUnits")
									end
									Logic.HurtEntity(eID, round(soldierdmg))
									break
								end
							end

						else

							if damage >= Logic.GetEntityHealth(eID) then
								BS.ManualUpdate_KillScore(player, player2, "Settler")
								if tab.DamageFactorBonus[player] >= 1 then
									local posX, posY = Logic.GetEntityPosition(eID)
									CEntity.DealDamageInArea(eID, posX, posY, 300, Logic.GetEntityDamage(eID))
									Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode, posX, posY)
								end
							end
							if ExtendedStatistics and (Logic.GetDiplomacyState(player, player2) == Diplomacy.Hostile) then
								BS.ManualUpdate_DamageDealt(_heroID, damage, Logic.GetEntityHealth(eID), "DamageToUnits")
							end
							Logic.HurtEntity(eID, damage)
						end

					-- wenn Held, dann...
					elseif Logic.IsHero(eID) == 1 then
						damage = damage * tab.DamageFactors.Hero
						-- Sonderbehandlung für Dovbar...
						if Logic.GetEntityType(eID) == Entities.PU_Hero13 then
							-- Stone Armor aktiv?
							if gvHero13.TriggerIDs.StoneArmor.DamageStoring[player2] then
								-- no damage
								Logic.CreateEffect(GGL_Effects.FXSalimHeal, Logic.GetEntityPosition(eID))
								gvHero13.AbilityProperties.StoneArmor.DamageStored[player2] = (gvHero13.AbilityProperties.StoneArmor.DamageStored[player2] or 0) + damage
								damage = 0
							end
						end

						if damage > 0 then
							if damage >= Logic.GetEntityHealth(eID) then
								if Logic.GetEntityType(eID) == Entities.PU_Hero13 then
									OnHeroDied_Action(eID)
								end
								BS.ManualUpdate_KillScore(player, player2, "Settler")
							end
							if ExtendedStatistics and (Logic.GetDiplomacyState(player, player2) == Diplomacy.Hostile) then
								BS.ManualUpdate_DamageDealt(_heroID, damage, Logic.GetEntityHealth(eID), "DamageToUnits")
							end
							Logic.HurtEntity(eID, damage)
						end

					-- wenn Gebäude, dann...
					elseif Logic.IsBuilding(eID) == 1 then
						if not gvLightning.IsLightningProofBuilding(eID) then
							damage = damage * tab.DamageFactors.Building
							if damage >= Logic.GetEntityHealth(eID) then
								BS.ManualUpdate_KillScore(player, player2, "Building")
							end
							if ExtendedStatistics and (Logic.GetDiplomacyState(player, player2) == Diplomacy.Hostile) then
								BS.ManualUpdate_DamageDealt(_heroID, damage, Logic.GetEntityHealth(eID), "DamageToBuildings")
							end
							Logic.HurtEntity(eID, damage)
						end

					-- wenn Leibi, dann...
					elseif Logic.IsSerf(eID) == 1 then

						if damage >= Logic.GetEntityHealth(eID) then
							BS.ManualUpdate_KillScore(player, player2, "Settler")
						end
						if ExtendedStatistics and (Logic.GetDiplomacyState(player, player2) == Diplomacy.Hostile) then
							BS.ManualUpdate_DamageDealt(_heroID, damage, Logic.GetEntityHealth(eID), "DamageToUnits")
						end
						Logic.HurtEntity(eID, damage)
					end
				end
			end
			if DamageFactorBonus >= 1 then
				if alliescount < enemiescount then
					local pos = GetPlayerStartPosition(player)
					local hq = Logic.GetEntityAtPosition(pos.X, pos.Y)
					if hq > 0 then
						local offX, offY = GetBuildingTypeLeavePos(Entities.PB_Headquarters1)
						local X, Y = RotateOffset(offX, offY, Logic.GetEntityOrientation(hq))
						TeleportSettler(_heroID, pos.X + X, pos.Y + Y)
					end
				end
			end
		end
		gvHero13.TriggerIDs.DivineJudgment.Judgment[player] = nil
		Trigger.UnrequestTrigger(gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player])
		gvHero13.TriggerIDs.DivineJudgment.DMGBonus[player] = nil
		return true
	end
end

Hero13_DivineJudgment_CalculateBonusEffects = function(_heroID, _player)
	-- no need to calculate it every second
	local tab = gvHero13.AbilityProperties.DivineJudgment.CalculateBonusEffects
	if Counter.Tick2("Hero13_DivineJudgment_CalculateBonusEffects_" .. _heroID, tab.EverySeconds) then
		-- only if hero is alive
		if Logic.IsEntityAlive(_heroID) then
			local NextTimeReady
			-- time in ms ability is ready again
			if CNetwork then
				NextTimeReady = (gvHero13DivineJudgment_NextCooldown and gvHero13DivineJudgment_NextCooldown[_player]) or gvHero13.Cooldown.DivineJudgment * 1000
			else
				NextTimeReady = (gvHero13.LastTimeUsed.DivineJudgment + gvHero13.Cooldown.DivineJudgment) * 1000
			end
			local time = Logic.GetTimeMs()
			local diff = time - NextTimeReady - tab.ThresholdMs
			if diff > 0 then
				local DamageFactorBonus = tab.EverySeconds * 1000 * tab.DamageFactorBonusPerMs
				local RangeFactorBonus = tab.EverySeconds * 1000 * tab.RangeFactorBonusPerMs
				gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactorBonus[_player] = math.min(tab.MaxDamageFactorBonus, gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactorBonus[_player] + DamageFactorBonus)
				gvHero13.AbilityProperties.DivineJudgment.Judgment.RangeFactorBonus[_player] = math.min(tab.MaxRangeFactorBonus, gvHero13.AbilityProperties.DivineJudgment.Judgment.RangeFactorBonus[_player] + RangeFactorBonus)
			else
				gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactorBonus[_player] = 0
				gvHero13.AbilityProperties.DivineJudgment.Judgment.RangeFactorBonus[_player] = 0
			end
		else
			if gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactorBonus[_player] > 0 then
				gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactorBonus[_player] = 0
				gvHero13.AbilityProperties.DivineJudgment.Judgment.RangeFactorBonus[_player] = 0
			end
		end
	end
end

Hero14_Lifesteal_Trigger = function(_heroID, _starttime)

	local heroplayer = Logic.EntityGetPlayer(_heroID)

	if not Logic.IsEntityAlive(_heroID) then
		gvHero14.LifestealAura.TriggerIDs[heroplayer] = nil
		return true
	end

	local time = Logic.GetTime()
	local duration = gvHero14.LifestealAura.Duration
	local daytimefactor = 1

	if IsNighttime() then
		daytimefactor = gvHero14.LifestealAura.NighttimeFactor
	end

	if time <= (_starttime + duration) then
		local attacker = Event.GetEntityID1()
		local attackerplayer = Logic.EntityGetPlayer(attacker)

		if attackerplayer == heroplayer then
			local heropos = GetPosition(_heroID)
			local attackerpos = GetPosition(attacker)
			local distance = GetDistance(heropos, attackerpos)

			if distance <= gvHero14.LifestealAura.Range then
				local maxhp = Logic.GetEntityMaxHealth(_heroID)
				local currhp = Logic.GetEntityHealth(_heroID)

				if currhp < maxhp then
					local cat = Logic.IsEntityInCategory(attacker, EntityCategories.EvilLeader)
					local dmg = CEntity.TriggerGetDamage()

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

Hero14_MovementEffects_Player = function(_EntityID)

	if IsNighttime() then

		if Logic.IsEntityAlive(_EntityID) then
			local posX, posY = Logic.GetEntityPosition(_EntityID)
			local playerID = Logic.EntityGetPlayer(_EntityID)

			if Logic.GetCurrentTaskList(_EntityID) == "TL_HERO14_WALK" then
				Logic.CreateEffect(GGL_Effects.FXHero14_Lightning, posX, posY)
				Logic.CreateEffect(gvHero14.MovementEffects[math.random(1,4)], posX, posY)
				gvHero14.NighttimeAura.TriggerIDs.BurnEffect[playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero14_BurnEffect_ApplyDamage",1,{},{_EntityID, playerID, posX, posY})

			elseif Logic.GetCurrentTaskList(_EntityID) == "TL_MILITARY_IDLE" or not Logic.IsEntityMoving(_EntityID) then
				if Counter.Tick2("Hero14_MovementEffects_Player"..playerID.."_CounterID", 3) then
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

	if entityType == Entities.PU_Hero14 then
		local playerID = Logic.EntityGetPlayer(entityID)
		gvHero14.NighttimeAura.TriggerIDs.Start[playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero14_MovementEffects_Player",1,{},{entityID})
	end

end

function OnDovbar_Created()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PU_Hero13 then
		local playerID = Logic.EntityGetPlayer(entityID)
		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Hero13_DivineJudgment_CalculateBonusEffects",1,{},{entityID, playerID})
	end

end

gvCommandCheck = {FunctionNameByCommand = {[0] = Logic.GroupAttack,
											[3] = Logic.GroupDefend,
											[4] = Logic.GroupPatrol,
											[5] = Logic.GroupAttackMove,
											[6] = Logic.GroupGuard,
											[7] = Logic.GroupStand,
											[8] = Logic.MoveSettler}}
function CheckForCommandAbortedJob(_id, _command, ...)
	if not IsValid(_id) or GetArmyByLeaderID(_id) ~= nil then
		gvCommandCheck[_id] = nil
		return true
	end
	if Logic.LeaderGetCurrentCommand(_id) ~= _command then
		if _command == 4 and gvCommandCheck[_id].PatrolPoints and next(gvCommandCheck[_id].PatrolPoints) then
			for i = 1,table.getn(gvCommandCheck[_id].PatrolPoints) do
				Logic.GroupAddPatrolPoint(_id, unpack(gvCommandCheck[_id].PatrolPoints[i]))
			end
		end
		gvCommandCheck[_id] = nil
		gvCommandCheck.FunctionNameByCommand[_command](_id, unpack(arg))
		return true
	end
end

gvEvil = {Troll = {AoERange = 500, AoEEffect = GGL_Effects.FXCrushBuilding, LastTimeUsed = {}}}
function EvilTroll_AoEDMG()

	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)

	if attype == Entities.CU_Evil_Troll1 then
		local last = gvEvil.Troll.LastTimeUsed[attacker]
		if not last or (Logic.GetTime() - last >= 1) then
			gvEvil.Troll.LastTimeUsed[attacker] = Logic.GetTime()
			local target = Event.GetEntityID2()
			local targetpos = GetPosition(target)
			local task = Logic.GetCurrentTaskList(attacker)
			local dmg = Logic.GetEntityDamage(attacker)
			Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "EvilTroll_DelayedAoEDMG", 1, {}, {attacker, targetpos.X, targetpos.Y, gvEvil.Troll.AoERange, dmg})
		end
	end
end
function EvilTroll_DelayedAoEDMG(_id, _x, _y, _range, _dmg)
	CEntity.DealDamageInArea(_id, _x, _y, _range, _dmg)
	Logic.CreateEffect(gvEvil.Troll.AoEEffect, _x, _y)
	return true
end

-- XMas Tower Trigger
function XMasTowerUpgraded()

	local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

	if entityType == Entities.PB_Tower2_Ballista then
		local posX, posY = Logic.GetEntityPosition(entityID)
		local tower = ({Logic.GetEntitiesInArea(Entities.PB_Tower2, posX, posY, 1, 1)})[2]
		if tower then
			if Logic.GetFoundationTop(tower) ~= entityID then
				if GetEntityHealth(tower) > 0 then
					local id = Logic.CreateEntity(Entities.PB_Tower2_Ballista, posX, posY, 0, Logic.EntityGetPlayer(entityID))
					Logic.SuspendEntity(id)
					Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "XMasTowerUpgradeComplete", 1, {}, {tower, id})
				end
			end
		end
	end
end
function XMasTowerUpgradeComplete(_tower, _ballista)

	local entityID = Event.GetEntityID()
    if entityID == _tower then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "XMasTowerDelayedBallistaDestroy", 1, {}, {_ballista})
		return true
	end
end
function XMasTowerDelayedBallistaDestroy(_ballista)
	if Logic.IsEntityDestroyed(_ballista) then
		return true
	end
	Logic.ResumeEntity(_ballista)
	Logic.DestroyEntity(_ballista)
	return true
end