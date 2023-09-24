local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

---@class TDLZ_GenericContextMenu:ISScrollingListBox
TDLZ_GenericContextMenu = ISScrollingListBox:derive("TDLZ_GenericContextMenu");

---@param x any
---@param y any
---@param width any
---@param height any
---@return TDLZ_GenericContextMenu
function TDLZ_GenericContextMenu:new(x, y, width, height)
    local o = {}
    o = ISScrollingListBox:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    o:setFont(UIFont.Small, 4)

    o.x = x;
    o.y = y;
    o.background = true;
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.width = width;
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = false;
    o.anchorTop = true;
    o.anchorBottom = false;
    o.joypadButtons = {};
    o.joypadIndex = 0;
    o.joypadButtonsY = {};
    o.joypadIndexY = 0;
    o.moveWithMouse = false;

    o.onCloseCTX = nil

    return o
end

function TDLZ_GenericContextMenu:setOnSelectedItem(onSelectItemCallback, arg1)
    self.onmousedblclick = onSelectItemCallback
    self.target = arg1
end

---@param item any
---@return number
function TDLZ_GenericContextMenu:doDrawItem(y, item, alt)
    self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.9, 0.1, 0.1, 0.1)
    return ISScrollingListBox.doDrawItem(self, y, item, alt)
end

function TDLZ_GenericContextMenu:onMouseDown(x, y)
    print("onMouseDown")
    if not self:isMouseOver() then
        self:setVisible(false);
        return
    end
    ISScrollingListBox.onMouseDown(self, x, y)
end

function TDLZ_GenericContextMenu:onMouseDoubleClick(x, y)
    if self.onmousedblclick and self.items[self.selected] ~= nil then
        self.onmousedblclick(self.target, self.items[self.selected].item);
        self:setVisible(false)
    end
end

function TDLZ_GenericContextMenu:destroy()
    self:setVisible(false);
    self:removeFromUIManager();
end

function TDLZ_GenericContextMenu:addItem(label, item)
    return ISScrollingListBox.addItem(self, label, item)
end

---Remove all items from list
function TDLZ_GenericContextMenu:clear()
    ISScrollingListBox.clear(self)
end