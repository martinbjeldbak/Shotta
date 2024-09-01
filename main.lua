-- local _, ns = ...

local Shotta = LibStub("AceAddon-3.0"):NewAddon("Shotta", "AceEvent-3.0", "AceConsole-3.0")

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

local function TakeScreenshot(text)
	if text ~= nil then
		Shotta:Print(text)
	end

	Screenshot()
end

local function TakeUILessScreenshot(text)
	UIParent:Hide()

	TakeScreenshot(text)

	C_Timer.After(0.01, function()
		UIParent:Show()
	end)
end

local shottaLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Shotta", {
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
		screenshottableEvents = {
			["**"] = {
				enabled = false, -- disable all new events by default, except for...
			},
			login = true, -- enable this by default
		},
	},
}

local function setupBlizzardEvent()
	return {
		name = function(info)
			return L["checkboxText." .. info[1]]
		end,
		-- desc = "" -- TODO: implement descriptions
		type = "toggle",
		set = function(info, val)
			local triggerName = info[1]
			Shotta.db.profile.screenshottableEvents[triggerName] = val
			Shotta:conditionallyRegisterEvent(val, triggerName)
		end,
		get = function(info)
			local triggerName = info[1]
			return Shotta.db.profile.screenshottableEvents[triggerName]
		end,
	}
end

options = {
	type = "group",
	args = {
		enable = {
			name = "Enable",
			desc = "Enables / disables the addon",
			type = "toggle",
			set = function(info, val)
				Shotta.enabled = val
			end,
			get = function(info)
				return Shotta.enabled
			end,
		},
		PLAYER_LOGIN = setupBlizzardEvent(),
		CHAT_MSG_CHANNEL = setupBlizzardEvent(),
		PLAYER_LEVEL_UP = setupBlizzardEvent(),
		MAIL_SHOW = setupBlizzardEvent(),
		READY_CHECK = setupBlizzardEvent(),
		ZONE_CHANGED = setupBlizzardEvent(),
		ZONE_CHANGED_NEW_AREA = setupBlizzardEvent(),
		HEARTHSTONE_BOUND = setupBlizzardEvent(),
		PLAYER_STARTED_MOVING = setupBlizzardEvent(),
	},
}

---comment
---@param val boolean
---@param blizzardEevent string
function Shotta:conditionallyRegisterEvent(val, blizzardEevent)
	if val then
		--@alpha@
		Shotta:Print("Registering event " .. blizzardEevent)
		--@end-alpha@
		self:RegisterEvent(blizzardEevent)
	else
		--@alpha@
		Shotta:Print("Unregistering event " .. blizzardEevent)
		--@end-alpha@
		self:UnregisterEvent(blizzardEevent)
	end
end

function Shotta:PLAYER_LOGIN()
	--@alpha@
	Shotta:Print("Got event player login: taking screenshot")
	--@end-alpha@
	C_Timer.After(5, function()
		TakeScreenshot()
	end)
end

function Shotta:PLAYER_LEVEL_UP()
	-- TODO: implement these modifiers
	-- if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat then
	-- 	if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat.enabled then
	-- 		ChatFrame1Tab:Click()
	-- 	end
	-- end

	-- if Shotta.db.screenshottableEvents.levelUp.modifiers.showPlayed.enabled then
	-- 	screenshotFrame.waitingForTimePlayed = true
	-- 	RequestTimePlayed() -- trigger "TIME_PLAYED_MSG" event
	-- 	return
	-- end

	C_Timer.After(0.5, function()
		TakeScreenshot()
	end)
end

function Shotta:CHAT_MSG_CHANNEL()
	Shotta:Print("Got event player message")
	TakeScreenshot()
end

function Shotta:OnInitialize()
	-- do init tasks here, like loading the Saved Variables,
	-- or setting up slash commands.
	--
	self.db = LibStub("AceDB-3.0"):New("ShottaDBv2", defaults)

	LibStub("LibDBIcon-1.0"):Register("Shotta", shottaLDB, self.db.profile.minimap)

	local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	local acreg = LibStub("AceConfigRegistry-3.0")
	acreg:RegisterOptionsTable("Shotta config", options)
	acreg:RegisterOptionsTable("Shotta profiles", profileOptions)

	local acdia = LibStub("AceConfigDialog-3.0")
	acdia:AddToBlizOptions("Shotta config", "Shotta")
	acdia:AddToBlizOptions("Shotta profiles", "Profiles", "Shotta")

	for event, enabled in pairs(self.db.profile.screenshottableEvents) do
		if enabled then
			Shotta:RegisterEvent("PLAYER_LOGIN")
		end
	end

	self:Print(self.VERSION .. " loaded!")
end

function Shotta:OnEnable()
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from
	-- the game that wasn't available in OnInitialize
	--
end

function Shotta:OnDisable()
	-- Unhook, Unregister Events, Hide frames that you created.
	-- You would probably only use an OnDisable if you want to
	-- build a "standby" mode, or be able to toggle modules on/off.
end

local function everyXSecond(seconds, callback)
	C_Timer.After(seconds, function()
		local continue = callback()
		if not continue then
			return
		end

		everyXSecond(seconds, callback)
	end)
end

--- Triggers the callback function every `minutes` minutes
--- @param minutes integer
--- @param callback function
local function everyXMinute(minutes, callback)
	everyXSecond(minutes * 60, callback)
end

local function registerEvent(self, frame)
	frame:RegisterEvent(self.eventName)
end

local function unregisterEvent(self, frame)
	frame:UnregisterEvent(self.eventName)
end

--- @param minutes integer
--- @return Trigger
local function setupTimedTrigger(minutes)
	return {
		registered = true,
		register = function(self)
			self.registered = true
			everyXMinute(minutes, function()
				if self.registered then
					ns.PrintToChat(format("Timer for %s minutes triggered, taking screenshot!", minutes))

					TakeScreenshot()
				end
				return self.registered
			end)
		end,
		unregister = function(self)
			self.registered = false
		end,
	}
end

---@alias triggerId string Key use to define the event that Shotta can listen to. Unique.

---@class Trigger
---@field eventName string|nil Name of Blizzard event, or nil if custom event
---@field register (fun(self, frame): nil)
---@field unregister (fun(self, frame): nil)
---@field triggerFunc (fun(self: Trigger, shottaFrame: ShottaFrame, ...): nil)|nil Function to execute if not to take a screenshot straight away
---@field id? string sometimes added when top level triggerId not available, see blizzardTriggerMap

---Creates a Trigger table given an in-game triggered event
---@param eventName string of the Blizzard event, one of https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)
---@return Trigger Trigger table implmementing required functions for event
-- local function setupBlizzardEvent(eventName)
-- 	return {
-- 		eventName = eventName,
-- 		register = registerEvent,
-- 		unregister = unregisterEvent,
-- 		triggerFunc = function(self)
-- 			ns.Debug(format('Got event "%s", taking screenshot!', ns.T[format("checkboxText.%s", self.id)]:lower()))
-- 			TakeScreenshot()
-- 		end,
-- 	}
-- end

---@type { [triggerId]: Trigger }
local triggers = {
	login = {
		eventName = "PLAYER_LOGIN",
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function()
			C_Timer.After(5, function()
				TakeScreenshot()
			end)
		end,
	},
	channelChat = setupBlizzardEvent("CHAT_MSG_CHANNEL"),
	levelUp = {
		eventName = "PLAYER_LEVEL_UP",
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function(_, screenshotFrame)
			if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat then
				if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat.enabled then
					ChatFrame1Tab:Click()
				end
			end

			if Shotta.db.screenshottableEvents.levelUp.modifiers.showPlayed.enabled then
				screenshotFrame.waitingForTimePlayed = true
				RequestTimePlayed() -- trigger "TIME_PLAYED_MSG" event
				return
			end

			C_Timer.After(0.5, function()
				TakeScreenshot()
			end)
		end,
		modifiers = { "showPlayed", "showMainChat" },
	},
	mailboxOpened = setupBlizzardEvent("MAIL_SHOW"),
	readyCheck = setupBlizzardEvent("READY_CHECK"),
	zoneChanged = setupBlizzardEvent("ZONE_CHANGED"),
	zoneChangedNewArea = setupBlizzardEvent("ZONE_CHANGED_NEW_AREA"),
	hearthstoneBound = setupBlizzardEvent("HEARTHSTONE_BOUND"),
	--@debug@
	movementStart = {
		eventName = "PLAYER_STARTED_MOVING",
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function(self, screenshotFrame)
			screenshotFrame.waitingForTimePlayed = true
			ns.PrintToChat(
				format('Got event "%s", should be taking screenshot!', ns.T[format("checkboxText.%s", self.id)]:lower())
			)
			-- Comment back to really take a screenshot
			-- TakeScreenshot()
		end,
	},
	--@end-debug@
	auctionWindowShow = setupBlizzardEvent("AUCTION_HOUSE_SHOW"),
	groupFormed = setupBlizzardEvent("GROUP_FORMED"),
	tradeAccepted = {
		eventName = "TRADE_ACCEPT_UPDATE",
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function(playerAccepted)
			if playerAccepted == 1 then
				TakeScreenshot()
			end
		end,
	},
	bossKill = setupBlizzardEvent("BOSS_KILL"),
	encounterEnd = setupBlizzardEvent("ENCOUNTER_END"),
	questFinished = setupBlizzardEvent("QUEST_TURNED_IN"),
	lootItemRollWin = setupBlizzardEvent("LOOT_ITEM_ROLL_WON"),
	every5Minutes = setupTimedTrigger(5),
	every10Minutes = setupTimedTrigger(10),
	every30Minutes = setupTimedTrigger(30),
	onDeath = setupBlizzardEvent("PLAYER_DEAD"),
	chatAllEmotesWithToken = {
		eventName = "CHAT_MSG_TEXT_EMOTE",
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function()
			C_Timer.After(0.5, function()
				TakeScreenshot()
			end)
		end,
	},
}

if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) or (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC) then
	triggers["achievementEarned"] = {
		eventName = "ACHIEVEMENT_EARNED",
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function()
			C_Timer.After(0.5, function()
				TakeScreenshot()
			end)
		end,
	}
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
