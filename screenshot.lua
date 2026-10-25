-- Taking screenshots: the helpers that wrap the Blizzard API, and the timers that defer a screenshot
-- until the client has had a frame or two to render.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta

-- luacheck: push ignore C_Timer
---Makes client take a screenshot. Simply wraps the WoW global method.
---@param text? string Optional text to log
local function TakeScreenshot(text)
  if text ~= nil then
    Shotta:Print(text)
  end

  Screenshot()
end
-- luacheck: pop

function Shotta:TimedScreenshot()
  --@alpha@
  self:Print 'Got timed event, taking screenshot'
  --@end-alpha@
  TakeScreenshot()
end

---@param text? string Optional text to log
local function TakeUILessScreenshot(text)
  UIParent:Hide()

  TakeScreenshot(text)

  C_Timer.After(0.01, function()
    UIParent:Show()
  end)
end

---Converts minutes to seconds
---@param minutes number how many minutes should be converted to seconds
---@return number minutes in seconds
local function minutesToSeconds(minutes)
  return minutes * 60
end

---@param enabled boolean
---@param minutes minutes
function Shotta:conditionallyEnableTimer(enabled, minutes)
  local timer = self.timerEvents[minutes]
  if timer then
    self:CancelTimer(timer)
    self.timerEvents[minutes] = nil
  end

  if enabled then
    --@alpha@
    self:Print(format('Enabling %s minute timer', minutes))
    --@end-alpha@
    self.timerEvents[minutes] = self:ScheduleRepeatingTimer('TimedScreenshot', minutesToSeconds(minutes))
  else
    --@alpha@
    self:Print(format('Cancelling %s minute timer', minutes))
    --@end-alpha@
  end
end

---Wipes the stored timer state; the actual timers are cancelled by the caller
function Shotta:ResetTimers()
  self.timerEvents = {}
end

function Shotta:OnEnableTimers()
  local events = self.db.profile.events
  if not (events and events.timer) then
    return
  end

  for min, enabled in pairs(events.timer) do
    if enabled then
      self:conditionallyEnableTimer(true, min)
    end
  end
end

ns.TakeScreenshot = TakeScreenshot
ns.TakeUILessScreenshot = TakeUILessScreenshot
