local House = Building:New{
	corpse					= "",
	maxDamage        	= 500,
	mass           	= 500,
	buildCostEnergy    	= 5,
	buildCostMetal    	= 5,
	explodeAs				= "none",
	name = "Housing Block",
	description = "houses civilians",
	Builder					= true,
	levelground				= true,
	FootprintX = 8,
	FootprintZ = 8,
	script 					= "Housescript.lua",
	objectName       	= "house.s3o",
	
	YardMap = 	[[hoooyyyyyyyyyyyyyyyyyyyyyyyyyooo
				   oyyyyyyyyyyyyyyyyyyyyyyyyyyyyyo
				   oyyyyyyyyyyyyyyyyyyyyyyyyyyyyyo
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
				   oyyyyyyyyyyyyyyyyyyyyyyyyyyyyyo
				   oyyyyyyyyyyyyyyyyyyyyyyyyyyyyyo
				   oooyyyyyyyyyyyyyyyyyyyyyyyyyooo]]	,
	

	customparams = {	
		helptext			= "Civilian Building",
		baseclass			= "Building", -- TODO: hacks
    },
	
	buildoptions = 
	{
	"civilian"
	},
	
	category =  [[GROUND BUILDING ARRESTABLE]],
}


return lowerkeys({
	--Temp
	["house"] = House:New(),
	
})