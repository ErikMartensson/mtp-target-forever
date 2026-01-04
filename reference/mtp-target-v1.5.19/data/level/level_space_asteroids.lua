include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(1.265931, -71.021049, 12.203509), CAngleAxis(-0.390262, 0.347703, -0.567118, 0.636534))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*
	
	self:addDefaultTerra()
	self:addDefaultMidgaard()
	self:addDefaultStartCircles()

	local m = self:addSpacePlanet("planet", "proxima", CVector(24, -112, 33))
	m:setScale(CVector(0.5, 0.5, 0.5))

	local m = self:addModuleNP("space_meteor", CVector(0.5, -69.7, 13.7))
	m:setScale(CVector(7, 7, 7))

	local m = self:addModuleNP("space_meteor", CVector(1.23, -70.15, 13.1))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(5, 9, 0, -30))	

	local m = self:addModuleNP("space_meteor", CVector(1.1, -70, 12.4))
	m:setScale(CVector(3, 3, 3))
	m:setRotation(CAngleAxis(5,0,0,-90))

	local m = self:addModuleNP("space_meteor", CVector(1.7, -71.6, 13.3))
	m:setScale(CVector(7, 7, 7))

	local m = self:addModuleNP("space_meteor", CVector(0.3, -71, 13))
	m:setScale(CVector(5, 5, 5))
	m:setRotation(CAngleAxis(5,0,10,-45))

	local m = self:addModuleNP("space_asteroid", CVector(3, -70, 13.4))
	m:setScale(CVector(9, 9, 9))

	local m = self:addModuleNP("space_asteroid", CVector(0.2, -72.4, 13.7))
	m:setScale(CVector(9, 9, 9))
	m:setRotation(CAngleAxis(5,0,0,-45))

	local m = self:addModuleNP("space_asteroid", CVector(1.8, -69.4, 13.7))
	m:setScale(CVector(4, 4, 4))
	m:setRotation(CAngleAxis(5, 6, 7, -45))

	local m = self:addModuleNP("space_asteroid", CVector(2.18, -69.4, 13.45))
	m:setScale(CVector(2, 2, 3.5))
	m:setRotation(CAngleAxis(5, 6, 7, -45))

	local m = self:addModuleNP("space_meteor", CVector(2.4, -69.2, 13.16))
	m:setScale(CVector(2, 2, 3.5))
	m:setRotation(CAngleAxis(5, 6, 7, -45))

	local m = self:addModuleNP("space_asteroid", CVector(2.41, -69.86, 13.43))
	m:setScale(CVector(1, 2, 1))
	m:setRotation(CAngleAxis(5, 6, 7, -45))
	local m = self:addModuleNP("space_asteroid", CVector(2.41, -69.6, 13.43))
	m:setScale(CVector(2.5, 1, 1))
	m:setRotation(CAngleAxis(5, 6, 7, -45))

	local m = self:addModuleNP("space_meteor", CVector(2.38, -69.7, 12.56))
	m:setScale(CVector(2, 3, 2))
	m:setRotation(CAngleAxis(5,0,10,-20))

	local m = self:addModuleNP("space_meteor", CVector(2.7, -69.7, 12.9))
	m:setRotation(CAngleAxis(5, 10, 4, -6))

	local m = self:addModuleNP("space_meteor", CVector(1.3, -69.34, 13.1))
	m:setRotation(CAngleAxis(5, 10, 4, -6))

	local m = self:addModuleNP("space_meteor", CVector(1.47, -69.54, 13))
	m:setRotation(CAngleAxis(5, 6, 7, 8))

	local m = self:addModuleNP("space_asteroid", CVector(1.37, -70.5, 12.62))
	m:setScale(CVector(2.5, 1, 1))
	m:setRotation(CAngleAxis(5, 6, 7, -45))

	local m = self:addModuleNP("space_asteroid", CVector(1.7, -69.8, 12.8))
	m:setRotation(CAngleAxis(7, 6, 7, -3))

	local m = self:addModuleNP("space_asteroid", CVector(1.1, -70.5, 12.5))
	m:setScale(CVector(2, 1, 1))
	m:setRotation(CAngleAxis(7, 6, 7, -3))

	local m = self:addModuleNP("space_asteroid", CVector(1.87, -69, 13.45))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_asteroid", CVector(1.95, -69.37, 13))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_meteor", CVector(2.29, -69.9, 13.2))
	--m:setScale(CVector(1.6, 1.6, 1.8))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_meteor", CVector(2.08, -69.48, 13.19))
	m:setScale(CVector(0.8, 0.8, 0.9))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_meteor", CVector(1.67, -70.23, 12.86))
	m:setScale(CVector(0.8, 0.8, 0.9))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_asteroid", CVector(1.24, -70.74, 12.67))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(1, 5, 3, -4))

	local m = self:addModuleNP("space_asteroid", CVector(1.55, -70.66, 12.21))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(0.5, 2.5, 6, 8))

	local m = self:addModuleNP("space_meteor", CVector(1.83, -70.47, 12.51))
	m:setScale(CVector(2.4, 2.5, 2.4))
	m:setRotation(CAngleAxis(5, 2, 9, -20))
	
	local m = self:addModuleNP("space_asteroid", CVector(2, -70.96, 12.47))
	m:setScale(CVector(2.5, 1, 1))
	m:setRotation(CAngleAxis(5, 6, 7, -45))

	local m = self:addModuleNP("space_asteroid", CVector(1.89, -70.8, 12.3))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(5, 2, -3, 5))

	local m = self:addModuleNP("space_meteor", CVector(2.06, -71.6, 12.46))
	m:setScale(CVector(2.6, 2.6, 2.6))
	m:setRotation(CAngleAxis(3.5, -3, 5, 7))

	local m = self:addModuleNP("space_meteor", CVector(0.67, -70.3, 12.4))
	m:setScale(CVector(0.8, 0.8, 0.9))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_asteroid", CVector(1.5, -70.05, 12.28))
	m:setRotation(CAngleAxis(7, 6, 7, -3))

	local m = self:addModuleNP("space_asteroid", CVector(1.24, -70.43, 12.35))
	m:setRotation(CAngleAxis(5, 2, 4, -8))

	local m = self:addModuleNP("space_asteroid", CVector(1.21, -70.65, 12.24))
	m:setRotation(CAngleAxis(-5, 4, -7, 6))

	local m = self:addModuleNP("space_meteor", CVector(1.04, -71.18, 12.56))
	m:setScale(CVector(0.8, 0.8, 0.9))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_asteroid", CVector(1.59, -70.06, 12.47))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(1, 5, 3, -4))

	local m = self:addModuleNP("space_asteroid", CVector(1.12, -71.1, 12.38))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(1, 5, 3, -4))

	local m = self:addModuleNP("space_asteroid", CVector(0.83, -71.84, 12.25))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(1, 5, 3, -4))

	local m = self:addModuleNP("space_asteroid", CVector(1.98, -71.09, 12.7))
	m:setScale(CVector(2, 2, 2.3))
	m:setRotation(CAngleAxis(5, 7, 1, -7))

	local m = self:addModuleNP("space_meteor", CVector(2.04, -71.1, 12.36))
	m:setScale(CVector(0.8, 0.8, 0.9))
	m:setRotation(CAngleAxis(7, 6, 7, -2))

	local m = self:addModuleNP("space_asteroid", CVector(1.69, -71, 12.39))
	m:setRotation(CAngleAxis(5, 2, 4, -8))

	local m = self:addModuleNP("space_asteroid", CVector(1.5, -71.6, 11.34))
	m:setScale(CVector(9, 9, 9))
	m:setRotation(CAngleAxis(5, 0, 0, 4))

	local m = self:addModuleNP("space_meteor", CVector(1.30, -70.95, 12.32))
	m:setScale(CVector(0.7, 0.7, 0.7))

	local m = self:addModuleNP("space_asteroid", CVector(2.03, -71.09, 12))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(5, 0, 0,3.7))

	local m = self:addModuleNP("space_asteroid", CVector(1, -70.78, 12.28))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(5, 0, 0,3.7))

	local m = self:addModuleNP("space_asteroid", CVector(0.8, -71.07, 12.37))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(5, 0, 0,3.7))

	local m = self:addModuleNP("space_asteroid", CVector(1.09, -71.68, 12.35))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(5, 3, 0,3))

	local m = self:addModuleNP("space_meteor", CVector(1.4, -71.8, 12.2))
	m:setScale(CVector(2.6, 2.6, 2.6))
	m:setRotation(CAngleAxis(3.5, -3, 5, 7))

	local m = self:addModuleNP("space_meteor", CVector(1.59, -71.26, 12.26))

	local m = self:addModuleNP("space_meteor", CVector(2.17, -70.95, 12.29))

	local m = self:addModuleNP("space_meteor", CVector(2.29, -71.27, 12.22))

	local m = self:addModuleNP("space_asteroid", CVector(1.91, -71.25, 12.21))

	local m = self:addModuleNP("space_asteroid", CVector(1, -71.0, 12.15))

	local m = self:addModuleNP("space_asteroid", CVector(0.88, -70.5, 12.16))
	m:setScale(CVector(1.5, 1.5, 1.5))

	local m = self:addModuleNP("space_asteroid", CVector(1.68, -70.87, 12.27))
	m:setScale(CVector(1.5, 1.5, 1.5))

	
	local m = self:addModuleNP("space_asteroid", CVector(1.02, -70, 12.29))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceAsteroTarget("hard", "stone", "300", CVector(1.4, -71, 12))
	m:setScale(CVector(1.5, 1.5, 1.5))
	m:setRotation(CAngleAxis(0,0,1,4.8))
	m:setFriction(20)

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(1.92, -69.8, 13.2))
	m:setScale(CVector(1.5, 1.5, 1.5))
	m:setFriction(20)
	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(1.27, -69.91, 12.8))
	--m:setScale(CVector(0.5, 0.5, 0.5))
	m:setFriction(20)
	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(2.4, -69.7, 13.05))
	m:setScale(CVector(0.5, 0.5, 0.5))
	m:setFriction(20)

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(0.6, -68.8, 14.1))
	m:setRotation(CAngleAxis(0,0,1,-2))

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(0.95, -70.6, 11.8))
	m:setRotation(CAngleAxis(0,0,1,-2))
end
