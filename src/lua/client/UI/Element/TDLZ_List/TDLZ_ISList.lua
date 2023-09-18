require "UI/Element/TDLZ_MultiSelectScrollList"
--- @class TDLZ_ISList:TDLZ_MultiSelectScrollList
--- @field highlighted TDLZ_NumSet
--- @field items table<number, TDLZ_ListItemViewModel>
--- @field marginLeft number
--- @field itemheight number
--- @field width number
TDLZ_ISList = TDLZ_MultiSelectScrollList:derive("TDLZ_ISList")
--- @type number
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
--- @type number
local MARGIN_TOP_BOTTOM = FONT_HGT_SMALL / 4
--- @type number
local MARGIN_BETWEEN = FONT_HGT_SMALL / 4

local original_onmouseup = TDLZ_MultiSelectScrollList.onMouseUp;
function TDLZ_ISList:new(x, y, width, height, previousState, onHighlight)
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


    if previousState ~= nil then
        o.mouseoverselected = previousState.mouseoverselected
        o.highlighted = previousState.highlighted
    end

    o.marginLeft = FONT_HGT_SMALL / 2

    o.onEditItem = nil
    o.editItemTarget = nil

    return o
end

function TDLZ_ISList:setOnMouseClick(target, onCheckboxToggle)
    self.onCheckboxToggle = onCheckboxToggle;
    self.target = target;
end

function TDLZ_ISList:setOnEraseItem(target, onEraseItem)
    self.onEraseItem = onEraseItem;
    self.target = target;
end

function TDLZ_ISList:setOnEditItem(target, onEditItem)
    self.onEditItem = onEditItem;
    self.editItemTarget = target;
end

---@param label string
---@param item TDLZ_BookLineModel
function TDLZ_ISList:addItem(label, item)
    local listItemViewModel = TDLZ_ListItemViewModel:new(label, item, nil, self.count + 1, self.itemheight)
    table.insert(self.items, listItemViewModel)
    self.count = self.count + 1
    self:setScrollHeight(self:getScrollHeight() + listItemViewModel.height)
end

function TDLZ_ISList:onMouseUp(x, y)
    original_onmouseup(x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y, "[onmousedown] ")
    if row == nil then return end
    if row > #self.items or row < 1 then
        return
    end

    if self.marginLeft < x and x < self.marginLeft + BOX_SIZE and self.items[row].lineData.isCheckbox then
        getSoundManager():playUISound("UISelectListItem")
        if self.onCheckboxToggle then
            self.onCheckboxToggle(self.target, self.items[row].lineData);
        end
    elseif self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + 3) < x and x < self:getWidth() - (self.marginLeft + BOX_SIZE + 3) then
        if self.onEditItem ~= nil and self.editItemTarget ~= nil then
            self.onEditItem(self.editItemTarget, self.items[row].lineData)
        end
    elseif self:getWidth() - (self.marginLeft + BOX_SIZE + 3) < x then
        if self.onEraseItem then
            self.onEraseItem(self.target, self.items[row].lineData);
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



    local checkBoxY = y + (self.itemheight / 2 - BOX_SIZE / 2)
    local isMouseOver = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()
    if not self.highlighted:contains(k) and isMouseOver then
        --- Mouse over list item
        TDLZ_Draw.drawRect(self, 0, y, self:getWidth(), self.itemheight, TDLZ_Colors.GRAY_130)
    elseif self.highlighted:contains(k) and item.lineData.isCheckbox then
        --- Item is highlighted
        TDLZ_Draw.drawRect(self, 3, y - 1, self.width - 5, self.itemheight + 2, TDLZ_Colors.GRAY_130)
        TDLZ_Draw.drawRectBorder(self, 1, y - 1, 2, self.itemheight + 2, TDLZ_Colors.YELLOW);
    end
    if isMouseOver then
        if item.lineData.isCheckbox and self.marginLeft < self:getMouseX()
            and self:getMouseX() < self.marginLeft + BOX_SIZE then
            --- Mouse over on checkbox
            TDLZ_Draw.drawRect(self, self.marginLeft, checkBoxY, BOX_SIZE, BOX_SIZE, TDLZ_Colors.GRAY_300)
        end
        local eraseX = self:getWidth() - (self.marginLeft + BOX_SIZE + 3)
        if eraseX < self:getMouseX() then
            TDLZ_Draw.drawTexture(self, getTexture("media/ui/erase.png"),
                self:getWidth() - (self.marginLeft + BOX_SIZE + 3),
                y + self.itemheight / 2 - 9, TDLZ_Colors.WHITE)
        else
            TDLZ_Draw.drawTexture(self, getTexture("media/ui/erase.png"),
                self:getWidth() - (self.marginLeft + BOX_SIZE + 3),
                y + self.itemheight / 2 - 9, TDLZ_Colors.GRAY_700)
        end
        local editLineX = self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + 3)
        if editLineX < self:getMouseX() and self:getMouseX() < eraseX then
            TDLZ_Draw.drawTexture(self, getTexture("media/ui/edit-line.png"),
                self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + 3),
                y + self.itemheight / 2 - 9, TDLZ_Colors.WHITE)
        else
            TDLZ_Draw.drawTexture(self, getTexture("media/ui/edit-line.png"),
                self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + 3),
                y + self.itemheight / 2 - 9, TDLZ_Colors.GRAY_700)
        end
        local moveX = self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + BOX_SIZE + 3)
        if moveX < self:getMouseX() and self:getMouseX() < editLineX then
            TDLZ_Draw.drawTexture(self, getTexture("media/ui/move.png"),
                self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + BOX_SIZE + 3),
                y + self.itemheight / 2 - 9, TDLZ_Colors.WHITE)
        else
            TDLZ_Draw.drawTexture(self, getTexture("media/ui/move.png"),
                self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + BOX_SIZE + 3),
                y + self.itemheight / 2 - 9, TDLZ_Colors.GRAY_700)
        end
    end
    if item.lineData.isCheckbox then
        if item.lineData.isChecked then
            --- Draw tick texture
            TDLZ_Draw.drawTexture(self, self.tickTexture, self.marginLeft + 3,
                checkBoxY + 2, TDLZ_Colors.WHITE)
        end
        TDLZ_Draw.drawRectBorder(self, self.marginLeft, checkBoxY, BOX_SIZE, BOX_SIZE, TDLZ_Colors.GRAY_300)
    end


    local dy = (self.itemheight - FONT_HGT_SMALL) / 2
    TDLZ_Draw.drawText(self, item.text,
        self.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy,
        TDLZ_Colors.GRAY_800, UIFont.Small)

    return y + self.itemheight;
end

function TDLZ_ISList:onMouseDown(x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y, "[onmousedown] ")
    if row == nil then return end
    if row > #self.items or row < 1 or not self.items[row].lineData.isCheckbox then
        return
    end
    local moveX = self:getWidth() - (self.marginLeft + BOX_SIZE + BOX_SIZE + BOX_SIZE + 3)
    if self.marginLeft < x and x < self.marginLeft + BOX_SIZE or moveX < x then
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
            self.highlighted = TDLZ_NumSet:new()
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
---@return TDLZ_BookLineModel
function TDLZ_ISList:getItem(row)
    return self.items[row].lineData
end

---Get all items from list
---@return table<number, TDLZ_BookLineModel>
function TDLZ_ISList:getItems()
    local rtnTable = {}
    for index, value in pairs(self.items) do
        table.insert(rtnTable, value.lineData)
    end
    return rtnTable
end
