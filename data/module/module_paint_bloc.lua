module:setBounce(0);
module:setScore(0);
module:setAccel(0.00001);
module:setFriction(10.0);

-- Only define CModulePaintBloc if it wasn't already defined by the
-- level's ServerLua script (e.g. level_paint_server.lua). The ServerLua
-- version uses correct method names (postUpdate/updateScore) that match
-- what CLevel:postUpdate() calls.
if not CModulePaintBloc then
  CModulePaintBloc = {}
  CModulePaintBloc_mt = {}
  function CModulePaintBloc:new(s)
    return setmetatable({ son=s, touchEntityId=-1, oldTouchEntityId=-1, oldTouchCount=0, touchCount=0 }, CModulePaintBloc_mt)
  end

  CModulePaintBloc_mt.__index = CModulePaintBloc

  function CModulePaintBloc:postUpdate()
    if(self.touchCount~=self.oldTouchCount and self.touchCount ~= 0) then
      if(self.touchCount == 1) then
        execLuaOnAllButOneClient(self.touchEntityId,"moduleById("..self.son:getId().."):setColor(255,0,0,255)");
        execLuaOnOneClient(self.touchEntityId,"moduleById("..self.son:getId().."):setColor(0,255,0,255)");
      else
        execLuaOnAllClient("moduleById("..self.son:getId().."):setColor(255,255,255,255)");
      end
    end
    self.oldTouchEntityId = self.touchEntityId;
    self.oldTouchCount    = self.touchCount;
  end

  function CModulePaintBloc:onCollide( entity )
    if(self.touchEntityId==-1) then
      self.touchEntityId=entity:getEid();
      self.touchCount = 1;
    end
  end

  function CModulePaintBloc:updateScore()
    if(self.touchCount == 1) then
      local score = getEntityById(self.touchEntityId):getCurrentScore();
      getEntityById(self.touchEntityId):setCurrentScore(score + 100);
    end
  end

  function CModulePaintBloc:onInit()
  end
end

module:setUserData(CModulePaintBloc:new(module)); --new CModulePaintBloc
