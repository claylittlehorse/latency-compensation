local import = require(game.ReplicatedStorage.Lib.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"

local Graph = import "../Graph"

local function round(number, increment)
	return math.floor(number/increment + 0.5) * increment
end

local function PingGraph(props)
	local ping = props.ping

	if not ping.pings[1] then
		return
	end

	local minTime = round(ping.pings[1].X, 0.01)
	local maxTime = round(ping.pings[#ping.pings].X, 0.01)

	return Roact.createElement(Graph, {
		size = UDim2.new(0, 600, 0, 400),
		anchorPoint = Vector2.new(0.5, 0.5),
		position = UDim2.new(0.5, 0, 0.5, 0),

		divisions = Vector2.new(20, 20),
		maxValue = Vector2.new(maxTime, 100),
		minValue = Vector2.new(minTime, 0),

		valueGroups = {
			-- pingValues = {
			-- 	values = ping.pings,
			-- 	color = Color3.fromRGB(248, 149, 36)
			-- },
			sendPingValues = {
				values = ping.sendPings,
				color = Color3.fromRGB(60, 211, 0)
			},
			recievePingValues = {
				values = ping.recievePings,
				color = Color3.fromRGB(255, 62, 36)
			}
		}
	})

end

return RoactRodux.connect(
	function(state)
		return {
			ping = state.Ping
		}
	end
)(PingGraph)
