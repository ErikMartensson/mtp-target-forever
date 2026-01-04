include("utilities_city.lua")
include("level_default_server.lua")

ReleaseLevel = 5

function CLevel:init()

	self:addExternalCamera(CVector(0.335299, -14.652275, 0.184275), CAngleAxis(-0.094143, -0.255560, 0.902884, 0.332605))


	self:setCityParams()
	self:setCityRamp(0, 0, 0)


--TARGETS

	local m = self:addCityTarget("wall", "ocre", 100, CVector(3,-22,2.2))
	m:setScale(CVector(3,3,3))


	local m = self:addCityTarget("slope", "ocre", 300, CVector(-0.008,-21,2.125))
	m:setScale(CVector(1.5,1.5,1.2))

	local m = self:addCityTarget("easy", "ocre", 50, CVector(1.96,-20,2))
	m:setScale(CVector(2,2,2))

      
--BUILDINGS

self:addCityBuilding("sf", "ocre", CVector(2, -20, 1))
self:addCityBuilding("skyscrap", "ocre", CVector(3, -22, 1))
self:addCityBuilding("fun", "ocre", CVector(0, -21, 1))

--DECOR

	local m = self:addModuleNP("city_statue", CVector(-1,-30,3.4))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addCityBuilding("fun", "ocre", CVector(-8,-28,1.6))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.1,0,1,9))

	local m = self:addCityBuilding("fun", "ocre", CVector(5,-28,1.6))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))

	local m = self:addCityBuilding("skyscrap", "brownbrick", CVector(-4,-27,2.3))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(0.7,0.7,2))	

	local m = self:addCityBuilding("skyscrap", "brownbrick", CVector(-0,-33,2.3))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(0.7,0.7,2))		
	
end

