local _, FBF = ...
local L = FBF.L

FBF.Minimap = {}
local MinimapModule = FBF.Minimap

function MinimapModule.Create(options)
    local button = CreateFrame("Button", "ForeverBuffFramesMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetPoint("TOPLEFT", 7, -5)
    background:SetTexture(136467)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 6, -6)
    icon:SetTexture("Interface\\AddOns\\ForeverBuffFrames\\Media\\MinimapIcon.png")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    border:SetTexture(136430)

    local function position()
        local profile = options.GetProfile()
        local angle = math.rad(profile.minimapAngle)
        local radius = Minimap:GetWidth() / 2 + 8
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end
    button.position = position

    local dragging = false
    local lastDragStop = 0
    button:SetScript("OnDragStart", function() dragging = true end)
    button:SetScript("OnUpdate", function()
        if not dragging then return end
        local scale = UIParent:GetEffectiveScale()
        local cursorX, cursorY = GetCursorPosition()
        local centerX, centerY = Minimap:GetCenter()
        if not centerX then return end
        local x = cursorX / scale - centerX
        local y = cursorY / scale - centerY
        local angle
        if x == 0 then
            angle = y >= 0 and math.pi / 2 or -math.pi / 2
        else
            angle = math.atan(y / x)
            if x < 0 then angle = angle + math.pi end
        end
        options.GetProfile().minimapAngle = math.deg(angle)
        position()
    end)
    button:SetScript("OnDragStop", function()
        dragging = false
        lastDragStop = GetTime()
    end)
    button:SetScript("OnClick", function()
        if GetTime() - lastDragStop >= 0.2 then options.OpenConfig() end
    end)
    options.Tooltip(button, "ForeverBuffFrames", L("Left click to open settings. Drag to move this minimap button."))
    position()
    button:SetShown(options.GetProfile().showMinimap)
    return button
end
