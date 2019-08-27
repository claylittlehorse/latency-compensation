local import = require(game.ReplicatedStorage.Lib.Import)

local action = import "Action"
local t = import "t"

local check = t.tuple(t.number, t.number, t.number, t.number)

return action(script.Name, function(totalPing, sendPing, recievePing, sendTime)
	assert(check(totalPing, sendPing, recievePing, sendTime))

	return {
		totalPing = totalPing,
		sendPing = sendPing,
		recievePing = recievePing,
		sendTime = sendTime
	}
end)
