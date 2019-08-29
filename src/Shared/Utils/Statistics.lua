local function calculateMean(dataSetList)
	local total = 0
	for _, value in ipairs(dataSetList) do
		total = total + value
	end
	return total / #dataSetList
end

local function calculateAverageDeviation(dataSetList)
	local mean = calculateMean(dataSetList)
	local total = 0
	for _, value in ipairs(dataSetList) do
		total = total + value - mean
	end
	return total / #dataSetList
end

local function calculateStandardDeviation(dataSetList)
	local mean = calculateMean(dataSetList)
	local total = 0
	for _, value in ipairs(dataSetList) do
		total = total + (value - mean)*(value - mean)
	end
	return math.sqrt(total / (#dataSetList-1))
end
