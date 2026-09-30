# ForeverBuffFrames

ForeverBuffFrames provides movable, configurable player buff and debuff bars for **World of Warcraft: Forever**. It keeps the familiar aura-icon presentation while giving each bar independent layout and text controls.

This release targets the Forever beta client (`Interface 16001`).

## Features

- Separate buff and debuff bars with independent positions and layouts
- Drag either bar directly while it is unlocked
- Configurable icon size, spacing, rows, growth direction, and aura ordering
- Configurable timer and stack text, including font, size, position, and outline
- Optional placement of known unlimited-duration auras on either side
- Named profiles with create, copy, rename, switch, and delete controls
- Optional hiding of Blizzard's original player buff and debuff frames
- Ten-second buff-expiration sound and raid-warning alerts
- Optional per-buff native sounds when selected learned buffs are removed, including during combat
- Twenty-one bundled alert recordings with preserved open-license attribution
- Alert filters for caster, minimum duration, and individual spell IDs
- Interactive test icons and a fifteen-second alert preview
- A Diagnostics tab with explicit preview controls, capability status, and a copyable support report
- Optional Blizzard-native debuff-type borders with three presentation styles and pulsing
- Experimental combat-safe debuff sounds that learn exact Magic, Curse, Disease, and Poison spell IDs while aura data is readable outside combat
- Independent debuff-type sound choices, including optional LibSharedMedia sounds and user-supplied files already present when WoW starts
- Searchable, scrollable build-matched debuff library with one-click Personal Tracker controls
- Minimap button and `/fbf` commands
- Manual backup and recovery codes, including older-code compatibility
- Localized settings and runtime messages for English, German, Spanish, Latin American Spanish, French, Italian, Brazilian Portuguese, Russian, Korean, Simplified Chinese, and Traditional Chinese

## Important beta behavior

The Forever beta may currently lose addon saved variables after a reload or restart. ForeverBuffFrames includes a **Backup / Recovery** tab so you can copy your complete profile collection into a text file and restore it later. See [RECOVERY.md](RECOVERY.md) for the short walkthrough.

Ten-second expiration alerts use ordinary aura timing and therefore run outside combat. The separate buff-removal option uses Blizzard's exact-spell sound registration: ForeverBuffFrames learns eligible timed player buffs while aura data is readable, then lets you enable and assign a recording to each buff before combat. Blizzard plays the chosen sound when that buff is removed. A buff first encountered during restricted combat must be learned outside combat before it can be selected. Removal sounds fire after the effect is gone; they are not an advance warning.

The Buff Alerts page opens a dedicated **Manage specific buff alerts** window. Every learned buff has an **Alert** checkbox, a sound selector on the same row, and a Preview button. Enable only the buffs that need removal alerts. To add recordings, close WoW, copy `.ogg` or `.mp3` files into `ForeverBuffFrames/CustomSounds`, restart the client, and add each relative path (for example `CustomSounds\\fire-ward.ogg`) at the top of the manager. Added files then appear in every combat-safe sound selector.

The manager scans the logged-in character's spellbook and normally shows learned buffs relevant to that character. Buffs actually observed on that class and all enabled assignments also remain visible. **Show all characters** reveals the complete profile-wide learned catalog for configuring group buffs or another character. Spellbook scanning deliberately does not treat every ability as a buff; an aura still needs to be observed once before FBF knows it is a valid timed buff.

Each enabled buff can optionally use **Combat only**. This experimental mode asks the Forever client to add that buff's native removal-sound registration when combat begins, then removes it after combat. Diagnostics reports how many combat-only registrations the client accepted.

Enabled sound-pack addons that register real audio filenames through LibSharedMedia are also listed automatically. Ordinary Blizzard SoundKit effects may appear in non-combat sound selectors but are intentionally excluded from combat-removal assignments because the native aura API requires an audio filename or file ID rather than a SoundKit event ID.

ForeverBuffFrames includes a redistributable subset of SharedMedia: AlertMediaPack so users have combat-compatible choices without installing another addon. Licensing and attribution are retained in `Media/AlertSounds/NOTICE.md` and its `Licenses` directory.

Debuff sounds use Blizzard's exact-spell registration API. ForeverBuffFrames learns dispellable debuff IDs when they are visible outside combat, then registers those known IDs for combat-safe playback. A debuff first encountered while aura data is restricted may therefore remain silent until the addon has learned it outside combat. The learned list is a rebuildable profile cache and is not included in manual recovery codes.

The Debuff Alerts page can choose a separate sound for each dispel type. LibSharedMedia sounds appear automatically when that library is supplied by another enabled addon. For a standalone custom sound, close WoW, place an `.ogg` or `.mp3` file in `ForeverBuffFrames/CustomSounds`, restart the client, and enter a path such as `CustomSounds/my-sound.ogg` in the desired row.

The Debuff Library is generated from build-matched Forever client tables and records its source and build in the addon. The current catalog contains spells explicitly marked as negative auras with Magic, Curse, Disease, or Poison classifications. Names, icons, and descriptions are resolved from the running client when available. Catalog entries are candidates until confirmed in play; the out-of-combat learner continues to supplement client data with debuffs actually observed on the player. Personal Tracker selections are included in new manual backup codes.

## Installation

1. Extract the download so the resulting path is `Interface/AddOns/ForeverBuffFrames/ForeverBuffFrames.toc`.
2. Start or restart World of Warcraft: Forever.
3. Open settings with `/fbf config` or the minimap button.

## Commands

- `/fbf config` — open the settings window
- `/fbf debug` — open the Diagnostics tab
- `/fbf unlock` — unlock both aura bars for dragging
- `/fbf lock` — lock both aura bars
- `/fbf test` — show or hide test icons
- `/fbf alert on` — enable ten-second expiration alerts
- `/fbf alert off` — disable expiration alerts
- `/fbf alert sound` — play the selected alert sound
- `/fbf` — display current status and command help

Most customization is easier through the settings window.

Opening Diagnostics is read-only. Test sounds, sample icons, retries, and future experimental probes run only when you press their controls.

## Feedback

ForeverBuffFrames is in worldwide beta testing. Please report reproducible problems through the [GitHub issue tracker](https://github.com/Wyveryx/ForeverBuffFrames/issues) and include the client build, selected language, steps to reproduce, and the complete Lua error when applicable.

## License

ForeverBuffFrames code and original artwork are copyright © 2026 Wyveryx. See [LICENSE](LICENSE).

### Bundled-media credits

The bundled open-license alert library is derived from **SharedMedia: AlertMediaPack 1.0.2** by Anahkas / Alert Media Pack contributors. It includes selected recordings originating from WeakAuras and sArena Reloaded under CC0 1.0, CC BY 3.0, or MIT terms. Creator-level attribution and complete license texts ship in [`Media/AlertSounds`](Media/AlertSounds/NOTICE.md). These third-party files remain governed by their respective licenses rather than ForeverBuffFrames' primary license.
