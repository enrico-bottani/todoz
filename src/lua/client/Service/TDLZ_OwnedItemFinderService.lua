require 'Utils/TDLZ_Map'
TDLZ_OwnedItemFinderService = {}
---Find items by name (not display name)
---@param name string Name of the item to find
---@return table map containing all items found, key is item id, value is the item obj
function TDLZ_OwnedItemFinderService.findByName(name)
    local playerObj = getPlayer();
    -- local playerObj = getSpecificPlayer(player)

    local notebooksIDS = {}
    local container = playerObj:getInventory()
    TDLZ_OwnedItemFinderService.recFindItemByName(notebooksIDS, container:getItems(), name)
    return notebooksIDS;
end
TDLZ_OwnedItemFinderService.recFindItemByName = function(itemMap, it, name)
    if it == nil then
        return;
    end
    for i = 0, it:size() - 1 do
        local item = it:get(i)
        if item:getName() == name then
            TDLZ_Map.add(itemMap, item:getID(), item)
        else
            if item:getCategory() == "Container" then
                TDLZ_OwnedItemFinderService.recFindItemByName(itemMap, item:getInventory():getItems())
            end
        end
    end
end
