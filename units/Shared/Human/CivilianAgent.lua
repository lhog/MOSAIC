local CivilianAgent = Human:New{
	corpse					  = "",
	maxDamage         	  = 500,
	mass                = 500,
	buildCostEnergy    	  = 5,
	buildCostMetal     	  = 5,
	canMove					  = true,
	
	explodeAs				  = "none",
	Acceleration = 0.4,
	BrakeRate = 0.3,
	TurnRate = 900,
	MaxVelocity = 4.5*0.35,
	

	CanAttack = false,
	CanGuard = true,

	CanMove = true,
	CanPatrol = true,
	CanStop = true,
	script 					= "civilianagentscript.lua",
	objectName        	= "human_placeholder.s3o",


	canCloak =true,
	cloakCost=0.0001,
	cloakCostMoving =0.0001,
	minCloakDistance = 15,
	onoffable=true,
	
	
	
	
	customparams = {
		helptext		= "Civilian Building",
		baseclass		= "Human", -- TODO: hacks
    },
}


return lowerkeys({
	--Temp
	["civilianagent"] = CivilianAgent:New(),
	
})