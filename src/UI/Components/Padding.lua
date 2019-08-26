local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local t = import "t"
local Styles = import "UI/Styles"

local IProps = t.interface({
	size = t.optional(t.number)
})

local function Padding(props)
	assert(IProps(props))

	local size = props.size or Styles.padding

	return Roact.createElement("UIPadding", {
		PaddingBottom = UDim.new(0, size),
		PaddingLeft = UDim.new(0, size),
		PaddingRight = UDim.new(0, size),
		PaddingTop = UDim.new(0, size),
	})
end

return Padding
