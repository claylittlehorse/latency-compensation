local import = require(game.ReplicatedStorage.Lib.Import)

local Rodux = import "Rodux"

local middlewares = {
	Rodux.thunkMiddleware,
}

local reducers = {
	-- import "Reducers/CoolReducer"
}

local rootReducer do
	if #reducers == 0 then
		rootReducer = function()
			return {}
		end
	else
		rootReducer = Rodux.combineReducers(reducers)
	end
end

local store = Rodux.Store.new(rootReducer, nil, middlewares)

return store
