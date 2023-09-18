---@class TDLZ_ListItemOptionButton
---@field bounds any
---@field onMouseDown any
---@field onMouseUp any
TDLZ_ListItemOptionButton = {}

function TDLZ_ListItemOptionButton:new(texture, tooltip)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.texture = texture
    o.tooltip = tooltip

    o.onMouseDown = {
        callback = nil,
        ctx = nil
    }

    o.onMouseUp = {
        callback = nil,
        ctx = nil
    }

    o.bounds = {
        x = 0,
        y = 0,
        width = 0,
        height = 0
    }
    return o
end

---@param x number coordinate to check if contained
---@param y number coordinate to check if contained
---@return boolean
function TDLZ_ListItemOptionButton:contains(x, y)
    return self.bounds.x < x and x < self.bounds.x + self.bounds.width
        and self.bounds.y < y and y < self.bounds.y + self.bounds.height
end

function TDLZ_ListItemOptionButton:setOnMouseUpCallback(ctx, fun)
    self.onMouseUp.callback = fun;
    self.onMouseUp.ctx = ctx;
end

function TDLZ_ListItemOptionButton:setOnMouseDownCallback(ctx, fun)
    self.onMouseDown.callback = fun;
    self.onMouseDown.ctx = ctx;
end

function TDLZ_ListItemOptionButton:triggerMouseUp(lineData)
    if self.onMouseUp.ctx ~= nil and self.onMouseUp.callback ~= nil then
        self.onMouseUp.callback(self.onMouseUp.ctx, lineData)
    end
end

function TDLZ_ListItemOptionButton:triggerMouseDown(lineData)
    if self.onMouseDown.ctx ~= nil and self.onMouseDown.callback ~= nil then
        self.onMouseDown.callback(self.onMouseDown.ctx, lineData)
    end
end
