---------------------- Level  ----------------------

setLevelTimeout(20);

---------------------- Entity ----------------------
local clientId = 0;

function Entity:init()
  self:displayText(0,5,1,255,200,0,"warning : In this level you must hit the target in open mode",60);
  self:setCurrentScore(0);
  --self:setStartPointId(clientId+getSessionId()*2);
  clientId = clientId + 1;
end

function Entity:preUpdate()
end

function Entity:update()
end

-- Scoring for darts.
-- ODE sphere-trimesh detection often misses thin sign meshes; the
-- entity stops on the platform (city_target_zero, score=0) instead.
-- When a score-0 collision occurs, we check if the entity is elevated
-- above the platform surface (at sign-face height) and award the
-- score of the closest scoring module.
-- Two conditions gate the proximity fallback:
--   1. Entity Z > 0.03 above the colliding module Z (at sign height)
--   2. XY distance to nearest scoring module < 0.5
function entitySceneCollideEvent ( entity, module )
  local newScore = module:getScore()
  if newScore > entity:getCurrentScore() then
    entity:setCurrentScore(newScore)
  elseif newScore == 0 then
    local epos = entity:getPos()
    local mpos = module:getPos()
    local zAbove = epos:getZ() - mpos:getZ()
    if zAbove > 0.03 then
      local bestScore = 0
      local bestDist = 999
      local count = getModuleCount()
      for i = 0, count - 1 do
        local m = getModule(i)
        local ms = m:getScore()
        if ms > 0 then
          local mp = m:getPos()
          local dx = epos:getX() - mp:getX()
          local dy = epos:getY() - mp:getY()
          local dist = math.sqrt(dx*dx + dy*dy)
          if dist < bestDist then
            bestDist = dist
            bestScore = ms
          end
        end
      end
      if bestDist < 0.5 and bestScore > entity:getCurrentScore() then
        entity:setCurrentScore(bestScore)
      end
    end
  end
  if entity:getCurrentScore() > 0 and entity:getArrivalTime() == 0 then
    entity:setArrivalTime()
  end
end

function entityEntityCollideEvent ( entity1, entity2 )
end

function entityWaterCollideEvent ( entity )
end
