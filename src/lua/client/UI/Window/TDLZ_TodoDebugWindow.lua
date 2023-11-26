require "ISUI/ISCollapsableWindowJoypad"
---@class TDLZ_TodoDebugWindow:ISCollapsableWindowJoypad
---@field taskLabel ISTextEntryBox
TDLZ_TodoDebugWindow = ISCollapsableWindowJoypad:derive("TDLZ_TodoListZWindow")
---comment
---@param x any
---@param y any
---@param width any
---@param height any
---@return TDLZ_TodoDebugWindow
function TDLZ_TodoDebugWindow:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindowJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.joypadParent = self
    return o
end

---comment
---@param o TDLZ_TodoDebugWindow
function TDLZ_TodoDebugWindow.initialise(o)
    ISCollapsableWindowJoypad.initialise(o)
    ISCollapsableWindowJoypad.setVisible(o, true)
    -- create and init textbox
    o.taskLabel = ISTextEntryBox:new("-----",1,o:titleBarHeight(),o.width-2,o.height-o:titleBarHeight()-o:resizeWidgetHeight()-1)
    o.taskLabel:instantiate()
    o.taskLabel:initialise()
    o.taskLabel:setMultipleLine(true)
    o.taskLabel:setEditable(true)
    
    o.taskLabel:setAnchorTop(true)
    o.taskLabel:setAnchorBottom(true)
    o.taskLabel:setAnchorLeft(true)
    o.taskLabel:setAnchorRight(true)
    o.taskLabel.backgroundColor = {r=0, g=0, b=0.2, a=1};
    o.taskLabel.borderColor = {r=1, g=1, b=1, a=1};
    TDLZ_TodoDebugWindow.addChild(o, o.taskLabel)
    
end

function TDLZ_TodoDebugWindow:setText(text)
    self.taskLabel:setText(text)
end

---@param o TDLZ_TodoDebugWindow
---@param text string
function TDLZ_TodoDebugWindow.newLine(o,text)
    o.taskLabel:setText(text ..'\n'.. o.taskLabel:getText())
end
function TDLZ_TodoDebugWindow.append(o,text)
    o.taskLabel:setText(text .. o.taskLabel:getText())
end