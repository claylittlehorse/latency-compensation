--[[
	Pretty prints the state to the output every time something changes.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Pretty = import "Utils/Pretty"

local function stateLoggerMiddleware(nextDispatch, store)
	return function(action)
		local nextAction = nextDispatch(action)
		local state = store:getState()

		print(Pretty(state))

		return nextAction
	end
end

return stateLoggerMiddleware
