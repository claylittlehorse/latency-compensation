local import = require(game.ReplicatedStorage.Lib.Import)

local HttpService = game:GetService("HttpService")

local Network = import "Network"
local PingEvents = import "Data/NetworkEvents/PingEvents"

local ServerPing = {}

function ServerPing.start()
	Network.createEvent(PingEvents.PING_CLIENT)

	Network.hookEvent(PingEvents.PING_SERVER, function(player, clientSentTime)
		local serverRecievedTime = tick()
		Network.fireClient(PingEvents.PING_CLIENT, player, serverRecievedTime, clientSentTime)
	end)

	Network.hookEvent(PingEvents.PASTE, function(_, string)
		local URL_PASTEBIN_NEW_PASTE = "https://pastebin.com/api/api_post.php"
		local dataFields = {
			api_dev_key = "2d6d23a5afcbe7802261cbe8c5b92c7f",
			api_option = "paste",
			api_paste_format = "text",
			api_paste_expire_date = "10M",
			api_paste_private = "2",

			api_paste_code = string,
		}

		local data = "" do
			for dataKey, dataVal in pairs(dataFields) do
				data = data .. ("&%s=%s"):format(
					HttpService:UrlEncode(dataKey),
					HttpService:UrlEncode(dataVal)
				)
			end
			data = data:sub(2)
		end

		local response = HttpService:PostAsync(URL_PASTEBIN_NEW_PASTE, data, Enum.HttpContentType.ApplicationUrlEncoded)
		print(response)
	end)
end

return ServerPing
