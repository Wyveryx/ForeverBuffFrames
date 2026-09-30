local _, FBF = ...

local TYPES = { Magic = true, Curse = true, Disease = true, Poison = true }

function FBF.CreateDebuffSounds(getProfile, report, soundSource)
    local registrations, pending = {}, false
    local status = { state = "Disabled", registered = 0, learned = 0, seed = 0, custom = 0, lastFailure = nil }

    local function clearRegistrations()
        if C_UnitAuras and C_UnitAuras.RemoveAuraSound then
            for _, id in ipairs(registrations) do pcall(C_UnitAuras.RemoveAuraSound, id) end
        end
        wipe(registrations)
        status.registered = 0
    end

    local function soundInfo(name)
        if name == "none" then return nil end
        local source = soundSource(name)
        if type(source) == "string" then return { soundFileName = source } end
        if name == "default" and type(source) == "number" then return { soundFileID = source } end
        return nil
    end

    local function combinedSpells()
        local result = {}
        local _, clientBuild = GetBuildInfo()
        if tostring(clientBuild) == FBF.DebuffSoundLibrary.build:match("(%d+)$") then
            for spellID, kind in pairs(FBF.DebuffSoundLibrary.spells) do
                if type(spellID) == "number" and TYPES[kind] then result[spellID] = { kind = kind } end
            end
        end
        for spellID, kind in pairs(getProfile().learnedDebuffs or {}) do
            if type(spellID) == "number" and TYPES[kind] then result[spellID] = { kind = kind } end
        end
        for spellID, tracker in pairs(getProfile().customDebuffTrackers or {}) do
            if type(spellID) == "number" and type(tracker) == "table" then
                if tracker.enabled ~= false then result[spellID] = { sound = tracker.sound or "default" } end
            end
        end
        return result
    end

    local function sync()
        if InCombatLockdown() then pending = true; status.state = "Pending combat"; return false end
        pending = false
        clearRegistrations()
        status.lastFailure = nil
        local profile = getProfile()
        local learned = 0
        for _ in pairs(profile.learnedDebuffs or {}) do learned = learned + 1 end
        status.learned = learned
        local custom = 0
        for _ in pairs(profile.customDebuffTrackers or {}) do custom = custom + 1 end
        status.custom = custom
        if not profile.debuffSoundsEnabled then status.state = "Disabled"; return true end
        if not (C_UnitAuras and C_UnitAuras.AddAuraSound and Enum and Enum.UnitAuraSoundTrigger) then
            status.state = "Unavailable"; return false
        end
        local added = Enum.UnitAuraSoundTrigger.Added
        for spellID, entry in pairs(combinedSpells()) do
            local info = soundInfo(entry.sound or profile.debuffSounds[entry.kind])
            if info then
                info.unitToken, info.spellID, info.outputChannel = "player", spellID, "Master"
                local ok, id = pcall(C_UnitAuras.AddAuraSound, added, info)
                if ok and id then registrations[#registrations + 1] = id
                else status.lastFailure = tostring(id or "registration refused") end
            end
        end
        status.registered = #registrations
        status.state = status.lastFailure and "Registration warning" or "Available"
        return true
    end

    local function learn()
        if InCombatLockdown() or not (C_UnitAuras and C_UnitAuras.GetUnitAuras) then return false end
        local ok, auras = pcall(C_UnitAuras.GetUnitAuras, "player", "HARMFUL")
        if not ok or type(auras) ~= "table" then return false end
        local profile, changed = getProfile(), false
        profile.learnedDebuffs = profile.learnedDebuffs or {}
        for _, aura in ipairs(auras) do
            local spellID, kind = aura.spellId or aura.spellID, aura.dispelName
            local readable = not issecretvalue or (not issecretvalue(spellID) and not issecretvalue(kind))
            if readable and type(spellID) == "number" and TYPES[kind] and profile.learnedDebuffs[spellID] ~= kind then
                profile.learnedDebuffs[spellID], changed = kind, true
            end
        end
        local count = 0
        for _ in pairs(profile.learnedDebuffs) do count = count + 1 end
        status.learned = count
        if changed then sync() end
        return changed
    end

    local _, clientBuild = GetBuildInfo()
    if tostring(clientBuild) == FBF.DebuffSoundLibrary.build:match("(%d+)$") then
        for _ in pairs(FBF.DebuffSoundLibrary.spells) do status.seed = status.seed + 1 end
    end
    return {
        Sync = sync,
        Learn = learn,
        ClearLearned = function()
            if InCombatLockdown() then return false end
            wipe(getProfile().learnedDebuffs)
            status.learned = 0
            sync()
            return true
        end,
        GetStatus = function() status.pending = pending; return status end,
        Test = function(kind)
            local name = getProfile().debuffSounds[kind or "Magic"]
            local source = soundSource(name)
            if not source then return false end
            if type(source) == "number" then
                return name == "default" and PlaySoundFile(source, "Master") or PlaySound(source, "Master")
            end
            return PlaySoundFile(source, "Master")
        end,
        TestSound = function(name)
            local source = soundSource(name)
            if not source then return false end
            if type(source) == "number" then
                return name == "default" and PlaySoundFile(source, "Master") or PlaySound(source, "Master")
            end
            return PlaySoundFile(source, "Master")
        end,
        Shutdown = clearRegistrations,
    }
end
