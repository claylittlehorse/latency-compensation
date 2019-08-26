local TextService = game:GetService("TextService")

local text = {}

local MAX_BOUND = 10000
text._TEMP_PATCHED_PADDING = Vector2.new(0, 0)

function text.getTextBounds(str, font, fontSize, bounds)
	return TextService:GetTextSize(str, fontSize, font, bounds) + text._TEMP_PATCHED_PADDING
end

function text.getTextWidth(str, font, fontSize)
	return text.getTextBounds(str, font, fontSize, Vector2.new(MAX_BOUND, MAX_BOUND)).X
end

function text.getTextHeight(str, font, fontSize, widthCap)
	return text.getTextBounds(str, font, fontSize, Vector2.new(widthCap, MAX_BOUND)).Y
end
