	Spring.Echo("script.Create-Operative")
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"
include "lib_mosaic.lua"

TablesOfPiecesGroups = {}

function script.HitByWeapon(x, z, weaponDefID, damage)
end

center = piece "center"


if not GG.OperativesDiscovered then  GG.OperativesDiscovered={} end

function script.Create()

	GG.OperativesDiscovered[unitID] = nil

    -- generatepiecesTableAndArrayCode(unitID)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)

end


function script.Killed(recentDamage, _)
	if doesUnitExistAlive(civilianID) == true then
		Spring.DestroyUnit(civilianID,true,true) 
	end
   return 1
end


--- -aimining & fire weapon
function script.AimFromWeapon1()
    return center
end



function script.QueryWeapon1()
    return center
end

function script.AimWeapon1(Heading, pitch)
    --aiming animation: instantly turn the gun towards the enemy

    return true
end


function script.FireWeapon1()

    return true
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
		civilianID = Spring.CreateUnit("civilian" , x + 5 , y, z , 1, Spring.GetGaiaTeamID())
		transferUnitStatusToUnit(unitID,civilianID)
		Spring.SetUnitNoSelect(civilianID, true)
		Spring.SetUnitAlwaysVisible(civilianID, true)
	

			persPack = {myID= civilianID, syncedID= unitID, startFrame = Spring.GetGameFrame()+1 }
			
			
			if civilianID then
				GG.EventStream:CreateEvent(
				syncDecoyToAgent,
				persPack,
				Spring.GetGameFrame()+1
				)

			end

	return 0
end

function script.Activate()
	setSpeedEnv(unitID, 0.35)
	Spring.Echo("Activate "..unitID)
	if not GG.OperativesDiscovered[unitID] then
        SetUnitValue(COB.WANT_CLOAK, 1)
		  Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {0}, {}) 
		  StartThread(spawnDecoyCivilian)
		  return 1
   else
		Spring.Echo("Operative ".. unitID.." is discovered")
			return 0
   end
  
end

function script.Deactivate()
	setSpeedEnv(unitID, 1.0)
	Spring.Echo("Deactivate "..unitID)
		SetUnitValue(COB.WANT_CLOAK, 0)
		Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {2}, {}) 
		if civilianID and doesUnitExistAlive(civilianID) == true then
			Spring.DestroyUnit(civilianID, true, true)
		end
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



Spring.SetUnitNanoPieces(unitID, { center })

