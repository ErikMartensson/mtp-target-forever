include("utilities_city.lua")
include("level_darts_server.lua")

ReleaseLevel = 5

function CLevel:init()
	self:setInfo("LevelInfoDarts")

	self:addExternalCamera(CVector(-0.111609, -42.626781, 2.437568), CAngleAxis(0.008825, -0.083603, 0.990954, -0.104606))

	self:setCameras()

	self:setTimeout(20)

	self:setCityParams()


	self:setCameraMinDistFromStartPointToMove(100)
	self:setCameraMinDistFromStartPointToMoveVerticaly(100)

	local m = self:addModuleNP("city_pillar", CVector(0, -43, 1.08))


	local m = self:addModuleNP("city_target_zero", CVector(0, -43, 2.3))
	local m = self:addModuleNoColorNPS("city_target_stop", CVector(0, -43.03, 2.5), 100)
	local m = self:addModuleNoColorNPS("city_target_death", CVector(0.25, -42.986, 2.4), 100)
	local m = self:addModuleNoColorNPS("city_target_warning", CVector(-0.03, -42.87, 2.34), 50)
		m:setScale(CVector (2,2,2))
	local m = self:addModuleNoColorNPS("city_target_square", CVector(0.18, -42.753, 2.34), 300)
		m:setRotation(CAngleAxis(-30,8,9,1))
		m:setScale(CVector (0.5,0.5,0.5))
	local m = self:addModuleNoColorNPS("city_target_nosmo", CVector(-0.1, -43.15, 2.5), 300)
		m:setScale(CVector (0.5,0.5,0.5))
	local m = self:addModuleNoColorNPS("city_target_square", CVector(-0.328, -43.088, 2.36), 50)
		m:setRotation(CAngleAxis(-30,-16,-13,1))
	local m = self:addModuleNoColorNPS("city_target_hands", CVector(-0.13, -42.9, 2.5), 50)
		m:setScale(CVector (2,2,2))
	
	local m = self:addCityBuilding("sf", "blue", CVector(-5,-48,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.07,0,1,9))	
	local m = self:addCityBuilding("classic", "orange", CVector(-2,-53,1.9))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.06,0,1,9))
	local m = self:addCityBuilding("skyscrap", "blue", CVector(4,-53,2.3))
	m:setScale(CVector(2,2,2.5))
	m:setRotation(CAngleAxis(-0.08,0,1,9))
	local m = self:addCityBuilding("fun", "blue", CVector(1,-56,1.9))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.08,0,1,9))
	local m = self:addCityBuilding("classic", "orange", CVector(6,-50,1.7))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))
 

	local m = self:addModuleNPSS("snow_box", CVector(0.24,-3.574639,7), 0, CVector(50, 510, 2))
	m:setColor(CRGBA(28,28,28,255))
	m:setBounce(0)
	m:setAccel(0.004)
	m:setFriction(0)
	for i = 0.0, 0.45, 0.03 do
		self:addStartPoint(CVector(i, 1.5, 7.1))
	end

end
