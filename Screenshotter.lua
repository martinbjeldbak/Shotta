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
    }
  }
} --- Creates or gets the SavedVariable for this addon

--- Print formatted message to chat
---@param message string
---@return nil
local function printToChat(message)
  print(format("%s: %s", WrapTextInColorCode(ADDON_NAME, COLOR), message))
end

--- Creates or gets the SavedVariable for this addon
----@return Database
local function fetchOrCreateDatabase(defaults)
  local db = ScreenshotterDB or {}

  for k, v in pairs(defaults) do
    if db[k] == nil then
      db[k] = v
    end
  end

  -- for k, v in pairs(defaults.screenshottableEvents) do
  --   if db.screenshottableEvents[k] == nil then
  --     db.screenshottableEvents[k] = v
  --   end
  -- end

  return db
end

local function TakeScreenshot(self, event, addonName)
  printToChat(format("Got event %s, taking screenshot", event))
  Screenshot()
end
local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", TakeScreenshot)


local function EventHandler(self, event, addOnName)
  if addOnName ~= ADDON_NAME then
    return nil
  end

  if event == "ADDON_LOADED" then
    local db = fetchOrCreateDatabase(DB_DEFAULTS)

    ns.InitializeOptions(self, db, ADDON_NAME, VERSION)
    for _, e in pairs(db.screenshottableEvents) do

      if e.enabled then
        printToChat(format("Should screenshot for event %s", e.name))
        screenshotFrame:RegisterEvent(e.name)
      end
    end
    ScreenshotterDB = db
    printToChat("v" .. VERSION .. " loaded")
  else
    printToChat(format("Got unknown event %s", event))
  end
end

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
