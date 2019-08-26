local import = require(game.ReplicatedStorage.Lib.Import)

local action = import "Action"
local t = import "t"

local check = t.tuple(t.string)

return action(script.Name, function(userId)
	assert(check(userId))

	return {
		userId = userId
	}
end)
