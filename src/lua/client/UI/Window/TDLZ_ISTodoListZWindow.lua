require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_CheckboxUtils'
--- @class TDLZ_ISTodoListZWindow
--- @field listbox TDLZ_ISList
--- @field notebook any
--- @field notebookID number
--- @field height number
--- @field width number
TDLZ_ISTodoListZWindow = ISCollapsableWindow:derive("TDLZ_ISTodoListZWindow")

CK_BOX_CHECKED_PATTERN = "^(%s-)%[([Xx])%]"
CK_BOX_CHECKED_R_PATTERN = "^(%s-)%[([ _])%]"
TDLZ_REM = getTextManager():getFontHeight(UIFont.Small)
TDLZ_BTN_MV = 0.25 * TDLZ_REM
TDLZ_BTN_DEFAULT_H = TDLZ_REM * 1.25
local WIN_BACKGROUND_COLOR = { r = 0, g = 0, b = 0, a = 0.8 }
local WIN_BORDER_COLOR = { r = 0.4, g = 0.4, b = 0.4, a = 1 }

function TDLZ_ISTodoListZWindow:getBookID() return self.notebookID end

---Set notebook id and refresh UI Elements
---@param notebookID number
function TDLZ_ISTodoListZWindow:setNotebookID(notebookID)
    TDLZ_ISTodoListZWindow:_setNotebookID(self, notebookID)
    self:refreshUIElements()
end

function TDLZ_ISTodoListZWindow:new()
    local mD = TDLZ_ModData.loadModData();
    local o = {}
    o = ISCollapsableWindow:new(mD.panelSettings.x, mD.panelSettings.y, mD.panelSettings.width, mD.panelSettings.height);
    setmetatable(o, self);
    self.__index = self;

    o.multiSelectMode = true
    o.frameChildren = {}
    o.pin = mD.panelSettings.pin

    if mD.todoListData == nil or mD.todoListData.notebookID == nil then
        TDLZ_ISTodoListZWindow:_setNotebookID(o, -1)
    else
        TDLZ_ISTodoListZWindow:_setNotebookID(o, mD.todoListData.notebookID)
    end

    -- Window notebook status
    o.x = mD.panelSettings.x
    o.y = mD.panelSettings.y
    o.width = mD.panelSettings.width
    o.height = mD.panelSettings.height
    o.minimumWidth = 300;
    o.minimumHeight = 600;
    o.resizable = true;
    o.drawFrame = true;
    o.moveWithMouse = true;

    o.borderColor = WIN_BORDER_COLOR
    o.backgroundColor = WIN_BACKGROUND_COLOR

    o.listbox = nil

    -- This will call the instantiate method
    o:initialise();

    o:addToUIManager();
    if o.pin then
        ISCollapsableWindow.pin(o)
    else
        ISCollapsableWindow.collapse(o)
    end
    return o;
end

function TDLZ_ISTodoListZWindow:onMouseMove(dx, dy)
    ISCollapsableWindow.onMouseMove(self, dx, dy);
    getPlayer():setIgnoreAimingInput(self:isMouseOver() and not self.closingWindow);
end

function TDLZ_ISTodoListZWindow:onMouseMoveOutside(dx, dy)
    ISCollapsableWindow.onMouseMoveOutside(self, dx, dy);
    getPlayer():setIgnoreAimingInput(false);
end

function TDLZ_ISTodoListZWindow:refreshUIElements()
    if self.notebookID == -1 then
        TDLZ_ISTodoListZWindow._setFormattedTitle(self, self.notebookID)
    else
        -- Set Title
        -- ---------
        TDLZ_ISTodoListZWindow._setFormattedTitle(self, self.notebook.currentNotebook:getName())

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

        -- Create tibox
        local resizeBarHeight = self.resizable and self:resizeWidgetHeight() or 0
        local titleBarHeight = self:titleBarHeight()

        ----------------------------
        -- Building PageNav
        local y = titleBarHeight
        local pageNav = TDLZ_PageNav:new(0, y, self.width, TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM)
        pageNav:initialise()
        pageNav:createPageNav(
            self.notebook.currentPage, self.notebook.numberOfPages,
            self, TDLZ_TodoListZWindowController.onClick)
        self:addFrameChild(pageNav)

        ----------------------------
        -- Building TodoList
        y = titleBarHeight + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM
        local h = self.height - resizeBarHeight - titleBarHeight - TDLZ_BTN_DEFAULT_H * 2 - TDLZ_BTN_MV * 2 * 2;
        TDLZ_ISTodoListZWindow._createTodoList(self, 0, y, self.width, h, previousState)

        ----------------------------
        -- Building TodoListToolbar
        y = self.listbox.y + self.listbox.height + TDLZ_BTN_MV
        TDLZ_TodoListToolbar._createTodoListToolbar(self, y)
    end
    -- save changes
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(), self.notebookID);
    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()
end

function TDLZ_ISTodoListZWindow:close()
    self.closingWindow = true
    getPlayer():setIgnoreAimingInput(false);
    self:setVisible(false)
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(), self.notebookID);
    ISCollapsableWindow.close(self);
    self:removeFromUIManager();

    -- Callback
    if self.onClose then
        self:onClose()
    end
end

function TDLZ_ISTodoListZWindow.onHighlightChange(windowUI, int)
    if windowUI ~= nil then
        windowUI:refreshUIElements()
        return
    end
    error("Callback ok")
end

--- **********************************************************************
--- PRIVATE FUNCTIONS
--- **********************************************************************

function TDLZ_ISTodoListZWindow:initialise()
    ISCollapsableWindow.initialise(self);

    self.closingWindow = false
    self:refreshUIElements();
end

---@private
function TDLZ_ISTodoListZWindow:prerender()
    ISCollapsableWindow.prerender(self);
end

---@private
function TDLZ_ISTodoListZWindow:render()
    ISCollapsableWindow.render(self);
end

---@private
---Add a child inside the Window frame
---@param child any UI Element
function TDLZ_ISTodoListZWindow:addFrameChild(child)
    self:addChild(child)
    table.insert(self.frameChildren, child)
end

---@private
function TDLZ_ISTodoListZWindow:clearFrameChildren()
    for index, c in pairs(self.frameChildren) do
        self:removeChild(c)
    end
    self.frameChildren = {}
end

---@private
---@param windowUI TDLZ_ISTodoListZWindow
---@param lineString string
---@param lineNumber number
---@param lines table
---@return TDLZ_ISListItemDataModel
function TDLZ_ISTodoListZWindow._createItemDataModel(windowUI, lineString, lineNumber, lines)
    return TDLZ_ISListItemDataModel.builder()
        :isCheckbox(TDLZ_CheckboxUtils.containsCheckBox(lineString))
        :isChecked(TDLZ_CheckboxUtils.containsCheckedCheckBox(lineString))
        :pageNumber(windowUI.notebook.currentPage)
        :lineNumber(lineNumber)
        :lineString(lineString)
        :lines(lines)
        :notebook(windowUI.notebook.currentNotebook)
        :build()
end

---@private
---@param o TDLZ_ISTodoListZWindow
---@param notebookID number
function TDLZ_ISTodoListZWindow:_setNotebookID(o, notebookID)
    if (notebookID == nil) then
        o.notebookID = -1
    else
        o.notebookID = notebookID
    end

    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local nb = notebookMap:get(o.notebookID)
    if nb == nil then o.notebookID = -1 end
    if o.notebookID == -1 then
        TDLZ_ISTodoListZWindow._setFormattedTitle(o, o.notebookID)
        o.notebook = {
            currentNotebook = {},
            currentPage = -1,
            numberOfPages = -1
        }
    else
        TDLZ_ISTodoListZWindow._setFormattedTitle(o, nb:getName())
        o.notebook = {
            currentNotebook = nb,
            currentPage = 1,
            numberOfPages = nb:getPageToWrite()
        }
    end
end

---@private
function TDLZ_ISTodoListZWindow._setFormattedTitle(obj, id)
    local todoText = getText("IGUI_TDLZ_window_title")
    obj.title = tostring(id) .. " " .. todoText
end

---@private
---@param windowUI TDLZ_ISTodoListZWindow
---@param x number list x position
---@param y number list y position
---@param width number list width
---@param height number list height
---@param previousState any
function TDLZ_ISTodoListZWindow._createTodoList(windowUI, x, y, width, height, previousState)
    windowUI.listbox = TDLZ_ISList:new(x, y, width, height, windowUI, previousState, {
        o = windowUI,
        f = TDLZ_ISTodoListZWindow.onHighlightChange
    });
    windowUI.listbox:setOnMouseClick(windowUI, TDLZ_TodoListZWindowController.onOptionTicked);

    local pageText = windowUI.notebook.currentNotebook:seePage(windowUI.notebook.currentPage);
    if pageText ~= "" then
        local lines = TDLZ_StringUtils.splitKeepingEmptyLines(pageText)
        for lineNumber, lineString in ipairs(lines) do
            local listItemText = lineString:gsub(CK_BOX_FLEX_PATTERN, function(space)
                return space
            end, 1)
            windowUI.listbox:addItem(
                TDLZ_ISListItemModel:new(
                    TDLZ_ISTodoListZWindow.createLabel(listItemText),
                    TDLZ_ISTodoListZWindow._createItemDataModel(windowUI, lineString, lineNumber, lines)
                ));
        end
    end

    if (previousState ~= nil) then
        windowUI.listbox:setYScroll(previousState.yScroll)
    end
    windowUI:addChild(windowUI.listbox);
end

--- @private
function TDLZ_ISTodoListZWindow.createLabel(label)
    local allHash = TDLZ_StringUtils.findAllHashTagName(label)

    local cursorIndex = 0
    local text = ""
    for key, value in pairs(allHash) do
        text = text .. string.sub(label, cursorIndex, value.startIndex - 1)
        local hashtagName = TDLZ_ItemsFinderService.filterName2(string.sub(
        string.sub(label, value.startIndex, value.endIndex), 2))
        if hashtagName ~= nil then
            text = text .. hashtagName:getDisplayName()
        end
        cursorIndex = value.endIndex + 1
    end
    text = text .. string.sub(label, cursorIndex)
    return text
end
