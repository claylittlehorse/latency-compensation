local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local function Scale(props)
	local scale = props.scale
	return Roact.createElement("UIScale", {
		Scale = scale
	})
end

return RoactRodux.connect(
	function(state)
		local interfaceState = state.Interface
		local scale = interfaceState.scale
		return {
			scale = scale
		}
	end
)(Scale)
