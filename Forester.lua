Forester = Forester or {}

-- table with landscape sets and respective tree types
Forester.LandscapeTreeSets = {["European"] = {	"XD_Tree1",
												"XD_Tree1_small",
												"XD_Tree2",
												"XD_Tree2_small",
												"XD_Tree3",
												"XD_Tree3_small",
												"XD_Tree4",
												"XD_Tree5",
												"XD_Tree6",
												"XD_Tree7",
												"XD_Tree8",
												"XD_Fir1",
												"XD_Fir1_small",
												"XD_Fir2",
												"XD_Fir2_small",
												"XD_DarkTree1",
												"XD_DarkTree2",
												"XD_DarkTree3",
												"XD_DarkTree4",
												"XD_DarkTree5",
												"XD_DarkTree6",
												"XD_DarkTree7",
												"XD_DarkTree8"
											},
							["Highlands"] = {	"XD_DeadTreeNorth1",
												"XD_DeadTreeNorth2",
												"XD_DeadTreeNorth3",
												"XD_Fir1",
												"XD_Fir1_small",
												"XD_Fir2",
												"XD_Fir2_small",
												"XD_PineNorth1",
												"XD_PineNorth2",
												"XD_PineNorth3",
												"XD_TreeNorth1",
												"XD_TreeNorth2",
												"XD_TreeNorth3"
											},
							["Mediterranean"] = {"XD_AppleTree1",
												"XD_AppleTree2",
												"XD_Cypress1",
												"XD_Cypress2",
												"XD_OliveTree1",
												"XD_OliveTree2",
												"XD_OrangeTree1",
												"XD_OrangeTree2",
												"XD_Palm1",
												"XD_Palm2",
												"XD_Palm3",
												"XD_Palm4",
												"XD_Pine1",
												"XD_Pine2",
												"XD_Pine3",
												"XD_Pine4",
												"XD_Pine5",
												"XD_Pine6"
											},
							["Steppe"] 	=	{	"XD_OliveTree1",
												"XD_OliveTree2",
												"XD_DeadTree1",
												"XD_DeadTree2",
												"XD_DeadTree4",
												"XD_DeadTree6",
												"XD_Palm1",
												"XD_Palm2",
												"XD_Palm3",
												"XD_Palm4",												
												"XD_Umbrella1",
												"XD_Umbrella2",
												"XD_Umbrella3"
											},
							["Evelance"] =	{	"XD_Fir1",
												"XD_Fir1_small",
												"XD_Fir2",
												"XD_Fir2_small",
												"XD_DeadTree1",
												"XD_DeadTree2",
												"XD_DeadTree4",
												"XD_DeadTree6",
												"XD_DeadTreeEvelance1",
												"XD_DeadTreeEvelance2",
												"XD_DeadTreeEvelance3",
												"XD_TreeEvelance1"
											},
							["Moor"]	=	{	"XD_DeadTreeMoor1",
												"XD_DeadTreeMoor2",
												"XD_DeadTreeMoor3",
												"XD_TreeMoor1",
												"XD_TreeMoor2",
												"XD_TreeMoor3",
												"XD_TreeMoor4",
												"XD_TreeMoor5",
												"XD_TreeMoor6",
												"XD_TreeMoor7",
												"XD_TreeMoor8",
												"XD_TreeMoor9"
											}
							}
-- table that concenates terrain types with landscape types 											
Forester.LandscapeTypeBySoilTexture = {
									[1] = "European",
									[2] = "European",
									[4] = "European",
									[5] = "European",
									[6] = "European",
									[7] = "European",
									[8] = "European",
									[13] = "European",
									[22] = "European",
									[23] = "European",
									[24] = "European",
									[25] = "European",
									[26] = "European",
									[32] = "European",
									[33] = "European",
									[34] = "European",
									[35] = "European",
									[36] = "European",
									[37] = "European",
									[38] = "European",
									[39] = "European",
									[40] = "European",
									[41] = "European",
									[42] = "European",
									[52] = "European",
									[75] = "Highlands",
									[76] = "Highlands",
									[78] = "Highlands",
									[79] = "Highlands",
									[100] = "Highlands",
									[101] = "Highlands",
									[102] = "Highlands",
									[103] = "Highlands",
									[104] = "Highlands",
									[105] = "Highlands",
									[106] = "Highlands",
									[109] = "Highlands",
									[116] = "Highlands",
									[117] = "Highlands",
									[124] = "Mediterranean",
									[125] = "Mediterranean",
									[126] = "Mediterranean",
									[127] = "Mediterranean",
									[128] = "Mediterranean",
									[129] = "Mediterranean",
									[130] = "Mediterranean",
									[131] = "Mediterranean",
									[132] = "European",
									[136] = "Evelance",
									[160] = "Steppe",
									[161] = "Steppe",
									[162] = "Steppe",
									[174] = "Steppe",
									[175] = "Steppe",
									[205] = "Moor",
									[206] = "Moor",
									[210] = "Moor",
									[211] = "Moor",
									[228] = "Moor",
									[229] = "Moor",
									}
-- max range in wich forester can plant trees
Forester.MaxRange = 3000
-- respective distance between searching points
Forester.SearchForFreeSpotRange = 500
-- minimum distance allowed between already existing/planted tree and new tree/ below no tree will be planted
Forester.AllowedInferenceRange = 300
-- delay forester needs to wait between work cycles
Forester.WorkCycleDelayBase = 10
Forester.WorkCycleDelay = {}
Forester.HomeSpotOffset = {	X = 0,
							Y = -500}
Forester.InitialTreeSizeFactor = 0.2	
Forester.TreeGrowthAmount = 0.02
Forester.TreeGrowthTimeNeeded = 2		
Forester.TreeGrowingBlockedPos = {}	
Forester.BuildingBelongingWorker = {}
Forester.WorkActiveState = {}
Forester.DoorOffsetByEntityType = {	[Entities.PB_VillageCenter1] = 	{X = -500,
																	Y = -600},
									[Entities.PB_VillageCenter2] = 	{X = -500,
																	Y = -600},	
									[Entities.PB_VillageCenter3] = 	{X = -500,
																	Y = -600},	
									[Entities.CB_Grange] = 			{X = -400,
																	Y = 200},	
									[Entities.PB_Castle1] = 		{X = -1000,
																	Y = -300},
									[Entities.PB_Castle2] = 		{X = -1000,
																	Y = -300},
									[Entities.PB_Castle3] = 		{X = -1000,
																	Y = -300},
									[Entities.PB_Castle4] = 		{X = -1000,
																	Y = -300},
									[Entities.PB_Castle5] = 		{X = -1000,
																	Y = -300}
									}
Forester.TriggerIDs = {	PrepareForPause = {},
						WorkControl = {	Start = {},
										Inside = {},
										Outside = {},
										ArrivedAtDestination = {},
										PrepareForPause = {}},						
						Tree = {	Growth = {},
									Cutted = {}},
						Behavior = {FinishAnim = {},
									ForesterDied = {}}						
						}
Forester.GetDistanceToNextPlantedTree = function(_posX, _posY)	
	local distance 
	for k,v in pairs(Forester.TreeGrowingBlockedPos) do
		local tempdistance = GetDistance({X = _posX, Y = _posY}, v)
		if not distance then
			distance = tempdistance
		else
			if tempdistance < distance then
				distance = tempdistance
			end
		end
	end
	return distance or 1000
end
Forester.GetWorkerIDByBuildingID = function(_id)
	return Forester.BuildingBelongingWorker[_id]
end
Forester.WorkChange = function(_id, _flag)
	local posX, posY = Logic.GetEntityPosition(_id)
	local workerID = Forester.GetWorkerIDByBuildingID(_id)
	if not workerID then	
		return
	end
	if _flag == 0 then
		Trigger.UnrequestTrigger(Forester.TriggerIDs.FinishAnim[workerID])
		Trigger.UnrequestTrigger(Forester.TriggerIDs.WorkControl.Inside[workerID])
		Trigger.UnrequestTrigger(Forester.TriggerIDs.WorkControl.Outside[workerID])
		Trigger.UnrequestTrigger(Forester.TriggerIDs.WorkControl.Start[workerID])
		Logic.MoveSettler(_id, posX + Forester.HomeSpotOffset.X, posY + Forester.HomeSpotOffset.Y)
		Forester.TriggerIDs.WorkControl.PrepareForPause[workerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_PrepareForPauseJob",1,{},{workerID, _id})
	elseif _flag == 1 then
		Forester.WorkActiveState[_id] = _flag
		Forester.UpdateWorkCycleDelay(workerID)
		Forester.TriggerIDs.WorkControl.Inside[workerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_WorkControl_Inside",1,{},{workerID, _id})	
	end
end
Forester.UpdateWorkCycleDelay = function(_id)
	local motivation = Logic.GetAverageMotivation(Logic.EntityGetPlayer(_id))
	Forester.WorkCycleDelay[_id] = math.max(round(Forester.WorkCycleDelayBase / (motivation^2)),1)
end
Forester.PlaceTree_StartAnim = function(_id, _buildingID, _posX, _posY, _terrType)
	if Forester.WorkActiveState[_buildingID] ~= 0 then
		Logic.SetTaskList(_id, TaskLists.TL_PLACE_TORCH)
		Forester.TriggerIDs.Behavior.FinishAnim[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,"","Forester_FinishAnimCheck",1,{},{_id, _buildingID, _posX, _posY, _terrType})
	end
end
Forester_FinishAnimCheck = function(_id, _buildingID, _posX, _posY, _terrType)
	if not IsExisting(_buildingID) then
		Logic.HurtEntity(_id, 100)
	end
	if not IsExisting(_id) then
		return true
	end
	
	if Logic.GetCurrentTaskList(_id) == "TL_NPC_IDLE" then		
		Forester.PlaceTree(_id, _buildingID, _posX, _posY, _terrType)
		return true
	end
end
Forester.PlaceTree = function(_id, _buildingID, _posX, _posY, _terrType)
	local id = Logic.CreateEntity(Entities.XD_Rock1, _posX, _posY, 0, 0)
	local suffixName = Forester.LandscapeTreeSets[Forester.LandscapeTypeBySoilTexture[_terrType]][math.random(table.getn(Forester.LandscapeTreeSets[Forester.LandscapeTypeBySoilTexture[_terrType]]))]
	Logic.SetModelAndAnimSet(id, _G["Models"][suffixName])
	SetEntitySize(id, Forester.InitialTreeSizeFactor)
	Forester.TriggerIDs.Tree.Growth[id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_TreeGrowthControl",1,{},{id, suffixName})
	table.insert(Forester.TreeGrowingBlockedPos, {X = _posX, Y = _posY})
	Forester.FinishWorkCycle(_id, _buildingID)	
end
Forester.FinishWorkCycle = function(_id, _buildingID)
	if not IsExisting(_buildingID) then
		Logic.HurtEntity(_id, 100)
	end
	if IsExisting(_id) then
		if Forester.WorkActiveState[_buildingID] ~= 0 then
		local posX, posY = Logic.GetEntityPosition(_buildingID)
		Logic.MoveSettler(_id, posX + Forester.HomeSpotOffset.X, posY + Forester.HomeSpotOffset.Y)		
		Forester.TriggerIDs.WorkControl.Start[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_WorkControl_Start",1,{},{_id, _buildingID})
		end
	end
end
Forester.FindNextTreePos = function(_id)

	local x, y = Logic.GetEntityPosition(_id)
	local offset = Forester.MaxRange
	local xmax, ymax = Logic.WorldGetSize()
	local dmin, xspawn, yspawn, tempterrType, terrType	
	local count, eID = Logic.GetEntitiesInArea(Entities.XD_TreeStump1, x, y, Forester.MaxRange, 1)	
	
	if count > 0 then
		local posX, posY = Logic.GetEntityPosition(eID)
		local height, blockingtype, sector, tempterrType = CUtil.GetTerrainInfo(posX, posY)
		if sector ~= 0 and blockingtype == 0 and Forester.LandscapeTypeBySoilTexture[tempterrType] ~= nil and (height > CUtil.GetWaterHeight(x/100, y/100)) then
		
			Logic.DestroyEntity(eID)		
			return posX, posY, tempterrType
		end
	end

	for y_ = y - offset, y + offset, Forester.SearchForFreeSpotRange do
	
		for x_ = x - offset, x + offset, Forester.SearchForFreeSpotRange do
		
			if 0 < x_ and 0 < y_ and x_ < xmax and y_ < ymax and (y_ ~= y and x_ ~= x) then				
				
				local d = (x_ - x)^2 + (y_ - y)^2
				local height, blockingtype, sector, tempterrType = CUtil.GetTerrainInfo(x_, y_)
				
				if sector ~= 0 and blockingtype == 0 and Forester.LandscapeTypeBySoilTexture[tempterrType] ~= nil and (height > CUtil.GetWaterHeight(x_/100, y_/100)) then
					
					if Forester.TreeGrowingBlockedPos[1] == nil or table.findvalue(Forester.TreeGrowingBlockedPos, {X = x_, Y = y_}) == 0 then		
						if Forester.GetDistanceToNextPlantedTree(x_, y_) >= Forester.AllowedInferenceRange then
							if not dmin or dmin > d then
							
								dmin = d
								terrType = tempterrType
								xspawn = x_
								yspawn = y_																	
							end		
						end				
					end						
				end
			end
		end
	end
	if xspawn then
		return xspawn, yspawn, terrType
	else
		return 0
	end
end

OnForester_Created = function(_id)  

	if IsExisting(_id) then
		if Logic.GetPlayerAttractionLimit(Logic.EntityGetPlayer(_id)) > 0 then
	
			local buildingposX, buildingposY = Logic.GetEntityPosition(_id)
			local playerID = Logic.EntityGetPlayer(_id)		
			local distancetable = {}

			for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(playerID), CEntityIterator.OfAnyTypeFilter(Entities.PB_VillageCenter1, Entities.PB_VillageCenter2, Entities.PB_VillageCenter3, Entities.CB_Grange, Entities.PB_Castle1, Entities.PB_Castle2, Entities.PB_Castle3, Entities.PB_Castle4, Entities.PB_Castle5)) do

				local posX, posY = Logic.GetEntityPosition(eID)			
				local distance = GetDistance({X = buildingposX, Y = buildingposY}, {X = posX, Y = posY})			
				table.insert(distancetable, {id = eID, dist = distance})
				
			end
			
			table.sort(distancetable, function(p1, p2)
				return p1.dist < p2.dist
			end)
			
			local posX, posY = Logic.GetEntityPosition(distancetable[1].id)		
			local rotation = Logic.GetEntityOrientation(distancetable[1].id)		
			local doorpos = Forester.DoorOffsetByEntityType[Logic.GetEntityType(distancetable[1].id)]		
			local r = math.rad(rotation)
			local s = math.sin(r)
			local c = math.cos(r)		
			local workerID = Logic.CreateEntity(Entities.PU_Forester, posX + (doorpos.X * c - doorpos.Y * s), posY + (doorpos.X * s + doorpos.Y * c), 0, playerID)
			Forester.BuildingBelongingWorker[_id] = workerID
			Logic.SetEntityScriptingValue(workerID,72,1)
			Logic.SetEntitySelectableFlag(workerID, 0)		
			
			Logic.MoveSettler(workerID, buildingposX + Forester.HomeSpotOffset.X, buildingposY + Forester.HomeSpotOffset.Y)

			Forester.TriggerIDs.WorkControl.Start[workerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_WorkControl_Start",1,{},{workerID, _id})
			Forester.TriggerIDs.Behavior.ForesterDied[workerID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED,"","OnForester_Died",1,{},{workerID, _id})
		end
	end
end
function OnForester_Died(_id, _buildingID)

	local entityID = Event.GetEntityID()	
    if entityID == _id then
		Forester.BuildingBelongingWorker[_buildingID] = nil
		if IsExisting(_buildingID) then	
			OnForester_Created(_buildingID)	
		else
			Forester.WorkActiveState[_buildingID] = nil
		end		
		Trigger.UnrequestTrigger(Forester.TriggerIDs.Behavior.ForesterDied[_id])
	end	
end
function Forester_Tree_OnTreeCutted(_id)

	local entityID = Event.GetEntityID()	
    if entityID == _id then
		removetablekeyvalue(Forester.TreeGrowingBlockedPos,GetPosition(_id))
		Trigger.UnrequestTrigger(Forester.TriggerIDs.Tree.Cutted[_id])
	end	
end
Forester_PrepareForPauseJob = function(_id, _buildingID)
	if not IsExisting(_buildingID) then
		Logic.HurtEntity(_id, 100)
	end
	if not IsExisting(_id) then
		return true
	end
	local buildingpos = GetPosition(_buildingID)
	local targetpos = {	X = buildingpos.X + Forester.HomeSpotOffset.X,
						Y = buildingpos.Y + Forester.HomeSpotOffset.Y}
	if Logic.GetCurrentTaskList(_id) == "TL_NPC_IDLE" then	
		if GetDistance(GetPosition(_id), {X = targetpos.X, Y = targetpos.Y}) <= 200 then
			Logic.MoveEntity(_id, buildingpos.X, buildingpos.Y)
			Forester.UpdateWorkCycleDelay(_id)
		else
			Logic.MoveSettler(_id, targetpos.X, targetpos.Y)
		end
	end
	if GetDistance(GetPosition(_id), buildingpos) <= 100 then
		Logic.SetEntityScriptingValue(_id, -30, 513)
		Forester.WorkActiveState[_buildingID] = 0
		return true
	end
end
Forester_WorkControl_Start = function(_id, _buildingID)
	if not IsExisting(_buildingID) then
		Logic.HurtEntity(_id, 100)
	end
	if not IsExisting(_id) then
		return true
	end
	local buildingpos = GetPosition(_buildingID)
	local targetpos = {	X = buildingpos.X + Forester.HomeSpotOffset.X,
						Y = buildingpos.Y + Forester.HomeSpotOffset.Y}
	if Logic.GetCurrentTaskList(_id) == "TL_NPC_IDLE" then	
		if GetDistance(GetPosition(_id), {X = targetpos.X, Y = targetpos.Y}) <= 200 then
			Logic.MoveEntity(_id, buildingpos.X, buildingpos.Y)
			Forester.UpdateWorkCycleDelay(_id)
		end
	end
	if GetDistance(GetPosition(_id), buildingpos) <= 100 then
		Logic.SetEntityScriptingValue(_id, -30, 513)
		Forester.TriggerIDs.WorkControl.Inside[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_WorkControl_Inside",1,{},{_id, _buildingID})	
		return true
	end
end
Forester_WorkControl_Inside = function(_id, _buildingID)
	if not IsExisting(_buildingID) then
		Logic.HurtEntity(_id, 100)
	end
	if not IsExisting(_id) then
		return true
	end
	if Forester.WorkActiveState[_buildingID] ~= 0 then
		local buildingpos = GetPosition(_buildingID)
		local targetpos = {	X = buildingpos.X + Forester.HomeSpotOffset.X,
							Y = buildingpos.Y + Forester.HomeSpotOffset.Y}
		if Logic.GetEntityScriptingValue(_id, -30) == 513 then
			if Counter.Tick2("Forester_WorkControl_Inside_Delay_".. _id, Forester.WorkCycleDelay[_id]) then
				Logic.MoveEntity(_id, math.floor(targetpos.X), math.floor(targetpos.Y))
				Logic.SetEntityScriptingValue(_id, -30, 65793)
				Logic.SetEntityScriptingValue(_id,72,1)
				Logic.SetEntitySelectableFlag(_id, 0)	
				Forester.TriggerIDs.WorkControl.Outside[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_WorkControl_Outside",1,{},{_id, _buildingID})		
				return true
			end
		end			
	else
		return true
	end
end
Forester_WorkControl_Outside = function(_id, _buildingID)
	if not IsExisting(_buildingID) then
		Logic.HurtEntity(_id, 100)
	end
	if not IsExisting(_id) then
		return true
	end
	local buildingpos = GetPosition(_buildingID)
	local targetpos = {	X = buildingpos.X + Forester.HomeSpotOffset.X,
						Y = buildingpos.Y + Forester.HomeSpotOffset.Y}
	if GetDistance(GetPosition(_id), {X = targetpos.X, Y = targetpos.Y}) <= 100 then
		if Counter.Tick2("Forester_WorkControl_Outside_Delay_".. _id, math.ceil(Forester.WorkCycleDelay[_id]/3)) then
			local posX, posY, terrType = Forester.FindNextTreePos(_id)
			if posX ~= 0 then
				Logic.MoveSettler(_id, posX, posY)
				Forester.TriggerIDs.WorkControl.ArrivedAtDestination[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_ArrivedAtDestinationCheck",1,{},{_id, _buildingID, posX, posY, terrType})				
				return true
			end
		end
	end
end
Forester_ArrivedAtDestinationCheck = function(_id, _buildingID, _posX, _posY, _terrType)

	if not IsExisting(_id) then
		return true
	end
	if GetDistance(GetPosition(_id), {X = _posX, Y = _posY}) <= 100 then
		Forester.PlaceTree_StartAnim(_id, _buildingID, _posX, _posY, _terrType)
		return true
	else
		if Counter.Tick2("Forester_ArrivedAtDestinationCheck_".. _id, Forester.WorkCycleDelay[_id]) then
			Logic.MoveSettler(_id, _posX, _posY)
		end
	end
end
Forester_TreeGrowthControl = function(_id, _suffixName)
	if not IsExisting(_id) then
		return true
	end
	if GetEntitySize(_id) >= 1 then
		local newID = ReplaceEntity(_id, _G["Entities"][_suffixName])		
		Forester.TriggerIDs.Tree.Cutted[newID] = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED,"","Forester_Tree_OnTreeCutted",1,{},{newID})
		return true
	else
		if Counter.Tick2("Forester_TreeGrowthControl_".. _id, Forester.TreeGrowthTimeNeeded) then
			local size = GetEntitySize(_id)
			__id = ReplaceEntity(_id, Entities.XD_Rock1)
			SetEntitySize(__id, math.min(size + Forester.TreeGrowthAmount, 1))
			Logic.SetModelAndAnimSet(__id, _G["Models"][_suffixName])
			Forester.TriggerIDs.Tree.Growth[__id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","Forester_TreeGrowthControl",1,{},{__id, _suffixName})
			return true
		end
	end
end