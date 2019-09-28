--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	file:		gui_music.lua
--	brief:	yay music
--	author:	cake
--
--	Copyright (C) 2007.
--	Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name	= "Sound Background",
		desc	= "Plays background sounds based on situation",
		author	= "cake, trepan, Smoth, Licho, xponen",
		date	= "Mar 01, 2008, Aug 20 2009, Nov 23 2011",
		license	= "GNU GPL, v2 or later",
		layer	= 0,
		enabled	= true	--	loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

options_path = 'Settings/Audio'
options = {

}



local windows = {}



local LOOP_BUFFER = 0.015	-- if looping track is this close to the end, go ahead and loop
local UPDATE_PERIOD = 1
local soundScapePath = "sounds/civilian/".._G.GameConfig.instance.culture.."/soundscape/"

local timeframetimer = 0
local timeframetimer_short = 0
local loopTrack = ''
local previousTrack = ''
local previousTrackType = ''
local newTrackWait = 1000
local numVisibleEnemy = 0
local fadeVol
local curTrack	= "no name"
local songText	= "no name"
local haltMusic = false
local looping = false
local paused = false
local lastTrackTime = -1


local	normalTracks		
local	launchleakTracks	
local	anarchyTracks		
local	postlaunchTracks	
local	gameoverTracks		
local	pacificationTracks	

local firstTime = false
local wasPaused = false
local firstFade = true
local initSeed = 0
local initialized = false
local gameStarted = Spring.GetGameFrame() > 0
local gameOver = false

local myTeam = Spring.GetMyTeamID()
local isSpec = Spring.GetSpectatingState() or Spring.IsReplay()
local defeat = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


local function StartLoopingTrack(trackInit, trackLoop)
	if not (VFS.FileExists(trackInit) and VFS.FileExists(trackLoop)) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Missing one or both tracks for looping")
	end
	haltMusic = true
	Spring.StopSoundStream()
	soundScapeType = GG.GlobalGameState or "Normal"
	
	curTrack = trackInit
	loopTrack = trackLoop
	Spring.PlaySoundStream(trackInit, WG.music_volume or 0.5)
	looping = 0.5
end



local function StartTrack(track)
	if not peaceTracks then
		Spring.Echo("Missing peaceTracks file, no music started")
		return
	end

	haltMusic = false
	looping = false
	Spring.StopSoundStream()
	
	local newTrack = previousTrack
	if soundScapeType == 'custom' then
		previousTrackType = "peace"
		soundScapeType = "peace"
	end
	if track then
		newTrack = track	-- play specified track
		soundScapeType = 'custom'
	else
		local tries = 0
		repeat
			if (not gameStarted) then
				if (#briefingTracks == 0) then return end
				newTrack = briefingTracks[ #briefingTracks -math.random(1, #briefingTracks-1)]
				soundScapeType = "briefing"
			elseif soundScapeType == 'peace' then
				if (#peaceTracks == 0) then return end
				newTrack = peaceTracks[math.random(1, #peaceTracks)]
			elseif soundScapeType == 'war' then
				if (#warTracks == 0) then return end
				newTrack = warTracks[math.random(1, #warTracks)]
			end
			tries = tries + 1
		until newTrack ~= previousTrack or tries >= 10
	end
	-- for key, val in pairs(oggInfo) do
		-- Spring.Echo(key, val)	
	-- end
	firstFade = false
	previousTrack = newTrack
	
	-- if (oggInfo.comments.TITLE and oggInfo.comments.TITLE) then
		-- Spring.Echo("Soundscape changed to: " .. oggInfo.comments.TITLE .. " By: " .. oggInfo.comments.ARTIST)
	-- else
		-- Spring.Echo("Soundscape changed but unable to get the artist and title info")
	-- end
	curTrack = newTrack
	Spring.PlaySoundStream(curTrack,WG.music_volume or 0.5)
	
	WG.music_start_volume = WG.music_volume
end




function widget:Update(dt)
	if gameOver then
		return
	end
	if not initialized then
		math.randomseed(os.clock()* 100)
		initialized=true
				
		local vfsMode = (options.useIncludedTracks.value and VFS.RAW_FIRST) or VFS.RAW
		normalTracks		= normalTracks or VFS.DirList(soundScapePath..'normal/', '*.ogg', vfsMode)
		launchleakTracks	= launchleakTracks or VFS.DirList(soundScapePath..'launchleak/', '*.ogg', vfsMode)
		anarchyTracks		= anarchyTracks or VFS.DirList(soundScapePath..'anarchy/', '*.ogg', vfsMode)
		postlaunchTracks	= postlaunchTracks or VFS.DirList(soundScapePath..'postlaunch/', '*.ogg', vfsMode)
		gameoverTracks		= gameoverTracks or VFS.DirList(soundScapePath..'gameover/', '*.ogg', vfsMode)
		pacificationTracks	= pacificationTracks or VFS.DirList(soundScapePath..'pacification/', '*.ogg', vfsMode)
		
	end
	
	timeframetimer_short = timeframetimer_short + dt
	if timeframetimer_short > 0.03 then
		local playedTime, totalTime = Spring.GetSoundStreamTime()
		playedTime = tonumber( ("%.2f"):format(playedTime) )
		paused = (playedTime == lastTrackTime)
		lastTrackTime = playedTime
		if looping then
			if looping == 0.5 then
				looping = 1
			elseif playedTime >= totalTime - LOOP_BUFFER then
				Spring.StopSoundStream()
				Spring.PlaySoundStream(loopTrack,WG.music_volume or 0.5)
			end
		end
		timeframetimer_short = 0
	end
	
	timeframetimer = timeframetimer + dt
	if (timeframetimer > UPDATE_PERIOD) then	-- every second
		timeframetimer = 0
		newTrackWait = newTrackWait + 1
		local PlayerTeam = Spring.GetMyTeamID()

			

		
		soundScapeType = string.gsub(GG.GlobalGameState, "GameState")
	
	
		if (not firstTime) then
			StartTrack()
			firstTime = true -- pop this cherry	
		end
		
		local playedTime, totalTime = Spring.GetSoundStreamTime()
		playedTime = math.floor(playedTime)
		totalTime = math.floor(totalTime)
	
		if ( previousTrackType == "Normal" and soundScapeType == 'LaunchLeak' )
		 or (playedTime >= totalTime)	-- both zero means track stopped
		 then
			previousTrackType = soundScapeType
			StartTrack()
			
			--Spring.Echo("Track: " .. newTrack)
			newTrackWait = 0
		end
		local _, _, paused = Spring.GetGameSpeed()
		if (paused ~= wasPaused) and options.pausemusic.value then
			Spring.PauseSoundStream()
			wasPaused = paused
		end
	end
end

function widget:GameStart()
	if not gameStarted then
		gameStarted = true
		previousTrackType = soundScapeType
		soundScapeType = string.gsub(GG.GlobalGameState, "GameState")
		StartTrack()
	end
	
	--Spring.Echo("Track: " .. newTrack)
	newTrackWait = 0	
end

-- Safety of a heisenbug
function widget:GameFrame()
	widget:GameStart()
	widgetHandler:RemoveCallIn('GameFrame')
end





function widget:TeamDied(team)
	if team == myTeam and not isSpec then
		defeat = true
	end
end

local function PlayGameOverMusic(gameWon)
	local track
	if gameWon then
		if #gameoverTracks <= 0 then return end
		track = gameoverTracks[math.random(1, #gameoverTracks)]
		soundScapeType = "GameOver"
	else
		if #postLaunchTracks <= 0 then return end
		track = postLaunchTracks[math.random(1, #postLaunchTracks)]
		soundScapeType = "PostLaunch"
	end
	looping = false
	Spring.StopSoundStream()
	Spring.PlaySoundStream(track,WG.music_volume or 0.5)
	WG.music_start_volume = WG.music_volume
end

function widget:GameOver()
	PlayGameOverMusic(not defeat)
end

function widget:Initialize()
	WG.Music = WG.Music or {}
	WG.Music.StartTrack = StartTrack
	WG.Music.StartLoopingTrack = StartLoopingTrack

	WG.Music.SetWarThreshold = SetWarThreshold
	WG.Music.SetPeaceThreshold = SetPeaceThreshold
	WG.Music.GetsoundScapeType = GetsoundScapeType
	WG.Music.PlayGameOverMusic = PlayGameOverMusic


end

function widget:Shutdown()
	Spring.StopSoundStream()
	WG.Music = nil

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------