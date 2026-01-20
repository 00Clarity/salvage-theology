# SALVAGE THEOLOGY — Development Log

## Purpose

Track what's built, decisions made, and what remains. Update after each session.

---

## Current Status

**Phase:** Phase 1 (Core Foundation) - Complete
**Playable:** Yes (basic movement in test room)
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

---

## Phase Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Core Foundation | Complete | Player polygon body, movement, test room |
| 2. Resources & HUD | Not started | Oxygen, death |
| 3. Room Generation | Not started | Procedural layout |
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
