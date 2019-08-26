local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local UserInputService = game:GetService("UserInputService")

local SetLayout = import "Actions/Interface/SetLayout"
local SetScale = import "Actions/Interface/SetScale"

local ScalingBoundaries, LayoutTypes = import("Data/InterfaceConstants", {"ScalingBoundaries", "LayoutTypes"})
local LayoutProvider = Roact.PureComponent:extend("LayoutProvider")

local function getScale(viewportSize)
	local minSizeDifference = ScalingBoundaries.MIN_SIZE - viewportSize
	local maxSizeDifference = viewportSize - ScalingBoundaries.MAX_SIZE

	local willScaleDown = minSizeDifference.X > 0 or minSizeDifference.Y > 0
	local willScaleUp = maxSizeDifference.X > 0 or minSizeDifference.Y > 0

	local boundarySize = (willScaleDown and ScalingBoundaries.MIN_SIZE) or ScalingBoundaries.MAX_SIZE
	local chooseFunc = willScaleDown and math.min or math.max

	if willScaleDown or willScaleUp then
		local scaleX = viewportSize.X / boundarySize.X
		local scaleY = viewportSize.Y / boundarySize.Y
		return chooseFunc(scaleX, scaleY)
	else
		return 1
	end
end

function LayoutProvider:init(props)
	local setLayout = props.setLayout
	local setScale = props.setScale
	local currentCamera = workspace.CurrentCamera

	local viewportSize = currentCamera.ViewportSize
	local uiScale = getScale(viewportSize)
	setScale(uiScale)

	self.viewportSizeListener = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local viewportSize = currentCamera.ViewportSize
		local uiScale = getScale(viewportSize)
		setScale(uiScale)
	end)



	if UserInputService.GamepadEnabled then
		setLayout(LayoutTypes.GAMEPAD)
	end

	self.inputListener = UserInputService.InputBegan:connect(function(input)
		local newLayout

		if (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3
			or input.UserInputType == Enum.UserInputType.MouseWheel
			or input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Keyboard)
		then
			newLayout = LayoutTypes.DESKTOP
		elseif (input.UserInputType == Enum.UserInputType.Gamepad1
			or input.UserInputType == Enum.UserInputType.Gamepad2
			or input.UserInputType == Enum.UserInputType.Gamepad3
			or input.UserInputType == Enum.UserInputType.Gamepad4
			or input.UserInputType == Enum.UserInputType.Gamepad5
			or input.UserInputType == Enum.UserInputType.Gamepad6)
		then
			newLayout = LayoutTypes.GAMEPAD
		end

		if newLayout then
			setLayout(newLayout)
		end
	end)
end

function LayoutProvider:willUnmount()
	if self.viewportSizeListener then
		self.viewportSizeListener:Disconnect()
	end
	if self.inputListener then
		self.inputListener:Disconnect()
	end
end

function LayoutProvider:render()
	return
end

return RoactRodux.connect(nil, function(dispatch)
	return {
		setLayout = function(layout)
			dispatch(SetLayout(layout))
		end,
		setScale = function(scale)
			dispatch(SetScale(scale))
		end,
	}
end)(LayoutProvider)
