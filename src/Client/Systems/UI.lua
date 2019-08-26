local import = require(game.ReplicatedStorage.Lib.Import)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Roact = import "Roact"

local ROOT_NAME = import("Data/InterfaceConstants", {"ROOT_NAME"})
local Store = import "State/Store"

local client = Players.LocalPlayer

local UI = {}

local mountedApp

local function mountApp(app)
	if mountedApp then
		local unmount = mountedApp
		mountedApp = nil
		Roact.unmount(unmount)
	end

	mountedApp = Roact.mount(
		app(Store),
		client:WaitForChild("PlayerGui"),
		ROOT_NAME
	)
end

function UI.start()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	local reloading = false
	local function reload()
		if reloading then
			return
		end

		reloading = true
		local success, msg = pcall(function()
			local newApp = import "UI/Root/App"
			mountApp(newApp)
		end)

		if not success then
			warn(">>> Error on load!: <<<")
			warn(msg)
		end
		reloading = false
	end

	import.changeDetected:Connect(reload)

	reload()
end

return UI
