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
- Alert filters for caster, minimum duration, and individual spell IDs
- Interactive test icons and a fifteen-second alert preview
- Minimap button and `/fbf` commands
- Manual backup and recovery codes, including older-code compatibility
- Localized settings and runtime messages for English, German, Spanish, Latin American Spanish, French, Italian, Brazilian Portuguese, Russian, Korean, Simplified Chinese, and Traditional Chinese

## Important beta behavior

The Forever beta may currently lose addon saved variables after a reload or restart. ForeverBuffFrames includes a **Backup / Recovery** tab so you can copy your complete profile collection into a text file and restore it later. See [RECOVERY.md](RECOVERY.md) for the short walkthrough.

Live expiration alerts rely on aura information that the beta client does not expose to addons during combat. A warning already scheduled outside combat is skipped if it becomes due during combat. Test alerts remain available outside combat.

## Installation

1. Extract the download so the resulting path is `Interface/AddOns/ForeverBuffFrames/ForeverBuffFrames.toc`.
2. Start or restart World of Warcraft: Forever.
3. Open settings with `/fbf config` or the minimap button.

## Commands

- `/fbf config` — open the settings window
- `/fbf unlock` — unlock both aura bars for dragging
- `/fbf lock` — lock both aura bars
- `/fbf test` — show or hide test icons
- `/fbf alert on` — enable ten-second expiration alerts
- `/fbf alert off` — disable expiration alerts
- `/fbf alert sound` — play the selected alert sound
- `/fbf` — display current status and command help

Most customization is easier through the settings window.

## Feedback

ForeverBuffFrames is in worldwide beta testing. Please report reproducible problems through the [GitHub issue tracker](https://github.com/Wyveryx/ForeverBuffFrames/issues) and include the client build, selected language, steps to reproduce, and the complete Lua error when applicable.

## License

Copyright © 2026 Wyveryx. All rights reserved. See [LICENSE](LICENSE).
