# SALVAGE THEOLOGY — Development Log

## Purpose

Track what's built, decisions made, and what remains. Update after each session.

---

## Current Status

**Phase:** Not started
**Playable:** No
**Last Updated:** —

---

## Session Log

### Session 1: [DATE]

**Completed:**
- [ ] Initial setup

**Decisions:**
- (none yet)

**Issues:**
- (none yet)

**Next:**
- Read all design docs
- Set up Godot project
- Begin Phase 1

---

## Phase Tracker

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Core Foundation | Not started | Player movement |
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
