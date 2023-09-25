---@class TDLZ_TodoListZWindowController
TDLZ_TodoListZWindowController = {}

---@param winCtx TDLZ_TodoListZWindow
---@param highlightedRowNumber number
function TDLZ_TodoListZWindowController.onRowIsChecked(winCtx, highlightedRowNumber)
    print("Checkrow")
    local listRows = winCtx.listbox:getItems()
    winCtx.listbox.highlighted:remove(highlightedRowNumber)
    local highlightedRow = listRows[highlightedRowNumber]
    local hashList = TDLZ_StringUtils.findAllHashTagName(highlightedRow.lineString)
    for k, hashname in pairs(hashList) do
        -- Checking row hashname
        -- ---------------------
        -- Remove #
        local cleanedHashname = string.sub(hashname.text, 2)
        local itemFound = TDLZ_OwnedItemService.findByName(cleanedHashname)
        if itemFound:size() > 0 then
            highlightedRow.isChecked = true
        else
            highlightedRow.isChecked = false
            break
        end
    end

    local getItems = winCtx.listbox:getItems()
    TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, getItems)
    winCtx:refreshUIElements()
end

---On execute button click
---@param winCtx TDLZ_TodoListZWindow Window Context
function TDLZ_TodoListZWindowController.onExecuteClick(winCtx)
    local hlist = winCtx.listbox.highlighted:toList()
    table.sort(hlist, function(a, b)
        return a < b
    end)
    local listRows = winCtx.listbox:getItems()

    local player = getPlayer()
    for rowNumber, highlightedRowNumber in pairs(hlist) do
        if winCtx.executeMode == 1 then
            local action = TDLZ_CheckEquipmentAction:new(player, highlightedRowNumber, 20, winCtx)
            action:setOnComplete(TDLZ_TodoListZWindowController.onRowIsChecked, winCtx, highlightedRowNumber)
            action:setOnStopAction(TDLZ_TodoListZWindowController.onStopAction, winCtx, highlightedRowNumber)
            local s = ISTimedActionQueue.add(action)
        elseif winCtx.executeMode == 3 then
            local row = highlightedRowNumber
            local item = winCtx.listbox:getItem(row)
            if item.isCheckbox then
                item.isChecked = false
            end
        elseif winCtx.executeMode == 2 then
            local row = highlightedRowNumber
            local item = winCtx.listbox:getItem(row)
            if item.isCheckbox then
                item.isChecked = true
            end
        end
    end

    TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, listRows)
    winCtx:refreshUIElements();
end

---@param winCtx TDLZ_TodoListZWindow
---@param button any
function TDLZ_TodoListZWindowController.onClick(winCtx, button)
    if button.internal == "NEXTPAGE" then
        winCtx.model.notebook.currentPage = winCtx.model.notebook.currentPage + 1
        winCtx.listbox.highlighted = TDLZ_NumSet:new();
    elseif button.internal == "PREVIOUSPAGE" then
        winCtx.model.notebook.currentPage = winCtx.model.notebook.currentPage - 1
        winCtx.listbox.highlighted = TDLZ_NumSet:new();
    elseif button.internal == "DELETEPAGE" then
        TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, {})
        winCtx:refreshUIElements()
    elseif button.internal == "LOCKBOOK" then
        local player = getPlayer()
        winCtx.model.notebook.currentNotebook:setLockedBy(player:getUsername());
    elseif button.internal == "UNLOCKBOOK" then
        winCtx.model.notebook.currentNotebook:setLockedBy(nil)
    end
    winCtx:refreshUIElements()
end

local run = 0
--- Toggle item state
---@param winCtx TDLZ_TodoListZWindow Window Context
---@param itemData TDLZ_BookLineModel Ticked item data
function TDLZ_TodoListZWindowController.onOptionTicked(winCtx, itemData)
    run = run + 1
    itemData.isChecked = not itemData.isChecked
    local allItemsInListbox = winCtx.listbox:getItems()
    TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, allItemsInListbox)
    -- Refresh the UI (and the list accordingly)
    winCtx:refreshUIElements();
end

---@param winCtx TDLZ_TodoListZWindow Window Context
---@param itemData TDLZ_BookLineModel Ticked item data
function TDLZ_TodoListZWindowController.onEraseItem(winCtx, itemData)
    run = run + 1
    itemData.lineString = ""
    itemData.isCheckbox = false
    local allItemsInListbox = winCtx.listbox:getItems()
    TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, allItemsInListbox)
    -- Refresh the UI (and the list accordingly)
    winCtx:refreshUIElements();
end

---@param winCtx TDLZ_TodoListZWindow
function TDLZ_TodoListZWindowController.onModalClose(winCtx)
    winCtx.modal1:setVisible(false);
    winCtx.modal1:removeFromUIManager();
end

---@param winCtx TDLZ_TodoListZWindow
---@param listItem TDLZ_BookLineModel
function TDLZ_TodoListZWindowController.onEditItem(winCtx, listItem)
    winCtx.modal1 = TDLZ_ISNewItemModalMask:new(winCtx.x, winCtx.y, winCtx.width, winCtx.height)
    winCtx.modal1:initialise();
    winCtx.modal1:addToUIManager();


    local modalHeight = 350;
    local modalWidth = 280;
    local mx = (winCtx.width - modalWidth) / 2

    local editItemModal = TDLZ_ISNewItemModal:new(winCtx.x + mx, winCtx.y + winCtx.height - modalHeight - 50,
        modalWidth,
        modalHeight,
        winCtx,
        listItem,
        TDLZ_TodoListZWindowController.onModalClose)
    editItemModal.backgroundColor.a = 0.9
    editItemModal:instantiate()
    TDLZ_ISNewItemModal.initialise(editItemModal)
    editItemModal:addToUIManager()
end

---Save data into Notebook. Please note this does not refresh the UI but reload the model
---@param winCtx TDLZ_TodoListZWindow
---@param bookLines table<number, TDLZ_BookLineModel>
function TDLZ_TodoListZWindowController.saveAllJournalData(winCtx, bookLines)
    if (bookLines == nil) then
        print("Warning - bookLines == nil")
        return ""
    end
    local toWrite = ""
    local insertedLines = 0
    for ln, itemData in pairs(bookLines) do
        local textLine = itemData.lineString

        local sep = "\n"
        if insertedLines == 0 then
            sep = "";
        end

        if itemData.isCheckbox then
            if itemData.isChecked then
                -- add x
                textLine = textLine:gsub(CK_BOX_CHECKED_R_PATTERN, function(space)
                    return space .. "[x]"
                end, 1)
            else
                -- remove
                textLine = textLine:gsub(CK_BOX_CHECKED_PATTERN, function(space)
                    return space .. "[_]"
                end, 1)
            end
            insertedLines = insertedLines + 1
            toWrite = toWrite .. sep .. textLine
        elseif textLine ~= "" then
            insertedLines = insertedLines + 1
            toWrite = toWrite .. sep .. textLine
        end
    end
    winCtx.model.notebook.currentNotebook:addPage(winCtx.model.notebook.currentPage, toWrite)
    TDLZ_TodoListZWindow.reloadModel(winCtx, winCtx.model.notebook.notebookID, winCtx.model.notebook.currentPage)
    return toWrite;
end

---@param winCtx TDLZ_TodoListZWindow
function TDLZ_TodoListZWindowController.onStopAction(winCtx, row)
    local listRows = winCtx.listbox:getItems()
    listRows[row].jobDelta = 0
end

---@return table<number,any>
function TDLZ_TodoListZWindowController.getHashnames(currentNotebook)
    local text = ""
    for i = 1, currentNotebook:getCustomPages():size(), 1 do
        if currentNotebook:seePage(i) ~= nil then
            text = text .. currentNotebook:seePage(i) .. " "
        end
    end
    local pageHashnames = TDLZ_StringUtils.findAllHashTagName(text)
    pageHashnames = TDLZ_StringUtils.removeAllHash(pageHashnames)
    local items = getAllItems()
    local rtnItems = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i);
        if not item:getObsolete() and not item:isHidden() then
            for key, value in pairs(pageHashnames) do
                if value == item:getName() then
                    table.insert(rtnItems, item)
                    break
                end
            end
        end
    end
    return rtnItems
end

---@param winCtx TDLZ_TodoListZWindow
---@param item any
function TDLZ_TodoListZWindowController.onSelectItem(winCtx,combobox)
    print("TDLZ_TodoListZWindowController.onSelectItem")
    local item = combobox:getOptionData(combobox.selected)
    winCtx:setExecuteMode(item.id)
    winCtx:refreshUIElements()
end