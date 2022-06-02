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
	Entities.PU_LeaderHeavyCavalry2
									} 
, soldieramount = 1 + math.random(6), soldiercavamount = 1 + math.random(5) , starttime = {}, cooldown = 300, villageplacesneeded = 10 + math.random(5),
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
function Lighthouse_SpawnJob(_playerID,_eID)
	local _pos = {}
	_pos.X,_pos.Y = Logic.GetEntityPosition(_eID)
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
	Logic.AddToPlayersGlobalResource(_playerID,ResourceType.Iron,-600)
	Logic.AddToPlayersGlobalResource(_playerID,ResourceType.Sulfur,-400)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "Lighthouse_SpawnTroops",1,{},{_playerID,(_pos.X + posadjust.X),(_pos.Y + posadjust.Y)} )	
end
function Lighthouse_SpawnTroops(_pID,_posX,_posY)
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