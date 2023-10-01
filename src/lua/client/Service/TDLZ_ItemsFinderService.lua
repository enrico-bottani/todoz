require("src.lua.client.Utils.TDLZ_Map")
TDLZ_ItemsFinderService = {}
local items = getAllItems()
TDLZ_ItemsFinderService.ALL_NOT_OBSOLETE_ITEMS = TDLZ_Map:new()
for i = 0, items:size() - 1 do
    local item = items:get(i);
    if not item:getObsolete() and not item:isHidden() then
        TDLZ_ItemsFinderService.ALL_NOT_OBSOLETE_ITEMS:add(item:getName(), item)
    end
end

function TDLZ_ItemsFinderService.filterName(filterTxt, scriptItem)
    local txtToCheck = string.lower(scriptItem:getDisplayName())
    txtToCheck = txtToCheck:gsub('[%p%c%s%-]', '')
    local filterTxt = string.lower(filterTxt)
    filterTxt = filterTxt:gsub('[%p%c%s%-]', '')
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end

---@param filterTxt any
---@param allItems TDLZ_Map
---@return nil
function TDLZ_ItemsFinderService.filterName2(filterTxt, allItems)
    if allItems==nil then
        return nil
    end
    filterTxt = string.lower(filterTxt:gsub('[%p%c%s%-]', ''))
    for key, value in pairs(allItems:toList()) do
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
