TDLZ_StringUtils = {}

-- ****************************************
-- *************     UTILS    *************
-- ****************************************
function TDLZ_StringUtils.split(inputString, delimiter)
    local r = {}
    for token in string.gmatch(inputString, "([^" .. delimiter .. "]+)") do
        table.insert(r, token)
    end
    return r
end
function TDLZ_StringUtils.splitKeepingEmptyLines(inputString)
    local result = {};
    local lastChar = string.sub(inputString, -1);
    local added = false;
    if lastChar ~= "\n" then
        inputString = inputString .. "\n"
        added = true
    end
    for line in string.gmatch(inputString .. "\n", "(.-)\n") do
        table.insert(result, line);
    end
    if added then
        table.remove(result)
    end
    return result
end