local _, FBF = ...
local L = FBF.L

function FBF.CreateAlerts(getDB, report, playAlertSound, refreshOptions)
    local watchedAuras = {}
    local recentFires = {}
    -- Aura names follow the game client locale, independently of the optional
    -- ForeverBuffFrames display-language override.
    local quietBuffNames = FBF.Locale.QuietBuffNames()
    local service = {}

    function service.Reset()
        watchedAuras = {}
    end

    local function announce(watch)
        local signature = tostring(watch.spellID) .. ":" .. tostring(math.floor(watch.expirationTime + 0.5))
        local now = GetTime()
        if recentFires[signature] and now - recentFires[signature] < 2 then return end
        recentFires[signature] = now
        if RaidNotice_AddMessage and RaidWarningFrame then
            RaidNotice_AddMessage(RaidWarningFrame, L("%s expires in 10 seconds", watch.name), (ChatTypeInfo and ChatTypeInfo.RAID_WARNING) or { r = 1, g = 0, b = 0 })
        end
        playAlertSound()
        watch.fired = true
    end

    function service.Sync()
        local db = getDB()
        if not db or InCombatLockdown() then return end
        if not db.expirationSounds then
            service.Reset()
            return
        end
        if not C_UnitAuras or not C_UnitAuras.GetUnitAuras then return end
        local ok, auras = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
        if not ok or type(auras) ~= "table" then return end
        local currentAuras = {}
        for _, aura in ipairs(auras) do
            local spellID = aura.spellId or aura.spellID
            local quiet = db.alertBlacklist[spellID] or (type(aura.name) == "string" and quietBuffNames[aura.name:lower()])
            local eligible = not quiet and (not db.onlyMyBuffs or aura.sourceUnit == "player")
                and (db.alertMinDuration == 0 or (type(aura.duration) == "number" and aura.duration >= db.alertMinDuration))
            local expirationTime = aura.expirationTime
            local instanceID = aura.auraInstanceID
            if eligible and type(spellID) == "number" and type(instanceID) == "number"
                and type(expirationTime) == "number" and expirationTime > GetTime() then
                local previous = watchedAuras[instanceID]
                if previous and previous.expirationTime == expirationTime and previous.spellID == spellID then
                    currentAuras[instanceID] = previous
                elseif expirationTime > GetTime() + 10 then
                    local watch = { spellID = spellID, name = aura.name or tostring(spellID), expirationTime = expirationTime }
                    currentAuras[instanceID] = watch
                    local delay = expirationTime - GetTime() - 10
                    C_Timer.After(math.max(0, delay), function()
                        db = getDB()
                        if watchedAuras[instanceID] ~= watch or not db.expirationSounds then return end
                        if InCombatLockdown() then
                            return
                        end
                        if not C_UnitAuras.GetAuraDataByAuraInstanceID then return end
                        local found, active = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, "player", instanceID)
                        local activeSpellID = active and (active.spellId or active.spellID)
                        if not found or not active or activeSpellID ~= spellID
                            or type(active.expirationTime) ~= "number"
                            or math.abs(active.expirationTime - expirationTime) > 0.5
                            or expirationTime - GetTime() < 8.5 then
                            return
                        end
                        announce(watch)
                    end)
                end
            end
        end
        watchedAuras = currentAuras
    end

    function service.Handle(value)
        local db = getDB()
        local command = value:lower()
        if command == "sound" then
            local played = playAlertSound()
            report(L(played and "Test sound played." or (db.alertSound == "none" and "Alert sound is set to None." or "Test sound could not be played.")))
            return
        end
        if InCombatLockdown() then
            report(L("Change expiration sounds after combat."))
            return
        end
        if command ~= "on" and command ~= "off" then
            report(L("Use /fbf alert on, /fbf alert off, or /fbf alert sound."))
            return
        end
        db.expirationSounds = command == "on"
        service.Sync()
        refreshOptions()
        report(L(command == "on" and "10-second expiry alerts enabled." or "10-second expiry alerts disabled."))
    end

    function service.GetStatus()
        local watched = 0
        for _ in pairs(watchedAuras) do watched = watched + 1 end
        return { enabled = getDB().expirationSounds == true, watched = watched }
    end

    return service
end
