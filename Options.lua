
local function InitializeOptions(frame, db, addonName, version)
  frame.panel = CreateFrame("Frame")
  frame.panel.name = "Screenshotter"

  local title = CreateFrame("Frame", nil, frame.panel)
  title:SetPoint("TOPLEFT", frame.panel, "TOPLEFT")
  title:SetPoint("TOPRIGHT", frame.panel, "TOPRIGHT")
  title:SetHeight(70)
  title.frameTitle = title:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title.frameTitle:SetPoint("TOP", title, "TOP", 0, -20);
  title.frameTitle:SetText(addonName .. " v" .. version)

  local header = CreateFrame("Frame", nil, title)
  header:SetHeight(18)
  header:SetPoint("TOPLEFT", title, "BOTTOMLEFT")
  header:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT")
  header.label = header:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
  header.label:SetPoint("TOP")
  header.label:SetPoint("BOTTOM")
  header.label:SetJustifyH("CENTER")
  header.label:SetText("Events")
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

  local cb = CreateFrame("CheckButton", nil, header, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", 20, -20)
  cb.Text:SetText("On level up")
  cb:HookScript("OnClick", function(_, btn, down)
    db.testEvent = cb:GetChecked()
  end)

  cb:SetChecked(db.testEvent)

  InterfaceOptions_AddCategory(frame.panel)
end


local _, ns = ...
ns.InitializeOptions = InitializeOptions
