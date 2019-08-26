return function(name, fn)
	assert(type(name) == 'string')
	assert(type(fn) == 'function')

	return setmetatable({
		name = name,
	}, {
		__call = function(_, ...)
			local result = fn(...)
			assert(type(result) == 'table')
			result.type = name
			return result
		end
	})
end
