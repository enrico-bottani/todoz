require 'src.lua.client.Utils.TDLZ_Vars'

---@class TDLZ_ISNewItemModal:ISPanelJoypad
---@field contextMenu TDLZ_ContextMenu Modal textbox contextual menu
---@field winCtx TDLZ_TodoListZWindow
---@field viewModel TDLZ_ISNewItemModalViewModel
---@field listItem TDLZ_BookLineModel
---@field textbox ISTextEntryBox
---@field label ISLabel
---@field lineType ISComboBox
---@field ckboxOptions ISTickBox
---@field yes ISButton
---@field no ISButton
TDLZ_ISNewItemModal = ISPanelJoypad:derive("TDLZ_ISNewItemModal");
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

TDLZ_ISNewItemModal.CHECKBOX_OPTION = 1
TDLZ_ISNewItemModal.OPTION_TXT = 2

local lineTypeWidth = 100


---@return TDLZ_ISNewItemModal
function TDLZ_ISNewItemModal:initialise()
    ISPanelJoypad.initialise(self)
    -- Instantiate children
    self.label:initialise()
    self.label:instantiate()
    self.label:setVisible(true)
    self:addChild(self.label)

    self.contextMenu:initialise()
    self.contextMenu:instantiate()
    self.contextMenu:setVisible(false)
    self.contextMenu:addToUIManager()

    self.textbox.font = UIFont.Small
    self.textbox:initialise()
    self.textbox:instantiate()
    self.textbox.onTextChange = function(ctx)
        self:setAlwaysOnTop(false)
        local cursorPosition = ctx.parent.textbox:getCursorPos()
        local absX = ctx.parent.textbox:getAbsoluteX()
        local absY = ctx.parent.textbox:getAbsoluteY() + ctx.parent.textbox.height
        self.contextMenu:setX(absX)
        self.contextMenu:setY(absY)
        local hashFound = TDLZ_StringUtils.findHashTagName(ctx.parent.textbox:getInternalText(), cursorPosition)
        self.contextMenu:searchAndDisplayResults(hashFound)
    end
    self:addChild(self.textbox);

    self.lineType:initialise()
    self.lineType:addOption("Checkbox")
    self.lineType:addOption("Text")
    self:addChild(self.lineType)

    self.ckboxOptions:initialise()
    self.ckboxOptions:instantiate()
    self.ckboxOptions:setAnchorLeft(true)
    self.ckboxOptions:setAnchorRight(false)
    self.ckboxOptions:setAnchorTop(true)
    self.ckboxOptions:setAnchorBottom(false)
    self.ckboxOptions.autoWidth = true
    self:addChild(self.ckboxOptions)
    self.ckboxOptions:addOption("Reset daily")

    self.yes:initialise()
    self.yes:instantiate()
    self.yes.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self.yes:setTitle("Save")
    self:addChild(self.yes)

    self.no:initialise()
    self.no:instantiate()
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.no)
    self:setHeight(self.no.y + self.no.height + TDLZ_REM * 0.75)
    return self
end


function TDLZ_ISNewItemModal:setListItem(listItem)
    self.listItem = listItem
    self.textbox:setText(TDLZ_StringUtils.removeCheckboxSquareBrackets(listItem.lineString))
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

function TDLZ_ISNewItemModal:onClose()
    self:setVisible(false)
    self.winCtx.lockedOverlay:setVisible(false)
    setJoypadFocus(self.winCtx.player, self.winCtx)
end

function TDLZ_ISNewItemModal:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData)
    self.borderColor = TDLZ_Colors.HIGHLIGHT
    self:setISButtonForA(self.yes)
    self:setISButtonForB(self.no)
    self.yes:setJoypadButton(Joypad.Texture.AButton)
    self.no:setJoypadButton(Joypad.Texture.BButton)
    self:setJoypadButtons(joypadData)
end

function TDLZ_ISNewItemModal:setJoypadButtons(joypadData)
    print("Joypad Buttons Start")
    if not joypadData then return end
    self:clearJoypadFocus(joypadData)
    self.joypadButtonsY = {}

    -- self.joypadButtonsY
    self.joypadIndex = 1
    self.joypadIndexY = 1

    self:insertNewLineOfButtons(self.textbox, self.lineType)
    self:insertNewLineOfButtons(self.yes, self.no)


    -- Set self.joypadButtons
    self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
    self.joypadIndex = math.min(math.max(self.joypadIndex, 1), #self.joypadButtons)
    self:restoreJoypadFocus(joypadData)
end

function TDLZ_ISNewItemModal:onClick(button)
    if button.internal == "CLOSE" then
        self:onClose()
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
        TDLZ_TodoListZWindow.reloadViewModel(self.winCtx, self.winCtx.model.notebook.notebookID,
            self.winCtx.model.notebook.currentPage)
        self.winCtx:refreshUIElements()
        self:onClose()
        return
    end
end

function TDLZ_ISNewItemModal:destroy()
    self:setVisible(false)
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
---@return table
function TDLZ_ISNewItemModal:new(x, y, width, height, winCtx)
    local o = {}
    --o.data = {}
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
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


    o.viewModel = {
        lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION,
    }
    o.fontHgt = TDLZ_REM
    o.listItem = {
        lineNumber = -1
    }

    -- Create ISLabel
    -- ------------------------------
    local addNewRowTxtLen = getTextManager():MeasureStringX(UIFont.Medium, "Add new row")
    o.label = ISLabel:new((o:getWidth() - addNewRowTxtLen) / 2, TDLZ_REM, FONT_HGT_MEDIUM, "Add new row", 1, 1, 1, 1,
        UIFont.Medium, true)

    -- Create ISTextEntryBox
    -- ------------------------------
    local inset = 2
    local numOfLines = 1
    local height = inset + TDLZ_REM * numOfLines + inset
    o.textbox = ISTextEntryBox:new("",
        TDLZ_REM * 0.75, label.y + TDLZ_REM + TDLZ_REM * 0.5,
        o:getWidth() - lineTypeWidth - (TDLZ_REM * 0.75) * 2,
        height);

    -- Create TDLZ_ContextMenu
    -- ------------------------------
    o.contextMenu = TDLZ_ContextMenu:new(0, 0, 200, 200)
    o.contextMenu:setOnCloseCallback(o, TDLZ_ISNewItemModal.onContextualMenuClose)
    o.contextMenu:setFont(UIFont.Small, 2)

    -- Create LineType ComboBox
    -- ------------------------------
    o.lineType = ISComboBox:new(o.textbox.x + o.textbox.width,
        o.textbox.y,
        lineTypeWidth,
        height, o, o.onLineTypeChange)

    -- Create Checkbox Option Tickbox
    -- ------------------------------
    o.ckboxOptions = ISTickBox:new(o.textbox.x, o.textbox.y + o.textbox.height, 10, 20, "", nil, nil)

    -- Create ISButton [YES|NO]
    -- ------------------------------

    local yesNoButtonSquare = {
        y = o.ckboxOptions.y + o.ckboxOptions.height + TDLZ_REM * 0.75,
        height = math.max(TDLZ_REM + 6, 25),
        width = math.max(math.max(
                getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12,
                getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12),
            100)
    }

    o.yes = ISButton:new(
        (o:getWidth() / 2) - 5 - yesNoButtonSquare.width, yesNoButtonSquare.y,
        yesNoButtonSquare.width, yesNoButtonSquare.height,
        "", o, TDLZ_ISNewItemModal.onClick);
    o.yes.internal = "OK"

    o.no = ISButton:new((o:getWidth() / 2) + 5, yesNoButtonSquare.y,
        yesNoButtonSquare.width, yesNoButtonSquare.height,
        getText("UI_Cancel"), o, TDLZ_ISNewItemModal.onClick);
    o.no.internal = "CLOSE"

    return o
end

---@class TDLZ_ISNewItemModalViewModel
---@field lineType number
TDLZ_ISNewItemModalViewModel = { lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION }
