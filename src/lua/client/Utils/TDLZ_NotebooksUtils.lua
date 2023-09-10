require 'Utils/TDLZ_Map'
TDLZ_NotebooksUtils = {}

---commented
---@return TDLZ_Map
TDLZ_NotebooksUtils.getNotebooksInContainer = function()
    local playerObj = getPlayer();
    -- local playerObj = getSpecificPlayer(player)

    local notebooksIDS = TDLZ_Map:new()
    local container = playerObj:getInventory()
    TDLZ_NotebooksUtils.recGetNotebooksInContainer(notebooksIDS, container:getItems())
    return notebooksIDS;
end

---commented
---@param notebookIDS TDLZ_Map
---@param it any
TDLZ_NotebooksUtils.recGetNotebooksInContainer = function(notebookIDS, it)
    if it == nil then
        return;
    end
    for i = 0, it:size() - 1 do
        local item = it:get(i)
        if item:getCategory() == "Literature" then
            notebookIDS:add(item:getID(), item)
        else
            if item:getCategory() == "Container" then
                TDLZ_NotebooksUtils.recGetNotebooksInContainer(notebookIDS, item:getInventory():getItems())
            end
        end
    end
end
