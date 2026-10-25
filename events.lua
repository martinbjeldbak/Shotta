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

---Key used to remember a boss kill in the active profile. The instance namespaces the key and keeps it
---readable; the encounter ID alone is already unique per boss.
---@param encounterID integer The journal encounter ID, which is globally unique per boss
---@param instanceName string? The map the kill happened on, also used to group the options page
---@return string
local function bossKey(encounterID, instanceName)
  return format('%s|%s', instanceName and strtrim(strlower(instanceName)) or UNKNOWN, encounterID)
end

---Reads the killed bosses for the active profile
---@return table<string, ShottaBossKill>
local function bossKillTable(self)
  local bossKills = self.db.profile.bossKills
  if type(bossKills) ~= 'table' then
    bossKills = {}
    self.db.profile.bossKills = bossKills
  end

  return bossKills
end

---Counts the bosses remembered as killed in the active profile
---@return integer
function Shotta:BossKillCount()
  return #self:BossKillEntries()
end

---The bosses remembered as killed in the active profile, most recently killed first
---@return ShottaBossKillEntry[]
function Shotta:BossKillEntries()
  local entries = {}
  for key, kill in pairs(bossKillTable(self)) do
    table.insert(entries, {
      key = key,
      encounterID = kill.encounterID,
      name = kill.name,
      instance = kill.instance,
      time = kill.time,
    })
  end

  -- Newest first, then by name so the order is stable when several kills share a timestamp
  table.sort(entries, function(a, b)
    if a.time ~= b.time then
      return a.time > b.time
    end

    return tostring(a.name) < tostring(b.name)
  end)

  return entries
end

---Marks a boss as killed in the active profile, so "first kill only" skips it from now on
---@param encounterID integer
---@param encounterName string?
---@param instanceName string?
function Shotta:RecordBossKill(encounterID, encounterName, instanceName)
  local bossKills = bossKillTable(self)
  local key = bossKey(encounterID, instanceName)

  -- Keep the first kill time if we somehow see the same boss again, since that is the one that matters
  local existing = bossKills[key]
  local killedAt = existing and existing.time or nil

  bossKills[key] = {
    encounterID = encounterID,
    name = encounterName,
    instance = instanceName,
    time = killedAt or time(),
  }

  LibStub('AceConfigRegistry-3.0'):NotifyChange 'Shotta'
end

---Forgets a single boss, so its next kill counts as a first kill again
---@param key string A key from BossKillEntries
---@return boolean forgotten Whether there was an entry to forget
function Shotta:ForgetBossKill(key)
  local bossKills = bossKillTable(self)
  if not bossKills[key] then
    return false
  end

  bossKills[key] = nil

  --@alpha@
  self:Print(format('Forgot boss kill: %s', key))
  --@end-alpha@

  LibStub('AceConfigRegistry-3.0'):NotifyChange 'Shotta'
  return true
end

---Forgets every boss killed so far, so each one counts as a first kill again
function Shotta:ResetBossKills()
  self.db.profile.bossKills = {}

  --@alpha@
  self:Print 'Cleared boss kills'
  --@end-alpha@

  LibStub('AceConfigRegistry-3.0'):NotifyChange 'Shotta'
end

---Boss kills are per character, but profiles are shared across characters, so start a clean slate
---when a different character loads this profile. Remembering the owner keeps reloads and
---logout/login intact for the same character.
function Shotta:ResetBossKillsIfStale()
  local owner = format('%s - %s', UnitName 'player', GetRealmName())
  if self.db.profile.bossKillsOwner == owner then
    return
  end

  self.db.profile.bossKillsOwner = owner
  self.db.profile.bossKills = {}
end

---The map name the player is in, used to group bosses by instance in the options page
---@return string?
local function currentInstanceName()
  if C_Map and C_Map.GetBestMapForUnit then
    local name = select(2, C_Map.GetBestMapForUnit 'player')
    if name then
      return name
    end
  end

  return GetRealZoneText()
end

---A boss kill. BOSS_KILL only fires on a kill and passes the encounter details directly, so no other event or
---lookup is needed. AceEvent passes the event name first, so the arguments are shifted by one.
---@param _event string
---@param encounterID integer
---@param encounterName string
function Shotta:BOSS_KILL(_event, encounterID, encounterName)
  --@alpha@
  self:Print(format('DEBUG BOSS_KILL id=%s name=%s', tostring(encounterID), tostring(encounterName)))
  --@end-alpha@

  if self.db.profile.firstKill.restrict and encounterID then
    local instanceName = currentInstanceName()
    local bossKills = self.db.profile.bossKills
    if type(bossKills) == 'table' and bossKills[bossKey(encounterID, instanceName)] then
      --@alpha@
      self:Print(format('First kill only: %s already killed, not taking a screenshot', tostring(encounterName)))
      --@end-alpha@
      return
    end

    self:RecordBossKill(encounterID, encounterName, instanceName)
  end

  self:DefaultBlizzardHandler()
end
