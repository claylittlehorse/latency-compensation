local import = require(game.ReplicatedStorage.Lib.Import)

local Rodux = import "Rodux"
local Cryo = import "Cryo"

local AddPing = import "Actions/AddPing"

local initialState = {
	pings = {},
	sendPings = {},
	recievePings = {},
}

local function truncateAdd(list, maxLength, value)
	local newList = Cryo.List.join(list, {value})
	if #newList > maxLength then
		table.remove(newList, 1)
	end
	return newList
end

return Rodux.createReducer(initialState, {
	[AddPing.name] = function(state, action)
		local totalPing = action.totalPing
		local sendPing = action.sendPing
		local recievePing = action.recievePing
		local sendTime = action.sendTime

		local newPings = truncateAdd(state.pings, 300, Vector2.new(sendTime, totalPing))
		local newSendPings = truncateAdd(state.pings, 300, Vector2.new(sendTime, sendPing))
		local newRecievePings = truncateAdd(state.pings, 300, Vector2.new(sendTime, recievePing))

		return {
			pings = newPings,
			sendPings = newSendPings,
			recievePings = newRecievePings
		}
	end
})
