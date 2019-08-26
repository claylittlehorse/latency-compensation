local assetIdModules = script:GetChildren()

local ASSET_PREFIX = "rbxassetid://"
local Assets = {}

for _, module in pairs(assetIdModules) do
	local idNumbers = require(module)
	local completedIds = {}
	for key, idNumber in pairs(idNumbers) do
		completedIds[key] = ASSET_PREFIX..idNumber
	end
	Assets[module.Name] = completedIds
end

return Assets
