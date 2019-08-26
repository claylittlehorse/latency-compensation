--[[
	Entry-point to the game UI.
]]

local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local LayoutProvider = import "../LayoutProvider"
-- local LanguageProvider = import "../LanguageProvider"

local function App(store)
	return Roact.createElement(RoactRodux.StoreProvider, { store = store }, {
		Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, {
			LayoutProvider = Roact.createElement(LayoutProvider),
			-- LanguageProvider = Roact.createElement(LanguageProvider),
		})
	})
end

return App
