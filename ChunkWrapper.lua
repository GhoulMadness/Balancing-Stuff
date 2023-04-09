ChunkFilter = {};

function ChunkFilter.new()
	return {
		EntityCategories = {};
		FunctionFilter = {};
		FunctionFilterArgs = {};
	};
end;

function ChunkFilter.AddEntityCategory(_filter, _eCat)
	table.insert(_filter.EntityCategories, _eCat);
end;

function ChunkFilter.CheckEntity(_filter, _id)

	for i = 1,table.getn(_filter.EntityCategories) do
		local ecat = _filter.EntityCategories[i];
		if Logic.IsEntityInCategory(_id, ecat) == 1 then
			return true;
		end;
	end;

	for i = 1, table.getn(_filter.FunctionFilter) do
		if _filter.FunctionFilter[i](_id, unpack(_filter.FunctionFilterArgs[i])) then
			return true;
		end;
	end;

	return false;
end;

function ChunkFilter.AddFunctionFilter(_filter, _function, ...)
	table.insert(_filter.FunctionFilter, _function);
	table.insert(_filter.FunctionFilterArgs, arg);
end;


ChunkWrapper = ChunkWrapper or {chunks={}};
function ChunkWrapper.new(_filter)
	local t = {
		Entities = {};
		Dirty = false;
		LastUpdate = 0;

		Filter = _filter or ChunkFilter.new();
		-- chunk = <UserData>
	};

	table.insert(ChunkWrapper.chunks, t);

	return t;
end;

function ChunkWrapper.destroy(chunk)
	for i = table.getn(ChunkWrapper.chunks), 1, -1 do
		if ChunkWrapper.chunks[i] == chunk then
			table.remove(ChunkWrapper.chunks, i);
		end;
	end;
end;


function ChunkWrapper.AddEntity(chunk, _id)
	chunk.Entities[_id] = true;
	chunk.Dirty = true;
	ChunkWrapper.Internal_GetOrInit(chunk):AddEntity(_id);
end;

function ChunkWrapper.Internal_GetOrInit(chunk)
	return (chunk.chunk or ChunkWrapper.Internal_Init(chunk) or chunk.chunk);
end;

function ChunkWrapper.RemoveEntity(chunk, _id)
	if chunk.Entities[_id] then
		chunk.Entities[_id] = nil;
		chunk.Dirty = true;
		ChunkWrapper.Internal_GetOrInit(chunk):RemoveEntity(_id);
	end;
end;

function ChunkWrapper.Internal_Init(chunk)
	chunk.chunk = CUtil.Chunks.new();
	for id, _ in pairs(chunk.Entities) do
		chunk.chunk:AddEntity(id)
	end;
end;

function ChunkWrapper.UpdatePositions(chunk)
	if chunk.Dirty or chunk.LastUpdate ~= Logic.GetTimeMs() then
		chunk.Dirty = false;
		chunk.LastUpdate = Logic.GetTimeMs();
		ChunkWrapper.Internal_GetOrInit(chunk):UpdatePositions();
	end;
end;

function ChunkWrapper.GetEntitiesInAreaInCMSorted(chunk, x, y, range)
	return ChunkWrapper.Internal_GetOrInit(chunk):GetEntitiesInAreaInCMSorted(x, y, range);
end;

function ChunkWrapper.GetEntitiesWithHealthAndNotCamouflagedAndNotConstructionSiteInAreaInCMSorted(chunk, x, y, range)
	return ChunkWrapper.Internal_GetOrInit(chunk):GetEntitiesInAreaInCMSorted(x, y, range, true, true, true);
end;


function ChunkWrapper.AddEntityApplyFilter(chunk, id)
	if ChunkFilter.CheckEntity(chunk.Filter, id) then
		ChunkWrapper.AddEntity(chunk, id);
	end;
end;

function ChunkWrapper.InitAllExistingEntities(chunk)
	for id in CEntityIterator.Iterator() do
		if ChunkFilter.CheckEntity(chunk.Filter, id) then
			ChunkWrapper.AddEntity(chunk, id);
		end;
	end;
end;

function ChunkWrapper_OnEntityDied()
	local id = Event.GetEntityID();
	for i = table.getn(ChunkWrapper.chunks), 1, -1 do
		ChunkWrapper.RemoveEntity(ChunkWrapper.chunks[i], id);
	end;
end;

function ChunkWrapper_OnEntityCreated()
	local id = Event.GetEntityID();

	for i = table.getn(ChunkWrapper.chunks), 1, -1 do
		local chunk = ChunkWrapper.chunks[i];
		if ChunkFilter.CheckEntity(chunk.Filter, id) then
			ChunkWrapper.AddEntity(chunk, id);
		end;
	end;

end;

if not CHUNKWRAPPER_TRIGGER then
	CHUNKWRAPPER_TRIGGER = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "ChunkWrapper_OnEntityDied", 1);
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "ChunkWrapper_OnEntityCreated", 1);
end