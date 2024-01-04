local _, ns = ...

Screenshotter = {}
Screenshotter.ADDON_NAME = "Screenshotter"
Screenshotter.VERSION = "@project-version@"
Screenshotter.COLOR = "245DC6FF"

---@class Event
---@field name string Event name as defiend in https://wowpedia.fandom.com/wiki/Category:API_events
---@field enabled boolean Whether or not the user has enabled this event
---@field checkboxText string Value displayed in AddOn options checkbox for togglign

---@alias friendlyEventName string Key use to define the event that Screenshotter can listen to. Unique.

---@class ScreenshotterDatabase
---@field screenshottableEvents { [friendlyEventName]: Event }

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
    readyCheck = {
      name = "READY_CHECK",
      enabled = false,
      checkboxText = "On ready check"
    }
  }
}

local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(_, event)
  ns.PrintToChat(format("Got event %s, taking screenshot!", event))

  Screenshot()
end)

function screenshotFrame:registerUnregisterEvent(event)
  if event.enabled then
    self:RegisterEvent(event.name)
    ns.PrintToChat(format("Will screenshot for event %s", event.name))
  else
    self:UnregisterEvent(event.name)
  end
end

local function EventHandler(self, event, addOnName)
  if addOnName ~= Screenshotter.ADDON_NAME then
    return
  end

  if event ~= "ADDON_LOADED" then
    ns.PrintToChat(format("Got unknown event %s", event))
    return
  end

  local db = ns.FetchOrCreateDatabase(DB_DEFAULTS)

  ns.InitializeOptions(self, db, screenshotFrame, Screenshotter.ADDON_NAME, Screenshotter.VERSION)

  --- Persist DB as SavedVariable since we've been using it as a local
  ScreenshotterDB = db

  for _, e in pairs(db.screenshottableEvents) do
    screenshotFrame:registerUnregisterEvent(e)
  end

  self:UnregisterEvent(event)

  ns.PrintToChat(Screenshotter.VERSION .. " loaded")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
