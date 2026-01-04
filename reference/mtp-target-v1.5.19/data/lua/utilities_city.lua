include("utilities.lua")

--------------------------------------------------------------------
-- CITY

function CLevel:setCityParams()
	self:setWater("city")
	self:setSky("city")
	self:setFog(50, 110, CRGBA(0,0,0))
	self:setSun(CRGBA(165,165,165), CRGBA(165,165,165), CRGBA(165,165,165), CVector(-1,0,-1))
end

function CLevel:setCityRamp(px, py, pz)
	local m = self:addModuleNP("city_ramp", CVector(px,py,pz+5))
	m:setBounce(0)
	m:setFriction(0)
	self:setStartPoints(px+0, py-1.2, pz+11.5)
	self:setCameras()
end

function CLevel:addCityTarget(name, texture, score, pos)
	local m = self:addModuleNP("city_target_"..name, pos)
	m:setTexture(0, "city_building_"..texture)
	m:setTexture(1, "score_"..score)
	m:setScore(score)
	return m
end

function CLevel:addCityBuilding(name, texture, pos)
	local m = self:addModuleNP("city_building_"..name, pos)
	m:setTexture(0, "city_building_"..texture)
	return m
end



function CLevel:addModuleNoColorNPS(name, pos, score)
	local m = self:addModule()
	m:setName(name)
	m:setPosition(pos)
	m:setScore(score)
	return m
end


function CLevel:addDefaultStatue()

	local m = self:addModuleNP("city_statue", CVector(-1,-30,3))
	m:setRotation(CAngleAxis(0.2,0,1,9))

	local m = self:addCityBuilding("sf", "ocre", CVector(-8,-28,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.1,0,1,9))

	local m = self:addCityBuilding("fun", "orange", CVector(-10,-26,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))

	local m = self:addCityBuilding("fun", "ocre", CVector(2,-28,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))

	local m = self:addCityBuilding("skyscrap", "orange", CVector(5,-25,1.99))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(0.1,0,1,9))

	local m = self:addCityBuilding("skyscrap", "brownbrick", CVector(-2.8,-33,1.9))
	m:setScale(CVector(2,2,2))
	m:setRotation(CAngleAxis(-0.1,0,1,9))
end


function CLevel:addDefaultTargetDarts()
	local m = self:addModuleNP("city_target_zero", CVector(0, -43, 2.3))
	local m = self:addModuleNoColorNPS("city_target_stop", CVector(0, -43.03, 2.5), 100)
	local m = self:addModuleNoColorNPS("city_target_death", CVector(0.25, -42.986, 2.4), 100)
	local m = self:addModuleNoColorNPS("city_target_warning", CVector(-0.03, -42.87, 2.34), 50)

end