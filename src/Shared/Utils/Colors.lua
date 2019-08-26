local colors = {}

local function _changeBrightness(color, percent)
    local h, s, v = Color3.toHSV(color)
    return Color3.fromHSV(h, s, math.clamp(v+(v*percent/100), 0, 1))
end

function colors.brighten(color, percent)
    return _changeBrightness(color, percent)
end

function colors.darken(color, percent)
    return _changeBrightness(color, -percent)
end

return colors
