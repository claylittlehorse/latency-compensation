local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local MODULE_POINTER_TAG = "IMPORT__ModulePointer"

local NONE_RESULT = "__IMPORT_NO_RESULT"

local absoluteRoot = game
local currentRoot = absoluteRoot
local aliasesMap
local reloadDirectories
local maxWaitTime = 0.25
local autoReload = false
local delimiter = "/"
local relativeChar = "%." -- String pattern for '.'

local pathCache = {}
local changedConnections = {}

local changeDetectedBindable = Instance.new("BindableEvent")

local Import = {}

Import.changeDetected = changeDetectedBindable.Event

function Import.setConfig(configDictionary)
	local oldAbsoluteRoot = absoluteRoot
	absoluteRoot = configDictionary.absoluteRoot or absoluteRoot
	-- Only update the currentRoot if it's still the same as the absoluteRoot
	currentRoot = (currentRoot == oldAbsoluteRoot and absoluteRoot) or currentRoot

	aliasesMap = configDictionary.aliasesMap or aliasesMap
	maxWaitTime = configDictionary.maxWaitTime or maxWaitTime
	autoReload = configDictionary.autoReload or autoReload
	delimiter = configDictionary.delimiter or delimiter
	relativeChar = configDictionary.relativeChar or relativeChar

	local oldReloadDirectories = reloadDirectories
	reloadDirectories = configDictionary.reloadDirectories or reloadDirectories

	-- If the reload directories were updated and we were previously listening,
	-- we'll disconnect those current listeners and set up the new listeners
	-- through setChangeListenersActive(true)
	if reloadDirectories ~= oldReloadDirectories and #changedConnections > 0 then
		Import:setChangeListenersActive(true)
	end
end

function Import.clearCache()
	pathCache = {}
end

---|| Path helpers ||---

-- Returns the first directory from the path and the remaining path as separate
-- strings.
local function splitFirstDirectoryFromPath(path)
	local delimiterPosition = string.find(path, delimiter)

	local directoryString = delimiterPosition and string.sub(path, 1, delimiterPosition - 1) or path
	local restOfPath = delimiterPosition and string.sub(path, delimiterPosition + 1)

	return directoryString, restOfPath
end

-- Used to find the full path (for caching) when using ../ or ./ as the first directory in
-- paths.
local function getPathToInstanceRecursive(path, instance)
	if instance == currentRoot or instance == absoluteRoot then
		-- TODO: Make this error sound like it wasn't written while I was tipsy at 1:42 AM
		error("you cant use. that many dots. What the fuck just chill")
	end

	local newPath = path and (instance.Name..delimiter..path) or instance.Name
	local parent = instance.Parent

	-- If the parent is either of our roots, we'll return the path, since we
	-- dont want our datamodel root included in the path. If this isn't the
	-- case, and the parent's parent exists, we need to keep creating our path.

	-- If neither of these cases are true, that means our path doesn't point to
	-- a descendant of the real datamodel OR the fake datamodel, so we need to
	-- return our parent to use as the special root when trying to find our
	-- asset.
	if parent == currentRoot or parent == absoluteRoot then
		return newPath
	elseif parent and parent.Parent then
		return getPathToInstanceRecursive(newPath, instance.Parent)
	else
		return newPath, parent
	end
end

-- Returns the full path from a shortened path using aliases, ../, or ./
local function getFullPath(path)
	local firstDirectory, restOfPath = splitFirstDirectoryFromPath(path)

	-- If first directory indicates a relative instance, find that instance
	local match = firstDirectory:match("^"..relativeChar.."+$")
	if match then
		-- Module calling the 'import' function
		local moduleCalling = getfenv(4)["script"]

		local instance
		for _ in match:gmatch(relativeChar) do -- Iterates over every individual instance of relativeChar
			-- If we're trying to get the parent of a parentless instance, throw
			-- an error so this can be more easily noticed and resolved
			if instance and not instance.Parent then
				-- TODO: We shoud actually check instance.Parent.Parent here
				-- so we can remove the check in getPathToInstanceRecursive on
				-- line 66.
				error("Instance '"..instance.Name.."' does not have a parent! (use one less '"..relativeChar.."')")
			end
			-- If instance is already defined, we want it's parent. Otherwise,
			-- we're on the first iteration, so we'll set instance to the module
			-- calling the 'import' function
			instance = (instance and instance.Parent) or moduleCalling
		end

		-- Once we've found our instance, we want to return the direct path to it.
		return getPathToInstanceRecursive(restOfPath, instance)
	end

	if not aliasesMap then return path end

	local alias = aliasesMap[firstDirectory]
	if alias then
		return aliasesMap[firstDirectory] .. ((restOfPath and "/"..restOfPath) or "")
	else
		return path
	end
end

-- Finds the first instance in the path from the specified rootParent
local function waitForFirstInstanceInPath(rootParent, path)
	local firstDirectory, restOfPath = splitFirstDirectoryFromPath(path)
	if firstDirectory == "." and not restOfPath then -- == relativeChar and ... then
		return rootParent
	end
	if maxWaitTime == 0 then
		local instance = rootParent:FindFirstChild(firstDirectory)
		return instance, restOfPath
	end
	local instance = rootParent:WaitForChild(firstDirectory, maxWaitTime)
	return instance, restOfPath
end

-- Recursively wait for the
local function findInstanceFromPathRecursive(parent, path, shouldReturnInstance)
	-- Find the current child we're looking for
	local childInstance, restOfPath = waitForFirstInstanceInPath(parent, path)

	-- If we don't find the child, return empty handed. If we're not looking in
	-- the real datamodel, we may be able to try again. Otherwise, we can keep
	-- recursing. We return the name of the missing child in case we need to
	-- report it in an error.
	if not childInstance then
		local childName = splitFirstDirectoryFromPath(path)
		return NONE_RESULT, childName
	end

	-- If theres no more path to parse, that means we've found the last instance
	-- in the path, so we can return it.
	if not restOfPath then
		-- If the child is a ModuleScript, we can easily return it. If the child
		-- is an ObjectValue, and is tagged with our "fake module" tag, it's in
		-- our fake, reloaded datamodel and is pointing to its counterpart in
		-- the real datamodel.
		-- If the child is neither of these, we just return it.
		if shouldReturnInstance then
			return childInstance
		elseif childInstance:IsA("ModuleScript") then
			return require(childInstance)
		elseif childInstance:IsA("ObjectValue") and CollectionService:HasTag(childInstance, MODULE_POINTER_TAG) then
			return require(childInstance.Value)
		else
			return childInstance
		end
	end

	-- If there's still more path
	return findInstanceFromPathRecursive(childInstance, restOfPath, shouldReturnInstance)
end

---|| Import ||---

-- Returns the result based on exports provided
local function getResult(result, exportNames)
	if exportNames then
		local exports = {}

		for _, name in ipairs(exportNames) do
			local export = result[name]
			assert(export, ("no export named %s"):format(name))
			table.insert(exports, export)
		end

		return unpack(exports)
	else
		return result
	end
end

-- Returns an instance or required module from a given path
local function import(path, exports, rootOverride)
	local currentRoot = currentRoot
	local absoluteRoot = absoluteRoot
	if rootOverride then
		currentRoot = rootOverride
		absoluteRoot = rootOverride
	end
	-- TODO: Figure out how to get the literal value from this (turn literal
	-- into pattern rather than vice-versa)
	assert(path ~= ".", "come on dude we both know that isnt gonna work")

	local fullPath, specialRoot = getFullPath(path)

	-- Specialroot is only returned if using a relative import path in an
	-- instance which is not a descendant of the current/absolute root
	if specialRoot then
		local _, restOfPath = splitFirstDirectoryFromPath(path)

		if not restOfPath then
			return specialRoot
		end

		local result, missingChildName = findInstanceFromPathRecursive(specialRoot, fullPath)

		local errorString = "Could not find instance '"..(missingChildName or "").."' from path '"
			..path.."' and special root'"..specialRoot.."'"
		assert(result, errorString)

		return getResult(result, exports)
	end

	local cachedResult = pathCache[fullPath]
	if cachedResult then
		return getResult(cachedResult, exports)
	end

	-- Get the root of our path, which is the first directory. If we've reloaded
	-- and are using the virtual datamodel, our root might not exist, so we'll
	-- check again in the absoluteRoot.
	local root, restOfPath = waitForFirstInstanceInPath(currentRoot, fullPath)
	if root == NONE_RESULT and currentRoot ~= absoluteRoot then
		root, restOfPath = waitForFirstInstanceInPath(absoluteRoot, fullPath)
	end
	-- If we don't find the root, we'll error to bring attention to any possible
	-- mistakes in the path provided.
	assert(root, "Root directory undefined for '"..path.."'")

	-- If the path is only a top level directory, there won't be a restOfPath,
	-- so we just return the root.
	if not restOfPath then
		-- TODO: Handle edge case where root is a modulescript
		-- TODO: Cache this?
		return root
	end

	-- If we get the module, we can require and try to cache it. If we don't get
	-- our module, we can try looking again with absoluteRoot as our absolute root.
	local result, missingChildName = findInstanceFromPathRecursive(root, restOfPath)
	if result == NONE_RESULT and currentRoot ~= absoluteRoot then
		root = waitForFirstInstanceInPath(absoluteRoot, fullPath)
		result, missingChildName = findInstanceFromPathRecursive(root, restOfPath)
	end
	-- If we don't find the instance, we'll error to bring attention to any
	-- mistakes.
	assert(result ~= NONE_RESULT, "Could not find instance '"..(missingChildName or "").."' from path '"..fullPath.."'")

	pathCache[fullPath] = result

	return getResult(result, exports)
end

---|| Reloading ||---

-- Recursive function to create a fake datamodel
local function cloneHierarchyRecursive(path, fakeParent, realParent)
	local childName, restOfPath = splitFirstDirectoryFromPath(path)

	-- When cloning the datamodel, we need to be selective about what instances,
	-- specifically modules, are copied. Some 'reloaded' modules that are copied
	-- into our fake datamodel will be dependent on other modules remaining
	-- persistent in the real datamodel, so we can't carelessly copy every
	-- instance. To ensure that we don't "over copy", we only copy the * very
	-- last * instance in the path.

	-- If we still have path, we won't copy the instance. If this instance is a
	-- modulescript though, we'll use an ObjectValue that points to said
	-- modulescript, in case it needs to be imported from one of it's
	-- descendants
	-- Otherwise, we'll clone the instance, add it to the fake datamodel,
	-- and stop recursing.
	if restOfPath then
		-- Get the real child. If we don't find it, we'll error.
		local realChild = realParent:findFirstChild(childName)
		assert(realChild, "Reload error: Child '"..childName.."' does not exist for instance "..tostring(realParent))

		-- Try to find the fake child, in case it's already been created. If the
		-- child we're trying to access doesn't yet exist, we'll create a folder
		-- to represent it in the fake datamodel.
		local fakeChild = fakeParent:findFirstChild(childName)

		if not fakeChild then
			if realChild:IsA("ModuleScript") then
				fakeChild = Instance.new("ObjectValue")
				fakeChild.Value = realChild
				CollectionService:AddTag(fakeChild, MODULE_POINTER_TAG)
			else
				fakeChild = Instance.new("Folder")
			end

			fakeChild.Name = childName
			fakeChild.Parent = fakeParent
		end

		-- Continue building the fake hierarchy.
		cloneHierarchyRecursive(restOfPath, fakeChild, realChild)
	elseif childName == "." then --relativeChar then
		local fakeChildren = realParent:Clone():GetChildren()
		for _, child in pairs(fakeChildren) do
			child.Parent = fakeParent
		end
	else
		local realChild = realParent:findFirstChild(childName)
		assert(realChild, "Child '"..childName.."' does not exist for instance "..tostring(realParent))

		local fakeChild = realChild:Clone()
		fakeChild.Parent = fakeParent
	end
end

function Import.reloadHierarchy()
	assert(reloadDirectories, "Cannot reload with reload directories undefined!")

	-- If we already have a fake datamodel floating around, clean it up.
	if currentRoot ~= absoluteRoot then
		currentRoot:Destroy()
	end

	-- Clear our cache so that we properly require reloaded modules
	pathCache = {}

	-- Create a new fake datamodel, and populate it based on the reload
	-- directories defined.
	currentRoot = Instance.new("Folder")
	for _, path in ipairs(reloadDirectories) do
		local firstDirectory = splitFirstDirectoryFromPath(path)
		local match = firstDirectory:match("^"..relativeChar.."+$")
		assert(not match, "Reload directories can not use relative position thingy, whatever")

		local fullPath = getFullPath(path)
		cloneHierarchyRecursive(fullPath, currentRoot, absoluteRoot)
	end

	print("Import reloaded")
end

---|| Change detection ||---

local updatingNextFrame = false
local function updateNextFrame()
	if updatingNextFrame then return end
	updatingNextFrame = true
	coroutine.resume(coroutine.create(function()
		RunService.RenderStepped:Wait()

		if autoReload then
			Import.reloadHierarchy()
		end
		changeDetectedBindable:Fire()

		updatingNextFrame = false
	end))
end

local function listenForChangesRecursive(object)
	local changedConnection = object.Changed:Connect(updateNextFrame)

    for _, child in pairs(object:GetChildren()) do
        listenForChangesRecursive(child)
	end

	changedConnections[#changedConnections+1] = changedConnection
end

local function listenForDescendantsAdded(object)
	local descendantAddedConnection = object.DescendantAdded:Connect(function(descendant)
		local changedConnection = descendant.Changed:Connect(updateNextFrame)
		changedConnections[#changedConnections+1] = changedConnection
        updateNextFrame()
	end)

	changedConnections[#changedConnections+1] = descendantAddedConnection
end

function Import.setChangeListenersActive(active)
	for _, connection in ipairs(changedConnections) do
		connection:Disconnect()
	end
	changedConnections = {}

	if active then
		assert(reloadDirectories, "reloadDirectories undefined")

		for _, path in ipairs(reloadDirectories) do
			local firstDirectory = splitFirstDirectoryFromPath(path)
			local match = firstDirectory:match("^"..relativeChar.."+$")
			assert(not match, "Reload directories can not use relative position thingy, whatever")

			local fullPath = getFullPath(path)
			local obj, missing = findInstanceFromPathRecursive(absoluteRoot, fullPath, true)
			assert(obj ~= NONE_RESULT, "Could not find instance '"..(missing or "").."' from path '"..path.."'")
			listenForChangesRecursive(obj)
			listenForDescendantsAdded(obj)
		end
	end
end

-- Metatable shenanigans which allows calling import "path" as well as import.reloadHierarchy()
return setmetatable(Import, {
	__call = function(_, ...)
		return import(...)
	end
})
