TDLZ_Set = {}
function TDLZ_Set.add(set, key)
    set[key] = true
end

function TDLZ_Set.remove(set, key)
    set[key] = nil
end

function TDLZ_Set.contains(set, key)
    return set[key] ~= nil
end