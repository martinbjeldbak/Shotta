-- Shared constants and client detection for every other file in the addon.
-- Loaded straight after main.lua; everything is exposed on the private addon namespace.
local _, ns = ...

-- luacheck: push ignore VERSION
---@type string
local VERSION = '@project-version@'
--@alpha@
-- Untagged builds get 'main' plus the commit the alpha zip was built from, so a bug report identifies its source.
VERSION = 'main-' .. '@project-abbreviated-hash@'
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
-- WOW_PROJECT_CAMELOT is the Forever game type. Compared directly like other addons do: the global is simply
-- nil on clients that predate Forever, which makes the comparison false rather than an error.
local IS_FOREVER = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
-- Out of the supported clients, only retail and MoP Classic have achievements. Forever shares Mainline's API.
local HAS_ACHIEVEMENTS = IS_MAINLINE or IS_MISTS or IS_FOREVER

-- luacheck: push ignore DEBUG_BUILD
---@type boolean
local DEBUG_BUILD = false
--@debug@
DEBUG_BUILD = true
--@end-debug@
-- luacheck: pop

---@type string
local L = LibStub('AceLocale-3.0'):GetLocale('Shotta', TRANSLATE_FAIL_SILENTLY)

ns.VERSION = VERSION
ns.UPDATED_TIMESTAMP = UPDATED_TIMESTAMP
ns.DISCORD_LINK = DISCORD_LINK
ns.GITHUB_LINK = GITHUB_LINK
ns.L = L
ns.IS_MAINLINE = IS_MAINLINE
ns.IS_FOREVER = IS_FOREVER
ns.IS_MISTS = IS_MISTS
ns.IS_CLASSIC_ERA = IS_CLASSIC_ERA
ns.IS_TBC = IS_TBC
ns.HAS_ACHIEVEMENTS = HAS_ACHIEVEMENTS
ns.DEBUG_BUILD = DEBUG_BUILD

---One Blizzard event the addon can screenshot on.
---@class ShottaEventDefinition
---@field order integer Position in the options list; gaps of 10 leave room to insert
---@field page 'events'|'bosses' Which options page it is listed on
---@field default? boolean Enabled for new profiles
---@field mainlineOnly? boolean Only offered on retail
---@field requiresAchievements? boolean Only offered where the client has achievements
---@field debugOnly? boolean Only present in debug builds

---Every screenshot event, in one place. The saved-variable defaults, the Events page and the Boss kills page
---are all derived from this table, so adding an event is a single edit rather than three that can drift.
---@type table<string, ShottaEventDefinition>
ns.EVENTS = {
  PLAYER_LOGIN = { order = 0, page = 'events', default = true },
  PLAYER_LEVEL_UP = { order = 10, page = 'events', default = true },
  ACHIEVEMENT_EARNED = { order = 20, page = 'events', requiresAchievements = true },
  QUEST_TURNED_IN = { order = 30, page = 'events' },
  ZONE_CHANGED_NEW_AREA = { order = 40, page = 'events' },
  ZONE_CHANGED = { order = 50, page = 'events' },
  HEARTHSTONE_BOUND = { order = 60, page = 'events' },
  -- Social and grouping
  GROUP_FORMED = { order = 100, page = 'events' },
  READY_CHECK = { order = 110, page = 'events' },
  CHAT_MSG_TEXT_EMOTE = { order = 120, page = 'events' },
  CHAT_MSG_CHANNEL = { order = 130, page = 'events' },
  TRADE_ACCEPT_UPDATE = { order = 140, page = 'events' },
  -- Economy
  MAIL_SHOW = { order = 200, page = 'events' },
  AUCTION_HOUSE_SHOW = { order = 210, page = 'events' },
  LOOT_ITEM_ROLL_WON = { order = 220, page = 'events', default = true },
  -- Combat
  PLAYER_DEAD = { order = 400, page = 'events', default = true },
  -- Bosses, on their own page
  BOSS_KILL = { order = 300, page = 'bosses', default = true },
  ENCOUNTER_END = { order = 305, page = 'bosses' },
  -- Retail-only
  MAJOR_FACTION_RENOWN_LEVEL_CHANGED = { order = 70, page = 'events', mainlineOnly = true },
  -- Debug builds only
  PLAYER_STARTED_MOVING = { order = 900, page = 'events', debugOnly = true },
}
