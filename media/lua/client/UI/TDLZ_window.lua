require 'Utils/TDLZ_Map'
require 'UI/TDLZ_ISTodoListZWindow'

TDLZ_UI = {}
-- ************************************************************************--
-- ** TodoListZManagerUI - toggle handler
-- ************************************************************************--
TDLZ_UI.instance = nil;
local function _removeFromController()
    TDLZ_UI.instance = null;
end
local function _newWindow()
    if TDLZ_UI.instance == nil then
        TDLZ_UI.instance = TDLZ_ISTodoListZWindow:new();
        TDLZ_UI.instance.onClose = _removeFromController
    end
end
TDLZ_UI.toggle = function()
    if TDLZ_UI.instance == nil then
        _newWindow();
    else
        print("TodoListZManagerWindow - window exists - close");
        TDLZ_UI.close()
        TDLZ_UI.instance = nil;
    end
end
TDLZ_UI.create = function()
    print("Creating new TodoListZManagerWindow")
    if TDLZ_UI.instance == nil then
        _newWindow();
    end
end
TDLZ_UI.close = function()
    print("Closing TDLZ_UI")
    if TDLZ_UI.instance == nil then
        return
    end

    TDLZ_UI.instance:close();
    TDLZ_UI.instance = nil;
end
TDLZ_UI.getNotebookID = function()
    if TDLZ_UI.instance == nil then
        return -1
    end
    print("GET ID: " .. TDLZ_UI.instance.notebookID)
    return TDLZ_UI.instance.notebookID;
end
function TDLZ_UI.setVisible()
    if TDLZ_UI.instance == nil then
        print("TDLZ_UI.setVisible - Error: instance is nil")
        return
    end
    TDLZ_UI.instance:setVisible(true);
    TDLZ_UI.instance:saveModData();
    print("TDLZ_UI.setVisible - UI hidden: " .. tostring(not TDLZ_UI.instance:getIsVisible()))
end
TDLZ_UI.setNotebookID = function(id)
    if TDLZ_UI.instance == nil then
        _newWindow();
    end
    TDLZ_UI.instance:setNotebookID(id)
end
TDLZ_UI.refreshContent = function()
    if TDLZ_UI.instance == nil then
        _newWindow();
    end
    TDLZ_UI.instance:setNotebookID(TDLZ_UI.instance.notebookID)
end
