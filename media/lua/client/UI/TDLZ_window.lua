TDLZ_ISTodoListZWindow = ISCollapsableWindow:derive("TDLZ_ISTodoListZWindow")

TDLZ_UI = {}
-- ************************************************************************--
-- ** TodoListZManagerUI - toggle handler
-- ************************************************************************--
TDLZ_UI.instance = nil;
TDLZ_UI.toggle = function()
    if TDLZ_UI.instance == nil then
        print("TodoListZManagerWindow - window not initialized - create new window");
        TDLZ_UI.instance = TDLZ_ISTodoListZWindow:new();
    else
        print("TodoListZManagerWindow - window exists - close");
        TDLZ_UI.close()
        TDLZ_UI.instance = nil;
    end
end
TDLZ_UI.open = function()
    print("Creating new TodoListZManagerWindow")
    if TDLZ_UI.instance == nil then
        print("TDLZ - window not initialized - create new window");
        TDLZ_UI.instance = TDLZ_ISTodoListZWindow:new();
    end
end
TDLZ_UI.close = function()
    print("Closing TDLZ_UI")
    if TDLZ_UI.instance == nil then
        return
    end

    TDLZ_UI.instance:close();
    TDLZ_UI.instance = nil;
end
TDLZ_UI.getNotebookID = function()
    if TDLZ_UI.instance == nil then
        return -1
    end
    print("GET ID: " .. TDLZ_UI.instance.notebookID)
    return TDLZ_UI.instance.notebookID;
end

TDLZ_UI.setNotebookID = function(id)
    if TDLZ_UI.instance == nil then
        print("TDLZ - window not initialized - create new window");
        TDLZ_UI.instance = TDLZ_ISTodoListZWindow:new();
    end
    TDLZ_UI.instance.setNotebookID(id) 
end

TDLZ_UI.OnCreateUI = function()
   -- TDLZ_UI.open();
end
-- ************************************************************************--
-- ** TodoListZManagerUI:new
-- **
-- ************************************************************************--
function TDLZ_ISTodoListZWindow:new()
    local mD = TDLZ_ISTodoListZWindow.loadModData();

    local panelWidth = mD.panelSettings.width;
    local panelHeight = mD.panelSettings.height;
    local startingX = mD.panelSettings.x;
    local startingY = mD.panelSettings.y;
    local pin = mD.panelSettings.pin;

    local o = {}
    o = ISCollapsableWindow:new(startingX, startingY, panelWidth, panelHeight);
    setmetatable(o, self);
    self.__index = self;
    o.title = getText("IGUI_TDLZ_window_title");
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
    o.backgroundColor.a = 0.9;
    o.moveWithMouse = true;

    -- o.storedChannels = mD.storedChannels;
    o.renderedChannels = {}
    o.notebookID = mD.notebookID == nil and -1 or mD.notebookID

    o:initialise();
    o:addToUIManager();

    -- o:setInfo("test");

    return o;
end

function TDLZ_ISTodoListZWindow:setNotebookID(notebookID)
    
end

function TDLZ_ISTodoListZWindow:renderStoredChannels()
    -- clear rendered channels
    for _, rc in ipairs(self.renderedChannels) do
        rc.statusBtn:removeFromUIManager();
        rc.contentBtn:removeFromUIManager();
        rc.deleteBtn:removeFromUIManager();
        rc.prnt:removeChild(rc.statusBtn);
        rc.prnt:removeChild(rc.contentBtn);
        rc.prnt:removeChild(rc.deleteBtn);
    end
    for i, _ in ipairs(self.renderedChannels) do
        self.renderedChannels[i] = nil;
    end
    self.renderedChannels = {};

    -- table.sort(self.storedChannels, function(a, b) return a.Freq < b.Freq end);

    -- insert stored channels
    -- local idx = 0;
    -- for _, channel in ipairs(self.storedChannels) do
    -- table.insert(self.renderedChannels, self.createChannelRow(self, channel, idx));
    -- idx  = idx + 1;
    -- end

    -- save changes
    self:saveModData();
end

-- ************************************************************************--
-- ** TodoListZManagerUI - base
-- ************************************************************************--
function TDLZ_ISTodoListZWindow:initialise()
    ISCollapsableWindow.initialise(self);
    self:create();
end

function TDLZ_ISTodoListZWindow:prerender()
    ISCollapsableWindow.prerender(self);
end

function TDLZ_ISTodoListZWindow:render()
    ISCollapsableWindow.render(self);
end

-- ************************************************************************--
-- ** TodoListZManagerUI - creating
-- ************************************************************************--
function TDLZ_ISTodoListZWindow:create()
    -- "Toolbar" buttons - Import/Export
    self.copyButton = ISButton:new(15, 25, 25, 25, getText("UI_KRFM_CopyFromRadio"), self, self.onCopy);
    self.copyButton.tooltip = getText("UI_KRFM_CopyFromRadio_Tooltip");
    self.copyButton:initialise();
    self.copyButton:instantiate();
    self.copyButton.borderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    self:addChild(self.copyButton);

    self.customButton = ISButton:new(self.copyButton:getRight(), 25, 25, 25, getText("UI_KRFM_Custom"), self,
        self.onCustomAdd);
    self.customButton:initialise();
    self.customButton:instantiate();
    self.customButton.borderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    self:addChild(self.customButton);

    -- Render rows
    self:renderStoredChannels();
end

-- ************************************************************************--
-- ** TodoListZManagerUI - actions and radio data processing
-- ************************************************************************--
function TDLZ_ISTodoListZWindow:close()
    print("Saving TDLZ_ISTodoListZWindow mod data")
    self:saveModData();
    ISCollapsableWindow.close(self);
    self:setVisible(false);
    self:removeFromUIManager();
    TDLZ_UI.instance = nil;
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
                    pin = false
                }
            }
        end
        return modData.todoListZMod;
    end
    print("ERROR: failed to load player and mod data.");
    return nil;
end

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
        pin = self.pin
    };
    modData.todoListZMod.todoListData = {
        notebookID = self.notebookID
    };
    player:transmitModData();
end
function TDLZ_ISTodoListZWindow:getBookID()
    return self.notebookID
end

