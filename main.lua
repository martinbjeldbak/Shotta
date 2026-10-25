local ADDON_NAME, ns = ...
---@type Shotta
local Shotta = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
ns.Shotta = Shotta

-- luacheck: push ignore VERSION
---@type string
local VERSION = '@project-version@'
--@alpha@
VERSION = 'main' -- hardcode for debuggability
--@end-alpha@
-- luacheck: pop

---@type string
local DISCORD_LINK = 'https://discord.gg/MHqGRpZxbB'
---@type string
local GITHUB_LINK = 'https://github.com/martinbjeldbak/shotta'

-- luacheck: push ignore UPDATED_TIMESTAMP
---@type number
local UPDATED_TIMESTAMP = tonumber '@project-timestamp@' or time()
--@alpha@
UPDATED_TIMESTAMP = 1792723357 -- hardcode for debuggability
--@end-alpha@
-- luacheck: pop

-- luacheck: push ignore TRANSLATE_FAIL_SILENTLY
---@type boolean
local TRANSLATE_FAIL_SILENTLY = true
--@alpha@
TRANSLATE_FAIL_SILENTLY = false
--@end-alpha@
-- luacheck: pop

local IS_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_MISTS = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
local IS_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
-- Out of the supported clients, only retail and MoP Classic have achievements.
local HAS_ACHIEVEMENTS = IS_MAINLINE or IS_MISTS

local L = LibStub('AceLocale-3.0'):GetLocale('Shotta', TRANSLATE_FAIL_SILENTLY)

function Shotta:OpenToCategory()
  Settings.OpenToCategory(self.optionsCategoryID or self.name)
end

---Uses AceLocale to translate an option
---@param info table
---@return string
local function localizedOptionName(info)
  return L['checkboxText.' .. info[#info]]
end

---Converts minutes to seconds
---@param minutes number how many minutes should be converted to seconds
---@return number minutes in seconds
local function minutesToSeconds(minutes)
  return minutes * 60
end

---Makes client take a screenshot. Simply wraps the WoW global method.
---@param text? string Optional text to log
local function TakeScreenshot(text)
  if text ~= nil then
    Shotta:Print(text)
  end

  Screenshot()
end

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

local iconOptions = LibStub('LibDataBroker-1.1'):NewDataObject('Shotta', {
  type = 'data source',
  text = 'Shotta',
  icon = 237290,
  OnClick = function()
    if IsShiftKeyDown() then
      Shotta:OpenToCategory()
    elseif IsControlKeyDown() then
      TakeScreenshot()
    else
      TakeUILessScreenshot()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip or not tooltip.AddLine then
      return
    end

    tooltip:AddLine 'Shotta'
    tooltip:AddLine ' '
    tooltip:AddLine(L['minimap.click'])
    tooltip:AddLine(L['minimap.ctrlClick'])
    tooltip:AddLine ' '
    tooltip:AddLine(L['minimap.shiftClick'])
  end,
})

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

---@return AceOptionsTable
function Shotta:BlizzardEventOption()
  return {
    name = localizedOptionName,
    type = 'toggle',
    width = 'full',
    set = function(info, val)
      local triggerName = info[#info]
      self.db.profile.events.blizzard[triggerName] = val
      self:conditionallyRegisterBlizzardEvent(val, triggerName)
    end,
    get = function(info)
      local triggerName = info[#info]
      return self.db.profile.events.blizzard[triggerName]
    end,
  }
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

---@return AceOptionsTable
function Shotta:LoadOptions()
  local config = {
    type = 'group',
    args = {
      general_options = {
        name = localizedOptionName,
        type = 'group',
        order = 0,
        inline = true,
        args = {
          hideMinimap = {
            name = localizedOptionName,
            type = 'toggle',
            set = function(_, val)
              self.db.profile.minimap.hide = val
              if val then
                LibStub('LibDBIcon-1.0'):Hide 'Shotta'
              else
                LibStub('LibDBIcon-1.0'):Show 'Shotta'
              end
            end,
            get = function(_)
              return self.db.profile.minimap.hide
            end,
          },
        },
      },
      blizzard_events = {
        name = localizedOptionName,
        type = 'group',
        order = 2,
        inline = true,
        args = {
          PLAYER_LOGIN = self:BlizzardEventOption(),
          CHAT_MSG_CHANNEL = self:BlizzardEventOption(),
          PLAYER_LEVEL_UP = self:BlizzardEventOption(),
          MAIL_SHOW = self:BlizzardEventOption(),
          READY_CHECK = self:BlizzardEventOption(),
          ZONE_CHANGED = self:BlizzardEventOption(),
          ZONE_CHANGED_NEW_AREA = self:BlizzardEventOption(),
          HEARTHSTONE_BOUND = self:BlizzardEventOption(),
          --@debug@
          PLAYER_STARTED_MOVING = self:BlizzardEventOption(),
          --@end-debug@
          AUCTION_HOUSE_SHOW = self:BlizzardEventOption(),
          GROUP_FORMED = self:BlizzardEventOption(),
          TRADE_ACCEPT_UPDATE = self:BlizzardEventOption(),
          BOSS_KILL = self:BlizzardEventOption(),
          ENCOUNTER_END = self:BlizzardEventOption(),
          QUEST_TURNED_IN = self:BlizzardEventOption(),
          LOOT_ITEM_ROLL_WON = self:BlizzardEventOption(),
          PLAYER_DEAD = self:BlizzardEventOption(),
          CHAT_MSG_TEXT_EMOTE = self:BlizzardEventOption(),
        },
      },
      timer_events = {
        name = localizedOptionName,
        type = 'group',
        inline = true,
        order = 1,
        args = {
          every_5_minutes = self:TimerEventOption(5, 0),
          every_10_minutes = self:TimerEventOption(10, 1),
          every_30_minutes = self:TimerEventOption(30, 2),
        },
      },
    },
  }
  if IS_MAINLINE then
    config.args.blizzard_events.args.MAJOR_FACTION_RENOWN_LEVEL_CHANGED = self:BlizzardEventOption()
  end

  if HAS_ACHIEVEMENTS then
    config.args.blizzard_events.args.ACHIEVEMENT_EARNED = self:BlizzardEventOption()
  end

  return config
end

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

---Computes number of days the input day is from today
---@param sourceDate string|number The iso timestamp of requested day
---@return integer number of days since sourceDate
local function daysAgo(sourceDate)
  local sourceDatetime = tonumber(sourceDate)
  if sourceDatetime == nil then
    return 0
  end

  local diffSeconds = time() - sourceDatetime
  return math.floor(diffSeconds / (24 * 60 * 60))
end

---Returns the client's install folder, as used in the screenshots path.
---@return string
local function folderName()
  if IS_MAINLINE then
    return 'retail'
  elseif IS_MISTS then
    return 'classic'
  elseif IS_TBC then
    return 'anniversary'
  elseif IS_CLASSIC_ERA then
    return 'classic_era'
  end

  return 'unknown'
end

local aboutOptions = {
  type = 'group',
  name = L['about'],
  args = {
    version = {
      name = format('Version: %s', VERSION),
      order = 0,
      type = 'description',
    },
    date = {
      name = format('Date: %s (%s days ago)', date('%x', UPDATED_TIMESTAMP), daysAgo(UPDATED_TIMESTAMP)),
      order = 1,
      type = 'description',
    },
    screenshotLocation = {
      name = format(L['saveLocationHelpText'], folderName(), folderName()),
      order = 5,
      fontSize = 'large',
      type = 'description',
    },
    discord = {
      name = format('%s (%s)', L['joinDiscord'], L['pressCtrlC']),
      type = 'input',
      order = 6,
      width = 'double',
      get = function(_)
        return DISCORD_LINK
      end,
    },
    code = {
      name = format('%s (%s)', L['gitHubLink'], L['pressCtrlC']),
      type = 'input',
      order = 7,
      width = 'double',
      get = function(_)
        return GITHUB_LINK
      end,
    },

    love = {
      name = 'For Nandar. Made with love in Melbourne, Australia',
      order = 80,
      fontSize = 'small',
      type = 'description',
    },
  },
}

---@param minutes minutes
---@param order integer
---@return AceOptionsTable
function Shotta:TimerEventOption(minutes, order)
  return {
    name = localizedOptionName,
    type = 'toggle',
    order = order,
    set = function(_, val)
      self.db.profile.events.timer[minutes] = val

      self:conditionallyEnableTimer(val, minutes)
    end,
    get = function(_)
      return self.db.profile.events.timer[minutes]
    end,
  }
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

function Shotta:OnInitialize()
  self.db = LibStub('AceDB-3.0'):New('ShottaDBv2', defaults)
  self.timerEvents = {}

  LibStub('LibDBIcon-1.0'):Register('Shotta', iconOptions, self.db.profile.minimap)

  local profileOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)

  local acreg = LibStub 'AceConfigRegistry-3.0'
  acreg:RegisterOptionsTable('Shotta', self:LoadOptions())
  acreg:RegisterOptionsTable('Shotta about', aboutOptions)
  acreg:RegisterOptionsTable('Shotta profiles', profileOptions)

  local acdia = LibStub 'AceConfigDialog-3.0'
  local _, categoryID = acdia:AddToBlizOptions('Shotta', 'Shotta')
  self.optionsCategoryID = categoryID
  acdia:AddToBlizOptions('Shotta profiles', 'Profiles', 'Shotta')
  acdia:AddToBlizOptions('Shotta about', 'About', 'Shotta')

  self:Print(VERSION .. ' loaded!')
end

function Shotta:OnEnable()
  for event, enabled in pairs(self.db.profile.events.blizzard) do
    if enabled then
      self:conditionallyRegisterBlizzardEvent(true, event)
    end
  end

  for min, enabled in pairs(self.db.profile.events.timer) do
    if enabled then
      self:conditionallyEnableTimer(true, min)
    end
  end
end

function Shotta:OnDisable()
  self:UnregisterAllEvents()
  self:CancelAllTimers()
  self.timerEvents = {}
end

Shotta:RegisterChatCommand('shotta', 'OpenToCategory')
Shotta:RegisterChatCommand('sh', 'OpenToCategory')
