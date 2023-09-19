require 'src.lua.client.Utils.TDLZ_Set'
--- @class TDLZ_NumSet:TDLZ_Set
TDLZ_NumSet = TDLZ_Set:derive("TDLZ_NumSet")
local notNumberMessage = "Element is not a number"

---@return TDLZ_NumSet
function TDLZ_NumSet:new()
    local o = TDLZ_Set:new()
    setmetatable(o, self)
    self.__index = self
    return o
end

---Add element to set
---@param number number to add 
function TDLZ_NumSet:add(number)
    if type(number) ~= "number" then
        error(notNumberMessage)
    end
    TDLZ_Set.add(self, number)
end
---Remove element from set
---@param number number to remove from set
function TDLZ_NumSet:remove(number)
    if type(number) ~= "number" then
        error(notNumberMessage)
    end
    TDLZ_Set.remove(self, number)
end

function TDLZ_NumSet:contains(element)
    if type(element) ~= "number" then
        error(notNumberMessage)
    end
    return TDLZ_Set.contains(self, element)
end
