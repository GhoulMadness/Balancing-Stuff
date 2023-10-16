gvHero9 = {AbilityProperties = {Summon = {BaseNumBonusTroops = 2, BonusFactorPerMissingHealth = 0.02, Cooldown = 300}, Rage = {Duration = 40}},
	WolfIDs = {}, CallAdditionalWolfs = {},
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
	end}
for i = 1, 16 do
	gvHero9.WolfIDs[i] = {}
end