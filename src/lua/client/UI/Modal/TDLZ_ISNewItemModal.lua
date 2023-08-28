TDLZ_ISNewItemModal = ISPanelJoypad:derive("TDLZ_ISNewItemModal");
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

TDLZ_ISNewItemModal.CHECKBOX_OPTION = 1
TDLZ_ISNewItemModal.OPTION_TXT = 2
function TDLZ_ISNewItemModal:initialise()
    ISPanelJoypad.initialise(self);

    local fontHgt = FONT_HGT_SMALL
    local lWidth = getTextManager():MeasureStringX(UIFont.Medium, "Add new row")
    local label = ISLabel:new((self:getWidth() - lWidth) / 2, FONT_HGT_SMALL, FONT_HGT_MEDIUM, "Add new row", 1, 1, 1, 1,
        UIFont.Medium, true)
    label:initialise()
    self:addChild(label)

    self.fontHgt = FONT_HGT_SMALL
    local inset = 2
    local numOfLines = 1
    local height = inset + self.fontHgt * numOfLines + inset
    local lineTypeWidth = 100
    self.textbox = ISTextEntryBox:new("", FONT_HGT_SMALL * 0.75,
        label.y + label.height + FONT_HGT_SMALL * 0.5,
        self:getWidth() - lineTypeWidth - (FONT_HGT_SMALL * 0.75) * 2,
        height);
    self.textbox.font = UIFont.Small
    self.textbox:initialise();
    self.textbox:instantiate();

    self.textbox.onTextChange = function(ctx)
        local filteredItems = {};
        local itemToFind = ctx.parent.textbox:getInternalText();
        if string.len(itemToFind)<3 then
            return
        end
        
        for index, item in pairs(self.viewModel.allItems) do
            if TDLZ_ItemsFinderService.filterName(itemToFind, item) then
                table.insert(filteredItems, item)
            end
        end
        print("-------------")
        for index, item in pairs(filteredItems) do
            print("i: " .. item:getName() .. " | " .. item:getDisplayName())
        end
    end

    --  self.entry:setMaxLines(self.maxLines)
    -- self.entry:setMultipleLine(self.multipleLine)
    self:addChild(self.textbox);


    self.lineType = ISComboBox:new(self.textbox.x + self.textbox.width,
        self.textbox.y,
        lineTypeWidth,
        height, self, self.onLineTypeChange)
    self.lineType:initialise()
    self.lineType:addOption("Checkbox")
    self.lineType:addOption("Text")
    self:addChild(self.lineType)

    self.ckboxOptions = ISTickBox:new(self.textbox.x, self.textbox.y + self.textbox.height, 10, 20, "", nil, nil);
    self.ckboxOptions:initialise();
    self.ckboxOptions:instantiate();
    self.ckboxOptions:setAnchorLeft(true);
    self.ckboxOptions:setAnchorRight(false);
    self.ckboxOptions:setAnchorTop(true);
    self.ckboxOptions:setAnchorBottom(false);
    self.ckboxOptions.autoWidth = true
    self:addChild(self.ckboxOptions);
    self.ckboxOptions:addOption("Is an item");
    self.ckboxOptions:addOption("Reset daily");

    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Ok") + 12
    local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Cancel") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)
    local padBottom = 10

    self.yes = ISButton:new((self:getWidth() / 2) - 5 - buttonWid,
        self.ckboxOptions.y + self.ckboxOptions.height + FONT_HGT_SMALL * 0.75, buttonWid,
        buttonHgt, "Add", self, TDLZ_ISNewItemModal.onClick);
    self.yes.internal = "OK";
    self.yes:initialise();
    self.yes:instantiate();
    self.yes.borderColor = { r = 1, g = 1, b = 1, a = 0.5 };
    self:addChild(self.yes);

    self.no = ISButton:new((self:getWidth() / 2) + 5,
        self.ckboxOptions.y + self.ckboxOptions.height + FONT_HGT_SMALL * 0.75, buttonWid, buttonHgt,
        getText("UI_Cancel"), self, TDLZ_ISNewItemModal.onClick);
    self.no.internal = "CLOSE";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = { r = 1, g = 1, b = 1, a = 0.5 };
    self:addChild(self.no);
    self:setHeight(self.no.y + self.no.height + FONT_HGT_SMALL * 0.75)
end

function TDLZ_ISNewItemModal:onLineTypeChange(button)
    if button.selected == nil then
        self.viewModel.lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION
    else
        self.viewModel.lineType = button.selected
    end
    if self.viewModel.lineType == TDLZ_ISNewItemModal.CHECKBOX_OPTION then
        self.ckboxOptions:setVisible(true)
    else
        self.ckboxOptions:setVisible(false)
    end
end

function TDLZ_ISNewItemModal:onClick(button)
    if button.internal == "CLOSE" then
        self:destroy();
        return
    elseif button.internal == "OK" then
        local options = { type = TDLZ_ISNewItemModal.OPTION_TXT }
        if self.viewModel.lineType == TDLZ_ISNewItemModal.CHECKBOX_OPTION then
            options = {
                type = TDLZ_ISNewItemModal.CHECKBOX_OPTION,
                isAnItem = self.ckboxOptions:isSelected(1),
                resetDaily = self.ckboxOptions:isSelected(2),
            }
        end

        TDLZ_NotebooksService.appendLineToNotebook(
            self.windowSelf.notebookID,
            self.windowSelf.notebook.currentPage,
            self.textbox:getText(),
            options
        )
        self.windowSelf:refreshUIElements()
        self:destroy();
        return
    end
end

function TDLZ_ISNewItemModal:destroy()
    UIManager.setShowPausedMessage(true);
    self:setVisible(false);
    self:removeFromUIManager();
    if self.onClose and self.windowSelf then
        self.onClose(self.windowSelf)
    end
    --	if UIManager.getSpeedControls() then
    --		UIManager.getSpeedControls():SetCurrentGameSpeed(1);
    --	end
end

function TDLZ_ISNewItemModal:setHeight(h)
    local deltaH = self.height - h
    self.height = h;

    if self.javaObject ~= nil then
        self.javaObject:setHeight(h);
        self.javaObject:setY(self.y + deltaH);
    end
end

--************************************************************************--
--** TDLZ_ISNewItemModal:new
--**
--************************************************************************--
function TDLZ_ISNewItemModal:new(x, y, width, height, windowSelf, onClose)
    local o = {}
    --o.data = {}
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x;
    o.y = y;
    o.background = true;
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
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
    o.windowSelf = windowSelf
    o.onClose = onClose

    local items = getAllItems()
    local allItems = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i);
        if not item:getObsolete() and not item:isHidden() then
            table.insert(allItems, item)
        end
    end

    o.viewModel = {
        lineType = TDLZ_ISNewItemModal.CHECKBOX_OPTION,
        allItems = allItems
    }
    return o
end
