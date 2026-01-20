# SALVAGE THEOLOGY
## Foundation Document

---

# THE GAME

A browser-based roguelite where you salvage divine material from the corpses of dead gods. Each god is a dungeon with its own theology — rules you must learn to survive. The deeper you go, the more you carry, the less human you become.

**Genre:** Top-down roguelite dungeon crawler
**Platform:** Browser (Godot WebGL export)
**Session:** 30-60 minute runs
**Aesthetic:** Neon fantasy — beautiful, sacred, subtly wrong

---

# THE PREMISE

The gods are dead. No one knows why.

Their corpses drift in the void — vast crystalline structures of impossible color, frozen mid-thought. Inside them, divine material accumulates. The substance that makes medicine, fuel, weapons, miracles.

You're a salvager. You enter the dead gods, navigate their theology, extract what you can, and get out before they reclaim you. It's a job. It pays. Most people don't come back.

---

# THE AESTHETIC

## The Look: Neon Sacred Fantasy

**Not grimdark.** The gods aren't rotting — they're radiant. Being inside a dead god is like being inside a stained glass cathedral that goes on forever. The horror isn't darkness. It's too much light. Too much beauty. The human mind straining against the sacred.

**Not grotesque (usually).** The angels are gorgeous. Sacred geometry, perfect symmetry, divine light. But something is deeply unsettling. Too perfect. Too bright. Looking too long feels like a violation.

**Fantasy, not sci-fi.** Despite the "salvage" framing, this is a mythic space. You're not in a spaceship. You're in heaven's corpse. The technology you carry is dwarfed by the sacred architecture around you.

## Visual Principles

**1. Light is holy**
- Everything glows from within
- Darkness is rare and meaningful
- The void between gods is deep indigo, not black
- Divine material is the brightest thing on screen

**2. Geometry is sacred**
- Architecture built from impossible shapes
- Penrose triangles, Klein bottles, tesseract shadows
- Patterns that repeat at every scale
- The deeper you go, the more the geometry breaks down

**3. Color is overwhelming**
- Each god has a dominant palette (cyan, magenta, gold, etc.)
- Colors are saturated, luminous, almost painful
- The void is the only dark — warm indigo with pale stars

**4. Scale is emotional**
- You are small. The god is vast.
- Rooms should feel like chambers in a giant's body
- Distant architecture visible through doorways
- The core is always impossibly far below

**5. Beauty with wrongness**
- Everything is beautiful — but something's off
- Symmetry that's slightly broken
- Eyes where there shouldn't be eyes
- Movement that's too smooth or too sudden
- The uncanny divine

## Color Palettes

**THE VOID (Between Gods)**
```
Deep indigo    #1a1a3a
Pale gold      #ffd89050 (stars)
Rose           #ff8a9050 (stars)
Mint           #8affd050 (stars)
```

**CALYX — God of Thresholds**
```
Primary        #00ffff (cyan)
Secondary      #40e0d0 (teal)
Accent         #ffffff (pure white)
Dark           #0a2a2a
```

**VORATH — God of Appetite**
```
Primary        #ff00ff (magenta)
Secondary      #ffd700 (gold)
Accent         #dc143c (crimson)
Dark           #2a0a2a
```

**SELEN — God of Forgetting**
```
Primary        #e6e6fa (lavender)
Secondary      #c0c0c0 (silver)
Accent         #b0e0e6 (pale blue)
Dark           #1a1a2a
```

**DIVINE MATERIAL**
```
Core           #ffffff
Inner glow     #fff4e0
Outer glow     Shifts based on which god (cyan/magenta/lavender)
```

---

# THE CHARACTERS

## Visual Style: Constructed Figures

All characters are built natively in Godot from polygons, bones, and light. No external sprites. The style is **intentional** — silhouettes with glowing accents, readable shapes, fluid skeletal animation.

## The Salvager (Player)

**Silhouette:** Human figure in form-fitting suit (EVA plug suit inspiration)
**Construction:** 
- Dark polygon shapes for body segments (head, torso, arms, legs)
- Glowing edge lines suggest suit details
- Visor is the only "face" — a horizontal slit of cyan light
- Backpack/tank shape for equipment

**Feel:** A worker. Anonymous. The suit obscures humanity. You're a tool for extraction.

**Animation:**
- Idle: Subtle breathing, visor glow pulses slowly
- Walk: Smooth skeletal animation, suit lines flow
- Damaged: Sparks, warning glow (orange), flickering visor
- Corrupted: Geometry starts breaking — limbs elongate, colors shift

## The Echoes (Enemies)

Fragments of divine consciousness. They enforce the god's theology.

**Visual Principle:** Abstract but consistent. Each Echo type has a recognizable shape that reads instantly.

**Echo Types:**

**Watcher (Basic)**
- Shape: Floating ring with single eye in center
- Movement: Drifts slowly, eye tracks player
- Glow: Soft, constant
- Threat: Alerts other Echoes, triggers theology enforcement

**Guardian (Tank)**
- Shape: Door-shaped frame, multiple eyes, radiating beams
- Movement: Slow patrol, blocks passages
- Glow: Intense, pulses with threat level
- Threat: Heavy damage, cannot be killed (only evaded)

**Seeker (Fast)**
- Shape: Triangle with trailing light ribbons
- Movement: Sudden darts, pauses, darts again
- Glow: Flickers rapidly
- Threat: Fast, damages on contact

**Remnant (Special)**
- Shape: Humanoid silhouette — a previous salvager, absorbed
- Movement: Mimics player movement, delayed
- Glow: Dim, flickering, wrong color
- Threat: Uses salvager abilities against you

## NPCs (Station)

Between runs, you're at a station. NPCs are other salvagers, merchants, faction reps.

**Visual Style:** Same construction as player — polygon bodies, glowing accents. Differentiated by:
- Suit colors/patterns (faction affiliation)
- Body proportions (tall/short, broad/narrow)
- Visor colors
- Damage/wear on suits
- Accessories (visible equipment, patches, marks)

---

# THE GODS (Dungeons)

Each god is a procedurally generated dungeon with:
- Unique visual palette
- Unique theology (rules you must learn)
- Unique hazards and Echoes
- A core (deepest point, greatest treasure, greatest danger)

## Dungeon Structure

```
ENTRY ZONE (Depth 1-2)
- Tutorial rooms
- Basic theology introduction
- Low threat, low reward

OUTER SANCTUM (Depth 3-5)
- Full theology in effect
- Standard enemies
- Medium reward

INNER SANCTUM (Depth 6-8)
- Theology complications (rules combine)
- Elite enemies
- High reward

THE CORE (Depth 9-10)
- Theology at maximum
- Guardian presence
- Divine material concentrated
- The god is most "alive" here
```

## God: CALYX (Thresholds)

**Domain:** Doors, passages, transitions, liminality
**Palette:** Cyan, teal, white
**Architecture:** Endless doorframes, corridors that don't connect logically, light from nowhere

**Theology:**
1. Every door requires payment (item, health, or memory)
2. A door opened cannot be closed
3. Standing in a threshold grants protection
4. The direct path is never the true path

**Hazards:**
- Looping corridors (wrong turn returns you to start)
- Closing walls (must find door before crushed)
- False doors (lead nowhere, waste payment)

**Echoes:** Watchers, Guardians (door-shaped), Door-Seekers

## God: VORATH (Appetite)

**Domain:** Hunger, consumption, desire, the void inside
**Palette:** Magenta, gold, crimson
**Architecture:** Vast stomach-like chambers, golden light, teeth-lined passages

**Theology:**
1. What you take, Vorath takes from you
2. Hunger can be redirected (feed enemies to the god)
3. The starving are sacred (don't attack weakened enemies)
4. Offer before you ask

**Hazards:**
- Digestive zones (constant resource drain)
- Feeding pits (sacrifice items for passage)
- Hunger aura (enemies and player both affected)

**Echoes:** Maws (stationary, block paths, must be fed), Parasites (attach and drain), Hollow Ones (starving, sacred)

## God: SELEN (Forgetting)

**Domain:** Memory, loss, peace, oblivion
**Palette:** Lavender, silver, pale blue
**Architecture:** Fading rooms, soft edges, spaces that weren't there before

**Theology:**
1. What is remembered is preserved
2. What is forgotten is free
3. Speaking a name binds it
4. Silence is sanctuary

**Hazards:**
- Fog of forgetting (lose map progress)
- Memory anchors (must remember path or lose it)
- Name traps (saying a name summons something)

**Echoes:** Faders (become invisible if you look away), Whisperers (force you to speak), The Forgotten (don't remember they're enemies)

---

# THE SYSTEMS

## Resources

**Oxygen**
- Depletes constantly (divine atmosphere is wrong)
- Refill at caches or with items
- Zero = forced extraction or death

**Light**
- Your visor filters divine radiance
- Depletes in high-divinity areas
- Zero = see true forms (sanity damage, but also revelation)

**Sanity**
- Depletes from witnessing impossible things
- Low sanity = hallucinations, UI distortion
- Zero = transformation, not death

**Corruption**
- Gained from carrying divine material
- More material = faster corruption
- High corruption = divine abilities, lost human options
- Max corruption = become part of the god (run ends, character persists as NPC)

## Theology System

Each god has rules. Rules are:
- **Discoverable** (observe, read, experiment)
- **Consistent** (always work the same)
- **Exploitable** (once understood, can be gamed)
- **Enforced** (break them, face consequences)

Players learn theology through:
- Environmental observation (what happens when...)
- Text fragments (divine scripture, salvager notes)
- Death (the best teacher)
- NPCs (intel purchased or earned)

## Combat

Combat exists but isn't the focus. Navigation and theology are primary.

**Style:** Real-time with pause option (like Transistor)
**Inputs:** Move, dodge, attack, use item, interact
**Approach:** 
- Violence is one option
- Stealth often better (Echoes are blind to certain behaviors)
- Theology exploitation best (use rules against enemies)
- Some enemies cannot be killed, only evaded

## Progression

**Within a run:**
- Find better equipment
- Gather divine material
- Learn theology (persists in your knowledge)
- Go deeper

**Between runs:**
- Sell material, buy upgrades
- Unlock new equipment
- Build faction relationships
- Advance story
- Unlock new gods

**Permanent progression:**
- Equipment unlocks
- Theology codex (what you've learned)
- Faction standing
- Story revelations
- Corrupted characters return as NPCs

---

# THE NARRATIVE

## The Mystery

Why did the gods die? The **Severance** is the central mystery. Theories:
- They killed each other
- Humanity killed them (unknowingly?)
- They chose to die
- They're not really dead

The truth unfolds across many runs, many gods, many conversations.

## The Factions

**THRESHOLD INDUSTRIES**
- Corporate, efficient, dominant
- Treat salvagers as expendable
- Building something with the material
- Color: White/cyan

**THE FEAST COLLECTIVE**
- Worker cooperative
- Believe in salvager dignity
- Hiding something about the Severance
- Color: Orange/gold

**CHURCH OF THE OPEN WOUND**
- Believe gods are dreaming, not dead
- Salvage is communion
- Trying to wake a god
- Color: Red/silver

**THE UNLICENSED**
- Pirates, criminals, free agents
- No safety net, high reward
- Know what the Concerns really want
- Color: Black/neon (chaotic)

## The Personal

Your salvager has a procedurally generated reason for doing this:
- Lost someone to a dive
- Corrupted loved one (seeking cure)
- Seeking something inside a specific god
- Running from something on the stations
- True believer (Church) trying to prove divinity lives

This personal thread weaves through runs. You may find what you're looking for. Or find it's changed you.

## The Kojima Layer

Deep in certain gods: **Terminal Rooms**
- Text-only interfaces
- The god speaks to you (the player, not the character)
- Knows you've been here before
- Asks questions you must answer
- Your answers affect future runs

The fourth wall is thin in the presence of the divine.

---

# TECHNICAL APPROACH

## Engine

Godot 4.x with WebGL export

## Native Art Pipeline

All visuals generated by Claude Code:
- Characters: Polygon2D + Skeleton2D + Light2D
- Environments: TileMap with generated tiles
- Effects: Shaders + GPUParticles2D
- UI: Control nodes with styled themes

No external sprites. The aesthetic is intentional, not placeholder.

## Audio

Procedural synthesis where possible:
- Drones from layered oscillators
- UI sounds from shaped waveforms
- Ambience from filtered noise

Free assets for complex sounds (footsteps, impacts) if needed.

## Procedural Generation

- Room layouts from templates + variation
- Enemy placement by depth rules
- Loot distribution by tables
- Each run is different, theology is consistent

---

# BUILD PHASES

## Phase 1: Proof of Concept
- One god (Calyx)
- Player movement and basic combat
- One theology rule working
- One enemy type
- Extraction loop
- Placeholder station (just restart)

## Phase 2: Core Loop
- Full Calyx theology
- All Calyx enemies
- Resource systems (oxygen, light)
- Basic equipment
- Station with shop

## Phase 3: Depth
- Second god (Vorath)
- Corruption system
- Sanity system
- Faction basics
- Meta-progression

## Phase 4: Full Game
- All gods
- All systems
- Full narrative
- All factions
- Polish and balance

---

# SUCCESS CRITERIA

The game works when:
- Entering a god feels like trespassing somewhere sacred
- Learning theology feels like cracking a code
- Dying teaches rather than frustrates
- Carrying material feels transgressive
- The gods are beautiful and wrong
- Players say "one more run"

---

*The gods are dead. Their bodies are full of treasure. You are small, greedy, and afraid. Enter anyway.*
