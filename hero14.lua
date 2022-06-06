gvHero14 = {CallOfDarkness = {LastTimeUsed = - 6000, Cooldown = 180,
			SpawnTroops = function(_heroID)
				local xp = math.min(CEntity.GetLeaderExperience(_heroID), 1000)
				local hppercent = GetEntityHealth(_heroID)
				local calcvalue = xp/hppercent
				local playerID = Logic.EntityGetPlayer(_heroID)
				local pos = GetPosition(_heroID)
				if IsNighttime then
					calcvalue = calcvalue * 2
				end
				if calcvalue < 10 then					
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Bearman1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue >= 10 and calcvalue < 25 then
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Bearman1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Skirmisher1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue >= 25 and calcvalue < 45 then
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Bearman2, 0, 8, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Skirmisher1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue >= 45 and calcvalue < 70 then
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Bearman1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Bearman2, 0, 8, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Skirmisher1, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_Skirmisher2, 0, 8, pos.X, pos.Y, 0, 0, 0, 0)
				elseif calcvalue > 70 then
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_BearmanElite, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_SkirmisherElite, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
					AI.Entity_CreateFormation(playerId, Entities.PU_Hero14_SkirmisherElite, 0, 4, pos.X, pos.Y, 0, 0, 0, 0)
				end
			end}
			LifestealAura = {LastTimeUsed = - 6000, Cooldown = 90, Duration = 45, Range = 800, LifestealAmount = 0.2},
			RisingEvil = {LastTimeUsed = - 6000, Cooldown = 300, Range = 1000,
			SpawnEvilTower = function(_heroID)
				local playerID = Logic.EntityGetPlayer(_heroID)
				local pos = GetPosition(_heroID)
				local towerID = Logic.GetPlayerEntitiesInArea(playerID, Entities.PB_Tower2, pos.X, pos.Y, gvHero14.RisingEvil.Range, 1)
				Logic.CreateEffect(GGL_Effects.FXKalaPoison, pos.X, pos.Y)
				Logic.CreateEffect(GGL_Effects.FXCrushBuilding, pos.X, pos.Y)
				ReplaceEntity(towerID, Entities.CB_Evil_Tower1)
				if IsNighttime then
					gvHero14.RisingEvil.LastTimeUsed = gvHero14.RisingEvil.LastTimeUsed - 120
					if gvHero14.RisingEvil.NextCooldown[playerID] then
						gvHero14.RisingEvil.NextCooldown[playerID] = gvHero14.RisingEvil.NextCooldown[playerID] - 120
					end
				end
			end}
			}