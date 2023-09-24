---@class TDLZ_GenericContextMenuItem
---@field index number
---@field icon string
---@field label string
TDLZ_GenericContextMenuItem = {}

---@generic T:any
---@param model T
---@return TDLZ_GenericContextMenuItem
function TDLZ_GenericContextMenuItem:new(index, label, icon, tooltip, model)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.index = index
    o.icon = icon
    o.label = label
    o.model = model
    o.tooltip = tooltip
    return o
end
