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

	ContextActionService:BindAction("Pause", togglePauseAction, false, Enum.KeyCode.P)
	-- while wait(0.2) do
	-- 	Network.fireServer(PingEvents.PING_SERVER, tick())
	-- end
end

return ClientPing
