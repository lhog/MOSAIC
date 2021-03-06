include "createCorpse.lua"
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"

local Animations = include('animations_civilian_female.lua')
local signMessages = include('protestSignMessages.lua')
include "lib_mosaic.lua"
myDefID=Spring.GetUnitDefID(unitID)
TablesOfPiecesGroups = {}

SIG_ANIM = 1
SIG_UP = 2
SIG_LOW = 4
SIG_COVER_WALK= 8
SIG_BEHAVIOUR_STATE_MACHINE = 16
SIG_PISTOL = 32
SIG_MOLOTOW = 64
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
local molotow = piece"molotow"
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

local spGetUnitTeam = Spring.GetUnitTeam
local myTeamID = spGetUnitTeam(unitID)
local gaiaTeamID = Spring.GetGaiaTeamID()
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget 
local loc_doesUnitExistAlive = doesUnitExistAlive

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

catatonicBodyPieces = lowerBodyPieces
catatonicBodyPieces[UpBody] = UpBody
--equipmentname: cellphone, shoppingbags, crates, baby, cigarett, food, stick, demonstrator sign, molotow cocktail

boolWalking = false
boolTurning = false
boolTurnLeft = false
boolDecoupled = false
boolAiming = false

home ={}

loadMax = 8

local bodyConfig={}

	iShoppingConfig = math.random(0,8)
	function variousBodyConfigs()
		
		bodyConfig.boolShoppingLoaded = (iShoppingConfig <= 1)
		bodyConfig.boolCarrysBaby =( iShoppingConfig == 2)
		bodyConfig.boolTrolley = (iShoppingConfig == 3)
		bodyConfig.boolHandbag =( iShoppingConfig == 4)
		bodyConfig.boolLoaded = ( iShoppingConfig <  5)
		bodyConfig.boolProtest = GG.GlobalGameState== GameConfig.GameState.anarchy
	end

function script.Create()
	makeWeaponsTable()
    Move(root,y_axis, -3,0)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)
	StartThread(turnDetector)
	
	variousBodyConfigs()

	bodyConfig.boolArmed = false
	bodyConfig.boolWounded = false
	bodyConfig.boolInfluenced = false
	bodyConfig.boolCoverWalk = false
	home.x,home.y,home.z= Spring.GetUnitPosition(unitID)
	bodyBuild()


	setupAnimation()

	setOverrideAnimationState( eAnimState.standing, eAnimState.standing,  true, nil, false)

	StartThread(threadStarter)

	-- StartThread(testAnimationLoop)
end

function testAnimationLoop()
	Sleep(500)
	while true do

		-- makeProtestSign(8, 3, 34, 62, signMessages[math.random(1,#signMessages)], "RAPHI")
		-- Show(TablesOfPiecesGroups["cellphone"][1])
		-- Show(cigarett)
		-- Show(ShoppingBag)
		-- Show(Handbag)
		-- Show(cofee)
		-- Show(SittingBaby)
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
	if TablesOfPiecesGroups["Hand"] then showT(TablesOfPiecesGroups["Hand"] ) end

	
	if bodyConfig.boolArmed == true  then
		Show(ak47)	
		Show(molotow)
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

---------------------------------------------------------------------ANIMATIONLIB-------------------------------------
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
	[eAnimState.aiming] = { 
		[1] = "UPBODY_AIMING",
	},
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

accumulatedTimeInSeconds=0
function script.HitByWeapon(x, z, weaponDefID, damage)


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

    local offsets = constructSkeleton(unitID, map.center, {0,0,0});
    
    for a,anim in pairs(Animations) do
        for i,keyframe in pairs(anim) do
            local commands = keyframe.commands;
            for k,command in pairs(commands) do
				if command.p and type(command.p)== "string" then
					command.p = map[command.p]
				end
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
		
		Signal(SIG_BEHAVIOUR_STATE_MACHINE)
		if bodyConfig.boolArmed == true then
			Hide(ak47)
			Explode(ak47, SFX.FALL + SFX.NO_HEATCLOUD)
			bodyConfig.boolArmed = false
		end
		
		if bodyConfig.boolProtest == true then
			Explode(ProtestSign, SFX.FALL + SFX.SHATTER + SFX.NO_HEATCLOUD)
		end
		
		bodyBuild(bodyConfig)
		Command(unitID, "stop")
	end
end

normalBehavourStateMachine = {
	[GameConfig.GameState.launchleak] = function(lastState, currentState)
										-- init clause
										if lastState ~= currentState then
											if bodyConfig.boolLoaded == false then
												PlayAnimation("UPBODY_PHONE", lowerBodyPieces)
											end
										end
											
											
										--Going home	
										Command(unitID,go, {x =home.x, y=home.y, z = home.z}, {})
										Command(unitID,go, {x =home.x, y=home.y, z = home.z}, {"shift"})
											
									end,
	[GameConfig.GameState.anarchy] = function(lastState, currentState)
										-- init clause
										if lastState ~= currentState then
											Spring.SetUnitNeutral(unitID, false)
											Spring.SetUnitNoSelect(unitID, true)
											
											bodyConfig.boolArmed = (math.random(1,100) > GameConfig.chanceCivilianArmsItselfInHundred)
											
											if bodyConfig.boolArmed == true then
												Show(ak47)
												Hide(ShoppingBag)
											else
												bodyConfig.boolProtest = (math.random(1,10) > 5)
												if bodyConfig.boolProtest == true then
													playerName = getRandomPlayerName()
													makeProtestSign(8, 3, 34, 62, signMessages[math.random(1,#signMessages)], playerName)
													Show(molotow)
													Hide(ShoppingBag)
													setOverrideAnimationState(eAnimState.protest, eAnimState.walking, false)
												end
											end	

											
											if fairRandom("JoinASide", 5)== true then
												enemy = Spring.GetUnitNearestEnemy(unitID)
												if enemy then
												targetTeamID= Spring.GetUnitTeam(enemy)
													if targetTeamID then
														Spring.TransferUnit(unitID, targetTeamID)
													end
												end
											end											
										end										
									
									
										ad = Spring.GetUnitNearestAlly(unitID)
										if ad then
											x,y,z=Spring.GetUnitPosition(ad)
											Command(unitID, "go" , {x=x,y=y,z=z},{})
										end
										Sleep(1000)
										
										if bodyConfig.boolArmed == true then
											T= getAllNearUnit(unitID, 1024)
											T= process(T, function(id) 
															if isUnitEnemy( myTeamID, id) == true and Spring.GetUnitIsCloaked(id) == false  then 
																return id 
															end
														end)
											if T and #T > 0 then
												ed = randT(T) or Spring.GetUnitNearestEnemy(unitID)
												
												if ed  then
													Command(unitID, "attack" , ed,{})
												end
											end
										end
										Sleep(3000)
										--pick a side - depending on the money
										
										
									end,
	[GameConfig.GameState.postlaunch]= function(lastState, currentState)
										Spring.SetUnitNeutral(unitID, true)
										Spring.TransferUnit(unitID, gaiaTeamID)
										
										if unitID%2 == 1 then -- cower catatonic
											setOverrideAnimationState(eAnimState.catatonic, eAnimState.slaved, true, nil, false)
											setSpeedEnv(unitID, 0)
										else -- run around wailing
											setOverrideAnimationState(eAnimState.wailing, eAnimState.walking, true, nil, true)
											x, y,z= Spring.GetUnitPosition(unitID)
											Command(unitID, "go", {x = x+ math.random(-100,100), y =y, z =z+ math.random(-100,100)})
										end
									end,
	[GameConfig.GameState.gameover]= function(lastState, currentState)
											setOverrideAnimationState(eAnimState.catatonic, eAnimState.slaved, true, nil, false)
											setSpeedEnv(unitID, 0)
									end,
	[GameConfig.GameState.pacification]= function(lastState, currentState)
										if lastState ~= currentState then
											Spring.TransferUnit(unitID, gaiaTeamID)
											Spring.SetUnitNeutral(unitID, true)
											PlayAnimation("UPBODY_HANDSUP")
											setSpeedEnv(unitID, 1.0)
											Turn(UpBody,x_axis, math.rad(0),60)
											Turn(center,x_axis, math.rad(0),45)
											Move(center, y_axis, 0, 60)											
											bodyConfig.boolArmed = false
											bodyConfig.boolProtest = false
											bodyBuild()
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

			Sleep(30)
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
	if boolDecoupled == true or boolAiming == true then 
		return upperBodyPieces
	 else
		return {}
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
[eAnimState.catatonic] = 	function () 
							PlayAnimation(randT(uppperBodyAnimations[eAnimState.wailing]),catatonicBodyPieces)
							Turn(UpBody,x_axis, math.rad(126.2),60)
							Turn(center,x_axis, math.rad(-91.2),45)
							Move(center, y_axis, -60, 60)
							return eAnimState.talking
							end,
[eAnimState.talking] = 	function () 
								if bodyConfig.boolLoaded == false then
									PlayAnimation(randT(uppperBodyAnimations[eAnimState.talking]))	
								end
							return eAnimState.talking
						end,
[eAnimState.standing] = function () 
							Sleep(30)	
							if bodyConfig.boolArmed == true then
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.aiming]),lowerBodyPieces)
								return eAnimState.standing
							end
							
							if bodyConfig.boolProtest == true then
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.protest]), lowerBodyPieces)
								return eAnimState.standing
							end
							
							if bodyConfig.boolLoaded == true then
								return eAnimState.standing
							end
							
							
							if bodyConfig.boolLoaded == false then
								Turn(LowArm1, y_axis,math.rad(12),1)
								Turn(LowArm2, y_axis,math.rad(-12),1)
								WaitForTurns(TablesOfPiecesGroups["LowArm"])
							end
							
							
							if boolDecoupled == true then
								if math.random(1,10) > 5 then
								playUpperBodyIdleAnimation()	
								resetT(TablesOfPiecesGroups["UpArm"],math.pi,false,true)
								end
							 end
							 
							
							return eAnimState.standing
						end,
[eAnimState.walking] = 	function () 
							if bodyConfig.boolArmed == true  then
								PlayAnimation("UPBODY_LOADED")		
								return eAnimState.walking									
							end	

							if bodyConfig.boolProtest == true  then
								return eAnimState.protest									
							end								
						
							if  bodyConfig.boolLoaded == true  then
								PlayAnimation("UPBODY_LOADED")		
								return eAnimState.walking									
							end	

							if bodyConfig.boolLoaded == false then
						
								if math.random(1,100) > 75  then
									playUpperBodyIdleAnimation()
									WaitForTurns(upperBodyPieces)
									-- resetT(upperBodyPieces, math.pi,false, true)
									return eAnimState.walking
								else
									GameFrame= Spring.GetGameFrame()
									Turn(UpArm1, z_axis,math.rad(-25),math.pi)
									Turn(UpArm2, z_axis,math.rad(25),math.pi)
									Turn(UpArm1, x_axis,math.rad(25*math.sin(unitID + GameFrame/15)),math.pi*2)
									Turn(UpArm2, x_axis,math.rad(25*math.cos(unitID + GameFrame/15)),math.pi*2)
									WaitForTurns(upperBodyPieces)
									return eAnimState.walking
								end								
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
		
								PlayAnimation(randT(uppperBodyAnimations[eAnimState.protest]))															
						return eAnimState.protest
					end,						
					
[eAnimState.slaved] = 	function () 
						Sleep(100)
						return eAnimState.slaved
					end,
[eAnimState.coverwalk] = function()		
			
						Hide(ShoppingBag);				
						Hide(SittingBaby);				
						Hide(trolley);			
						Hide(Handbag);
			
						Sleep(100)
							Turn(UpArm1,z_axis,math.rad(0), 7)
							Turn(UpArm1,y_axis,math.rad(0), 7)
							Turn(UpArm1,x_axis,math.rad(-120), 7)
							
							Turn(LowArm1,y_axis,math.rad(0), 7)
							Turn(LowArm1,x_axis,math.rad(-60), 7)
							Turn(LowArm1,z_axis,math.rad(-45), 7)
							
							Turn(UpArm2,x_axis,math.rad(-120), 7)
							Turn(UpArm2,y_axis,math.rad(0), 7)
							Turn(UpArm2,z_axis,math.rad(0), 7)
							
							Turn(LowArm2,x_axis,math.rad(-60), 7)
							Turn(LowArm2,y_axis,math.rad(0), 7)
							Turn(LowArm2,z_axis,math.rad(45), 7)
						return eAnimState.coverwalk
						end,	
[eAnimState.wounded] = function()					
						Sleep(100)
						return eAnimState.wounded
						end,
						
[eAnimState.aiming] = function()					
						Sleep(100)
						PlayAnimation(randT(uppperBodyAnimations[eAnimState.aiming]),lowerBodyPieces)
						return eAnimState.aiming
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
									
						if bodyConfig.boolArmed == true then	
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.walking]), conditionalFilterOutUpperBodyTable())					
							return eAnimState.walking
						end
						
						Turn(center,y_axis, math.rad(0), 12)
							
						if bodyConfig.boolWounded == true then
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.wounded],conditionalFilterOutUpperBodyTable()))
							return eAnimState.walking
						end					
						
						if bodyConfig.boolProtest == true then	
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.walking]), upperBodyPieces)
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
[eAnimState.slaved] = function()
						Sleep(100)
						return eAnimState.slaved
						end,
[eAnimState.coverwalk] = function()					
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.wounded]),upperBodyPieces)							
					
						return eAnimState.coverwalk
						end,	

[eAnimState.wounded] = function()					
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.wounded]))
						return eAnimState.wounded
						end,							
[eAnimState.trolley] = function()
						
						PlayAnimation(randT(lowerBodyAnimations[eAnimState.trolley]))
						

						return eAnimState.trolley
						end,	
[eAnimState.aiming] = 	function () 
						AimDelay=AimDelay+100
						if boolWalking == true  or AimDelay < 1000 then
							AimDelay=0	
							PlayAnimation(randT(lowerBodyAnimations[eAnimState.walking]),upperBodyPieces)	
						elseif AimDelay > 1000 then		

							PlayAnimation(randT(lowerBodyAnimations[eAnimState.standing]),upperBodyPieces)	
						end
						Sleep(100)
						return eAnimState.aiming
					end			
						
}

AimDelay = 0
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
	boolWalking = false
	-- Spring.Echo("Stopping")
	setOverrideAnimationState(eAnimState.standing, eAnimState.standing,  true, nil, true)
end

function getWalkingState()
if bodyConfig.boolCoverWalk == true then return eAnimState.coverwalk end
if bodyConfig.boolWounded == true then return eAnimState.wounded end

return eAnimState.walking
end

function script.StartMoving()
	boolWalking = true
	setOverrideAnimationState(eAnimState.walking, eAnimState.walking,  true, nil, true)
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


function akAimFunction(weaponID, heading, pitch)
	if bodyConfig.boolArmed == false or oldBehaviourState ~= GameConfig.GameState.anarchy then
		return false 
	end
	
	boolAiming = true
	setOverrideAnimationState(eAnimState.aiming, eAnimState.standing,  true, nil, false)
	WTurn(center,y_axis,heading, 22)
	WaitForTurns(UpArm1, UpArm2, LowArm1,LowArm2)
	boolAiming = false
return  allowTarget(weaponID)
end
 
function molotowAimFunction(weaponID, heading, pitch)
-- if true == true then return true end
	-- Aim Animation
return  allowTarget(weaponID)
end

function akFireFunction(weaponID, heading, pitch)
	boolAiming = false
	return true
end

function molotowFireFunction(weaponID, heading, pitch)
	return true
end



WeaponsTable = {}
function makeWeaponsTable()
    WeaponsTable[1] = { aimpiece = center, emitpiece = ak47, aimfunc = akAimFunction, firefunc = akFireFunction, signal = SIG_PISTOL }
    WeaponsTable[2] = { aimpiece = Head1, emitpiece = cellphone1, aimfunc = molotowAimFunction, firefunc = molotowFireFunction, signal = SIG_MOLOTOW }
end

function script.AimFromWeapon(weaponID)
    if WeaponsTable[weaponID] then
        return WeaponsTable[weaponID].aimpiece
    else
        return ak47
    end
end

function script.QueryWeapon(weaponID)
    if WeaponsTable[weaponID] then
        return WeaponsTable[weaponID].emitpiece
    else
        return ak47
    end
end

function script.AimWeapon(weaponID, heading, pitch)
    if WeaponsTable[weaponID] then
        if WeaponsTable[weaponID].aimfunc then
            return WeaponsTable[weaponID].aimfunc(weaponID, heading, pitch)
        else
            WTurn(WeaponsTable[weaponID].aimpiece, y_axis, heading, turretSpeed)
            WTurn(WeaponsTable[weaponID].aimpiece, x_axis, -pitch, turretSpeed)
            return allowTarget(weaponID)
        end
    end
    return false
end


function allowTarget(weaponID)
	
	return true
end
function script.Killed(recentDamage, _)
-- TODO Test
 --   --createCorpseCUnitGeneric(recentDamage)
    return 1
end
