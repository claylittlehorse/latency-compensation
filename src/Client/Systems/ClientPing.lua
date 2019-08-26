local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local PingEvents = import "Data/NetworkEvents/PingEvents"

local Store = import "State/Store"
local SetPing = import "Actions/SetPing"

local ClientPing = {}

function ClientPing.start()
	local pingSentTime = tick()

	Network.hookEvent(PingEvents.PING_CLIENT, function()
		local transitTime = tick() - pingSentTime
		local ping = math.floor(transitTime*1000)
		Store:dispatch(SetPing(ping))

		pingSentTime = tick()
		Network.fireServer(PingEvents.PING_SERVER)
	end)

	Network.fireServer(PingEvents.PING_SERVER)
end

return ClientPing
