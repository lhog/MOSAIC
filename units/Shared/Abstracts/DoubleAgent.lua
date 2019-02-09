local DoubleAgent = Abstract:New{
	corpse					  = "",
	maxDamage         	  = 500,
	mass                = 500,
	buildCostEnergy    	  = 5,
	buildCostMetal     	  = 5,
	canMove					  = true,
	
	explodeAs				  = "none",
	Acceleration = 0,
	BrakeRate = 0,
	TurnRate = 0,
	MaxVelocity = 0,
	--
	description = "Activate to turn sides",

	CanAttack = false,
	CanGuard = false,

	CanMove = true,
	CanPatrol = true,
	CanStop = true,
	script 					= "doubleagentscript.lua",
	objectName        	= "doubleagent.s3o",

	canCloak =true,
	cloakCost=0.0001,
	ActivateWhenBuilt=1,
	cloakCostMoving =0.0001,
	minCloakDistance = 0,
	onoffable=true,
	initCloaked = true,
	decloakOnFire = true,
	cloakTimeout = 5,
	
	onoffable=true,
	activatewhenbuilt = true,
	
	
	
	customparams = {
		helptext		= "Civilian Agent working for the opposite site",
		baseclass		= "Human", -- TODO: hacks
    },
	category = "NOTARGET",
}


return lowerkeys({
	--Temp
	["doubleagent"] = DoubleAgent:New(),
	
})