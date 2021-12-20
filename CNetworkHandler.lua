

	if CNetwork then 
	
		CNetwork.SetNetworkHandler("Ghoul_LevyTaxes", 
			function(name, _playerID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then 
				
					CLogger.Log("Ghoul_LevyTaxes", name, _playerID); 
					
					-- Cooldown handling
					gvTaxes_NextCooldown = gvTaxes_NextCooldown or {};

					if gvTaxes_NextCooldown[_playerID] then
					
						if gvTaxes_NextCooldown[_playerID] > Logic.GetTimeMs() then
						
							return;
							
						end;
						
					end;
					
					-- update cooldown.
					gvTaxes_NextCooldown[_playerID] = Logic.GetTimeMs() + 4 * 60 * 1000;
    
					-- execute stuff
					Logic.AddToPlayersGlobalResource(_playerID, ResourceType.GoldRaw, Logic.GetPlayerTaxIncome(_playerID)) 
					
					for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerID), CEntityIterator.OfCategoryFilter(EntityCategories.Worker)) do 
					
						local motivation = Logic.GetSettlersMotivation(eID) 
						
						CEntity.SetMotivation(eID, motivation - 0.12) 
						
					end; 
					
				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_LightningRod_Protected", 
			function(name, _playerID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then 
				
					CLogger.Log("Ghoul_LightningRod_Protected", name, _playerID); 
					
					-- Cooldown handling
					gvLightning.NextCooldown = gvLightning.NextCooldown or {};
					
					if gvLightning.NextCooldown[_playerID] then
					
						if gvLightning.NextCooldown[_playerID] > Logic.GetTimeMs() then
						
							return;
							
						end;
						
					end;
					
					-- update cooldown.
					gvLightning.NextCooldown[_playerID] = Logic.GetTimeMs() + 4 * 60 * 1000;
    
					-- execute stuff
					gvLightning.RodProtected[_playerID] = true
					
					Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","LightningRod_UnProtected",1,{},{_playerID})

				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_Lighthouse_SpawnJob", 
			function(name, _playerID,_eID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then 
				
					CLogger.Log("Ghoul_Lighthouse_SpawnJob", name, _playerID,_eID); 
					
					if Logic.GetEntityType(_eID) ~= Entities.CB_LighthouseActivated then
					
						return
						
					end
					
					-- Cooldown handling
					gvLighthouse.NextCooldown = gvLighthouse.NextCooldown or {};
					
					if gvLighthouse.NextCooldown[_playerID] then
					
						if gvLighthouse.NextCooldown[_playerID] > Logic.GetTimeMs() then
						
							return;
							
						end;
						
					end;
					
					-- update cooldown.
					gvLighthouse.NextCooldown[_playerID] = Logic.GetTimeMs() + (5 * 60 * 1000);
    
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
					
				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_ChangeWeatherToThunderstorm", 
			function(name, _playerID,_eID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name, _playerID) then 
				
					CLogger.Log("Ghoul_ChangeWeatherToThunderstorm", name); 
					
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
					
				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_Hero13StoneArmor", 
			function(name,_playerID,_heroID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Hero13StoneArmor", name, _playerID,_heroID); 
					
					-- Cooldown handling
					gvHero13StoneArmor_NextCooldown = gvHero13StoneArmor_NextCooldown or {};
					
					local starttime = Logic.GetTimeMs()
					
					if gvHero13StoneArmor_NextCooldown[_playerID] then
					
						if gvHero13StoneArmor_NextCooldown[_playerID] > starttime then
						
							return;
							
						end;
						
					end;
					
					-- update cooldown.
					gvHero13StoneArmor_NextCooldown[_playerID] = Logic.GetTimeMs() + 2.5 * 60 * 1000;
    
					-- execute stuff
					_G["Hero13TriggerID_".._playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_StoneArmor_Trigger_".._playerID, 1, nil, {_heroID,starttime})
					
				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_Hero13DivineJudgment", 
			function(name,_playerID,_heroID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Hero13DivineJudgment", name, _playerID,_heroID); 
					
					-- Cooldown handling
					gvHero13DivineJudgment_NextCooldown = gvHero13DivineJudgment_NextCooldown or {};
					
					local starttime = Logic.GetTimeMs()
					
					local basedmg = Logic.GetEntityDamage(_heroID)
					
					local posX,posY = Logic.GetEntityPosition(_heroID)
					
					if gvHero13DivineJudgment_NextCooldown[_playerID] then
					
						if gvHero13DivineJudgment_NextCooldown[_playerID] > starttime then
						
							return;
							
						end;
						
					end;
					
					-- update cooldown.
					gvHero13DivineJudgment_NextCooldown[_playerID] = Logic.GetTimeMs() + 1 * 60 * 1000;
    
					-- execute stuff
					Logic.CreateEffect(GGL_Effects.FXKerberosFear,posX,posY)
					
					_G["Hero13DMGBonusTriggerID_".._playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "Hero13_DMGBonus_Trigger_".._playerID, 1, nil, {_heroID,starttime})
					
					_G["Hero13JudgmentTriggerID_".._playerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "Hero13_DivineJudgment_Trigger_".._playerID, 1, nil, {_heroID,basedmg,posX,posY,starttime})
					
				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_Archers_Tower_RemoveTroop", 
			function(name,_playerID,_entityID,_slot) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Archers_Tower_RemoveTroop", name, _playerID,_entityID,_slot); 
    
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
					
				end; 
				
			end 
			
		); 
		
		CNetwork.SetNetworkHandler("Ghoul_Archers_Tower_AddTroop", 
			function(name,_playerID,_entityID,_leaderID) 
			
				if CNetwork.IsAllowedToManipulatePlayer(name,_playerID) then 
				
					CLogger.Log("Ghoul_Archers_Tower_AddTroop", name, _playerID,_entityID,_leaderID); 
    
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
					
				end; 
				
			end 
			
		); 
		
	end

--