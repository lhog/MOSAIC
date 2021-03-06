--- http://springrts.com/wiki/Weapon_Variables#Cannon_.28Plasma.29_Visuals
local weaponName = "cruise_missiles" --this is the actually maschinegune of the inferno trooper
local weaponDef = {
    name = "Cruise Missile",
    weaponType = [[MissileLauncher]],

    damage = {
        default = 1500
    },
	
	range = 16635,
	impulseBoost  = 0,
	impulseFactor = 0.4,
	reloadtime = 100,
    areaOfEffect = 256,
	noSelfDamage = true,
	trajectoryHeight = 15 ,
	-- fixedLauncher = true, 
	avoidFeature = false,
	avoidGround = true,
	smokeTrail = true,
	startVelocity  = 380,
	weaponAcceleration = 100,
	turnRate = 4*182, --degrees per second
	weaponVelocity = 1950,
	tracks = true,
	flightTime = 25 ,
	-- uselos = false,
	canAttackGround = true,
	turret = false,
	explosionScar = true, 
    explosionGenerator = "custom:missile_explosion",
	fireStarter  = 50.0,
	cameraShake =1.0
	
    }	
	
local CruiseMissiles ={}

local Missile = weaponDef
Missile.model = "cm_airstrike_proj.dae"
Missile.name = "cruisemissile airstrike | airssied droplets"
CruiseMissiles["cm_airstrike"] = Missile

local Missile = weaponDef
Missile.model = "cm_walker_proj.dae"
Missile.name = "cruise missile walkerdrop"
CruiseMissiles["cm_walker"] = Missile

local Missile = weaponDef
Missile.model = "cm_antiarmor_proj.dae"
Missile.name = "cruisemissile antiarmour"
CruiseMissiles["cm_antiarmor"] = Missile

local Missile = weaponDef
Missile.model = "cm_turret_ssied_proj.dae"
Missile.name = "cruisemissile ssied | turret drop"
CruiseMissiles["cm_turret_ssied"] = Missile

return lowerkeys( CruiseMissiles )