# SALVAGE THEOLOGY

## What Is This?

A browser-based roguelite where you salvage divine material from the corpses of dead gods. Each god is a dungeon with its own theology — rules you must learn to survive.

## Core Documents

- `FOUNDATION.md` — Creative vision, aesthetic direction, game overview
- `IMPLEMENTATION.md` — Build phases and exact steps
- `CHARACTERS.md` — All character/enemy technical specifications
- `GODS.md` — Dungeon design, theology rules, room generation
- `SYSTEMS.md` — Game systems, math, formulas
- `AUDIO.md` — Sound design and synthesis specifications
- `DEVLOG.md` — Development progress tracking

## Technical Approach

**Engine:** Godot 4.x (GDScript)
**Target:** WebGL browser export
**Art:** All visuals generated natively (Polygon2D, meshes, shaders, particles)
**Audio:** Procedural synthesis + minimal free assets

## The Aesthetic

**Neon sacred fantasy.** Beautiful, overwhelming, subtly wrong.

- Gods are radiant, not rotting
- Colors are saturated and luminous
- Geometry is sacred and impossible
- Scale makes you feel small
- Beauty with wrongness — too perfect, unsettling

## Native Art Pipeline

No external sprites or models. Everything built in Godot:

- **Characters:** Polygon2D bodies + Skeleton2D animation + Light2D accents
- **Enemies:** Geometric shapes + particles + shaders
- **Environments:** TileMap with procedural tiles, or 3D primitives
- **Effects:** GPUParticles2D/3D + custom shaders

## Key Principles

1. **Theology is the mechanic** — Each god has rules. Learn them or die.
2. **Death teaches** — Failure should inform, not frustrate.
3. **Corruption is progression** — Carrying divine material changes you.
4. **The gods are beautiful** — Horror through overwhelming sacred beauty.
5. **Systems create stories** — Emergence over authored narrative.

## Build Priority

Phase 1 first. Test core loop before expanding.

Always commit and update DEVLOG.md after significant progress.
