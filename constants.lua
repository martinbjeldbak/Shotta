-- Shared constants and client detection for every other file in the addon.
-- Loaded straight after main.lua; everything is exposed on the private addon namespace.
local _, ns = ...

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
-- WOW_PROJECT_CAMELOT is the Forever game type. Compared directly like other addons do: the global is simply
-- nil on clients that predate Forever, which makes the comparison false rather than an error.
local IS_FOREVER = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
-- Out of the supported clients, only retail and MoP Classic have achievements. Forever shares Mainline's API.
local HAS_ACHIEVEMENTS = IS_MAINLINE or IS_MISTS or IS_FOREVER

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
