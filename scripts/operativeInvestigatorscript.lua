
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"
include "lib_mosaic.lua"

TablesOfPiecesGroups = {}

function script.HitByWeapon(x, z, weaponDefID, damage)
end

center = piece "center"
Pistol = piece "Pistol"

GameConfig = getGameConfig()
local civilianWalkingTypeTable = getCultureUnitModelTypes(GameConfig.instance.culture, "civilian", UnitDefs)

if not GG.OperativesDiscovered then  GG.OperativesDiscovered={} end

function script.Create()
	makeWeaponsTable()
	GG.OperativesDiscovered[unitID] = nil

    -- generatepiecesTableAndArrayCode(unitID)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)
	StartThread(cloakLoop)
	StartThread(raidReactor)
end


function script.Killed(recentDamage, _)
	if doesUnitExistAlive(civilianID) == true then
		Spring.DestroyUnit(civilianID,true,true) 
	end
   return 1
end


function script.StartMoving()
end

function script.StopMoving()
end

local civilianID 


function spawnDecoyCivilian()
--spawnDecoyCivilian
		Sleep(10)	

		x,y,z= Spring.GetUnitPosition(unitID)
		civilianID = Spring.CreateUnit(randT(civilianWalkingTypeTable) , x + randSign()*5 , y, z+ randSign()*5 , 1, Spring.GetGaiaTeamID())
		transferUnitStatusToUnit(unitID,civilianID)
		Spring.SetUnitNoSelect(civilianID, true)
		Spring.SetUnitAlwaysVisible(civilianID, true)

			persPack = {myID= civilianID, syncedID= unitID, startFrame = Spring.GetGameFrame()+1 }
			GG.DisguiseCivilianFor[civilianID]= unitID
			GG.DiedPeacefully[civilianID] = false
			
			if civilianID then
				GG.EventStream:CreateEvent(
				syncDecoyToAgent,
				persPack,
				Spring.GetGameFrame()+1
				)

			end

	return 0
end


boolCloaked = false
Icon = piece("Icon")
function cloakLoop()
	local spGetUnitIsActive = Spring.GetUnitIsActive
	local boolIsCurrentlyActive= spGetUnitIsActive(unitID)
	Sleep(100)
	waitTillComplete(unitID)

	Sleep(100)

	
	while true do 
	
		boolIsCurrentlyActive = spGetUnitIsActive(unitID)
		if boolCloaked == false and boolIsCurrentlyActive == true  and not  GG.OperativesDiscovered[unitID]  then
			setSpeedEnv(unitID, 0.35)
			SetUnitValue(COB.WANT_CLOAK, 1)
			Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {0}, {}) 
			boolCloaked=true
			StartThread(spawnDecoyCivilian)
		end
		Sleep(100)
		if (boolIsCurrentlyActive == true and  GG.OperativesDiscovered[unitID] ) or  
		 (boolIsCurrentlyActive == false and boolCloaked == true )then
	
			setSpeedEnv(unitID, 1.0)
			SetUnitValue(COB.WANT_CLOAK, 0)
			Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {1}, {}) 
			boolCloaked= false
			if civilianID and doesUnitExistAlive(civilianID) == true then
				GG.DiedPeacefully[civilianID] = true
				Spring.DestroyUnit(civilianID, true, true)
			end
		end
		

		Sleep(100)
	end
end


function script.Activate()
	return 1
  
end

function script.Deactivate()
    return 0
end




function script.QueryBuildInfo()
    return center
end


function script.StopBuilding()

	SetUnitValue(COB.INBUILDSTANCE, 0)
end


function script.StartBuilding(heading, pitch)
	SetUnitValue(COB.INBUILDSTANCE, 1)
end



Spring.SetUnitNanoPieces(unitID, { Pistol })
GameConfig = getGameConfig()
 raidDownTime = GameConfig.agentConfig.raidWeaponDownTimeInSeconds * 1000
local raidComRange = GameConfig.agentConfig.raidComRange
myRaidDownTime = raidDownTime
local scanSatDefID = UnitDefNames["satellitescan"].id
local raidBonusFactorSatellite=  GameConfig.agentConfig.raidBonusFactorSatellite

function raidReactor()
	myTeam = Spring.GetUnitTeam(unitID)
	while true do
		Sleep(100)
		boolComSatelliteNearby= false
		process(getAllNearUnit(unitID, raidComRange),
				function (id)
					if myTeam == Spring.GetUnitTeam(id) and Spring.GetUnitDefID(id) == scanSatDefID then
						myRaidDownTime= math.max( -100, myRaidDownTime - 100* raidBonusFactorSatellite)
						boolComSatelliteNearby = true
					end				
				end
				)

		myRaidDownTime= math.max( -100, myRaidDownTime - 100)

	end
end

function raidReloadComplete()
	return myRaidDownTime < 0
end


function raidAimFunction(weaponID, heading, pitch)
return raidReloadComplete()
end

function pistolAimFunction(weaponID, heading, pitch)
return true
end

function gunAimFunction(weaponID, heading, pitch)
return boolCloaked
end

function raidFireFunction(weaponID, heading, pitch)
Spring.Echo("raidAimFunction")
boolRecharge = raidDownTime
return true
end
Shell1 = piece("Shell1")
function pistolFireFunction(weaponID, heading, pitch)
	Explode(Shell1, SFX.FALL + SFX.NO_HEATCLOUD)
	Spring.Echo("pistolFireFunction")
	return true
end



SIG_RAID = 1
SIG_PISTOL = 2
SIG_GUN = 4

WeaponsTable = {}
function makeWeaponsTable()
    WeaponsTable[1] = { aimpiece = Pistol, emitpiece = Pistol, aimfunc = raidAimFunction, firefunc = raidFireFunction, signal = SIG_RAID }
    WeaponsTable[2] = { aimpiece = Pistol, emitpiece = Pistol, aimfunc = pistolAimFunction, firefunc = pistolFireFunction, signal = SIG_PISTOL}
end


function turretReseter()
    while true do
        Sleep(1000)
        for i = 1, #WeaponsTable do
			if WeaponsTable[i].coolDownTimer then
				if WeaponsTable[i].coolDownTimer > 0 then
					WeaponsTable[i].coolDownTimer = math.max(WeaponsTable[i].coolDownTimer - 1000, 0)

				elseif WeaponsTable[i].coolDownTimer <= 0 then
					tP(WeaponsTable[i].emitpiece, -90, 0, 0, 0)
					WeaponsTable[i].coolDownTimer = -1
				end
			end
        end
    end
end

function script.AimFromWeapon(weaponID)
    if WeaponsTable[weaponID] then
        return WeaponsTable[weaponID].aimpiece
    else
        return center
    end
end

function script.QueryWeapon(weaponID)
    if WeaponsTable[weaponID] then
        return WeaponsTable[weaponID].emitpiece
    else
        return center
    end
end



function script.AimWeapon(weaponID, heading, pitch)
    if WeaponsTable[weaponID] then
        if WeaponsTable[weaponID].aimfunc then
            return WeaponsTable[weaponID].aimfunc(weaponID, heading, pitch)
        else
            WTurn(WeaponsTable[weaponID].aimpiece, y_axis, heading, turretSpeed)
            WTurn(WeaponsTable[weaponID].aimpiece, x_axis, -pitch, turretSpeed)
            return true
        end
    end
    return false
end

boolLocalCloaked = false
function showHideIcon(boolCloaked)
    boolLocalCloaked = boolCloaked
    if  boolCloaked == true then
        hideAll(unitID)
        Show(Icon)
    else
        showAll(unitID)
        Hide(Icon)
    end
end
