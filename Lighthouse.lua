------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Lighthouse Comforts ----------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
gvLighthouse = { delay = 60 + math.random(30) , troopamount = 2 + math.random(4) , techlevel = 1 + math.random(2) , troops = {
	Entities.PU_LeaderSword1,
	Entities.PU_LeaderPoleArm1,
	Entities.PU_LeaderBow1,
	Entities.PU_LeaderRifle1,
	Entities.PU_LeaderCavalry1,
	Entities.PU_LeaderHeavyCavalry1,
	Entities.PU_LeaderSword2,
	Entities.PU_LeaderPoleArm2,
	Entities.PU_LeaderBow2,
	Entities.PU_LeaderSword3,
	Entities.PU_LeaderPoleArm3,
	Entities.PU_LeaderBow3,
	Entities.PU_LeaderSword4,
	Entities.PU_LeaderPoleArm4,
	Entities.PU_LeaderBow4,
	Entities.PU_LeaderRifle2,
	Entities.PU_LeaderCavalry2,
	Entities.PU_LeaderHeavyCavalry2},
	soldieramount = 1 + math.random(6), soldiercavamount = 1 + math.random(5) , starttime = {}, cooldown = 300, villageplacesneeded = 10 + math.random(5),
	UpdateTroopQuality = function(_time)
		gvLighthouse.troopamount = math.max(gvLighthouse.troopamount, math.min(round(3 ^ (1 + _time / 10000)), 10))
		gvLighthouse.soldieramount = math.max(gvLighthouse.soldieramount, math.min(round(2 ^ (1 + _time / 2000)), 12))
		if table.getn(gvLighthouse.troops) > 14 then
			table.remove(gvLighthouse.troops, math.random(1, table.getn(gvLighthouse.troops) - 14))
		elseif table.getn(gvLighthouse.troops) > 6 and table.getn(gvLighthouse.troops) <= 14 then
			table.remove(gvLighthouse.troops, math.random(1, table.getn(gvLighthouse.troops) - 6))
		end
	end
	}
if not CNetwork then
	gvLighthouse.starttime[1] = 0
else
	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		gvLighthouse.starttime[i] = 0
	end
end
gvLighthouse.RotationOffsets = {[0] = {X = -700, Y = -100},
								[90] = {X = 100, Y = -800},
								[180] = {X = 600, Y = 100},
								[270] = {X = -100, Y = 600},
								[360] = {X = -700, Y = -100}
							}
gvLighthouse.GetOffsetByOrientation = function(_rot)
	return gvLighthouse.RotationOffsets[_rot]
end
gvLighthouse.HireCosts = {	[ResourceType.Iron] = 600,
							[ResourceType.Sulfur] = 400
						}
gvLighthouse.CheckForResources = function(_playerID)
	for k,v in pairs(gvLighthouse.HireCosts) do
		if Logic.GetPlayersGlobalResource(_playerID, k) + Logic.GetPlayersGlobalResource(_playerID, k+1) < v then
			return false
		end
	end
	return true
end
gvLighthouse.PrepareSpawn = function(_playerID,_eID)
	gvLighthouse.starttime[_playerID] = Logic.GetTime()
	local _pos = {}
	_pos.X,_pos.Y = Logic.GetEntityPosition(_eID)
	local rot = Logic.GetEntityOrientation(_eID)
	local posadjust = gvLighthouse.GetOffsetByOrientation(rot)
	for k,v in pairs(gvLighthouse.HireCosts) do
		Logic.AddToPlayersGlobalResource(_playerID, k, -v)
	end
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "Lighthouse_SpawnTroops",1,{},{_playerID,(_pos.X + posadjust.X),(_pos.Y + posadjust.Y)} )
end
Lighthouse_SpawnTroops = function(_pID,_posX,_posY)
	if Logic.GetTime() >= gvLighthouse.starttime[_pID] + gvLighthouse.delay then
		gvLighthouse.UpdateTroopQuality(Logic.GetTime())
		-- Maximum number of settlers attracted?
		if Logic.GetPlayerAttractionUsage(_pID) >= Logic.GetPlayerAttractionLimit(_pID) then
			GUI.SendPopulationLimitReachedFeedbackEvent(_pID)
			return
		end
		if Logic.GetPlayerAttractionUsage(_pID) + gvLighthouse.villageplacesneeded >= Logic.GetPlayerAttractionLimit(_pID) then
			CreateGroup(_pID,gvLighthouse.troops[math.random(table.getn(gvLighthouse.troops))],gvLighthouse.soldieramount,_posX ,_posY,0)
			if _pID == GUI.GetPlayerID() then
				GUI.AddNote("Euer Siedlungsplatz war begrenzt. Es konnten nicht alle Verstärkungstruppen eintreffen!")
				Stream.Start("Voice\\cm_generictext\\supplytroopsarrive.mp3",110)
			end
			return true
		end
		for i = 1,gvLighthouse.troopamount do
			CreateGroup(_pID,gvLighthouse.troops[math.random(table.getn(gvLighthouse.troops))],gvLighthouse.soldieramount,_posX ,_posY,0)
		end
		if _pID == GUI.GetPlayerID() then
			GUI.AddNote("Verstärkungstruppen sind eingetroffen")
			Stream.Start("Voice\\cm_generictext\\supplytroopsarrive.mp3",110)
		end
		return true
	end
end