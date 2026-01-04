include("utilities_sun.lua")
include("level_gates_server.lua")

ReleaseLevel = 5

function CLevel:init()
	self:addExternalCamera(CVector(0.005157, -18.117212, 0.222303), CAngleAxis(0.006667, -0.000004, -0.000626, 0.999978))
	self:setSunParams()
	self:setSunRamp(0, 0, 0)
	local m = self:addModuleNP("sun_island_mohai", CVector(-2,-32, 1.2))
	m:setRotation(CAngleAxis(0,0,1,15.5))
	local m = self:addModuleNP("sun_island_little", CVector(12,-18,0.5))
	m:setRotation(CAngleAxis(0,0,1,8.4))
	local m = self:addModuleNP("sun_island_circle", CVector(-9,-12,1))
	m:setRotation(CAngleAxis(0,0,1,3))
	local m = self:addModuleNP("sun_island_circle", CVector(-11,-22,0.6))
	m:setRotation(CAngleAxis(0,0,1,3.9))


	self:addGatePS(CVector(0, -10, 3), 100)
	self:addGatePS(CVector(0, -13, 2), 100)
	self:addGatePS(CVector(0, -16, 1), 100)
	self:addSunModule("box", "sand", 0, CVector(0, -18, 0.2), CVector(10,10,1))
end
