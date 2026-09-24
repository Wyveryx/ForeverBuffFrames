local ADDON, FBF = ...
local L = FBF.L
local SOUND_FILE_ID = FBF.SOUND_FILE_ID
local soundSource = FBF.SoundSource
local db
local database
local minimapButton
local stockFrames = {}
local function playAlertSound()
    local source = soundSource(db and db.alertSound or "default")
    if not source then return false end
    if type(source) == "number" then
        if source == SOUND_FILE_ID then return PlaySoundFile(source, "Master") end
        return PlaySound(source, "Master")
    end
    return PlaySoundFile(source, "Master")
end

local function report(message)
    print("|cff66ccff" .. ADDON .. ":|r " .. message)
end

local function applyStockVisibility()
    if InCombatLockdown() then
        report(L("Blizzard frame visibility will update after combat."))
        return
    end
    for _, spec in ipairs({ { "buffs", "BuffFrame", "hideBlizzardBuffs" }, { "debuffs", "DebuffFrame", "hideBlizzardDebuffs" } }) do
        local kind, name, key = unpack(spec)
        local frame = _G[name]
        if frame and (db[key] or stockFrames[kind]) then
            if not stockFrames[kind] then
                stockFrames[kind] = { frame = frame, alpha = frame:GetAlpha() }
                local hideKey = key
                hooksecurefunc(frame, "Show", function(self)
                    if db[hideKey] and not InCombatLockdown() then self:Hide() end
                end)
            end
            if db[key] then
                frame:SetAlpha(0)
                frame:Hide()
            else
                frame:SetAlpha(stockFrames[kind].alpha)
                if frame.UpdateShownState then
                    frame:UpdateShownState()
                else
                    frame:Show()
                end
            end
        elseif not frame and db[key] then
            report(L("%s is unavailable in this client.", name))
        end
    end
end

local options
local alerts = FBF.CreateAlerts(
    function() return db end,
    report,
    playAlertSound,
    function() if options then options.Refresh() end end)
local handleAlertCommand = alerts.Handle
local syncExpiryAlerts = alerts.Sync
local auraFrames = FBF.AuraFrames.Create(function() return db end, report, playAlertSound)
local build = auraFrames.Build
local refreshUntimedGroups = auraFrames.RefreshUntimedGroups
local start = auraFrames.Start
local setUnlocked = auraFrames.SetUnlocked
local toggleTest = auraFrames.ToggleTest
options = FBF.Options.Create({
    GetProfile = function() return db end,
    GetDatabase = function() return database end,
    SetProfile = function(profile) db = profile end,
    SetDatabase = function(value)
        database = value
        ForeverBuffFramesDB = value
    end,
    GetMinimapButton = function() return minimapButton end,
    Report = report,
    ApplyStockVisibility = applyStockVisibility,
    AuraFrames = auraFrames,
    Alerts = alerts,
})
local openConfig = options.Open
local tooltip = options.Tooltip
local registerSettings = options.Register


local function createMinimapButton()
    minimapButton = FBF.Minimap.Create({
        GetProfile = function() return db end,
        OpenConfig = openConfig,
        Tooltip = tooltip,
    })
end

SLASH_FBF1 = "/fbf"
SLASH_FBF2 = "/fbf0"
SlashCmdList["FBF"] = function(message)
    local rawMessage = (message or ""):match("^%s*(.-)%s*$")
    message = rawMessage:lower()
    if message == "unlock" then
        setUnlocked(true)
        return
    elseif message == "lock" then
        setUnlocked(false)
        return
    elseif message == "test" then
        toggleTest()
        return
    elseif message == "config" or message == "options" then
        openConfig()
        return
    end
    local alertValue = rawMessage:match("^[Aa][Ll][Ee][Rr][Tt]%s+(.+)$")
    if alertValue then
        handleAlertCommand(alertValue)
        return
    end
    local kind, setting, value = message:match("^(%S+)%s+(%S+)%s+(%S+)$")
    if auraFrames.Supports(kind) then
        if InCombatLockdown() then
            report(L("Change layout after combat."))
            return
        end
        local cfg = db[kind]
        local choices = {
            grow = { left = true, right = true },
            sort = { default = true, shortest = true, longest = true },
            untimed = { mixed = true, untimedleft = true, untimedright = true },
            timerpos = { above = true, below = true, center = true },
            countpos = { topleft = true, topright = true, bottomleft = true, bottomright = true },
            font = { default = true, unit = true, damage = true, narrow = true, morpheus = true, skurri = true },
            outline = { none = true, outline = true, thick = true },
        }
        if choices[setting] and choices[setting][value] then
            local key = ({ timerpos = "timerPos", countpos = "countPos" })[setting] or setting
            cfg[key] = value
        else
            local limits = {
                size = { 16, 96 }, gapx = { 0, 32 }, gapy = { 0, 32 },
                perrow = { 1, 20 }, rows = { 1, 10 }, timer = { 6, 36 }, count = { 6, 36 },
            }
            local limit = limits[setting]
            local number = tonumber(value)
            if not limit or not number or number % 1 ~= 0 or number < limit[1] or number > limit[2] then
                report(L("Use /fbf for commands. Examples: /fbf buffs timer 14; /fbf debuffs timerpos above."))
                return
            end
            local key = ({ gapx = "gapX", gapy = "gapY", perrow = "perRow", timer = "timerSize", count = "countSize" })[setting] or setting
            cfg[key] = number
        end
        build(kind)
        return
    end
    if InCombatLockdown() then
        report(L("Check status after combat."))
        return
    end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        local container = auraFrames.GetContainer(kind)
        if container then
            local cfg = db[kind]
            report(L("%s: position %d, %d; size %d; spacing %d/%d; %d per row, %d rows; growth %s; order %s; unlimited %s",
                L(kind == "buffs" and "Buffs" or "Debuffs"), math.floor(cfg.x), math.floor(cfg.y), cfg.size,
                cfg.gapX, cfg.gapY, cfg.perRow, cfg.rows, cfg.grow, cfg.sort, cfg.untimed))
            report(L("%s: timer %d %s; stack %d %s; font %s; outline %s",
                L(kind == "buffs" and "Buffs" or "Debuffs"), cfg.timerSize, cfg.timerPos,
                cfg.countSize, cfg.countPos, cfg.font, cfg.outline))
        else
            report(L("%s: %s", L(kind == "buffs" and "Buffs" or "Debuffs"), auraFrames.GetResult(kind) or L("not started")))
        end
    end
    report(L("/fbf config opens settings; /fbf test toggles sample icons."))
    report(L("Layout commands use size, spacing, rows, growth, order, and unlimited-aura placement. Open settings for the complete controls."))
    report(L("Text commands control timer and stack size, position, font, and outline. Open settings for the complete controls."))
    report(L("Use the settings checkbox or /fbf alert on to enable 10-second expiry alerts; /fbf alert off disables them."))
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
if events.RegisterUnitEvent then
    events:RegisterUnitEvent("UNIT_AURA", "player")
else
    events:RegisterEvent("UNIT_AURA")
end
events:RegisterEvent("ADDON_ACTION_BLOCKED")
events:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_ACTION_BLOCKED" then
        if addon == ADDON then
            report(L("The client blocked an addon action; check the Lua error for details."))
        end
    elseif event == "ADDON_LOADED" and addon == ADDON then
        database = FBF.Profiles.InitializeDatabase(ForeverBuffFramesDB)
        ForeverBuffFramesDB = database
        FBF.Locale.Initialize(database.uiLocale)
        db = database.profiles[database.activeProfile]
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")
        start()
        registerSettings()
        createMinimapButton()
        applyStockVisibility()
        syncExpiryAlerts()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        refreshUntimedGroups()
        syncExpiryAlerts()
    elseif event == "UNIT_AURA" and addon == "player" then
        refreshUntimedGroups()
        syncExpiryAlerts()
    end
end)
