local import = require(game.ReplicatedStorage.Lib.Import)
local Cmdr = import "Cmdr"
local commandsFolder = import "Server/Commands"
local typesFolder = import "Server/CommandTypes"

local Commands = {}

function Commands.start()
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(commandsFolder)
	Cmdr:RegisterTypesIn(typesFolder)
end

return Commands
