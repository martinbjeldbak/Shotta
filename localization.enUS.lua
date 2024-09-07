-- Inspiration for this file: https://wowpedia.fandom.com/wiki/Localizing_an_addon
-- local _, ns = ...

local T = LibStub("AceLocale-3.0"):NewLocale("Shotta", "enUS", true)

T["checkboxText.CHAT_MSG_CHANNEL"] = "On message in channel"
T["checkboxText.PLAYER_STARTED_MOVING"] = "On start moving (for easier debugging)"
T["checkboxText.PLAYER_LEVEL_UP"] = "On level up"
T["checkboxText.PLAYER_LEVEL_UP.modifiers.showPlayed"] = "Print /played in chat"
T["checkboxText.PLAYER_LEVEL_UP.modifiers.showMainChat"] = "Show main chat window"
T["checkboxText.ZONE_CHANGED_NEW_AREA"] = "When entering a new zone or area"
T["checkboxText.ZONE_CHANGED"] = "When entering a different zone, building, etc."
T["checkboxText.PLAYER_LOGIN"] = "On login"
T["checkboxText.READY_CHECK"] = "On ready check"
T["checkboxText.MAIL_SHOW"] = "On mailbox open"
T["checkboxText.AUCTION_HOUSE_SHOW"] = "On auction house window open"
T["checkboxText.GROUP_FORMED"] = "On joining or creating a group"
T["checkboxText.TRADE_ACCEPT_UPDATE"] = "Trade window is accepted by a player"
T["checkboxText.every_5_minutes"] = "Every 5 minutes"
T["checkboxText.every_10_minutes"] = "Every 10 minutes"
T["checkboxText.every_30_minutes"] = "Every 30 minutes"
T["checkboxText.PLAYER_DEAD"] = "On death"
T["checkboxText.chatAllEmotesWithToken"] = "On all emotes with an emote token"
T["checkboxText.BOSS_KILL"] = "On boss kill, including raids"
T["checkboxText.ENCOUNTER_END"] = "At end of a dungeon or raid encounter"
T["checkboxText.QUEST_TURNED_IN"] = "Upon completion of a quest"
T["checkboxText.HEARTHSTONE_BOUND"] = "When binding your hearthstone"
T["checkboxText.LOOT_ITEM_ROLL_WON"] = "Upon winning a loot roll"
T["checkboxText.profile.hideMiniMap"] = "Hide minimap icon"
T["checkboxText.achievementEarned"] = "Upon earning an achievement"
T["events"] = "Events"
T["settings"] = "Settings"
T["about"] = "About"
T["saveLocationHelpText"] = [[
Screenshots are saved to the default location for your operating system


Windows:  C:\Program Files (x86)\World of Warcraft\_%s_\Screenshots
MacOS:     \World of Warcraft\_%s_\Screenshots]]
T["minimap.click"] = "Click to take a UI-less screenshot"
T["minimap.ctrlClick"] = "Control-click to take a screenshot"
T["minimap.shiftClick"] = "Shift-click to open settings"
T["pressCtrlC"] = "Press Ctrl+C to copy the URL to your clipboard"
T["joinDiscord"] = "Join our Discord!"
