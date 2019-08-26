local import = require(game.ReplicatedStorage.Lib.Import)

local Inspect = import("Inspect", {"inspect"})

local Store = import "State/Store"

return function(_, stateSlice)
	if stateSlice then
		print(Inspect(stateSlice))
		return "Printed state"
	else
		local state = Store:getState()
		print(Inspect(state))
		return "Printed state"
	end
end
