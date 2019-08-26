--[[
	Removes an item from the state using an action's key.

	Usage:

		local reducer = createReducer({
			foo = "bar"
		}, {
			REMOVE = removeByKey("userId")
		})

		local action = {
			type = "REMOVE",
			userId = "foo"
		}

		reducer(nil, action)
		-- {}
]]

local import = require(game.ReplicatedStorage.Lib.Import)

local Immutable = import "Immutable"
local t = import "t"

local check = t.tuple(t.string)

local function removeByKey(key)
	assert(check(key))

	return function(state, action)
		local copy = Immutable.copy(state)
		copy[action[key]] = nil
		return copy
	end
end

return removeByKey
