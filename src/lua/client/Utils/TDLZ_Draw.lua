TDLZ_Draw = {}

---Draw text on canvas
---@param canvas any
---@param text string
---@param x number
---@param y number
---@param color TDLZ_Color
---@param fontSize number
function TDLZ_Draw.drawText(canvas, text, x, y, color, fontSize)
    canvas:drawText(text, x, y, color.r, color.g, color.b, color.a, fontSize)
end

---@param canvas any
---@param texture string
---@param x number
---@param y number
---@param color TDLZ_Color
function TDLZ_Draw.drawTexture(canvas, texture, x, y, color)
    canvas:drawTexture(texture, x, y, color.a, color.r, color.g, color.b)
end
---@param canvas ISUIElement
---@param x number
---@param y number
---@param width number
---@param height number
---@param color TDLZ_Color
function TDLZ_Draw.drawRectBorder(canvas, x, y, width, height, color)
    canvas:drawRectBorder(x, y, width, height, color.a, color.r, color.g, color.b)
end

function TDLZ_Draw.drawRect(canvas, x, y, width, height, color)
    canvas:drawRect(x, y, width, height, color.a, color.r, color.g, color.b)
end
