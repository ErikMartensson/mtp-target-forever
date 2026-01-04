include("utilities_city.lua")
include("level_default_server.lua")

ReleaseLevel = 5

function CLevel:init()

	self:addExternalCamera(CVector(0.045754, -16.833622, 3.745991), CAngleAxis(-0.105902, -0.445669, 0.864830, 0.205505))

	self:setCityParams()
	self:setCityRamp(0, 0, 0)

--TARGETS

local m = self:addCityTarget("wall", "ocre", 100, CVector(-0.15,-17.2,3.6))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0,0,1,2.67+3.14))

local m = self:addCityTarget("wall", "ocre", 100, CVector(0,-16.88,3.6))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0,0,1,2.67))

local m = self:addCityTarget("wall", "ocre", 100, CVector(-0.357,-16.92,3.6))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0,0,1,2.67+1.70))

local m = self:addCityTarget("wall", "ocre", 100, CVector(0.19,-17.15,3.6))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0,0,1,2.67-1.54))

local m = self:addCityTarget("easy", "ocre", 50, CVector(-0.12,-17.08,3.8))
	m:setScale(CVector(3,3,2))
	m:setRotation(CAngleAxis(0,0,1,2.67-3.14))

local m = self:addCityTarget("hard", "ocre", 300, CVector(-0.09,-17.03,3.5))
	m:setScale(CVector(1,0.4,0.2))
	m:setRotation(CAngleAxis(0,0,1,2.67-3.14))
	m:setFriction(40)	

      
--BUILDINGS

local m = self:addCityBuilding("sf", "ocre", CVector(0,-17,1.99))
	m:setScale(CVector(1.5,1.5,1.5))



--DECOR

local m = self:addModuleNP("city_statue", CVector(-10,-23,4))
	m:setRotation(CAngleAxis(0,0,1,9))


	m:setRotation(CAngleAxis(0.07,0,1,9))	
	local m = self:addCityBuilding("skyscrap", "ocre", CVector(-2,-23,1.9))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.06,0,1,9))
	local m = self:addCityBuilding("fun", "orange", CVector(1,-26,1.9))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.08,0,1,9))
	local m = self:addCityBuilding("classic", "orange", CVector(6,-22,1.7))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))
	local m = self:addCityBuilding("classic", "orange", CVector(-6,-24,1.7))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.14,0,1,9))
	
end
