include("utilities_city.lua")
include("level_default_server.lua")

ReleaseLevel = 5

function CEntity:init()
	self:setMaxOpenClose(6)
end

function CLevel:init()

	self:addExternalCamera(CVector(1.490756, -20.241009, 5.210258), CAngleAxis(-0.390533, -0.428382, 0.602170, 0.548967))

	self:setCityParams()
	self:setCityRamp(0, 0, 0)

	local m = self:addCityBuilding("fun", "orange", CVector(0,-22,1.8))
	m:setRotation(CAngleAxis(0,0.5,2,1))
	m:setScale(CVector(1,1,2))
	local m = self:addCityTarget("easy", "orange", 50, CVector(0.43,-21.8, 3.74))
	m:setRotation(CAngleAxis(0,0.5,2,1))

	local m = self:addCityBuilding("classic", "orange", CVector(-3,-19,1))
	m:setRotation(CAngleAxis(0,0.5,2,-4))
	local m = self:addCityTarget("basic", "orange", 300, CVector(-2.8,-18.615,1.9))
	m:setScale(CVector(3.8,4.6,4))
	m:setRotation(CAngleAxis(0,0.5,2,-4))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(2,-18,1))
	m:setRotation(CAngleAxis(1,0,0,0.4))
	local m = self:addCityTarget("wall", "orange", 100, CVector(2,-18.5,2.05))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(1,0,0,0.4))

	self:addDefaultStatue()
			

--	local m = self:addCityBuilding("classic", "orange", CVector(0,-15,1))
--	local m = self:addCityBuilding("fun", "orange", CVector(1,-15,1))
--	local m = self:addCityBuilding("sf", "orange", CVector(2,-15,1))
--	local m = self:addCityBuilding("skyscrap", "orange", CVector(3,-15,1))
--	local m = self:addCityTarget("basic", "orange", 50, CVector(0,-15, 2.2))
--	local m = self:addCityTarget("easy", "orange", 50, CVector(1,-15, 2.2))
--	local m = self:addCityTarget("hard", "orange", 50, CVector(2,-15, 2.2))
--	local m = self:addCityTarget("slope", "orange", 50, CVector(3,-15, 2.2))
--	local m = self:addCityTarget("wall", "orange", 50, CVector(4,-15, 2.2))

end
