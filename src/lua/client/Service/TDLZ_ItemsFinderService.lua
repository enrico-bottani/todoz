TDLZ_ItemsFinderService = {}
function TDLZ_ItemsFinderService.filterName(filterTxt, scriptItem)
    local txtToCheck = string.lower(scriptItem:getDisplayName())
    txtToCheck = txtToCheck:gsub('[%p%c%s%-]', '')
    local filterTxt = string.lower(filterTxt)
    filterTxt = filterTxt:gsub('[%p%c%s%-]', '')
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end

function TDLZ_ItemsFinderService.filterName2(filterTxt)
    local items = getAllItems()
    local allItems = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i);
        if not item:getObsolete() and not item:isHidden() then
            table.insert(allItems, item)
        end
    end
    filterTxt = string.lower(filterTxt:gsub('[%p%c%s%-]', ''))
    for key, value in pairs(allItems) do
        local txtToCheck = string.lower(value:getName())
        txtToCheck = txtToCheck:gsub('[%p%c%s%-]', '')
        if (checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)) then
            return value
        end
    end
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
