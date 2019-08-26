local import = require(game.ReplicatedStorage.Lib.Import)

local Rodux = import "Rodux"

local middlewares = {
	Rodux.thunkMiddleware,
}

local reducers = Rodux.combineReducers({
	Ping = import "Reducers/Ping"
})

local store = Rodux.Store.new(reducers, nil, middlewares)

return store
