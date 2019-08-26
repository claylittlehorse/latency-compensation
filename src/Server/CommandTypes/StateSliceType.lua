local import = require(game.ReplicatedStorage.Lib.Import)
local Store = import "State/Store"

-- On init, cmdr moves this module to a realtive path from Util
local Util = require(script.Parent.Parent.Shared.Util)

local function getStateSliceNames()
	local state = Store:getState()
	local names = {}
	for name, _ in pairs(state) do
		names[#names+1] = name
	end
	return names
end

local stateSliceType = {
	Transform = function(text)
		local sliceNames = getStateSliceNames()
		local findSliceName = Util.MakeFuzzyFinder(sliceNames)

		return findSliceName(text)
	end;

	Validate = function(sliceNames)
		return #sliceNames > 0, "No valid state slices with that name could be found"
	end;

	Autocomplete = function(sliceNames)
		return sliceNames
	end;

	Parse = function(sliceNames)
		local sliceName = sliceNames[1]
		local state = Store:getState()
		return state[sliceName]
	end;
}

return function(cmdr)
	cmdr:RegisterType("stateSlice", stateSliceType)
end
