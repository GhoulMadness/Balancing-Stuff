------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Mercenary Tower Table -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvMercenaryTower = { LastTimeUsed = 0, Cooldown = {
	["BuyLeaderBarbarian"] = 18,
	["BuyLeaderElite"] = 120,
	["BuyLeaderBanditSword"] = 12,
	["BuyLeaderBanditBow"] = 15,
	["BuyLeaderBlackKnight"] = 8,
	["BuyLeaderBlackSword"] = 40,
	["BuyLeaderEvilBear"] = 15,
	["BuyLeaderEvilSkir"] = 25
	}	, TechReq = {
	["BuyLeaderBarbarian"] = Technologies.T_BarbarianCulture,
	["BuyLeaderElite"] = Technologies.T_BarbarianCulture,
	["BuyLeaderBanditSword"] = Technologies.T_BanditCulture,
	["BuyLeaderBanditBow"] = Technologies.T_BanditCulture,
	["BuyLeaderBlackKnight"] = Technologies.T_KnightsCulture,
	["BuyLeaderBlackSword"] = Technologies.T_KnightsCulture,
	["BuyLeaderEvilBear"] = Technologies.T_BearmanCulture,
	["BuyLeaderEvilSkir"] = Technologies.T_BearmanCulture
	} 	, RechargeButton = {
	["BuyLeaderBarbarian"] = "Barbarian_Recharge",
	["BuyLeaderElite"] = "Elite_Recharge",
	["BuyLeaderBanditSword"] = "BanditSword_Recharge",
	["BuyLeaderBanditBow"] = "BanditBow_Recharge",
	["BuyLeaderBlackKnight"] = "BlackKnight_Recharge",
	["BuyLeaderBlackSword"] = "BlackSword_Recharge",
	["BuyLeaderEvilBear"] = "EvilBear_Recharge",
	["BuyLeaderEvilSkir"] = "EvilSkir_Recharge"
	}
}