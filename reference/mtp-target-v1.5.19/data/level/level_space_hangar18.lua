include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(-9.552649, -45.785805, 3.240532), CAngleAxis(-0.368733, -0.204019, 0.439045, 0.793506))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultArraqys()
	self:addDefaultProxima()

	local m = self:addSpacePlanet("planet", "terra", CVector(-60, -55, 25))
	m:setScale(CVector(4, 4, 4))
	m:setRotation(CAngleAxis(2, 0, 5, 1.57))

	local m = self:addModuleNP("space_cargo", CVector(-10.13, -47.03, 4))
	--m:setRotation(CAngleAxis(0,0,1,9))
	
	local m = self:addModuleNP("space_box", CVector(-10.1, -46.5, 4.52))
	m:setScale(CVector(2.5, 2.5, 0.3))

	local m = self:addModuleNP("space_box", CVector(-10.1, -45.6, 4.52))
	m:setScale(CVector(2, 2, 0.3))

	local m = self:addModuleNP("space_box", CVector(-9.87, -45.515, 3.35))
	m:setScale(CVector(2, 2, 0.1))

	local m = self:addModuleNP("space_box", CVector(-10.5, -46.5, 3.35))
	m:setScale(CVector(1.2, 3, 0.1))

	local m = self:addModuleNP("space_box", CVector(-10.5, -45.52, 3.35))
	m:setScale(CVector(1.2, 2, 0.1))
	
	local m = self:addModuleNP("space_box", CVector(-9.87, -46.5, 3.35))
	m:setScale(CVector(2, 3, 0.1))

	local m = self:addModuleNP("space_box", CVector(-9.7, -45.89, 3.25))
	m:setScale(CVector(1, 0.3, 0.3))

	local m = self:addModuleNP("space_box", CVector(-10.1, -45, 3.9))
	m:setScale(CVector(4, 2, 0.3))
	m:setRotation(CAngleAxis(1,0,0,1.57))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(-9.77, -45.82, 3.41))
	m:setScale(CVector(4, 4, 1))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(-10.20, -46.20, 3.6))
	m:setRotation(CAngleAxis(0,0,1,-5))
	m:setScale(CVector(2.4, 2.4, 2))

	local m = self:addSpaceTarget("crate", "crate", 1000, CVector(-9.59, -45.76, 3.2))
	m:setRotation(CAngleAxis(0, 0, 1,1))
	m:setScale(CVector(1, 1, 0.3))
	m:setFriction(20)

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(-9.66, -46.2, 3.2))
	m:setRotation(CAngleAxis(0, 0, 1,1))
	m:setScale(CVector(1.5, 1.5, 0.3))
	m:setFriction(10)
end
