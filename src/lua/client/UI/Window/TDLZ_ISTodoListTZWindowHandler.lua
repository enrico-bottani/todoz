require 'src.lua.client.Utils.TDLZ_Map'
require 'src.lua.client.UI.Window.TDLZ_TodoListZWindow.TDLZ_TodoListZWindow'

---@class TDLZ_ISTodoListTZWindowHandler
TDLZ_ISTodoListTZWindowHandler = {}

---Close **all** TodoList Windows
function TDLZ_ISTodoListTZWindowHandler.close()
    for key, window in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        window:close()
    end
end

---@param ownedNotebooks TDLZ_Map
function TDLZ_ISTodoListTZWindowHandler.closeExcept(ownedNotebooks)
    for key, window in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if not ownedNotebooks:containsKey(window:getNotebookID()) then
            window:close()
        end
    end
end

---@param notebookID number
TDLZ_ISTodoListTZWindowHandler.isOpen = function(notebookID)
    for key, value in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if value:getNotebookID() == notebookID then
            return true
        end
    end
    return false
end

---@param notebookID number
---@return TDLZ_TodoListZWindow|nil
function TDLZ_ISTodoListTZWindowHandler.getInstance(notebookID)
    for key, value in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if value:getNotebookID() == notebookID then
            return value
        end
    end
    return nil
end

---Get or create TodoList Window instance by notebookID
---@param player number
---@param notebookID number
---@param pageNumber number
---@return TDLZ_TodoListZWindow
function TDLZ_ISTodoListTZWindowHandler.getOrCreateInstance(player, notebookID, pageNumber)
    assert(notebookID, "notebookID not set")
    local instanceIDs = ""
    for key, window in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        instanceIDs = " " .. window:getNotebookID()
        if window:getNotebookID() == notebookID then
            window:setVisible(true)
            return window
        end
    end
    print("ID: " .. notebookID .. " not found between: " .. instanceIDs)
    local newWindow = TDLZ_TodoListZWindow:new(player, notebookID, pageNumber)


    newWindow:initialise()
    newWindow:addToUIManager()
    return newWindow
end