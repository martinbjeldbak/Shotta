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


---@alias triggerId string Key use to define the event that Screenshotter can listen to. Unique.
---@class Trigger
---@field eventName string
---@field triggerFunc (fun(): nil)|nil
---@type { [triggerId]: Trigger }
local BlizzardEventTriggers = {
  login = {
    eventName = "PLAYER_LOGIN",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  channelChat = {
    eventName = "CHAT_MSG_CHANNEL",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  levelUp = {
    eventName = "PLAYER_LEVEL_UP",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,

    triggerFunc = function()
      C_Timer.After(0.5, function()
        TakeScreenshot()
      end)
    end
  },
  mailboxOpened = {
    eventName = "MAIL_SHOW",

    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  readyCheck = {
    eventName = "READY_CHECK",

    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  zoneChanged = {
    eventName = "ZONE_CHANGED",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  zoneChangedNewArea = {
    eventName = "ZONE_CHANGED_NEW_AREA",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  movementStart = {
    eventName = "PLAYER_STARTED_MOVING",

    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  auctionWindowShow = {
    eventName = "AUCTION_HOUSE_SHOW",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  groupFormed = {
    eventName = "GROUP_FORMED",
    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  tradeAccepted = {
    eventName = "TRADE_ACCEPT_UPDATE",

    register = function(self, frame)
      frame:RegisterEvent(self.eventName)
    end,
    unregister = function(self, frame)
      frame:UnregisterEvent(self.eventName)
    end,
  },
  every5Minutes = {
    on = true,
    register = function(self)
      self.on = true
      everyXMinute(5, function()
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
      ns.PrintToChat(format("Got event \"%s\", taking screenshot!", event))

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
  local event = BlizzardEventTriggers[trigger]

  if enabled then
    event:register(self)
  else
    event:unregister(self)
  end

  -- if event.register == nil then
  --   local eventName = AllTriggers[trigger].eventName

  --   if enabled then
  --     self:RegisterEvent(eventName)
  --   else
  --     self:UnregisterEvent(eventName)
  --   end
  -- else
  --   if enabled then
  --     event:register()
  --   else
  --     event:unregister()
  --   end
  -- end
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

  ns.InitializeOptions(self, db, BlizzardEventTriggers, screenshotFrame,
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

  ns.PrintToChat(version .. " loaded")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
