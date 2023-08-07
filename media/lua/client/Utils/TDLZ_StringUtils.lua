TDLZ_StringUtils = {}

-- ****************************************
-- *************     UTILS    *************
-- ****************************************
function TDLZ_StringUtils.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end