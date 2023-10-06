require 'luautils'
require 'src.lua.client.Utils.TDLZ_Map'
require 'src.lua.client.Utils.TDLZ_StringUtils'
require 'src.lua.client.Utils.TDLZ_NotebooksUtils'
require 'UI/TDLZ_ISTodoListTZWindowHandler'
require 'ISUI/ISUIWriteJournal'

TDLZ_ISContextMenu = {}

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

local original_onDisplayRight = ISDPadWheels.onDisplayRight
---@diagnostic disable-next-line: duplicate-set-field
function ISDPadWheels.onDisplayRight(joypadData)
    original_onDisplayRight(joypadData)
    local playerIndex = joypadData.player
    local menu = getPlayerRadialMenu(playerIndex)
    menu:addSlice(getText("IGUI_WorldMap_Toggle"), getTexture('media/textures/TDLZ_ctx_icon.png'),
        TDLZ_ISContextMenu.onOpenTodoZ, -1, playerIndex)
end

---@param notebookID number
---@param playerNum number
---@param context ISContextMenu
function TDLZ_ISContextMenu.onOpenTodoZ(notebookID, playerNum, context)
    local instance = TDLZ_ISTodoListTZWindowHandler.getOrCreateInstance(playerNum, notebookID, 1)
    if instance ~= nil then
        instance:setVisible(true)
        if JoypadState.players[playerNum + 1] then
            --- Move focus to TDLZ_TodoListZWindow instance
            setJoypadFocus(playerNum, instance)
            if context then
                instance:setOnCloseCallback(context.parent, function(_ctx)
                    setJoypadFocus(playerNum, getPlayerInventory(playerNum))
                end)
            else
                instance:setOnCloseCallback(nil, nil)
            end
        end
    else
        error("TDLZ_TodoListZWindow instance is null")
    end
end

---@return table<number,any>
function TDLZ_ISContextMenu.getNotebooks(items)
    local notebooks = {}
    local item = nil
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
function TDLZ_ISContextMenu.handleShowTodoListContextMenu(player, context, items)
    local notebooks = TDLZ_ISContextMenu.getNotebooks(items);
    if type(notebooks) == 'table' and #notebooks > 0 then
        local notebookID = notebooks[1]:getID();
        local instance = TDLZ_ISTodoListTZWindowHandler.getInstance(notebookID)
        if instance ~= nil then
            if instance:getIsVisible() then
                -- TodoZ UI is open and visible, don't do anything.
                return
            end
        end
        if #items ~= 1 then return end
        local opt = context:addOption(getText('IGUI_TDLZ_context_open_onclick'), notebookID,
            TDLZ_ISContextMenu.onOpenTodoZ,
            player, context)
        opt.iconTexture = getTexture('media/textures/TDLZ_ctx_icon.png')
    end
end

---@param ctx any
---@param state string
function TDLZ_ISContextMenu.onRefreshInventoryWindowContainers(ctx, state)
    if state == "begin" then
        local ownedNotebooks = TDLZ_NotebooksUtils.getNotebooksInContainer()
        TDLZ_ISTodoListTZWindowHandler.closeExcept(ownedNotebooks)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(TDLZ_ISContextMenu.handleShowTodoListContextMenu)
Events.OnRefreshInventoryWindowContainers.Add(TDLZ_ISContextMenu.onRefreshInventoryWindowContainers)
