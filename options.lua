local _, ns = ...

---Convert a boolean into humanized enabled/disabled
---@param option boolean
---@return string "Enabled" or "Disabled" depending on boolean value
local function EnabledHumanized(option)
  if option then
    return "enabled"
  else
    return "disabled"
  end
end

---Sort table by keys. Source: https://www.lua.org/pil/19.3.html
---@generic T
---@param t T[]
---@param f fun(a: T, b: T)
---@return function
local function pairsByKeys(t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0             -- iterator variable
  local iter = function() -- iterator function
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i], t[a[i]]
    end
  end
  return iter
end

---Compares the translated checkbox text values to support ordering
---@param a string
---@param b string
---@return boolean
local function compareByCheckboxText(a, b)
  return ns.T[format("checkboxText.%s", a)]:upper() < ns.T[format("checkboxText.%s", b)]:upper()
end

---Initialize addon options panel
---@param frame any
---@param db ShottaDatabase
---@param triggers Trigger
---@param screenshotFrame any
---@param addonName string
---@param version string
local function InitializeOptions(frame, db, triggers, screenshotFrame, addonName, version)
  frame.panel = CreateFrame("Frame")
  frame.panel.name = addonName

  local title = CreateFrame("Frame", nil, frame.panel)
  title:SetPoint("TOPLEFT", frame.panel, "TOPLEFT")
  title:SetPoint("TOPRIGHT", frame.panel, "TOPRIGHT")
  title:SetHeight(70)
  title.frameTitle = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title.frameTitle:SetPoint("TOP", title, "TOP", 0, -20);
  title.frameTitle:SetText(addonName .. " " .. version)

  local header = CreateFrame("Frame", nil, title)
  header:SetHeight(18)
  header:SetPoint("TOPLEFT", title, "BOTTOMLEFT")
  header:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT")
  header.label = header:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
  header.label:SetPoint("TOP")
  header.label:SetPoint("BOTTOM")
  header.label:SetJustifyH("CENTER")
  header.label:SetText(ns.T["events"])
  header.left = header:CreateTexture(nil, "BACKGROUND")
  header.left:SetHeight(8)
  header.left:SetPoint("LEFT", 10, 0)
  header.left:SetPoint("RIGHT", header.label, "LEFT", -5, 0)
  header.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  header.left:SetTexCoord(0.81, 0.94, 0.5, 1)
  header.right = header:CreateTexture(nil, "BACKGROUND")
  header.right:SetHeight(8)
  header.right:SetPoint("RIGHT", -10, 0)
  header.right:SetPoint("LEFT", header.label, "RIGHT", 5, 0)
  header.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  header.right:SetTexCoord(0.81, 0.94, 0.5, 1)
  header.left:SetPoint("RIGHT", header.label, "LEFT", -5, 0)

  -- Create checkboxes for all events we should listen to
  local offset = -20

  for k, _ in pairsByKeys(triggers, compareByCheckboxText) do
    local cb = CreateFrame("CheckButton", nil, header, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, offset)
    cb.Text:SetText(ns.T["checkboxText." .. k])
    cb:HookScript("OnClick", function()
      local isChecked = cb:GetChecked()

      if isChecked then
        if db.screenshottableEvents[k] == nil then
          db.screenshottableEvents[k] = {}
        end
        db.screenshottableEvents[k].enabled = true
      else
        db.screenshottableEvents[k].enabled = nil
      end

      screenshotFrame:registerUnregisterEvent(k, isChecked)

      ns.Debug(format("%s is now %s", k, EnabledHumanized(isChecked)))
    end)

    offset = offset - 20

    local enabled = false
    if db.screenshottableEvents[k] then
      enabled = db.screenshottableEvents[k].enabled
    end

    cb:SetChecked(enabled)
  end

  --- Footer
  local footerOffset = -400
  local t = CreateFrame("Frame", nil, frame.panel)
  t:SetPoint("TOPLEFT", header, "TOPLEFT")
  t:SetPoint("TOPRIGHT", header, "TOPRIGHT")
  t:SetHeight(30)
  t.helpText = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t.helpText:SetFont("", 10)
  t.helpText:SetJustifyH("LEFT")
  t.helpText:SetPoint("TOP", t, "TOP", 0, footerOffset);
  t.helpText:SetText(ns.T["saveLocationHelpText." .. WOW_PROJECT_ID ])

  t.love = title:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  t.love:SetPoint("TOP", t, "TOP", 0, footerOffset-100);
  t.love:SetText("Made with love in Melbourne, Australia")



  InterfaceOptions_AddCategory(frame.panel)
end


ns.InitializeOptions = InitializeOptions
