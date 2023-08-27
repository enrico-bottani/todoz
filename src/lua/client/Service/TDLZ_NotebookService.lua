TDLZ_NotebooksService = {}
function TDLZ_NotebooksService.saveTextToNotebookPage(notebookID, page, text)
    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local notebook = TDLZ_Map.get(notebookMap, notebookID)
    if notebook ~= nil then notebook:addPage(page, text) end
end

function TDLZ_NotebooksService.getTextFromNotebookPage(notebookID, page)
    local notebookMap = TDLZ_NotebooksUtils.getNotebooksInContainer()
    local notebook = TDLZ_Map.get(notebookMap, notebookID)
    if notebook ~= nil then
        local text = notebook:seePage(page)
        if text == nil then return "" end
        return text
    end
    return ""
end

function TDLZ_NotebooksService.appendLineToNotebook(notebookID,currentPage,lineStr,options)
    local pageText = TDLZ_NotebooksService.getTextFromNotebookPage(notebookID, currentPage)
    local sep = ""
    if pageText ~= "" then
        sep = "\n"
    end
    local prepend = ""
    print("options.type ".. options.type)
    if options.type == TDLZ_ISNewItemModal.CHECKBOX_OPTION then
        prepend = "[_]"
    end
    
    
    local append = " "
    if TDLZ_StringUtils.endsWithChar(lineStr, " ") then
        append = ""
    end
    if options.isAnItem then
        append = append .. ":item"
    end
    if options.resetDaily then
        if not TDLZ_StringUtils.endsWithChar(append, " ") then
            append = append .. " "
        end
        append = append .. ":daily"
    end
    if append==" " then
        append = ""
    end
    TDLZ_NotebooksService.saveTextToNotebookPage(notebookID, currentPage,
        pageText .. sep .. prepend .. lineStr .. append)
end