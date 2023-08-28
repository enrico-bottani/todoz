TDLZ_ItemsFinderService = {}
function TDLZ_ItemsFinderService.filterName(filterTxt, scriptItem)
    local txtToCheck = string.lower(scriptItem:getDisplayName())
    local filterTxt = string.lower(filterTxt)
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end
