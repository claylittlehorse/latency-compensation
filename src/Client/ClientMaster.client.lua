local import = require(game.ReplicatedStorage.Lib.Import)
import.setConfig{
	aliasesMap = require(game.ReplicatedStorage.ImportPaths),
	reloadDirectories = require(game.ReplicatedStorage.ReloadDirectories),
}

import.setChangeListenersActive(true)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Store = import "State/Store"

-- Wait for local player to actually exist
local localPlayer = Players.LocalPlayer
if RunService:IsStudio() then
	while localPlayer.UserId == 0 do
		localPlayer.Changed:Wait()
	end
end

local loadOrder = {
	"../Systems/ClientCommands",
	"../Systems/UI",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system.start(Store)
end

import.setConfig{
	autoReload = true,
}
