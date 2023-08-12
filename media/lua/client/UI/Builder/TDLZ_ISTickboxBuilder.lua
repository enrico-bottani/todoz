TDLZ_ISTickboxBuilder = {}
TDLZ_ISTickboxBuilder.Type = "TDLZ_ISTickboxBuilder";
require 'UI/TDLZ_ISTickboxBuilderDefaultDispatcher'
CK_BOX_CHECKED_PATTERN = "^(%s-)%[([Xx])%]"

function TDLZ_ISTickboxBuilder:new(parent_self)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.parent_self = parent_self;
    o.options = {}

    o.tickBox = ISTickBox:new(10, 50, 10, 10, "Admin Powers", nil, TDLZ_ISTickboxBuilderDefaultDispatcher.onTicked)
    o.tickBox.changeOptionArgs = {o.tickBox, nil}
    o.tickBox.choicesColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
    }
    o.tickBox.leftMargin = 2
    o.tickBox:setFont(UIFont.Small)

    return o
end
function TDLZ_ISTickboxBuilder:addOption(text, selected, data)
    local optionID = self.tickBox:addOption(text, data)
    local startIndex, endIndex = text:find(CK_BOX_CHECKED_PATTERN)
    if startIndex then
        self.tickBox:setSelected(optionID, true)
    else
        self.tickBox:setSelected(optionID, false)
    end
end
function TDLZ_ISTickboxBuilder:build()
    self.parent_self:addChild(self.tickBox);
    self.tickBox:setWidthToFit()
    return self.tickBox
end
