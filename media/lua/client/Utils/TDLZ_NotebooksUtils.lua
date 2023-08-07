require 'Utils/TDLZ_Set'
TDLZ_NotebooksUtils = {}
TDLZ_NotebooksUtils.getNotebooksInContainer = function(inventorySelfInstance, state)
    local playerObj = getSpecificPlayer(inventorySelfInstance.player)
    if state == "begin" then
        print("INV REFRESH: " .. state)
        local notebooksIDS = {}
        local container = playerObj:getInventory()
        TDLZ_NotebooksUtils.recGetNotebooksInContainer(notebooksIDS, container:getItems())
        if not TDLZ_Set.contains(notebooksIDS, TDLZ_UI.getNotebookID()) then
            TDLZ_UI.close();
        end
    end
end
TDLZ_NotebooksUtils.recGetNotebooksInContainer = function(notebookIDS, it)
    if it == nil then
        return;
    end
    for i = 0, it:size() - 1 do
        local item = it:get(i)
        if item:getCategory() == "Literature" then
            TDLZ_Set.add(notebookIDS, item:getID())
        else
            if item:getCategory() == "Container" then
                TDLZ_NotebooksUtils.recGetNotebooksInContainer(notebookIDS, item:getInventory():getItems())
            end
        end
    end
end