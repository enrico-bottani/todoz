require 'luautils'
require 'Utils/TDLZ_Map'
require 'Utils/TDLZ_StringUtils'
require 'Utils/TDLZ_NotebooksUtils'
require 'UI/TDLZ_ISTodoListTZWindowHandler'
require 'ISUI/ISUIWriteJournal'

TDLZ_ContextMenu = {}

-- ****************************************************************
-- ***************   VANILLA FUNCTIONS OVERRIDE       *************
-- ****************************************************************

local original_ISUIOnClick = ISUIWriteJournal.onClick;
-- @original_ISUIOnClick override
---@diagnostic disable-next-line: duplicate-set-field
function ISUIWriteJournal:onClick(button, player, p2)
    original_ISUIOnClick(self, button)

    if button.internal == "OK" then
        -- update todolist
        local notebookID = button.parent.notebook:getID();
        -- Recover instance and update notebook id
        if TDLZ_ISTodoListTZWindowHandler.isOpen(notebookID) then
            local instance = TDLZ_ISTodoListTZWindowHandler.getInstance(notebookID)
            -- instance==nil should never happend after isOpen() check
            if instance == nil then
                error("get instance returned nil")
                return
            end
            instance:setNotebookID(notebookID, instance.model.notebook.currentPage)
            return
        end
    end
end

---@param items table
---@param player any
function TDLZ_ContextMenu.onOpenTodoZ(items, player)
    local instance = TDLZ_ISTodoListTZWindowHandler.getOrCreateInstance(items[1]:getID(), 1)
    if instance ~= nil then
        instance:setVisible(true)
    end
    if JoypadState.players[player+1] then
        setJoypadFocus(player, instance)
    end
end

---@return table<number,any>
function TDLZ_ContextMenu.getNotebooks(items)
    local notebooks = {}
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
            table.insert(notebooks, item)
        end
    end
    return notebooks;
end

---@param player any
---@param context ISContextMenu
---@param items table
function TDLZ_ContextMenu.handleShowTodoListContextMenu(player, context, items)
    local notebooks = TDLZ_ContextMenu.getNotebooks(items);

    if type(notebooks) == 'table' and #notebooks > 0 then
        local notebookID = notebooks[1]:getID();
        local instance = TDLZ_ISTodoListTZWindowHandler.getInstance(notebookID)
        if instance ~= nil then
            if instance:getIsVisible() then
                -- TodoZ UI is open and visible, don't do anything.
                return
            end
        end
        local opt = context:addOption(getText('IGUI_TDLZ_context_open_onclick'), notebooks, TDLZ_ContextMenu.onOpenTodoZ,
            player)
        opt.iconTexture = getTexture('media/textures/TDLZ_ctx_icon.png')
    end
end

---@param ctx any
---@param state string
function TDLZ_ContextMenu.onRefreshInventoryWindowContainers(ctx, state)
    if state == "begin" then
        local ownedNotebooks = TDLZ_NotebooksUtils.getNotebooksInContainer()
        TDLZ_ISTodoListTZWindowHandler.closeExcept(ownedNotebooks)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(TDLZ_ContextMenu.handleShowTodoListContextMenu)
Events.OnRefreshInventoryWindowContainers.Add(TDLZ_ContextMenu.onRefreshInventoryWindowContainers)
