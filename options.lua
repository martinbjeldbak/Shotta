-- The AceConfig options tree shown in the Blizzard Settings interface, and the command that opens it.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta
local L = ns.L

local IS_MAINLINE = ns.IS_MAINLINE
local IS_MISTS = ns.IS_MISTS
local IS_CLASSIC_ERA = ns.IS_CLASSIC_ERA
local IS_TBC = ns.IS_TBC
local HAS_ACHIEVEMENTS = ns.HAS_ACHIEVEMENTS

local VERSION = ns.VERSION
local UPDATED_TIMESTAMP = ns.UPDATED_TIMESTAMP
local DISCORD_LINK = ns.DISCORD_LINK
local GITHUB_LINK = ns.GITHUB_LINK

function Shotta:OpenToCategory()
  Settings.OpenToCategory(self.optionsCategoryID or self.name)
end

---Uses AceLocale to translate an option
---@param info table
---@return string
local function localizedOptionName(info)
  return L['checkboxText.' .. info[#info]]
end

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

---Registers the settings page, the profiles page, the about page and the chat commands that open them
function Shotta:RegisterOptions()
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

  self:RegisterChatCommand('shotta', 'OpenToCategory')
  self:RegisterChatCommand('sh', 'OpenToCategory')
end
