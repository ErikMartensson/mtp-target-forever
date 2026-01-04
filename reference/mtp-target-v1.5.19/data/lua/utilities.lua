
--------------------------------------------------------------------
-- GENERIC FUNCTIONS

function CLevel:setStartPoints(px, py, pz)
	for i = -0.5, 0.5, 0.05 do
		self:addStartPoint(CVector(px+i, py, pz))
	end
end

function CLevel:setCameras()
	for i = 0, 16 do
		self:addCamera(CVector(0, 3, 10))
		--nlinfo("adding default camera")
	end
end

function CLevel:addModuleNPSS(name, pos, score, scale)
	local m = self:addModule()
	m:setName(name)
	m:setPosition(pos)
	m:setScale(scale)
	m:setScore(score)
	if(score == 300) then m:setColor(CRGBA(255,0,0))
	elseif(score == 100) then m:setColor(CRGBA(0,0,255))
	elseif(score == 50) then m:setColor(CRGBA(0,255,0))
	end
	return m
end

function CLevel:addModuleNPS(name, pos, score)
	return self:addModuleNPSS(name, pos, score, CVector(1,1,1))
end

function CLevel:addModuleNP(name, pos)
	return self:addModuleNPS(name, pos, 0)
end

--------------------------------------------------------------------
-- GATES

function CLevel:addGatePS(pos, score)
	local m = self:addModuleNP("gate", pos)
	local g = self:addGate()
	g:setPosition(pos)
	g:setScale(CVector(14,3,14))
	g:setScore(score)
	g:setModule(m)
	return g
end

function CLevel:addGate90PS(pos, score)
	local m = self:addModuleNP("gate", pos)
	m:setRotation(CAngleAxis(0,0,1,3.14/2))

	local g = self:addGate()
	g:setPosition(pos)
	g:setScale(CVector(3,14,14))
	g:setScore(score)
	return g
end
