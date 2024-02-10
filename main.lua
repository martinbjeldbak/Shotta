local _, ns = ...

Shotta = {}
Shotta.ADDON_NAME = "Shotta"
Shotta.VERSION = "@project-version@"
Shotta.COLOR = "245DC6FF"

local function TakeScreenshot(text)
  if text ~= nil then
    ns.PrintToChat(text)
  end

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

local function registerEvent(self, frame)
  frame:RegisterEvent(self.eventName)
end

local function unregisterEvent(self, frame)
  frame:UnregisterEvent(self.eventName)
end

---@alias triggerId string Key use to define the event that Shotta can listen to. Unique.
---@class Trigger
---@field eventName string|nil Name of Blizzard event, or nil if custom event
---@field register (fun(self, frame): nil)
---@field unregister (fun(self, frame): nil)
---@field triggerFunc (fun(...): nil)|nil Function to excute if not to take a screenshot straight away
---@type { [triggerId]: Trigger }
local triggers = {
  login = {
    eventName = "PLAYER_LOGIN",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  channelChat = {
    eventName = "CHAT_MSG_CHANNEL",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  levelUp = {
    eventName = "PLAYER_LEVEL_UP",
    register = registerEvent,
    unregister = unregisterEvent,
    triggerFunc = function()
      C_Timer.After(0.5, function()
        TakeScreenshot()
      end)
    end
  },
  mailboxOpened = {
    eventName = "MAIL_SHOW",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  readyCheck = {
    eventName = "READY_CHECK",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  zoneChanged = {
    eventName = "ZONE_CHANGED",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  zoneChangedNewArea = {
    eventName = "ZONE_CHANGED_NEW_AREA",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  --@alpha@
  movementStart = {
    eventName = "PLAYER_STARTED_MOVING",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  --@end-alpha@
  auctionWindowShow = {
    eventName = "AUCTION_HOUSE_SHOW",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  groupFormed = {
    eventName = "GROUP_FORMED",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  tradeAccepted = {
    eventName = "TRADE_ACCEPT_UPDATE",
    register = registerEvent,
    unregister = unregisterEvent,
    triggerFunc = function(playerAccepted)
      if playerAccepted == 1 then
        TakeScreenshot()
      end
    end,
  },
  bossKill = {
    eventName = "BOSS_KILL",
    register = registerEvent,
    unregister = unregisterEvent,
  },
  encounterEnd = {
    eventName = "ENCOUNTER_END",
    register = registerEvent,
    unregister = unregisterEvent,
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

---@class ShottaDatabase
---@field screenshottableEvents { [triggerId]: Event }
local DB_DEFAULTS = {
  screenshottableEvents = {
    login = { enabled = true, },
    levelUp = { enabled = true, },
    encounterEnd = { enabled = true, },
  }
}


local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(_, event, ...)
  for id, details in pairs(triggers) do
    if event == details.eventName then
      ns.PrintToChat(format("Got event \"%s\", taking screenshot!", ns.T[format("checkboxText.%s", id)]:lower()))

      if details.triggerFunc == nil then
        TakeScreenshot()
      else
        details.triggerFunc(...)
      end
    end
  end
end)

---Conditionally register or unregister event based on enabled
---@param trigger string
---@param enabled boolean
function screenshotFrame:registerUnregisterEvent(trigger, enabled)
  local event = triggers[trigger]

  if enabled then
    event:register(self)
  else
    event:unregister(self)
  end
end

local function EventHandler(self, event, addOnName)
  if addOnName ~= Shotta.ADDON_NAME then
    return
  end

  if event ~= "ADDON_LOADED" then
    ns.PrintToChat(format("Got unsupported event %s, should only be ADDON_LOADED", event))
    return
  end

  ---@type ShottaDatabase
  local db = ns.FetchOrCreateDatabase(DB_DEFAULTS)

  local version = Shotta.VERSION
  if version == "@project-version@" then
    version = "dev"
  end

  ns.InitializeOptions(self, db, triggers, screenshotFrame,
    Shotta.ADDON_NAME, version)

  --- Persist DB as SavedVariable since we've been using it as a local
  ShottaDB = db

  for trigger, _ in pairs(triggers) do
    local enabled = false

    if db.screenshottableEvents[trigger] then
      ---@type boolean enabled should always be there after this if check
      enabled = db.screenshottableEvents[trigger].enabled
    end

    screenshotFrame:registerUnregisterEvent(trigger, enabled)
  end

  self:UnregisterEvent(event)

  ns.PrintToChat(version .. " loaded. Use /shotta or /sh to open the options menu.")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)


SLASH_SHOTTA1, SLASH_SHOTTA2 = "/shotta", "/sh"

SlashCmdList["SHOTTA"] = function()
  InterfaceOptionsFrame_OpenToCategory(Shotta.ADDON_NAME)
  -- Call this twice to ensure the correct category is selected
  InterfaceOptionsFrame_OpenToCategory(Shotta.ADDON_NAME)
  InterfaceOptionsFrame_Show()
end
