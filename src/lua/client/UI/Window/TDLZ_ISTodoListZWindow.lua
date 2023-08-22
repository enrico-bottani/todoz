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


function TDLZ_ISTodoListZWindow:saveModData()
    local player = getPlayer();
    local modData = player:getModData()
    modData.todoListZMod.isFirstRun = false;
    modData.todoListZMod.storedChannels = self.storedChannels;
    modData.todoListZMod.panelSettings = {
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height,
        pin = self.pin,
        hidden = not self:getIsVisible()
    };
    modData.todoListZMod.todoListData = {
        notebookID = self.notebookID
    };
    player:transmitModData();
end

function TDLZ_ISTodoListZWindow:getBookID()
    return self.notebookID
end



local function _setNotebookID(o, notebookID)
    if (notebookID == nil) then
        o.notebookID = -1
    else
        o.notebookID = notebookID
    end

    if o.notebookID == -1 then
        TDLZ_ISTodoListZWindow._setFormattedTitle(o, o.notebookID)
        o.notebook = {
            currentNotebook = {},
            currentPage = -1,
            numberOfPages = -1
        }
    else
        local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
        local nb = TDLZ_Map.get(notebookMap, o.notebookID)
        TDLZ_ISTodoListZWindow._setFormattedTitle(o, nb:getName())
        o.notebook = {
            currentNotebook = nb,
            currentPage = 1,
            numberOfPages = nb:getPageToWrite()
        }
    end
end
function TDLZ_ISTodoListZWindow:new()
    local mD = TDLZ_ISTodoListZWindow.loadModData();

    local panelWidth = mD.panelSettings.width;
    local panelHeight = mD.panelSettings.height;
    local startingX = mD.panelSettings.x;
    local startingY = mD.panelSettings.y;
    local pin = mD.panelSettings.pin;

    local hidden = false;
    if mD.panelSettings.hidden then
        hidden = true
    end
    local o = {}
    o = ISCollapsableWindow:new(startingX, startingY, panelWidth, panelHeight);
    setmetatable(o, self);
    self.__index = self;

    if mD.todoListData == nil or mD.todoListData.notebookID == nil then
        _setNotebookID(o, -1)
    else
        _setNotebookID(o, mD.todoListData.notebookID)
    end

    -- Window notebook status

    o.pin = pin;
    o.x = startingX;
    o.y = startingY;
    o.width = panelWidth;
    o.height = panelHeight;
    o.minimumWidth = 300;
    o.minimumHeight = 100;
    o.resizable = true;
    o.drawFrame = true;
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
    o.moveWithMouse = true;
    o.listbox = nil

    o:setVisible(not hidden)
    -- o.storedChannels = mD.storedChannels;
    o:initialise();
    o:addToUIManager();

    -- o:setInfo("test");

    return o;
end

function TDLZ_ISTodoListZWindow._setFormattedTitle(obj, id)
    local todoText = getText("IGUI_TDLZ_window_title");
    obj.title = tostring(id) .. " " .. todoText;
end

function TDLZ_ISTodoListZWindow:setNotebookID(notebookID)
    -- is a different notebook id?
    if self.notebookID == notebookID then
        -- if same do nothing
        return
    end
    _setNotebookID(self, notebookID)

    self:refreshUIElements()
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
        --        print("add at pos " .. self.currentPage .. " text " .. self.entry:getText())
        -- self.newPage[self.currentPage] = self.entry:getText();
        self.notebook.currentPage = self.notebook.currentPage + 1;
        -- self.entry.javaObject:setCursorLine(0);
        -- self.entry:setText(self.newPage[self.currentPage]);
    elseif button.internal == "PREVIOUSPAGE" then
        -- self.newPage[self.currentPage] = self.entry:getText();
        self.notebook.currentPage = self.notebook.currentPage - 1;

        --        print("set text from pos " .. self.currentPage .. " text " .. self.newPage[self.currentPage]);
        -- self.entry.javaObject:setCursorLine(0);
        -- self.entry:setText(self.newPage[self.currentPage]);
    elseif button.internal == "DELETEPAGE" then
        -- self.newPage[self.currentPage] = "";
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
    else
        --   self.newPage[self.currentPage] = self.entry:getText();
        --  self:destroy();
        -- if self.onclick ~= nil then
        --   self.onclick(self.target, button, self.param1, self.param2);
        -- end
    end

    self:refreshUIElements()
    -- self.pinButton:setVisible(false);
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
            self.listbox:clear()
            self:removeChild(self.listbox)

            previousState = {
                mouseoverselected = self.listbox.mouseoverselected,
                yScroll = self.listbox:getYScroll()
            }
        end

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
    self:saveModData();
    self.resizeWidget2:bringToTop()
    self.resizeWidget:bringToTop()
end

function TDLZ_ISTodoListZWindow:onOptionTicked(data)
    print("Checkbox [page: " .. data.pageNumber .. ", line: " .. data.lineNumber .. "] " .. data.lineString ..
        "clicked ")
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
    print("Saving TDLZ_ISTodoListZWindow mod data")
    getPlayer():setIgnoreAimingInput(false);
    self:setVisible(false)
    self:saveModData();
    ISCollapsableWindow.close(self);
    self:removeFromUIManager();

    -- Callback
    if self.onClose then
        self:onClose()
    end
end

-- ************************************************************************--
-- ** TodoListZManagerUI - mod data
-- ************************************************************************--
function TDLZ_ISTodoListZWindow.loadModData()
    local player = getPlayer();
    if player then
        local modData = player:getModData()
        local reset = false;
        if modData.todoListZMod == nil or reset == true then
            modData.todoListZMod = {
                isFirstRun = true,
                todoListData = {
                    notebookID = -1
                },
                panelSettings = {
                    x = 70,
                    y = 400,
                    width = 400,
                    height = 300,
                    pin = false,
                    hidden = false
                }
            }
        end
        return modData.todoListZMod;
    end
    print("ERROR: failed to load player and mod data.");
    return nil;
end

