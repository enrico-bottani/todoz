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
    local lines = {}
    local pattern = "(.-)\r?\n"
    
    for line in inputString:gmatch(pattern) do
        table.insert(lines, line)
    end
    
    -- Handle the last line if it doesn't end with a line break
    local lastLine = inputString:match(pattern .. "$")
    if lastLine then
        table.insert(lines, lastLine)
    end
    
    return lines
end