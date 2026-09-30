local _, FBF = ...

function FBF.CreateBuffRemovalSounds(getProfile, soundSource)
    local registrations, pending = { always = {}, combat = {} }, false
    local status = { state = "Disabled", registered = 0, learned = 0, combatRegistered = 0,
        combatAttempts = 0, lastCombatRegistered = 0, lastFailure = nil }
    local quietBuffNames = FBF.Locale.QuietBuffNames()
    local service = {}

    local function updateRegisteredCount()
        status.registered = #registrations.always + #registrations.combat
        status.combatRegistered = #registrations.combat
    end

    local function clearRegistrations(kind)
        if C_UnitAuras and C_UnitAuras.RemoveAuraSound then
            if kind then
                for _, id in ipairs(registrations[kind]) do pcall(C_UnitAuras.RemoveAuraSound, id) end
            else
                for _, list in pairs(registrations) do
                    for _, id in ipairs(list) do pcall(C_UnitAuras.RemoveAuraSound, id) end
                end
            end
        end
        if kind then wipe(registrations[kind]) else wipe(registrations.always); wipe(registrations.combat) end
        updateRegisteredCount()
    end

    local function nativeSoundInfo(name)
        if name == "none" then return nil end
        local source = soundSource(name)
        if type(source) == "string" then return { soundFileName = source } end
        if name == "default" and type(source) == "number" then return { soundFileID = source } end
        -- SoundKit identifiers cannot be passed to AddAuraSound's file-ID
        -- field. Use FBF's file-backed warning for native combat playback.
        return { soundFileID = FBF.SOUND_FILE_ID }
    end

    local function registerKind(kind)
        local profile = getProfile()
        clearRegistrations(kind)
        if not profile.buffRemovedSounds then updateRegisteredCount(); return true end
        if not (C_UnitAuras and C_UnitAuras.AddAuraSound and Enum and Enum.UnitAuraSoundTrigger) then
            status.state = "Unavailable"
            return false
        end
        local removed = Enum.UnitAuraSoundTrigger.Removed
        for spellID, learnedAura in pairs(profile.learnedBuffAlerts or {}) do
            local eligible = learnedAura.enabled == true and not profile.alertBlacklist[spellID]
                and ((kind == "combat") == (learnedAura.combatOnly == true))
                and (not profile.onlyMyBuffs or learnedAura.mine)
                and (profile.alertMinDuration == 0 or (learnedAura.duration or 0) >= profile.alertMinDuration)
            if eligible then
                local sound = nativeSoundInfo(learnedAura.sound or profile.buffRemovalSound or "default")
                if sound then
                    local info = FBF.CopyTable(sound)
                    info.unitToken, info.spellID, info.outputChannel = "player", spellID, "Master"
                    local ok, id = pcall(C_UnitAuras.AddAuraSound, removed, info)
                    if ok and id then registrations[kind][#registrations[kind] + 1] = id
                    else status.lastFailure = tostring(id or "registration refused") end
                end
            end
        end
        updateRegisteredCount()
        return not status.lastFailure
    end

    function service.Sync()
        if InCombatLockdown() then pending = true; status.state = "Pending combat"; return false end
        pending = false
        clearRegistrations()
        status.lastFailure = nil
        local profile = getProfile()
        local learned = 0
        for _ in pairs(profile.learnedBuffAlerts or {}) do learned = learned + 1 end
        status.learned = learned
        if not profile.buffRemovedSounds then status.state = "Disabled"; return true end
        registerKind("always")
        status.state = status.lastFailure and "Registration warning" or "Available"
        return not status.lastFailure
    end

    function service.EnterCombat()
        status.combatAttempts = status.combatAttempts + 1
        status.lastFailure = nil
        local ok = registerKind("combat")
        status.lastCombatRegistered = #registrations.combat
        status.lastCombatFailure = ok and nil or status.lastFailure or "registration refused"
        status.state = ok and "Available" or "Combat registration refused"
        return ok
    end

    function service.Learn()
        if InCombatLockdown() or not (C_UnitAuras and C_UnitAuras.GetUnitAuras) then return false end
        local ok, auras = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
        if not ok or type(auras) ~= "table" then return false end
        local profile, changed = getProfile(), false
        profile.learnedBuffAlerts = profile.learnedBuffAlerts or {}
        for _, aura in ipairs(auras) do
            local spellID, duration = aura.spellId or aura.spellID, aura.duration
            local name, sourceUnit = aura.name, aura.sourceUnit
            local readable = not issecretvalue or (not issecretvalue(spellID) and not issecretvalue(duration)
                and not issecretvalue(name) and not issecretvalue(sourceUnit))
            local quiet = readable and type(name) == "string" and quietBuffNames[name:lower()]
            if readable and not quiet and type(spellID) == "number" and type(duration) == "number" and duration > 0 then
                local current = profile.learnedBuffAlerts[spellID]
                local mine = sourceUnit == "player"
                local class = select(2, UnitClass("player"))
                if type(current) ~= "table" or current.duration ~= duration or current.mine ~= mine or current.name ~= name then
                    profile.learnedBuffAlerts[spellID] = {
                        duration = duration, mine = mine, name = name or tostring(spellID),
                        enabled = current and current.enabled == true or false,
                        sound = current and current.sound or nil,
                        combatOnly = current and current.combatOnly == true or false,
                        classes = current and current.classes or {},
                    }
                    if class then profile.learnedBuffAlerts[spellID].classes[class] = true end
                    changed = true
                elseif class and not (current.classes and current.classes[class]) then
                    current.classes = current.classes or {}
                    current.classes[class] = true
                    changed = true
                end
            end
        end
        local count = 0
        for _ in pairs(profile.learnedBuffAlerts) do count = count + 1 end
        status.learned = count
        if changed then service.Sync() end
        return changed
    end

    function service.ClearLearned()
        if InCombatLockdown() then return false end
        wipe(getProfile().learnedBuffAlerts)
        status.learned = 0
        service.Sync()
        return true
    end

    function service.GetStatus()
        status.pending = pending
        return status
    end

    service.Shutdown = clearRegistrations
    return service
end
