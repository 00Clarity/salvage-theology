# SALVAGE THEOLOGY: IMPLEMENTATION
## Phased Build Guide for Claude Code

---

# OVERVIEW

This document provides step-by-step instructions for building Salvage Theology. Follow phases in order. Test each phase before moving on.

**Read these documents first:**
- FOUNDATION.md — Creative vision
- CHARACTERS.md — Character construction
- GODS.md — Dungeon design
- SYSTEMS.md — Game mechanics
- AUDIO.md — Sound design

---

# PHASE 1: CORE FOUNDATION
## Goal: Player moves in a room

**Time estimate:** 1-2 sessions

### Step 1.1: Project Setup

```
Create Godot 4 project structure:

salvage-theology/
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── player/
│   │   └── player.tscn
│   ├── rooms/
│   │   └── test_room.tscn
│   └── ui/
│       └── hud.tscn
├── scripts/
│   ├── player/
│   │   ├── player.gd
│   │   └── player_body.gd
│   ├── systems/
│   │   └── game_manager.gd
│   └── utils/
├── resources/
│   └── colors.tres
└── shaders/
```

### Step 1.2: Create Color Resources

Create `resources/colors.tres` with the palettes from FOUNDATION.md:

```gdscript
# Calyx colors
const CALYX_PRIMARY = Color("#00ffff")
const CALYX_SECONDARY = Color("#40e0d0")
const CALYX_DARK = Color("#0a2020")

# Player colors
const PLAYER_BASE = Color("#0a0f1a")
const PLAYER_ACCENT = Color("#00ffff")
const PLAYER_VISOR = Color("#00ffff")
```

### Step 1.3: Create Player (Polygon Construction)

Follow CHARACTERS.md "Salvager" section. Build the player from Polygon2D nodes.

**Checklist:**
- [ ] Head with helmet shape
- [ ] Visor as bright polygon
- [ ] Torso
- [ ] Arms (upper and lower, both sides)
- [ ] Legs (upper and lower, both sides)
- [ ] PointLight2D for visor glow
- [ ] Basic skeleton for animation prep

### Step 1.4: Player Movement

```gdscript
# player.gd
extends CharacterBody2D

@export var move_speed: float = 200.0

func _physics_process(delta):
    var input = Vector2.ZERO
    input.x = Input.get_axis("move_left", "move_right")
    input.y = Input.get_axis("move_up", "move_down")
    
    velocity = input.normalized() * move_speed
    move_and_slide()
```

### Step 1.5: Create Test Room

Simple room to test movement:
- TileMap or simple polygons for walls
- Floor area
- Collision shapes on walls

### Step 1.6: Test

**Verify:**
- [ ] Player renders (dark body, glowing visor)
- [ ] Player moves in 8 directions
- [ ] Player collides with walls
- [ ] Visor light affects environment

**Commit:** "Phase 1 complete: Basic player movement"

---

# PHASE 2: RESOURCES & HUD
## Goal: Oxygen depletes, player can die

**Time estimate:** 1-2 sessions

### Step 2.1: Resource System

Create `scripts/systems/resource_system.gd`:

```gdscript
class_name ResourceSystem
extends Node

signal resource_changed(resource_name, new_value, max_value)
signal resource_depleted(resource_name)

var oxygen: float = 100.0
var max_oxygen: float = 100.0
var oxygen_drain_rate: float = 1.0

func _process(delta):
    drain_oxygen(delta)

func drain_oxygen(delta):
    oxygen -= oxygen_drain_rate * delta
    oxygen = max(oxygen, 0)
    emit_signal("resource_changed", "oxygen", oxygen, max_oxygen)
    
    if oxygen <= 0:
        emit_signal("resource_depleted", "oxygen")
```

### Step 2.2: HUD

Create basic HUD showing:
- Oxygen bar (depleting)
- Visual warning when low

```gdscript
# hud.gd
extends CanvasLayer

@onready var oxygen_bar = $OxygenBar

func _on_resource_changed(resource_name, value, max_value):
    if resource_name == "oxygen":
        oxygen_bar.value = value
        oxygen_bar.max_value = max_value
        
        # Warning color when low
        if value < max_value * 0.25:
            oxygen_bar.modulate = Color.RED
        else:
            oxygen_bar.modulate = Color.CYAN
```

### Step 2.3: Death State

When oxygen depletes:
- Player movement stops
- Death animation plays
- Game over screen appears

### Step 2.4: Test

**Verify:**
- [ ] Oxygen bar displays and depletes
- [ ] Warning appears at low oxygen
- [ ] Player dies at zero oxygen
- [ ] Can restart after death

**Commit:** "Phase 2 complete: Resource system and death"

---

# PHASE 3: BASIC ROOM GENERATION
## Goal: Procedural rooms connect together

**Time estimate:** 2-3 sessions

### Step 3.1: Room Template

Create room data structure:

```gdscript
class_name RoomData
extends Resource

@export var width: int = 15
@export var height: int = 12
@export var doors: Array[Vector2i] = []  # Door positions
@export var room_type: String = "passage"
```

### Step 3.2: Room Generator

```gdscript
class_name RoomGenerator
extends Node

func generate_room(depth: int) -> RoomData:
    var room = RoomData.new()
    
    # Random size within bounds
    room.width = randi_range(12, 20)
    room.height = randi_range(10, 16)
    
    # Add 2-4 doors
    var door_count = randi_range(2, 4)
    for i in range(door_count):
        var door_pos = get_random_door_position(room)
        room.doors.append(door_pos)
    
    return room
```

### Step 3.3: Dungeon Generator

Connect rooms together:

```gdscript
class_name DungeonGenerator
extends Node

var rooms: Array[RoomData] = []
var room_instances: Dictionary = {}  # position -> RoomNode

func generate_dungeon(max_depth: int):
    # Start room
    var start_room = generate_room(1)
    place_room(start_room, Vector2i(0, 0))
    
    # Generate path to depth
    var current_pos = Vector2i(0, 0)
    for depth in range(2, max_depth + 1):
        var direction = get_random_direction()
        var next_pos = current_pos + direction
        var next_room = generate_room(depth)
        place_room(next_room, next_pos)
        connect_rooms(current_pos, next_pos)
        current_pos = next_pos
```

### Step 3.4: Room Transitions

When player reaches door:
- Load/activate adjacent room
- Teleport player to corresponding door
- Unload distant rooms

### Step 3.5: Test

**Verify:**
- [ ] Rooms generate with varying sizes
- [ ] Doors connect rooms
- [ ] Can traverse multiple rooms
- [ ] Distant rooms unload

**Commit:** "Phase 3 complete: Basic room generation"

---

# PHASE 4: CALYX THEOLOGY
## Goal: Doors require payment

**Time estimate:** 2-3 sessions

### Step 4.1: Door Entity

```gdscript
class_name TheologyDoor
extends Area2D

enum DoorState { LOCKED, PAID, OPEN }
enum PaymentType { ITEM, HEALTH, MEMORY }

var state: DoorState = DoorState.LOCKED
var accepted_payments: Array[PaymentType] = [
    PaymentType.ITEM, 
    PaymentType.HEALTH, 
    PaymentType.MEMORY
]

signal payment_requested(door)
signal door_opened(door)
```

### Step 4.2: Payment UI

When player interacts with locked door:
- Show payment options
- Player selects payment type
- Execute payment
- Open door

```gdscript
func show_payment_menu():
    var options = []
    
    if PaymentType.ITEM in accepted_payments:
        if player.has_items():
            options.append({"type": PaymentType.ITEM, "label": "Sacrifice Item"})
    
    if PaymentType.HEALTH in accepted_payments:
        if player.health > player.max_health * 0.15:
            options.append({"type": PaymentType.HEALTH, "label": "Sacrifice Health (10%)"})
    
    if PaymentType.MEMORY in accepted_payments:
        if player.has_memories():
            options.append({"type": PaymentType.MEMORY, "label": "Sacrifice Memory"})
    
    UI.show_choice_menu(options, on_payment_selected)
```

### Step 4.3: Payment Effects

```gdscript
func execute_payment(payment_type: PaymentType):
    match payment_type:
        PaymentType.ITEM:
            var item = player.inventory.pop_random()
            spawn_sacrifice_effect(item)
        PaymentType.HEALTH:
            player.take_damage(player.max_health * 0.1)
        PaymentType.MEMORY:
            player.forget_random_memory()
    
    state = DoorState.PAID
    open_door()
```

### Step 4.4: Door Permanence

Implement Rule 2: Open doors cannot close.

```gdscript
func open_door():
    state = DoorState.OPEN
    # Visual: door opens
    # Save to dungeon state - this door stays open forever
    DungeonManager.set_door_state(room_id, door_id, DoorState.OPEN)
```

### Step 4.5: Test

**Verify:**
- [ ] Doors start locked
- [ ] Payment menu appears on interaction
- [ ] Each payment type works correctly
- [ ] Doors stay open permanently
- [ ] Can traverse between rooms through paid doors

**Commit:** "Phase 4 complete: Calyx theology (doors)"

---

# PHASE 5: BASIC ENEMY
## Goal: Watcher enemy patrols and detects

**Time estimate:** 2 sessions

### Step 5.1: Echo Base Class

```gdscript
class_name EchoBase
extends CharacterBody2D

var max_health: float = 50.0
var health: float = max_health
var speed: float = 50.0
var detection_range: float = 150.0

enum State { IDLE, PATROL, ALERT, CHASE }
var current_state: State = State.PATROL

signal player_detected
signal died
```

### Step 5.2: Watcher Construction

Follow CHARACTERS.md "Watcher" section:
- Ring shape (Line2D circle)
- Central eye (Polygon2D)
- Glow (PointLight2D)
- Eye tracks player

### Step 5.3: Patrol Behavior

```gdscript
func _physics_process(delta):
    match current_state:
        State.PATROL:
            patrol_behavior(delta)
            check_for_player()
        State.ALERT:
            alert_behavior(delta)
        State.CHASE:
            chase_behavior(delta)

func patrol_behavior(delta):
    # Move between patrol points
    var target = patrol_points[current_patrol_index]
    var direction = (target - position).normalized()
    velocity = direction * speed
    move_and_slide()
    
    if position.distance_to(target) < 10:
        current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func check_for_player():
    var player = get_tree().get_first_node_in_group("player")
    if player and position.distance_to(player.position) < detection_range:
        enter_alert_state()
```

### Step 5.4: Alert System

Watcher doesn't attack directly — it alerts others.

```gdscript
func enter_alert_state():
    current_state = State.ALERT
    alert_timer = 2.0  # Player has 2 seconds to break line of sight
    play_alert_sound()
    show_alert_visual()

func alert_behavior(delta):
    alert_timer -= delta
    
    # Check if player still visible
    if not can_see_player():
        return_to_patrol()
        return
    
    if alert_timer <= 0:
        trigger_full_alert()

func trigger_full_alert():
    emit_signal("player_detected")
    # Alert all enemies in room
    for echo in get_tree().get_nodes_in_group("echo"):
        echo.on_player_alert(player.position)
```

### Step 5.5: Test

**Verify:**
- [ ] Watcher renders correctly (ring + eye)
- [ ] Eye tracks player
- [ ] Watcher patrols between points
- [ ] Detection triggers alert
- [ ] Alert can be avoided by breaking line of sight

**Commit:** "Phase 5 complete: Watcher enemy"

---

# PHASE 6: COMBAT
## Goal: Player can fight, enemies can damage

**Time estimate:** 2 sessions

### Step 6.1: Player Attack

```gdscript
# In player.gd
@export var attack_damage: float = 20.0
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 0.5

var can_attack: bool = true

func _input(event):
    if event.is_action_pressed("attack") and can_attack:
        perform_attack()

func perform_attack():
    can_attack = false
    
    # Get enemies in range
    var enemies = get_tree().get_nodes_in_group("echo")
    for enemy in enemies:
        if position.distance_to(enemy.position) < attack_range:
            enemy.take_damage(attack_damage)
    
    play_attack_animation()
    play_attack_sound()
    
    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true
```

### Step 6.2: Enemy Damage

```gdscript
# In echo_base.gd
func take_damage(amount: float):
    health -= amount
    flash_damage()
    play_hit_sound()
    
    if health <= 0:
        die()

func die():
    emit_signal("died")
    drop_loot()
    play_death_effect()
    queue_free()
```

### Step 6.3: Player Damage

```gdscript
# In player.gd
func take_damage(amount: float, type: DamageType = DamageType.PHYSICAL):
    if invincible:
        return
    
    health -= amount
    play_damage_effect()
    
    # Brief invincibility
    invincible = true
    await get_tree().create_timer(0.5).timeout
    invincible = false
    
    if health <= 0:
        die()
```

### Step 6.4: Seeker Enemy

Add a second enemy type that actually attacks:

```gdscript
class_name EchoSeeker
extends EchoBase

func chase_behavior(delta):
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return
    
    var direction = (player.position - position).normalized()
    velocity = direction * speed * 2  # Faster when chasing
    move_and_slide()
    
    # Damage on contact
    if position.distance_to(player.position) < 20:
        attack_player(player)
```

### Step 6.5: Test

**Verify:**
- [ ] Player attack animation plays
- [ ] Enemies take damage and die
- [ ] Enemies damage player on contact
- [ ] Player invincibility frames work
- [ ] Player can die from enemy damage

**Commit:** "Phase 6 complete: Combat system"

---

# PHASE 7: DIVINE MATERIAL & EXTRACTION
## Goal: Complete run loop

**Time estimate:** 2 sessions

### Step 7.1: Divine Material Pickup

```gdscript
class_name DivineMaterial
extends Area2D

@export var grade: int = 1  # 1-5
@export var value: int = 25

func _ready():
    body_entered.connect(_on_body_entered)
    create_visual()
    create_glow()

func _on_body_entered(body):
    if body.is_in_group("player"):
        body.collect_material(self)
        play_pickup_effect()
        queue_free()
```

### Step 7.2: Inventory System

```gdscript
# In player.gd
var inventory: Array[DivineMaterial] = []

func collect_material(material: DivineMaterial):
    inventory.append(material)
    update_corruption(material.value)
    play_collect_sound()
```

### Step 7.3: Corruption System

```gdscript
class_name CorruptionSystem
extends Node

var corruption: float = 0.0
const MAX_CORRUPTION: float = 100.0

func _process(delta):
    # Passive gain from carried material
    var material_value = player.get_total_material_value()
    corruption += material_value * 0.001 * delta
    
    check_corruption_effects()
```

### Step 7.4: Extraction Point

```gdscript
class_name ExtractionPoint
extends Area2D

func _on_body_entered(body):
    if body.is_in_group("player"):
        show_extraction_prompt()

func extract():
    # Calculate rewards
    var total_value = player.get_total_material_value()
    
    # End run successfully
    GameManager.end_run(true, {
        "material_value": total_value,
        "depth_reached": current_depth,
        "corruption": player.corruption
    })
```

### Step 7.5: Run Summary Screen

After extraction or death:
- Show material collected
- Show depth reached
- Show credits earned
- Option to return to station or dive again

### Step 7.6: Test

**Verify:**
- [ ] Material spawns in rooms
- [ ] Material can be collected
- [ ] Corruption increases while carrying material
- [ ] Extraction point works
- [ ] Run summary displays correct info
- [ ] Can start new run

**Commit:** "Phase 7 complete: Full run loop"

---

# PHASE 8: STATION & META-PROGRESSION
## Goal: Persistent upgrades between runs

**Time estimate:** 2-3 sessions

### Step 8.1: Station Scene

Create station hub with:
- Starting area (dive portal)
- Shop
- Upgrade station
- NPC positions (for later)

### Step 8.2: Currency System

```gdscript
# In game_manager.gd (autoload)
var credits: int = 0

func add_credits(amount: int):
    credits += amount
    save_game()

func spend_credits(amount: int) -> bool:
    if credits >= amount:
        credits -= amount
        save_game()
        return true
    return false
```

### Step 8.3: Upgrade System

```gdscript
var upgrades = {
    "oxygen_max": {"level": 0, "max_level": 5, "cost": [100, 200, 400, 800, 1600]},
    "health_max": {"level": 0, "max_level": 5, "cost": [150, 300, 600, 1200, 2400]},
}

func purchase_upgrade(upgrade_name: String) -> bool:
    var upgrade = upgrades[upgrade_name]
    if upgrade.level >= upgrade.max_level:
        return false
    
    var cost = upgrade.cost[upgrade.level]
    if spend_credits(cost):
        upgrade.level += 1
        apply_upgrade(upgrade_name)
        save_game()
        return true
    return false
```

### Step 8.4: Save/Load

```gdscript
func save_game():
    var save_data = {
        "credits": credits,
        "upgrades": upgrades,
        "unlocks": unlocks,
        "statistics": statistics
    }
    
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func load_game():
    if FileAccess.file_exists("user://save.json"):
        var file = FileAccess.open("user://save.json", FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())
        file.close()
        
        credits = data.credits
        upgrades = data.upgrades
        # etc.
```

### Step 8.5: Test

**Verify:**
- [ ] Station renders and is navigable
- [ ] Credits persist between runs
- [ ] Upgrades can be purchased
- [ ] Upgrades affect gameplay
- [ ] Save/load works correctly

**Commit:** "Phase 8 complete: Station and meta-progression"

---

# PHASE 9: POLISH - VISUALS
## Goal: Game looks good

**Time estimate:** 2-3 sessions

### Step 9.1: Player Polish

- Add walking animation (bone-based)
- Add idle animation (breathing, visor pulse)
- Add damage flash
- Add corruption visual shift
- Add particle trail when damaged

### Step 9.2: Environment Polish

- Add ambient particles (floating divine dust)
- Add lighting variations per room
- Add fog/atmosphere effect
- Add screen shake on impacts
- Add chromatic aberration when damaged/low sanity

### Step 9.3: Enemy Polish

- Add smooth eye tracking
- Add alert indicators
- Add death effects (particles, flash)
- Add idle animations

### Step 9.4: UI Polish

- Animate resource bars
- Add screen transitions
- Add damage vignette
- Polish menus

### Step 9.5: Test

**Verify:**
- [ ] Animations play smoothly
- [ ] Visual feedback is clear
- [ ] Performance is acceptable
- [ ] Aesthetics match FOUNDATION.md vision

**Commit:** "Phase 9 complete: Visual polish"

---

# PHASE 10: POLISH - AUDIO
## Goal: Game sounds good

**Time estimate:** 2 sessions

### Step 10.1: Implement Audio Systems

Follow AUDIO.md to implement:
- Ambient drones
- God-specific layers
- Footstep sounds
- Combat sounds
- UI sounds

### Step 10.2: Music System

Implement generative music:
- Base drone (always playing)
- Tension layer (combat)
- Depth layer (deeper = more ominous)

### Step 10.3: Audio Mixing

- Set up audio buses
- Balance levels
- Add reverb for space
- Add limiter to master

### Step 10.4: Test

**Verify:**
- [ ] Ambient sound creates atmosphere
- [ ] Sound effects play at right times
- [ ] Music responds to game state
- [ ] Audio doesn't clip or distort

**Commit:** "Phase 10 complete: Audio polish"

---

# PHASE 11: ADDITIONAL CONTENT
## Goal: More gods, more enemies, more items

**Time estimate:** Variable (4-8 sessions)

### Step 11.1: Vorath (Second God)

- Implement Vorath color palette
- Implement Vorath theology rules
- Create Vorath-specific enemies
- Create Vorath room templates

### Step 11.2: Selen (Third God)

- Implement Selen color palette
- Implement Selen theology rules
- Create Selen-specific enemies
- Create Selen room templates

### Step 11.3: More Enemies

- Guardian (blocking enemy)
- Remnant (corrupted salvager)
- God-specific variants

### Step 11.4: Equipment System

- Equipment drops
- Equipment slots
- Equipment effects
- Equipment UI

### Step 11.5: Test Each Addition

**Verify each new element before moving on.**

**Commit frequently:** "Added Vorath god", "Added Guardian enemy", etc.

---

# PHASE 12: WEB EXPORT & DEPLOYMENT
## Goal: Playable in browser

### Step 12.1: Configure Export

1. Open Project → Export
2. Add Web preset
3. Configure:
   - Enable VRAM compression
   - Enable threads if needed (experimental)
   - Set HTML wrapper

### Step 12.2: Test Export

```bash
# Export from command line
godot --headless --export-release "Web" ./build/index.html

# Test locally
cd build
python -m http.server 8000
# Open http://localhost:8000
```

### Step 12.3: Deploy

**Itch.io:**
1. Create project on itch.io
2. Zip contents of `build/` folder
3. Upload zip
4. Set launch file to `index.html`

**GitHub Pages:**
1. Push build to gh-pages branch
2. Enable Pages in repo settings
3. Access at `username.github.io/salvage-theology`

### Step 12.4: Test Deployed Version

**Verify:**
- [ ] Game loads in browser
- [ ] No console errors
- [ ] Performance acceptable
- [ ] Save/load works (localStorage)
- [ ] Audio works (may need user interaction to start)

**Commit:** "Phase 12 complete: Web deployment"

---

# TESTING CHECKLIST

After each phase, verify:

- [ ] No crashes
- [ ] No console errors
- [ ] Performance stable (60fps target)
- [ ] Core mechanic works as intended
- [ ] Commit made with descriptive message
- [ ] DEVLOG.md updated

---

# COMMON ISSUES

**Web audio doesn't play:**
- Godot web exports require user interaction before audio
- Add a "Click to Start" screen

**Save doesn't persist:**
- Web uses localStorage, which has limits
- Check for errors in browser console

**Performance issues:**
- Reduce particle counts
- Unload distant rooms
- Use lower resolution

**Physics behave differently:**
- Web exports may have minor physics differences
- Test frequently in browser, not just editor
