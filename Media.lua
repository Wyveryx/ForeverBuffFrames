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
    { "fire-shield-test", "Fire Ward expired", "Interface\\AddOns\\ForeverBuffFrames\\CustomSounds\\Fire Shield.mp3" },
    { "poison-warning", "Poison warning", "Interface\\AddOns\\ForeverBuffFrames\\CustomSounds\\Poison.mp3" },
    { "amp-air-horn", "Alert pack: Air Horn", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\AirHorn.ogg" },
    { "amp-applause", "Alert pack: Applause", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\Applause.ogg" },
    { "amp-blast", "Alert pack: Blast", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\Blast.ogg" },
    { "amp-bleat", "Alert pack: Bleat", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\Bleat.ogg" },
    { "amp-boxing-gong", "Alert pack: Boxing Arena Gong", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\BoxingArenaSound.ogg" },
    { "amp-cartoon-baritone", "Alert pack: Cartoon Voice Baritone", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\CartoonVoiceBaritone.ogg" },
    { "amp-cartoon-walking", "Alert pack: Cartoon Walking", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\CartoonWalking.ogg" },
    { "amp-cat-meow", "Alert pack: Cat Meow", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\CatMeow2.ogg" },
    { "amp-cow-mooing", "Alert pack: Cow Mooing", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\CowMooing.ogg" },
    { "amp-heartbeat", "Alert pack: Heartbeat Single", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\HeartbeatSingle.ogg" },
    { "amp-kitten-meow", "Alert pack: Kitten Meow", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\KittenMeow.ogg" },
    { "amp-healer-trinket", "Alert pack: Lossa Healer Trinket", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\LossaHealerTrinket.ogg" },
    { "amp-trinket", "Alert pack: Lossa Trinket", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\LossaTrinket.ogg" },
    { "amp-ringing-phone", "Alert pack: Ringing Phone", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\RingingPhone.ogg" },
    { "amp-roaring-lion", "Alert pack: Roaring Lion", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\RoaringLion.ogg" },
    { "amp-robot-blip", "Alert pack: Robot Blip", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\RobotBlip.ogg" },
    { "amp-shotgun", "Alert pack: Shotgun", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\Shotgun.ogg" },
    { "amp-temple-bell", "Alert pack: Temple Bell", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\TempleBellHuge.ogg" },
    { "amp-torch", "Alert pack: Torch", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\Torch.ogg" },
    { "amp-warning-siren", "Alert pack: Warning Siren", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\WarningSiren.ogg" },
    { "amp-water-drop", "Alert pack: Water Drop", "Interface\\AddOns\\ForeverBuffFrames\\Media\\AlertSounds\\WaterDrop.ogg" },
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
    if type(name) == "string" and name:sub(1, 5) == "file:" then
        local path = name:sub(6)
        return path ~= "" and path or nil
    end
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
            if type(entry[3]) == "string"
                and (entry[3]:find("\\", 1, true) or entry[3]:find("/", 1, true)) then
                return entry[3]
            end
            return SOUNDKIT and SOUNDKIT[entry[3]]
        end
    end
    return FBF.SOUND_FILE_ID
end
