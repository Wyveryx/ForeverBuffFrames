local _, FBF = ...
local L = FBF.L

FBF.Profiles = {}
local Profiles = FBF.Profiles

function Profiles.ValidName(name)
    name = type(name) == "string" and name:match("^%s*(.-)%s*$") or ""
    if name == "" then return nil, L("Enter a profile name.") end
    if #name > 32 then return nil, L("Profile names can use at most 32 characters.") end
    if name:find("[%c;=]") then
        return nil, L("Profile names cannot contain control characters, semicolons, or equals signs.")
    end
    return name
end

function Profiles.SortedNames(database)
    local names = {}
    for name in pairs(database.profiles) do names[#names + 1] = name end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

function Profiles.InitializeDatabase(saved)
    saved = type(saved) == "table" and saved or {}
    if type(saved.profiles) ~= "table" then
        saved = {
            schemaVersion = 2,
            activeProfile = "Default",
            profiles = { Default = FBF.InitializeProfile(FBF.CopyTable(saved)) },
        }
    end
    saved.schemaVersion = 2
    if type(saved.uiTextSize) ~= "number" or saved.uiTextSize % 1 ~= 0
        or saved.uiTextSize < 0 or saved.uiTextSize > 4 then
        saved.uiTextSize = 0
    end
    if not FBF.Locale.IsSupported(saved.uiLocale) then saved.uiLocale = "auto" end
    if next(saved.profiles) == nil then saved.profiles.Default = FBF.InitializeProfile({}) end
    if type(saved.activeProfile) ~= "string" or not saved.profiles[saved.activeProfile] then
        saved.activeProfile = Profiles.SortedNames(saved)[1]
    end
    for name, profile in pairs(saved.profiles) do
        if Profiles.ValidName(name) then
            saved.profiles[name] = FBF.InitializeProfile(profile)
        else
            saved.profiles[name] = nil
        end
    end
    if next(saved.profiles) == nil then
        saved.profiles.Default = FBF.InitializeProfile({})
        saved.activeProfile = "Default"
    elseif not saved.profiles[saved.activeProfile] then
        saved.activeProfile = Profiles.SortedNames(saved)[1]
    end
    return saved
end
