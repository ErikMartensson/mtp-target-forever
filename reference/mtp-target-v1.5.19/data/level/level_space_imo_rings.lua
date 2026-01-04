include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CEntity:init()
	self:setMaxOpenClose(8)
end

function CLevel:init()

	self:setInfo("LevelInfoOpenCloseExt")

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(2.075755, -79.455544, 7.837872), CAngleAxis(-0.106068, -0.495016, 0.843245, 0.180683))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultCalbren()
	self:addDefaultTerra()

	local m = self:addSpacePlanet("planet", "mondomi", CVector(0, -56.38, 15.9))
	m:setScale(CVector(2.1, 2.1, 2.1))
	m:setRotation(CAngleAxis(0,0,1,3))
	local m = self:addSpacePlanetRing("big", "green", CVector(0, -56.38, 15.9))
	--m:setScale(CVector(0.9, 0.9, 0.9))
	local m = self:addSpacePlanetRing("big", "green", CVector(0, -56.38, 15))
	m:setScale(CVector(0.9, 0.9, 0.9))
	local m = self:addSpacePlanetRing("big", "green", CVector(0, -56.38, 17))
	m:setScale(CVector(0.9, 0.9, 0.9))

	local m = self:addSpacePlanet("planet", "arraqys", CVector(5, -62, 9))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(0,0,1,3))

	local m = self:addSpacePlanetRing("small", "yellow", CVector(5, -62, 9))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setAccel(0.00045)
	local m = self:addSpacePlanetRing("big", "yellow", CVector(5, -62, 9))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setAccel(0.0005)

	local m = self:addSpacePlanet("planet", "proxima", CVector(3.8, -71, 8.8))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(0,0,1,3))
	local m = self:addSpacePlanetRing("small", "green", CVector(3.8, -71, 8.75))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setRotation(CAngleAxis(0.1,0,1,-1))
	m:setAccel(0.0005)

	local m = self:addSpacePlanet("planet", "midgaard", CVector(4, -77, 8.3))
	m:setScale(CVector(0.2, 0.2, 0.2))
	m:setRotation(CAngleAxis(0,0,1,5))
	local m = self:addSpacePlanetRing("small", "mallow", CVector(4, -77, 8.3))
	m:setScale(CVector(0.5, 0.35, 0.2))
	m:setRotation(CAngleAxis(0.1,0,1,-1))
	m:setAccel(0.00045)

	local m = self:addSpacePlanet("planet", "terra", CVector(-5, -62, 10))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setRotation(CAngleAxis(0,0,1,3))

	local m = self:addSpacePlanetRing("small", "green", CVector(-5, -62, 10))
	m:setScale(CVector(1, 1, 1))
	m:setAccel(0.00055)

	local m = self:addSpacePlanet("planet", "calbren", CVector(-6, -73, 9.4))
	m:setScale(CVector(0.5, 0.5, 0.5))
	m:setRotation(CAngleAxis(0,0,1,3))
	local m = self:addSpacePlanetRing("small", "mallow", CVector(-6, -73, 9.5))
	m:setScale(CVector(1, 1.8, 1))
	m:setRotation(CAngleAxis(0,0.1,4,3.7))
	m:setAccel(0.00055)

	local m = self:addModuleNP("space_asteroid", CVector(-8,-61.8, 10.4))
	m:setScale(CVector(4, 5, 5))
	m:setRotation(CAngleAxis(0,0,1,2))

	local m = self:addModuleNP("space_meteor", CVector(-2.08, -61.5, 10.4))
	m:setScale(CVector(1.8, 1.8, 1.8))
	m:setRotation(CAngleAxis(0,0,1,2))

	local m = self:addModuleNP("space_meteor", CVector(7.3, -59.6, 9.7))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(0,0,1,-1))

	local m = self:addModuleNP("space_asteroid", CVector(-8.4, -55, 16.5))
	m:setScale(CVector(20, 20, 30))
	m:setRotation(CAngleAxis(0,0,-1,-2))

	local m = self:addModuleNP("space_asteroid", CVector(8.3, -58.3, 15.3))
	m:setScale(CVector(10, 10, 10))
	m:setRotation(CAngleAxis(0,0,1,2))

	local m = self:addModuleNP("space_asteroid", CVector(-1.47, -74.37, 9.76))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceAsteroTarget("hard", "stone", "300", CVector(4.78, -66.6, 8.05))
	m:setScale(CVector(1.4, 1.4, 1.4))
	m:setRotation(CAngleAxis(0,0,1,4.8))
	m:setFriction(20)

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(5.6, -70, 7.5))

	local m = self:addSpaceAsteroTarget("hard", "stone", "100", CVector(9.4, -62.5, 8.7))
	m:setRotation(CAngleAxis(0,0,1,-7))
	m:setScale(CVector(1.5, 1.5, 1))

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(5.62, -70.5, 7.63))
	m:setRotation(CAngleAxis(0,0,1,-2))

	local m = self:addSpaceAsteroTarget("easy", "stone", "300", CVector(-5.8, -67, 9.2))
	m:setRotation(CAngleAxis(0,0,1,-2))

	local m = self:addSpaceAsteroTarget("easy", "stone", "1000", CVector(2, -79.6, 7.7))
	m:setRotation(CAngleAxis(0,0,1,-2))
	m:setScale(CVector(2, 2, 2 ))
end
