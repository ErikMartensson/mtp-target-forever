include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(3.031428, -66.023575, 5.997799), CAngleAxis(-0.112910, 0.006391, -0.056152, 0.991997))

	self:setCameras()

	self:setSpaceParams()	

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultStartCircles()
	self:addDefaultTerra()

	self:addDefaultProxima()

	--- 100__01
	local m = self:addModuleNP("space_cargo", CVector(0, -65, 7))
	m:setRotation(CAngleAxis(0,0,2,6.2))
	m:setScale(CVector(0.1, 0.1, 0.1))

	---  50__01
	local m = self:addModuleNP("space_cargo", CVector(2, -63, 7))
	m:setRotation(CAngleAxis(0,0,1,6))
	m:setScale(CVector(0.1, 0.1, 0.1))

	--  300
	local m = self:addModuleNP("space_cargo", CVector(3, -66, 6))
	m:setRotation(CAngleAxis(0,0,1,6))
	m:setScale(CVector(0.1, 0.1, 0.1))

	-- 100__02
	local m = self:addModuleNP("space_cargo", CVector(2, -66, 6.4))
	m:setRotation(CAngleAxis(0,0,1,6.5))
	m:setScale(CVector(0.1, 0.1, 0.1))

	-- 50__02
	local m = self:addModuleNP("space_cargo", CVector(3, -64.3, 6.4))
	m:setRotation(CAngleAxis(0,0,1,5.8))
	m:setScale(CVector(0.1, 0.1, 0.1))
	
	-- 100__03
	local m = self:addModuleNP("space_cargo", CVector(1.5, -64.3, 6.4))
	m:setRotation(CAngleAxis(0,0,1,6.3))
	m:setScale(CVector(0.1, 0.1, 0.1))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- 100__01	
	local m = self:addSpaceTarget("crate", "crate", 100, CVector(0, -64.9, 7.17))
	m:setRotation(CAngleAxis(0,0,2,3))
	m:setScale(CVector(1, 1, 0.5))

	-- 50__01
	local m = self:addSpaceTarget("crate", "crate", 50, CVector(2.04, -62.9, 7.16))
	m:setRotation(CAngleAxis(0,0,1,2.85))
	m:setScale(CVector(1.3, 1.3, 0.4))

	--  300
	local m = self:addSpaceTarget("crate", "crate", 300, CVector(3.05, -65.9, 5.93))
	m:setScale(CVector(1.3, 2, 0.3))
	m:setRotation(CAngleAxis(0,0,1,6))
	m:setFriction(20)

	-- 100__02
	local m = self:addSpaceTarget("crate", "crate", 100, CVector(1.95, -65.88, 6.56))
	m:setRotation(CAngleAxis(0,0,1,3.3))
	m:setScale(CVector(1, 1, 0.3))

	--  50__02
	local m = self:addSpaceTarget("crate", "crate", 50, CVector(3.06, -64.16, 6.568))
	m:setRotation(CAngleAxis(0, 0, 1,2.6))
	m:setScale(CVector(1.5, 1.5, 0.5))

	-- 100__03
	local m = self:addSpaceTarget("crate", "crate", 100, CVector(1.5, -64.22, 6.56))
	m:setRotation(CAngleAxis(0,0,1,3.3))
	m:setScale(CVector(1, 1, 0.3))
end
