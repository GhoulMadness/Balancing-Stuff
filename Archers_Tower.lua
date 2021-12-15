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
	gvArchers_Tower.Troop_SearchRadius = 300
	
	gvArchers_Tower.AmountOfTowers = {}
	
	gvArchers_Tower.CurrentlyUsedSlots = {}
	
	gvArchers_Tower.SlotData = {}
				
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
	
												[EntityCategories.Rifle]  = "Data\\Graphics\\Textures\\GUI\\b_select_rifleman"
												
											}
	
	gvArchers_Tower.EmptySlot_Icon = "Data\\Graphics\\Textures\\GUI\\b_select_empty"
											
	function gvArchers_Tower.GetIcon_ByEntityCategory(_entity)
	
		if Logic.IsEntityInCategory(_entity, EntityCategories.Bow) == 1 then
		
			return gvArchers_Tower.Icon_ByEntityCategory[EntityCategories.Bow]
			
		elseif Logic.IsEntityInCategory(_entity, EntityCategories.Rifle) == 1 then
		
			return gvArchers_Tower.Icon_ByEntityCategory[EntityCategories.Rifle]
			
		else
		
			return false
			
		end
		
	end