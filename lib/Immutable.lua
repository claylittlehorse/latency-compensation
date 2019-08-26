local Immutable = {}

function Immutable.joinDict(...)
	local t = {}
	for i = 1, select("#", ...) do
		local dict = select(i, ...)
		for k, v in pairs(dict) do
			t[k] = v
		end
	end
	return t
end

Immutable.join = Immutable.joinDict

function Immutable.joinLists(...)
	local t = {}
	for i = 1, select("#", ...) do
		local list = select(i, ...)
		local len = #t
		for k = 1, #list do
			t[len + k] = list[k]
		end
	end
	return t
end

function Immutable.set(dict, setkey, setvalue)
	local t = {}
	for k, v in pairs(dict) do
		t[k] = v
	end
	t[setkey] = setvalue
	return t
end

function Immutable.append(list, ...)
	local t = {}
	local len = #list
	for k = 1, len do
		t[k] = list[k]
	end
	for i = 1, select("#", ...) do
		t[len + i] = select(i, ...)
	end
	return t
end

function Immutable.removeRange(list, index, len)
	local t = {}
	for i = 1, #list do
		if i < index or i >= index + len then
			table.insert(t, list[i])
		end
	end
	return t
end

function Immutable.removeValue(list, removeValue)
	local t = {}
	for i = 1, #list do
		if list[i] ~= removeValue then
			table.insert(t, list[i])
		end
	end
	return t
end

function Immutable.copy(t)
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = v
	end
	return copy
end

return Immutable