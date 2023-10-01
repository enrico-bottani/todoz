require 'src.lua.client.Utils.TDLZ_Map'
require 'Utils/TDLZ_Vars'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_CheckboxUtils'
---@class TDLZ_TodoListZWindow:ISCollapsableWindowJoypad
---@field listbox TDLZ_ISList
---@field model TDLZ_TodoListZWindowViewModel
---@field x number
---@field y number
---@field height number
---@field width number
---@field lockedOverlay TDLZ_ISNewItemModalMask
---@field pageNav TDLZ_PageNav
---@field onReviewOptCtxMenu TDLZ_GenericContextMenu
---@field editItemModal TDLZ_ISNewItemModal
---@field player any
---@field actions table<number,TDLZ_CheckEquipmentAction>
---@field todoListToolbar TDLZ_TodoListToolbar
TDLZ_TodoListZWindow = ISCollapsableWindowJoypad:derive("TDLZ_TodoListZWindow")

TDLZ_TodoListZWindow.UI_MAP = TDLZ_Map:new()


-- SETTERS AND GETTERS
-- ================================

-- Notebook Getter and Setters
-- --------------------------------

---Get notebook ID
---@return number
function TDLZ_TodoListZWindow:getNotebookID() return self.model.notebook.notebookID end

---Set notebook id, reload model and refresh UI Elements
---@param notebookID number
function TDLZ_TodoListZWindow:setNotebookID(notebookID, pageNumber)
    TDLZ_TodoListZWindow.reloadViewModel(self, notebookID, pageNumber)
    self:refreshUIElements()
end

function TDLZ_TodoListZWindow:new(player)
    local o = {}
    local mD = TDLZ_ModData.loadModData();
    o = ISCollapsableWindowJoypad:new(mD.panelSettings.x, mD.panelSettings.y, mD.panelSettings.width,
        mD.panelSettings.height);
    setmetatable(o, self);
    self.__index = self;

    o.pin = mD.panelSettings.pin
    o.minimumWidth = 300
    o.minimumHeight = 200
    o.resizable = true
    o.borderColor = WIN_BORDER_COLOR
    o.backgroundColor = WIN_BACKGROUND_COLOR
    o.drawFrame = true;
    o.moveWithMouse = true;
    o.player = player

    TDLZ_TodoListZWindow.reloadViewModel(o, mD.todoListData.notebookID, mD.todoListData.pageNumber)
    
    o.actions = {}
    o.listbox = nil
    o.pageNav = nil
    o.frameChildren = {}



    local modalHeight = 350;
    local modalWidth = 280;
    local mx = (o.width - modalWidth) / 2
    o.editItemModal = TDLZ_ISNewItemModal:new(o.x + mx, o.y + o.height - modalHeight - 50,
        modalWidth, modalHeight,
        o)
    --   o.onReviewOptCtxMenu = nil
    o.onReviewOptCtxMenu = TDLZ_GenericContextMenu:new(0, 0 + 10, 200, 60)
    o.lockedOverlay = TDLZ_ISNewItemModalMask:new(0, 0, o.width, o.height)
    -- This will call the instantiate method
    o.debug_firstRun = true

    o:initialise()
    o:addToUIManager()

    if o.pin then
        ISCollapsableWindowJoypad.pin(o)
    else
        ISCollapsableWindowJoypad.collapse(o)
    end

    TDLZ_TodoListZWindow.UI_MAP:add(o.ID, o)

    return o;
end

local TDLZ_DEBUG_RNumber = 0
function TDLZ_TodoListZWindow:refreshUIElements()
    TDLZ_DEBUG_RNumber = TDLZ_DEBUG_RNumber + 1
    if self.model.notebook.notebookID == -1 then
        TDLZ_TodoListZWindow._setFormattedTitle(self, self.model.notebook.notebookID)
    else
        --- Refresh UI With ID
        local notebook = self.model.notebook
        local _pageText = notebook.currentNotebook:seePage(notebook.currentPage)
        self:_setFormattedTitle(notebook.currentNotebook:getName())
        self.pageNav:_update(notebook.currentPage, notebook.numberOfPages, notebook.currentNotebook:getLockedBy() ~= nil)
        self.listbox:_update(notebook.notebookID, notebook.currentPage, _pageText, self.model.notebookItems,
            notebook.currentNotebook)
        --self.todoListToolbar:_update(self.listbox.highlighted:size())
        self.todoListToolbar:_update(self.listbox.highlighted:size())
        self.editItemModal:_update()
        self.lockedOverlay:_update(self.model.notebook.currentNotebook:getLockedBy() ~= nil)
    end

    -- Save Changes in Mod Data
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(),
        self.model.notebook.notebookID, self.model.notebook.currentPage, self.listbox:getYScroll())


    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()
end

function TDLZ_TodoListZWindow:onLoseJoypadFocus(joypadData)
    ISPanel.onLoseJoypadFocus(self, joypadData)
    self.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
end

function TDLZ_TodoListZWindow:setJoypadButtons(joypadData)
    print("Joypad Buttons Start")
    if not joypadData then return end
    self:clearJoypadFocus(joypadData)
    self.joypadButtonsY = {}

    -- self.joypadButtonsY

    if self.listbox.highlighted:size() > 0 then
        print("Joypad Buttons Set (n of highlighted: " .. self.listbox.highlighted:size() .. ")")
        self.joypadIndex = 1
        self.joypadIndexY = 3
        self:insertNewLineOfButtons(self.pageNav.buttonDelete, self.pageNav.buttonLock,
            self.pageNav.previousPage, self.pageNav.nextPage)
        self:insertNewLineOfButtons(self.listbox)
        self:insertNewLineOfButtons(self.todoListToolbar.buttonBack, self.todoListToolbar.buttonSelectOpt,
            self.todoListToolbar.btnExecute)
    else
        print("Joypad Buttons Set (n of highlighted: " .. self.listbox.highlighted:size() .. ")")
        self.joypadIndex = 1
        self.joypadIndexY = 3
        self:insertNewLineOfButtons(self.pageNav.buttonDelete, self.pageNav.buttonLock,
            self.pageNav.previousPage, self.pageNav.nextPage)
        self:insertNewLineOfButtons(self.listbox)
        self:insertNewLineOfButtons(self.todoListToolbar.buttonNewItem, self.todoListToolbar.btnSelectAll)
    end


    -- Set self.joypadButtons
    self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
    self.joypadIndex = math.min(math.max(self.joypadIndex, 1), #self.joypadButtons)
    self:restoreJoypadFocus(joypadData)
end

function TDLZ_TodoListZWindow:onGainJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData)
    self.borderColor = TDLZ_Colors.GREEN
    self:drawRectBorder(1, 1, self:getWidth() - 2, self:getHeight() - 2, 0.4, 0.2, 1.0, 1.0);
    -- self:setISButtonForA(self.yes)
    -- self:setISButtonForB(self.no)
    -- self.yes:setJoypadButton(Joypad.Texture.AButton)
    -- self.no:setJoypadButton(Joypad.Texture.BButton)
    self:setJoypadButtons(joypadData)
end

function TDLZ_TodoListZWindow:close()
    self.closingWindow = true
    getPlayer():setIgnoreAimingInput(false);
    self:setVisible(false)
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(),
        self.model.notebook.notebookID, self.model.notebook.currentPage)
    ISCollapsableWindowJoypad.close(self)
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
    assert(self.debug_firstRun, "Can only be initialised once!")
    self.debug_firstRun = false

    ISCollapsableWindowJoypad.initialise(self)

    -- UI Variables Creation
    local resizeBarHeight = self.resizable and self:resizeWidgetHeight() or 0
    local titleBarHeight = self:titleBarHeight()
    local y = titleBarHeight

    -- Create Pge Navigation
    self.pageNav = TDLZ_PageNav:new(0, y, self.width, TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM)
    self.pageNav:initialise()
    self.pageNav:instantiate()
    TDLZ_PageNav.createPageNav(self.pageNav,
        self.model.notebook.currentPage, self.model.notebook.numberOfPages,
        self, TDLZ_TodoListZWindowController.onClick)
    self:addChild(self.pageNav)
    y = y + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM

    -- Create Todos Multi Item List
    local h = self.height - resizeBarHeight - titleBarHeight - TDLZ_BTN_DEFAULT_H * 2 - TDLZ_BTN_MV * 2 * 2;
    TDLZ_TodoListZWindow._createTodoList(self, 0, y, self.width, h, nil)
    y = self.listbox.y + self.listbox.height + TDLZ_BTN_MV

    -- Create "New +" Button
    self.todoListToolbar = TDLZ_TodoListToolbar:new(0, y, self.width, TDLZ_BTN_DEFAULT_H)
    self.todoListToolbar:onButtonNewClick(self, TDLZ_TodoListZWindowController.createNewItem)
    self.todoListToolbar:onButtonSelectAll(self, TDLZ_TodoListZWindowController.selectAll)
    self.todoListToolbar:onButtonBackClick(self, TDLZ_TodoListZWindowController.onTodoListToolbarButtonBackClick)
    self.todoListToolbar:onButtonExecuteClick(self, TDLZ_TodoListZWindowController.onExecuteClick)

    self.todoListToolbar:instantiate()
    self.todoListToolbar:initialise()
    self:addChild(self.todoListToolbar);

    self.lockedOverlay:initialise()
    self.lockedOverlay:instantiate()
    self:addChild(self.lockedOverlay)
    self.lockedOverlay:setVisible(false)

    self.editItemModal:instantiate()
    self.editItemModal:initialise()
    self.editItemModal:setVisible(false)
    self.editItemModal:setAlwaysOnTop(true)
    self.editItemModal:addToUIManager()
    --self:addChild(self.editItemModal);


    self.closingWindow = false
    self:refreshUIElements()
end

---@private
function TDLZ_TodoListZWindow:prerender()
    ISCollapsableWindowJoypad.prerender(self);
end

---@private
function TDLZ_TodoListZWindow:render()
    ISCollapsableWindowJoypad.render(self);
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
---@param lineString string
---@param lineNumber number
---@param currentPage number
---@param currentNotebook any
---@return TDLZ_BookLineModel
function TDLZ_TodoListZWindow._createItemDataModel(lineString, lineNumber, currentPage, currentNotebook)
    return TDLZ_BookLineModel.builder()
        :isCheckbox(TDLZ_CheckboxUtils.containsCheckBox(lineString))
        :isChecked(TDLZ_CheckboxUtils.containsCheckedCheckBox(lineString))
        :pageNumber(currentPage)
        :lineNumber(lineNumber)
        :lineString(lineString)
        :notebook(currentNotebook)
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

    windowUI:addChild(windowUI.listbox)
    if (previousState ~= nil) then
        --windowUI.listbox:addScrollBars(false)
        windowUI.listbox:setYScroll(previousState.yScroll)
    end
    windowUI.listbox:setVisible(true)
end

---Create Label for ListItem
---@param rawLineText any
---@param notebookItems any
---@return string
function TDLZ_TodoListZWindow.createLabel(rawLineText, notebookItems)
    local allHash = TDLZ_StringUtils.findAllHashTagName(rawLineText)
    local cursorIndex = 0
    local text = ""

    for _key, value in pairs(allHash) do
        text = text .. string.sub(rawLineText, cursorIndex, value.startIndex - 1)
        local hashtagName = TDLZ_ItemsFinderService.filterName2(string.sub(
            string.sub(rawLineText, value.startIndex, value.endIndex), 2), notebookItems)
        if hashtagName ~= nil then
            text = text .. "#[" .. hashtagName:getDisplayName() .. "]"
        end
        cursorIndex = value.endIndex + 1
    end

    text = text .. string.sub(rawLineText, cursorIndex)
    return text
end

---Reload TodoListZ Window ViewModel
---@param winCtx TDLZ_TodoListZWindow
---@param notebookID number
---@param pageNumber number
function TDLZ_TodoListZWindow.reloadViewModel(winCtx, notebookID, pageNumber)
    local notebookData = nil
    if notebookID == nil then
        notebookData = TDLZ_TodoListZWindow._getNotebookData(-1, 1)
        winCtx.model = TDLZ_TodoListZWindowViewModel:new(notebookData, {})
    else
        notebookData = TDLZ_TodoListZWindow._getNotebookData(notebookID, pageNumber)
        local itemList = TDLZ_TodoListZWindowController.getHashnames(notebookData.currentNotebook)
        winCtx.model = TDLZ_TodoListZWindowViewModel:new(notebookData, itemList)
    end
end

function TDLZ_TodoListZWindow:onMouseMove(dx, dy)
    ISCollapsableWindowJoypad.onMouseMove(self, dx, dy);
    getPlayer():setIgnoreAimingInput(self:isMouseOver() and not self.closingWindow);
    if self.moving then
        self:updatePosition()
    end
end

function TDLZ_TodoListZWindow:onMouseMoveOutside(dx, dy)
    ISCollapsableWindowJoypad.onMouseMoveOutside(self, dx, dy);
    getPlayer():setIgnoreAimingInput(false);
    if self.moving then
        self:updatePosition()
    end
end

---Update "indirect" child windows position
function TDLZ_TodoListZWindow:updatePosition()
    if self.buttonSelectOpt ~= nil then
        self.onReviewOptCtxMenu:setX(self.buttonSelectOpt:getAbsoluteX())
        self.onReviewOptCtxMenu:setY(self.buttonSelectOpt:getAbsoluteY() + self.buttonSelectOpt.height)
    end
end

---On Window resize
function TDLZ_TodoListZWindow:onResize()
    ISCollapsableWindowJoypad.onResize(self)
    self:updatePosition()
end