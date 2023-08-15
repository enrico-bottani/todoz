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
local REM = getTextManager():getFontHeight(UIFont.Small)
local BTN_MV = 0.25 * REM
local BTN_DEFAULT_H = REM * 1.25
local BTN_DEFAULT_BORDER_COLOR = {
    r = 0.5,
    g = 0.5,
    b = 0.5,
    a = 1
}
local BTN_ERROR_BORDER_COLOR = {
    r = 1,
    g = 0,
    b = 0,
    a = 1
}
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
    self.notebookID = notebookID;
    self:refreshUIElements()
end


function TDLZ_ISTodoListZWindow:_createPageNav(titleBarHight)
    local y = titleBarHight + BTN_MV
    local buttonDelete = ISButton:new(REM * 0.25, y, REM * 1.5, BTN_DEFAULT_H, "")
    buttonDelete.borderColor = BTN_DEFAULT_BORDER_COLOR;
    buttonDelete:setImage(getTexture("media/ui/trashIcon.png"));
    buttonDelete:setTooltip(getText("Tooltip_Journal_Erase"));
    buttonDelete.anchorBottom = false
    buttonDelete.anchorLeft = true
    buttonDelete.anchorRight = false
    buttonDelete.anchorTop = true
    self:addChild(buttonDelete);
    local buttonLock = ISButton:new(REM * 0.25 + buttonDelete.width + REM * 0.125, y, REM * 1.5,
        BTN_DEFAULT_H, "")
    buttonLock.borderColor = BTN_DEFAULT_BORDER_COLOR;
    buttonLock.anchorBottom = false
    buttonLock.anchorLeft = true
    buttonLock.anchorRight = false
    buttonLock.anchorTop = true
    buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
    buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    self:addChild(buttonLock);

    local previousPage = ISButton:new(buttonLock.x + buttonLock.width + 0.5 * REM, y, BTN_DEFAULT_H,
        BTN_DEFAULT_H, "<");
    previousPage.internal = "PREVIOUSPAGE";
    previousPage.anchorLeft = true
    previousPage.anchorRight = false
    previousPage:initialise();
    previousPage:instantiate();
    previousPage.borderColor = BTN_ERROR_BORDER_COLOR;
    previousPage:setEnable(false);
    self:addChild(previousPage);

    local nextPage = ISButton:new(previousPage.x + previousPage.width + 0.125 * REM, y, BTN_DEFAULT_H,
        BTN_DEFAULT_H, ">");
    nextPage.internal = "NEXTPAGE";
    nextPage.anchorLeft = true
    nextPage.anchorRight = false
    nextPage:initialise();
    nextPage:instantiate();
    buttonDelete.borderColor = BTN_DEFAULT_BORDER_COLOR;
    self:addChild(nextPage);
    if self.pageLabel ~= nil then
        self:removeChild(self.pageLabel)
    end

    self.pageLabel = ISLabel:new(nextPage.x + nextPage.width + 0.5 * REM, y, BTN_DEFAULT_H,
        getText("IGUI_Pages") .. "1" .. "/" .. "10", 1, 1, 1, 1, UIFont.Small, true);
    self.pageLabel.anchorRight = false
    self.pageLabel.anchorLeft = true
    self.pageLabel:initialise();
    self.pageLabel:instantiate();
    self:addChild(self.pageLabel);
end

function TDLZ_ISTodoListZWindow:refreshUIElements()
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
        -- TEMP, let's test 1 page for now (change 1 to currentNotebook:getCustomPages():size() - 1)
        local rh = self.resizable and self:resizeWidgetHeight() or 0
        local tbh = self:titleBarHeight()
        local btnNewHeight = REM * 1.25


        self.listbox = TDLZ_ISList:new(0, tbh + btnNewHeight + 0.5 * REM, self.width,
            self.height - rh - tbh - btnNewHeight * 2 - BTN_MV * 2 * 2, self, previousState);
        self.listbox:setOnMouseClick(self, TDLZ_ISTodoListZWindow.onOptionTicked);
        for i = 0, 1 - 1 do
            local currentIndex = i + 1
            local page = currentNotebook:seePage(currentIndex);
            local lines = TDLZ_StringUtils.splitKeepingEmptyLines(page)
            for lineNumber, lineString in ipairs(lines) do
                self.listbox:addItem(lineString:gsub(CK_BOX_FLEX_PATTERN, function(space)
                    return space
                end, 1), {
                    isCheckbox = TDLZ_CheckboxUtils.containsCheckBox(lineString),
                    isChecked = TDLZ_CheckboxUtils.containsCheckedCheckBox(lineString),
                    pageNumber = currentIndex,
                    lineNumber = lineNumber,
                    lineString = lineString, -- test only (redundant)
                    lines = lines, -- test only (redundant)
                    notebook = currentNotebook
                });
            end
        end
        if (previousState ~= nil) then
            self.listbox:setYScroll(previousState.yScroll)
        end
        self:addChild(self.listbox);

        self:_createPageNav(tbh)

        local buttonNewMarginLeft = REM * 0.5
        local buttonNewItem = ISButton:new(REM * 0.5, self.height - rh - btnNewHeight - BTN_MV,
            self.width - 100 - REM, btnNewHeight, "New item")
        buttonNewItem.borderColor = {
            r = 0.5,
            g = 0.5,
            b = 0.5,
            a = 1
        };
        buttonNewItem.anchorBottom = true
        buttonNewItem.anchorLeft = true
        buttonNewItem.anchorRight = true
        buttonNewItem.anchorTop = false
        self:addChild(buttonNewItem);

        local marginRight = REM * 0.25
        local buttonCheckMarginLeft = buttonNewMarginLeft + REM * 0.25 + buttonNewItem.width
        local buttonCheck = ISButton:new(buttonCheckMarginLeft, self.height - rh - btnNewHeight - BTN_MV,
            100 - marginRight, btnNewHeight, "Check all")
        buttonCheck.borderColor = {
            r = 0.5,
            g = 0.5,
            b = 0.5,
            a = 1
        };
        buttonCheck.anchorBottom = true
        buttonCheck.anchorLeft = false
        buttonCheck.anchorRight = true
        buttonCheck.anchorTop = false
        self:addChild(buttonCheck);

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

