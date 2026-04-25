
--------------------------------------------------------------------
-- UTILITIES.LUA - CLevel compatibility shim
--
-- This file provides the CLevel class used by v1.5.19-style levels.
-- It bridges the imperative API (self:addModule(), self:setWater(), etc.)
-- into the global tables that the v1.2.2a C++ engine reads.
--
-- v1.5.19 levels define CLevel:init() which calls methods on self.
-- After init() runs, global tables (Modules, StartPoints, Cameras, etc.)
-- are populated and ready for the C++ level loader to read.
--------------------------------------------------------------------

-- Include guard: prevent double-initialization when multiple theme
-- utilities (e.g. utilities_snow.lua + utilities_sun.lua) each
-- include this file. Without this, the second include would reset
-- CLevel = {} and wipe out methods added by the first theme utility.
if _utilities_loaded then return end
_utilities_loaded = true

--------------------------------------------------------------------
-- MODULE PROXY
-- Wraps a Modules table entry so m:setName(), m:setScale(), etc. work

CLevelModule = {}
CLevelModule.__index = CLevelModule

function CLevelModule:new(entry)
	local o = setmetatable({}, CLevelModule)
	o._entry = entry
	return o
end

function CLevelModule:setName(name)
	self._entry.Lua = name
	self._entry.Shape = name
	return self
end

function CLevelModule:setPosition(pos)
	self._entry.Position = pos
	return self
end

function CLevelModule:setScale(scale)
	self._entry.Scale = scale
	return self
end

function CLevelModule:setRotation(rot)
	self._entry.Rotation = rot
	return self
end

function CLevelModule:setColor(color)
	self._entry.Color = color
	return self
end

function CLevelModule:setScore(score)
	self._entry.Score = score
	return self
end

function CLevelModule:setFriction(f)
	self._entry.Friction = f
	return self
end

function CLevelModule:setBounce(b)
	self._entry.Bounce = b
	return self
end

function CLevelModule:setAccel(a)
	self._entry.Accel = a
	return self
end

function CLevelModule:setTexture(layer, textureName)
	if layer == 0 then
		self._entry.Texture0 = textureName
	elseif layer == 1 then
		self._entry.Texture1 = textureName
	end
	return self
end

function CLevelModule:setCollide(c)
	self._entry.Collide = c
	return self
end

function CLevelModule:setBounceVel(v)
	self._entry.BounceVel = v
	return self
end

function CLevelModule:setBounceCoef(v)
	self._entry.BounceCoef = v
	return self
end

function CLevelModule:setEnabled(e)
	self._entry.Enabled = e
	return self
end

function CLevelModule:getId()
	return self._entry._id or 0
end

function CLevelModule:setUserData(data)
	self._entry._userData = data
	return self
end

function CLevelModule:getUserData()
	return self._entry._userData
end

--------------------------------------------------------------------
-- CLEVEL CLASS
-- Accumulates level data into global tables

CLevel = {}
CLevel.__index = CLevel

-- Add a new module, returns a CLevelModule proxy for chaining
function CLevel:addModule()
	if not Modules then Modules = {} end
	local entry = {
		Position = CVector(0, 0, 0),
		Scale = CVector(1, 1, 1),
		Rotation = CAngleAxis(1, 0, 0, 0),
		Color = CRGBA(255, 255, 255, 255),
		Lua = "",
		Shape = "",
		Score = 0,
		Friction = 0,
		Bounce = 0,
		Accel = 0,
		_id = #Modules  -- 0-based index for getId()
	}
	table.insert(Modules, entry)
	return CLevelModule:new(entry)
end

-- Add a start point
function CLevel:addStartPoint(pos)
	if not StartPoints then StartPoints = {} end
	table.insert(StartPoints, pos)
end

-- Add a camera position
function CLevel:addCamera(pos)
	if not Cameras then Cameras = {} end
	table.insert(Cameras, pos)
end

-- Add an external camera with position and rotation
function CLevel:addExternalCamera(pos, rot)
	if not ExternalCameras then ExternalCameras = {} end
	table.insert(ExternalCameras, { Position = pos, Rotation = rot })
end

--------------------------------------------------------------------
-- THEME FUNCTIONS
-- Set global variables that the C++ level loader reads

function CLevel:setWater(name)
	skyEnvMap0Name = "water_" .. name .. "_env.dds"
	skyEnvMap1Name = "water_" .. name .. "_env.dds"
	skyHeightMap0Name = "water_" .. name .. "_disp.dds"
	skyHeightMap1Name = "water_" .. name .. "_disp2.dds"
end

function CLevel:setSky(name)
	skyShapeFileName = "sky_" .. name .. ".shape"
end

function CLevel:setSkyTexture(name)
	-- Store for potential future use; the sky shape should already
	-- have the correct texture baked in for each theme
	skyTextureFileName = "sky_" .. name .. ".tga"
end

function CLevel:setFog(min, max, color)
	fogDistMin = min
	fogDistMax = max
	fogColor = color
end

function CLevel:setSun(ambient, diffuse, specular, direction)
	sunAmbientColor = ambient
	sunDiffuseColor = diffuse
	sunSpecularColor = specular
	sunDirection = direction
end

function CLevel:setAdvancedLevel(v)
	-- No-op in our build for now
end

function CLevel:setMaxOpenClose(n)
	-- Sets the max open/close count for all entities in this level.
	-- Stored as a global; applied to each entity during init.
	MaxOpenClose = n
end

-- Level info text lookup table (replaces v1.5.19 CI18N localization)
local _levelInfoText = {
	LevelInfoOpenCloseExt = "You can open your wings more than once on this level",
	LevelInfoDarts = "Hit the target in flying mode",
	LevelInfoBowls1 = "Get closest to the green bar",
	LevelInfoStairs = "Go down the stairs: 1 step = 50 Points",
	LevelInfoFight = "After landing, you can still move",
}

function CLevel:setInfo(key)
	-- Level info/help text displayed to players during countdown
	Info = _levelInfoText[key] or key
end

function CLevel:setTimeout(n)
	-- Level timeout in seconds
	if setLevelTimeout then setLevelTimeout(n) end
	Timeout = n
end

function CLevel:setHasBonusTime(b)
	-- Whether the level uses bonus time scoring
	if setLevelHasBonusTime then
		setLevelHasBonusTime(b and 1 or 0)
	end
end

function CLevel:setCameraMinDistFromStartPointToMove(n)
	CameraMinDistFromStartPointToMove = n
end

function CLevel:setCameraMinDistFromStartPointToMoveVerticaly(n)
	CameraMinDistFromStartPointToMoveVerticaly = n
end

--------------------------------------------------------------------
-- GENERIC HELPER FUNCTIONS (from v1.5.19 utilities.lua)

function CLevel:setStartPoints(px, py, pz)
	for i = -0.5, 0.5, 0.05 do
		self:addStartPoint(CVector(px + i, py, pz))
	end
end

function CLevel:setCameras()
	for i = 0, 16 do
		self:addCamera(CVector(0, 3, 10))
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

function CLevel:addModuleNoColorNPS(name, pos, score)
	local m = self:addModule()
	m:setName(name)
	m:setPosition(pos)
	m:setScore(score)
	return m
end

--------------------------------------------------------------------
-- GATE PROXY CLASS
-- Provides score(), setScore(), setPosition(), setEnabled() etc.
-- Used by level_gates_server.lua and level_sun_extra_ball_server.lua

CGateProxy = {}
CGateProxy.__index = CGateProxy

function CGateProxy:new(gate)
	local o = setmetatable({}, CGateProxy)
	o._gate = gate
	return o
end

function CGateProxy:score()      return self._gate.Score end
function CGateProxy:setScore(s)  self._gate.Score = s end
function CGateProxy:setPosition(pos)
	self._gate.Position = pos
	-- Also move the linked visual module. CLevelModule:setPosition only
	-- mutates the level-load entry table (a no-op once the level is loaded),
	-- so we must additionally call setPos() on the runtime CModuleProxy.
	-- That call relocates the ODE physics geom AND broadcasts an
	-- UpdateElement message so the client re-renders the mesh at the new
	-- position. Without this, the AABB silently teleports while the visible
	-- gate stays put — players see the gate at its original location but
	-- only score by passing through an invisible volume elsewhere.
	if self._gate._moduleProxy then
		self._gate._moduleProxy:setPosition(pos)
		if getModule then
			local mod = getModule(self._gate._moduleProxy:getId())
			if mod and mod.setPos then
				mod:setPos(pos)
			end
		end
	end
end
function CGateProxy:setScale(scale) self._gate.Scale = scale end
function CGateProxy:setOpeningHalfExtents(h) self._gate.OpeningHalfExtents = h end
function CGateProxy:setModule(m) self._gate._moduleProxy = m end
function CGateProxy:setEnabled(e)
	self._gate._enabled = (e ~= 0)
	-- Also toggle the linked visual module's collision if one exists
	if self._gate._linkedModuleId and Module then
		local mod = getModule(self._gate._linkedModuleId)
		if mod then mod:setEnabled(e) end
	end
end

--------------------------------------------------------------------
-- GATE FUNCTIONS
-- Gates are stored in the global Gates table with AABB collision

function CLevel:addGate()
	if not Gates then Gates = {} end
	local gate = {
		Position = CVector(0, 0, 0),
		Scale = CVector(14, 3, 14),
		-- Trigger-volume half-extents covering the gate *opening* only, not
		-- the visible frame. The Scale above (14×3×14) is the legacy size
		-- used by the visual mesh; the trigger uses these tighter bounds so
		-- approaching anywhere near the gate doesn't score before the
		-- player has actually passed through it. Tune these values via
		-- gate:setOpeningHalfExtents(CVector(...)) per level if needed.
		OpeningHalfExtents = CVector(0.05, 0.05, 0.05),
		Score = 0,
		_moduleProxy = nil,
		_enabled = true
	}
	table.insert(Gates, gate)
	return CGateProxy:new(gate)
end

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
	-- 90°-rotated gate: opening lies in the YZ plane, narrow axis is X.
	g._gate.OpeningHalfExtents = CVector(0.05, 0.05, 0.05)
	g:setScore(score)
	return g
end

--------------------------------------------------------------------
-- V1.5.19 COMPATIBILITY ALIASES
-- Server-side entity/module class name aliases and method shorthands
--
-- In v1.5.19, the entity proxy class was called "CEntity" and methods
-- had shorter names. Our v1.2.2a server uses "Entity" with get/set prefix.
-- These aliases make v1.5.19 server scripts work without modification.

-- Entity class alias (server-side only; Entity is nil on client)
if Entity then
	CEntity = Entity
	-- Method aliases (v1.5.19 name -> our name)
	Entity.currentScore  = Entity.getCurrentScore
	Entity.name          = Entity.getName
	Entity.isOpen        = Entity.getIsOpen
	Entity.position      = Entity.getPos
	Entity.startPointPos = Entity.getStartPointPos
	Entity.setPosition   = Entity.setPos
	Entity.setMaxOpenClose = Entity.setOpenCloseMax
	-- v1.5.19 team() returns 0-based team ID with no args.
	-- Our getTeam(teamCount) requires a count and returns 1-based.
	local _origGetTeam = Entity.getTeam
	Entity.team = function(self, teamCount)
		return _origGetTeam(self, teamCount or 2) - 1
	end
else
	-- Client-side: create empty CEntity table so server scripts
	-- included via include() don't error when defining methods
	if not CEntity then CEntity = {} end
end

-- Module class alias (server-side)
if Module then
	CModule = Module
	-- Method aliases
	Module.score    = Module.getScore
	Module.position = Module.getPos
else
	if not CModule then CModule = {} end
	-- Client-side stub so CModule:new() in CLevel:init() doesn't error
	if not CModule.new then
		function CModule:new(...) return {} end
	end
end

-- Server-side global function aliases (v1.5.19 names)
if getModule then module = getModule end
if getModuleCount then moduleCount = getModuleCount end
if getEntityById then entityById = getEntityById end
if getTimeRemaining then timeRemaining = getTimeRemaining end

--------------------------------------------------------------------
-- LEVEL PROXY FUNCTIONS
-- level() returns the CLevel table so server scripts can call
-- level():teamMode() etc.

function level()
	return CLevel
end

function CLevel:teamMode()
	if not getEntityCount then return false end
	local count = getEntityCount()
	for i = 0, count - 1 do
		local e = getEntity(i)
		if e then
			local n = e:getName()
			if n and string.sub(n, 1, 1) == "[" then
				return true
			end
		end
	end
	return false
end
