local import = require(game.ReplicatedStorage.Lib.Import)

-- Necessary workaround to a bug with fragments being returned from functional components

local Roact = import "Roact"

local function Fragment(props)
    return Roact.createFragment(props[Roact.Children])
end

local function createFragment(children)
    return Roact.createElement(Fragment, {}, children)
end

return createFragment
