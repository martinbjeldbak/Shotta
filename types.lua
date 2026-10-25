---@meta
---

---@alias minutes number Number of minutes for timer to be triggered

---@class ShottaEvents
---@field blizzard table<string, boolean>
---@field timer table<minutes, boolean>

---@class ShottaMinimap
---@field hide boolean

---@class ShottaConstants
---@field VERSION string The addon version, substituted by the packager at release
---@field UPDATED_TIMESTAMP number Unix timestamp of the last commit, substituted by the packager
---@field DISCORD_LINK string
---@field GITHUB_LINK string
---@field L table<string, string> The AceLocale table for the current client locale
---@field IS_MAINLINE boolean Retail
---@field IS_FOREVER boolean World of Warcraft: Forever, which shares Mainline's API
---@field IS_MISTS boolean Mists of Pandaria Classic
---@field IS_CLASSIC_ERA boolean Classic Era
---@field IS_TBC boolean Burning Crusade Classic Anniversary
---@field HAS_ACHIEVEMENTS boolean Only retail, Forever and MoP Classic have achievements
---@field DEBUG_BUILD boolean Debug build, set by the packager's @debug@ filter
---@field Shotta Shotta The addon instance, created in main.lua

---@class ShottaFirstKillOptions
---@field restrict boolean Only screenshot the first kill of each boss

---A single boss remembered as killed
---@class ShottaBossKill
---@field encounterID integer The journal encounter ID, unique per boss across the game
---@field name? string The boss name as the client reported it, absent if the journal could not resolve it
---@field instance? string The map or zone the kill happened on
---@field time number Unix timestamp of the first kill

---@class ShottaBossKillEntry : ShottaBossKill
---@field key string The key in ShottaBossKills, for a per-boss reset

---Bosses killed while "first kill only" was enabled. Keyed by `<instance>|<encounterID>`. BOSS_KILL does not
---report a difficulty, so normal and heroic share one entry.
---@alias ShottaBossKills table<string, ShottaBossKill>

---@class ShottaProfile
---@field minimap ShottaMinimap
---@field events ShottaEvents
---@field firstKill ShottaFirstKillOptions

---Per-character data. AceDB keeps this separate for every character, so nothing has to track an owner.
---@class ShottaChar
---@field bossKills ShottaBossKills

---@class ShottaDb
---@field profile ShottaProfile
---@field char ShottaChar

---List of implemented functions that support being called by ScheduleTimer method
---@alias TimerCallbacks "TimedScreenshot"
---@alias ChatCommandCallbacks "OpenToCategory"

---An AceConfig-3.0 options table
---@class AceOptionsTable
---@field name string|fun(info: table): string
---@field type string
---@field order? number
---@field width? string
---@field inline? boolean
---@field fontSize? string
---@field args? table<string, AceOptionsTable>
---@field set? fun(info: table, value: any)
---@field get? fun(info: table): any

---@class Shotta
---@field [string] any Allows event handlers to be looked up by event name
---@field name string The addon name, as passed to AceAddon
---@field optionsCategoryID any The Settings category ID returned by AceConfigDialog:AddToBlizOptions
---@field timerEvents table<minutes, any>
---@field db ShottaDb
---@field OpenToCategory fun(self: Shotta) Makes the UI open to the plugin
---@field TimedScreenshot fun(self: Shotta) Triggered when screenshot event fires
---@field LoadOptions fun(self: Shotta): AceOptionsTable The main settings page
---@field LoadEventOptions fun(self: Shotta): AceOptionsTable The Blizzard event toggles page
---@field LoadBossOptions fun(self: Shotta): AceOptionsTable The boss kill settings page
---@field conditionallyEnableTimer fun(self: Shotta, enabled: boolean, minutes: minutes)
---@field ResetTimers fun(self: Shotta) Empties the timer bookkeeping table without cancelling timers
---@field OnEnableTimers fun(self: Shotta) Starts every timer enabled in the profile
---@field RegisterMinimapIcon fun(self: Shotta)
---@field RegisterOptions fun(self: Shotta) Registers the options pages and the chat commands
---@field BlizzardEventOption fun(self: Shotta): AceOptionsTable
---@field TimerEventOption fun(self: Shotta, minutes: minutes, order: integer): AceOptionsTable
---@field conditionallyRegisterBlizzardEvent fun(self: Shotta, enabled: boolean, blizzardEvent: string)
---@field DefaultBlizzardHandler fun(self: Shotta)
---@field RecordBossKill fun(self: Shotta, encounterID: integer?, encounterName: string?, instanceName: string?) Marks a boss as killed for the current character
---@field ResetBossKills fun(self: Shotta) Forgets every boss killed so far for the current character
---@field BossKillCount fun(self: Shotta): integer How many bosses the current character has killed
---@field BossKillEntries fun(self: Shotta): ShottaBossKillEntry[] Killed bosses, most recent first
---@field ForgetBossKill fun(self: Shotta, key: string): boolean Forgets a single boss so its next kill counts again
---@field BossKillStateText fun(self: Shotta): string The killed boss count, phrased for the options page
---@field FirstKillOptions fun(self: Shotta): AceOptionsTable The first kill settings, shown on the boss kills page
---@field BossKillEnabled fun(self: Shotta): boolean Whether the "on boss kill" event is enabled
--- Below fields are provided by the Ace3 framework, see https://legacy.curseforge.com/wow/addons/ace3
---@field ScheduleTimer fun(self: Shotta, callback: TimerCallbacks, seconds: number): any
---@field ScheduleRepeatingTimer fun(self: Shotta, callback: TimerCallbacks, seconds: number): any
---@field CancelTimer fun(self: Shotta, timer: any): boolean Cancels a timer with the given id, registered by the same addon object as used for `:ScheduleTimer` Both one-shot and repeating timers can be canceled with this function, as long as the `id` is valid and the timer has not fired yet or was canceled before.
---@field CancelAllTimers fun(self: Shotta)
---@field OnInitialize fun(self: Shotta)
---@field OnEnable fun(self: Shotta)
---@field OnDisable fun(self: Shotta)
---@field RegisterEvent fun(self: Shotta, event: string, method?: string)
---@field UnregisterEvent fun(self: Shotta, event: string)
---@field UnregisterAllEvents fun(self: Shotta)
---@field RegisterChatCommand fun(self: Shotta, command: string, callback: ChatCommandCallbacks)
---@field Print fun(self: Shotta, message: string, ...) Prints to the chat
---@field PLAYER_STARTED_MOVING fun(self: Shotta)
---@field PLAYER_LOGIN fun(self: Shotta)
---@field ACHIEVEMENT_EARNED fun(self: Shotta)
---@field CHAT_MSG_TEXT_EMOTE fun(self: Shotta)
---@field TRADE_ACCEPT_UPDATE fun(self: Shotta, event: string, playerAccepted: number)
---@field PLAYER_LEVEL_UP fun(self: Shotta)
---@field BOSS_KILL fun(self: Shotta, encounterID: integer, encounterName: string) Screenshots the kill unless the boss was already killed
---@field ENCOUNTER_END fun(self: Shotta, ...) Only used so its toggle can exist; BOSS_KILL carries everything needed
