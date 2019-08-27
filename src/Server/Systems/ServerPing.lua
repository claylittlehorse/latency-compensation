local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local PingEvents = import "Data/NetworkEvents/PingEvents"

local ServerPing = {}

function ServerPing.start()
	Network.createEvent(PingEvents.PING_CLIENT)

	Network.hookEvent(PingEvents.PING_SERVER, function(player, clientSentTime)
		local serverRecievedTime = tick()
		Network.fireClient(PingEvents.PING_CLIENT, player, serverRecievedTime, clientSentTime)
	end)
end

return ServerPing
