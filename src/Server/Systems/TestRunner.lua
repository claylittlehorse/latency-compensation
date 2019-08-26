-- Uses TestEZ to run all the spec files. Remember to write unit tests!
-- https://github.com/Roblox/TestEZ

local import = require(game.ReplicatedStorage.Lib.Import)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local TestEZ = import "TestEZ"

-- The places to look for spec files
local LOCATIONS = {
	ServerScriptService,
	ReplicatedStorage,
	StarterPlayerScripts
}

local TestRunner = {}

function TestRunner.start()
	TestEZ.TestBootstrap:run(LOCATIONS, TestEZ.Reporters.TextReporterQuiet)
end

return TestRunner
