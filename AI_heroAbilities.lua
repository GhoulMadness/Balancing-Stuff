gvHeroAbilities = {	UnitsTreshold = 10,
					DefaultRange = 800,
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
																		(SendEvent or CSendEvent).HeroInflictFear(_heroID)
																	end,
									[Abilities.AbilityPlaceBomb] = 	function(_heroID, _posX, _posY)
																		(SendEvent or CSendEvent).HeroPlaceBomb(_heroID, _posX, _posY)
																	end,
									[Abilities.AbilityBuildCannon] = function(_heroID, _posX, _posY)
																		(SendEvent or CSendEvent).HeroPlaceCannon(_heroID, _posX, _posY)
																	end,
									[Abilities.AbilityRangedEffect] = 	function(_heroID)
																			(SendEvent or CSendEvent).HeroActivateAura(_heroID)
																		end,
									[Abilities.AbilityCircularAttack] = function(_heroID)
																			(SendEvent or CSendEvent).HeroCircularAttack(_heroID)
																		end,
									[Abilities.AbilitySummon] = function(_heroID)
																	(SendEvent or CSendEvent).HeroSummon(_heroID)
																end,
									[Abilities.AbilityConvertSettlers] = function(_heroID, _targetID)
																			(SendEvent or CSendEvent).HeroConvertSettler(_heroID, _targetID)
																		end,
									[Abilities.AbilityShuriken] = 	function(_heroID, _targetID)
																		(SendEvent or CSendEvent).HeroShuriken(_heroID, _targetID)
																	end,
									[Abilities.AbilitySniper] = function(_heroID, _targetID)
																	(SendEvent or CSendEvent).HeroSnipeSettler(_heroID, _targetID)
																end,
									["StoneArmor"] = function(_heroID) end,
									["DivineJudgment"] = function(_heroID) end,
									["CallOfDarkness"] = function(_heroID) gvHero14.CallOfDarkness.SpawnTroops(_heroID) end,
									["LifestealAura"] = function(_heroID) end,
									["RisingEvil"] = function(_heroID, _targetID) end
								},
					CheckByAbility = {	[Abilities.AbilityInflictFear] = function(_heroID, _posX, _posY, _player)
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				return true
																			end
																			return false
																		end,
										[Abilities.AbilityPlaceBomb] = 	function(_heroID, _posX, _posY, _player)
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				local postable = GetNodesInCircleAndRange({X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																				local pos = GetPositionClump(postable, 500, 100)
																				return true, pos.X, pos.Y
																			end
																			return false
																		end,
										[Abilities.AbilityBuildCannon] = function(_heroID, _posX, _posY, _player)
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				return true, _posX, _posY
																			end
																			return false
																		end,
										[Abilities.AbilityRangedEffect] = 	function(_heroID, _posX, _posY, _player)
																				local numE = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange*2)
																				local numA = GetNumberOfAlliesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																				if numE >= gvHeroAbilities.UnitsTreshold and numA >= gvHeroAbilities.UnitsTreshold then
																					return true
																				end
																				return false
																			end,
										[Abilities.AbilityCircularAttack] = function(_heroID, _posX, _posY, _player)
																				local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																				if num >= gvHeroAbilities.UnitsTreshold then
																					return true
																				end
																				return false
																			end,
										[Abilities.AbilitySummon] = function(_heroID, _posX, _posY, _player)
																		local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																		if num >= gvHeroAbilities.UnitsTreshold then
																			return true
																		end
																		return false
																	end,
										[Abilities.AbilityConvertSettlers] = function(_heroID, _posX, _posY, _player)
																				local id = GetNearestEnemyInRange(_player, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange, true)
																				if id then
																					return true, id
																				end
																				return false
																			end,
										[Abilities.AbilityShuriken] = 	function(_heroID, _posX, _posY, _player)
																			local num = GetNumberOfEnemiesInRange(_player, {EntityCategories.Leader, EntityCategories.Soldier}, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange)
																			if num >= gvHeroAbilities.UnitsTreshold then
																				local id = GetNearestEnemyInRange(_player, {X = _posX, Y = _posY}, gvHeroAbilities.DefaultRange, true)
																				return true, id
																			end
																			return false
																		end,
										[Abilities.AbilitySniper] = function(_heroID, _posX, _posY, _player)
																		local enemies = BS.GetAllEnemyPlayerIDs(_player)
																		for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(enemies)), CEntityIterator.OfCategoryFilter(EntityCategories.Hero),
																		CEntityIterator.InCircleFilter(_posX, _posY, gvHeroAbilities.DefaultRange)) do
																			if Logic.IsEntityAlive(eID) then
																				return true, eID
																			end
																		end
																		return false
																	end,
										["StoneArmor"] = function(_heroID, _posX, _posY, _player)
															return false
														end,
										["DivineJudgment"] = function(_heroID, _posX, _posY, _player)
																return false
															end,
										["CallOfDarkness"] = function(_heroID, _posX, _posY, _player)
																return false
															end,
										["LifestealAura"] = function(_heroID, _posX, _posY, _player)
																return false
															end,
										["RisingEvil"] = function(_heroID, _posX, _posY, _player)
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
							if Logic.HeroGetAbiltityChargeSeconds(_heroID, ability) == Logic.HeroGetAbilityRechargeTime(_heroID, ability) then
								local allowed, param1, param2 = gvHeroAbilities.CheckByAbility[ability](_heroID, posX, posY, player)
								if allowed then
									gvHeroAbilities.CastAbility[ability](_heroID, param1, param2)
									return true
								end
							else
								return
							end
						end
					end
					}
