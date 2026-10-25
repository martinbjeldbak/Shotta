---@meta
---

---@alias minutes number Number of minutes for timer to be triggered

---@class ShottaEvents
---@field blizzard table<string, boolean>
---@field timer table<minutes, boolean>

---@class ShottaMinimap
---@field hide boolean

---@class ShottaProfile
---@field minimap ShottaMinimap
---@field events ShottaEvents

---@class ShottaDb
---@field profile ShottaProfile

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
---@field timerEvents table<minutes, any>
---@field db ShottaDb
---@field OpenToCategory fun(self: Shotta) Makes the UI open to the plugin
---@field TimedScreenshot fun(self: Shotta) Triggered when screenshot event fires
---@field LoadOptions fun(self: Shotta): AceOptionsTable
---@field conditionallyEnableTimer fun(self: Shotta, enabled: boolean, minutes: minutes)
---@field BlizzardEventOption fun(self: Shotta): AceOptionsTable
---@field TimerEventOption fun(self: Shotta, minutes: minutes, order: integer): AceOptionsTable
---@field conditionallyRegisterBlizzardEvent fun(self: Shotta, enabled: boolean, blizzardEvent: string)
---@field DefaultBlizzardHandler fun(self: Shotta)
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
