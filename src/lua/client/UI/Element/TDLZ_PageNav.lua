--- @class TDLZ_PageNav
TDLZ_PageNav = ISPanel:derive("TDLZ_PageNav");

local TDLZ_BTN_DEFAULT_BORDER_COLOR = { r = 0.5, g = 0.5, b = 0.5, a = 1 }

---@private
---Add a child inside the Window frame
---@param child any UI Element
function TDLZ_PageNav:addFrameChild(child)
    self:addChild(child)
    table.insert(self.frameChildren, child)
end

---@param currentPage number
---@param numberOfPages number
---@param windowUI TDLZ_TodoListZWindow
function TDLZ_PageNav:createPageNav(currentPage, numberOfPages, windowUI, onBtnClick)
    self.frameChildren = {}
    self.borderColor = { r = 0, g = 0, b = 0, a = 1 }
    self.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }

    local y = TDLZ_BTN_MV
    local x = TDLZ_REM * 0.25
    local height = self.height - TDLZ_BTN_MV * 2
    local width = TDLZ_REM * 1.5

    local buttonDelete = ISButton:new(x, y, width, height, "")
    buttonDelete.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonDelete:setImage(getTexture("media/ui/trashIcon.png"));
    buttonDelete:setTooltip(getText("Tooltip_Journal_Erase"));
    buttonDelete.anchorBottom = false
    buttonDelete.anchorLeft = true
    buttonDelete.anchorRight = false
    buttonDelete.anchorTop = true
    self:addFrameChild(buttonDelete);

    local x = buttonDelete.x + buttonDelete.width + TDLZ_REM * 0.125
    local buttonLock = ISButton:new(x, y, width, height, "")
    buttonLock.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    buttonLock.anchorBottom = false
    buttonLock.anchorLeft = true
    buttonLock.anchorRight = false
    buttonLock.anchorTop = true
    buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
    buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    self:addFrameChild(buttonLock);

    local previousPage = ISButton:new(buttonLock.x + buttonLock.width + 0.5 * TDLZ_REM, y, TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, "<",
        windowUI, onBtnClick);
    previousPage.internal = "PREVIOUSPAGE";
    previousPage.anchorLeft = true
    previousPage.anchorRight = false
    --windowUI.previousPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.previousPage.borderColor = BTN_ERROR_BORDER_COLOR;
    previousPage:initialise();
    previousPage:instantiate();
    if currentPage == 1 then
        previousPage:setEnable(false);
    else
        previousPage:setEnable(true);
    end
    self:addFrameChild(previousPage);

    local nextPage = ISButton:new(previousPage.x + previousPage.width + 0.125 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, ">", windowUI, onBtnClick);
    nextPage.internal = "NEXTPAGE";
    nextPage.anchorLeft = true
    nextPage.anchorRight = false
    -- windowUI.nextPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.nextPage.borderColor = BTN_ERROR_BORDER_COLOR;
    nextPage:initialise();
    nextPage:instantiate();
    if currentPage == numberOfPages then
        nextPage:setEnable(false);
    else
        nextPage:setEnable(true);
    end
    self:addFrameChild(nextPage);

    local pageLabel = ISLabel:new(nextPage.x + nextPage.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, getText(
            "IGUI_Pages") .. currentPage .. "/" .. numberOfPages, 1, 1, 1, 1,
        UIFont.Small, true);
    pageLabel.anchorRight = false
    pageLabel.anchorLeft = true
    pageLabel:initialise();
    pageLabel:instantiate();
    self:addFrameChild(pageLabel);
end
