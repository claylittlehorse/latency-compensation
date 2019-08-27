local import = require(game.ReplicatedStorage.Lib.Import)

local Rodux = import "Rodux"

local SetPing = import "Actions/SetPing"

local initialState = {
	current = 0,
	highest = 0,
	lowest = math.huge,
	average = 0,
}

local pings = {}

return Rodux.createReducer(initialState, {
	[SetPing.name] = function(state, action)
		local ping = action.ping

		pings[#pings+1] = ping

		if #pings > 1000 then
			table.remove(pings, 1)
		end

		local total = 0
		for i = 1, #pings do
			total = total + pings[i]
		end

		local average = math.floor(total / #pings)

		return {
			current = ping,
			highest = state.highest > ping and state.highest or ping,
			lowest = state.lowest < ping and state.lowest or ping,
			average = average,
		}
	end
})
