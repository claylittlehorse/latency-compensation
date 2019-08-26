local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local function PingDisplay(props)
	local ping = props.ping
	return Roact.createElement("TextLabel", {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 40, 0, 40),

		TextSize = 12,
		Text = tostring(ping),
	})
end

return RoactRodux.connect(
	function(state)
		return {
			ping = state.Ping
		}
	end
)(PingDisplay)
