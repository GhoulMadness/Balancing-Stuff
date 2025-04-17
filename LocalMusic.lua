---------------------------------------------------------------------------------------------
---------------------------------- LocalMusic Additions -------------------------------------
---------------------------------------------------------------------------------------------
if LocalMusic then
	LocalMusic.SetEvilBattle= 	{
								{ "43_Extra1_DarkMoor_Combat.mp3", 120 },
								{ "05_CombatEvelance1.mp3", 117 },
								{ "03_CombatEurope1.mp3", 117 },
								{ "04_CombatMediterranean1.mp3", 113 }
								}
	function LocalMusic_Spectator_TriggerSettlerKilled()
		if GUI.GetPlayerID() == BS.SpectatorPID then
			local entityID = Event.GetEntityID()
			if Logic.IsSettler(entityID) == 1 and Logic.IsWorker(entityID) == 0 and Logic.IsSerf(entityID) == 0 then
				local playerID = Logic.EntityGetPlayer(entityID)
				if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(playerID) == 1 then
					Spectator_UnitKill_Ping_LastTime = Spectator_UnitKill_Ping_LastTime or 0
					if Logic.GetTime() > Spectator_UnitKill_Ping_LastTime + 5 then
						local posX, posY = Logic.GetEntityPosition(entityID)
						GUI.ScriptSignal(posX, posY, 3)
						Spectator_UnitKill_Ping_LastTime = Logic.GetTime()
						LocalMusic.Spectator_CallbackSettlerKilled(posX, posY)
					end
				end
			end
		end
	end
	function LocalMusic.Spectator_CallbackSettlerKilled(_posX, _posY)

		local currX, currY = GUI.Debug_GetMapPositionUnderMouse()
		if GetDistance({X = currX, Y = currY}, {X = _posX, Y = _posY}) <= (GUI.GetScreenSize() * math.sqrt(2) * Camera.GetZoomFactor()) then
			if LocalMusic.LastBattleMusicStarted < Logic.GetTime() then
				LocalMusic.BattlesOnTheMap = 2
				LocalMusic.LastBattleMusicStarted = Logic.GetTime() + 127
				LocalMusic.SongLength = 0
			end
		end
	end
end