gvHeroTarget = {Thresholds = {CriticalCharge = 0.9,
							CriticalRange = 1.5,
							CriticalNumEntitiesClump = 10,
				},
				EndangeredCats = {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero, EntityCategories.Cannon},
				AffectedCatsByHero = {	[Entities.PU_Hero4] = {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero, EntityCategories.Cannon},
										[Entities.PU_Hero6] = {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero, EntityCategories.Cannon},
										[Entities.CU_Barbarian_Hero] = {EntityCategories.Leader, EntityCategories.Soldier, EntityCategories.Hero, EntityCategories.Cannon},
										[Entities.PU_Hero10] = {EntityCategories.LongRange}},
				AffectedEntCountFuncByHero = {[Entities.PU_Hero4] = GetNumberOfAlliesInRange,
											[Entities.PU_Hero6] = GetNumberOfAlliesInRange,
											[Entities.CU_Barbarian_Hero] = GetNumberOfPlayerEntitiesByCatInRange,
											[Entities.PU_Hero10] = GetNumberOfAlliesInRange},
				BombThreatRange = 500,
				BaseThreatVal = {	[Entities.PU_Hero1] = 0.5,
									[Entities.PU_Hero1a] = 0.5,
									[Entities.PU_Hero1b] = 0.5,
									[Entities.PU_Hero1c] = 0.5,
									[Entities.PU_Hero2] = 0.7,
									[Entities.PU_Hero3] = 0.6,
									[Entities.PU_Hero4] = 0.7,
									[Entities.PU_Hero5] = 0.5,
									[Entities.PU_Hero6] = 0.7,
									[Entities.CU_BlackKnight] = 0.6,
									[Entities.CU_Mary_de_Mortfichet] = 1.0,
									[Entities.CU_Barbarian_Hero] = 0.7,
									[Entities.PU_Hero10] = 0.7,
									[Entities.PU_Hero11] = 0.9,
									[Entities.CU_Evil_Queen] = 1.0,
									[Entities.PU_Hero13] = 0.8,
									[Entities.PU_Hero14] = 0.8
								},
				MainThreat = {	[Entities.PU_Hero1] = {"CloseRange", Abilities.AbilityInflictFear},
								[Entities.PU_Hero1a] = {"CloseRange", Abilities.AbilityInflictFear},
								[Entities.PU_Hero1b] = {"CloseRange", Abilities.AbilityInflictFear},
								[Entities.PU_Hero1c] = {"CloseRange", Abilities.AbilityInflictFear},
								[Entities.PU_Hero2] = {"CloseRange", Abilities.AbilityPlaceBomb},
								[Entities.PU_Hero3] = {"CloseRange", Abilities.AbilityBuildCannon},
								[Entities.PU_Hero4] = {"AbilityAtDistance", Abilities.AbilityRangedEffect},
								[Entities.PU_Hero5] = {"AbilityAtDistance", Abilities.AbilitySummon},
								[Entities.PU_Hero6] = {"AbilityAtDistance", Abilities.AbilityRangedEffect},
								[Entities.CU_BlackKnight] = {"CloseRange", Abilities.AbilityInflictFear},
								[Entities.CU_Mary_de_Mortfichet] = {"CloseRange", Abilities.AbilityCircularAttack},
								[Entities.CU_Barbarian_Hero] = {"AbilityAtDistance", Abilities.AbilityRangedEffect},
								[Entities.PU_Hero10] = {"AbilityAtDistance", Abilities.AbilityRangedEffect},
								[Entities.PU_Hero11] = {"CloseRange", Abilities.AbilityInflictFear},
								[Entities.CU_Evil_Queen] = {"CloseRange", Abilities.AbilityCircularAttack},
								[Entities.PU_Hero13] = {"CloseRangeSpec", "DivineJudgment"},
								[Entities.PU_Hero14] = {"CloseRangeSpec", "NighttimeAura"}
							},
				FactorByThreatType = {
				CloseRange = function(_id, _heroID, _ability)
					local posX, posY = Logic.GetEntityPosition(_heroID)
					local chargeval = Logic.HeroGetAbiltityChargeSeconds(_heroID, _ability) / Logic.HeroGetAbilityRechargeTime(_heroID, _ability)
					local factor = chargeval
					if chargeval > gvHeroTarget.Thresholds.CriticalCharge then
						local critrange = GetAbilityRange(Logic.GetEntityType(_heroID), _ability) or gvHeroTarget.BombThreatRange * gvHeroTarget.Thresholds.CriticalRange
						local numthreatened_ent = GetNumberOfEnemiesInRange(Logic.EntityGetPlayer(_heroID), gvHeroTarget.EndangeredCats, GetPosition(_heroID), critrange)
						factor = factor * numthreatened_ent / gvHeroTarget.Thresholds.CriticalNumEntitiesClump
					end
					return factor
				end,
				CloseRangeSpec = function(_id, _heroID, _ability)
					local type = Logic.GetEntityType(_heroID)
					local player = Logic.EntityGetPlayer(_heroID)
					local dist = GetDistance(_id, _heroID)
					if type == Entities.PU_Hero13 then
						if gvHero13.TriggerIDs[_ability].Judgment[player] then
							if dist < gvHero13.AbilityProperties[_ability].Judgment.BaseRange then
								if GetEntityHealth(_heroID) < 30 then
									return -1
								else
									return 0
								end
							end
						end
						if gvHero13.TriggerIDs.StoneArmor.DamageStoring[player] then
							return 0
						end
					elseif type == Entities.PU_Hero14 then
						if IsNighttime() then
							local range = gvHero14[_ability].Range * 2
							local numthreatened_ent = GetNumberOfEnemiesInRange(player, gvHeroTarget.EndangeredCats, GetPosition(_heroID), range)
							if numthreatened_ent >= gvHeroTarget.Thresholds.CriticalNumEntitiesClump then
								return 3
							else
								if dist < range then
									return -1
								else
									return math.max(numthreatened_ent / gvHeroTarget.Thresholds.CriticalNumEntitiesClump, 2)
								end
							end
						else
							return 1
						end
					end
					return 1
				end,
				AbilityAtDistance = function(_id, _heroID, _ability)
					local charge = Logic.HeroGetAbiltityChargeSeconds(_heroID, _ability)
					local type = Logic.GetEntityType(_heroID)
					local chargeval = charge/Logic.HeroGetAbilityRechargeTime(_heroID, _ability)
					local factor = chargeval
					if _ability ~= Abilities.AbilitySummon then
						local IsActive = (charge <= GetAbilityDuration(type, _ability))
						if IsActive or chargeval > gvHeroTarget.Thresholds.CriticalCharge then
							local range = GetAbilityRange(type, _ability)
							local numentities = gvHeroTarget.AffectedEntCountFuncByHero[type](Logic.EntityGetPlayer(_heroID), gvHeroTarget.AffectedCatsByHero[type], GetPosition(_heroID), range)
							factor = factor * numentities / gvHeroTarget.Thresholds.CriticalNumEntitiesClump
						end
					end
					return factor
				end},
				AreEntitiesThreatenedByConvertSettler = function(_heroID)
					if Logic.HeroGetAbiltityChargeSeconds(_heroID, Abilities.AbilityConvertSettlers) < Logic.HeroGetAbilityRechargeTime(_heroID, Abilities.AbilityConvertSettlers) then
						local id = GetConvertSettlersTarget(_heroID)
						return id ~= nil
					end
				end,
				EvaluateThreatFactor = function(_id, _heroID)
					assert(IsValid(_id) and IsValid(_heroID), "invalid entity ID")
					local type = Logic.GetEntityType(_heroID)
					local base = gvHeroTarget.BaseThreatVal[type]
					if type == Entities.PU_Hero6 then
						if gvHeroTarget.AreEntitiesThreatenedByConvertSettler(_heroID) then
							base = base * 3
						end
					end
					local threat, ability = unpack(gvHeroTarget.MainThreat[type])
					local factor = gvHeroTarget.FactorByThreatType[threat](_id, _heroID, ability)
					return base * factor
				end
}