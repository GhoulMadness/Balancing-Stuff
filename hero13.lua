gvHero13 = {LastTimeUsed = {StoneArmor = - 6000, DivineJudgment = - 6000}, TriggerIDs = {StoneArmor = {}, DivineJudgment = {DMGBonus = {}, Judgment = {}}},
			Cooldown = {StoneArmor = 2.5 * 60, DivineJudgment = 1 * 60}, 
			AbilityProperties = {StoneArmor = {DamageStored = {}}, DivineJudgment = {DMGBonus = {Multiplier = 4, Duration = 5 * 1000}, Judgment = {Duration = 4 * 1000, BaseRange = 1000, BaseExponent = 2.5, RangeDelayFalloff = 10, ExponentDelayFalloff = 2000, NumberOfLightningStrikes = 10, DamageFalloff = 0.07, MinDamage = 0.2, DamageFactors = {Hero = 2, Building = 8}}}},
			AbilityNameRechargeButtons = {StoneArmor = "Hero13_RechargeStoneArmor", DivineJudgment = "Hero13_RechargeDivineJudgment"},				
			GetRechargeButtonByAbilityName = function(_name)
				return gvHero13.AbilityNameRechargeButtons[_name]
			end
			}