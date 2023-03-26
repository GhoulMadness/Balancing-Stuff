gvHero13 = {LastTimeUsed = {StoneArmor = - 6000, DivineJudgment = - 6000},
			TriggerIDs = {StoneArmor = {DamageStoring = {}, DamageApply = {}}, DivineJudgment = {DMGBonus = {}, Judgment = {}}, Resurrection = {}},
			Cooldown = {StoneArmor = 2.5 * 60, DivineJudgment = 1 * 60},
			AbilityProperties = 
			{StoneArmor = {Duration = 5 * 1000, DamageFactor = 0.7, DamageStored = {}},
			DivineJudgment = {DMGBonus = {Multiplier = 4, Duration = 5 * 1000},
				Judgment = {Duration = 4 * 1000, BaseRange = 1200, BaseExponent = 2.5, RangeDelayFalloff = 10, ExponentDelayFalloff = 2700, NumberOfLightningStrikes = 10, DamageFalloff = 0.07, MinDamage = 0.2, MinAttackDamageFactor = 4, DamageFactors = {Hero = 2, Building = 8}}}},
			AbilityNameRechargeButtons = {StoneArmor = "Hero13_RechargeStoneArmor", DivineJudgment = "Hero13_RechargeDivineJudgment"},
			GetRechargeButtonByAbilityName = function(_name)
				return gvHero13.AbilityNameRechargeButtons[_name]
			end,
			StoneArmor = {}, DivineJudgment = {}
			}