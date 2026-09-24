local _, FBF = ...

FBF.SOUND_FILE_ID = 567397
FBF.builtinFonts = {
    { "default", "Default", STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF" },
    { "unit", "Unit name", UNIT_NAME_FONT },
    { "damage", "Damage", DAMAGE_TEXT_FONT },
    { "narrow", "Arial Narrow", "Fonts\\ARIALN.TTF" },
    { "morpheus", "Morpheus", "Fonts\\MORPHEUS.TTF" },
    { "skurri", "Skurri", "Fonts\\SKURRI.TTF" },
}
FBF.builtinSounds = {
    { "default", "Original warning", FBF.SOUND_FILE_ID },
    { "raid", "Raid warning", "RAID_WARNING" },
    { "ready", "Ready check", "READY_CHECK" },
    { "level", "Level up", "LEVELUP" },
    { "quest", "Quest complete", "QUEST_COMPLETE" },
    { "tell", "Whisper", "TELL_MESSAGE" },
}

function FBF.SharedMedia()
    return LibStub and LibStub("LibSharedMedia-3.0", true)
end

function FBF.FontPath(name)
    if type(name) == "string" and name:sub(1, 4) == "lsm:" then
        local media = FBF.SharedMedia()
        if media then
            local path = media:Fetch("font", name:sub(5), true)
            if path then return path end
        end
    end
    for _, entry in ipairs(FBF.builtinFonts) do
        if entry[1] == name then return entry[3] end
    end
    return FBF.builtinFonts[1][3]
end

function FBF.SoundSource(name)
    if name == "none" then return nil end
    if type(name) == "string" and name:sub(1, 4) == "lsm:" then
        local media = FBF.SharedMedia()
        if media then
            local path = media:Fetch("sound", name:sub(5), true)
            if path then return path end
        end
        return FBF.SOUND_FILE_ID
    end
    for _, entry in ipairs(FBF.builtinSounds) do
        if entry[1] == name then
            if type(entry[3]) == "number" then return entry[3] end
            return SOUNDKIT and SOUNDKIT[entry[3]]
        end
    end
    return FBF.SOUND_FILE_ID
end
