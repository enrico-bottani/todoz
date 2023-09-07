TDLZ_TodoListZWindowController = {}

---@param winCtx TDLZ_ISTodoListZWindow Window Context
function TDLZ_TodoListZWindowController.onExecuteClick(winCtx)
    local highlightedList = winCtx.listbox.highlighted:toList()
    table.sort(highlightedList, function(a, b)
        return a < b
    end)

    for key, value in pairs(highlightedList) do
        local item = winCtx.listbox:getItem(value)
        print(item.lineNumber .. ". " .. item.lineString)
    end
end

function TDLZ_TodoListZWindowController.onClick(winCtx, button)
    if button.internal == "NEXTPAGE" then
        winCtx.notebook.currentPage = winCtx.notebook.currentPage + 1;
    elseif button.internal == "PREVIOUSPAGE" then
        winCtx.notebook.currentPage = winCtx.notebook.currentPage - 1;
    elseif button.internal == "DELETEPAGE" then
        winCtx.entry:setText("");
        winCtx.entry.javaObject:setCursorLine(0);
    elseif button.internal == "LOCKBOOK" then
        winCtx.lockButton:setImage(getTexture("media/ui/lock.png"));
        winCtx.lockButton.internal = "UNLOCKBOOK";
        winCtx.notebook:setLockedBy(winCtx.character:getUsername());
        winCtx.title:setEditable(false);
        winCtx.entry:setEditable(false);
        winCtx.lockButton:setTooltip("Allow the journal to be edited");
        winCtx:setJoypadButtons(winCtx.joyfocus)
    elseif button.internal == "UNLOCKBOOK" then
        winCtx.lockButton:setImage(getTexture("media/ui/lockOpen.png"));
        winCtx.lockButton.internal = "LOCKBOOK";
        winCtx.notebook:setLockedBy(nil);
        winCtx.title:setEditable(true);
        winCtx.entry:setEditable(true);
        winCtx.lockButton:setTooltip("Prevent the journal from being edited");
        winCtx:setJoypadButtons(winCtx.joyfocus)
    end

    winCtx:refreshUIElements()
end

---@param winCtx TDLZ_ISTodoListZWindow Window Context
---@param itemData TDLZ_ISListItemDataModel Ticked item data
function TDLZ_TodoListZWindowController.onOptionTicked(winCtx, itemData)
    -- In this function, an "x" is removed or inserted between the square brackets of the ticked element
    local toWrite = ""
    for ln, s in pairs(itemData.lines) do
        local sep = "\n"
        if ln == 1 then
            sep = "";
        end
        if ln == itemData.lineNumber then
            if not itemData.isChecked then
                -- add x
                s = s:gsub(CK_BOX_CHECKED_R_PATTERN, function(space)
                    return space .. "[x]"
                end, 1)
            else
                -- remove
                s = s:gsub(CK_BOX_CHECKED_PATTERN, function(space)
                    return space .. "[_]"
                end, 1)
            end
            toWrite = toWrite .. sep .. s
        else
            toWrite = toWrite .. sep .. s
        end
    end
    -- Save modified text
    itemData.notebook:addPage(itemData.pageNumber, toWrite);
    -- Refresh the UI (and the list accordingly)
    winCtx:refreshUIElements();
end
