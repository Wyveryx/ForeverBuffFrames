local _, FBF = ...
local L = FBF.L

local getProfile
local report
local playAlertSound
local fontPath = FBF.FontPath
local theme = FBF.Theme
local results = {}
local awarenessResult = "Not tested"
local containers = {}
local holders = {}
local unlocked = false
local testMode = false
local toggleTest
local untimedSpellIDs = { buffs = {}, debuffs = {} }
local untimedSignatures = { buffs = "", debuffs = "" }
local tracking
local dispelColors = {
    Magic = { 0.20, 0.60, 1.00 }, Curse = { 0.60, 0.00, 1.00 },
    Disease = { 0.60, 0.40, 0.00 }, Poison = { 0.00, 0.60, 0.00 },
}
local nativeDispelColors = {}
for kind, color in pairs(dispelColors) do
    nativeDispelColors[kind] = { r = color[1], g = color[2], b = color[3] }
end

local function startPulse(region)
    local group = region:CreateAnimationGroup()
    group:SetLooping("BOUNCE")
    local alpha = group:CreateAnimation("Alpha")
    alpha:SetFromAlpha(1)
    alpha:SetToAlpha(0.25)
    alpha:SetDuration(0.65)
    alpha:SetSmoothing("IN_OUT")
    group:Play()
    return group
end

local function addSolidBorder(button, color, style, pulse, kind, borderThickness, pulseExpansion)
    local root = CreateFrame("Frame", nil, button)
    root:SetAllPoints()
    root:SetFrameLevel(button:GetFrameLevel() + 4)
    borderThickness = math.max(1, math.min(6, borderThickness or 2))
    local function makeLayer(expansion, animated)
        local host = CreateFrame("Frame", nil, root)
        host:SetPoint("TOPLEFT", button, "TOPLEFT", -expansion, expansion)
        host:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", expansion, -expansion)
        if style ~= "icon" then
        for _, edge in ipairs({
                { "TOPLEFT", "TOPRIGHT", 0, -borderThickness }, { "BOTTOMLEFT", "BOTTOMRIGHT", 0, borderThickness },
                { "TOPLEFT", "BOTTOMLEFT", borderThickness, 0 }, { "TOPRIGHT", "BOTTOMRIGHT", -borderThickness, 0 },
        }) do
            local texture = host:CreateTexture(nil, "OVERLAY")
            texture:SetPoint(edge[1]); texture:SetPoint(edge[2])
            if edge[3] == 0 then texture:SetHeight(math.abs(edge[4])) else texture:SetWidth(math.abs(edge[3])) end
            texture:SetColorTexture(color[1], color[2], color[3], 1)
        end
        end
        if style ~= "border" then
        local badge = host:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        badge:SetPoint("TOPRIGHT", 3, 3)
        badge:SetTextColor(color[1], color[2], color[3])
        badge:SetShadowColor(0, 0, 0, 1)
        badge:SetShadowOffset(1, -1)
        badge:SetText(kind:sub(1, 1))
        end
        if animated then host.pulse = startPulse(host) end
        return host
    end
    makeLayer(math.max(0, borderThickness - 2), false)
    if pulse then root.pulseLayer = makeLayer(pulseExpansion or 4, true) end
    return root
end

local function addNativeDispelTexture(button, cfg, expansion, pulse)
    local styles = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
    local style = styles and ({ border = styles.Border, bordericon = styles.BorderWithIcon, icon = styles.Icon })[cfg.debuffBorderStyle]
    if style == nil then return false end
    local host = CreateFrame("Frame", nil, button)
    host:SetPoint("TOPLEFT", button, "TOPLEFT", -expansion, expansion)
    host:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", expansion, -expansion)
    host:SetFrameLevel(button:GetFrameLevel() + (pulse and 4 or 3))
    local texture = host:CreateTexture(nil, "OVERLAY", nil, pulse and 4 or 3)
    texture:SetAllPoints()
    local ok = pcall(button.AddDispelTypeTexture, button, texture, {
        style = style, showWhenHarmful = true, showWhenHelpful = false,
        customDispelColorMap = nativeDispelColors,
    })
    if ok and pulse then host.pulse = startPulse(host) end
    return ok, host
end

local function addNativeDispelBorder(button, cfg)
    if not cfg.debuffAwareness then awarenessResult = "Disabled"; return end
    if not button.AddDispelTypeTexture then awarenessResult = "Unavailable"; return end
    local staticExpansion = math.max(0, (cfg.debuffBorderThickness or 2) - 2)
    local ok = addNativeDispelTexture(button, cfg, staticExpansion, false)
    awarenessResult = ok and "Available" or "Unavailable"
    if ok and cfg.debuffPulse then
        local pulseOK, pulseHost = addNativeDispelTexture(button, cfg, cfg.debuffPulseExpansion or 4, true)
        if pulseOK then button.fbfDispelPulse = pulseHost and pulseHost.pulse end
    end
end

local function styleText(text, button, cfg, timer)
    local face = fontPath(cfg.font)
    local flags = ({ outline = "OUTLINE", thick = "THICKOUTLINE" })[cfg.outline] or ""
    local size = timer and cfg.timerSize or cfg.countSize
    if text:SetFont(face, size, flags) == false then
        text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, flags)
    end
    text:ClearAllPoints()
    if timer then
        if cfg.timerPos == "above" then
            text:SetPoint("BOTTOM", button, "TOP", 0, 1)
        elseif cfg.timerPos == "center" then
            text:SetPoint("CENTER", button, "CENTER")
        else
            text:SetPoint("TOP", button, "BOTTOM", 0, -1)
        end
    else
        local anchors = {
            topleft = { "TOPLEFT", 1, -1 }, topright = { "TOPRIGHT", -1, -1 },
            bottomleft = { "BOTTOMLEFT", 1, 1 }, bottomright = { "BOTTOMRIGHT", -1, 1 },
        }
        local anchor = anchors[cfg.countPos] or anchors.bottomright
        text:SetPoint(anchor[1], button, anchor[1], anchor[2], anchor[3])
    end
end

local function showTest(holder, cfg)
    if not holder.test then
        local test = CreateFrame("Frame", nil, holder.auraArea or holder)
        test:SetAllPoints()
        test:SetFrameLevel(holder.container:GetFrameLevel() + 5)
        test.buttons = {}
        for i = 1, cfg.perRow * cfg.rows do
            local button = CreateFrame(i == 1 and "Button" or "Frame", nil, test)
            button:SetSize(cfg.size, cfg.size)
            local col = (i - 1) % cfg.perRow
            local row = math.floor((i - 1) / cfg.perRow)
            if cfg.grow == "left" then
                button:SetPoint("TOPRIGHT", test, "TOPRIGHT", -col * (cfg.size + cfg.gapX), -row * (cfg.size + cfg.gapY))
            else
                button:SetPoint("TOPLEFT", test, "TOPLEFT", col * (cfg.size + cfg.gapX), -row * (cfg.size + cfg.gapY))
            end
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints()
            icon:SetTexture(134400)
            test.buttons[i] = button
            local count = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            styleText(count, button, cfg, false)
            count:SetText(tostring((i % 4) + 2))
            local duration = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            styleText(duration, button, cfg, true)
            duration:SetText(i == 1 and L("click") or (i % 2 == 0 and "12m" or "8s"))
            if i == 1 then
                local flash = button:CreateTexture(nil, "OVERLAY")
                flash:SetAllPoints()
                flash:SetColorTexture(1, 0, 0, 0.45)
                flash:Hide()
                test.firstDuration = duration
                test.firstFlash = flash
                button:SetScript("OnClick", function()
                    test.run = (test.run or 0) + 1
                    local run = test.run
                    local seconds = 15
                    flash:Hide()
                    duration:SetText("15s")
                    local function tick()
                        if test.run ~= run or not test:IsShown() then return end
                        seconds = seconds - 1
                        if seconds > 0 then
                            duration:SetText(seconds .. "s")
                            if seconds == 10 then
                                if RaidNotice_AddMessage and RaidWarningFrame then
                                    RaidNotice_AddMessage(RaidWarningFrame, L("Test buff expires in 10 seconds"), (ChatTypeInfo and ChatTypeInfo.RAID_WARNING) or { r = 1, g = 0, b = 0 })
                                else
                                    report(L("Raid-warning display is unavailable in this client."))
                                end
                                local played = playAlertSound()
                                if not played then report(L("Sample alert sound failed.")) end
                            end
                            C_Timer.After(1, tick)
                        else
                            duration:SetText(L("done"))
                            flash:Show()
                            C_Timer.After(1.5, function()
                                if test.run == run then
                                    flash:Hide()
                                    duration:SetText(L("click"))
                                end
                            end)
                        end
                    end
                    C_Timer.After(1, tick)
                end)
                button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L("Test alert"))
                    GameTooltip:AddLine(L("Click for a 15-second sample countdown. Sound and raid warning play together at 10 seconds; the icon flashes at zero."), 1, 1, 1, true)
                    GameTooltip:Show()
                end)
                button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
        end
        holder.test = test
    end
    holder.test.run = (holder.test.run or 0) + 1
    holder.test.firstDuration:SetText(L("click"))
    holder.test.firstFlash:Hide()
    holder.test:Show()
end

local function previewDebuffAwareness(style, pulse, borderThickness, pulseExpansion)
    if InCombatLockdown() then report(L("Preview debuff borders after combat.")); return end
    if not testMode then toggleTest() end
    local holder = holders.debuffs
    if not holder or not holder.test then return end
    for _, button in ipairs(holder.test.buttons or {}) do
        if button.fbfPreviewBorder then button.fbfPreviewBorder:Hide() end
    end
    for index, kind in ipairs({ "Magic", "Curse", "Disease", "Poison" }) do
        local button = holder.test.buttons and holder.test.buttons[index]
        if button then
            button.fbfPreviewBorder = addSolidBorder(button, dispelColors[kind], style, pulse, kind,
                borderThickness or 2, pulseExpansion or 4)
        end
    end
    report(L("Debuff border preview shown."))
end

local function scanUntimedAuras(kind, filter)
    local ids, ordered = {}, {}
    if InCombatLockdown() or not C_UnitAuras or not C_UnitAuras.GetUnitAuras then
        return untimedSpellIDs[kind], untimedSignatures[kind]
    end
    local ok, auras = pcall(C_UnitAuras.GetUnitAuras, "player", filter)
    if not ok or type(auras) ~= "table" then return untimedSpellIDs[kind], untimedSignatures[kind] end
    for _, aura in ipairs(auras) do
        local duration, expirationTime = aura.duration, aura.expirationTime
        local readable = (not issecretvalue or (not issecretvalue(duration) and not issecretvalue(expirationTime)))
        local spellID = aura.spellId or aura.spellID
        if readable and type(spellID) == "number"
            and ((type(duration) == "number" and duration == 0)
                or (type(expirationTime) == "number" and expirationTime == 0)) then
            ids[spellID] = true
        end
    end
    for spellID in pairs(ids) do ordered[#ordered + 1] = spellID end
    table.sort(ordered)
    untimedSpellIDs[kind] = ids
    untimedSignatures[kind] = table.concat(ordered, ",")
    return ids, untimedSignatures[kind]
end

local function makeContainer(kind, filter)
    local cfg = getProfile()[kind]
    local knownUntimed = scanUntimedAuras(kind, filter)
    local auraWidth = cfg.perRow * cfg.size + (cfg.perRow - 1) * cfg.gapX
    local trackingWidth = kind == "buffs" and getProfile().showTrackingControls and (cfg.gapX + cfg.size) or 0
    local width = auraWidth + trackingWidth
    local height = cfg.rows * cfg.size + (cfg.rows - 1) * cfg.gapY
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:SetSize(width, height)
    holder:SetPoint("CENTER", UIParent, "CENTER", cfg.x, cfg.y)
    holder:SetMovable(true)
    holder:SetClampedToScreen(true)
    holder:EnableMouse(true)
    if holder.SetPropagateMouseClicks then holder:SetPropagateMouseClicks(false) end

    local moving = false
    local function startMoving()
        if unlocked and not InCombatLockdown() then
            moving = true
            holder:StartMoving()
        end
    end
    local function stopMoving()
        if not moving then return end
        moving = false
        holder:StopMovingOrSizing()
        local centerX, centerY = holder:GetCenter()
        local screenX, screenY = UIParent:GetCenter()
        if centerX and screenX then
            cfg.x = centerX - screenX
            cfg.y = centerY - screenY
            holder:ClearAllPoints()
            holder:SetPoint("CENTER", UIParent, "CENTER", cfg.x, cfg.y)
            report(L("%s position saved.", L(kind == "buffs" and "Buffs" or "Debuffs")))
        end
    end
    local function makeDraggable(frame)
        frame:RegisterForDrag("LeftButton")
        frame:HookScript("OnDragStart", startMoving)
        frame:HookScript("OnDragStop", stopMoving)
    end
    makeDraggable(holder)

    local background = holder:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.025, 0.018, 0.016, 0.76)
    background:SetShown(unlocked)

    local label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(L("ForeverBuffFrames — %s — drag to move", L(kind == "buffs" and "Buffs" or "Debuffs")))

    local handle = CreateFrame("Frame", nil, holder)
    handle:SetPoint("BOTTOMLEFT", holder, "TOPLEFT")
    handle:SetPoint("BOTTOMRIGHT", holder, "TOPRIGHT")
    handle:SetHeight(20)
    handle:EnableMouse(true)
    makeDraggable(handle)
    local handleFill = handle:CreateTexture(nil, "BACKGROUND")
    handleFill:SetAllPoints()
    handleFill:SetColorTexture(unpack(theme.accent))
    local handleTop = handle:CreateTexture(nil, "BORDER")
    handleTop:SetPoint("TOPLEFT")
    handleTop:SetPoint("TOPRIGHT")
    handleTop:SetHeight(1)
    handleTop:SetColorTexture(unpack(theme.gold))
    local handleBottom = handle:CreateTexture(nil, "BORDER")
    handleBottom:SetPoint("BOTTOMLEFT")
    handleBottom:SetPoint("BOTTOMRIGHT")
    handleBottom:SetHeight(1)
    handleBottom:SetColorTexture(0.22, 0.07, 0.035, 1)
    label:SetPoint("CENTER", handle, "CENTER", 0, 0)
    label:SetShown(unlocked)
    handle:SetShown(unlocked)
    holder.background = background
    holder.label = label
    holder.handle = handle
    holder.handleFill = handleFill

    local auraArea = CreateFrame("Frame", nil, holder)
    auraArea:SetSize(auraWidth, height)
    auraArea:SetPoint("TOPLEFT")
    holder.auraArea = auraArea

    local container = CreateFrame("AuraContainer", nil, auraArea, "CustomAuraContainerTemplate")
    container:SetAllPoints()
    container:EnableMouse(true)
    makeDraggable(container)
    container:SetUnit("player")
    local left = cfg.grow == "left"
    container:SetFlowLayoutAnchorPoint(left and "TOPRIGHT" or "TOPLEFT")
    container:SetFlowLayoutGrowthDirection(left and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down)
    container:SetFlowLayoutMaximumLineSize(cfg.perRow * (cfg.size + cfg.gapX))

    local sortMethods = {
        default = { AuraContainerSortMethod and AuraContainerSortMethod.Default, AuraContainerSortDirection and AuraContainerSortDirection.Normal },
        shortest = { AuraContainerSortMethod and AuraContainerSortMethod.ExpirationOnly, AuraContainerSortDirection and AuraContainerSortDirection.Normal },
        longest = { AuraContainerSortMethod and AuraContainerSortMethod.ExpirationOnly, AuraContainerSortDirection and AuraContainerSortDirection.Reverse },
    }
    local sort = sortMethods[cfg.sort] or sortMethods.default
    local groupOptions = {
        maxFrameCount = cfg.perRow * cfg.rows,
        layout = { elementSpacing = cfg.gapX, lineSpacing = cfg.gapY },
        initializeFrame = function(button)
            button:SetSize(cfg.size, cfg.size)
            makeDraggable(button)
            if kind == "buffs" and button.SetCancelAuraButtons then
                pcall(button.SetCancelAuraButtons, button, "RightButtonUp")
            end

            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints()
            button:SetIcon(icon)

            local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
            cooldown:SetAllPoints()
            if cooldown.SetHideCountdownNumbers then
                cooldown:SetHideCountdownNumbers(true)
            end
            cooldown:SetDrawSwipe(false)
            cooldown:SetDrawEdge(false)
            button:SetDurationCooldown(cooldown)

            local count = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            styleText(count, button, cfg, false)
            button:SetApplicationCount(count)

            local duration = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            styleText(duration, button, cfg, true)
            button:SetDurationText(duration)
            if kind == "debuffs" then addNativeDispelBorder(button, getProfile()) end
        end,
    }
    if sort[1] then
        groupOptions.sortMethod = sort[1]
        groupOptions.sortDirection = sort[2]
    end
    local hasKnownUntimed = next(knownUntimed) ~= nil
    if cfg.untimed ~= "mixed" and hasKnownUntimed then
        local untimedFirst = (cfg.untimed == "untimedleft" and cfg.grow == "right")
            or (cfg.untimed == "untimedright" and cfg.grow == "left")
        local function addGroup(groupKey, candidateFilters)
            groupOptions.candidateFilters = candidateFilters
            container:AddAuraGroup(groupKey, filter, groupOptions)
        end
        local function addUntimed() addGroup(kind .. "Untimed", { includeSpellIDs = knownUntimed }) end
        local function addTimed() addGroup(kind .. "Timed", { excludeSpellIDs = knownUntimed }) end
        if untimedFirst then addUntimed(); addTimed() else addTimed(); addUntimed() end
    else
        container:AddAuraGroup(kind, filter, groupOptions)
    end

    if holders[kind] then
        holders[kind]:Hide()
    end
    containers[kind] = container
    holders[kind] = holder
    holder.container = container
    if kind == "buffs" and tracking then tracking.Attach(holder, cfg) end
    if testMode then
        showTest(holder, cfg)
        container:Hide()
    end
end

local filters = { buffs = "HELPFUL", debuffs = "HARMFUL" }

local function build(kind)
    local ok, err = pcall(makeContainer, kind, filters[kind])
    results[kind] = ok and L("created") or tostring(err)
    if not ok then
        report(L("%s: %s", L(kind == "buffs" and "Buffs" or "Debuffs"), results[kind]))
    end
end

local function refreshUntimedGroups()
    if not getProfile() or InCombatLockdown() then return end
    for kind, filter in pairs(filters) do
        if getProfile()[kind] and getProfile()[kind].untimed ~= "mixed" then
            local previous = untimedSignatures[kind]
            local _, current = scanUntimedAuras(kind, filter)
            if current ~= previous then build(kind) end
        end
    end
end

local function start()
    build("buffs")
    build("debuffs")
end

local function setUnlocked(value)
    if InCombatLockdown() then
        report(L("Change the lock after combat."))
        return
    end
    unlocked = value
    for _, holder in pairs(holders) do
        holder.background:SetShown(unlocked)
        holder.label:SetShown(unlocked)
        holder.handle:SetShown(unlocked)
    end
    report(L(unlocked and "Bars unlocked; drag a bar or its label to move it." or "Bars locked."))
end

toggleTest = function()
    if InCombatLockdown() then
        report(L("Toggle test icons after combat."))
        return
    end
    testMode = not testMode
    for kind, holder in pairs(holders) do
        if testMode then
            showTest(holder, getProfile()[kind])
            holder.container:Hide()
        elseif holder.test then
            holder.test.run = (holder.test.run or 0) + 1
            holder.test:Hide()
            holder.container:Show()
            holder.container:UpdateAllAuras()
        end
    end
    report(L(testMode and "Test icons shown; /fbf test hides them." or "Test icons hidden."))
end

FBF.AuraFrames = {}

function FBF.AuraFrames.Create(profileProvider, reporter, soundPlayer)
    getProfile = profileProvider
    report = reporter
    playAlertSound = soundPlayer
    tracking = FBF.Tracking.Create(profileProvider, reporter)
    return {
        Build = build,
        RefreshUntimedGroups = refreshUntimedGroups,
        Start = start,
        SetUnlocked = setUnlocked,
        ToggleTest = toggleTest,
        IsUnlocked = function() return unlocked end,
        Supports = function(kind) return filters[kind] ~= nil end,
        GetContainer = function(kind) return containers[kind] end,
        GetResult = function(kind) return results[kind] end,
        GetAwarenessResult = function() return awarenessResult end,
        GetTrackingStatus = function() return tracking and tracking.GetStatus() or {} end,
        PreviewDebuffAwareness = previewDebuffAwareness,
    }
end
