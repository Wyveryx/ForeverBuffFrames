local _, FBF = ...

FBF.Options = {}

function FBF.Options.Create(context)
local SOUND_FILE_ID = FBF.SOUND_FILE_ID
local builtinFonts = FBF.builtinFonts
local builtinSounds = FBF.builtinSounds
local sharedMedia = FBF.SharedMedia
local fontPath = FBF.FontPath
local soundSource = FBF.SoundSource
local theme = FBF.Theme
local defaults = FBF.defaults
local copyTable = FBF.CopyTable
local initializeProfile = FBF.InitializeProfile
local L = FBF.L
local getProfile = context.GetProfile
local getDatabase = context.GetDatabase
local report = context.Report
local applyStockVisibility = context.ApplyStockVisibility
local build = context.AuraFrames.Build
local setUnlocked = context.AuraFrames.SetUnlocked
local toggleTest = context.AuraFrames.ToggleTest
local previewDebuffAwareness = context.AuraFrames.PreviewDebuffAwareness
local auraFrames = context.AuraFrames
local alerts = context.Alerts
local debuffSounds = context.DebuffSounds
local buffRemovalSounds = context.BuffRemovalSounds or {}
local handleAlertCommand = alerts.Handle
local getDiagnosticState = context.GetDiagnosticState or function() return {} end
local clearDiagnosticState = context.ClearDiagnosticState or function() end
local configFrame
local selectedKind = "buffs"
local selectedTab = "buffs"
local selectedSection = "layout"
local debuffPageState = {}
local buffAlertDetail = false
local refreshConfig

local numericSettings = {
    { "Icon size", "size", 16, 96, "Width and height of each aura icon, in pixels." },
    { "Horizontal spacing", "gapX", 0, 32, "Space between icons in the same row, in pixels." },
    { "Vertical spacing", "gapY", 0, 32, "Space between rows, in pixels." },
    { "Icons per row", "perRow", 1, 20, "Maximum number of icons before the next row begins." },
    { "Rows", "rows", 1, 10, "Maximum number of rows shown in this bar." },
    { "Timer text size", "timerSize", 6, 36, "Font size of the remaining-duration text." },
    { "Stack text size", "countSize", 6, 36, "Font size of the stack-count number." },
}

local choiceSettings = {
    { "Growth", "grow", { "right", "left" }, "Direction icons fill each row." },
    { "Aura order", "sort", { "default", "shortest", "longest" }, "Order auras using Blizzard's protected container sorter. Permanent-aura placement will be verified in game." },
    { "Unlimited auras", "untimed", { "mixed", "untimedleft", "untimedright" }, "Keep Blizzard's default placement, or group known unlimited auras on a physical side. New classifications may update after combat." },
    { "Timer position", "timerPos", { "below", "above", "center" }, "Where duration text appears relative to each icon." },
    { "Stack position", "countPos", { "bottomright", "bottomleft", "topright", "topleft" }, "Corner used for the stack-count number." },
    { "Outline", "outline", { "none", "outline", "thick" }, "Border weight around timer and stack text." },
}
local choiceLabels = {
    right = "Grow right", left = "Grow left",
    default = "Default order", shortest = "Shortest remaining first", longest = "Longest remaining first",
    mixed = "Default placement", untimedleft = "Place on left", untimedright = "Place on right",
    below = "Below", above = "Above", center = "Centered",
    bottomright = "Bottom right", bottomleft = "Bottom left", topright = "Top right", topleft = "Top left",
    none = "None", outline = "Outline", thick = "Thick outline",
}

local function tooltip(widget, title, description)
    widget:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    widget:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local baseConfigFonts = setmetatable({}, { __mode = "k" })
local baseConfigButtonSizes = setmetatable({}, { __mode = "k" })
local function setConfigLocaleFont(text, locale)
    if not text then return end
    local base = baseConfigFonts[text]
    if not base then
        local path, size, flags = text:GetFont()
        if not path or not size then return end
        base = { path, size, flags }
        baseConfigFonts[text] = base
    end
    local code = locale == "auto" and FBF.Locale.GetClient() or locale
    local localeFace = FBF.Locale.FontPath(code)
    local _, currentSize, currentFlags = text:GetFont()
    currentSize, currentFlags = currentSize or base[2], currentFlags or base[3]
    if not localeFace or text:SetFont(localeFace, currentSize, currentFlags) == false then
        text:SetFont(base[1], currentSize, currentFlags)
    end
end

local function fitConfigButton(frame)
    if not (frame.IsObjectType and frame:IsObjectType("Button") and frame.GetFontString) then return end
    local label = frame:GetFontString()
    if not label or not label:GetText() or label:GetText() == "" then return end
    local base = baseConfigButtonSizes[frame]
    if not base then
        base = { frame:GetWidth(), frame:GetHeight() }
        baseConfigButtonSizes[frame] = base
    end
    local measured
    if label.GetUnboundedStringWidth then
        local ok, width = pcall(label.GetUnboundedStringWidth, label)
        if ok then measured = width end
    end
    measured = measured or label:GetStringWidth()
    local padding = frame.selectorArrow and 52 or 26
    local wantedWidth = math.max(base[1], math.ceil(measured) + padding)
    local wantedHeight = math.max(base[2], math.ceil(label:GetStringHeight()) + 10)
    local maxWidth = frame.autoFitMaxWidth or math.max(base[1], 360)
    local maxHeight = frame.autoFitMaxHeight or math.max(base[2], 48)
    frame:SetWidth(math.min(wantedWidth, maxWidth))
    frame:SetHeight(math.min(wantedHeight, maxHeight))
end

local function applyConfigTextSize(root, extraSize)
    local function visit(frame)
        for _, region in ipairs({ frame:GetRegions() }) do
            if region.IsObjectType and region:IsObjectType("FontString") then
                local base = baseConfigFonts[region]
                if not base then
                    local path, size, flags = region:GetFont()
                    if path and size then
                        base = { path, size, flags }
                        baseConfigFonts[region] = base
                    end
                end
                if base then
                    local localeFace = FBF.Locale.FontPath()
                    if not localeFace or region:SetFont(localeFace, base[2] + extraSize, base[3]) == false then
                        region:SetFont(base[1], base[2] + extraSize, base[3])
                    end
                end
            end
        end
        for _, child in ipairs({ frame:GetChildren() }) do visit(child) end
    end
    visit(root)
end

local function fitConfigButtons(root)
    local function visit(frame)
        fitConfigButton(frame)
        for _, child in ipairs({ frame:GetChildren() }) do visit(child) end
    end
    visit(root)
end

local function fitLocalizedWindow(r, textExpansion)
    local navigationWidth = 138
    for _, tab in pairs(r.tabs) do
        navigationWidth = math.max(navigationWidth, math.ceil(tab.label:GetStringWidth()) + 24)
    end
    local contentWidth = 710 + textExpansion * 28
    contentWidth = math.max(contentWidth,
        25 + r.test:GetWidth() + 8 + r.move:GetWidth() + 8 + r.reset:GetWidth() + 25)
    for _, control in pairs(r.choiceControls) do
        contentWidth = math.max(contentWidth, 385 + control:GetWidth() + 25)
    end
    contentWidth = math.max(contentWidth,
        25 + r.createProfile:GetWidth() + 8 + r.copyProfile:GetWidth()
            + 8 + r.renameProfile:GetWidth() + 8 + r.deleteProfile:GetWidth() + 25,
        25 + r.profileButton:GetWidth() + 25)
    for _, check in ipairs(r.generalChecks) do
        contentWidth = math.max(contentWidth,
            25 + check:GetWidth() + 2 + check.textLabel:GetStringWidth() + 25)
    end
    local alertToggleWidth = 250
    for _, check in ipairs(r.alertChecks) do
        alertToggleWidth = math.max(alertToggleWidth,
            15 + check:GetWidth() + 2 + check.textLabel:GetStringWidth() + 15)
    end
    local alertLeftWidth = math.max(390,
        10 + r.blacklistInput:GetWidth() + 10 + r.blockID:GetWidth() + 8 + r.unblockID:GetWidth() + 15,
        10 + r.soundButton:GetWidth() + 15,
        10 + r.soundTest:GetWidth() + 15)
    r.alertLeft:SetWidth(alertLeftWidth)
    r.alertRight:SetWidth(alertToggleWidth)
    contentWidth = math.max(contentWidth, 15 + alertLeftWidth + 15 + alertToggleWidth + 15,
        25 + r.copyBackup:GetWidth() + 12 + r.restoreBackup:GetWidth() + 25,
        25 + r.languageButton:GetWidth() + 25,
        25 + r.applyLanguage:GetWidth() + 25)
    if r.diagnosticTestRow then
        local leftWidth = math.max(310, r.diagnosticTestRow[1]:GetWidth() + 8 + r.diagnosticTestRow[2]:GetWidth())
        local rightWidth = math.max(320, r.diagnosticStatusRow[1]:GetWidth() + 8 + r.diagnosticStatusRow[2]:GetWidth())
        contentWidth = math.max(contentWidth, 25 + leftWidth + 25 + rightWidth + 25,
            25 + r.diagnosticReportRow[1]:GetWidth() + 8 + r.diagnosticReportRow[2]:GetWidth() + 25)
        r.diagnosticStatusHeading:ClearAllPoints()
        r.diagnosticStatusHeading:SetPoint("TOPLEFT", 25 + leftWidth + 25, -168)
        r.diagnosticTestHelp:SetWidth(leftWidth)
    end
    r.sidebar:SetWidth(navigationWidth)
    for _, tab in pairs(r.tabs) do tab:SetWidth(navigationWidth - 6) end
    r.frame:SetSize(navigationWidth + 12 + contentWidth, 720 + textExpansion * 8)
    for _, panel in ipairs(r.contentPanels) do
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", r.frame, "TOPLEFT", navigationWidth + 12, 0)
        panel:SetPoint("BOTTOMRIGHT", r.frame, "BOTTOMRIGHT", 0, 0)
    end
    r.generalHelp:SetWidth(math.max(1, contentWidth - 50))
    r.profileHelp:SetWidth(math.max(1, contentWidth - 50))
    r.languageHelp:SetWidth(math.max(1, contentWidth - 50))
    if r.diagnosticsHelp then r.diagnosticsHelp:SetWidth(math.max(1, contentWidth - 50)) end
    if r.diagnosticReport then r.diagnosticReport:SetWidth(math.max(1, contentWidth - 60)) end
end

local function applySetting(key, value)
    if InCombatLockdown() then
        report(L("Change settings after combat."))
        refreshConfig()
        return
    end
    getProfile()[selectedKind][key] = value
    build(selectedKind)
    refreshConfig()
end

local function mediaChoices(kind)
    local choices = {}
    if kind == "font" then
        for _, entry in ipairs(builtinFonts) do
            choices[#choices + 1] = { value = entry[1], label = L(entry[2]), source = entry[3] }
        end
    else
        choices[1] = { value = "none", label = L("None") }
        for _, entry in ipairs(builtinSounds) do
            local fileBacked = type(entry[3]) == "string"
                and (entry[3]:find("\\", 1, true) or entry[3]:find("/", 1, true))
            if type(entry[3]) == "number" or fileBacked or (SOUNDKIT and SOUNDKIT[entry[3]]) then
                choices[#choices + 1] = { value = entry[1], label = L(entry[2]) }
            end
        end
        for label, path in pairs(getProfile().customSounds or {}) do
            choices[#choices + 1] = { value = "file:" .. path, label = label }
        end
    end
    local media = sharedMedia()
    if media then
        for _, name in ipairs(media:List(kind)) do
            choices[#choices + 1] = { value = "lsm:" .. name, label = name, source = kind == "font" and media:Fetch("font", name, true) or nil }
        end
    end
    return choices
end

local mediaPicker
local function openMediaPicker(kind, current, onPick, owner, choiceFilter)
    if not mediaPicker then
        local frame = CreateFrame("Frame", "ForeverBuffFramesMediaPicker", UIParent, "BackdropTemplate")
        frame:SetSize(370, 430)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("FULLSCREEN_DIALOG")
        frame:SetClampedToScreen(true)
        theme.ApplyPopup(frame)
        table.insert(UISpecialFrames, "ForeverBuffFramesMediaPicker")
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 22, -18)
        theme.StyleSectionHeading(frame.title)
        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT")
        frame.close = close
        frame.search = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        frame.search:SetSize(310, 24)
        frame.search:SetPoint("TOPLEFT", 25, -55)
        frame.search:SetAutoFocus(false)
        theme.StyleInput(frame.search)
        frame.search:SetScript("OnEscapePressed", frame.search.ClearFocus)
        frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        frame.hint:SetPoint("TOPLEFT", 27, -82)
        local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 22, -94)
        scroll:SetPoint("BOTTOMRIGHT", -38, 20)
        frame.scroll = scroll
        frame.child = CreateFrame("Frame", nil, scroll)
        frame.child:SetSize(310, 1)
        scroll:SetScrollChild(frame.child)
        frame.rows = {}
        frame.search:SetScript("OnTextChanged", function() frame:Refresh() end)
        function frame:Refresh()
            local query = self.search:GetText():lower()
            local shown = 0
            for _, choice in ipairs(mediaChoices(self.kind)) do
                if (not self.choiceFilter or self.choiceFilter(choice))
                    and (query == "" or choice.label:lower():find(query, 1, true)) then
                    shown = shown + 1
                    local row = self.rows[shown]
                    if not row then
                        row = CreateFrame("Button", nil, self.child)
                        row:SetSize(self.inline and 208 or 305, 29)
                        row:SetPoint("TOPLEFT", 0, -(shown - 1) * 30)
                        theme.AddRowHighlight(row, 1)
                        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        row.text:SetPoint("LEFT", 8, 0)
                        row.text:SetWidth(self.kind == "sound" and 143 or (self.inline and 190 or 285))
                        row.text:SetJustifyH("LEFT")
                        row:SetScript("OnClick", function(self)
                            frame.onPick(self.choice.value)
                            frame:Hide()
                        end)
                        row.play = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                        row.play:SetSize(46, 22)
                        row.play:SetPoint("RIGHT", -3, 0)
                        row.play:SetText(L("Play"))
                        row.play:SetScript("OnClick", function()
                            local source = soundSource(row.choice.value)
                            if source == SOUND_FILE_ID then PlaySoundFile(source, "Master")
                            elseif type(source) == "number" then PlaySound(source, "Master")
                            elseif source then PlaySoundFile(source, "Master") end
                        end)
                        self.rows[shown] = row
                    end
                    row.choice = choice
                    row.play:SetShown(self.kind == "sound" and choice.value ~= "none")
                    if not row.selected then
                        row.selected = row:CreateTexture(nil, "BACKGROUND")
                        row.selected:SetPoint("TOPLEFT", 2, -2)
                        row.selected:SetPoint("BOTTOMRIGHT", -2, 2)
                        row.selected:SetColorTexture(unpack(theme.accent))
                    end
                    row.selected:SetShown(choice.value == self.current)
                    row.text:SetText(choice.label)
                    local extraSize = getDatabase() and (getDatabase().uiTextSize or 0) or 0
                    local baseSize = self.kind == "font" and 14 or 13
                    local face = self.kind == "font" and choice.source
                        or (STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF")
                    if self.kind == "font" then
                        local ok = face and row.text:SetFont(face, baseSize + extraSize, "")
                        if not ok then
                            face = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
                            row.text:SetFont(face, baseSize + extraSize, "")
                        end
                    else
                        row.text:SetFont(face, baseSize + extraSize, "")
                    end
                    -- Rows are reused between font and sound modes. Refresh the
                    -- responsive-size baseline so a preview face cannot leak
                    -- into the alert-sound list on the next open.
                    baseConfigFonts[row.text] = { face, baseSize, "" }
                    row:Show()
                end
            end
            for i = shown + 1, #self.rows do self.rows[i]:Hide() end
            self.child:SetHeight(math.max(1, shown * 30))
        end
        frame:Hide()
        mediaPicker = frame
    end
    mediaPicker.kind = kind
    mediaPicker.current = current
    mediaPicker.onPick = onPick
    mediaPicker.choiceFilter = choiceFilter
    mediaPicker.inline = owner and true or false
    mediaPicker:SetParent(owner and configFrame or UIParent)
    mediaPicker:ClearAllPoints()
    mediaPicker.search:ClearAllPoints()
    mediaPicker.scroll:ClearAllPoints()
    if owner then
        mediaPicker:SetSize(255, 220)
        mediaPicker:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
        mediaPicker:SetFrameStrata("DIALOG")
        mediaPicker:SetFrameLevel(configFrame:GetFrameLevel() + 20)
        mediaPicker.title:Hide()
        mediaPicker.hint:Hide()
        mediaPicker.close:Hide()
        mediaPicker.search:SetSize(205, 22)
        mediaPicker.search:SetPoint("TOPLEFT", 12, -12)
        mediaPicker.scroll:SetPoint("TOPLEFT", 10, -42)
        mediaPicker.scroll:SetPoint("BOTTOMRIGHT", -32, 10)
        mediaPicker.child:SetWidth(210)
    else
        mediaPicker:SetSize(370, 430)
        mediaPicker:SetPoint("CENTER")
        mediaPicker:SetFrameStrata("FULLSCREEN_DIALOG")
        mediaPicker.title:Show()
        mediaPicker.hint:Show()
        mediaPicker.close:Show()
        mediaPicker.search:SetSize(310, 24)
        mediaPicker.search:SetPoint("TOPLEFT", 25, -55)
        mediaPicker.scroll:SetPoint("TOPLEFT", 22, -94)
        mediaPicker.scroll:SetPoint("BOTTOMRIGHT", -38, 20)
        mediaPicker.child:SetWidth(310)
    end
    for _, row in ipairs(mediaPicker.rows) do
        row:SetWidth(owner and 208 or 305)
        row.text:SetWidth(kind == "sound" and 143 or (owner and 190 or 285))
    end
    mediaPicker.title:SetText(L(kind == "font" and "Choose font" or "Choose alert sound"))
    mediaPicker.hint:SetText(L(kind == "font" and "Search fonts; names preview their typeface" or "Search sounds; Play previews without selecting"))
    mediaPicker.search:SetText("")
    mediaPicker:Refresh()
    mediaPicker:Show()
    if getDatabase() then
        applyConfigTextSize(mediaPicker, getDatabase().uiTextSize or 0)
        fitConfigButtons(mediaPicker)
    end
    mediaPicker.search:SetFocus()
end

local validProfileName = FBF.Profiles.ValidName
local function sortedProfileNames() return FBF.Profiles.SortedNames(getDatabase()) end

local function activateProfile(name)
    if InCombatLockdown() then report(L("Switch profiles after combat.")); return false end
    if not getDatabase().profiles[name] then report(L("That profile no longer exists.")); return false end
    if type(getDatabase().uiTextSize) ~= "number" then getDatabase().uiTextSize = 0 end
    getDatabase().activeProfile = name
    context.SetProfile(initializeProfile(getDatabase().profiles[name]))
    alerts.Reset()
    build("buffs")
    build("debuffs")
    if context.GetMinimapButton() then
        context.GetMinimapButton():SetShown(getProfile().showMinimap)
        if context.GetMinimapButton().position then context.GetMinimapButton().position() end
    end
    applyStockVisibility()
    handleAlertCommand(getProfile().expirationSounds and "on" or "off")
    if debuffSounds then debuffSounds.Sync() end
    if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
    if refreshConfig then refreshConfig() end
    report(L("Profile selected: %s", name))
    return true
end

local function makeConfig()
    if configFrame then
        return configFrame
    end
    local frame = CreateFrame("Frame", "ForeverBuffFramesConfig", UIParent, "BackdropTemplate")
    frame:SetSize(860, 720)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    theme.ApplyWindow(frame)
    frame:Hide()
    table.insert(UISpecialFrames, "ForeverBuffFramesConfig")

    theme.AddTitlePlaque(frame)
    local sidebar = frame:CreateTexture(nil, "BACKGROUND")
    sidebar:SetPoint("TOPLEFT", 8, -8)
    sidebar:SetPoint("BOTTOMLEFT", 8, 8)
    sidebar:SetWidth(138)
    sidebar:SetColorTexture(unpack(theme.sidebar))
    theme.AddVerticalDivider(frame, sidebar)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 0, 0)
    tooltip(close, L("Close"), L("Close the configuration window. Settings are saved automatically."))
    local layoutPanel = CreateFrame("Frame", nil, frame)
    layoutPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    layoutPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local layoutControls = CreateFrame("Frame", nil, layoutPanel)
    layoutControls:SetAllPoints()
    local textControls = CreateFrame("Frame", nil, layoutPanel)
    textControls:SetAllPoints()
    local generalPanel = CreateFrame("Frame", nil, frame)
    generalPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    generalPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local alertsPanel = CreateFrame("Frame", nil, frame)
    alertsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    alertsPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local debuffAlertsPanel = CreateFrame("Frame", nil, frame)
    debuffAlertsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    debuffAlertsPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local debuffAppearancePanel = CreateFrame("Frame", nil, frame)
    debuffAppearancePanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    debuffAppearancePanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local debuffLibraryPanel = CreateFrame("Frame", nil, frame)
    debuffLibraryPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    debuffLibraryPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    debuffPageState.sounds = debuffAlertsPanel
    debuffPageState.appearance = debuffAppearancePanel
    debuffPageState.library = debuffLibraryPanel
    local profilesPanel = CreateFrame("Frame", nil, frame)
    profilesPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    profilesPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local recoveryPanel = CreateFrame("Frame", nil, frame)
    recoveryPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    recoveryPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local languagePanel = CreateFrame("Frame", nil, frame)
    languagePanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    languagePanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local diagnosticsPanel = CreateFrame("Frame", nil, frame)
    diagnosticsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    diagnosticsPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local contentPanels = { layoutPanel, generalPanel, alertsPanel, debuffAlertsPanel, debuffAppearancePanel, debuffLibraryPanel, profilesPanel, recoveryPanel, languagePanel, diagnosticsPanel }
    contentPanels.layout = layoutPanel
    contentPanels.general = generalPanel
    contentPanels.alerts = alertsPanel
    contentPanels.profiles = profilesPanel
    contentPanels.recovery = recoveryPanel
    contentPanels.language = languagePanel
    contentPanels.diagnostics = diagnosticsPanel
    local alertLeft = CreateFrame("Frame", nil, alertsPanel)
    alertLeft:SetPoint("TOPLEFT", 15, -105)
    alertLeft:SetSize(390, 560)
    local alertRight = CreateFrame("Frame", nil, alertsPanel)
    alertRight:SetPoint("TOPLEFT", alertLeft, "TOPRIGHT", 15, 0)
    alertRight:SetSize(250, 180)
    local openMenu
    local function dismissTransientUI()
        if mediaPicker then mediaPicker:Hide() end
        if openMenu then openMenu:Hide(); openMenu = nil end
        local focus = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
        if focus and focus.ClearFocus then focus:ClearFocus() end
        GameTooltip:Hide()
    end
    local function decorateSelector(button)
        if button.selectorArrow then return end
        local arrow = button:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(16, 16)
        arrow:SetPoint("RIGHT", -8, 0)
        arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
        button.selectorArrow = arrow
        local label = button:GetFontString()
        if label then
            label:ClearAllPoints()
            label:SetPoint("LEFT", 12, 0)
            label:SetPoint("RIGHT", arrow, "LEFT", -6, 0)
            label:SetJustifyH("LEFT")
        end
        theme.StyleSelector(button)
    end
    frame:HookScript("OnHide", function()
        dismissTransientUI()
    end)
    local sectionTabs = {}
    for i, section in ipairs({ "layout", "text" }) do
        local button = CreateFrame("Button", nil, layoutPanel, "UIPanelButtonTemplate")
        button:SetSize(105, 23)
        button:SetPoint("TOPLEFT", 25 + (i - 1) * 112, -91)
        button:SetText(L(section == "layout" and "Layout" or "Text"))
        theme.AddRowHighlight(button, 2)
        button:SetScript("OnClick", function()
            dismissTransientUI()
            selectedSection = section
            refreshConfig()
        end)
        sectionTabs[section] = button
    end
    local tabLabels = {
        general = "General", buffs = "Buffs", debuffs = "Debuffs", alerts = "Alerts",
        profiles = "Profiles", recovery = "Backup / Recovery", language = "Language", diagnostics = "Diagnostics",
    }
    local tabs = {}
    for index, kind in ipairs({ "general", "buffs", "debuffs", "alerts", "profiles", "recovery", "language", "diagnostics" }) do
        local tab = CreateFrame("Button", nil, frame)
        tab:SetSize(126, 30)
        tab:SetPoint("TOPLEFT", 14, -58 - (index - 1) * 36)
        theme.AddRowHighlight(tab)
        tab.selected = tab:CreateTexture(nil, "BACKGROUND")
        tab.selected:SetAllPoints()
        tab.selected:SetColorTexture(unpack(theme.accent))
        tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.label:SetPoint("LEFT", 10, 0)
        tab.label:SetText(L(tabLabels[kind]))
        tab:SetScript("OnClick", function()
            dismissTransientUI()
            selectedTab = kind
            if kind == "buffs" or kind == "debuffs" then selectedKind = kind end
            if kind == "debuffs" then debuffPageState.current = nil end
            if kind == "alerts" then buffAlertDetail = false end
            refreshConfig()
        end)
        local tabTitle = kind == "diagnostics" and L("Diagnostics") or (kind == "language" and L("Language settings") or (kind == "general" and "General settings" or (kind == "recovery" and "Backup / Recovery" or (kind == "profiles" and "Profiles" or (kind == "alerts" and "Alert settings" or (kind == "buffs" and "Buff settings" or "Debuff settings"))))))
        local tabHelp = kind == "recovery" and "Save all profiles or restore them if the beta forgets them."
            or (kind == "profiles" and "Create, copy, rename, delete, and select named settings profiles."
            or (kind == "general" and "Configure the settings window and shared display choices."
            or (kind == "diagnostics" and "Preview existing effects and collect a compact support report."
            or (kind == "language" and "Choose the automatic client language or override it to test a translation."
            or (kind == "alerts" and "Configure ten-second warnings and their blacklist." or "Configure this bar independently from the other bar.")))))
        tooltip(tab, L(tabTitle), L(tabHelp))
        tabs[kind] = tab
    end

    local function returnToDebuffs()
        dismissTransientUI()
        debuffPageState.current = nil
        refreshConfig()
    end
    local function makeDebuffBackButton(parent)
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        button:SetSize(145, 24)
        button:SetPoint("TOPLEFT", 25, -82)
        button:SetText(L("Back to Debuffs"))
        button:SetScript("OnClick", returnToDebuffs)
        return button
    end
    local debuffNavButtons = {}
    local openCustomTrackerEditor
    local debuffDestinations = {
        { "sounds", "Sound Alerts" }, { "appearance", "Appearance" },
        { "library", "Debuff Library" }, { "trackers", "Personal Trackers" },
    }
    for index, spec in ipairs(debuffDestinations) do
        local button = CreateFrame("Button", nil, layoutPanel, "UIPanelButtonTemplate")
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        button:SetSize(250, 27)
        button.autoFitMaxWidth = 250
        -- Keep the nested Debuff pages in their own two-row block above the
        -- existing test/move/reset toolbar at the bottom of this panel.
        button:SetPoint("BOTTOMLEFT", 25 + column * 335, 94 - row * 36)
        button:SetText(L(spec[2]))
        button:SetScript("OnClick", function()
            dismissTransientUI()
            if spec[1] == "trackers" then
                openCustomTrackerEditor()
            else
                debuffPageState.current = spec[1]
                refreshConfig()
            end
        end)
        debuffNavButtons[index] = button
    end
    debuffPageState.navigation = debuffNavButtons

    local debuffAlertHeading = debuffAlertsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    debuffAlertHeading:SetPoint("TOPLEFT", 25, -120)
    debuffAlertHeading:SetText(L("Sound Alerts"))
    theme.StyleSectionHeading(debuffAlertHeading)
    makeDebuffBackButton(debuffAlertsPanel)
    local debuffAlertHelp = debuffAlertsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    debuffAlertHelp:SetPoint("TOPLEFT", debuffAlertHeading, "BOTTOMLEFT", 0, -10)
    debuffAlertHelp:SetWidth(650)
    debuffAlertHelp:SetJustifyH("LEFT")
    debuffAlertHelp:SetText(L("Play combat-safe sounds for known Magic, Curse, Disease, and Poison spell IDs. Registrations are prepared outside combat."))
    local debuffAlertEnable = CreateFrame("CheckButton", nil, debuffAlertsPanel, "UICheckButtonTemplate")
    debuffAlertEnable:SetPoint("TOPLEFT", debuffAlertHelp, "BOTTOMLEFT", 0, -12)
    debuffAlertEnable.textLabel = debuffAlertEnable:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    debuffAlertEnable.textLabel:SetPoint("LEFT", debuffAlertEnable, "RIGHT", 2, 0)
    debuffAlertEnable.textLabel:SetText(L("Enable debuff alert sounds"))
    local debuffAlertStatus = debuffAlertsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    debuffAlertStatus:SetPoint("TOPLEFT", debuffAlertEnable, "BOTTOMLEFT", 4, -8)
    debuffAlertStatus:SetWidth(650)
    debuffAlertStatus:SetJustifyH("LEFT")
    local personalTrackersButton = CreateFrame("Button", nil, debuffAlertsPanel, "UIPanelButtonTemplate")
    personalTrackersButton:SetSize(175, 24)
    personalTrackersButton:SetPoint("TOPRIGHT", debuffAlertsPanel, "TOPRIGHT", -35, -105)
    personalTrackersButton:SetText(L("Personal trackers"))
    personalTrackersButton:Hide()
    local debuffSoundControls = {}
    local debuffKinds = { "Magic", "Curse", "Disease", "Poison" }
    local function combatSoundChoice(choice)
        return choice.value == "none" or choice.value == "default"
            or type(soundSource(choice.value)) == "string"
    end
    local function debuffSoundLabel(value)
        if type(value) == "string" and value:sub(1, 5) == "file:" then
            return value:sub(6):match("([^\\]+)$") or value:sub(6)
        end
        for _, choice in ipairs(mediaChoices("sound")) do
            if choice.value == value then return L(choice.label) end
        end
        return value or L("None")
    end
    local function setDebuffSound(kind, value)
        if InCombatLockdown() then report(L("Change debuff sounds after combat.")); return false end
        getProfile().debuffSounds[kind] = value
        getProfile()["debuffSound" .. kind] = value
        debuffSounds.Sync()
        return true
    end
    local customTrackerEditor, refreshCustomTrackerEditor
    openCustomTrackerEditor = function()
        if not customTrackerEditor then
            local editor = CreateFrame("Frame", nil, frame)
            customTrackerEditor = editor
            debuffPageState.trackers = editor
            editor:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
            editor:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            makeDebuffBackButton(editor)
            editor.title = editor:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            editor.title:SetPoint("TOPLEFT", 25, -120)
            editor.title:SetText(L("Personal debuff trackers"))
            theme.StyleSectionHeading(editor.title)
            editor.help = editor:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            editor.help:SetPoint("TOPLEFT", editor.title, "BOTTOMLEFT", 0, -8)
            editor.help:SetWidth(560)
            editor.help:SetJustifyH("LEFT")
            editor.help:SetText(L("Add an exact debuff Spell ID with its own name and combat-safe sound. Personal entries override learned and seeded sounds."))
            local function fieldLabel(text, x, width)
                local label = editor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                label:SetPoint("TOPLEFT", x, -182)
                label:SetWidth(width)
                label:SetJustifyH("LEFT")
                label:SetText(L(text))
                return label
            end
            fieldLabel("Spell ID", 22, 105)
            fieldLabel("Custom name", 137, 220)
            fieldLabel("Sound", 367, 225)
            editor.spellID = CreateFrame("EditBox", nil, editor, "InputBoxTemplate")
            editor.spellID:SetSize(105, 24)
            editor.spellID:SetPoint("TOPLEFT", 22, -200)
            editor.spellID:SetNumeric(true)
            editor.spellID:SetMaxLetters(10)
            editor.spellID:SetAutoFocus(false)
            theme.StyleInput(editor.spellID)
            editor.name = CreateFrame("EditBox", nil, editor, "InputBoxTemplate")
            editor.name:SetSize(220, 24)
            editor.name:SetPoint("TOPLEFT", 137, -200)
            editor.name:SetMaxLetters(80)
            editor.name:SetAutoFocus(false)
            theme.StyleInput(editor.name)
            editor.sound = "default"
            editor.soundButton = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
            editor.soundButton:SetSize(225, 24)
            editor.soundButton:SetPoint("TOPLEFT", 367, -200)
            decorateSelector(editor.soundButton)
            editor.soundButton:SetScript("OnClick", function()
                openMediaPicker("sound", editor.sound, function(value)
                    editor.sound = value
                    editor.soundButton:SetText(debuffSoundLabel(value))
                end, editor.soundButton, combatSoundChoice)
            end)
            editor.enabled = CreateFrame("CheckButton", nil, editor, "UICheckButtonTemplate")
            editor.enabled:SetPoint("TOPLEFT", 18, -237)
            editor.enabled.textLabel = editor.enabled:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            editor.enabled.textLabel:SetPoint("LEFT", editor.enabled, "RIGHT", 2, 0)
            editor.enabled.textLabel:SetText(L("Enabled"))
            editor.save = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
            editor.save:SetSize(120, 24)
            editor.save:SetPoint("TOPLEFT", 137, -240)
            editor.save:SetText(L("Add tracker"))
            editor.clear = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
            editor.clear:SetSize(95, 24)
            editor.clear:SetPoint("LEFT", editor.save, "RIGHT", 8, 0)
            editor.clear:SetText(L("Clear"))
            editor.pageText = editor:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            editor.pageText:SetPoint("TOPRIGHT", -22, -247)
            editor.page = 1

            local function clearEditor()
                editor.editingID = nil
                editor.spellID:SetText("")
                editor.spellID:Enable()
                editor.name:SetText("")
                editor.sound = "default"
                editor.soundButton:SetText(debuffSoundLabel(editor.sound))
                editor.enabled:SetChecked(true)
                editor.save:SetText(L("Add tracker"))
            end
            editor.clear:SetScript("OnClick", clearEditor)
            editor.save:SetScript("OnClick", function()
                if InCombatLockdown() then report(L("Change debuff sounds after combat.")); return end
                local spellID = tonumber(editor.spellID:GetText())
                local name = editor.name:GetText():match("^%s*(.-)%s*$")
                if not spellID or spellID < 1 or spellID % 1 ~= 0 then report(L("Enter a valid Spell ID.")); return end
                if name == "" then report(L("Enter a custom name.")); return end
                local trackers = getProfile().customDebuffTrackers
                if editor.editingID and editor.editingID ~= spellID then trackers[editor.editingID] = nil end
                trackers[spellID] = { name = name, sound = editor.sound, enabled = editor.enabled:GetChecked() and true or false }
                debuffSounds.Sync()
                clearEditor()
                refreshCustomTrackerEditor()
                refreshConfig()
            end)

            editor.rows = {}
            for index = 1, 7 do
                local row = CreateFrame("Frame", nil, editor, "BackdropTemplate")
                row:SetSize(576, 40)
                row:SetPoint("TOPLEFT", 22, -280 - (index - 1) * 43)
                row:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
                row:SetBackdropColor(unpack(theme.raised))
                row:SetBackdropBorderColor(unpack(theme.border))
                row.toggle = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
                row.toggle:SetPoint("LEFT", 4, 0)
                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.text:SetPoint("LEFT", 39, 0)
                row.text:SetWidth(335)
                row.text:SetJustifyH("LEFT")
                row.edit = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                row.edit:SetSize(78, 22)
                row.edit:SetPoint("RIGHT", -94, 0)
                row.edit:SetText(L("Edit"))
                row.remove = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                row.remove:SetSize(82, 22)
                row.remove:SetPoint("RIGHT", -7, 0)
                row.remove:SetText(L("Remove"))
                editor.rows[index] = row
            end
            editor.previous = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
            editor.previous:SetSize(90, 22)
            editor.previous:SetPoint("BOTTOMLEFT", 22, 18)
            editor.previous:SetText(L("Previous"))
            editor.next = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
            editor.next:SetSize(90, 22)
            editor.next:SetPoint("LEFT", editor.previous, "RIGHT", 8, 0)
            editor.next:SetText(L("Next"))
            editor.previous:SetScript("OnClick", function() editor.page = math.max(1, editor.page - 1); refreshCustomTrackerEditor() end)
            editor.next:SetScript("OnClick", function() editor.page = editor.page + 1; refreshCustomTrackerEditor() end)

            refreshCustomTrackerEditor = function()
                local entries = {}
                for spellID, tracker in pairs(getProfile().customDebuffTrackers or {}) do
                    entries[#entries + 1] = { id = spellID, tracker = tracker }
                end
                table.sort(entries, function(a, b) return a.id < b.id end)
                local pages = math.max(1, math.ceil(#entries / #editor.rows))
                editor.page = math.min(editor.page, pages)
                editor.pageText:SetText(string.format(L("Page %d of %d"), editor.page, pages))
                editor.previous:SetEnabled(editor.page > 1)
                editor.next:SetEnabled(editor.page < pages)
                local first = (editor.page - 1) * #editor.rows
                for index, row in ipairs(editor.rows) do
                    local entry = entries[first + index]
                    row:SetShown(entry ~= nil)
                    if entry then
                        local tracker, spellID = entry.tracker, entry.id
                        row.toggle:SetChecked(tracker.enabled ~= false)
                        row.text:SetText(tostring(spellID) .. "  " .. tracker.name .. "  —  " .. debuffSoundLabel(tracker.sound))
                        row.toggle:SetScript("OnClick", function(self)
                            if InCombatLockdown() then self:SetChecked(tracker.enabled ~= false); report(L("Change debuff sounds after combat.")); return end
                            tracker.enabled = self:GetChecked() and true or false
                            debuffSounds.Sync(); refreshConfig()
                        end)
                        row.edit:SetScript("OnClick", function()
                            editor.editingID = spellID
                            editor.spellID:SetText(spellID)
                            editor.spellID:Disable()
                            editor.name:SetText(tracker.name)
                            editor.sound = tracker.sound
                            editor.soundButton:SetText(debuffSoundLabel(editor.sound))
                            editor.enabled:SetChecked(tracker.enabled ~= false)
                            editor.save:SetText(L("Update tracker"))
                        end)
                        row.remove:SetScript("OnClick", function()
                            if InCombatLockdown() then report(L("Change debuff sounds after combat.")); return end
                            getProfile().customDebuffTrackers[spellID] = nil
                            debuffSounds.Sync(); refreshCustomTrackerEditor(); refreshConfig()
                        end)
                    end
                end
            end
            debuffPageState.refreshTrackers = refreshCustomTrackerEditor
            editor:SetScript("OnShow", function() clearEditor(); refreshCustomTrackerEditor() end)
            editor:Hide()
        end
        debuffPageState.current = "trackers"
        refreshConfig()
        refreshCustomTrackerEditor()
    end
    personalTrackersButton:SetScript("OnClick", openCustomTrackerEditor)
    tooltip(personalTrackersButton, L("Personal trackers"), L("Add exact Spell IDs with custom names and individual sounds."))

    makeDebuffBackButton(debuffLibraryPanel)
    local libraryHeading = debuffLibraryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    libraryHeading:SetPoint("TOPLEFT", 25, -120)
    libraryHeading:SetText(L("Debuff Library"))
    theme.StyleSectionHeading(libraryHeading)
    local libraryHelp = debuffLibraryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryHelp:SetPoint("TOPLEFT", libraryHeading, "BOTTOMLEFT", 0, -8)
    libraryHelp:SetWidth(640)
    libraryHelp:SetJustifyH("LEFT")
    libraryHelp:SetText(L("Search the build-matched debuff catalog. Use the check or X to add or remove a Personal Tracker."))

    local librarySearch = CreateFrame("EditBox", nil, debuffLibraryPanel, "InputBoxTemplate")
    librarySearch:SetSize(390, 25)
    librarySearch:SetPoint("TOPLEFT", libraryHelp, "BOTTOMLEFT", 0, -14)
    librarySearch:SetAutoFocus(false)
    librarySearch:SetMaxLetters(80)
    theme.StyleInput(librarySearch)
    local librarySearchLabel = debuffLibraryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    librarySearchLabel:SetPoint("BOTTOMLEFT", librarySearch, "TOPLEFT", 2, 3)
    librarySearchLabel:SetText(L("Search by name, type, or Spell ID"))
    local libraryCount = debuffLibraryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    libraryCount:SetPoint("LEFT", librarySearch, "RIGHT", 14, 0)
    libraryCount:SetWidth(225)
    libraryCount:SetJustifyH("RIGHT")

    local libraryScroll = CreateFrame("ScrollFrame", nil, debuffLibraryPanel, "UIPanelScrollFrameTemplate")
    libraryScroll:SetPoint("TOPLEFT", 25, -225)
    libraryScroll:SetPoint("BOTTOMRIGHT", -42, 28)
    local libraryChild = CreateFrame("Frame", nil, libraryScroll)
    libraryChild:SetWidth(620)
    libraryChild:SetHeight(1)
    libraryScroll:SetScrollChild(libraryChild)
    local libraryRows = {}
    local libraryInfoCache = {}
    local libraryTooltipScanner
    local refreshDebuffLibrary

    local function tooltipSpellDescription(spellID, spellName)
        if C_TooltipInfo and C_TooltipInfo.GetSpellByID then
            local ok, data = pcall(C_TooltipInfo.GetSpellByID, spellID)
            if ok and type(data) == "table" and type(data.lines) == "table" then
                for index = #data.lines, 2, -1 do
                    local line = data.lines[index]
                    local value = line and (line.leftText or line.rightText)
                    if type(value) == "string" and value ~= "" and value ~= spellName then
                        return value
                    end
                end
            end
        end

        if not libraryTooltipScanner then
            libraryTooltipScanner = CreateFrame("GameTooltip", "ForeverBuffFramesLibraryTooltipScanner", UIParent, "GameTooltipTemplate")
            libraryTooltipScanner:SetOwner(UIParent, "ANCHOR_NONE")
        end
        libraryTooltipScanner:ClearLines()
        local ok = pcall(libraryTooltipScanner.SetSpellByID, libraryTooltipScanner, spellID)
        if ok then
            for index = libraryTooltipScanner:NumLines(), 2, -1 do
                local line = _G["ForeverBuffFramesLibraryTooltipScannerTextLeft" .. index]
                local value = line and line:GetText()
                if type(value) == "string" and value ~= "" and value ~= spellName then
                    return value
                end
            end
        end
    end

    local function librarySpellInfo(spellID, entry)
        local cached = libraryInfoCache[spellID]
        if cached then return cached.name, cached.icon, cached.description end
        local name, icon, description = entry.name, entry.icon, entry.description
        if C_Spell then
            if C_Spell.GetSpellInfo then
                local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
                if ok and type(info) == "table" then
                    if type(info.name) == "string" and info.name ~= "" then name = info.name end
                    if type(info.iconID) == "number" then icon = info.iconID end
                end
            end
            if C_Spell.GetSpellTexture then
                local ok, value = pcall(C_Spell.GetSpellTexture, spellID)
                if ok and value then icon = value end
            end
            if C_Spell.GetSpellDescription then
                local ok, value = pcall(C_Spell.GetSpellDescription, spellID)
                if ok and type(value) == "string" and value ~= "" then description = value end
            end
        end
        description = tooltipSpellDescription(spellID, name) or description
        cached = {
            name = name or (L("Spell") .. " " .. tostring(spellID)),
            icon = icon or 134400,
            description = description or L("No description is available from this client build."),
        }
        libraryInfoCache[spellID] = cached
        return cached.name, cached.icon, cached.description
    end

    local function makeLibraryRow(index)
        local row = CreateFrame("Frame", nil, libraryChild, "BackdropTemplate")
        row:SetSize(615, 66)
        row:SetPoint("TOPLEFT", 0, -(index - 1) * 70)
        row:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 9, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        row:SetBackdropColor(unpack(theme.raised))
        row:SetBackdropBorderColor(unpack(theme.border))
        row:EnableMouse(true)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(40, 40)
        row.icon:SetPoint("LEFT", 10, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, -7)
        row.name:SetWidth(425)
        row.name:SetJustifyH("LEFT")
        row.description = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.description:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -4)
        row.description:SetWidth(500)
        row.description:SetHeight(28)
        row.description:SetJustifyH("LEFT")
        row.description:SetJustifyV("TOP")
        row.toggle = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.toggle:SetSize(42, 30)
        row.toggle.autoFitMaxWidth = 42
        row.toggle.autoFitMaxHeight = 30
        row.toggle:SetPoint("RIGHT", -12, 0)
        row.toggle.owner = row
        row.toggle.check = row.toggle:CreateTexture(nil, "OVERLAY")
        row.toggle.check:SetSize(22, 22)
        row.toggle.check:SetPoint("CENTER")
        row.toggle.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        row.toggle.check:SetVertexColor(0.45, 1, 0.45)
        row.toggle:SetScript("OnClick", function(self)
            if InCombatLockdown() then report(L("Change debuff sounds after combat.")); return end
            local owner = self.owner
            local trackers = getProfile().customDebuffTrackers
            if trackers[owner.spellID] then
                trackers[owner.spellID] = nil
            else
                trackers[owner.spellID] = { name = owner.spellName, sound = "default", enabled = true }
            end
            debuffSounds.Sync()
            refreshDebuffLibrary()
            if debuffPageState.refreshTrackers then debuffPageState.refreshTrackers() end
        end)
        row.toggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L(getProfile().customDebuffTrackers[self.owner.spellID] and "Remove Personal Tracker" or "Add Personal Tracker"))
            GameTooltip:Show()
        end)
        row.toggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.spellName or L("Debuff"))
            GameTooltip:AddLine(L("%s · Spell ID %d", self.spellKind or L("Unknown"), self.spellID or 0), 0.72, 0.61, 0.45)
            GameTooltip:AddLine(self.spellDescription or L("No description is available from this client build."), 1, 1, 1, true)
            GameTooltip:AddLine((FBF.DebuffSoundLibrary and FBF.DebuffSoundLibrary.source) or L("Unknown source"), 0.55, 0.75, 1, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        libraryRows[index] = row
        return row
    end

    refreshDebuffLibrary = function()
        local catalog = FBF.DebuffSoundLibrary and FBF.DebuffSoundLibrary.entries or {}
        local query = librarySearch:GetText():lower():match("^%s*(.-)%s*$")
        local matches = {}
        local eligible = FBF.DebuffSoundLibrary and FBF.DebuffSoundLibrary.catalogEligible
        for spellID, entry in pairs(catalog) do
            if not eligible or eligible[spellID] then
            local name, icon, description = librarySpellInfo(spellID, entry)
            local haystack = (name .. " " .. entry.kind .. " " .. tostring(spellID) .. " " .. description):lower()
            if query == "" or haystack:find(query, 1, true) then
                matches[#matches + 1] = { id = spellID, entry = entry, name = name, icon = icon, description = description }
            end
            end
        end
        table.sort(matches, function(a, b)
            local an, bn = a.name:lower(), b.name:lower()
            return an == bn and a.id < b.id or an < bn
        end)
        local trackers = getProfile().customDebuffTrackers
        for index, match in ipairs(matches) do
            local row = libraryRows[index] or makeLibraryRow(index)
            row.spellID, row.spellName = match.id, match.name
            row.spellKind, row.spellDescription = match.entry.kind, match.description
            row.icon:SetTexture(match.icon)
            row.name:SetText(match.name .. "  |cffb89b72" .. match.entry.kind .. " · " .. L("Spell ID") .. " " .. tostring(match.id) .. "|r")
            row.description:SetText(match.description)
            local tracked = trackers[match.id] ~= nil
            row.toggle:SetText(tracked and "X" or "")
            row.toggle.check:SetShown(not tracked)
            local label = row.toggle:GetFontString()
            if label then label:SetTextColor(tracked and 1 or 0.45, tracked and 0.35 or 1, tracked and 0.25 or 0.45) end
            row:Show()
        end
        for index = #matches + 1, #libraryRows do libraryRows[index]:Hide() end
        libraryChild:SetHeight(math.max(1, #matches * 70))
        libraryCount:SetText(L("%d debuffs · build %s", #matches, FBF.DebuffSoundLibrary.build or "unknown"))
    end
    librarySearch:SetScript("OnTextChanged", refreshDebuffLibrary)
    librarySearch:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    debuffPageState.refreshLibrary = refreshDebuffLibrary

    for index, kind in ipairs(debuffKinds) do
        local row = CreateFrame("Frame", nil, debuffAlertsPanel, "BackdropTemplate")
        row:SetSize(650, 78)
        row:SetPoint("TOPLEFT", 25, -375 - (index - 1) * 84)
        row:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        row:SetBackdropColor(unpack(theme.raised))
        row:SetBackdropBorderColor(unpack(theme.border))
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.label:SetPoint("TOPLEFT", 12, -10)
        row.label:SetText(L(kind))
        row.selector = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.selector:SetSize(245, 24)
        row.selector:SetPoint("TOPLEFT", 105, -7)
        decorateSelector(row.selector)
        row.preview = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.preview:SetSize(88, 24)
        row.preview:SetPoint("LEFT", row.selector, "RIGHT", 8, 0)
        row.preview:SetText(L("Preview"))
        row.preview:SetScript("OnClick", function() debuffSounds.Test(kind) end)
        row.path = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        row.path:SetSize(395, 22)
        row.path:SetPoint("TOPLEFT", 105, -43)
        row.path:SetAutoFocus(false)
        row.path:SetMaxLetters(240)
        theme.StyleInput(row.path)
        row.path:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        row.usePath = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.usePath:SetSize(125, 22)
        row.usePath:SetPoint("LEFT", row.path, "RIGHT", 8, 0)
        row.usePath:SetText(L("Use custom file"))
        row.usePath:SetScript("OnClick", function()
            local path = row.path:GetText():match("^%s*(.-)%s*$"):gsub("/", "\\")
            if path == "" then report(L("Enter a custom sound path first.")); return end
            if not path:lower():match("^interface\\") then path = "Interface\\AddOns\\ForeverBuffFrames\\" .. path end
            if setDebuffSound(kind, "file:" .. path) then refreshConfig() end
        end)
        row.selector:SetScript("OnClick", function()
            openMediaPicker("sound", getProfile().debuffSounds[kind], function(value)
                if setDebuffSound(kind, value) then refreshConfig() end
            end, row.selector, combatSoundChoice)
        end)
        tooltip(row.path, L("Custom sound file"), L("Enter a path relative to the ForeverBuffFrames addon, or a full Interface path. Restart WoW after copying a new sound file."))
        debuffSoundControls[kind] = row
    end
    debuffAlertEnable:SetScript("OnClick", function(self)
        if InCombatLockdown() then self:SetChecked(getProfile().debuffSoundsEnabled); report(L("Change debuff sounds after combat.")); return end
        getProfile().debuffSoundsEnabled = self:GetChecked() and true or false
        debuffSounds.Sync()
        refreshConfig()
    end)
    local function refreshDebuffAlerts()
        local soundState = debuffSounds.GetStatus()
        debuffAlertEnable:SetChecked(getProfile().debuffSoundsEnabled)
        debuffAlertStatus:SetText(L("Status") .. ": " .. L(soundState.state or "Unavailable") .. " — " ..
            tostring(soundState.registered or 0) .. " " .. L("registered") .. ", " ..
            tostring(soundState.learned or 0) .. " " .. L("learned") .. ", " ..
            tostring(soundState.seed or 0) .. " " .. L("seeded") .. ", " ..
            tostring(soundState.custom or 0) .. " " .. L("personal"))
        for _, kind in ipairs(debuffKinds) do
            local value = getProfile().debuffSounds[kind]
            local row = debuffSoundControls[kind]
            row.selector:SetText(debuffSoundLabel(value))
            row.path:SetText(type(value) == "string" and value:sub(1, 5) == "file:" and value:sub(6) or "")
        end
    end

    makeDebuffBackButton(debuffAppearancePanel)
    local debuffAppearanceHeading = debuffAppearancePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    debuffAppearanceHeading:SetPoint("TOPLEFT", 25, -120)
    debuffAppearanceHeading:SetText(L("Debuff Appearance"))
    theme.StyleSectionHeading(debuffAppearanceHeading)
    local debuffAppearanceHelp = debuffAppearancePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    debuffAppearanceHelp:SetPoint("TOPLEFT", debuffAppearanceHeading, "BOTTOMLEFT", 0, -10)
    debuffAppearanceHelp:SetWidth(650)
    debuffAppearanceHelp:SetJustifyH("LEFT")
    debuffAppearanceHelp:SetText(L("Configure debuff borders, corner icons, pulsing, thickness, and expansion."))

    local languageHeading = languagePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    languageHeading:SetPoint("TOPLEFT", 25, -105)
    languageHeading:SetText(L("Language settings"))
    theme.StyleSectionHeading(languageHeading)
    local languageHelp = languagePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    languageHelp:SetPoint("TOPLEFT", languageHeading, "BOTTOMLEFT", 0, -14)
    languageHelp:SetWidth(490)
    languageHelp:SetJustifyH("LEFT")
    languageHelp:SetText(L("Automatic follows the WoW client language. Select another language to review its translation, then reload the interface."))
    local clientLanguage = languagePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    clientLanguage:SetPoint("TOPLEFT", languageHelp, "BOTTOMLEFT", 0, -18)
    clientLanguage:SetText(L("Client language") .. ": " .. FBF.Locale.Name(FBF.Locale.GetClient()))
    local displayedLanguage = languagePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    displayedLanguage:SetPoint("TOPLEFT", clientLanguage, "BOTTOMLEFT", 0, -8)
    displayedLanguage:SetText(L("Displayed language") .. ": " .. FBF.Locale.Name(FBF.Locale.GetActive()))
    local languageButton = CreateFrame("Button", nil, languagePanel, "UIPanelButtonTemplate")
    languageButton:SetSize(300, 27)
    languageButton:SetPoint("TOPLEFT", displayedLanguage, "BOTTOMLEFT", 0, -18)
    decorateSelector(languageButton)
    local pendingLocale = getDatabase().uiLocale or "auto"
    local function updateLanguageButton()
        local name = pendingLocale == "auto" and L("Automatic") or FBF.Locale.Name(pendingLocale)
        -- Keep the selector text in one writing system. Locale-specific Blizzard
        -- fonts do not necessarily contain glyphs for the currently displayed
        -- language and the newly selected language at the same time.
        languageButton:SetText(name)
        setConfigLocaleFont(languageButton:GetFontString(), pendingLocale)
    end
    updateLanguageButton()
    languageButton:SetScript("OnClick", function()
        if openMenu then openMenu:Hide(); openMenu = nil; return end
        local choices = FBF.Locale.supported
        local menu = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        menu:SetFrameStrata("DIALOG")
        menu:SetFrameLevel(frame:GetFrameLevel() + 20)
        menu:SetSize(300, #choices * 27 + 12)
        menu:SetPoint("TOPLEFT", languageButton, "BOTTOMLEFT", 0, -2)
        theme.ApplyPopup(menu)
        local localeLabels = {}
        for index, entry in ipairs(choices) do
            local code, nativeName = entry[1], entry[2]
            local choice = CreateFrame("Button", nil, menu)
            choice:SetSize(286, 26)
            choice:SetPoint("TOPLEFT", 7, -6 - (index - 1) * 27)
            theme.AddRowHighlight(choice, 1)
            local label = choice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("LEFT", 9, 0)
            label:SetText(code == "auto" and L("Automatic") or nativeName)
            setConfigLocaleFont(label, code)
            localeLabels[#localeLabels + 1] = { label, code }
            choice:SetScript("OnClick", function()
                pendingLocale = code
                updateLanguageButton()
                fitConfigButton(languageButton)
                if refreshConfig then refreshConfig() end
                setConfigLocaleFont(languageButton:GetFontString(), pendingLocale)
                menu:Hide()
                openMenu = nil
            end)
        end
        applyConfigTextSize(menu, getDatabase().uiTextSize or 0)
        for _, entry in ipairs(localeLabels) do setConfigLocaleFont(entry[1], entry[2]) end
        openMenu = menu
    end)
    local applyLanguage = CreateFrame("Button", nil, languagePanel, "UIPanelButtonTemplate")
    applyLanguage:SetSize(180, 27)
    applyLanguage:SetPoint("TOPLEFT", languageButton, "BOTTOMLEFT", 0, -18)
    applyLanguage:SetText(L("Apply and reload"))
    applyLanguage:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Change language after combat.")); return end
        getDatabase().uiLocale = pendingLocale
        ReloadUI()
    end)

    -- Diagnostics are deliberately pull-based: opening this panel only reads
    -- capability flags. Tests and retries require an explicit button press.
    local diagnosticsHeading = diagnosticsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    diagnosticsHeading:SetPoint("TOPLEFT", 25, -105)
    diagnosticsHeading:SetText(L("Diagnostics"))
    theme.StyleSectionHeading(diagnosticsHeading)
    local diagnosticsHelp = diagnosticsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    diagnosticsHelp:SetPoint("TOPLEFT", diagnosticsHeading, "BOTTOMLEFT", 0, -10)
    diagnosticsHelp:SetWidth(650)
    diagnosticsHelp:SetJustifyH("LEFT")
    diagnosticsHelp:SetText(L("Preview existing effects and copy a compact report for support. Opening this tab does not change gameplay settings."))

    local testHeading = diagnosticsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    testHeading:SetPoint("TOPLEFT", diagnosticsHelp, "BOTTOMLEFT", 0, -18)
    testHeading:SetText(L("Test Lab"))
    theme.StyleSectionHeading(testHeading)
    local testHelp = diagnosticsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    testHelp:SetPoint("TOPLEFT", testHeading, "BOTTOMLEFT", 0, -8)
    testHelp:SetWidth(310)
    testHelp:SetJustifyH("LEFT")
    testHelp:SetText(L("These previews use the addon's current test icons and alert sound. Combat-safe feature probes will be added in their own phases."))
    local diagnosticTestIcons = CreateFrame("Button", nil, diagnosticsPanel, "UIPanelButtonTemplate")
    diagnosticTestIcons:SetSize(155, 25)
    diagnosticTestIcons:SetPoint("TOPLEFT", testHelp, "BOTTOMLEFT", 0, -12)
    diagnosticTestIcons:SetText(L("Toggle test icons"))
    diagnosticTestIcons:SetScript("OnClick", toggleTest)
    local diagnosticSound = CreateFrame("Button", nil, diagnosticsPanel, "UIPanelButtonTemplate")
    diagnosticSound:SetSize(155, 25)
    diagnosticSound:SetPoint("LEFT", diagnosticTestIcons, "RIGHT", 8, 0)
    diagnosticSound:SetText(L("Play test sound"))
    diagnosticSound:SetScript("OnClick", function() handleAlertCommand("sound") end)

    local statusHeading = diagnosticsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusHeading:SetPoint("TOPLEFT", 375, -168)
    statusHeading:SetText(L("System Status"))
    theme.StyleSectionHeading(statusHeading)
    local statusText = diagnosticsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("TOPLEFT", statusHeading, "BOTTOMLEFT", 0, -10)
    statusText:SetWidth(320)
    statusText:SetJustifyH("LEFT")
    statusText:SetJustifyV("TOP")

    local reportFrame = CreateFrame("Frame", nil, diagnosticsPanel, "BackdropTemplate")
    reportFrame:SetPoint("TOPLEFT", 25, -500)
    reportFrame:SetSize(650, 195)
    reportFrame:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    reportFrame:SetBackdropColor(unpack(theme.raised))
    reportFrame:SetBackdropBorderColor(unpack(theme.border))
    local function layoutDiagnosticReport(expanded)
        reportFrame:ClearAllPoints()
        reportFrame:SetPoint("TOPLEFT", 25, -500)
        reportFrame:SetHeight(195)
    end
    local reportScroll = CreateFrame("ScrollFrame", nil, reportFrame, "UIPanelScrollFrameTemplate")
    reportScroll:SetPoint("TOPLEFT", 8, -8)
    reportScroll:SetPoint("BOTTOMRIGHT", -29, 8)
    local reportBox = CreateFrame("EditBox", nil, reportScroll)
    reportBox:SetSize(610, 179)
    reportScroll:SetScrollChild(reportBox)
    reportBox:SetMultiLine(true)
    reportBox:SetAutoFocus(false)
    reportBox:SetMaxLetters(0)
    reportBox:SetFontObject("ChatFontNormal")
    reportBox:SetTextInsets(4, 4, 4, 4)
    reportBox:SetJustifyH("LEFT")
    reportBox:SetJustifyV("TOP")
    reportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    reportBox:SetScript("OnTextChanged", function(self)
        local textHeight = self.GetTextHeight and self:GetTextHeight() or nil
        self:SetHeight(math.max(179, (tonumber(textHeight) or 163) + 16))
        reportScroll:UpdateScrollChildRect()
    end)
    reportScroll:SetScript("OnSizeChanged", function(self, width)
        reportBox:SetWidth(math.max(1, width - 8))
        self:UpdateScrollChildRect()
    end)
    theme.StyleInput(reportBox)

    local clearStatus
    local function diagnosticValues()
        local version, build, _, interface = GetBuildInfo()
        local restricted = InCombatLockdown() and true or false
        if C_Secrets and C_Secrets.ShouldAurasBeSecret then
            local ok, value = pcall(C_Secrets.ShouldAurasBeSecret)
            if ok then
                restricted = (issecretvalue and issecretvalue(value)) and true or (value and true or false)
            end
        end
        local container = auraFrames.GetContainer("buffs") or auraFrames.GetContainer("debuffs")
        local state = getDiagnosticState()
        local soundState = debuffSounds and debuffSounds.GetStatus() or {}
        local removalState = buffRemovalSounds.GetStatus and buffRemovalSounds.GetStatus() or {}
        return {
            client = tostring(version or "?") .. " (" .. tostring(build or "?") .. ")",
            interface = tostring(interface or "?"),
            restricted = restricted,
            container = container ~= nil,
            dispel = C_AuraContainerUtil and C_AuraContainerUtil.ProcessCustomAuraButtonDispelTypeTextureOptions ~= nil,
            typed = container and container.SetAuraGroupCandidateFilters ~= nil,
            sound = C_UnitAuras and C_UnitAuras.AddAuraSound ~= nil,
            tracking = C_Minimap and C_Minimap.GetNumTrackingTypes ~= nil and C_Minimap.GetTrackingInfo ~= nil,
            awareness = auraFrames.GetAwarenessResult and auraFrames.GetAwarenessResult() or "Unavailable",
            debuffSounds = soundState.state or "Unavailable",
            soundRegistrations = soundState.registered or 0,
            learnedDebuffs = soundState.learned or 0,
            seedDebuffs = soundState.seed or 0,
            removalState = removalState.state or "Unavailable",
            removalRegistered = removalState.registered or 0,
            removalCombatRegistered = removalState.combatRegistered or 0,
            removalCombatAttempts = removalState.combatAttempts or 0,
            removalLastCombatRegistered = removalState.lastCombatRegistered or 0,
            removalLastCombatFailure = removalState.lastCombatFailure,
            removalLearned = removalState.learned or 0,
            blocked = state and state.lastBlocked or nil,
        }
    end
    local function yesNo(value) return L(value and "Available" or "Unavailable") end
    local function diagnosticReport()
        local v = diagnosticValues()
        return table.concat({
            "ForeverBuffFrames diagnostics",
            "Addon: " .. tostring((C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("ForeverBuffFrames", "Version"))
                or (GetAddOnMetadata and GetAddOnMetadata("ForeverBuffFrames", "Version")) or "unknown"),
            "Client: " .. v.client,
            "Interface: " .. v.interface,
            "Locale: " .. tostring(FBF.Locale.GetActive()),
            "Combat: " .. tostring(InCombatLockdown() and true or false),
            "Auras restricted: " .. tostring(v.restricted),
            "Aura container: " .. tostring(v.container),
            "Native dispel styling: " .. tostring(v.dispel),
            "Typed candidate filters: " .. tostring(v.typed),
            "Aura sounds: " .. tostring(v.sound),
            "Tracking API: " .. tostring(v.tracking),
            "Debuff awareness: " .. tostring(v.awareness),
            "Debuff sounds: " .. tostring(v.debuffSounds),
            "Debuff sound registrations: " .. tostring(v.soundRegistrations),
            "Learned debuffs: " .. tostring(v.learnedDebuffs),
            "Seed debuffs: " .. tostring(v.seedDebuffs),
            "Combat buff removal sounds: " .. tostring(v.removalState),
            "Buff removal learned/registered: " .. tostring(v.removalLearned) .. "/" .. tostring(v.removalRegistered),
            "Combat-only registrations current/last/attempts: " .. tostring(v.removalCombatRegistered) .. "/" ..
                tostring(v.removalLastCombatRegistered) .. "/" .. tostring(v.removalCombatAttempts),
            "Last combat-only registration error: " .. tostring(v.removalLastCombatFailure or "none"),
            "Last blocked operation: " .. tostring(v.blocked or "none"),
        }, "\n")
    end
    local function refreshDiagnostics()
        local v = diagnosticValues()
        statusText:SetText(table.concat({
            L("Client") .. ": " .. v.client,
            L("Interface") .. ": " .. v.interface,
            L("Aura data restricted") .. ": " .. L(v.restricted and "Yes" or "No"),
            L("Aura containers") .. ": " .. yesNo(v.container),
            L("Native dispel styling") .. ": " .. yesNo(v.dispel),
            L("Typed aura filters") .. ": " .. yesNo(v.typed),
            L("Combat-safe aura sounds") .. ": " .. yesNo(v.sound),
            L("Tracking API") .. ": " .. yesNo(v.tracking),
            L("Debuff awareness") .. ": " .. L(v.awareness),
            L("Debuff sounds") .. ": " .. L(v.debuffSounds) .. " (" ..
                v.soundRegistrations .. " " .. L("registered") .. ", " ..
                v.learnedDebuffs .. " " .. L("learned") .. ", " ..
                v.seedDebuffs .. " " .. L("seeded") .. ")",
            L("Combat buff removal sounds") .. ": " .. L(v.removalState) .. " (" ..
                v.removalRegistered .. " " .. L("registered") .. ", " ..
                v.removalLearned .. " " .. L("learned") .. ", " ..
                v.removalCombatRegistered .. " " .. L("combat-only") .. ")",
            L("Last blocked operation") .. ": " .. (v.blocked or L("None")),
        }, "\n"))
        if clearStatus then clearStatus:SetEnabled(v.blocked ~= nil) end
    end
    local refreshStatus = CreateFrame("Button", nil, diagnosticsPanel, "UIPanelButtonTemplate")
    refreshStatus:SetSize(120, 24)
    refreshStatus:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -10)
    refreshStatus:SetText(L("Recheck capabilities"))
    refreshStatus:SetScript("OnClick", refreshDiagnostics)
    tooltip(refreshStatus, L("Recheck capabilities"), L("Read the current combat, aura, sound, tracking, and blocked-action status again."))
    clearStatus = CreateFrame("Button", nil, diagnosticsPanel, "UIPanelButtonTemplate")
    clearStatus:SetSize(120, 24)
    clearStatus:SetPoint("LEFT", refreshStatus, "RIGHT", 8, 0)
    clearStatus:SetText(L("Clear blocked action"))
    clearStatus:SetScript("OnClick", function() clearDiagnosticState(); refreshDiagnostics() end)
    tooltip(clearStatus, L("Clear blocked action"), L("Forget the last ADDON_ACTION_BLOCKED event recorded for this session. This does not hide Lua errors."))
    local copyReport = CreateFrame("Button", nil, diagnosticsPanel, "UIPanelButtonTemplate")
    copyReport:SetSize(150, 24)
    copyReport:SetPoint("BOTTOMLEFT", reportFrame, "TOPLEFT", 0, 8)
    copyReport:SetText(L("Copy diagnostic report"))
    copyReport:SetScript("OnClick", function()
        reportBox:SetText(diagnosticReport())
        reportScroll:SetVerticalScroll(0)
        reportBox:SetFocus()
        reportBox:HighlightText()
    end)
    local retryDiagnostics = CreateFrame("Button", nil, diagnosticsPanel, "UIPanelButtonTemplate")
    retryDiagnostics:SetSize(150, 24)
    retryDiagnostics:SetPoint("LEFT", copyReport, "RIGHT", 8, 0)
    retryDiagnostics:SetText(L("Rescan expiry alerts"))
    retryDiagnostics:SetScript("OnClick", function()
        if InCombatLockdown() then
            report(L("Rescan expiry alerts after combat."))
            return
        end
        alerts.Sync()
        refreshDiagnostics()
    end)
    tooltip(retryDiagnostics, L("Rescan expiry alerts"), L("Scan current buffs again and schedule eligible ten-second expiry alerts. This does not play a test sound."))

    local experimentalCheck = CreateFrame("CheckButton", nil, diagnosticsPanel, "UICheckButtonTemplate")
    experimentalCheck:SetPoint("TOPLEFT", diagnosticTestIcons, "BOTTOMLEFT", 0, -24)
    experimentalCheck.textLabel = experimentalCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    experimentalCheck.textLabel:SetPoint("LEFT", experimentalCheck, "RIGHT", 2, 0)
    experimentalCheck.textLabel:SetText(L("Show experimental tools"))
    local experimentalPanel = CreateFrame("Frame", nil, diagnosticsPanel)
    experimentalPanel:SetPoint("TOPLEFT", experimentalCheck, "BOTTOMLEFT", 0, -8)
    experimentalPanel:SetSize(390, 100)
    local experimentalHelp = experimentalPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    experimentalHelp:SetPoint("TOPLEFT")
    experimentalHelp:SetSize(320, 28)
    experimentalHelp:SetJustifyH("LEFT")
    experimentalHelp:SetJustifyV("TOP")
    experimentalHelp:SetText(L("Preview and opt into native debuff-type borders. These controls do not add sounds."))
    local awarenessCheck = CreateFrame("CheckButton", nil, experimentalPanel, "UICheckButtonTemplate")
    awarenessCheck:SetPoint("TOPLEFT", experimentalHelp, "BOTTOMLEFT", 0, -4)
    awarenessCheck.textLabel = awarenessCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    awarenessCheck.textLabel:SetPoint("LEFT", awarenessCheck, "RIGHT", 2, 0)
    awarenessCheck.textLabel:SetText(L("Enable debuff borders"))
    awarenessCheck:SetScript("OnClick", function(self)
        if InCombatLockdown() then self:SetChecked(getProfile().debuffAwareness); report(L("Change debuff borders after combat.")); return end
        getProfile().debuffAwareness = self:GetChecked() and true or false
        build("debuffs")
    end)
    local pulseCheck = CreateFrame("CheckButton", nil, experimentalPanel, "UICheckButtonTemplate")
    pulseCheck:SetPoint("LEFT", awarenessCheck.textLabel, "RIGHT", 18, 0)
    pulseCheck.textLabel = pulseCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    pulseCheck.textLabel:SetPoint("LEFT", pulseCheck, "RIGHT", 2, 0)
    pulseCheck.textLabel:SetText(L("Pulse borders"))
    pulseCheck:SetScript("OnClick", function(self)
        if InCombatLockdown() then self:SetChecked(getProfile().debuffPulse); report(L("Change debuff borders after combat.")); return end
        getProfile().debuffPulse = self:GetChecked() and true or false
        build("debuffs")
    end)
    local borderStyle = CreateFrame("Button", nil, experimentalPanel, "UIPanelButtonTemplate")
    borderStyle:SetSize(190, 24)
    borderStyle:SetPoint("TOPLEFT", awarenessCheck, "BOTTOMLEFT", 0, -8)
    decorateSelector(borderStyle)
    local styleOrder = { "border", "bordericon", "icon" }
    local styleLabels = { border = "Border", bordericon = "Border and icon", icon = "Corner icon" }
    local function updateBorderStyle() borderStyle:SetText(L(styleLabels[getProfile().debuffBorderStyle] or "Border")) end
    local borderStyleMenu = CreateFrame("Frame", nil, diagnosticsPanel, "BackdropTemplate")
    borderStyleMenu:SetSize(190, #styleOrder * 28 + 12)
    borderStyleMenu:SetPoint("TOPLEFT", borderStyle, "BOTTOMLEFT", 0, -2)
    borderStyleMenu:SetFrameStrata("DIALOG")
    borderStyleMenu:SetFrameLevel(frame:GetFrameLevel() + 20)
    theme.ApplyPopup(borderStyleMenu)
    local borderStyleMenuFill = borderStyleMenu:CreateTexture(nil, "BACKGROUND", nil, -8)
    borderStyleMenuFill:SetPoint("TOPLEFT", 5, -5)
    borderStyleMenuFill:SetPoint("BOTTOMRIGHT", -5, 5)
    borderStyleMenuFill:SetColorTexture(0.025, 0.018, 0.014, 1)
    borderStyleMenu:Hide()
    for index, value in ipairs(styleOrder) do
        local item = CreateFrame("Button", nil, borderStyleMenu)
        item:SetSize(176, 27)
        item:SetPoint("TOPLEFT", 7, -6 - (index - 1) * 28)
        theme.AddRowHighlight(item, 1)
        item.selected = item:CreateTexture(nil, "BACKGROUND")
        item.selected:SetPoint("TOPLEFT", 1, -1)
        item.selected:SetPoint("BOTTOMRIGHT", -1, 1)
        item.selected:SetColorTexture(unpack(theme.accent))
        item.label = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        item.label:SetPoint("LEFT", 9, 0)
        item.label:SetText(L(styleLabels[value]))
        item:SetScript("OnShow", function(self) self.selected:SetShown(getProfile().debuffBorderStyle == value) end)
        item:SetScript("OnClick", function()
            if InCombatLockdown() then report(L("Change debuff borders after combat.")); return end
            getProfile().debuffBorderStyle = value
            borderStyleMenu:Hide()
            openMenu = nil
            updateBorderStyle()
            build("debuffs")
        end)
    end
    borderStyle:SetScript("OnClick", function()
        if openMenu and openMenu ~= borderStyleMenu then openMenu:Hide() end
        local show = not borderStyleMenu:IsShown()
        if show then
            -- SetParent can recalculate frame levels. Raise the popup when it is
            -- opened so controls beneath it cannot draw through the menu fill.
            borderStyleMenu:SetFrameStrata("FULLSCREEN_DIALOG")
            borderStyleMenu:SetFrameLevel(frame:GetFrameLevel() + 100)
        end
        borderStyleMenu:SetShown(show)
        openMenu = show and borderStyleMenu or nil
    end)
    tooltip(borderStyle, L("Debuff border style"), L("Choose the Blizzard-native presentation used by live debuffs and the four-type preview."))
    local previewBorders = CreateFrame("Button", nil, experimentalPanel, "UIPanelButtonTemplate")
    previewBorders:SetSize(170, 24)
    previewBorders:SetPoint("LEFT", borderStyle, "RIGHT", 8, 0)
    previewBorders:SetText(L("Preview"))
    previewBorders:SetScript("OnClick", function()
        previewDebuffAwareness(getProfile().debuffBorderStyle, getProfile().debuffPulse,
            getProfile().debuffBorderThickness, getProfile().debuffPulseExpansion)
    end)
    tooltip(previewBorders, L("Preview"), L("Preview Magic, Curse, Disease, and Poison using the selected border style and pulse setting."))
    awarenessCheck:SetParent(debuffAppearancePanel)
    awarenessCheck:ClearAllPoints()
    awarenessCheck:SetPoint("TOPLEFT", 25, -245)
    pulseCheck:SetParent(debuffAppearancePanel)
    pulseCheck:ClearAllPoints()
    pulseCheck:SetPoint("LEFT", awarenessCheck.textLabel, "RIGHT", 18, 0)
    borderStyle:SetParent(debuffAppearancePanel)
    borderStyle:ClearAllPoints()
    borderStyle:SetPoint("TOPLEFT", 25, -280)
    borderStyleMenu:SetParent(frame)
    borderStyleMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    borderStyleMenu:SetFrameLevel(frame:GetFrameLevel() + 100)
    previewBorders:SetParent(debuffAppearancePanel)
    previewBorders:ClearAllPoints()
    previewBorders:SetPoint("LEFT", borderStyle, "RIGHT", 8, 0)
    local appearanceControls = {}
    local appearanceSyncing = false
    local function makeAppearanceSlider(label, key, minimum, maximum, x)
        local title = debuffAppearancePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        title:SetPoint("TOPLEFT", x, -318)
        title:SetText(L(label))
        local slider = CreateFrame("Slider", nil, debuffAppearancePanel)
        slider:SetSize(200, 18)
        slider:SetPoint("TOPLEFT", x, -338)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(minimum, maximum)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)
        slider:EnableMouseWheel(true)
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        local track = slider:CreateTexture(nil, "BACKGROUND")
        theme.StyleSlider(slider, track)
        track:SetPoint("LEFT", slider, "LEFT")
        track:SetPoint("RIGHT", slider, "RIGHT")
        track:SetHeight(4)
        local box = CreateFrame("EditBox", nil, debuffAppearancePanel, "InputBoxTemplate")
        box:SetSize(48, 20)
        box:SetPoint("LEFT", slider, "RIGHT", 10, 0)
        box:SetAutoFocus(false)
        box:SetJustifyH("CENTER")
        theme.StyleInput(box)
        local function apply(value)
            value = math.floor(value + 0.5)
            if InCombatLockdown() then report(L("Change debuff borders after combat.")); refreshConfig(); return end
            getProfile()[key] = value
            build("debuffs")
            previewDebuffAwareness(getProfile().debuffBorderStyle, getProfile().debuffPulse,
                getProfile().debuffBorderThickness, getProfile().debuffPulseExpansion)
            refreshConfig()
        end
        slider:SetScript("OnValueChanged", function(_, value)
            if not appearanceSyncing then box:SetText(tostring(math.floor(value + 0.5))) end
        end)
        slider:SetScript("OnMouseUp", function(self) apply(self:GetValue()) end)
        slider:SetScript("OnMouseWheel", function(_, delta)
            apply(math.max(minimum, math.min(maximum, getProfile()[key] + (delta > 0 and 1 or -1))))
        end)
        box:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refreshConfig() end)
        box:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            self:ClearFocus()
            if value and value % 1 == 0 and value >= minimum and value <= maximum then apply(value)
            else report(L("%s must be a whole number from %d to %d.", L(label), minimum, maximum)); refreshConfig() end
        end)
        tooltip(slider, L(label), L("Drag the slider or use the mouse wheel for one-point steps."))
        appearanceControls[key] = { slider = slider, box = box }
    end
    makeAppearanceSlider("Border thickness", "debuffBorderThickness", 1, 6, 25)
    makeAppearanceSlider("Pulse expansion", "debuffPulseExpansion", 0, 12, 360)
    local soundEnable = CreateFrame("CheckButton", nil, experimentalPanel, "UICheckButtonTemplate")
    soundEnable:SetPoint("TOPLEFT", borderStyle, "BOTTOMLEFT", 0, -8)
    soundEnable.textLabel = soundEnable:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    soundEnable.textLabel:SetPoint("LEFT", soundEnable, "RIGHT", 2, 0)
    soundEnable.textLabel:SetText(L("Enable learned debuff sounds"))
    soundEnable:SetScript("OnClick", function(self)
        if InCombatLockdown() then self:SetChecked(getProfile().debuffSoundsEnabled); report(L("Change debuff sounds after combat.")); return end
        getProfile().debuffSoundsEnabled = self:GetChecked() and true or false
        debuffSounds.Sync(); refreshDiagnostics()
    end)
    local debuffSoundButton = CreateFrame("Button", nil, experimentalPanel, "UIPanelButtonTemplate")
    debuffSoundButton:SetSize(155, 24)
    debuffSoundButton:SetPoint("TOPLEFT", soundEnable, "BOTTOMLEFT", 0, -6)
    decorateSelector(debuffSoundButton)
    local function updateDebuffSoundButton()
        local selected = getProfile().debuffSounds.Magic
        local label = selected
        for _, choice in ipairs(mediaChoices("sound")) do if choice.value == selected then label = choice.label; break end end
        debuffSoundButton:SetText(L("Debuff sound") .. ": " .. L(label))
    end
    debuffSoundButton:SetScript("OnClick", function()
        openMediaPicker("sound", getProfile().debuffSounds.Magic, function(value)
            for _, kind in ipairs({ "Magic", "Curse", "Disease", "Poison" }) do getProfile().debuffSounds[kind] = value end
            getProfile().debuffSoundName = value
            updateDebuffSoundButton(); debuffSounds.Sync(); refreshDiagnostics()
        end, debuffSoundButton, function(choice)
            return choice.value == "none" or choice.value == "default" or choice.value:sub(1, 4) == "lsm:"
        end)
    end)
    local testDebuffSound = CreateFrame("Button", nil, experimentalPanel, "UIPanelButtonTemplate")
    testDebuffSound:SetSize(80, 24)
    testDebuffSound:SetPoint("LEFT", debuffSoundButton, "RIGHT", 8, 0)
    testDebuffSound:SetText(L("Test sound"))
    testDebuffSound:SetScript("OnClick", function() debuffSounds.Test("Magic") end)
    local clearLearnedDebuffs = CreateFrame("Button", nil, experimentalPanel, "UIPanelButtonTemplate")
    clearLearnedDebuffs:SetSize(120, 24)
    clearLearnedDebuffs:SetPoint("LEFT", testDebuffSound, "RIGHT", 8, 0)
    clearLearnedDebuffs:SetText(L("Clear learned"))
    clearLearnedDebuffs:SetScript("OnClick", function()
        if not debuffSounds.ClearLearned() then report(L("Clear learned debuffs after combat.")); return end
        refreshDiagnostics()
        report(L("Learned debuff data cleared."))
    end)
    -- Sound configuration graduated to its own page after the combat probe
    -- succeeded. Keep Diagnostics focused on capability and border testing.
    soundEnable:Hide()
    debuffSoundButton:Hide()
    testDebuffSound:Hide()
    clearLearnedDebuffs:Hide()
    experimentalPanel:Hide()
    experimentalCheck:Hide()
    experimentalCheck:SetScript("OnClick", function(self)
        experimentalPanel:SetShown(self:GetChecked())
        layoutDiagnosticReport(self:GetChecked())
        if not self:GetChecked() then borderStyleMenu:Hide(); if openMenu == borderStyleMenu then openMenu = nil end end
    end)
    tooltip(experimentalCheck, L("Show experimental tools"), L("Reveal opt-in development probes. They never run merely because this tab is opened."))

    local syncing = false
    local numericControls = {}
    for i, spec in ipairs(numericSettings) do
        local label, key, minimum, maximum, description = unpack(spec)
        label, description = L(label), L(description)
        local isText = key == "timerSize" or key == "countSize"
        local parent = isText and textControls or layoutControls
        local index = isText and (i - 5) or i
        local y = -145 - (index - 1) * 62
        local titleText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        titleText:SetPoint("TOPLEFT", 25, y)
        titleText:SetText(label)
        local slider = CreateFrame("Slider", nil, parent)
        slider:SetSize(240, 18)
        slider:SetPoint("TOPLEFT", 25, y - 18)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(minimum, maximum)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)
        slider:EnableMouseWheel(true)
        tooltip(slider, label, description .. L(" Drag the slider or use the mouse wheel for one-point steps."))
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        local track = slider:CreateTexture(nil, "BACKGROUND")
        theme.StyleSlider(slider, track)
        track:SetPoint("LEFT", slider, "LEFT")
        track:SetPoint("RIGHT", slider, "RIGHT")
        track:SetHeight(4)
        local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
        box:SetSize(55, 20)
        box:SetPoint("LEFT", slider, "RIGHT", 12, 0)
        box:SetAutoFocus(false)
        box:SetJustifyH("CENTER")
        theme.StyleInput(box)
        tooltip(box, label .. L(" exact value"), description .. L(" Type a whole number from %d to %d, then press Enter.", minimum, maximum))
        box:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refreshConfig() end)
        box:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            self:ClearFocus()
            if value and value % 1 == 0 and value >= minimum and value <= maximum then
                applySetting(key, value)
            else
                report(L("%s must be a whole number from %d to %d.", label, minimum, maximum))
                refreshConfig()
            end
        end)
        slider:SetScript("OnValueChanged", function(_, value)
            if not syncing then box:SetText(tostring(math.floor(value + 0.5))) end
        end)
        slider:SetScript("OnMouseUp", function(self)
            applySetting(key, math.floor(self:GetValue() + 0.5))
        end)
        slider:SetScript("OnMouseWheel", function(_, delta)
            local current = getProfile()[selectedKind][key]
            local nextValue = math.max(minimum, math.min(maximum, current + (delta > 0 and 1 or -1)))
            if nextValue ~= current then applySetting(key, nextValue) end
        end)
        numericControls[key] = { slider = slider, box = box }
    end

    local choiceControls = {}
    for i, spec in ipairs(choiceSettings) do
        local label, key, options, description = unpack(spec)
        label, description = L(label), L(description)
        local isText = key ~= "grow" and key ~= "sort" and key ~= "untimed"
        local parent = isText and textControls or layoutControls
        local index = isText and (i - 3) or i
        local y = -145 - (index - 1) * 74
        local titleText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        titleText:SetPoint("TOPLEFT", 385, y)
        titleText:SetText(label)
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        button:SetSize(255, 25)
        button:SetPoint("TOPLEFT", 385, y - 18)
        decorateSelector(button)
        tooltip(button, label, description .. L(" Click to choose an option."))
        local menu = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        local visibleRows = math.min(7, #options)
        menu:SetSize(255, visibleRows * 28 + 12)
        menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
        menu:SetFrameStrata("DIALOG")
        menu:SetFrameLevel(frame:GetFrameLevel() + 20)
        theme.ApplyPopup(menu)
        local scroll = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 7, -6)
        scroll:SetPoint("BOTTOMRIGHT", -29, 6)
        local child = CreateFrame("Frame", nil, scroll)
        child:SetSize(211, #options * 28)
        scroll:SetScrollChild(child)
        menu:Hide()
        for j, option in ipairs(options) do
            local item = CreateFrame("Button", nil, child)
            item:SetSize(211, 27)
            item:SetPoint("TOPLEFT", 0, -(j - 1) * 28)
            theme.AddRowHighlight(item, 1)
            item.selected = item:CreateTexture(nil, "BACKGROUND")
            item.selected:SetPoint("TOPLEFT", 1, -1)
            item.selected:SetPoint("BOTTOMRIGHT", -1, 1)
            item.selected:SetColorTexture(unpack(theme.accent))
            item.text = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            item.text:SetPoint("LEFT", 9, 0)
            item.text:SetText(L(choiceLabels[option] or option))
            tooltip(item, label .. ": " .. L(choiceLabels[option] or option), description)
            item:SetScript("OnClick", function()
                menu:Hide()
                openMenu = nil
                applySetting(key, option)
            end)
            item:SetScript("OnShow", function(self) self.selected:SetShown(getProfile()[selectedKind][key] == option) end)
        end
        button:SetScript("OnClick", function()
            if mediaPicker then mediaPicker:Hide() end
            if openMenu and openMenu ~= menu then openMenu:Hide() end
            local show = not menu:IsShown()
            menu:SetShown(show)
            openMenu = show and menu or nil
        end)
        choiceControls[key] = button
    end

    local fontButton = CreateFrame("Button", nil, textControls, "UIPanelButtonTemplate")
    fontButton:SetSize(255, 25)
    fontButton:SetPoint("TOPLEFT", 385, -385)
    decorateSelector(fontButton)
    local fontLabel = textControls:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontLabel:SetPoint("TOPLEFT", 385, -367)
    fontLabel:SetText(L("Font"))
    fontButton:SetScript("OnClick", function()
        local kind = selectedKind
        if openMenu then openMenu:Hide(); openMenu = nil end
        if mediaPicker and mediaPicker:IsShown() and mediaPicker.kind == "font" then
            mediaPicker:Hide()
            return
        end
        openMediaPicker("font", getProfile()[kind].font, function(value)
            selectedKind = kind
            applySetting("font", value)
        end, fontButton)
    end)
    tooltip(fontButton, L("Font"), L("Choose a font with a live typeface preview. Installed media packs appear here too."))

    local test = CreateFrame("Button", nil, layoutPanel, "UIPanelButtonTemplate")
    test:SetSize(125, 25)
    test:SetPoint("BOTTOMLEFT", 25, 22)
    test:SetText(L("Toggle test icons"))
    test:SetScript("OnClick", toggleTest)
    tooltip(test, L("Test icons"), L("Show sample icons in place of live auras. Click the first sample icon for a 15-second alert preview. Click again to restore live auras."))
    local move = CreateFrame("Button", nil, layoutPanel, "UIPanelButtonTemplate")
    move:SetSize(125, 25)
    move:SetPoint("LEFT", test, "RIGHT", 8, 0)
    move:SetScript("OnClick", function() setUnlocked(not auraFrames.IsUnlocked()); refreshConfig() end)
    tooltip(move, L("Move bars"), L("Unlock to drag a bar itself or its label. Lock again when finished; positions save automatically."))
    local reset = CreateFrame("Button", nil, layoutPanel, "UIPanelButtonTemplate")
    reset:SetSize(125, 25)
    reset:SetPoint("LEFT", move, "RIGHT", 8, 0)
    reset:SetText(L("Reset this bar"))
    theme.StyleDangerButton(reset)
    reset:SetScript("OnClick", function()
        if InCombatLockdown() then
            report(L("Reset after combat."))
            return
        end
        for key, value in pairs(defaults[selectedKind]) do
            getProfile()[selectedKind][key] = value
        end
        build(selectedKind)
        refreshConfig()
        report(L("%s settings and position reset.", L(selectedKind == "buffs" and "Buffs" or "Debuffs")))
    end)
    tooltip(reset, L("Reset this bar"), L("Restore this bar's default layout, text settings, and position."))

    local profileHeading = profilesPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    profileHeading:SetPoint("TOPLEFT", 25, -105)
    profileHeading:SetText(L("Named profiles"))
    theme.StyleSectionHeading(profileHeading)
    local profileHelp = profilesPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    profileHelp:SetPoint("TOPLEFT", 25, -135)
    profileHelp:SetWidth(630)
    profileHelp:SetJustifyH("LEFT")
    profileHelp:SetText(L("Each profile stores the complete ForeverBuffFrames setup. The active profile is saved automatically. Backup codes continue to protect all profiles from the current beta settings bug."))
    local profileButton = CreateFrame("Button", nil, profilesPanel, "UIPanelButtonTemplate")
    profileButton:SetSize(300, 27)
    profileButton:SetPoint("TOPLEFT", profileHelp, "BOTTOMLEFT", 0, -18)
    decorateSelector(profileButton)
    tooltip(profileButton, L("Active profile"), L("Click to select another saved profile."))
    profileButton:SetScript("OnClick", function()
        if mediaPicker then mediaPicker:Hide() end
        if openMenu then openMenu:Hide(); openMenu = nil; return end
        local names = sortedProfileNames()
        local menu = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        menu:SetFrameStrata("DIALOG")
        menu:SetFrameLevel(frame:GetFrameLevel() + 20)
        menu:SetSize(300, math.min(7, #names) * 29 + 12)
        menu:SetPoint("TOPLEFT", profileButton, "BOTTOMLEFT", 0, -2)
        theme.ApplyPopup(menu)
        local scroll = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 7, -6)
        scroll:SetPoint("BOTTOMRIGHT", -29, 6)
        local child = CreateFrame("Frame", nil, scroll)
        child:SetSize(256, #names * 29)
        scroll:SetScrollChild(child)
        for index, name in ipairs(names) do
            local choice = CreateFrame("Button", nil, child)
            choice:SetSize(256, 28)
            choice:SetPoint("TOPLEFT", 0, -(index - 1) * 29)
            theme.AddRowHighlight(choice, 1)
            local selected = choice:CreateTexture(nil, "BACKGROUND")
            selected:SetPoint("TOPLEFT", 1, -1)
            selected:SetPoint("BOTTOMRIGHT", -1, 1)
            selected:SetColorTexture(unpack(theme.accent))
            selected:SetShown(name == getDatabase().activeProfile)
            local choiceText = choice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            choiceText:SetPoint("LEFT", 9, 0)
            choiceText:SetText(name)
            choice:SetScript("OnClick", function()
                menu:Hide()
                openMenu = nil
                activateProfile(name)
            end)
        end
        applyConfigTextSize(menu, getDatabase().uiTextSize or 0)
        fitConfigButtons(menu)
        openMenu = menu
    end)
    local profileName = CreateFrame("EditBox", nil, profilesPanel, "InputBoxTemplate")
    profileName:SetSize(300, 24)
    profileName:SetAutoFocus(false)
    profileName:SetMaxLetters(32)
    theme.StyleInput(profileName)
    profileName:SetScript("OnEscapePressed", profileName.ClearFocus)
    tooltip(profileName, L("Profile name"), L("Enter a name for Create, Copy, or Rename."))
    local nameLabel = profilesPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameLabel:SetPoint("TOPLEFT", profileButton, "BOTTOMLEFT", 0, -18)
    nameLabel:SetText(L("Profile name"))
    profileName:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6)
    local function requestedProfileName()
        local name, err = validProfileName(profileName:GetText())
        if not name then report(err); return end
        local count = 0
        for existing in pairs(getDatabase().profiles) do
            count = count + 1
            if existing:lower() == name:lower() then
                report(L("A profile named %s already exists.", existing))
                return
            end
        end
        if count >= 50 then report(L("ForeverBuffFrames supports up to 50 profiles.")); return end
        return name
    end
    local createProfile = CreateFrame("Button", nil, profilesPanel, "UIPanelButtonTemplate")
    createProfile:SetSize(94, 25)
    createProfile:SetPoint("TOPLEFT", profileName, "BOTTOMLEFT", 0, -18)
    createProfile:SetText(L("Create new"))
    createProfile:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Create profiles after combat.")); return end
        local name = requestedProfileName(); if not name then return end
        getDatabase().profiles[name] = initializeProfile({})
        profileName:SetText("")
        activateProfile(name)
    end)
    tooltip(createProfile, L("Create new profile"), L("Create and select a profile using default settings."))
    local copyProfile = CreateFrame("Button", nil, profilesPanel, "UIPanelButtonTemplate")
    copyProfile:SetSize(94, 25)
    copyProfile:SetPoint("LEFT", createProfile, "RIGHT", 8, 0)
    copyProfile:SetText(L("Copy active"))
    copyProfile:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Copy profiles after combat.")); return end
        local name = requestedProfileName(); if not name then return end
        getDatabase().profiles[name] = copyTable(getProfile())
        profileName:SetText("")
        activateProfile(name)
    end)
    tooltip(copyProfile, L("Copy active profile"), L("Make and select a copy of the current profile."))
    local renameProfile = CreateFrame("Button", nil, profilesPanel, "UIPanelButtonTemplate")
    renameProfile:SetSize(94, 25)
    renameProfile:SetPoint("LEFT", copyProfile, "RIGHT", 8, 0)
    renameProfile:SetText(L("Rename"))
    renameProfile:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Rename profiles after combat.")); return end
        local name = requestedProfileName(); if not name then return end
        local oldName = getDatabase().activeProfile
        getDatabase().profiles[name] = getDatabase().profiles[oldName]
        getDatabase().profiles[oldName] = nil
        getDatabase().activeProfile = name
        profileName:SetText("")
        refreshConfig()
        report(L("Profile renamed to %s", name))
    end)
    tooltip(renameProfile, L("Rename active profile"), L("Rename the current profile without changing its settings."))
    local deleteProfile = CreateFrame("Button", nil, profilesPanel, "UIPanelButtonTemplate")
    deleteProfile:SetSize(110, 25)
    deleteProfile:SetPoint("TOPLEFT", createProfile, "BOTTOMLEFT", 0, -14)
    deleteProfile:SetText(L("Delete active"))
    theme.StyleDangerButton(deleteProfile)
    StaticPopupDialogs["FOREVERBUFFFRAMES_DELETE_PROFILE"] = {
        text = L("Delete active profile") .. ": |cffffb36b%s|r?\n\n" .. L("This cannot be undone."),
        button1 = DELETE or "Delete",
        button2 = CANCEL or "Cancel",
        OnAccept = function(_, profileName)
            if InCombatLockdown() then report(L("Delete profiles after combat.")); return end
            if not getDatabase().profiles[profileName] then
                report(L("That profile no longer exists."))
                return
            end
            local names = sortedProfileNames()
            if #names <= 1 then report(L("At least one profile must remain.")); return end
            getDatabase().profiles[profileName] = nil
            activateProfile(sortedProfileNames()[1])
            report(L("Profile deleted: %s", profileName))
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    deleteProfile:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Delete profiles after combat.")); return end
        local names = sortedProfileNames()
        if #names <= 1 then report(L("At least one profile must remain.")); return end
        local oldName = getDatabase().activeProfile
        StaticPopup_Show("FOREVERBUFFFRAMES_DELETE_PROFILE", oldName, nil, oldName)
    end)
    tooltip(deleteProfile, L("Delete active profile"), L("Permanently delete the current profile and select another one. At least one profile must remain."))
    local recoveryInstructions = CreateFrame("Frame", nil, recoveryPanel)
    recoveryInstructions:SetPoint("TOPLEFT", 15, -88)
    recoveryInstructions:SetPoint("TOPRIGHT", -15, -88)
    recoveryInstructions:SetHeight(1)
    local recoveryEntries = {}

    local function recoveryText(titleText, body)
        local heading = recoveryInstructions:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if #recoveryEntries == 0 then
            heading:SetPoint("TOPLEFT", 10, -12)
        else
            heading:SetPoint("TOPLEFT", recoveryEntries[#recoveryEntries].detail, "BOTTOMLEFT", 0, -18)
        end
        heading:SetText(titleText)
        theme.StyleSectionHeading(heading)
        local detail = recoveryInstructions:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        detail:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -6)
        detail:SetWidth(640)
        detail:SetJustifyH("LEFT")
        detail:SetText(body)
        recoveryEntries[#recoveryEntries + 1] = { heading = heading, detail = detail }
    end
    recoveryText(L("Why is this here?"), L("The current WoW beta sometimes forgets addon settings after a reload or restart. Save a backup code outside the game now; paste it back here if your setup disappears. The addon cannot save a separate recovery file itself."))
    recoveryText(L("1. Save your profiles"), L("Click Copy backup code below, press Ctrl+C, then paste it into Notepad and save the file. The code contains every named profile and the active-profile selection."))
    recoveryText(L("2. Restore your profiles"), L("Paste the code from your saved file into the box below and click Restore pasted code. New backup codes replace all profiles; older backup codes restore into the active profile."))

    local codeFrame = CreateFrame("Frame", nil, recoveryPanel, "BackdropTemplate")
    codeFrame:SetHeight(170)
    codeFrame:SetPoint("TOPLEFT", recoveryInstructions, "BOTTOMLEFT", 10, -12)
    codeFrame:SetPoint("TOPRIGHT", recoveryInstructions, "BOTTOMRIGHT", -35, -12)
    codeFrame:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    codeFrame:SetBackdropColor(unpack(theme.raised))
    codeFrame:SetBackdropBorderColor(unpack(theme.border))
    local codeScroll = CreateFrame("ScrollFrame", nil, codeFrame, "UIPanelScrollFrameTemplate")
    codeScroll:SetPoint("TOPLEFT", 8, -8)
    codeScroll:SetPoint("BOTTOMRIGHT", -29, 8)
    local input = CreateFrame("EditBox", nil, codeScroll)
    input:SetSize(580, 154)
    codeScroll:SetScrollChild(input)
    input:SetMultiLine(true)
    input:SetAutoFocus(false)
    input:SetMaxLetters(0)
    input:SetFontObject("ChatFontNormal")
    theme.StyleInput(input)
    input:SetTextInsets(4, 4, 4, 4)
    input:SetJustifyH("LEFT")
    input:SetJustifyV("TOP")
    input:SetScript("OnEscapePressed", input.ClearFocus)
    local restore
    input:SetScript("OnTextChanged", function(self)
        local textHeight = self.GetTextHeight and self:GetTextHeight() or nil
        textHeight = tonumber(textHeight) or 138
        self:SetHeight(math.max(154, textHeight + 16))
        codeScroll:UpdateScrollChildRect()
        if restore then restore:SetEnabled(self:GetText():match("%S") ~= nil) end
    end)
    codeScroll:SetScript("OnSizeChanged", function(self, width)
        input:SetWidth(math.max(1, width - 8))
        self:UpdateScrollChildRect()
    end)
    local copy = CreateFrame("Button", nil, recoveryPanel, "UIPanelButtonTemplate")
    copy:SetSize(155, 25)
    copy:SetPoint("TOPLEFT", codeFrame, "BOTTOMLEFT", 0, -10)
    copy:SetText(L("Copy backup code"))
    copy:SetScript("OnClick", function()
        input:SetText(FBF.Backup.Export(getDatabase()))
        codeScroll:SetVerticalScroll(0)
        input:SetFocus()
        input:HighlightText()
    end)
    restore = CreateFrame("Button", nil, recoveryPanel, "UIPanelButtonTemplate")
    restore:SetSize(155, 25)
    restore:SetPoint("LEFT", copy, "RIGHT", 12, 0)
    restore:SetText(L("Restore pasted code"))
    theme.StyleDangerButton(restore)
    restore:SetEnabled(false)
    restore:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Restore settings after combat.")); return end
        local restored, legacyOrError = FBF.Backup.Import(input:GetText())
        local err = type(legacyOrError) == "string" and legacyOrError or nil
        if not restored then report(err); return end
        if legacyOrError == true then
            getDatabase().profiles[getDatabase().activeProfile] = restored.profiles.Default
        else
            context.SetDatabase(restored)
        end
        activateProfile(getDatabase().activeProfile)
        report(L(legacyOrError == true and "Older backup restored into the active profile." or "All profiles restored from backup."))
    end)
    local function layoutRecovery()
        local height = 24
        local detailWidth = math.max(1, recoveryInstructions:GetWidth() - 20)
        for index, entry in ipairs(recoveryEntries) do
            entry.detail:SetWidth(detailWidth)
            height = height + entry.heading:GetStringHeight() + 6 + entry.detail:GetStringHeight()
            if index < #recoveryEntries then height = height + 18 end
        end
        recoveryInstructions:SetHeight(height)
    end
    local alertHelp = alertLeft:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    alertHelp:SetPoint("TOPLEFT", 10, -15)
    alertHelp:SetWidth(360)
    alertHelp:SetJustifyH("LEFT")
    alertHelp:SetText(L("The ten-second warning remains available outside combat. An optional native sound can play when a learned buff is removed, including during combat."))

    local soundTest = CreateFrame("Button", nil, alertLeft, "UIPanelButtonTemplate")
    soundTest:SetSize(125, 25)
    soundTest:SetText(L("Play test sound"))
    soundTest:SetScript("OnClick", function() handleAlertCommand("sound") end)
    tooltip(soundTest, L("Play test sound"), L("Play the sound used for the ten-second expiration warning."))
    local soundButton = CreateFrame("Button", nil, alertLeft, "UIPanelButtonTemplate")
    soundButton:SetSize(265, 25)
    soundButton:SetPoint("TOPLEFT", alertHelp, "BOTTOMLEFT", 0, -18)
    decorateSelector(soundButton)
    soundButton:SetScript("OnClick", function()
        if openMenu then openMenu:Hide(); openMenu = nil end
        if mediaPicker and mediaPicker:IsShown() and mediaPicker.kind == "sound" then
            mediaPicker:Hide()
            return
        end
        openMediaPicker("sound", getProfile().alertSound, function(value)
            if InCombatLockdown() then report(L("Change the alert sound after combat.")); return end
            getProfile().alertSound = value
            if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
            refreshConfig()
        end, soundButton)
    end)
    tooltip(soundButton, L("Alert sound"), L("Search sounds. Play previews a sound; click its name to select it. None keeps the raid warning silent."))
    soundTest:SetPoint("TOPLEFT", soundButton, "BOTTOMLEFT", 0, -18)
    local blacklistHeading = alertLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blacklistHeading:SetPoint("TOPLEFT", soundTest, "BOTTOMLEFT", 0, -18)
    blacklistHeading:SetText(L("Alert blacklist"))
    theme.StyleSectionHeading(blacklistHeading)

    local blacklistHelp = alertLeft:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    blacklistHelp:SetPoint("TOPLEFT", blacklistHeading, "BOTTOMLEFT", 0, -8)
    blacklistHelp:SetWidth(355)
    blacklistHelp:SetJustifyH("LEFT")
    blacklistHelp:SetText(L("Block specific buff spell IDs from triggering expiry or removal alerts."))

    local blacklistInput = CreateFrame("EditBox", nil, alertLeft, "InputBoxTemplate")
    blacklistInput:SetSize(115, 25)
    blacklistInput:SetPoint("TOPLEFT", blacklistHelp, "BOTTOMLEFT", 0, -15)
    blacklistInput:SetAutoFocus(false)
    blacklistInput:SetJustifyH("CENTER")
    theme.StyleInput(blacklistInput)
    blacklistInput:SetScript("OnEscapePressed", blacklistInput.ClearFocus)
    tooltip(blacklistInput, L("Spell ID"), L("Enter the numeric ID of a buff to exclude or restore."))

    local blacklistScroll = CreateFrame("ScrollFrame", nil, alertLeft, "UIPanelScrollFrameTemplate")
    blacklistScroll:SetPoint("TOPLEFT", blacklistInput, "BOTTOMLEFT", 0, -18)
    -- UIPanelScrollFrameTemplate draws its arrow column to the right of the
    -- scroll frame, so reserve that width inside the alert panel.
    blacklistScroll:SetPoint("BOTTOMRIGHT", alertLeft, "BOTTOMRIGHT", -42, 15)
    local blacklistChild = CreateFrame("Frame", nil, blacklistScroll)
    blacklistChild:SetSize(330, 1)
    blacklistScroll:SetScrollChild(blacklistChild)
    local blacklistList = blacklistChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    blacklistList:SetPoint("TOPLEFT")
    blacklistList:SetWidth(325)
    blacklistList:SetJustifyH("LEFT")
    blacklistList:SetJustifyV("TOP")

    local requestedNames = {}
    local function updateBlacklistList()
        local ids = {}
        for id, blocked in pairs(getProfile().alertBlacklist) do
            if blocked and type(id) == "number" then ids[#ids + 1] = id end
        end
        table.sort(ids)
        local lines = {}
        for _, id in ipairs(ids) do
            local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(id)
            local name = info and info.name
            if not name and C_Spell and C_Spell.GetSpellName then name = C_Spell.GetSpellName(id) end
            if not name and C_Spell and C_Spell.RequestLoadSpellData and not requestedNames[id] then
                requestedNames[id] = true
                C_Spell.RequestLoadSpellData(id)
            end
            lines[#lines + 1] = (name or L("Unknown spell")) .. " (" .. id .. ")"
        end
        blacklistList:SetText(#lines == 0 and L("No spells blacklisted.") or table.concat(lines, "\n"))
        blacklistChild:SetHeight(math.max(1, blacklistList:GetStringHeight() + 8))
    end

    alertsPanel:RegisterEvent("SPELL_DATA_LOAD_RESULT")
    alertsPanel:SetScript("OnEvent", updateBlacklistList)

    local function changeBlacklist(blocked)
        if InCombatLockdown() then report(L("Change the alert blacklist after combat.")); return end
        local id = tonumber(blacklistInput:GetText())
        if not id or id % 1 ~= 0 or id < 1 then
            report(L("Enter a positive numeric spell ID."))
            return
        end
        getProfile().alertBlacklist[id] = blocked and true or nil
        blacklistInput:SetText("")
        blacklistInput:ClearFocus()
        updateBlacklistList()
        handleAlertCommand(getProfile().expirationSounds and "on" or "off")
        if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
        report(L(blocked and "Spell %d added to the alert blacklist." or "Spell %d removed from the alert blacklist.", id))
    end

    local blockID = CreateFrame("Button", nil, alertLeft, "UIPanelButtonTemplate")
    blockID:SetSize(95, 25)
    blockID:SetPoint("LEFT", blacklistInput, "RIGHT", 10, 0)
    blockID:SetText(L("Block ID"))
    blockID:SetScript("OnClick", function() changeBlacklist(true) end)
    local unblockID = CreateFrame("Button", nil, alertLeft, "UIPanelButtonTemplate")
    unblockID:SetSize(95, 25)
    unblockID:SetPoint("LEFT", blockID, "RIGHT", 8, 0)
    unblockID:SetText(L("Unblock ID"))
    unblockID:SetScript("OnClick", function() changeBlacklist(false) end)

    local function makeCheck(parent, label, y, description, onClick, x)
        local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", x or 15, y)
        local textLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        textLabel:SetPoint("LEFT", check, "RIGHT", 2, 0)
        textLabel:SetText(label)
        check.textLabel = textLabel
        check:SetScript("OnClick", function(self)
            onClick(self:GetChecked() and true or false)
            refreshConfig()
        end)
        tooltip(check, label, description)
        return check
    end
    local generalHeading = generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    generalHeading:SetPoint("TOPLEFT", 25, -105)
    generalHeading:SetText(L("General options"))
    theme.StyleSectionHeading(generalHeading)
    local generalHelp = generalPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    generalHelp:SetPoint("TOPLEFT", 25, -135)
    generalHelp:SetWidth(630)
    generalHelp:SetJustifyH("LEFT")
    generalHelp:SetText(L("These controls affect the settings window or shared game displays. Bar layout and aura ordering remain in the Buffs and Debuffs pages."))
    local textSizeLabel = generalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    textSizeLabel:SetPoint("TOPLEFT", generalHelp, "BOTTOMLEFT", 0, -18)
    textSizeLabel:SetText(L("Configuration text size"))
    local textSizeValue = generalPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    textSizeValue:SetPoint("LEFT", textSizeLabel, "LEFT", 315, 0)
    local textSizeSlider = CreateFrame("Slider", nil, generalPanel)
    textSizeSlider:SetSize(300, 18)
    textSizeSlider:SetPoint("TOPLEFT", textSizeLabel, "BOTTOMLEFT", 0, -8)
    textSizeSlider:SetOrientation("HORIZONTAL")
    textSizeSlider:SetMinMaxValues(0, 4)
    textSizeSlider:SetValueStep(1)
    textSizeSlider:SetObeyStepOnDrag(true)
    textSizeSlider:EnableMouseWheel(true)
    textSizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local textTrack = textSizeSlider:CreateTexture(nil, "BACKGROUND")
    theme.StyleSlider(textSizeSlider, textTrack)
    textTrack:SetPoint("LEFT", textSizeSlider, "LEFT")
    textTrack:SetPoint("RIGHT", textSizeSlider, "RIGHT")
    textTrack:SetHeight(4)
    tooltip(textSizeSlider, L("Configuration text size"), L("Increase text throughout the ForeverBuffFrames settings window without changing the aura text on your bars."))
    textSizeSlider:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value + 0.5)
        getDatabase().uiTextSize = value
        textSizeValue:SetText(value == 0 and L("Standard") or ("+" .. value))
        applyConfigTextSize(frame, value)
        if not syncing and refreshConfig then refreshConfig() end
    end)
    textSizeSlider:SetScript("OnMouseWheel", function(self, delta)
        local value = math.floor(self:GetValue() + 0.5)
        self:SetValue(math.max(0, math.min(4, value + (delta > 0 and 1 or -1))))
    end)
    local minimapCheck = makeCheck(generalPanel, L("Show minimap button"), -270,
        L("Keep a button on the minimap that opens this window. /fbf config always works."),
        function(value)
            getProfile().showMinimap = value
            if context.GetMinimapButton() then context.GetMinimapButton():SetShown(value) end
        end, 25)
    local stockBuffCheck = makeCheck(generalPanel, L("Hide Blizzard buffs"), -303,
        L("Hide the game's original player buff display. Turn this off to restore it."),
        function(value)
            if InCombatLockdown() then report(L("Change Blizzard frames after combat.")); return end
            getProfile().hideBlizzardBuffs = value
            applyStockVisibility()
        end, 25)
    local stockDebuffCheck = makeCheck(generalPanel, L("Hide Blizzard debuffs"), -336,
        L("Hide the game's original player debuff display. Turn this off to restore it."),
        function(value)
            if InCombatLockdown() then report(L("Change Blizzard frames after combat.")); return end
            getProfile().hideBlizzardDebuffs = value
            applyStockVisibility()
        end, 25)
    minimapCheck:ClearAllPoints()
    minimapCheck:SetPoint("TOPLEFT", textSizeSlider, "BOTTOMLEFT", 0, -24)
    stockBuffCheck:ClearAllPoints()
    stockBuffCheck:SetPoint("TOPLEFT", minimapCheck, "BOTTOMLEFT", 0, -1)
    stockDebuffCheck:ClearAllPoints()
    stockDebuffCheck:SetPoint("TOPLEFT", stockBuffCheck, "BOTTOMLEFT", 0, -1)
    local expirationSoundCheck = makeCheck(alertRight, L("10-second expiry alert"), -15,
        L("Play a sound and show a raid warning when a watched buff has 10 seconds left. Requires an out-of-combat aura check; alerts are skipped during combat."),
        function(value)
            handleAlertCommand(value and "on" or "off")
        end)
    local ownBuffsCheck = makeCheck(alertRight, L("Only buffs I cast"), -48,
        L("Watch buffs cast by your character. Turn this off to include buffs cast by others."),
        function(value)
            if InCombatLockdown() then report(L("Change alert filters after combat.")); return end
            getProfile().onlyMyBuffs = value
            handleAlertCommand(getProfile().expirationSounds and "on" or "off")
            if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
        end)
    local removedSoundCheck = makeCheck(alertRight, L("Combat buff-removed sound"), -81,
        L("Play a Blizzard-native sound when an eligible learned buff is removed. This works during combat but fires after the buff is gone, not ten seconds before."),
        function(value)
            if InCombatLockdown() then report(L("Change buff removal sounds after combat.")); return end
            getProfile().buffRemovedSounds = value
            if buffRemovalSounds.Learn then buffRemovalSounds.Learn() end
            if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
        end)
    local refreshAssignments
    local removalSoundButton = CreateFrame("Button", nil, alertRight, "UIPanelButtonTemplate")
    removalSoundButton:SetSize(250, 25)
    removalSoundButton:SetPoint("TOPLEFT", removedSoundCheck, "BOTTOMLEFT", 0, -8)
    decorateSelector(removalSoundButton)
    removalSoundButton:SetScript("OnClick", function()
        if openMenu then openMenu:Hide(); openMenu = nil end
        if mediaPicker and mediaPicker:IsShown() and mediaPicker.kind == "sound" then
            mediaPicker:Hide()
            return
        end
        openMediaPicker("sound", getProfile().buffRemovalSound, function(value)
            if InCombatLockdown() then report(L("Change buff removal sounds after combat.")); return end
            getProfile().buffRemovalSound = value
            if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
            if refreshAssignments then refreshAssignments() end
            refreshConfig()
        end, removalSoundButton, combatSoundChoice)
    end)
    tooltip(removalSoundButton, L("Default removal sound"),
        L("Choose the fallback sound for selected buffs that do not have their own assignment. Use Play in the list to preview it."))
    local minimumLabel = alertRight:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    minimumLabel:SetText(L("Minimum duration (sec)"))
    local minimumBox = CreateFrame("EditBox", nil, alertRight, "InputBoxTemplate")
    minimumBox:SetSize(55, 20)
    minimumBox:SetPoint("TOPRIGHT", alertRight, "TOPRIGHT", -15, -168)
    minimumLabel:SetPoint("RIGHT", minimumBox, "LEFT", -8, 0)
    minimumBox:SetAutoFocus(false)
    minimumBox:SetJustifyH("CENTER")
    theme.StyleInput(minimumBox)
    tooltip(minimumBox, L("Minimum buff duration"), L("Only watch buffs lasting at least this many seconds. Enter a whole number from 0 to 3600; 0 includes all durations."))
    minimumBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); refreshConfig() end)
    minimumBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        self:ClearFocus()
        if InCombatLockdown() then
            report(L("Change alert filters after combat."))
        elseif value and value % 1 == 0 and value >= 0 and value <= 3600 then
            getProfile().alertMinDuration = value
            handleAlertCommand(getProfile().expirationSounds and "on" or "off")
            if buffRemovalSounds.Sync then buffRemovalSounds.Sync() end
        else
            report(L("Minimum buff duration must be a whole number from 0 to 3600 seconds."))
        end
        refreshConfig()
    end)

    local assignmentHeading = alertRight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    assignmentHeading:SetPoint("TOPLEFT", alertRight, "TOPLEFT", 15, -215)
    assignmentHeading:SetText(L("Specific buff alerts"))
    theme.StyleSectionHeading(assignmentHeading)
    local assignmentHelp = alertRight:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    assignmentHelp:SetPoint("TOPLEFT", assignmentHeading, "BOTTOMLEFT", 0, -8)
    assignmentHelp:SetWidth(250)
    assignmentHelp:SetJustifyH("LEFT")
    assignmentHelp:SetText(L("Choose exactly which learned buffs should alert and assign a sound to each one."))
    local manageAssignments = CreateFrame("Button", nil, alertRight, "UIPanelButtonTemplate")
    manageAssignments:SetSize(245, 26)
    manageAssignments:SetPoint("TOPLEFT", assignmentHelp, "BOTTOMLEFT", 0, -12)
    manageAssignments:SetText(L("Manage specific buff alerts"))

    local assignmentFrame = CreateFrame("Frame", nil, frame)
    assignmentFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    assignmentFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    table.insert(contentPanels, assignmentFrame)
    assignmentFrame:Hide()
    local assignmentTitle = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentTitle:SetPoint("TOPLEFT", 25, -120)
    assignmentTitle:SetText(L("Specific buff alerts"))
    theme.StyleSectionHeading(assignmentTitle)
    local assignmentBack = CreateFrame("Button", nil, assignmentFrame, "UIPanelButtonTemplate")
    assignmentBack:SetSize(145, 24)
    assignmentBack:SetPoint("TOPLEFT", 25, -82)
    assignmentBack:SetText(L("Back to Alerts"))
    assignmentBack:SetScript("OnClick", function()
        dismissTransientUI()
        buffAlertDetail = false
        refreshConfig()
    end)
    local assignmentInstructions = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    assignmentInstructions:SetPoint("TOPLEFT", assignmentTitle, "BOTTOMLEFT", 0, -8)
    assignmentInstructions:SetWidth(610)
    assignmentInstructions:SetJustifyH("LEFT")
    assignmentInstructions:SetText(L("Check Alert beside a buff, then choose the recording on that same row. Unchecked buffs stay silent. Combat-compatible files from enabled LibSharedMedia sound packs appear automatically."))
    local customSoundLabel = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    customSoundLabel:SetPoint("TOPLEFT", assignmentInstructions, "BOTTOMLEFT", 0, -14)
    customSoundLabel:SetText(L("Add a custom sound file"))
    local customSoundPath = CreateFrame("EditBox", nil, assignmentFrame, "InputBoxTemplate")
    customSoundPath:SetSize(400, 22)
    customSoundPath:SetPoint("TOPLEFT", customSoundLabel, "BOTTOMLEFT", 0, -6)
    customSoundPath:SetAutoFocus(false)
    customSoundPath:SetTextInsets(6, 6, 0, 0)
    theme.StyleInput(customSoundPath)
    local addCustomSound = CreateFrame("Button", nil, assignmentFrame, "UIPanelButtonTemplate")
    addCustomSound:SetSize(105, 22)
    addCustomSound:SetPoint("LEFT", customSoundPath, "RIGHT", 10, 0)
    addCustomSound:SetText(L("Add file"))
    addCustomSound:SetScript("OnClick", function()
        if InCombatLockdown() then report(L("Change buff removal sounds after combat.")); return end
        local relative = customSoundPath:GetText():match("^%s*(.-)%s*$"):gsub("/", "\\")
        local lower = relative:lower()
        if relative == "" or (not lower:match("%.ogg$") and not lower:match("%.mp3$")) then
            report(L("Enter an .ogg or .mp3 path first.")); return
        end
        local path = relative
        if not path:lower():match("^interface\\") then path = "Interface\\AddOns\\ForeverBuffFrames\\" .. path end
        local label = relative:match("([^\\]+)$") or relative
        getProfile().customSounds[label] = path
        customSoundPath:SetText("")
        report(L("Custom sound added. Use a buff's sound selector to assign it."))
    end)
    tooltip(customSoundPath, L("Custom sound file"), L("Copy the file into CustomSounds before starting WoW, then enter a path such as CustomSounds\\my-alert.ogg."))
    local assignmentSearchLabel = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    assignmentSearchLabel:SetPoint("TOPLEFT", customSoundPath, "BOTTOMLEFT", 0, -14)
    assignmentSearchLabel:SetWidth(610)
    assignmentSearchLabel:SetJustifyH("LEFT")
    assignmentSearchLabel:SetText(L("Find a learned buff by name or Spell ID"))
    local showAllLearned = false
    local showAllCheck = CreateFrame("CheckButton", nil, assignmentFrame, "UICheckButtonTemplate")
    showAllCheck:SetPoint("RIGHT", assignmentSearchLabel, "RIGHT", -5, 0)
    showAllCheck.textLabel = showAllCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showAllCheck.textLabel:SetPoint("RIGHT", showAllCheck, "LEFT", -2, 0)
    showAllCheck.textLabel:SetText(L("Show all characters"))
    local assignmentSearch = CreateFrame("EditBox", nil, assignmentFrame, "InputBoxTemplate")
    assignmentSearch:SetSize(505, 22)
    assignmentSearch:SetPoint("TOPLEFT", assignmentSearchLabel, "BOTTOMLEFT", 0, -6)
    assignmentSearch:SetAutoFocus(false)
    assignmentSearch:SetTextInsets(6, 6, 0, 0)
    theme.StyleInput(assignmentSearch)
    local assignmentCount = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    assignmentCount:SetPoint("LEFT", assignmentSearch, "RIGHT", 10, 0)
    local assignmentScroll = CreateFrame("ScrollFrame", nil, assignmentFrame, "UIPanelScrollFrameTemplate")
    assignmentScroll:SetPoint("TOPLEFT", assignmentSearch, "BOTTOMLEFT", -2, -12)
    assignmentScroll:SetPoint("BOTTOMRIGHT", assignmentFrame, "BOTTOMRIGHT", -38, 20)
    local assignmentChild = CreateFrame("Frame", nil, assignmentScroll)
    assignmentChild:SetSize(595, 1)
    assignmentScroll:SetScrollChild(assignmentChild)
    local assignmentRows = {}
    local function currentSpellBook()
        local ids, names = {}, {}
        if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines
            and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo
            and Enum and Enum.SpellBookSpellBank) then return ids, names end
        local ok, count = pcall(C_SpellBook.GetNumSpellBookSkillLines)
        if not ok or type(count) ~= "number" then return ids, names end
        for line = 1, count do
            local lineOK, info = pcall(C_SpellBook.GetSpellBookSkillLineInfo, line)
            if lineOK and type(info) == "table" then
                local first = (info.itemIndexOffset or 0) + 1
                local last = (info.itemIndexOffset or 0) + (info.numSpellBookItems or 0)
                for slot = first, last do
                    local itemOK, item = pcall(C_SpellBook.GetSpellBookItemInfo, slot, Enum.SpellBookSpellBank.Player)
                    if itemOK and type(item) == "table" and not item.isPassive then
                        if type(item.actionID) == "number" then ids[item.actionID] = true end
                        if type(item.spellID) == "number" then ids[item.spellID] = true end
                        if type(item.name) == "string" and item.name ~= "" then names[item.name:lower()] = true end
                    end
                end
            end
        end
        return ids, names
    end
    local function soundLabel(value)
        for _, choice in ipairs(mediaChoices("sound")) do if choice.value == value then return choice.label end end
        return L("Original warning")
    end
    local function makeAssignmentRow(index)
        local row = CreateFrame("Frame", nil, assignmentChild, "BackdropTemplate")
        row:SetSize(590, 62)
        row:SetPoint("TOPLEFT", 0, -(index - 1) * 66)
        row:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 9, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        row:SetBackdropColor(unpack(theme.raised))
        row:SetBackdropBorderColor(unpack(theme.border))
        row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        row.check:SetPoint("TOPLEFT", 8, -4)
        row.checkLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.checkLabel:SetPoint("LEFT", row.check, "RIGHT", -2, 0)
        row.checkLabel:SetText(L("Alert"))
        row.combat = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        row.combat:SetPoint("BOTTOMLEFT", 8, 2)
        row.combatLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.combatLabel:SetPoint("LEFT", row.combat, "RIGHT", -2, 0)
        row.combatLabel:SetText(L("Combat only"))
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("TOPLEFT", 130, -10)
        row.name:SetWidth(430)
        row.name:SetJustifyH("LEFT")
        row.soundLabel = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        row.soundLabel:SetPoint("TOPLEFT", 130, -36)
        row.soundLabel:SetText(L("Sound:"))
        row.sound = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.sound:SetSize(215, 22)
        row.sound:SetPoint("LEFT", row.soundLabel, "RIGHT", 6, 0)
        decorateSelector(row.sound)
        row.preview = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.preview:SetSize(78, 22)
        row.preview:SetPoint("LEFT", row.sound, "RIGHT", 8, 0)
        row.preview:SetText(L("Preview"))
        row.check:SetScript("OnClick", function(self)
            if InCombatLockdown() then self:SetChecked(not self:GetChecked()); report(L("Change buff removal sounds after combat.")); return end
            row.entry.enabled = self:GetChecked() and true or false
            buffRemovalSounds.Sync()
        end)
        row.combat:SetScript("OnClick", function(self)
            if InCombatLockdown() then self:SetChecked(not self:GetChecked()); report(L("Change buff removal sounds after combat.")); return end
            row.entry.combatOnly = self:GetChecked() and true or false
            buffRemovalSounds.Sync()
        end)
        row.sound:SetScript("OnClick", function()
            openMediaPicker("sound", row.entry.sound or getProfile().buffRemovalSound or "default", function(value)
                if InCombatLockdown() then report(L("Change buff removal sounds after combat.")); return end
                row.entry.sound = value
                row.sound:SetText(soundLabel(value))
                buffRemovalSounds.Sync()
            end, row.sound, combatSoundChoice)
        end)
        row.preview:SetScript("OnClick", function()
            local source = soundSource(row.entry.sound or getProfile().buffRemovalSound or "default")
            if source == SOUND_FILE_ID then PlaySoundFile(source, "Master")
            elseif type(source) == "number" then PlaySound(source, "Master")
            elseif source then PlaySoundFile(source, "Master") end
        end)
        assignmentRows[index] = row
        return row
    end
    refreshAssignments = function()
        local query = assignmentSearch:GetText():lower():match("^%s*(.-)%s*$")
        local matches, total = {}, 0
        local knownIDs, knownNames = currentSpellBook()
        local class = select(2, UnitClass("player"))
        for spellID, entry in pairs(getProfile().learnedBuffAlerts or {}) do
            total = total + 1
            local haystack = ((entry.name or "") .. " " .. tostring(spellID)):lower()
            local relevant = entry.enabled == true or knownIDs[spellID]
                or knownNames[(entry.name or ""):lower()]
                or (class and entry.classes and entry.classes[class])
            if (showAllLearned or relevant) and (query == "" or haystack:find(query, 1, true)) then
                matches[#matches + 1] = { id = spellID, entry = entry }
            end
        end
        table.sort(matches, function(a, b) return (a.entry.name or ""):lower() < (b.entry.name or ""):lower() end)
        for index, match in ipairs(matches) do
            local row = assignmentRows[index] or makeAssignmentRow(index)
            row.entry = match.entry
            row.name:SetText((match.entry.name or L("Spell")) .. "  |cff9b9b9b" .. tostring(match.id) .. "|r")
            row.check:SetChecked(match.entry.enabled == true)
            row.combat:SetChecked(match.entry.combatOnly == true)
            row.sound:SetText(soundLabel(match.entry.sound or getProfile().buffRemovalSound or "default"))
            row:Show()
        end
        for index = #matches + 1, #assignmentRows do assignmentRows[index]:Hide() end
        assignmentChild:SetHeight(math.max(1, #matches * 66))
        assignmentCount:SetText(L("%d shown / %d learned", #matches, total))
    end
    assignmentSearch:SetScript("OnTextChanged", refreshAssignments)
    assignmentSearch:SetScript("OnEscapePressed", assignmentSearch.ClearFocus)
    showAllCheck:SetScript("OnClick", function(self)
        showAllLearned = self:GetChecked() and true or false
        refreshAssignments()
    end)
    manageAssignments:SetScript("OnClick", function()
        dismissTransientUI()
        buffAlertDetail = true
        refreshAssignments()
        refreshConfig()
    end)

    local responsive = {
        frame = frame, sidebar = sidebar, tabs = tabs, contentPanels = contentPanels,
        test = test, move = move, reset = reset, choiceControls = choiceControls,
        createProfile = createProfile, copyProfile = copyProfile,
        renameProfile = renameProfile, deleteProfile = deleteProfile, profileButton = profileButton,
        generalChecks = { minimapCheck, stockBuffCheck, stockDebuffCheck },
        alertChecks = { expirationSoundCheck, ownBuffsCheck, removedSoundCheck },
        alertLeft = alertLeft, alertRight = alertRight, blacklistInput = blacklistInput,
        blockID = blockID, unblockID = unblockID, soundButton = soundButton, soundTest = soundTest,
        removalSoundButton = removalSoundButton,
        copyBackup = copy, restoreBackup = restore,
        languageButton = languageButton, applyLanguage = applyLanguage,
        generalHelp = generalHelp, profileHelp = profileHelp, languageHelp = languageHelp,
        diagnosticsHelp = diagnosticsHelp, diagnosticReport = reportFrame,
        diagnosticTestHelp = testHelp,
        diagnosticStatusHeading = statusHeading,
        diagnosticTestRow = { diagnosticTestIcons, diagnosticSound },
        diagnosticStatusRow = { refreshStatus, clearStatus },
        diagnosticReportRow = { copyReport, retryDiagnostics },
    }

    refreshConfig = function()
        if not configFrame then return end
        syncing = true
        local cfg = getProfile()[selectedKind]
        for _, spec in ipairs(numericSettings) do
            local key = spec[2]
            local control = numericControls[key]
            control.slider:SetValue(cfg[key])
            control.box:SetText(tostring(cfg[key]))
        end
        textSizeSlider:SetValue(getDatabase().uiTextSize or 0)
        textSizeValue:SetText((getDatabase().uiTextSize or 0) == 0 and L("Standard") or ("+" .. (getDatabase().uiTextSize or 0)))
        syncing = false
        for _, spec in ipairs(choiceSettings) do
            local key = spec[2]
            choiceControls[key]:SetText(L(choiceLabels[cfg[key]] or cfg[key]))
        end
        local fontName = cfg.font
        for _, choice in ipairs(mediaChoices("font")) do
            if choice.value == cfg.font then fontName = choice.label; break end
        end
        fontButton:SetText(fontName)
        local soundName = getProfile().alertSound
        for _, choice in ipairs(mediaChoices("sound")) do
            if choice.value == getProfile().alertSound then soundName = choice.label; break end
        end
        soundButton:SetText(L("Alert sound") .. ": " .. soundName)
        move:SetText(L(auraFrames.IsUnlocked() and "Lock bars" or "Unlock bars"))
        minimapCheck:SetChecked(getProfile().showMinimap)
        stockBuffCheck:SetChecked(getProfile().hideBlizzardBuffs)
        stockDebuffCheck:SetChecked(getProfile().hideBlizzardDebuffs)
        expirationSoundCheck:SetChecked(getProfile().expirationSounds)
        ownBuffsCheck:SetChecked(getProfile().onlyMyBuffs)
        removedSoundCheck:SetChecked(getProfile().buffRemovedSounds)
        local removalSoundName = getProfile().buffRemovalSound
        for _, choice in ipairs(mediaChoices("sound")) do
            if choice.value == removalSoundName then removalSoundName = choice.label; break end
        end
        removalSoundButton:SetText(L("Default removal sound") .. ": " .. L(removalSoundName))
        refreshAssignments()
        minimumBox:SetText(tostring(getProfile().alertMinDuration))
        contentPanels.general:SetShown(selectedTab == "general")
        local debuffDetail = selectedTab == "debuffs" and debuffPageState.current or nil
        contentPanels.layout:SetShown((selectedTab == "buffs" or selectedTab == "debuffs") and not debuffDetail)
        layoutControls:SetShown(selectedSection == "layout")
        textControls:SetShown(selectedSection == "text")
        for section, button in pairs(sectionTabs) do
            local selected = selectedSection == section
            button:SetButtonState(selected and "PUSHED" or "NORMAL", selected)
            local label = button:GetFontString()
            if label then
                label:SetTextColor(1, selected and 0.82 or 0.72, selected and 0.28 or 0.18)
            end
        end
        for _, button in ipairs(debuffPageState.navigation) do button:SetShown(selectedTab == "debuffs" and not debuffDetail) end
        contentPanels.alerts:SetShown(selectedTab == "alerts" and not buffAlertDetail)
        assignmentFrame:SetShown(selectedTab == "alerts" and buffAlertDetail)
        debuffPageState.sounds:SetShown(debuffDetail == "sounds")
        debuffPageState.appearance:SetShown(debuffDetail == "appearance")
        debuffPageState.library:SetShown(debuffDetail == "library")
        if debuffPageState.trackers then debuffPageState.trackers:SetShown(debuffDetail == "trackers") end
        contentPanels.profiles:SetShown(selectedTab == "profiles")
        contentPanels.recovery:SetShown(selectedTab == "recovery")
        contentPanels.language:SetShown(selectedTab == "language")
        contentPanels.diagnostics:SetShown(selectedTab == "diagnostics")
        if selectedTab == "diagnostics" then refreshDiagnostics() end
        if debuffDetail == "sounds" then refreshDebuffAlerts() end
        if debuffDetail == "library" and debuffPageState.refreshLibrary then debuffPageState.refreshLibrary() end
        if debuffDetail == "trackers" and debuffPageState.refreshTrackers then debuffPageState.refreshTrackers() end
        awarenessCheck:SetChecked(getProfile().debuffAwareness)
        pulseCheck:SetChecked(getProfile().debuffPulse)
        updateBorderStyle()
        appearanceSyncing = true
        for key, control in pairs(appearanceControls) do
            control.slider:SetValue(getProfile()[key])
            control.box:SetText(tostring(getProfile()[key]))
        end
        appearanceSyncing = false
        soundEnable:SetChecked(getProfile().debuffSoundsEnabled)
        updateDebuffSoundButton()
        for kind, tab in pairs(tabs) do
            local selected = selectedTab == kind
            tab.selected:SetShown(selected)
            tab.label:SetTextColor(1, selected and 0.93 or 0.78, selected and 0.70 or 0.12)
        end
        profileButton:SetText(L("Active profile") .. ": " .. getDatabase().activeProfile)
        local profileCount = 0
        for _ in pairs(getDatabase().profiles) do profileCount = profileCount + 1 end
        deleteProfile:SetEnabled(profileCount > 1)
        applyConfigTextSize(frame, getDatabase().uiTextSize or 0)
        fitConfigButtons(frame)
        local textExpansion = getDatabase().uiTextSize or 0
        fitLocalizedWindow(responsive, textExpansion)
        layoutRecovery()
        updateBlacklistList()
    end
    configFrame = frame
    return frame
end

local function openConfig(tab)
    if tab == "general" or tab == "buffs" or tab == "debuffs" or tab == "alerts"
        or tab == "profiles" or tab == "recovery" or tab == "language" or tab == "diagnostics" then
        selectedTab = tab
        if tab == "buffs" or tab == "debuffs" then selectedKind = tab end
        if tab == "debuffs" then debuffPageState.current = nil end
    end
    local frame = makeConfig()
    refreshConfig()
    frame:Show()
end

local function registerSettings()
    local panel = CreateFrame("Frame")
    panel.name = "ForeverBuffFrames"
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("ForeverBuffFrames")
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(190, 28)
    button:SetPoint("TOPLEFT", 20, -60)
    button:SetText(L("Open configuration"))
    button:SetScript("OnClick", openConfig)
    tooltip(button, L("Open configuration"), L("Open the full ForeverBuffFrames settings window."))
    applyConfigTextSize(panel, getDatabase() and (getDatabase().uiTextSize or 0) or 0)
    fitConfigButtons(panel)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local ok = pcall(function()
            local category = Settings.RegisterCanvasLayoutCategory(panel, "ForeverBuffFrames")
            Settings.RegisterAddOnCategory(category)
        end)
        if ok then return end
    end
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    else
        report(L("Settings entry unavailable in this client; use /fbf config."))
    end
end

return {
    Open = openConfig,
    Register = registerSettings,
    Refresh = function() if refreshConfig then refreshConfig() end end,
    Tooltip = tooltip,
}
end
