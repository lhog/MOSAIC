local weaponName = "railGun"
local weaponDef = {
    name = "Rail Gun",
    alphaDecay = 0.12,
    areaOfEffect = 16,
    bouncerebound = 0.15,
    bounceslip = 1,
    burst = 2,
    burstrate = 0.4,
    cegTag = [[railGunCeg]],
    craterBoost = 0,
    craterMult = 0,
    damage = {
        default = 250,

    },
    explosionGenerator = [[custom:cRailSparks]],
    groundbounce = 1,
    impactOnly = true,
	avoidFriendly = false,
	avoidGround  = true,
	collideNeutral = false,
	collideFirebase  = false,
	collideGround = true,
	
	--command
	canAttackGround  = true,
	
    impulseBoost = 0,
    impulseFactor = 0,
    interceptedByShieldType = 0,
    tolerance = 3000,
    noExplode = true,
    numbounce = 40,
    range = 2048,
    reloadtime = 12,
    rgbColor = [[0.5 1 1]],
    separation = 0.5,
    size = 0.8,
    sizeDecay = -0.1,
    soundHit = "sounds/weapons/sniper/sniperFire.ogg",
    sprayangle = 800,
    stages = 32,
    fireStarter = 35,
    turret = true,
    waterbounce = 1,
    weaponType = [[Cannon]],
    weaponVelocity = 2400,
}

return lowerkeys({ [weaponName] = weaponDef })