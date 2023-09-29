require 'Utils/TDLZ_Vars'
---@class TDLZ_TodoListToolbar:ISPanelJoypad
---@field buttonNewItem ISButton
---@field btnSelectAll ISButton
---@field buttonBack ISButton
---@field buttonSelectOpt ISButton
---@field btnExecute ISButton
---@field taskLabel ISLabel
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
    

    y = 0
   -- o.backgroundColor = TDLZ_Colors.YELLOW
    --o.borderColor = TDLZ_Colors.RED

    o.buttonNewItem = ISButton:new(TDLZ_HALF_REM, y,
        100,
        TDLZ_BTN_DEFAULT_H,
        "+ Add...")
    -- Create "Select All" Button
    --- TDLZ_BTN_DEFAULT_H
    o.btnSelectAll = ISButton:new(
        o.buttonNewItem.x + o.buttonNewItem.width + TDLZ_QUARTER_REM, y, 120,
        500, "Select all")
    --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
    o.btnSelectAll.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    o.btnSelectAll.anchorBottom = true
    o.btnSelectAll.anchorLeft = false
    o.btnSelectAll.anchorRight = true
    o.btnSelectAll.anchorTop = false
    o.btnSelectAll:setVisible(false)
    o:addChild(o.btnSelectAll);

    ---
    o.buttonBack = ISButton:new(TDLZ_HALF_REM, y, TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H,
        "")
    o.buttonBack:setImage(getTexture("media/ui/arrow-small-left.png"));
    o.buttonBack.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 0 }
    o.buttonBack.anchorBottom = true
    o.buttonBack.anchorLeft = true
    o.buttonBack.anchorRight = false
    o.buttonBack.anchorTop = false
    o.buttonBack.onclick = function()
        self.listbox.highlighted = TDLZ_NumSet:new();
        self:refreshUIElements()
        self:setJoypadButtons(joypadData)
    end
    o.buttonBack:setVisible(false)
    o:addChild(o.buttonBack);

    o.buttonSelectOpt = ISComboBox:new(o.buttonBack.x + o.buttonBack.width + TDLZ_REM * 0.5, y, 100,
        TDLZ_BTN_DEFAULT_H, self, TDLZ_TodoListZWindowController.onSelectItem)
    --o.buttonSelectOpt:setImage(getTexture("media/ui/trashIcon.png"));
    o.buttonSelectOpt.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    o.buttonSelectOpt.anchorBottom = true
    o.buttonSelectOpt.anchorLeft = true
    o.buttonSelectOpt.anchorRight = false
    o.buttonSelectOpt.anchorTop = false
    o.buttonSelectOpt.selected = o.executeMode
    o.buttonSelectOpt:addOptionWithData("Review", { id = 1 })
    o.buttonSelectOpt:addOptionWithData("Check", { id = 2 })
    o.buttonSelectOpt:addOptionWithData("Uncheck", { id = 3 })
    --  o.buttonSelectOpt:setOnClick(TDLZ_TodoListZWindowController.onClickReviewOptButton, o)
    o.buttonSelectOpt:setVisible(false)
    o:addChild(o.buttonSelectOpt);

    o.btnExecute = ISButton:new(o.buttonSelectOpt.x + o.buttonSelectOpt.width, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, "", o, TDLZ_TodoListZWindowController.onExecuteClick)
    o.btnExecute:setImage(getTexture("media/ui/execute.png"));
    o.btnExecute.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    o.btnExecute.anchorBottom = true
    o.btnExecute.anchorLeft = true
    o.btnExecute.anchorRight = false
    o.btnExecute.anchorTop = false
    o.btnExecute:setVisible(false)
    o:addChild(o.btnExecute);

    -- numOfTasks = o.listbox.highlighted:size()
    o.taskLabel = ISLabel:new(o.btnExecute.x + o.btnExecute.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, 0 .. " Tasks", 1, 1, 1, 1,
        UIFont.Small, true);
    o.taskLabel.anchorBottom = true
    o.taskLabel.anchorRight = false
    o.taskLabel.anchorLeft = true
    o.taskLabel.anchorTop = false
    o.taskLabel:initialise();
    o.taskLabel:instantiate()
    o.taskLabel:setVisible(false)
    o:addChild(o.taskLabel);


    return o
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
end

function TDLZ_TodoListToolbar:onButtonNewClick(btnNewClickTarget, btnNewClickCallback)
   -- self.buttonNewItem.onclick = function()
    --    TDLZ_TargetAndCallback:new(btnNewClickTarget, btnNewClickCallback):call()
    --end
end

function TDLZ_TodoListToolbar:onButtonSelectAll(btnNewClickTarget, btnNewClickCallback)
    self.btnSelectAll.onclick = function()
        TDLZ_TargetAndCallback:new(btnNewClickTarget, btnNewClickCallback):call()
    end
end

---@param size number
function TDLZ_TodoListToolbar:_update(size)
    if size > 0 then
        self.buttonNewItem:setVisible(false)
        self.btnSelectAll:setVisible(false)

        -- Highlight controls
        self.buttonBack:setVisible(true)
        self.buttonSelectOpt:setVisible(true)
        self.btnExecute:setVisible(true)
        self.taskLabel:setVisible(true)
    else
        self.buttonNewItem:setVisible(true)
        self.btnSelectAll:setVisible(true)

        -- Highlight controls
        self.buttonBack:setVisible(false)
        self.buttonSelectOpt:setVisible(false)
        self.btnExecute:setVisible(false)
        self.taskLabel:setVisible(false)
    end
end
