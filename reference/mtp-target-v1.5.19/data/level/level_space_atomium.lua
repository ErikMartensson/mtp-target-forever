include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(-5.664844, -57.808601, 12.526599), CAngleAxis(0.147612, -0.262421, 0.831131, -0.467512))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultTerra()
	self:addDefaultMidgaard()

	local m = self:addSpacePlanet("planet", "arraqys", CVector(-50, -92, 25))
	m:setScale(CVector(0.35, 0.35, 0.35))

	local m = self:addSpacePlanet("planet", "arraqys", CVector(0, -62, 9))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(0,0,1,3))

	local m = self:addSpacePlanetRing("small", "yellow", CVector(0, -62, 9))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setRotation(CAngleAxis(3,3,1,3))

	local m = self:addSpacePlanetRing("big", "yellow", CVector(0, -62, 9))
	m:setScale(CVector(0.6, 0.9, 0.6))
	m:setRotation(CAngleAxis(3,3,1,3))

	local m = self:addSpacePlanetRing("big", "green", CVector(0, -62, 9))
	m:setScale(CVector(0.6, 0.6, 0.6))
	m:setRotation(CAngleAxis(1,8,2,4))
	
	local m = self:addSpacePlanetRing("small", "yellow", CVector(0, -62, 9))
	m:setScale(CVector(0.9, 1.2, 0.6))
	m:setRotation(CAngleAxis(-3,-3,1,3))

	local m = self:addSpacePlanetRing("small", "mallow", CVector(0, -62, 9))
	m:setScale(CVector(1, 1, 0.6))
	m:setRotation(CAngleAxis(9,9,7,3))

	local m = self:addSpacePlanetRing("small", "yellow", CVector(0, -62, 9))
	m:setScale(CVector(0.8, 0.8, 0.8))
	m:setRotation(CAngleAxis(-3,3,1,3))

	local m = self:addSpacePlanetRing("small", "green", CVector(0, -62, 9))
	m:setScale(CVector(0.8, 0.8, 0.8))
	m:setRotation(CAngleAxis(6,3,1,3))

	local m = self:addSpacePlanetRing("small", "mallow", CVector(0, -62, 9))
	m:setScale(CVector(0.6, 0.6, 0.6))
	m:setRotation(CAngleAxis(7,6,9,3))

	local m = self:addSpacePlanetRing("small", "green", CVector(0, -62, 9))
	m:setScale(CVector(0.65, 0.65, 0.65))
	m:setRotation(CAngleAxis (-3,3,-1,7))

	local m = self:addSpacePlanetRing("small", "yellow", CVector(0, -62, 9))
	m:setScale(CVector(0.55, 0.55, 0.55))
	m:setRotation(CAngleAxis(-3,3,-1,3))

	local m = self:addSpacePlanetRing("small", "yellow", CVector(0, -62, 9))
	m:setScale(CVector(0.8, 0.8, 0.8))
	m:setRotation(CAngleAxis(-3,3,-1,-9))

	local m = self:addModuleNP("space_asteroid", CVector(1.1,-58.7, 9.4))

	local m = self:addModuleNP("space_asteroid", CVector(-1.5,-58.8, 9.5))
	m:setScale(CVector(3, 3, 3))

	local m = self:addModuleNP("space_meteor", CVector(2., -65.6, 9.9))
	m:setScale(CVector(6, 6, 6))
	m:setRotation(CAngleAxis(0, 0, 1, 5))

	local m = self:addModuleNP("space_asteroid", CVector(0.6, -61, 8))
	m:setScale(CVector(3, 3, 3))
	m:setRotation(CAngleAxis(0, 0, 1, 5))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(1.45, -59.4, 9.58))
	m:setScale(CVector(0.8, 0.8, 0.8))
	m:setRotation(CAngleAxis(0, 0, 1, 5.5))

	local m = self:addSpaceAsteroTarget("normal", "stone", "300", CVector(1.27, -64.69, 9.24))
	m:setFriction(30)

	local m = self:addSpaceAsteroTarget("hard", "stone", "100", CVector(1, -64.35, 9.85))
	m:setRotation(CAngleAxis(0, 0, 1, 4.8))
	m:setFriction(20)

	local m = self:addSpaceAsteroTarget("hard", "stone", "100", CVector(-0.1, -59.4, 11.6))
	m:setRotation(CAngleAxis(0, 0, 1, 3.3))
	m:setFriction(20)

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(0, -62, 8.2))
	m:setScale(CVector(2, 2, 1.5))
	m:setRotation(CAngleAxis(0, 0, 1, 4.5))

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(0, -62, 7))
	m:setScale(CVector(2, 2, 1.5))
	m:setRotation(CAngleAxis(0, 0, 1.5, -5))

	local m = self:addSpaceAsteroTarget("hard", "stone", "100", CVector(-1.78, -63.7, 8.5))
	m:setRotation(CAngleAxis(0, 0, 1, 3.8))
	m:setScale(CVector(2, 2, 1.5))
end
