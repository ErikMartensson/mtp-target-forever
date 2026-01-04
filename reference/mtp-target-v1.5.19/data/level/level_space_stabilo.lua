include("utilities_space.lua")
include("level_default_server.lua")

-- STABILO-- VISEZ LES STABILISATEURS!

ReleaseLevel = 6

function CEntity:init()
	self:setMaxOpenClose(6)
end

function CLevel:init()

	self:setInfo("LevelInfoOpenCloseExt")

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(3.666425, -50.799736, 10.118333), CAngleAxis(-0.050492, -0.199730, 0.948704, 0.239833))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp(0, 0, 0)

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*
	self:addDefaultTerra()
	self:addDefaultProxima()

	local m = self:addModuleNP("space_cargo", CVector(0.13, -52.03, 8))
	--m:setRotation(CAngleAxis(0,0,1,9))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(0.13, -51, 7.3))
	m:setScale(CVector(4, 4, 2))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(1.60, -49.78, 8.85))
	m:setRotation(CAngleAxis(0, 0, -1,1))
	m:setScale(CVector(1.5, 1.5, 1))
	m:setFriction(30)

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(-1.3, -49.78, 8.85))
	m:setRotation(CAngleAxis(0, 0, 1,1))
	m:setScale(CVector(1.5, 1.5, 1))
	m:setFriction(30)

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(-0.96, -52.57, 8.7))
	m:setRotation(CAngleAxis(0,0,1,4))
	m:setScale(CVector(2.4, 2.4, 2))

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(1.2, -52.57, 8.6))
	m:setRotation(CAngleAxis(0,0,1,4))
	m:setScale(CVector(2.4, 2.4, 2))
end
