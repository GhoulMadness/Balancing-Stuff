------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Silversmith Grievance Job ------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ControlSiversmithGrievance()
	-- Need to reset globals?
	if not gvSpeech then
		return
	end
	if gvSpeech.ResetGlobalsFlag == 1 then
		Speech_Privat_InitGlobals()
		return
	end
	--not needed if the Sounds are already valid
	if Sounds.VoicesMentor_LEAVE_Silversmith ~= nil then
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
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 262)
					--StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooHighTaxes,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\leave_silversmith.wav", 262)
					----StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooMuchWork,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\mad_silversmith.wav", 262)
					----StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooMuchWork,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
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
					Stream.Start("Sounds\\VoicesMentor\\sad_silversmith.wav", 262)
					----StartCountdown(math.ceil(Stream.GetDuration()),GrievanceReasonTooMuchWork,false)
					gvSpeech.SecondsToWait = gcSpeechSecondsToWaitLimit
				end
				return
			end
		end
	end
end