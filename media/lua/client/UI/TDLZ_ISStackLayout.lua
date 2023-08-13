require "ISUI/ISPanel"

TDLZ_ISStackLayout = ISPanel:derive("ISTickBox");

function TDLZ_ISStackLayout:addItem(name, item)
    local i = {}
    i.text=name;
    i.item=item;
	i.tooltip = nil;
    i.itemindex = self.count + 1;
	i.height = self.itemheight
    table.insert(self.items, i);
    self.count = self.count + 1;
    self:setScrollHeight(self:getScrollHeight()+i.height);
    return i;
end