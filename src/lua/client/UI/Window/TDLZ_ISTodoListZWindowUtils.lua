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
    windowUI:addChild(buttonDelete);

    local buttonLock = ISButton:new(TDLZ_REM * 0.25 + buttonDelete.width + TDLZ_REM * 0.125, y, TDLZ_REM * 1.5,
        TDLZ_BTN_DEFAULT_H, "")
    buttonLock.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonLock.anchorBottom = false
    buttonLock.anchorLeft = true
    buttonLock.anchorRight = false
    buttonLock.anchorTop = true
    buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
    buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    windowUI:addChild(buttonLock);

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
    windowUI:addChild(windowUI.previousPage);

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
    windowUI:addChild(windowUI.nextPage);

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
    windowUI:addChild(windowUI.pageLabel);
end

function TDLZ_ISTodoListZWindowUtils._createTodoListToolbar(windowUI, y)
    local buttonCheckWidth = 100
    local buttonCheckOtherWidth = TDLZ_BTN_DEFAULT_H
    local buttonNewMarginLR = TDLZ_REM * 0.5
    local marginBetween = TDLZ_REM * 0.25
    local buttonNewItem = ISButton:new(buttonNewMarginLR, y,
        windowUI.width - marginBetween - buttonCheckWidth - buttonCheckOtherWidth - buttonNewMarginLR * 2,
        TDLZ_BTN_DEFAULT_H,
        "+ New...")
    buttonNewItem.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonNewItem.anchorBottom = true
    buttonNewItem.anchorLeft = true
    buttonNewItem.anchorRight = true
    buttonNewItem.anchorTop = false
    windowUI:addChild(buttonNewItem);

    local buttonCheck = ISButton:new(buttonNewItem.x + buttonNewItem.width + TDLZ_REM * 0.25, y, buttonCheckWidth,
        TDLZ_BTN_DEFAULT_H, "Review all")
    --buttonCheck:setImage(getTexture("media/ui/trashIcon.png"));
    buttonCheck.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonCheck.anchorBottom = true
    buttonCheck.anchorLeft = false
    buttonCheck.anchorRight = true
    buttonCheck.anchorTop = false
    windowUI:addChild(buttonCheck);

    local buttonCheckOthers = ISButton:new(buttonCheck.x + buttonCheck.width, y, buttonCheckOtherWidth,
        TDLZ_BTN_DEFAULT_H,
        ">")
    buttonCheckOthers.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonCheckOthers.anchorBottom = true
    buttonCheckOthers.anchorLeft = false
    buttonCheckOthers.anchorRight = true
    buttonCheckOthers.anchorTop = false
    windowUI:addChild(buttonCheckOthers);
end

function TDLZ_ISTodoListZWindowUtils._createTodoList(windowUI, x, y, width, height, previousState)
    windowUI.listbox = TDLZ_ISList:new(x, y, width, height, windowUI, previousState);
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
