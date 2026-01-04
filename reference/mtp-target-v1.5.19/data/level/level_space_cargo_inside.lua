include("utilities_space.lua")
include("level_default_server.lua")

--CARGO_INSIDE -- VISEZ LA CARGAISON!

ReleaseLevel = 6

function CEntity:init()
	self:setMaxOpenClose(6)
end

function CLevel:init()

	self:setInfo("LevelInfoOpenCloseExt")

	self:setAdvancedLevel(true)

	self:addExternalCamera(CVector(-0.770465, -71.562767, 5.400587), CAngleAxis(-0.381502, 0.164245, -0.359710, 0.835517))

	self:setCameras()

	self:setSpaceParams()

-- RAMP  -*-*-*-*-*-*-*-*-*-*-*

	self:setSpaceRamp()

-- BACKGROUND -*-*-*-*--*-*-*-*-*-*-*-*

	self:addDefaultStartCircles()
	self:addDefaultArraqys()
	self:addDefaultCalbren()

	local m = self:addModuleNP("space_cargo", CVector(0,-70,5))
	m:setRotation(CAngleAxis(0,0,1,9))

-- TARGETS -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local m = self:addSpaceTarget("crate", "crate", 100, CVector(-0.01, -70.05, 4.65))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(-0.3, -70.5, 4.5))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 50, CVector(-0.2, -71.56, 4.5))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addSpaceTarget("crate", "crate", 300, CVector(-0.7, -71.5, 5.3))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(0.75, 0.75, 0.75))
	m:setFriction(30)

end
