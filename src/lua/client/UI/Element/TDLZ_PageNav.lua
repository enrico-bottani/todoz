--- @class TDLZ_PageNav:ISPanel
--- @field buttonDelete ISButton
--- @field buttonLock ISButton
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
function TDLZ_PageNav.createPageNav(winCtx, currentPage, numberOfPages, windowUI, onBtnClick)
    winCtx.frameChildren = {}
    winCtx.borderColor = { r = 0, g = 0, b = 0, a = 1 }
    winCtx.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }

    local y = TDLZ_BTN_MV
    local x = TDLZ_REM * 0.25
    local height = winCtx.height - TDLZ_BTN_MV * 2
    local width = TDLZ_REM * 1.5
    if winCtx.buttonDelete == nil then
        winCtx.buttonDelete = ISButton:new(x, y, width, height, "", windowUI, onBtnClick)
        winCtx.buttonDelete.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        winCtx.buttonDelete:setImage(getTexture("media/ui/trashIcon.png"));
        winCtx.buttonDelete:setTooltip(getText("Tooltip_Journal_Erase"));
        winCtx.buttonDelete.anchorBottom = false
        winCtx.buttonDelete.anchorLeft = true
        winCtx.buttonDelete.anchorRight = false
        winCtx.buttonDelete.anchorTop = true
        winCtx.buttonDelete.internal = "DELETEPAGE"
        winCtx:addChild(winCtx.buttonDelete)
    end


    local x = winCtx.buttonDelete.x + winCtx.buttonDelete.width + TDLZ_REM * 0.125
    if winCtx.buttonLock == nil then
        winCtx.buttonLock = ISButton:new(x, y, width, height, "", windowUI, onBtnClick)
        winCtx.buttonLock.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        winCtx.buttonLock.anchorBottom = false
        winCtx.buttonLock.anchorLeft = true
        winCtx.buttonLock.anchorRight = false
        winCtx.buttonLock.anchorTop = true
        winCtx.buttonLock.internal = "LOCKBOOK"
        winCtx.buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
        winCtx.buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
        winCtx.buttonLock.textureColor = { g = 0.7, r = 0, b = 0, a = 1 }
        if windowUI.model.notebook.currentNotebook:getLockedBy() then
            winCtx.buttonLock.internal = "UNLOCKBOOK"
            winCtx.buttonLock.textureColor = { r = 0.7, g = 0, b = 0, a = 1 }
            winCtx.buttonLock:setImage(getTexture("media/ui/lock.png"));
            winCtx.buttonLock:setTooltip(getText("Tooltip_Journal_UnLock"));
        end
        winCtx:addChild(winCtx.buttonLock)
    end


    --  winCtx.lockButton:setImage(getTexture("media/ui/lock.png"));
    --  winCtx.lockButton:setImage(getTexture("media/ui/lockOpen.png"));

    if winCtx.previousPage == nil then
        winCtx.previousPage = ISButton:new(winCtx.buttonLock.x + winCtx.buttonLock.width + 0.5 * TDLZ_REM, y,
            TDLZ_BTN_DEFAULT_H,
            TDLZ_BTN_DEFAULT_H, "<",
            windowUI, onBtnClick);
        winCtx.previousPage.internal = "PREVIOUSPAGE";
        winCtx.previousPage.anchorLeft = true
        winCtx.previousPage.anchorRight = false
        --windowUI.winCtx.previousPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
        -- windowUI.winCtx.previousPage.borderColor = BTN_ERROR_BORDER_COLOR;
        winCtx.previousPage:initialise();
        winCtx.previousPage:instantiate();
        if currentPage == 1 then
            winCtx.previousPage:setEnable(false);
        else
            winCtx.previousPage:setEnable(true);
        end
        winCtx:addChild(winCtx.previousPage)
    end
    local nextPage = ISButton:new(winCtx.previousPage.x + winCtx.previousPage.width + 0.125 * TDLZ_REM, y,
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
    winCtx:addFrameChild(nextPage);

    local pageLabel = ISLabel:new(nextPage.x + nextPage.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, getText(
            "IGUI_Pages") .. currentPage .. "/" .. numberOfPages, 1, 1, 1, 1,
        UIFont.Small, true);
    pageLabel.anchorRight = false
    pageLabel.anchorLeft = true
    pageLabel:initialise();
    pageLabel:instantiate();
    winCtx:addFrameChild(pageLabel);
end
