local _, FBF = ...
local L = FBF.L

-- Backup owns every on-disk backup format. Keep the field order append-only:
-- FBF3 compact profiles are positional and old codes depend on these layouts.
local Backup = {
    fields = {
        "minimapAngle", "showMinimap", "hideBlizzardBuffs", "hideBlizzardDebuffs",
        "expirationSounds", "alertSound", "onlyMyBuffs", "debugAlerts", "alertMinDuration",
    },
    barFields = {
        "x", "y", "size", "gapX", "gapY", "perRow", "rows", "grow",
        "sort", "untimed", "timerSize", "countSize", "timerPos", "countPos", "font", "outline",
    },
    booleans = {
        showMinimap = true, hideBlizzardBuffs = true, hideBlizzardDebuffs = true,
        expirationSounds = true, onlyMyBuffs = true, debugAlerts = true,
    },
    numbers = {
        minimapAngle = { -3600, 3600 }, alertMinDuration = { 0, 3600, true },
        x = { -10000, 10000 }, y = { -10000, 10000 },
        size = { 16, 96, true }, gapX = { 0, 32, true }, gapY = { 0, 32, true },
        perRow = { 1, 20, true }, rows = { 1, 10, true },
        timerSize = { 6, 36, true }, countSize = { 6, 36, true },
    },
    choices = {
        grow = { left = true, right = true },
        sort = { default = true, shortest = true, longest = true },
        untimed = { mixed = true, untimedleft = true, untimedright = true },
        timerPos = { below = true, above = true, center = true },
        countPos = { bottomright = true, bottomleft = true, topright = true, topleft = true },
        outline = { none = true, outline = true, thick = true },
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
    for _, key in ipairs(Backup.fields) do add(key, source[key]) end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, key in ipairs(Backup.barFields) do add(kind .. "." .. key, source[kind][key]) end
    end
    add("alertBlacklist", blacklistValue(source))
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
        local value, err = readValue(values, field, field)
        if err then return nil, err end
        restored[field] = value
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
    for _, key in ipairs(Backup.fields) do add(key, source[key]) end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, key in ipairs(Backup.barFields) do add(key, source[kind][key]) end
    end
    add("alertBlacklist", blacklistValue(source))
    return table.concat(values, ",")
end

-- All FBF3 compact layouts shipped before the current schema. The first had
-- neither sort nor untimed fields; the next added sort; the current has both.
local historicalBarFields = {
    { "x", "y", "size", "gapX", "gapY", "perRow", "rows", "grow", "timerSize", "countSize", "timerPos", "countPos", "font", "outline" },
    { "x", "y", "size", "gapX", "gapY", "perRow", "rows", "grow", "sort", "timerSize", "countSize", "timerPos", "countPos", "font", "outline" },
    Backup.barFields,
}

local function importCompactProfile(payload)
    local encoded = split(payload, ",")
    local layout
    for _, candidate in ipairs(historicalBarFields) do
        if #encoded == #Backup.fields + 2 * #candidate + 1 then
            layout = candidate
            break
        end
    end
    if not layout then return nil, L("Invalid compact profile data.") end

    local parts, index = { "FBF1" }, 1
    local function add(key)
        parts[#parts + 1] = key .. "=" .. encoded[index]
        index = index + 1
    end
    for _, key in ipairs(Backup.fields) do add(key) end
    for _, kind in ipairs({ "buffs", "debuffs" }) do
        for _, key in ipairs(layout) do add(kind .. "." .. key) end
    end
    add("alertBlacklist")
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
