--- @class TDLZ_BookLineModel
--- @field isCheckbox boolean
--- @field isChecked boolean
--- @field pageNumber number
--- @field lineNumber number
--- @field lineString string
--- @field notebook any
TDLZ_BookLineModel = {}

function TDLZ_BookLineModel:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.isCheckbox = false
    o.isChecked = false
    o.pageNumber = 0
    o.lineNumber = 0
    o.lineString = ""
    o.notebook = nil
    return o
end
---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModel.builder()
    return TDLZ_BookLineModelBuilder:new()
end

---------------
--- BUILDER ---

--- @class TDLZ_ListItemViewModelBuilder
--- @field listItemModel TDLZ_BookLineModel
TDLZ_BookLineModelBuilder = {}
function TDLZ_BookLineModelBuilder:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.listItemModel = TDLZ_BookLineModel:new()
    return o
end

---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModelBuilder:isCheckbox(value)
    self.listItemModel.isCheckbox = value
    return self
end

---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModelBuilder:isChecked(value)
    self.listItemModel.isChecked = value
    return self
end
---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModelBuilder:pageNumber(value)
    self.listItemModel.pageNumber = value
    return self
end

---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModelBuilder:lineNumber(value)
    self.listItemModel.lineNumber = value
    return self
end

---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModelBuilder:lineString(value)
    self.listItemModel.lineString = value
    return self
end

---@return TDLZ_ListItemViewModelBuilder
function TDLZ_BookLineModelBuilder:notebook(value)
    self.listItemModel.notebook = value
    return self
end

---@return TDLZ_BookLineModel
function TDLZ_BookLineModelBuilder:build()
    return self.listItemModel
end