HurtProjectileFix = {projectileMem={}, lastProjectile={}, projectilesToAdd={}}

function HurtProjectileFix.OnEffectCreated(effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId, isHookCreated)
	if creatorType == 7816856 then
		if IsValid(attackerId) and isHookCreated==0 then
			HurtProjectileFix.projectilesToAdd[effectId] = attackerId
		end
	end
end

function HurtProjectileFix.AddOnTick()
	for effectId, attackerId in pairs(HurtProjectileFix.projectilesToAdd) do
		HurtProjectileFix.AddProjectileToFix(effectId,
			Logic.GetEntityDamage(attackerId), -- modified by hero auras and techs
			MemoryManipulation.GetSettlerTypeDamageClass(Logic.GetEntityType(attackerId))
		)
	end
	HurtProjectileFix.projectilesToAdd = {}
end

function HurtProjectileFix.AddOnDestroy()
	local id = Event.GetEntityID()
	local effs = {}
	for effectId, attackerId in pairs(HurtProjectileFix.projectilesToAdd) do
		if id==attackerId then
			HurtProjectileFix.AddProjectileToFix(effectId,
				Logic.GetEntityDamage(attackerId), -- modified by hero auras and techs
				MemoryManipulation.GetSettlerTypeDamageClass(Logic.GetEntityType(attackerId))
			)
		end
		table.insert(effs, effectId)
	end
	for _,eid in ipairs(effs) do
		HurtProjectileFix.projectilesToAdd[eid] = nil
	end
end

function HurtProjectileFix.AddProjectileToFix(effectId, baseDamage, damageClass)
	HurtProjectileFix.projectileMem[effectId] = {
		baseDamage = baseDamage,
		damageClass = damageClass,
	}
end

function HurtProjectileFix.OnProjectileHit(effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	if HurtProjectileFix.projectilesToAdd[effectId] then
		HurtProjectileFix.AddProjectileToFix(effectId,
			Logic.GetEntityDamage(HurtProjectileFix.projectilesToAdd[effectId]), -- modified by hero auras and techs
			MemoryManipulation.GetSettlerTypeDamageClass(Logic.GetEntityType(HurtProjectileFix.projectilesToAdd[effectId]))
		)
		HurtProjectileFix.projectilesToAdd[effectId] = nil
	end
	HurtProjectileFix.lastProjectile = HurtProjectileFix.projectileMem[effectId]
	HurtProjectileFix.projectileMem[effectId] = nil
end

function HurtProjectileFix.OnHit()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	local pinf = TriggerFixExtHurtEntity.HurtTrigger_GetProjectileInfo()
	if so == S5HookHurtEntitySources.CannonProjectile and pinf and HurtProjectileFix.lastProjectile then
		local at = Event.GetEntityID1()
		local def = Event.GetEntityID2()
		local dmod = HurtProjectileFix.GetDamageMod(MemoryManipulation.GetEntityTypeArmorClass(Logic.GetEntityType(def)), HurtProjectileFix.lastProjectile.damageClass)
		local distmod = (pinf.radius - GetDistance(def, pinf.targetPos)) / pinf.radius
		local dmg = HurtProjectileFix.lastProjectile.baseDamage * dmod * distmod - Logic.GetEntityArmor(def)
		S5Hook.HurtEntityTrigger_SetDamage(math.max(dmg, 1))
	end
end

function HurtProjectileFix.GetDamageMod(ac, dc)
	return MemoryManipulation.GetDamageModifier(dc, ac)
end

function HurtProjectileFix.Init()
	TriggerFixExtHurtEntity.AddEffectCreatedCallback(HurtProjectileFix.OnEffectCreated)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, "HurtProjectileFix.AddOnDestroy", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "HurtProjectileFix.AddOnTick", 1)
	TriggerFixExtHurtEntity.AddProjectileHitCb(HurtProjectileFix.OnProjectileHit)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "HurtProjectileFix.OnHit", 1)
end
TriggerFix = {triggers={}, nId=0, idToTrigger={}, currStartTime=0, afterTriggerCB={}, onHackTrigger={}, ShowErrorMessageText={}, xpcallTimeMsg=false, currentEvent=nil}
TriggerFix_mode = TriggerFix_mode or (LuaDebugger.Log and "Debugger" or "Xpcall")
TriggerFix.xpcallTimeMsg=true

function TriggerFix.AddTrigger(event, con, act, active, acon, aact, comm)
	if not TriggerFix.triggers[event] then
		TriggerFix.triggers[event] = {}
	end
	local tid = TriggerFix.nId
	TriggerFix.nId = TriggerFix.nId + 1
	if con == "" then
		con = nil
	end
	if type(con)=="string" then
		con = TriggerFix.SplitTableIndexPath(con)
	end
	if type(act)=="string" then
		act = TriggerFix.SplitTableIndexPath(act)
	end
	local t = {event=event, con=con, act=act, active=active, acon=acon or {}, aact=aact or {}, tid=tid, err=nil, time=0, comm=comm}
	table.insert(TriggerFix.triggers[event], t)
	TriggerFix.idToTrigger[tid] = t
	return tid
end

function TriggerFix.RemoveTrigger(tid)
	local t = TriggerFix.idToTrigger[tid]
	local ev = TriggerFix.triggers[t.event]
	for i=table.getn(ev),1,-1 do
		if ev[i]==t then
			table.remove(ev, i)
		end
	end
	TriggerFix.idToTrigger[tid] = nil
end

function TriggerFix.ExecuteSingleTrigger(t)
	if t.con then
		local ret = TriggerFix.GetTriggerFunc(t.con, t.acon[1])(unpack(t.acon))
		if not ret or ret==0 then
			return nil, true
		end
	end
	return TriggerFix.GetTriggerFunc(t.act, t.aact[1])(unpack(t.aact))
end

function TriggerFix.GetTriggerFunc(f, obj)
	local t = type(f)
	if t=="function" then
		return f
	end
	if t=="string" then
		return _G[f]
	end
	if t=="table" then
		local ta = _G
		if f.object then
			ta = obj
		end
		for _, k in ipairs(f) do
			ta = ta[k]
		end
		return ta
	end
end

function TriggerFix.ExecuteAllTriggersOfEventDebugger(event, cev)
	TriggerFix.currStartTime = XGUIEng.GetSystemTime()
	if not cev then
		cev = {}
		for k,v in pairs(TriggerFix.event) do
			cev[k] = v()
		end
	end
	local ev = TriggerFix.triggers[event]
	local rem, remi = {}, 1
	for _, t in ipairs(ev) do
		if t.active and t.active~=0 then
			local tim = XGUIEng.GetSystemTime()
			TriggerFix.currentEvent = cev
			local r = TriggerFix.ExecuteSingleTrigger(t)
			t.time=XGUIEng.GetSystemTime()-tim
			if r and r~=0 then
				rem[remi] = t.tid
				remi = remi + 1
			end
		end
	end
	for _,tid in ipairs(rem) do
		TriggerFix.RemoveTrigger(tid)
	end
	for _,f in ipairs(TriggerFix.afterTriggerCB) do
		TriggerFix.currentEvent = cev
		f(event)
	end
	local rtime = XGUIEng.GetSystemTime()-TriggerFix.currStartTime
	if rtime > 0.03 and KeyOf then
		Message("@color:255,0,0 Trigger "..KeyOf(event, Events).." runtime too long: "..rtime)
		if TriggerFix.breakOnRuntimeAlert then
			LuaDebugger.Break()
		end
	end
	TriggerFix.currentEvent = nil
end

function TriggerFix.ExecuteAllTriggersOfEventXpcall(event, cev)
	TriggerFix.currStartTime = XGUIEng.GetSystemTime()
	if not cev then
		cev = {}
		for k,v in pairs(TriggerFix.event) do
			cev[k] = v()
		end
	end
	local ev = TriggerFix.triggers[event]
	local rem, remi = {}, 1
	for _, t in ipairs(ev) do
		if t.active and t.active~=0 then
			local tim = XGUIEng.GetSystemTime()
			local r = nil
			TriggerFix.currentEvent = cev
			xpcall(function()
				r = TriggerFix.ExecuteSingleTrigger(t)
			end, TriggerFix.ShowErrorMessage)
			t.time=XGUIEng.GetSystemTime()-tim
			if r then
				rem[remi] = t.tid
				remi = remi + 1
			end
		end
	end
	for _,tid in ipairs(rem) do
		TriggerFix.RemoveTrigger(tid)
	end
	for _,f in ipairs(TriggerFix.afterTriggerCB) do
		TriggerFix.currentEvent = cev
		f(event)
	end
	local rtime = XGUIEng.GetSystemTime()-TriggerFix.currStartTime
	if rtime > 0.03 and TriggerFix.xpcallTimeMsg and KeyOf then
		Message("@color:255,0,0 Trigger "..KeyOf(event, Events).." runtime too long: "..rtime)
	end
	TriggerFix.currentEvent = nil
end

function TriggerFix.ShowErrorMessage(txt)
	if S5Hook then
		S5Hook.Log("TriggerFix error catched: "..txt)
	end
	Message("@color:255,0,0 Err:")
	Message(txt)
	table.insert(TriggerFix.ShowErrorMessageText, txt)
	if table.getn(TriggerFix.ShowErrorMessageText) > 15 then
		table.remove(TriggerFix.ShowErrorMessageText)
	end
	XGUIEng.ShowWidget("DebugWindow", 1)
end
GUIUpdate_UpdateDebugInfo = function()
	local txt = ""
	for k,v in ipairs(TriggerFix.ShowErrorMessageText) do
		txt = txt.." @color:255,0,0 "..v.." @cr "
	end
	XGUIEng.SetText("DebugWindow", txt)
end

function TriggerFix.SplitTableIndexPath(s)
	if string.sub(s, 1, 1)==":" then
		local r = TriggerFix.SplitTableIndexPath(string.sub(s, 2))
		if type(r)=="string" then
			r = {r}
		end
		r.object = true
		return r
	end
	if not string.find(s, ".", nil, true) then
		return s
	end
	local t = {}
	local find, i = true, nil
	while true do
		i, i, find, s = string.find(s, "^([%w_]+)%.([%w_.]+)$")
		table.insert(t, find)
		if not string.find(s, ".", nil, true) then
			table.insert(t, s)
			return t
		end
	end
end


function TriggerFix.HackTrigger()
	if not unpack{true} then
		unpack = function(t, i)
			i = i or 1
			if i <= table.getn(t) then
				return t[i], unpack(t, i+1)
			end
		end
	end
	TriggerFix.RequestTrigger = Trigger.RequestTrigger
	Trigger.RequestTrigger = function(typ, con, act, active, acon, aact)
		return TriggerFix.AddTrigger(typ, con, act, active, acon, aact)
	end
	TriggerFix.UnrequestTrigger = Trigger.UnrequestTrigger
	Trigger.UnrequestTrigger = function(tid)
		if TriggerFix.idToTrigger[tid] then
			return TriggerFix.RemoveTrigger(tid)
		end
	end
	TriggerFix.DisableTrigger = Trigger.DisableTrigger
	Trigger.DisableTrigger = function(tid)
		if TriggerFix.idToTrigger[tid] then
			TriggerFix.idToTrigger[tid].active = 0
			return true
		end
	end
	TriggerFix.EnableTrigger = Trigger.EnableTrigger
	Trigger.EnableTrigger = function(tid)
		if TriggerFix.idToTrigger[tid] then
			TriggerFix.idToTrigger[tid].active = 1
			return true
		end
	end
	TriggerFix.IsTriggerEnabled = Trigger.IsTriggerEnabled
	Trigger.IsTriggerEnabled = function(tid)
		if TriggerFix.idToTrigger[tid] then
			return TriggerFix.idToTrigger[tid].active
		end
	end
	TriggerFix.event = {}
	for k,v in pairs(Event) do
		TriggerFix.event[k] = v
	end
	for k,v in pairs(TriggerFix.event) do
		local name = k	-- upvalue, muss aber sowieso nach jedem laden neu initialisiert werden
		Event[name] = function()
			if TriggerFix.currentEvent then
				return TriggerFix.currentEvent[name]
			end
			return TriggerFix.event[name]()
		end
	end
	for _,f in ipairs(TriggerFix.onHackTrigger) do
		f()
	end
end

function TriggerFix.ProtectedCall(func, ...)
	if LuaDebugger.Log then
		return func(unpack(arg))
	end
	local r = nil
	xpcall(function()
		r = {func(unpack(arg))}
	end, function(err)
		TriggerFix.ShowErrorMessage("protectedCall: "..err)
	end)
	return unpack(r)
end

function TriggerFix.CheckTriggerRuntime()
	local ct = nil
	for _,t in pairs(TriggerFix.idToTrigger) do
		if not ct or ct.time < t.time then
			ct = t
		end
	end
	return ct
end

function TriggerFix.Init()
	TriggerFix_action = TriggerFix["ExecuteAllTriggersOfEvent"..TriggerFix_mode]
	TriggerFix.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
	Mission_OnSaveGameLoaded = function()
		TriggerFix.HackTrigger()
		TriggerFix.Mission_OnSaveGameLoaded()
	end
	TriggerFix.HackTrigger()
	for _,event in ipairs{
		Events.LOGIC_EVENT_DIPLOMACY_CHANGED, Events.LOGIC_EVENT_ENTITY_CREATED, Events.LOGIC_EVENT_ENTITY_DESTROYED,
		Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY,
		Events.LOGIC_EVENT_EVERY_SECOND, Events.LOGIC_EVENT_EVERY_TURN, Events.LOGIC_EVENT_GOODS_TRADED,
		Events.LOGIC_EVENT_RESEARCH_DONE, Events.LOGIC_EVENT_TRIBUTE_PAID, Events.LOGIC_EVENT_WEATHER_STATE_CHANGED,
	} do
		if not TriggerFix.triggers[event] then
			TriggerFix.triggers[event] = {}
		end
		TriggerFix.RequestTrigger(event, nil, "TriggerFix_action", 1, nil, {event})
	end
	if not TriggerFix.triggers[Events.LOGIC_EVENT_ENTITY_HURT_ENTITY] then
		TriggerFix.triggers[Events.LOGIC_EVENT_ENTITY_HURT_ENTITY] = {}
	end
	TriggerFix.entityHurtEntityBaseTriggerId = TriggerFix.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "TriggerFix_action", 1, nil, {Events.LOGIC_EVENT_ENTITY_HURT_ENTITY})
	StartSimpleJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, f, 1, nil, arg)
	end
	StartSimpleHiResJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, f, 1, nil, arg)
	end
	StartJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "Condition_"..f, "Action_"..f, 1, arg, arg)
	end
	StartHiResJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "Condition_"..f, "Action_"..f, 1, arg, arg)
	end
end
TriggerFix.Init()


TriggerFix.LowPriorityJob = {next = 1}
function TriggerFix.LowPriorityJob.RunTrigger(t)
	while true do
		if XGUIEng.GetSystemTime()-TriggerFix.currStartTime >= (0.03 - (t.needTime or 0.005)) then
			return true
		end
		local r, c = TriggerFix.ExecuteSingleTrigger(t)
		if not r and c then
			return
		end
		if r then
			return nil, r
		end
	end
end

function TriggerFix.LowPriorityJob.Run()
	local ev = TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY]
	while true do
		local t = ev[TriggerFix.LowPriorityJob.next]
		if not t then
			TriggerFix.LowPriorityJob.next = 1
			return
		end
		local nt, r = TriggerFix.LowPriorityJob.RunTrigger(t)
		if r==-1 then
			TriggerFix.LowPriorityJob.next = TriggerFix.LowPriorityJob.next + 1
			r = nil
		end
		if type(r)=="number" then
			t.needTime = r
			r = nil
		end
		if r then
			TriggerFix.RemoveTrigger(t.tid)
		end
		if nt then
			TriggerFix.LowPriorityJob.next = 1
			return
		end
	end
end

function TriggerFix.LowPriorityJob.Init()
	Events.SCRIPT_EVENT_LOW_PRIORITY = "mcb_lpj"
	if not TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY] then
		TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY] = {}
	end
	table.insert(TriggerFix.afterTriggerCB, function(event)
		if event ~= Events.LOGIC_EVENT_EVERY_TURN then
			return
		end
		if not TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY][1] then
			return
		end
		TriggerFix.LowPriorityJob.Run()
	end)
	table.insert(TriggerFix.onHackTrigger, function()
		Events.SCRIPT_EVENT_LOW_PRIORITY = "mcb_lpj"
	end)
	StartSimpleLowPriorityJob = function(f, ...)
		return Trigger.RequestTrigger(Events.SCRIPT_EVENT_LOW_PRIORITY, nil, f, 1, nil, arg)
	end
end
TriggerFix.LowPriorityJob.Init()

TriggerFix.KillTrigger = {}

function TriggerFix.KillTrigger.Init()
	Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY = "mcb_kill"
	if not TriggerFix.triggers[Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY] then
		TriggerFix.triggers[Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY] = {}
	end
	table.insert(TriggerFix.afterTriggerCB, function(event)
		if event ~= Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
			return
		end
		if not S5Hook or not S5Hook.HurtEntityTrigger_GetDamage then
			return
		end
		if not TriggerFix.triggers[Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY][1] then
			S5Hook.HurtEntityTrigger_Reset()
			return
		end
		TriggerFix.KillTrigger.Run()
		S5Hook.HurtEntityTrigger_Reset()
	end)
	table.insert(TriggerFix.onHackTrigger, function()
		Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY = "mcb_kill"
	end)
end

function TriggerFix.KillTrigger.Run()
	local id = Event.GetEntityID2()
	local dmg = S5Hook.HurtEntityTrigger_GetDamage()
	if MemoryManipulation.IsSoldier(id) then
		id = MemoryManipulation.GetLeaderOfSoldier(id)
	end
	if Logic.IsLeader(id)==1 and Logic.LeaderGetNumberOfSoldiers(id)>=1 then
		local solth = MemoryManipulation.GetLeaderTroopHealth(id)
		local solph = MemoryManipulation.GetEntityTypeMaxHealth(Logic.LeaderGetSoldiersType(id))
		if solth == -1 then
			solth = (Logic.LeaderGetNumberOfSoldiers(id)) * solph
		end
		local sols = {Logic.GetSoldiersAttachedToLeader(id)}
		table.remove(sols, 1)
		local newsolh = solth - dmg
		for i,sid in ipairs(sols) do
			if ((Logic.LeaderGetNumberOfSoldiers(id)-i) * solph) > newsolh then
				local t = {}
				for k,v in pairs(TriggerFix.event) do
					t[k] = 0
				end
				t.GetEntityID1 = Event.GetEntityID1()
				t.GetEntityID2 = sid
				TriggerFix["ExecuteAllTriggersOfEvent"..TriggerFix_mode](Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY, t)
			else
				break
			end
		end
		dmg = math.max(0, -newsolh)
	end
	if Logic.GetEntityHealth(id) <= dmg then
		local t = {}
		for k,v in pairs(TriggerFix.event) do
			t[k] = 0
		end
		t.GetEntityID1 = Event.GetEntityID1()
		t.GetEntityID2 = id
		TriggerFix["ExecuteAllTriggersOfEvent"..TriggerFix_mode](Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY, t)
	end
end
TriggerFix.KillTrigger.Init()
TriggerFixExtHurtEntity = {projectiles={}, currentProjectile={}, createdCbs={}, hitCbs={}, currentEntity={}}

function TriggerFixExtHurtEntity.InternalEffectCreatedCallback(effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId, isHookCreated)
	if creatorType == 7816856 then
		TriggerFixExtHurtEntity.projectiles[effectId] = {
			effectType = effectType,
			playerId = playerId,
			attackerPlayer = GetPlayer(attackerId),
			startPos = {X=startPosX, Y=startPosY},
			targetPos = {X=targetPosX,Y=targetPosY},
			attackerId = attackerId,
			targetId = targetId,
			damage = damage,
			radius = radius,
			effectId = effectId,
			isHookCreated = isHookCreated,
		}
	elseif creatorType ~= 7790912 then
		LuaDebugger.Log("unknown effect created: "..creatorType)
	end
	for _,f in ipairs(TriggerFixExtHurtEntity.createdCbs) do
		TriggerFix.ProtectedCall(f, effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId, isHookCreated)
	end
end

function TriggerFixExtHurtEntity.AddEffectCreatedCallback(func)
	table.insert(TriggerFixExtHurtEntity.createdCbs, func)
end

function TriggerFixExtHurtEntity.RemoveEffectCreatedCb(func)
	for i=table.getn(TriggerFixExtHurtEntity.createdCbs),1,-1 do
		if TriggerFixExtHurtEntity.createdCbs[i]==func then
			table.remove(TriggerFixExtHurtEntity.createdCbs, i)
		end
	end
end

function TriggerFixExtHurtEntity.InternalProjectileHitCallback(effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	TriggerFixExtHurtEntity.currentProjectile = TriggerFixExtHurtEntity.projectiles[effectId]
	TriggerFixExtHurtEntity.projectiles[effectId] = nil
	TriggerFixExtHurtEntity.currentProjectile.tick = Logic.GetTimeMs()
	if TriggerFixExtHurtEntity.currentEntity.tick==TriggerFixExtHurtEntity.currentProjectile.tick then
		TriggerFixExtHurtEntity.currentEntity = {}
	end
	for _,f in ipairs(TriggerFixExtHurtEntity.hitCbs) do
		TriggerFix.ProtectedCall(f, effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	end
end

function TriggerFixExtHurtEntity.AddProjectileHitCb(func)
	table.insert(TriggerFixExtHurtEntity.hitCbs, func)
end

function TriggerFixExtHurtEntity.RemoveProjectileHitCb(func)
	for i=table.getn(TriggerFixExtHurtEntity.hitCbs),1,-1 do
		if TriggerFixExtHurtEntity.hitCbs[i]==func then
			table.remove(TriggerFixExtHurtEntity.hitCbs, i)
		end
	end
end

function TriggerFixExtHurtEntity.HurtTrigger_GetProjectileInfo()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	if (so == S5HookHurtEntitySources.ArrowProjectile or so == S5HookHurtEntitySources.CannonProjectile
	or so == S5HookHurtEntitySources.SniperAttackAbility) and TriggerFixExtHurtEntity.currentProjectile.tick==Logic.GetTimeMs() then
		return TriggerFixExtHurtEntity.currentProjectile
	end
end

function TriggerFixExtHurtEntity.HurtTrigger_GetEntityInfo()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	if (so == S5HookHurtEntitySources.ArrowProjectile or so == S5HookHurtEntitySources.CannonProjectile
	or so == S5HookHurtEntitySources.SniperAttackAbility) and TriggerFixExtHurtEntity.currentEntity.tick==Logic.GetTimeMs() then
		return TriggerFixExtHurtEntity.currentEntity
	end
end

function TriggerFixExtHurtEntity.InternalHurtEntityCallback(attackerId, targetId)
	if attackerId==0 then
		local pinf = TriggerFixExtHurtEntity.HurtTrigger_GetProjectileInfo()
		local einf = TriggerFixExtHurtEntity.HurtTrigger_GetEntityInfo()
		if pinf then
			attackerId = pinf.attackerId
		elseif einf then
			attackerId = einf.attackerId
		end
	end
	local t = {}
	for k,v in pairs(TriggerFix.event) do
		t[k] = 0
	end
	t.GetEntityID1 = attackerId
	t.GetEntityID2 = targetId
	TriggerFix_action(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, t)
end

function TriggerFixExtHurtEntity.InternalDestroyedTrigger()
	local id = Event.GetEntityID()
	local ty = Logic.GetEntityType(id)
	if MemoryManipulation.HasEntityBehavior(id, MemoryManipulation.ClassVTable.GGL_CBombBehavior)
	or MemoryManipulation.HasEntityBehavior(id, MemoryManipulation.ClassVTable.GGL_CKegBehavior) then
		TriggerFixExtHurtEntity.currentEntity = {
			tick = Logic.GetTimeMs(),
			attackerId = id,
			attackerPlayer = GetPlayer(id),
			attackerType = ty,
		}
		if TriggerFixExtHurtEntity.currentEntity.tick==TriggerFixExtHurtEntity.currentProjectile.tick then
			TriggerFixExtHurtEntity.currentProjectile = {}
		end
	end
end

function TriggerFixExtHurtEntity.Init()
	TriggerFix.UnrequestTrigger(TriggerFix.entityHurtEntityBaseTriggerId)
	S5Hook.SetEffectCreatedCallback(TriggerFixExtHurtEntity.InternalEffectCreatedCallback)
	S5Hook.SetGlobalProjectileHitCallback(TriggerFixExtHurtEntity.InternalProjectileHitCallback)
	S5Hook.SetHurtEntityCallback(TriggerFixExtHurtEntity.InternalHurtEntityCallback)
	if not TriggerFixExtHurtEntity.InternalDestroyedTriggerId then
		TriggerFixExtHurtEntity.InternalDestroyedTriggerId = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, "TriggerFixExtHurtEntity.InternalDestroyedTrigger", 1)
	end
end
