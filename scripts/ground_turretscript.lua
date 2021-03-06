include "createCorpse.lua"
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"

TablesOfPiecesGroups = {}

function script.HitByWeapon(x, z, weaponDefID, damage)
end

center = piece "center"
Turret = piece "Turret"
aimpiece = piece "aimpiece"
SIG_GUARDMODE = 1

function script.Create()
    generatepiecesTableAndArrayCode(unitID)
	resetAll(unitID)
	Hide(aimpiece)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)
	hideT(TablesOfPiecesGroups["TBase"])
	StartThread(foldControl)
	StartThread(guardSwivelTurret)

end

boolAiming = false

function guardSwivelTurret()
Signal(SIG_GUARDMODE)
SetSignalMask(SIG_GUARDMODE)
Sleep(5000)

	while true do
		if isTransported(unitID)== false then
			target = math.random(1,360)
			WTurn(center,y_axis, math.rad(target),math.pi)
			Sleep(500)
			WTurn(center,y_axis, math.rad(target),math.pi)
		end
		Sleep(500)
	end


end

function foldControl()
	Sleep(10)
	Turn(Turret,x_axis,math.rad(90),0)
	Turn(TablesOfPiecesGroups["TBase"][1],2,math.rad(-30),0)
	Turn(TablesOfPiecesGroups["TBase"][2],2,math.rad(30),0)
	Turn(TablesOfPiecesGroups["TBase"][3],2,math.rad(-30),0)
	Turn(TablesOfPiecesGroups["TBase"][4],2,math.rad(30),0)
	WTurn(Turret,x_axis,math.rad(0),math.pi)
	
	while true do
		if isTransported(unitID)== false then

			unfold()
		else
			
			fold()		
		end
	Sleep(1000)
	end


end

function unfold()	
			Sleep(100)
			WaitForTurns(TablesOfPiecesGroups["UpLeg"])	
			for i=1,2 do
				Turn(TablesOfPiecesGroups["UpLeg"][i],x_axis,math.rad(50),math.pi)
				Turn(TablesOfPiecesGroups["LowLeg"][i],x_axis,math.rad(-90),math.pi)	
			end	
			for i=3,4 do
				Turn(TablesOfPiecesGroups["UpLeg"][i],x_axis,math.rad(-50),math.pi)
				Turn(TablesOfPiecesGroups["LowLeg"][i],x_axis,math.rad(90),math.pi)	
			end
			WaitForTurns(TablesOfPiecesGroups["LowLeg"])
			WaitForTurns(TablesOfPiecesGroups["UpLeg"])
end

function fold()
			WaitForTurns(TablesOfPiecesGroups["UpLeg"])	
				for i=1,2 do
					Turn(TablesOfPiecesGroups["UpLeg"][i],x_axis,math.rad(0),math.pi)
					Turn(TablesOfPiecesGroups["LowLeg"][i],x_axis,math.rad(0),math.pi)	
				end	
				for i=3,4 do
					Turn(TablesOfPiecesGroups["UpLeg"][i],x_axis,math.rad(0),math.pi)
					Turn(TablesOfPiecesGroups["LowLeg"][i],x_axis,math.rad(0),math.pi)	
				end
			WaitForTurns(TablesOfPiecesGroups["LowLeg"])
			WaitForTurns(TablesOfPiecesGroups["UpLeg"])

end

function script.Killed(recentDamage, _)
		
    --createCorpseCUnitGeneric(recentDamage)
    return 1
end


--- -aimining & fire weapon
function script.AimFromWeapon1()
    return Turret
end



function script.QueryWeapon1()
    return Turret
end

function script.AimWeapon1(Heading, pitch)
	Signal(SIG_GUARDMODE)
    --aiming animation: instantly turn the gun towards the enemy

	Turn(center,y_axis, Heading, math.pi)
	WTurn(Turret,x_axis, -pitch, math.pi)

	
    return true
end



function script.FireWeapon1()
	StartThread(guardSwivelTurret)
    return true
end



function script.StartMoving()
end

function script.StopMoving()
end

function script.Activate()

    return 1
end

function script.Deactivate()

    return 0
end



