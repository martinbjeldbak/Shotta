local _, ns = ...

local EventFrame = CreateFrame("Frame")
ADDON_NAME = "Screenshotter"
VERSION = "0.1.0"
COLOR = "245DC6FF"

DB_DEFAULTS = {
  screenshottableEvents = {
    login = {
      name = "PLAYER_LOGIN",
      enabled = false,
      checkboxText = "On login"
    },
    channelChat = {
      name = "CHAT_MSG_CHANNEL",
      enabled = false,
      checkboxText = "On message in channel"
    },
    movementStart = {
      name = "PLAYER_STARTED_MOVING",
      enabled = false,
      checkboxText = "On start moving"
    }
  }
} --- Creates or gets the SavedVariable for this addon

--- Print formatted message to chat
---@param message string
---@return nil
local function printToChat(message)
  print(format("%s: %s", WrapTextInColorCode(ADDON_NAME, COLOR), message))
end

ns.PrintToChat = printToChat

--- Creates or gets the SavedVariable for this addon
----@return Database
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

local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(self, event, ...)
  printToChat(format("Got event %s, taking screenshot", event))

  Screenshot()
end)

local function registerUnregisterEvent(screenshotFrame, event)
  if event.enabled then
    screenshotFrame:RegisterEvent(event.name)
    printToChat(format("Will screenshot for event %s", event.name))
  else
    screenshotFrame:UnregisterEvent(event.name)
  end
end

ns.registerUnregisterEvent = registerUnregisterEvent

local function EventHandler(self, event, addOnName)
  if addOnName ~= ADDON_NAME then
    return nil
  end

  if event == "ADDON_LOADED" then
    local db = fetchOrCreateDatabase(DB_DEFAULTS)

    ns.InitializeOptions(self, db, screenshotFrame, ADDON_NAME, VERSION)

    for _, e in pairs(db.screenshottableEvents) do
      registerUnregisterEvent(screenshotFrame, e)
    end
    ScreenshotterDB = db
    printToChat("v" .. VERSION .. " loaded")
  else
    printToChat(format("Got unknown event %s", event))
  end
end

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
