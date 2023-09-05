TDLZ_ItemsFinderService = {}
function TDLZ_ItemsFinderService.filterName(filterTxt, scriptItem)
    local txtToCheck = string.lower(scriptItem:getDisplayName())
    txtToCheck = txtToCheck:gsub('[%p%c%s%-]', '')
    local filterTxt = string.lower(filterTxt)
    filterTxt = filterTxt:gsub('[%p%c%s%-]', '')
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end

function TDLZ_ItemsFinderService.hasIcon(item)
    local icon = item:getIcon()
    if item:getIconsForTexture() and not item:getIconsForTexture():isEmpty() then
        icon = item:getIconsForTexture():get(0)
    end
    if icon then
        return true
    end
    return false
end
