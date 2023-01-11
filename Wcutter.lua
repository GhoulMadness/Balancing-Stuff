
WCutter = WCutter or {}
-- max range woodcutter can find trees (s-cm)
WCutter.MaxRange = 2000
-- min time woodcutter needs to chop tree (sec)
WCutter.BaseTimeNeeded = 5
-- bonus time needed for chopping tree per ressource of respective tree (sec)
WCutter.TimeNeededPerRess = 0.5
-- maximum duration woodcutter needs to chop tree (sec)
WCutter.MaxTimeNeeded = 30
-- chop anim duration in ticks (sec/10)
WCutter.ChopSubAnimDuration = 15
-- range in which the woodcutter needs to be to start chopping tree (s-cm)
WCutter.ApproachRange = 100
-- fake entity to replace tree (needs same blocking params)
WCutter.FakeTreeType = {[1] = Entities.XD_Flower1,
						[2] = Entities.XD_BuildBlockScriptEntity,
						[3] = Entities.XD_Signpost1}
-- table filled with respective trigger type IDs
WCutter.TriggerIDs = {	StartWork = {},
						CutTree = {},
						RemoveTree = {}
					}
WCutter.FindNearestTree = function(_id)
	local distancetable = {}
	local x,y = Logic.GetEntityPosition(_id)
	for k,v in pairs(Forester.TreeGrowingBlockedPos) do	
		table.insert(distancetable, {id = Logic.GetEntityAtPosition(v.X, v.Y), dist = GetDistance({X = x, Y = y}, v)})
	end
	table.sort(distancetable, function(p1, p2) return p1.dist < p2.dist end)
	if distancetable[1].dist <= WCutter.MaxRange then
		return distancetable[1].id
	else
		return 0
	end
end
WCutter.StartWork = function(_id, _treeid)
	if not WCutter.TriggerIDs.StartWork[_id] then
		Logic.MoveSettler(_id, Logic.GetEntityPosition(_treeid))
		WCutter.TriggerIDs.StartWork[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "WCutter_ArrivedAtTreeCheck", 1, {}, {_id, _treeid})
	end
end
WCutter_ArrivedAtTreeCheck = function(_id, _treeid)
	if IsNear(_id, _treeid, WCutter.ApproachRange) then
		WCutter.TriggerIDs.StartWork[_id] = nil
		Trigger.UnrequestTrigger(WCutter.TriggerIDs.StartWork[_id])
		WCutter.CutTree(_id, _treeid)		
		return true
	else
		if Logic.GetCurrentTaskList(_id) == "TL_WORKER_IDLE" then
			Logic.MoveSettler(_id, _treeid)
		end
	end
end
WCutter.CutTree = function(_id, _treeid)
	local res_amount = Logic.GetEntityResourceAmount(_treeid)
	local newID, etype = WCutter.BlockTree(_treeid, 2)
	_treeid = newID
	if res_amount > 0 then
		WCutter.TriggerIDs.CutTree[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "WCutter_CutTreeDelay", 1, {}, {_id, _treeid, etype, res_amount})
	else	
		SetEntityCurrentTaskIndex(_id, 3)
	end
end
WCutter.BlockTree = function(_treeid, _flag)
	--[[ _flag param: 0: unblock
					1: soft block - tree cannot be cut but approached
					2: hard block - tree can neither be approached nor cut
					]]
	local etype = Logic.GetEntityType(_treeid)
	local model = Models[Logic.GetEntityTypeName(etype)]
	local newID = ReplaceEntity(_treeid, WCutter.FakeTreeType[_flag + 1])		

	Logic.SetModelAndAnimSet(newID, model)
	return newID, etype
end
WCutter_CutTreeDelay = function(_id, _treeid, _tree_type, _res_amount)
	if Counter.Tick2("WCutter_CutTreeDelay_".._id.."_".._treeid) >= (math.min(WCutter.BaseTimeNeeded + WCutter.TimeNeededPerRess * _res_amount, WCutter.MaxTimeNeeded)) then
		local newID
		if IsValid(_treeid) then
			newID = ReplaceEntity(_treeid, _tree_type)
			WCutter.BlockTree(newID, 1)
			--TODO: Tree needs to be blocked so no serfs can chop it during subanim 
		end 
		if newID then
			--TODO: SubAnim ChopTree ausführen
			WCutter.TriggerIDs.CutTree[_id] = nil
			Trigger.UnrequestTrigger(WCutter.TriggerIDs.CutTree[_id])
			WCutter.TriggerIDs.RemoveTree[_id] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "WCutter_RemoveTree", 1, {}, {_id, newID, _res_amount})
			return true
		end
	end
end
WCutter_RemoveTree = function(_id, _treeid, _res_amount)
	if Counter.Tick2("WCutter_RemoveTree_".._id.."_".._treeid) >= WCutter.ChopSubAnimDuration then
		Logic.DestroyEntity(_treeid)
		Logic.AddToPlayersGlobalResource(Logic.EntityGetPlayer(_id), ResourceType.WoodRaw, _res_amount)
		WCutter.EndWorkCycle(_id)
		WCutter.TriggerIDs.RemoveTree[_id] = nil
		Trigger.UnrequestTrigger(WCutter.TriggerIDs.RemoveTree[_id])
		return true
	end
end
WCutter.EndWorkCycle = function(_id)
	SetEntityCurrentTaskIndex(_id, 1)		
end
