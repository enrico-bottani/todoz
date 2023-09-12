require 'Utils/TDLZ_Map'
require 'UI/Window/TDLZ_TodoListZWindow'

---@class TDLZ_ISTodoListTZWindowHandler
---@field instance TDLZ_TodoListZWindow
TDLZ_ISTodoListTZWindowHandler = {}
-- ************************************************************************--
-- ** TodoListZManagerUI - toggle handler
-- ************************************************************************--

---@private
---@return TDLZ_TodoListZWindow
function TDLZ_ISTodoListTZWindowHandler._createWindow()
    return TDLZ_TodoListZWindow:new()
end

---@return TDLZ_TodoListZWindow|nil
function TDLZ_ISTodoListTZWindowHandler.create()
    if TDLZ_TodoListZWindow.UI_MAP:size() == 0 then
        return TDLZ_ISTodoListTZWindowHandler._createWindow()
    end
    return nil
end

---Close **all** todo list windows
function TDLZ_ISTodoListTZWindowHandler.close()
    for key, window in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        window:close()
    end
end

---@param ownedNotebooks TDLZ_Map
function TDLZ_ISTodoListTZWindowHandler.closeExcept(ownedNotebooks)
    for key, window in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if not ownedNotebooks:containsKey(window:getBookID()) then
            window:close()
        end
    end
end

TDLZ_ISTodoListTZWindowHandler.getNotebookID = function()
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        return -1
    end
    return TDLZ_ISTodoListTZWindowHandler.instance.model.notebook.notebookID;
end

---@param notebookID number
TDLZ_ISTodoListTZWindowHandler.isOpen = function(notebookID)
    for key, value in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if value:getBookID() == notebookID then
            return true
        end
    end
    return false
end

---@param notebookID number
---@return TDLZ_TodoListZWindow|nil
function TDLZ_ISTodoListTZWindowHandler.getInstance(notebookID)
    for key, value in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if value:getBookID() == notebookID then
            return value
        end
    end
    return nil
end

---@param notebookID number
---@return TDLZ_TodoListZWindow
function TDLZ_ISTodoListTZWindowHandler.getOrCreateInstance(notebookID)
    for key, window in pairs(TDLZ_TodoListZWindow.UI_MAP:toList()) do
        if window:getBookID() == notebookID then
            return window
        end
    end
    local newWindow = TDLZ_ISTodoListTZWindowHandler._createWindow()
    newWindow:setNotebookID(notebookID)
    return newWindow
end

Events.OnCreateUI.Add(TDLZ_ISTodoListTZWindowHandler.create)
