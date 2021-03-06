function gadget:GetInfo()
        return {
                name                    = "CruiseMissile Management",
                desc                    = "SetProjectileTarget etc",
                author          		= "knorke",
                date                    = "Mar 2014",
                license  				= "later horses dont be mean.",
                layer            		= 0,
                enabled  = true, --      loaded by default?
        }
end

if (not gadgetHandler:IsSyncedCode()) then return end

VFS.Include("scripts/lib_OS.lua")
VFS.Include("scripts/lib_UnitScript.lua")
VFS.Include("scripts/lib_Animation.lua")
VFS.Include("scripts/lib_Build.lua")
VFS.Include("scripts/lib_mosaic.lua")
GameConfig = getGameConfig()

local cruiseMissileWeapons = {}
cruiseMissileWeapons[WeaponDefNames["cm_airstrike"].id] = true
cruiseMissileWeapons[WeaponDefNames["cm_walker"].id] = true
cruiseMissileWeapons[WeaponDefNames["cm_antiarmor"].id] = true
cruiseMissileWeapons[WeaponDefNames["cm_turret_ssied"].id] = true

local redirectProjectiles = {}  -- [frame][projectileID] = table with .targetType .targetX .targetY .targetZ .targetID

function gadget:Initialize()
	for id, boolActive in pairs(cruiseMissileWeapons) do
		Script.SetWatchWeapon (id, true)
	end
end

 
 function gadget:GameFrame (frame)
	-- if frame%60==0 then Spring.Echo ("projectile_test.lua"..frame) end

	if redirectProjectiles[frame] then
		for projectileID,_ in pairs (redirectProjectiles[frame]) do
			if (Spring.GetProjectileType (projectileID)) then
				setTargetTable (projectileID, redirectProjectiles[frame][projectileID])		
			end
		end
	redirectProjectiles[frame] = nil
	end
end
 



 function gadget:ProjectileCreated(proID, proOwnerID, proWeaponDefID)
	if (cruiseMissileWeapons [proWeaponDefID] or cruiseMissileWeapons[Spring.GetProjectileDefID(proID)]) then
		local originalTarget = getTargetTable (proID)
		local tx,ty,tz = getProjectileTargetXYZ (proID)
		local x,y,z = Spring.GetUnitPosition (proOwnerID)		
		local resolution = 20
		local preCog = 3
		
		for i= 1, resolution, 1 do
			
			rx,  rz = mix(tx, x, resolution/i), mix(tz, z, resolution/i)
			
			interpolate_Y = 0
			for add= 0, preCog, 1 do
				it = math.max(0, math.min(resolution, i+add))
				ix, iz =  mix(tx, x, resolution/it), mix(tz, z, resolution/it)
				interpolate_Y =  math.max(Spring.GetSmoothMeshHeight(ix,iz),interpolate_Y)
			end
			
			addProjectileRedirect (proID, rx, interpolate_Y + GameConfig.CruiseMissilesHeightOverGround , rz)
		end
		
		addProjectileRedirect (proID, tx, ty + GameConfig.CruiseMissilesHeightOverGround, tz)		
		
		return true
	end
end


function getProjectileTargetXYZ (proID)
	local targetTypeInt, target  = Spring.GetProjectileTarget (proID)
	if targetTypeInt == string.byte('g') then
		return target[1],target[2],target[3]
	end
	if targetTypeInt == string.byte('u') then
		return Spring.GetUnitPosition (target)
	end
	if targetTypeInt == string.byte('f') then
		return Spring.GetFeaturePosition (target)
	end
	if targetTypeInt == string.byte('p') then
		return Spring.GetProjectilePosition (target)
	end
end

function addProjectileRedirect (proID, targetTable, delay)
	local f = Spring.GetGameFrame() + delay
	if not redirectProjectiles[f] then redirectProjectiles[f] = {} end
	redirectProjectiles[f][proID] = targetTable
end

function makeTargetTable (x,y,z)
	return {targetType = string.byte('g'), targetX=x,targetY=y,targetZ=z}
end

function getTargetTable (proID)
	local targetTable = {}
	local targetTypeInt, target  = Spring.GetProjectileTarget (proID)
	if targetTypeInt == string.byte('g') then 	--target is position on ground
		targetTable = {targetType = targetTypeInt, targetX=target[1],targetY=target[2],targetZ=target[3],}	
	else 										--target is unit,feature or projectile
		targetTable = {targetType = targetTypeInt, targetID=target,}		
	end
	return targetTable
end

function setTargetTable (proID, targetTable)	
	if targetTable.targetType == string.byte('g') then
		Spring.SetProjectileTarget (proID, targetTable.targetX, targetTable.targetY, targetTable.targetZ)
	else
		Spring.SetProjectileTarget (proID, targetTable.targetID, targetTable.targetType)		
	end
end