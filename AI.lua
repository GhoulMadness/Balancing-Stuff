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
	
	if MapEditor_Armies.controlerId == nil then
		MapEditor_Armies.controlerId = {}
		for i = 2,16 do
			MapEditor_Armies.controlerId[i] = {}
		end
	end
	for i=1, (_strength+6) do
		
		MapEditor_Armies[_playerId][i] 						=	{}
		MapEditor_Armies[_playerId][i].player 				=	_playerId
		MapEditor_Armies[_playerId][i].id					=	i - 1
		MapEditor_Armies[_playerId][i].strength				=	_strength+5
		MapEditor_Armies[_playerId][i].position				=	GetPosition(_position)
		local offset = (math.mod((i-1),3)-1)
		MapEditor_Armies[_playerId][i].position.X			=	MapEditor_Armies[_playerId][i].position.X + offset*1000
		MapEditor_Armies[_playerId][i].position.Y			=	MapEditor_Armies[_playerId][i].position.Y + (math.floor((i-1)/3)*1000)
		MapEditor_Armies[_playerId][i].rodeLength			=	(_range*2)/3
		MapEditor_Armies[_playerId][i].retreatStrength		=	3-_strength
		MapEditor_Armies[_playerId][i].baseDefenseRange		=	(_range)/3
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
		
		AI.Army_BeAlwaysAggressive(_playerId, MapEditor_Armies[_playerId][i].id)
		AI.Army_SetScatterTolerance(_playerId, MapEditor_Armies[_playerId][i].id,4)		
		--AI.Army_SetSize(_playerId, MapEditor_Armies[_playerId][i].id, 1)
		-- Spawn generator
		SetupAITroopGenerator("MapEditor_Armies_".._playerId.."_"..i, MapEditor_Armies[_playerId][i])
				
		if math.ceil((_aggressiveLevel^2*_strength)/3) >= i then
			
			Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND,
									nil,
									"StartMapEditor_ArmyAttack",
									1,
									nil,
									{_playerId, i-1, _peaceTime})
			
		end
		Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_TURN,
												"",
												"StartMapEditor_Controller",
												1,{},
												{_playerId, i})		
	end	
	SetHostile(1,_playerId)
	
end
function StartMapEditor_Controller(_playerId,_armycount)
	if Counter.Tick2("StartMapEditor_Controller_Ticker",_armycount) then
		
		if MapEditor_Armies.controlerId[_playerId][_armycount] == nil then
			MapEditor_Armies.controlerId[_playerId][_armycount] = Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_TURN,
												"",
												"ControlMapEditor_Armies_".._playerId.."_".._armycount,
												1,{},
												{_playerId, _armycount})
		end
		return true
	end
end
function StartMapEditor_ArmyAttack(_playerId,_armyId,_delay)

	if Counter.Tick2("StartMapEditor_ArmyAttack".._playerId.."_".._armyId, _delay) then
		
		MapEditor_Armies[_playerId][_armyId+1].AttackAllowed = true
		
		return true
		
	end

end
for i = 2,16 do
	for j = 1,9 do
		_G["ControlMapEditor_Armies_"..i.."_"..j] = function(_playerId,_armycount)

			if Counter.Tick2("ControlMapEditor_Armies_".._playerId.."_".._armycount,100) then
						
				if MapEditor_Armies[_playerId] ~= nil then
							
					if MapEditor_Armies[_playerId][_armycount] ~= nil then
								
						TickOffensiveAIController(MapEditor_Armies[_playerId][_armycount])								
						
					end
					
				end	
				
			end
			
		end
		
	end
	
end
TickOffensiveAIController = function(_army)

	---
	--- collect important information
	---------------------------------		
	local army				= _army.id
	local player			= _army.player
	local numberOfTroops	= AI.Army_GetNumberOfTroops(player,army)	
	local position			= _army.position

-------------------------------------------------------------
-- Init
-------------------------------------------------------------
	if _army.offensiveAIControllerState == nil then
		
	    Retreat(_army,_army.outerDefenseRange)				
		_army.rodeLength = _army.outerDefenseRange

		_army.offensiveAIControllerState = 0
	end


-------------------------------------------------------------
-- Defensive
-------------------------------------------------------------
	if _army.offensiveAIControllerState == 0 then

		-- enough soldiers
		if numberOfTroops > _army.retreatStrength and not AI.Army_IsRefreshing(player, army) then
			
			_army.offensiveAIControllerState = 1

			_army.rodeLength = _army.outerDefenseRange
			AI.Army_SetAnchorRodeLength(player, army, _army.rodeLength)
		
		else
		
			AIController_Defensive( _army, _army.baseDefenseRange )
	
		end
-------------------------------------------------------------
-- Offensive Defense
-------------------------------------------------------------	
	elseif _army.offensiveAIControllerState == 1 then
		
		if numberOfTroops <= _army.retreatStrength then
			
			_army.offensiveAIControllerState = 0
			
			_army.rodeLength = _army.baseDefenseRange
			AI.Army_SetAnchorRodeLength(player, army, _army.rodeLength)
		
		elseif numberOfTroops >= _army.strength and _army.AttackAllowed and not AI.Army_IsRefreshing(player, army) then

			_army.offensiveAIControllerState = 2
		
			if _army.AttackPos ~= nil then
		
				if table.getn(_army.AttackPos) ~= 0 then
					
					local Index = Logic.GetRandom(table.getn(_army.AttackPos))+1
						
					AI.Army_SetAnchor(player, army, _army.AttackPos[Index].X, _army.AttackPos[Index].Y, 0)
					
				else
					
					AI.Army_SetAnchor(player, army, _army.AttackPos.X, _army.AttackPos.Y, 0)
					
				end
			end
			
			_army.Attack = true
				
		else
			
			if _army.pulse ~= nil and not AI.Army_IsRefreshing(player, army) then
				
				if _army.pulseCounter == nil or _army.pulseCounter == 0 then
					_army.pulseCounter = Logic.GetTime() + 61 + Logic.GetRandom(60)
				end
				
				if Logic.GetTime() > _army.pulseCounter then
					
					_army.pulseCounter = 0
					_army.offensiveAIControllerState = 3
					
				end
				
			end

			AIController_Defensive( _army, _army.outerDefenseRange )
					
		end
-------------------------------------------------------------
-- Attack
-------------------------------------------------------------
	elseif _army.offensiveAIControllerState == 2 then

		if numberOfTroops <= _army.retreatStrength then
			
			_army.offensiveAIControllerState = 0
			
			_army.Attack = false
			 
			 Retreat(_army,_army.baseDefenseRange)				
			_army.rodeLength = _army.baseDefenseRange
			
		elseif not _army.AttackAllowed then
			
			_army.offensiveAIControllerState = 1
			 
			 _army.Attack = false
			 
			 Retreat(_army,_army.outerDefenseRange)				
			_army.rodeLength = _army.outerDefenseRange
			
		else
			
			Advance(_army)
			
		end

-------------------------------------------------------------
-- Start Pulse
-------------------------------------------------------------
	elseif _army.offensiveAIControllerState == 3 then
		
		-- Start frontal attack (nope, this is rather useless!)
		Advance(_army)
		_army.offensiveAIControllerState = 4
		_army.pulseCounter = Logic.GetTime() + 11 + Logic.GetRandom(10)
-------------------------------------------------------------
-- Pulse active
-------------------------------------------------------------
	elseif _army.offensiveAIControllerState == 4 then

		if Logic.GetTime() > _army.pulseCounter then
			
			_army.offensiveAIControllerState = 1
			
			 Retreat(_army,_army.outerDefenseRange)				

			_army.rodeLength = _army.outerDefenseRange
			
			_army.pulseCounter = 0
			
		end
		
	end
	
end


AIController_Defensive = function(_army, _range)

		if AI.Army_GetAnchorRodeLength(_army.player, _army.id) > _range then								

		    Retreat(_army,_range)				
			_army.rodeLength = _range
	
		else
			
			Defend(_army)
			
		end
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

	-- Already enough troops
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
		AI.Player_GetNumberOfLeaders(DataTable[_Index].player) >= table.getn(MapEditor_Armies[DataTable[_Index].player]) *DataTable[_Index].strength then
		return false
	end

	-- not enough troops
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
	if AI.Player_GetNumberOfLeaders(DataTable[_Index].player) < table.getn(MapEditor_Armies[DataTable[_Index].player]) * DataTable[_Index].strength * 3/4 then
		AI.Army_BuyLeader(DataTable[_Index].player, DataTable[_Index].id, DataTable[_Index].AllowedTypes[UpgradeCategoryIndex])
	end
	return false

end