include "createCorpse.lua"
include "lib_OS.lua"
include "lib_UnitScript.lua"
include "lib_Animation.lua"
include "lib_Build.lua"

local Animations = include('animations_civilian_female.lua')

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



local spGetUnitTeam = Spring.GetUnitTeam
local myTeamID = spGetUnitTeam(unitID)
local gaiaTeamID = Spring.GetGaiaTeamID()
local spGetUnitWeaponTarget = Spring.GetUnitWeaponTarget 
local loc_doesUnitExistAlive = doesUnitExistAlive

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
	function variousBodyConfigs()
	
	bodyConfig.boolShoppingLoaded = (iShoppingConfig == 1)
	bodyConfig.boolCarrysBaby =( iShoppingConfig == 2)
	bodyConfig.boolTrolley = (iShoppingConfig == 3)
	bodyConfig.boolHandbag =( iShoppingConfig == 4)
	bodyConfig.boolLoaded = ( iShoppingConfig <  5)
	end

function script.Create()
    Move(root,y_axis, -3,0)
    TablesOfPiecesGroups = getPieceTableByNameGroups(false, true)
	StartThread(turnDetector)
	hideAll(unitID)
	variousBodyConfigs()

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
		-- Show(ShoppingBag)
		-- Show(Handbag)
		-- Show(cofee)
		-- Show(SittingBaby)
		-- Show(ak47)
		
		-- PlayAnimation("UPBODY_LOADED", nil, 1.0)
	
		Sleep(100)
	end
end

function bodyBuild()




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

 --   --createCorpseCUnitGeneric(recentDamage)
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
		if bodyConfig.boolInfluenced == true then return end
		
		Signal(SIG_BEHAVIOUR_STATE_MACHINE)
		Hide(ak47)
		Explode(ak47, SFX.FALL + SFX.NO_HEATCLOUD)
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
											runAwayFrom(unitID, T[1], GameConfig.civilianPanicRadius)
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
