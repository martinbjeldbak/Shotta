local _, ns = ...

Screenshotter = {}
Screenshotter.ADDON_NAME = "Screenshotter"
Screenshotter.VERSION = "@project-version@"
Screenshotter.COLOR = "245DC6FF"

local function TakeScreenshot()
  ns.PrintToChat("Taking screenshot!")
  Screenshot()
end

---@alias triggerId string Key use to define the event that Screenshotter can listen to. Unique.

---@class Trigger
---@field eventName string|nil
---@field triggerFunc (fun(): nil)|nil

---@type { [triggerId]: Trigger }
local Triggers = {
  login = { eventName = "PLAYER_LOGIN", },
  channelChat = { eventName = "CHAT_MSG_CHANNEL", },
  levelUp = {
    eventName = "PLAYER_LEVEL_UP",
    triggerFunc = function()
      C_Timer.After(0.5, function()
        TakeScreenshot()
      end)
    end
  },
  mailboxOpened = { eventName = "MAIL_SHOW", },
  readyCheck = { eventName = "READY_CHECK", },
  zoneChanged = { eventName = "ZONE_CHANGED", },
  zoneChangedNewArea = { eventName = "ZONE_CHANGED_NEW_AREA", },
  movementStart = { eventName = "PLAYER_STARTED_MOVING", },
  auctionWindowShow = { eventName = "AUCTION_HOUSE_SHOW" },
  groupFormed = { eventName = "GROUP_FORMED" },
  tradeAccepted = { eventName = "TRADE_ACCEPT_UPDATE" },
  everyXMinute = {
    triggerFunc = function()
      C_Timer.After(10, function()
        TakeScreenshot()
      end)
    end
  },
}


---@class Event
---@field enabled boolean|nil Whether or not the user has enabled this event

---@class ScreenshotterDatabase
---@field screenshottableEvents { [triggerId]: Event }
local DB_DEFAULTS = {
  screenshottableEvents = {
    login = { enabled = true, },
    levelUp = { enabled = true, },
  }
}

local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(_, event)
  for _, details in pairs(Triggers) do
    if event == details.eventName then
      ns.PrintToChat(format("Got event %s, taking screenshot!", event))

      if details.triggerFunc == nil then
        TakeScreenshot()
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
  local eventName = Triggers[trigger].eventName

  if not eventName then
    return
  end

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
    ns.PrintToChat(format("Got unsupported event %s, should only be ADDON_LOADED", event))
    return
  end

  ---@type ScreenshotterDatabase
  local db = ns.FetchOrCreateDatabase(DB_DEFAULTS)

  ns.InitializeOptions(self, db, Triggers, screenshotFrame, Screenshotter.ADDON_NAME, Screenshotter.VERSION)

  --- Persist DB as SavedVariable since we've been using it as a local
  ScreenshotterDB = db

  for trigger, _ in pairs(Triggers) do
    local enabled = false

    if db.screenshottableEvents[trigger] then
      ---@type boolean enabled should always be there after this if check
      enabled = db.screenshottableEvents[trigger].enabled
    end


    screenshotFrame:registerUnregisterEvent(trigger, enabled)
  end

  self:UnregisterEvent(event)

  ns.PrintToChat(Screenshotter.VERSION .. " loaded")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
