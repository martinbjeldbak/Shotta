local _, ns = ...

Screenshotter = {}
Screenshotter.ADDON_NAME = "Screenshotter"
Screenshotter.VERSION = "@project-version@"
Screenshotter.COLOR = "245DC6FF"

local function TakeScreenshot(text)
  if text == nil then
    text = "Taking screenshot!"
  end

  ns.PrintToChat(text)

  Screenshot()
end

---@alias triggerId string Key use to define the event that Screenshotter can listen to. Unique.

local function tableMerge(table1, table2)
  local merged = {}

  for k, v in pairs(table1) do
    merged[k] = v
  end
  for k, v in pairs(table2) do
    merged[k] = v
  end

  return merged
end

---@class Trigger
---@field eventName string
---@field triggerFunc (fun(): nil)|nil

---@type { [triggerId]: Trigger }
local BlizzardEventTriggers = {
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
}


local function everyXSecond(seconds, callback)
  C_Timer.After(seconds, function()
    local continue = callback()
    if not continue then
      return
    end

    everyXSecond(seconds, callback)
  end)
end

local function everyXMinute(minutes, callback)
  everyXSecond(minutes * 60, callback)
end

local CustomTriggers = {
  every5Minutes = {
    on = true,
    registerFunc = function(self)
      self.on = true
      everyXMinute(5, function()
        if self.on then
          TakeScreenshot()
        end
        return self.on
      end)
    end,
    unregisterFunc = function(self)
      self.on = false
    end,
  },
  every10Minutes = {
    on = true,
    register = function(self)
      self.on = true
      everyXMinute(10, function()
        if self.on then
          TakeScreenshot()
        end
        return self.on
      end)
    end,
    unregister = function(self)
      self.on = false
    end,
  },
}


local AllTriggers = tableMerge(BlizzardEventTriggers, CustomTriggers)

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
  for _, details in pairs(BlizzardEventTriggers) do
    if event == details.eventName then
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
  local event = AllTriggers[trigger]

  if event.register == nil then
    local eventName = AllTriggers[trigger].eventName

    if enabled then
      self:RegisterEvent(eventName)
    else
      self:UnregisterEvent(eventName)
    end
  else
    if enabled then
      event:register()
    else
      event:unregister()
    end
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

  local version = Screenshotter.VERSION
  if version == "@project-version@" then
    version = "dev"
  end

  ns.InitializeOptions(self, db, AllTriggers, screenshotFrame,
    Screenshotter.ADDON_NAME, version)

  --- Persist DB as SavedVariable since we've been using it as a local
  ScreenshotterDB = db

  for trigger, _ in pairs(BlizzardEventTriggers) do
    local enabled = false

    if db.screenshottableEvents[trigger] then
      ---@type boolean enabled should always be there after this if check
      enabled = db.screenshottableEvents[trigger].enabled
    end

    screenshotFrame:registerUnregisterEvent(trigger, enabled)
  end

  self:UnregisterEvent(event)

  for trigger, v in pairs(CustomTriggers) do
    local enabled = false

    if db.screenshottableEvents[trigger] then
      ---@type boolean enabled should always be there after this if check
      enabled = db.screenshottableEvents[trigger].enabled
    end

    if enabled then
      v:registerFunc()
    else
    end
  end

  ns.PrintToChat(version .. " loaded")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
