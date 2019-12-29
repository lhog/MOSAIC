function gadget:GetInfo()
	return {
		name = "Aersoldrones Gadget",
		desc = "Keeps Track of Aerosoldrones ",
		author = "Picasso",
		date = "3rd of May 2010",
		license = "GPL3",
		layer = 4,
		version = 1,
		enabled = true
	}
end

if (not gadgetHandler:IsSyncedCode()) then
    return false
end

	VFS.Include("scripts/lib_OS.lua")
	VFS.Include("scripts/lib_UnitScript.lua")
	VFS.Include("scripts/lib_Animation.lua")
	VFS.Include("scripts/lib_Build.lua")
	VFS.Include("scripts/lib_mosaic.lua")
	
	local GameConfig = getGameConfig()
	
	aeroSolDroneDefIDs = getAerosolUnitDefIDs(getUnitDefNames(UnitDefs))	
	
	aeroSolUnits = {}
	
function gadget:UnitCreated(unitID, unitDefID)
	if aeroSolDroneDefIDs[unitDefID] then
		aeroSolUnits[unitID] = unitDefID
	end
end

function gadget:UnitDestroyed(unitID)
	if aeroSolUnits[unitID] then aeroSolUnits[unitID] = nil end
end

function gadget:Initialize()
	if not GG.SelectedAerosol then GG.SelectedAerosol = {} end
end

aerosolAffectableUnits= getAersolAffectableUnits()

function gadget:GameFrame(n)

	if n > 1 and n % 33 == 1 then
		for unitID, unitDefID in pairs(aeroSolUnits) do
			if unitID and unitDefID and isUnitActive(unitID) == true then
					aerosolTypeOfUnit  = aeroSolDroneDefIDs[unitDefID]
				
					
					-- if unit is activate 
					-- if getUnitValueEnv(unitID, "ACTIVATION") == 1 then
					if Spring.GetUnitActive(unitID) == true then
						T = getAllNearUnit(unitID, GameConfig.aerosolDistance)
						affectedUnits = process(T,
								function(id)
									if aerosolAffectableUnits[Spring.GetUnitDefID(id)] and not GG.AerosolAffectedCivilians[id] then
										if not GG.AerosolAffectedCivilians then GG.AerosolAffectedCivilians = {} end
										
										--if unit is not already affected by aerosolDistance
										if not GG.AerosolAffectedCivilians[id] thn
											Spring.Echo("Unit ".. id.." is now under the influence of "..aerosolTypeOfUnit)
											setCivilianBehaviourMode(id, true, aerosolTypeOfUnit)
											if not GG.AerosolAffectedCivilians then GG.AerosolAffectedCivilians = {} end
											GG.AerosolAffectedCivilians[id] = aerosolTypeOfUnit 
											return id
										end
									end
								end
								)
					end
			end
		end
	end
end

