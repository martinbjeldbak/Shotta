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
---@field triggerFunc (fun(...): nil)|nil Function to execute if not to take a screenshot straight away
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
			--@alpha@
			ns.PrintToChat(
				format('Got event "%s", taking screenshot!', ns.T[format("checkboxText.%s", self.id)]:lower())
			)
			--@end-alpha@
			TakeScreenshot()
		end,
	}
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
		triggerFunc = function()
			C_Timer.After(0.5, function()
				TakeScreenshot()
			end)
		end,
	},
	mailboxOpened = setupBlizzardEvent("MAIL_SHOW"),
	readyCheck = setupBlizzardEvent("READY_CHECK"),
	zoneChanged = setupBlizzardEvent("ZONE_CHANGED"),
	zoneChangedNewArea = setupBlizzardEvent("ZONE_CHANGED_NEW_AREA"),
	hearthstoneBound = setupBlizzardEvent("HEARTHSTONE_BOUND"),
	--@alpha@
	movementStart = setupBlizzardEvent("PLAYER_STARTED_MOVING"),
	--@end-alpha@
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
	questFinished = setupBlizzardEvent("QUEST_COMPLETE"),
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
	triggers["achievementEarned"] = setupBlizzardEvent("ACHIEVEMENT_EARNED")
end

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

local screenshotFrame = CreateFrame("Frame")
screenshotFrame:SetScript("OnEvent", function(_, event, ...)
	screenshotFrame.blizzardTrigger[event]:triggerFunc(...)
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

local shottaLDB = LibStub("LibDataBroker-1.1"):NewDataObject(Shotta.ADDON_NAME, {
	type = "data source",
	text = Shotta.ADDON_NAME,
	icon = 237290,
	OnClick = function()
		if IsShiftKeyDown() then
			if SettingsPanel:IsShown() then
				HideUIPanel(SettingsPanel)
			else
				HideUIPanel(SettingsPanel)
				InterfaceOptionsFrame_OpenToCategory(Shotta.ADDON_NAME)
			end
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
		tooltip:AddLine("Click to take a UI-less screenshot")
		tooltip:AddLine("Control-click to take a screenshot")
		tooltip:AddLine(" ")
		tooltip:AddLine("Shift-click to open settings")
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

	---@type ShottaDatabase
	local db = ns.FetchOrCreateDatabase(DB_DEFAULTS)

	local version = Shotta.VERSION

	ns.InitializeOptions(self, db, triggers, screenshotFrame, Shotta.ADDON_NAME, version, icon)

	icon:Register(Shotta.ADDON_NAME, shottaLDB, db.profile.minimap)

	--- Persist DB as SavedVariable since we've been using it as a local
	ShottaDB = db

	screenshotFrame.blizzardTrigger = makeBlizzardTriggerMap(triggers)

	for trigger, _ in pairs(triggers) do
		local enabled = false

		if db.screenshottableEvents[trigger] then
			---@type boolean enabled should always be there after this if check
			enabled = db.screenshottableEvents[trigger].enabled
		end

		screenshotFrame:registerUnregisterEvent(trigger, enabled)
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
