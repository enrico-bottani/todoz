require 'Utils/TDLZ_Map'
require 'UI/TDLZ_ISTodoListZWindow'

TDLZ_ISTodoListTZWindowHandler = {}
-- ************************************************************************--
-- ** TodoListZManagerUI - toggle handler
-- ************************************************************************--
TDLZ_ISTodoListTZWindowHandler.instance = nil;
local function _removeFromController()
    TDLZ_ISTodoListTZWindowHandler.instance = null;
end
local function _newWindow()
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        TDLZ_ISTodoListTZWindowHandler.instance = TDLZ_ISTodoListZWindow:new();
        TDLZ_ISTodoListTZWindowHandler.instance.onClose = _removeFromController
    end
end
TDLZ_ISTodoListTZWindowHandler.toggle = function()
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        _newWindow();
    else
        print("TodoListZManagerWindow - window exists - close");
        TDLZ_ISTodoListTZWindowHandler.close()
        TDLZ_ISTodoListTZWindowHandler.instance = nil;
    end
end
TDLZ_ISTodoListTZWindowHandler.create = function()
    print("Creating new TodoListZManagerWindow")
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        _newWindow();
    end
end
TDLZ_ISTodoListTZWindowHandler.close = function()
    print("Closing TDLZ_ISTodoListTZWindowHandler")
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        return
    end

    TDLZ_ISTodoListTZWindowHandler.instance:close();
    TDLZ_ISTodoListTZWindowHandler.instance = nil;
end
TDLZ_ISTodoListTZWindowHandler.getNotebookID = function()
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        return -1
    end
    return TDLZ_ISTodoListTZWindowHandler.instance.notebookID;
end
function TDLZ_ISTodoListTZWindowHandler.setVisible()
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        print("TDLZ_ISTodoListTZWindowHandler.setVisible - Error: instance is nil")
        return
    end
    TDLZ_ISTodoListTZWindowHandler.instance:setVisible(true);
    TDLZ_ISTodoListTZWindowHandler.instance:saveModData();
    print("TDLZ_ISTodoListTZWindowHandler.setVisible - UI hidden: " .. tostring(not TDLZ_ISTodoListTZWindowHandler.instance:getIsVisible()))
end
TDLZ_ISTodoListTZWindowHandler.setNotebookID = function(id)
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        _newWindow();
    end
    TDLZ_ISTodoListTZWindowHandler.instance:setNotebookID(id)
end
TDLZ_ISTodoListTZWindowHandler.refreshContent = function()
    if TDLZ_ISTodoListTZWindowHandler.instance == nil then
        _newWindow();
    end
    TDLZ_ISTodoListTZWindowHandler.instance:setNotebookID(TDLZ_ISTodoListTZWindowHandler.instance.notebookID)
end
