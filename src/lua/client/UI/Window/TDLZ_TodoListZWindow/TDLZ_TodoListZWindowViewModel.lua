---@class TDLZ_TodoListZWindowViewModel
---@field notebook TDLZ_NotebookModel
---@field allItems table<number,any>
TDLZ_TodoListZWindowViewModel = {}

---comment
---@param notebook TDLZ_NotebookModel
---@param allItems table
---@return TDLZ_TodoListZWindowViewModel
function TDLZ_TodoListZWindowViewModel:new(notebook, allItems)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.allItems = allItems
    o.notebook = notebook
    return o
end

---@param allItems table<number,any>
---@return TDLZ_TodoListZWindowViewModel
function TDLZ_TodoListZWindowViewModel:setHashnames(allItems)
    self.allItems = allItems
    return self;
end

---@param notebook TDLZ_NotebookModel
---@return TDLZ_TodoListZWindowViewModel
function TDLZ_TodoListZWindowViewModel:setNotebook(notebook)
    self.notebook = notebook
    return self;
end
