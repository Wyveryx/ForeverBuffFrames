local ADDON, FBF = ...
FBF.name = ADDON

FBF.defaults = {
    buffs = { x = -190, y = 160, size = 40, gapX = 4, gapY = 4, perRow = 8, rows = 1, grow = "right", sort = "default", untimed = "mixed", timerSize = 10, countSize = 10, timerPos = "below", countPos = "bottomright", font = "default", outline = "none" },
    debuffs = { x = 190, y = 160, size = 40, gapX = 4, gapY = 4, perRow = 8, rows = 1, grow = "right", sort = "default", untimed = "mixed", timerSize = 10, countSize = 10, timerPos = "below", countPos = "bottomright", font = "default", outline = "none" },
}

function FBF.CopyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do
        result[key] = type(value) == "table" and FBF.CopyTable(value) or value
    end
    return result
end

function FBF.InitializeProfile(profile)
    profile = type(profile) == "table" and profile or {}
    if type(profile.minimapAngle) ~= "number" then profile.minimapAngle = 135 end
    if profile.showMinimap == nil then profile.showMinimap = true end
    if profile.hideBlizzardBuffs == nil then profile.hideBlizzardBuffs = false end
    if profile.hideBlizzardDebuffs == nil then profile.hideBlizzardDebuffs = false end
    if profile.expirationSounds == nil then profile.expirationSounds = profile.alertSpellID ~= nil end
    if profile.buffRemovedSounds == nil then profile.buffRemovedSounds = false end
    if type(profile.buffRemovalSound) ~= "string" then profile.buffRemovalSound = "default" end
    if type(profile.learnedBuffAlerts) ~= "table" then profile.learnedBuffAlerts = {} end
    for spellID, learned in pairs(profile.learnedBuffAlerts) do
        if type(spellID) ~= "number" or type(learned) ~= "table" then
            profile.learnedBuffAlerts[spellID] = nil
        else
            learned.enabled = learned.enabled == true
            learned.combatOnly = learned.combatOnly == true
            if type(learned.sound) ~= "string" then learned.sound = nil end
            if type(learned.classes) ~= "table" then learned.classes = {} end
        end
    end
    if type(profile.customSounds) ~= "table" then profile.customSounds = {} end
    for key, path in pairs(profile.customSounds) do
        if type(key) ~= "string" or type(path) ~= "string" or path == "" then profile.customSounds[key] = nil end
    end
    if type(profile.alertSound) ~= "string" then profile.alertSound = "default" end
    if profile.onlyMyBuffs == nil then profile.onlyMyBuffs = false end
    -- debugAlerts was a user-facing diagnostic switch before 0.9.1. Leave an
    -- imported value harmlessly in place for old saved variables and backups,
    -- but runtime diagnostics now live in the dedicated options tab.
    if type(profile.alertMinDuration) ~= "number" then profile.alertMinDuration = 60 end
    if profile.debuffAwareness == nil then profile.debuffAwareness = false end
    if profile.debuffPulse == nil then profile.debuffPulse = false end
    if type(profile.debuffBorderThickness) ~= "number" then profile.debuffBorderThickness = 2 end
    profile.debuffBorderThickness = math.max(1, math.min(6, math.floor(profile.debuffBorderThickness + 0.5)))
    if type(profile.debuffPulseExpansion) ~= "number" then profile.debuffPulseExpansion = 4 end
    profile.debuffPulseExpansion = math.max(0, math.min(12, math.floor(profile.debuffPulseExpansion + 0.5)))
    if profile.debuffSoundsEnabled == nil then profile.debuffSoundsEnabled = false end
    if type(profile.debuffSoundName) ~= "string" then profile.debuffSoundName = "default" end
    if type(profile.debuffSounds) ~= "table" then profile.debuffSounds = {} end
    for _, kind in ipairs({ "Magic", "Curse", "Disease", "Poison" }) do
        local key = "debuffSound" .. kind
        if type(profile[key]) ~= "string" then profile[key] = profile.debuffSoundName end
        if type(profile.debuffSounds[kind]) ~= "string" then profile.debuffSounds[kind] = profile[key] end
        profile[key] = profile.debuffSounds[kind]
    end
    if type(profile.learnedDebuffs) ~= "table" then profile.learnedDebuffs = {} end
    if type(profile.customDebuffTrackers) ~= "table" then profile.customDebuffTrackers = {} end
    for spellID, tracker in pairs(profile.customDebuffTrackers) do
        local id = tonumber(spellID)
        if not id or id < 1 or id % 1 ~= 0 or type(tracker) ~= "table" then
            profile.customDebuffTrackers[spellID] = nil
        else
            if id ~= spellID then
                profile.customDebuffTrackers[id] = tracker
                profile.customDebuffTrackers[spellID] = nil
            end
            tracker.name = type(tracker.name) == "string" and tracker.name:sub(1, 80) or ""
            tracker.sound = type(tracker.sound) == "string" and tracker.sound or "default"
            tracker.enabled = tracker.enabled ~= false
        end
    end
    -- Player-debuff Spell ID exclusions are not honored by the client, so
    -- discard data created by the short-lived experimental Hidden Debuffs UI.
    profile.hiddenDebuffs = nil
    if profile.debuffBorderStyle ~= "border" and profile.debuffBorderStyle ~= "bordericon" and profile.debuffBorderStyle ~= "icon" then
        profile.debuffBorderStyle = "border"
    end
    if type(profile.alertBlacklist) ~= "table" then profile.alertBlacklist = {} end
    profile.alertSpellID = nil
    profile.alertSpellName = nil
    for kind, position in pairs(FBF.defaults) do
        if type(profile[kind]) ~= "table" then profile[kind] = {} end
        for key, value in pairs(position) do
            if profile[kind][key] == nil then profile[kind][key] = value end
        end
    end
    return profile
end
