------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Archers Tower Table -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
gvArchers_Tower = gvArchers_Tower or {}

-- max. Anzahl erlaubter Türme
gvArchers_Tower.TowerLimit = 10
-- max. Anzahl Truppen pro Turm
gvArchers_Tower.MaxSlots = 2
-- Zeitdauer in Sek. die benötigt wird, um in den Turm zu gelangen
gvArchers_Tower.ClimbUpTime = 10
-- Schadens-Multiplikator für Truppen auf Türmen
gvArchers_Tower.DamageFactor = 1.3
-- Rüstungs-Multiplikator für Truppen auf Türmen
gvArchers_Tower.ArmorFactor = 1.3
-- Reichweiten-Multiplikator für Truppen auf Türmen
gvArchers_Tower.MaxRangeFactor = 1.2
-- In dieser Reichweite werden Truppen zum stationieren gesucht
gvArchers_Tower.Troop_SearchRadius = 500
-- Kategorien von feindlichen Fernkampf-Truppen, die nicht nahe des Turms stehen dürfen, wenn er befüllt werden soll
gvArchers_Tower.RangedEnemySearchCategories = {EntityCategories.LongRange,EntityCategories.EvilLeader,EntityCategories.Cannon,EntityCategories.CavalryLight,EntityCategories.Hero5,EntityCategories.Hero10}
-- Kritische Reichweite, in der sich keine Fernkampf-Feinde in der Nähe des Turmes befinden dürfen
gvArchers_Tower.RangedEnemySearchRange = 3500
-- Kategorien von feindlichen Nahkampf-Truppen, die nicht nahe des Turms stehen dürfen, wenn er befüllt werden soll
gvArchers_Tower.MeleeEnemySearchCategories = {EntityCategories.Melee}
-- Kritische Reichweite, in der sich keine Nahkampf-Feinde in der Nähe des Turmes befinden dürfen
gvArchers_Tower.MeleeEnemySearchRange = 600

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