# SALVAGE THEOLOGY — Development Log

## Purpose

Track what's built, decisions made, and what remains. Update after each session.

---

## Current Status

**Phase:** Phase 3 (Room Generation) - Complete
**Playable:** Yes (procedural dungeon, room transitions)
**Last Updated:** 2026-01-20

---

## Session Log

### Session 1: 2026-01-20

**Completed:**
- [x] Project structure created (scenes/, scripts/, resources/, shaders/, assets/)
- [x] project.godot configured (Godot 4.2, GL Compatibility, input mapping)
- [x] Color resources created with Calyx palette (cyan/teal/white)
- [x] Player character built from Polygon2D nodes:
  - Dark suit body (#0a0f1a)
  - Glowing cyan visor
  - Accent lines on torso, arms, legs
  - PointLight2D for visor glow
  - Subtle breathing and visor pulse animations
- [x] Player movement (WASD/Arrows, 200 units/sec)
- [x] Test room with collision walls and Calyx-themed decorations
- [x] Main scene combining room and player

**Decisions:**
- Used Polygon2D construction as specified in CHARACTERS.md
- Player character origin at feet (y=0), body extends upward to y=-60
- Collision shape is 12-unit radius circle centered on player body
- Camera zoom at 2x for better visibility
- Room has cyan accent lines on walls matching Calyx aesthetic

**Issues:**
- None

**Next:**
- Test in Godot editor to verify rendering
- Begin Phase 2: Resources & HUD (oxygen system)

### Session 2: 2026-01-20

**Completed:**
- [x] ResourceSystem with oxygen depletion (2 units/sec drain rate)
- [x] GameManager autoload for game state coordination
- [x] HUD with oxygen bar:
  - Cyan → Orange (25%) → Red (15%) color transitions
  - Pulsing warning effect at low oxygen
  - Percentage label display
- [x] Death panel with "OXYGEN DEPLETED" message
- [x] Player death state (movement stops, visual collapse)
- [x] Restart functionality (scene reload)

**Decisions:**
- Oxygen drains at 2 units/sec (50 seconds to death from full)
- Warning color at 25%, critical at 15%
- Death triggers visual fade + collapse animation on player
- GameManager as autoload for global game state

**Issues:**
- None

**Next:**
- Begin Phase 3: Basic Room Generation

### Session 3: 2026-01-20

**Completed:**
- [x] RoomData resource class with room types (Passage, Chamber, Shrine, Hazard)
- [x] RoomGenerator for procedural room creation
- [x] DungeonGenerator managing connected rooms:
  - Main path generation (8 rooms deep)
  - Side room branching (30% chance)
  - Adjacent room loading/unloading
- [x] GeneratedRoom scene with:
  - Dynamic wall/floor polygon generation
  - Door detection areas at cardinal directions
  - Room type decorations (shrine altar, hazard warnings)
  - Collision shapes with door gaps
- [x] Room transitions when player enters doors
- [x] Depth indicator in HUD

**Decisions:**
- Rooms are 10-18 tiles wide, 8-14 tiles tall (32px tiles)
- Dungeon generates main path first, then branches
- Only current + adjacent rooms loaded at once
- Rooms larger at deeper depths
- Room types affect decoration only (for now)

**Issues:**
- None

**Next:**
- Begin Phase 4: Calyx Theology (door payments)

### Session 4: 2026-01-20

**Completed:**
- [x] Rebuilt Phase 3 room system from scratch
- [x] Rewrote RoomData with proper room types from GODS.md:
  - PASSAGE (simple connector, 1-2 enemies)
  - CHAMBER (larger room, 3-5 enemies)
  - VAULT (treasure room, guarded)
  - SANCTUM (theology puzzle room)
  - HAZARD (environmental danger)
  - REST (safe zone, oxygen cache)
- [x] Implemented depth zone distribution (Entry 1-2, Outer 3-5, Inner 6-8, Core 9+)
- [x] Created comprehensive Calyx-themed room renderer:
  - Calyx color palette (cyan #00ffff, teal #40e0d0, dark #0a2020)
  - Glowing door frames with point lights
  - Floor grid pattern
  - Room-type-specific decorations (altar for SANCTUM, warning for HAZARD, etc.)
  - Proper z-index management
- [x] Fixed room transitions to properly teleport player to entry door
- [x] Simplified DungeonGenerator to show only current room (no overlap)

**Decisions:**
- Rooms centered at origin, only current room visible (simpler than grid positioning)
- Each room type has distinct visual marker for player recognition
- Door detection uses Area2D with player group check
- Ambient lighting added to each room for Calyx glow effect

**Issues:**
- None

**Next:**
- Begin Phase 4: Calyx Theology (door payments)

---

## Phase Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Core Foundation | Complete | Player polygon body, movement, test room |
| 2. Resources & HUD | Complete | Oxygen depletion, HUD, death/restart |
| 3. Room Generation | Complete | Procedural dungeon, room transitions |
| 4. Calyx Theology | Not started | Door payments |
| 5. Basic Enemy | Not started | Watcher |
| 6. Combat | Not started | Attack, damage |
| 7. Material & Extraction | Not started | Run loop |
| 8. Station & Meta | Not started | Progression |
| 9. Visual Polish | Not started | Animations, effects |
| 10. Audio Polish | Not started | Sound, music |
| 11. Additional Content | Not started | More gods, enemies |
| 12. Web Export | Not started | Deployment |

---

## Design Decisions Log

Track any deviations from or clarifications of design docs:

(none yet)

---

## Known Issues

(none yet)

---

## Questions for Creative Review

Bring these back to Claude.ai for discussion:

(none yet)

---

## Build Commands

**Run in editor:**
```
Open Godot → F5
```

**Export for web:**
```bash
godot --headless --export-release "Web" ./build/index.html
```

**Test locally:**
```bash
cd build && python -m http.server 8000
```

**Deploy to itch.io:**
1. Zip build/ folder
2. Upload to itch.io project
3. Set index.html as launch file

---

## Performance Notes

Target: 60fps in browser

Watch for:
- Particle counts
- Number of loaded rooms
- Audio stream counts
