require 'luautils'
require 'Utils/TDLZ_Set'
TDLZ_menu = {}
require 'UI/TDLZ_Window'
require 'ISUI/ISUIWriteJournal'
local original_ISUIOnClick = ISUIWriteJournal.onClick;

function ISUIWriteJournal:onClick(button)
    original_ISUIOnClick(self, button)

    if button.internal == "OK" then
        print("OK clicked")
        -- update todolist
        local editedNotebook = button.parent.notebook;
        local notebookTitleNew = button.parent.title:getText();
        local notebookID = editedNotebook:getID();
        local openedTodoUIID = TDLZ_UI.getNotebookID();
        if openedTodoUIID == notebookID then
            print("Refreshing Todo UI")

            return
        end
        print("Notebook not assigned as Todo. Nothing to refresh")
    end
end
function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

TDLZ_menu.onCraftHelper = function(items, player, itemMode)

    -- print("n of items: " .. #items)
    -- print("category: " .. tostring(items[1]:getCategory()))
    -- print("name: " .. tostring(items[1]:getBookName()))
    -- print("pages: " .. items[1]:getPageToWrite())
    -- print("-------------------------------")
    -- local next = items[1]:getCustomPages();
    -- print("page: " .. items[1]:tostring())
    -- print("type: " .. type(items[1]))
    local customPagesHashMap = items[1]:getCustomPages() -- userdata
    -- print(customPagesHashMap:toString() .. " type: " .. type(customPagesHashMap))
    local b = transformIntoKahluaTable(customPagesHashMap)
    local levels = ""
    for perk, level in pairs(b) do
        levels = levels .. level
    end
    local splitted = mysplit(levels, "\n")
    -- print(type(splitted))
    --[[
    for lineNum, line in pairs(splitted) do
        -- print(line .. " (" .. type(line) .. ")")
        for w in string.gmatch(line, "^%[% %]") do
            print("found: " .. line)
            UI:nextLine()

            UI:addText("", tostring(line), _, "Left");
          
            UI:addTickBox("t1");
        end

    end
    
    UI:saveLayout()
    --]]
    TDLZ_UI.setNotebookID(items[1]:getID())
    -- TDLZ_UI.toggle();
    print("onCraftHelper() -> Open UI")
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

TDLZ_menu.doCraftHelperMenu = function(player, context, items)
    local notebooks = getNotebooks(items);

    if type(notebooks) == 'table' and #notebooks > 0 then
        local notebookID = notebooks[1]:getID();
        if TDLZ_UI.instance ~= nil and TDLZ_UI.getNotebookID() == notebookID then
            -- local opt = context:addOption(getText('IGUI_TDLZ_context_open_onclick'), notebooks, TDLZ_menu.onCraftHelper,
            --  player)
            --  opt.iconTexture = getTexture('media/textures/TDLZ_ctx_icon.png')
            return
        end
        -- ELSE
        local opt = context:addOption(getText('IGUI_TDLZ_context_open_onclick'), notebooks, TDLZ_menu.onCraftHelper,
            player)
        opt.iconTexture = getTexture('media/textures/TDLZ_ctx_icon.png')
    end

end

TDLZ_menu.OnBeginRefresh = function(invSelf, playerInv)

    TDLZ_UI.close()
end
TDLZ_menu.OnRefreshInventoryWindowContainers = function(invSelf, state)
    local playerObj = getSpecificPlayer(invSelf.player)
    if invSelf.onCharacter and state == "begin" then
        --print("INV REFRESH: ".. state .. " ".. invSelf.title)
        local it = playerObj:getInventory():getItems()
        local notebooksIDS = {}
        for i = 0, it:size() - 1 do
            local item = it:get(i)
            if item:getCategory() == "Literature" then
                print("We got literature: " .. item:getID())
                TDLZ_Set.add(notebooksIDS, item:getID())
            end
        end
        print("INV REFRESH END")
    end

end

Events.OnFillInventoryObjectContextMenu.Add(TDLZ_menu.doCraftHelperMenu)
Events.OnRefreshInventoryWindowContainers.Add(TDLZ_menu.OnRefreshInventoryWindowContainers)
Events.OnCreateUI.Add(TDLZ_menu.OnCreateUI)
