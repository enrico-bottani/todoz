require "src.lua.client.UI.Element.TDLZ_List.TDLZ_ISList"
TDLZ_ISListDrawing = {}

---@param o TDLZ_ISList
---@param y number y position where to draw checkbox
---@param highlight? true to highlight checkbox borders
function TDLZ_ISListDrawing.drawTickboxBorders(o, y, highlight)
    if highlight then
        TDLZ_Draw.drawRectBorder(o, o.marginLeft, y, BOX_SIZE, BOX_SIZE, TDLZ_Colors.HIGHLIGHT)
        TDLZ_Draw.drawRectBorder(o, o.marginLeft - 1, y - 1, BOX_SIZE + 2, BOX_SIZE + 2,
            TDLZ_Colors.HIGHLIGHT)
    else
        TDLZ_Draw.drawRectBorder(o, o.marginLeft, y, BOX_SIZE, BOX_SIZE, TDLZ_Colors.GRAY_300)
    end
end

function TDLZ_ISListDrawing.drawTickboxTick(o, y)
    TDLZ_Draw.drawTexture(o, o.tickTexture, o.marginLeft + 3, y + 2, TDLZ_Colors.WHITE)
end

function TDLZ_ISListDrawing.drawMoveTexture(o, y, color)
    TDLZ_Draw.drawTexture(o, getTexture("media/ui/move.png"),
        o:getWidth() - o.marginLeft - BOX_SIZE,
        y + o.itemheight / 2 - 9, color)
end

---comment
---@param o TDLZ_ISList
---@param y number
---@param text string
function TDLZ_ISListDrawing.drawText(o, y, text)
    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local MARGIN_BETWEEN = FONT_HGT_SMALL / 4
    local dy = (o.itemheight - FONT_HGT_SMALL) / 2
    TDLZ_Draw.drawText(o, text,
        o.marginLeft + BOX_SIZE + MARGIN_BETWEEN, y + dy,
        TDLZ_Colors.GRAY_800, UIFont.Small)
end

---commented
---@param o TDLZ_ISList
---@param y number
---@param color? TDLZ_Color
function TDLZ_ISListDrawing.drawLineLeftHighlight(o, y, color)
    local c = TDLZ_Colors.YELLOW
    if color then
        c = color
    end
    TDLZ_Draw.drawRect(o, 1, y - 1, 2, o.itemheight + 2, c);
end

function TDLZ_ISListDrawing.drawJobDelta(o, y, jobDelta)
    TDLZ_Draw.drawRect(o, 0, y - 1, o.width * jobDelta, o.itemheight + 2,
        TDLZ_Colors.YELLOW_A1)
end
