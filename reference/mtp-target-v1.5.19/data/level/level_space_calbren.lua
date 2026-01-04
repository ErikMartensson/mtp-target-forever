include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(-2.941156, -56.904678, 9.816333), CAngleAxis(0.007099, -0.035965, 0.980411, -0.193521))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultMidgaard()
	self:addDefaultArraqys()

	local m = self:addSpacePlanet("planet", "calbren", CVector(0, -62, 9))
	m:setScale(CVector(0.75, 0.75, 0.75))
	m:setRotation(CAngleAxis(0,0,1,3))

	local m = self:addSpacePlanetRing("big", "green", CVector(0, -62, 9))
	m:setScale(CVector(0.75, 0.75, 0.5))
	
	local m = self:addModuleNP("space_asteroid", CVector(-1.7, -58, 9.2))
	m:setScale(CVector(1.5, 1.75, 1.5))

	local m = self:addModuleNP("space_asteroid", CVector(0.77, -56.9, 9.41))
	m:setScale(CVector(1.5, 1.75, 1.5))

	local m = self:addModuleNP("space_asteroid", CVector(-1.8, -57.4, 9.2))
	m:setScale(CVector(0.7, 0.6, 0.7))
	m:setRotation(CAngleAxis(0,0,1,4.8))

	local m = self:addModuleNP("space_asteroid", CVector(0, -57.2, 9.3))
	m:setScale(CVector(0.8, 0.7, 0.8))
	m:setRotation(CAngleAxis(0,0,1,4))

	local m = self:addModuleNP("space_asteroid", CVector(-1, -57, 9.2))
	m:setScale(CVector(0.8, 0.7, 0.8))
	m:setRotation(CAngleAxis(0,0,1,4))

	local m = self:addModuleNP("space_meteor", CVector(-2.3, -57.9, 9.32))
	m:setScale(CVector(1.5, 1.75, 1.5))
	m:setRotation(CAngleAxis(6,3,9,4))

	local m = self:addModuleNP("space_meteor", CVector(-0.35, -56.64, 9.27))
	m:setScale(CVector(1.5, 1.75, 1.5))
	m:setRotation(CAngleAxis(6,3,9,4))

	local m = self:addModuleNP("space_asteroid", CVector(3.98, -59.45, 9.79))
	m:setScale(CVector(1.2, 1.3, 1.4))
	m:setRotation(CAngleAxis(0,0,1,4))

	local m = self:addModuleNP("space_meteor", CVector(4.08, -60.23, 9.88))
	m:setScale(CVector(1.5, 1.75, 1.5))
	m:setRotation(CAngleAxis(9,4,9,4))

	local m = self:addModuleNP("space_asteroid", CVector(3.25, -60.87, 9.87))
	m:setScale(CVector(2, 2.5, 2.3))

	local m = self:addModuleNP("space_asteroid", CVector(4.07, -61.41, 9.9))
	m:setScale(CVector(1.7, 1.6, 1.7))
	m:setRotation(CAngleAxis(12,0,5,-4.8))

	local m = self:addModuleNP("space_asteroid", CVector(-3.66, -60.087, 9.81))
	m:setScale(CVector(2, 2.5, 2.3))

	local m = self:addModuleNP("space_meteor", CVector(-3.64, -61.23, 9.58))
	m:setScale(CVector(1.5, 1.75, 1.5))
	m:setRotation(CAngleAxis(9,4,9,4))

	local m = self:addModuleNP("space_meteor", CVector(-4.36, -60.73, 10.2))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(4,9,4,9))

	local m = self:addModuleNP("space_meteor", CVector(-0.29, -65.9, 9.54))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(9,4,9,9))

	local m = self:addModuleNP("space_asteroid", CVector(0.47, -65.4, 9.37))
	m:setScale(CVector(1.7, 1.6, 1.7))
	m:setRotation(CAngleAxis(9,4,9,9))

	local m = self:addModuleNP("space_asteroid", CVector(0.62, -66.3, 9.87))
	m:setScale(CVector(1.7, 1.6, 1.7))
	m:setRotation(CAngleAxis(4,9,4,4))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(0, -56.9, 9))
	m:setRotation(CAngleAxis(0, 0, 1, -1))

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(-4, -60.5, 9.5))

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(4, -60.5, 9.5))

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(0, -66, 9.2))

	local m = self:addSpaceAsteroTarget("hard", "stone", "300", CVector(0, -65.75, 8.7))
	m:setRotation(CAngleAxis(0,0,1,4.8))
	m:setFriction(30)
end
