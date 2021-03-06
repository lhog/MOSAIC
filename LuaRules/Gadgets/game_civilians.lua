function gadget:GetInfo()
	return {
		name = "Civilian City and Inhabitants Gadget",
		desc = "Coordinates Traffic ",
		author = "Picasso",
		date = "3rd of May 2010",
		license = "GPL3",
		layer = 3,
		version = 1,
		enabled = false
	}
end

if (not gadgetHandler:IsSyncedCode()) then
    return false
end

	VFS.Include("scripts/lib_OS.lua")
	VFS.Include("scripts/lib_UnitScript.lua")
	VFS.Include("scripts/lib_Animation.lua")
	VFS.Include("scripts/lib_Build.lua")
	VFS.Include("scripts/lib_mosaic.lua")
	
	statistics ={}
	local GameConfig = getGameConfig()
	local spGetUnitPosition = Spring.GetUnitPosition
	local spGetUnitDefID = Spring.GetUnitDefID
	local currentGlobalGameState = GG.GlobalGameState or  GameConfig.GameState.normal
	local UnitDefNames = getUnitDefNames(UnitDefs)
	local PoliceTypes = getPoliceTypes(UnitDefs)
	
	local 	activePoliceUnitIds_DispatchTime = {}
	local maxNrPolice = GameConfig.maxNrPolice
	local _,AllCiviliansTypeTable = getCivilianTypeTable(UnitDefs)
	local scrapHeapTypeTable = getScrapheapTypeTable(UnitDefs)
	local activePoliceUnitIds_Dispatchtime ={}
	local MobileCivilianDefIds = getMobileCivilianDefIDTypeTable(UnitDefs)
	local CivAnimStates = getCivilianAnimationStates()
	local PanicAbleCivliansTable = getPanicableCiviliansTypeTable(UnitDefs)
	local TimeDelayedRespawn ={}
		  BuildingWithWaitingRespawn={}
	
	GG.CivilianTable = {} --[id ] ={ defID, startNodeID }
	GG.UnitArrivedAtTarget = {} --[id] = true UnitID -- Units report back once they reach this target
	GG.BuildingTable= {} --[BuildingUnitID] = {routeID, stationIndex}
	local BuildingPlaceTable={} -- SizeOf Map/Divide by Size of Building
	local uDim ={}
	uDim.x,uDim.y,uDim.z = GameConfig.houseSizeX + GameConfig.allyWaySizeX, GameConfig.houseSizeY, GameConfig.houseSizeZ+ GameConfig.allyWaySizeZ	
	numberTileX, numberTileZ = Game.mapSizeX/uDim.x, Game.mapSizeZ/uDim.z
	local RouteTabel = {} --Every start has a subtable of reachable nodes 	
	boolInitialized = false

	local TruckTypeTable = getCultureUnitModelTypes(GameConfig.instance.culture, "truck", UnitDefs)
	assert(TruckTypeTable[UnitDefNames["truck_arab0"].id]==UnitDefNames["truck_arab0"].id)
	local houseTypeTable = getCultureUnitModelTypes(GameConfig.instance.culture, "house", UnitDefs)
	local civilianWalkingTypeTable = getCultureUnitModelTypes(GameConfig.instance.culture, "civilian", UnitDefs)
	local gaiaTeamID = Spring.GetGaiaTeamID()
	

	function getPoliceSpawnLocation(suspect)
		sx,sy,sz = spGetUnitPosition(suspect)
		Tmax = getAllNearUnit(suspect, GameConfig.policeSpawnMinDistance)
		Tmin = getAllNearUnit(suspect, GameConfig.policeSpawnMaxDistance)
		T= removeDictFromDict(Tmax, Tmin)
		T= process(T,
				function (id)
					if  houseTypeTable[spGetUnitDefID(id)] then
						return id
					end
				end
				)
				
		randDeg =math.random(1,360)
		px, pz = Rotate(0,GameConfig.policeSpawnMaxDistance, math.rad(randDeg))
		px,pz = px+ sx, pz+sz
		
		if count(T) > 0 then
			element= randT(T)
			dx,py,dz = spGetUnitPosition(element)		
			if dx then
				px, pz= dx, dz
			end
		end
		

	return px,0,pz
	end
	
	function UnitSetAnimationState(unitID, AnimationstateUpperOverride, AnimationstateLowerOverride, boolInstantOverride, boolDeCoupled)
	  env = Spring.UnitScript.GetScriptEnv(unitID)
        if env and env.setOverrideAnimationState then

			Spring.UnitScript.CallAsUnit(unitID, env.setOverrideAnimationState,  AnimationstateUpperOverride, AnimationstateLowerOverride, boolInstantOverride or false, conditionFunction or nil, boolDeCoupled)
        end
	end

	function makePasserBysLook(unitID)
		ux,uy,uz= spGetUnitPosition(unitID)
		process(getInCircle(unitID, GameConfig.civilianInterestRadius, gaiaTeamID),
			function(id)
				--filter out civilians
				if  id then
				defID = spGetUnitDefID(id)				
					if defID and PanicAbleCivliansTable[defID] then
						return id
					end
				end
			end,
			function(id)
				if math.random(0,100) > GameConfig.inHundredChanceOfInterestInDisaster then			
					offx, offz= math.random(0,10)*randSign(), math.random(0,10)*randSign()
					Command(id, "go", { x=  ux+ offx, y=  uy, z = uz+ offz}, {})
					--TODO Set Behaviour filming
					UnitSetAnimationState(id, CivAnimStates.filming, CivAnimStates.walking, true, true)
					
				elseif math.random(0,100) > GameConfig.inHundredChanceOfDisasterWailing then			
					offx, offz= math.random(0,10)*randSign(), math.random(0,10)*randSign()
					Command(id, "go", { x=  ux+ offx, y=  uy, z = uz+ offz}, {})
					UnitSetAnimationState(id, CivAnimStates.wailing, CivAnimStates.walking, true, true)
					
				end
			end
			)
	
	end
	
	function gadget:UnitCreated(unitID, unitDefID, teamID)
		if PoliceTypes[unitDefID] then
			maxNrPolice = math.max( maxNrPolice - 1, 0)
		end
	end
	
	function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID)
	if PoliceTypes[unitDefID] then
		activePoliceUnitIds_DispatchTime[unitID] = nil
		maxNrPolice = math.min( maxNrPolice +1, GameConfig.maxNrPolice)
	end
	
		--Spring.Echo("Unit "..unitID .." of type "..UnitDefs[unitDefID].name .. " destroyed")
		-- if building, get all Civilians/Trucks nearby in random range and let them get together near the rubble
		if teamID == gaiaTeamID and attackerID then

			makePasserBysLook(unitID)
			--other gadgets worries about propaganda price
			if houseTypeTable[unitDefID] then
				rubbleHeapID = spawnRubbleHeapAt(unitID)
				
				-- checkReSpawnHouses()
				-- regenerateRoutesTable()
			end
		end
	end
	
	function spawnRubbleHeapAt(id)
		x,y,z = spGetUnitPosition(id)
		if x then
		
			rubbleHeapID= Spring.CreateUnit(randDict(scrapHeapTypeTable),x,y,z, 1, gaiaTeamID)
			TimeDelayedRespawn[rubbleHeapID] ={
			frame= GameConfig.TimeForScrapHeapDisappearanceInMs,
			x= x, z= z, bID = id}
			BuildingWithWaitingRespawn[id]= true
		end	
	end
	
	function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
		if MobileCivilianDefIds[unitDefID] then
			attackerID =  Spring.GetUnitLastAttacker(unitID) 
			if attackerID and isUnitAlive(attackerID) == true then
				
				officerID = nil
				if maxNrPolice > 0 then				
					px,py,pz = getPoliceSpawnLocation(attackerID)
					direction = math.random(1,4)
					officerID = Spring.CreateUnit("policetruck",px,py,pz, direction, gaiaTeamID)
					activePoliceUnitIds_DispatchTime[officerID] = GameConfig.policeMaxDispatchTime + math.random(1, GameConfig.policeMaxDispatchTime)	
				else --reasign one
					officerID = randDict(activePoliceUnitIds_DispatchTime)		
					activePoliceUnitIds_DispatchTime[officerID] = GameConfig.policeMaxDispatchTime	+ math.random(1, GameConfig.policeMaxDispatchTime)			
				end
				
				if officerID then
					if not GG.PoliceInPursuit then GG.PoliceInPursuit={} end
					GG.PoliceInPursuit[officerID]= attackerID 
					Command(officerID, "attack", {attackerID},  4)	
							

				end
			end
		end
	end
	
	BuildingPlaceTable = makeTable(true, Game.mapSizeX/uDim.x, Game.mapSizeZ/uDim.z)	 
	startindex = 1
	function distributedPathValidationComplete(frame, elements)
		oldstartindex = startindex
		
		boolComplete = false
		startindex = validateBuildSpotsReachable(startindex, math.min(startindex + elements, #BuildingPlaceTable))
		-- echo("Pathingpercentage: ", startindex/((#BuildingPlaceTable)))
		if startindex >= #BuildingPlaceTable then boolComplete = true end
		
		return boolComplete
	end
	
	-- check Traversability from each position to the previous position	
	function validateBuildSpotsReachable(start, endindex)
		tileX, tileZ = uDim.x, uDim.z
		
		for x=start, endindex, 1 do	
			for z=1,#BuildingPlaceTable[1] do
				startx, startz = x * tileX, z * tileZ
				
				PlacesReachableFromPosition = 0
				local boolEarlyOut
				for xi=1,#BuildingPlaceTable do
					for zi=1,#BuildingPlaceTable[1] do
						if xi~= x or zi~= z then
							endx, endz = xi*tileX, zi*tileZ
							
							if Spring.RequestPath(UnitDefNames["truck_arab0"].moveDef.name , startx,0,startz,endx,0,endz) then
								PlacesReachableFromPosition = PlacesReachableFromPosition + 1
								if PlacesReachableFromPosition > 5 then
									dx, dy, dz, slope =Spring.GetGroundNormal(x*tileX,z*tileZ)
									
									BuildingPlaceTable[x][z] = Spring.GetGroundHeight(x*tileX,z*tileZ) > 5 and slope < 0.2
									boolEarlyOut = true
									break;
								end
							end
						end
					end
					if boolEarlyOut then
						break
					end
				end				
			end
		end
		
		return endindex +1
	end
	
	function cursorIsOnMainRoad(cursor,sx,sz)
		return( (cursor.x-sx) % GameConfig.mainStreetModulo == 0 ) or ((cursor.z-sz) % GameConfig.mainStreetModulo == 0 )
	end
	
	function clampCursor(cursor)
		cursor.x = math.max(1,math.min(cursor.x, math.floor(Game.mapSizeX/uDim.x)))
		cursor.z = math.max(1,math.min(cursor.z, math.floor(Game.mapSizeZ/uDim.z)))
		return cursor
	end
	
	function randomWalk(cursor)
		return {x = cursor.x + randSign(), z = cursor.z + randSign()}
	end
	
	function mirrorCursor(cursor, cx,cz)
		x,z = cx - cursor.x, cz - cursor.z
		return {x= cx +x , z= cz +z} 
	end
	
	--spawns intial buildings
	function fromMapCenterOutwards(BuildingPlaceT,startx, startz)
		
		local finiteSteps= GameConfig.maxIterationSteps
		cursor ={x=startx, z=startz}
		mirror = {x=startx, z=startz}
		local numberOfBuildings = GameConfig.numberOfBuildings -1
		
		while finiteSteps > 0 and numberOfBuildings > 0 do
			finiteSteps = finiteSteps -1
			
			dice= math.floor(math.random(10,30)/10)		
			if dice == 1 then 	--1 random walk into a direction doing nothing
				cursor = randomWalk(cursor)
				cursor = clampCursor(cursor)
				mirror = mirrorCursor(cursor, startx, startz)
				mirror = clampCursor(mirror)
				-- Spring.Echo("dice 1")
			elseif dice == 2 then --2 place a single block
				boolFirstPlaced= false
				if BuildingPlaceT[cursor.x][cursor.z] == true and cursorIsOnMainRoad(cursor,startx,startz) == false then
					buildingType = randDict(houseTypeTable)				
					spawnBuilding(buildingType, 
					cursor.x * uDim.x,
					cursor.z * uDim.z,
					(GameConfig.numberOfBuildings-numberOfBuildings),
					1
					)
					numberOfBuildings = numberOfBuildings -1
					BuildingPlaceT[cursor.x][cursor.z] = false
					boolFirstPlaced = true
					-- Spring.Echo("dice 2.1")
				end
				
				if boolFirstPlaced == true and BuildingPlaceT[mirror.x][mirror.z] == true and cursorIsOnMainRoad(mirror, startx,startz) == false then
					buildingType = randDict(houseTypeTable)
					spawnBuilding(buildingType, 
					mirror.x * uDim.x,
					mirror.z * uDim.z,
					(GameConfig.numberOfBuildings-numberOfBuildings),
					1
					)
					numberOfBuildings = numberOfBuildings -1
					BuildingPlaceT[mirror.x][mirror.z] = false
					-- Spring.Echo("dice 2.2")
				end
				
			elseif dice == 3 then
				numberOfBuildings, BuildingPlaceT = placeThreeByThreeBlockAroundCursor(cursor, numberOfBuildings, BuildingPlaceT)
				numberOfBuildings, BuildingPlaceT = placeThreeByThreeBlockAroundCursor(mirror, numberOfBuildings, BuildingPlaceT)
				-- Spring.Echo("dice 3")
			end
		end
	end
	
	function placeThreeByThreeBlockAroundCursor(cursor, numberOfBuildings, BuildingPlaceT)
		for offx = -1, 1, 1 do
			if 	BuildingPlaceT[cursor.x + offx] then
				for offz = -1, 1, 1 do 
					local tmpCursor= cursor
					tmpCursor.x = tmpCursor.x + offx ;	tmpCursor.z = tmpCursor.z + offz
					tmpCursor = clampCursor(tmpCursor)
					buildingType = randDict(houseTypeTable)
					if 	BuildingPlaceT[tmpCursor.x][tmpCursor.z] == true then
						spawnBuilding(
						buildingType, 
						tmpCursor.x * uDim.x,
						tmpCursor.z * uDim.z,
						(GameConfig.numberOfBuildings-numberOfBuildings),
						1
						)
						numberOfBuildings=numberOfBuildings-1
						BuildingPlaceT[tmpCursor.x][tmpCursor.z] = false
					end 
				end 
			end 
		end
		
		return numberOfBuildings, BuildingPlaceT
	end
	
	function spawnInitialPopulation(frame)
		-- create Grid of all placeable Positions
		-- great Grid of placeable Positions 
		if distributedPathValidationComplete(frame, 10) == true then
			
			
			-- spawn Buildings from MapCenter Outwards
			fromMapCenterOutwards(BuildingPlaceTable, math.ceil((Game.mapSizeX/uDim.x)*0.5), math.ceil((Game.mapSizeZ/uDim.z)*0.5))
			
		--	echo("regenerateRoutesTable()")
			regenerateRoutesTable()
			
			-- spawn Population at Buildings
		--	echo("checkReSpawnPopulation()")
			checkReSpawnPopulation()
			
			checkReSpawnTraffic()
			
			-- give Arrived Units Commands
			sendArrivedUnitsCommands()
			boolInitialized = true
		end
	end
	function checkReSpawnHouseAt(x,z, bID)
			dataToAdd= {}	
			GG.BuildingTable[bID]= nil
			buildingType = randDict(houseTypeTable)
			id = spawnBuilding(buildingType, x, z)
			dataToAdd[id] = {x=x,z=z}
			GG.BuildingTable[id] = dataToAdd[id]

	end
	
	
	
	function checkReSpawnHouses()
		dataToAdd= {}
		for bID, routeData in pairs(GG.BuildingTable) do
			local routeDataCopy = routeData
			if doesUnitExistAlive(bID) ~= true and  BuildingWithWaitingRespawn[bID] == nil then
				GG.BuildingTable[bID]= nil
				
				x, z = routeDataCopy.x, routeDataCopy.z
				buildingType = randDict(houseTypeTable)
				id = spawnBuilding(buildingType, x, z)
				dataToAdd[id] = routeDataCopy
			end
		end
		
		for id, routeData in pairs(dataToAdd) do
			GG.BuildingTable[id] = routeData
		end
	end
	
	function checkReSpawnPopulation()
		counter = 0
		nilTable={}
		for id, data in pairs(GG.CivilianTable) do
			if id and civilianWalkingTypeTable[data.defID] then
				if doesUnitExistAlive(id) == true then
					counter = counter + 1
				else
					nilTable[id] = true
				end
			end
		end
		
		for id, data in pairs(nilTable) do
			GG.CivilianTable[id]= nil
		end
		
		if counter < GameConfig.numberOfPersons then
		Spring.Echo("Spawning "..(GameConfig.numberOfPersons - counter).." nr of persons")
			for i=1, GameConfig.numberOfPersons - counter do
				x,_,z, startNode = getRandomSpawnNode()
				--assert(z)
				--assert(x)
				--assert(startNode)
				--assert(RouteTabel[startNode])
				goalNode = RouteTabel[startNode][math.random(1,#RouteTabel[startNode])]
				civilianType = randDict(civilianWalkingTypeTable)
				id = spawnAMobileCivilianUnit(civilianType, x,z, startNode, goalNode )	
				if id then
					GG.UnitArrivedAtTarget[id] = true
				end
			end
		
		end	
	end
	
	function checkReSpawnTraffic()
		counter = 0
		nilTable={}
		for id, data in pairs(GG.CivilianTable) do
			if id and TruckTypeTable[data.defID] then
				if doesUnitExistAlive(id) == true then
					counter = counter + 1
				else
					nilTable[id] = true
				end
			end
		end
		
		for id, data in pairs(nilTable) do
			GG.CivilianTable[id]= nil
		end
		
		if counter < GameConfig.numberOfVehicles then
		echo("Spawning "..(GameConfig.numberOfVehicles - counter).." nr of vehicles")
			for i=1, GameConfig.numberOfVehicles - counter do
				x,_,z, startNode = getRandomSpawnNode()
				
				--assert(RouteTabel[startNode])
				goalNode = RouteTabel[startNode][math.random(1,#RouteTabel[startNode])]
				TruckType = randDict(TruckTypeTable)
				id = spawnAMobileCivilianUnit(TruckType, x,z, startNode, goalNode )	
				if id then
					GG.UnitArrivedAtTarget[id] = true
				end
			end
		end	
	end
	
	function getRandomSpawnNode()
		startNode = randT(RouteTabel)
		--assert(doesUnitExistAlive(startNode) == true)
		--assert(startNode)
		x,y,z= spGetUnitPosition(startNode)
		--assert(x)
		--assert(z)
		return x,y,z , startNode
	end
	
	function buildRouteSquareFromTwoUnits(unitOne, unitTwo, uType)
		--assert(unitOne)
		--assert(unitTwo)

		local Route = {}
		
		x1,y1, z1 = spGetUnitPosition(unitOne)
		x2, y2, z2 = spGetUnitPosition(unitTwo)
		index= 1
		Route[index]= {}
		Route[index].x = x1
		Route[index].z = z1
		index = index + 1
		Route[index]= {}


		boolLongWay = distance(x1,y1,z1,x2,y2,z2) > 2048 
		
		if boolLongWay == false then				
			
			
			if Spring.GetGroundHeight(x1, z2) > 5 then
				Route[index].x = x1
				Route[index].z = z2
				index = index + 1
				Route[index]= {}
			end
		end
		
		Route[index].x = x2
		Route[index].z = z2
		index = index + 1
		Route[index]= {}
		
		if boolLongWay == false then
			if Spring.GetGroundHeight(x2, z1) > 5 then
				Route[index].x = x2
				Route[index].z = z1
				index = index + 1
				Route[index]= {}
			end		
		end		
		
		Route[index].x = x1
		Route[index].z = z1
		
		return testClampRoute(Route,uType)
	end
	
	function regenerateRoutesTable()
		local newRouteTabel={}
		TruckType = randDict(TruckTypeTable)
		for thisBuildingID, data in pairs(GG.BuildingTable) do--[BuildingUnitID] = {x=x, z=z} 
			newRouteTabel[thisBuildingID]={}
			for otherID, oData in pairs(GG.BuildingTable) do--[BuildingUnitID] = {x=x, z=z} 		
				if thisBuildingID ~= otherID and isRouteTraversable(TruckType, thisBuildingID, otherID ) then
					newRouteTabel[thisBuildingID][# newRouteTabel[thisBuildingID]+1] = otherID
				end
			end
		end
		RouteTabel = newRouteTabel
	end
	
	function isRouteTraversable(defID, unitA, unitB)
		vA = getUnitPositionV(unitA)
		vB = getUnitPositionV(unitB)
		
		path = 	Spring.RequestPath(UnitDefNames["truck_arab0"].moveDef.id ,
		vA.x,vA.y,vA.z,
		vB.x,vB.y,vB.z)
		
		return path ~= nil
	end
	
	function spawnUnit(defID, x,z)	
		dir = math.max(1, math.floor(math.random(1, 3)))
			if not x then echo("Spawning unit of typ "..UnitDefs[defID].name .." with no coords") end
		h = Spring.GetGroundHeight(x,z)
		id = Spring.CreateUnit(defID, x, h, z, dir, gaiaTeamID)
		
		if not statistics[defID] then statistics[defID]= 0 end
		statistics[defID] = statistics[defID]+1
		
		if id then
			Spring.SetUnitNoSelect(id, true)
			Spring.SetUnitAlwaysVisible(id, true)
			return id
		end
	end
	
	-- truck or Person
	function spawnAMobileCivilianUnit(defID, x, z, startID, goalID)
	
		--offx, offz = randSign()*(GameConfig.houseSizeX/2),randSign()*(GameConfig.houseSizeZ/2)
		id = spawnUnit(defID,x ,z)
		if id then 
			--assert(goalID)
			--assert(startID)
			GG.CivilianTable [id] = {defID = defID, startID =startID, goalID = goalID}
			GG.UnitArrivedAtTarget[id]= defID
		end
	end
	
	function spawnBuilding(defID, x, z)
		
		id = spawnUnit(
		defID,
		x + math.random(-1* GameConfig.xRandOffset,GameConfig.xRandOffset),
		z + math.random(-1* GameConfig.zRandOffset,GameConfig.zRandOffset)
		)
		
		if id then 
			Spring.SetUnitAlwaysVisible(id, true)
			Spring.SetUnitBlocking(id, false)
			GG.BuildingTable[id] = {x=x, z=z}
			return id
		end
	end
	
	function gadget:Initialize()
	--Initialize global tables
	GG.DisguiseCivilianFor={}
	 GG.DiedPeacefully = {}


	--	Spring.Echo("gadget:Initialize")
		process(Spring.GetAllUnits(),
		function(id)
			Spring.DestroyUnit(id,true,true)
		end
		)
		
	end
	
	travellFunction = function(evtID, frame, persPack, startFrame)
		--	only apply if Unit is still alive
		myID = persPack.unitID
		if Spring.GetUnitIsDead(myID) == true then
			return nil, persPack
		end
		
		-- <External GameState Handling>
		-- abort if aerosol afflicted
		if GG.AerosolAffectedCivilians and GG.AerosolAffectedCivilians[myID] then 
			return nil, persPack
		end
		
		if not 	persPack.boolAnarchy then 	persPack.boolAnarchy = false end
		
		if  GG.GlobalGameState and GG.GlobalGameState == GameConfig.GameState.normal and persPack.boolAnarchy == true then
			setCivilianBehaviourMode(myID, false)
			persPack.boolAnarchy = false
		end
		
		if  GG.GlobalGameState and GG.GlobalGameState ~= GameConfig.GameState.normal then
			setCivilianBehaviourMode(myID, true, GG.GlobalGameState )
			persPack.boolAnarchy = true
			return frame + math.random(30*5,30*25) , persPack
		end			
		-- </External GameState Handling>
		
		hp = Spring.GetUnitHealth(myID)
		if not persPack.myHP then persPack.myHP = hp end
		
		x,y,z = spGetUnitPosition(myID)
		if not x then 
			return nil, persPack
		end
		
		if not persPack.currPos then
			persPack.currPos ={x=x,y=y,z=z}
			persPack.stuckCounter=0
		end
		
		if distance(x,y,z, persPack.currPos.x,persPack.currPos.y,persPack.currPos.z) < 100 then				
			persPack.stuckCounter=persPack.stuckCounter+1
		else
			persPack.currPos={x=x,y=y,z=z}
			persPack.stuckCounter=0
		end
		
		--if stuck move towards the next goal
		if persPack.stuckCounter == 4 then
			persPack.goalIndex = math.min(persPack.goalIndex + 1,#persPack.goalList)
			persPack.stuckCounter = 0
		end
		
		if persPack.stuckCounter > 5 then
			Spring.DestroyUnit(myID,true,true)
			return nil, nil
		end
		--we where obviously attacked - flee from attacker
		if persPack.myHP < hp then
			attackerID = Spring.GetUnitLastAttacker(myID)
			if attackerID and isUnitAlive(attackerID)== true then
				--panic ends with distance
				if distanceUnitToUnit (id, attackerID) > GameConfig.civilianPanicRadius then persPack.myHP = hp end
				runAwayFrom(myID, attackerID, 500)
				UnitSetAnimationState(id, CivAnimStates.slaved, CivAnimStates.coverwalk, true, false)
				return frame + 30 , persPack
			end
		end
		
		---ocassionally detour toward the nearest ally or enemy
		if math.random(0, 42) > 35 and civilianWalkingTypeTable[persPack.mydefID]  then
			local partnerID
			
			if math.random(0,1)==1 then
				partnerID = Spring.GetUnitNearestAlly(myID)
			else
				partnerID = Spring.GetUnitNearestEnemy(myID)
			end
			
			if partnerID and distanceUnitToUnit(myID, partnerID) < GameConfig.generalInteractionDistance then
				px,py,pz= spGetUnitPosition(partnerID)
				Command(myID, "go", {x= px ,y= py ,z=pz}, {})
				Command(partnerID, "go", {x= px + math.random(-20,20) ,y= py ,z=pz+ math.random(-20,20)}, {})
			
				--assemble a small group for communication 
				if math.random(0,1)==1 then
	
					T= process(getAllNearUnit(myID, GameConfig.groupChatDistance),
					function (id)
						if Spring.GetUnitTeam(id) == persPack.myTeam and civilianWalkingTypeTable[spGetUnitDefID(id)] then 
							return id
						end
					end,
					function(id)
						if distanceUnitToPoint(id, myID) > GameConfig.groupChatDistance/2 then
							Command(id, "go", {x= px + math.random(-20,20) ,y= py ,z=pz+ math.random(-20,20)}, {})
							UnitSetAnimationState(id, CivAnimStates.Talking, CivAnimStates.walking, true, true)
						else
							Command(id, "stop")
							UnitSetAnimationState(id, CivAnimStates.Talking, CivAnimStates.stop, true, true)

						end
						
						
						return id
					end
					)
			
				end
				
				return frame + math.random(GameConfig.minConversationLengthFrames, GameConfig.maxConversationLengthFrames) , persPack
			end
		end
		
		--if near Destination increase goalIndex
		if distanceUnitToPoint(myID, 
		persPack.goalList[persPack.goalIndex].x,
		0,
		persPack.goalList[persPack.goalIndex].z)
		< (GameConfig.houseSizeX + GameConfig.houseSizeZ)/2 + 40 then
			persPack.goalIndex = persPack.goalIndex + 1
			
			if persPack.goalIndex > #persPack.goalList then						
				GG.UnitArrivedAtTarget[myID] = true
				return nil, persPack
			end					
		end			
		
		--only issue commands if not moving for a time - prevents repathing frame drop of 15 fps
		if persPack.stuckCounter > 1 then
			Command(myID, "go",  {x=persPack.goalList[persPack.goalIndex].x,y=0,z=persPack.goalList[persPack.goalIndex].z}, {})
		end
		return frame +  math.random(60,90), persPack
	end	
	
	function giveWaypointsToUnit(uID, uType, startNodeID)
		boolIsCivilian = ( civilianWalkingTypeTable[uType] ~= nil)
		boolShortestPath= ( math.random(0,1)== 1 and TruckTypeTable[uType] == nil )-- direct route to target

		targetNodeID = math.random(2,#RouteTabel[startNodeID])

		mydefID = spGetUnitDefID(uID)
		
		assert(not Spring.GetUnitIsDead(startNodeID) )
		assert(not Spring.GetUnitIsDead(RouteTabel[startNodeID][targetNodeID]) )
		GG.EventStream:CreateEvent(
		travellFunction,
		{--persistance Pack
			mydefID = mydefID ,
			myTeam = Spring.GetUnitTeam(uID),
			unitID = uID ,
			goalIndex = 1,
			goalList = buildRouteSquareFromTwoUnits(startNodeID, RouteTabel[startNodeID][targetNodeID], mydefID )
		},
		Spring.GetGameFrame() + (uID % 100)
		)
	end
	
	function testClampRoute(Route, defID)
		
		return Route
	end

	function sendArrivedUnitsCommands()
		for id, uType in pairs(GG.UnitArrivedAtTarget) do
			if GG.CivilianTable[id] and doesUnitExistAlive(GG.CivilianTable[id].startID) == true and doesUnitExistAlive(id) then
				giveWaypointsToUnit(id, uType, GG.CivilianTable[id].startID)
			end
		end
		
		GG.UnitArrivedAtTarget = {}
	end
	
	function countDownRespawnHouses(framesToSubstract)
	 for rubbleHeapID, tables in pairs( TimeDelayedRespawn) do
		TimeDelayedRespawn[rubbleHeapID].frame = TimeDelayedRespawn[rubbleHeapID].frame - framesToSubstract

		if TimeDelayedRespawn[rubbleHeapID].frame <= 0 then
			if isUnitAlive(rubbleHeapID) == true then Spring.DestroyUnit(rubbleHeapID, false, true) end	
			regenerateRoutesTable()
			BuildingWithWaitingRespawn[tables.bID]= nil
			TimeDelayedRespawn[rubbleHeapID] = nil			
		end
	 end
	end
	
	function gadget:GameFrame(frame)
		if boolInitialized == false then
			spawnInitialPopulation(frame)
		--	echo("Initialization:Frame:"..frame)
		elseif boolInitialized == true and frame > 0 and frame % 5 == 0 then
			countDownRespawnHouses(5)		

			-- echo("Runcycle:Frame:"..frame)
			-- recreate buildings 
			-- recreate civilians
			checkReSpawnHouses()
			
			--Check number of Units	
			checkReSpawnPopulation()
			
			checkReSpawnTraffic()
			
			--if Unit arrived at Location
			--give new Target
			sendArrivedUnitsCommands()
			--echoT(statistics)
			for id,times in pairs(activePoliceUnitIds_DispatchTime) do
				if times then
					activePoliceUnitIds_DispatchTime[id] = times - 5
					if activePoliceUnitIds_DispatchTime[id] <= 0 then
						checkReSpawnHouses()
						regenerateRoutesTable()
						Spring.DestroyUnit(id, false,true)
					end
				end
			end
		end		
	end