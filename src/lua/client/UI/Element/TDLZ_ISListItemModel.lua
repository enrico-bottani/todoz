TDLZ_ISListItemModel = {}
--- @class TDLZ_ISListItemModel
--- @field label string
--- @field data TDLZ_ISListItemDataModel
function TDLZ_ISListItemModel:new(label, data)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.label =label
    o.data = data
    return o
end

--- @class TDLZ_ISListItemDataModel
--- @field isCheckbox boolean
--- @field isChecked boolean
--- @field pageNumber number
--- @field lineNumber number
--- @field lineString string
--- @field lines table
--- @field notebook any
TDLZ_ISListItemDataModel = {}

function TDLZ_ISListItemDataModel:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.isCheckbox = false
    o.isChecked = false
    o.pageNumber = 0
    o.lineNumber = 0
    o.lineString = "" -- test only (redundant)
    o.lines = 0       -- test only (redundant)
    o.notebook = nil
    return o
end
---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModel.builder()
    return TDLZ_ISListItemDataModelBuilder:new()
end

---------------
--- BUILDER ---

--- @class TDLZ_ISListItemModelBuilder
--- @field listItemModel TDLZ_ISListItemDataModel
TDLZ_ISListItemDataModelBuilder = {}
function TDLZ_ISListItemDataModelBuilder:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.listItemModel = TDLZ_ISListItemDataModel:new()
    return o
end

---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:isCheckbox(value)
    self.listItemModel.isCheckbox = value
    return self
end

---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:isChecked(value)
    self.listItemModel.isChecked = value
    return self
end
---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:pageNumber(value)
    self.listItemModel.pageNumber = value
    return self
end

---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:lineNumber(value)
    self.listItemModel.lineNumber = value
    return self
end

---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:lineString(value)
    self.listItemModel.lineString = value
    return self
end

---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:lines(value)
    self.listItemModel.lines = value
    return self
end

---@return TDLZ_ISListItemModelBuilder
function TDLZ_ISListItemDataModelBuilder:notebook(value)
    self.listItemModel.notebook = value
    return self
end

---@return TDLZ_ISListItemDataModel
function TDLZ_ISListItemDataModelBuilder:build()
    return self.listItemModel
end