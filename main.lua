local _, ns = ...

Shotta = {}
Shotta.ADDON_NAME = "Shotta"
Shotta.VERSION = "@project-version@"
Shotta.COLOR = "245DC6FF"

local function TakeScreenshot(text)
	if text ~= nil then
		ns.PrintToChat(text)
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
local function setupBlizzardEvent(eventName)
	return {
		eventName = eventName,
		register = registerEvent,
		unregister = unregisterEvent,
		triggerFunc = function(self)
			ns.Debug(format('Got event "%s", taking screenshot!', ns.T[format("checkboxText.%s", self.id)]:lower()))
			TakeScreenshot()
		end,
	}
end

---Prints an identical message to chat as if player typed "/played"
---@param formatString string Lozalised format string, takes 4 args
---@param totalMinutes number retrieved as args from event TIME_PLAYED_MSG
local function printTimePlayedToChat(formatString, totalMinutes)
	local systemMessageSettings = ChatTypeInfo["SYSTEM"]
	local days, hours, minutes, seconds = ns.MinutesToDaysHoursMinutesSeconds(totalMinutes)
	DEFAULT_CHAT_FRAME:AddMessage(
		format(formatString, days, hours, minutes, seconds),
		systemMessageSettings.r,
		systemMessageSettings.g,
		systemMessageSettings.b
	)
end

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
			if Shotta.db.screenshottableEvents.levelUp.modifiers.showMainChat.enabled then
				ChatFrame1Tab:Click()
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
		---@param totalTimePlayed integer in minutes
		---@param timePlayedThisLevel integer in minutes
		triggerFunc = function(_, screenshotFrame, totalTimePlayed, timePlayedThisLevel)
			ns.Debug("TIME_PLAYED_MSG triggered")

			if screenshotFrame.waitingForTimePlayed then
				screenshotFrame.waitingForTimePlayed = false

				printTimePlayedToChat(ns.T["totalTimePlayedFormat"], totalTimePlayed)
				printTimePlayedToChat(ns.T["timePlayedThisLevelFormat"], timePlayedThisLevel)
				TakeScreenshot()
			end
		end,
	},
}

---@class Event
---@field enabled boolean|nil Whether the user has enabled this event

---@class ShottaDatabase
---@field screenshottableEvents { [triggerId]: Event }
local DB_DEFAULTS = {
	screenshottableEvents = {
		login = { enabled = true },
		levelUp = { enabled = true },
		encounterEnd = { enabled = true },
	},
	profile = { minimap = { hide = false } },
}

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
function screenshotFrame:registerUnregisterEvent(ts, trigger, enabled)
	local event = ts[trigger]

	if enabled then
		event:register(self)
	else
		event:unregister(self)
	end
end

local shottaLDB = LibStub("LibDataBroker-1.1"):NewDataObject(Shotta.ADDON_NAME, {
	type = "data source",
	text = Shotta.ADDON_NAME,
	icon = 237290,
	OnClick = function()
		if IsShiftKeyDown() then
			HideUIPanel(SettingsPanel)
			InterfaceOptionsFrame_OpenToCategory(Shotta.ADDON_NAME)
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

		tooltip:AddLine(Shotta.ADDON_NAME)
		tooltip:AddLine(" ")
		tooltip:AddLine(ns.T["minimap.click"])
		tooltip:AddLine(ns.T["minimap.ctrlClick"])
		tooltip:AddLine(" ")
		tooltip:AddLine(ns.T["minimap.shiftClick"])
	end,
})
local icon = LibStub("LibDBIcon-1.0")

local function AddonLoadedEventHandler(self, event, addOnName)
	if addOnName ~= Shotta.ADDON_NAME then
		return
	end
	if event ~= "ADDON_LOADED" then
		ns.PrintToChat(format("Got unsupported event %s, should be ADDON_LOADED", event))
		return
	end

	local version = Shotta.VERSION

	---@type ShottaDatabase
	Shotta.db = ns.FetchOrCreateDatabase(DB_DEFAULTS)

	ns.InitializeOptions(self, triggers, screenshotFrame, Shotta.ADDON_NAME, version, icon)

	icon:Register(Shotta.ADDON_NAME, shottaLDB, Shotta.db.profile.minimap)

	--- Persist DB as SavedVariable since we've been using it as a local
	ShottaDB = Shotta.db

	screenshotFrame.blizzardTrigger = makeBlizzardTriggerMap(triggers)

	for trigger, _ in pairs(triggers) do
		local enabled = false

		if Shotta.db.screenshottableEvents[trigger] then
			---@type boolean enabled should always be there after this if check
			enabled = Shotta.db.screenshottableEvents[trigger].enabled
		end

		screenshotFrame:registerUnregisterEvent(triggers, trigger, enabled)
	end

	for _, trigger in pairs(hiddenTriggers) do
		screenshotFrame.blizzardTrigger["TIME_PLAYED_MSG"] = hiddenTriggers.timePlayed
		trigger:register(screenshotFrame)
	end

	self:UnregisterEvent(event)

	ns.PrintToChat(version .. " loaded. Use /shotta or /sh to open the options menu.")
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", AddonLoadedEventHandler)

SLASH_SHOTTA1, SLASH_SHOTTA2 = "/shotta", "/sh"

SlashCmdList["SHOTTA"] = function()
	InterfaceOptionsFrame_OpenToCategory(Shotta.ADDON_NAME)
	-- Call this twice to ensure the correct category is selected
	InterfaceOptionsFrame_OpenToCategory(Shotta.ADDON_NAME)
end
