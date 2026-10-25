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
      blizzard = {
        -- enable these events by default
        PLAYER_LOGIN = true,
        PLAYER_LEVEL_UP = true,
        PLAYER_DEAD = true,
        LOOT_ITEM_ROLL_WON = true,
        BOSS_KILL = true,
      },
      timer = {},
    },
    ---@type ShottaFirstKillOptions
    firstKill = {
      -- Never seed killed bosses here: AceDB copies this table into every new profile,
      -- which would make every boss count as already killed from the start.
      restrict = false,
    },
    ---@type ShottaBossKills
    bossKills = {},
    ---@type string? Which character the bossKills table belongs to
    bossKillsOwner = nil,
  },
}

function Shotta:OnInitialize()
  self.db = LibStub('AceDB-3.0'):New('ShottaDBv2', defaults)
  self:ResetTimers()
  self:ResetBossKillsIfStale()

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
