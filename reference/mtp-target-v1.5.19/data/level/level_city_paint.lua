include("utilities_sun.lua")
include("utilities_city.lua")
include("level_city_paint_server.lua")

ReleaseLevel = 5

function CLevel:init()

	self:addExternalCamera(CVector(-0.004763, -15.335158, 1.692366), CAngleAxis(-0.521265, 0.000803, -0.001315, 0.853393))

	self:setCityParams()
	self:setCityRamp(0, 5, 0)

	local m = self:addCityBuilding("skyscrap", "orange", CVector(0.285,-15-0.285,0.6)) m:setScale(CVector(0.3,0.3,0.6))
	local m = self:addCityTarget("easy", "orange", 300, CVector(0.285,-15-0.285,1.22)) m:setUserData(CModulePaintBloc:new(m))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(0.285,-15+0.285,0.6)) m:setScale(CVector(0.3,0.3,0.6))
	local m = self:addCityTarget("easy", "orange", 300, CVector(0.285,-15+0.285,1.22)) m:setUserData(CModulePaintBloc:new(m))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(-0.285,-15-0.285,0.6)) m:setScale(CVector(0.3,0.3,0.6))
	local m = self:addCityTarget("easy", "orange", 300, CVector(-0.285,-15-0.285,1.22)) m:setUserData(CModulePaintBloc:new(m))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(-0.285,-15+0.285,0.6)) m:setScale(CVector(0.3,0.3,0.6))
	local m = self:addCityTarget("easy", "orange", 300, CVector(-0.285,-15+0.285,1.22)) m:setUserData(CModulePaintBloc:new(m))

	for x = 0, 8 do
		local m = self:addModuleNP("city_box", CVector(-0.285,-0.04*4-15+0.04*x,0.61735+0.62))
		m:setTexture(0,"city_building_orange") m:setScale(CVector(2,2,1)) m:setUserData(CModulePaintBloc:new(m))
		m:setBounce(0) m:setAccel(0.00001) m:setFriction(10)

		local m = self:addModuleNP("city_box", CVector(0.285,-0.04*4-15+0.04*x,0.61735+0.62))
		m:setTexture(0,"city_building_orange") m:setScale(CVector(2,2,1)) m:setUserData(CModulePaintBloc:new(m))
		m:setBounce(0) m:setAccel(0.00001) m:setFriction(10)

		local m = self:addModuleNP("city_box", CVector(0.158-0.04*x,-15+0.285,0.61735+0.62))
		m:setTexture(0,"city_building_orange") m:setScale(CVector(2,2,1)) m:setUserData(CModulePaintBloc:new(m))
		m:setBounce(0) m:setAccel(0.00001) m:setFriction(10)

		local m = self:addModuleNP("city_box", CVector(0.158-0.04*x,-15-0.285,0.61735+0.62))
		m:setTexture(0,"city_building_orange") m:setScale(CVector(2,2,1)) m:setUserData(CModulePaintBloc:new(m))
		m:setBounce(0) m:setAccel(0.00001) m:setFriction(10)
	end

-- DECORS

	local m = self:addModuleNP("city_statue", CVector(-1,-20,3.4))
	m:setRotation(CAngleAxis(0,0,1,9))

	local m = self:addCityBuilding("fun", "orange", CVector(-8,-15,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.1,0,1,9))

	local m = self:addCityBuilding("fun", "orange", CVector(5,-18,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(-4,-10,2.3))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(1.7,1.7,2))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(6,-10,2.3))
	m:setRotation(CAngleAxis(0,0,1,9))
	m:setScale(CVector(1.7,1.7,2))	

end
