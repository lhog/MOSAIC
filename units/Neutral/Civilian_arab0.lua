local Civil = Civilian:New{
	--This class inherits alot from its 
	name = "Civilian",
	description = " innocent bystander <colateral>",
	objectName        	= "civilian0_arab.dae",
	
	usepiececollisionvolumes = false,
	collisionVolumeType = "box",
	collisionvolumescales = "10 25 10",

	
	customparams = {
		baseclass		= "Civilian", -- TODO: hacks
    },

	
	category = [[GROUND]],
}


return lowerkeys({
	--Temp
	["civilian_arab0"] = Civil:New(),
})