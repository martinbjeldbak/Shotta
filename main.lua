---@class Shotta
---@field timerEvents { [number]: any }
local Shotta = LibStub("AceAddon-3.0"):NewAddon("Shotta", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

Shotta:RegisterChatCommand("shotta", "OpenToCategory")
Shotta:RegisterChatCommand("sh", "OpenToCategory")

---@type string
Shotta.ADDON_NAME = "Shotta"
---@type string
Shotta.VERSION = "@project-version@"
--@alpha@
Shotta.VERSION = "main" -- hardcode for debuggability
--@end-alpha@

---@type string
Shotta.DISCORD_LINK = "https://discord.gg/MHqGRpZxbB"
Shotta.GITHUB_LINK = "https://github.com/martinbjeldbak/shotta"

---@type string
Shotta.UPDATED_TIMESTAMP = "@project-timestamp@"
--@alpha@
Shotta.UPDATED_TIMESTAMP = "1725716326" -- hardcode for debuggability
--@end-alpha@

---@type boolean
Shotta.TRANSLATE_FAIL_SILENTLY = true
--@alpha@
Shotta.TRANSLATE_FAIL_SILENTLY = false
--@end-alpha@

local L = LibStub("AceLocale-3.0"):GetLocale("Shotta", Shotta.TRANSLATE_FAIL_SILENTLY)

function Shotta:OpenToCategory()
	Settings.OpenToCategory(self.ADDON_NAME)
end

local function localizedCheckboxName(info)
	return L["checkboxText." .. info[#info]]
end

---Converts minutes to seconds
---@param min number how many minutes should be converted to seconds
---@return number minutes in seconds
local function toMinutes(min)
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
				-- enable these events by default
				PLAYER_LOGIN = true,
				PLAYER_LEVEL_UP = true,
				PLAYER_DEAD = true,
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
		name = localizedCheckboxName,
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
				name = localizedCheckboxName,
				type = "group",
				order = 0,
				inline = true,
				args = {
					hideMinimap = {
						name = localizedCheckboxName,
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
				name = localizedCheckboxName,
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
				name = localizedCheckboxName,
				type = "group",
				inline = true,
				order = 1,
				args = {
					every_5_minutes = self:setupTimerEvent(5, 0),
					every_10_minutes = self:setupTimerEvent(10, 1),
					every_30_minutes = self:setupTimerEvent(30, 2),
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

---Computes number of days the input day is from today
---@param sourceDate string|number The iso timestamp of requested day
---@return integer number of days since sourceDate
local function daysAgo(sourceDate)
	local currentTime = time()
	local sourceDatetime = tonumber(sourceDate)
	local diffSeconds = currentTime - sourceDatetime
	return math.floor(diffSeconds / (24 * 60 * 60))
end

local function folderName()
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		return "retail"
	elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
		return "classic"
	elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		return "classic_era"
	end

	return "unknown"
end

local aboutOptions = {
	type = "group",
	name = L["about"],
	args = {
		version = {
			name = format("Version: %s", Shotta.VERSION),
			order = 0,
			type = "description",
		},
		date = {
			name = format(
				"Date: %s (%s days ago)",
				date("%x", Shotta.UPDATED_TIMESTAMP),
				daysAgo(Shotta.UPDATED_TIMESTAMP)
			),
			order = 1,
			type = "description",
		},
		screenshotLocation = {
			name = format(L["saveLocationHelpText"], folderName(), folderName()),
			order = 5,
			fontSize = "large",
			type = "description",
		},
		discord = {
			name = format("%s (%s)", L["joinDiscord"], L["pressCtrlC"]),
			type = "input",
			order = 6,
			width = "double",
			get = function(info)
				return Shotta.DISCORD_LINK
			end,
		},
		code = {
			name = format("%s (%s)", L["gitHubLink"], L["pressCtrlC"]),
			type = "input",
			order = 7,
			width = "double",
			get = function(info)
				return Shotta.GITHUB_LINK
			end,
		},

		love = {
			name = "For Nandar. Made with love in Melbourne, Australia",
			order = 80,
			fontSize = "small",
			type = "description",
		},
	},
}

---comment
---@param minutes integer how many minutes to repeat the timer for
---@param order integer order in the Ace3 options table to have, see docs https://legacy.curseforge.com/wow/addons/ace3/pages/ace-config-3-0-options-tables
---@return table
function Shotta:setupTimerEvent(minutes, order)
	return {
		name = localizedCheckboxName,
		type = "toggle",
		order = order,
		set = function(info, val)
			self.db.profile.events.timer[minutes] = val

			self:conditionallyEnableTimer(val, minutes)
		end,
		get = function(info)
			return self.db.profile.events.timer[minutes]
		end,
	}
end

function Shotta:conditionallyEnableTimer(val, minutes)
	if val then
		--@alpha@
		Shotta:Print(format("Enabling %s minute timer", minutes))
		--@end-alpha@
		self.timerEvents[minutes] = self:ScheduleRepeatingTimer("RepeatingScreenshotTimer", toMinutes(minutes))
	else
		--@alpha@
		Shotta:Print(format("Cancelling %s minute timer", minutes))
		--@end-alpha@
		self:CancelTimer(self.timerEvents[minutes])
	end
end

function Shotta:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ShottaDBv2", defaults)
	self.timerEvents = {}

	LibStub("LibDBIcon-1.0"):Register("Shotta", iconOptions, self.db.profile.minimap)

	local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	local acreg = LibStub("AceConfigRegistry-3.0")
	acreg:RegisterOptionsTable("Shotta", self:getConfig())
	acreg:RegisterOptionsTable("Shotta about", aboutOptions)
	acreg:RegisterOptionsTable("Shotta profiles", profileOptions)

	local acdia = LibStub("AceConfigDialog-3.0")
	acdia:AddToBlizOptions("Shotta", "Shotta")
	acdia:AddToBlizOptions("Shotta profiles", "Profiles", "Shotta")
	acdia:AddToBlizOptions("Shotta about", "About", "Shotta")

	Shotta:Print(self.VERSION .. " loaded!")
end

function Shotta:OnEnable()
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from
	-- the game that wasn't available in OnInitialize
	--
	for event, enabled in pairs(self.db.profile.events.blizzard) do
		if enabled then
			self:conditionallyRegisterBlizzardEvent(true, event)
		end
	end

	for min, enabled in pairs(self.db.profile.events.timer) do
		if enabled then
			self:conditionallyEnableTimer(true, min)
		end
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
