
	--normaler Sommer
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox07")
    Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 152,172,182, 5000,32000)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  120,130,110,  205,204,180)
	
	--Nacht
    Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox09")
    Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(9, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 52,82,92, 3500,32000)
	Display.GfxSetSetLightParams(9,  0.0, 1.0, 40, -15, -50,  80,90,80,  1,1,1)
	AddPeriodicNight = function(dauer)
		Logic.AddWeatherElement(1, dauer, 1, 9, 5, 15)
	end
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
	--Schnee ohne Schneefall und keine Schneebodentextur
    Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(4, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 152,172,182, 3500,29500)
	Display.GfxSetSetLightParams(4,  0.0, 1.0,  40, -15, -75,  106,154,154, 255,234,202)
	AddPeriodicMeltingSnow = function(dauer)
		Logic.AddWeatherElement(3, dauer, 1, 4, 5, 15)
	end
	--Regen mit Schneeflocken
    Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
    Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 102,132,142, 3500,29000)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50,  90,100,80,  205,204,180)
	AddPeriodicSnowyRain = function(dauer)
		Logic.AddWeatherElement(2, dauer, 1, 5, 5, 15)
	end
	--Winter mit Regen
    Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 1)
    Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 152,172,182, 3500,29000)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -75,  106,154,154, 255,234,202)
	AddPeriodicWinterRain = function(dauer)
		Logic.AddWeatherElement(3, dauer, 1, 6, 5, 15)
	end
	--Sommer mit Schneetextur
    Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
    Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 152,172,182, 3500,32000)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -50,  120,130,110,  205,204,180)
	AddPeriodicSummerSnow = function(dauer)
		Logic.AddWeatherElement(1, dauer, 1, 7, 5, 15)
	end		
	--Winter ohne Schneefall
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox01")
    Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 0)
    Display.GfxSetSetSnowStatus(8, 0, 1.0, 1)
    Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 152,172,182, 3500,29000)
	Display.GfxSetSetLightParams(8,  0.0, 1.0,  40, -15, -75,  116,164,164, 255,234,202)
	AddPeriodicSnow = function(dauer)
		Logic.AddWeatherElement(3, dauer, 1, 8, 5, 15)
	end
	--Sonnenauf-/-untergang
	 Display.GfxSetSetSkyBox(10, 0.0, 1.0, "YSkyBox08")   
	 Display.GfxSetSetRainEffectStatus(10, 0.0, 1.0, 0)   
	 Display.GfxSetSetSnowStatus(10, 0, 1.0, 0)   
	 Display.GfxSetSetSnowEffectStatus(10, 0.0, 0.8, 0)	
	 Display.GfxSetSetFogParams(10, 0.0, 1.0, 1, 215,70,0, 3500,29000)	
	 Display.GfxSetSetLightParams(10,  0.0, 1.0, 40, 165, -50,  80,90,80,  175,70,0)	
	 AddPeriodicSunrise = function(dauer)		
		Logic.AddWeatherElement(1, dauer, 1, 10, 5, 15)		
	 end	
	 --Sonnenauf-/-untergangs-Übergang
	 Display.GfxSetSetSkyBox(12, 0.0, 1.0, "YSkyBox07")   
	 Display.GfxSetSetRainEffectStatus(12, 0.0, 1.0, 0)   
	 Display.GfxSetSetSnowStatus(12, 0, 1.0, 0)   
	 Display.GfxSetSetSnowEffectStatus(12, 0.0, 0.8, 0)	
	 Display.GfxSetSetFogParams(12, 0.0, 1.0, 1, 165,70,70, 3500,29000)	
	 Display.GfxSetSetLightParams(12,  0.0, 1.0, 40, 115, -50,  80,90,80,  135,70,60)	
	 AddPeriodicTransitionSunrise = function(dauer)		
		Logic.AddWeatherElement(1, dauer, 1, 12, 5, 15)		
	 end	
	 --Gewitter
	 Display.GfxSetSetSkyBox(11, 0.0, 1.0, "YSkyBox04")
	 Display.GfxSetSetRainEffectStatus(11, 0.0, 1.0, 1)
	 Display.GfxSetSetSnowStatus(11, 0, 1.0, 0)
	 Display.GfxSetSetSnowEffectStatus(11, 0.0, 0.8, 1)
	 Display.GfxSetSetFogParams(11, 0.0, 1.0, 1, 0,0,230, 7500,27000)	
	 Display.GfxSetSetLightParams(11,  0.0, 1.0, 40, -15, -50,  80,90,80,  0,0,170) 
	 AddPeriodicThunderstorm = function(dauer)		
		Logic.AddWeatherElement(2, dauer, 1, 11, 5, 15)	
	 end
	 
function TagNachtZyklus(_duration,_rainflag,_snowflag,_bonuscount)

	if _duration == nil then
		_duration = 24
	end
	if _bonuscount == nil then
		_bonuscount = 0
	end
	if _rainflag == nil then
		_rainflag = 0
	end
	if _snowflag == nil then
		_snowflag = 0
	end
	local durationinsec = _duration*60 
	local bonuscountinsec = _bonuscount * 60
	gvDayTimeSeconds = _duration

	if _rainflag == 0 and _snowflag == 0 then
		AddPeriodicSummer(durationinsec/2)							--12min Tag startet um 08:00 morgens
		AddPeriodicTransitionSunrise(durationinsec/24)				--1min
		AddPeriodicSunrise(durationinsec/24)						--1min
		AddPeriodicNight(durationinsec/3)							--8min
		AddPeriodicSunrise(durationinsec/24)						--1min
		AddPeriodicTransitionSunrise(durationinsec/24)				--1min
		Display.SetRenderUseGfxSets(1)	
	elseif _rainflag == 1 and _snowflag == 0 then
		AddPeriodicSummer((durationinsec/2.4)-bonuscountinsec)		--10min	Tag startet um 08:00 morgens
		AddPeriodicRain((durationinsec/48)+bonuscountinsec)			--0.5min
		AddPeriodicSnowyRain((durationinsec/48)+bonuscountinsec)	--0.5min
		AddPeriodicTransitionSunrise(durationinsec/48)				--0.5min
		AddPeriodicSunrise(durationinsec/24)						--1min
		AddPeriodicNight((durationinsec/2.4)-bonuscountinsec)			--10min
		AddPeriodicSunrise(durationinsec/24)						--1min
		AddPeriodicTransitionSunrise(durationinsec/48)				--0.5min
		Display.SetRenderUseGfxSets(1)	
	elseif _rainflag == 0 and _snowflag == 1 then
		AddPeriodicSummer((durationinsec/2.4)-bonuscountinsec)
		AddPeriodicWinter((durationinsec/48)+bonuscountinsec)
		AddPeriodicSnow((durationinsec/48)+bonuscountinsec)
		AddPeriodicTransitionSunrise(durationinsec/48)
		AddPeriodicSunrise(durationinsec/24)
		AddPeriodicNight((durationinsec/2.4)-bonuscountinsec)
		AddPeriodicSunrise(durationinsec/24)
		AddPeriodicTransitionSunrise(durationinsec/48)
		Display.SetRenderUseGfxSets(1)	
	elseif _rainflag == 1 and _snowflag == 1 then
		AddPeriodicSummer((durationinsec/2.4)-bonuscountinsec)
		AddPeriodicWinter((durationinsec/48)+(bonuscountinsec/2))
		AddPeriodicSnowyRain((durationinsec/48)+(bonuscountinsec/2))
		AddPeriodicSnow((durationinsec/48)+(bonuscountinsec/2))
		AddPeriodicRain((durationinsec/48)+(bonuscountinsec/2))
		AddPeriodicTransitionSunrise(durationinsec/24)
		AddPeriodicSunrise(durationinsec/24)
		AddPeriodicNight((durationinsec/3)-bonuscountinsec)
		AddPeriodicSunrise(durationinsec/24)
		AddPeriodicTransitionSunrise(durationinsec/24)
		Display.SetRenderUseGfxSets(1)	
	end
end