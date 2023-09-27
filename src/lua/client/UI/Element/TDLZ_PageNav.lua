--- @class TDLZ_PageNav:ISPanelJoypad
--- @field buttonDelete ISButton
--- @field buttonLock ISButton
--- @field previousPage ISButton
--- @field nextPage ISButton
--- @field pageLabel ISLabel
--- @field currentPage number
--- @field numberOfPages number
TDLZ_PageNav = ISPanelJoypad:derive("TDLZ_PageNav");

local TDLZ_BTN_DEFAULT_BORDER_COLOR = { r = 0.5, g = 0.5, b = 0.5, a = 1 }

---@private
---Add a child inside the Window frame
---@param child any UI Element
function TDLZ_PageNav:addFrameChild(child)
    self:addChild(child)
    table.insert(self.frameChildren, child)
end

function TDLZ_PageNav:_update(currentPage, numberOfPages, isLocked)
    if currentPage == self.currentPage and numberOfPages == self.numberOfPages and isLocked == self.isLocked then
        return
    end
    self.isLocked = isLocked
    self.currentPage = currentPage
    self.numberOfPages = numberOfPages
    self.pageLabel:setName(getText("IGUI_Pages") .. currentPage .. "/" .. numberOfPages)

    if self.currentPage == 1 then
        self.previousPage:setEnable(false)
    else
        self.previousPage:setEnable(true);
    end

    if self.currentPage == self.numberOfPages then
        self.nextPage:setEnable(false);
    else
        self.nextPage:setEnable(true);
    end

    if self.isLocked then
        self.buttonLock.internal = "UNLOCKBOOK"
        self.buttonLock.textureColor = { r = 0.7, g = 0, b = 0, a = 1 }
        self.buttonLock:setImage(getTexture("media/ui/lock.png"));
        self.buttonLock:setTooltip(getText("Tooltip_Journal_UnLock"));
    else
        self.buttonLock.internal = "LOCKBOOK"
        self.buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
        self.buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    end
end

function TDLZ_PageNav:new(x, y, width, height)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.currentPage = 1
    o.numberOfPages = 1
    return o
end

---@param currentPage number
---@param numberOfPages number
---@param windowUI TDLZ_TodoListZWindow
function TDLZ_PageNav.createPageNav(pNavCtx, currentPage, numberOfPages, windowUI, onBtnClick)
    pNavCtx.frameChildren = {}
    pNavCtx.borderColor = { r = 0, g = 0, b = 0, a = 1 }
    pNavCtx.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }

    local y = TDLZ_BTN_MV
    local x = TDLZ_REM * 0.25
    local height = pNavCtx.height - TDLZ_BTN_MV * 2
    local width = TDLZ_REM * 1.5
    if pNavCtx.buttonDelete == nil then
        pNavCtx.buttonDelete = ISButton:new(x, y, width, height, "", windowUI, onBtnClick)
        pNavCtx.buttonDelete.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
        pNavCtx.buttonDelete:setImage(getTexture("media/ui/trashIcon.png"));
        pNavCtx.buttonDelete:setTooltip(getText("Tooltip_Journal_Erase"));
        pNavCtx.buttonDelete.anchorBottom = false
        pNavCtx.buttonDelete.anchorLeft = true
        pNavCtx.buttonDelete.anchorRight = false
        pNavCtx.buttonDelete.anchorTop = true
        pNavCtx.buttonDelete.internal = "DELETEPAGE"
        pNavCtx:addChild(pNavCtx.buttonDelete)
    end


    local x = pNavCtx.buttonDelete.x + pNavCtx.buttonDelete.width + TDLZ_REM * 0.125

    pNavCtx.buttonLock = ISButton:new(x, y, width, height, "", windowUI, onBtnClick)
    pNavCtx.buttonLock.borderColor = TDLZ_BTN_DEFAULT_BORDER_COLOR;
    pNavCtx.buttonLock.anchorBottom = false
    pNavCtx.buttonLock.anchorLeft = true
    pNavCtx.buttonLock.anchorRight = false
    pNavCtx.buttonLock.anchorTop = true

    pNavCtx.buttonLock.textureColor = { g = 0.7, r = 0, b = 0, a = 1 }
    if windowUI.model.notebook.currentNotebook:getLockedBy() then
        pNavCtx.buttonLock.internal = "UNLOCKBOOK"
        pNavCtx.buttonLock:setImage(getTexture("media/ui/lock.png"));
        pNavCtx.buttonLock:setTooltip(getText("Tooltip_Journal_UnLock"));
    else
        pNavCtx.buttonLock.internal = "LOCKBOOK"
        pNavCtx.buttonLock:setImage(getTexture("media/ui/lockOpen.png"));
        pNavCtx.buttonLock:setTooltip(getText("Tooltip_Journal_Lock"));
    end
    pNavCtx:addChild(pNavCtx.buttonLock)



    --  winCtx.lockButton:setImage(getTexture("media/ui/lock.png"));
    --  winCtx.lockButton:setImage(getTexture("media/ui/lockOpen.png"));


    pNavCtx.previousPage = ISButton:new(pNavCtx.buttonLock.x + pNavCtx.buttonLock.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, "<",
        windowUI, onBtnClick);
    pNavCtx.previousPage.internal = "PREVIOUSPAGE";
    pNavCtx.previousPage.anchorLeft = true
    pNavCtx.previousPage.anchorRight = false
    --windowUI.winCtx.previousPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.winCtx.previousPage.borderColor = BTN_ERROR_BORDER_COLOR;
    pNavCtx.previousPage:initialise();
    pNavCtx.previousPage:instantiate();
    if currentPage == 1 then
        pNavCtx.previousPage:setEnable(false);
    else
        pNavCtx.previousPage:setEnable(true);
    end
    pNavCtx:addChild(pNavCtx.previousPage)

    pNavCtx.nextPage = ISButton:new(pNavCtx.previousPage.x + pNavCtx.previousPage.width + 0.125 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H,
        TDLZ_BTN_DEFAULT_H, ">", windowUI, onBtnClick);
    pNavCtx.nextPage.internal = "NEXTPAGE";
    pNavCtx.nextPage.anchorLeft = true
    pNavCtx.nextPage.anchorRight = false
    -- windowUI.pNavCtx.nextPage.borderColorEnabled = BTN_DEFAULT_BORDER_COLOR;
    -- windowUI.pNavCtx.nextPage.borderColor = BTN_ERROR_BORDER_COLOR;
    pNavCtx.nextPage:initialise();
    pNavCtx.nextPage:instantiate();
    if currentPage == numberOfPages then
        pNavCtx.nextPage:setEnable(false);
    else
        pNavCtx.nextPage:setEnable(true);
    end
    pNavCtx:addChild(pNavCtx.nextPage);

    pNavCtx.pageLabel = ISLabel:new(pNavCtx.nextPage.x + pNavCtx.nextPage.width + 0.5 * TDLZ_REM, y,
        TDLZ_BTN_DEFAULT_H, getText(
            "IGUI_Pages") .. currentPage .. "/" .. numberOfPages, 1, 1, 1, 1,
        UIFont.Small, true);
    pNavCtx.pageLabel.anchorRight = false
    pNavCtx.pageLabel.anchorLeft = true
    pNavCtx.pageLabel:initialise();
    pNavCtx.pageLabel:instantiate();
    pNavCtx:addChild(pNavCtx.pageLabel);
end
