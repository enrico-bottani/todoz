--- @class TDLZ_Map
--- @field _size number
--- @field _table table
TDLZ_Map = {}

function TDLZ_Map:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o._table = {}
    o._size = 0
    return o
end

function TDLZ_Map:add(key, value)
    if not self:containsKey(key) then self._size = self._size + 1 end
    self._table[key] = value
end

function TDLZ_Map:remove(key)
    if self:containsKey(key) then self._size = self._size - 1 end
    self._table[key] = nil
end

function TDLZ_Map:containsKey(key)
    return self._table[key] ~= nil
end

function TDLZ_Map:get(key)
    if self:containsKey(key) then
        return self._table[key];
    end
    return nil;
end

function TDLZ_Map:size()
    return self._size
end
