

	if CNetwork then 
		CNetwork.SetNetworkHandler("Ghoul_LevyTaxes", 
			function(name, _playerID) 
				if CNetwork.isAllowedToManipulatePlayer(name, _playerID) then 
					CLogger.Log("Ghoul_LevyTaxes", name, _playerID); 
					-- Cooldown handling
					gvTaxes_NextCooldown = gvTaxes_NextCooldown or {};

					if gvTaxes_NextCooldown[_playerID] then
						if gvTaxes_NextCooldown[_playerID] < Logic.GetTimeMs() then
							return;
						end;
					end;
					-- update cooldown.
					gvTaxes_NextCooldown[_playerID] = Logic.GetTimeMs() + 4 * 60 * 1000;
    
					-- execute stuff
					Logic.AddToPlayersGlobalResource(_playerID, ResourceType.GoldRaw, Logic.GetPlayerTaxIncome(_playerID)) 
					for eID in S5Hook.EntityIterator(Predicate.OfPlayer(_playerID), Predicate.OfCategory(EntityCategories.Worker)) do 
						local motivation = Logic.GetSettlersMotivation(eID) S5Hook.SetSettlerMotivation(eID, motivation - 0.12) 
					end; 
				end; 
			end 
		); 
		CNetwork.SetNetworkHandler("Ghoul_LightningRod_Protected", 
			function(name, _playerID) 
				if CNetwork.isAllowedToManipulatePlayer(name, _playerID) then 
					CLogger.Log("Ghoul_LightningRod_Protected", name, _playerID); 
					-- Cooldown handling
					gvLightning.NextCooldown = gvLightning.NextCooldown or {};
					
					if gvLightning.NextCooldown[_playerID] then
						if gvLightning.NextCooldown[_playerID] < Logic.GetTimeMs() then
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
				if CNetwork.isAllowedToManipulatePlayer(name, _playerID) then 
					CLogger.Log("Ghoul_Lighthouse_SpawnJob", name, _playerID,_eID); 
					
					if Logic.GetEntityType(_eID) ~= Entities.CB_LighthouseActivated then
						return
					end
					-- Cooldown handling
					gvLighthouse.NextCooldown = gvLighthouse.NextCooldown or {};
					
					if gvLighthouse.NextCooldown[_playerID] then
						if gvLighthouse.NextCooldown[_playerID] < Logic.GetTimeMs() then
							return;
						end;
					end;
					-- update cooldown.
					gvLighthouse.NextCooldown[_playerID] = Logic.GetTimeMs() + 5 * 60 * 1000;
    
					-- execute stuff
					local pos = GetPosition(_eID)
					local Iron   = Logic.GetPlayersGlobalResource( _playerID, ResourceType.Iron ) + Logic.GetPlayersGlobalResource( _playerID, ResourceType.IronRaw)
					local Sulfur = Logic.GetPlayersGlobalResource( _playerID, ResourceType.Sulfur ) + Logic.GetPlayersGlobalResource( _playerID, ResourceType.SulfurRaw)
	
					if Iron >= 600 and Sulfur >= 400 then
						Logic.AddToPlayersGlobalResource(_playerID,ResourceType.Iron,-600)
						Logic.AddToPlayersGlobalResource(_playerID,ResourceType.Sulfur,-400)
						Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,"", "Lighthouse_SpawnTroops",1,{},{_playerID,pos.X,pos.Y} )
						gvLighthouse.starttime = Logic.GetTime()
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
				if CNetwork.isAllowedToManipulatePlayer(name, _playerID,_eID) then 
					CLogger.Log("Ghoul_ChangeWeatherToThunderstorm", name); 
					if Logic.GetPlayersGlobalResource(_playerID,ResourceType.WeatherEnergy) < Logic.GetEnergyRequiredForWeatherChange() then
						return
					end
					if Logic.GetEntityType ~= Entities.PB_WeatherTower1 then
						return
					end
					Logic.AddWeatherElement(2,120,0,11,5,15)
					Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetEnergyRequiredForWeatherChange()))
					--in case the player still has energy left, bring him down to zero!
					if Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy ) > Logic.GetEnergyRequiredForWeatherChange() then
						Logic.AddToPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy, -(Logic.GetPlayersGlobalResource(_playerID, ResourceType.WeatherEnergy )))
					end
					GUI.DeselectEntity(_eID)
					GUI.SelectEntity(_eID)
				end; 
			end 
		); 
	
		
	end

--