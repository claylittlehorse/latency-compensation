local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"

local function round(number, increment)
	return math.floor(number/increment + 0.5) * increment
end

local Graph = Roact.PureComponent:extend("Graph")
function Graph:rendererDividers()
	local props = self.props
	local divisions = props.divisions
	local maxValue = props.maxValue
	local minValue = props.minValue

	local dividers = {}
	for i = 0, divisions.Y do
		dividers["verticalDivider"..i] = Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(150, 150, 150),
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1-i/divisions.Y, 0)
		}, {
			ValueText = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 8,
				Text =  round(minValue.Y + i/divisions.Y * maxValue.Y, 0.01),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.new(0, -5, 0, 0),
			})
		})
	end

	for i = 0, divisions.X do
		dividers["HorizontalDivider"..i] = Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(150, 150, 150),
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(i/divisions.X, 0, 0, 0)
		}, {
			ValueText = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 8,
				Text = round(minValue.X + i/divisions.X * maxValue.X, 0.01),
				TextYAlignment = Enum.TextYAlignment.Top,
				Position = UDim2.new(0, 0, 1, 5),
			})
		})
	end

	return Roact.createFragment(dividers)
end

function Graph:renderValueComponents()
	local props = self.props
	local valueGroups = props.valueGroups
	local maxValue = props.maxValue
	local minValue = props.minValue
	local valueRange = maxValue - minValue

	local valComponents = {}
	for groupName, group in pairs(valueGroups) do
		local valuesCount = #group.values
		local xSize = 1 / valuesCount
		for i, value in ipairs(group.values) do
			local yPos, yHeight do
				local fittedValue = (value - minValue) / valueRange
				yPos = fittedValue.Y

				local nextVal = group.values[i+1]
				if nextVal then
					local nextFittedValue = (nextVal - minValue) / valueRange
					yHeight = nextFittedValue.Y - fittedValue.Y
				end
			end

			if i == 1 then
				print(yHeight)
			end

			valComponents[groupName..i] = Roact.createElement("Frame", {
				BorderSizePixel = 0,
				BackgroundColor3 = group.color,
				BackgroundTransparency = 0.25,
				ZIndex = 2,
				Size = UDim2.new(xSize, 0, yHeight or 0, not yHeight and 3),
				Position = UDim2.new(((i-1)/valuesCount), 0, yPos, 0)
			})

			-- valComponents[groupName..i] = Roact.createElement("Frame", {
			-- 	BorderSizePixel = 0,
			-- 	BackgroundColor3 = group.color,
			-- 	ZIndex = 2,
			-- 	Size = UDim2.new(0, 3, fittedValue.Y, 0),
			-- 	AnchorPoint = Vector2.new(0.5, 1),
			-- 	Position = UDim2.new(fittedValue.X, 0, 1, 0)
			-- })
		end
	end

	return Roact.createFragment(valComponents)
end

function Graph:render()
	local props = self.props

	local size = props.size
	local anchorPoint = props.anchorPoint
	local position = props.position

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(230, 230, 230),
		BorderSizePixel = 0,
		Size = size,
		AnchorPoint = anchorPoint,
		Position = position,
	}, {
		Dividers = self:rendererDividers(),
		Values = self:renderValueComponents()
	})
end

return Graph
