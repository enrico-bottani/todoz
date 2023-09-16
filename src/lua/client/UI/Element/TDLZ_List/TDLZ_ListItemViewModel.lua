--- @class TDLZ_ListItemViewModel
--- @field text string
--- @field lineData TDLZ_BookLineModel
TDLZ_ListItemViewModel = {}
function TDLZ_ListItemViewModel:new(label, data, tooltip, itemindex, height)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.text = label
    o.lineData = data
    o.tooltip = tooltip
    o.itemindex = itemindex
    o.height = height
    return o
end