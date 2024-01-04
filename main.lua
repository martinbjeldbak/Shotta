local _, ns = ...

Screenshotter = {}
Screenshotter.ADDON_NAME = "Screenshotter"
Screenshotter.VERSION = "@project-version@"
Screenshotter.COLOR = "245DC6FF"

---@class Event
---@field enabled boolean Whether or not the user has enabled this event

---@alias friendlyEventName string Key use to define the event that Screenshotter can listen to. Unique.

---@class ScreenshotterDatabase
---@field screenshottableEvents { [friendlyEventName]: Event }


local TriggerHandlers = {
  login = { eventName = "PLAYER_LOGIN", },
  channelChat = { eventName = "CHAT_MSG_CHANNEL", },
  levelUp = {
    eventName = "PLAYER_LEVEL_UP",
    triggerFunc = function()
      C_Timer.After(0.5, function()
        Screenshot()
      end)
    end
  },
  readyCheck = { eventName = "READY_CHECK", },
  zoneChanged = { eventName = "ZONE_CHANGED_NEW_AREA", },
  movementStart = {
    eventName = "PLAYER_STARTED_MOVING",
  }
}
ns.TriggerHandlers = TriggerHandlers

---@type ScreenshotterDatabase
local DB_DEFAULTS = {
  screenshottableEvents = {
    login = {
      enabled = true,
    },
    channelChat = {
      enabled = false,
    },
    movementStart = {
      enabled = false,
    },
    levelUp = {
      enabled = true,
    },
    zoneChanged = {
      enabled = false,
    },
    readyCheck = {
      enabled = false,
    },
  }
}

local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(_, event)
  ns.PrintToChat(format("Got event %s, taking screenshot!", event))

  for _, details in pairs(TriggerHandlers) do
    if details.eventName == event then
      if details.triggerFunc == nil then
        Screenshot()
      else
        details.triggerFunc()
      end
    end
  end
end)

---Conditionally register or unregister event based on enabled
---@param trigger string
---@param enabled boolean
function screenshotFrame:registerUnregisterEvent(trigger, enabled)
  local eventName = ns.TriggerHandlers[trigger].eventName

  if enabled then
    self:RegisterEvent(eventName)
  else
    self:UnregisterEvent(eventName)
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

  for trigger, e in pairs(db.screenshottableEvents) do
    screenshotFrame:registerUnregisterEvent(trigger, e.enabled)
  end

  self:UnregisterEvent(event)

  ns.PrintToChat(Screenshotter.VERSION .. " loaded")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
