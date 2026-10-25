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
  },
}

function Shotta:OnInitialize()
  self.db = LibStub('AceDB-3.0'):New('ShottaDBv2', defaults)
  self:ResetTimers()

  self:RegisterMinimapIcon()
  self:RegisterOptions()

  self:Print(ns.VERSION .. ' loaded!')
end

function Shotta:OnEnable()
  for event, enabled in pairs(self.db.profile.events.blizzard) do
    if enabled then
      self:conditionallyRegisterBlizzardEvent(true, event)
    end
  end

  self:OnEnableTimers()
end

function Shotta:OnDisable()
  self:UnregisterAllEvents()
  self:CancelAllTimers()
  self:ResetTimers()
end
