TDLZ_ModData = {
    defaultData = {
        isFirstRun = true,
        todoListData = {
            notebookID = -1
        },
        panelSettings = {
            x = 70,
            y = 400,
            width = 400,
            height = 300,
            pin = false,
            hidden = false
        }
    }
}


function TDLZ_ModData.loadModData()
    local player = getPlayer();
    if player then
        local modData = player:getModData()
        local reset = false;
        if modData.todoListZMod == nil or reset == true then
            modData.todoListZMod = TDLZ_ModData.defaultData
        end
        return modData.todoListZMod
    end
    print("ERROR: failed to load player and mod data.");
    return TDLZ_ModData.modData;
end

function TDLZ_ModData.saveModData(x, y, width, height, pin, hidden, notebookID)
    local player = getPlayer();
    local modData = player:getModData()
    modData.todoListZMod.isFirstRun = false;
    modData.todoListZMod.panelSettings = {
        x = x,
        y = y,
        width = width,
        height = height,
        pin = pin,
        hidden = hidden
    };
    modData.todoListZMod.todoListData = {
        notebookID = notebookID
    };
    player:transmitModData();
end
