------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Lighthouse Comforts ----------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
gvLighthouse = { delay = 60 + Logic.GetRandom(30) , troopamount = 3 + Logic.GetRandom(4) , techlevel = 2 + Logic.GetRandom(1) , troops = {
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
, soldieramount = 2 + Logic.GetRandom(10), soldiercavamount = 1 + Logic.GetRandom(5) , starttime = {}, cooldown = 300
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
		-- Maximum number of settlers attracted?
		if Logic.GetPlayerAttractionUsage(_pID) >= Logic.GetPlayerAttractionLimit(_pID) then
			GUI.SendPopulationLimitReachedFeedbackEvent(_pID)
			return
		end
		for i = 1,gvLighthouse.troopamount do 
			CreateGroup(_pID,gvLighthouse.troops[Logic.GetRandom(17)+1],gvLighthouse.soldieramount,_posX ,_posY,0)
		end
		if _pID == GUI.GetPlayerID() then
			GUI.AddNote("Verst\195\164rkungstruppen sind eingetroffen")
			Stream.Start("Voice\\cm_generictext\\supplytroopsarrive.mp3",110)
		end
		return true
	end
end