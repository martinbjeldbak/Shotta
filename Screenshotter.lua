local _, ns = ...

local EventFrame = CreateFrame("Frame")
ADDON_NAME = "Screenshotter"
VERSION = "0.1.0"
COLOR = "245DC6FF"


---@class Event
---@field name string
---@field enabled boolean
---@field checkboxText string

---@class ScreenshotterDatabase
---@field screenshottableEvents { [string]: Event }

---@type ScreenshotterDatabase
local DB_DEFAULTS = {
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
    },
    levelUp = {
      name = "PLAYER_LEVEL_UP",
      enabled = true,
      checkboxText = "On level up"
    },
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

local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(self, event, ...)
  printToChat(format("Got event %s, taking screenshot", event))

  Screenshot()
end)

function screenshotFrame:registerUnregisterEvent(event)
  if event.enabled then
    self:RegisterEvent(event.name)
    printToChat(format("Will screenshot for event %s", event.name))
  else
    self:UnregisterEvent(event.name)
  end
end

local function EventHandler(self, event, addOnName)
  if addOnName ~= ADDON_NAME then
    return
  end

  if event ~= "ADDON_LOADED" then
    printToChat(format("Got unknown event %s", event))
    return
  end

  local db = fetchOrCreateDatabase(DB_DEFAULTS)

  ns.InitializeOptions(self, db, screenshotFrame, ADDON_NAME, VERSION)

  for _, e in pairs(db.screenshottableEvents) do
    screenshotFrame:registerUnregisterEvent(e)
  end

  --- Persist DB as SavedVariable since we've been using it as a local
  ScreenshotterDB = db

  printToChat("v" .. VERSION .. " loaded")
end

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
