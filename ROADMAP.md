# ForeverBuffFrames release roadmap

This document records where the addon has been, its current release position,
and what is intentionally deferred. It is a scope guard as well as a roadmap.

## Current position

**Phase 13 and its release gate are complete. ForeverBuffFrames 0.9.10-beta.1
is packaged for release.**

No new feature phase begins until the release gate is complete and the current
beta is packaged. Corrections found during verification remain part of the
release gate; unrelated enhancements return to the deferred list.

## Reconstructed history

The earliest phase names were not preserved in the repository. Phases 1–9 are
therefore grouped here from the implemented 0.9.0 baseline rather than assigned
invented individual titles.

### Phases 1–9 — Core beta foundation (complete)

- Independent movable buff and debuff aura containers.
- Icon size, spacing, rows, growth, sorting, and unlimited-aura placement.
- Timer and stack text appearance controls.
- Locking, reset controls, test icons, and native-frame visibility choices.
- Named profiles plus manual backup and recovery.
- Ten-second out-of-combat expiration warnings and filters.
- Minimap access and supported-client localization.
- Initial `0.9.0-beta.1` public-beta baseline.

### Phase 10 — Diagnostics and native presentation (complete)

- Dedicated diagnostics and test-lab interface.
- Native debuff-type borders and pulse presentation.
- Capability reporting for the Forever client.

### Phase 11 — Debuff awareness and library (complete)

- Combat-safe typed debuff sounds.
- Learned and seeded debuff records.
- Searchable, scrollable build-matched debuff library.
- One-click Personal Tracker integration and custom tracker editor.

### Phase 12 — Buff-alert sound system (complete)

- Combat-safe native buff-removal alerts.
- Per-buff sound assignments and combat-only mode.
- Custom sound-file registration and bundled open-license recordings.
- Current-character spellbook filtering.
- CDM and text-to-speech feasibility testing; unsuccessful experimental hooks
  were removed rather than shipped as nonfunctional options.

### Phase 13 — Tracking and pre-publish interface pass (complete)

- Fixed buff-bar magnifying-glass selector.
- Class, profession, and racial tracking abilities without duplicating general
  minimap service filters.
- Native tracking spell selection shown as ordinary buff auras, with the client
  deciding which tracking categories replace or coexist with one another.
- Selector integration with bar movement, sizing, and left/right growth.
- Consistent popup spacing, layering, containment, and responsive page fixes.

## Phase 13 release gate — current work

Only the following work is in scope before the next beta release:

1. [x] Regression-test expiration and buff-removal alerts.
2. [x] Regression-test debuff sounds, the library, and Personal Trackers.
3. [x] Verify profile switching and backup/recovery across characters.
4. [x] Test buff/debuff layouts across icon sizes, rows, growth directions, UI
   scales, and supported configuration text sizes.
5. [x] Review Diagnostics for obsolete or missing release-support information.
6. [x] Finish the changelog, release notes, and distributable beta package.

The detailed visual checks remain in `RELEASE_CHECKLIST.md`.

## Phase 14 — not started

Phase 14 will be selected only after the current beta is released. Its scope
must be agreed before implementation and must address a remaining core purpose,
not an opportunistic quality-of-life tangent.

## Deferred backlog

These ideas are explicitly outside the current release gate:

- Elkano-style duration bars as an alternative to icon bars.
- Text-to-speech alerts, unless a future Forever API makes combat hooks reliable.
- Further CDM integration, unless the Forever client exposes usable supported
  data or events.
- Additional convenience features that do not directly serve buff/debuff
  placement, expiration awareness, debuff awareness, or alert assignment.

## Project rules

- Major additions advance the beta version; ordinary UI corrections do not.
- Approved major milestones receive a changelog entry and Git push.
- When intent is uncertain, clarify before implementing.
- During a release gate, fixes and verification take priority over new features.
