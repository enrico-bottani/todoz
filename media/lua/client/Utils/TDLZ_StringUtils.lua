TDLZ_StringUtils = {}

-- ****************************************
-- *************     UTILS    *************
-- ****************************************
function TDLZ_StringUtils.split(inputString, delimiter)
    local r = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    for token in string.gmatch(inputString, pattern) do
        table.insert(r, token)
    end
    return r
end