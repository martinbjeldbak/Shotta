-- Inspiration for this file: https://wowpedia.fandom.com/wiki/Localizing_an_addon
local _, ns = ...


--- Returns folder name of current client, used to identify where screenshots
--- are saved. See https://wowpedia.fandom.com/wiki/WOW_PROJECT_ID
---@return string ProjectKind folder used by the current game client
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

-- Localization table
ns.T = {}
ns.T["checkboxText.channelChat"] = "On message in channel"
ns.T["checkboxText.movementStart"] = "On start moving (for easier debugging)"
ns.T["checkboxText.levelUp"] = "On level up"
ns.T["checkboxText.zoneChangedNewArea"] = "When entering a new zone or area"
ns.T["checkboxText.zoneChanged"] = "When entering a different zone, building, etc."
ns.T["checkboxText.login"] = "On login"
ns.T["checkboxText.readyCheck"] = "On ready check"
ns.T["checkboxText.mailboxOpened"] = "On mailbox open"
ns.T["checkboxText.auctionWindowShow"] = "On auction house window open"
ns.T["checkboxText.groupFormed"] = "On joining or creating a group"
ns.T["checkboxText.tradeAccepted"] = "Trade window is accepted by a player"
ns.T["checkboxText.every5Minutes"] = "Every 5 minutes"
ns.T["checkboxText.every10Minutes"] = "Every 10 minutes"
ns.T["checkboxText.onDeath"] = "On death"
ns.T["checkboxText.chatAllEmotesWithToken"] = "On all emotes with an emote token"
ns.T["checkboxText.bossKill"] = "On boss kill, including raids"
ns.T["checkboxText.encounterEnd"] = "At end of a dungeon or raid encounter"
ns.T["checkboxText.questFinished"] = "Upon completion of a quest"
ns.T["checkboxText.lootItemRollWin"] = "Upon winning a loot roll"
ns.T["checkboxText.profile.hideMiniMap"] = "Hide minimap icon"
ns.T["events"] = "Events"
ns.T["settings"] = "Settings"
ns.T["about"] = "About"
ns.T["saveLocationHelpText"] = format([[
Screenshots are saved to the default location for your operating system


Windows:  C:\Program Files (x86)\World of Warcraft\_%s_\Screenshots
MacOS:     \World of Warcraft\_%s_\Screenshots]], folderName(), folderName())

setmetatable(ns.T, {
  __index = function(_, key)
    return format("FIXME: missing localization for '%s'", key)
  end
})
