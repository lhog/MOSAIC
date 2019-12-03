include "createCorpse.lua"
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"

myDefID=Spring.GetUnitDefID(unitID)
TablesOfPiecesGroups = {}
local center = piece('center');
local Feet1 = piece('Feet1');
local Feet2 = piece('Feet2');
local Head1 = piece('Head1');
local LowArm1 = piece('LowArm1');
local LowArm2 = piece('LowArm2');
local LowLeg1 = piece('LowLeg1');
local LowLeg2 = piece('LowLeg2');
local trolley = piece('trolley');
local root = piece('root');
local UpArm1 = piece('UpArm1');
local UpArm2 = piece('UpArm2');
local UpBody = piece('UpBody');
local UpLeg1 = piece('UpLeg1');
local UpLeg2 = piece('UpLeg2');
local cigarett = piece('cigarett');
local Handbag = piece('Handbag');
local SittingBaby = piece('SittingBaby');
local ak47		= piece('ak47')
local cofee = piece('cofee');
local ProtestSign = piece"ProtestSign"
local cellphone1 = piece"cellphone1"
local cellphone2 = piece"cellphone2"
local ShoppingBag = piece"ShoppingBag"

local scriptEnv = {
	Handbag = Handbag,
	trolley = trolley,
	SittingBaby = SittingBaby,
	center = center,
	Feet1 = Feet1,
	Feet2 = Feet2,
	Head1 = Head1,
	LowArm1 = LowArm1,
	LowArm2 = LowArm2,
	LowLeg1 = LowLeg1,
	LowLeg2 = LowLeg2,
	cigarett = cigarett,
	cofee = cofee,
	root = root,
	UpArm1 = UpArm1,
	UpArm2 = UpArm2,
	UpBody = UpBody,
	UpLeg1 = UpLeg1,
	UpLeg2 = UpLeg2,
	x_axis = x_axis,
	y_axis = y_axis,
	z_axis = z_axis,
}

SIG_ANIM = 1
SIG_UP = 2
SIG_LOW = 4
SIG_COVER_WALK= 8
SIG_BEHAVIOUR_STATE_MACHINE = 16
GameConfig = getGameConfig()

eAnimState = getCivilianAnimationStates()
upperBodyPieces =
{
	[Head1	]  = Head1,
	[LowArm1 ] = LowArm1,
	[LowArm2]  = LowArm2,
	[UpBody  ]	= UpBody,
	[UpArm1 ]= UpArm1,
	[UpArm2 ]= UpArm2,
	}
	
lowerBodyPieces =
{
	[center	]= center,
	[UpLeg1	]= UpLeg1,
	[UpLeg2 ]= UpLeg2,
	[LowLeg1]= LowLeg1,
	[LowLeg2]= LowLeg2,
	[Feet1 	]= Feet1,
	[Feet2	]= Feet2
}
--equipmentname: cellphone, shoppingbags, crates, baby, cigarett, food, stick, demonstrator sign, molotow cocktail



boolWalking = false
boolTurning = false
boolTurnLeft = false
boolDecoupled = false

loadMax = 8

local bodyConfig={}


	iShoppingConfig =  math.floor(math.random(1,8))

function script.Create()
    Move(root,y_axis, -3,0)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)
	StartThread(turnDetector)
	


	bodyConfig.boolShoppingLoaded = (iShoppingConfig == 1)
	bodyConfig.boolCarrysBaby =( iShoppingConfig == 2)
	bodyConfig.boolTrolley = (iShoppingConfig == 3)
	bodyConfig.boolHandbag =( iShoppingConfig == 4)
	bodyConfig.boolLoaded = ( iShoppingConfig <  5)
	bodyConfig.boolArmed = false
	bodyConfig.boolWounded = false
	bodyConfig.boolInfluenced = false
	bodyConfig.boolCoverWalk = false
	
	bodyBuild()


	setupAnimation()

	setOverrideAnimationState( eAnimState.slaved, eAnimState.standing,  true, nil, false)

	StartThread(threadStarter)

	-- StartThread(testAnimationLoop)
end

function testAnimationLoop()
	Sleep(500)
	while true do
	
		-- makeProtestSign(8, 3, 34, 62, signMessages[math.random(1,#signMessages)], "RAPHI")
		-- Show(TablesOfPiecesGroups["cellphone"][1])
		-- Show(cigarett)
		Show(ShoppingBag)
		-- Show(Handbag)
		-- Show(cofee)
		Show(SittingBaby)
		-- Show(ak47)
		
		PlayAnimation("UPBODY_LOADED", nil, 1.0)
	
		Sleep(100)
	end
end

function bodyBuild()



	hideAll(unitID)
	Show(UpBody)
	Show(center)
	showT(TablesOfPiecesGroups["UpLeg"])
	showT(TablesOfPiecesGroups["LowLeg"])
	showT(TablesOfPiecesGroups["LowArm"])
	showT(TablesOfPiecesGroups["UpArm"])
	showT(TablesOfPiecesGroups["Head"])
	showT(TablesOfPiecesGroups["Feet"])
	
	if bodyConfig.boolArmed == true  then
		Show(ak47)	
		return
	end
	
	if bodyConfig.boolLoaded == true  and bodyConfig.boolWounded == false then
	
		if iShoppingConfig == 1 then
			Show(ShoppingBag);return
		end
		
		if iShoppingConfig == 2 then
			Show(SittingBaby);return
		end
		
		if iShoppingConfig == 3 then
			Show(trolley);return
		end
		
		if iShoppingConfig == 4 then
			Show(Handbag);return
		end
	end
end

function script.Killed(recentDamage, _)

 --   createCorpseCUnitGeneric(recentDamage)
    return 1
end

--- -aimining & fire weapon
function script.AimFromWeapon1()
    return center
end

function script.QueryWeapon1()
    return center
end

function script.AimWeapon1(Heading, pitch)
    --aiming animation: instantly turn the gun towards the enemy

    return true
end

function script.FireWeapon1()

    return true
end
---------------------------------------------------------------------ANIMATIONLIB-------------------------------------
deg_90 = math.pi/2
deg_45 = math.pi/4

Animations = {
["UPBODY_PROTEST"] =  {
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.021178, ['s']=0.070484},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.001579, ['s']=0.001893},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.048496, ['s']=0.378781},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.068032,r=deg_45, ['s']=1.053315},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.415644, r=deg_45,['s']=0.066133},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.075009,r=deg_45, ['s']=0.417566},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.041625, ['s']=0.114315},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.237889, ['s']=0.475778},
		}
	},
	{
		['time'] = 2,
		['commands'] = {
	
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-deg_90, ['s']=0.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-deg_90, ['s']=0.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']= deg_90, ['s']=0.837582},
			
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0, ['s']=0.366700},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-deg_90 - deg_45, ['s']=0.82062},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0, ['s']=0.319189},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-1.183930, r=deg_45,['s']=0.111408},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.910735, r=deg_45,['s']=0.736785},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-1.665229, r=deg_45,['s']=0.255216},
			{['c']='turn',['p']=ProtestSign, ['a']=x_axis, ['t']=0.056186, ['s']=0.496796},
			{['c']='turn',['p']=ProtestSign, ['a']=y_axis, ['t']= -math.pi, ['s']=3.24313},
			{['c']='turn',['p']=ProtestSign, ['a']=z_axis, ['t']=0.055234, ['s']=0.500869},

		}
	},
	{
		['time'] = 9,
		['commands'] = {
			{['c']='turn',['p']=ProtestSign, ['a']=x_axis, ['t']=0.100448, ['s']=0.028867},
			{['c']='turn',['p']=ProtestSign, ['a']=y_axis, ['t']= -math.pi, ['s']=3.1626},
			{['c']='turn',['p']=ProtestSign, ['a']=z_axis, ['t']=0.096349, ['s']=0.026814},
		}
	},
	{
		['time'] = 10,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.000418, ['s']=0.064788},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.008744, ['s']=0.021496},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.181563, ['s']=0.399200},
		}
	},
	{
		['time'] = 12,
		['commands'] = {

		}
	},
	{
		['time'] = 13,
		['commands'] = {

		}
	},
	{
		['time'] = 16,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.074899, ['s']=0.158897},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.072075, ['s']=0.422678},
		}
	},
	{
		['time'] = 20,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.021228, ['s']=0.108229},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.009685, ['s']=0.004703},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.134532, ['s']=0.235154},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-0.512093, ['s']=0.839797},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.761485, ['s']=2.090275},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-0.480960, ['s']=1.480337},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.840463, ['s']=0.643693},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.367146, ['s']=0.040415},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.381224, ['s']=0.255179},
		}
	},
	{
		['time'] = 26,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.121386, ['s']=0.713068},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.005533, ['s']=0.020760},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.036988, ['s']=0.487717},
		}
	},
	{
		['time'] = 32,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.000019, ['s']=0.364098},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.012285, ['s']=0.020257},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.074651, ['s']=0.334918},
		}
	},
	{
		['time'] = 38,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.015532, ['s']=0.084811},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.102965},
		}
	},
	{
		['time'] = 42,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.058376, ['s']=0.291785},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.011177, ['s']=0.005542},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.071703, ['s']=0.014742},
		}
	},
	{
		['time'] = 47,
		['commands'] = {
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-1.105945, ['s']=1.484630},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.394986, ['s']=2.891177},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-1.486578, ['s']=2.514046},
		}
	},
	{
		['time'] = 48,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.000033, ['s']=0.159298},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.001011, ['s']=0.027724},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.065138, ['s']=0.017903},
		}
	},
	{
		['time'] = 49,
		['commands'] = {
		}
	},
	{
		['time'] = 55,
		['commands'] = {
			{['c']='turn',['p']=ProtestSign, ['a']=x_axis, ['t']=0.172105, ['s']=0.537422},
			{['c']='turn',['p']=ProtestSign, ['a']=y_axis, ['t']= -math.pi, ['s']=5.23848},
			{['c']='turn',['p']=ProtestSign, ['a']=z_axis, ['t']=0.172103, ['s']=0.568157},
		}
	},
	{
		['time'] = 59,
		['commands'] = {
		}
	},
},
["UPBODY_HANDSUP"]={
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=3.714181 *-1, ['s']=0.535925},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.296218 , ['s']=0.141328},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.991118*-1, ['s']=1.085806},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-2.664833 *-1, ['s']=0.735825},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.550202 , ['s']=0.323870},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-1.537796*-1, ['s']=0.899105},
			
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.798368 *-1, ['s']=0.021825},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.453922, ['s']=1.324240},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.698181*-1, ['s']=2.222537},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.831275 *-1, ['s']=1.115186},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=-0.091092, ['s']=1.326423},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.569845*-1, ['s']=1.113761},
		}
	}
},

["UPBODY_WAILING2"]={
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.286658, ['s']=0.419503},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=3.053207 *-1, ['s']=0.901329},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.470522, ['s']=0.237688},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.651957, ['s']=1.826128},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-3.572351 *-1, ['s']=1.237524},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.150762 , ['s']=0.544691},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-0.428901*-1, ['s']=1.512130},
			
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.812190 *-1, ['s']=0.032595},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=1.292607 , ['s']=1.489154},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=-0.709426 *-1, ['s']=0.398408},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0.544122 *-1, ['s']=1.875540},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=-1.727014 , ['s']=2.230803},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.803794*-1, ['s']=1.873144},
			
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.092147, ['s']=0.703434},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 12,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.271322, ['s']=0.046010},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 15,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.053908, ['s']=0.156487},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 22,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.212876, ['s']=0.146113},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=3.714181 *-1, ['s']=0.535925},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.296218 , ['s']=0.141328},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.991118*-1, ['s']=1.085806},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-2.664833 *-1, ['s']=0.735825},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.550202 , ['s']=0.323870},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-1.537796*-1, ['s']=0.899105},
			
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.798368 *-1, ['s']=0.021825},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.453922, ['s']=1.324240},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.698181*-1, ['s']=2.222537},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.831275 *-1, ['s']=1.115186},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=-0.091092, ['s']=1.326423},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.569845*-1, ['s']=1.113761},
		}
	},
	{
		['time'] = 34,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.376503, ['s']=0.409066},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 42,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.836093 *-1, ['s']=0.062875},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.200561, ['s']=0.422268},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=-0.417260*-1, ['s']=1.859068},
		}
	},
	{
		['time'] = 43,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.236123, ['s']=0.321555},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 46,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.067814, ['s']=1.028962},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 55,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.132841, ['s']=0.390158},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},
},
["UPBODY_WAILING1"]={
{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.286658, ['s']=0.680578},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.092147, ['s']=0.703434},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 2,
		['commands'] = {
	
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-deg_90,				 	['s']=1.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-deg_90, 					['s']=1.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']= deg_90, 					['s']=1.837582},
			
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-deg_45/2, r=deg_45/4,		['s']=1.866700},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-deg_90 - deg_45, 			['s']=1.82062},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=deg_45/2,  r=deg_45/4, 	['s']=1.819189},

			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-deg_90,				['s']=2.000001},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=-deg_90,  			['s']=2.000000},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']= deg_90, 			 ['s']=2.000001},

			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis,['t']=deg_45/2, r=deg_45/4,	 ['s']=2.054762},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis,['t']=deg_90 + deg_45, 		 ['s']=2.164007},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis,['t']=deg_45/2,  r=deg_45/4,  ['s']=2.143011},
			
		}
	},
	{
		['time'] = 12,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.271322, ['s']=0.046010},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 15,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.693675, ['s']=0.841952},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 22,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.212876, ['s']=0.146113},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			--{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=3.714181, ['s']=0.057033},
			--{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.296218, ['s']=0.192514},
			--{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.991118, ['s']=0.222071},
			--{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-2.664833, ['s']=0.031945},
			--{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.550202, ['s']=0.095671},
			--{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-1.537796, ['s']=0.083423},
			--{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.798368, ['s']=0.426538},
			--{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.453922, ['s']=0.378760},
			--{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.698181, ['s']=0.200806},
			--{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.443455, ['s']=0.000001},
			--{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=-0.550168, ['s']=0.000000},
			--{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-1.186636, ['s']=0.000000},
		}
	},
	{
		['time'] = 34,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0,	 	['s']=3.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=math.pi,		['s']=3.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0,		['s']=3.837582},
															
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0,		r= deg_45/2	,['s']=3.866700},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-1.0,	r= deg_45	,	['s']=3.82062},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0, 	r= deg_45/2	,['s']=3.819189},
															
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-math.pi,		['s']=3.000001},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,		['s']=3.000000},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0, 		['s']=3.000001},
															
			{['c']='turn',['p']=LowArm2, ['a']=x_axis,['t']=0,	r= deg_45/2	, 	['s']=3.054762},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis,['t']=1.0, r= deg_45	 	,['s']=3.164007},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis,['t']=0,  r= deg_45/2	,	['s']=3.143011},
			
		
		
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.376503, ['s']=0.409066},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 42,
		['commands'] = {
		}
	},
	{
		['time'] = 43,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.236123, ['s']=0.807446},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 46,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.067814, ['s']=1.028962},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 55,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.132841, ['s']=0.390158},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 59,
		['commands'] = {
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},
},
["UPBODY_FILMING"]={
	{
		['time'] = 2,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.002899, ['s']=0.077009},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.107539, ['s']=0.263254},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.035267, ['s']=0.088960},
			
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-deg_90, ['s']=0.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-deg_90, ['s']=0.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']= deg_90, ['s']=0.837582},
			
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0, ['s']=0.366700},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-deg_90 - deg_45, ['s']=0.82062},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0, ['s']=0.319189},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
			
			
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.102456, ['s']=0.066960},
			

		}
	},
	{
		['time'] = 19,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.002107, ['s']=0.006007},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.040994, ['s']=0.178239},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.013548, ['s']=0.058578},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		}
	},
	{
		['time'] = 34,
		['commands'] = {

			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.031032, ['s']=0.082413},
		}
	},
	
	{
		['time'] = 43,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		}
	},
	{
		['time'] = 44,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.040739, ['s']=0.077265},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.041638, ['s']=0.001288},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.015144, ['s']=0.003192},
		}
	},
	{
		['time'] = 59,
		['commands'] = {
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},

},
["UPBODY_AGGRO_TALK"]={
	{
		['time'] = 0,
		['commands'] = {
			
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.050508, ['s']=0.379929},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.794486, ['s']=0.364301},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-1.133969, ['s']=0.357030},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.797779, ['s']=1.292637},
		
		
		
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-2.374084, ['s']=2.784815},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.033274, ['s']=0.047021},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.013436, ['s']=0.003703},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		
		
		
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.015417, ['s']=0.236374},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 7,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		}
	},
	{
		['time'] = 10,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.048429, ['s']=0.228316},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 12,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.527957, ['s']=1.142270},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.725322, ['s']=1.751343},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.001014, ['s']=3.414708},
		}
	},
	{
		['time'] = 17,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.103547, ['s']=0.509847},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 19,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.067904, ['s']=3.239687},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.529153, ['s']=1.177016},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.098887, ['s']=6.587234},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-1.136410, ['s']=1.687738},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.011287, ['s']=0.029982},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.016929, ['s']=0.004763},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.005059, ['s']=0.123433},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 24,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.344935, ['s']=1.807424},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.344614, ['s']=0.461348},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.047984, ['s']=2.627256},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.067652, ['s']=0.427998},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 27,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		}
	},
	{
		['time'] = 36,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.128774, ['s']=0.446110},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-2.144801, ['s']=5.999552},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-1.191648, ['s']=2.823448},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=2.444769, ['s']=7.989284},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.118529, ['s']=0.620602},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 41,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-1.313511, ['s']=1.328257},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.014428, ['s']=0.023552},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.018715, ['s']=0.013394},
		}
	},
	{
		['time'] = 45,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.648766, ['s']=2.137193},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.991157, ['s']=0.286416},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.280725, ['s']=3.091492},
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-0.433385, ['s']=1.412322},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=1.419432, ['s']=4.336356},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-1.136855, ['s']=3.580860},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.610368, ['s']=1.004489},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.003494, ['s']=0.015619},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.011091, ['s']=0.010890},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-3.119716, ['s']=4.831673},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.278273, ['s']=0.780341},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.029676, ['s']=0.031084},
		}
	},
	{
		['time'] = 55,
		['commands'] = {
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0.037389, ['s']=1.283929},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.026020, ['s']=3.942142},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0.056765, ['s']=3.255327},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-1.509158, ['s']=4.392430},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.018160, ['s']=0.709401},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.019315, ['s']=0.028259},
		}
	},
	{
		['time'] = 66,
		['commands'] = {
		}
	},
},
["UPBODY_NORMAL_TALK"]={
	{
		['time'] = 0,
		['commands'] = {
		
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.009083, ['s']=0.078608},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},

			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.004839, ['s']=0.009532},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.378985, ['s']=0.245984},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.028545, ['s']=0.021297},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.093853, ['s']=0.209316},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=1.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.458284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.498281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.408325},
		}
	},
	{
		['time'] = 1,
		['commands'] = {
		}
	},
	{
		['time'] = 15,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.014752, ['s']=0.148313},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 18,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.205645, ['s']=0.737109},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 21,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.163123, ['s']=0.212891},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.015469, ['s']=0.045869},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.113488, ['s']=0.122251},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.011511, ['s']=0.005133},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.551174, ['s']=0.132453},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.043453, ['s']=0.011468},
		}
	},
	{
		['time'] = 26,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.051642, ['s']=0.924019},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 30,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=1.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.458284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.498281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.408325},

		}
	},
	{
		['time'] = 31,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.037382, ['s']=0.085562},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.071781, ['s']=0.122203},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 36,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.111530, ['s']=0.741476},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 39,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.024322, ['s']=0.261623},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 45,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.010805, ['s']=0.165172},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 49,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.056248, ['s']=0.087070},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.361822, ['s']=0.541904},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.058280, ['s']=0.116756},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.227590, ['s']=0.311185},
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},
	},
["UPBODY_PHONE"]={
		{
		['time'] = 0,
		['commands'] = {
			
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.045881, ['s']=0.229407},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.196004, ['s']=0.001407},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.005441, ['s']=0.027205},

		
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.16 , ['s']=0.70260},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.827 - deg_90, ['s']=0.72465},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.16, ['s']=0.73747},
			
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0- deg_90 + deg_45/2, ['s']=0.705598},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']= -0.7853 , ['s']=0.74629},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0+ deg_90 -deg_45/2, ['s']=0.77300},
			
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.045319, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.053385, ['s']=0.042968},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 5,
		['commands'] = {
		}
	},
	{
		['time'] = 6,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.000802, ['s']=0.175062},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.196288, ['s']=0.001065},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000095, ['s']=0.020761},
		}
	},
	{
		['time'] = 11,
		['commands'] = {

			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-1.052336, ['s']=0.201731},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=-0.105158, ['s']=1.199621},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.092752, ['s']=0.219161},
		}
	},
	{
		['time'] = 14,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.098156, ['s']=0.296875},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.195385, ['s']=0.002707},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.011617, ['s']=0.035137},
		}
	},
	{
		['time'] = 17,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.045319, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.080521, ['s']=0.054271},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 21,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		}
	},
	{
		['time'] = 24,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.017473, ['s']=0.302563},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.196207, ['s']=0.003081},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.002074, ['s']=0.035788},

		}
	},
	{
		['time'] = 32,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.098156, ['s']=0.201709},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.195385, ['s']=0.002054},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.011617, ['s']=0.023859},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.045319, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.053385, ['s']=0.067839},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 35,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		}
	},
	{
		['time'] = 42,
		['commands'] = {

		}
	},
	{
		['time'] = 44,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.017473, ['s']=0.403418},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.196207, ['s']=0.004108},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.002074, ['s']=0.047717},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.077734, ['s']=0.052175},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 45,
		['commands'] = {
		}
	},
	{
		['time'] = 50,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.000000, ['s']=0.074883},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.196285, ['s']=0.000335},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.008887},
		}
	},
	{
		['time'] = 51,
		['commands'] = {

		}
	},
	{
		['time'] = 57,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=2.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=2.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.858284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.898281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.808325},
		
		}
	},
	{
		['time'] = 58,
		['commands'] = {
		}
	},
},
["UPBODY_LOADED"]={
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=Handbag, ['a']=x_axis, ['t']=-0.029155, ['s']=0.016287},
			{['c']='turn',['p']=Handbag, ['a']=y_axis, ['t']=-0.045022, ['s']=0.118480},
			{['c']='turn',['p']=Handbag, ['a']=z_axis, ['t']=-1.416788, ['s']=0.143623},
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.265485, ['s']=0.140177},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.014153, ['s']=0.003016},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.159935, ['s']=0.018162},
			
			{['c']='turn',['p']=ShoppingBag, ['a']=x_axis, ['t']=-0.117924 , ['s']=0.5448},
			{['c']='turn',['p']=ShoppingBag, ['a']=y_axis, ['t']=-0.148104+deg_45, ['s']=0.046261},
			{['c']='turn',['p']=ShoppingBag, ['a']=z_axis, ['t']=-1.794599 , ['s']=0.384701},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0.183250 , ['s']=0.305417},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.301351 , ['s']=0.8707}, --+ deg_45
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.054955, ['s']=0.91592},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.011348, ['s']=0.022963},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0.0, ['s']=0.026580},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.3, ['s']=0.267672},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0.0, ['s']=0.031314},
			
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.16 , ['s']=0.70260},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.827 - deg_90, ['s']=0.72465},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.16, ['s']=0.73747},
			
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']= deg_45/2, ['s']=0.705598},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']= -0.7853 , ['s']=0.74629},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0, ['s']=0.77300},
			
			
		}
	},
	{
		['time'] = 3,
		['commands'] = {
			{['c']='turn',['p']=SittingBaby, ['a']=x_axis, ['t']=-0.016479, ['s']=0.017047},
			{['c']='turn',['p']=SittingBaby, ['a']=y_axis, ['t']=0.157080, ['s']=0.162496},
			{['c']='turn',['p']=SittingBaby, ['a']=z_axis, ['t']=0.052360, ['s']=0.054165},
		}
	},
	{
		['time'] = 13,
		['commands'] = {

		}
	},
	{
		['time'] = 18,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.059251, ['s']=0.055273},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 19,
		['commands'] = {
			{['c']='turn',['p']=ShoppingBag, ['a']=x_axis, ['t']=-0.119448, ['s']=0.011434},
			{['c']='turn',['p']=ShoppingBag, ['a']=y_axis, ['t']=-0.133895+deg_45, ['s']=0.106565},
			{['c']='turn',['p']=ShoppingBag, ['a']=z_axis, ['t']=-1.676702 , ['s']=0.884227},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.107804, ['s']=0.379636},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.304904 , ['s']=0.4634}, --+ deg_90
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.032478, ['s']=0.114042},
		}
	},
	{
		['time'] = 20,
		['commands'] = {
			{['c']='turn',['p']=Handbag, ['a']=x_axis, ['t']=-0.019781, ['s']=0.011249},
			{['c']='turn',['p']=Handbag, ['a']=y_axis, ['t']=0.026275, ['s']=0.085556},
			{['c']='turn',['p']=Handbag, ['a']=z_axis, ['t']=-1.516682, ['s']=0.119873},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=ShoppingBag, ['a']=x_axis, ['t']=-0.118826 , ['s']=0.001166},
			{['c']='turn',['p']=ShoppingBag, ['a']=y_axis, ['t']=-0.097433+deg_45, ['s']=0.068367},
			{['c']='turn',['p']=ShoppingBag, ['a']=z_axis, ['t']=-1.373211, ['s']=0.569046},
		}
	},
	{
		['time'] = 26,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.148671, ['s']=0.106194},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.016667, ['s']=0.002285},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.175070, ['s']=0.013759},
		}
	},
	{
		['time'] = 32,
		['commands'] = {
			{['c']='turn',['p']=SittingBaby, ['a']=x_axis, ['t']=0.000000, ['s']=0.019014},
			{['c']='turn',['p']=SittingBaby, ['a']=y_axis, ['t']=0.000000, ['s']=0.181246},
			{['c']='turn',['p']=SittingBaby, ['a']=z_axis, ['t']=0.000000, ['s']=0.060415},
		}
	},
	{
		['time'] = 33,
		['commands'] = {

		}
	},
	{
		['time'] = 39,
		['commands'] = {
			{['c']='turn',['p']=ShoppingBag, ['a']=x_axis, ['t']=-0.120942, ['s']=0.010576},
			{['c']='turn',['p']=ShoppingBag, ['a']=y_axis, ['t']=-0.113837+deg_45, ['s']=0.082020},
			{['c']='turn',['p']=ShoppingBag, ['a']=z_axis, ['t']=-1.509792, ['s']=0.682902},
		}
	},
	{
		['time'] = 42,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0.000000 , ['s']=0.179674},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.306575 , ['s']=0.2785}, --+ deg_90
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.000000, ['s']=0.54129},
		}
	},
	{
		['time'] = 44,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.024360, ['s']=0.069781},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 45,
		['commands'] = {
			{['c']='turn',['p']=Handbag, ['a']=x_axis, ['t']=-0.018840, ['s']=0.001881},
			{['c']='turn',['p']=Handbag, ['a']=y_axis, ['t']=0.030015, ['s']=0.007481},
			{['c']='turn',['p']=Handbag, ['a']=z_axis, ['t']=-1.507750, ['s']=0.017865},
			{['c']='turn',['p']=ShoppingBag, ['a']=x_axis, ['t']=-0.121193, ['s']=0.000502},
			{['c']='turn',['p']=ShoppingBag, ['a']=y_axis, ['t']=-0.120347+deg_45, ['s']=0.013020},
			{['c']='turn',['p']=ShoppingBag, ['a']=z_axis, ['t']=-1.563779, ['s']=0.107974},
		}
	},
	{
		['time'] = 46,
		['commands'] = {
		
		}
	},
	{
		['time'] = 58,
		['commands'] = {
		}
	},
	{
		['time'] = 59,
		['commands'] = {
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},
},	
["UPBODY_CONSUMPTION"]={
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0,0 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['ru']=math.pi/8 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=1.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['rl']=-deg_90,['ru']=0,['s']=0.458284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.498281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['rl']=-deg_45,['ru']=0,['s']=0.408325},
		}
	},

	{
		['time'] = 13,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.324092, ['s']=0.902387},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.294168, ['s']=1.903459},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.718100, ['s']=3.075234},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.135686, ['s']=0.895047},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.686241, ['s']=3.346777},
		}
	},
	{
		['time'] = 24,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.219193, ['s']=0.252915},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.054414, ['s']=0.062785},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.309211, ['s']=0.017171},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.735223, ['s']=0.826978},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.231101, ['s']=1.779751},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.985264, ['s']=0.282042},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0.249867, ['s']=1.755203},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.272321, ['s']=0.510602},
		}
	},
	{
		['time'] = 40,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-2.410163, ['s']=2.249800},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.417720, ['s']=2.162734},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.467039, ['s']=1.605916},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.301170, ['s']=1.836791},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.733207, ['s']=2.444025},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.233522, ['s']=0.129332},
		}
	},
	{
		['time'] = 49,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-2.019141, ['s']=1.466330},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.098528, ['s']=1.196970},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.074383, ['s']=1.472460},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.301170, ['s']=0.000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.678995, ['s']=1.670524},
		}
	},
	{
		['time'] = 50,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.245834, ['s']=0.099905},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.060746, ['s']=0.023745},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.306605, ['s']=0.009772},
		}
	},
	{
		['time'] = 57,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.908796, ['s']=0.076985},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.120065, ['s']=0.152507},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.000749, ['s']=0.051372},
		}
	},
	{
		['time'] = 58,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.159237, ['s']=0.649478},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.039904, ['s']=0.156315},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.314456, ['s']=0.058882},
		}
	},
	{
		['time'] = 62,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.263466, ['s']=0.390858},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.064894, ['s']=0.093713},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.304789, ['s']=0.036251},
		}
	},
	{
		['time'] = 70,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.115124, ['s']=0.556282},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.029024, ['s']=0.134511},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.317758, ['s']=0.048633},
		}
	},
	{
		['time'] = 78,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.086603, ['s']=0.095072},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.021910, ['s']=0.023713},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.319637, ['s']=0.006264},
		}
	},
	{
		['time'] = 87,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.000000, ['s']=0.199852},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.000000, ['s']=0.050563},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.000000, ['s']=0.737623},
		}
	},
	{
		['time'] = 100,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-2.104822, ['s']=0.490065},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.089220, ['s']=0.523212},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=1.260738, ['s']=0.649972},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.301170, ['s']=0.000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.233522, ['s']=1.670524},
		}
	},
	{
		['time'] = 108,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0.249867, ['s']=2.066390},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0.000000, ['s']=2.749528},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.272321, ['s']=0.145499},
		}
	},
	{
		['time'] = 112,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.939342, ['s']=0.620553},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.343392, ['s']=1.622295},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.804728, ['s']=1.710039},
		}
	},
	{
		['time'] = 116,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0.540910, ['s']=0.970144},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.300000, ['s']=0.1000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.000000, ['s']=0.1907737},
		}
	},
	{
		['time'] = 120,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.992103, ['s']=0.158284},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.409486, ['s']=0.198281},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.807503, ['s']=0.18325},

			
		}
	},
	{
		['time'] = 125,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-deg_45,['ru']=deg_45 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,	['r']=math.pi/8 ,['s']=1.970144},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0				,['s']=1.907737},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0, ['s']=0.258284},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0, ['ru']=math.pi/8,['s']=0.298281},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0, ['r']=math.pi/8,['s']=0.208325},
		}
	},
	{
		['time'] = 180,
		['commands'] = {
		}
	},
},
["UPBODY_HANDSUP"] ={
	{
		['time'] = 1,
		['commands'] = {

			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=0,	 	['s']=3.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=math.pi,		['s']=3.8000000},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0,		['s']=3.837582},
															
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0,		['s']=3.866700},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-1.0,	r= deg_45	,	['s']=3.82062},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0, 	['s']=3.819189},
															
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-math.pi,		['s']=3.000001},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0,		['s']=3.000000},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0, 		['s']=3.000001},
															
			{['c']='turn',['p']=LowArm2, ['a']=x_axis,['t']=0,	 	['s']=3.054762},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis,['t']=1.0, r= deg_45	 	,['s']=3.164007},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis,['t']=0,  	['s']=3.143011},
		}
	},
	{
		['time'] = 3,
		['commands'] = {

		}
	},
	{
		['time'] = 128,
		['commands'] = {
		}
	},


},
["SLAVED"]={
		{
			['time'] = 1,
			['commands'] = {		
			},
		},		
		{
			['time'] = 60,
			['commands'] = {		
			},
		},


},
["WALKCYCLE_UNLOADED"]={
	{
		['time'] = 0,
		['commands'] = {
		
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0.139018, ['s']=0.214771},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.017453, ['s']=0.057163},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=-0.091487, ['s']=0.152119},
			
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-0.104861, ['s']=0.786650},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=-0.009331, ['s']=0.090051},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0.051170, ['s']=0.984351},
			
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0.000000, ['s']=0.891025},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.615430, ['s']=0.075622},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.000000, ['s']=0.507045},
			
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0.000000, ['s']=0.916466},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.615579, ['s']=0.080057},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.000000, ['s']=0.521190},
		}
	},
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=-0.040484, ['s']=0.158043},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.156793, ['s']=1.186987},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.097370, ['s']=0.537055},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.017156, ['s']=0.022929},
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=0.212970, ['s']=1.967028},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=0.018212, ['s']=0.123941},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=0.236178, ['s']=0.042580},
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.054269, ['s']=0.009961},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.036623, ['s']=0.211963},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000688, ['s']=0.011530},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.010911, ['s']=0.156055},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.029487, ['s']=0.068002},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.012414, ['s']=0.030243},
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=0.280484, ['s']=0.676133},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=0.023582, ['s']=0.178514},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=-0.005542, ['s']=0.058872},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.005538, ['s']=0.015104},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.066086, ['s']=0.160734},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000143, ['s']=0.000389},
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=0.025493, ['s']=0.883404},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=-0.026542, ['s']=0.050210},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=0.014260, ['s']=0.042770},
			{['c']='turn',['p']=UpLeg2, ['a']=x_axis, ['t']=-0.291093, ['s']=0.918559},
			{['c']='turn',['p']=UpLeg2, ['a']=y_axis, ['t']=0.076399, ['s']=0.092268},
			{['c']='turn',['p']=UpLeg2, ['a']=z_axis, ['t']=0.003685, ['s']=0.000876},
		}
	},
	{
		['time'] = 5,
		['commands'] = {
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=0.882144, ['s']=2.578542},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=0.007687, ['s']=0.068122},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=-0.023967, ['s']=0.078963},
		}
	},
	{
		['time'] = 7,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=-0.001485, ['s']=0.791390},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.094039, ['s']=0.016655},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=-0.160515, ['s']=0.888355},
		}
	},
	{
		['time'] = 9,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=-0.124491, ['s']=1.124870},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=0.028319, ['s']=0.033693},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=0.414133, ['s']=0.593184},
		}
	},
	{
		['time'] = 10,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.029068, ['s']=0.357159},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.038794, ['s']=0.323215},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000427, ['s']=0.001115},
		}
	},
	{
		['time'] = 11,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=0.077246, ['s']=0.196216},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-0.137398, ['s']=0.088737},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.074715, ['s']=0.229217},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0.293361, ['s']=0.660521},
		}
	},
	{
		['time'] = 12,
		['commands'] = {
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=0.043998, ['s']=2.793819},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=0.008892, ['s']=0.004019},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=-0.028198, ['s']=0.014104},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.465619, ['s']=0.997755},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.558981, ['s']=0.120961},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.283341, ['s']=0.607158},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0.401825, ['s']=1.506842},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.580885, ['s']=0.130103},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.227009, ['s']=0.851283},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.015869, ['s']=0.028175},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.105000, ['s']=0.466599},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000978, ['s']=0.003056},
		}
	},
	{
		['time'] = 13,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=-0.345989, ['s']=0.939555},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.016579, ['s']=0.211254},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=-0.179203, ['s']=0.050967},
		}
	},
	{
		['time'] = 14,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0.099758, ['s']=0.098149},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.104720, ['s']=0.305433},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=-0.087433, ['s']=0.010135},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.212402, ['s']=0.464978},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.025069, ['s']=0.010194},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.021892, ['s']=0.021874},
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=0.271179, ['s']=0.566968},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=-0.132604, ['s']=0.244759},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=0.036954, ['s']=0.052371},
		}
	},
	{
		['time'] = 17,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.000000, ['s']=0.087204},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.079206, ['s']=0.121236},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000000, ['s']=0.001282},
		}
	},
	{
		['time'] = 18,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=-0.152109, ['s']=0.165710},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.042260, ['s']=0.423479},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=0.105737, ['s']=1.850375},
		}
	},
	{
		['time'] = 19,
		['commands'] = {
			{['c']='turn',['p']=UpLeg2, ['a']=x_axis, ['t']=-0.294232, ['s']=0.023543},
			{['c']='turn',['p']=UpLeg2, ['a']=y_axis, ['t']=0.052187, ['s']=0.181584},
			{['c']='turn',['p']=UpLeg2, ['a']=z_axis, ['t']=0.000498, ['s']=0.023898},
		}
	},
	{
		['time'] = 20,
		['commands'] = {
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=0.000000, ['s']=1.095885},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.615579, ['s']=0.094620},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=0.000000, ['s']=0.619115},
		}
	},
	{
		['time'] = 21,
		['commands'] = {
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=-0.009824, ['s']=0.269113},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=-0.005613, ['s']=0.072528},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=-0.029465, ['s']=0.006334},
		}
	},
	{
		['time'] = 22,
		['commands'] = {
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=-0.121166, ['s']=0.044270},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.025828, ['s']=0.133329},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=0.077655, ['s']=0.588290},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=0.193087, ['s']=2.588971},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.116693, ['s']=0.558244},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=-0.008607, ['s']=0.857579},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.012521, ['s']=0.085170},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.095028, ['s']=0.029916},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000363, ['s']=0.004022},
			{['c']='turn',['p']=UpLeg2, ['a']=x_axis, ['t']=0.260042, ['s']=0.791821},
			{['c']='turn',['p']=UpLeg2, ['a']=y_axis, ['t']=0.131759, ['s']=0.113674},
			{['c']='turn',['p']=UpLeg2, ['a']=z_axis, ['t']=0.003159, ['s']=0.003801},
		}
	},
	{
		['time'] = 24,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.243292, ['s']=3.535683},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.004427, ['s']=0.126037},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.025981, ['s']=1.231108},
		}
	},
	{
		['time'] = 26,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0.139018, ['s']=0.107072},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=0.017453, ['s']=0.333199},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=-0.091487, ['s']=0.011056},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0.000000, ['s']=1.396857},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.615430, ['s']=0.169346},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.000000, ['s']=0.850022},
		}
	},
	{
		['time'] = 27,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=-0.154303, ['s']=1.157964},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.154733, ['s']=0.126801},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=0.032344, ['s']=0.136503},
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=-0.041419, ['s']=0.207093},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.063841, ['s']=0.076824},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.001421, ['s']=0.007103},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.658612, ['s']=3.346578},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.049425, ['s']=0.182669},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.029532, ['s']=0.057300},
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=0.190333, ['s']=0.353219},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=-0.000220, ['s']=0.009517},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=0.002308, ['s']=0.056069},
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=-0.385206, ['s']=1.312770},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=-0.031172, ['s']=0.202865},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=-0.002828, ['s']=0.079564},
		}
	},
	{
		['time'] = 29,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=0.012197, ['s']=0.130097},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=-0.400895, ['s']=2.415698},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.178056, ['s']=0.651109},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=-0.400068, ['s']=1.597684},
		}
	},
	{
		['time'] = 31,
		['commands'] = {
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.809039, ['s']=0.752137},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.028867, ['s']=0.102793},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.022829, ['s']=0.033517},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.366586, ['s']=0.785542},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.583556, ['s']=0.068620},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.208476, ['s']=0.446734},
		}
	},
	{
		['time'] = 33,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.051281, ['s']=0.252817},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.100212, ['s']=0.447417},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.004147, ['s']=0.007434},
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=0.183577, ['s']=0.831118},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.023688, ['s']=0.005837},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=-0.309758, ['s']=1.056582},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.000000, ['s']=0.034148},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.007151, ['s']=0.278669},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000990},
		}
	},
	{
		['time'] = 36,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=-0.311571, ['s']=0.589755},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.014839, ['s']=0.524602},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=0.247533, ['s']=0.806955},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=0.356410, ['s']=1.188033},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.585181, ['s']=0.100829},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=-0.202818, ['s']=0.676060},
		}
	},
	{
		['time'] = 37,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=-0.080605, ['s']=1.372671},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.010041, ['s']=0.720064},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.021741, ['s']=1.807753},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=0.038792, ['s']=0.375849},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.009223, ['s']=0.100035},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=-0.162475, ['s']=0.266209},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=-0.056713, ['s']=3.710367},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.000020, ['s']=0.123631},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=-0.000691, ['s']=0.100802},
		}
	},
	{
		['time'] = 42,
		['commands'] = {
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=-0.357315, ['s']=0.418358},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=-0.048299, ['s']=0.256915},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=-0.004274, ['s']=0.021689},
		}
	},
	{
		['time'] = 44,
		['commands'] = {
		}
	},
	{
		['time'] = 45,
		['commands'] = {
		}
	},
},
["WALKCYCLE_WOUNDED"]={
{
		['time'] = 0,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.046779, ['s']=0.077966},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.001801, ['s']=0.003002},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=-0.001366, ['s']=0.002276},
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=-0.017392, ['s']=0.030692},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.000917, ['s']=0.001618},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.108989, ['s']=0.163483},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.020146, ['s']=0.030219},
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=-0.210369, ['s']=0.371240},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=0.030644, ['s']=0.054077},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=-0.001749, ['s']=0.003086},
			{['c']='turn',['p']=UpLeg2, ['a']=x_axis, ['t']=0.168795, ['s']=0.297873},
			{['c']='turn',['p']=UpLeg2, ['a']=y_axis, ['t']=-0.024464, ['s']=0.043171},
			{['c']='turn',['p']=UpLeg2, ['a']=z_axis, ['t']=-0.001759, ['s']=0.003104},
		}
	},
	{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.015086, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.184675, ['s']=0.277012},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.382633, ['s']=0.209045},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.618961, ['s']=0.067639},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.389230, ['s']=0.123862},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.246223, ['s']=0.000261},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.002229, ['s']=0.003519},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.148268, ['s']=0.234108},
		}
	},
	{
		['time'] = 2,
		['commands'] = {
		}
	},
	{
		['time'] = 3,
		['commands'] = {
		}
	},
	{
		['time'] = 17,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=0.209251, ['s']=0.283303},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.038430, ['s']=0.046891},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=-0.004623, ['s']=0.005270},
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=0.245139, ['s']=0.594142},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=-0.044878, ['s']=0.098506},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=-0.006218, ['s']=0.005829},
			{['c']='turn',['p']=UpLeg2, ['a']=x_axis, ['t']=-0.201101, ['s']=0.462370},
			{['c']='turn',['p']=UpLeg2, ['a']=y_axis, ['t']=0.037074, ['s']=0.076922},
			{['c']='turn',['p']=UpLeg2, ['a']=z_axis, ['t']=-0.003177, ['s']=0.001772},
		}
	},
	{
		['time'] = 18,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.044961, ['s']=0.010907},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.240925, ['s']=1.456358},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.304959, ['s']=1.837948},
		}
	},
	{
		['time'] = 20,
		['commands'] = {
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.000000, ['s']=0.083837},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=0.000000, ['s']=0.015497},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.248179, ['s']=0.011739},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.057524, ['s']=0.331773},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.125526, ['s']=0.136452},
		}
	},
	{
		['time'] = 21,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.019449, ['s']=0.032727},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=-0.026917, ['s']=0.201880},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.160733, ['s']=0.179566},
		}
	},
	{
		['time'] = 22,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.347416, ['s']=0.264124},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.591575, ['s']=0.205393},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.360203, ['s']=0.217701},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=-0.332979, ['s']=0.629901},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.060683, ['s']=0.300404},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=-0.009261, ['s']=0.523700},
		}
	},
	{
		['time'] = 25,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.015086, ['s']=0.008182},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=0.000000, ['s']=0.050470},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=-0.046102, ['s']=0.387815},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.247212, ['s']=0.007255},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.026799, ['s']=0.230436},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.117445, ['s']=0.060608},
		}
	},
	{
		['time'] = 26,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.204393, ['s']=0.268170},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.666445, ['s']=0.140380},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.281122, ['s']=0.148278},
		}
	},
	{
		['time'] = 29,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.246388, ['s']=0.002059},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000068, ['s']=0.067168},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.004489, ['s']=0.304835},
		}
	},
	{
		['time'] = 40,
		['commands'] = {
			{['c']='turn',['p']=UpLeg1, ['a']=x_axis, ['t']=0.000000, ['s']=0.387062},
			{['c']='turn',['p']=UpLeg1, ['a']=y_axis, ['t']=0.000000, ['s']=0.070860},
			{['c']='turn',['p']=UpLeg1, ['a']=z_axis, ['t']=0.000000, ['s']=0.009818},
		}
	},
	{
		['time'] = 41,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.015086, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.000000, ['s']=0.072793},
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.000000, ['s']=0.554965},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.000000, ['s']=0.101138},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.000000, ['s']=0.015435},
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=0.000000, ['s']=0.348751},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=0.000000, ['s']=0.064050},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.246388, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000107},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.007088},
			{['c']='turn',['p']=UpLeg2, ['a']=x_axis, ['t']=0.000000, ['s']=0.335168},
			{['c']='turn',['p']=UpLeg2, ['a']=y_axis, ['t']=0.000000, ['s']=0.061790},
			{['c']='turn',['p']=UpLeg2, ['a']=z_axis, ['t']=0.000000, ['s']=0.005294},
		}
	},
	{
		['time'] = 42,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.236302, ['s']=0.053182},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.666309, ['s']=0.000227},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.302527, ['s']=0.035675},
		}
	},
	{
		['time'] = 59,
		['commands'] = {
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},

},
["WALKCYCLE_ROLLY"]={{
		['time'] = 1,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.077418, ['s']=0.061639},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.894400, ['s']=0.062763},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.041369, ['s']=0.038654},
			{['c']='turn',['p']=trolley, ['a']=x_axis, ['t']=0.471759, ['s']=0.046341},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.242967, ['s']=0.002215},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.186960, ['s']=0.003036},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=-1.157361, ['s']=0.375518},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.000145, ['s']=0.000141},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.009999, ['s']=0.009676},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.014522, ['s']=0.254374},
		}
	},
	{
		['time'] = 31,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.015778, ['s']=0.063765},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.831637, ['s']=0.064927},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=0.002715, ['s']=0.039987},
		}
	},
	{
		['time'] = 32,
		['commands'] = {
			{['c']='turn',['p']=trolley, ['a']=x_axis, ['t']=0.423873, ['s']=0.053206},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.240679, ['s']=0.002543},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.183823, ['s']=0.003486},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=-0.769325, ['s']=0.431151},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.000000, ['s']=0.000161},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.011110},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=-0.248331, ['s']=0.292060},
		}
	},
	{
		['time'] = 59,
		['commands'] = {
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},
	},
["WALKCYCLE_COVERWALK"]={
{
		['time'] = 1,
		['commands'] = {
			{['c']='move',['p']=center, ['a']=y_axis, ['t']=-15.625361, ['s']=7.263875},
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.507957, ['s']=1.578540},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.634135, ['s']=0.010860},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=0.065751, ['s']=0.109584},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=0.197479, ['s']=0.329132},
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.870292, ['s']=0.213269},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.162037, ['s']=0.347012},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=2.167445, ['s']=0.170347},
				{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=4.224595, ['s']=0.291566},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.754924, ['s']=0.352636},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=4.410536, ['s']=0.469128},
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=0.871078, ['s']=2.739166},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
				{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.555612, ['s']=0.309770},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.454317, ['s']=0.068081},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.266639, ['s']=0.139536},
				{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-1.422290, ['s']=0.342509},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.684756, ['s']=0.115139},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.456199, ['s']=0.222402},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.792780, ['s']=2.185121},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 2,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.744631, ['s']=4.101306},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.006390, ['s']=0.037762},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.007692, ['s']=0.013846},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=-0.416577, ['s']=2.640090},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 7,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=-0.040768, ['s']=1.308999},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=0.000920, ['s']=0.012185},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.009958, ['s']=0.003776},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=-0.366307, ['s']=0.502697},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 8,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.908025, ['s']=1.152445},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 10,
		['commands'] = {
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.262064, ['s']=1.256742},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 11,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=0.495523, ['s']=2.508702},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=0.000000, ['s']=4.277934},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=-0.458201, ['s']=3.323198},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=-0.198423, ['s']=2.766120},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 12,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.075078, ['s']=1.108926},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.520777, ['s']=0.153369},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.037968, ['s']=0.527702},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-0.857322, ['s']=1.303772},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.799622, ['s']=0.265075},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.068140, ['s']=0.895521},
		}
	},
	{
		['time'] = 13,
		['commands'] = {
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 19,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.631819, ['s']=0.003157},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.012272, ['s']=0.106394},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.150451, ['s']=0.474450},
		}
	},
	{
		['time'] = 23,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=-0.412454, ['s']=1.134971},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Feet2, ['a']=x_axis, ['t']=-0.296994, ['s']=0.445490},
			{['c']='turn',['p']=Feet2, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=Feet2, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
				{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-0.977970, ['s']=0.119643},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.331555, ['s']=0.188352},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=2.078941, ['s']=0.098338},
			{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=4.333627, ['s']=0.121147},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=0.924061, ['s']=0.187930},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=4.602767, ['s']=0.213590},
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=0.707261, ['s']=1.748192},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.630858, ['s']=0.956862},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 25,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.647884, ['s']=1.147753},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.005617, ['s']=0.010897},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.008273, ['s']=0.002807},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=-0.403652, ['s']=1.109527},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.289633, ['s']=0.495127},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.503701, ['s']=0.039405},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.143439, ['s']=0.243395},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-1.119464, ['s']=0.604944},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.769313, ['s']=0.069944},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.253883, ['s']=0.428639},
		}
	},
	{
		['time'] = 38,
		['commands'] = {
			{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.240287, ['s']=0.123364},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.509408, ['s']=0.014267},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.119494, ['s']=0.059862},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-1.060225, ['s']=0.148097},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.779373, ['s']=0.025151},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.212454, ['s']=0.103573},
		}
	},
	{
		['time'] = 41,
		['commands'] = {
			{['c']='turn',['p']=Head1, ['a']=x_axis, ['t']=0.627619, ['s']=0.006632},
			{['c']='turn',['p']=Head1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.019377},
			{['c']='turn',['p']=Head1, ['a']=z_axis, ['t']=-0.000000, ['s']=0.237554},
		}
	},
	{
		['time'] = 43,
		['commands'] = {
			{['c']='turn',['p']=Feet1, ['a']=x_axis, ['t']=0.061080, ['s']=0.978006},
			{['c']='turn',['p']=Feet1, ['a']=y_axis, ['t']=-0.000097, ['s']=0.009201},
			{['c']='turn',['p']=Feet1, ['a']=z_axis, ['t']=0.010000, ['s']=0.002877},
			{['c']='turn',['p']=LowLeg1, ['a']=x_axis, ['t']=0.023438, ['s']=0.711817},
			{['c']='turn',['p']=LowLeg1, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg1, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg2, ['a']=x_axis, ['t']=-0.041977, ['s']=1.322184},
			{['c']='turn',['p']=LowLeg2, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=LowLeg2, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 47,
		['commands'] = {
			{['c']='turn',['p']=center, ['a']=x_axis, ['t']=0.018223, ['s']=0.993869},
			{['c']='turn',['p']=center, ['a']=y_axis, ['t']=0.000000, ['s']=0.000000},
			{['c']='turn',['p']=center, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 49,
		['commands'] = {
			{['c']='turn',['p']=UpBody, ['a']=x_axis, ['t']=0.282919, ['s']=0.948924},
			{['c']='turn',['p']=UpBody, ['a']=y_axis, ['t']=-0.000000, ['s']=0.000000},
			{['c']='turn',['p']=UpBody, ['a']=z_axis, ['t']=0.000000, ['s']=0.000000},
		}
	},
	{
		['time'] = 50,
		['commands'] = {
			{['c']='turn',['p']=LowArm1, ['a']=x_axis, ['t']=-1.026689, ['s']=0.146155},
			{['c']='turn',['p']=LowArm1, ['a']=y_axis, ['t']=-0.416513, ['s']=0.254874},
			{['c']='turn',['p']=LowArm1, ['a']=z_axis, ['t']=2.042524, ['s']=0.109251},
		{['c']='turn',['p']=LowArm2, ['a']=x_axis, ['t']=4.438410, ['s']=0.314349},
			{['c']='turn',['p']=LowArm2, ['a']=y_axis, ['t']=1.013524, ['s']=0.268389},
			{['c']='turn',['p']=LowArm2, ['a']=z_axis, ['t']=4.754564, ['s']=0.455389},
		{['c']='turn',['p']=UpArm1, ['a']=x_axis, ['t']=-0.442030, ['s']=0.605230},
			{['c']='turn',['p']=UpArm1, ['a']=y_axis, ['t']=-0.479280, ['s']=0.090385},
			{['c']='turn',['p']=UpArm1, ['a']=z_axis, ['t']=0.215476, ['s']=0.287943},
			{['c']='turn',['p']=UpArm2, ['a']=x_axis, ['t']=-1.296703, ['s']=0.709432},
			{['c']='turn',['p']=UpArm2, ['a']=y_axis, ['t']=0.726973, ['s']=0.157198},
			{['c']='turn',['p']=UpArm2, ['a']=z_axis, ['t']=-0.374652, ['s']=0.486593},
		}
	},
	{
		['time'] = 60,
		['commands'] = {
		}
	},
	{
		['time'] = 61,
		['commands'] = {
		}
	},


},

}

---------------------------------------------------------------------ANIMATIONLIB-------------------------------------
---------------------------------------------------------------------ANIMATIONS-------------------------------------
-- +STOPED+---------------------------------------------------+    +----------------------------+
-- |                                                          |    |Aiming/Assaultanimation:    |
-- |  +--------------+         +----------------------------+ |    |Stick                       |
-- |  |Transfer Pose |         |Idle Animations:            | |    |Molotowcocktail             |
-- |  +--------+----++         |talk Cycle, debate-intensity| |    |Fist                        |
-- |           ^    ^          |stand alone idle:           | |    |                            |
-- |           |    |          |cellphone,                  | |    |                            |
-- |           |    |          |smoking, squatting          | |    |                            |
-- |           |    +--------->+prayer                      | |    |                            |
-- |           |    |          |sleep on street             | |    |                            |
-- |           |    |          +----------------------------+ |    +----------------------------+
-- |           |    |          +----------------------------+ |
-- |           |    |          |   ReactionAnimation:       | |    +----------------------------+
-- |           |    |          |		   Catastrophe:     | |    | Hit-Animation              |
-- |           |    |          |		     filming        | |    |touch Wound/ hold wound		|
-- |           |    +--------->+		     whailing       | |    |	                        |
-- |           |    |          |		     Protesting     | |    |                            |
-- |           |    |          +----------------------------+ |    |                            |
-- |           |    |          +-------------------------+    |    |                            |
-- |           |    +----------> Hit Animation           |    |    |                            |
-- |           |               | touch Wound/ hold wound |    |    +----------------------------+
-- +----------------------------------------------------------+
-- +-Walking+-------------------------------------------------+  +-------------------------------------+
-- |           v                                              |  |Death Animation                      |
-- | +---------+-------------------------+                    |  |Blasteded                            |
-- | |Transfer Pose|TransferPose Wounded +<--+                |  |Swirlingng                           |
-- | +-----------------------------------+   |                |  |Suprised                             |
-- +-----------------------------------------v----------------+  Collapsing, Shivering, Coiling Up     |
-- |    Walk Animation:                                       |  |                                     |
-- |walk Cycles: Normal/ Wounded/ Carrying/ Cowering/Run      |  +-------------------------------------+
-- |-----------------------------------------------------------

-- Animation StateMachine
	-- Every Animation optimized for fast blending
	-- Health movement loops
	-- Allows for External Override
	-- AnimationStates have abort Condition
	--Animations can be diffrent depending on buildScript (State_Idle/Walk Animation loaded)
	-- Usually the Lower animation state is the master- but the upper can detach, so seperate upper Body Animations are possible



uppperBodyAnimations = {
	[eAnimState.slaved] = { 
		[1] = "SLAVED",	
	},
	[eAnimState.idle] = { 	
		[1] = "SLAVED",
		[2] = "UPBODY_PHONE",
		[3] = "UPBODY_CONSUMPTION",
	},
	[eAnimState.filming] = {
		[1] = "UPBODY_FILMING",
		[2] = "UPBODY_PHONE",
	},
	[eAnimState.wailing] = {
		[1] = "UPBODY_WAILING1",
		[2] = "UPBODY_WAILING2",
	},
	[eAnimState.talking] = {
		[1] = "UPBODY_AGGRO_TALK",
		[2] = "UPBODY_NORMAL_TALK",
	},
	[eAnimState.walking] ={ 
		[1] = "UPBODY_LOADED",
	},
	[eAnimState.protest] ={ 
		[1] = "UPBODY_PROTEST",
	},
	[eAnimState.handsup] ={ 
		[1] = "UPBODY_HANDSUP",
	},
}


lowerBodyAnimations = {
	[eAnimState.walking] = {
		[1]="WALKCYCLE_UNLOADED"},
	[eAnimState.wounded] = {
		[1]="WALKCYCLE_WOUNDED"},		
	[eAnimState.coverwalk] = {
		[1]="WALKCYCLE_COVERWALK"},
	[eAnimState.trolley] = {
		[1]="WALKCYCLE_ROLLY"},

}

	
if bodyConfig.boolLoaded == true then
	boolDecoupled=true

	uppperBodyAnimations[eAnimState.walking] = "UPBODY_LOADED"
else
	uppperBodyAnimations[eAnimState.walking] = "SLAVED"
end

accumulatedTimeInSeconds=0
function script.HitByWeapon(x, z, weaponDefID, damage)
	attackerID =Spring.GetUnitLastAttacker(unitID)
	if attackerID and confirmUnit(attackerID) then
	process(getAllNearUnit(unitID, GameConfig.civilianPanicRadius),
			function(id)
					if Spring.GetUnitDefID(id) == myDefID and not GG.DisguiseCivilianFor[unitID] then
						runAwayFrom(id, attackerID, 500)
					end				
				end
			)
	end

	clampedDamage = math.max(math.min(damage,10),35)
	StartThread(delayedWoundedWalkAfterCover,  clampedDamage)
	accumulatedTimeInSeconds = accumulatedTimeInSeconds + clampedDamage
	bodyConfig.boolCoverWalk = true
	bodyConfig.boolLoaded = false
	bodyConfig.boolWounded = true
	bodyBuild()
	StartThread(setAnimationState,getWalkingState(), getWalkingState())
end

function delayedWoundedWalkAfterCover(timeInSeconds)
	Signal(SIG_COVER_WALK)
	SetSignalMask(SIG_COVER_WALK)
	Sleep(accumulatedTimeInSeconds *1000)
	bodyConfig.boolWounded = true
	bodyConfig.boolCoverWalk = false
end


-- Civilian
-- Props:
	-- -Abstract Female and Male Skeletton
	-- - Bags, Luggage, Crates, Trolleys, Rucksack
	-- - Cellphones, Handbags
-- Animation:
	-- Walk Animation:
	-- - walk Cycle
	-- - cowering run Cycle
	-- - run Cycle
	-- - Carrying Animation
	
	-- Idle-Animation:
		-- - talk Cycle, debate-intensity
		-- - stand alone idle: cellphone, smoking, squatting
		-- - prayer
		-- sleep on street
	-- ReactionAnimation:
		-- Catastrophe:
		-- - filming
		-- - whailing
		-- - Protesting
	-- Hit Animation:
		-- - touch Wound/ hold wound
		
	-- AttackAnimation:
		-- - punching
		-- - hitting with stick
		-- - throwing molotow cocktail
	
	-- Death Animation:
		-- - Blasted
		-- - Swirling
		-- - Suprised 
		-- -Collapsing, Shivering, Coiling Up

function setupAnimation()
    local map = Spring.GetUnitPieceMap(unitID);
	local switchAxis = function(axis) 
		if axis == z_axis then return y_axis end
		if axis == y_axis then return z_axis end
		return axis
	end

    local offsets = constructSkeleton(unitID, map.root, {0,0,0});
    
    for a,anim in pairs(Animations) do
        for i,keyframe in pairs(anim) do
            local commands = keyframe.commands;
            for k,command in pairs(commands) do
                -- commands are described in (c)ommand,(p)iece,(a)xis,(t)arget,(s)peed format
                -- the t attribute needs to be adjusted for move commands from blender's absolute values
                if (command.c == "move") then
                    local adjusted =  command.t - (offsets[command.p][command.a]);
                    Animations[a][i]['commands'][k].t = command.t - (offsets[command.p][command.a]);
                end
				
			   Animations[a][i]['commands'][k].a = switchAxis(command.a)	
            end
        end
    end
end

local animCmd = {['turn']=Turn,['move']=Move};

local axisSign ={
	[x_axis]=1,
	[y_axis]=1,
	[z_axis]=1,
}

function PlayAnimation(animname, piecesToFilterOutTable, speed)
	local speedFactor = speed or 1.0
	if not piecesToFilterOutTable then piecesToFilterOutTable ={} end
	assert(animname, "animation name is nil")
assert(type(animname)=="string", "Animname is not string "..toString(animname))
	assert(Animations[animname], "No animation with name ")
    local anim = Animations[animname];
	local randoffset 
    for i = 1, #anim do
        local commands = anim[i].commands;
        for j = 1,#commands do
            local cmd = commands[j];
			randoffset = 0.0
			if cmd.r then
				randVal = cmd.r* 100
				randoffset = math.random(-randVal, randVal)/100
			end
			
			if cmd.ru or cmd.rl then
				randUpVal=	( cmd.ru or 0.01)*100
				randLowVal=	( cmd.rl or 0	)*100
				randoffset = math.random(randLowVal, randUpVal)/100
			end
			
			if  not piecesToFilterOutTable[cmd.p] then	
				animCmd[cmd.c](cmd.p, cmd.a, axisSign[cmd.a] * (cmd.t + randoffset) ,cmd.s*speedFactor)
				
			end
        end
        if(i < #anim) then
            local t = anim[i+1]['time'] - anim[i]['time'];
            Sleep(t*33* math.abs(1/speedFactor)); -- sleep works on milliseconds
        end
    end
end

function constructSkeleton(unit, piece, offset)
    if (offset == nil) then
        offset = {0,0,0};
    end
	
    local bones = {};

    local info = Spring.GetUnitPieceInfo(unit,piece);

    for i=1,3 do
        info.offset[i] = offset[i]+info.offset[i];
    end 

    bones[piece] = info.offset;
    local map = Spring.GetUnitPieceMap(unit);
    local children = info.children;

    if (children) then
        for i, childName in pairs(children) do
            local childId = map[childName];
            local childBones = constructSkeleton(unit, childId, info.offset);
            for cid, cinfo in pairs(childBones) do
                bones[cid] = cinfo;
            end
        end
    end        
    return bones;
end


local	locAnimationstateUpperOverride 
local	locAnimationstateLowerOverride
local	locBoolInstantOverride 
local	locConditionFunction
local	boolStartThread = false

-- allow external behaviour statemachine to be started and stopped, and set
function setBehaviourStateMachineExternal( boolStartStateMachine, State)
	if bodyConfig.boolInfluenced == true then return end
	
	if boolStartStateMachine == true then
		StartThread(beeHaviourStateMachine, State)
	else
		if bodyConfig.boolInfluenced == true then return end
		
		Signal(SIG_BEHAVIOUR_STATE_MACHINE)
		Hide(ak47)
		Explode(ak47, SFX.FALL + SFX_NO_HEATCLOUD)
		bodyConfig.boolArmed = false
		bodyBuild(bodyConfig)
		Command(unitID, "stop")
	end
end

normalBehavourStateMachine = {
	--Normal gamestate is handled external
	[GameConfig.GameState.Anarchy] = function(lastState, currentState)
										-- init clause
										if lastState ~= currentState then
											if bodyConfig.boolArmed == true then
												Show(ak47)
												-- if anarchy and armed then civilians either join a faction (protagon, antagon, or fight against these)	
												--TODO
											else
												playerName = getRandomPlayerName()
												makeProtestSign(8, 3, 34, 62, signMessages[math.random(1,#signMessages)], playerName)
												Show(molotow)
												setOverrideAnimationState(eAnimState.protest, eAnimState.walking, false, function() return GameConfig.GameState.Anarchy == GG.GlobalGameState end  , true)
											end	
											
										end
										
										
										
									end,
	[GameConfig.GameState.PostLaunch]= function(lastState, currentState)
										if unitID%2 == 1 then -- cower catatonic
											setOverrideAnimationState(eAnimState.catatonic, eAnimState.slaved, true, nil, false)
											setSpeedEnv(unitID, 0)
										else -- run around wailing
											setOverrideAnimationState(eAnimState.wailing, eAnimState.walking, true, nil, true)
											x, y,z= Spring.GetUnitPosition(unitID)
											Command(unitID,go, {x = x+ math.random(-100,100), y =y, z =z+ math.random(-100,100)})
										end
									end,
	[GameConfig.GameState.GameOver]= function(lastState, currentState)
											setOverrideAnimationState(eAnimState.catatonic, eAnimState.slaved, true, nil, false)
											setSpeedEnv(unitID, 0)
									end,
	[GameConfig.GameState.Pacification]= function(lastState, currentState)
										boolPlayerUnitNearby, T = isPlayerUnitNearby(unitID, 250)
										if  boolPlayerUnitNearby == true then
											setOverrideAnimationState(eAnimState.handsup, eAnimState.slaved, false, nil, true )
											runAwayFrom(unitID, T[1], 314)
										end
									end,
}

AerosolTypes = getChemTrailTypes()
influencedStateMachine ={
	[AerosolTypes.orgyanyl] = function (lastState, currentState)
							 end,
	[AerosolTypes.wanderlost] = function (lastState, currentState)
							 end,
	[AerosolTypes.tollwutox] = function (lastState, currentState)
							 end,
	[AerosolTypes.depressol] = function (lastState, currentState)
							 end
}

oldBehaviourState =  ""
function beeHaviourStateMachine(newState)
Signal(SIG_BEHAVIOUR_STATE_MACHINE)
SetSignalMask(SIG_BEHAVIOUR_STATE_MACHINE)

	if influencedStateMachine[newState] then
		bodyConfig.boolInfluenced = true
	end
	
	while true do
		if influencedStateMachine[newState] then influencedStateMachine[newState](oldBehaviourState, newState) end
		if normalBehavourStateMachine[newState] then normalBehavourStateMachine[newState](oldBehaviourState, newState) end
		-- Verschiedene States
		Sleep(250)
		oldBehaviourState = newState
	end
end

function threadStarter()
	Sleep(100)
	while true do
		if boolStartThread == true then
			boolStartThread = false
			StartThread(deferedOverrideAnimationState, locAnimationstateUpperOverride, locAnimationstateLowerOverride, locBoolInstantOverride, locConditionFunction)
			while boolStartThread == false do
				Sleep(33)
			end
		end
		Sleep(33)
	end
end

function deferedOverrideAnimationState( AnimationstateUpperOverride, AnimationstateLowerOverride, boolInstantOverride, conditionFunction)
	
	
	if boolInstantOverride == true then
		if AnimationstateUpperOverride then
			-- echo(unitID.." Starting new Animation State Machien Upper")
			UpperAnimationState = AnimationstateUpperOverride
			StartThread(animationStateMachineUpper, UpperAnimationStateFunctions)
		end
		if AnimationstateLowerOverride then
			-- echo(unitID.." Starting new Animation State Machien Lower")
			LowerAnimationState = AnimationstateLowerOverride
			StartThread(animationStateMachineLower, LowerAnimationStateFunctions)
		end
		
	else
		StartThread(setAnimationState, AnimationstateUpperOverride, AnimationstateLowerOverride)
	end
	
	if conditionFunction then StartThread(conditionFunction) end
end

function setAnimationState(AnimationstateUpperOverride, AnimationstateLowerOverride)
	-- if we are already animating correctly early out
	if AnimationstateUpperOverride == UpperAnimationState and AnimationstateLowerOverride == LowerAnimationState then return end

	Signal(SIG_ANIM)
	SetSignalMask(SIG_ANIM)

		if AnimationstateUpperOverride then	boolUpperStateWaitForEnd = true end
		if AnimationstateLowerOverride then boolLowerStateWaitForEnd = true end
		
		
		 while AnimationstateLowerOverride and boolLowerAnimationEnded == false or AnimationstateUpperOverride and boolUpperAnimationEnded == false do
		 Sleep(30)
			if AnimationstateUpperOverride == true then
				boolUpperStateWaitForEnd = true
			end
			 
			if AnimationstateLowerOverride == true then		
				boolLowerStateWaitForEnd = true
			end

	
		 end
			 
		if AnimationstateUpperOverride then	UpperAnimationState = AnimationstateUpperOverride end
		if AnimationstateLowerOverride then LowerAnimationState = AnimationstateLowerOverride end
		if boolUpperStateWaitForEnd == true then	boolUpperStateWaitForEnd = false end
		if boolLowerStateWaitForEnd == true then boolLowerStateWaitForEnd = false end
end

--<Exposed Function>

function setOverrideAnimationState( AnimationstateUpperOverride, AnimationstateLowerOverride,  boolInstantOverride, conditionFunction, boolDecoupledStates)
	boolDecoupled = boolDecoupledStates
	locAnimationstateUpperOverride = AnimationstateUpperOverride
	locAnimationstateLowerOverride = AnimationstateLowerOverride
	locBoolInstantOverride = boolInstantOverride or false
	locConditionFunction = conditionFunction or (function() return true end)
	boolStartThread = true
end

--</Exposed Function>
function conditionalFilterOutUpperBodyTable()
	if boolDecoupled == false  then 
		return {}
	 else
		return upperBodyPieces
	end
end

function showHideProps(selectedIdleFunction, bShow)
	--1 slaved
	if selectedIdleFunction== 2 then
		index = unitID %(#TablesOfPiecesGroups["cellphone"])
		index = math.min(#TablesOfPiecesGroups["cellphone"], math.max(1,index))
		showHide(TablesOfPiecesGroups["cellphone"][index], bShow)
	elseif selectedIdleFunction == 3 then --consumption
		if unitID%2 == 1 then
			showHide(cigarett, bShow)
		else
			showHide(cofee, bShow)
		end
	end

end

function playUpperBodyIdleAnimation()
	 if bodyConfig.boolLoaded == false then
		selectedIdleFunction = (unitID % #uppperBodyAnimations[eAnimState.idle])+1
		showHideProps(selectedIdleFunction, true)
		PlayAnimation(uppperBodyAnimations[eAnimState.idle][selectedIdleFunction])
		showHideProps(selectedIdleFunction, false)
	end
end

UpperAnimationStateFunctions ={
[eAnimState.talking] = 	function () 
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.talking]))			
							return eAnimState.talking
						end,
[eAnimState.standing] = function () 
							Turn(LowArm1, y_axis,math.rad(12),1)
							Turn(LowArm2, y_axis,math.rad(-12),1)
							WaitForTurns(TablesOfPiecesGroups["LowArm"])
								 if boolDecoupled == true then
									if math.random(1,10) > 5 then
									playUpperBodyIdleAnimation()	
									resetT(TablesOfPiecesGroups["UpArm"],math.pi,false,true)
									end
								 end
							Sleep(30)	
							return eAnimState.standing
						end,
[eAnimState.walking] = 	function () 
							if bodyConfig.boolLoaded == false and math.random(1,100) > 50 then
								boolDecoupled = true
									playUpperBodyIdleAnimation()
									WaitForTurns(upperBodyPieces)
									resetT(upperBodyPieces, math.pi,false, true)
								boolDecoupled = false
							elseif bodyConfig.boolLoaded == true then
								PlayAnimation("UPBODY_LOADED")									
							end							
					
						return eAnimState.walking
					end,
[eAnimState.filming] = 	function () 
								cellID= (unitID%2)+1
								Show(TablesOfPiecesGroups["cellphone"][cellID])
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.filming]))								
								Hide(TablesOfPiecesGroups["cellphone"][cellID])
						return eAnimState.filming
					end,					
[eAnimState.wailing] = 	function () 								
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.filming]))								
								
						return eAnimState.wailing
					end,	
[eAnimState.handsup] = 	function () 								
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.handsup]))															
						return eAnimState.handsup
					end,		

[eAnimState.protest] = 	function () 
								 makeProtestSign(8, 3, 34, 62, deterministicElement(unitID, signMessages), getRandomPlayerName())		
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.protest]))															
						return eAnimState.protest
					end,						
					
[eAnimState.slaved] = 	function () 
						Sleep(100)
						return eAnimState.slaved
					end,
[eAnimState.coverwalk] = function()					
						Sleep(100)
						return eAnimState.coverwalk
						end,	
[eAnimState.wounded] = function()					
						Sleep(100)
						return eAnimState.wounded
						end,

}

LowerAnimationStateFunctions ={
[eAnimState.standing] = 	function () 
						-- Spring.Echo("Lower Body standing")
						WaitForTurns(lowerBodyPieces)
						resetT(lowerBodyPieces, math.pi,false, true)
						WaitForTurns(lowerBodyPieces)
						Sleep(10)
						return eAnimState.standing
					end,
[eAnimState.aiming] = 	function () 
						
						WaitForTurns(lowerBodyPieces)
						resetT(lowerBodyPieces, math.pi,false, true)
						WaitForTurns(lowerBodyPieces)
						Sleep(10)
						return eAnimState.aiming
					end,					
[eAnimState.walking] = function()
						

						if bodyConfig.boolWounded == true then
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.wounded],conditionalFilterOutUpperBodyTable()))
							return eAnimState.walking
						end
						
						if bodyConfig.boolTrolley == true then
								PlayAnimation(randT(lowerBodyAnimations[eAnimState.walking]), conditionalFilterOutUpperBodyTable())					
						else
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.walking]), conditionalFilterOutUpperBodyTable())					
						end
						
						return eAnimState.walking
						end,
[eAnimState.transported] = function()
						echo("TODO: Civilian State transported")
						return eAnimState.transported
						end,	
[eAnimState.catatonic] = function()
						echo("TODO: Civilian State catatonic")
						return eAnimState.catatonic
						end,
[eAnimState.coverwalk] = function()					
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.coverwalk]))
							
						echo("TODO: Civilian State coverwalk")
						return eAnimState.coverwalk
						end,	

[eAnimState.wounded] = function()					
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.wounded]))
							
						echo("TODO: Civilian State coverwalk")
						return eAnimState.wounded
						end,							
[eAnimState.trolley] = function()
						
						PlayAnimation(randT(lowerBodyAnimations[eAnimState.trolley]))
						

						return eAnimState.trolley
						end,	
}

LowerAnimationState = eAnimState.standing
boolLowerStateWaitForEnd = false
boolLowerAnimationEnded = false

function animationStateMachineLower(AnimationTable)
Signal(SIG_LOW)
SetSignalMask(SIG_LOW)

boolLowerStateWaitForEnd = false

local animationTable = AnimationTable
	-- Spring.Echo("lower Animation StateMachine Cycle")
	while true do
		assert(LowerAnimationState)
		assert(animationTable[LowerAnimationState], "Animationstate not existing "..LowerAnimationState)
		LowerAnimationState = animationTable[LowerAnimationState]()
		
		--Sync Animations
		--echoNFrames("Unit "..unitID.." :LStatMach :"..LowerAnimationState, 500)
		if boolLowerStateWaitForEnd == true then
			boolLowerAnimationEnded = true
			while boolLowerStateWaitForEnd == true do
				Sleep(33)
				--echoNFrames("Unit "..unitID.." :LWaitForEnd :"..LowerAnimationState, 500)
				-- Spring.Echo("lower Animation Waiting For End")
			end
			boolLowerAnimationEnded = false
		end
	Sleep(33)
	end
end

UpperAnimationState = eAnimState.standing
boolUpperStateWaitForEnd = false
boolUpperAnimationEnded = false

function animationStateMachineUpper(AnimationTable)
Signal(SIG_UP)
SetSignalMask(SIG_UP)

boolUpperStateWaitForEnd = false
local animationTable = AnimationTable

	while true do
		assert(UpperAnimationState)
		assert(animationTable[UpperAnimationState], "Upper Animationstate not existing "..UpperAnimationState)

		UpperAnimationState = animationTable[UpperAnimationState]()
		--echoNFrames("Unit "..unitID.." :UStatMach :"..UpperAnimationState, 500)
		--Sync Animations
		if boolUpperStateWaitForEnd == true then
			boolUpperAnimationEnded = true
			while boolUpperStateWaitForEnd == true do
				Sleep(10)
				--echoNFrames("Unit "..unitID.." :UWaitForEnd :"..UpperAnimationState, 500)
			end
			boolUpperAnimationEnded = false
		end
	Sleep(33)
	end

end

function delayedStop()
	Signal(SIG_STOP)
	SetSignalMask(SIG_STOP)
	Sleep(250)
	-- Spring.Echo("Stopping")
	StartThread(setAnimationState, eAnimState.standing, eAnimState.standing)
end

function getWalkingState()
if bodyConfig.boolCoverWalk == true then return eAnimState.coverwalk end
if bodyConfig.boolWounded == true then return eAnimState.wounded end

return eAnimState.walking
end

function script.StartMoving()
	StartThread(setAnimationState,getWalkingState(), getWalkingState())
end

function script.StopMoving()
	StartThread(delayedStop)
end
---------------------------------------------------------------------ANIMATIONS-------------------------------------
function script.Activate()
    return 1
end

function script.Deactivate()

    return 0
end

function script.QueryBuildInfo()
    return center
end

signMessages ={
	--Denial
	"JUST&NUKE&THEM",
	" SHAME ",
	"THEY &ARE NOT& US",
	"INOCENT",
	"NOT&GUILTY",
	"COULD&BE&WORSER",
	"CONSPIRACY",
	"CHEMTRAJLS DID THIS",
	"GOD SAVE US",
	
	" CITY &FOR AN &CITY",
	" BROTHFRS& KEEPFRS",
	"WE WILL &NOT DIE",
	"VENGANCE IS MURDFR",
	"  IT &CANT BE& US",
	"PUNISH&GROUPS ",
	"VIVE&LA RESISTANCE ",
	"LIES ANDWAR&CRIMES",
	"THE END&IS& NIGH",
	"PHOENIX &FACTION",
	"FOR MAN&KIND",
	"THATS&LIFE",
	"AND LET LIFE",

	"ALWAYS&LCOK ON&BRIGHTSIDE",
	
	--Anger
	"ANTIFA",
	"ROCKET&IS&RAPE",
	"HICBM& UP YOUR ASS",
	"RISE &UP",
	"UNDEFEATED",
	" BURN& THE& BRIDGE",	
	" BURN&THEM& ALL",
	" ANARCHY",
	" FUCK& YOU& ALL",
	" HOPE&  IT&HURTS",
	"VENGANCE IS& OURS",
	"MAD&IS&MURDER",
	"WE& SHALL& REBUILD",
	
	--Bargaining
	" SPARE& US",
	" SPARE& OUR&CHILDREN",
	"ANYTHINGFOR LIFE",
	"NO ISM&WORTH IT",
	"ANARCHY",
	"KILL THE GODS",
	"NO GODS&JUST MEN",
	" SEX&SAVES",
	" MERCY",

	--DEPRESSION
	"HIROSHIMA&ALL OVER",
	" SEX& KILLS",
	" GOD& IS& DEATH",
	"TEARS& IN& RAIN",
	"NEVR &FORGET& LA",
	"REMBR&HONG&KONG",
	"NEVR &FORGET& SA",
	"REMEMBR PALO& ALTO",
	"REMEBR  LAGOS",
	"REMEBR  DUBAI",
	"HITLER&WOULD&BE PROUD",
	"NEVER &AGAIN",
	"  HOLO&  CAUST",
	"IN DUBIO&PRU REO",
	--Accepting
	"NO&CITYCIDE",
	" REPENT& YOUR& SINS",
	"DUST&IN THE&WIND",
	"MAN IS& MEN A& WULF",
	"POMPEJ  ALLOVER",
	"AVENGE&US",
	"SHIT&HAPPENS",
	"FOR WHOM&THE BELL",
	"IS TOLLS&FOR THEE",
	"MEMENTO",
	"MORI",
	"CARPE&DIEM",
	
	--Personification
	"Ü&HAS SMALL&DICK",
	"I&LOVE&Ü",
	"Ü&U HAVE A&SON",
	"Ü&MARRY&ME",
	" DEATH&TO&Ü",
	"  I& BLAME&Ü",
	"WHAT DO&YOU DESIRE?Ü",
	"MUMS&AGAINST&Ü",	
	"HATE Ü",
	"FUCK Ü",
	"Ü IS&EVIL",
	
	
	--Humor
	" PRO&TEST&ICLES",
	"NO MORE&TAXES",
	"PRO&TAXES",
	"NO&PROTEST",
	"NEVER GONNA GIVE",
	"YOU UP",
	"NEVER GONNA LET",
	"YOU DOWN",
}



function makeProtestSign(xIndexMax, zIndexMax, sizeLetterX, sizeLetterZ, sentence, personification)
	for i=1, 26 do
		charOn = string.char(64+i) 
		if TablesOfPiecesGroups[charOn] then
			resetT(TablesOfPiecesGroups[charOn])
			hideT(TablesOfPiecesGroups[charOn])
		end		
	end
	hideT(TablesOfPiecesGroups["Quest"])
	resetT(TablesOfPiecesGroups["Quest"])
	hideT(TablesOfPiecesGroups["Exclam"])
	resetT(TablesOfPiecesGroups["Exclam"])

index = 0
Show(ProtestSign)
alreadyUsedLetter ={} 
sentence = string.gsub(sentence, "Ü", personification or "")

	for i=1, #sentence do
		letter = string.upper(string.sub(sentence, i, i))
		if letter == "!" then letter = "Exclam" end
		if letter == "?" then letter = "Quest" end

			if letter == "&" then 
				index = (index + xIndexMax ) - ((index + xIndexMax)%xIndexMax); 
			else	
				local pieceToMove 
				if TablesOfPiecesGroups[letter] then 
					if  not alreadyUsedLetter[letter] then 
						alreadyUsedLetter[letter]= 1; 
						pieceToMove = TablesOfPiecesGroups[letter][alreadyUsedLetter[letter]]		
					else
					alreadyUsedLetter[letter]= alreadyUsedLetter[letter] +  1; 
						if TablesOfPiecesGroups[letter][alreadyUsedLetter[letter]] then
							pieceToMove = TablesOfPiecesGroups[letter][alreadyUsedLetter[letter]]
						end
					end
				end
				
				if letter == " " then	
					index= index+1
				elseif pieceToMove ~= nil then
					--place and show letter
					assert(pieceToMove)
					Show(pieceToMove)

					xIndex= index % xIndexMax
					zIndex=  math.floor((index/xIndexMax))
					Turn(pieceToMove,z_axis,math.rad(math.random(-2,2)),0)
					Move(pieceToMove,z_axis, zIndex* sizeLetterZ ,0)
					Move(pieceToMove,x_axis, xIndex* sizeLetterX,0)
					index= index + 1
					if zIndex > zIndexMax then return end
				end

			end
	end
	
end
