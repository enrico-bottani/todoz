---@class TDLZ_TargetAndCallback
---@field callback function
---@field target any
TDLZ_TargetAndCallback = {}

---@param target any
---@param callback function
---@return TDLZ_TargetAndCallback
function TDLZ_TargetAndCallback:new(target, callback)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.target = target
    o.callback = callback
    return o
end

---@return any
function TDLZ_TargetAndCallback:getTarget()
    return self.target
end

---@return function
function TDLZ_TargetAndCallback:getCallback()
    return self.callback
end

function TDLZ_TargetAndCallback:call()
    self.callback(self.target)
end