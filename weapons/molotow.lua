local weaponName = "molotow" --this is the actually maschinegune of the inferno trooper
local weaponDef = {
	name = "molotow cocktail",
	weaponType = [[Cannon]],
	--damage
	damage = {
		default = 50,
		heavyarmor = 75,
	},
	areaOfEffect = 50,
	craterMult = 1,
	impulseFactor = 3.0,
	model = "placeholder.s3o",-- "molotow.dae"
	--physics
	
	weaponVelocity = 50,
	reloadtime = 50.42,
	range = 200,
	sprayAngle = 6000,
	accuracy = 0.2,
	tolerance = 5000,
	lineOfSight = false,
	groundbounce = false,
	WaterBounce = false,
	flighttime = 20,

	soundtrigger = 1,
	--apperance
	
	size = 1,
	highTrajectory = 1,
	craterBoost = 3,
	cylinderTargeting = 17.0,
	edgeEffectiveness = 0.2,
	fireStarter = 100,

	
	myGravity = 1,
	targetBorder = 0,
	
	--targeting
	collideFriendly = false,
	avoidGround = false,
	avoidFeature  = false,
	avoidNeutral =false,
	collideEnemy  = true,
	collideFirebase  = false,
	collideFeature  = false,
	collideNeutral = true,
	collideGround  = true,
	turret = true,
	canAttackGround  = true,
	proximityPriority = -1,
}

return lowerkeys({ [weaponName] = weaponDef })