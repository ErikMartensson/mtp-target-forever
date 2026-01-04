include("utilities.lua")

--------------------------------------------------------------------
-- SNOW

function CLevel:setRamp(px, py, pz)
	local m = self:addModuleNP("snow_ramp", CVector(px, py, pz))
	m:setBounce(0)
	m:setFriction(0)
	self:setStartPoints(px, py+1.6, pz+4.38)
	self:setCameras()
end

function CLevel:setTeamRamp(px, py, pz)
	local m = self:addModuleNP("snow_ramp", CVector(px, py, pz))
	m:setBounce(0)
	m:setFriction(0)
	m:setColor(CRGBA(255,200,200))

	local m = self:addModuleNP("snow_ramp", CVector(px, -py, pz))
	m:setBounce(0)
	m:setFriction(0)
	m:setColor(CRGBA(200,200,255))
	m:setRotation(CAngleAxis(0,0,1,3.1415))

	for i = -0.5, 0.5, 0.05 do
		self:addStartPoint(CVector(px+i, py+1.6, pz+4.38))
		self:addCamera(CVector(0, 3, 10))
		self:addStartPoint(CVector(px+i, -py-1.6, pz+4.38))
		self:addCamera(CVector(0, -3, 10))
	end
end



function CLevel:addDefaultIsland()
	self:addModuleNP("snow_island", CVector(10, -25, 3.5))
	self:addModuleNP("snow_island2", CVector(6, -14, 1.8))
	self:addModuleNP("snow_island3", CVector(-3.8, -17, 2))
end

function CLevel:addDefaultIslandCenter()
	self:addModuleNP("snow_island", CVector(10,-10,3.5))
	self:addModuleNP("snow_island", CVector(-10,10,3.5))
	self:addModuleNP("snow_island2", CVector(6,3,1.8))
	self:addModuleNP("snow_island3", CVector(-3.8,-3,2))
end
