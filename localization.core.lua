-- Inspiration for this file: https://wowpedia.fandom.com/wiki/Localizing_an_addon
local _, ns = ...

-- Localization table
ns.T = {}
ns.T["checkboxText.channelChat"] = "On message in channel"
ns.T["checkboxText.movementStart"] = "On start moving (for easier debugging)"
ns.T["checkboxText.levelUp"] = "On level up"
ns.T["checkboxText.zoneChanged"] = "When entering a new zone or area"
ns.T["checkboxText.login"] = "On login"
ns.T["checkboxText.readyCheck"] = "On ready check"
ns.T["checkboxText.mailboxOpened"] = "On mailbox open"
ns.T["checkboxText.auctionWindowShow"] = "On auction house window open"

setmetatable(ns.T, {
  __index = function(_, key)
    return format("FIXME: missing localization for '%s'", key)
  end
})
