function BS.GfxInit()
	----------------------------  Nacht -GFXs  ----------------------------------------------------
	--Sommer-Nacht
    Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox09")
    Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(9, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(9,  0.0, 1.0, 40, -15, -50,  80,90,80,  1,1,1)
	AddPeriodicNight = AddPeriodicNight or function(dauer)
		Logic.AddWeatherElement(1, dauer, 1, 9, 5, 15)
	end
	--Sommer-Nacht mit Schneefall
    Display.GfxSetSetSkyBox(19, 0.0, 1.0, "YSkyBox09")
    Display.GfxSetSetRainEffectStatus(19, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(19, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(19, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(19, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(19,  0.0, 1.0, 40, -15, -50,  80,90,80,  31,31,31)
	--Regen-Nacht
    Display.GfxSetSetSkyBox(13, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(13, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(13, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(13, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(13, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(13,  0.0, 1.0, 40, -15, -50,  80,90,80,  21,21,21)
	--Regen-Nacht mit Schneefall
    Display.GfxSetSetSkyBox(20, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(20, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(20, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(20, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(20, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(20,  0.0, 1.0, 40, -15, -50,  80,90,80,  21,21,21)
	--Nächtliches Gewitter
	Display.GfxSetSetSkyBox(28, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(28, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(28, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(28, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(28, 0.0, 1.0, 1, 30,30,85, 7500,28000)
	Display.GfxSetSetLightParams(28,  0.0, 1.0, 40, -15, -50,  10,30,70,  0,0,40)
	--Winter-Nacht
    Display.GfxSetSetSkyBox(14, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(14, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(14, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(14, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(14, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(14,  0.0, 1.0, 40, -15, -50,  80,90,80,  21,21,21)
	--Winter-Nacht mit Regen
    Display.GfxSetSetSkyBox(21, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(21, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(21, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(21, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(21, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(21,  0.0, 1.0, 40, -15, -50,  80,90,80,  21,21,21)
	----------------------------  Tag -GFXs  ------------------------------------------------------
	--normaler Sommer
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox07")
    Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 152,172,182, 5000,32000)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  120,130,110,  205,204,180)
	--normaler Regen
    Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 72,102,112, 0,29500)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  70,80,70,  205,204,180)
	--normaler Winter
    Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
    Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 108,128,138, 3000,29500)
    Display.GfxSetSetLightParams(3,  0.0, 1.0, 40, -15, -50,  116,164,164, 255,234,202)
	--Schnee ohne Schneefall mit Regen
    Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(4, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 152,172,182, 3500,29500)
	Display.GfxSetSetLightParams(4,  0.0, 1.0,  40, -15, -75,  106,154,154, 255,234,202)
	AddPeriodicMeltingSnow = AddPeriodicMeltingSnow or function(dauer)
		Logic.AddWeatherElement(3, dauer, 1, 4, 5, 15)
	end
	--Regen mit Schneeflocken
    Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 102,132,142, 3500,29000)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50,  90,100,80,  205,204,180)
	AddPeriodicSnowyRain = AddPeriodicSnowyRain or function(dauer)
		Logic.AddWeatherElement(2, dauer, 1, 5, 5, 15)
	end
	--Winter mit Regen
    Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 152,172,182, 3500,29000)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -75,  106,154,154, 255,234,202)
	AddPeriodicWinterRain = AddPeriodicWinterRain or function(dauer)
		Logic.AddWeatherElement(3, dauer, 1, 6, 5, 15)
	end
	--Sommer mit Schneefall
    Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 152,172,182, 3500,32000)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -50,  120,130,110,  205,204,180)
	AddPeriodicSummerSnow = AddPeriodicSummerSnow or function(dauer)
		Logic.AddWeatherElement(1, dauer, 1, 7, 5, 15)
	end
	--Winter ohne Schneefall
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(8, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 152,172,182, 3500,29000)
	Display.GfxSetSetLightParams(8,  0.0, 1.0,  40, -15, -75,  116,164,164, 255,234,202)
	AddPeriodicSnow = AddPeriodicSnow or function(dauer)
		Logic.AddWeatherElement(3, dauer, 1, 8, 5, 15)
	end
	--Gewitter
	Display.GfxSetSetSkyBox(11, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(11, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(11, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(11, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(11, 0.0, 1.0, 1, 90,90,170, 7500,27000)
	Display.GfxSetSetLightParams(11,  0.0, 1.0, 40, -15, -50,  90,90,140,  60,60,140)
	AddPeriodicThunderstorm = AddPeriodicThunderstorm or function(dauer)
		Logic.AddWeatherElement(2, dauer, 1, 11, 5, 15)
	end
	----------------------------  Sonnenauf-/-untergangs -GFXs  -----------------------------------
	--Sonnenauf-/-untergang
	Display.GfxSetSetSkyBox(10, 0.0, 1.0, "YSkyBox08")
	Display.GfxSetSetRainEffectStatus(10, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(10, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(10, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(10, 0.0, 1.0, 1, 215,70,0, 3500,29000)
	Display.GfxSetSetLightParams(10,  0.0, 1.0, 40, 165, -50,  80,90,80,  175,70,0)
	AddPeriodicSunrise = AddPeriodicSunrise or function(dauer)
		Logic.AddWeatherElement(1, dauer, 1, 10, 5, 15)
	end
	--Sonnenauf-/-untergang mit Schneefall
	Display.GfxSetSetSkyBox(22, 0.0, 1.0, "YSkyBox08")
	Display.GfxSetSetRainEffectStatus(22, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(22, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(22, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(22, 0.0, 1.0, 1, 215,70,0, 3500,29000)
	Display.GfxSetSetLightParams(22,  0.0, 1.0, 40, 165, -50,  80,90,80,  175,70,0)
	--Sonnenauf-/-untergang mit Regen
    Display.GfxSetSetSkyBox(15, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(15, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(15, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(15, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(15, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(15,  0.0, 1.0, 40, 165, -50,  80,90,80,  91,91,91)
	--Sonnenauf-/-untergang mit Regen und Schneefall
    Display.GfxSetSetSkyBox(23, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(23, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(23, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(23, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(23, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(23,  0.0, 1.0, 40, 165, -50,  80,90,80,  91,91,91)
	--Sonnenauf-/-untergang mit Winter
    Display.GfxSetSetSkyBox(16, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(16, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(16, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(16, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(16, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(16,  0.0, 1.0, 40, 165, -50,  80,90,80,  91,91,91)
	--Sonnenauf-/-untergang mit Winter und Regen
    Display.GfxSetSetSkyBox(24, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(24, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(24, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(24, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(24, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(24,  0.0, 1.0, 40, 165, -50,  80,90,80,  91,91,91)
	--Sonnenauf-/-untergangs-Übergang
	Display.GfxSetSetSkyBox(12, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(12, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(12, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(12, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(12, 0.0, 1.0, 1, 165,70,70, 3500,29000)
	Display.GfxSetSetLightParams(12,  0.0, 1.0, 40, 115, -50,  100,110,100,  135,70,60)
	AddPeriodicTransitionSunrise = AddPeriodicTransitionSunrise or function(dauer)
		Logic.AddWeatherElement(1, dauer, 1, 12, 5, 15)
	end
	--Sonnenauf-/-untergangs-Übergang mit Schneefall
	Display.GfxSetSetSkyBox(25, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(25, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(25, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(25, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(25, 0.0, 1.0, 1, 165,70,70, 3500,29000)
	Display.GfxSetSetLightParams(25,  0.0, 1.0, 40, 115, -50,  100,110,100,  135,70,60)
	--Sonnenauf-/-untergangs-Übergang mit Regen
    Display.GfxSetSetSkyBox(17, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(17, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(17, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(17, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(17, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(17,  0.0, 1.0, 40, 115, -50,  80,90,80,  51,51,51)
	--Sonnenauf-/-untergangs-Übergang mit Regen und Schnee
    Display.GfxSetSetSkyBox(26, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(26, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(26, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(26, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(26, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(26,  0.0, 1.0, 40, 115, -50,  70,80,70,  51,51,51)
	--Sonnenauf-/-untergangs-Übergang mit Winter
    Display.GfxSetSetSkyBox(18, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(18, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(18, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(18, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(18, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(18,  0.0, 1.0, 40, 115, -50,  100,110,100,  51,51,51)
	--Sonnenauf-/-untergangs-Übergang mit Winter und Regen
    Display.GfxSetSetSkyBox(27, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(27, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(27, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(27, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(27, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(27,  0.0, 1.0, 40, 115, -50,  80,90,80,  51,51,51)
	--
	Display.SetRenderUseGfxSets(1)
end
---------------------------------------------------------------------------------------------------
function TagNachtZyklus(_duration, _rainflag, _snowflag, _bonuscount, _randomflag)

	--default values if nil
	_duration = _duration or 24
	_bonuscount = _bonuscount or 0
	_rainflag = _rainflag or 0
	_snowflag = _snowflag or 0
	_randomflag = _randomflag or 0

	local durationinsec = _duration * 60
	local bonuscountinsec = _bonuscount * 60
	--0 = weder Regen noch Winter; 1 = Regen, aber kein Winter; 2 = Winter, aber kein Regen; 3 = Regen und Winter
	local allowed_weathertypes = _rainflag + (2*_snowflag)
	gvDayTimeSeconds = _duration
	if _rainflag == 0 and _snowflag == 0 then
		AddPeriodicSummer(round(durationinsec/2))							--12min Tag startet um 08:00 morgens
		AddPeriodicTransitionSunrise(round(durationinsec/24))				--1min
		AddPeriodicSunrise(round(durationinsec/24))							--1min
		AddPeriodicNight(round(durationinsec/3))							--8min
		AddPeriodicSunrise(round(durationinsec/24))							--1min
		AddPeriodicTransitionSunrise(round(durationinsec/24))				--1min
	end
	if _randomflag == 0 then
		if _rainflag == 1 and _snowflag == 0 then
			AddPeriodicSummer((durationinsec/2)-(bonuscountinsec/2))		--12min	Tag startet um 08:00 morgens
			AddPeriodicRain((durationinsec/48)+(bonuscountinsec/2))			--0.5min
			AddPeriodicSnowyRain((durationinsec/48)+(bonuscountinsec/2))	--0.5min
			AddPeriodicTransitionSunrise(durationinsec/48)					--0.5min
			AddPeriodicSunrise(durationinsec/24)							--1min
			AddPeriodicNight((durationinsec/3)-(bonuscountinsec/2))			--8min
			AddPeriodicSunrise(durationinsec/24)							--1min
			AddPeriodicTransitionSunrise(durationinsec/48)					--0.5min
		elseif _rainflag == 0 and _snowflag == 1 then
			AddPeriodicSummer((durationinsec/2.4)-(bonuscountinsec/2))
			AddPeriodicWinter((durationinsec/48)+(bonuscountinsec/2))
			AddPeriodicSnow((durationinsec/48)+(bonuscountinsec/2))
			AddPeriodicTransitionSunrise(durationinsec/48)
			AddPeriodicSunrise(durationinsec/24)
			AddPeriodicNight((durationinsec/2.4)-(bonuscountinsec/2))
			AddPeriodicSunrise(durationinsec/24)
			AddPeriodicTransitionSunrise(durationinsec/48)
		elseif _rainflag == 1 and _snowflag == 1 then
			AddPeriodicSummer((durationinsec/2.4)-(bonuscountinsec/2))			--10min
			AddPeriodicWinter((durationinsec/48)+((bonuscountinsec/2)/2))		--0.5min
			AddPeriodicSnowyRain((durationinsec/48)+((bonuscountinsec/2)/2))	--0.5min
			AddPeriodicSnow((durationinsec/48)+((bonuscountinsec/2)/2))			--0.5min
			AddPeriodicRain((durationinsec/48)+((bonuscountinsec/2)/2))			--0.5min
			AddPeriodicTransitionSunrise(durationinsec/24)						--1min
			AddPeriodicSunrise(durationinsec/24)								--1min
			AddPeriodicNight((durationinsec/3)-(bonuscountinsec/2))				--8min
			AddPeriodicSunrise(durationinsec/24)								--1min
			AddPeriodicTransitionSunrise(durationinsec/24)						--1min
		end
	else
		AddRandomWeatherSet(round(durationinsec/12),4,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),4,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),4,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),4,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),4,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),4,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/48),3,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/48),3,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/48),2,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/48),2,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/12),1,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),1,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),1,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/12),1,allowed_weathertypes,_bonuscount)							--2min
		AddRandomWeatherSet(round(durationinsec/48),2,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/48),2,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/48),3,allowed_weathertypes,_bonuscount)							--0.5min
		AddRandomWeatherSet(round(durationinsec/48),3,allowed_weathertypes,_bonuscount)							--0.5min

	end
	gvDayCycleStartTime = Logic.GetTime()
end
--daytypes: 1 = Nacht, 2 = Sonnenauf-/-untergang, 3 = Sonnenauf-/-untergangs-Übergang, 4 = Tag
--weathertypes: 1 = Sommer, 2 = Regen, 3 = Winter
GfxElements = 	{ daytypes =   {[1] = {weathertypes = {[1] = {[1] = 9,
															  [2] = 19},
													   [2] = {[1] = 13,
															  [2] = 20,
															  [3] = 28},
													   [3] = {[1] = 14,
															  [2] = 21}}},
								[2] = {weathertypes = {[1] = {[1] = 10,
															  [2] = 22},
													   [2] = {[1] = 15,
															  [2] = 23},
													   [3] = {[1] = 16,
															  [2] = 24}}},
								[3] = {weathertypes = {[1] = {[1] = 12,
															  [2] = 25},
													   [2] = {[1] = 17,
															  [2] = 26},
													   [3] = {[1] = 18,
															  [2] = 27}}},
								[4] = {weathertypes = {[1] = {[1] = 1,
															  [2] = 7},
													   [2] = {[1] = 2,
															  [2] = 5,
															  [3] = 11},
													   [3] = {[1] = 3,
															  [2] = 4,
															  [3] = 6,
															  [4] = 8}}}
							   },
				 weathertypes = { [1] = {1,7,9,10,12,19,22,25},
								  [2] = {2,5,8,11,13,15,17,20,23,26,28},
								  [3] = {3,4,6,14,16,18,21,24,27}
								}
				}

function AddRandomWeatherSet(_duration, _daytype, _allowed_weathertypes, _modifier)

	local num = math.random(100)
	local weathergfx,weathertype
	-- nur Sommer
	if _allowed_weathertypes == 0 then
			--Sommer
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[1][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[1]))]
			weathertype = 1
	-- Sommer und Regen
	elseif _allowed_weathertypes == 1 then
		if num <= (80 - (_modifier*5)) then
			--Sommer
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[1][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[1]))]
			weathertype = 1
		else
			--Regen
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[2][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[2]))]
			weathertype = 2
		end
	-- Sommer und Winter
	elseif _allowed_weathertypes == 2 then
		if num <= (80 - (_modifier*5)) then
			--Sommer
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[1][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[1]))]
			weathertype = 1
		else
			--Winter
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[3][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[3]))]
			weathertype = 3
		end
	-- Sommer, Regen und Winter
	elseif _allowed_weathertypes == 3 then
		if num <= (70 - (_modifier*5)) then
			--Sommer
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[1][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[1]))]
			weathertype = 1
		elseif num > (70 - (_modifier*5)) and num <= (90 - (_modifier*2)) then
			--Regen
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[2][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[2]))]
			weathertype = 2
		else
			--Winter
			weathergfx = GfxElements.daytypes[_daytype].weathertypes[3][math.random(table.getn(GfxElements.daytypes[_daytype].weathertypes[3]))]
			weathertype = 3
		end
	end
	return Logic.AddWeatherElement(weathertype, _duration, 1, weathergfx, 5, 15)
end