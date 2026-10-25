-- Blizzard event handlers. A handler method is named exactly after the event, and
-- conditionallyRegisterBlizzardEvent looks it up on the addon; events without a handler take a plain
-- screenshot through DefaultBlizzardHandler.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta

local TakeScreenshot = ns.TakeScreenshot

---@param enabled boolean
---@param blizzardEvent string
function Shotta:conditionallyRegisterBlizzardEvent(enabled, blizzardEvent)
  if enabled then
    --@alpha@
    self:Print(format('Enabling event: %s', blizzardEvent))
    --@end-alpha@
    local handler = type(self[blizzardEvent]) == 'function' and blizzardEvent or 'DefaultBlizzardHandler'
    self:RegisterEvent(blizzardEvent, handler)
  else
    --@alpha@
    self:Print(format('Disabling event: %s', blizzardEvent))
    --@end-alpha@
    self:UnregisterEvent(blizzardEvent)
  end
end

function Shotta:DefaultBlizzardHandler()
  --@alpha@
  self:Print 'Default handler: got enabled Blizzard event, taking screenshot.'
  --@end-alpha@
  TakeScreenshot()
end

function Shotta:PLAYER_STARTED_MOVING()
  --@alpha@
  self:Print 'Got PLAYER_STARTED_MOVING (debug event, not taking a screenshot)'
  --@end-alpha@
end

function Shotta:PLAYER_LOGIN()
  --@alpha@
  self:Print 'Got event player login: taking screenshot'
  --@end-alpha@
  self:ScheduleTimer('TimedScreenshot', 5)
end

function Shotta:ACHIEVEMENT_EARNED()
  self:ScheduleTimer('TimedScreenshot', 0.5)
end

function Shotta:CHAT_MSG_TEXT_EMOTE()
  self:ScheduleTimer('TimedScreenshot', 0.5)
end

function Shotta:TRADE_ACCEPT_UPDATE(_, playerAccepted)
  if playerAccepted == 1 then
    --@alpha@
    self:Print 'Trade accepted, taking screenshot'
    --@end-alpha@
    TakeScreenshot()
  end
end

function Shotta:PLAYER_LEVEL_UP()
  self:ScheduleTimer('TimedScreenshot', 0.5)
end
