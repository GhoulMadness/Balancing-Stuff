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
	
	gvArchers_Tower.SlotData = {}
	
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
	
		if Logic.IsEntityInCategory(_entity, EntityCategories.Bow) == 1 and Logic.IsEntityInCategory(_entity, EntityCategories.EvilLeader) ~= 1 then
		
			return gvArchers_Tower.Icon_ByEntityCategory[EntityCategories.Bow]
			
		elseif Logic.IsEntityInCategory(_entity, EntityCategories.Rifle) == 1 then
		
			return gvArchers_Tower.Icon_ByEntityCategory[EntityCategories.Rifle]
			
		elseif Logic.IsEntityInCategory(_entity, EntityCategories.Cannon) == 1 then
		
			return gvArchers_Tower.Icon_ByEntityCategory[EntityCategories.Cannon]
			
		elseif Logic.IsEntityInCategory(_entity, EntityCategories.EvilLeader) == 1 then
		
			return gvArchers_Tower.Icon_ByEntityCategory[EntityCategories.EvilLeader]
				
		else
		
			return false
			
		end
		
	end