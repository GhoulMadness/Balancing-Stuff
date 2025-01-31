gvHero14 = {CallOfDarkness = {LastTimeUsed = - 6000, Cooldown = 120,
			SpawnTroops = function(_heroID)
				if not Logic.IsEntityAlive(_heroID) then
					return
				end
				if Logic.IsHero(_heroID) ~= 1 then
					return
				end
				local xp = math.min(CEntity.GetLeaderExperience(_heroID), 1000)
				local hppercent = GetEntityHealth(_heroID)
				local calcvalue = xp/hppercent
				local playerID = Logic.EntityGetPlayer(_heroID)
				local pos = GetPosition(_heroID)
				if IsNighttime() then
					calcvalue = calcvalue * 2.5
				end
				if calcvalue < 10 then
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Bearman1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue >= 10 and calcvalue < 25 then
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Bearman1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Skirmisher1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue >= 25 and calcvalue < 45 then
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Bearman2, 0, 8, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Skirmisher1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue >= 45 and calcvalue < 70 then
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Bearman1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Bearman2, 0, 8, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Skirmisher1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_Skirmisher2, 0, 8, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue > 70 then
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_BearmanElite, 0, 0, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_SkirmisherElite, 0, 0, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerID, Entities.PU_Hero14_SkirmisherElite, 0, 0, pos.X, pos.Y, 0, 0, 0, 0)
				end
			end},
			LifestealAura = {LastTimeUsed = - 6000, Cooldown = 90, Duration = 45, Range = 800, LifestealAmount = 0.2, TriggerIDs = {}, NighttimeFactor = 1.5, FogPeopleBonusFactor = 3},
			RisingEvil = {LastTimeUsed = - 6000, Cooldown = 300, Range = 1000, TowerTreshold = 5, TriggerIDs = {},
			SpawnEvilTower = function(_heroID)
				if not Logic.IsEntityAlive(_heroID) then
					return
				end
				if Logic.IsHero(_heroID) ~= 1 then
					return
				end
				local playerID = Logic.EntityGetPlayer(_heroID)
				local pos = GetPosition(_heroID)
				local towerID = ({Logic.GetPlayerEntitiesInArea(playerID, Entities.PB_Tower2, pos.X, pos.Y, gvHero14.RisingEvil.Range, 1)})[2]
				if not towerID then
					towerID = ({Logic.GetPlayerEntitiesInArea(playerID, Entities.PB_DarkTower2, pos.X, pos.Y, gvHero14.RisingEvil.Range, 1)})[2]
				end
				local towerpos = GetPosition(towerID)
				local health = GetEntityHealth(towerID)
				Logic.CreateEffect(GGL_Effects.FXHero14_Poison, towerpos.X, towerpos.Y)
				Logic.CreateEffect(GGL_Effects.FXHero14_Fear, towerpos.X, towerpos.Y)
				Logic.CreateEffect(GGL_Effects.FXCrushBuilding, towerpos.X, towerpos.Y)
				local id = ReplaceEntity(towerID, Entities.PU_Hero14_EvilTower)
				SetHealth(id, health)
				if IsNighttime() then
					if playerID == GUI.GetPlayerID() then
						gvHero14.RisingEvil.LastTimeUsed = gvHero14.RisingEvil.LastTimeUsed - 120
					end
					if gvHero14.RisingEvil.NextCooldown then
						if gvHero14.RisingEvil.NextCooldown[playerID] then
							gvHero14.RisingEvil.NextCooldown[playerID] = gvHero14.RisingEvil.NextCooldown[playerID] - 120
						end
					end
				else
					local num = Logic.GetNumberOfEntitiesOfTypeOfPlayer(playerID, Entities.PU_Hero14_EvilTower) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(playerID, Entities.CB_Evil_Tower1)
					if num >= gvHero14.RisingEvil.TowerTreshold then
						local wtype = Logic.GetWeatherState()
						Logic.AddWeatherElement(wtype, math.min(120 + num * 15, 360), 0, NighttimeGFXSets[wtype][math.random(1, table.getn(NighttimeGFXSets[wtype]))], 5, 15)
					end
				end
			end},
			NighttimeAura = {Range = 600, Damage = 30, MaxDuration = 5, TriggerIDs = {Start = {}, BurnEffect = {}},
			ApplyDamage = function(_heroID, posX, posY)
				if not Logic.IsEntityAlive(_heroID) then
					return
				end
				if Logic.IsHero(_heroID) ~= 1 then
					return
				end
				local pos = GetPosition(_heroID)
				if posX and posY then
					pos.X = posX
					pos.Y = posY
				end
				local pID = Logic.EntityGetPlayer(_heroID)
				for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsSettlerOrBuildingFilter(), CEntityIterator.InCircleFilter(pos.X, pos.Y, gvHero14.NighttimeAura.Range)) do
					local player2 = Logic.EntityGetPlayer(eID)
					if Logic.IsEntityInCategory(eID, EntityCategories.EvilLeader) ~= 1 and (pID == player2 or Logic.GetDiplomacyState(pID, player2) ~= Diplomacy.Neutral) then
						local damage = gvHero14.NighttimeAura.Damage + math.random(gvHero14.NighttimeAura.Damage)
						if Logic.IsLeader(eID) == 1 and Logic.IsEntityAlive(eID) then
							local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
							if Soldiers[1] > 0 then
								for i = 2, Soldiers[1] + 1 do
									local soldierdmg = math.max(damage - ((i - 2) * damage/10), damage/5)
									if soldierdmg >= Logic.GetEntityHealth(Soldiers[i]) then
										BS.ManualUpdate_KillScore(pID, Logic.EntityGetPlayer(Soldiers[i]), "Settler")
									end
									if ExtendedStatistics and (Logic.GetDiplomacyState(pID, Logic.EntityGetPlayer(Soldiers[i])) == Diplomacy.Hostile) then
										ExtendedStatistics.Players[pID]["DamageToUnits"] = ExtendedStatistics.Players[pID]["DamageToUnits"] + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
										ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
										ExtendedStatistics.Players[pID].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[pID].MostDeadlyEntityDamage, ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID])
									end
									Logic.HurtEntity(Soldiers[i], soldierdmg)
									if gvHero14.LifestealAura.TriggerIDs[pID] then
										Logic.HealEntity(_heroID, soldierdmg * gvHero14.LifestealAura.LifestealAmount)
										Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
									end
								end
							else
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
										BS.ManualUpdate_KillScore(pID, player2, "Settler")
									end

									if ExtendedStatistics and (Logic.GetDiplomacyState(pID, player2) == Diplomacy.Hostile) then
										ExtendedStatistics.Players[pID]["DamageToUnits"] = ExtendedStatistics.Players[pID]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
										ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
										ExtendedStatistics.Players[pID].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[pID].MostDeadlyEntityDamage, ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID])
									end
									Logic.HurtEntity(eID, damage)
									if gvHero14.LifestealAura.TriggerIDs[pID] then
										Logic.HealEntity(_heroID, damage * gvHero14.LifestealAura.LifestealAmount)
										Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
									end
								end
							end
						elseif Logic.IsBuilding(eID) == 1 then
							if gvLightning.IsLightningProofBuilding(eID) ~= true then
								if Logic.IsConstructionComplete(eID) == 1 then
									if Logic.GetEntityType(eID) ~= Entities.CB_Evil_Tower1 and Logic.GetEntityType(eID) ~= Entities.PU_Hero14_EvilTower then
										if damage >= Logic.GetEntityHealth(eID) then
											BS.ManualUpdate_KillScore(pID, player2, "Building")
										end
										if ExtendedStatistics and (Logic.GetDiplomacyState(pID, player2) == Diplomacy.Hostile) then
											ExtendedStatistics.Players[pID]["DamageToBuildings"] = ExtendedStatistics.Players[pID]["DamageToBuildings"] + (math.min(damage, Logic.GetEntityHealth(eID)))
											ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
											ExtendedStatistics.Players[pID].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[pID].MostDeadlyEntityDamage, ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID])
										end
										Logic.HurtEntity(eID, damage)
										if gvHero14.LifestealAura.TriggerIDs[pID] then
											Logic.HealEntity(_heroID, damage * gvHero14.LifestealAura.LifestealAmount)
											Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
										end
									end
								end
							end
						elseif Logic.IsSerf(eID) == 1 or Logic.IsEntityInCategory(eID, EntityCategories.Cannon) == 1 then
							if damage >= Logic.GetEntityHealth(eID) then
								BS.ManualUpdate_KillScore(pID, player2, "Settler")
							end
							if ExtendedStatistics and (Logic.GetDiplomacyState(pID, player2) == Diplomacy.Hostile) then
								ExtendedStatistics.Players[pID]["DamageToUnits"] = ExtendedStatistics.Players[pID]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
								ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
								ExtendedStatistics.Players[pID].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[pID].MostDeadlyEntityDamage, ExtendedStatistics.Players[pID].MostDeadlyEntityDamage_T[_heroID])
							end
							Logic.HurtEntity(eID, damage)
							if gvHero14.LifestealAura.TriggerIDs[pID] then
								Logic.HealEntity(_heroID, damage * gvHero14.LifestealAura.LifestealAmount)
								Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
							end
						end
					end
				end
			end},
			MovementEffects = {	[1] = GGL_Effects.FXHero14_Fire,
								[2] = GGL_Effects.FXHero14_FireMedium,
								[3] = GGL_Effects.FXHero14_FireSmall,
								[4] = GGL_Effects.FXHero14_FireLo
							  },
			AbilityNameRechargeButtons = {CallOfDarkness = "Hero14_RechargeCallOfDarkness", LifestealAura = "Hero14_RechargeLifestealAura", RisingEvil = "Hero14_RechargeRisingEvil"},
			GetRechargeButtonByAbilityName = function(_name)
				return gvHero14.AbilityNameRechargeButtons[_name]
			end,
			TriggerIDs = {Resurrection = {}}
			}