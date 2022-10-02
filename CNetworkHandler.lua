

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
			function(name, _playerID,_eID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then 
				
					CLogger.Log("Ghoul_Lighthouse_SpawnJob", name, _playerID,_eID)  
					
					if Logic.GetEntityType(_eID) ~= Entities.CB_LighthouseActivated then
					
						return
						
					end
					
					-- Cooldown handling
					gvLighthouse.NextCooldown = gvLighthouse.NextCooldown or {} 
					
					if gvLighthouse.NextCooldown[_playerID] then
					
						if gvLighthouse.NextCooldown[_playerID] > Logic.GetTimeMs() then
						
							return 
							
						end 
						
					end 
					
					-- update cooldown.
					gvLighthouse.NextCooldown[_playerID] = Logic.GetTimeMs() + (5 * 60 * 1000) 
    
					-- execute stuff
					local pos = {}
					
					pos.X,pos.Y = Logic.GetEntityPosition(_eID)
					
					local rot = Logic.GetEntityOrientation(_eID)
					
					local posadjust = {}
					
					if rot == 0 or rot == 360 then
					
						posadjust.X = -700
						
						posadjust.Y = -100
						
					elseif rot == 90 then
					
						posadjust.X = 100
						
						posadjust.Y = -800
						
					elseif rot == 180 then
					
						posadjust.X = 600
						
						posadjust.Y = 100
						
					elseif rot == 270 then
					
						posadjust.X = -100
						
						posadjust.Y = 600
						
					end
					
					local Iron   = Logic.GetPlayersGlobalResource( _playerID, ResourceType.Iron ) + Logic.GetPlayersGlobalResource( _playerID, ResourceType.IronRaw)
					
					local Sulfur = Logic.GetPlayersGlobalResource( _playerID, ResourceType.Sulfur ) + Logic.GetPlayersGlobalResource( _playerID, ResourceType.SulfurRaw)
	
					if Iron >= 600 and Sulfur >= 400 then
					
						Logic.AddToPlayersGlobalResource(_playerID,ResourceType.Iron,-600)
						
						Logic.AddToPlayersGlobalResource(_playerID,ResourceType.Sulfur,-400)
						
						Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,"", "Lighthouse_SpawnTroops",1,{},{_playerID,(pos.X + posadjust.X),(pos.Y + posadjust.Y)} )
						
						gvLighthouse.starttime[_playerID] = Logic.GetTime()
						
					else
					
						if GUI.GetPlayerID() == _playerID then
							
							Stream.Start("Sounds\\VoicesMentor\\INFO_notenough.wav",110)
							
						end
						
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
					
					if Logic.GetEntityType(_eID) ~= Entities.PB_WeatherTower1 then
					
						return
						
					end
					
					Logic.AddWeatherElement(2,120,0,11,5,15)
					
					Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetEnergyRequiredForWeatherChange()))
					
					--in case the player still has energy left, bring him down to zero!
					if Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy ) > Logic.GetEnergyRequiredForWeatherChange() then
					
						Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy )))
						
					end
					
					if EMS then
					
						EMS.RF.WLT.LockWeatherChange()
						
					end
					
					if _playerID == GUI.GetPlayerID() and GUI.GetSelectedEntity() == _eID then
					
						GUI.DeselectEntity(_eID)
						
						GUI.SelectEntity(_eID)
						
					end
					
				end  
				
			end 
			
		)  
		
		CNetwork.SetNetworkHandler("Ghoul_Hero13StoneArmor", 
			function(name,_playerID,_heroID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Hero13StoneArmor", name, _playerID,_heroID)  					
					-- Cooldown handling
					gvHero13StoneArmor_NextCooldown = gvHero13StoneArmor_NextCooldown or {} 					
					local starttime = Logic.GetTimeMs()	
					
					if gvHero13StoneArmor_NextCooldown[_playerID] then					
						if gvHero13StoneArmor_NextCooldown[_playerID] > starttime then						
							return 							
						end 						
					end 					
					-- update cooldown.
					gvHero13StoneArmor_NextCooldown[_playerID] = Logic.GetTimeMs() + gvHero13.Cooldown.StoneArmor
					-- execute stuff
					if not gvHero13.TriggerIDs.StoneArmor[_playerID] then
						gvHero13.TriggerIDs.StoneArmor[_playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_StoneArmor_Trigger", 1, nil, {_heroID,starttime})
					end
				end  
				
			end 
			
		)  
		
		CNetwork.SetNetworkHandler("Ghoul_Hero13DivineJudgment", 
			function(name,_playerID,_heroID) 
			
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
					gvHero13DivineJudgment_NextCooldown[_playerID] = Logic.GetTimeMs() + gvHero13.Cooldown.DivineJudgment
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
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Archers_Tower_RemoveTroop", name, _playerID,_entityID,_slot)  
    
					-- execute stuff
					
					local soldiers,_soldierstable
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entityID][_slot], EntityCategories.Cannon) ~= 1 then
					
						_soldierstable = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_entityID][_slot])}
					
						soldiers = _soldierstable[1]
						
					else
						
						soldiers = 0
						
					end
					
					_G["Archers_Tower_RemoveTroopTriggerID_".._entityID.."_".._slot] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Archers_Tower_RemoveTroop_".._playerID.."_".._slot, 1, nil, {_slot,_entityID,soldiers,_playerID})
	
					Logic.SuspendEntity(gvArchers_Tower.SlotData[_entityID][_slot])
					
					Logic.SetEntityScriptingValue(gvArchers_Tower.SlotData[_entityID][_slot],-30,257)
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entityID][_slot], EntityCategories.Cannon) ~= 1 then
					
						table.remove(_soldierstable,1)
										
						for i = 1,table.getn(_soldierstable) do

							Logic.SuspendEntity(_soldierstable[i])

							Logic.SetEntityScriptingValue(_soldierstable[i],-30,257)
						
						end
						
					end
					
				end  
				
			end 
			
		)  
		
		CNetwork.SetNetworkHandler("Ghoul_Archers_Tower_AddTroop", 
			function(name,_playerID,_entityID,_leaderID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Archers_Tower_AddTroop", name, _playerID,_entityID,_leaderID)  
    
					-- execute stuff
					
					local _slot = gvArchers_Tower.GetFirstFreeSlot(_entityID)
					
					gvArchers_Tower.SlotData[_entityID][_slot] = _leaderID
										
					local soldiers,_soldierstable
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entityID][_slot], EntityCategories.Cannon) ~= 1 then
					
						_soldierstable = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_entityID][_slot])}
					
						soldiers = _soldierstable[1]
						
					else
					
						soldiers = 0
						
					end										
					
					_G["Archers_Tower_AddTroopTriggerID_".._entityID.."_".._slot] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Archers_Tower_AddTroop_".._playerID.."_".._slot, 1, nil, {_slot,soldiers,_playerID,_entityID})
			
					gvArchers_Tower.CurrentlyUsedSlots[_entityID] = gvArchers_Tower.CurrentlyUsedSlots[_entityID] + 1
					
					Logic.SuspendEntity(gvArchers_Tower.SlotData[_entityID][_slot])
	
					Logic.SetEntityScriptingValue(gvArchers_Tower.SlotData[_entityID][_slot],-30,257)
					
					if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entityID][_slot], EntityCategories.Cannon) ~= 1 then
					
						table.remove(_soldierstable,1)
						
						for i = 1,table.getn(_soldierstable) do

							Logic.SuspendEntity(_soldierstable[i])
		
							Logic.SetEntityScriptingValue(_soldierstable[i],-30,257)
						
						end
						
					end
					
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
						if not ArmyCreator.CheckForAchievement(_playerID) then
							trooptable[Entities.PU_Hero14] = 0
						end
					end
					ArmyCreator.ReadyForTroopCreation(_playerID, trooptable)
					
				end
				
			end
			
		)
		
		CNetwork.SetNetworkHandler("Ghoul_Hero14CallOfDarkness", 
			function(name, _heroID) 
			
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
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
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
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Hero14RisingEvil", name, _playerID,_heroID)
					
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
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Forester_WorkChange", name, _playerID, _id, _flag)
    
					-- execute stuff
					
					Forester.WorkChange(_id, _flag)
					
				end
				
			end
			
		)
		
		CNetwork.SetNetworkHandler("BuyHero",
			function(name, _playerID, _type, _buildingID)
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
							SendEvent.BuyHero(_playerID, _type, _buildingID)
						end
					else
						CLogger.Log("BuyHero", _playerID, _type, _buildingID)
						SendEvent.BuyHero(_playerID, _type, _buildingID)
					end
				end
			end
		)
		
		CNetwork.SetNetworkHandler("PlaceBuilding",
			function(name, _player, _upgradeCategory, _x, _y, _rotation, ...)

				local selection = arg
				
				local type_func = type
				
				local type = Logic.GetBuildingTypeByUpgradeCategory(_upgradeCategory, _player) 
				local isMine = false 
				local isBridge = false 
				local isVC = false 
				
				local buildOn = 0 
				
				if _upgradeCategory == UpgradeCategories.GenericBridge then
					
					local entity = GetBridgeSlotAtPosition(_x, _y) 
					local bridges = {
						[Entities.XD_Bridge1] = Entities.PB_Bridge1, 
						[Entities.XD_Bridge2] = Entities.PB_Bridge2,
						[Entities.XD_Bridge3] = Entities.PB_Bridge3, 
						[Entities.XD_Bridge4] = Entities.PB_Bridge4, 
					} 
					if entity and (entity) ~= 0 then
						local t = Logic.GetEntityType(entity) 
						if bridges[t] then
							type = bridges[t] 
						else
							return 
						end 
					else
						return 
					end 
					
					buildOn = entity
				elseif _upgradeCategory == UpgradeCategories.GenericMine then
					local entity = GetBuildOnEntityAtPosition(_x, _y) 
					
					if entity and entity ~= 0 then
						
						if CEntity.GetAttachedEntities(entity)[36] then
							return 
						end 
						
						type = BuildOnDefinitionsReverse[Logic.GetEntityType(entity)] 
						
						buildOn = entity 
						
						if not type then
							return 
						end 
					else
						return 
					end 
				elseif BuildOnDefinitions[type] then
					local entity = GetBuildOnEntityAtPosition(_x, _y) 
					if entity and entity ~= 0 then
						if CEntity.GetAttachedEntities(entity)[36] then
							return 
						end 
						
						local t = Logic.GetEntityType(entity) 
						
						if not BuildOnDefinitions[type] then
							return 
						end 
						
						if type_func(BuildOnDefinitions[type]) == "number" then
							-- old variant
							if BuildOnDefinitions[type] ~= t then
								return 
							end 
						else
							-- new variant
							if not BuildOnDefinitions[type][t] then
								return 
							end 
						end 
						
						buildOn = entity 
						
					end 
				else
					for i = 1,4 do 
						if _upgradeCategory == _G["UpgradeCategories"]["VictoryStatue"..i] then
							local allowed
							for k,v in pairs(BS.AchievementWhitelist[i]) do
								if v == XNetwork.GameInformation_GetLogicPlayerUserName(_player) then
									allowed = true							
								end
							end
							if not allowed then
								return
							end
						end
					end
				end 
				
				if CNetwork.IsAllowedToManipulatePlayer(name, _player)
				and CPlaceBuilding.CanPlaceBuilding(type, _player, _x, _y, _rotation, buildOn)
				then
					
					local e = {Logic.GetEntitiesInArea(0, _x, _y, 1, 64)} 
					
					for i = 2, e[1]+1 do
						if Logic.IsBuilding(e[i]) then
							return 
						end 
					end 
					
					
					
					if CheckResources(_upgradeCategory, _player) then
						SubResources(_upgradeCategory, _player) 
						
						local id = Logic.CreateConstructionSite( _x, _y, _rotation, type, _player ) 
						
						CLogger.Log("PlaceBuilding_CreateConstructionSite", _x, _y, _rotation, type, _player, id, InputHandler_LastPlacedBuilding) 

						id = InputHandler_LastPlacedBuilding 
						

						if isMine then
							SetMine(_x, _y, id) 
						elseif isBridge then
							SetBridge(_x, _y, id) 
						end 
						
						if Logic.IsEntityAlive(id) then
							for i = 1,table.getn(selection) do
								if Logic.IsEntityAlive(selection[i]) and Logic.EntityGetPlayer(selection[i]) == _player then
									CLogger.Log("PlaceBuilding_SerfConstructBuilding", selection[i], id) 
									SendEvent.SerfConstructBuilding(selection[i], id) 
								end 
							end 
						end 
					end 
				end
			end 
		
		)
		
	end

--