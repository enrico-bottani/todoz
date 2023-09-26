TDLZ_TodoListToolbar = {}

local TDLZ_BTN_DEFAULT_BORDER_COLOR = { r = 0.5, g = 0.5, b = 0.5, a = 1 }

---@private
---@param windowUI TDLZ_TodoListZWindow
---@param y number
function TDLZ_TodoListToolbar._createTodoListToolbar(windowUI, y)
    local buttonCheckOtherWidth = TDLZ_BTN_DEFAULT_H
    local buttonNewMarginLR = TDLZ_REM * 0.5
    local marginBetween = TDLZ_REM * 0.25
    if windowUI.listbox.highlighted:size() > 0 then
        local buttonCheckWidth = 140
        local buttonBack = ISButton:new(buttonNewMarginLR, y, TDLZ_BTN_DEFAULT_H,
            TDLZ_BTN_DEFAULT_H,
            "")
        buttonBack:setImage(getTexture("media/ui/arrow-small-left.png"));
        buttonBack.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 0 }
        buttonBack.anchorBottom = true
        buttonBack.anchorLeft = true
        buttonBack.anchorRight = false
        buttonBack.anchorTop = false
        buttonBack.onclick = function()
            windowUI.listbox.highlighted = TDLZ_NumSet:new();
            windowUI:refreshUIElements()
        end
        windowUI:addFrameChild(buttonBack);

        windowUI.buttonSelectOpt = ISComboBox:new(buttonBack.x + buttonBack.width + TDLZ_REM * 0.5, y, 100,
            TDLZ_BTN_DEFAULT_H, windowUI, TDLZ_TodoListZWindowController.onSelectItem)
        --windowUI.buttonSelectOpt:setImage(getTexture("media/ui/trashIcon.png"));
        windowUI.buttonSelectOpt.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        windowUI.buttonSelectOpt.anchorBottom = true
        windowUI.buttonSelectOpt.anchorLeft = true
        windowUI.buttonSelectOpt.anchorRight = false
        windowUI.buttonSelectOpt.anchorTop = false
        windowUI.buttonSelectOpt.selected = windowUI.executeMode
        windowUI.buttonSelectOpt:addOptionWithData("Review", { id = 1 })
        windowUI.buttonSelectOpt:addOptionWithData("Check", { id = 2 })
        windowUI.buttonSelectOpt:addOptionWithData("Uncheck", { id = 3 })
        --  windowUI.buttonSelectOpt:setOnClick(TDLZ_TodoListZWindowController.onClickReviewOptButton, windowUI)
        windowUI:addFrameChild(windowUI.buttonSelectOpt);

        local btnExecute = ISButton:new(windowUI.buttonSelectOpt.x + windowUI.buttonSelectOpt.width, y,
            TDLZ_BTN_DEFAULT_H,
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
        if (windowUI.buttonNewItem == nil) then
            windowUI.buttonNewItem = ISButton:new(buttonNewMarginLR, y,
                windowUI.width - marginBetween - buttonCheckWidth - buttonCheckOtherWidth - buttonNewMarginLR * 2,
                TDLZ_BTN_DEFAULT_H,
                "+ New...")
            windowUI.buttonNewItem.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
            windowUI.buttonNewItem.anchorBottom = true
            windowUI.buttonNewItem.anchorLeft = true
            windowUI.buttonNewItem.anchorRight = true
            windowUI.buttonNewItem.anchorTop = false
            windowUI.buttonNewItem.onclick = function()
                TDLZ_TodoListZWindowController.onEditItem(windowUI,
                    TDLZ_BookLineModel.builder()
                    :lineNumber(-1) -- -1: new Item
                    :lineString("")
                    :notebook(windowUI.model.notebook):build())
            end
            windowUI:addChild(windowUI.buttonNewItem);
        end
        if (windowUI.btnSelectAll == nil) then
            windowUI.btnSelectAll = ISButton:new(
                windowUI.buttonNewItem.x + windowUI.buttonNewItem.width + TDLZ_REM * 0.25, y, buttonCheckWidth,
                TDLZ_BTN_DEFAULT_H, "Select all")
            --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
            windowUI.btnSelectAll.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
            windowUI.btnSelectAll.anchorBottom = true
            windowUI.btnSelectAll.anchorLeft = false
            windowUI.btnSelectAll.anchorRight = true
            windowUI.btnSelectAll.anchorTop = false
            windowUI.btnSelectAll.onclick = function()
                for key, lineData in pairs(windowUI.listbox:getItems()) do
                    if lineData.isCheckbox then
                        windowUI.listbox.highlighted:add(key)
                    end
                end
                windowUI:refreshUIElements()
            end
            windowUI:addChild(windowUI.btnSelectAll);
        end
        local buttonCheckOthers = ISButton:new(windowUI.btnSelectAll.x + windowUI.btnSelectAll.width, y, buttonCheckOtherWidth,
            TDLZ_BTN_DEFAULT_H,
            "")
        buttonCheckOthers:setImage(getTexture("media/ui/menu-dots-vertical.png"));
        buttonCheckOthers.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonCheckOthers.anchorBottom = true
        buttonCheckOthers.anchorLeft = false
        buttonCheckOthers.anchorRight = true
        buttonCheckOthers.anchorTop = false
        windowUI:addFrameChild(buttonCheckOthers)
    end
end
