-- The minimap entry, registered through LibDataBroker and LibDBIcon. Shotta lives in the minimap's addon
-- compartment (the dropdown next to the Minimap); the floating ring button is opt-in via `minimap.floatButton`.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta
local L = ns.L

local TakeScreenshot = ns.TakeScreenshot
local TakeUILessScreenshot = ns.TakeUILessScreenshot

local iconOptions = LibStub('LibDataBroker-1.1'):NewDataObject('Shotta', {
  type = 'data source',
  text = 'Shotta',
  icon = 'Interface\\AddOns\\Shotta\\icons\\logo',
  OnClick = function()
    -- Left click opens settings (the conventional launcher gesture, and the only sensible one for a compartment
    -- entry). Screenshots need a modifier so the plain click never writes a file by accident.
    if IsControlKeyDown() then
      TakeScreenshot()
    elseif IsShiftKeyDown() then
      TakeUILessScreenshot()
    else
      Shotta:OpenToCategory()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip or not tooltip.AddLine then
      return
    end

    -- AddLine defaults to yellow text when no colour is passed, so the hint lines pass white explicitly.
    -- Colouring here rather than in the locale strings keeps the translations free of escape codes.
    local r, g, b = 1, 1, 1

    tooltip:AddLine 'Shotta'
    tooltip:AddLine ' '
    tooltip:AddLine(L['minimap.click'], r, g, b)
    tooltip:AddLine(L['minimap.ctrlClick'], r, g, b)
    tooltip:AddLine(L['minimap.shiftClick'], r, g, b)
  end,
})

---AceDB only copies defaults into sections it creates itself, so a profile saved before `minimap` was added
---to the defaults reaches this function with no `minimap` table. LibDBIcon treats a nil db as "not hidden" but
---never shows the button, which is why the icon silently went missing. Ensure the table exists before handing
---it over.
---This only guarantees shape: it must never write `hide`, because AceConfig re-reads the option's `get` straight
---after `set`, and a getter that recomputed `hide` would undo the toggle it was just asked to apply.
---@return ShottaMinimap
function Shotta:MinimapDb()
  local minimap = self.db.profile.minimap
  if type(minimap) ~= 'table' then
    minimap = {}
    self.db.profile.minimap = minimap
  end

  if type(minimap.floatButton) ~= 'boolean' then
    minimap.floatButton = false
  end

  -- Shotta's entry lives in the minimap's addon compartment; this is not a user setting, so it is forced on.
  minimap.showInCompartment = true

  -- minimapPos is deliberately not seeded here. LibDBIcon writes it every frame while the button is dragged, so
  -- recreating it from this function (which the options `get` calls) would snap the button back mid-drag. It is
  -- a default in Shotta.lua instead, which only applies to profiles that do not already have a value.

  return minimap
end

---Show or hide the optional minimap ring button. `hide` is the inverse of `floatButton` because that is the
---field LibDBIcon reads, both at registration and here. This is the only place `hide` is written.
---@param float boolean Whether the ring button should be visible
function Shotta:SetMinimapFloat(float)
  local minimap = self:MinimapDb()
  minimap.floatButton = float
  minimap.hide = not float

  local icons = LibStub 'LibDBIcon-1.0'
  if float then
    icons:Show 'Shotta'
  else
    icons:Hide 'Shotta'
  end
end

function Shotta:RegisterMinimapIcon()
  local minimap = self:MinimapDb()
  -- Registration reads `hide` to decide whether the ring button is shown at login, so apply the saved choice
  -- before handing the table over. Register also copies it into the compartment when showInCompartment is true.
  minimap.hide = not minimap.floatButton
  LibStub('LibDBIcon-1.0'):Register('Shotta', iconOptions, minimap)
end
