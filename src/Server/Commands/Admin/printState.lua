return {
	Name = "printState",
	Aliases = {"ps"},
	Description = "Prints the state or a specific slice.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "stateSlice",
			Name = "State slice",
			Description = "Slice of the state",
			Optional = true,
        },
	},
}
