gvHero9 = {AbilityProperties = {Summon = {BaseNumBonusTroops = 2, BonusFactorPerMissingHealth = 0.02, Cooldown = 300}, Rage = {Duration = 40},
		Plunder = {Range = 1200, Duration = 60, ResPerHit = {[ResourceType.Silver] = 2, [ResourceType.SilverRaw] = 2, ["default"] = 5},
			AllowedTypes = {Entities.CU_AggressiveWolf, Entities.CU_Barbarian_Hero_wolf, Entities.CU_Barbarian_LeaderClub1, Entities.CU_Barbarian_SoldierClub1,
				Entities.CU_Barbarian_LeaderClub2, Entities.CU_Barbarian_SoldierClub2, Entities.CU_VeteranLieutenant, Entities.CU_VeteranLieutenantSoldier
			},
			Plundered = {}
		}
	},
	WolfIDs = {}, CallAdditionalWolfs = {}, Plunder = {}, TriggerIDs = {Plunder = {}, DiedCheck = {}, NearOwnBuildingCheck = {}, Resurrection = {}},
	Cooldown = {Plunder = 4*60}, LastTimeUsed = {Plunder = -3000},
	AbilityNameRechargeButtons = {Plunder = "Hero9_RechargePlunder"},
	GetRechargeButtonByAbilityName = function(_name)
		return gvHero9.AbilityNameRechargeButtons[_name]
	end,
	SpawnAdditionalWolfs = function(_playerID, _heroID)
		local posX, posY = Logic.GetEntityPosition(_heroID)
		local chargeTime = Logic.HeroGetAbiltityChargeSeconds(_heroID, Abilities.AbilityRangedEffect)
		if chargeTime <= gvHero9.AbilityProperties.Rage.Duration then
			local missinghealth = 100 - GetEntityHealth(_heroID)
			for i = 1, round(gvHero9.AbilityProperties.Summon.BaseNumBonusTroops * (1 + gvHero9.AbilityProperties.Summon.BonusFactorPerMissingHealth * missinghealth)) do
				local id = Logic.CreateEntity(Entities.CU_Barbarian_Hero_wolf, posX - math.random(100), posY - math.random(100), 0, _playerID)
				table.insert(gvHero9.WolfIDs[_playerID], id)
			end
			Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "Hero9_Died", 1, {}, {_heroID})
		end
	end,
	PlunderedResourceTypeByUpCat = {
		[UpgradeCategories.Blacksmith]         = ResourceType.Iron,
		[UpgradeCategories.StoneMine]          = ResourceType.StoneRaw,
		[UpgradeCategories.IronMine]           = ResourceType.IronRaw,
		[UpgradeCategories.SulfurMine]         = ResourceType.SulfurRaw,
		[UpgradeCategories.ClayMine]           = ResourceType.ClayRaw,
		[UpgradeCategories.SilverMine]         = ResourceType.SilverRaw,
		[UpgradeCategories.GoldMine]           = ResourceType.GoldRaw,
		[UpgradeCategories.Coalmine]           = ResourceType.Knowledge,
		[UpgradeCategories.Bank]               = ResourceType.Gold,
		[UpgradeCategories.StoneMason]         = ResourceType.Stone,
		[UpgradeCategories.Sawmill]            = ResourceType.Wood,
		[UpgradeCategories.Alchemist]          = ResourceType.Sulfur,
		[UpgradeCategories.Brickworks]         = ResourceType.Clay,
		[UpgradeCategories.Weathermachine]     = ResourceType.WeatherEnergy,
		[UpgradeCategories.PowerPlant]         = ResourceType.WeatherEnergy,
		[UpgradeCategories.GunsmithWorkshop]   = ResourceType.Sulfur,
		[UpgradeCategories.Weathermanipulator] = ResourceType.WeatherEnergy,
		[UpgradeCategories.Silversmith]        = ResourceType.Silver,
		[UpgradeCategories.Mint]               = ResourceType.Gold,
		[UpgradeCategories.Woodcutter]         = ResourceType.WoodRaw,
		[UpgradeCategories.Coalmaker]          = ResourceType.Knowledge,
		[UpgradeCategories.Monastery]		   = ResourceType.Faith,
		[UpgradeCategories.Dome]               = ResourceType.Faith
	},
	GetPlunderedResourceTypeByTarget = function(_ID)
		local etype = Logic.GetEntityType(_ID)
		local ucat = Logic.GetUpgradeCategoryByBuildingType(etype)
		if ucat == 0 then
			return ResourceType.Gold
		else
			return gvHero9.PlunderedResourceTypeByUpCat[ucat] or ResourceType.Gold
		end
	end,
	ResourceTypeToName = {
		[ResourceType.Gold] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney"),
		[ResourceType.GoldRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney") .. " RAW",
		[ResourceType.Wood] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood"),
		[ResourceType.WoodRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood") .. " RAW",
		[ResourceType.Silver] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameSilver"),
		[ResourceType.SilverRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameSilver") .. " RAW",
		[ResourceType.Clay] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay"),
		[ResourceType.ClayRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay") .. " RAW",
		[ResourceType.Stone] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone"),
		[ResourceType.StoneRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone") .. " RAW",
		[ResourceType.Iron] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron"),
		[ResourceType.IronRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron") .. " RAW",
		[ResourceType.Sulfur] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur"),
		[ResourceType.SulfurRaw] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur") .. " RAW",
		[ResourceType.Knowledge] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameCoal"),
		[ResourceType.Faith] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameFaith"),
		[ResourceType.WeatherEnergy] = XGUIEng.GetStringTableText("InGameMessages/GUI_NameWeatherenergy")
	},
	CreatePlunderedResDataString = function(_data)
		local str = ""
		for k,v in pairs(_data) do
			str = str .. gvHero9.ResourceTypeToName[k] .. ": " .. v .. " @cr "
		end
		return str
	end}
for i = 1, 16 do
	gvHero9.WolfIDs[i] = {}
end