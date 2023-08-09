require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_StringUtils'
TDLZ_ISTodoListZWindow = ISCollapsableWindow:derive("TDLZ_ISTodoListZWindow")
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

    local hidden = false;
    if mD.panelSettings.hidden then
        hidden = true
    end
    print("On create - UI hidden: " .. tostring(hidden))
    local o = {}
    o = ISCollapsableWindow:new(startingX, startingY, panelWidth, panelHeight);
    setmetatable(o, self);
    self.__index = self;
    if mD.todoListData == nil or mD.todoListData.notebookID == nil then
        o.notebookID = -1
    else
        o.notebookID = mD.todoListData.notebookID
    end
    if o.notebookID == -1 then
        TDLZ_ISTodoListZWindow._setFormattedTitle(o, o.notebookID)
    else
        local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
        TDLZ_ISTodoListZWindow._setFormattedTitle(o, TDLZ_Map.get(notebookMap, o.notebookID):getName())
    end

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
    o:setVisible(not hidden)
    -- o.storedChannels = mD.storedChannels;
    o.renderedChannels = {}

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
    self.notebookID = notebookID;
    self:refreshUIElements()
end
function ISCheatPanelUI:onTicked(index, selected)
end
function TDLZ_ISTodoListZWindow:addOption(text, selected, setFunction)
    local n = self.tickBox:addOption(text)
    self.tickBox:setSelected(n, selected)
    self.setFunction[n] = setFunction
end

function TDLZ_ISTodoListZWindow:refreshUIElements()
    self.setFunction = {}
    if self.notebookID == -1 then
        TDLZ_ISTodoListZWindow._setFormattedTitle(self, self.notebookID)
    else
        -- Book ID changed (and different from -1), refresh whole UI
        -- =========================================================
        local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
        -- Get notebook object
        local currentNotebook = TDLZ_Map.get(notebookMap, self.notebookID)

        -- Set Title
        -- ---------
        TDLZ_ISTodoListZWindow._setFormattedTitle(self, currentNotebook:getName())

        -- Set Checkboxes
        -- ---------------
        if self.tickBox~=nil then
            self.tickBox:clearOptions()
        end
        self.tickBox = ISTickBox:new(10, 50, 100, 20, "Admin Powers", self, self.onTicked)
        self.tickBox.choicesColor = {r=1, g=1, b=1, a=1}
        self.tickBox.leftMargin = 2
        self.tickBox:setFont(UIFont.Small)
        self:addChild(self.tickBox);

        -- Save pages
        self.newPage = {}
        for i = 0, currentNotebook:getCustomPages():size() - 1 do
            local currentIndex = i + 1
            self.newPage[currentIndex] = currentNotebook:seePage(currentIndex);
            local lines = TDLZ_StringUtils.split(self.newPage[currentIndex], "\n")
            self.filterUI = {}
            for lineNumber, lineString in ipairs(lines) do
                self:addOption(lineString, false, function(self, selected)
                    print("Checkbox clicked " .. selected)
                end);
            end
        end
    end
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
    -- Render UI
    self:refreshUIElements();
end

-- ************************************************************************--
-- ** TodoListZManagerUI - actions and radio data processing
-- ************************************************************************--
function TDLZ_ISTodoListZWindow:close()
    print("Saving TDLZ_ISTodoListZWindow mod data")
    self:setVisible(false)
    self:saveModData();
    ISCollapsableWindow.close(self);
    self:removeFromUIManager();
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

