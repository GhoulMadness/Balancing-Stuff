gvHeroAbilities = {	UnitsTreshold = 10,
					DefaultRange = 800,
					WoundedTreshold = 20,
					HighlyWoundedTreshold = 5,
					CurrentlyMovingToReachCastDestination = {},
					HerosWithHealingAura = {[Entities.PU_Hero3] = true,
											[Entities.CU_Barbarian_Hero] = true},
					AuraAffectedCategoryByHeroType = {	[Entities.PU_Hero3] = "Allies",
														[Entities.PU_Hero4] = "Allies",
														[Entities.PU_Hero6] = "Allies",
														[Entities.PU_Hero10] = "LongRange",
														[Entities.PU_Hero13] = "Allies",
														[Entities.PU_Hero14] = "Own",
														[Entities.CU_Barbarian_Hero] = "Own",
														[Entities.CU_Mary_de_Mortfichet] = "Hostile",
														[Entities.CU_BlackKnight] = "Hostile"},
					InternalAbilities = {InitialCooldown = - 6000,
										["Hero13"] = {	["StoneArmor"] = {LastTimeUsed = {}, Cooldown = gvHero13.Cooldown.StoneArmor},
														["DivineJudgment"] = {LastTimeUsed = {}, Cooldown = gvHero13.Cooldown.DivineJudgment}},
										["Hero14"] = {	["CallOfDarkness"] = {LastTimeUsed = {}, Cooldown = gvHero14.CallOfDarkness.Cooldown},
														["LifestealAura"] = {LastTimeUsed = {}, Cooldown = gvHero14.LifestealAura.Cooldown},
														["RisingEvil"] = {LastTimeUsed = {}, Cooldown = gvHero14.RisingEvil.Cooldown}}},
					AbilitiesByHero = {	[Entities.PU_Hero1] = {Abilities.AbilityInflictFear},
										[Entities.PU_Hero1a] = {Abilities.AbilityInflictFear},
										[Entities.PU_Hero1b] = {Abilities.AbilityInflictFear},
										[Entities.PU_Hero1c] = {Abilities.AbilityInflictFear},
										[Entities.PU_Hero2] = {Abilities.AbilityPlaceBomb, Abilities.AbilityBuildCannon},
										[Entities.PU_Hero3] = {Abilities.AbilityBuildCannon, Abilities.AbilityRangedEffect},
										[Entities.PU_Hero4] = {Abilities.AbilityRangedEffect, Abilities.AbilityCircularAttack},
										[Entities.PU_Hero5] = {Abilities.AbilitySummon},
										[Entities.PU_Hero6] = {Abilities.AbilityConvertSettlers, Abilities.AbilityRangedEffect},
										[Entities.CU_BlackKnight] = {Abilities.AbilityInflictFear, Abilities.AbilityRangedEffect},
										[Entities.CU_Mary_de_Mortfichet] = {Abilities.AbilityCircularAttack, Abilities.AbilityRangedEffect},
										[Entities.CU_Barbarian_Hero] = {Abilities.AbilitySummon, Abilities.AbilityRangedEffect},
										[Entities.PU_Hero10] = {Abilities.AbilitySniper, Abilities.AbilityRangedEffect},
										[Entities.PU_Hero11] = {Abilities.AbilityShuriken, Abilities.AbilityInflictFear},
										[Entities.CU_Evil_Queen] = {Abilities.AbilityShuriken, Abilities.AbilityCircularAttack},
										[Entities.PU_Hero13] = {"StoneArmor", Abilities.AbilityRangedEffect, "DivineJudgment"},
										[Entities.PU_Hero14] = {"CallOfDarkness", "LifestealAura", "RisingEvil"}
									},
					CastAbility = {	[Abilities.AbilityInflictFear] = function(_heroID)
																		Logic.GroupStand(_heroID);
																		(SendEvent or CSendEvent).HeroInflictFear(_heroID)
																		CLogger.Log("AIHeroInflictFear", _heroID)
																	end,
									[Abilities.AbilityPlaceBomb] = 	function(_heroID, _posX, _posY)
																		gvHeroAbilities.CurrentlyMovingToReachCastDestination[_heroID] = true;
																		(SendEvent or CSendEvent).HeroPlaceBomb(_heroID, _posX, _posY)
																		CLogger.Log("AIHeroPlaceBomb", _heroID, _posX, _posY)
																	end,
									[Abilities.AbilityBuildCannon] = function(_heroID, _posX, _posY)
																		gvHeroAbilities.CurrentlyMovingToReachCastDestination[_heroID] = true;
																		(SendEvent or CSendEvent).HeroPlaceCannon(_heroID, _posX, _posY)
																		CLogger.Log("AIHeroPlaceCannon", _heroID, _posX, _posY)
																	end,
									[Abilities.AbilityRangedEffect] = 	function(_heroID)
																			(SendEvent or CSendEvent).HeroActivateAura(_heroID)
																			CLogger.Log("AIHeroActivateAura", _heroID)
																		end,
									[Abilities.AbilityCircularAttack] = function(_heroID)
																			Logic.GroupStand(_heroID);
																			(SendEvent or CSendEvent).HeroCircularAttack(_heroID)
																			CLogger.Log("AIHeroCircularAttack", _heroID)
																		end,
									[Abilities.AbilitySummon] = function(_heroID)
																	(SendEvent or CSendEvent).HeroSummon(_heroID)
																	CLogger.Log("AIHeroSummon", _heroID)
																end,
									[Abilities.AbilityConvertSettlers] = function(_heroID, _targetID)
																			Logic.GroupStand(_heroID);
																			(SendEvent or CSendEvent).HeroConvertSettler(_heroID, _targetID)
																			CLogger.Log("AIHeroConvertSettler", _heroID, _targetID)
																		end,
									[Abilities.AbilityShuriken] = 	function(_heroID, _targetID)
																		Logic.GroupStand(_heroID);
																		(SendEvent or CSendEvent).HeroShuriken(_heroID, _targetID)
																		CLogger.Log("AIHeroShuriken", _heroID, _targetID)
																	end,
									[Abilities.AbilitySniper] = function(_heroID, _targetID)
																	Logic.GroupStand(_heroID);
																	(SendEvent or CSendEvent).HeroSnipeSettler(_heroID, _targetID)
																	CLogger.Log("AIHeroSnipeSettler", _heroID, _targetID)
																end,
									["StoneArmor"] = function(_heroID, _player)
														local starttime = Logic.GetTimeMs()
														gvHeroAbilities.InternalAbilities.Hero13.StoneArmor.LastTimeUsed[_player] = starttime/1000
														if not gvHero13.TriggerIDs.StoneArmor.DamageStoring[_player] then
															gvHero13.TriggerIDs.StoneArmor.DamageStoring[_player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_StoneArmor_StoreDamage", 1, nil, {_heroID, starttime})
														end
														if not gvHero13.TriggerIDs.StoneArmor.DamageApply[_player] then
															gvHero13.TriggerIDs.StoneArmor.DamageApply[_player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_StoneArmor_ApplyDamage", 1, nil, {_heroID, starttime})
														end
														CLogger.Log("AIHeroStoneArmor", _heroID)
													end,
									["DivineJudgment"] = function(_heroID, _player)
															local starttime = Logic.GetTimeMs()
															local basedmg = Logic.GetEntityDamage(_heroID)
															local posX,posY = Logic.GetEntityPosition(_heroID)
															gvHeroAbilities.InternalAbilities.Hero13.DivineJudgment.LastTimeUsed[_player] = starttime/1000
															if not gvHero13.TriggerIDs.DivineJudgment.DMGBonus[_player] then
																gvHero13.TriggerIDs.DivineJudgment.DMGBonus[_player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_DMGBonus_Trigger", 1, nil, {_heroID, starttime})
																Logic.CreateEffect(GGL_Effects.FXKerberosFear, posX, posY)
															end
															if not gvHero13.TriggerIDs.DivineJudgment.Judgment[_player] then
																gvHero13.TriggerIDs.DivineJudgment.Judgment[_player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_DivineJudgment_Trigger", 1, nil, {_heroID,basedmg,posX,posY,starttime})
															end
															CLogger.Log("AIHeroDivineJudgment", _heroID)
														end,
									["CallOfDarkness"] = function(_heroID, _player)
															gvHero14.CallOfDarkness.SpawnTroops(_heroID)
															gvHeroAbilities.InternalAbilities.Hero14.CallOfDarkness.LastTimeUsed[_player] = Logic.GetTime()
															CLogger.Log("AIHeroCallOfDarkness", _heroID)
														end,
									["LifestealAura"] = function(_heroID, _player)
															local starttime = Logic.GetTime()
															gvHeroAbilities.InternalAbilities.Hero14.LifestealAura.LastTimeUsed[_player] = starttime;
															(SendEvent or CSendEvent).HeroActivateAura(_heroID)
															gvHero14.LifestealAura.TriggerIDs[_player] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero14_Lifesteal_Trigger", 1, nil, {_heroID, starttime})
															CLogger.Log("AIHeroLifestealAura", _heroID)
														end,
									["RisingEvil"] = function(_heroID, _player)
														local posX, posY = Logic.GetEntityPosition(_heroID)
														for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyTypeFilter(Entities.PB_Tower2, Entities.PB_DarkTower2), CEntityIterator.InCircleFilter(posX, posY, gvHero14.RisingEvil.Range*3)) do
															if GetDistance(eID, _heroID) <= gvHero14.RisingEvil.Range then
																Logic.GroupStand(_heroID)
																gvHero14.RisingEvil.SpawnEvilTower(_heroID)
																gvHeroAbilities.InternalAbilities.Hero14.RisingEvil.LastTimeUsed[_player] = Logic.GetTime()
																CLogger.Log("AIHeroRisingEvil", _heroID)
															else
																Logic.MoveSettler(_heroID, Logic.GetEntityPosition(eID))
															end
															break
														end
													end
								},
					CheckByAbility = {	[Abilities.AbilityInflictFear] = function(_heroID, _posX, _posY, _player)
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				return true
																			end
																			return false
																		end,
										[Abilities.AbilityPlaceBomb] = 	function(_heroID, _posX, _posY, _player)
																			if gvHeroAbilities.CurrentlyMovingToReachCastDestination[_heroID] then
																				return false
																			end
																			local t = GetEnemiesPositionTableInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																			if table.getn(t) >= gvHeroAbilities.UnitsTreshold then
																				local pos = GetPositionClump(t, 500, 100)
																				return true, pos.X, pos.Y
																			end
																			return false
																		end,
										[Abilities.AbilityBuildCannon] = function(_heroID, _posX, _posY, _player)
																			if gvHeroAbilities.CurrentlyMovingToReachCastDestination[_heroID] then
																				return false
																			end
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				local posX, posY = EvaluateNearestUnblockedPosition(_posX, _posY, 1000, 100, false)
																				return true, (posX or _posX), (posY or _posY)
																			end
																			return false
																		end,
										[Abilities.AbilityRangedEffect] = 	function(_heroID, _posX, _posY, _player, _htype)
																				if gvHeroAbilities.HerosWithHealingAura[_htype] then
																					local health = GetEntityHealth(_heroID)
																					if health <= gvHeroAbilities.WoundedTreshold
																					or AreWoundedEntitiesNearby(_player, {EntityCategories.Hero, EntityCategories.Cannon}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange, gvHeroAbilities.HighlyWoundedTreshold, gvHeroAbilities.AuraAffectedCategoryByHeroType[_htype]) then
																						return true
																					end
																					return false
																				end
																				local numE = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																				local numA = GetNumberOfAlliesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																				if numE >= gvHeroAbilities.UnitsTreshold and numA >= gvHeroAbilities.UnitsTreshold then
																					return true
																				end
																				return false
																			end,
										[Abilities.AbilityCircularAttack] = function(_heroID, _posX, _posY, _player)
																				local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																				if num >= gvHeroAbilities.UnitsTreshold then
																					return true
																				end
																				return false
																			end,
										[Abilities.AbilitySummon] = function(_heroID, _posX, _posY, _player)
																		local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																		if num >= gvHeroAbilities.UnitsTreshold then
																			return true
																		end
																		return false
																	end,
										[Abilities.AbilityConvertSettlers] = function(_heroID, _posX, _posY, _player)
																				local id = GetNearestEnemyInRange(_player, {X = _posX, Y = _posY}, 1400, true)
																				if id then
																					return true, id
																				end
																				return false
																			end,
										[Abilities.AbilityShuriken] = 	function(_heroID, _posX, _posY, _player)
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, 2000)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				local id = GetNearestEnemyInRange(_player, {X = _posX, Y = _posY}, 2000, true)
																				return true, id
																			end
																			return false
																		end,
										[Abilities.AbilitySniper] = function(_heroID, _posX, _posY, _player)
																		local enemies = BS.GetAllEnemyPlayerIDs(_player)
																		for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(enemies)), CEntityIterator.OfAnyCategoryFilter(EntityCategories.Hero, EntityCategories.Cannon),
																		CEntityIterator.InCircleFilter(_posX, _posY, 3800)) do
																			if Logic.IsEntityAlive(eID) then
																				return true, eID
																			end
																		end
																		return false
																	end,
										["StoneArmor"] = function(_heroID, _posX, _posY, _player)
															if GetEntityHealth(_heroID) <= gvHeroAbilities.WoundedTreshold then
																local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																if num >= gvHeroAbilities.UnitsTreshold then
																	return true
																end
															end
															return false
														end,
										["DivineJudgment"] = function(_heroID, _posX, _posY, _player)
																if GetEntityHealth(_heroID) <= gvHeroAbilities.HighlyWoundedTreshold
																or (gvHero13.AbilityProperties.StoneArmor.DamageStored[_player]
																and (gvHero13.AbilityProperties.StoneArmor.DamageStored[_player] * gvHero13.AbilityProperties.StoneArmor.DamageFactor >= Logic.GetEntityHealth(_heroID)))
																then
																	local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																	if num >= gvHeroAbilities.UnitsTreshold then
																		return true
																	end
																end
																return false
															end,
										["CallOfDarkness"] = function(_heroID, _posX, _posY, _player)
																local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																if num >= gvHeroAbilities.UnitsTreshold then
																	return true
																end
																return false
															end,
										["LifestealAura"] = function(_heroID, _posX, _posY, _player)
																local numE = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																local numA = GetNumberOfAlliesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																if numE >= gvHeroAbilities.UnitsTreshold and numA >= gvHeroAbilities.UnitsTreshold then
																	return true
																end
																return false
															end,
										["RisingEvil"] = function(_heroID, _posX, _posY, _player)
															for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_player), CEntityIterator.OfAnyTypeFilter(Entities.PB_Tower2, Entities.PB_DarkTower2), CEntityIterator.InCircleFilter(_posX, _posY, gvHero14.RisingEvil.Range*3)) do
																return true
															end
															return false
														end
									},
					HeroAbilityControl = function(_heroID)
						if not Logic.IsEntityAlive(_heroID) then
							return
						end
						local htype = Logic.GetEntityType(_heroID)
						local posX, posY = Logic.GetEntityPosition(_heroID)
						local player = Logic.EntityGetPlayer(_heroID)
						for i = 1,table.getn(gvHeroAbilities.AbilitiesByHero[htype]) do
							local ability = gvHeroAbilities.AbilitiesByHero[htype][i]
							if type(ability) == "number" then
								if Logic.HeroGetAbiltityChargeSeconds(_heroID, ability) == Logic.HeroGetAbilityRechargeTime(_heroID, ability) then
									local allowed, param1, param2 = gvHeroAbilities.CheckByAbility[ability](_heroID, posX, posY, player, htype)
									if allowed then
										gvHeroAbilities.CastAbility[ability](_heroID, param1, param2)
										return true
									end
								else
									if gvHeroAbilities.CurrentlyMovingToReachCastDestination[_heroID] then
										gvHeroAbilities.CurrentlyMovingToReachCastDestination[_heroID] = nil
									end
								end
							else
								local str = BS.GetTableStrByHeroType(htype)
								local TimePassed = math.floor(Logic.GetTime() - (gvHeroAbilities.InternalAbilities[str][ability].LastTimeUsed[player]
								or gvHeroAbilities.InternalAbilities.InitialCooldown))
								local cooldown = gvHeroAbilities.InternalAbilities[str][ability].Cooldown
								if TimePassed >= cooldown then
									local allowed, param1, param2 = gvHeroAbilities.CheckByAbility[ability](_heroID, posX, posY, player)
									if allowed then
										gvHeroAbilities.CastAbility[ability](_heroID, player, param1, param2)
										return true
									end
								end
							end
						end
					end
					}
