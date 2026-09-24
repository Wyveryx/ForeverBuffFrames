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
local auraFrames = context.AuraFrames
local alerts = context.Alerts
local handleAlertCommand = alerts.Handle
local configFrame
local selectedKind = "buffs"
local selectedTab = "buffs"
local selectedSection = "layout"
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
    frame:SetWidth(math.max(base[1], math.ceil(measured) + padding))
    frame:SetHeight(math.max(base[2], math.ceil(label:GetStringHeight()) + 10))
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
            if type(entry[3]) == "number" or (SOUNDKIT and SOUNDKIT[entry[3]]) then
                choices[#choices + 1] = { value = entry[1], label = L(entry[2]) }
            end
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
local function openMediaPicker(kind, current, onPick, owner)
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
                if query == "" or choice.label:lower():find(query, 1, true) then
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
    local profilesPanel = CreateFrame("Frame", nil, frame)
    profilesPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    profilesPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local recoveryPanel = CreateFrame("Frame", nil, frame)
    recoveryPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    recoveryPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local languagePanel = CreateFrame("Frame", nil, frame)
    languagePanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 150, 0)
    languagePanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local contentPanels = { layoutPanel, generalPanel, alertsPanel, profilesPanel, recoveryPanel, languagePanel }
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
        profiles = "Profiles", recovery = "Backup / Recovery", language = "Language",
    }
    local tabs = {}
    for index, kind in ipairs({ "general", "buffs", "debuffs", "alerts", "profiles", "recovery", "language" }) do
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
            refreshConfig()
        end)
        local tabTitle = kind == "language" and L("Language settings") or (kind == "general" and "General settings" or (kind == "recovery" and "Backup / Recovery" or (kind == "profiles" and "Profiles" or (kind == "alerts" and "Alert settings" or (kind == "buffs" and "Buff settings" or "Debuff settings")))))
        local tabHelp = kind == "recovery" and "Save all profiles or restore them if the beta forgets them."
            or (kind == "profiles" and "Create, copy, rename, delete, and select named settings profiles."
            or (kind == "general" and "Configure the settings window and shared display choices."
            or (kind == "language" and "Choose the automatic client language or override it to test a translation."
            or (kind == "alerts" and "Configure ten-second warnings and their blacklist." or "Configure this bar independently from the other bar."))))
        tooltip(tab, L(tabTitle), L(tabHelp))
        tabs[kind] = tab
    end

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
    alertHelp:SetText(L("Sound and raid warning play together at 10 seconds remaining. Live alerts require an out-of-combat aura check; they are skipped during combat."))

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
    blacklistHelp:SetText(L("Block specific buff spell IDs from triggering expiry alerts."))

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
        end)
    local alertDebugCheck = makeCheck(alertRight, L("Debug expiry alerts"), -81,
        L("Print scheduled, skipped, and fired alerts outside combat. Aura details are unavailable to the addon during combat."),
        function(value) getProfile().debugAlerts = value end)
    local minimumLabel = alertRight:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    minimumLabel:SetText(L("Minimum duration (sec)"))
    local minimumBox = CreateFrame("EditBox", nil, alertRight, "InputBoxTemplate")
    minimumBox:SetSize(55, 20)
    minimumBox:SetPoint("TOPRIGHT", alertRight, "TOPRIGHT", -15, -125)
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
        else
            report(L("Minimum buff duration must be a whole number from 0 to 3600 seconds."))
        end
        refreshConfig()
    end)

    local responsive = {
        frame = frame, sidebar = sidebar, tabs = tabs, contentPanels = contentPanels,
        test = test, move = move, reset = reset, choiceControls = choiceControls,
        createProfile = createProfile, copyProfile = copyProfile,
        renameProfile = renameProfile, deleteProfile = deleteProfile, profileButton = profileButton,
        generalChecks = { minimapCheck, stockBuffCheck, stockDebuffCheck },
        alertChecks = { expirationSoundCheck, ownBuffsCheck, alertDebugCheck },
        alertLeft = alertLeft, alertRight = alertRight, blacklistInput = blacklistInput,
        blockID = blockID, unblockID = unblockID, soundButton = soundButton, soundTest = soundTest,
        copyBackup = copy, restoreBackup = restore,
        languageButton = languageButton, applyLanguage = applyLanguage,
        generalHelp = generalHelp, profileHelp = profileHelp, languageHelp = languageHelp,
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
        alertDebugCheck:SetChecked(getProfile().debugAlerts)
        minimumBox:SetText(tostring(getProfile().alertMinDuration))
        generalPanel:SetShown(selectedTab == "general")
        layoutPanel:SetShown(selectedTab == "buffs" or selectedTab == "debuffs")
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
        alertsPanel:SetShown(selectedTab == "alerts")
        profilesPanel:SetShown(selectedTab == "profiles")
        recoveryPanel:SetShown(selectedTab == "recovery")
        languagePanel:SetShown(selectedTab == "language")
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

local function openConfig()
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
