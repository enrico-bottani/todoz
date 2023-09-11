require 'Utils/TDLZ_Map'
TDLZ_OwnedItemService = {}
---Find items by name (not display name)
---@param name string Name of the item to find
---@return TDLZ_Map map containing all items found, key is item id, value is the item obj
function TDLZ_OwnedItemService.findByName(name)
    local playerObj = getPlayer();
    -- local playerObj = getSpecificPlayer(player)

    local notebooksIDS = TDLZ_Map:new()
    -- inventory: zombie.inventory.ItemContainer
    local inventory = playerObj:getInventory()
    TDLZ_OwnedItemService.recFindItemByName(notebooksIDS, inventory:getItems(), name)
    return notebooksIDS;
end

---comment
--- @private
---@param itemMap TDLZ_Map
---@param it any ArrayList<InventoryItem>
---@param name string
TDLZ_OwnedItemService.recFindItemByName = function(itemMap, it, name)
    if it == nil then
        return;
    end
    for i = 0, it:size() - 1 do
        local item = it:get(i)
        local scriptItem = item:getScriptItem()
        if scriptItem:getName() == name then
            itemMap:add(item:getID(), item)
        else
            if item:getCategory() == "Container" then
                TDLZ_OwnedItemService.recFindItemByName(itemMap, item:getInventory():getItems())
            end
        end
    end
end
