local AntiSat = Satellite:New{
	name = "Spacecraft  Destroyer",
	Description = "Destroys other satellites ",
	isFirePlatform 				= true,
	corpse						= "",
	transportSize				= 1024  ,
	transportCapacity 			= 18,
	maxDamage          			= 500,
	mass              			= 500,
	buildCostEnergy    			= 5,
	buildCostMetal      		= 5,
	explodeAs					= "none",
	maxVelocity					= 7.15, --14.3, --86kph/20
	acceleration   		 		= 1.7,
	brakeRate      		 		= 0.01,
	turninplace					= true,
	canattack					= true,
	sightDistance 				= 320,
	footprintX 					= 1,
	footprintZ 					= 1,
	noAutoFire                	= false,
	script 						= "satelliteantiscript.lua",
	objectName        			= "satellite.s3o",
	usePieceCollisionVolumes 	= true,
	
	customparams = {
		helptext		= "Anti-Satellite Satellite",
		baseclass		= "Satellite", -- TODO: hacks
    },
		category = [[ORBIT]],
		

	
	

}

return lowerkeys({
	--Temp
	["satelliteanti"] = AntiSat:New(),
	
})