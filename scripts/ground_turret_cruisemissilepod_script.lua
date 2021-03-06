include "createCorpse.lua"
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"

TablesOfPiecesGroups = {}

function script.HitByWeapon(x, z, weaponDefID, damage)
end

center = piece "Pod"
PodTop = piece "PodTop"
aimpiece = piece "aimpiece"
if not aimpiece then echo("Unit of type "..UnitDefs[Spring.GetUnitDefID(unitID)].name .. " has no aimpiece") end
if not center then echo("Unit of type"..UnitDefs[Spring.GetUnitDefID(unitID)].name .. " has no center") end		
rocketPiece= aimpiece

DefIDPieceMap = {
	[UnitDefNames["ground_turret_cm_airdrop"].id	]= "cm_airstrike_fold",
	[UnitDefNames["ground_turret_cm_walker"].id		]= "cm_walker_fold",
	[UnitDefNames["ground_turret_cm_antiarmor"].id	]= "cm_AntiAmour_fold" ,
	[UnitDefNames["ground_turret_cm_ssied"].id		]= "cm_turret_ssied_fold" 
	}


function showDependantOnType()
	myDefID= Spring.GetUnitDefID(unitID)
	rocketPiece = piece(DefIDPieceMap[myDefID])
	Show(rocketPiece)

end




function script.Create()
    -- generatepiecesTableAndArrayCode(unitID)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)
	resetAll(unitID)
	hideAll(unitID)
	Show(center)
	Show(PodTop)
	showDependantOnType()

	Hide(aimpiece)

end


function script.Killed(recentDamage, _)


    return 1
end


--aimining & fire weapon
function script.AimFromWeapon1()
    return aimpiece
end



function script.QueryWeapon1()
    return aimpiece
end

function script.AimWeapon1(Heading, pitch)
	WTurn(PodTop,z_axis, math.rad(180),math.pi*3)
	WMove(rocketPiece,y_axis, 1000, 2000)
	
    return true
end


function script.FireWeapon1()
		Spring.DestroyUnit(unitID, true, false)
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

-- function script.QueryBuildInfo()
    -- return center
-- end

-- Spring.SetUnitNanoPieces(unitID, { center })

