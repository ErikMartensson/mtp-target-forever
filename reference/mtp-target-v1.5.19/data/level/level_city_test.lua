include("utilities_city.lua")
include("level_default_server.lua")

ReleaseLevel = 200

function CLevel:init()

	self:addExternalCamera(CVector(0.335299, -14.652275, 0.184275), CAngleAxis(-0.094143, -0.255560, 0.902884, 0.332605))

	self:setCityParams()
	self:setCityRamp(0, 0, 0)

	self:setSun(CRGBA(64,64,64), CRGBA(255,255,255), CRGBA(255,255,255), CVector(-1,0,-0.3))

local m = self:addModuleNP("city_parking", CVector(-0,-20,4))
	m:setRotation(CAngleAxis(0,0,1,9))

local m = self:addModuleNP("city_stop_sign", CVector(-0,-20,4.1))
	m:setRotation(CAngleAxis(0,0,1,6.5))

local m = self:addModuleNP("city_plot", CVector(-0,-20.2,4.05))
	m:setRotation(CAngleAxis(0,0,1,9))

local m = self:addModuleNP("city_plot", CVector(-0,-19.8,4.05))
	m:setRotation(CAngleAxis(0,0,1,9))

local m = self:addModuleNP("city_plot", CVector(-0.36,-19.9,4.05))
	m:setRotation(CAngleAxis(0,0,1,9))	





--TARGETS

self:addCityTarget("easy", "brownbrick", 100, CVector(0,-20,2.15))
self:addCityTarget("wall", "orange", 50, CVector(2,-20,2.15))
self:addCityTarget("basic", "ocre", 50, CVector(4,-20,2.15))
self:addCityTarget("hard", "blue", 50, CVector(6,-20,2.15))
self:addCityTarget("slope", "blue", 50, CVector(-2,-20,2.15))



--BUILDINGS

self:addCityBuilding("classic", "brownbrick", CVector(0, -20, 1))
self:addCityBuilding("sf", "orange", CVector(2, -20, 1))
self:addCityBuilding("skyscrap", "ocre", CVector(4, -20, 1))
self:addCityBuilding("fun", "blue", CVector(6, -20, 1))

--DECOR

	local m = self:addModuleNP("city_statue", CVector(-10,-23,4))
	m:setRotation(CAngleAxis(0,0,1,9))
	local m = self:addModuleNP("city_plot", CVector(-10,-23,4.3))
	m:setRotation(CAngleAxis(0,0,1,9))
	
end

