local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "_NETWORK"

local REMOTE_STORAGE = ReplicatedStorage:FindFirstChild(FOLDER_NAME)

local CALL_ERROR_MESSAGE = "%s is a static method (call with '.', not ':')"

if not REMOTE_STORAGE and RunService:IsServer() then
	REMOTE_STORAGE = Instance.new("Folder", ReplicatedStorage)
	REMOTE_STORAGE.Name = FOLDER_NAME
end

local isClient = RunService:IsClient()
local isServer = RunService:IsServer()

local Network = {}
local eventConnections = {}

local function getRemote(eventName, isFunction)
	if isServer then
		local remoteObject = REMOTE_STORAGE:FindFirstChild(eventName)
		if not remoteObject then
			remoteObject = Network.createEvent(eventName, isFunction)
		end
		return remoteObject
	else
		local remoteObject = REMOTE_STORAGE:WaitForChild(eventName, 1)
		assert(remoteObject, "Event '"..eventName.."' is not defined")

		return remoteObject
	end
end

function Network.createEvent(eventName, isFunction)
	assert(eventName ~= Network, CALL_ERROR_MESSAGE:format("createEvent"))
	assert(isServer, "Events cannot be created on the client.")
	local remoteObject = Instance.new(isFunction and "RemoteFunction" or "RemoteEvent", REMOTE_STORAGE)
	remoteObject.Name = eventName
	return remoteObject
end

function Network.hookEvent(eventName, callback)
	assert(eventName ~= Network, CALL_ERROR_MESSAGE:format("hookEvent"))
	local remoteObject = getRemote(eventName)

	local event = isClient and remoteObject.OnClientEvent or remoteObject.OnServerEvent
	local connection = event:Connect(function(...)
		callback(...)
	end)

	eventConnections[eventName] = connection
end

function Network.unhookEvent(eventName)
	assert(eventName ~= Network, CALL_ERROR_MESSAGE:format("unhookEvent"))
	local connection = eventConnections[eventName]
	if connection then
		connection:Disconnect()
	end
end

function Network.hookFunction(functionName, callback)
	assert(functionName ~= Network, CALL_ERROR_MESSAGE:format("hookFunction"))
	local remoteObject = getRemote(functionName, true)

	local callbackKey = isClient and "OnClientInvoke" or "OnServerInvoke"
	remoteObject[callbackKey] = callback
	eventConnections[functionName] = remoteObject
end

function Network.invokeServer(functionName, ...)
	assert(isClient, "Cannot invoke server functions from server")
	assert(functionName ~= Network, CALL_ERROR_MESSAGE:format("invokeServer"))
	local remoteObject = getRemote(functionName)
	return remoteObject:InvokeServer(...)
end

function Network.invokeClient(functionName, ...)
	assert(isServer, "Cannot invoke client functions from client")
	assert(functionName ~= Network, CALL_ERROR_MESSAGE:format("invokeClient"))
	local remoteObject = getRemote(functionName)
	return remoteObject:InvokeClient(...)
end

function Network.fireServer(eventName, ...)
	assert(isClient, "Cannot fire server events from server")
	assert(eventName ~= Network, CALL_ERROR_MESSAGE:format("fireServer"))
	local remoteObject = getRemote(eventName)
	remoteObject:FireServer(...)
end

function Network.fireClient(eventName, client, ...)
	assert(isServer, "Cannot fire client events from client")
	assert(eventName ~= Network, CALL_ERROR_MESSAGE:format("fireClient"))
	local remoteObject = getRemote(eventName)
	remoteObject:FireClient(client, ...)
end

function Network.fireAllClients(eventName, ...)
	assert(eventName ~= Network, CALL_ERROR_MESSAGE:format("fireAllClients"))
	local remoteObject = getRemote(eventName)
	remoteObject:FireAllClients(...)
end

return Network
