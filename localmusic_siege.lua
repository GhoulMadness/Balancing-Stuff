--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Music Script for Siege Maps
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LocalMusic = LocalMusic or {}

LocalMusic.MusicPath = "data\\voice\\music\\"

LocalMusic.Songs = {
					{ "castlejam.mp3", 259 },
					{ "fiddle_solo.mp3", 155 },
					{ "labyrinth.mp3", 302 },
					{ "mattsjig.mp3", 172 },
					{ "minstrelosity.mp3", 158 },
					{ "sad_times_full.mp3", 309 },
					{ "the_life_of_a_gong_farmer.mp3", 212 },
					{ "two_mandolins.mp3", 153 },
					{ "underanoldtree.mp3", 267 },
					{ "virgin_territory.mp3", 263 }
					}

LocalMusic.SetBattle =  {
						{ "the_chant.mp3", 69 },
						{ "the_lamb.mp3", 88 },
						{ "the_smith.mp3", 181 }
						}
LocalMusic.SetMainTheme = LocalMusic.Songs
LocalMusic.SetBriefing =	{
							{ "victory_is_ours.mp3", 39 }
							}

LocalMusic.SongLength = 0
LocalMusic.BattlesOnTheMap = 0
LocalMusic.LastBattleMusicStarted = 0

function LocalMusic_UpdateMusic()

	if LocalMusic.BattlesOnTheMap == 0 then
		--Music is playing?
		if LocalMusic.SongLength > Logic.GetTime() then
			return
		end
	end

	local SetToUse

	if LocalMusic.BattlesOnTheMap == 1 or LocalMusic.BattlesOnTheMap == 2 then
		SetToUse = LocalMusic.SetBattle
	elseif LocalMusic.BattlesOnTheMap == 0 then
		SetToUse = LocalMusic.SetMainTheme
	end

	--is briefing running?
 	if (IsBriefingActive ~= nil and IsBriefingActive() == true )
 	or (IsCutsceneActive~= nil and IsCutsceneActive() == true)then
		SetToUse = LocalMusic.SetBriefing
	end

	local SongAmount = table.getn(SetToUse)
	local Random = 1 + XGUIEng.GetRandom(SongAmount-1)
	local SongToPlay = LocalMusic.MusicPath .. SetToUse[Random][1]

	Sound.StartMusic( SongToPlay, 157)
	LocalMusic.SongLength =  Logic.GetTime() + SetToUse[Random][2] + 2

	LocalMusic.BattlesOnTheMap = 0

end