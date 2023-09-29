require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_Vars'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_CheckboxUtils'
--- @class TDLZ_TodoListZWindow:ISCollapsableWindowJoypad
--- @field listbox TDLZ_ISList
--- @field model TDLZ_TodoListZWindowViewModel
--- @field x number
--- @field y number
--- @field height number
--- @field width number
--- @field lockedOverlay TDLZ_ISNewItemModalMask
--- @field pageNav TDLZ_PageNav
--- @field onReviewOptCtxMenu TDLZ_GenericContextMenu
--- @field allItems TDLZ_Set
--- @field editItemModal TDLZ_ISNewItemModal
--- @field player any
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
    o.pin = mD.panelSettings.pin
    o.minimumWidth = 300
    o.minimumHeight = 200
    o.resizable = true
    o.borderColor = WIN_BORDER_COLOR
    o.backgroundColor = WIN_BACKGROUND_COLOR
    o.drawFrame = true;
    o.moveWithMouse = true;
    o.isUnlocked = nil
    setmetatable(o, self);
    self.__index = self;

    o.listbox = nil
    o.pageNav = nil
    o.frameChildren = {}
    TDLZ_TodoListZWindow.reloadViewModel(o, mD.todoListData.notebookID, mD.todoListData.pageNumber)

    local items = getAllItems()
    local allItems = TDLZ_Map:new()
    for i = 0, items:size() - 1 do
        local item = items:get(i);
        if not item:getObsolete() and not item:isHidden() then
            allItems:add(item:getName(), item)
        end
    end
    o.allItems = allItems

    local modalHeight = 350;
    local modalWidth = 280;
    local mx = (o.width - modalWidth) / 2
    o.editItemModal = TDLZ_ISNewItemModal:new(o.x + mx, o.y + o.height - modalHeight - 50,
        modalWidth, modalHeight,
        o, o.allItems)

    o.executeMode = 1
    --   o.onReviewOptCtxMenu = nil
    o.onReviewOptCtxMenu = TDLZ_GenericContextMenu:new(0, 0 + 10, 200, 60)
    o.lockedOverlay = TDLZ_ISNewItemModalMask:new(0, 0, o.width, o.height)
    -- This will call the instantiate method
    o.debug_firstRun = true

    o:initialise()
    o:addToUIManager()

    if o.pin then
        ISCollapsableWindow.pin(o)
    else
        ISCollapsableWindow.collapse(o)
    end

    TDLZ_TodoListZWindow.UI_MAP:add(o.ID, o)
    o.player = player
    return o;
end

local TDLZ_DEBUG_RNumber = 0
function TDLZ_TodoListZWindow:refreshUIElements()
    TDLZ_DEBUG_RNumber = TDLZ_DEBUG_RNumber + 1
    print("Refresh UI Run #" .. TDLZ_DEBUG_RNumber)
    if self.model.notebook.notebookID == -1 then
        TDLZ_TodoListZWindow._setFormattedTitle(self, self.model.notebook.notebookID)
    else
        --- Refresh UI With ID
        print("Refresh UI WID #" .. TDLZ_DEBUG_RNumber)
        local notebook = self.model.notebook
        local _pageText = notebook.currentNotebook:seePage(notebook.currentPage)
        self:_setFormattedTitle(notebook.currentNotebook:getName())
        self.pageNav:_update(notebook.currentPage, notebook.numberOfPages, notebook.currentNotebook:getLockedBy() ~= nil)
        self.listbox:_update(notebook.notebookID, notebook.currentPage, _pageText, self.model.notebookItems,
            notebook.currentNotebook)
        TDLZ_TodoListToolbar.refreshTodoListToolbar(self)
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
        self.joypadIndexY = 2
        self:insertNewLineOfButtons(self.pageNav.buttonDelete, self.pageNav.buttonLock,
            self.pageNav.previousPage, self.pageNav.nextPage)
        self:insertNewLineOfButtons(self.buttonBack, self.buttonSelectOpt, self.btnExecute)
    else
        print("Joypad Buttons Set (n of highlighted: " .. self.listbox.highlighted:size() .. ")")
        self.joypadIndex = 2
        self.joypadIndexY = 2
        self:insertNewLineOfButtons(self.pageNav.buttonDelete, self.pageNav.buttonLock,
            self.pageNav.previousPage, self.pageNav.nextPage)
        self:insertNewLineOfButtons(self.buttonNewItem, self.btnSelectAll)
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
    self.buttonNewItem = ISButton:new(TDLZ_HALF_REM, y,
        100,
        TDLZ_BTN_DEFAULT_H,
        "+ Add...")
    self.buttonNewItem.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.buttonNewItem.anchorBottom = true
    self.buttonNewItem.anchorLeft = true
    self.buttonNewItem.anchorRight = true
    self.buttonNewItem.anchorTop = false
    self.buttonNewItem.onclick = function()
        self.lockedOverlay:setVisible(true)
        TDLZ_TodoListZWindowController.onEditItem(self,
            TDLZ_BookLineModel.builder()
            :lineNumber(-1) -- -1: new Item
            :lineString("")
            :notebook(self.model.notebook):build())
    end
    self.buttonNewItem:setVisible(false)
    self:addChild(self.buttonNewItem);

    -- Create "Select All" Button
    self.btnSelectAll = ISButton:new(
        self.buttonNewItem.x + self.buttonNewItem.width + TDLZ_QUARTER_REM, y, 120,
        TDLZ_BTN_DEFAULT_H, "Select all")
    --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
    self.btnSelectAll.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.btnSelectAll.anchorBottom = true
    self.btnSelectAll.anchorLeft = false
    self.btnSelectAll.anchorRight = true
    self.btnSelectAll.anchorTop = false
    self.btnSelectAll.onclick = function()
        for key, lineData in pairs(self.listbox:getItems()) do
            if lineData.isCheckbox then
                self.listbox.highlighted:add(key)
            end
        end
        self:refreshUIElements()
        self:setJoypadButtons(joypadData)
    end
    self.btnSelectAll:setVisible(false)
    self:addChild(self.btnSelectAll);

    ---
    self.buttonBack = ISButton:new(TDLZ_HALF_REM, y, TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H,
        "")
    self.buttonBack:setImage(getTexture("media/ui/arrow-small-left.png"));
    self.buttonBack.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 0 }
    self.buttonBack.anchorBottom = true
    self.buttonBack.anchorLeft = true
    self.buttonBack.anchorRight = false
    self.buttonBack.anchorTop = false
    self.buttonBack.onclick = function()
        self.listbox.highlighted = TDLZ_NumSet:new();
        self:refreshUIElements()
        self:setJoypadButtons(joypadData)
    end
    self.buttonBack:setVisible(false)
    self:addChild(self.buttonBack);

    self.buttonSelectOpt = ISComboBox:new(self.buttonBack.x + self.buttonBack.width + TDLZ_REM * 0.5, y, 100,
        TDLZ_BTN_DEFAULT_H, self, TDLZ_TodoListZWindowController.onSelectItem)
    --self.buttonSelectOpt:setImage(getTexture("media/ui/trashIcon.png"));
    self.buttonSelectOpt.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.buttonSelectOpt.anchorBottom = true
    self.buttonSelectOpt.anchorLeft = true
    self.buttonSelectOpt.anchorRight = false
    self.buttonSelectOpt.anchorTop = false
    self.buttonSelectOpt.selected = self.executeMode
    self.buttonSelectOpt:addOptionWithData("Review", { id = 1 })
    self.buttonSelectOpt:addOptionWithData("Check", { id = 2 })
    self.buttonSelectOpt:addOptionWithData("Uncheck", { id = 3 })
    --  self.buttonSelectOpt:setOnClick(TDLZ_TodoListZWindowController.onClickReviewOptButton, self)
    self.buttonSelectOpt:setVisible(false)
    self:addChild(self.buttonSelectOpt);

    self.btnExecute = ISButton:new(self.buttonSelectOpt.x + self.buttonSelectOpt.width, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, "", self, TDLZ_TodoListZWindowController.onExecuteClick)
    self.btnExecute:setImage(getTexture("media/ui/execute.png"));
    self.btnExecute.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.btnExecute.anchorBottom = true
    self.btnExecute.anchorLeft = true
    self.btnExecute.anchorRight = false
    self.btnExecute.anchorTop = false
    self.btnExecute:setVisible(false)
    self:addChild(self.btnExecute);

    self.taskLabel = ISLabel:new(self.btnExecute.x + self.btnExecute.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, self.listbox.highlighted:size() .. " Tasks", 1, 1, 1, 1,
        UIFont.Small, true);
    self.taskLabel.anchorBottom = true
    self.taskLabel.anchorRight = false
    self.taskLabel.anchorLeft = true
    self.taskLabel.anchorTop = false
    self.taskLabel:initialise();
    self.taskLabel:instantiate()
    self.taskLabel:setVisible(false)
    self:addChild(self.taskLabel);


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

---Update "indirect" child windows position
function TDLZ_TodoListZWindow:updatePosition()
    if self.buttonSelectOpt ~= nil then
        self.onReviewOptCtxMenu:setX(self.buttonSelectOpt:getAbsoluteX())
        self.onReviewOptCtxMenu:setY(self.buttonSelectOpt:getAbsoluteY() + self.buttonSelectOpt.height)
    end
end

---On Window resize
function TDLZ_TodoListZWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:updatePosition()
end

---@param executeMode number
function TDLZ_TodoListZWindow:setExecuteMode(executeMode)
    self.executeMode = executeMode
end
