gvHero6 = {LastTimeUsed = {Sacrilege = - 6000},
			TriggerIDs = {Sacrilege = {}, Resurrection = {}},
			Cooldown = {Sacrilege = 5 * 60},
			AbilityProperties =
			{Sacrilege = {Duration = 30}, Bless = {Duration = 45, MaxRange = 600, DamageReductionFactor = 0.5}},
			AbilityNameRechargeButtons = {Sacrilege = "Hero6_RechargeSacrilege"},
			GetRechargeButtonByAbilityName = function(_name)
				return gvHero6.AbilityNameRechargeButtons[_name]
			end,
			Sacrilege = {Active = {}}
			}