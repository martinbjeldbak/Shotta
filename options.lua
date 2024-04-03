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
local function InitializeOptions(frame, db, triggers, screenshotFrame, addonName, version, icon)
  frame.panel = CreateFrame("Frame")
  frame.panel.name = addonName

  local tabFrame = CreateFrame("Frame", nil, frame.panel)
  tabFrame:SetPoint("TOPLEFT", frame.panel, "TOPLEFT")
  tabFrame:SetPoint("TOPRIGHT", frame.panel, "TOPRIGHT")
  tabFrame:SetHeight(70)
  tabFrame.frameTitle = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  tabFrame.frameTitle:SetPoint("TOP", tabFrame, "TOP", 0, -20);
  tabFrame.frameTitle:SetText(addonName .. " " .. version)

  -- Create the first tab button
  local tab1Button = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
  tab1Button:SetPoint("LEFT", tabFrame, "LEFT", 0, -20)
  tab1Button:SetText("Events")
  tab1Button:SetWidth(140)
  
  -- Create the second tab button
  local tab2Button = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
  tab2Button:SetPoint("LEFT", tab1Button, "CENTER", 80, 0)
  tab2Button:SetText("Settings")
  tab2Button:SetWidth(140)

  -- Create the third tab button
  local tab3Button = CreateFrame("Button", nil, tabFrame, "UIPanelButtonTemplate")
  tab3Button:SetPoint("LEFT", tab1Button, "RIGHT", 160, 0)
  tab3Button:SetText("About")
  tab3Button:SetWidth(140)

  -- Create the tab content frames
  local tab1Content = CreateFrame("Frame", nil, frame.panel)
  tab1Content:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT", 0, -10)
  tab1Content:SetPoint("BOTTOMRIGHT", frame.panel, "BOTTOMRIGHT", 0, 0)
  tab1Content:Hide() -- Hide initially

  local tab2Content = CreateFrame("Frame", nil, frame.panel)
  tab2Content:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT", 0, -10)
  tab2Content:SetPoint("BOTTOMRIGHT", frame.panel, "BOTTOMRIGHT", 0, 0)
  tab2Content:Hide() -- Hide initially

  local tab3Content = CreateFrame("Frame", nil, frame.panel)
  tab3Content:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT", 0, -10)
  tab3Content:SetPoint("BOTTOMRIGHT", frame.panel, "BOTTOMRIGHT", 0, 0)
  tab3Content:Hide() -- Hide initially

  -- Function to switch tabs
  local function SwitchTab(tab)
    tab1Content:Hide()
    tab2Content:Hide()
    tab3Content:Hide()
    if tab == 1 then
      tab1Content:Show()
    elseif tab == 2 then
      tab2Content:Show()
    elseif tab == 3 then
      tab3Content:Show()
    end
  end
  
  -- Hook up the tab buttons to switch tabs
  tab1Button:SetScript("OnClick", function() SwitchTab(1) end)
  tab2Button:SetScript("OnClick", function() SwitchTab(2) end)
  tab3Button:SetScript("OnClick", function() SwitchTab(3) end)
  
  -- Initialize the first tab with content
  -- You can add your existing options initialization code here
  -- For example, to add a checkbox to tab1Content:
  
  -- Event tab
  tab1Content:SetHeight(18)
  tab1Content:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT")
  tab1Content:SetPoint("TOPRIGHT", tabFrame, "BOTTOMRIGHT")
  tab1Content.label = tab1Content:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
  tab1Content.label:SetPoint("TOP")
  tab1Content.label:SetPoint("BOTTOM")
  tab1Content.label:SetJustifyH("CENTER")
  tab1Content.label:SetText(ns.T["events"])
  tab1Content.left = tab1Content:CreateTexture(nil, "BACKGROUND")
  tab1Content.left:SetHeight(8)
  tab1Content.left:SetPoint("LEFT", 10, 0)
  tab1Content.left:SetPoint("RIGHT", tab1Content.label, "LEFT", -5, 0)
  tab1Content.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  tab1Content.left:SetTexCoord(0.81, 0.94, 0.5, 1)
  tab1Content.right = tab1Content:CreateTexture(nil, "BACKGROUND")
  tab1Content.right:SetHeight(8)
  tab1Content.right:SetPoint("RIGHT", -10, 0)
  tab1Content.right:SetPoint("LEFT", tab1Content.label, "RIGHT", 5, 0)
  tab1Content.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  tab1Content.right:SetTexCoord(0.81, 0.94, 0.5, 1)
  tab1Content.left:SetPoint("RIGHT", tab1Content.label, "LEFT", -5, 0)
  
  -- Create checkboxes for all events we should listen to
  local totalCheckboxes = 0
  for _ in pairsByKeys(triggers, compareByCheckboxText) do
    totalCheckboxes = totalCheckboxes + 1
  end
  
  local columns = 2
  local checkboxWidth = 330 -- Adjust based on your checkbox size
  local checkboxHeight = 20 -- Adjust based on your checkbox size
  local spacing = 5 -- Spacing between checkboxes
  
  local currentRow = 0
  local currentCol = 0
  
  for k, _ in pairsByKeys(triggers, compareByCheckboxText) do
    local cb = CreateFrame("CheckButton", nil, tab1Content, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20 + currentCol * (checkboxWidth + spacing), -20 - currentRow * (checkboxHeight + spacing))
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
    
    local enabled = false
    if db.screenshottableEvents[k] then
      enabled = db.screenshottableEvents[k].enabled
    end
    
    cb:SetChecked(enabled)
    
    currentCol = currentCol + 1
    
    if currentCol >= columns then
      currentCol = 0
        currentRow = currentRow + 1
      end
  end
  
  -- Initialize the second tab with content
  -- Add your options for the second tab here
  local checkBox = CreateFrame("CheckButton", nil, tab2Content, "InterfaceOptionsCheckButtonTemplate")
  checkBox:SetPoint("TOPLEFT", tab2Content, "TOPLEFT", 10, -10)
  checkBox.Text:SetText("Example Checkbox")

  -- Hide map icon button
  local hideButton = CreateFrame("CheckButton", nil, tab2Content, "InterfaceOptionsCheckButtonTemplate")
  hideButton:SetPoint("TOPLEFT", 20, -0)
  hideButton.Text:SetText(ns.T["checkboxText.profile.hideMiniMap"])
  hideButton:HookScript("OnClick", function()
    local isChecked = hideButton:GetChecked()

    db.profile.minimap.hide = isChecked

    if isChecked then
      icon:Hide(Shotta.ADDON_NAME)
    else
      icon:Show(Shotta.ADDON_NAME)
    end
  end)
  hideButton:SetChecked(db.profile.minimap.hide)
  
  -- Initialize the third tab with content
  -- Add your options for the third tab here

  -- Footer
  local t = CreateFrame("Frame", nil, tab3Content, "BackdropTemplate")
  local footerOffset = -350
  t:SetPoint("TOPLEFT", tab3Content, "TOPLEFT")
  t:SetPoint("TOPRIGHT", tab3Content, "TOPRIGHT")
  t:SetHeight(30)

  -- Help text
  t.helpText = tab3Content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  t.helpText:SetFont("", 10)
  t.helpText:SetJustifyH("LEFT")
  t.helpText:SetPoint("TOP", tab3Content, "TOP", 0, footerOffset);
  t.helpText:SetText(ns.T["saveLocationHelpText"])
  
  -- Love text
  t.love = tab3Content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  t.love:SetPoint("TOP", tab3Content, "TOP", 0, footerOffset-100);
  t.love:SetText("For Nandar. Made with love in Melbourne, Australia")

  -- Show the first tab by default
  SwitchTab(1)
  
  InterfaceOptions_AddCategory(frame.panel)
end


ns.InitializeOptions = InitializeOptions
