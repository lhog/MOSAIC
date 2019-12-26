local AntiSat = Satellite:New{
	name = "Anti Satellite  Satellite",
	Description = "Destroys other satellites ",

	corpse						= "",
	maxDamage          		= 500,
	mass              	= 500,
	buildCostEnergy    		= 5,
	buildCostMetal      		= 5,
	explodeAs					= "none",
	maxVelocity					= 7.15, --14.3, --86kph/20
	acceleration   		 	= 1.7,
	brakeRate      		 	= 0.1,
	turninplace					= true,
	
	footprintX 					= 1,
	footprintZ 					= 1,
	script 						= "satelliteantitscript.lua",
	objectName        		= "satellite.s3o",

	customparams = {
		helptext		= "Observationsatellite",
		baseclass		= "Satellite", -- TODO: hacks
    },
		category = [[ORBIT]],
		
	weapons = {
		[1]={name  = "noonelaser",
			onlyTargetCategory = [[ORBIT]],
			},
					
		},
}

return lowerkeys({
	--Temp
	["satelliteanti"] = AntiSat:New(),
	
})