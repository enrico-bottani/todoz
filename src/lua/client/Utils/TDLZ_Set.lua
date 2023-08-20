TDLZ_Set = {}
TDLZ_Set.Type = "TDLZ_Set";

--- Check if set is empty
-- @return false if contains at least one element, false otherwise
function TDLZ_Set.isEmpty(tbl)
    for k, v in pairs(tbl) do
        return false
    end
    return true
end

function TDLZ_Set:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o._table = {}
    o._min = nil
    o._max = nil
    o._empty = true
    return o
end

function TDLZ_Set:derive(type)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.Type = type;
    o._table = {}
    o._min = nil
    o._max = nil
    o._empty = true
    return o
end

function TDLZ_Set:add(element)
    self._table[element] = true
    local sortedKeys = self:_getSortedKeys();
    self:_updateMin(sortedKeys)
    self:_updateMax(sortedKeys)
    self._empty = TDLZ_Set.isEmpty(self._table)
end
function TDLZ_Set:remove(element)
    self._table[element] = nil
    local sortedKeys = self:_getSortedKeys();
    self:_updateMin(sortedKeys)
    self:_updateMax(sortedKeys)
    self._empty = TDLZ_Set.isEmpty(self._table)
end
function TDLZ_Set:_getSortedKeys()
    if TDLZ_Set.isEmpty(self._table) then
        return nil
    end
    local a = {}
    for k, v in pairs(self._table) do
        table.insert(a, k)
    end
    table.sort(a)
    return a;
end

function TDLZ_Set:contains(key)
    return self._table[key] ~= nil
end

function TDLZ_Set:_updateMax(sortedKeys)
    if sortedKeys == nil then
        self._max = nil
        return
    end
    self._max = sortedKeys[1 + #sortedKeys - 1]
end

function TDLZ_Set:_updateMin(sortedKeys)
    if sortedKeys == nil then
        self._min = nil
        return
    end
    self._min = sortedKeys[1]
end
