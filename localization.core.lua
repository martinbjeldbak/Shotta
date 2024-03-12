-- Inspiration for this file: https://wowpedia.fandom.com/wiki/Localizing_an_addon
local _, ns = ...

-- Localization table
ns.T = {}
ns.T["checkboxText.channelChat"] = "On message in channel"
ns.T["checkboxText.movementStart"] = "On start moving (for easier debugging)"
ns.T["checkboxText.levelUp"] = "On level up"
ns.T["checkboxText.zoneChangedNewArea"] = "When discovering a new zone or area"
ns.T["checkboxText.zoneChanged"] = "When entering a different zone, building, etc."
ns.T["checkboxText.login"] = "On login"
ns.T["checkboxText.readyCheck"] = "On ready check"
ns.T["checkboxText.mailboxOpened"] = "On mailbox open"
ns.T["checkboxText.auctionWindowShow"] = "On auction house window open"
ns.T["checkboxText.groupFormed"] = "On joining or creating a group"
ns.T["checkboxText.tradeAccepted"] = "Trade window is accepted by a player"
ns.T["checkboxText.every5Minutes"] = "Every 5 minutes"
ns.T["checkboxText.every10Minutes"] = "Every 10 minutes"
ns.T["checkboxText.bossKill"] = "On boss kill, including raids"
ns.T["checkboxText.encounterEnd"] = "At end of an instanced encounter, such as a dungeon or raid encounter"
ns.T["checkboxText.questFinished"] = "Upon completion of a quest"
ns.T["checkboxText.lootItemRollWin"] = "Upon winning a loot roll"
ns.T["events"] = "Events"
ns.T["saveLocationHelpText.base"] = "Screenshots are saved to the default location for your operating system"
ns.T["saveLocationHelpText." .. WOW_PROJECT_MAINLINE] = ns.T["saveLocationHelpText.base"] .. [[


Windows:  C:\Program Files (x86)\World of Warcraft\_retail_\Screenshots
MacOS:     \World of Warcraft\_retail_\Screenshots]]
ns.T["saveLocationHelpText." .. WOW_PROJECT_WRATH_CLASSIC] = ns.T["saveLocationHelpText.base"] .. [[


Windows:  C:\Program Files (x86)\World of Warcraft\_classic_\Screenshots
MacOS:     \World of Warcraft\_classic_\Screenshots]]
ns.T["saveLocationHelpText." .. WOW_PROJECT_CLASSIC] = ns.T["saveLocationHelpText.base"] .. [[


Windows:  C:\Program Files (x86)\World of Warcraft\_classic_era_\Screenshots
MacOS:     \World of Warcraft\_classic_era_\Screenshots]]

setmetatable(ns.T, {
  __index = function(_, key)
    return format("FIXME: missing localization for '%s'", key)
  end
})
