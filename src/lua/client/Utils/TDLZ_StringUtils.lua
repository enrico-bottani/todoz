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
    if inputString == nil then
        return {}
    end
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

function TDLZ_StringUtils.endsWithChar(inputString, character)
    if inputString == nil or character == nil then
        return false
    end
    local lastChar = string.sub(inputString, -1);
    return character == lastChar
end

---@param inputString string
---@param position number
---@return table tag
function TDLZ_StringUtils.findHashTagName(inputString, position)
    if inputString == nil or #inputString == 0 then return { text = "", startIndex = 0, endIndex = 0 } end
    local startIndex = position
    while true do
        if startIndex == 0 then
            return { text = "", startIndex = -1, endIndex = -1 }
        end
        local c = inputString:sub(startIndex, startIndex)
        if c == " " then return { text = "", startIndex = -1, endIndex = -1 } end
        if c == "#" then break end
        startIndex = startIndex - 1
    end
    local endIndex = position
    while (endIndex ~= #inputString) do
        if endIndex == #inputString then break end
        endIndex = endIndex + 1
        local c = inputString:sub(endIndex, endIndex)
        if c == " " then
            endIndex = endIndex - 1
            break
        end
    end
    return { text = inputString:sub(startIndex, endIndex), startIndex = startIndex, endIndex = endIndex }
end

---@param inputString string
---@return table tag
function TDLZ_StringUtils.findAllHashTagName(inputString)
    local rtn = {}
    if inputString == nil or #inputString == 0 then
        return rtn
    end
    local cursor = 0
    local loopBreaker = 0
    while cursor < #inputString do
        local hashTagName = TDLZ_StringUtils.findHashTagName(inputString, cursor)
        if hashTagName.startIndex == -1 then
            cursor = cursor + 1
        else
            table.insert(rtn, hashTagName)
            cursor = hashTagName.endIndex + 1
        end
        loopBreaker = loopBreaker + 1
    end
    return rtn
end
