-- Inspiration for this file: https://wowpedia.fandom.com/wiki/Localizing_an_addon
local _, ns = ...

-- Localization table
ns.T = {}
ns.T["checkboxText.channelChat"] = "On message in channel"
ns.T["checkboxText.movementStart"] = "On start moving"
ns.T["checkboxText.levelUp"] = "On level up"
ns.T["checkboxText.zone"] = "When entering a new zone or area"
ns.T["checkboxText.login"] = "On login"
ns.T["checkboxText.readyCheck"] = "On ready check"

setmetatable(ns.T, {
  __index = function(L, key)
    return format("FIXME: missing localization for '%s'", key)
  end
})
