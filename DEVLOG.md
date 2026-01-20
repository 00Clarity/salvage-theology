# SALVAGE THEOLOGY — Development Log

## Purpose

Track what's built, decisions made, and what remains. Update after each session.

---

## Current Status

**Phase:** Phase 8 (Station & Meta) - Complete
**Playable:** Yes (full run loop with extraction and upgrades)
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

### Session 5: 2026-01-20

**Completed:**
- [x] TheologyDoor entity with three states (LOCKED, PAID, OPEN)
- [x] Calyx Rule 1 - Payment system:
  - ITEM payment: Sacrifice inventory item
  - HEALTH payment: Sacrifice 10% max health
  - MEMORY payment: Sacrifice learned information
- [x] PaymentMenu UI with styled options
- [x] Calyx Rule 2 - Permanence:
  - Doors stay open forever once paid
  - Door states persisted in GameManager
  - Restored on room revisit
- [x] Calyx Rule 3 - Sanctuary:
  - Threshold zones inside door frames
  - Player immune to damage while in threshold
  - HUD indicator when protected
- [x] Player inventory system (items, memories)
- [x] HUD updates:
  - Health bar with color warnings
  - Inventory count display
  - Sanctuary indicator
- [x] GameManager tracking:
  - Door permanence states
  - Sacrifice statistics
  - Depth tracking

**Decisions:**
- Doors start locked, require payment to open
- Player starts with 2 items (Scrap Metal, Faded Cloth)
- Health sacrifice cannot kill player (minimum 1 HP)
- Threshold zones are 80% of door size
- Game pauses during payment menu

**Issues:**
- None

**Next:**
- Begin Phase 5: Basic Enemy (Watcher)

### Session 6: 2026-01-20

**Completed:**
- [x] EchoBase enemy class with state machine:
  - IDLE, PATROL, ALERT, CHASE, STARVING, DEAD states
  - Configurable stats (health, speed, detection range)
  - Line of sight detection
  - Alert other enemies within range
- [x] EchoWatcher enemy (scout type):
  - Ring/eye geometric visual design
  - 2-second detection window before chase
  - Rotating outer ring animation
  - Eye tracks player when detected
- [x] EchoSeeker enemy (attacker type):
  - Triangle/trail geometric visual
  - Fast movement with dash ability
  - Trail effect during chase
  - Attack damage on collision
- [x] EnemySpawner system:
  - Spawns enemies based on room type
  - Depth-based enemy distribution
  - No enemies in REST rooms
- [x] Combat system:
  - Player attack with directional arc
  - Attack input (Space, J, Left Click)
  - 70-degree attack cone
  - Attack cooldown system
  - Enemy damage and death

**Decisions:**
- Watcher alerts other enemies when detecting player
- Seeker has dash ability for aggressive pursuit
- Enemies don't spawn in REST rooms (safe zones)
- Attack requires facing enemy (adds tactical depth)

**Issues:**
- None

**Next:**
- Begin Phase 7: Divine Material & Extraction

### Session 7: 2026-01-20

**Completed:**
- [x] DivineMaterial pickup entity:
  - 5 grades: COMMON, UNCOMMON, RARE, EPIC, LEGENDARY
  - Grade-based colors and values
  - Hexagonal crystal visual with glow
  - Depth-based grade distribution
  - Pickup effect animation
- [x] MaterialSpawner system:
  - Spawns materials based on room type
  - VAULT rooms have most materials
  - Depth increases material count
- [x] Player material collection:
  - collect_material() method
  - Track divine_material_value
  - Material collected signal
- [x] Corruption system:
  - Corruption increases with material collected
  - Visual tint toward cyan at high corruption
  - Stat effects: slower movement, stronger attacks
  - Caps at 100%
- [x] ExtractionPoint entity:
  - Diamond shape with upward arrow
  - Progress ring during extraction
  - 2-second extraction time
  - Spawns in starting room (depth 1)
- [x] RunSummary screen:
  - Shows material collected, depth, rooms explored
  - Enemy kills and sacrifices made
  - Total banked material display
  - Extraction complete vs Signal Lost states
  - Continue to Station or New Run buttons
- [x] HUD updates:
  - Material value display
  - Corruption bar with warning colors

**Decisions:**
- Extraction point in starting room encourages depth exploration
- Corruption provides risk/reward for collecting more material
- Run summary appears on both extraction and death
- Material is only banked on successful extraction

**Issues:**
- None

**Next:**
- Begin Phase 8: Station & Meta-progression

### Session 8: 2026-01-20

**Completed:**
- [x] Station scene (hub between runs):
  - Dark background with grid pattern
  - Material display (banked total)
  - BEGIN DIVE button to start runs
- [x] Upgrade system with 6 upgrades:
  - O2 Tank Upgrade: +20% oxygen capacity
  - Reinforced Suit: +25 max health
  - Weapon Calibration: +10% attack damage
  - Servo Motors: +10% move speed
  - Divine Filter: -20% corruption gain
  - Supply Cache: +1 starting item
- [x] Upgrade persistence:
  - Upgrades applied to player at run start
  - Multiple upgrade levels per category
  - Costs scale with level
- [x] Save/Load system:
  - Saves to user://salvage_theology_save.dat
  - Persists banked material, runs completed, upgrades
  - Auto-loads on game start

**Decisions:**
- Station is accessed after successful extraction
- Upgrades provide permanent progression across runs
- Material only banks on extraction (death loses run progress)
- Save uses Godot's variant storage for simplicity

**Issues:**
- None

**Next:**
- Phase 9: Visual Polish
- Phase 10: Audio Polish

---

## Phase Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Core Foundation | Complete | Player polygon body, movement, test room |
| 2. Resources & HUD | Complete | Oxygen depletion, HUD, death/restart |
| 3. Room Generation | Complete | Procedural dungeon, room transitions |
| 4. Calyx Theology | Complete | Door payments, sanctuary, permanence |
| 5. Basic Enemy | Complete | Watcher scout, Seeker attacker |
| 6. Combat | Complete | Attack arc, damage, enemy death |
| 7. Material & Extraction | Complete | Divine material, corruption, extraction |
| 8. Station & Meta | Complete | Upgrades, save/load, meta-progression |
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
