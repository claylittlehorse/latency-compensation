--[[
	This file defines interfaces and types used for typechecking common
	constructs.

	For example, this allows us to expect a Rodux Store in a function, and
	typecheck it accordingly:

		local function foo(store)
			assert(IStore(store))
			-- `store` is now garanteed to have properties that resemble a rodux
			-- Store instance.
		end

	Without t, you might use an assertion like `assert(typeof(store) == "table")`,
	which isn't very specific about what should be expected. Using a t interface
	allows us to be declarative about what our function arguments are.

	Types are written in UpperCamelCase, and each innterface is prefixed with
	"I" (for interface).
]]

local import = require(game.ReplicatedStorage.Lib.Import)

local t = import "t"

local types = {}

--[[
	Basic rodux action.

	For anything more complex than just checking if it has a `type`, you should
	create a new interface.
]]
types.IAction = t.union(t.callback, t.interface({
	type = t.string,
}))

--[[
	The object returned from our "action" function for making acction creators.
]]
types.IActionCreator = t.interface({
	name = t.string,
})

--[[
	Rodux store.
]]
types.IStore = t.interface({
	changed = types.ISignal,
	getState = t.callback,
	dispatch = t.callback,
	destruct = t.callback,
	flush = t.callback,
})

--[[
	Fake Player instance used for unit testing. See the "UPlayer" type.
]]
types.IMockPlayer = t.interface({
	Name = t.string,
	UserId = t.integer
})

--[[
	Type representing a player or a fake player. This is used with functions
	that need to be unit tested.

	Since it's impossible to make a Player instance, we have to rely on
	providing mock data to the function, in the form of a MockPlayer.

	This should _not_ be used with remotes when validating that a client passed
	a player as an argument. A client could easily pass fake data through and
	cause problems in this case.
]]
types.Player = t.union(
	t.instance("Player"),
	types.IMockPlayer
)

return types
