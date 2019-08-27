local import = require(game.ReplicatedStorage.Lib.Import)

local Network = import "Network"
local PingEvents = import "Data/NetworkEvents/PingEvents"

local Store = import "State/Store"
local SetPing = import "Actions/SetPing"

local ClientPing = {}

function ClientPing.start()
	local pingSentTime = tick()
	local offsets = {}

	Network.hookEvent(PingEvents.PING_CLIENT, function(serverTick)
		local transitTime = tick() - pingSentTime
		local ping = math.floor(transitTime*1000)
		Store:dispatch(SetPing(ping))

		local timeOffsetMs = math.floor((tick() - (transitTime/2) - serverTick) * 1000)
		offsets[#offsets+1] = {
			offsetTime = timeOffsetMs,
			ping = ping,
			sendTime = math.floor((serverTick - pingSentTime) * 1000),
			recieveTime = math.floor((tick() - serverTick) * 1000),
			est = math.floor((transitTime/2) * 1000),
		}

		pingSentTime = tick()
		Network.fireServer(PingEvents.PING_SERVER)
	end)

	Network.fireServer(PingEvents.PING_SERVER)

	while wait(5) do
		local highest = -math.huge
		local high
		local lowest = math.huge
		local low

		for _, offset in ipairs(offsets) do
			if offset.offsetTime > highest then
				highest = offset.offsetTime
				high = offset
			end

			if offset.offsetTime < lowest then
				lowest = offset.offsetTime
				low = offset
			end
		end

		print("High", high.offsetTime, "ping", high.ping, "send time", high.sendTime, "recieveTime", high.recieveTime, "rec est", high.est)
		print("Low", low.offsetTime, "ping", low.ping, "send time", low.sendTime, "recieveTime", low.recieveTime, "rec est", low.est)
		print("range", high.offsetTime-low.offsetTime)

		offsets = {}
	end
end

return ClientPing
