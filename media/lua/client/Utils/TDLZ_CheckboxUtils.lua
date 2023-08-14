CK_BOX_CHECKED_PATTERN = "^(%s-)%[([Xx])%]"
CK_BOX_FLEX_PATTERN = "^(%s-)%[([ Xx_]-)%]"
TDLZ_CheckboxUtils = {}
function TDLZ_CheckboxUtils.containsCheckedCheckBox(text)
    local startIndex, endIndex = text:find(CK_BOX_CHECKED_PATTERN)
    if startIndex then
        return true
    else
        return false
    end
end
function TDLZ_CheckboxUtils.containsCheckBox(text)
    local startIndex, endIndex = text:find(CK_BOX_FLEX_PATTERN)
    if startIndex then
        return true
    else
        return false
    end
end