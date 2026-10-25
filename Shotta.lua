-- Addon defaults and lifecycle. Loaded last, so every other file has already added its methods to the
-- addon before AceAddon starts calling them from OnInitialize and OnEnable.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta

local defaults = {
  ---@type table<string, table>
  profile = {
    ---@type ShottaMinimap
    minimap = {
      hide = false,
    },
    ---@type ShottaEvents
    events = {
      ['**'] = false,
      -- Derive which events are on for new profiles from the single event table in constants.lua
      blizzard = {},
      timer = {},
    },
    ---@type ShottaFirstKillOptions
    firstKill = {
      restrict = false,
    },
  },
  ---@type ShottaChar
  char = {
    ---@type ShottaBossKills
    bossKills = {},
  },
}

for event, definition in pairs(ns.EVENTS) do
  if definition.default then
    defaults.profile.events.blizzard[event] = true
  end
end

function Shotta:OnInitialize()
  self.db = LibStub('AceDB-3.0'):New('ShottaDBv2', defaults)
  self:ResetTimers()

  self:RegisterMinimapIcon()
  self:RegisterOptions()

  self:Print(ns.VERSION .. ' loaded!')
end

function Shotta:OnEnable()
  -- Profiles can lack these tables (see the note on BossKillEnabled). OnEnable throwing would abort every
  -- registration below it, so read defensively rather than assuming AceDB merged the defaults in.
  local events = self.db.profile.events
  if events and events.blizzard then
    for event, enabled in pairs(events.blizzard) do
      if enabled then
        self:conditionallyRegisterBlizzardEvent(true, event)
      end
    end
  end

  self:OnEnableTimers()
end

function Shotta:OnDisable()
  self:UnregisterAllEvents()
  self:CancelAllTimers()
  self:ResetTimers()
end
