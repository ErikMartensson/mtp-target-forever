include("utilities_space.lua")
include("level_default_server.lua")

-- HOTWINGS -- LES CIBLES SONT SUR LES AILES...

ReleaseLevel = 6

function CEntity:init()
	self:setMaxOpenClose(4)
end

function CLevel:init()

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(0.012595, -74.858337, 8.956359), CAngleAxis(-0.475643, -0.483983, 0.523880, 0.514853))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultMidgaard()
	self:addDefaultArraqys()
	self:addDefaultStartCircles()

	local m = self:addModuleNP("space_cargo", CVector(0,-73,8.5))
	--m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addModuleNP("space_box", CVector(0, -72.6, 9.1))
	m:setScale(CVector(2.3, 2.3, 0.3))

	local m = self:addModuleNP("space_box", CVector(0, -71.6, 9.1))
	m:setScale(CVector(2.3, 2.3, 0.3))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(0, -75, 8.7))
	m:setRotation(CAngleAxis(0, 0, 1,3))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setFriction(30)

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(0, -74.7, 8.7))
	m:setRotation(CAngleAxis(0, 0, 1,6))
	m:setScale(CVector(0.9, 0.9, 0.9))
	m:setFriction(30)

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(0, -72.6, 8))
	m:setScale(CVector(3, 3, 2))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(-0.01, -71.6, 10.025))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(1.5, 1.5, 1.3))

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(-0.3, -72.5, 10.025))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(1.5, 1.5, 1.3))

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(-2.5, -72.5, 9.63))
	m:setScale(CVector(3, 3, 2))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(2.3, -72.7, 9.63))
	m:setScale(CVector(3, 3, 2))
	m:setRotation(CAngleAxis(0,0,1,9))
end
