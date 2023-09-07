--- @class TDLZ_ISListItemViewModel
--- @field text string
--- @field lineData TDLZ_ISListItemDataModel
TDLZ_ISListItemViewModel = {}
function TDLZ_ISListItemViewModel:new(label, data, tooltip, itemindex, height)
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
