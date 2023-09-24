require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_Vars'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_CheckboxUtils'
--- @class TDLZ_TodoListZWindow:ISCollapsableWindow
--- @field listbox TDLZ_ISList
--- @field model TDLZ_TodoListZWindowViewModel
--- @field x number
--- @field y number
--- @field height number
--- @field width number
--- @field modal1 any
--- @field onReviewOptCtxMenu TDLZ_GenericContextMenu
TDLZ_TodoListZWindow = ISCollapsableWindow:derive("TDLZ_TodoListZWindow")

TDLZ_TodoListZWindow.UI_MAP = TDLZ_Map:new()

function TDLZ_TodoListZWindow:getBookID() return self.model.notebook.notebookID end

---Set notebook id and refresh UI Elements
---@param notebookID number
function TDLZ_TodoListZWindow:setNotebookID(notebookID, pageNumber)
    TDLZ_TodoListZWindow.reloadModel(self, notebookID, pageNumber)
    self:refreshUIElements()
end

function TDLZ_TodoListZWindow:new()
    local o = {}
    local mD = TDLZ_ModData.loadModData();
    o = ISCollapsableWindow:new(mD.panelSettings.x, mD.panelSettings.y, mD.panelSettings.width, mD.panelSettings.height);
    o.pin = mD.panelSettings.pin
    o.minimumWidth = 300
    o.minimumHeight = 200
    o.resizable = true
    o.borderColor = WIN_BORDER_COLOR
    o.backgroundColor = WIN_BACKGROUND_COLOR
    o.drawFrame = true;
    o.moveWithMouse = true;
    setmetatable(o, self);
    self.__index = self;

    o.multiSelectMode = true
    o.frameChildren = {}

    TDLZ_TodoListZWindow.reloadModel(o, mD.todoListData.notebookID, mD.todoListData.pageNumber)

    o.listbox = nil
    o.executeMode = 0
    --   o.onReviewOptCtxMenu = nil
    o.onReviewOptCtxMenu = TDLZ_GenericContextMenu:new(0, 0 + 10, 200, 60)
    -- This will call the instantiate method
    o:initialise()
    o:addToUIManager()

    if o.pin then
        ISCollapsableWindow.pin(o)
    else
        ISCollapsableWindow.collapse(o)
    end

    TDLZ_TodoListZWindow.UI_MAP:add(o.ID, o)
    return o;
end

local TDLZ_DEBUG_RNumber = 0
function TDLZ_TodoListZWindow:refreshUIElements()
    TDLZ_DEBUG_RNumber = TDLZ_DEBUG_RNumber + 1
    local resizeBarHeight = self.resizable and self:resizeWidgetHeight() or 0
    local titleBarHeight = self:titleBarHeight()
    if self.model.notebook.notebookID == -1 then
        TDLZ_TodoListZWindow._setFormattedTitle(self, self.model.notebook.notebookID)
    else
        -- Set Title
        -- ---------
        TDLZ_TodoListZWindow._setFormattedTitle(self, self.model.notebook.currentNotebook:getName())

        ----------------------------
        -- Set Checkboxes
        local previousState = nil
        if self.listbox ~= nil then
            previousState = {
                mouseoverselected = self.listbox.mouseoverselected,
                yScroll = self.listbox:getYScroll(),
                highlighted = self.listbox.highlighted
            }
            self.listbox:clear()
            self:removeChild(self.listbox)
        end
        self:clearFrameChildren()

        ----------------------------
        -- Building PageNav
        local y = titleBarHeight
        local pageNav = TDLZ_PageNav:new(0, y, self.width, TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM)
        pageNav:initialise()
        TDLZ_PageNav.createPageNav(pageNav,
            self.model.notebook.currentPage, self.model.notebook.numberOfPages,
            self, TDLZ_TodoListZWindowController.onClick)
        self:addFrameChild(pageNav)

        ----------------------------
        -- Building TodoList
        y = titleBarHeight + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM
        local h = self.height - resizeBarHeight - titleBarHeight - TDLZ_BTN_DEFAULT_H * 2 - TDLZ_BTN_MV * 2 * 2;
        TDLZ_TodoListZWindow._createTodoList(self, 0, y, self.width, h, previousState)

        ----------------------------
        -- Building TodoListToolbar
        y = self.listbox.y + self.listbox.height + TDLZ_BTN_MV
        TDLZ_TodoListToolbar._createTodoListToolbar(self, y)
    end
    -- save changes
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(),
        self.model.notebook.notebookID, self.model.notebook.currentPage, self.listbox:getYScroll())

    if self.model.notebook.currentNotebook:getLockedBy() then
        local modal1 = TDLZ_ISNewItemModalMask:new(0,
            titleBarHeight + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM,
            self.width, self.height - (titleBarHeight + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM) - resizeBarHeight)
        modal1:initialise()
        self:addFrameChild(modal1)
    end

    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()
end

function TDLZ_TodoListZWindow:close()
    self.closingWindow = true
    getPlayer():setIgnoreAimingInput(false);
    self:setVisible(false)
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(),
        self.model.notebook.notebookID, self.model.notebook.currentPage)
    ISCollapsableWindow.close(self)
    self:removeFromUIManager();

    -- Callback
    if self.onClose then
        self:onClose()
    end

    TDLZ_TodoListZWindow.UI_MAP:remove(self.ID)
end

function TDLZ_TodoListZWindow.onHighlightChange(windowUI, int)
    if windowUI ~= nil then
        windowUI:refreshUIElements()
        return
    end
    error("Callback ok")
end

--- **********************************************************************
--- PRIVATE FUNCTIONS
--- **********************************************************************

function TDLZ_TodoListZWindow:initialise()
    ISCollapsableWindow.initialise(self);
    self.onReviewOptCtxMenu:instantiate()
    self.onReviewOptCtxMenu:setVisible(false)
    self.onReviewOptCtxMenu:initialise()
    self.onReviewOptCtxMenu:addToUIManager()


    self.closingWindow = false
    self:refreshUIElements();
end

---@private
function TDLZ_TodoListZWindow:prerender()
    ISCollapsableWindow.prerender(self);
end

---@private
function TDLZ_TodoListZWindow:render()
    ISCollapsableWindow.render(self);
end

---Add a child inside the Window frame
---@param child any UI Element
function TDLZ_TodoListZWindow:addFrameChild(child)
    self:addChild(child)
    table.insert(self.frameChildren, child)
end

---@private
function TDLZ_TodoListZWindow:clearFrameChildren()
    for index, c in pairs(self.frameChildren) do
        self:removeChild(c)
    end
    self.frameChildren = {}
end

---@private
---@param windowUI TDLZ_TodoListZWindow
---@param lineString string
---@param lineNumber number
---@param lines table
---@return TDLZ_BookLineModel
function TDLZ_TodoListZWindow._createItemDataModel(windowUI, lineString, lineNumber, lines)
    return TDLZ_BookLineModel.builder()
        :isCheckbox(TDLZ_CheckboxUtils.containsCheckBox(lineString))
        :isChecked(TDLZ_CheckboxUtils.containsCheckedCheckBox(lineString))
        :pageNumber(windowUI.model.notebook.currentPage)
        :lineNumber(lineNumber)
        :lineString(lineString)
        :notebook(windowUI.model.notebook.currentNotebook)
        :build()
end

---@private
---@param notebookID number
---@return TDLZ_NotebookModel
function TDLZ_TodoListZWindow._getNotebookData(notebookID, pageNumber)
    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local nb = notebookMap:get(notebookID)
    if nb == nil then
        return TDLZ_NotebookModel:new({}, -1, "", -1, -1)
    end
    if notebookID == nil or notebookID == -1 then
        return TDLZ_NotebookModel:new({}, -1, "", -1, -1)
    else
        return TDLZ_NotebookModel:new(nb, notebookID, nb:seePage(pageNumber), pageNumber, nb:getPageToWrite())
    end
end

---@private
function TDLZ_TodoListZWindow._setFormattedTitle(obj, id)
    local todoText = getText("IGUI_TDLZ_window_title")
    obj.title = tostring(id) .. " " .. todoText
end

---@private
---@param windowUI TDLZ_TodoListZWindow
---@param x number list x position
---@param y number list y position
---@param width number list width
---@param height number list height
---@param previousState any
function TDLZ_TodoListZWindow._createTodoList(windowUI, x, y, width, height, previousState)
    windowUI.listbox = TDLZ_ISList:new(x, y, width, height, previousState, {
        o = windowUI,
        f = TDLZ_TodoListZWindow.onHighlightChange
    })
    windowUI.listbox.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }

    windowUI.listbox:setOnMouseClick(windowUI, TDLZ_TodoListZWindowController.onOptionTicked)
    windowUI.listbox:setOnEraseItem(windowUI, TDLZ_TodoListZWindowController.onEraseItem)
    windowUI.listbox:setOnEditItem(windowUI, TDLZ_TodoListZWindowController.onEditItem)
    windowUI.listbox:initialise()
    windowUI.listbox:instantiate()
    local pageText = windowUI.model.notebook.currentNotebook:seePage(windowUI.model.notebook.currentPage)
    if pageText ~= "" then
        local lines = TDLZ_StringUtils.splitKeepingEmptyLines(pageText)
        for lineNumber, lineString in ipairs(lines) do
            local listItemText = TDLZ_StringUtils.removeCheckboxSquareBrackets(lineString)
            windowUI.listbox:addItem(
                windowUI:createLabel(listItemText),
                TDLZ_TodoListZWindow._createItemDataModel(windowUI, lineString, lineNumber, lines))
        end
    end
    windowUI:addChild(windowUI.listbox)
    if (previousState ~= nil) then
        --windowUI.listbox:addScrollBars(false)
        windowUI.listbox:setYScroll(previousState.yScroll)
    end
end

--- @private
function TDLZ_TodoListZWindow:createLabel(label)
    local allHash = TDLZ_StringUtils.findAllHashTagName(label)
    local cursorIndex = 0
    local text = ""

    for key, value in pairs(allHash) do
        text = text .. string.sub(label, cursorIndex, value.startIndex - 1)
        local hashtagName = TDLZ_ItemsFinderService.filterName2(string.sub(
            string.sub(label, value.startIndex, value.endIndex), 2), self.model.allItems)
        if hashtagName ~= nil then
            text = text .. "#[" .. hashtagName:getDisplayName() .. "]"
        end
        cursorIndex = value.endIndex + 1
    end

    text = text .. string.sub(label, cursorIndex)
    return text
end

--- This does not refresh the UI
---@param o any
---@param notebookID any
---@param pageNumber any
function TDLZ_TodoListZWindow.reloadModel(o, notebookID, pageNumber)
    local notebookData = nil
    if notebookID == nil then
        notebookData = TDLZ_TodoListZWindow._getNotebookData(-1, 1)
        o.model = TDLZ_TodoListZWindowViewModel:new(notebookData, {})
    else
        notebookData = TDLZ_TodoListZWindow._getNotebookData(notebookID, pageNumber)
        local itemList = TDLZ_TodoListZWindowController.getHashnames(notebookData.currentNotebook)
        o.model = TDLZ_TodoListZWindowViewModel:new(notebookData, itemList)
    end
end

function TDLZ_TodoListZWindow:onMouseMove(dx, dy)
    ISCollapsableWindow.onMouseMove(self, dx, dy);
    getPlayer():setIgnoreAimingInput(self:isMouseOver() and not self.closingWindow);
    if self.moving then
        self:updatePosition()
    end
end

function TDLZ_TodoListZWindow:onMouseMoveOutside(dx, dy)
    ISCollapsableWindow.onMouseMoveOutside(self, dx, dy);
    getPlayer():setIgnoreAimingInput(false);
    if self.moving then
        self:updatePosition()
    end
end

function TDLZ_TodoListZWindow:onResize()
    print("onresize")
    ISCollapsableWindow.onResize(self)
    self:updatePosition()
end

function TDLZ_TodoListZWindow:updatePosition()
    if self.buttonSelectOpt ~= nil then
        self.onReviewOptCtxMenu:setX(self.buttonSelectOpt:getAbsoluteX())
        self.onReviewOptCtxMenu:setY(self.buttonSelectOpt:getAbsoluteY() + self.buttonSelectOpt.height)
    end
end

---@param executeMode number
function TDLZ_TodoListZWindow:setExecuteMode(executeMode)
    self.executeMode = executeMode
end
