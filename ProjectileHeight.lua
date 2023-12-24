ProjectileHeightCheck = ProjectileHeightCheck or {}

ProjectileHeightCheck.TaskLists = {["TL_BATTLE_BOW"] = true,
									["TL_BATTLE_CROSSBOW"] = true,
									["TL_BATTLE_SKIRMISHER"] = true,
									["TL_BATTLE_RIFLE"] = true,
									["TL_BATTLE_VEHICLE"] = true,
									["TL_BATTLE_GATLING"] = true
									}
ProjectileHeightCheck.EffectsSuffixByBuilding = {[Entities.PB_Archers_Tower] = "AtArchersTower",
												[Entities.PB_Bridge1] = "AtBridge",
												[Entities.PB_Bridge2] = "AtBridge",
												[Entities.PB_Bridge3] = "AtBridge",
												[Entities.PB_Bridge4] = "AtBridge",
												[Entities.PB_DrawBridgeClosed1] = "AtDrawBridge",
												[Entities.PB_DrawBridgeClosed2] = "AtDrawBridge",
												[Entities.XD_OSO_Wall_Straight2] = "AtFortification2",
												[Entities.XD_OSO_Wall_Straight2_90] = "AtFortification2",
												[Entities.XD_OSO_Wall_Straight2_180] = "AtFortification2",
												[Entities.XD_OSO_Wall_Straight2_270] = "AtFortification2",
												[Entities.XD_OSO_Wall_Tower2] = "AtFortification3",
												[Entities.XD_OSO_Wall_Tower3] = "AtFortification3"
												}
ProjectileHeightCheck.ProjectileByEntity = {[Entities.PU_LeaderBow1] = "FXArrow",
											[Entities.PU_SoldierBow1] = "FXArrow",
											[Entities.PU_LeaderBow2] = "FXArrow",
											[Entities.PU_SoldierBow2] = "FXArrow",
											[Entities.CU_BanditLeaderBow1] = "FXArrow",
											[Entities.CU_BanditSoldierBow1] = "FXArrow",
											[Entities.CU_Evil_LeaderSkirmisher1] = "FXArrow",
											[Entities.CU_Evil_SoldierSkirmisher1] = "FXArrow",
											[Entities.PU_LeaderBow3] = "FXCrossBowArrow",
											[Entities.PU_SoldierBow3] = "FXCrossBowArrow",
											[Entities.PU_LeaderBow4] = "FXCrossBowArrow",
											[Entities.PU_SoldierBow4] = "FXCrossBowArrow",
											[Entities.PU_LeaderCavalry1] = "FXCavalryArrow",
											[Entities.PU_SoldierCavalry1] = "FXCavalryArrow",
											[Entities.PU_LeaderCavalry2] = "FXCrossBowCavalryArrow",
											[Entities.PU_SoldierCavalry2] = "FXCrossBowCavalryArrow",
											[Entities.PU_LeaderRifle1] = "FXBulletRifleman",
											[Entities.PU_SoldierRifle1] = "FXBulletRifleman",
											[Entities.PU_LeaderRifle2] = "FXShotRifleman",
											[Entities.PU_SoldierRifle2] = "FXShotRifleman",
											[Entities.PV_Cannon1] = "FXCannonBallShrapnel",
											[Entities.PV_Cannon2] = "FXCannonBallShrapnel",
											[Entities.PV_Cannon3] = "FXCannonBall",
											[Entities.PV_Cannon4] = "FXCannonBall",
											[Entities.PV_Cannon5] = "FXCannonBallGatling_Barrel1",
											[Entities.PV_Cannon6] = "FXCannonBallLarge"
											}
ProjectileHeightCheck.GetBridgeEntityTypeEntityStandsOn = function(_id)
	local pos = GetPosition(_id)
	for eID in CEntityIterator.Iterator(CEntityIterator.OfCategoryFilter(EntityCategories.Bridge), CEntityIterator.InCircleFilter(pos.X, pos.Y, 500)) do
		return Logic.GetEntityType(eID)
	end
end
ProjectileHeightCheck.GetProjectileEffectByEntityTypeAndBridgeEntity = function(_etype, _btype)
	return (ProjectileHeightCheck.ProjectileByEntity[_etype] .. "_" .. ProjectileHeightCheck.EffectsSuffixByBuilding[_btype])
end
ProjectileHeightCheck.GetGatlingProjectileEffectByEffectAndBridgeEntity = function(_effect, _btype)
	return (_effect .. "_" .. ProjectileHeightCheck.EffectsSuffixByBuilding[_btype])
end