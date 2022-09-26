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
				if IsNighttime then
					calcvalue = calcvalue * 2
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
			LifestealAura = {LastTimeUsed = - 6000, Cooldown = 90, Duration = 45, Range = 800, LifestealAmount = 0.2},
			RisingEvil = {LastTimeUsed = - 6000, Cooldown = 300, Range = 1000, TowerTreshold = 5,
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
				local towerpos = GetPosition(towerID)
				Logic.CreateEffect(GGL_Effects.FXHero14_Poison, towerpos.X, towerpos.Y)
				Logic.CreateEffect(GGL_Effects.FXHero14_Fear, towerpos.X, towerpos.Y)
				Logic.CreateEffect(GGL_Effects.FXCrushBuilding, towerpos.X, towerpos.Y)
				ReplaceEntity(towerID, Entities.PU_Hero14_EvilTower)
				if IsNighttime() then
					gvHero14.RisingEvil.LastTimeUsed = gvHero14.RisingEvil.LastTimeUsed - 120
					if gvHero14.RisingEvil.NextCooldown then
						if gvHero14.RisingEvil.NextCooldown[playerID] then
							gvHero14.RisingEvil.NextCooldown[playerID] = gvHero14.RisingEvil.NextCooldown[playerID] - 120
						end
					end
				else
					if Logic.GetNumberOfEntitiesOfTypeOfPlayer(playerID, Entities.PU_Hero14_EvilTower) + Logic.GetNumberOfEntitiesOfTypeOfPlayer(playerID, Entities.CB_Evil_Tower1) >= gvHero14.RisingEvil.TowerTreshold then
						Logic.AddWeatherElement(1, 300, 1, NighttimeGFXSets[math.random(1,7)], 5, 15)
					end
				end
			end},
			NighttimeAura = {Range = 600, Damage = 30, 
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
					if Logic.IsEntityInCategory(eID, EntityCategories.EvilLeader) ~= 1 then
						local damage = gvHero14.NighttimeAura.Damage + math.random(gvHero14.NighttimeAura.Damage)
						if Logic.IsLeader(eID) == 1 and Logic.IsEntityAlive(eID) then
							local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
							if Soldiers[1] > 0 then
								for i = 2, Soldiers[1] + 1 do
									local soldierdmg = math.max(damage - ((i - 2) * damage/10), damage/5)
									if soldierdmg >= Logic.GetEntityHealth(Soldiers[i]) then						
										BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(Soldiers[i]), "Settler")							
									end
									if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(Soldiers[i])) == Diplomacy.Hostile) then
										ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
										ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(soldierdmg, Logic.GetEntityHealth(Soldiers[i])))
										ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
									end
									Logic.HurtEntity(Soldiers[i], soldierdmg)
									if _G["Hero14LifestealTriggerID_"..pID] then
										Logic.HealEntity(_heroID, soldierdmg * gvHero14.LifestealAura.LifestealAmount)
										Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
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
								if _G["Hero14LifestealTriggerID_"..pID] then
									Logic.HealEntity(_heroID, damage * gvHero14.LifestealAura.LifestealAmount)
									Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
								end
							end
						elseif Logic.IsBuilding(eID) == 1 then 
							if gvLightning.IsLightningProofBuilding(eID) ~= true then
								if Logic.IsConstructionComplete(eID) == 1 then
									if Logic.GetEntityType(eID) ~= Entities.CB_Evil_Tower1 and Logic.GetEntityType(eID) ~= Entities.PU_Hero14_EvilTower then
										if damage >= Logic.GetEntityHealth(eID) then						
											BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Building")							
										end
										if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
											ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToBuildings"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToBuildings"] + (math.min(damage, Logic.GetEntityHealth(eID)))
											ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
											ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
										end
										Logic.HurtEntity(eID, damage)
										if _G["Hero14LifestealTriggerID_"..pID] then
											Logic.HealEntity(_heroID, damage * gvHero14.LifestealAura.LifestealAmount)
											Logic.CreateEffect(GGL_Effects.FXSalimHeal, pos.X, pos.Y)
										end										
									end
								end
							end
						elseif Logic.IsSerf(eID) == 1 or Logic.IsEntityInCategory(eID, EntityCategories.Cannon) == 1 then
							if damage >= Logic.GetEntityHealth(eID) then						
								BS.ManualUpdate_KillScore(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID), "Settler")							
							end
							if ExtendedStatistics and (Logic.GetDiplomacyState(Logic.EntityGetPlayer(_heroID), Logic.EntityGetPlayer(eID)) == Diplomacy.Hostile) then
								ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] = ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)]["DamageToUnits"] + (math.min(damage, Logic.GetEntityHealth(eID)))
								ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] = (ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID] or 0) + (math.min(damage, Logic.GetEntityHealth(eID)))
								ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage = math.max(ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage, ExtendedStatistics.Players[Logic.EntityGetPlayer(_heroID)].MostDeadlyEntityDamage_T[_heroID])
							end
							Logic.HurtEntity(eID, damage)
							if _G["Hero14LifestealTriggerID_"..pID] then
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
							  }
			}