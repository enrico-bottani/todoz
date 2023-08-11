TDLZ_ISTickboxBuilderDefaultDispatcher = {}
TDLZ_ISTickboxBuilderDefaultDispatcher.Type = "TDLZ_ISTickboxBuilderDefaultDispatcher";
function TDLZ_ISTickboxBuilderDefaultDispatcher:onTicked(index, selected, tickBox)
    -- Dispatch onTicked
    local optionData = tickBox:getOptionData(index);
    optionData.onTicked(optionData.onTickedSelf, selected, optionData.bookInfo)
end