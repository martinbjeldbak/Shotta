local _, ns = ...

--- Print formatted message to chat
---@param message string
---@return nil
local function printToChat(message)
  print(format("%s: %s", WrapTextInColorCode(Shotta.ADDON_NAME, Shotta.COLOR), message))
end
ns.PrintToChat = printToChat

local function debug(message)
  --@debug@
  ns.PrintToChat(message)
  --@end-debug@
end
ns.Debug = debug

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

  return db
end

ns.FetchOrCreateDatabase = fetchOrCreateDatabase
