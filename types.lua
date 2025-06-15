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

---@class AceOptionsTable
---@field name string|function
---@field type string
---@field width string
---@field set fun(info: string, val: boolean)
---@field get fun(info: string, val: boolean): boolean

---@class Shotta
---@field timerEvents { [number]: any }
---@field db ShottaDb
---@field OpenToCategory function Makes the UI open to the plugin
---@field TimedScreenshot function Triggered when screenshot event fires
---@field LoadOptions fun(self: Shotta): AceOptionsTable
---@field conditionallyEnableTimer fun(self: Shotta, val: boolean, minutes: number)
---@field BlizzardEventOption fun(self: Shotta): AceOptionsTable
---@field TimerEventOption fun(self: Shotta, minutes: number, order: integer): AceOptionsTable
---@field conditionallyRegisterBlizzardEvent fun(self: Shotta, newValue: boolean, blizzardEvent: string)
---@field DefaultBlizzardHandler fun(self: Shotta, eventName: string)
--- Below fields provided by Ace3 framework, see https://legacy.curseforge.com/wow/addons/ace3
---@field ScheduleTimer fun(self: Shotta, callback: TimerCallbacks, seconds: number)
---@field ScheduleRepeatingTimer fun(self: Shotta, callback: TimerCallbacks, seconds: number)
---@field CancelTimer fun(self: Shotta, id: string) Cancels a timer with the given id, registered by the same addon object as used for `:ScheduleTimer` Both one-shot and repeating timers can be canceled with this function, as long as the `id` is valid and the timer has not fired yet or was canceled before.
---@field CancelAllTimers function
---@field OnInitialize function
---@field OnEnable function
---@field OnDisable function
---@field RegisterEvent fun(self: Shotta, event: string, handler: string, args?: any)
---@field UnregisterEvent fun(self: Shotta, event: string)
---@field RegisterChatCommand fun(self: Shotta, command: string, callback: ChatCommandCallbacks)
---@field Print function Prints to the chat
---@field PLAYER_STARTED_MOVING fun(self: Shotta)
---@field PLAYER_LOGIN fun(self: Shotta)
---@field ACHIEVEMENT_EARNED function
---@field CHAT_MSG_TEXT_EMOTE function
---@field TRADE_ACCEPT_UPDATE fun(playerAccepted: number)
---@field PLAYER_LEVEL_UP function
