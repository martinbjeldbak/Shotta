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
---@return fun()
local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0 -- iterator variable
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
---@param triggers Trigger
---@param screenshotFrame any
---@param version string
local function InitializeOptions(frame, triggers, screenshotFrame, version, icon)
	frame.panel = CreateFrame("Frame")
	frame.panel.name = Shotta.ADDON_NAME

	local tabFrame = CreateFrame("Frame", nil, frame.panel)
	tabFrame:SetPoint("TOPLEFT", frame.panel, "TOPLEFT")
	tabFrame:SetPoint("TOPRIGHT", frame.panel, "TOPRIGHT")
	tabFrame:SetHeight(70)
	tabFrame.frameTitle = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	tabFrame.frameTitle:SetPoint("TOP", tabFrame, "TOP", 0, -15)
	tabFrame.frameTitle:SetText(Shotta.ADDON_NAME .. " " .. version)

	-- Create the first tab button
	local tab1Button = CreateFrame("Button", nil, tabFrame, "GameMenuButtonTemplate")
	tab1Button:SetPoint("LEFT", tabFrame, "LEFT", 0, -20)
	tab1Button:SetText(ns.T["events"])
	tab1Button:SetWidth(140)

	-- Create the second tab button
	local tab2Button = CreateFrame("Button", nil, tabFrame, "GameMenuButtonTemplate")
	tab2Button:SetPoint("LEFT", tab1Button, "CENTER", 80, 0)
	tab2Button:SetText(ns.T["settings"])
	tab2Button:SetWidth(140)

	-- Create the third tab button
	local tab3Button = CreateFrame("Button", nil, tabFrame, "GameMenuButtonTemplate")
	tab3Button:SetPoint("LEFT", tab1Button, "RIGHT", 160, 0)
	tab3Button:SetText(ns.T["about"])
	tab3Button:SetWidth(140)

	local function ShowDiscordPopup()
		StaticPopupDialogs["Shotta_Link"] = {
			text = "Press Ctrl+C to copy the URL to your clipboard",
			hasEditBox = 1,
			button1 = _G.OKAY,
			OnShow = function(self)
				local box = self.editBox
				box:SetWidth(275)
				box:SetText("https://discord.gg/MHqGRpZxbB")
				box:HighlightText()
				box:SetFocus()
			end,
			EditBoxOnEscapePressed = function(self)
				self:GetParent():Hide()
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		StaticPopup_Show("Shotta_Link")
	end

	local discordButton = CreateFrame("Button", nil, tabFrame, "GameMenuButtonTemplate")
	discordButton:SetPoint("LEFT", tab3Button, "RIGHT", 85, 40)
	discordButton:SetText("Join our Discord!")
	discordButton:SetWidth(125)
	discordButton:SetScript("OnClick", ShowDiscordPopup)

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
	tab1Button:SetScript("OnClick", function()
		SwitchTab(1)
	end)
	tab2Button:SetScript("OnClick", function()
		SwitchTab(2)
	end)
	tab3Button:SetScript("OnClick", function()
		SwitchTab(3)
	end)

	-- Initialize the first tab with content
	-- You can add your existing options initialization code here
	-- For example, to add a checkbox to tab1Content:

	-- Event tab
	local eventTab = CreateFrame("Frame", nil, tab1Content)
	eventTab:SetHeight(18)
	eventTab:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT")
	eventTab:SetPoint("TOPRIGHT", tabFrame, "BOTTOMRIGHT")
	eventTab.label = eventTab:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	eventTab.label:SetPoint("TOP")
	eventTab.label:SetPoint("BOTTOM")
	eventTab.label:SetJustifyH("CENTER")
	eventTab.label:SetText(ns.T["events"])
	eventTab.left = eventTab:CreateTexture(nil, "BACKGROUND")
	eventTab.left:SetHeight(8)
	eventTab.left:SetPoint("LEFT", 10, 0)
	eventTab.left:SetPoint("RIGHT", eventTab.label, "LEFT", -5, 0)
	eventTab.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	eventTab.left:SetTexCoord(0.81, 0.94, 0.5, 1)
	eventTab.right = eventTab:CreateTexture(nil, "BACKGROUND")
	eventTab.right:SetHeight(8)
	eventTab.right:SetPoint("RIGHT", -10, 0)
	eventTab.right:SetPoint("LEFT", eventTab.label, "RIGHT", 5, 0)
	eventTab.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	eventTab.right:SetTexCoord(0.81, 0.94, 0.5, 1)
	eventTab.left:SetPoint("RIGHT", eventTab.label, "LEFT", -5, 0)

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

	ns.AddToDevToolInspector(triggers, "triggers")
	for k, v in pairsByKeys(triggers, compareByCheckboxText) do
		ns.AddToDevToolInspector(k, "k")
		ns.AddToDevToolInspector(v, "v")
		local cb = CreateFrame("CheckButton", nil, tab1Content, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint(
			"TOPLEFT",
			20 + currentCol * (checkboxWidth + spacing),
			-20 - currentRow * (checkboxHeight + spacing)
		)
		cb.Text:SetText(ns.T["checkboxText." .. k])
		cb:HookScript("OnClick", function()
			local isChecked = cb:GetChecked()

			if isChecked then
				if Shotta.db.screenshottableEvents[k] == nil then
					Shotta.db.screenshottableEvents[k] = {}
				end
				Shotta.db.screenshottableEvents[k].enabled = true
			else
				Shotta.db.screenshottableEvents[k].enabled = nil
			end

			screenshotFrame:registerUnregisterEvent(k, isChecked)

			ns.Debug(format("%s is now %s", k, EnabledHumanized(isChecked)))
		end)

		local enabled = false
		if Shotta.db.screenshottableEvents[k] then
			enabled = Shotta.db.screenshottableEvents[k].enabled
		end
		cb:SetChecked(enabled)

		for _, m in pairs(v.modifiers or {}) do
			ns.AddToDevToolInspector(m, "modifier")
			local modifierCb = CreateFrame("CheckButton", nil, tab1Content, "InterfaceOptionsCheckButtonTemplate")
			currentRow = currentRow + 1
			modifierCb:SetPoint(
				"TOPLEFT",
				50 + currentCol * (checkboxWidth + spacing),
				-20 - currentRow * (checkboxHeight + spacing)
			)
			modifierCb.Text:SetText(ns.T[format("checkboxText.%s.modifiers.%s", k, m)])

			modifierCb:HookScript("OnClick", function()
				local isChecked = modifierCb:GetChecked()

				if isChecked then
					ns.AddToDevToolInspector(Shotta.db.screenshottableEvents[k].modifiers, "before")
					if Shotta.db.screenshottableEvents[k].modifiers == nil then
						Shotta.db.screenshottableEvents[k].modifiers = {}
					end

					if Shotta.db.screenshottableEvents[k].modifiers[m] == nil then
						Shotta.db.screenshottableEvents[k].modifiers[m] = {}
					end
					Shotta.db.screenshottableEvents[k].modifiers[m]["enabled"] = true
				else
					Shotta.db.screenshottableEvents[k].modifiers[m]["enabled"] = false
				end

				ns.Debug(format("%s is now %s", m, EnabledHumanized(isChecked)))
			end)
			local modifierEnabled = false
			if Shotta.db.screenshottableEvents[k].modifiers[m] then
				modifierEnabled = Shotta.db.screenshottableEvents[k].modifiers[m].enabled
			end
			modifierCb:SetChecked(modifierEnabled)
		end

		currentCol = currentCol + 1

		if currentCol >= columns then
			currentCol = 0
			currentRow = currentRow + 1
		end
	end

	-- Initialize the second tab with content
	-- Add your options for the second tab here
	local settingsName = CreateFrame("Frame", nil, tab2Content)
	settingsName:SetHeight(18)
	settingsName:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT")
	settingsName:SetPoint("TOPRIGHT", tabFrame, "BOTTOMRIGHT")
	settingsName.label = settingsName:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	settingsName.label:SetPoint("TOP")
	settingsName.label:SetPoint("BOTTOM")
	settingsName.label:SetJustifyH("CENTER")
	settingsName.label:SetText(ns.T["settings"])
	settingsName.left = settingsName:CreateTexture(nil, "BACKGROUND")
	settingsName.left:SetHeight(8)
	settingsName.left:SetPoint("LEFT", 10, 0)
	settingsName.left:SetPoint("RIGHT", settingsName.label, "LEFT", -5, 0)
	settingsName.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	settingsName.left:SetTexCoord(0.81, 0.94, 0.5, 1)
	settingsName.right = settingsName:CreateTexture(nil, "BACKGROUND")
	settingsName.right:SetHeight(8)
	settingsName.right:SetPoint("RIGHT", -10, 0)
	settingsName.right:SetPoint("LEFT", settingsName.label, "RIGHT", 5, 0)
	settingsName.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	settingsName.right:SetTexCoord(0.81, 0.94, 0.5, 1)
	settingsName.left:SetPoint("RIGHT", settingsName.label, "LEFT", -5, 0)

	-- Hide map icon button
	local hideButton = CreateFrame("CheckButton", nil, tab2Content, "InterfaceOptionsCheckButtonTemplate")
	hideButton:SetPoint("TOPLEFT", tab2Content, "TOPLEFT", 20, -20)
	hideButton.Text:SetText(ns.T["checkboxText.profile.hideMiniMap"])
	hideButton:HookScript("OnClick", function()
		local isChecked = hideButton:GetChecked()

		Shotta.db.profile.minimap.hide = isChecked

		if isChecked then
			icon:Hide(Shotta.ADDON_NAME)
		else
			icon:Show(Shotta.ADDON_NAME)
		end
	end)
	hideButton:SetChecked(Shotta.db.profile.minimap.hide)

	-- Initialize the third tab with content
	-- Add your options for the third tab here

	-- Footer
	local aboutName = CreateFrame("Frame", nil, tab3Content)
	aboutName:SetHeight(18)
	aboutName:SetPoint("TOPLEFT", tabFrame, "BOTTOMLEFT")
	aboutName:SetPoint("TOPRIGHT", tabFrame, "BOTTOMRIGHT")
	aboutName.label = aboutName:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	aboutName.label:SetPoint("TOP")
	aboutName.label:SetPoint("BOTTOM")
	aboutName.label:SetJustifyH("CENTER")
	aboutName.label:SetText(ns.T["about"])
	aboutName.left = aboutName:CreateTexture(nil, "BACKGROUND")
	aboutName.left:SetHeight(8)
	aboutName.left:SetPoint("LEFT", 10, 0)
	aboutName.left:SetPoint("RIGHT", aboutName.label, "LEFT", -5, 0)
	aboutName.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	aboutName.left:SetTexCoord(0.81, 0.94, 0.5, 1)
	aboutName.right = aboutName:CreateTexture(nil, "BACKGROUND")
	aboutName.right:SetHeight(8)
	aboutName.right:SetPoint("RIGHT", -10, 0)
	aboutName.right:SetPoint("LEFT", aboutName.label, "RIGHT", 5, 0)
	aboutName.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	aboutName.right:SetTexCoord(0.81, 0.94, 0.5, 1)
	aboutName.left:SetPoint("RIGHT", aboutName.label, "LEFT", -5, 0)

	local t = CreateFrame("Frame", nil, tab3Content, "BackdropTemplate")
	local footerOffset = -30
	t:SetPoint("TOPLEFT", tab3Content, "TOPLEFT")
	t:SetPoint("TOPRIGHT", tab3Content, "TOPRIGHT")
	t:SetHeight(30)

	-- Help text
	t.helpText = tab3Content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	t.helpText:SetFont("", 10)
	t.helpText:SetJustifyH("LEFT")
	t.helpText:SetPoint("TOP", tab3Content, "TOP", 0, footerOffset)
	t.helpText:SetText(ns.T["saveLocationHelpText"])

	-- Love text
	t.love = tab3Content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	t.love:SetPoint("TOP", tab3Content, "TOP", 0, footerOffset - 100)
	t.love:SetText("For Nandar. Made with love in Melbourne, Australia")

	-- Show the first tab by default
	SwitchTab(1)

	InterfaceOptions_AddCategory(frame.panel)
end

ns.InitializeOptions = InitializeOptions
