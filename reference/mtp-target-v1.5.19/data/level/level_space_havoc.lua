include("utilities_space.lua")
include("level_default_server.lua")

ReleaseLevel = 6

function CEntity:init()
	self:setMaxOpenClose(4)
end

function CLevel:init()

	self:setInfo("LevelInfoOpenCloseExt")

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(13.558390, -59.792812, 5.915631), CAngleAxis(0.096886, 0.046096, 0.427146, 0.897795))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultStartCircles()
	self:addDefaultCalbren()
	self:addDefaultArraqys()
	local m = self:addSpacePlanet("planet", "midgaard", CVector(60, -85, 18))
	m:setScale(CVector(5, 5, 5))
	m:setRotation(CAngleAxis(0,0,2,5))

	local m = self:addModuleNP("space_cargo", CVector(14, -60, 6))
	m:setRotation(CAngleAxis(0,0,2,1))

	local m = self:addModuleNP("space_box", CVector(13.4, -59.5, 6.6))
	m:setRotation(CAngleAxis(0,0,2,1))
	m:setScale(CVector(2.5, 4.3, 0.3))

	local m = self:addModuleNP("space_box", CVector(12.560, -59.46, 6.2))
	m:setRotation(CAngleAxis(0,0,2,1))
	m:setScale(CVector(0.5, 2, 0.2))

	local m = self:addModuleNP("space_box", CVector(12.87, -58.88, 6.39))
	m:setRotation(CAngleAxis(0,0,2,1))
	m:setScale(CVector(0.5, 2, 0.1))

	local m = self:addModuleNP("space_box", CVector(13.725, -58.92, 6.17))
	m:setRotation(CAngleAxis(0,0,2,1))
	m:setScale(CVector(0.2, 0.2, 0.4))

	local m = self:addModuleNP("space_box", CVector(14.20, -59.22, 6))
	m:setRotation(CAngleAxis(0,0,2,1))
	m:setScale(CVector(0.2, 0.83, 0.3))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(13.52, -59.76, 5.86))
	m:setScale(CVector(0.6, 0.6, 1))
	m:setRotation(CAngleAxis(0,0,1,4))
	m:setFriction(20)

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(12.95, -59.71, 6.2))
	m:setRotation(CAngleAxis(0, 0, 1,4.2))
	m:setScale(CVector(1.5, 1.5, 0.75))

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(13.25, -59.12, 6.35))
	m:setRotation(CAngleAxis(0, 0, 1,4.2))
	m:setScale(CVector(1.5, 1.5, 0.75))

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(13.04, -59.22, 5.6))
	m:setRotation(CAngleAxis(0, 0, 1,4.2))
	m:setScale(CVector(1.5, 1.5, 0.75))

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(13.57, -59.36, 5.29))
	m:setRotation(CAngleAxis(0, 0, 1,4.2))
	m:setScale(CVector(2.5, 2.5, 0.9))
end
