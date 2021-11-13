function MapEditor_SetupAI(_playerId, _strength, _range, _techlevel, _position, _aggressiveLevel, _peaceTime)

	-- Valid
	if 	_strength == 0 or _strength > 3 or
		_techlevel < 0 or _techlevel > 3 or 
		_playerId < 1 or _playerId > 16 or
		_aggressiveLevel < 0 or _aggressiveLevel > 3 or
		type(_position) ~= "string" then
		return
	end

	-- get position
	local position = GetPosition(_position)

	-- check for buildings
	if Logic.GetPlayerEntitiesInArea(_playerId, 0, position.X, position.Y, 0, 1, 8) == 0 then
		return
	end

	-- setup AI
	
		--	describe the player structure
		--Logic.SetPlayerName(2, String.MainKey.."_Player2Name")????
	
		--	set up default information
		local description = {
		
			serfLimit				=	(_strength-1)*3,
			--------------------------------------------------
			extracting				=	false,
			--------------------------------------------------
			resources = {
				gold				=	_strength*15000,
				clay				=	_strength*12500,
				iron				=	_strength*12500,
				sulfur				=	_strength*12500,
				stone				=	_strength*12500,
				wood				=	_strength*12500
			},
			--------------------------------------------------
			refresh = {
				gold				=	_strength*2000,
				clay				=	_strength*500,
				iron				=	_strength*1500,
				sulfur				=	_strength*700,
				stone				=	_strength*500,
				wood				=	_strength*1000,
				updateTime			=	math.floor(30/_strength)
			},
			--------------------------------------------------
			constructing			=	true,
			--------------------------------------------------
			rebuild = {
				delay				=	20*(4-_strength),
				randomTime			=	15*(4-_strength)
			},
		}
		
		SetupPlayerAi(_playerId,description)
		
		local CannonEntityType1
		local CannonEntityType2
	-- Tech level
		if _techlevel <= 2 then		
			CannonEntityType1 = Entities.PV_Cannon1
			CannonEntityType2 = Entities.PV_Cannon2
		elseif _techlevel == 3 then
			CannonEntityType1 = Entities.PV_Cannon3
			CannonEntityType2 = Entities.PV_Cannon4
		end
		-- Upgrade entities..Rifle?
		for i=1,_techlevel do
			Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderBow, _playerId)
			Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderSword, _playerId)
			Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderPoleArm, _playerId)
		end
		for i=2, ((_techlevel+1)/2) do
			Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderCavalry, _playerId)
			Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderHeavyCavalry, _playerId)
			Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderRifle, _playerId)
		end

	-- army
	if MapEditor_Armies == nil then
		MapEditor_Armies = {}
	end
		
	MapEditor_Armies[_playerId] = {}
		
	for i=1, (_strength+3) do
		
		MapEditor_Armies[_playerId][i] 						=	{}
		MapEditor_Armies[_playerId][i].player 				=	_playerId
		MapEditor_Armies[_playerId][i].id					=	i
		MapEditor_Armies[_playerId][i].strength				=	_strength+3
		MapEditor_Armies[_playerId][i].position				=	GetPosition(_position)
		local offset = (math.mod((i-1),3)-1)
		MapEditor_Armies[_playerId][i].position.X			=	MapEditor_Armies[_playerId][i].position.X + offset*1000
		MapEditor_Armies[_playerId][i].position.Y			=	MapEditor_Armies[_playerId][i].position.Y + (math.floor((i-1)/3)*1000)
		MapEditor_Armies[_playerId][i].rodeLength			=	(_range*2)/3
		MapEditor_Armies[_playerId][i].retreatStrength		=	3
		MapEditor_Armies[_playerId][i].baseDefenseRange		=	(_range*2)/3
		MapEditor_Armies[_playerId][i].outerDefenseRange	=	_range
		MapEditor_Armies[_playerId][i].AttackAllowed		=	false
		
		MapEditor_Armies[_playerId][i].AllowedTypes			=	{ 	UpgradeCategories.LeaderBow,
																	UpgradeCategories.LeaderSword,
																	UpgradeCategories.LeaderPoleArm,
																	UpgradeCategories.LeaderCavalry,
																	UpgradeCategories.LeaderHeavyCavalry,
																	UpgradeCategories.LeaderRifle,
																	CannonEntityType1,
																	CannonEntityType2
																	}
													
		-- Spawn generator
		SetupAITroopGenerator("MapEditor_Armies_".._playerId.."_"..i, MapEditor_Armies[_playerId][i])
				
		if math.ceil((_aggressiveLevel*_strength)/2) >= i then
			
			Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND,
									nil,
									"StartMapEditor_ArmyAttack",
									1,
									nil,
									{_playerId, i, _peaceTime})
			
		end
					
	end
	
	if MapEditor_Armies.controlerId == nil then
		MapEditor_Armies.controlerId = StartSimpleJob("ControlMapEditor_Armies")
	end
	
	SetHostile(1,_playerId)
	
end
SetupAITroopGenerator = function(_Name, _army)

	local Index = AddData(_army)

	-- Setup trigger
	assert(_army.generatorID==nil, "There is already a generator registered")
	_army.generatorID = Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND,
												"AITroopGenerator_Condition",
												"AITroopGenerator_Action",
												1,
												{_Name, Index},
												{Index})

end
AITroopGenerator_Condition = function(_Name, _Index)

	-- Not enough troops
	if 	Counter.Tick2(_Name.."Generator",7) == false
		or
		(
			(
				DataTable[_Index].ignoreAttack == nil
				or	not DataTable[_Index].ignoreAttack
			)
			and	DataTable[_Index].Attack
		) 
		or
		AI.Player_GetNumberOfLeaders(DataTable[_Index].player) >= 12*DataTable[_Index].strength then
		return false
	end

	-- Already enough
	if AI.Army_GetNumberOfTroops(DataTable[_Index].player, DataTable[_Index].id) < DataTable[_Index].strength then

		-- Connect unemployed leader
		AI.Entity_ConnectUnemployedLeaderToArmy(DataTable[_Index].player, DataTable[_Index].id, 6)

	end

	return AI.Army_GetNumberOfTroops(DataTable[_Index].player, DataTable[_Index].id) < DataTable[_Index].strength

end
AITroopGenerator_Action = function(_Index)

	-- Get table size
	local UpgradeCategoryCount = table.getn(DataTable[_Index].AllowedTypes)

	-- Get random category
	local UpgradeCategoryIndex = Logic.GetRandom(UpgradeCategoryCount)+1
	if AI.Player_GetNumberOfLeaders(DataTable[_Index].player) < 12*DataTable[_Index].strength then
		AI.Army_BuyLeader(DataTable[_Index].player, DataTable[_Index].id, DataTable[_Index].AllowedTypes[UpgradeCategoryIndex])
	end
	return false

end