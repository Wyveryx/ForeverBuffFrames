local _, FBF = ...
local L = FBF.L

-- Backup owns every on-disk backup format. Keep the field order append-only:
-- FBF3 compact profiles are positional and old codes depend on these layouts.
local Backup = {
    -- The legacy field order remains available to the readers below. New
    -- exports use exportFields so positional FBF3 codes no longer carry the
    -- retired debugAlerts option.
    fields = {
        "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs",
        "expirationSounds", "alertSound", "onlyMyBuffs", "debugAlerts", "alertMinDuration",
    },
    exportFields = {
        "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs",
        "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
        "debuffAwareness", "debuffPulse", "debuffBorderStyle",
        "debuffSoundsEnabled", "debuffSoundName",
        "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison",
        "debuffBorderThickness", "debuffPulseExpansion",
        "buffRemovedSounds", "buffRemovalSound", "showTrackingControls",
    },
    barFields = {
        "x", "y", "size", "gapX", "gapY", "perRow", "rows", "grow",
        "sort", "untimed", "timerSize", "countSize", "timerPos", "countPos", "font", "outline",
    },
    booleans = {
        showMinimap = true, hideBlizzardBuffs = true, hideBlizzardDebuffs = true,
        expirationSounds = true, onlyMyBuffs = true, debugAlerts = true,
        debuffAwareness = true, debuffPulse = true,
        debuffSoundsEnabled = true,
        buffRemovedSounds = true,
        showTrackingControls = true,
        experimentalTTSEnabled = true,
    },
    numbers = {
        minimapAngle = { -3600, 3600 }, alertMinDuration = { 0, 3600, true },
        experimentalTTSSpellID = { 0, 100000000, true },
        x = { -10000, 10000 }, y = { -10000, 10000 },
        size = { 16, 96, true }, gapX = { 0, 32, true }, gapY = { 0, 32, true },
        perRow = { 1, 20, true }, rows = { 1, 10, true },
        timerSize = { 6, 36, true }, countSize = { 6, 36, true },
        debuffBorderThickness = { 1, 6, true }, debuffPulseExpansion = { 0, 12, true },
    },
    choices = {
        grow = { left = true, right = true },
        sort = { default = true, shortest = true, longest = true },
        untimed = { mixed = true, untimedleft = true, untimedright = true },
        timerPos = { below = true, above = true, center = true },
        countPos = { bottomright = true, bottomleft = true, topright = true, topleft = true },
        outline = { none = true, outline = true, thick = true },
        debuffBorderStyle = { border = true, bordericon = true, icon = true },
    },
}
FBF.Backup = Backup

function Backup.Encode(value)
    if type(value) == "boolean" then return value and "1" or "0" end
    local encoded = tostring(value):gsub("([^%w %-%._:])", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
    return encoded
end

function Backup.Decode(value)
    local decoded = value:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
    return decoded
end

local function split(value, separator)
    local parts, start = {}, 1
    while true do
        local position = value:find(separator, start, true)
        if not position then
            parts[#parts + 1] = value:sub(start)
            return parts
        end
        parts[#parts + 1] = value:sub(start, position - 1)
        start = position + #separator
    end
end

local function blacklistValue(profile)
    local blocked = {}
    for id, enabled in pairs(profile.alertBlacklist or {}) do
        if enabled and type(id) == "number" and id > 0 and id % 1 == 0 then
            blocked[#blocked + 1] = id
        end
    end
    table.sort(blocked)
    return table.concat(blocked, ",")
end

local function trackerValue(profile)
    local entries = {}
    for spellID, tracker in pairs(profile.customDebuffTrackers or {}) do
        if type(spellID) == "number" and spellID > 0 and spellID % 1 == 0 and type(tracker) == "table" then
            entries[#entries + 1] = {
                id = spellID,
                value = table.concat({
                    tostring(spellID),
                    tracker.enabled == false and "0" or "1",
                    Backup.Encode(type(tracker.name) == "string" and tracker.name:sub(1, 80) or ""),
                    Backup.Encode(type(tracker.sound) == "string" and tracker.sound:sub(1, 150) or "default"),
                }, "~"),
            }
        end
    end
    table.sort(entries, function(a, b) return a.id < b.id end)
    local values = {}
    for index, entry in ipairs(entries) do values[index] = entry.value end
    return table.concat(values, "|")
end

local function readTrackers(value)
    local trackers = {}
    if value == nil or value == "" then return trackers end
    if #value > 50000 then return nil, L("Personal tracker data is too large.") end
    for entry in value:gmatch("[^|]+") do
        local idText, enabled, name, sound = entry:match("^(%d+)~([01])~([^~]*)~(.*)$")
        local spellID = tonumber(idText)
        name, sound = name and Backup.Decode(name), sound and Backup.Decode(sound)
        if not spellID or spellID < 1 or spellID % 1 ~= 0 or not name or name == "" or #name > 80
            or not sound or sound == "" or #sound > 150 then
            return nil, L("Invalid Personal Tracker data.")
        end
        trackers[spellID] = { name = name, sound = sound, enabled = enabled == "1" }
    end
    return trackers
end

local function buffAlertValue(profile)
    local entries = {}
    for spellID, alert in pairs(profile.learnedBuffAlerts or {}) do
        if type(spellID) == "number" and alert.enabled == true then
            entries[#entries + 1] = table.concat({
                tostring(spellID), Backup.Encode(alert.name or tostring(spellID)),
                Backup.Encode(alert.sound or ""), alert.combatOnly == true and "1" or "0"
            }, "~")
        end
    end
    table.sort(entries)
    return table.concat(entries, "|")
end

local function readBuffAlerts(value)
    local alerts = {}
    for entry in (value or ""):gmatch("[^|]+") do
        local idText, name, sound, combatOnly = entry:match("^(%d+)~([^~]*)~([^~]*)~([01])$")
        if not idText then
            idText, name, sound = entry:match("^(%d+)~([^~]*)~(.*)$")
            combatOnly = "0"
        end
        local spellID = tonumber(idText)
        name, sound = name and Backup.Decode(name), sound and Backup.Decode(sound)
        if not spellID or not name or #name > 80 or not sound or #sound > 240 then
            return nil, L("Invalid buff alert data.")
        end
        alerts[spellID] = { name = name, enabled = true, sound = sound ~= "" and sound or nil, combatOnly = combatOnly == "1" }
    end
    return alerts
end

local function customSoundValue(profile)
    local entries = {}
    for label, path in pairs(profile.customSounds or {}) do
        if type(label) == "string" and type(path) == "string" then
            entries[#entries + 1] = Backup.Encode(label) .. "~" .. Backup.Encode(path)
        end
    end
    table.sort(entries)
    return table.concat(entries, "|")
end

local function readCustomSounds(value)
    local sounds = {}
    for entry in (value or ""):gmatch("[^|]+") do
        local label, path = entry:match("^([^~]*)~(.*)$")
        label, path = label and Backup.Decode(label), path and Backup.Decode(path)
        if not label or label == "" or #label > 100 or not path or path == "" or #path > 240 then
            return nil, L("Invalid custom sound data.")
        end
        sounds[label] = path
    end
    return sounds
end

local function readValue(values, key, field)
    local value = values[key]
    if value == nil then return nil, L("Backup is missing %s.", key) end
    if Backup.booleans[field] then
        if value ~= "0" and value ~= "1" then return nil, L("Invalid %s.", key) end
        return value == "1"
    end
    local limits = Backup.numbers[field]
    if limits then
        local number = tonumber(value)
        if not number or number < limits[1] or number > limits[2]
            or (limits[3] and number % 1 ~= 0) then
            return nil, L("Invalid %s.", key)
        end
        return number
    end
    if #value > 150 or (Backup.choices[field] and not Backup.choices[field][value]) then
        return nil, L("Invalid %s.", key)
    end
    return value
end

function Backup.ExportProfile(source)
    local parts = { "FBF1" }
    local function add(key, value)
        parts[#parts + 1] = key .. "=" .. Backup.Encode(value)
    end
    for _, key in ipairs(Backup.exportFields) do add(key, source[key]) end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, key in ipairs(Backup.barFields) do add(kind .. "." .. key, source[kind][key]) end
    end
    add("alertBlacklist", blacklistValue(source))
    add("customDebuffTrackers", trackerValue(source))
    add("buffAlerts", buffAlertValue(source))
    add("customSounds", customSoundValue(source))
    return table.concat(parts, ";")
end

function Backup.ImportProfile(code)
    if type(code) ~= "string" or code:sub(1, 5) ~= "FBF1;" then
        return nil, L("This is not a ForeverBuffFrames backup code.")
    end
    local values = {}
    for part in code:gmatch("[^;]+") do
        local key, value = part:match("^([^=]+)=(.*)$")
        if key then values[key] = Backup.Decode(value) end
    end
    local restored = { buffs = {}, debuffs = {}, alertBlacklist = {} }
    for _, field in ipairs(Backup.fields) do
        local value, err
        if field == "debugAlerts" and values[field] == nil then
            value = false
        else
            value, err = readValue(values, field, field)
        end
        if err then return nil, err end
        restored[field] = value
    end
    for _, field in ipairs({ "debuffAwareness", "debuffPulse", "debuffBorderStyle" }) do
        if values[field] == nil then
            restored[field] = field == "debuffBorderStyle" and "border" or false
        else
            local value, err = readValue(values, field, field)
            if err then return nil, err end
            restored[field] = value
        end
    end
    for _, field in ipairs({ "debuffSoundsEnabled", "debuffSoundName", "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison" }) do
        if values[field] == nil then
            restored[field] = field == "debuffSoundsEnabled" and false or (restored.debuffSoundName or "default")
        else
            local value, err = readValue(values, field, field)
            if err then return nil, err end
            restored[field] = value
        end
    end
    for _, field in ipairs({ "debuffBorderThickness", "debuffPulseExpansion" }) do
        if values[field] == nil then
            restored[field] = field == "debuffBorderThickness" and 2 or 4
        else
            local value, err = readValue(values, field, field)
            if err then return nil, err end
            restored[field] = value
        end
    end
    for _, field in ipairs({ "buffRemovedSounds", "buffRemovalSound" }) do
        if values[field] == nil then
            restored[field] = field == "buffRemovedSounds" and false or "default"
        else
            local value, err = readValue(values, field, field)
            if err then return nil, err end
            restored[field] = value
        end
    end
    for _, field in ipairs({ "experimentalTTSEnabled", "experimentalTTSTarget", "experimentalTTSText" }) do
        if values[field] == nil then
            if field == "experimentalTTSEnabled" then restored[field] = false
            elseif field == "experimentalTTSTarget" then restored[field] = "Fire Shield"
            else restored[field] = "Fire Shield expired" end
        else
            local value, err = readValue(values, field, field)
            if err then return nil, err end
            restored[field] = value
        end
    end
    if values.experimentalTTSSpellID == nil then
        restored.experimentalTTSSpellID = 0
    else
        local value, err = readValue(values, "experimentalTTSSpellID", "experimentalTTSSpellID")
        if err then return nil, err end
        restored.experimentalTTSSpellID = value
    end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, field in ipairs(Backup.barFields) do
            local value, err
            if (field == "sort" or field == "untimed") and values[kind .. "." .. field] == nil then
                value = field == "sort" and "default" or "mixed"
            else
                value, err = readValue(values, kind .. "." .. field, field)
            end
            if err then return nil, err end
            restored[kind][field] = value
        end
    end
    local blacklist = values.alertBlacklist
    if blacklist == nil then return nil, L("Backup is missing the alert blacklist.") end
    if blacklist ~= "" and not blacklist:match("^%d+[,%d]*$") then
        return nil, L("Invalid alert blacklist.")
    end
    for id in blacklist:gmatch("%d+") do
        local number = tonumber(id)
        if number and number > 0 then restored.alertBlacklist[number] = true end
    end
    local trackers, trackerError = readTrackers(values.customDebuffTrackers)
    if not trackers then return nil, trackerError end
    restored.customDebuffTrackers = trackers
    local buffAlerts, buffAlertError = readBuffAlerts(values.buffAlerts)
    if not buffAlerts then return nil, buffAlertError end
    restored.learnedBuffAlerts = buffAlerts
    local customSounds, customSoundError = readCustomSounds(values.customSounds)
    if not customSounds then return nil, customSoundError end
    restored.customSounds = customSounds
    return restored
end

local function compactProfile(source)
    local values = {}
    -- Frame centers and minimap angles are saved as floating-point values by
    -- WoW, often with long tails such as 489.99993896484. Whole pixels/degrees
    -- are indistinguishable here and make shared recovery codes much shorter.
    local function compactNumber(key, value)
        if type(value) == "number" and (key == "x" or key == "y" or key == "minimapAngle") then
            return math.floor(value + 0.5)
        end
        return value
    end
    local function add(key, value) values[#values + 1] = Backup.Encode(compactNumber(key, value)) end
    for _, key in ipairs(Backup.exportFields) do add(key, source[key]) end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, key in ipairs(Backup.barFields) do add(key, source[kind][key]) end
    end
    add("alertBlacklist", blacklistValue(source))
    add("customDebuffTrackers", trackerValue(source))
    add("buffAlerts", buffAlertValue(source))
    add("customSounds", customSoundValue(source))
    return table.concat(values, ",")
end

-- All FBF3 compact layouts shipped before the current schema. The first had
-- neither sort nor untimed fields; the next added sort; the current has both.
local historicalBarFields = {
    { "x", "y", "size", "gapX", "gapY", "perRow", "rows", "grow", "timerSize", "countSize", "timerPos", "countPos", "font", "outline" },
    { "x", "y", "size", "gapX", "gapY", "perRow", "rows", "grow", "sort", "timerSize", "countSize", "timerPos", "countPos", "font", "outline" },
    Backup.barFields,
}
local baseProfileFields = { "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration" }
local awarenessProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle",
}
local sharedSoundProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle", "debuffSoundsEnabled", "debuffSoundName",
}
local typedSoundProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle", "debuffSoundsEnabled", "debuffSoundName",
    "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison",
}
local buffRemovalProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle", "debuffSoundsEnabled", "debuffSoundName",
    "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison",
    "debuffBorderThickness", "debuffPulseExpansion", "buffRemovedSounds",
}
local customRemovalSoundProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle", "debuffSoundsEnabled", "debuffSoundName",
    "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison",
    "debuffBorderThickness", "debuffPulseExpansion", "buffRemovedSounds", "buffRemovalSound",
}
local experimentalTTSNameProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle", "debuffSoundsEnabled", "debuffSoundName",
    "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison",
    "debuffBorderThickness", "debuffPulseExpansion", "buffRemovedSounds", "buffRemovalSound",
    "experimentalTTSEnabled", "experimentalTTSTarget", "experimentalTTSText",
}
local experimentalTTSProfileFields = {
    "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs", "expirationSounds", "alertSound", "onlyMyBuffs", "alertMinDuration",
    "debuffAwareness", "debuffPulse", "debuffBorderStyle", "debuffSoundsEnabled", "debuffSoundName",
    "debuffSoundMagic", "debuffSoundCurse", "debuffSoundDisease", "debuffSoundPoison",
    "debuffBorderThickness", "debuffPulseExpansion", "buffRemovedSounds", "buffRemovalSound",
    "experimentalTTSEnabled", "experimentalTTSTarget", "experimentalTTSText", "experimentalTTSSpellID",
}
local historicalSchemas = {}
for _, fields in ipairs({ baseProfileFields, Backup.fields }) do
    for _, bars in ipairs(historicalBarFields) do historicalSchemas[#historicalSchemas + 1] = { fields, bars } end
end
for _, fields in ipairs({ awarenessProfileFields, sharedSoundProfileFields, typedSoundProfileFields, buffRemovalProfileFields, customRemovalSoundProfileFields, experimentalTTSNameProfileFields, experimentalTTSProfileFields, Backup.exportFields }) do
    historicalSchemas[#historicalSchemas + 1] = { fields, Backup.barFields }
end

local function importCompactProfile(payload)
    local encoded = split(payload, ",")
    local layout, profileFields
    for _, schema in ipairs(historicalSchemas) do
        local fields, candidate = schema[1], schema[2]
        local extras = #encoded - (#fields + 2 * #candidate)
        if extras >= 1 and extras <= 4 then
            layout, profileFields = candidate, fields
            break
        end
    end
    if not layout then return nil, L("Invalid compact profile data.") end

    local parts, index = { "FBF1" }, 1
    local function add(key)
        parts[#parts + 1] = key .. "=" .. encoded[index]
        index = index + 1
    end
    for _, key in ipairs(profileFields) do add(key) end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, key in ipairs(layout) do add(kind .. "." .. key) end
    end
    add("alertBlacklist")
    if index <= #encoded then add("customDebuffTrackers") end
    if index <= #encoded then add("buffAlerts") end
    if index <= #encoded then add("customSounds") end
    return Backup.ImportProfile(table.concat(parts, ";"))
end

function Backup.Export(database)
    local parts = {
        "FBF3",
        "active=" .. Backup.Encode(database.activeProfile),
        "text=" .. Backup.Encode(database.uiTextSize or 0),
        "locale=" .. Backup.Encode(database.uiLocale or "auto"),
    }
    for _, name in ipairs(FBF.Profiles.SortedNames(database)) do
        parts[#parts + 1] = "p=" .. Backup.Encode(name) .. "~" .. compactProfile(database.profiles[name])
    end
    return table.concat(parts, ";")
end

local function importFBF3(code)
    local restored = { schemaVersion = 2, profiles = {} }
    for part in code:gmatch("[^;]+") do
        local active = part:match("^active=(.*)$")
        if active then restored.activeProfile = Backup.Decode(active) end
        local textSize = part:match("^text=(.*)$")
        if textSize then restored.uiTextSize = tonumber(Backup.Decode(textSize)) end
        local locale = part:match("^locale=(.*)$")
        if locale then restored.uiLocale = Backup.Decode(locale) end
        local encodedName, payload = part:match("^p=([^~]+)~(.*)$")
        if encodedName then
            local name, nameError = FBF.Profiles.ValidName(Backup.Decode(encodedName))
            if not name then return nil, nameError end
            if restored.profiles[name] then return nil, L("The backup contains duplicate profile names.") end
            local profile, profileError = importCompactProfile(payload)
            if not profile then return nil, L("Profile %s: %s", name, profileError) end
            restored.profiles[name] = profile
        end
    end
    local count = 0
    for _ in pairs(restored.profiles) do count = count + 1 end
    if count < 1 or count > 50 then return nil, L("Invalid profile count in backup.") end
    if type(restored.uiTextSize) ~= "number" or restored.uiTextSize % 1 ~= 0
        or restored.uiTextSize < 0 or restored.uiTextSize > 4 then
        restored.uiTextSize = 0
    end
    if not FBF.Locale.IsSupported(restored.uiLocale) then restored.uiLocale = "auto" end
    if not restored.profiles[restored.activeProfile] then
        return nil, L("The backup's active profile is missing.")
    end
    return restored, false
end

local function importFBF2(code)
    local values = {}
    for part in code:gmatch("[^;]+") do
        local key, value = part:match("^([^=]+)=(.*)$")
        if key then values[key] = Backup.Decode(value) end
    end
    local count = tonumber(values.count)
    if not count or count % 1 ~= 0 or count < 1 or count > 50 then
        return nil, L("Invalid profile count in backup.")
    end
    local restored = { schemaVersion = 2, profiles = {}, activeProfile = values.active }
    for index = 1, count do
        local name, err = FBF.Profiles.ValidName(values["profile" .. index .. ".name"])
        if not name then return nil, err end
        if restored.profiles[name] then return nil, L("The backup contains duplicate profile names.") end
        local profile, profileError = Backup.ImportProfile(values["profile" .. index .. ".data"] or "")
        if not profile then return nil, L("Profile %s: %s", name, profileError) end
        restored.profiles[name] = profile
    end
    if not restored.profiles[restored.activeProfile] then
        return nil, L("The backup's active profile is missing.")
    end
    return restored, false
end

function Backup.Import(code)
    if type(code) == "string" and code:sub(1, 5) == "FBF1;" then
        local profile, err = Backup.ImportProfile(code)
        if not profile then return nil, err end
        return { profiles = { Default = profile }, activeProfile = "Default" }, true
    end
    if type(code) == "string" and code:sub(1, 5) == "FBF3;" then return importFBF3(code) end
    if type(code) == "string" and code:sub(1, 5) == "FBF2;" then return importFBF2(code) end
    return nil, L("This is not a ForeverBuffFrames backup code.")
end
