require "Utils/TDLZ_Set"
TDLZ_NumSet = TDLZ_Set:derive("TDLZ_NumSet")
local oAdd = TDLZ_Set.add;
local oRemove = TDLZ_Set.remove;
local oContains = TDLZ_Set.contains;
local notNumberMessage = "Element is not a number"
function TDLZ_NumSet:new()
    local o = TDLZ_Set:new()
    setmetatable(o, self)
    self.__index = self
    return o
end

function TDLZ_NumSet:add(element)
    if type(element) ~= "number" then
        error(notNumberMessage)
    end
    TDLZ_Set.add(self, element)
end

function TDLZ_NumSet:remove(element)
    if type(element) ~= "number" then
        error(notNumberMessage)
    end
    oRemove(self, element)
end
function TDLZ_NumSet:contains(element)
    if type(element) ~= "number" then
        error(notNumberMessage)
    end
    return oContains(self, element)
end
