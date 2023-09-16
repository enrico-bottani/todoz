---@class TDLZ_ISNewItemModal
---@field contextMenu TDLZ_ISContextMenu Modal textbox contextual menu
---@field winCtx TDLZ_TodoListZWindow
---@field onCloseCallback function
---@field viewModel TDLZ_ISNewItemModalViewModel
---@field listItem TDLZ_BookLineModel
TDLZ_ISNewItemModal = ISPanelJoypad:derive("TDLZ_ISNewItemModal");
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

TDLZ_ISNewItemModal.CHECKBOX_OPTION = 1
TDLZ_ISNewItemModal.OPTION_TXT = 2

---@param o TDLZ_ISNewItemModal
---@return TDLZ_ISNewItemModal
function TDLZ_ISNewItemModal.initialise(o)
    ISPanelJoypad.initialise(o)

    local fontHgt = FONT_HGT_SMALL
    local lWidth = getTextManager():MeasureStringX(UIFont.Medium, "Add new row")
    local label = ISLabel:new((o:getWidth() - lWidth) / 2, FONT_HGT_SMALL, FONT_HGT_MEDIUM, "Add new row", 1, 1, 1, 1,
        UIFont.Medium, true)
    label:initialise()
    o:addChild(label)

    o.fontHgt = FONT_HGT_SMALL
    local inset = 2
    local numOfLines = 1
    local height = inset + o.fontHgt * numOfLines + inset
    local lineTypeWidth = 100
    o.textbox = ISTextEntryBox:new(o.listItem.lineString, FONT_HGT_SMALL * 0.75,
        label.y + label.height + FONT_HGT_SMALL * 0.5,
        o:getWidth() - lineTypeWidth - (FONT_HGT_SMALL * 0.75) * 2,
        height);
    o.textbox.font = UIFont.Small
    o.textbox:initialise()
    o.textbox:instantiate()

    o.contextMenu:setVisible(false)
    o.contextMenu:initialise()
    o.contextMenu:instantiate()
    o.contextMenu:addToUIManager()

    o.textbox.onTextChange = function(ctx)
        local cursorPosition = ctx.parent.textbox:getCursorPos()
        local absX = ctx.parent.textbox:getAbsoluteX()
        local absY = ctx.parent.textbox:getAbsoluteY() + ctx.parent.textbox.height
        o.contextMenu:setX(absX)
        o.contextMenu:setY(absY)
        local hashFound = TDLZ_StringUtils.findHashTagName(ctx.parent.textbox:getInternalText(), cursorPosition)
        o.contextMenu:searchAndDisplayResults(hashFound)
    end
    o:addChild(o.textbox);

    o.lineType = ISComboBox:new(o.textbox.x + o.textbox.width,
        o.textbox.y,
        lineTypeWidth,
        height, o, o.onLineTypeChange)
    o.lineType:initialise()
    o.lineType:addOption("Checkbox")
    o.lineType:addOption("Text")
    o:addChild(o.lineType)

    o.ckboxOptions = ISTickBox:new(o.textbox.x, o.textbox.y + o.textbox.height, 10, 20, "", nil, nil)
    o.ckboxOptions:initialise()
    o.ckboxOptions:instantiate()
    o.ckboxOptions:setAnchorLeft(true)
    o.ckboxOptions:setAnchorRight(false)
    o.ckboxOptions:setAnchorTop(true)
    o.ckboxOptions:setAnchorBottom(false)
    o.ckboxOptions.autoWidth = true
    o:addChild(o.ckboxOptions)
    o.ckboxOptions:addOption("Reset daily")

    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12
    local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)

    o.yes = ISButton:new((o:getWidth() / 2) - 5 - buttonWid,
        o.ckboxOptions.y + o.ckboxOptions.height + FONT_HGT_SMALL * 0.75, buttonWid,
        buttonHgt, "Add", o, TDLZ_ISNewItemModal.onClick);
    o.yes.internal = "OK";
    o.yes:initialise();
    o.yes:instantiate();
    o.yes.borderColor = { r = 1, g = 1, b = 1, a = 0.5 };
    o:addChild(o.yes);

    o.no = ISButton:new((o:getWidth() / 2) + 5,
        o.ckboxOptions.y + o.ckboxOptions.height + FONT_HGT_SMALL * 0.75, buttonWid, buttonHgt,
        getText("UI_Cancel"), o, TDLZ_ISNewItemModal.onClick);
    o.no.internal = "CLOSE";
    o.no:initialise()
    o.no:instantiate()
    o.no.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    o:addChild(o.no)
    o:setHeight(o.no.y + o.no.height + FONT_HGT_SMALL * 0.75)
    return o
end

function TDLZ_ISNewItemModal:onLineTypeChange(button)
    if button.selected == nil then
        self.viewModel.lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION
    else
        self.viewModel.lineType = button.selected
    end
    if self.viewModel.lineType == TDLZ_ISNewItemModal.CHECKBOX_OPTION then
        self.ckboxOptions:setVisible(true)
    else
        self.ckboxOptions:setVisible(false)
    end
end

function TDLZ_ISNewItemModal:onClick(button)
    if button.internal == "CLOSE" then
        self:destroy();
        return
    elseif button.internal == "OK" then
        local options = { type = TDLZ_ISNewItemModal.OPTION_TXT }
        if self.viewModel.lineType == TDLZ_ISNewItemModal.CHECKBOX_OPTION then
            options = {
                type = TDLZ_ISNewItemModal.CHECKBOX_OPTION,
                resetDaily = self.ckboxOptions:isSelected(1),
            }
        end
        local notebookItems = self.winCtx.listbox:getItems()
        if self.listItem.lineNumber == -1 then
            self.listItem.lineNumber = #self.winCtx.model.notebook:getPageLines() + 1
            TDLZ_NotebooksService.appendLineToNotebook(
                self.listItem,
                self.textbox:getText(),
                options)
            table.insert(notebookItems, self.listItem)
        else
            TDLZ_NotebooksService.appendLineToNotebook(
                self.listItem,
                self.textbox:getText(),
                options)
        end


        TDLZ_TodoListZWindowController.saveAllJournalData(self.winCtx, notebookItems)
        TDLZ_TodoListZWindow.reloadModel(self.winCtx, self.winCtx.model.notebook.notebookID)
        self.winCtx:refreshUIElements()
        self:destroy()
        return
    end
end

function TDLZ_ISNewItemModal:destroy()
    self:setVisible(false);
    self:removeFromUIManager();
    if self.contextMenu ~= nil then
        self.contextMenu:destroy()
    end
    if self.onCloseCallback and self.winCtx then
        self.onCloseCallback(self.winCtx)
    end
end

function TDLZ_ISNewItemModal:setHeight(h)
    local deltaH = self.height - h
    self.height = h;

    if self.javaObject ~= nil then
        self.javaObject:setHeight(h);
        self.javaObject:setY(self.y + deltaH);
    end
end

function TDLZ_ISNewItemModal:onContextualMenuClose(rtn)
    local internalText = self.textbox:getInternalText()
    local firstChunk = string.sub(internalText, 0, rtn.startIndex);
    local lastChunk = string.sub(internalText, rtn.endIndex + 1);
    self.textbox:setText(firstChunk .. rtn.text .. lastChunk)
    self.textbox:focus()
    self.textbox:setCursorPos(#firstChunk + #rtn.text)
end

---comment
---@param x number
---@param y number
---@param width number
---@param height number
---@param winCtx any
---@param onCloseCallback function
---@param listItem TDLZ_BookLineModel
---@return table
function TDLZ_ISNewItemModal:new(x, y, width, height, winCtx, listItem, onCloseCallback)
    local o = {}
    --o.data = {}
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x;
    o.y = y;
    o.background = true;
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.width = width;
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = false;
    o.anchorTop = true;
    o.anchorBottom = false;
    o.joypadButtons = {};
    o.joypadIndex = 0;
    o.joypadButtonsY = {};
    o.joypadIndexY = 0;
    o.moveWithMouse = false;
    o.winCtx = winCtx
    o.onCloseCallback = onCloseCallback
    o.listItem = listItem
    o.contextMenu = TDLZ_ISContextMenu:new(0, 0, 200, 200)
    o.contextMenu:setOnCloseCallback(o, TDLZ_ISNewItemModal.onContextualMenuClose)
    o.contextMenu:setFont(UIFont.Small, 2)
    o.viewModel = {
        lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION,
    }
    return o
end

---@class TDLZ_ISNewItemModalViewModel
---@field lineType number
TDLZ_ISNewItemModalViewModel = { lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION }
