local _, ns = ...

--- Print formatted message to chat
---@param message string
---@return nil
local function printToChat(message)
  print(format("%s: %s", WrapTextInColorCode(Screenshotter.ADDON_NAME, Screenshotter.COLOR), message))
end
ns.PrintToChat = printToChat

local function debug(message)
  if ns.DEBUG then
    ns.PrintToChat(message)
  end
end
ns.Debug = debug

--- Creates or gets the SavedVariable for this addon
---@param defaults any
---@return ScreenshotterDatabase
local function fetchOrCreateDatabase(defaults)
  local db = ScreenshotterDB or {}

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
