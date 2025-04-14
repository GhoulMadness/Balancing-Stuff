

if CNetwork then

	CNetwork.SetNetworkHandler("Ghoul_LevyTaxes",
		function(name, _playerID)

			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_LevyTaxes", name, _playerID)

				-- Cooldown handling
				gvTaxes_NextCooldown = gvTaxes_NextCooldown or {}

				if gvTaxes_NextCooldown[_playerID] then

					if gvTaxes_NextCooldown[_playerID] > Logic.GetTimeMs() then

						return

					end

				end

				-- update cooldown.
				gvTaxes_NextCooldown[_playerID] = Logic.GetTimeMs() + 4 * 60 * 1000

				BS.LevyTax(_playerID)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_ForceSettlersToWorkPenalty",
		function(name, _playerID)

			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_ForceSettlersToWorkPenalty", name, _playerID)

				for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do

					local motivation = Logic.GetSettlersMotivation(eID)

					CEntity.SetMotivation(eID, motivation - 0.08)

				end

				CUtil.AddToPlayersMotivationHardcap(_playerID, - 0.02)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_LightningRod_Protected",
		function(name, _playerID)

			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_LightningRod_Protected", name, _playerID)

				-- Cooldown handling
				gvLightning.NextCooldown = gvLightning.NextCooldown or {}

				if gvLightning.NextCooldown[_playerID] then

					if gvLightning.NextCooldown[_playerID] > Logic.GetTimeMs() then

						return

					end

				end

				-- update cooldown.
				gvLightning.NextCooldown[_playerID] = Logic.GetTimeMs() + 4 * 60 * 1000

				-- execute stuff
				gvLightning.RodProtected[_playerID] = true

				Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","LightningRod_UnProtected",1,{},{_playerID})

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Lighthouse_SpawnJob",
		function(name, _playerID, _eID)

			if Logic.GetEntityType(_eID) ~= Entities.CB_LighthouseActivated then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_Lighthouse_SpawnJob", name, _playerID, _eID)

				-- Cooldown handling
				gvLighthouse.NextCooldown = gvLighthouse.NextCooldown or {}

				if gvLighthouse.NextCooldown[_playerID] then

					if gvLighthouse.NextCooldown[_playerID] > Logic.GetTime() then

						return

					end

				end

				-- update cooldown.
				gvLighthouse.NextCooldown[_playerID] = Logic.GetTime() + gvLighthouse.cooldown

				-- execute stuff
				if gvLighthouse.CheckForResources(_playerID) then
					gvLighthouse.PrepareSpawn(_playerID, _eID)
				end
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_ChangeWeatherToThunderstorm",
		function(name, _playerID,_eID)

			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_ChangeWeatherToThunderstorm", name)

				if Logic.GetPlayersGlobalResource(_playerID,ResourceType.WeatherEnergy) < Logic.GetEnergyRequiredForWeatherChange() then

					return

				end
				GUIAction_ChangeToThunderstorm(_playerID, _eID)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero6Sacrilege",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.PU_Hero6 then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Hero6Sacrilege", name, _playerID,_heroID)
				-- Cooldown handling
				gvHero6.Sacrilege.NextCooldown = gvHero6.Sacrilege.NextCooldown or {}
				local starttime = Logic.GetTime()

				if gvHero6.Sacrilege.NextCooldown[_playerID] then
					if gvHero6.Sacrilege.NextCooldown[_playerID] > starttime then
						return
					end
				end
				-- update cooldown.
				gvHero6.Sacrilege.NextCooldown[_playerID] = Logic.GetTime() + (gvHero6.Cooldown.Sacrilege)
				-- execute stuff
				if not gvHero6.TriggerIDs.Sacrilege[_playerID] then
					gvHero6.TriggerIDs.Sacrilege[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Hero6_Sacrilege_Trigger", 1, nil, {_heroID,_playerID,starttime})
				end
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero9CallAdditionalWolfs",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.CU_Barbarian_Hero then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Hero9CallAdditionalWolfs", name, _playerID,_heroID)
				-- Cooldown handling
				gvHero9.CallAdditionalWolfs.NextCooldown = gvHero9.CallAdditionalWolfs.NextCooldown or {}
				local starttime = Logic.GetTime()

				if gvHero9.CallAdditionalWolfs.NextCooldown[_playerID] then
					if gvHero9.CallAdditionalWolfs.NextCooldown[_playerID] > starttime then
						return
					end
				end
				-- update cooldown.
				gvHero9.CallAdditionalWolfs.NextCooldown[_playerID] = Logic.GetTime() + (gvHero9.AbilityProperties.Summon.Cooldown)
				-- execute stuff
				gvHero9.SpawnAdditionalWolfs(_playerID, _heroID)
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero9Plunder",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.CU_Barbarian_Hero then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Hero9Plunder", name, _playerID, _heroID)
				-- Cooldown handling
				gvHero9.Plunder.NextCooldown = gvHero9.Plunder.NextCooldown or {}
				local starttime = Logic.GetTime()

				if gvHero9.Plunder.NextCooldown[_playerID] then
					if gvHero9.Plunder.NextCooldown[_playerID] > starttime then
						return
					end
				end
				-- update cooldown.
				gvHero9.Plunder.NextCooldown[_playerID] = Logic.GetTime() + (gvHero9.Cooldown.Plunder)
				-- execute stuff
				GUIAction_Hero9PlunderAction(_heroID, _playerID, starttime)
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero13StoneArmor",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.PU_Hero13 then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Hero13StoneArmor", name, _playerID,_heroID)
				-- Cooldown handling
				gvHero13.StoneArmor.NextCooldown = gvHero13.StoneArmor.NextCooldown or {}
				local starttime = Logic.GetTimeMs()

				if gvHero13.StoneArmor.NextCooldown[_playerID] then
					if gvHero13.StoneArmor.NextCooldown[_playerID] > starttime then
						return
					end
				end
				-- update cooldown.
				gvHero13.StoneArmor.NextCooldown[_playerID] = Logic.GetTimeMs() + (gvHero13.Cooldown.StoneArmor * 1000)
				-- execute stuff
				if not gvHero13.TriggerIDs.StoneArmor.DamageStoring[_playerID] then
					gvHero13.TriggerIDs.StoneArmor.DamageStoring[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_StoneArmor_StoreDamage", 1, nil, {_heroID,starttime})
				end
				if not gvHero13.TriggerIDs.StoneArmor.DamageApply[_playerID] then
					gvHero13.TriggerIDs.StoneArmor.DamageApply[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_StoneArmor_ApplyDamage", 1, nil, {_heroID,starttime})
				end
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero13DivineJudgment",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.PU_Hero13 then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Hero13DivineJudgment", name, _playerID,_heroID)
				-- Cooldown handling
				gvHero13DivineJudgment_NextCooldown = gvHero13DivineJudgment_NextCooldown or {}
				local starttime = Logic.GetTimeMs()
				local basedmg = Logic.GetEntityDamage(_heroID)
				local posX,posY = Logic.GetEntityPosition(_heroID)

				if gvHero13DivineJudgment_NextCooldown[_playerID] then
					if gvHero13DivineJudgment_NextCooldown[_playerID] > starttime then
						return
					end
				end
				-- update cooldown.
				gvHero13DivineJudgment_NextCooldown[_playerID] = Logic.GetTimeMs() + (gvHero13.Cooldown.DivineJudgment * 1000)
				-- execute stuff
				if not gvHero13.TriggerIDs.DivineJudgment.DMGBonus[_playerID] then
					gvHero13.TriggerIDs.DivineJudgment.DMGBonus[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_DMGBonus_Trigger", 1, nil, {_heroID,starttime})
					Logic.CreateEffect(GGL_Effects.FXKerberosFear,posX,posY)
				end
				if not gvHero13.TriggerIDs.DivineJudgment.Judgment[_playerID] then
					gvHero13.TriggerIDs.DivineJudgment.Judgment[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_DivineJudgment_Trigger", 1, nil, {_heroID,basedmg,posX,posY,starttime})
				end
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Archers_Tower_RemoveTroop",
		function(name,_playerID,_entityID,_slot)
			if not gvArchers_Tower.SlotData[_entityID] then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Archers_Tower_RemoveTroop", name, _playerID,_entityID,_slot)

				-- execute stuff
				gvArchers_Tower.PrepareData.RemoveTroop(_playerID, _entityID, _slot)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Archers_Tower_AddTroop",
		function(name,_playerID,_entityID,_leaderID)
			if not gvArchers_Tower.SlotData[_entityID] then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_Archers_Tower_AddTroop", name, _playerID,_entityID,_leaderID)

				-- execute stuff
				gvArchers_Tower.PrepareData.AddTroop(_playerID, _entityID, _leaderID)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_ArmyCreator_SpawnTroops",
		function(name, _playerID, ...)

			if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then

				CLogger.Log("Ghoul_ArmyCreator_SpawnTroops", name, _playerID, arg)

				-- execute stuff

				local trooptable = {}

				for i = 1, (arg.n - 1), 2 do

					trooptable[arg[i]] = arg[i + 1]

				end

				-- is player really using the intended points limit?
				while ArmyCreator.CheckForPointsLimitExceeded(trooptable) ~= nil do
					trooptable[ArmyCreator.CheckForPointsLimitExceeded(trooptable)] = trooptable[ArmyCreator.CheckForPointsLimitExceeded(trooptable)] - 1
				end
				-- has player really completed the challenge maps properly?
				if trooptable[Entities.PU_Hero14] > 0 then
					if not ArmyCreator.CheckForAchievement(_playerID, "BS_ArmyCreator_Hero14") then
						trooptable[Entities.PU_Hero14] = 0
					end
				end
				if trooptable[Entities.PV_Cannon5] > 0 then
					if not ArmyCreator.CheckForAchievement(_playerID, "BS_ArmyCreator_Cannon_T5") then
						trooptable[Entities.PV_Cannon5] = 0
					end
				end
				if trooptable[Entities.PV_Cannon6_2] > 0 then
					if not ArmyCreator.CheckForAchievement(_playerID, "BS_ArmyCreator_Cannon_T6") then
						trooptable[Entities.PV_Cannon6_2] = 0
					end
				end
				ArmyCreator.ReadyForTroopCreation(_playerID, trooptable)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero14CallOfDarkness",
		function(name, _heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.PU_Hero14 then
				return
			end
			local playerID = Logic.EntityGetPlayer(_heroID)

			if CNetwork.IsAllowedToManipulatePlayer(name, playerID) then

				CLogger.Log("Ghoul_Hero14CallOfDarkness", name, _heroID)

				-- Cooldown handling
				gvHero14.CallOfDarkness.NextCooldown = gvHero14.CallOfDarkness.NextCooldown or {}

				local starttime = Logic.GetTime()

				if gvHero14.CallOfDarkness.NextCooldown[playerID] then

					if gvHero14.CallOfDarkness.NextCooldown[playerID] > starttime then

						return

					end

				end

				-- update cooldown.
				gvHero14.CallOfDarkness.NextCooldown[playerID] = Logic.GetTime() + gvHero14.CallOfDarkness.Cooldown

				-- execute stuff
				gvHero14.CallOfDarkness.SpawnTroops(_heroID)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero14LifestealAura",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.PU_Hero14 then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_Hero14LifestealAura", name, _playerID,_heroID)

				-- Cooldown handling
				gvHero14.LifestealAura.NextCooldown = gvHero14.LifestealAura.NextCooldown or {}

				local starttime = Logic.GetTime()

				if gvHero14.LifestealAura.NextCooldown[_playerID] then

					if gvHero14.LifestealAura.NextCooldown[_playerID] > starttime then

						return

					end

				end

				-- update cooldown.
				gvHero14.LifestealAura.NextCooldown[_playerID] = Logic.GetTime() + gvHero14.LifestealAura.Cooldown

				-- execute stuff
				gvHero14.LifestealAura.TriggerIDs[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero14_Lifesteal_Trigger", 1, nil, {_heroID,starttime})

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Hero14RisingEvil",
		function(name,_playerID,_heroID)
			if Logic.GetEntityType(_heroID) ~= Entities.PU_Hero14 then
				return
			end
			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then

				CLogger.Log("Ghoul_Hero14RisingEvil", name, _playerID, _heroID)

				-- Cooldown handling
				gvHero14.RisingEvil.NextCooldown = gvHero14.RisingEvil.NextCooldown or {}

				local starttime = Logic.GetTime()

				if gvHero14.RisingEvil.NextCooldown[_playerID] then

					if gvHero14.RisingEvil.NextCooldown[_playerID] > starttime then

						return

					end

				end

				-- update cooldown.
				gvHero14.RisingEvil.NextCooldown[_playerID] = Logic.GetTime() + gvHero14.RisingEvil.Cooldown

				-- execute stuff
				gvHero14.RisingEvil.SpawnEvilTower(_heroID)

			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_Forester_WorkChange",
		function(name, _playerID, _id, _flag)

			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then
				CLogger.Log("Ghoul_Forester_WorkChange", name, _playerID, _id, _flag)
				-- execute stuff
				Forester.WorkChange(_id, _flag)
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_CoalUsageChange",
		function(name, _flag, _playerID, _type)

			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then
				CLogger.Log("Ghoul_CoalUsageChange", name, _playerID, _id, _flag)
				-- execute stuff
				gvCoal.AdjustTypeList(_flag, _playerID, _type)
			end

		end

	)

	CNetwork.SetNetworkHandler("Ghoul_UpgradeLeaderCommand",
		function(name, _leaderID, _playerID, ...)
			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then
				CLogger.Log("Ghoul_UpgradeLeaderCommand", name, _leaderID, _playerID, arg)
				-- execute stuff
				GUIAction_ActionUpgradeLeader(_leaderID, _playerID, unpack(arg))
			end
		end
	)

	CNetwork.SetNetworkHandler("BuyHero",
		function(name, _playerID, _buildingID, _type)
			if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then
				if _type == Entities.PU_Hero14 then
					local count = 0
					for i = 1,3 do
						for k,v in pairs(BS.AchievementWhitelist[i]) do
							if v == XNetwork.GameInformation_GetLogicPlayerUserName(_playerID) then
								count = count + 1
							end
						end
					end
					if count == 3 then
					    CLogger.Log("BuyHero", _playerID, _type, _buildingID)
						SendEvent.BuyHero(_playerID, _buildingID, _type)
					end
				else
					CLogger.Log("BuyHero", _playerID, _type, _buildingID)
					SendEvent.BuyHero(_playerID, _buildingID, _type)
				end
			end
		end
	)

	CNetwork.SetNetworkHandler("BuyCannon",
		function(name, _buildingID, _ctype)
			if Logic.IsEntityAlive(_buildingID) then
				local playerID = Logic.EntityGetPlayer(_buildingID)
				if CNetwork.IsAllowedToManipulatePlayer(name, playerID) then
					if _ctype == Entities.PV_Catapult then
						local count = 0
						for i = 4,6 do
							for k,v in pairs(BS.AchievementWhitelist[i]) do
								if v == XNetwork.GameInformation_GetLogicPlayerUserName(playerID) then
									count = count + 1
								end
							end
						end
						if count == 3 then
							CLogger.Log("BuyCannon", playerID, _buildingID, _ctype)
							SendEvent.BuyCannon(_buildingID, _ctype)
						end
					elseif _ctype == Entities.PV_Cannon5 then
						local count = 0
						for i = 7,9 do
							for k,v in pairs(BS.AchievementWhitelist[i]) do
								if v == XNetwork.GameInformation_GetLogicPlayerUserName(playerID) then
									count = count + 1
								end
							end
						end
						if count == 3 then
							CLogger.Log("BuyCannon", playerID, _buildingID, _ctype)
							SendEvent.BuyCannon(_buildingID, _ctype)
						end
					elseif _ctype == Entities.PV_Cannon6 then
						local count = 0
						for i = 1,9 do
							for k,v in pairs(BS.AchievementWhitelist[i]) do
								if v == XNetwork.GameInformation_GetLogicPlayerUserName(playerID) then
									count = count + 1
								end
							end
						end
						if count == 3 then
							CLogger.Log("BuyCannon", playerID, _buildingID, _ctype)
							SendEvent.BuyCannon(_buildingID, _ctype)
						end
					else
						CLogger.Log("BuyCannon", playerID, _buildingID, _ctype)
						SendEvent.BuyCannon(_buildingID, _ctype)
					end
				end
			end
		end
	)

	CommandCallback_PlaceBuilding = function(_name, _player, _upgradeCategory, _x, _y, _rotation, ...)
		for i = 1,9 do
			if _upgradeCategory == UpgradeCategories["VictoryStatue"..i] then
				for k,v in pairs(BS.AchievementWhitelist[i]) do
					if v == XNetwork.GameInformation_GetLogicPlayerUserName(_player) then
						return true
					end
				end
				return false
			end
		end
		return true
	end

	function Network_Handler_Diplomacy_Self_Destruct_Helper(pid, type)

		local time = XGUIEng.GetSystemTime()
		while true do
			local TempTable = {Logic.GetPlayerEntities( pid, type, 48 ) }
			for j = 1,TempTable[1] + 1, 1 do
				Logic.DestroyEntity(TempTable[j]);
			end;

			if TempTable[1] == 0 then
				break;
			end;
			if XGUIEng.GetSystemTime() > time + 5 then
				LuaDebugger.Log("SELF DESTRUCT PLAYER " .. pid .. ": cant delete entity type " .. Logic.GetEntityTypeName(type) )
				CLogger.Log("SELF DESTRUCT PLAYER " .. pid .. ": cant delete entity type " .. Logic.GetEntityTypeName(type) )
				break
			end
		end;
	end;
	function Network.Handlers.Diplomacy_SelfDestruct(name, pid)
		if CNetwork.IsAllowedToManipulatePlayer(name, pid) then
			Message("Player " .. name .. " has given up all hope.");
			-- As long as there are entities

			CLogger.Log("Diplomacy_SelfDestruct", pid);


			local destroy_later = {
				[Entities.PB_Headquarters1] = true;
				[Entities.PB_Headquarters2] = true;
				[Entities.PB_Headquarters3] = true;
				[Entities.PB_Market1] = true;
				[Entities.PB_Market2] = true;

				[Entities.PB_ClayMine1] = true;
				[Entities.PB_ClayMine2] = true;
				[Entities.PB_ClayMine3] = true;

				[Entities.PB_IronMine1] = true;
				[Entities.PB_IronMine2] = true;
				[Entities.PB_IronMine3] = true;

				[Entities.PB_StoneMine1] = true;
				[Entities.PB_StoneMine2] = true;
				[Entities.PB_StoneMine3] = true;

				[Entities.PB_SulfurMine1] = true;
				[Entities.PB_SulfurMine2] = true;
				[Entities.PB_SulfurMine3] = true;

				[Entities.PB_Outpost1] = true;
				[Entities.PB_Outpost2] = true;
				[Entities.PB_Outpost3] = true;

				[Entities.PB_Market3] = true;

				[Entities.PB_Castle1] = true;
				[Entities.PB_Castle2] = true;
				[Entities.PB_Castle3] = true;
				[Entities.PB_Castle4] = true;
				[Entities.PB_Castle5] = true;

				[Entities.PB_SilverMine1] = true;
				[Entities.PB_SilverMine2] = true;
				[Entities.PB_SilverMine3] = true;

				[Entities.PB_GoldMine1] = true;
				[Entities.PB_GoldMine2] = true;
				[Entities.PB_GoldMine3] = true;
				
				[Entities.PU_WoodCutter] = true;
				[Entities.PU_Forester] = true
			};

			for k,v in pairs(Entities) do
				if not destroy_later[v] then
					Network_Handler_Diplomacy_Self_Destruct_Helper(pid, v);
				end;
			end;

			for k,v in pairs(destroy_later) do
				Network_Handler_Diplomacy_Self_Destruct_Helper(pid, k);
			end;

		end;
	end;
end