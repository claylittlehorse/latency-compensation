local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Roact = import "Roact"

local ROOT_NAME = import("Data/InterfaceConstants", {"ROOT_NAME"})

local RootPortal = Roact.PureComponent:extend("RootPortal")

function RootPortal:render()
	local screenGui = self.state.screenGui
	if not screenGui then
		return
	end
	return Roact.createElement(Roact.Portal, {
		target = screenGui
	}, self.props[Roact.Children])
end

function RootPortal:didMount()
	spawn(function()
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local screenGui = playerGui:WaitForChild(ROOT_NAME)
		self:setState{
			screenGui = screenGui
		}
	end)
end


return RootPortal
