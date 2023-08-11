TDLZ_ISTickboxBuilder = {}
TDLZ_ISTickboxBuilder.Type = "TDLZ_ISTickboxBuilder";
function TDLZ_ISTickboxBuilder:new(parent_self)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.parent_self = parent_self;
    o.options = {}
    return o
end
function TDLZ_ISTickboxBuilder:onTicked(onTicked)
    if onTicked ~= nil then
        self.onTicked = onTicked
    end
    return self
end
function TDLZ_ISTickboxBuilder:build()
    local tickBox = ISTickBox:new(10, 50, 10, 10, "Admin Powers", nil, self.onTicked)
    tickBox.changeOptionArgs = {tickBox, nil}
    tickBox.choicesColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
    }
    tickBox.leftMargin = 2
    tickBox:setFont(UIFont.Small)
    self.parent_self:addChild(tickBox);
    return tickBox
end
