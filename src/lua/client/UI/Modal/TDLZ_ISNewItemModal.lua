TDLZ_ISNewItemModal = ISPanelJoypad:derive("TDLZ_ISNewItemModal");
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function TDLZ_ISNewItemModal:initialise()
    ISPanelJoypad.initialise(self);

	local fontHgt = FONT_HGT_SMALL
	local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12
	local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12
	local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
	local buttonHgt = math.max(fontHgt + 6, 25)
	local padBottom = 10
    
    self.yes = ISButton:new((self:getWidth() / 2)  - 5 - buttonWid, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Ok"), self, TDLZ_ISNewItemModal.onClick);
    self.yes.internal = "OK";
    self.yes:initialise();
    self.yes:instantiate();
    self.yes.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.yes);

    self.no = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Cancel"), self, TDLZ_ISNewItemModal.onClick);
    self.no.internal = "CLOSE";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.no);
end

function TDLZ_ISNewItemModal:onClick(button)
    if button.internal == "CLOSE" then
        self:destroy();
        return;
    end
end

function TDLZ_ISNewItemModal:destroy()
	UIManager.setShowPausedMessage(true);
	self:setVisible(false);
	self:removeFromUIManager();
    if self.onClose and self.onCloseS then
        self.onClose(self.onCloseS)
    end
--	if UIManager.getSpeedControls() then
--		UIManager.getSpeedControls():SetCurrentGameSpeed(1);
--	end
end

--************************************************************************--
--** TDLZ_ISNewItemModal:new
--**
--************************************************************************--
function TDLZ_ISNewItemModal:new (x, y, width, height, onCloseS, onClose)
	local o = {}
	--o.data = {}
	o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
	o.x = x;
	o.y = y;
	o.background = true;
	o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
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
    o.onCloseS = onCloseS
    o.onClose = onClose
   return o
end