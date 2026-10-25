-- The minimap button, shown through LibDataBroker and LibDBIcon.
local _, ns = ...
---@type Shotta
local Shotta = ns.Shotta
local L = ns.L

local TakeScreenshot = ns.TakeScreenshot
local TakeUILessScreenshot = ns.TakeUILessScreenshot

local iconOptions = LibStub('LibDataBroker-1.1'):NewDataObject('Shotta', {
  type = 'data source',
  text = 'Shotta',
  icon = 237290,
  OnClick = function()
    if IsShiftKeyDown() then
      Shotta:OpenToCategory()
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

    tooltip:AddLine 'Shotta'
    tooltip:AddLine ' '
    tooltip:AddLine(L['minimap.click'])
    tooltip:AddLine(L['minimap.ctrlClick'])
    tooltip:AddLine ' '
    tooltip:AddLine(L['minimap.shiftClick'])
  end,
})

function Shotta:RegisterMinimapIcon()
  LibStub('LibDBIcon-1.0'):Register('Shotta', iconOptions, self.db.profile.minimap)
end
