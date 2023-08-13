TDLZ_ISList = ISScrollingListBox:derive("TDLZ_ISList")
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local MARGIN_TOP_BOTTOM = FONT_HGT_SMALL / 4;
local MARGIN_BETWEEN = FONT_HGT_SMALL / 4;
local BOX_SIZE = 16;
local TEXT_RGBA = {
    r = 0.8,
    g = 0.8,
    b = 0.8,
    a = 1
}
function TDLZ_ISList:new(x, y, width, height, parent)
    local o = {}
    o = ISScrollingListBox:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.itemheight = FONT_HGT_SMALL + MARGIN_TOP_BOTTOM * 2
    o:setAnchorLeft(true);
    o:setAnchorRight(true);
    o:setAnchorTop(true);
    o:setAnchorBottom(true);
    o.drawBorder = true

    
    o.selected = -1;
    o.joypadParent = self;
    o.font = UIFont.NewSmall;
    o.doDrawItem = TDLZ_ISTodoListZWindow.drawTodoLines;

    o.parent = parent;

    o:initialise();
    o:instantiate();

    o.marginLeft = FONT_HGT_SMALL / 2

    return o
end

function TDLZ_ISList:addItem(name, item)
    local i = {}
    i.text = name;
    i.item = item;
    i.tooltip = nil;
    i.itemindex = self.count + 1;
    i.height = self.itemheight
    table.insert(self.items, i);
    self.count = self.count + 1;
    self:setScrollHeight(self:getScrollHeight() + i.height);
    return i;
end

function TDLZ_ISTodoListZWindow:drawTodoLines(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, self.borderColor.r, self.borderColor.g,
            self.borderColor.b);
    else
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.1, self.borderColor.r, self.borderColor.g,
            self.borderColor.b);
    end

    -- if we selected an item, we display a grey rect over it
    local isMouseOver = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()
 
    if isMouseOver then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, self.borderColor.r, self.borderColor.g,
            self.borderColor.b);
    end
   -- On selected (unused?)
   --if self.selected == item.index then
  --  self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
  -- end
    local borderOpacity = 1
    -- DRAW CHECKBOX RECT
    self:drawRectBorder(self.marginLeft, y + (self.itemheight / 2 - BOX_SIZE / 2), BOX_SIZE, BOX_SIZE, 1.0, 0.3, 0.3,
        0.3);
    -- self:drawRect(0, y, BOX_SIZE, BOX_SIZE, 1.0, 0.3, 0.3, 0.3);
    local dy = (self.itemheight - FONT_HGT_SMALL) / 2
    -- Text pos debug
    -- self:drawRect(BOX_SIZE + MARGIN_BETWEEN, y + dy, self:getWidth(), FONT_HGT_SMALL, 1.0, 0.8, 0.3, 0.3);
    self:drawText(item.text, self.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy, TEXT_RGBA.r, TEXT_RGBA.g, TEXT_RGBA.b,
        TEXT_RGBA.a, UIFont.Small);
    return y + self.itemheight;
end
