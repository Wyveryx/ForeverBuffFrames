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
    if type(profile.alertSound) ~= "string" then profile.alertSound = "default" end
    if profile.onlyMyBuffs == nil then profile.onlyMyBuffs = false end
    if profile.debugAlerts == nil then profile.debugAlerts = false end
    if type(profile.alertMinDuration) ~= "number" then profile.alertMinDuration = 60 end
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
