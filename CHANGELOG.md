# Changelog

## 0.9.10-beta.1 — Unreleased

- Added one optional magnifying-glass tracking selector fixed at the physical far right of the buff bar.
- Removed the redundant second tracking icon; the selected native tracking buff now appears in the ordinary buff slots.
- Populated the selector with class, profession, and racial tracking abilities, including hunter creature tracking, while excluding bankers, mailboxes, innkeepers, quest filters, and other general points of interest.
- Selecting a tracker disables the other supported trackers so only the chosen tracking buff is added to the bar.
- Reserved a full-size selector slot inside the buff holder so the movable outline and drag handle include it without overlapping left-growing auras.
- Replaced the padded quick-slot artwork with a full-edge icon border so the magnifier uses the same visual footprint as neighboring buffs.
- Applied Blizzard's rounded action-icon mask and frame to match the corner treatment of the aura icons.
- Standardized dropdown row height, padding, selected-state insets, selector height, and popup elevation across the configuration interface.
- Added safe right padding to Debuff Sound custom-file rows, kept Personal Trackers inside the responsive content pane, and capped the long default-removal selector within its Alerts column.
- Added profile and manual backup support for the tracking-control visibility setting.

## 0.9.9-beta.1 — 2026-09-30

- Added an experimental per-buff Combat only mode for native removal sounds.
- Combat-only registrations are attempted when combat begins and removed after combat; always-on registrations remain independent.
- Added diagnostic reporting for the number of combat-only registrations accepted by the client.
- Credited SharedMedia: AlertMediaPack and every retained upstream audio license in the public release documentation.

## 0.9.8-beta.1 — Unreleased

- Added a current-character spellbook scan to prioritize learned buffs relevant to the logged-in class.
- Added a Show all characters option so group buffs and cross-character assignments remain available without cluttering the default list.
- Kept enabled alerts visible even when the assigned buff is not in the current character's spellbook.

## 0.9.7-beta.1 — Unreleased

- Bundled 21 redistributable recordings from SharedMedia: AlertMediaPack for immediate use in expiry, debuff, and per-buff combat-removal selectors.
- Preserved the source pack's CC0, CC-BY 3.0, MIT, and upstream attribution documents.
- Excluded seven author-provided recordings whose downstream redistribution permission was not explicit.

## 0.9.6-beta.1 — Unreleased

- Removed the unsuccessful experimental CDM text-to-speech hooks and controls.
- Added searchable, per-buff combat-removal alert assignments for learned timed buffs.
- Moved per-buff assignments into a clearly labeled manager with explicit Alert, Sound, and Preview controls on every row.
- Changed newly learned buffs to opt-in so unrelated abilities do not inherit a removal warning automatically.
- Added a custom sound-file registry for additional `.ogg` and `.mp3` recordings and kept the ten-second warning independent.

## 0.9.5-beta.1 — Unreleased

- Added an isolated experimental CDM text-to-speech probe with editable target spell and personalized spoken text.
- Added an out-of-combat TTS preview and combat counters for CDM aura-removal events, target matches, and successful speech calls.
- Kept experimental TTS opt-in and separate from the proven native prerecorded removal-sound path.
- Changed the probe target from a localized spell name to an exact Spell ID, matching CDM base, active, aura, and linked IDs for override compatibility.
- Fixed the experimental target resolver so a buff learned after login can populate its Spell ID instead of remaining at zero.
- Moved the TTS probe below CDM's optional alert dispatcher to its aura-instance removal hook after testing showed the dispatcher is not invoked without a functioning CDM alert.
- Hooked the category-specific CDM item mixins as well as the base mixin; Blizzard copies methods into Essential, Utility, and aura item implementations before addons can attach hooks.
- Added the earlier CDM unit-aura removal entry point to the probe, with path diagnostics and duplicate-speech suppression.

## 0.9.4-beta.1 — Unreleased

- Added an independent, combat-compatible buff-removal sound selector with in-list previews.
- Added the supplied Fire Shield voice recording as the first custom combat-removal test option.
- Kept the ten-second warning sound separate so testing a removal voice does not change its audio.
- Fixed bundled file-backed sounds being mistaken for Blizzard SoundKit names and hidden from the combat-removal picker.

## 0.9.3-beta.1 — Unreleased

- Added optional Blizzard-native buff-removal sounds that work during combat for exact buff IDs learned while aura data is readable.
- Kept the existing accurate ten-second warning as an outside-combat feature and clearly separated it from the new after-removal combat sound.
- Applied the existing caster, minimum-duration, blacklist, and alert-sound choices to native buff-removal registrations.
- Added learned and registered buff-removal counts to Diagnostics and manual backup support for the new enable setting.
- Removed the experimental Cooldown Manager timing bridge after client testing confirmed its aura timing remains secret to addon code during combat.

## 0.9.2-beta.1 — Unreleased

- Added a searchable, scrollable debuff library generated from negative, typed aura records in WoW Forever client build `1.60.1.70009`.
- Added localized in-client spell names, icons, and descriptions when the client can resolve them, with build-data fallbacks.
- Added check and X controls that add or remove catalog entries from Personal Trackers without opening the manual editor.
- Kept automatic combat-sound registration conservative: catalog entries register when selected, while observed debuffs continue to be learned outside combat.
- Added Personal Trackers to new manual backup/recovery codes while retaining older-code compatibility.
- Cached client spell metadata for responsive repeated searches and localized the new library status and action labels.
- Tightened catalog qualification to player-facing hostile effects, excluding internal negative-aura records such as the Forsaken Skill family and placeholder copies.
- Read localized descriptions from the client's spell-tooltip data when the direct description API is unavailable.
- Replaced the font-dependent add checkmark with a Blizzard check texture so it renders on every supported client font.

## 0.9.1-beta.1 — 2026-09-28

- Added opt-in combat-safe debuff sounds backed by exact spell-ID registrations, an out-of-combat learner, a build-stamped seed library, and Diagnostics controls for testing and clearing learned data.
- Added a dedicated Debuff Alerts page with independent Magic, Curse, Disease, and Poison sounds, optional LibSharedMedia choices, per-type previews, and custom sound-file paths.
- Embedded LibSharedMedia-3.0 with its LibStub and CallbackHandler dependencies for consistent shared-sound availability on Forever.
- Moved debuff-border configuration into Debuff Alerts and separated the static border from its animated overlay, with profile-backed Border Thickness and Pulse Expansion controls and live previews.
- Added profile and recovery-code support for the debuff-sound setting and selected sound. Learned spell IDs remain a rebuildable per-profile cache and are intentionally not included in recovery codes.
- Added opt-in Blizzard-native Magic, Curse, Disease, and Poison presentation with border, border-and-icon, and corner-icon styles plus optional pulsing.
- Added an out-of-combat four-type border preview and live debuff-awareness capability status to Diagnostics.
- Added a localized Diagnostics tab with a Test Lab, live capability status, a copyable support report, and gated space for future experimental probes.
- Added `/fbf debug` as an optional shortcut to the Diagnostics tab.
- Removed the user-facing expiry-debug toggle and continuous alert tracing. Existing profiles and older recovery codes containing that setting remain compatible.
- New recovery codes omit the retired debug setting, reducing profile payload size without breaking older codes.

## 0.9.0-beta.1 — 2026-09-24

Initial public beta release for World of Warcraft: Forever.

- Added independently configurable buff and debuff bars.
- Added direct bar dragging, locking, reset controls, and test icons.
- Added layout, aura-ordering, font, timer, stack, and outline controls.
- Added named profiles and complete manual backup/recovery codes.
- Added compatibility with older FBF1 and FBF2 recovery codes.
- Added shorter FBF3 recovery codes with harmless coordinate rounding.
- Added optional ten-second expiration warnings, sounds, filters, and spell-ID exclusions.
- Added minimap and Blizzard-frame visibility options.
- Added settings and runtime localization for all supported WoW client languages.
- Added locale-appropriate fonts for Cyrillic, Korean, Simplified Chinese, and Traditional Chinese.
- Documented the Forever beta saved-variable and in-combat aura limitations.
