require 'luautils'
require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_NotebooksUtils'
require 'UI/TDLZ_ISTodoListTZWindowHandler'
require 'ISUI/ISUIWriteJournal'

TDLZ_menu = {}

-- ****************************************************************
-- ***************   VANILLA FUNCTIONS OVERRIDE       *************
-- ****************************************************************

local original_ISUIOnClick = ISUIWriteJournal.onClick;
function ISUIWriteJournal:onClick(button)
    original_ISUIOnClick(self, button)

    if button.internal == "OK" then
        print("OK clicked")
        -- update todolist
        local editedNotebook = button.parent.notebook;
        local notebookTitleNew = button.parent.title:getText();
        local notebookID = editedNotebook:getID();
        local openedTodoUIID = TDLZ_ISTodoListTZWindowHandler.getNotebookID();
        if openedTodoUIID == notebookID then
            print("Refreshing Todo UI")
            TDLZ_ISTodoListTZWindowHandler.refreshContent();
            return
        end
        print("Notebook not assigned as Todo. Nothing to refresh")
    end
end

TDLZ_menu.onOpenTodoZ = function(items, player, itemMode)
    local customPagesHashMap = items[1]:getCustomPages() -- userdata
    local b = transformIntoKahluaTable(customPagesHashMap)
    local levels = ""
    for perk, level in pairs(b) do
        levels = levels .. level
    end
    local splitted = TDLZ_StringUtils.split(levels, "\n")
    
    TDLZ_ISTodoListTZWindowHandler.setNotebookID(items[1]:getID())
    TDLZ_ISTodoListTZWindowHandler.setVisible()
    
    print("onOpenTodoZ() -> Open UI")
end

function getNotebooks(items)
    local itemsUsedInRecipes = {}
    local item
    -- Go through the items selected (because multiple selections in inventory is possible)
    for i = 1, #items do
        if not instanceof(items[i], 'InventoryItem') then
            item = items[i].items[1]
        else
            item = items[i]
        end
        -- if item is used in any recipe OR there is a way to create this item - mark item as valid
        local fullType = item:getFullType()
        -- print(fullType)
        local isNote = fullType == 'Base.Notebook'
        -- print("isNote : " .. tostring(isNote))
        if isNote then
            table.insert(itemsUsedInRecipes, item)
        end
    end
    return itemsUsedInRecipes;
end

TDLZ_menu.handleShowTodoListContenxtMenu = function(player, context, items)
    local notebooks = getNotebooks(items);

    if type(notebooks) == 'table' and #notebooks > 0 then
        local notebookID = notebooks[1]:getID();
        if TDLZ_ISTodoListTZWindowHandler.instance ~= nil and TDLZ_ISTodoListTZWindowHandler.getNotebookID() == notebookID then
            -- TodoZ UI is open, don't do anything
            return
        end
        local opt = context:addOption(getText('IGUI_TDLZ_context_open_onclick'), notebooks, TDLZ_menu.onOpenTodoZ,
            player)
        opt.iconTexture = getTexture('media/textures/TDLZ_ctx_icon.png')
    end

end

TDLZ_menu.OnRefreshInventoryWindowContainers = function(inventorySelfInstance, state)
    if state == "begin" then
        local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
        if not TDLZ_Map.containsKey(notebookMap, TDLZ_ISTodoListTZWindowHandler.getNotebookID()) then
            TDLZ_ISTodoListTZWindowHandler.close();
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(TDLZ_menu.handleShowTodoListContenxtMenu)
Events.OnRefreshInventoryWindowContainers.Add(TDLZ_menu.OnRefreshInventoryWindowContainers)
Events.OnCreateUI.Add(TDLZ_ISTodoListTZWindowHandler.create)
