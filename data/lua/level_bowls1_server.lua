-- Ensure tables exist (needed when loaded via ServerLua without utilities.lua)
CEntity = CEntity or Entity or {}

-- Debug counters for bowls1 scoring conditions
_dbg_bowls_isOpen = 0
_dbg_bowls_isClosed = 0
_dbg_bowls_modScorePos = 0
_dbg_bowls_modScoreZero = 0
_dbg_bowls_scoreSet = 0

---------------------- Entity ----------------------

function CEntity:init()
	self:displayText(0,12,1,255,200,0,"Get closest to the green bar", 60)
	--self:setMaxOpenClose(3) -- to be able to move on the target
end

function CEntity:preUpdate()
	-- Only reset score if entity is still moving (has velocity)
	-- Once stopped, keep the last score so session manager reads it correctly
	local speed = self:getMeanVelocity()
	if speed > 0.1 then
		self:setCurrentScore(0, false)
	end
end

function CEntity:collideWithModule(module)
	-- Track conditions
	if self:isOpen() == 0 then
		_dbg_bowls_isClosed = _dbg_bowls_isClosed + 1
	else
		_dbg_bowls_isOpen = _dbg_bowls_isOpen + 1
	end

	if module:score() > 0 then
		_dbg_bowls_modScorePos = _dbg_bowls_modScorePos + 1
	else
		_dbg_bowls_modScoreZero = _dbg_bowls_modScoreZero + 1
	end

	if(self:isOpen()==0 and module:score()>0) then
		local pos = self:position()
		local center = CVector(0.0, -15.35, 0.0)
		local x = center:getX() - pos:getX()
		local y = center:getY() - pos:getY()
		local dist = math.sqrt(x*x+y*y)
		local score = 10.0*math.floor((400.0-dist*400.0/0.25)/10.0)

		if score > 400 then
			score = 400
		elseif score < -200 then
			score = -200
		end

		_dbg_bowls_scoreSet = _dbg_bowls_scoreSet + 1
		self:setCurrentScore(score, false)
	end
end

function levelEndSession()
	-- Print debug counters at end of each round
	nlinfo("BOWLS1 DEBUG: collideWithModule called=" .. tostring(_dbg_collideWithModule_called) .. " nil=" .. tostring(_dbg_collideWithModule_nil))
	nlinfo("BOWLS1 DEBUG: isClosed=" .. tostring(_dbg_bowls_isClosed) .. " isOpen=" .. tostring(_dbg_bowls_isOpen))
	nlinfo("BOWLS1 DEBUG: modScorePos=" .. tostring(_dbg_bowls_modScorePos) .. " modScoreZero=" .. tostring(_dbg_bowls_modScoreZero))
	nlinfo("BOWLS1 DEBUG: scoreSet=" .. tostring(_dbg_bowls_scoreSet))
end
