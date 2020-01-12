include "createCorpse.lua"
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"
include "lib_mosaic.lua"
TablesOfPiecesGroups = {}

center = piece "center"
attachPoint = piece "attachPoint"
myDefID = Spring.GetUnitDefID(unitID)
TruckTypeTable = getTruckTypeTable(UnitDefs)
boolIsCivilianTruck = (TruckTypeTable[myDefID] == nil)
GameConfig= getGameConfig()

SIG_LOUDNESOVERRIDE= 2

function showAndTell()
	showAll(unitID)
	if TablesOfPiecesGroups["LightEmit"] then
		hideT(TablesOfPiecesGroups["LightEmit"])
	end

	if TablesOfPiecesGroups["Body"]  then
		hideT(TablesOfPiecesGroups["Body"])
		Show(TablesOfPiecesGroups["Body"][2])
	end

end

function script.Create()
	Spring.SetUnitAlwaysVisible(unitID, true)
	Spring.SetUnitNeutral(unitID, false)
    generatepiecesTableAndArrayCode(unitID)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false)
	showAndTell()
	StartThread(delayedSirens)
	StartThread(theySeeMeRollin)
end




function theySeeMeRollin()
	oldConvictID = unitID --police will never chase itself
	x,y,z = Spring.GetUnitPosition(unitID)
	local lastSeenPos ={x=x,y=y,z=z};	
	local searchRange =1
	options = 4

	--echo("Entering Police truck loop")
	while true do
		if not GG.PoliceInPursuit then GG.PoliceInPursuit={} end
		
		if ( GG.PoliceInPursuit and  GG.PoliceInPursuit[unitID] )	then
			convictID = GG.PoliceInPursuit[unitID]
			while isUnitAlive(convictID) == true  do
			
				-- there is still a person to pursuit..
				if oldConvictID ~= convictID then
					x,y,z = Spring.GetUnitPosition(convictID)
					lastSeenPos ={x=x,y=y,z=z};	
					oldConvictID = convictID; 
					searchRange =1; 
				end
					
					boolDisguised= false
					if GG.DisguiseCivilianFor then 
						for agentID, disguiseID in pairs( GG.DisguiseCivilianFor) do
							if agentID == convictID then
							boolDisguised = true
							end
						end
					end
						
						--if visible hunt him
					if boolDisguised == false then
						lastSeenPos.x,lastSeenPos.y,lastSeenPos.z = Spring.GetUnitPosition(convictID)	
						
						Command(unitID, "attack", convictID,  {"shift"})	
						-- echo("Hunting visible convict "..convictID)
					else -- circle around last known position
						searchRange = math.min(2000,searchRange + 33)
						xOffset, zOffset= math.random(0,searchRange)*randSign(),  math.random(0,searchRange)*randSign()
						
						if math.random(0,100) > 85 then -- a little suspense now and then
							lastSeenPos.x,lastSeenPos.y,lastSeenPos.z = Spring.GetUnitPosition(convictID)
						end
						
						targetCopy= lastSeenPos
						targetCopy.x, targetCopy.z = targetCopy.x + xOffset,targetCopy.z + zOffset,

						Command(unitID, "go",  {x=targetCopy.x, y= targetCopy.y, z= target.z}, {})

					-- echo("Hunting hidden convict "..convictID)						
					end
				
					
			Sleep(500)	
			end
		end
		
		searchRange = math.min(4000,searchRange + 33)
		xOffset, zOffset= math.random(0,searchRange)*randSign(),  math.random(0,searchRange)*randSign()
		
		targetCopy= lastSeenPos
		if math.random(0,100) > 50 then
			ed = getNearestGroundEnemy(unitID, UnitDefs)
			if ed then
				targetCopy= getUnitPositionV(ed)
			end
		end
		
		targetCopy.x, targetCopy.z = targetCopy.x + xOffset,targetCopy.z + zOffset,

		Command(unitID, "go", {x=targetCopy.x, y= targetCopy.y, z= targetCopy.z},  {})	
		echo("Patrollin officer "..unitID)	
		Sleep(8000)
	end
end


function delayedSirens()
	sleeptime= math.random(1,10)
	Sleep(sleeptime*1000)
	for i=1,3 do
		StartThread( PieceLight, unitID, TablesOfPiecesGroups["LightEmit"][i], "policelight",1000)
		Sleep(350)
	end
	seconds = 35
	framesPerSecond=30
	startFrame = Spring.GetGameFrame()
	while true do
		sirenDice=math.random(1,GameConfig.maxSirenSoundFiles)
		loudness = math.max(0,math.sin(((((Spring.GetGameFrame()-startFrame)/framesPerSecond)%seconds)/seconds)*2*math.pi))
		if boolLoudnessOverrideActive == true then loudness = 1.0 end
		StartThread(PlaySoundByUnitDefID, myDefID, "sounds/civilian/police/siren"..sirenDice..".ogg", 0.9,50, 2)
		Sleep(50*1000)	
	end
end
boolLoudnessOverrideActive = false
function loudnessOverride()
	Signal(SIG_LOUDNESOVERRIDE)
	SetSignalMask(SIG_LOUDNESOVERRIDE)
	boolLoudnessOverrideActive = true
	Sleep(30000)

	boolLoudnessOverrideActive = false
end

function script.HitByWeapon(x, z, weaponDefID, damage)
StartThread(loudnessOverride)
return damage
end
function script.Killed(recentDamage, _)
	if doesUnitExistAlive(loadOutUnitID) then Spring.DestroyUnit(loadOutUnitID,true,true) end

    return 1
end



function script.StartMoving()
	spinT(TablesOfPiecesGroups["wheel"], x_axis,  -160, 0.3 )
end

function script.StopMoving()
	stopSpinT(TablesOfPiecesGroups["wheel"], x_axis, 3)	
end

function script.Activate()
    return 1
end

function script.Deactivate()
    return 0
end

--- -aimining & fire weapon
function script.AimFromWeapon1()
    return center
end

function script.QueryWeapon1()
    return center
end

function script.AimWeapon1(Heading, pitch)
    return true
end

function script.FireWeapon1()
    return true
end
