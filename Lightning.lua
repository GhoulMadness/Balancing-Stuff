--------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Blitzeinschläge & Unwetter ---------------------------------------
--------------------------------------------------------------------------------------------------------------------
Mapsize = Logic.WorldGetSize()
gvLightning = { Range = 245, BaseDamage = 25, DamageAmplifier = 1, AdditionalStrikes = 0, 
	--Menge an Blitzen pro Sekunde abhängig von der Fläche der Map
	Amount = math.floor((((Mapsize/100)^2)/70000)+0.5),
	RecentlyDamaged = 
	{
		false, 
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	},
	
	RodProtected = 
	{
		false, 
		false, 
		false, 
		false, 
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	}	
, 	DamageProofBuildings = {
		[Entities.CB_OldKingsCastleRuin] = true,
		[Entities.CB_Mercenary] = true,
		[Entities.CB_Abbey01] = true,
		[Entities.CB_Abbey02] = true,
		[Entities.CB_Abbey03] = true,
		[Entities.CB_Abbey04] = true,
		[Entities.CB_BarmeciaCastle] = true,
		[Entities.CB_Bastille1] = true,
		[Entities.CB_Camp01] = true,
		[Entities.CB_Camp02] = true,
		[Entities.CB_Camp03] = true,
		[Entities.CB_Camp04] = true,
		[Entities.CB_Camp05] = true,
		[Entities.CB_Camp06] = true,
		[Entities.CB_Camp07] = true,
		[Entities.CB_Camp08] = true,
		[Entities.CB_Camp09] = true,
		[Entities.CB_Camp10] = true,
		[Entities.CB_Camp11] = true,
		[Entities.CB_Camp12] = true,
		[Entities.CB_Camp13] = true,
		[Entities.CB_Camp14] = true,
		[Entities.CB_Camp15] = true,
		[Entities.CB_Camp16] = true,
		[Entities.CB_Camp17] = true,
		[Entities.CB_Camp18] = true,
		[Entities.CB_Camp19] = true,
		[Entities.CB_Camp20] = true,
		[Entities.CB_Camp21] = true,
		[Entities.CB_Camp22] = true,
		[Entities.CB_Camp23] = true,
		[Entities.CB_Camp24] = true,
		[Entities.CB_Castle1] = true,
		[Entities.CB_CleycourtCastle] = true,
		[Entities.CB_CrawfordCastle] = true,
		[Entities.CB_DarkCastle] = true,
		[Entities.CB_DestroyAbleRuinHouse1] = true,
		[Entities.CB_DestroyAbleRuinMonastery1] = true,
		[Entities.CB_DestroyAbleRuinResidence1] = true,
		[Entities.CB_DestroyAbleRuinSmallTower1] = true,
		[Entities.CB_DestroyAbleRuinSmallTower3] = true,
		[Entities.CB_FolklungCastle] = true,
		[Entities.CB_HermitHut1] = true,
		[Entities.CB_InventorsHut1] = true,
		[Entities.CB_KaloixCastle] = true,
		[Entities.CB_MinerCamp1] = true,
		[Entities.CB_MinerCamp2] = true,
		[Entities.CB_MinerCamp3] = true,
		[Entities.CB_MinerCamp4] = true,
		[Entities.CB_MinerCamp5] = true,
		[Entities.CB_MinerCamp6] = true,
		[Entities.CB_MonasteryBuildingSite1] = true,
		[Entities.CB_OldKingsCastle] = true,
		[Entities.CB_RobberyTower1] = true,
		[Entities.CB_Tower1] = true,
		[Entities.CB_SteamMashine] = true,
		[Entities.CB_TechTrader] = true,
		[Entities.XD_WallCorner] = true,
		[Entities.XD_WallDistorted] = true,
		[Entities.XD_WallStraight] = true,
		[Entities.XD_WallStraightGate] = true,
		[Entities.XD_WallStraightGate_Closed] = true,
		[Entities.XD_DarkWallCorner] = true,
		[Entities.XD_DarkWallDistorted] = true,
		[Entities.XD_DarkWallStraight] = true,
		[Entities.XD_DarkWallStraightGate] = true,
		[Entities.XD_DarkWallStraightGate_Closed] = true,
		[Entities.ZB_ConstructionSite1] = true, 
		[Entities.ZB_ConstructionSite2] = true,
		[Entities.ZB_ConstructionSite3] = true, 
		[Entities.ZB_ConstructionSite4] = true,
		[Entities.ZB_ConstructionSite5] = true,
		[Entities.ZB_ConstructionSiteArchery1] = true,
		[Entities.ZB_ConstructionSiteBarracks1] = true,
		[Entities.ZB_ConstructionSiteStables1] = true,
		[Entities.ZB_ConstructionSiteBlacksmith1] = true,
		[Entities.ZB_ConstructionSiteFarm1] = true,
		[Entities.ZB_ConstructionSiteResidence1] = true,
		[Entities.ZB_ConstructionSiteMarket1] = true,
		[Entities.ZB_ConstructionSiteMint1] = true,
		[Entities.ZB_ConstructionSiteMonastery1] = true,
		[Entities.ZB_ConstructionSiteIronMine1] = true,
		[Entities.ZB_ConstructionSiteStoneMine1] = true,
		[Entities.ZB_ConstructionSiteSulfurMine1] = true,
		[Entities.ZB_ConstructionSiteStonemason1] = true, 
		[Entities.ZB_ConstructionSiteTower1] = true,
		[Entities.ZB_ConstructionSiteUniversity1] = true,
		[Entities.ZB_ConstructionSiteVillageCenter1] = true,
		[Entities.ZB_ConstructionSiteDome1] = true,
		[Entities.ZB_ConstructionSiteCastle1] = true
	}
}
function gvLightning.IsLightningProofBuilding(_entityID)
	return gvLightning.DamageProofBuildings[Logic.GetEntityType(_entityID)] 
end
function Lightning_Job() 
	--Blitzeinschläge nur bei Regen
	if Logic.GetWeatherState() == 2 then
		local range = gvLightning.Range + Logic.GetRandom(gvLightning.Range)
		local damage = gvLightning.BaseDamage + Logic.GetRandom(gvLightning.BaseDamage) 
		local buildingdamage = (((gvLightning.BaseDamage + Logic.GetRandom(gvLightning.BaseDamage))*3) + math.min(GetCurrentWeatherGfxSet()*5,55)*gvLightning.DamageAmplifier)
		local amount = gvLightning.Amount
		local x,y
		--noch mehr Blitze bei Unwetter und nächtlichem Unwetter (Gfx-Set 11 und 28)
		if GetCurrentWeatherGfxSet() == 11 or GetCurrentWeatherGfxSet() == 28 then
			amount = amount + (gvLightning.Amount *2) + gvLightning.AdditionalStrikes
		end
			
		for i = 1,amount do	
			x = Logic.GetRandom(Mapsize)
			y = Logic.GetRandom(Mapsize)
		
			Logic.CreateEffect(GGL_Effects.FXLightning_PerformanceMode,x,y)
			gvLightning.Damage(x,y,range,damage,buildingdamage)
		end		
		
		local pID = GUI.GetPlayerID()
		if gvLightning.RecentlyDamaged[pID] == true then
			Sound.PlayGUISound( Sounds.OnKlick_Select_varg, 92 ) 
			Sound.PlayGUISound( Sounds.OnKlick_PB_Tower3, 94 ) 
			Sound.PlayGUISound( Sounds.OnKlick_PB_PowerPlant1, 82 )
			Sound.PlayGUISound(Sounds.AmbientSounds_rainmedium,120)
			Stream.Start("Sounds\\Misc\\SO_buildingdestroymedium.wav",72)
			gvLightning.RecentlyDamaged[pID] = false
		end
    end	
end
-- besser als HiResJob (10 mal so oft, 10 mal weniger Blitze/Performance verteilt sich auf Ticks nicht auf Sekunden)
function gvLightning.Damage(_posX,_posY,_range,_damage,_buildingdamage)

    for eID in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.InCircleFilter(_posX, _posY, _range)) do
	
		if Logic.IsHero(eID) == 1 or Logic.IsSerf(eID) == 1 or Logic.IsEntityInCategory(eID, EntityCategories.Cannon) == 1 then
			Logic.HurtEntity(eID, _damage)
			if GUI.GetPlayerID() == Logic.EntityGetPlayer(eID) then
				gvLightning.RecentlyDamaged[Logic.EntityGetPlayer(eID)] = true
				GUI.ScriptSignal(_posX, _posY, 0)
			end
		end
			
			if Logic.IsLeader(eID) == 1 then
				local Soldiers = {Logic.GetSoldiersAttachedToLeader(eID)}
					if Soldiers[1] >= 8 then
						for i = 2,4 do
							ChangeHealthOfEntity(Soldiers[i],0)
						end
					elseif Soldiers[1] >= 4 and Soldiers[1] <=7 then
						for i = 2,3 do
							ChangeHealthOfEntity(Soldiers[i],0)
						end
					elseif Soldiers[1] <= 3 then
						ChangeHealthOfEntity(Soldiers[2],0)
					elseif Soldiers[1] == 0 then
						Logic.HurtEntity(eID, _damage)
					end
				if GUI.GetPlayerID() == Logic.EntityGetPlayer(eID) then
					gvLightning.RecentlyDamaged[Logic.EntityGetPlayer(eID)] = true
					GUI.ScriptSignal(_posX, _posY, 0)
				end
			end
			
		if Logic.IsBuilding(eID) == 1 then 
			if gvLightning.IsLightningProofBuilding(eID) ~= true then
				if Logic.IsConstructionComplete(eID) == 1 then
					local PID = Logic.EntityGetPlayer(eID)
					if gvLightning.RodProtected[PID] == false then
						Logic.HurtEntity(eID, _buildingdamage)
						if Logic.GetTechnologyState(PID,Technologies.T_LightningInsurance) == 4 then
							if _buildingdamage ~= nil then
								local InsuranceCash = math.floor(_buildingdamage)
								Logic.AddToPlayersGlobalResource(PID,ResourceType.GoldRaw,InsuranceCash)
								if GUI.GetPlayerID() == PID then
									GUI.AddNote("Durch die abgeschlossene Blitzschlag-Versicherung erhaltet ihr ".. InsuranceCash .." zus\195\164tzliche Taler")
								end
							end
						end
						if GUI.GetPlayerID() == PID then
							gvLightning.RecentlyDamaged[Logic.EntityGetPlayer(eID)] = true
							GUI.ScriptSignal(_posX, _posY, 0)							
						end
					end
				end
			end
		end   	
	end
end