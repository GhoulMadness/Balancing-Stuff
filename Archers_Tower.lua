------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Archers Tower Table -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvArchers_Tower = gvArchers_Tower or {}

-- max. Anzahl erlaubter Türme
gvArchers_Tower.TowerLimit = 10
-- max. Anzahl Truppen pro Turm
gvArchers_Tower.MaxSlots = 2
-- Zeitdauer in Sek. die benötigt wird, um in den Turm zu gelangen
gvArchers_Tower.ClimbUpTime = 6
-- Schadens-Multiplikator für Truppen auf Türmen
gvArchers_Tower.DamageFactor = 1.4
-- Rüstungs-Multiplikator für Truppen auf Türmen
gvArchers_Tower.ArmorFactor = 1.4
-- Reichweiten-Bonus für Truppen auf Türmen
gvArchers_Tower.MaxRangeBonus = 600
-- In dieser Reichweite werden Truppen zum stationieren gesucht
gvArchers_Tower.Troop_SearchRadius = 500
-- Kategorien von feindlichen Fernkampf-Truppen, die nicht nahe des Turms stehen dürfen, wenn er befüllt werden soll
gvArchers_Tower.RangedEnemySearchCategories = {EntityCategories.LongRange,EntityCategories.EvilLeader,EntityCategories.Cannon,EntityCategories.CavalryLight,EntityCategories.Hero5,EntityCategories.Hero10}
-- Kritische Reichweite, in der sich keine Fernkampf-Feinde in der Nähe des Turmes befinden dürfen
gvArchers_Tower.RangedEnemySearchRange = 3500
-- Kategorien von feindlichen Nahkampf-Truppen, die nicht nahe des Turms stehen dürfen, wenn er befüllt werden soll
gvArchers_Tower.MeleeEnemySearchCategories = {EntityCategories.Melee}
-- Kritische Reichweite, in der sich keine Nahkampf-Feinde in der Nähe des Turmes befinden dürfen
gvArchers_Tower.MeleeEnemySearchRange = 1000

gvArchers_Tower.AmountOfTowers = {}

gvArchers_Tower.CurrentlyUsedSlots = {}

gvArchers_Tower.CurrentlyClimbing = {}

gvArchers_Tower.SlotData = {}

gvArchers_Tower.TriggerIDs = {AddTroop = {}, RemoveTroop = {}}

gvArchers_Tower.AllowedTypes = {Entities.PU_LeaderBow1,
								Entities.PU_LeaderBow2,
								Entities.PU_LeaderBow3,
								Entities.PU_LeaderBow4,
								Entities.PU_LeaderRifle1,
								Entities.PU_LeaderRifle2,
								Entities.PV_Cannon1,
								Entities.PV_Cannon3,
								Entities.PV_Cannon5,
								Entities.CU_Evil_LeaderSkirmisher1,
								Entities.CU_BanditLeaderBow1}
								-- value that defines the damage treshold needed to trigger the damage recalculation
gvArchers_Tower.OccupiedTroop = {DamageTreshold = 50,
								-- value that defines the used damage class/armor class value for calculation
								AverageDamageFactor = 0.35,
								-- value that defines the range in which the nearest archers tower is searched
								TowerSearchRange = 500}
if CNetwork then

	for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		gvArchers_Tower.AmountOfTowers[i] = Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Archers_Tower)
	end

else

	for i = 1,8 do
		gvArchers_Tower.AmountOfTowers[i] = Logic.GetNumberOfEntitiesOfTypeOfPlayer(i, Entities.PB_Archers_Tower)
	end

end

gvArchers_Tower.Offset_ByOrientation = {[0] = {	X = 0,
												Y = 700},

										[90] = {X = -600,
												Y = 0},

										[180]= {X = 0,
												Y = -600},

										[270]= {X = 800,
												Y = 0},

										[360]= {X = 0,
												Y = 700}
										}

function gvArchers_Tower.GetOffset_ByOrientation(_entity)

	local orientation = Logic.GetEntityOrientation(_entity)
	while orientation < 0 do
		orientation = orientation + 360
	end
	return gvArchers_Tower.Offset_ByOrientation[orientation]

end

function gvArchers_Tower.GetFirstFreeSlot(_entity)

	if gvArchers_Tower.SlotData[_entity][1] == nil then
		return 1

	elseif gvArchers_Tower.SlotData[_entity][2] == nil then
		return 2

	else
		return false

	end

end

gvArchers_Tower.Icon_ByEntityCategory = {	[EntityCategories.Bow]	 = "Data\\Graphics\\Textures\\GUI\\b_select_bowman",
											[EntityCategories.Rifle]  = "Data\\Graphics\\Textures\\GUI\\b_select_rifleman",
											[EntityCategories.Cannon] = "Data\\Graphics\\Textures\\GUI\\b_select_cannon",
											[EntityCategories.EvilLeader] = "Data\\Graphics\\Textures\\GUI\\b_select_skirmisher"
										}

gvArchers_Tower.EmptySlot_Icon = "Data\\Graphics\\Textures\\GUI\\b_select_empty"

function gvArchers_Tower.GetIcon_ByEntityCategory(_entity)

	for k,v in pairs(EntityCategories) do
		if Logic.IsEntityInCategory(_entity, v) == 1 and gvArchers_Tower.Icon_ByEntityCategory[v] then
			return gvArchers_Tower.Icon_ByEntityCategory[v]
		end
	end
	return gvArchers_Tower.EmptySlot_Icon
end
gvArchers_Tower.PrepareData = {}
function gvArchers_Tower.PrepareData.AddTroop(_playerID, _entityID, _leaderID)

	local _slot = gvArchers_Tower.GetFirstFreeSlot(_entityID)
	gvArchers_Tower.SlotData[_entityID][_slot] = _leaderID
	local soldiers,_soldierstable

	if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entityID][_slot], EntityCategories.Cannon) ~= 1 then
		_soldierstable = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_entityID][_slot])}
		soldiers = _soldierstable[1]
	end

	gvArchers_Tower.TriggerIDs.AddTroop[_entityID.."_".._slot] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Archers_Tower_AddTroop", 1, nil, {_slot, soldiers or 0, _playerID, _entityID})
	gvArchers_Tower.CurrentlyUsedSlots[_entityID] = gvArchers_Tower.CurrentlyUsedSlots[_entityID] + 1
	Logic.SuspendEntity(gvArchers_Tower.SlotData[_entityID][_slot])
	SetEntityVisibility(gvArchers_Tower.SlotData[_entityID][_slot], 0)

	if _soldierstable then
		table.remove(_soldierstable,1)

		for i = 1,table.getn(_soldierstable) do
			Logic.SuspendEntity(_soldierstable[i])
			SetEntityVisibility(_soldierstable[i], 0)
		end
	end
end

function gvArchers_Tower.PrepareData.RemoveTroop(_playerID, _entityID, _slot)

	local soldiers, _soldierstable

	if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entityID][_slot], EntityCategories.Cannon) ~= 1 then
		_soldierstable = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_entityID][_slot])}
		soldiers = _soldierstable[1]
	end

	gvArchers_Tower.TriggerIDs.RemoveTroop[_entityID.."_".._slot] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "Archers_Tower_RemoveTroop", 1, nil, {_slot, _entityID, soldiers or 0, _playerID})
	Logic.SuspendEntity(gvArchers_Tower.SlotData[_entityID][_slot])
	SetEntityVisibility(gvArchers_Tower.SlotData[_entityID][_slot], 0)

	if _soldierstable then
		table.remove(_soldierstable,1)

		for i = 1,table.getn(_soldierstable) do
			Logic.SuspendEntity(_soldierstable[i])
			SetEntityVisibility(_soldierstable[i], 0)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Archers Tower Trigger -----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Archers_Tower_RemoveTroop = function(_slot,_entity,_soldiers,_player)

	if Counter.Tick2("Archers_Tower_RemoveTroop_Counter_".._entity.."_".._slot, gvArchers_Tower.ClimbUpTime) then

		Logic.ResumeEntity(gvArchers_Tower.SlotData[_entity][_slot])
		gvArchers_Tower.CurrentlyClimbing[_entity] = nil

		if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entity][_slot], EntityCategories.Cannon) ~= 1 then
			local soldiers = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_entity][_slot])}
			table.remove(soldiers,1)

			for i = 1,table.getn(soldiers) do
				Logic.ResumeEntity(soldiers[i])
			end

		end

		if IsExisting(_entity) then

			local pos = GetPosition(_entity)
			local offset = gvArchers_Tower.GetOffset_ByOrientation(_entity)
			local newLeaderID
			local experience = CEntity.GetLeaderExperience(gvArchers_Tower.SlotData[_entity][_slot])

			if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_entity][_slot], EntityCategories.Cannon) == 1 then
				newLeaderID = CreateEntity(_player,Logic.GetEntityType(gvArchers_Tower.SlotData[_entity][_slot]),{X = pos.X - offset.X, Y = pos.Y - offset.Y})
			else
				newLeaderID = CreateGroup(_player, Logic.GetEntityType(gvArchers_Tower.SlotData[_entity][_slot]), _soldiers, pos.X - offset.X, pos.Y - offset.Y, 0 , experience)
			end

			Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_entity][_slot])
			gvArchers_Tower.SlotData[_entity][_slot] = nil
			gvArchers_Tower.CurrentlyUsedSlots[_entity] = gvArchers_Tower.CurrentlyUsedSlots[_entity] - 1

			for i = 1,4 do
				XGUIEng.SetMaterialTexture("Archers_Tower_Slot".._slot, i-1, gvArchers_Tower.EmptySlot_Icon)
			end

			gvArchers_Tower.TriggerIDs.RemoveTroop[_entity.."_".._slot] = nil
			return true

		else

			Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_entity][_slot])
			gvArchers_Tower.SlotData[_entity][_slot] = nil
			gvArchers_Tower.CurrentlyUsedSlots[_entity] = gvArchers_Tower.CurrentlyUsedSlots[_entity] - 1
			gvArchers_Tower.TriggerIDs.RemoveTroop[_entity.."_".._slot] = nil
			return true
		end

	end

end

Archers_Tower_AddTroop = function(_slot,_soldiers,_player,_towerID)

	if Counter.Tick2("Archers_Tower_AddTroop_Counter_".._towerID.."_".._slot, gvArchers_Tower.ClimbUpTime) then

		Logic.ResumeEntity(gvArchers_Tower.SlotData[_towerID][_slot])

		if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_towerID][_slot], EntityCategories.Cannon) ~= 1 then

			local soldiers = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[_towerID][_slot])}
			table.remove(soldiers,1)

			for i = 1,table.getn(soldiers) do
				Logic.ResumeEntity(soldiers[i])
			end

		end

		if IsExisting(_towerID) then

			local pos = GetPosition(_towerID)
			local entityType = Logic.GetEntityType(gvArchers_Tower.SlotData[_towerID][_slot])
			local experience = CEntity.GetLeaderExperience(gvArchers_Tower.SlotData[_towerID][_slot])
			Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_towerID][_slot])
			local newLeaderID = CreateGroup(_player, entityType, _soldiers, pos.X , pos.Y , 0 , experience)
			gvArchers_Tower.SlotData[_towerID][_slot] = newLeaderID

			if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[_towerID][_slot], EntityCategories.Cannon) ~= 1 then
				local TroopIDs = {Logic.GetSoldiersAttachedToLeader(newLeaderID)}
				table.remove(TroopIDs,1)
				table.insert(TroopIDs,newLeaderID)

				for i = 1,table.getn(TroopIDs) do
					CEntity.SetDamage(TroopIDs[i], Logic.GetEntityDamage(TroopIDs[i]) * gvArchers_Tower.DamageFactor)
					CEntity.SetArmor(TroopIDs[i], Logic.GetEntityArmor(TroopIDs[i]) * gvArchers_Tower.ArmorFactor)
					CEntity.SetAttackRange(TroopIDs[i], GetEntityTypeMaxAttackRange((TroopIDs[i]), _player) + gvArchers_Tower.MaxRangeBonus)
				end

			else
				CEntity.SetDamage(newLeaderID, Logic.GetEntityDamage(newLeaderID) * gvArchers_Tower.DamageFactor)
				CEntity.SetArmor(newLeaderID, Logic.GetEntityArmor(newLeaderID) * gvArchers_Tower.ArmorFactor)
				CEntity.SetAttackRange(newLeaderID, GetEntityTypeMaxAttackRange(newLeaderID, _player) + gvArchers_Tower.MaxRangeBonus)

			end

			gvArchers_Tower.CurrentlyClimbing[_towerID] = nil
			gvArchers_Tower.TriggerIDs.AddTroop[_towerID.."_".._slot] = nil
			return true

		else

			gvArchers_Tower.CurrentlyClimbing[_towerID] = nil
			Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[_towerID][_slot])
			gvArchers_Tower.SlotData[_towerID][_slot] = nil
			gvArchers_Tower.TriggerIDs.AddTroop[_towerID.."_".._slot] = nil
			gvArchers_Tower.CurrentlyUsedSlots[_towerID] = gvArchers_Tower.CurrentlyUsedSlots[_towerID] - 1
			return true

		end

	end

end

function OnArchers_TowerDestroyed()

    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

    if entityType == Entities.PB_Archers_Tower then
		for i = 1,gvArchers_Tower.MaxSlots do

			if gvArchers_Tower.SlotData[entityID][i] ~= nil then
				Logic.ResumeEntity(gvArchers_Tower.SlotData[entityID][i])

				if Logic.IsEntityInCategory(gvArchers_Tower.SlotData[entityID][i], EntityCategories.Cannon) ~= 1 then
					local soldiers = {Logic.GetSoldiersAttachedToLeader(gvArchers_Tower.SlotData[entityID][i])}
					table.remove(soldiers,1)

					for k = 1,table.getn(soldiers) do
						Logic.ResumeEntity(soldiers[k])
					end

				end

				Logic.DestroyGroupByLeader(gvArchers_Tower.SlotData[entityID][i])

				if gvArchers_Tower.TriggerIDs.RemoveTroop[entityID.."_"..i] then
					Trigger.UnrequestTrigger(gvArchers_Tower.TriggerIDs.RemoveTroop[entityID.."_"..i])
				end

				if gvArchers_Tower.TriggerIDs.AddTroop[entityID.."_"..i] then
					Trigger.UnrequestTrigger(gvArchers_Tower.TriggerIDs.AddTroop[entityID.."_"..i])
				end

				if gvArchers_Tower.CurrentlyClimbing[entityID] then
					gvArchers_Tower.CurrentlyClimbing[entityID] = nil
				end

				gvArchers_Tower.SlotData[entityID][i] = nil
				gvArchers_Tower.CurrentlyUsedSlots[entityID] = nil

			end

		end

		gvArchers_Tower.SlotData[entityID] = nil
		gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] = gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] - 1

	end

end

function OnArchers_TowerCreated()

    local entityID = Event.GetEntityID()
    local entityType = Logic.GetEntityType(entityID)

    if entityType == Entities.PB_Archers_Tower then
		gvArchers_Tower.CurrentlyUsedSlots[entityID] = 0
		gvArchers_Tower.SlotData[entityID] = {}
		gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] = gvArchers_Tower.AmountOfTowers[Logic.EntityGetPlayer(entityID)] + 1
	end

end

function OnArchers_Tower_OccupiedTroopDied()

	local entityID = Event.GetEntityID()
	local playerID = Logic.EntityGetPlayer(entityID)

	if playerID ~= 0 then
		if CNetwork and XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(playerID) ~= 0 then
			if Logic.IsLeader(entityID) == 1 then
				if gvArchers_Tower.AmountOfTowers[playerID] > 0 then

					for k,v in pairs(gvArchers_Tower.SlotData) do
						local slot = table_findvalue(gvArchers_Tower.SlotData[k],entityID)

						if  slot ~= 0 then
							gvArchers_Tower.SlotData[k][slot] = nil

							if gvArchers_Tower.CurrentlyUsedSlots[k] ~= nil then
								gvArchers_Tower.CurrentlyUsedSlots[k] = gvArchers_Tower.CurrentlyUsedSlots[k] - 1
							end

							if gvArchers_Tower.TriggerIDs.RemoveTroop[k.."_"..slot] then
								Trigger.UnrequestTrigger(gvArchers_Tower.TriggerIDs.RemoveTroop[k.."_"..slot])
							end

						end
					end
				end
			end

		else

			if playerID == 1 then
				if Logic.IsLeader(entityID) == 1 then
					if gvArchers_Tower.AmountOfTowers[playerID] > 0 then

						for k,v in pairs(gvArchers_Tower.SlotData) do
							local slot = table_findvalue(gvArchers_Tower.SlotData[k],entityID)

							if  slot ~= 0 then
								gvArchers_Tower.SlotData[k][slot] = nil

								if gvArchers_Tower.CurrentlyUsedSlots[k] then
									gvArchers_Tower.CurrentlyUsedSlots[k] = gvArchers_Tower.CurrentlyUsedSlots[k] - 1
								end

								if gvArchers_Tower.TriggerIDs.RemoveTroop[k.."_"..slot] then
									Trigger.UnrequestTrigger(gvArchers_Tower.TriggerIDs.RemoveTroop[k.."_"..slot])
								end

							end
						end
					end
				end
			end
		end
	end
end

function OnArchers_Tower_OccupiedTroopAttacked()

	local attacker = Event.GetEntityID1()
	local attype = Logic.GetEntityType(attacker)
	for _type, _range in pairs(gvAntiBuildingCannonsRange) do
		if attype == _type then
			local target = Event.GetEntityID2()
			local playerID = Logic.EntityGetPlayer(target)

			if gvArchers_Tower.AmountOfTowers[playerID] then

				if gvArchers_Tower.AmountOfTowers[playerID] > 0 then
					local posX,posY = Logic.GetEntityPosition(target)
					local towerID = ({Logic.GetEntitiesInArea(Entities.PB_Archers_Tower, posX, posY, gvArchers_Tower.OccupiedTroop.TowerSearchRange, 1)})[2]
					local soldiers = {}

					if towerID then

						for k,v in pairs(gvArchers_Tower.SlotData[towerID]) do
							soldiers[k] = {Logic.GetSoldiersAttachedToLeader(v)}
							table.remove(soldiers[k],1)

							for n,m in pairs(soldiers[k]) do

								if target == soldiers[k][n] then
									local targettype = Logic.GetEntityType(v)
									local dmg = CEntity.TriggerGetDamage()
									local currdmgfactor = GetDamageFactor(GetEntityTypeDamageClass(attype), GetEntityTypeArmorClass(Entities.PB_Archers_Tower))
									local dmgfactor = GetDamageFactor(GetEntityTypeDamageClass(attype), GetEntityTypeArmorClass(targettype))
									local dmgrange = GetEntityTypeDamageRange(attype)
									local distance = GetDistance(GetPosition(attacker), GetPosition(target))
									CEntity.TriggerSetDamage(math.ceil((dmg / currdmgfactor * dmgfactor) * (1-(distance/dmgrange))))
									return
								end
							end
						end
					end
				end
			end
		end
	end
end