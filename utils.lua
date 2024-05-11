local _, ns = ...

--- Print formatted message to chat
---@param message string
---@return nil
local function printToChat(message)
	print(format("%s: %s", WrapTextInColorCode(Shotta.ADDON_NAME, Shotta.COLOR), message))
end
ns.PrintToChat = printToChat

---@param message string
---@return nil
local function debug(message)
	--@debug@
	ns.PrintToChat(message)
	--@end-debug@
end
ns.Debug = debug

---Support improved debugging with DevTool, see https://github.com/brittyazel/DevTool?tab=readme-ov-file#example-of-a-very-common-use-case
---@param data any
---@param strName string
function AddToDevToolInspector(data, strName)
	--@debug--
	if DevTool then
		DevTool:AddData(data, strName)
	end
	--@end-debug--
end
ns.AddToDevToolInspector = AddToDevToolInspector

--- Creates or gets the SavedVariable for this addon
---@param defaults any
---@return ShottaDatabase
local function fetchOrCreateDatabase(defaults)
	local db = ShottaDB or {}

	for k, v in pairs(defaults) do
		if db[k] == nil then
			db[k] = v
		end
	end

	-- Table keys may already exist so let's make sure we pick up any new events
	for k, v in pairs(defaults.screenshottableEvents) do
		if db.screenshottableEvents[k] == nil then
			db.screenshottableEvents[k] = v
		end
	end

	for k, v in pairs(defaults.profile) do
		if db.profile[k] == nil then
			db.profile[k] = v
		end
	end

	for k, v in pairs(defaults.profile.minimap) do
		if db.profile.minimap[k] == nil then
			db.profile.minimap[k] = v
		end
	end

	AddToDevToolInspector(db, "fetchedDatabase")

	return db
end

ns.FetchOrCreateDatabase = fetchOrCreateDatabase
