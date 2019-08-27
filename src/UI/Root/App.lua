--[[
	Entry-point to the game UI.
]]

local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local PingGraph = import "UI/Components/PingGraph"

local function App(store)
	return Roact.createElement(RoactRodux.StoreProvider, { store = store }, {
		Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, {
			-- PingGraph = Roact.createElement(PingGraph)
		})
	})
end

return App
