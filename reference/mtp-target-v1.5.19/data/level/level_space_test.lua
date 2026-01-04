include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 20


function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(-2.39, -57.12, 10.15), CAngleAxis(0.18, -0.36, 0.926846, 4.01641))

	self:setCameras()

	self:setSpaceParams()

	--RAMP  -*-*-*-*-*-*-*-*-*-*-*


	self:setSpaceRamp(0, 0, 0)


-- 	BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

		
	local m = self:addModuleNP("space_meteor", CVector(0.5, -69.7, 13.7))
	m:setScale(CVector(7, 7, 7))

	local m = self:addModuleNP("space_meteor", CVector(2.1, -69, 14))
	m:setScale(CVector(5, 5, 5))
	m:setRotation(CAngleAxis(5,0,0,-90))

	local m = self:addModuleNP("space_meteor", CVector(1.1, -70, 12.4))
	m:setScale(CVector(5, 5, 5))
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

	

	self:addDefaultTerra()
	self:addDefaultStartCircles()
	
	--m:setScale(CVector(0.7, 0.7, 0.7))
	
	
	
	
--	TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceAsteroTarget("hard", "stone", "300", CVector(1.4, -71, 12.4))
	m:setScale(CVector(1.5, 1.5, 1.5))
	m:setRotation(CAngleAxis(0,0,1,4.8))
	

	local m = self:addSpaceAsteroTarget("normal", "stone", "100", CVector(1.96, -70, 13))
	m:setScale(CVector(1.5, 1.5, 1.5))
	

	local m = self:addSpaceAsteroTarget("easy", "stone", "50", CVector(0.6, -68.8, 14.1))
	m:setRotation(CAngleAxis(0,0,1,-2))
	m:setScale(CVector(1.5, 1.5, 1))

	
end



