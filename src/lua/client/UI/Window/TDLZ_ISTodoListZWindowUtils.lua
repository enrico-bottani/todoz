require "src.lua.client.UI.Element.TDLZ_ISList"
TDLZ_ISTodoListZWindowUtils = {}
function TDLZ_ISTodoListZWindowUtils._createPageNav(windowUI, titleBarHight)
    local y = titleBarHight + TDLZ_BTN_MV
    local buttonDelete = ISButton:new(TDLZ_REM * 0.25, y, TDLZ_REM * 1.5, TDLZ_BTN_DEFAULT_H, "")
    buttonDelete.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonDelete:setImage(getTexture("media/ui/trashIcon.png"));
    buttonDelete:setTooltip(getText("Tooltip_Journal_Erase"));
    buttonDelete.anchorBottom = false
    buttonDelete.anchorLeft = true
    buttonDelete.anchorRight = false
    buttonDelete.anchorTop = true
    windowUI:addFrameChild(buttonDelete);

    local buttonLock = ISButton:new(TDLZ_REM * 0.25 + buttonDelete.width + TDLZ_REM * 0.125, y, TDLZ_REM * 1.5,
        TDLZ_BTN_DEFAULT_H, "")
    buttonLock.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonLock.anchorBottom = false
    buttonLock.anchorLeft = true
    buttonLock.anchorRight = false
    buttonLock.anchorTop = true
    buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
    buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    windowUI:addFrameChild(buttonLock);

    windowUI.previousPage = ISButton:new(buttonLock.x + buttonLock.width + 0.5 * TDLZ_REM, y, TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, "<",
        windowUI, TDLZ_ISTodoListZWindow.onClick);
    windowUI.previousPage.internal = "PREVIOUSPAGE";
    windowUI.previousPage.anchorLeft = true
    windowUI.previousPage.anchorRight = false
    --windowUI.previousPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.previousPage.borderColor = BTN_ERROR_BORDER_COLOR;
    windowUI.previousPage:initialise();
    windowUI.previousPage:instantiate();
    if windowUI.notebook.currentPage == 1 then
        windowUI.previousPage:setEnable(false);
    else
        windowUI.previousPage:setEnable(true);
    end
    windowUI:addFrameChild(windowUI.previousPage);

    windowUI.nextPage = ISButton:new(windowUI.previousPage.x + windowUI.previousPage.width + 0.125 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, ">", windowUI, TDLZ_ISTodoListZWindow.onClick);
    windowUI.nextPage.internal = "NEXTPAGE";
    windowUI.nextPage.anchorLeft = true
    windowUI.nextPage.anchorRight = false
    -- windowUI.nextPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.nextPage.borderColor = BTN_ERROR_BORDER_COLOR;
    windowUI.nextPage:initialise();
    windowUI.nextPage:instantiate();
    if windowUI.notebook.currentPage == windowUI.notebook.numberOfPages then
        windowUI.nextPage:setEnable(false);
    else
        windowUI.nextPage:setEnable(true);
    end
    windowUI:addFrameChild(windowUI.nextPage);

    if windowUI.pageLabel ~= nil then
        windowUI:removeChild(windowUI.pageLabel)
    end
    windowUI.pageLabel = ISLabel:new(windowUI.nextPage.x + windowUI.nextPage.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, getText(
            "IGUI_Pages") .. windowUI.notebook.currentPage .. "/" .. windowUI.notebook.numberOfPages, 1, 1, 1, 1,
        UIFont.Small, true);
    windowUI.pageLabel.anchorRight = false
    windowUI.pageLabel.anchorLeft = true
    windowUI.pageLabel:initialise();
    windowUI.pageLabel:instantiate();
    windowUI:addFrameChild(windowUI.pageLabel);
end

function TDLZ_ISTodoListZWindowUtils._createTodoListToolbar(windowUI, y)
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
            TDLZ_BTN_DEFAULT_H, "")
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
                        print("k: ".. key)
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

function TDLZ_ISTodoListZWindowUtils.onHighlightChange(windowUI, int)
    if windowUI ~= nil then
        windowUI:refreshUIElements()
        return
    end
    error("Callback ok")
end

function TDLZ_ISTodoListZWindowUtils._createTodoList(windowUI, x, y, width, height, previousState)
    windowUI.listbox = TDLZ_ISList:new(x, y, width, height, windowUI, previousState, {
        o = windowUI,
        f = TDLZ_ISTodoListZWindowUtils.onHighlightChange
    });
    windowUI.listbox:setOnMouseClick(windowUI, TDLZ_ISTodoListZWindow.onOptionTicked);

    local page = windowUI.notebook.currentNotebook:seePage(windowUI.notebook.currentPage);
    local lines = TDLZ_StringUtils.splitKeepingEmptyLines(page)
    for lineNumber, lineString in ipairs(lines) do
        windowUI.listbox:addItem(lineString:gsub(CK_BOX_FLEX_PATTERN, function(space)
            return space
        end, 1), {
            isCheckbox = TDLZ_CheckboxUtils.containsCheckBox(lineString),
            isChecked = TDLZ_CheckboxUtils.containsCheckedCheckBox(lineString),
            pageNumber = windowUI.notebook.currentPage,
            lineNumber = lineNumber,
            lineString = lineString, -- test only (redundant)
            lines = lines,           -- test only (redundant)
            notebook = windowUI.notebook.currentNotebook
        });
    end

    if (previousState ~= nil) then
        windowUI.listbox:setYScroll(previousState.yScroll)
    end
    windowUI:addChild(windowUI.listbox);
end
