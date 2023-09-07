TDLZ_TodoListToolbar = {}

---@private
---@param windowUI TDLZ_ISTodoListZWindow
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
        buttonBack.borderColor = {
            r = 0.5,
            g = 0.5,
            b = 0.5,
            a = 0
        };
        buttonBack.anchorBottom = true
        buttonBack.anchorLeft = true
        buttonBack.anchorRight = false
        buttonBack.anchorTop = false
        buttonBack.onclick = function()
            windowUI.listbox.highlighted = TDLZ_NumSet:new();
            TDLZ_ISTodoListTZWindowHandler.refreshContent();
        end
        windowUI:addFrameChild(buttonBack);



        local buttonUncheck = ISButton:new(buttonBack.x + buttonBack.width + TDLZ_REM * 0.5, y, 100,
            TDLZ_BTN_DEFAULT_H, "Review")
        --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
        buttonUncheck.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonUncheck.anchorBottom = true
        buttonUncheck.anchorLeft = true
        buttonUncheck.anchorRight = false
        buttonUncheck.anchorTop = false
        windowUI:addFrameChild(buttonUncheck);

        local btnExecute = ISButton:new(buttonUncheck.x + buttonUncheck.width, y, TDLZ_BTN_DEFAULT_H,
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
        local buttonNewItem = ISButton:new(buttonNewMarginLR, y,
            windowUI.width - marginBetween - buttonCheckWidth - buttonCheckOtherWidth - buttonNewMarginLR * 2,
            TDLZ_BTN_DEFAULT_H,
            "+ New...")
        buttonNewItem.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonNewItem.anchorBottom = true
        buttonNewItem.anchorLeft = true
        buttonNewItem.anchorRight = true
        buttonNewItem.anchorTop = false
        buttonNewItem.onclick = function()
            windowUI.modal1 = TDLZ_ISNewItemModalMask:new(windowUI.x, windowUI.y, windowUI.width, windowUI.height)
            windowUI.modal1:initialise();
            windowUI.modal1:addToUIManager();


            local modalHeight = 350;
            local modalWidth = 280;
            local mx = (windowUI.width - modalWidth) / 2
            local modal = TDLZ_ISNewItemModal:new(windowUI.x + mx, windowUI.y + windowUI.height - modalHeight - 50,
                modalWidth,
                modalHeight,
                windowUI, function()
                    windowUI.modal1:setVisible(false);
                    windowUI.modal1:removeFromUIManager();
                end)
            modal.backgroundColor.a = 0.9
            modal:initialise();
            modal:addToUIManager();
            --if JoypadState.players[getPlayer()+1] then
            --   setJoypadFocus(getPlayer(), modal)
            --end
        end
        windowUI:addFrameChild(buttonNewItem);

        local btnSelectAll = ISButton:new(buttonNewItem.x + buttonNewItem.width + TDLZ_REM * 0.25, y, buttonCheckWidth,
            TDLZ_BTN_DEFAULT_H, "Select all")
        --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
        btnSelectAll.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        btnSelectAll.anchorBottom = true
        btnSelectAll.anchorLeft = false
        btnSelectAll.anchorRight = true
        btnSelectAll.anchorTop = false
        btnSelectAll.onclick = function()
            for key, value in pairs(windowUI.listbox:getItems()) do
                if value.lineData.isCheckbox then
                    windowUI.listbox.highlighted:add(key)
                end
            end
            windowUI:refreshUIElements()
        end
        windowUI:addFrameChild(btnSelectAll);

        local buttonCheckOthers = ISButton:new(btnSelectAll.x + btnSelectAll.width, y, buttonCheckOtherWidth,
            TDLZ_BTN_DEFAULT_H,
            "")
        buttonCheckOthers:setImage(getTexture("media/ui/menu-dots-vertical.png"));
        buttonCheckOthers.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        buttonCheckOthers.anchorBottom = true
        buttonCheckOthers.anchorLeft = false
        buttonCheckOthers.anchorRight = true
        buttonCheckOthers.anchorTop = false
        windowUI:addFrameChild(buttonCheckOthers);
    end
end