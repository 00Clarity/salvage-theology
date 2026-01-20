# SALVAGE THEOLOGY: CHARACTERS
## Complete Technical Specifications

All characters are built natively in Godot. No external assets.

---

# CONSTRUCTION METHOD

## The Pipeline

Every character follows this construction:

1. **Define body parts** as Polygon2D nodes (2D) or MeshInstance3D primitives (3D)
2. **Create skeleton** with Bone2D (2D) or Skeleton3D (3D)
3. **Bind parts to bones** for animation
4. **Add lights** for glowing elements (Light2D or OmniLight3D)
5. **Add particles** for effects (GPUParticles2D/3D)
6. **Create animations** in AnimationPlayer
7. **Apply shaders** for glow, distortion, special effects

## The Style

**Silhouette-first design:**
- Characters readable from shape alone
- Details suggested by glow lines, not drawn features
- Faces are visors, eyes, or light sources — not human features
- Movement conveys personality

---

# THE SALVAGER (Player Character)

## Overview

A human figure in a form-fitting salvage suit. Anonymous, utilitarian, dwarfed by the divine architecture around them. The suit obscures humanity — you're a tool for extraction.

## Visual Design

```
HEIGHT: 64 units (2D) / 1.8 meters (3D)
PROPORTION: Slightly elongated limbs (suit aesthetic)
COLOR: Dark base (#0a0f1a) with colored accents (faction-based, default cyan)
GLOW: Visor slit, suit seams, equipment indicators

SILHOUETTE (front):
        ┌───┐
        │ ▬ │       ← Helmet with visor slit
        └─┬─┘
       ┌──┴──┐
       │     │      ← Torso (slight taper)
       └──┬──┘
        ┌─┴─┐
       ╱│   │╲     ← Arms (thin, angular)
        │   │
        ├───┤       ← Hips
       ╱     ╲
      │       │     ← Legs (long, tapered)
      └       ┘
```

## 2D Construction (Polygon2D)

```gdscript
# Salvager body parts as Polygon2D nodes
# All coordinates relative to character origin (feet)

extends Node2D
class_name SalvagerBody

# Colors
const BASE_COLOR = Color(0.04, 0.06, 0.1)      # Dark suit
const ACCENT_COLOR = Color(0, 1, 1)            # Cyan (default)
const VISOR_COLOR = Color(0, 1, 1, 0.9)        # Bright visor

func _ready():
    create_body()
    create_skeleton()
    create_lights()
    create_animations()

func create_body():
    # HEAD (helmet)
    var head = Polygon2D.new()
    head.name = "Head"
    head.polygon = PackedVector2Array([
        Vector2(-10, -60), Vector2(10, -60),   # Top
        Vector2(12, -48), Vector2(12, -44),    # Right side
        Vector2(-12, -44), Vector2(-12, -48),  # Left side
    ])
    head.color = BASE_COLOR
    add_child(head)
    
    # VISOR (glowing slit)
    var visor = Polygon2D.new()
    visor.name = "Visor"
    visor.polygon = PackedVector2Array([
        Vector2(-8, -52), Vector2(8, -52),
        Vector2(8, -50), Vector2(-8, -50),
    ])
    visor.color = VISOR_COLOR
    head.add_child(visor)
    
    # TORSO
    var torso = Polygon2D.new()
    torso.name = "Torso"
    torso.polygon = PackedVector2Array([
        Vector2(-11, -44), Vector2(11, -44),   # Shoulders
        Vector2(9, -20), Vector2(-9, -20),     # Waist
    ])
    torso.color = BASE_COLOR
    add_child(torso)
    
    # TORSO ACCENT LINES
    var torso_lines = Line2D.new()
    torso_lines.name = "TorsoAccent"
    torso_lines.points = PackedVector2Array([
        Vector2(0, -42), Vector2(0, -22)
    ])
    torso_lines.width = 1.5
    torso_lines.default_color = ACCENT_COLOR
    torso.add_child(torso_lines)
    
    # LEFT ARM (upper)
    var arm_l_upper = Polygon2D.new()
    arm_l_upper.name = "ArmLeftUpper"
    arm_l_upper.polygon = PackedVector2Array([
        Vector2(-14, -42), Vector2(-11, -42),
        Vector2(-12, -30), Vector2(-16, -30),
    ])
    arm_l_upper.color = BASE_COLOR
    add_child(arm_l_upper)
    
    # LEFT ARM (lower)
    var arm_l_lower = Polygon2D.new()
    arm_l_lower.name = "ArmLeftLower"
    arm_l_lower.polygon = PackedVector2Array([
        Vector2(-16, -30), Vector2(-12, -30),
        Vector2(-11, -16), Vector2(-15, -16),
    ])
    arm_l_lower.color = BASE_COLOR
    add_child(arm_l_lower)
    
    # RIGHT ARM (upper)
    var arm_r_upper = Polygon2D.new()
    arm_r_upper.name = "ArmRightUpper"
    arm_r_upper.polygon = PackedVector2Array([
        Vector2(11, -42), Vector2(14, -42),
        Vector2(16, -30), Vector2(12, -30),
    ])
    arm_r_upper.color = BASE_COLOR
    add_child(arm_r_upper)
    
    # RIGHT ARM (lower)
    var arm_r_lower = Polygon2D.new()
    arm_r_lower.name = "ArmRightLower"
    arm_r_lower.polygon = PackedVector2Array([
        Vector2(12, -30), Vector2(16, -30),
        Vector2(15, -16), Vector2(11, -16),
    ])
    arm_r_lower.color = BASE_COLOR
    add_child(arm_r_lower)
    
    # HIPS
    var hips = Polygon2D.new()
    hips.name = "Hips"
    hips.polygon = PackedVector2Array([
        Vector2(-9, -20), Vector2(9, -20),
        Vector2(8, -14), Vector2(-8, -14),
    ])
    hips.color = BASE_COLOR
    add_child(hips)
    
    # LEFT LEG (upper)
    var leg_l_upper = Polygon2D.new()
    leg_l_upper.name = "LegLeftUpper"
    leg_l_upper.polygon = PackedVector2Array([
        Vector2(-8, -14), Vector2(-2, -14),
        Vector2(-3, 4), Vector2(-7, 4),
    ])
    leg_l_upper.color = BASE_COLOR
    add_child(leg_l_upper)
    
    # LEFT LEG (lower)
    var leg_l_lower = Polygon2D.new()
    leg_l_lower.name = "LegLeftLower"
    leg_l_lower.polygon = PackedVector2Array([
        Vector2(-7, 4), Vector2(-3, 4),
        Vector2(-2, 24), Vector2(-6, 24),
    ])
    leg_l_lower.color = BASE_COLOR
    add_child(leg_l_lower)
    
    # RIGHT LEG (upper)
    var leg_r_upper = Polygon2D.new()
    leg_r_upper.name = "LegRightUpper"
    leg_r_upper.polygon = PackedVector2Array([
        Vector2(2, -14), Vector2(8, -14),
        Vector2(7, 4), Vector2(3, 4),
    ])
    leg_r_upper.color = BASE_COLOR
    add_child(leg_r_upper)
    
    # RIGHT LEG (lower)
    var leg_r_lower = Polygon2D.new()
    leg_r_lower.name = "LegRightLower"
    leg_r_lower.polygon = PackedVector2Array([
        Vector2(3, 4), Vector2(7, 4),
        Vector2(6, 24), Vector2(2, 24),
    ])
    leg_r_lower.color = BASE_COLOR
    add_child(leg_r_lower)

func create_lights():
    # Visor glow
    var visor_light = PointLight2D.new()
    visor_light.name = "VisorLight"
    visor_light.position = Vector2(0, -51)
    visor_light.color = ACCENT_COLOR
    visor_light.energy = 0.8
    visor_light.texture = preload("res://assets/light_gradient.tres") # Soft gradient
    visor_light.texture_scale = 0.3
    add_child(visor_light)

func create_skeleton():
    # Skeleton2D setup for animation
    var skeleton = Skeleton2D.new()
    skeleton.name = "Skeleton"
    
    # Root bone (hips)
    var bone_root = Bone2D.new()
    bone_root.name = "BoneRoot"
    bone_root.position = Vector2(0, -17)
    skeleton.add_child(bone_root)
    
    # Spine bone
    var bone_spine = Bone2D.new()
    bone_spine.name = "BoneSpine"
    bone_spine.position = Vector2(0, -15)
    bone_root.add_child(bone_spine)
    
    # Head bone
    var bone_head = Bone2D.new()
    bone_head.name = "BoneHead"
    bone_head.position = Vector2(0, -12)
    bone_spine.add_child(bone_head)
    
    # Continue for all limbs...
    add_child(skeleton)
```

## 3D Construction (Low-Poly)

```gdscript
# Salvager as low-poly 3D mesh
# Built from primitives and CSG operations

extends Node3D
class_name Salvager3D

const BASE_COLOR = Color(0.04, 0.06, 0.1)
const ACCENT_COLOR = Color(0, 1, 1)

func _ready():
    create_body()
    create_materials()
    create_lights()

func create_body():
    # HEAD (helmet) - Stretched cube with beveled edges
    var head = CSGBox3D.new()
    head.name = "Head"
    head.size = Vector3(0.25, 0.28, 0.25)
    head.position = Vector3(0, 1.65, 0)
    add_child(head)
    
    # VISOR - Thin emissive strip
    var visor = CSGBox3D.new()
    visor.name = "Visor"
    visor.size = Vector3(0.2, 0.03, 0.02)
    visor.position = Vector3(0, 1.62, 0.13)
    visor.material = create_emissive_material(ACCENT_COLOR)
    add_child(visor)
    
    # TORSO - Tapered box
    var torso = CSGBox3D.new()
    torso.name = "Torso"
    torso.size = Vector3(0.35, 0.45, 0.2)
    torso.position = Vector3(0, 1.25, 0)
    add_child(torso)
    
    # Continue for all body parts...
    # Arms: CSGCylinder3D, tapered
    # Legs: CSGCylinder3D, jointed
    # Hands: Small CSGBox3D
    # Feet: CSGBox3D

func create_emissive_material(color: Color) -> StandardMaterial3D:
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 2.0
    return mat
```

## Animations

**IDLE**
- Duration: 2.0s, looping
- Subtle breathing: torso scales Y 1.0 → 1.02 → 1.0
- Visor pulse: light energy 0.8 → 1.0 → 0.8
- Micro-sway: root position shifts ±1 unit

**WALK**
- Duration: 0.6s per cycle, looping
- Legs alternate swing (±20° rotation)
- Arms opposite swing (±15° rotation)
- Torso slight bob (±2 units Y)
- Head stays stable (counter-rotation)

**RUN**
- Same as walk, 0.4s cycle
- More extreme angles (±30° legs, ±25° arms)
- More bob (±4 units Y)

**DAMAGED**
- Duration: 0.3s, one-shot
- Flash all parts to warning color (orange)
- Screen shake trigger
- Visor flicker (rapid on/off)

**DEATH**
- Duration: 1.0s, one-shot
- Collapse: bones lose stiffness
- Visor fades to black
- Particles: divine material released

**CORRUPTION STATES**
- At 25%: Subtle color shift toward current god's palette
- At 50%: Geometry starts distorting (vertex displacement)
- At 75%: Extra geometry appears (growths, extensions)
- At 100%: Full transformation (unique per god)

---

# ECHOES (Enemies)

Echoes are fragments of divine consciousness. Abstract, geometric, beautiful, threatening.

## WATCHER (Basic Scout)

**Role:** Patrol, detect, alert others
**Threat Level:** Low (no direct attack)
**Speed:** Slow drift

**Visual Design:**
```
        ╭───────╮
       ╱    ◉    ╲        ← Central eye
      │           │        ← Outer ring
       ╲         ╱
        ╰───────╯
        
CONSTRUCTION:
- Outer ring: Torus (3D) or circle outline (2D)
- Inner eye: Sphere with emissive pupil
- Rotation: Ring rotates slowly, eye tracks player
```

**2D Construction:**
```gdscript
extends Node2D
class_name EchoWatcher

var ring_rotation = 0.0
var eye_target = Vector2.ZERO

func _ready():
    create_ring()
    create_eye()
    create_glow()

func create_ring():
    var ring = Line2D.new()
    ring.name = "Ring"
    
    # Create circle from points
    var points = PackedVector2Array()
    for i in range(32):
        var angle = i * TAU / 32
        points.append(Vector2(cos(angle), sin(angle)) * 24)
    points.append(points[0])  # Close the circle
    
    ring.points = points
    ring.width = 3.0
    ring.default_color = Color(0, 1, 1, 0.8)
    add_child(ring)

func create_eye():
    var eye = Polygon2D.new()
    eye.name = "Eye"
    
    # Circle for eye
    var points = PackedVector2Array()
    for i in range(16):
        var angle = i * TAU / 16
        points.append(Vector2(cos(angle), sin(angle)) * 8)
    
    eye.polygon = points
    eye.color = Color(1, 1, 1)
    add_child(eye)
    
    # Pupil
    var pupil = Polygon2D.new()
    pupil.name = "Pupil"
    var pupil_points = PackedVector2Array()
    for i in range(12):
        var angle = i * TAU / 12
        pupil_points.append(Vector2(cos(angle), sin(angle)) * 3)
    pupil.polygon = pupil_points
    pupil.color = Color(0, 0, 0)
    eye.add_child(pupil)

func create_glow():
    var light = PointLight2D.new()
    light.color = Color(0, 1, 1)
    light.energy = 0.6
    light.texture_scale = 0.5
    add_child(light)

func _process(delta):
    # Rotate ring
    ring_rotation += delta * 0.5
    $Ring.rotation = ring_rotation
    
    # Eye tracks player
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var dir = (player.global_position - global_position).normalized()
        $Eye/Pupil.position = dir * 3
```

**Behavior:**
- Drifts in patrol pattern
- Eye tracks nearest player
- If player in range for 2s: triggers alert
- Alert: Ring flashes, sound plays, nearby enemies converge

---

## GUARDIAN (Blocker)

**Role:** Block passages, force theology compliance
**Threat Level:** High (instant kill if rules broken)
**Speed:** Slow patrol or stationary

**Visual Design:**
```
    ╔═══════════════╗
    ║   ◉   ◉   ◉   ║      ← Multiple eyes
    ║               ║
    ║   DOOR FRAME  ║      ← Body is a doorway
    ║               ║
    ║   ◉   ◉   ◉   ║
    ╚═══════════════╝
    
    │││││││││││││││││      ← Light beams below
    
CONSTRUCTION:
- Body: Rectangular frame (no center)
- Eyes: 6 emissive spheres arranged in frame
- Beams: Line2D or RayCast3D visuals
```

**2D Construction:**
```gdscript
extends Node2D
class_name EchoGuardian

const FRAME_COLOR = Color(0, 0.8, 0.8)
const EYE_COLOR = Color(1, 1, 1)
const BEAM_COLOR = Color(0, 1, 1, 0.3)

func _ready():
    create_frame()
    create_eyes()
    create_beams()

func create_frame():
    # Outer rectangle
    var outer = Line2D.new()
    outer.points = PackedVector2Array([
        Vector2(-32, -48), Vector2(32, -48),
        Vector2(32, 48), Vector2(-32, 48),
        Vector2(-32, -48)
    ])
    outer.width = 6.0
    outer.default_color = FRAME_COLOR
    add_child(outer)
    
    # Inner rectangle (creates frame effect)
    var inner = Line2D.new()
    inner.points = PackedVector2Array([
        Vector2(-24, -40), Vector2(24, -40),
        Vector2(24, 40), Vector2(-24, 40),
        Vector2(-24, -40)
    ])
    inner.width = 2.0
    inner.default_color = FRAME_COLOR
    add_child(inner)

func create_eyes():
    var eye_positions = [
        Vector2(-20, -36), Vector2(0, -36), Vector2(20, -36),
        Vector2(-20, 36), Vector2(0, 36), Vector2(20, 36)
    ]
    
    for pos in eye_positions:
        var eye = create_single_eye()
        eye.position = pos
        add_child(eye)

func create_single_eye() -> Node2D:
    var eye_container = Node2D.new()
    
    var eye = Polygon2D.new()
    var points = PackedVector2Array()
    for i in range(12):
        var angle = i * TAU / 12
        points.append(Vector2(cos(angle), sin(angle)) * 5)
    eye.polygon = points
    eye.color = EYE_COLOR
    eye_container.add_child(eye)
    
    var light = PointLight2D.new()
    light.color = FRAME_COLOR
    light.energy = 0.4
    light.texture_scale = 0.2
    eye_container.add_child(light)
    
    return eye_container

func create_beams():
    # Detection beams below the guardian
    for i in range(9):
        var beam = Line2D.new()
        var x = -24 + (i * 6)
        beam.points = PackedVector2Array([
            Vector2(x, 48), Vector2(x, 148)
        ])
        beam.width = 2.0
        beam.default_color = BEAM_COLOR
        add_child(beam)
```

**Behavior:**
- Blocks passages that require payment
- Eyes scan for theology violations
- If player breaks rule in range: beams activate, instant kill
- Cannot be damaged — only evaded

---

## SEEKER (Fast Attacker)

**Role:** Hunt player, damage on contact
**Threat Level:** Medium
**Speed:** Fast bursts

**Visual Design:**
```
         ╱╲
        ╱  ╲
       ╱    ╲          ← Triangular body
      ╱  ◉   ╲         ← Central eye
     ╱________╲
     
     ~~~~~~~~~~~       ← Trailing light ribbons
     
CONSTRUCTION:
- Body: Triangle (Polygon2D or CSGPrism)
- Eye: Emissive circle at center
- Trails: Line2D with gradient fade or GPUParticles
```

**2D Construction:**
```gdscript
extends Node2D
class_name EchoSeeker

var velocity = Vector2.ZERO
var trail_points = []
const MAX_TRAIL = 20

func _ready():
    create_body()
    create_eye()
    create_trail()

func create_body():
    var body = Polygon2D.new()
    body.name = "Body"
    body.polygon = PackedVector2Array([
        Vector2(0, -20),      # Tip
        Vector2(-14, 16),     # Bottom left
        Vector2(14, 16)       # Bottom right
    ])
    body.color = Color(0, 1, 1, 0.9)
    add_child(body)
    
    # Inner triangle (darker)
    var inner = Polygon2D.new()
    inner.polygon = PackedVector2Array([
        Vector2(0, -12),
        Vector2(-8, 10),
        Vector2(8, 10)
    ])
    inner.color = Color(0, 0.3, 0.3)
    body.add_child(inner)

func create_eye():
    var eye = Polygon2D.new()
    var points = PackedVector2Array()
    for i in range(10):
        var angle = i * TAU / 10
        points.append(Vector2(cos(angle), sin(angle)) * 4)
    eye.polygon = points
    eye.color = Color(1, 1, 1)
    eye.position = Vector2(0, 2)
    add_child(eye)

func create_trail():
    var trail = Line2D.new()
    trail.name = "Trail"
    trail.width = 8.0
    trail.width_curve = Curve.new()
    trail.width_curve.add_point(Vector2(0, 1))
    trail.width_curve.add_point(Vector2(1, 0))
    trail.default_color = Color(0, 1, 1, 0.5)
    add_child(trail)

func _process(delta):
    # Update trail
    trail_points.insert(0, global_position)
    if trail_points.size() > MAX_TRAIL:
        trail_points.pop_back()
    $Trail.points = PackedVector2Array(trail_points)
    
    # Point toward movement
    if velocity.length() > 1:
        rotation = velocity.angle() + PI/2
```

**Behavior:**
- Pauses, then darts toward player
- Leaves light trail
- Damages on contact
- Dies in 2-3 hits

---

## REMNANT (Corrupted Salvager)

**Role:** Mirror player actions, use salvager abilities
**Threat Level:** High
**Speed:** Matches player

**Visual Design:**
```
Same silhouette as Salvager, BUT:
- Colors wrong (shifted to god's palette)
- Geometry corrupted (limbs too long, extra joints)
- Visor flickers between colors
- Trailing corruption particles
```

**Construction:**
```gdscript
extends SalvagerBody  # Inherits from player body
class_name EchoRemnant

func _ready():
    super._ready()
    corrupt_appearance()

func corrupt_appearance():
    # Shift all colors to current god's palette
    var god_color = Global.current_god_color  # e.g., magenta for Vorath
    
    for child in get_children():
        if child is Polygon2D:
            child.color = child.color.lerp(god_color, 0.6)
    
    # Distort geometry
    for child in get_children():
        if child is Polygon2D:
            var new_poly = PackedVector2Array()
            for point in child.polygon:
                # Add slight random displacement
                var displaced = point + Vector2(
                    randf_range(-3, 3),
                    randf_range(-3, 3)
                )
                # Elongate limbs
                displaced.y *= randf_range(1.0, 1.3)
                new_poly.append(displaced)
            child.polygon = new_poly
    
    # Visor flicker
    var flicker_tween = create_tween().set_loops()
    flicker_tween.tween_property($Head/Visor, "color:a", 0.3, 0.1)
    flicker_tween.tween_property($Head/Visor, "color:a", 1.0, 0.1)
    
    # Corruption particles
    var particles = GPUParticles2D.new()
    particles.process_material = create_corruption_particles()
    particles.amount = 20
    particles.lifetime = 1.5
    add_child(particles)
```

**Behavior:**
- Mirrors player movement (delayed by 0.5s)
- Uses same attacks player has
- Speaks in corrupted dialogue (your words, fragmented)
- Killing it grants bonus material but increases corruption

---

# NPCs (Station)

NPCs use the same construction as the player — polygon bodies, skeletal animation, unique accents.

## Differentiation

Each NPC is distinguished by:

**Body Proportions:**
- Tall/short (scale Y)
- Broad/narrow (scale X)
- Stance (bone rest positions)

**Suit Colors:**
- Faction base color
- Personal accent color

**Accessories:**
- Visible equipment (shoulder pads, belt pouches)
- Damage/wear (missing pieces, scorch marks)
- Faction insignia (geometric symbol on chest)

**Visor Style:**
- Shape (horizontal slit, vertical slit, cross, circle)
- Color (matches faction or personal)
- Animation (steady, flickering, pulsing)

## Example NPCs

**DISPATCH (Threshold Industries)**
```
- Tall, narrow build
- White suit with cyan accents
- Pristine, no damage
- Horizontal visor slit, steady cyan
- Stiff posture (barely moves)
```

**MARA (Feast Collective)**
```
- Average height, broader build
- Orange suit with gold accents
- Visible patches and repairs
- Warm orange visor, gentle pulse
- Relaxed posture, gestures when talking
```

**THE SEEKER (Church of the Open Wound)**
```
- Hunched, asymmetric
- Red suit with silver accents
- Deliberate damage (self-inflicted marks)
- Red visor that flickers erratically
- Swaying movement, unsettling
```

**VEX (Unlicensed)**
```
- Short, wiry
- Black suit with chaotic neon accents (multiple colors)
- Heavy wear, custom modifications
- Visor changes color based on mood
- Constant movement, never still
```

---

# CONSTRUCTION GUIDELINES FOR CLAUDE CODE

## When Building Characters

1. **Start with silhouette** — Get the shape right first
2. **Add base color** — Dark body, distinguish from background
3. **Add accent lights** — The glowing details that sell it
4. **Add skeleton** — For animation capability
5. **Add particles** — For life and presence
6. **Create animations** — Idle, move, act, damage, death
7. **Test in context** — Does it read against the environment?

## Performance Considerations

- Keep polygon counts low (16-32 points per part)
- Limit particle counts (20-50 per system)
- Use shared materials where possible
- Pool enemies rather than instantiating

## Scaling for 3D

If converting to 3D:
- Polygon2D → CSGBox3D/CSGCylinder3D/CSGPolygon3D
- Line2D → MeshInstance3D with simple tube mesh
- Skeleton2D → Skeleton3D
- Light2D → OmniLight3D
- GPUParticles2D → GPUParticles3D

Same visual principles apply. Keep it low-poly and stylized.
