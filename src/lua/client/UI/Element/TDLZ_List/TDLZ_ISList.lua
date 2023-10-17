require "UI/Element/TDLZ_MultiSelectScrollList"
require 'src.lua.client.Utils.TDLZ_Vars'
require 'src.lua.client.UI.Element.TDLZ_ListItemOptionButton'
---@class TDLZ_ISList:TDLZ_MultiSelectScrollList
---@field highlighted TDLZ_NumSet
---@field items table<number, TDLZ_ListItemViewModel>
---@field marginLeft number
---@field itemheight number
---@field width number
---@field buttons table<number,TDLZ_ListItemOptionButton>
---@field eraseButton TDLZ_ListItemOptionButton
---@field editButton TDLZ_ListItemOptionButton
---@field moveMode boolean
---@field tickTexture any
---@field itemToMoveIndex number
---@field onHighlight TDLZ_TargetAndCallback
TDLZ_ISList = TDLZ_MultiSelectScrollList:derive("TDLZ_ISList")

---@type number
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
---@type number
local MARGIN_TOP_BOTTOM = FONT_HGT_SMALL / 4
---@type number
local MARGIN_BETWEEN = FONT_HGT_SMALL / 4

-- Mouse Events Setters
-- -------------------------------------------------------------

---On item's checkbox click
---@param target any
---@param onCheckboxClick function
function TDLZ_ISList:setOnCheckboxClick(target, onCheckboxClick)
    self.onCheckboxClick = onCheckboxClick;
    self.target = target;
end

---On item's erase button click
---@param target any
---@param onEraseItem function
function TDLZ_ISList:setOnEraseItem(target, onEraseItem)
    self.eraseButton:setOnMouseUpCallback(target, onEraseItem)
end

---On item's edit button click
---@param target any
---@param onEditItem function
function TDLZ_ISList:setOnEditItem(target, onEditItem)
    self.editButton:setOnMouseUpCallback(target, onEditItem)
end

---@private
---On move item inside the list
---@param ctx any
---@param lineData TDLZ_BookLineModel
function TDLZ_ISList.handleOnMove(ctx, lineData)
    if ctx.itemToMoveIndex == -1 then
        ctx.itemToMoveIndex = lineData.lineNumber
        ctx.highlighted = TDLZ_NumSet:new()
        return
    end
    ctx.itemToMoveIndex = -1
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param previousState any
---@param onHighlight TDLZ_TargetAndCallback
---@return TDLZ_ISList
function TDLZ_ISList:new(x, y, width, height, previousState, onHighlight)
    local o = {}
    o = TDLZ_MultiSelectScrollList:new(x, y, width, height, onHighlight)
    setmetatable(o, self)
    self.__index = self

    o.width = width

    o.itemheight = FONT_HGT_SMALL + MARGIN_TOP_BOTTOM * 2
    o:setAnchorLeft(true)
    o:setAnchorRight(true)
    o:setAnchorTop(true)
    o:setAnchorBottom(true)
    o.drawBorder = true
    o.tickTexture = getTexture("Quest_Succeed");
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

    o.buttons = {
        TDLZ_ListItemOptionButton:new(getTexture("media/ui/move.png"), "Move element"),
        TDLZ_ListItemOptionButton:new(getTexture("media/ui/edit-line.png"), "Edit element"),
        TDLZ_ListItemOptionButton:new(getTexture("media/ui/erase.png"), "Erase element")
    }
    o.editButton = o.buttons[2]
    o.eraseButton = o.buttons[3]

    o.itemToMoveIndex = -1 -- -1 = not in move mode
    return o
end

function TDLZ_ISList:initialise()
    if self.javaObject == nil then
        print("Warning: initialising not instantiated component")
    end
    TDLZ_MultiSelectScrollList.initialise(self)
    self.buttons[1]:setOnMouseUpCallback(self, TDLZ_ISList.handleOnMove)
end

---@param notebookID number
---@param currentPage number
---@param notebookItems TDLZ_Set
---@param currentNotebook any
function TDLZ_ISList:_update(notebookID, currentPage, pageText, notebookItems, currentNotebook)
    if currentPage == self.currentPage and notebookID == self.notebookID and pageText == self.pageText then
        return
    end
    self.notebookID = notebookID
    self.currentPage = currentPage
    self.pageText = pageText

    self:clearItems()

    if self.pageText ~= "" then
        local lines = TDLZ_StringUtils.splitKeepingEmptyLines(self.pageText)
        for lineNumber, lineString in ipairs(lines) do
            local listItemText = TDLZ_StringUtils.removeCheckboxSquareBrackets(lineString)
            self:addItem(
                TDLZ_TodoListZWindow.createLabel(listItemText, notebookItems),
                TDLZ_TodoListZWindow._createItemDataModel(lineString, lineNumber, currentPage, currentNotebook))
        end
    end
end

function TDLZ_ISList:moveMode()
    return self.itemToMoveIndex ~= -1
end

---@param label string
---@param item TDLZ_BookLineModel
function TDLZ_ISList:addItem(label, item)
    if self:getScrollHeight() == 0 then
        self:setScrollHeight(4)
    end
    local listItemViewModel = TDLZ_ListItemViewModel:new(label, item, nil, self.count + 1, self.itemheight)
    table.insert(self.items, listItemViewModel)
    self.count = self.count + 1
    self:setScrollHeight(self:getScrollHeight() + listItemViewModel.height)
    return item
end

---@param winCtx TDLZ_TodoListZWindow
---@param t table<number,TDLZ_BookLineModel>
---@param from any
---@param to any
function TDLZ_ISList:moveAtRow(winCtx, t, from, to)
    local value = t[from]
    table.insert(t, to, value)
    if from > to then
        from = from + 1
    end

    table.remove(t, from)

    for key, value in pairs(t) do
        value.lineNumber = key
    end

    TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, t)
    winCtx:refreshUIElements()
end

function TDLZ_ISList:onMouseUp(x, mouseY)
    TDLZ_MultiSelectScrollList:onMouseUp(x, mouseY)
    if #self.items == 0 then return end
    local clickedRow = self:rowAt(x, mouseY)
    if clickedRow == nil then return end
    if clickedRow > #self.items or clickedRow < 1 then
        return
    end
    -- Dispatch mouse up event
    for key, btn in pairs(self.buttons) do
        if btn:contains(x, mouseY) then
            btn:triggerMouseUp(self.items[clickedRow].lineData)
            return
        end
    end

    local item = self.items[clickedRow]
    local isMouseOver = self.mouseOverRow == item.index and not self:isMouseOverScrollBar()
    local isMovingAndMouseHoverItem = self:moveMode() and isMouseOver
    local y = self:yAtRow(x, mouseY)
    if isMovingAndMouseHoverItem and mouseY < y + self.itemheight / 2
        and not (clickedRow - 1 == self.itemToMoveIndex or clickedRow == self.itemToMoveIndex) then
        self:moveAtRow(self.target, self:getItems(), self.itemToMoveIndex, clickedRow)
    elseif isMovingAndMouseHoverItem and mouseY > y + self.itemheight / 2
        and not (clickedRow + 1 == self.itemToMoveIndex or clickedRow == self.itemToMoveIndex) then
        self:moveAtRow(self.target, self:getItems(), self.itemToMoveIndex, clickedRow + 1)
    end

    if not self:moveMode() and self.marginLeft < x and x < self.marginLeft + BOX_SIZE and self.items[clickedRow].lineData.isCheckbox then
        getSoundManager():playUISound("UISelectListItem")
        if self.onCheckboxClick then
            self.onCheckboxClick(self.target, self.items[clickedRow].lineData);
        end
    end

    if not self:moveMode() and isCtrlKeyDown() then
        if self.highlighted:contains(clickedRow) then
            self.highlighted:remove(clickedRow)
            self.onHighlightCD.callback(self.onHighlightCD.target, self.highlighted:size())
        else
            self.highlighted:add(clickedRow)
            self.onHighlightCD.callback(self.onHighlightCD.target, self.highlighted:size())
        end
    elseif not self:moveMode() then
        if self.highlighted:contains(clickedRow) and self.highlighted:size() == 1 then
            -- remove highlight from choosen element only if one is highlighted
            self.highlighted = TDLZ_NumSet:new();
            self.onHighlightCD.callback(self.onHighlightCD.target, self.highlighted:size())
        else
            -- wipe all and add highlight choosen element
            self.highlighted = TDLZ_NumSet:new()
            self.highlighted:add(clickedRow)
            self.onHighlightCD.callback(self.onHighlightCD.target, self.highlighted:size())
        end
    end

    -- callback
    if self.onmouseup then
        self.onmouseup(self.target, self.items[self.selected].item);
    end
end

---@param y number
---@param item TDLZ_ListItemViewModel
---@param alt any
---@param itemIndex number
function TDLZ_ISList:doDrawItem(y, item, alt, itemIndex)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    TDLZ_ISList.drawLineBackground(self, y, alt)

    local mouseY = self:getMouseY()
    local isItemOvered = self.mouseOverRow == item.index and not self:isMouseOverScrollBar()
    local checkBoxY = y + (self.itemheight / 2 - BOX_SIZE / 2)

    if self:moveMode() and isItemOvered then
        if self:isItemAtIndexSelectedToBeMoved(itemIndex) then
            TDLZ_ISListDrawing.drawMoveTexture(self, y, TDLZ_Colors.YELLOW)
        else
        if mouseY < y + self.itemheight / 2 and not (itemIndex - 1 == self.itemToMoveIndex) then
            TDLZ_Draw.drawRect(self, 0, y - 1, self:getWidth(), 3, TDLZ_Colors.YELLOW)
        elseif mouseY > y + self.itemheight / 2 and not (itemIndex + 1 == self.itemToMoveIndex) then
            TDLZ_Draw.drawRect(self, 0, y + self.itemheight - 1, self:getWidth(), 3, TDLZ_Colors.YELLOW)
        end
        end
    elseif not self:moveMode() then
        if isItemOvered then
            if not self.highlighted:contains(itemIndex) then
                -- Mouse hover effect
                TDLZ_Draw.drawRect(self, 0, y, self:getWidth(), self.itemheight, TDLZ_Colors.GRAY_130)
            end
            self:handleMouseOverButtons(item, y)
        end
    
        -- Highlight effect
        if self.highlighted:contains(itemIndex) and item.lineData.isCheckbox then
            --- Item is highlighted
            TDLZ_Draw.drawRect(self, 3, y - 1, self.width - 5, self.itemheight + 2, TDLZ_Colors.GRAY_130)
            TDLZ_ISListDrawing.drawJobDelta(self, y, item.lineData.jobDelta)
            TDLZ_ISListDrawing.drawLineLeftHighlight(self, y)
        end
    end

    -- In any case, move or not move mode
    if item.lineData.isCheckbox then
        if item.lineData.isChecked then
            TDLZ_ISListDrawing.drawTickboxTick(self, checkBoxY)
        end
        TDLZ_ISListDrawing.drawTickboxBorders(self, checkBoxY, TDLZ_ISList.isJoypadFocusedOnTickbox(self, item))
    end

    TDLZ_ISListDrawing.drawText(self, y, item.text)
    return y + self.itemheight;
end

function TDLZ_ISList:handleMouseOverButtons(item, y)
    local mouseX = self:getMouseX()
    --- Mouse hover checkbox effect
    if item.lineData.isCheckbox
        and self.marginLeft < mouseX and mouseX < self.marginLeft + BOX_SIZE then
        TDLZ_Draw.drawRect(self, self.marginLeft, y+ (self.itemheight / 2 - BOX_SIZE / 2), BOX_SIZE, BOX_SIZE, TDLZ_Colors.GRAY_300)
    end

    --- Delete, edit and move buttons
    local btnX = self:getWidth() - self.marginLeft
    for key, btn in pairs(self.buttons) do
        btn.bounds.width = BOX_SIZE
        btnX = btnX - btn.bounds.width
        btn.bounds.x = btnX
        btn.bounds.y = y + self.itemheight / 2 - 9
        btn.bounds.height = 18
        if btn.bounds.x < self:getMouseX() and self:getMouseX() < btn.bounds.x + btn.bounds.width then
            TDLZ_Draw.drawTexture(self, btn.texture,
                btn.bounds.x, btn.bounds.y, TDLZ_Colors.WHITE)
        else
            TDLZ_Draw.drawTexture(self, btn.texture,btn.bounds.x, btn.bounds.y, TDLZ_Colors.GRAY_700)
        end
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

---@param o TDLZ_ISList
---@param item TDLZ_ListItemViewModel
---@return boolean true if over item checkbox
TDLZ_ISList.isJoypadFocusedOnTickbox = function(o, item)
    if joypadData==nil then return false end
    return joypadData.focus == o and o.selected == item.index
end
function TDLZ_ISList:isItemAtIndexSelectedToBeMoved(itemIndex)
    return itemIndex == self.itemToMoveIndex
end

function TDLZ_ISList:onJoypadDown(button, joypadData)
	if button == Joypad.AButton then
        if (#self.items > 0) and (self.selected ~= -1) then
            -- local previousSelected = self.selected;
            --self.onmousedblclick(self.target, self.items[self.selected].item);
            self.highlighted:add(self.selected)
        end
    else
        TDLZ_MultiSelectScrollList.onJoypadDown(self, button, joypadData);
    end
end