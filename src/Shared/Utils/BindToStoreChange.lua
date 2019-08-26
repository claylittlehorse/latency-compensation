local function shallowEqual(A, B)
	for key, aValue in pairs(A) do
		local bValue = B[key]

		if aValue ~= bValue then
			return false
		end
	end
	for key, bValue in pairs(B) do
		local aValue = A[key]

		if bValue ~= aValue then
			return false
		end
	end
	return true
end

local function isMicrostateChanged(newState, oldState)
	local newType = typeof(newState)
	local oldType = typeof(oldState)

	local typeIsTable = newType == "table"
	local typeIsSame = newType == oldType

	if typeIsTable and typeIsSame then
		return not shallowEqual(newState, oldState)
	else
		return oldState ~= newState
	end
end

local function BindToStoreChange(store, microstateProvider, callBack)
	store.changed:connect(function(newState, oldState)
		local newMicrostate = microstateProvider(newState)
		local oldMicrostate = microstateProvider(oldState)

		if isMicrostateChanged(newMicrostate, oldMicrostate) then
			callBack(newMicrostate, oldMicrostate)
		end
	end)
end

return BindToStoreChange
