require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_CheckboxUtils'

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
    o.minimumHeight = 300;
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
    local todoText = getText("IGUI_TDLZ_window_title");
    obj.title = tostring(id) .. " " .. todoText;
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
        TDLZ_ISTodoListZWindowUtils._createPageNav(self, y)

        y = tbh + TDLZ_BTN_DEFAULT_H + 0.5 * TDLZ_REM
        local h = self.height - rh - tbh - TDLZ_BTN_DEFAULT_H * 2 - TDLZ_BTN_MV * 2 * 2;
        TDLZ_ISTodoListZWindowUtils._createTodoList(self, 0, y, self.width, h, previousState)

        y = self.listbox.y + self.listbox.height + TDLZ_BTN_MV
        TDLZ_ISTodoListZWindowUtils._createTodoListToolbar(self, y)
    end
    -- save changes
    TDLZ_ModData.saveModData(self.x, self.y, self.width, self.height, self.pin, not self:getIsVisible(), self.notebookID);
    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()
end

function TDLZ_ISTodoListZWindow:onOptionTicked(data)
    local toWrite = ""
    for ln, s in pairs(data.lines) do
        local sep = "\n"
        if ln == 1 then
            sep = "";
        end
        if ln == data.lineNumber then
            if not data.isChecked then
                -- add x
                s = s:gsub(CK_BOX_CHECKED_R_PATTERN, function(space)
                    return space .. "[x]"
                end, 1)
            else
                -- remove
                s = s:gsub(CK_BOX_CHECKED_PATTERN, function(space)
                    return space .. "[_]"
                end, 1)
            end
            toWrite = toWrite .. sep .. s
        else
            toWrite = toWrite .. sep .. s
        end
    end
    -- Get notebook object
    data.notebook:addPage(data.pageNumber, toWrite);
    self:refreshUIElements();
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
