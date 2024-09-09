---@meta

---@class ShottaEvents
---@field blizzard table<string, boolean>
---@field timer table<string, boolean>

---@class ShottaMinimap
---@field hide boolean

---@class ShottaProfile
---@field minimap ShottaMinimap
---@field events ShottaEvents

---@class ShottaDb
---@field profile ShottaProfile

---@class Shotta
---@field timerEvents { [number]: any }
---@field db ShottaDb
---@field ADDON_NAME string
---@field VERSION string
