require 'luautils'
require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_NotebooksUtils'
require 'UI/TDLZ_ISTodoListTZWindowHandler'
require 'ISUI/ISUIWriteJournal'

TDLZ_Menu = {}

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

TDLZ_Menu.onOpenTodoZ = function(items, player, itemMode)
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
        local isNote = fullType == 'Base.Notebook'
        if isNote then
            table.insert(itemsUsedInRecipes, item)
        end
    end
    return itemsUsedInRecipes;
end

TDLZ_Menu.handleShowTodoListContenxtMenu = function(player, context, items)
    local notebooks = getNotebooks(items);

    if type(notebooks) == 'table' and #notebooks > 0 then
        local notebookID = notebooks[1]:getID();
        if TDLZ_ISTodoListTZWindowHandler.instance ~= nil and TDLZ_ISTodoListTZWindowHandler.getNotebookID() ==
            notebookID then
            if TDLZ_ISTodoListTZWindowHandler.instance:getIsVisible() then
                -- TodoZ UI is open and visible, don't do anything.
                return
            end
        end
        local opt = context:addOption(getText('IGUI_TDLZ_context_open_onclick'), notebooks, TDLZ_Menu.onOpenTodoZ,
            player)
        opt.iconTexture = getTexture('media/textures/TDLZ_ctx_icon.png')
    end

end

TDLZ_Menu.onRefreshInventoryWindowContainers = function(inventorySelfInstance, state)
    if state == "begin" then
        local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
        if not TDLZ_Map.containsKey(notebookMap, TDLZ_ISTodoListTZWindowHandler.getNotebookID()) then
            TDLZ_ISTodoListTZWindowHandler.close();
        end
    end
end
-- These are the default options.
local SETTINGS = {
    options = {
        box1 = true
    },
    names = {
        box1 = "Use colors"
    },
    mod_id = "TDLZ",
    mod_shortname = "Todo List"
}

-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
    ModOptions:getInstance(SETTINGS)
end

-- Check actual options at game loading.
Events.OnGameStart.Add(function()
    print("checkbox1 = ", SETTINGS.options.box1)
end)
Events.OnFillInventoryObjectContextMenu.Add(TDLZ_Menu.handleShowTodoListContenxtMenu)
Events.OnRefreshInventoryWindowContainers.Add(TDLZ_Menu.onRefreshInventoryWindowContainers)
