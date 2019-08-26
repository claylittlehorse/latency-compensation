local import = require(game.ReplicatedStorage.Lib.Import)

local action = import "Action"
local t = import "t"

local check = t.tuple(t.number)

return action(script.Name, function(ping)
	assert(check(ping))

	return {
		ping = ping
	}
end)
