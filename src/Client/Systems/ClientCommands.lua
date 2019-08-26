local Commands = {}

function Commands.start()
	local Cmdr = require(game.ReplicatedStorage:WaitForChild("CmdrClient"))
	-- Configurable, and you can choose multiple keys
	Cmdr:SetActivationKeys({ Enum.KeyCode.Tilde, Enum.KeyCode.Semicolon })
end

return Commands
