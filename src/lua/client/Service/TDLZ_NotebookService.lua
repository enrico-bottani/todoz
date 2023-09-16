TDLZ_NotebooksService = {}
function TDLZ_NotebooksService.saveTextToNotebookPage(notebookID, page, text)
    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local notebook = notebookMap:get(notebookID)
    if notebook ~= nil then 
        notebook:addPage(page, text) 
    end
end

function TDLZ_NotebooksService.getTextFromNotebookPage(notebookID, page)
    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local notebook = notebookMap:get(notebookID)
    if notebook ~= nil then
        local text = notebook:seePage(page)
        if text == nil then return "" end
        return text
    end
    return ""
end
---@param listItem TDLZ_BookLineModel
---@param lineStr any
---@param options any
function TDLZ_NotebooksService.appendLineToNotebook(listItem, lineStr, options)
    local prepend = ""
    if options.type == TDLZ_ISNewItemModal.CHECKBOX_OPTION then
        prepend = "[_]"
        listItem.isCheckbox = true
    end

    local append = " "
    if TDLZ_StringUtils.endsWithChar(lineStr, " ") then
        append = ""
    end
    if options.resetDaily then
        if not TDLZ_StringUtils.endsWithChar(append, " ") then
            append = append .. " "
        end
        append = append .. ":daily"
    end
    if append == " " then
        append = ""
    end
    listItem.lineString = prepend .. lineStr .. append
end
