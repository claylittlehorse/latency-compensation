local import = require(game.ReplicatedStorage.Lib.Import)

local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local Network = import "Network"
local PingEvents = import "Data/NetworkEvents/PingEvents"

local Store = import "State/Store"
local AddPing = import "Actions/AddPing"

local ClientPing = {}

local paused = false
local togglePauseAction = function(_, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		paused = not paused
	end
end

local function round(number, increment)
	return math.floor(number/increment + 0.5) * increment
end

local function makeStwing(values)
	local valstr = "{x: %s, y:%s}, "
	local str = ""
	for _, v in ipairs(values) do
		str = str..valstr:format(tostring(round(v.x, 0.001)), tostring(round(v.y, 0.001)))
	end
	return str
end

function ClientPing.start()
	local startTime = tick()
	Network.hookEvent(PingEvents.PING_CLIENT, function(serverRecievedTime, clientSentTime)
		local sendTimeMs = math.floor((serverRecievedTime - clientSentTime) * 1000)
		local recieveTimeMs = math.floor((tick() - serverRecievedTime) * 1000)
		local ping = math.floor((tick()-clientSentTime) * 1000)

		Store:dispatch(AddPing(ping, sendTimeMs, recieveTimeMs, clientSentTime-startTime))
	end)

	RunService.Heartbeat:connect(function()
		if not paused then
			Network.fireServer(PingEvents.PING_SERVER, tick())
		end
	end)

	-- ContextActionService:BindAction("Pause", togglePauseAction, false, Enum.KeyCode.P)

	wait(5)
	togglePauseAction()

	local state = Store:getState()
	local pingValues = makeStwing(state.Ping.pings)
	Network.fireServer(PingEvents.PASTE, pingValues)
	print("----------------|| PING ||----------------")
	print(pingValues)
end

return ClientPing
