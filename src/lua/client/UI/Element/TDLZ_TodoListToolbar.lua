TDLZ_TodoListToolbar = {}

local TDLZ_BTN_DEFAULT_BORDER_COLOR = { r = 0.5, g = 0.5, b = 0.5, a = 1 }

---@private
---@param windowUI TDLZ_TodoListZWindow
---@param y number
function TDLZ_TodoListToolbar.refreshTodoListToolbar(windowUI)
    if windowUI.listbox.highlighted:size() > 0 then
        print("hsize: " .. windowUI.listbox.highlighted:size())
        windowUI.buttonNewItem:setVisible(false)
        windowUI.btnSelectAll:setVisible(false)
        
        -- Highlight controls
        windowUI.buttonBack:setVisible(true)
        windowUI.buttonSelectOpt:setVisible(true)
        windowUI.btnExecute:setVisible(true)
        windowUI.taskLabel:setVisible(true)
        
    else
        print("hsize: " .. windowUI.listbox.highlighted:size())
        windowUI.buttonNewItem:setVisible(true)
        windowUI.btnSelectAll:setVisible(true)
        
        -- Highlight controls
        windowUI.buttonBack:setVisible(false)
        windowUI.buttonSelectOpt:setVisible(false)
        windowUI.btnExecute:setVisible(false)
        windowUI.taskLabel:setVisible(false)
    end
end
