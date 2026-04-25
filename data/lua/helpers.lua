
--------------------------------------------------------------------
-- HELPERS.LUA - Server-side bridge for v1.5.19 compatibility
--
-- This file is loaded by the server's CLuaEngine::init() BEFORE the
-- level file. It provides:
--   1. Default collision event routing that supports both v1.2.2a
--      global function style AND v1.5.19 entity method style
--   2. Gate collision detection (AABB trigger volumes)
--   3. Bridge for CLevel:preUpdate/postUpdate methods
--
-- For v1.2.2a levels (with ServerLua = "level_default_server.lua"),
-- the default server script overrides these functions - which is fine.
--
-- For v1.5.19 levels (with include("level_*_server.lua") and no
-- ServerLua), these bridge functions handle the routing.
--------------------------------------------------------------------


--------------------------------------------------------------------
-- DEBUG COUNTERS for Issue #1 (Intermittent Scoring Failure)
-- These silent counters track entity method lookup success/failure
-- without masking the bug (no print() statements).
-- Check values via Lua console or add periodic logging if needed.

_dbg_collideWithModule_called = 0
_dbg_collideWithModule_nil = 0
_dbg_collideWithEntity_called = 0
_dbg_collideWithEntity_nil = 0
_dbg_collideWithWater_called = 0
_dbg_collideWithWater_nil = 0


--------------------------------------------------------------------
-- GATE COLLISION STATE
-- Tracks which entities are currently inside which gates to avoid
-- firing collideWithGate every physics frame.

local _gateCollisionState = {}


--------------------------------------------------------------------
-- COLLISION EVENT BRIDGES
-- Route global C++ collision callbacks to entity methods

function entitySceneCollideEvent(entity, module)
	-- v1.5.19 style: entity:collideWithModule(module)
	if entity.collideWithModule then
		_dbg_collideWithModule_called = _dbg_collideWithModule_called + 1
		entity:collideWithModule(module)
	else
		_dbg_collideWithModule_nil = _dbg_collideWithModule_nil + 1
		-- v1.2.2a fallback: Module:collide(entity)
		if module.collide then
			module:collide(entity)
		else
			-- Ultimate fallback: simple scoring (higher score wins)
			local newScore = module:getScore()
			if newScore > 0 and newScore > entity:getCurrentScore() then
				entity:setCurrentScore(newScore)
			end
		end
	end
end

function entityEntityCollideEvent(entity1, entity2)
	-- v1.5.19 style: entity:collideWithEntity(entity2)
	if entity1.collideWithEntity then
		_dbg_collideWithEntity_called = _dbg_collideWithEntity_called + 1
		entity1:collideWithEntity(entity2)
	else
		_dbg_collideWithEntity_nil = _dbg_collideWithEntity_nil + 1
	end
end

function entityWaterCollideEvent(entity)
	-- v1.5.19 style: entity:collideWithWater()
	if entity.collideWithWater then
		_dbg_collideWithWater_called = _dbg_collideWithWater_called + 1
		entity:collideWithWater()
	else
		_dbg_collideWithWater_nil = _dbg_collideWithWater_nil + 1
		-- Default: reset score on water
		entity:setCurrentScore(0)
	end
end


--------------------------------------------------------------------
-- GATE COLLISION DETECTION
-- Checks entity positions against gate AABB volumes each frame

local function _isInsideGateAABB(pos, gate)
	local gp = gate.Position
	-- Prefer the explicit opening half-extents (tight trigger volume around
	-- the actual passable opening). Fall back to Scale/2 for any caller that
	-- predates OpeningHalfExtents — that gives the legacy oversized AABB.
	local halfX, halfY, halfZ
	if gate.OpeningHalfExtents then
		local h = gate.OpeningHalfExtents
		halfX, halfY, halfZ = h:getX(), h:getY(), h:getZ()
	else
		local gs = gate.Scale
		halfX, halfY, halfZ = gs:getX() / 2, gs:getY() / 2, gs:getZ() / 2
	end
	local px, py, pz = pos:getX(), pos:getY(), pos:getZ()
	local gpx, gpy, gpz = gp:getX(), gp:getY(), gp:getZ()
	return px >= gpx - halfX and px <= gpx + halfX
	   and py >= gpy - halfY and py <= gpy + halfY
	   and pz >= gpz - halfZ and pz <= gpz + halfZ
end

local function _checkGateCollisions()
	if not Gates or #Gates == 0 then return end
	if not getEntityCount then return end

	local entityCount = getEntityCount()
	for i = 0, entityCount - 1 do
		local entity = getEntity(i)
		if entity then
			local pos = entity:getPos()
			for gIdx, gate in ipairs(Gates) do
				if gate._enabled ~= false then
					local key = i .. "_" .. gIdx
					local inside = _isInsideGateAABB(pos, gate)
					if inside and not _gateCollisionState[key] then
						-- Entity just entered this gate
						_gateCollisionState[key] = true
						if entity.collideWithGate then
							-- Wrap gate data in a proxy if needed
							local gateProxy
							if getmetatable(gate) == nil then
								-- Raw gate table from Gates array; wrap it
								gateProxy = CGateProxy:new(gate)
							else
								gateProxy = gate
							end
							entity:collideWithGate(gateProxy)
						end
					elseif not inside then
						-- Entity left this gate
						_gateCollisionState[key] = nil
					end
				end
			end
		end
	end
end


--------------------------------------------------------------------
-- LEVEL UPDATE BRIDGES
-- Route C++ levelPreUpdate/levelPostUpdate to CLevel methods
-- and run gate collision detection

function levelPreUpdate()
	-- Gate collision detection
	_checkGateCollisions()

	-- v1.5.19 CLevel:preUpdate() bridge
	if CLevel and type(CLevel.preUpdate) == "function" then
		CLevel:preUpdate()
	end
end

function levelPostUpdate()
	-- v1.5.19 CLevel:postUpdate() bridge
	if CLevel and type(CLevel.postUpdate) == "function" then
		CLevel:postUpdate()
	end
end


--------------------------------------------------------------------
-- ENTITY LIFECYCLE BRIDGES
-- These work with Entity:init(), Entity:preUpdate(), Entity:update()
-- which are called via the Lunar proxy system (entity->luaProxy->call())

-- Reset gate collision state and apply level settings at session start
local _entityInitWrapped = false
function levelInit()
	_gateCollisionState = {}

	-- Transfer userData from Lua Modules table entries (populated by
	-- CLevel:init()) to the C++ CModuleProxy objects (created after init).
	-- This is needed for levels like city_paint where CLevel:init() stores
	-- CModulePaintBloc objects via m:setUserData() on CLevelModule proxies,
	-- but the server scripts later access them via module(i):getUserData()
	-- on the C++ CModuleProxy.
	if Modules and getModule then
		for i, entry in ipairs(Modules) do
			if entry._userData then
				local mod = getModule(i - 1) -- ipairs is 1-based, getModule is 0-based
				if mod then
					mod:setUserData(entry._userData)
				end
			end
		end
	end

	-- Apply MaxOpenClose (set by CLevel:setMaxOpenClose) to all entities.
	-- We wrap Entity:init once to apply the level's MaxOpenClose setting.
	if MaxOpenClose and Entity and not _entityInitWrapped then
		_entityInitWrapped = true
		local _origInit = Entity.init
		Entity.init = function(self)
			if _origInit then _origInit(self) end
			self:setOpenCloseMax(MaxOpenClose)
		end
	end
end
