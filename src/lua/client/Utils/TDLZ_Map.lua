TDLZ_Map = {}
function TDLZ_Map.add(set, key, value)
    set[key] = value
end

function TDLZ_Map.remove(set, key)
    set[key] = nil
end

function TDLZ_Map.containsKey(set, key)
    return set[key] ~= nil
end
function TDLZ_Map.get(set, key)
    if TDLZ_Map.containsKey(set, key) then
        return set[key];
    end
    return nil;
end
