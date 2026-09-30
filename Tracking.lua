local _, FBF = ...
local L = FBF.L

FBF.Tracking = {}

function FBF.Tracking.Create(profileProvider, reporter)
    local getProfile = profileProvider
    local report = reporter
    local current
    local supportedTrackingSpells = {
        [1494] = true,  -- Track Beasts
        [2383] = true,  -- Find Herbs
        [2481] = true,  -- Find Treasure
        [2580] = true,  -- Find Minerals
        [2836] = true,  -- Detect Traps
        [5225] = true,  -- Track Humanoids (Druid)
        [5500] = true,  -- Sense Demons
        [5502] = true,  -- Sense Undead
        [19878] = true, -- Track Demons
        [19879] = true, -- Track Dragonkin
        [19880] = true, -- Track Elementals
        [19882] = true, -- Track Giants
        [19883] = true, -- Track Humanoids (Hunter)
        [19884] = true, -- Track Undead
        [19885] = true, -- Track Hidden
        [30645] = true, [43308] = true,
    }

    local function getInfo(index)
        if not C_Minimap or not C_Minimap.GetTrackingInfo then return nil end
        local values = { pcall(C_Minimap.GetTrackingInfo, index) }
        if not values[1] then return nil end
        if type(values[2]) == "table" then return values[2] end
        if values[2] == nil then return nil end
        return { name = values[2], texture = values[3], active = values[4], type = values[5], subType = values[6], spellID = values[7] }
    end

    local function count()
        if not C_Minimap or not C_Minimap.GetNumTrackingTypes then return 0 end
        local ok, value = pcall(C_Minimap.GetNumTrackingTypes)
        return ok and tonumber(value) or 0
    end

    local function isSupported(info)
        return info and supportedTrackingSpells[tonumber(info.spellID)] == true
    end

    local function closeMenu()
        if current and current.menu then current.menu:Hide() end
    end

    local function setExclusiveTracking(selectedIndex)
        if InCombatLockdown() then report(L("Change tracking after combat.")); return false end
        if not C_Minimap or not C_Minimap.SetTracking then
            report(L("Tracking selection is unavailable in this client.")); return false
        end
        for index = 1, count() do
            local info = getInfo(index)
            if isSupported(info) then
                local ok = pcall(C_Minimap.SetTracking, index, index == selectedIndex)
                if not ok then report(L("The client blocked that tracking change.")); return false end
            end
        end
        return true
    end

    local function buildMenu(owner)
        if owner.menu then owner.menu:Hide() end
        local entries = {}
        for index = 1, count() do
            local info = getInfo(index)
            if isSupported(info) and info.name and info.name ~= "" then
                entries[#entries + 1] = { index = index, info = info }
            end
        end
        local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        menu:SetFrameStrata("DIALOG")
        menu:SetFrameLevel(owner:GetFrameLevel() + 20)
        menu:SetClampedToScreen(true)
        menu:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 0, -20)
        local visible = math.max(1, math.min(8, #entries))
        menu:SetSize(250, visible * FBF.Theme.popupRowStep + 2 * FBF.Theme.popupPadding)
        FBF.Theme.ApplyPopup(menu)
        FBF.Theme.RaisePopup(menu, owner)
        local scroll = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", FBF.Theme.popupPadding, -FBF.Theme.popupPadding)
        scroll:SetPoint("BOTTOMRIGHT", -32, FBF.Theme.popupPadding)
        local child = CreateFrame("Frame", nil, scroll)
        child:SetSize(206, math.max(1, #entries * FBF.Theme.popupRowStep))
        scroll:SetScrollChild(child)
        for rowIndex, entry in ipairs(entries) do
            local row = CreateFrame("Button", nil, child)
            row:SetSize(206, FBF.Theme.popupRowHeight)
            row:SetPoint("TOPLEFT", 0, -(rowIndex - 1) * FBF.Theme.popupRowStep)
            FBF.Theme.AddRowHighlight(row, 2)
            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(22, 22); icon:SetPoint("LEFT", 4, 0); icon:SetTexture(entry.info.texture)
            local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            name:SetPoint("LEFT", icon, "RIGHT", 7, 0); name:SetPoint("RIGHT", -28, 0); name:SetJustifyH("LEFT"); name:SetText(entry.info.name)
            local check = row:CreateTexture(nil, "OVERLAY")
            check:SetSize(20, 20); check:SetPoint("RIGHT", -4, 0); check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            check:SetShown(entry.info.active == true)
            row:SetScript("OnClick", function() setExclusiveTracking(entry.index); closeMenu() end)
        end
        if #entries == 0 then
            local empty = child:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            empty:SetPoint("CENTER"); empty:SetText(L("No character tracking abilities are available."))
        end
        owner.menu = menu
        current.menu = menu
        return menu
    end

    local function attach(holder, cfg)
        closeMenu()
        if not getProfile().showTrackingControls then return end
        local selector = CreateFrame("Button", nil, holder)
        selector:SetSize(cfg.size, cfg.size)
        selector:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
        selector:SetFrameLevel(holder:GetFrameLevel() + 8)
        local icon = selector:CreateTexture(nil, "ARTWORK")
        local glyphSize = math.max(16, math.floor(cfg.size * 0.78 + 0.5))
        icon:SetSize(glyphSize, glyphSize); icon:SetPoint("CENTER")
        local atlasOK = icon.SetAtlas and pcall(icon.SetAtlas, icon, "common-search-magnifyingglass")
        if not atlasOK then
            icon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
            icon:SetTexCoord(0.16, 0.84, 0.16, 0.84)
        end
        local background = selector:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.035, 0.035, 0.035, 0.92)
        local mask = selector:CreateMaskTexture()
        mask:SetAllPoints()
        local maskOK = mask.SetAtlas and pcall(mask.SetAtlas, mask, "UI-HUD-ActionBar-IconFrame-Mask")
        if maskOK then background:AddMaskTexture(mask) end
        local border = selector:CreateTexture(nil, "OVERLAY")
        border:SetAllPoints()
        local borderOK = border.SetAtlas and pcall(border.SetAtlas, border, "UI-HUD-ActionBar-IconFrame")
        if not borderOK then
            border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
            border:SetTexCoord(0.12, 0.88, 0.12, 0.88)
        end
        if selector.SetHighlightAtlas then
            pcall(selector.SetHighlightAtlas, selector, "UI-HUD-ActionBar-IconFrame-Highlight", "ADD")
        end
        selector:SetScript("OnClick", function(self)
            if InCombatLockdown() then report(L("Choose tracking after combat.")); return end
            if self.menu and self.menu:IsShown() then self.menu:Hide(); return end
            buildMenu(self):Show()
        end)
        selector:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L("Choose tracking buff"))
            GameTooltip:AddLine(L("Choose a class, profession, or racial tracking ability. Its native tracking buff will appear in the buff bar."), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        selector:SetScript("OnLeave", function() GameTooltip:Hide() end)
        holder.trackingSelector = selector
        current = selector
    end

    return { Attach = attach }
end
