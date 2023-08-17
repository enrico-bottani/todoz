require "UI/TDLZ_MultiSelectScrollList"
TDLZ_ISList = TDLZ_MultiSelectScrollList:derive("TDLZ_ISList")
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
local original_onmouseup = TDLZ_MultiSelectScrollList.onMouseUp;
function TDLZ_ISList:new(x, y, width, height, parent, previousState)
    local o = {}
    o = TDLZ_MultiSelectScrollList:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.itemheight = FONT_HGT_SMALL + MARGIN_TOP_BOTTOM * 2
    o:setAnchorLeft(true);
    o:setAnchorRight(true);
    o:setAnchorTop(true);
    o:setAnchorBottom(true);
    o.drawBorder = true
    o.tickTexture = getTexture("Quest_Succeed");
    o.doDrawItem = TDLZ_ISList.doDrawItem
    o.selected = -1;
    o.joypadParent = self;
    o.font = UIFont.NewSmall;

    o.onmouseclick = nil
    o.parent = parent;

    if previousState ~= nil then
        o.mouseoverselected = previousState.mouseoverselected
    end

    o:initialise();
    o:instantiate();

    o.marginLeft = FONT_HGT_SMALL / 2

    return o
end
function TDLZ_ISList:setOnMouseClick(target, onmouseclick)
    self.onmouseclick = onmouseclick;
    self.target = target;
end
function TDLZ_ISList:addItem(name, item)
    local i = {}
    i.text = name;
    i.lineData = item;
    i.tooltip = nil;
    i.itemindex = self.count + 1;
    i.height = self.itemheight
    table.insert(self.items, i);
    self.count = self.count + 1;
    self:setScrollHeight(self:getScrollHeight() + i.height);
    return i;
end
local function isSelectAllPossible(page)
    if true then
        return true
    end
    if not page then
        return false
    end
    if not page:isVisible() then
        return false
    end
    if page.isCollapsed then
        return false
    end
    if not page:isMouseOver() then
        return false
    end
    for _, v in pairs(page.inventoryPane.selected) do
        return true
    end
    return false
end
function TDLZ_ISList:update()
    if isCtrlKeyDown() and isKeyDown(Keyboard.KEY_A) and isSelectAllPossible(self.parent) then
        table.wipe(self.selected)
        for k, v in ipairs(self.items) do
            self.selected[k] = v
        end
    end
end

function TDLZ_ISList:onMouseUp(x, y)
    original_onmouseup(x, y)

    if #self.items == 0 then
        return
    end

    local row = self:rowAt(x, y)
    if row > #self.items then
        row = #self.items;
    end
    if row < 1 then
        row = 1;
    end

    getSoundManager():playUISound("UISelectListItem")
    if self.selected == row then
        self.selected = row;
        self.mouseoverselected = self:rowAt(x, y)
        if self.onmouseclick then
            self.onmouseclick(self.target, self.items[self.selected].lineData);
        end
    end
end

function TDLZ_ISList._drawCheckboxBackground(uiSelf, y, item, alt)
    if alt then
        uiSelf:drawRect(0, (y), uiSelf:getWidth(), uiSelf.itemheight, 0.2, uiSelf.borderColor.r, uiSelf.borderColor.g,
            uiSelf.borderColor.b);
    else
        uiSelf:drawRect(0, (y), uiSelf:getWidth(), uiSelf.itemheight, 0.1, uiSelf.borderColor.r, uiSelf.borderColor.g,
            uiSelf.borderColor.b);
    end
end
function TDLZ_ISList._drawT1RowBackground(uiSelf, y, item, alt)
    if alt then
        uiSelf:drawRect(0, (y), uiSelf:getWidth(), uiSelf.itemheight, 1, 0.98, 0.98, 0.97);
    else
        uiSelf:drawRect(0, (y), uiSelf:getWidth(), uiSelf.itemheight, 1, 1, 1, 1);
    end
end

function TDLZ_ISList:doDrawItem(y, item, alt)

    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    if item.lineData.isCheckbox or not item.lineData.isTitle then
        TDLZ_ISList._drawCheckboxBackground(self, y, item, alt)
    else
        TDLZ_ISList._drawT1RowBackground(self, y, item, alt)
    end

    local borderOpacity = 1
    -- DRAW CHECKBOX RECT
    local isMouseOver = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()
    if item.lineData.isCheckbox then
        if isMouseOver then
            self:drawRect(self.marginLeft, y + (self.itemheight / 2 - BOX_SIZE / 2), BOX_SIZE, BOX_SIZE, 1.0, 0.3, 0.3,
                0.3);
        end
        self:drawRectBorder(self.marginLeft, y + (self.itemheight / 2 - BOX_SIZE / 2), BOX_SIZE, BOX_SIZE, 1.0, 0.3,
            0.3, 0.3);

        if item.lineData.isChecked then
            self:drawTexture(self.tickTexture, self.marginLeft + 3, y + (self.itemheight / 2 - BOX_SIZE / 2) + 2, 1, 1,
                1, 1);
        end
    end

    local dy = (self.itemheight - FONT_HGT_SMALL) / 2
    -- Text pos debug
    -- self:drawRect(BOX_SIZE + MARGIN_BETWEEN, y + dy, self:getWidth(), FONT_HGT_SMALL, 1.0, 0.8, 0.3, 0.3);
    if item.lineData.isCheckbox or not item.lineData.isTitle then
        self:drawText(item.text, self.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy, TEXT_RGBA.r, TEXT_RGBA.g,
            TEXT_RGBA.b, TEXT_RGBA.a, UIFont.Small);
    else
        -- Not a checkbox, write text
        self:drawText(item.text, self.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy, 0.3, 0.3, 0.3, 1, UIFont.Small);

    end
    return y + self.itemheight;
end
