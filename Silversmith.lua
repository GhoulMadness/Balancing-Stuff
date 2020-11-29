gvSilversmith = {}
gvSilversmith.SoundCheck = {SAD = {},MAD = {},LEAVE = {}}
gvSilversmith.OvertimeCheck = {}
gvSilversmith.PaydayCheck = {}
for i = 1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
	gvSilversmith.SoundCheck.SAD[i] = 0
	gvSilversmith.SoundCheck.MAD[i] = 0
	gvSilversmith.SoundCheck.LEAVE[i] = 0
	gvSilversmith.OvertimeCheck[i] = 0
	gvSilversmith.PaydayCheck[i] = 0
end
function gvSilversmith.MotiCheck(_PID,_eID)
	
	if Logic.IsEntityAlive(_eID) ~= 1 then
		return 
	end
	if Logic.IsWorker(_eID) ~= 1 then
		return
	end
	if Logic.EntityGetPlayer(_eID) ~= _PID then
		return
	end
	local moti = Logic.GetSettlersMotivation(_eID)
	local motiSAD = Logic.GetLogicPropertiesMotivationThresholdSad()
	local motiMAD = Logic.GetLogicPropertiesMotivationThresholdAngry()
	local motiLEAVE = Logic.GetLogicPropertiesMotivationThresholdLeave()
	local bID = Logic.GetSettlersWorkBuilding(_eID)
	
	gvSilversmith.SoundCheck.SAD[_PID] = gvSilversmith.SoundCheck.SAD[_PID] - 1
	gvSilversmith.SoundCheck.MAD[_PID] = gvSilversmith.SoundCheck.MAD[_PID] - 1
	gvSilversmith.SoundCheck.LEAVE[_PID] = gvSilversmith.SoundCheck.LEAVE[_PID] - 1
	gvSilversmith.OvertimeCheck[_PID] = Logic.IsOvertimeActiveAtBuilding(bID)
	if Logic.GetPlayerPaydayFrequency(_PID) - Logic.GetPlayerPaydayTimeLeft(_PID) <= 5 then
		gvSilversmith.PaydayCheck[_PID] = 1
	else
		gvSilversmith.PaydayCheck[_PID] = 0
	end
	if _PID == GUI.GetPlayerID() then
		if moti < motiSAD and moti >= motiMAD then
			if gvSilversmith.SoundCheck.SAD[_PID] == 0 then
				if gvSilversmith.OvertimeCheck[_PID] == 1 or gvSilversmith.PaydayCheck[_PID] == 1 then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 232)
					gvSilversmith.SoundCheck.SAD[_PID] = 20 
				end
			end
		end
		if moti < motiMAD and moti > motiLEAVE then
			if gvSilversmith.SoundCheck.MAD[_PID] == 0 then
				if gvSilversmith.OvertimeCheck[_PID] == 1 or gvSilversmith.PaydayCheck[_PID] == 1 then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 232)
					gvSilversmith.SoundCheck.MAD[_PID] = 20 
				end
			end
		end
		if moti <= motiLEAVE then
			if gvSilversmith.SoundCheck.LEAVE[_PID] == 0 then
				if gvSilversmith.OvertimeCheck[_PID] == 1 or gvSilversmith.PaydayCheck[_PID] == 1 then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 232)
					gvSilversmith.SoundCheck.LEAVE[_PID] = 20 
				end
			end
		end
	end
end
function ControlSiversmithSpeech()
	-- Need to reset globals?
	if gvSpeech.ResetGlobalsFlag == 1 then
		Speech_Privat_InitGlobals()
		return
	end
	
	
    -----------------------------------------------------------------------------------------------
    -- Get current game time
    local GameTimeMS = Logic.GetTimeMs()
    
    	
    -----------------------------------------------------------------------------------------------
    -- Get player ID
    local PlayerID = GUI.GetPlayerID()
	-----------------------------------------------------------------------------------------------
    -- System stuff
    
	-- Decrement wait counter; return when time to wait bigger than 0	
    if gvSpeech.SecondsToWait ~= 0 then
		gvSpeech.SecondsToWait = gvSpeech.SecondsToWait - 1
		if gvSpeech.SecondsToWait > 0 then
			return
        end
        gvSpeech.SecondsToWait = 0
	end
	

	--Don't play speeches during cinematics
	if gvInterfaceCinematicFlag == 1 then
		return
	end
	 -----------------------------------------------------------------------------------------------
    -- Settler grievance
    do
		-------------------------------------------------------------------------------------------
		-- No work
		
		-- Settler is leaving, because of no work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateLeaving, Feedback.SettlerReasonNoWork )
 			if LastGrievanceMS > gvSpeech.GrievanceLeavingNoWorkBanGameTimeMS then
				gvSpeech.GrievanceLeavingNoWorkBanGameTimeMS = GameTimeMS 
				gvSpeech.GrievanceAngryNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 232)
				end
				return
			end
		end
		-- Settler is angry, because of no work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateAngry, Feedback.SettlerReasonNoWork )
 			if LastGrievanceMS > gvSpeech.GrievanceAngryNoWorkBanGameTimeMS then
				gvSpeech.GrievanceAngryNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 232)
				end
				return
			end
		end
		-- Settler is sad, because of no work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateSad, Feedback.SettlerReasonNoWork )
 			if LastGrievanceMS > gvSpeech.GrievanceSadNoWorkBanGameTimeMS then
				gvSpeech.GrievanceSadNoWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 232)
				end
				return
			end
		end
		-------------------------------------------------------------------------------------------
		-- Taxes
		
		-- Settler is leaving, because of taxes
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateLeaving, Feedback.SettlerReasonTaxes )
 			if LastGrievanceMS > gvSpeech.GrievanceLeavingTaxesBanGameTimeMS then
				gvSpeech.GrievanceLeavingTaxesBanGameTimeMS = GameTimeMS 
				gvSpeech.GrievanceAngryTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 232)
				end
				return
			end
		end
	
		-- Settler is angry, because of taxes
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateAngry, Feedback.SettlerReasonTaxes )
 			if LastGrievanceMS > gvSpeech.GrievanceAngryTaxesBanGameTimeMS then
				gvSpeech.GrievanceAngryTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 232)
				end
				return
			end
		end
		
		-- Settler is sad, because of taxes
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateSad, Feedback.SettlerReasonTaxes )
 			if LastGrievanceMS > gvSpeech.GrievanceSadTaxesBanGameTimeMS then
				gvSpeech.GrievanceSadTaxesBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 232)
				end
				return
			end
		end
		-------------------------------------------------------------------------------------------
		-- Too much work
		
		-- Settler is leaving, because of too much work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateLeaving, Feedback.SettlerReasonTooMuchWork )
 			if LastGrievanceMS > gvSpeech.GrievanceLeavingTooMuchWorkBanGameTimeMS then
				gvSpeech.GrievanceLeavingTooMuchWorkBanGameTimeMS = GameTimeMS 
				gvSpeech.GrievanceAngryTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS

				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 232)
				end
				return
			end
		end
	
		-- Settler is angry, because of too much work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateAngry, Feedback.SettlerReasonTooMuchWork )
 			if LastGrievanceMS > gvSpeech.GrievanceAngryTooMuchWorkBanGameTimeMS then
				gvSpeech.GrievanceAngryTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 232)
				end
				return
			end
		end
		
		-- Settler is sad, because of too much work
		do
			local LastGrievanceMS, EntityType = Logic.FeedbackGetLastGrievanceGameTimeMS( PlayerID, Feedback.SettlerStateSad, Feedback.SettlerReasonTooMuchWork )
 			if LastGrievanceMS > gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS then
				gvSpeech.GrievanceSadTooMuchWorkBanGameTimeMS = GameTimeMS + gcFeedbackSettlerBanTimeMS
				
				if EntityType == Entities.PU_Silversmith then
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 232)
				end
				return
			end
		end
	end
end
--Logic.FeedbackGetEntityTypeArrivalGameTimeMS(_player, _entityType) Gibt die Zeit in Millisekunden zurück, bei der zum ersten Mal ein bestimmter Siedler Typ aus dem Dorfzentrum eines Spielers
--  gekommen ist; wenn noch kein Siedler des Typs existiert, dann wird 0 zurückgegeben.
--Logic.FeedbackGetLastGrievanceGameTimeMS(_player, _feedbackState, _feedbackReason) Gibt die Zeit in Millisekunden zurück, bei der zum letzten Mal eine Feedback Meldung über eine Siedler Beschwerde kam und den betreffenden Siedler Typ
