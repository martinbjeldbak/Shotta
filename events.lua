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

---Key used to remember a boss kill in the active profile
---@param encounterID integer? Journal encounter ID, when the client exposes one
---@param encounterName string? Localized boss name, used when there is no ID
---@param instanceName string? Map name the kill happened on
---@return string
local function bossKey(encounterID, encounterName, instanceName)
  local boss = encounterID or encounterName or UNKNOWN
  return format('%s %s', instanceName or UNKNOWN, boss)
end

---Marks a boss as killed in the active profile, so "first kill only" skips it from now on
---@param encounterID integer?
---@param encounterName string?
---@param instanceName string?
function Shotta:RecordBossKill(encounterID, encounterName, instanceName)
  local bossKills = self.db.profile.bossKills
  if type(bossKills) ~= 'table' then
    bossKills = {}
    self.db.profile.bossKills = bossKills
  end

  bossKills[bossKey(encounterID, encounterName, instanceName)] = time()

  LibStub('AceConfigRegistry-3.0'):NotifyChange 'Shotta'
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

---BOSS_KILL only carries a name, so look the running encounter up for its ID and instance
---@return integer? encounterID
---@return string? encounterName
---@return string? instanceName
local function currentEncounter()
  local instanceName
  if C_Map and C_Map.GetBestMapForUnit then
    instanceName = select(2, C_Map.GetBestMapForUnit 'player')
  end
  instanceName = instanceName or GetRealZoneText()

  if not C_EncounterJournal then
    return nil, nil, instanceName
  end

  local encounter = C_EncounterJournal.GetActiveEncounter()
  if not encounter then
    return nil, nil, instanceName
  end

  local info = C_EncounterJournal.GetEncounterInfoByIndex(encounter.journalEncounterID, encounter.difficultyID)
  return encounter.journalEncounterID, info and info.name, instanceName
end

function Shotta:BOSS_KILL(isKill)
  -- The encounter journal has no ID to key on in older clients, so fall back to the localized name.
  local encounterID, encounterName, instanceName = currentEncounter()

  -- Retail also fires BOSS_KILL for loot rolls that end a raid boss, which are not kills. Older clients
  -- pass no argument at all, so treat a missing flag as a kill.
  isKill = isKill ~= false

  if isKill and self.db.profile.firstKill.only then
    local bossKills = self.db.profile.bossKills
    if type(bossKills) == 'table' and bossKills[bossKey(encounterID, encounterName, instanceName)] then
      --@alpha@
      self:Print(format('First kill only: %s already killed, not taking a screenshot', encounterName or 'this boss'))
      --@end-alpha@
      return
    end

    self:RecordBossKill(encounterID, encounterName, instanceName)
  end

  self:DefaultBlizzardHandler()
end
