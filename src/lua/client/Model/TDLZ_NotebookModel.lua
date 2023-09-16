---@class TDLZ_NotebookModel
---@field currentNotebook any
---@field notebookID number
---@field currentPage number
---@field numberOfPages number
---@field pageString string
TDLZ_NotebookModel = {}

---@param currentNotebook any
---@param notebookID number
---@param currentPage number
---@param numberOfPages number
function TDLZ_NotebookModel:new(currentNotebook, notebookID, pageString, currentPage, numberOfPages)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.currentNotebook = currentNotebook
    o.notebookID = notebookID
    o.pageString = pageString
    o.currentPage = currentPage
    o.numberOfPages = numberOfPages
    return o
end

---@return table<number, string>
function TDLZ_NotebookModel:getPageLines()
    local rtn = {}
    if self.pageString ~= "" then
        local lines = TDLZ_StringUtils.splitKeepingEmptyLines(self.pageString)
        for lineNumber, lineString in ipairs(lines) do
            table.insert(rtn, lineString)
        end
    end
    return rtn
end
