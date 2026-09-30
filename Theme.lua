local _, FBF = ...

FBF.Theme = {
    background = { 0.055, 0.043, 0.034, 0.99 },
    raised = { 0.065, 0.052, 0.052, 0.98 },
    sidebar = { 0.030, 0.022, 0.020, 0.98 },
    accent = { 0.58, 0.10, 0.075, 0.92 },
    accentBright = { 0.92, 0.28, 0.16, 1 },
    border = { 0.48, 0.23, 0.11, 0.9 },
    gold = { 1, 0.72, 0.28, 1 },
    popupRowHeight = 32,
    popupRowStep = 34,
    popupPadding = 8,
}

function FBF.Theme.ApplyWindow(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:SetBackdropColor(unpack(FBF.Theme.background))
    frame:SetBackdropBorderColor(0.72, 0.52, 0.25, 1)
end

function FBF.Theme.ApplyPopup(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    frame:SetBackdropColor(unpack(FBF.Theme.background))
    frame:SetBackdropBorderColor(unpack(FBF.Theme.border))
    frame:SetToplevel(true)
end

function FBF.Theme.RaisePopup(frame, owner)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(math.max(frame:GetFrameLevel(), (owner and owner:GetFrameLevel() or 0) + 100))
end

function FBF.Theme.StylePopupRow(button, label, selected)
    FBF.Theme.AddRowHighlight(button, 2)
    if selected then
        selected:ClearAllPoints()
        selected:SetPoint("TOPLEFT", 2, -2)
        selected:SetPoint("BOTTOMRIGHT", -2, 2)
        selected:SetColorTexture(unpack(FBF.Theme.accent))
    end
    if label then
        label:ClearAllPoints()
        label:SetPoint("LEFT", 12, 0)
        label:SetPoint("RIGHT", -12, 0)
        label:SetJustifyH("LEFT")
        label:SetWordWrap(false)
    end
end

function FBF.Theme.AddTitlePlaque(frame)
    local plaque = frame:CreateTexture(nil, "OVERLAY")
    plaque:SetTexture("Interface\\AddOns\\ForeverBuffFrames\\Media\\TitlePlaque.png")
    -- Crop the transparent generation margin so the ornament uses its full
    -- on-screen footprint without increasing the header's vertical space.
    plaque:SetTexCoord(0, 1, 0.12, 0.84)
    plaque:SetSize(390, 92)
    plaque:SetPoint("TOP", frame, "TOP", 0, 12)
    return plaque
end

function FBF.Theme.AddVerticalDivider(frame, anchor)
    local shadow = frame:CreateTexture(nil, "BORDER")
    shadow:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 0, 0)
    shadow:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", 0, 0)
    shadow:SetWidth(5)
    shadow:SetColorTexture(0.055, 0.025, 0.012, 1)

    local bronze = frame:CreateTexture(nil, "ARTWORK")
    bronze:SetPoint("TOPLEFT", shadow, "TOPLEFT", 1, 0)
    bronze:SetPoint("BOTTOMLEFT", shadow, "BOTTOMLEFT", 1, 0)
    bronze:SetWidth(2)
    bronze:SetColorTexture(0.52, 0.29, 0.10, 1)

    local highlight = frame:CreateTexture(nil, "OVERLAY")
    highlight:SetPoint("TOPLEFT", shadow, "TOPLEFT", 1, 0)
    highlight:SetPoint("BOTTOMLEFT", shadow, "BOTTOMLEFT", 1, 0)
    highlight:SetWidth(1)
    highlight:SetColorTexture(0.92, 0.63, 0.25, 0.88)
    return shadow
end

function FBF.Theme.AddRowHighlight(button, inset)
    inset = inset or 0
    local highlight = button:CreateTexture(nil, "BACKGROUND")
    highlight:SetPoint("TOPLEFT", inset, -inset)
    highlight:SetPoint("BOTTOMRIGHT", -inset, inset)
    highlight:SetColorTexture(0.48, 0.25, 0.075, 0.38)
    button:SetHighlightTexture(highlight)
    return highlight
end

function FBF.Theme.StyleSectionHeading(text)
    text:SetTextColor(unpack(FBF.Theme.gold))
    text:SetShadowColor(0, 0, 0, 1)
    text:SetShadowOffset(1, -1)
end

function FBF.Theme.StyleSlider(slider, track)
    track:SetColorTexture(0.31, 0.19, 0.075, 1)
    track:SetHeight(5)
    local highlight = slider:CreateTexture(nil, "ARTWORK")
    highlight:SetPoint("LEFT", track, "LEFT", 1, 1)
    highlight:SetPoint("RIGHT", track, "RIGHT", -1, 1)
    highlight:SetHeight(1)
    highlight:SetColorTexture(0.76, 0.49, 0.17, 0.72)
end

function FBF.Theme.StyleInput(input)
    input:SetTextColor(0.96, 0.88, 0.72)
    if input.SetHighlightColor then input:SetHighlightColor(0.62, 0.20, 0.08, 0.65) end
end

function FBF.Theme.StyleSelector(button)
    local label = button:GetFontString()
    if label then
        label:SetTextColor(1, 0.78, 0.30)
        label:SetShadowColor(0, 0, 0, 1)
        label:SetShadowOffset(1, -1)
    end
    if button.selectorArrow then button.selectorArrow:SetVertexColor(1, 0.72, 0.18, 1) end
end

function FBF.Theme.StyleDangerButton(button)
    local label = button:GetFontString()
    if label then
        label:SetTextColor(1, 0.52, 0.34)
        label:SetShadowColor(0.12, 0, 0, 1)
        label:SetShadowOffset(1, -1)
    end
end

function FBF.Theme.AddInsetSurface(parent, left, top, width, height)
    local function stabilize(texture)
        -- Resizable, centered windows frequently land on fractional UI pixels.
        -- A one-pixel edge can then disappear at particular window sizes.  Keep
        -- solid-color geometry independent of WoW's texel snapping and use a
        -- two-pixel connected edge so every side remains visible at every scale.
        if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(false) end
        if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
        return texture
    end

    local fill = stabilize(parent:CreateTexture(nil, "BACKGROUND"))
    fill:SetPoint("TOPLEFT", left, top)
    fill:SetSize(width, height)
    fill:SetColorTexture(0.018, 0.014, 0.012, 0.34)

    local bronze = { 0.43, 0.24, 0.085, 0.58 }
    local topEdge = stabilize(parent:CreateTexture(nil, "BORDER"))
    topEdge:SetPoint("TOPLEFT", fill, "TOPLEFT")
    topEdge:SetPoint("TOPRIGHT", fill, "TOPRIGHT")
    topEdge:SetHeight(2)
    topEdge:SetColorTexture(unpack(bronze))
    local bottomEdge = stabilize(parent:CreateTexture(nil, "BORDER"))
    bottomEdge:SetPoint("BOTTOMLEFT", fill, "BOTTOMLEFT")
    bottomEdge:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT")
    bottomEdge:SetHeight(2)
    bottomEdge:SetColorTexture(unpack(bronze))
    local leftEdge = stabilize(parent:CreateTexture(nil, "BORDER"))
    leftEdge:SetPoint("TOPLEFT", fill, "TOPLEFT")
    leftEdge:SetPoint("BOTTOMLEFT", fill, "BOTTOMLEFT")
    leftEdge:SetWidth(2)
    leftEdge:SetColorTexture(unpack(bronze))
    local rightEdge = stabilize(parent:CreateTexture(nil, "BORDER"))
    rightEdge:SetPoint("TOPRIGHT", fill, "TOPRIGHT")
    rightEdge:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT")
    rightEdge:SetWidth(2)
    rightEdge:SetColorTexture(unpack(bronze))
    return fill
end

function FBF.Theme.AddInsetDivider(parent, left, top, height)
    local shadow = parent:CreateTexture(nil, "BORDER")
    shadow:SetPoint("TOPLEFT", left, top)
    shadow:SetSize(2, height)
    shadow:SetColorTexture(0.055, 0.025, 0.012, 0.82)
    local highlight = parent:CreateTexture(nil, "ARTWORK")
    highlight:SetPoint("TOPLEFT", shadow, "TOPLEFT")
    highlight:SetPoint("BOTTOMLEFT", shadow, "BOTTOMLEFT")
    highlight:SetWidth(1)
    highlight:SetColorTexture(0.50, 0.28, 0.09, 0.58)
    return shadow
end
