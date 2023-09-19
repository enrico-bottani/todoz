TDLZ_ISNewItemModalMask = ISPanel:derive("TDLZ_ISNewItemModal");
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function TDLZ_ISNewItemModalMask:new(x, y, width, height)
    local o = {}
    --o.data = {}
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = {r=0, g=0, b=0, a=0.7}
    o.borderColor = {r=0, g=0, b=0, a=0};

    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;

    o.x = x;
	o.y = y;
    o.width = width;
	o.height = height;
    return o
end

function TDLZ_ISNewItemModalMask:onFocus(x, y)
end
