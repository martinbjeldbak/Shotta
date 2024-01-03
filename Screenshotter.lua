local _, ns = ...

local EventFrame = CreateFrame("Frame")
ADDON_NAME = "Screenshotter"
VERSION = "0.1.0"
COLOR = "245DC6FF"

local DbDefaults = {
  screenshottableEvents = {
    jump = {
      eventName = "JumpOrAscendStart",
      enabled = false,
      checkboxText = "On jump"
    }
  }
}

--- Creates or gets the SavedVariable for this addon
local function fetchOrCreateDatabase()
  return ScreenshotterDB or CopyTable(DbDefaults)
end

--- Print formatted message to chat
---@param message string
local function printToChat(message)
  print(format("%s: %s", WrapTextInColorCode(ADDON_NAME, COLOR), message))
end


local function EventHandler(self, event, addOnName)
  if addOnName ~= ADDON_NAME then
    return nil
  end

  printToChat("v" .. VERSION .. " loaded")

  ScreenshotterDB = fetchOrCreateDatabase()

  ns.InitializeOptions(self, ScreenshotterDB, ADDON_NAME, VERSION)
end

EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", EventHandler)
