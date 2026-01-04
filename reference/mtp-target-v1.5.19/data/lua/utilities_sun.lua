include("utilities.lua")

--------------------------------------------------------------------
-- SUN

function CLevel:setSunParams()
	self:setWater("sun")
	self:setFog(50, 110, CRGBA(168,170,185))
	self:setSun(CRGBA(128,128,128), CRGBA(255,255,255), CRGBA(255,255,255), CVector(-1,0,-1))
end

function CLevel:setSunRamp(px, py, pz)
	local m = self:addModuleNP("sun_ramp", CVector(px,py,pz+2))
	m:setBounce(0)
	m:setFriction(0)
	self:setStartPoints(px+0, py+1.6, pz+2+4.38)
	self:setCameras()
end

function CLevel:addSunModule(name, mat, score, pos, scale)
	local m = self:addModule()
	if(mat == "ice") then
		m:setName(name.."_score_env")
	else
		m:setName(name.."_score")
	end
	m:setTexture(0, "material_"..mat)
	if(score == 0) then
		m:setTexture(1, "empty")
	else
		m:setTexture(1, "score_"..score)
	end
	m:setScore(score)
	m:setPosition(pos)
	m:setScale(scale)
	m:setColor(CRGBA(255,255,255))
	if(mat == "sand") then m:setFriction(15)
	elseif(mat == "wood") then m:setFriction(10)
	elseif(mat == "ice") then m:setFriction(5)
	end
	return m
end

function CLevel:addDefaultMohai()
	local m = self:addModuleNP("sun_island_mohai", CVector(-7,-32, 1.2))
	m:setRotation(CAngleAxis(0,0,1,15))
	local m = self:addModuleNP("sun_island_little", CVector(12,-27,0.5))
	m:setRotation(CAngleAxis(0,0,1,8))
	local m = self:addModuleNP("sun_island_circle", CVector(-9,-12,1))
	m:setRotation(CAngleAxis(0,0,1,3))
end

function CLevel:addDefaultHouse()self:addModuleNP("sun_island_house", CVector(-15, -50, 3,5))
	self:addModuleNP("sun_island_circle", CVector(10, -40, 1))
	local m = self:addModuleNP("sun_island_circle", CVector(-10,-23,1))
	m:setRotation(CAngleAxis(0,0,1,9))
	local m = self:addModuleNP("sun_island_little", CVector(15,-18,0.5))
end

