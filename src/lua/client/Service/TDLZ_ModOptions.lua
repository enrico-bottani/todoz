-- These are the default options.
local SETTINGS = {
    options = {
        box1 = true
    },
    names = {
        box1 = "Use colors"
    },
    mod_id = "TDLZ",
    mod_shortname = "Todo List"
}

-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
    ModOptions:getInstance(SETTINGS)
end

-- Check actual options at game loading.
Events.OnGameStart.Add(function()
    print("checkbox1 = ", SETTINGS.options.box1)
end)