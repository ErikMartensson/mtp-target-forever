include("utilities.lua")

--------------------------------------------------------------------
-- SPACE

function CLevel:setSpaceParams()
	self:setWater("space")
	self:setSky("space")
	self:setFog(50, 110, CRGBA(0, 0, 0))
	self:setSun(CRGBA(200, 200, 200), CRGBA(200, 200, 200), CRGBA(200, 200, 200), CVector(-1,0,-1))
end

function CLevel:setSpaceRamp(px, py, pz)
	local m = self:addModuleNP("space_ramp_background", CVector(0.24,-6.674639,8))
	m:setRotation(CAngleAxis(0.1,0,0,-0.06))

	local m = self:addModuleNP("space_ramp", CVector(0.24,-6.674639,8))
	m:setRotation(CAngleAxis(0.1,0,0,-0.06))

	m:setBounce(0)
	m:setAccel(0.0045)
	m:setFriction(0)
	for i = 0.0, 0.45, 0.03 do
		self:addStartPoint(CVector(i, 1.4, 7.1))
	end
end

function CLevel:addSpaceTarget(name, texture, score, pos)
	local m = self:addModuleNP("space_target_"..name, pos)
	m:setTexture(0, "space_"..texture)
	m:setTexture(1, "score_"..score)
	m:setScore(score)
	return m
end

function CLevel:addSpaceAsteroTarget(name, texture, score, pos)
	local m = self:addModuleNP("space_target_astero_"..name, pos)
	m:setTexture(0, "texture_"..texture)
	m:setTexture(1, "score_"..score)
	m:setScore(score)
	return m
end

function CLevel:addDefaultStartCircles(name, pos)
	local m = self:addSpacePlanetRing("big", "yellow", CVector(0, -26, 11.8))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(2,1,1,4))

	local m = self:addSpacePlanetRing("big", "yellow", CVector(0, -22.36, 11.02))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(2,1,1,4))

	local m = self:addSpacePlanetRing("big", "yellow", CVector(0, -20, 10.46))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(2,1,1,4))

	local m = self:addSpacePlanetRing("big", "yellow", CVector(0, -18.63, 9.91))
	m:setScale(CVector(0.3, 0.3, 0.3))
	m:setRotation(CAngleAxis(2,1,1,4))
end

-- BACKGROUND CENTER
function CLevel:addDefaultCalbren(name, pos)
	local m = self:addSpacePlanet("planet", "calbren", CVector(-10, -135, 25))
	m:setScale(CVector(3, 3, 3))
	local m = self:addSpacePlanetRing("big", "green", CVector(-10, -135, 22))
	m:setScale(CVector(5, 5, 5))
	--m:setRotation(CAngleAxis(3,3,1,3))
	local m = self:addSpacePlanet("planet", "arraqys", CVector(7, -102, 25))
	m:setScale(CVector(0.42, 0.42, 0.42))
end

-- BACKGROUND RIGHT
function CLevel:addDefaultMidgaard(name, pos)
	local m = self:addSpacePlanet("planet", "midgaard", CVector(-40, -100, 20))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(-3,3,1,3))
	local m = self:addSpacePlanetRing("big", "mallow", CVector(-40, -100, 20))
	m:setScale(CVector(2.2, 2.2, 2))
	m:setRotation(CAngleAxis(-3,-3,1,3))
	local m = self:addSpacePlanetRing("small", "mallow", CVector(-40, -100, 20))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(-3,-3,1,3))

	local m = self:addSpacePlanet("planet", "midgaard", CVector(40, -55, 10))
	m:setScale(CVector(5, 5, 5))
	m:setRotation(CAngleAxis(-7,-3,1,9))

	local m = self:addSpacePlanet("planet", "calbren", CVector(-54, -92, 15))
	local m = self:addSpacePlanetRing("small", "green", CVector(-54, -92, 15))
	m:setScale(CVector(3, 3, 3))
	m:setRotation(CAngleAxis(3,3,1,3))
end

function CLevel:addDefaultProxima(name, pos)
	local m = self:addSpacePlanet("planet", "proxima", CVector(-10, -125, 15))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(3, -3, 1, 8))

	local m = self:addSpacePlanet("planet", "arraqys", CVector(-8, -105, 20))
	m:setScale(CVector(0.7, 0.7, 0.7))
	m:setRotation(CAngleAxis(3, 0, 1, 8))

	local m = self:addSpacePlanet("planet", "arraqys", CVector(-28, -105, 30))
	m:setScale(CVector(0.4, 0.4, 0.4))
	m:setRotation(CAngleAxis(6, 0, 7, 8))

	local m = self:addSpacePlanetRing("big", "yellow", CVector(-10, -125, 15))
	m:setScale(CVector(1.6, 1.6, 2))
	m:setRotation(CAngleAxis(-3,-3,1,3))

	local m = self:addSpacePlanet("planet", "proxima", CVector(-30, -105, 15))
	m:setScale(CVector(5, 5, 5))
	m:setRotation(CAngleAxis(3, 0, 1, 8))

	local m = self:addSpacePlanet("planet", "proxima", CVector(-25, -105, 15))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(3, 0, 1, 8))

	local m = self:addSpacePlanet("planet", "midgaard", CVector(7, -102, 10))
	m:setScale(CVector(0.42, 0.42, 0.42))
	m:setRotation(CAngleAxis(3, 0, 1, 8))

	local m = self:addSpacePlanet("planet", "mondomi", CVector(27, -100, 30))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(3, 0, 1, 8))
end

-- BACKGROUND LEFT
function CLevel:addDefaultTerra(name, pos)
	local m = self:addSpacePlanet("planet", "terra", CVector(45, -115, 15))
	m:setScale(CVector(2, 2, 2))
	m:setRotation(CAngleAxis(5,2,0,2))
	local m = self:addSpacePlanet("planet", "calbren", CVector(27, -102, 15))
	m:setScale(CVector(0.35, 0.35, 0.35))
	local m = self:addSpacePlanet("planet", "calbren", CVector(47, -102, 15))
	m:setScale(CVector(0.2, 0.2, 0.2))

	local m = self:addSpacePlanet("planet", "calbren", CVector(37, -90, 7))
	m:setScale(CVector(0.42, 0.42, 0.42))
	local m = self:addSpacePlanetRing("small", "green", CVector(37, -90, 7))
	m:setScale(CVector(0.6, 0.6, 0.6))
	m:setRotation(CAngleAxis(9, 6, 4, 3))
end

function CLevel:addDefaultArraqys(name, pos)
	local m = self:addSpacePlanet("planet", "arraqys", CVector(35, -110, 30))
	m:setScale(CVector(1.5, 1.5, 1.5))
	m:setRotation(CAngleAxis(5,2,0,2))
	local m = self:addSpacePlanet("planet", "proxima", CVector(17, -102, 15))
	m:setScale(CVector(0.5, 0.5, 0.5))
	local m = self:addSpacePlanet("planet", "proxima", CVector(37, -102, 20))
	m:setScale(CVector(0.2, 0.2, 0.2))
	local m = self:addSpacePlanetRing("small", "yellow", CVector(17, -102, 15))
	m:setScale(CVector(0.5, 0.5, 0.5))
	m:setRotation(CAngleAxis(-9,6,2,3))
	local m = self:addSpacePlanetRing("small", "green", CVector(17, -102, 15))
	m:setScale(CVector(0.8, 0.8, 0.8))
	m:setRotation(CAngleAxis(-9,6,2,3))

	local m = self:addSpacePlanet("planet", "proxima", CVector(24, -112, 33))
	m:setScale(CVector(0.5, 0.5, 0.5))

	local m = self:addSpacePlanet("planet", "proxima", CVector(38, -112, 38))
	m:setScale(CVector(0.5, 0.5, 0.5))
	local m = self:addSpacePlanetRing("big", "green", CVector(38, -112, 38))
	m:setScale(CVector(0.5, 0.5, 0.5))
	m:setRotation(CAngleAxis(8,6,1,3))

	local m = self:addSpacePlanet("planet", "calbren", CVector(35, -113, 28))
	m:setScale(CVector(0.8, 0.8, 0.8))	

	local m = self:addSpacePlanet("planet", "mondomi", CVector(-24, -108, 33))
	m:setScale(CVector(0.5, 0.5, 0.5))	
	local m = self:addSpacePlanetRing("big", "green", CVector(-24, -108, 33))
	m:setScale(CVector(0.5, 0.5, 0.5))
end

function CLevel:addSpacePlanet(name, texture, pos)
	local m = self:addModuleNP("space_"..name, pos)
	m:setTexture(0, "space_planet_"..texture)
	return m
end

function CLevel:addSpacePlanetRing(name, texture, pos)
	local m = self:addModuleNP("space_planet_ring_"..name, pos)
	m:setTexture(0, "space_planet_ring_"..texture)
	return m
end

function CLevel:addModuleNoColorNPS(name, pos, score)
	local m = self:addModule()
	m:setName(name)
	m:setPosition(pos)
	m:setScore(score)
	return m
end
