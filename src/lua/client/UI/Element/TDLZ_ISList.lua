require "UI/Element/TDLZ_MultiSelectScrollList"
--- @class TDLZ_ISList:TDLZ_MultiSelectScrollList
--- @field highlighted TDLZ_NumSet
--- @field items table<number, TDLZ_ISListItemViewModel>
--- @field marginLeft number
--- @field itemheight number
--- @field width number
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
function TDLZ_ISList:new(x, y, width, height, parent, previousState, onHighlight)
    local o = {}
    o = TDLZ_MultiSelectScrollList:new(x, y, width, height, onHighlight)
    setmetatable(o, self)
    self.__index = self

    o.itemheight = FONT_HGT_SMALL + MARGIN_TOP_BOTTOM * 2
    o:setAnchorLeft(true)
    o:setAnchorRight(true)
    o:setAnchorTop(true)
    o:setAnchorBottom(true)
    o.drawBorder = true
    o.tickTexture = getTexture("Quest_Succeed");
    -- o.doDrawItem = TDLZ_ISList.doDrawItem
    o.selected = -1;
    o.joypadParent = self;
    o.font = UIFont.NewSmall;

    o.onCheckboxToggle = nil
    o.parent = parent;

    if previousState ~= nil then
        o.mouseoverselected = previousState.mouseoverselected
        o.highlighted = previousState.highlighted
    end

    o:initialise()
    o:instantiate()

    o.marginLeft = FONT_HGT_SMALL / 2

    return o
end

function TDLZ_ISList:setOnMouseClick(target, onCheckboxToggle)
    self.onCheckboxToggle = onCheckboxToggle;
    self.target = target;
end

---commented
---@param item TDLZ_ISListItemModel
---@return TDLZ_ISListItemViewModel
function TDLZ_ISList:addItem(item)
    local i = TDLZ_ISListItemViewModel:new(item.label, item.data, nil, self.count + 1, self.itemheight)
    table.insert(self.items, i)
    self.count = self.count + 1
    self:setScrollHeight(self:getScrollHeight() + i.height)
    return i;
end

function TDLZ_ISList:onMouseUp(x, y)
    original_onmouseup(x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y, "[onmousedown] ")
    if row == nil then return end
    if row > #self.items or row < 1 or not self.items[row].lineData.isCheckbox then
        return
    end

    if self.marginLeft < x and x < self.marginLeft + BOX_SIZE then
        getSoundManager():playUISound("UISelectListItem")
        if self.onCheckboxToggle then
            self.onCheckboxToggle(self.target, self.items[row].lineData);
        end
    end
end

function TDLZ_ISList._drawCheckboxBackground(uiSelf, y, item, alt)
    if alt then
        uiSelf:drawRect(0, y, uiSelf:getWidth(), uiSelf.itemheight, 0.08, uiSelf.borderColor.r, uiSelf.borderColor.g,
            uiSelf.borderColor.b);
    else
        uiSelf:drawRect(0, y, uiSelf:getWidth(), uiSelf.itemheight, 0.0, uiSelf.borderColor.r, uiSelf.borderColor.g,
            uiSelf.borderColor.b);
    end
end

function TDLZ_ISList:doDrawItem(y, item, alt, k)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    TDLZ_ISList._drawCheckboxBackground(self, y, item, alt)

    if item.lineData.isCheckbox then
        if self.highlighted:contains(k) then
            self:drawRect(3, y - 1, self.width - 5, self.itemheight + 2, 1, 0.13,
                0.13, 0.13);
            self:drawRectBorder(1, y - 1, 2, self.itemheight + 2, 1, 0.6, 0.6, 0.3);
        end
        local isMouseOver = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()
        if isMouseOver then
            if self.marginLeft < self:getMouseX() and self:getMouseX() < self.marginLeft + BOX_SIZE then
                local ckBoxY = y + (self.itemheight / 2 - BOX_SIZE / 2)
                self:drawRect(self.marginLeft, ckBoxY, BOX_SIZE, BOX_SIZE, 1.0, 0.3,
                    0.3,
                    0.3);
            elseif not self.highlighted:contains(k) then
                self:drawRect(0, y, self:getWidth(), self.itemheight, 1.0, 0.1,
                    0.1,
                    0.1);
            end
        end
        self:drawRectBorder(self.marginLeft, y + (self.itemheight / 2 - BOX_SIZE / 2), BOX_SIZE, BOX_SIZE, 1.0, 0.3,
            0.3, 0.3);
        if item.lineData.isChecked then
            self:drawTexture(self.tickTexture, self.marginLeft + 3, y + (self.itemheight / 2 - BOX_SIZE / 2) + 2, 1, 1,
                1, 1);
        end
    end

    local dy = (self.itemheight - FONT_HGT_SMALL) / 2
    if item.lineData.isCheckbox or not item.lineData.isTitle then
        self:drawText(item.text, self.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy, TEXT_RGBA.r, TEXT_RGBA.g,
            TEXT_RGBA.b, TEXT_RGBA.a, UIFont.Small);
    else
        -- Not a checkbox, write text
        self:drawText(item.text, self.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy, 0.3, 0.3, 0.3, 1, UIFont.Small);
    end
    return y + self.itemheight;
end

function TDLZ_ISList:onMouseDown(x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y, "[onmousedown] ")
    if row == nil then return end
    if row > #self.items or row < 1 or not self.items[row].lineData.isCheckbox then
        return
    end

    if self.marginLeft < x and x < self.marginLeft + BOX_SIZE then
        return
    end

    getSoundManager():playUISound("UISelectListItem")
    self.selected = row;

    if isCtrlKeyDown() then
        if self.highlighted:contains(row) then
            self.highlighted:remove(row)
            self.onHighlightCD.f(self.onHighlightCD.o, self.highlighted:size())
        else
            self.highlighted:add(row)
            self.onHighlightCD.f(self.onHighlightCD.o, self.highlighted:size())
        end
    else
        if self.highlighted:contains(row) and self.highlighted:size() == 1 then
            -- remove highlight from choosen element only if one is highlighted
            self.highlighted = TDLZ_NumSet:new();
            self.onHighlightCD.f(self.onHighlightCD.o, self.highlighted:size())
        else
            -- wipe all and add highlight choosen element
            self.highlighted = TDLZ_NumSet:new();
            self.highlighted:add(row)
            self.onHighlightCD.f(self.onHighlightCD.o, self.highlighted:size())
        end
    end
    -- callback
    if self.onmousedown then
        self.onmousedown(self.target, self.items[self.selected].item);
    end
end

---Get item from list
---@param row number row where the item is located
---@return TDLZ_ISListItemDataModel
function TDLZ_ISList:getItem(row)
    return self.items[row].lineData
end
