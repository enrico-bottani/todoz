--- @class TDLZ_Color
--- @field r number red
--- @field g number green
--- @field b number blue
--- @field a number Alpha Channel
TDLZ_Color = {}
function TDLZ_Color:new(r, g, b, a)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.r = r
    o.g = g
    o.b = b
    o.a = a
    return o
end

--- @class TDLZ_Colors
--- @field TEXT_COLOR TDLZ_Color
TDLZ_Colors = {}
TDLZ_Colors.GRAY_800 = TDLZ_Color:new(0.8, 0.8, 0.8, 1)
TDLZ_Colors.GRAY_700 = TDLZ_Color:new(0.7, 0.7, 0.7, 1)
TDLZ_Colors.GRAY_600 = TDLZ_Color:new(0.6, 0.6, 0.6, 1)
TDLZ_Colors.GRAY_500 = TDLZ_Color:new(0.5, 0.5, 0.5, 1)

TDLZ_Colors.WHITE = TDLZ_Color:new(1, 1, 1, 1)

TDLZ_Colors.TRANSPARENT = TDLZ_Color:new(0, 0, 0, 0)

TDLZ_Colors.GRAY_300 = TDLZ_Color:new(0.3, 0.3, 0.3, 1)
TDLZ_Colors.GRAY_100 = TDLZ_Color:new(0.1, 0.1, 0.1, 1)
TDLZ_Colors.GRAY_130 = TDLZ_Color:new(0.13, 0.13, 0.13, 1)
TDLZ_Colors.YELLOW = TDLZ_Color:new(1, 0.92, 0.3, 1)
TDLZ_Colors.GREEN = TDLZ_Color:new(0.2, 1.0, 1.0, 0.4)
TDLZ_Colors.RED = TDLZ_Color:new(1, 0, 0, 1)
TDLZ_Colors.YELLOW_A5 = TDLZ_Color:new(1, 0.92, 0.3, 0.5)
TDLZ_Colors.YELLOW_A1 = TDLZ_Color:new(1, 0.92, 0.3, 0.1)
