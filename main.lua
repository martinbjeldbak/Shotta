---@class Shotta
local Shotta = LibStub("AceAddon-3.0"):NewAddon("Shotta", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

Shotta:RegisterChatCommand("shotta", "OpenToCategory")
Shotta:RegisterChatCommand("sh", "OpenToCategory")

Shotta.ADDON_NAME = "Shotta"
Shotta.VERSION = "@project-version@"

Shotta.TRANSLATE_FAIL_SILENTLY = true
--@alpha@
Shotta.TRANSLATE_FAIL_SILENTLY = false
--@end-alpha@

local L = LibStub("AceLocale-3.0"):GetLocale("Shotta", Shotta.TRANSLATE_FAIL_SILENTLY)

function Shotta:OpenToCategory()
	Settings.OpenToCategory(self.ADDON_NAME)
end

local function localisedName(info)
	return L["checkboxText." .. info[#info]]
end

---Converts minutes to seconds
---@param min number how many minutes should be converted to seconds
---@return number minutes in seconds
local function minutes(min)
	return min * 60
end

---Makes client take a screenshot. Simply wraps the WoW global method.
---@param text? string Optional text to log
local function TakeScreenshot(text)
	if text ~= nil then
		Shotta:Print(text)
	end

	Screenshot()
end

function TakeUILessScreenshot(text)
	UIParent:Hide()

	TakeScreenshot(text)

	C_Timer.After(0.01, function()
		UIParent:Show()
	end)
end

local iconOptions = LibStub("LibDataBroker-1.1"):NewDataObject("Shotta", {
	type = "data source",
	text = "Shotta",
	icon = 237290,
	OnClick = function()
		if IsShiftKeyDown() then
			HideUIPanel(SettingsPanel)
			Settings.OpenToCategory("Shotta")
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

		tooltip:AddLine("Shotta")
		tooltip:AddLine(" ")
		tooltip:AddLine(L["minimap.click"])
		tooltip:AddLine(L["minimap.ctrlClick"])
		tooltip:AddLine(" ")
		tooltip:AddLine(L["minimap.shiftClick"])
	end,
})

local defaults = {
	profile = {
		minimap = {
			hide = false,
		},
		events = {
			["**"] = false,
			blizzard = {
				PLAYER_LOGIN = true, -- enable this by default
				PLAYER_LEVEL_UP = true,
				LOOT_ITEM_ROLL_WON = true,
				BOSS_KILL = true,
			},
			timer = {},
		},
	},
}

---@class AceOptions
---@field name string|function The name of the option
---@field type integer

---@return AceOptions table for AceOptions to display a Blizzard-triggered event
function Shotta:blizzardEventAceOption()
	return {
		name = localisedName,
		type = "toggle",
		width = "full",
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
	Shotta:Print("Got overridden event, taking screenshot")
end

function Shotta:PLAYER_LOGIN()
	--@alpha@
	Shotta:Print("Got event player login: taking screenshot")
	--@end-alpha@
	C_Timer.After(5, function()
		TakeScreenshot()
	end)
end
function Shotta:CHAT_MSG_TEXT_EMOTE()
	C_Timer.After(0.5, function()
		TakeScreenshot()
	end)
end
function Shotta:TRADE_ACCEPT_UPDATE(playerAccepted)
	-- TODO: TEST ME
	if playerAccepted == 1 then
		TakeScreenshot()
	end
end

function Shotta:PLAYER_LEVEL_UP()
	-- 	-- TODO: implement these modifiers
	-- 	-- if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat then
	-- 	-- 	if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat.enabled then
	-- 	-- 		ChatFrame1Tab:Click()
	-- 	-- 	end
	-- 	-- end

	-- 	-- if Shotta.db.screenshottableEvents.levelUp.modifiers.showPlayed.enabled then
	-- 	-- 	screenshotFrame.waitingForTimePlayed = true
	-- 	-- 	RequestTimePlayed() -- trigger "TIME_PLAYED_MSG" event
	-- 	-- 	return
	-- 	-- end

	C_Timer.After(0.5, function()
		TakeScreenshot()
	end)
end

function Shotta:getConfig()
	local config = {
		type = "group",
		args = {
			general_options = {
				name = localisedName,
				type = "group",
				order = 0,
				inline = true,
				args = {
					hideMinimap = {
						name = localisedName,
						type = "toggle",
						set = function(info, val)
							self.db.profile.minimap.hide = val
							if val then
								LibStub("LibDBIcon-1.0"):Hide("Shotta")
							else
								LibStub("LibDBIcon-1.0"):Show("Shotta")
							end
						end,
						get = function(info)
							return self.db.profile.minimap.hide
						end,
					},
				},
			},
			blizzard_events = {
				name = localisedName,
				type = "group",
				order = 2,
				inline = true,
				args = {
					PLAYER_LOGIN = self:blizzardEventAceOption(),
					CHAT_MSG_CHANNEL = self:blizzardEventAceOption(),
					PLAYER_LEVEL_UP = self:blizzardEventAceOption(),
					MAIL_SHOW = self:blizzardEventAceOption(),
					READY_CHECK = self:blizzardEventAceOption(),
					ZONE_CHANGED = self:blizzardEventAceOption(),
					ZONE_CHANGED_NEW_AREA = self:blizzardEventAceOption(),
					HEARTHSTONE_BOUND = self:blizzardEventAceOption(),
					--@debug@
					PLAYER_STARTED_MOVING = self:blizzardEventAceOption(),
					--@end-debug@
					AUCTION_HOUSE_SHOW = self:blizzardEventAceOption(),
					GROUP_FORMED = self:blizzardEventAceOption(),
					TRADE_ACCEPT_UPDATE = self:blizzardEventAceOption(),
					BOSS_KILL = self:blizzardEventAceOption(),
					ENCOUNTER_END = self:blizzardEventAceOption(),
					QUEST_TURNED_IN = self:blizzardEventAceOption(),
					LOOT_ITEM_ROLL_WON = self:blizzardEventAceOption(),
					PLAYER_DEAD = self:blizzardEventAceOption(),
					CHAT_MSG_TEXT_EMOTE = self:blizzardEventAceOption(),
				},
			},
			timer_events = {
				name = localisedName,
				type = "group",
				inline = true,
				order = 1,
				args = {
					-- Timer-based events
					every_5_minutes = {
						name = localisedName,
						type = "toggle",
						order = 0,
						set = function(info, val)
							self.db.profile.events.timer.every_5_minutes = val

							if val then
								self.screenshotFifthMinuteTimer =
									self:ScheduleRepeatingTimer("RepeatingScreenshotTimer", minutes(5))
							else
								self:CancelTimer(self.screenshotFifthMinuteTimer)
							end
						end,
						get = function(info)
							return self.db.profile.events.timer.every_5_minutes
						end,
					},
					every_10_minutes = {
						name = localisedName,
						order = 1,
						type = "toggle",
						set = function(info, val)
							self.db.profile.events.timer.every_10_minutes = val

							if val then
								self.screenshotTenMinuteTimer =
									self:ScheduleRepeatingTimer("RepeatingScreenshotTimer", minutes(10))
							else
								self:CancelTimer(self.screenshotTenMinuteTimer)
							end
						end,
						get = function(info)
							return self.db.profile.events.timer.every_10_minutes
						end,
					},
					every_30_minutes = {
						name = localisedName,
						type = "toggle",
						order = 2,
						set = function(info, val)
							self.db.profile.events.timer.every_30_minutes = val

							if val then
								self.screenshotThirtyMinuteTimer =
									self:ScheduleRepeatingTimer("RepeatingScreenshotTimer", minutes(30))
							else
								self:CancelTimer(self.screenshotThirtyMinuteTimer)
							end
						end,
						get = function(info)
							return self.db.profile.events.timer.every_30_minutes
						end,
					},
				},
			},
		},
	}

	if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) or (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC) then
		config.args.blizzard_events.args.ACHIEVEMENT_EARNED = self:blizzardEventAceOption()
	end

	return config
end

function Shotta:RepeatingScreenshotTimer()
	Shotta:Print("Timed trigger fired, taking screenshot!")

	TakeScreenshot()
end

---Either register o unregister a blizzard-based Event
---@param newValue boolean
---@param blizzardEvent string
function Shotta:conditionallyRegisterBlizzardEvent(newValue, blizzardEvent)
	local handler = self[blizzardEvent]

	if not handler then
		handler = "DefaultBlizzardHandler"
	end

	if newValue then
		self:RegisterEvent(blizzardEvent, handler)
	else
		self:UnregisterEvent(blizzardEvent)
	end
end

function Shotta:DefaultBlizzardHandler(eventName)
	--@alpha@
	Shotta:Print("Default handler: got enabled Blizzard event " .. eventName .. ", taking screenshot.")
	--@end-alpha@
	TakeScreenshot()
end

-- function Shotta:PLAYER_LEVEL_UP()
-- end

function Shotta:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ShottaDBv2", defaults)

	LibStub("LibDBIcon-1.0"):Register("Shotta", iconOptions, self.db.profile.minimap)

	local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	local acreg = LibStub("AceConfigRegistry-3.0")
	acreg:RegisterOptionsTable("Shotta", self:getConfig())
	acreg:RegisterOptionsTable("Shotta profiles", profileOptions)

	local acdia = LibStub("AceConfigDialog-3.0")
	acdia:AddToBlizOptions("Shotta", "Shotta")
	acdia:AddToBlizOptions("Shotta profiles", "Profiles", "Shotta")

	Shotta:Print(self.VERSION .. " loaded!")
end

function Shotta:OnEnable()
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from
	-- the game that wasn't available in OnInitialize
	--
	for event, enabled in pairs(self.db.profile.events.blizzard) do
		-- if enabled then
		-- 	local info = { event }
		-- 	self:getConfig().args[event].set(info, true)
		-- end
	end

	for event, enabled in pairs(self.db.profile.events.timer) do
		-- if enabled then
		-- 	local info = { event }
		-- 	self:getConfig().args[event].set(info, true)
		-- end
	end
end

function Shotta:OnDisable()
	-- Unhook, Unregister Events, Hide frames that you created.
	-- You would probably only use an OnDisable if you want to
	-- build a "standby" mode, or be able to toggle modules on/off.

	-- Unregister all events
	for event, enabled in pairs(self.db.profile.events.blizzard) do
		if enabled then
			self:conditionallyRegisterBlizzardEvent(false, event)
		end
	end

	self:CancelAllTimers()
end

---@type { [triggerId]: Trigger }
local hiddenTriggers = {
	timePlayed = {
		eventName = "TIME_PLAYED_MSG",
		register = registerEvent,
		unregister = unregisterEvent,
		---Executed when the event is triggered
		---@param _ Trigger
		---@param screenshotFrame ShottaFrame contains state for the application
		triggerFunc = function(_, screenshotFrame)
			ns.Debug("TIME_PLAYED_MSG triggered")

			if screenshotFrame.waitingForTimePlayed then
				screenshotFrame.waitingForTimePlayed = false

				TakeScreenshot()
			end
		end,
	},
}

---@class Event
---@field enabled boolean|nil Whether the user has enabled this event

---@class ShottaFrame contains state of addon, created from Blizzard's CreateFrame() function
---@field SetScript fun(self: ShottaFrame, callbackName: string, callback: fun(self: ShottaFrame, event: string, ...))
---@field blizzardTrigger {[string]: Trigger}
---@field waitingForTimePlayed boolean
local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(self, event, ...)
	screenshotFrame.blizzardTrigger[event]:triggerFunc(self, ...)
end)

---@param ts Trigger[]
---@return {[string]: Trigger}
local function makeBlizzardTriggerMap(ts)
	local blizzardTriggerMap = {}

	for id, details in pairs(ts) do
		if details.eventName then
			blizzardTriggerMap[details.eventName] = details
			blizzardTriggerMap[details.eventName].id = id
		end
	end

	return blizzardTriggerMap
end

---Conditionally register or unregister event based on enabled
---@param trigger string
---@param enabled boolean
function screenshotFrame:registerUnregisterEvent(trigger, enabled)
	local event = triggers[trigger]

	if enabled then
		event:register(self)
	else
		event:unregister(self)
	end
end

-- local function AddonLoadedEventHandler(self, event, addOnName)
-- 	if addOnName ~= Shotta.ADDON_NAME then
-- 		return
-- 	end
-- 	if event ~= "ADDON_LOADED" then
-- 		ns.PrintToChat(format("Got unsupported event %s, should be ADDON_LOADED", event))
-- 		return
-- 	end
--
-- 	---@type ShottaDatabase
-- 	Shotta.db = ns.FetchOrCreateDatabase(DB_DEFAULTS)
--
-- 	ns.InitializeOptions(self, triggers, screenshotFrame, icon)
--
-- 	icon:Register(Shotta.ADDON_NAME, shottaLDB, Shotta.db.profile.minimap)
--
-- 	--- Persist DB as SavedVariable since we've been using it as a local
-- 	ShottaDB = Shotta.db
--
-- 	screenshotFrame.blizzardTrigger = makeBlizzardTriggerMap(triggers)
--
-- 	for trigger, _ in pairs(triggers) do
-- 		local enabled = false
--
-- 		if Shotta.db.screenshottableEvents[trigger] then
-- 			---@type boolean enabled should always be there after this if check
-- 			enabled = Shotta.db.screenshottableEvents[trigger].enabled
-- 		end
--
-- 		screenshotFrame:registerUnregisterEvent(trigger, enabled)
-- 	end
--
-- 	for _, trigger in pairs(hiddenTriggers) do
-- 		screenshotFrame.blizzardTrigger["TIME_PLAYED_MSG"] = hiddenTriggers.timePlayed
-- 		trigger:register(screenshotFrame)
-- 	end
--
-- 	self:UnregisterEvent(event)
--
-- 	ns.PrintToChat(Shotta.VERSION .. " loaded. Use /shotta or /sh to open the options menu.")
-- end
--
-- local EventFrame = CreateFrame("Frame")
-- EventFrame:RegisterEvent("ADDON_LOADED")
-- EventFrame:SetScript("OnEvent", AddonLoadedEventHandler)
--
--SLASH_SHOTTA1, SLASH_SHOTTA2 = "/shotta", "/sh"
----
--SlashCmdList["SHOTTA"] = function()
--	-- Call this twice to ensure the correct category is selected
--	Settings.OpenToCategory(Shotta.ADDON_NAME)
--end
