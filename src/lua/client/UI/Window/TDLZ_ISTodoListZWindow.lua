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
-- ************************************************************************--
-- ** TodoListZManagerUI:new
-- **
-- ************************************************************************--
CK_BOX_CHECKED_PATTERN = "^(%s-)%[([Xx])%]"
CK_BOX_CHECKED_R_PATTERN = "^(%s-)%[([ _])%]"
TDLZ_REM = getTextManager():getFontHeight(UIFont.Small)
TDLZ_BTN_MV = 0.25 * TDLZ_REM
TDLZ_BTN_DEFAULT_H = TDLZ_REM * 1.25
TDLZ_BTN_DEFAULT_BORDER_COLOR = {
    r = 0.5,
    g = 0.5,
    b = 0.5,
    a = 1
}

function TDLZ_ISTodoListZWindow:getBookID() return self.notebookID end

---@param o TDLZ_ISTodoListZWindow
---@param notebookID number
local function _setNotebookID(o, notebookID)
    if (notebookID == nil) then
        o.notebookID = -1
    else
        o.notebookID = notebookID
    end

    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local nb = TDLZ_Map.get(notebookMap, o.notebookID)
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
function TDLZ_ISTodoListZWindow:setNotebookID(notebookID)
    _setNotebookID(self, notebookID)
    self:refreshUIElements()
end

-- Frame functions
------------------
---Add a child inside the Window frame
---@param child any UI Element
function TDLZ_ISTodoListZWindow:addFrameChild(child)
    self:addChild(child)
    table.insert(self.frameChildren, child)
end

function TDLZ_ISTodoListZWindow:clearFrameChildren()
    for index, c in pairs(self.frameChildren) do
        self:removeChild(c)
    end
    self.frameChildren = {}
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
        _setNotebookID(o, -1)
    else
        _setNotebookID(o, mD.todoListData.notebookID)
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

    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 1
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };

    o.listbox = nil

    o:initialise();
    -- This will call the instantiate method
    o:addToUIManager();
    if o.pin then
        ISCollapsableWindow.pin(o)
    else
        ISCollapsableWindow.collapse(o)
    end
    return o;
end

function TDLZ_ISTodoListZWindow._setFormattedTitle(obj, id)
    local todoText = getText("IGUI_TDLZ_window_title")
    obj.title = tostring(id) .. " " .. todoText
end

function TDLZ_ISTodoListZWindow:onMouseMove(dx, dy)
    ISCollapsableWindow.onMouseMove(self, dx, dy);
    getPlayer():setIgnoreAimingInput(self:isMouseOver() and not self.closingWindow);
end

function TDLZ_ISTodoListZWindow:onMouseMoveOutside(dx, dy)
    ISCollapsableWindow.onMouseMoveOutside(self, dx, dy);
    getPlayer():setIgnoreAimingInput(false);
end

function TDLZ_ISTodoListZWindow:onClick(button)
    if button.internal == "NEXTPAGE" then
        self.notebook.currentPage = self.notebook.currentPage + 1;
    elseif button.internal == "PREVIOUSPAGE" then
        self.notebook.currentPage = self.notebook.currentPage - 1;
    elseif button.internal == "DELETEPAGE" then
        self.entry:setText("");
        self.entry.javaObject:setCursorLine(0);
    elseif button.internal == "LOCKBOOK" then
        self.lockButton:setImage(getTexture("media/ui/lock.png"));
        self.lockButton.internal = "UNLOCKBOOK";
        self.notebook:setLockedBy(self.character:getUsername());
        self.title:setEditable(false);
        self.entry:setEditable(false);
        self.lockButton:setTooltip("Allow the journal to be edited");
        self:setJoypadButtons(self.joyfocus)
    elseif button.internal == "UNLOCKBOOK" then
        self.lockButton:setImage(getTexture("media/ui/lockOpen.png"));
        self.lockButton.internal = "LOCKBOOK";
        self.notebook:setLockedBy(nil);
        self.title:setEditable(true);
        self.entry:setEditable(true);
        self.lockButton:setTooltip("Prevent the journal from being edited");
        self:setJoypadButtons(self.joyfocus)
    end

    self:refreshUIElements()
end

function TDLZ_ISTodoListZWindow:refreshUIElements()
    if self.notebookID == -1 then
        TDLZ_ISTodoListZWindow._setFormattedTitle(self, self.notebookID)
    else
        -- Set Title
        -- ---------
        TDLZ_ISTodoListZWindow._setFormattedTitle(self, self.notebook.currentNotebook:getName())

        -- Set Checkboxes
        -- ---------------
        local selectedIndex = -1;
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

        -- Save pages
        self.newPage = {}

        -- Create tibox
        local rh = self.resizable and self:resizeWidgetHeight() or 0
        local tbh = self:titleBarHeight()

        local y = tbh
        TDLZ_ISTodoListZWindow._createPageNav(self, y)

        y = tbh + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM
        local h = self.height - rh - tbh - TDLZ_BTN_DEFAULT_H * 2 - TDLZ_BTN_MV * 2 * 2;
        TDLZ_ISTodoListZWindow._createTodoList(self, 0, y, self.width, h, previousState)

        y = self.listbox.y + self.listbox.height + TDLZ_BTN_MV
        TDLZ_ISTodoListZWindow._createTodoListToolbar(self, y)
    end
    -- save changes
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(), self.notebookID);
    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()
end

-- ************************************************************************--
-- ** TodoListZManagerUI - base
-- ************************************************************************--
function TDLZ_ISTodoListZWindow:initialise()
    ISCollapsableWindow.initialise(self);

    self.closingWindow = false
    self:refreshUIElements();
end

function TDLZ_ISTodoListZWindow:prerender()
    ISCollapsableWindow.prerender(self);
end

function TDLZ_ISTodoListZWindow:render()
    ISCollapsableWindow.render(self);
end

-- ************************************************************************--
-- ** TodoListZManagerUI - actions and radio data processing
-- ************************************************************************--
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

function TDLZ_ISTodoListZWindow._createPageNav(windowUI, titleBarHight)
    local y = titleBarHight + TDLZ_BTN_MV
    local buttonDelete = ISButton:new(TDLZ_REM * 0.25, y, TDLZ_REM * 1.5, TDLZ_BTN_DEFAULT_H, "")
    buttonDelete.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonDelete:setImage(getTexture("media/ui/trashIcon.png"));
    buttonDelete:setTooltip(getText("Tooltip_Journal_Erase"));
    buttonDelete.anchorBottom = false
    buttonDelete.anchorLeft = true
    buttonDelete.anchorRight = false
    buttonDelete.anchorTop = true
    windowUI:addFrameChild(buttonDelete);

    local buttonLock = ISButton:new(TDLZ_REM * 0.25 + buttonDelete.width + TDLZ_REM * 0.125, y, TDLZ_REM * 1.5,
        TDLZ_BTN_DEFAULT_H, "")
    buttonLock.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonLock.anchorBottom = false
    buttonLock.anchorLeft = true
    buttonLock.anchorRight = false
    buttonLock.anchorTop = true
    buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
    buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    windowUI:addFrameChild(buttonLock);

    windowUI.previousPage = ISButton:new(buttonLock.x + buttonLock.width + 0.5 * TDLZ_REM, y, TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, "<",
        windowUI, TDLZ_ISTodoListZWindow.onClick);
    windowUI.previousPage.internal = "PREVIOUSPAGE";
    windowUI.previousPage.anchorLeft = true
    windowUI.previousPage.anchorRight = false
    --windowUI.previousPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.previousPage.borderColor = BTN_ERROR_BORDER_COLOR;
    windowUI.previousPage:initialise();
    windowUI.previousPage:instantiate();
    if windowUI.notebook.currentPage == 1 then
        windowUI.previousPage:setEnable(false);
    else
        windowUI.previousPage:setEnable(true);
    end
    windowUI:addFrameChild(windowUI.previousPage);

    windowUI.nextPage = ISButton:new(windowUI.previousPage.x + windowUI.previousPage.width + 0.125 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, ">", windowUI, TDLZ_ISTodoListZWindow.onClick);
    windowUI.nextPage.internal = "NEXTPAGE";
    windowUI.nextPage.anchorLeft = true
    windowUI.nextPage.anchorRight = false
    -- windowUI.nextPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.nextPage.borderColor = BTN_ERROR_BORDER_COLOR;
    windowUI.nextPage:initialise();
    windowUI.nextPage:instantiate();
    if windowUI.notebook.currentPage == windowUI.notebook.numberOfPages then
        windowUI.nextPage:setEnable(false);
    else
        windowUI.nextPage:setEnable(true);
    end
    windowUI:addFrameChild(windowUI.nextPage);

    if windowUI.pageLabel ~= nil then
        windowUI:removeChild(windowUI.pageLabel)
    end
    windowUI.pageLabel = ISLabel:new(windowUI.nextPage.x + windowUI.nextPage.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, getText(
            "IGUI_Pages") .. windowUI.notebook.currentPage .. "/" .. windowUI.notebook.numberOfPages, 1, 1, 1, 1,
        UIFont.Small, true);
    windowUI.pageLabel.anchorRight = false
    windowUI.pageLabel.anchorLeft = true
    windowUI.pageLabel:initialise();
    windowUI.pageLabel:instantiate();
    windowUI:addFrameChild(windowUI.pageLabel);
end

function TDLZ_ISTodoListZWindow._createTodoListToolbar(windowUI, y)
    local buttonCheckOtherWidth = TDLZ_BTN_DEFAULT_H
    local buttonNewMarginLR = TDLZ_REM * 0.5
    local marginBetween = TDLZ_REM * 0.25
    if windowUI.listbox.highlighted:size() > 0 then
        local buttonCheckWidth = 140
        local buttonBack = ISButton:new(buttonNewMarginLR, y, TDLZ_BTN_DEFAULT_H,
            TDLZ_BTN_DEFAULT_H,
            "")
        buttonBack:setImage(getTexture("media/ui/arrow-small-left.png"));
        buttonBack.borderColor = {
            r = 0.5,
            g = 0.5,
            b = 0.5,
            a = 0
        };
        buttonBack.anchorBottom = true
        buttonBack.anchorLeft = true
        buttonBack.anchorRight = false
        buttonBack.anchorTop = false
        buttonBack.onclick = function()
            windowUI.listbox.highlighted = TDLZ_NumSet:new();
            TDLZ_ISTodoListTZWindowHandler.refreshContent();
        end
        windowUI:addFrameChild(buttonBack);



        local buttonUncheck = ISButton:new(buttonBack.x + buttonBack.width + TDLZ_REM * 0.5, y, 100,
            TDLZ_BTN_DEFAULT_H, "Review")
        --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
        buttonUncheck.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonUncheck.anchorBottom = true
        buttonUncheck.anchorLeft = true
        buttonUncheck.anchorRight = false
        buttonUncheck.anchorTop = false
        windowUI:addFrameChild(buttonUncheck);

        local btnExecute = ISButton:new(buttonUncheck.x + buttonUncheck.width, y, TDLZ_BTN_DEFAULT_H,
            TDLZ_BTN_DEFAULT_H, "", windowUI, TDLZ_TodoListZWindowController.onExecuteClick)
        btnExecute:setImage(getTexture("media/ui/execute.png"));
        btnExecute.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        btnExecute.anchorBottom = true
        btnExecute.anchorLeft = true
        btnExecute.anchorRight = false
        btnExecute.anchorTop = false
        windowUI:addFrameChild(btnExecute);

        local taskLabel = ISLabel:new(btnExecute.x + btnExecute.width + 0.5 * TDLZ_REM, y,
            TDLZ_BTN_DEFAULT_H, windowUI.listbox.highlighted:size() .. " Tasks", 1, 1, 1, 1,
            UIFont.Small, true);
        taskLabel.anchorBottom = true
        taskLabel.anchorRight = false
        taskLabel.anchorLeft = true
        taskLabel.anchorTop = false
        taskLabel:initialise();
        taskLabel:instantiate();

        windowUI:addFrameChild(taskLabel);
    else
        local buttonCheckWidth = 140
        local buttonNewItem = ISButton:new(buttonNewMarginLR, y,
            windowUI.width - marginBetween - buttonCheckWidth - buttonCheckOtherWidth - buttonNewMarginLR * 2,
            TDLZ_BTN_DEFAULT_H,
            "+ New...")
        buttonNewItem.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonNewItem.anchorBottom = true
        buttonNewItem.anchorLeft = true
        buttonNewItem.anchorRight = true
        buttonNewItem.anchorTop = false
        buttonNewItem.onclick = function()
            windowUI.modal1 = TDLZ_ISNewItemModalMask:new(windowUI.x, windowUI.y, windowUI.width, windowUI.height)
            windowUI.modal1:initialise();
            windowUI.modal1:addToUIManager();


            local modalHeight = 350;
            local modalWidth = 280;
            local mx = (windowUI.width - modalWidth) / 2
            local modal = TDLZ_ISNewItemModal:new(windowUI.x + mx, windowUI.y + windowUI.height - modalHeight - 50,
                modalWidth,
                modalHeight,
                windowUI, function()
                    windowUI.modal1:setVisible(false);
                    windowUI.modal1:removeFromUIManager();
                end)
            modal.backgroundColor.a = 0.9
            modal:initialise();
            modal:addToUIManager();
            --if JoypadState.players[getPlayer()+1] then
            --   setJoypadFocus(getPlayer(), modal)
            --end
        end
        windowUI:addFrameChild(buttonNewItem);

        local btnSelectAll = ISButton:new(buttonNewItem.x + buttonNewItem.width + TDLZ_REM * 0.25, y, buttonCheckWidth,
            TDLZ_BTN_DEFAULT_H, "Select all")
        --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
        btnSelectAll.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        btnSelectAll.anchorBottom = true
        btnSelectAll.anchorLeft = false
        btnSelectAll.anchorRight = true
        btnSelectAll.anchorTop = false
        btnSelectAll.onclick = function()
            for key, value in pairs(windowUI.listbox:getItems()) do
                if value.lineData.isCheckbox then
                    windowUI.listbox.highlighted:add(key)
                end
            end
            windowUI:refreshUIElements()
        end
        windowUI:addFrameChild(btnSelectAll);

        local buttonCheckOthers = ISButton:new(btnSelectAll.x + btnSelectAll.width, y, buttonCheckOtherWidth,
            TDLZ_BTN_DEFAULT_H,
            "")
        buttonCheckOthers:setImage(getTexture("media/ui/menu-dots-vertical.png"));
        buttonCheckOthers.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonCheckOthers.anchorBottom = true
        buttonCheckOthers.anchorLeft = false
        buttonCheckOthers.anchorRight = true
        buttonCheckOthers.anchorTop = false
        windowUI:addFrameChild(buttonCheckOthers);
    end
end

function TDLZ_ISTodoListZWindow.onHighlightChange(windowUI, int)
    if windowUI ~= nil then
        windowUI:refreshUIElements()
        return
    end
    error("Callback ok")
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

---comment
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

    local page = windowUI.notebook.currentNotebook:seePage(windowUI.notebook.currentPage);
    if page ~= "" then
        local lines = TDLZ_StringUtils.splitKeepingEmptyLines(page)
        for lineNumber, lineString in ipairs(lines) do
            local listItemText = lineString:gsub(CK_BOX_FLEX_PATTERN, function(space)
                return space
            end, 1)
            windowUI.listbox:addItem(
                TDLZ_ISListItemModel:new(
                    listItemText,
                    TDLZ_ISTodoListZWindow._createItemDataModel(windowUI, lineString, lineNumber, lines)
                ));
        end
    end
    if (previousState ~= nil) then
        windowUI.listbox:setYScroll(previousState.yScroll)
    end
    windowUI:addChild(windowUI.listbox);
end