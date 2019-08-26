-- Implementation of signal w/o bindable event

local Signal = {}
Signal.__index = {}

function Signal.new()
	return setmetatable({connections = {}}, Signal)
end

function Signal:Connect(func)
	self.connections[func] = func

	local disconnect = function()
		self.connections[func] = nil
	end

	return disconnect
end

function Signal:Fire(...)
	for _, func in pairs(self.connections) do
		func(...)
	end
end

return Signal
