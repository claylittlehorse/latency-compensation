local import = require(game.ReplicatedStorage.Lib.Import)

local Rodux = import "Rodux"

local SetPing = import "Actions/SetPing"

return Rodux.createReducer(0, {
	[SetPing.name] = function(state, action)
		return action.ping or 0
	end
})
