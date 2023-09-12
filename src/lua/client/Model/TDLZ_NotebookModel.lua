---@class TDLZ_NotebookModel
---@field currentNotebook any
---@field notebookID number
---@field currentPage number
---@field numberOfPages number
TDLZ_NotebookModel = {}

---@param currentNotebook any
---@param notebookID number
---@param currentPage number
---@param numberOfPages number
function TDLZ_NotebookModel:new(currentNotebook, notebookID, currentPage, numberOfPages)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.currentNotebook = currentNotebook
    o.notebookID = notebookID

    print("TDLZ_NotebookModel current page: " .. currentPage)
    o.currentPage = currentPage
    o.numberOfPages = numberOfPages
    return o
end
