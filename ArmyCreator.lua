--load widgets
WidgetHelper.AddPreCommitCallback(
function()
	CWidget.Transaction_AddRawWidgetsFromFile("extra2/shr/maps/user/Balancing_Stuff_in_Dev/ArmyCreator.xml", "Normal")
end)
CWidget.LoadGUINoPreserve("maps\\user\\Balancing_Stuff_in_Dev\\BS_GUI.xml")
--initializing table
ArmyCreator = {TroopLimit = 10, PointCosts = {	[Entities.PU_LeaderSword1] = 4,
												[Entities.PU_LeaderSword2] = 5,
												[Entities.PU_LeaderSword3] = 8,
												[Entities.PU_LeaderSword4] = 11,
												[Entities.PU_LeaderPoleArm1] = 3,
												[Entities.PU_LeaderPoleArm2] = 4,
												[Entities.PU_LeaderPoleArm3] = 7,
												[Entities.PU_LeaderPoleArm4] = 10,
												[Entities.PU_LeaderBow1] = 4,
												[Entities.PU_LeaderBow2] = 5,
												[Entities.PU_LeaderBow3] = 9,
												[Entities.PU_LeaderBow4] = 14,
												[Entities.PU_LeaderRifle1] = 5,
												[Entities.PU_LeaderRifle2] = 12,
												[Entities.PU_LeaderCavalry1] = 7,
												[Entities.PU_LeaderCavalry2] = 12,
												[Entities.PU_LeaderHeavyCavalry1] = 7,
												[Entities.PU_LeaderHeavyCavalry2] = 12,
												[Entities.PU_Thief] = 15,
												[Entities.PU_Scout] = 6,
												[Entities.PU_BattleSerf] = 2,
												[Entities.PV_Cannon1] = 8,
												[Entities.PV_Cannon2] = 10,
												[Entities.PV_Cannon3] = 15,
												[Entities.PV_Cannon4] = 18,
												[Entities.PV_Catapult] = 50,
												[Entities.PV_Ram] = 20,
												[Entities.CU_BanditLeaderSword1] = 6,
												[Entities.CU_BanditLeaderBow1] = 8,
												[Entities.CU_Barbarian_LeaderClub1] = 7,
												[Entities.CU_VeteranLieutenant] = 35,
												[Entities.CU_BlackKnight_LeaderMace1] = 7,
												[Entities.CU_BlackKnight_LeaderSword3] = 10,
												[Entities.CU_Evil_LeaderBearman1] = 8,
												[Entities.CU_Evil_LeaderSkirmisher1] = 10,
												[Entities.PU_Hero1c] = 25,
												[Entities.PU_Hero2] = 28,
												[Entities.PU_Hero3] = 28,
												[Entities.PU_Hero4] = 24,
												[Entities.PU_Hero5] = 22,
												[Entities.PU_Hero6] = 30,
												[Entities.CU_Mary_de_Mortfichet] = 28,
												[Entities.CU_Barbarian_Hero] = 24,
												[Entities.CU_BlackKnight] = 20,
												[Entities.CU_Evil_Queen] = 20,
												[Entities.PU_Hero10] = 28,
												[Entities.PU_Hero11] = 20,
												[Entities.PU_Hero13] = 26,
												[Entities.PU_Hero14] = 22
												},
				BasePoints = 100,
				PlayerPoints = 0,
				TroopException = {	[Entities.PU_Hero1c] = true,
									[Entities.PU_Hero2] = true,
									[Entities.PU_Hero3] = true,
									[Entities.PU_Hero4] = true,
									[Entities.PU_Hero5] = true,
									[Entities.PU_Hero6] = true,
									[Entities.CU_Mary_de_Mortfichet] = true,
									[Entities.CU_Barbarian_Hero] = true,
									[Entities.CU_BlackKnight] = true,
									[Entities.CU_Evil_Queen] = true,
									[Entities.PU_Hero10] = true,
									[Entities.PU_Hero11] = true,
									[Entities.PU_Hero13] = true,
									[Entities.PU_Hero14] = true
									},
				TroopOnlyLeader = {	[Entities.PV_Cannon1] = true,
									[Entities.PV_Cannon2] = true,
									[Entities.PV_Cannon3] = true,
									[Entities.PV_Cannon4] = true,
									[Entities.PV_Catapult] = true,
									[Entities.PV_Ram] = true,
									[Entities.PU_Thief] = true,
									[Entities.PU_BattleSerf] = true,
									[Entities.PU_Scout] = true
									},
				PlayerTroops = { },
				SpawnPos = { },
				Finished = { }
}
for i = 1,16 do
	ArmyCreator.SpawnPos[i] = {X = 1000, Y = 1000}
	if IsValid("start_pos_p"..i) then
		ArmyCreator.SpawnPos[i] = GetPosition("start_pos_p"..i)
	end
	ArmyCreator.Finished[i] = false
	ArmyCreator.PlayerTroops[i] = {	[Entities.PU_LeaderSword1] = 0,
									[Entities.PU_LeaderSword2] = 0,
									[Entities.PU_LeaderSword3] = 0,
									[Entities.PU_LeaderSword4] = 0,
									[Entities.PU_LeaderPoleArm1] = 0,
									[Entities.PU_LeaderPoleArm2] = 0,
									[Entities.PU_LeaderPoleArm3] = 0,
									[Entities.PU_LeaderPoleArm4] = 0,
									[Entities.PU_LeaderBow1] = 0,
									[Entities.PU_LeaderBow2] = 0,
									[Entities.PU_LeaderBow3] = 0,
									[Entities.PU_LeaderBow4] = 0,
									[Entities.PU_LeaderRifle1] = 0,
									[Entities.PU_LeaderRifle2] = 0,
									[Entities.PU_LeaderCavalry1] = 0,
									[Entities.PU_LeaderCavalry2] = 0,
									[Entities.PU_LeaderHeavyCavalry1] = 0,
									[Entities.PU_LeaderHeavyCavalry2] = 0,
									[Entities.PU_Thief] = 0,
									[Entities.PU_Scout] = 0,
									[Entities.PU_BattleSerf] = 0,
									[Entities.PV_Cannon1] = 0,
									[Entities.PV_Cannon2] = 0,
									[Entities.PV_Cannon3] = 0,
									[Entities.PV_Cannon4] = 0,
									[Entities.PV_Catapult] = 0,
									[Entities.PV_Ram] = 0,
									[Entities.CU_BanditLeaderSword1] = 0,
									[Entities.CU_BanditLeaderBow1] = 0,
									[Entities.CU_Barbarian_LeaderClub1] = 0,
									[Entities.CU_VeteranLieutenant] = 0,
									[Entities.CU_BlackKnight_LeaderMace1] = 0,
									[Entities.CU_BlackKnight_LeaderSword3] = 0,
									[Entities.CU_Evil_LeaderBearman1] = 0,
									[Entities.CU_Evil_LeaderSkirmisher1] = 0,
									[Entities.PU_Hero1c] = 0,
									[Entities.PU_Hero2] = 0,
									[Entities.PU_Hero3] = 0,
									[Entities.PU_Hero4] = 0,
									[Entities.PU_Hero5] = 0,
									[Entities.PU_Hero6] = 0,
									[Entities.CU_Mary_de_Mortfichet] = 0,
									[Entities.CU_Barbarian_Hero] = 0,
									[Entities.CU_BlackKnight] = 0,
									[Entities.CU_Evil_Queen] = 0,
									[Entities.PU_Hero10] = 0,
									[Entities.PU_Hero11] = 0,
									[Entities.PU_Hero13] = 0,
									[Entities.PU_Hero14] = 0
									}
end

if not CNetwork then
	ArmyCreator.BasePoints = ArmyCreator.BasePoints * 2
end
ArmyCreator.PlayerPoints = ArmyCreator.BasePoints * (gvDiffLVL or 1)

ArmyCreator.CheckForPointsLimitExceeded = function(_trooptable)
	local count = 0
	for k,v in pairs(_trooptable) do
		count = count + (ArmyCreator.PointCosts[k] * v)
		if count > (ArmyCreator.BasePoints * (gvDiffLVL)) then
			return k
		end
	end
end
ArmyCreator.CheckForAchievement = function(_playerID)
	local allowed
	for k,v in pairs(BS.AchievementWhitelist[i]) do
		if v == XNetwork.GameInformation_GetLogicPlayerUserName(_playerID) then
			allowed = true
		end
	end
	return allowed
end
ArmyCreator.ReadyForTroopCreation = function(_playerID, _trooptable)

	ArmyCreator.Finished[_playerID] = true

	ArmyCreator.PlayerTroops[_playerID] = _trooptable

	if ArmyCreator.OnSetupFinished then

		if CNetwork then

			local count = 0

			for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do

				if ArmyCreator.Finished[i] then

					count = count + 1

				end

			end

			if count == GetNumberOfPlayingHumanPlayer() then

				local playersleft = GetNumberOfPlayingHumanPlayer()

				for i = 1, 12 do

					if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) ~= 0 then

						ArmyCreator.CreateTroops(i, ArmyCreator.PlayerTroops[i])

						playersleft = playersleft - 1

					end

					if playersleft == 0 then

						break

					end

				end

				ArmyCreator.OnSetupFinished()

			end

		else

			ArmyCreator.CreateTroops(_playerID, _trooptable)

			ArmyCreator.OnSetupFinished()

		end

	end

end
ArmyCreator.CreateTroops = function(_playerID, _trooptable)

	for k,v in pairs(_trooptable) do

		if ArmyCreator.TroopException[k] and v == 1 then

			Logic.CreateEntity(k, ArmyCreator.SpawnPos[_playerID].X, ArmyCreator.SpawnPos[_playerID].Y, math.random(360), _playerID)

		elseif ArmyCreator.TroopOnlyLeader[k] then

			if v > 1 then

				for i = 1,v do

					Logic.CreateEntity(k, ArmyCreator.SpawnPos[_playerID].X, ArmyCreator.SpawnPos[_playerID].Y, math.random(360), _playerID)

				end

			elseif v == 1 then

				Logic.CreateEntity(k, ArmyCreator.SpawnPos[_playerID].X, ArmyCreator.SpawnPos[_playerID].Y, math.random(360), _playerID)

			end

		else

			if v > 1 then

				for i = 1,v do

					CreateMilitaryGroup(_playerID, k, 16, ArmyCreator.SpawnPos[_playerID])

				end

			elseif v == 1 then

				CreateMilitaryGroup(_playerID, k, 16, ArmyCreator.SpawnPos[_playerID])

			end

		end

	end

end