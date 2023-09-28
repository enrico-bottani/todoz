---@class TDLZ_TodoListZWindowViewModel
---@field notebook TDLZ_NotebookModel
---@field notebookItems TDLZ_Set
TDLZ_TodoListZWindowViewModel = {}

---comment
---@param notebook TDLZ_NotebookModel
---@param notebookItems TDLZ_Set
---@return TDLZ_TodoListZWindowViewModel
function TDLZ_TodoListZWindowViewModel:new(notebook, notebookItems)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.notebookItems = notebookItems
    o.notebook = notebook
    return o
end

---@param notebookItems TDLZ_Set
---@return TDLZ_TodoListZWindowViewModel
function TDLZ_TodoListZWindowViewModel:setHashnames(notebookItems)
    self.notebookItems = notebookItems
    return self;
end

---@param notebook TDLZ_NotebookModel
---@return TDLZ_TodoListZWindowViewModel
function TDLZ_TodoListZWindowViewModel:setNotebook(notebook)
    self.notebook = notebook
    return self;
end
