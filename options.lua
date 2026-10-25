-- The AceConfig options tree shown in the Blizzard Settings interface, and the command that opens it.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta
local L = ns.L

local IS_MAINLINE = ns.IS_MAINLINE
local IS_FOREVER = ns.IS_FOREVER
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

---An event toggle. Events are ordered explicitly because AceConfig otherwise sorts them alphabetically by
---key, which mixes unrelated events together.
---@param order integer
---@return AceOptionsTable
function Shotta:BlizzardEventOption(order)
  return {
    name = localizedOptionName,
    type = 'toggle',
    width = 'full',
    order = order,
    set = function(info, val)
      local triggerName = info[#info]
      self.db.profile.events = self.db.profile.events or {}
      self.db.profile.events.blizzard = self.db.profile.events.blizzard or {}
      self.db.profile.events.blizzard[triggerName] = val
      self:conditionallyRegisterBlizzardEvent(val, triggerName)

      -- Options nested under this event (the first kill settings) are disabled while it is off
      LibStub('AceConfigRegistry-3.0'):NotifyChange 'Shotta'
    end,
    get = function(info)
      local triggerName = info[#info]
      local events = self.db.profile.events
      local blizzard = events and events.blizzard
      return blizzard ~= nil and blizzard[triggerName] == true
    end,
  }
end

---How many bosses the profile remembers, shown above the first kill settings
---@return string
function Shotta:BossKillStateText()
  local count = self:BossKillCount()
  if count == 0 then
    return L['firstKill.state.none']
  end

  if count == 1 then
    return L['firstKill.state.one']
  end

  return format(L['firstKill.state.count'], count)
end

---Whether the "on boss kill" event is enabled, which every setting below depends on
---@return boolean
function Shotta:BossKillEnabled()
  -- Read defensively: profiles created before an option existed (or emptied ones) can lack these tables,
  -- and an unguarded index here throws during options rendering.
  local events = self.db.profile.events
  local blizzard = events and events.blizzard
  return blizzard ~= nil and blizzard.BOSS_KILL == true
end

---The killed bosses keyed for the dropdown, and their labels. Both are read when the page renders rather than
---when the options tree is built, so a kill or a reset shows up without a reload.
---@param self Shotta
---@return table<string, string> labels keyed by boss key
local function bossKillChoices(self)
  local labels = {}
  for _, entry in ipairs(self:BossKillEntries()) do
    local boss = entry.name or entry.key
    local instance = entry.instance and format(' (%s)', entry.instance) or ''
    labels[entry.key] = format('%s%s', boss, instance)
  end

  return labels
end

---Pick a boss, then forget it with the button. Selecting is harmless so the dropdown can double as a
---preview; only the button destroys data, and it asks first.
---@param self Shotta
---@return table<string, AceOptionsTable>
local function bossKillPicker(self)
  local function disabled()
    return not self:BossKillEnabled()
  end

  return {
    forgetChoice = {
      name = L['bossKills.forgetChoice'],
      desc = L['bossKills.forgetChoiceDesc'],
      type = 'select',
      width = 'full',
      order = 330,
      values = function()
        return bossKillChoices(self)
      end,
      disabled = disabled,
      -- Remembers the selection between renders so the button below knows what to forget
      get = function()
        local choices = bossKillChoices(self)
        if self.forgetChoice and choices[self.forgetChoice] then
          return self.forgetChoice
        end

        return nil
      end,
      set = function(_, value)
        self.forgetChoice = value
      end,
    },
    forget = {
      name = L['bossKills.forget'],
      desc = L['bossKills.forgetDesc'],
      type = 'execute',
      width = 'full',
      order = 340,
      confirm = true,
      disabled = function()
        local choices = bossKillChoices(self)
        return disabled() or not (self.forgetChoice and choices[self.forgetChoice])
      end,
      func = function()
        if self.forgetChoice then
          self:ForgetBossKill(self.forgetChoice)
          self.forgetChoice = nil
        end
      end,
    },
  }
end

---@param minutes minutes
---@param order integer
---@return AceOptionsTable
function Shotta:TimerEventOption(minutes, order)
  return {
    name = localizedOptionName,
    type = 'toggle',
    width = 'full',
    order = order,
    set = function(_, val)
      self.db.profile.events = self.db.profile.events or {}
      self.db.profile.events.timer = self.db.profile.events.timer or {}
      self.db.profile.events.timer[minutes] = val

      self:conditionallyEnableTimer(val, minutes)
    end,
    get = function(_)
      local events = self.db.profile.events
      local timer = events and events.timer
      return timer ~= nil and timer[minutes] == true
    end,
  }
end

---Whether this event can be offered on the current client and build.
---@param definition ShottaEventDefinition
---@return boolean
local function eventAvailable(definition)
  if definition.mainlineOnly and not IS_MAINLINE then
    return false
  end

  if definition.requiresAchievements and not HAS_ACHIEVEMENTS then
    return false
  end

  if definition.debugOnly and not ns.DEBUG_BUILD then
    return false
  end

  return true
end

---The event toggles, on their own page because the list is long enough to push everything else off the main
---page. Built from ns.EVENTS so adding an event does not mean editing this function.
---@param page 'events'|'bosses'
---@return AceOptionsTable
function Shotta:LoadEventOptions(page)
  local args = {}

  for event, definition in pairs(ns.EVENTS) do
    if definition.page == page and eventAvailable(definition) then
      args[event] = self:BlizzardEventOption(definition.order)
    end
  end

  return {
    type = 'group',
    args = args,
  }
end

---The first kill settings, returned flat rather than as a group: a nested group in this AceConfig build gets a
---wrong height when it is not the only thing on a page, which rendered it as a tall empty box.
---@return table<string, AceOptionsTable>
function Shotta:FirstKillOptions()
  local function bossKillDisabled()
    return not self:BossKillEnabled()
  end

  return {
    state = {
      name = function()
        return format('%s\n%s', self:BossKillStateText(), L['bossKills.perCharacter'])
      end,
      type = 'description',
      fontSize = 'medium',
      order = 310,
    },
    restrict = {
      name = function()
        return L['checkboxText.firstKill.restrict']
      end,
      desc = function()
        if bossKillDisabled() then
          return L['firstKill.disabledDesc']
        end

        return L['firstKill.restrictDesc']
      end,
      type = 'toggle',
      width = 'full',
      order = 320,
      disabled = bossKillDisabled,
      set = function(_, val)
        self.db.profile.firstKill.restrict = val
      end,
      get = function(_)
        return self.db.profile.firstKill.restrict
      end,
    },
    reset = {
      name = function()
        return L['checkboxText.firstKill.reset']
      end,
      desc = L['firstKill.resetDesc'],
      type = 'execute',
      width = 'full',
      order = 325,
      confirm = true,
      disabled = bossKillDisabled,
      func = function()
        self:ResetBossKills()
      end,
    },
  }
end

---@return AceOptionsTable
function Shotta:LoadBossOptions()
  -- The boss event toggles come from the same event table as the Events page, so a new boss-related event
  -- needs no edit here.
  local args = {}
  for event, option in pairs(self:LoadEventOptions('bosses').args) do
    args[event] = option
  end

  for key, option in pairs(self:FirstKillOptions()) do
    args[key] = option
  end

  for key, option in pairs(bossKillPicker(self)) do
    args[key] = option
  end

  return {
    type = 'group',
    args = args,
  }
end

---@return AceOptionsTable
function Shotta:LoadOptions()
  return {
    type = 'group',
    args = {
      -- Positive, well-spaced orders: AceConfig does not reliably sort negative orders ahead of the
      -- defaults, which put the intro below the sections it introduces.
      intro = {
        name = L['intro.about'],
        type = 'description',
        fontSize = 'large',
        order = 1,
      },
      introEvents = {
        name = L['intro.events'],
        type = 'description',
        order = 2,
      },
      general_options = {
        name = localizedOptionName,
        type = 'group',
        order = 10,
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
      timer_events = {
        name = localizedOptionName,
        type = 'group',
        inline = true,
        order = 20,
        args = {
          every_5_minutes = self:TimerEventOption(5, 0),
          every_10_minutes = self:TimerEventOption(10, 1),
          every_30_minutes = self:TimerEventOption(30, 2),
        },
      },
    },
  }
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
  elseif IS_FOREVER then
    return 'camelot'
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
    screenshotUI = {
      name = L['screenshotUIHelpText'],
      order = 6,
      type = 'description',
    },
    discord = {
      name = format('%s (%s)', L['joinDiscord'], L['pressCtrlC']),
      type = 'input',
      order = 7,
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
      name = 'For Nandar. Made with love in Sydney, Australia',
      order = 80,
      fontSize = 'small',
      type = 'description',
    },
  },
}

---Registers the settings page, the events page, the profiles page, the about page and the chat commands
function Shotta:RegisterOptions()
  local profileOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)

  local acreg = LibStub 'AceConfigRegistry-3.0'
  acreg:RegisterOptionsTable('Shotta', self:LoadOptions())
  acreg:RegisterOptionsTable('Shotta events', self:LoadEventOptions 'events')
  acreg:RegisterOptionsTable('Shotta boss kills', self:LoadBossOptions())
  acreg:RegisterOptionsTable('Shotta about', aboutOptions)
  acreg:RegisterOptionsTable('Shotta profiles', profileOptions)

  local acdia = LibStub 'AceConfigDialog-3.0'
  local _, categoryID = acdia:AddToBlizOptions('Shotta', 'Shotta')
  self.optionsCategoryID = categoryID
  acdia:AddToBlizOptions('Shotta events', L['checkboxText.events'], 'Shotta')
  acdia:AddToBlizOptions('Shotta boss kills', L['checkboxText.bossKillsPage'], 'Shotta')
  acdia:AddToBlizOptions('Shotta profiles', 'Profiles', 'Shotta')
  acdia:AddToBlizOptions('Shotta about', 'About', 'Shotta')

  self:RegisterChatCommand('shotta', 'OpenToCategory')
  self:RegisterChatCommand('sh', 'OpenToCategory')
end
