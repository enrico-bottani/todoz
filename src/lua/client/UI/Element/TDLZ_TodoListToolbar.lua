require 'Utils/TDLZ_Vars'
---@class TDLZ_TodoListToolbar:ISPanelJoypad
---@field buttonNewItem ISButton
---@field btnSelectAll ISButton
---@field buttonBack ISButton
---@field buttonSelectOpt ISComboBox
---@field btnExecute ISButton
---@field taskLabel ISLabel
---@field viewModel {size:number,executeMode:number}
---@field toUpdate boolean
TDLZ_TodoListToolbar = ISPanelJoypad:derive("TDLZ_TodoListToolbar");
function TDLZ_TodoListToolbar:new(x, y, width, height)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.borderColor = TDLZ_Colors.TRANSPARENT

    o.anchorTop = false
    o.anchorBottom = true
    o.anchorLeft = true
    o.anchorRight = true

    o.toUpdate = false

    o.viewModel = {
        size = 0,
        executeMode = 1
    }

    y = 0
    o.buttonNewItem = ISButton:new(TDLZ_HALF_REM, y,
        100, TDLZ_BTN_DEFAULT_H,
        "+ Add...")
    o.btnSelectAll = ISButton:new(
        o.buttonNewItem.x + o.buttonNewItem.width + TDLZ_QUARTER_REM, y, 120,
        TDLZ_BTN_DEFAULT_H, "Select all")
    o.buttonBack = ISButton:new(TDLZ_HALF_REM, y,
        TDLZ_BTN_DEFAULT_H, TDLZ_BTN_DEFAULT_H,
        "")
    o.buttonSelectOpt = ISComboBox:new(o.buttonBack.x + o.buttonBack.width + TDLZ_REM * 0.5, y, 100,
        TDLZ_BTN_DEFAULT_H, o, TDLZ_TodoListToolbar.onSelectItem)
    o.buttonSelectOpt:addOptionWithData("Review", { id = 1 })
    o.buttonSelectOpt:addOptionWithData("Check", { id = 2 })
    o.buttonSelectOpt:addOptionWithData("Uncheck", { id = 3 })

    o.btnExecute = ISButton:new(o.buttonSelectOpt.x + o.buttonSelectOpt.width, y,
        TDLZ_BTN_DEFAULT_H, TDLZ_BTN_DEFAULT_H, "", o)
    o.taskLabel = ISLabel:new(o.btnExecute.x + o.btnExecute.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, 0 .. " Tasks", 1, 1, 1, 1,
        UIFont.Small, true)

    return o
end

function TDLZ_TodoListToolbar:onSelectItem(combobox)
    local comboboxItem = combobox:getOptionData(combobox.selected)
    if comboboxItem == nil then return end

    self.viewModel.executeMode = comboboxItem.id
end

function TDLZ_TodoListToolbar:initialise()
    ISPanelJoypad.initialise(self)
    print("TDLZ_TodoListToolbar:initialise BEGIN")
    self.buttonNewItem:initialise()
    self.buttonNewItem:instantiate()
    self.buttonNewItem.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.buttonNewItem.anchorBottom = false
    self.buttonNewItem.anchorLeft = true
    self.buttonNewItem.anchorRight = false
    self.buttonNewItem.anchorTop = true
    self.buttonNewItem:setVisible(true)
    self:addChild(self.buttonNewItem)

    self.btnSelectAll:initialise()
    self.btnSelectAll:instantiate()
    self.btnSelectAll.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.btnSelectAll.anchorBottom = true
    self.btnSelectAll.anchorLeft = false
    self.btnSelectAll.anchorRight = true
    self.btnSelectAll.anchorTop = false
    self.btnSelectAll:setVisible(true)
    self:addChild(self.btnSelectAll)

    self.buttonBack:initialise()
    self.buttonBack:instantiate()
    self.buttonBack:setImage(getTexture("media/ui/arrow-small-left.png"));
    self.buttonBack.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 0 }
    self.buttonBack.anchorBottom = true
    self.buttonBack.anchorLeft = true
    self.buttonBack.anchorRight = false
    self.buttonBack.anchorTop = false
    self.buttonBack:setVisible(false)
    self:addChild(self.buttonBack)

    self.buttonSelectOpt:initialise()
    self.buttonSelectOpt:instantiate()
    self.buttonSelectOpt.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.buttonSelectOpt.anchorBottom = true
    self.buttonSelectOpt.anchorLeft = true
    self.buttonSelectOpt.anchorRight = false
    self.buttonSelectOpt.anchorTop = false
    --  self.buttonSelectOpt:setOnClick(TDLZ_TodoListZWindowController.onClickReviewOptButton, self)
    self.buttonSelectOpt:setVisible(false)
    self:addChild(self.buttonSelectOpt);

    self.btnExecute:initialise()
    self.btnExecute:instantiate()
    self.btnExecute:setImage(getTexture("media/ui/execute.png"));
    self.btnExecute.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    self.btnExecute.anchorBottom = true
    self.btnExecute.anchorLeft = true
    self.btnExecute.anchorRight = false
    self.btnExecute.anchorTop = false
    self.btnExecute:setVisible(false)
    self:addChild(self.btnExecute)

    self.taskLabel:initialise()
    self.taskLabel:instantiate()
    self.taskLabel.anchorBottom = true
    self.taskLabel.anchorRight = false
    self.taskLabel.anchorLeft = true
    self.taskLabel.anchorTop = false
    self.taskLabel:setVisible(false)
    self:addChild(self.taskLabel)
end

function TDLZ_TodoListToolbar:onButtonNewClick(btnNewClickTarget, btnNewClickCallback)
    self.btnSelectAll:setOnClick(btnNewClickCallback, btnNewClickTarget)
end

function TDLZ_TodoListToolbar:onButtonSelectAll(btnNewClickTarget, btnNewClickCallback)
    self.btnSelectAll:setOnClick(btnNewClickCallback, btnNewClickTarget)
end

function TDLZ_TodoListToolbar:onButtonBackClick(btnBackTarget, btnBackClickCallback)
    self.buttonBack:setOnClick(btnBackClickCallback, btnBackTarget)
end

function TDLZ_TodoListToolbar:onButtonExecuteClick(winctx, callback)
    self.btnExecute.target = self
    self.btnExecute:setOnClick(callback, winctx)
end

---@param size number
function TDLZ_TodoListToolbar:_update(size)
    if self.viewModel.size == size then
        return
    end
    self.viewModel.size = size

    if size > 0 then
        self.buttonNewItem:setVisible(false)
        self.btnSelectAll:setVisible(false)

        self.taskLabel:setName(size .. " Tasks")
        self.buttonBack:setVisible(true)

        self.buttonSelectOpt:setVisible(true)
        self.btnExecute:setVisible(true)
        self.taskLabel:setVisible(true)
    else
        self.buttonNewItem:setVisible(true)
        self.btnSelectAll:setVisible(true)

        self.buttonBack:setVisible(false)
        self.buttonSelectOpt:setVisible(false)
        self.btnExecute:setVisible(false)
        self.taskLabel:setVisible(false)
    end
end
