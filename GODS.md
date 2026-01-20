# SALVAGE THEOLOGY: GODS
## Dungeon Design, Theology, and Generation

---

# OVERVIEW

Each god is:
- A **procedurally generated dungeon** with consistent theme
- Governed by **theology** — rules the player must learn
- Visually distinct with **unique color palette and architecture**
- Increasingly dangerous with **depth**
- Home to **unique Echoes** that enforce the rules

---

# DUNGEON STRUCTURE

## Universal Structure

All gods share this macro-structure:

```
ENTRY ZONE (Depth 1-2)
├── Tutorial-like rooms
├── Basic theology introduction
├── Few enemies, forgiving
└── Low-value material

OUTER SANCTUM (Depth 3-5)
├── Full theology in effect
├── Standard enemy density
├── More complex room layouts
└── Medium-value material

INNER SANCTUM (Depth 6-8)
├── Theology rules combine
├── Elite enemies appear
├── Environmental hazards increase
└── High-value material

THE CORE (Depth 9-10)
├── Maximum theology complexity
├── Guardian presence
├── The god is most "alive" here
└── Legendary material, extreme danger
```

## Room Generation

### Room Templates

Each god has 15-20 room templates that are:
- Procedurally placed and connected
- Rotated and mirrored for variety
- Scaled slightly (±15%)
- Populated based on depth

### Connection Rules

```
RULES:
1. Every room has 1-4 doors
2. Doors must connect to doors (no dead ends in geometry)
3. Critical path always exists to extraction
4. Side paths contain optional treasure and danger
5. Backtracking is possible but costs resources
```

### Room Types

**PASSAGE** — Simple connector, 1-2 enemies, minimal loot
**CHAMBER** — Larger room, 3-5 enemies, moderate loot
**VAULT** — Treasure room, guarded, high loot
**SANCTUM** — Theology puzzle room, requires understanding to pass
**HAZARD** — Environmental danger, skill-based traversal
**REST** — Safe zone, oxygen cache, no enemies

Distribution by depth:
```
Depth 1-2: 50% Passage, 30% Chamber, 10% Vault, 10% Rest
Depth 3-5: 30% Passage, 40% Chamber, 15% Vault, 10% Sanctum, 5% Rest
Depth 6-8: 20% Passage, 30% Chamber, 20% Vault, 20% Sanctum, 10% Hazard
Depth 9-10: 10% Passage, 30% Chamber, 25% Vault, 25% Sanctum, 10% Hazard
```

---

# GOD: CALYX (THRESHOLDS)

## Identity

**Domain:** Doors, passages, transitions, liminality
**Meaning:** The space between states, the cost of change
**Emotional Core:** Every transition requires sacrifice

## Visual Design

### Color Palette
```
Primary:    #00ffff (cyan)
Secondary:  #40e0d0 (teal)
Tertiary:   #008080 (deep teal)
Accent:     #ffffff (white)
Dark:       #0a2020
Background: #061515
```

### Architecture

**Style:** Infinite doorways, impossible passages

**Elements:**
- Doorframes everywhere (some lead somewhere, some don't)
- Corridors that bend in ways they shouldn't
- Rooms that are bigger inside than outside
- Stairs that go sideways
- Light with no source (the threshold itself glows)

**Construction (2D):**
```gdscript
# Calyx wall tile
func create_calyx_wall_tile() -> Polygon2D:
    var tile = Polygon2D.new()
    tile.polygon = PackedVector2Array([
        Vector2(0, 0), Vector2(32, 0),
        Vector2(32, 32), Vector2(0, 32)
    ])
    tile.color = Color("#0a2020")
    
    # Add doorframe motif
    var frame = Line2D.new()
    frame.points = PackedVector2Array([
        Vector2(8, 32), Vector2(8, 8),
        Vector2(24, 8), Vector2(24, 32)
    ])
    frame.width = 2.0
    frame.default_color = Color("#40e0d0")
    tile.add_child(frame)
    
    return tile

# Calyx floor tile
func create_calyx_floor_tile() -> Polygon2D:
    var tile = Polygon2D.new()
    tile.polygon = PackedVector2Array([
        Vector2(0, 0), Vector2(32, 0),
        Vector2(32, 32), Vector2(0, 32)
    ])
    tile.color = Color("#061515")
    
    # Add grid pattern
    var grid = Line2D.new()
    grid.points = PackedVector2Array([
        Vector2(16, 0), Vector2(16, 32)
    ])
    grid.width = 1.0
    grid.default_color = Color("#00ffff", 0.1)
    tile.add_child(grid)
    
    return tile
```

### Lighting

- Cool, even illumination
- Doorframes emit soft glow
- Shadows are sharp-edged
- Light appears to come from thresholds themselves

## Theology

### Rule 1: Payment

**"Every door requires payment."**

To pass through any door, you must pay ONE of:
- **Item** — Lose one inventory item
- **Health** — Lose 10% max health
- **Memory** — Lose one piece of learned information (map reveals, theology notes)

**Implementation:**
```gdscript
# Door interaction
func interact_with_door():
    if door_state == LOCKED:
        show_payment_menu()
    elif door_state == PAID:
        open_door()

func show_payment_menu():
    var options = []
    if player.inventory.size() > 0:
        options.append("Sacrifice item")
    if player.health > player.max_health * 0.1:
        options.append("Sacrifice health")
    if player.memories.size() > 0:
        options.append("Sacrifice memory")
    
    UI.show_choice(options, on_payment_selected)

func on_payment_selected(choice):
    match choice:
        "Sacrifice item":
            var item = player.inventory.pop_back()
            spawn_sacrifice_effect(item)
        "Sacrifice health":
            player.health -= player.max_health * 0.1
            spawn_blood_effect()
        "Sacrifice memory":
            var memory = player.memories.pop_back()
            spawn_fade_effect(memory)
    
    door_state = PAID
    open_door()
```

**Exploit:** Some items are worthless. Hoard junk for door payment.
**Counter:** Certain doors require specific payment types.

### Rule 2: Permanence

**"A door opened cannot be closed."**

Once you open a door, it stays open. Forever.

**Implications:**
- Enemies can follow you through
- Backtracking is always possible
- You're creating paths as you go
- The dungeon becomes more connected over time

**Implementation:**
```gdscript
func open_door():
    door_state = OPEN
    # Door stays open permanently
    # Save this in room state
    room_manager.set_door_state(room_id, door_id, OPEN)
    
    # Never closes
    # No close_door() function exists
```

**Exploit:** Open doors to create escape routes before engaging enemies.
**Counter:** Some enemies are held back by closed doors — opening releases them.

### Rule 3: Sanctuary

**"Standing in a threshold protects you."**

While you are positioned within a doorframe (the liminal space), you cannot be damaged.

**Implementation:**
```gdscript
# In player damage handler
func take_damage(amount):
    if is_in_threshold():
        spawn_protection_effect()
        return  # No damage
    
    health -= amount
    # etc.

func is_in_threshold():
    var overlapping = $HitBox.get_overlapping_areas()
    for area in overlapping:
        if area.is_in_group("threshold"):
            return true
    return false
```

**Exploit:** Stand in doorways to avoid all damage.
**Counter:** You can't attack from a threshold either. And enemies will wait.

### Rule 4: Indirection

**"The direct path is never the true path."**

If you can see your destination directly (same room, straight line), that route will harm you. You must find an indirect path.

**Implementation:**
```gdscript
# Check if player is taking "direct path" to objective
func _process(delta):
    if current_objective:
        var direct_path = has_line_of_sight(player.position, current_objective.position)
        var in_same_room = player.current_room == current_objective.current_room
        
        if direct_path and in_same_room and player.is_moving_toward(current_objective):
            apply_indirection_damage(delta)
            show_warning("The direct path burns...")

func apply_indirection_damage(delta):
    player.take_damage(5 * delta)
```

**Exploit:** Break line of sight, move behind obstacles.
**Counter:** Some rooms are designed with minimal cover.

## Hazards

### Loop Corridors
Taking the same turn three times returns you to the room you started in.

### Crushing Walls
Some rooms slowly close. Find and pass through a door before crushed.

### False Doors
Some doors look real but lead to solid wall. Payment is consumed, nothing gained.

### Memory Fog
Certain zones cause your map to fade. The room you're in is clear; adjacent rooms become uncertain.

## Echoes (Calyx-Specific)

**Watcher** — Standard (see CHARACTERS.md)
**Guardian** — Door-shaped blocker (see CHARACTERS.md)
**Threshold Keeper** — Elite enemy that can close doors you've opened (violates Rule 2)
**Loop Walker** — Appears in loop corridors, forces you into loops

---

# GOD: VORATH (APPETITE)

## Identity

**Domain:** Hunger, consumption, desire, the void inside
**Meaning:** The cycle of need and fulfillment, the impossibility of satisfaction
**Emotional Core:** To desire is to suffer

## Visual Design

### Color Palette
```
Primary:    #ff00ff (magenta)
Secondary:  #ffd700 (gold)
Tertiary:   #dc143c (crimson)
Accent:     #ffff00 (yellow)
Dark:       #2a0a2a
Background: #150515
```

### Architecture

**Style:** Organic, digestive, opulent

**Elements:**
- Curved walls like the inside of a stomach
- Golden light that feels like honey
- Teeth-like protrusions along passages
- Pools of unknown liquid (magenta, glowing)
- Treasure everywhere (but at what cost?)

**Construction:**
```gdscript
# Vorath wall tile - curved, organic
func create_vorath_wall_tile() -> Polygon2D:
    var tile = Polygon2D.new()
    # Curved edge instead of straight
    var points = PackedVector2Array()
    points.append(Vector2(0, 0))
    for i in range(5):
        var x = 6 + i * 5
        var y = sin(i * 0.5) * 4  # Curved
        points.append(Vector2(x, y))
    points.append(Vector2(32, 0))
    points.append(Vector2(32, 32))
    points.append(Vector2(0, 32))
    tile.polygon = points
    tile.color = Color("#2a0a2a")
    
    # Add vein-like pattern
    var vein = Line2D.new()
    vein.points = PackedVector2Array([
        Vector2(5, 16), Vector2(16, 12), Vector2(27, 18)
    ])
    vein.width = 2.0
    vein.default_color = Color("#ff00ff", 0.3)
    tile.add_child(vein)
    
    return tile
```

### Lighting

- Warm, golden, like late afternoon sun
- Pools of magenta glow
- Shadows are soft and hungry
- Everything looks delicious (and dangerous)

## Theology

### Rule 1: Exchange

**"What you take, Vorath takes from you."**

Picking up divine material in Vorath immediately costs you something — health, oxygen, sanity. The better the material, the higher the cost.

**Implementation:**
```gdscript
func pickup_material(material):
    var cost = material.value * 0.1
    
    # Vorath chooses what to take
    var resource = ["health", "oxygen", "sanity"][randi() % 3]
    match resource:
        "health":
            player.health -= cost
            show_text("Vorath feeds on your vitality")
        "oxygen":
            player.oxygen -= cost
            show_text("Vorath breathes through you")
        "sanity":
            player.sanity -= cost
            show_text("Vorath whispers in your mind")
    
    player.inventory.add(material)
```

**Exploit:** Be selective — take only high-value material.
**Counter:** Sometimes the only way forward requires taking something.

### Rule 2: Redirection

**"Hunger can be redirected."**

You can feed items to Vorath (drop them in the glowing pools). This sates the god temporarily, reducing ambient damage and calming enemies.

**Implementation:**
```gdscript
func feed_vorath(item):
    var satiation = item.value * 0.5
    vorath_hunger -= satiation
    
    # Temporarily calm all enemies
    for echo in get_tree().get_nodes_in_group("echo"):
        echo.calm(satiation * 0.5)  # Duration in seconds
    
    # Reduce ambient damage
    ambient_damage_multiplier = 0.5
    await get_tree().create_timer(satiation).timeout
    ambient_damage_multiplier = 1.0
    
    show_text("Vorath is sated... for now")
```

**Exploit:** Feed junk to create safe windows.
**Counter:** Vorath's hunger grows faster as you go deeper.

### Rule 3: The Sacred Starving

**"The starving are sacred."**

Enemies at low health enter a "starving" state. Killing a starving enemy is a theology violation — Vorath punishes you. You must let them retreat or feed them.

**Implementation:**
```gdscript
# In enemy AI
func _process(delta):
    if health < max_health * 0.2:
        enter_starving_state()

func enter_starving_state():
    state = STATE_STARVING
    # Visual change
    modulate = Color(1, 1, 0.5)
    # Stop attacking
    attacking = false
    # Try to retreat
    target_position = find_retreat_point()

# In player attack
func attack_enemy(enemy):
    if enemy.state == STATE_STARVING:
        # Theology violation!
        violate_theology("sacred_starving")
        trigger_vorath_punishment()
    else:
        deal_damage(enemy)

func trigger_vorath_punishment():
    # Vorath drains all resources rapidly
    player.health -= player.max_health * 0.3
    player.oxygen -= player.max_oxygen * 0.3
    player.sanity -= player.max_sanity * 0.3
    show_text("VORATH HUNGERS")
```

**Exploit:** Let enemies starve, then ignore them.
**Counter:** Starving enemies still block paths and call reinforcements.

### Rule 4: Offering

**"Offer before you ask."**

Before taking material from a vault or treasure room, you must place something in the offering basin. The value of your offering determines what you're allowed to take.

**Implementation:**
```gdscript
# Treasure room
var offering_value = 0
var treasure_available = []

func interact_with_basin():
    show_offering_menu(player.inventory)

func make_offering(item):
    offering_value += item.value
    player.inventory.remove(item)
    spawn_consume_effect(item)
    update_treasure_availability()

func update_treasure_availability():
    for treasure in all_treasure:
        if treasure.value <= offering_value * 1.5:
            treasure.set_available(true)
        else:
            treasure.set_available(false)

func take_treasure(treasure):
    if not treasure.is_available:
        violate_theology("insufficient_offering")
        trigger_vorath_punishment()
    else:
        player.inventory.add(treasure)
        offering_value -= treasure.value
```

**Exploit:** Offer cheap items, take expensive ones (1.5x multiplier).
**Counter:** The best treasures require significant offerings.

## Hazards

### Digestive Zones
Areas that slowly drain all resources. Must pass through quickly.

### Feeding Pits
Require item sacrifice to cross. Bridges extend only after feeding.

### Hunger Aura
Enemies emit aura that drains your resources when near. Keep distance.

### Golden Traps
Treasure that looks valuable but triggers when taken. Must offer first.

## Echoes (Vorath-Specific)

**Maw** — Stationary, blocks paths, must be fed to pass
**Parasite** — Attaches and drains resources over time
**Hollow One** — Starving from the start, sacred, blocks path without violence
**The Glutted** — Overfed Echo, explodes on death damaging everything nearby

---

# GOD: SELEN (FORGETTING)

## Identity

**Domain:** Memory, loss, peace, oblivion
**Meaning:** The kindness and cruelty of forgetting
**Emotional Core:** What we forget sets us free (and destroys us)

## Visual Design

### Color Palette
```
Primary:    #e6e6fa (lavender)
Secondary:  #c0c0c0 (silver)
Tertiary:   #b0e0e6 (pale blue)
Accent:     #ffffff (white)
Dark:       #1a1a2a
Background: #0f0f1a
```

### Architecture

**Style:** Fading, uncertain, dreamlike

**Elements:**
- Edges are soft, not sharp
- Rooms seem to dissolve at the periphery
- Walls fade in and out of visibility
- Some rooms weren't there a moment ago
- Light is diffuse, sourceless, peaceful

**Construction:**
```gdscript
# Selen wall tile - faded edges
func create_selen_wall_tile() -> Polygon2D:
    var tile = Polygon2D.new()
    tile.polygon = PackedVector2Array([
        Vector2(0, 0), Vector2(32, 0),
        Vector2(32, 32), Vector2(0, 32)
    ])
    tile.color = Color("#1a1a2a")
    
    # Gradient shader for faded edges
    var shader_material = ShaderMaterial.new()
    shader_material.shader = preload("res://shaders/fade_edges.gdshader")
    tile.material = shader_material
    
    return tile

# Fade edges shader
# res://shaders/fade_edges.gdshader
shader_type canvas_item;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    
    // Fade edges
    float edge_fade = smoothstep(0.0, 0.1, UV.x) * smoothstep(0.0, 0.1, UV.y);
    edge_fade *= smoothstep(0.0, 0.1, 1.0 - UV.x) * smoothstep(0.0, 0.1, 1.0 - UV.y);
    
    // Soft noise
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
    edge_fade *= 0.8 + noise * 0.2;
    
    COLOR = vec4(col.rgb, col.a * edge_fade);
}
```

### Lighting

- Soft, diffuse, no harsh shadows
- Everything slightly hazy
- Light sources are unclear
- The deeper you go, the softer everything becomes

## Theology

### Rule 1: Preservation

**"What is remembered is preserved."**

Things you focus on remain solid. Things you ignore begin to fade. Rooms you haven't visited recently become uncertain. Information you haven't accessed becomes unreliable.

**Implementation:**
```gdscript
# Room memory system
var room_memory = {}  # room_id: last_visit_time

func _process(delta):
    for room_id in room_memory:
        var time_since_visit = current_time - room_memory[room_id]
        var room = get_room(room_id)
        
        # Fade rooms based on time
        if time_since_visit > 60:  # 1 minute
            room.fade_level = 0.5
            room.layout_uncertain = true
        if time_since_visit > 120:  # 2 minutes
            room.fade_level = 0.2
            room.may_change = true

func visit_room(room_id):
    room_memory[room_id] = current_time
    var room = get_room(room_id)
    room.fade_level = 1.0
    room.layout_uncertain = false
    room.may_change = false
```

**Exploit:** Revisit important rooms to keep them stable.
**Counter:** Time spent revisiting is time not progressing.

### Rule 2: Release

**"What is forgotten is free."**

You can choose to forget things — skills, map knowledge, item locations. Forgetting grants benefits:
- Forget a skill → Pass through a barrier that blocks the skilled
- Forget the map → Become invisible to Echoes briefly
- Forget an item → It reappears elsewhere, possibly improved

**Implementation:**
```gdscript
func forget_skill(skill):
    player.skills.erase(skill)
    player.add_buff("forgotten_passage", 30)  # 30 second buff
    show_text("The barrier does not see you")

func forget_map():
    player.map_data.clear()
    player.add_buff("invisible", 10)  # 10 seconds
    show_text("You are no one, nowhere")

func forget_item(item):
    var improved_item = improve_item(item)
    place_item_somewhere_in_dungeon(improved_item)
    player.inventory.erase(item)
    show_text("It will find you again, changed")
```

**Exploit:** Strategic forgetting for specific benefits.
**Counter:** Forgotten things are genuinely gone — skills don't come back.

### Rule 3: Names

**"Speaking a name binds it."**

In Selen, saying (selecting/using) a specific name calls it to you. This can be useful (call an item) or dangerous (call an enemy, call your death).

**Implementation:**
```gdscript
# Name system
func speak_name(name):
    if things_with_name.has(name):
        var thing = things_with_name[name]
        call_thing_to_player(thing)
    else:
        # Unknown names may create something
        var created = generate_from_name(name)
        things_with_name[name] = created
        call_thing_to_player(created)

func call_thing_to_player(thing):
    if thing is Enemy:
        thing.teleport_near(player)
        thing.aggro_player()
        show_text("It heard you")
    elif thing is Item:
        thing.teleport_to(player.position)
        show_text("It returns")
```

**Exploit:** Call items you've seen to your location.
**Counter:** Enemies can be called too. Be careful with names.

### Rule 4: Silence

**"Silence is sanctuary."**

Making noise (attacking, running, using abilities) draws attention. Perfect silence makes you invisible to all but direct sight.

**Implementation:**
```gdscript
var silence_timer = 0.0
const SILENCE_THRESHOLD = 3.0

func _process(delta):
    if not is_making_noise():
        silence_timer += delta
        if silence_timer >= SILENCE_THRESHOLD:
            player.add_buff("sanctuary", 0)  # Indefinite until broken
    else:
        silence_timer = 0.0
        player.remove_buff("sanctuary")

func is_making_noise():
    return player.is_attacking or player.is_running or player.using_ability

# Enemy sight check
func can_see_player():
    if player.has_buff("sanctuary"):
        # Can only see if looking directly
        return is_looking_at(player.position) and distance_to(player) < 3
    else:
        return has_line_of_sight(player.position)
```

**Exploit:** Walk slowly, don't attack, remain invisible.
**Counter:** Some enemies always see you. And you can't stay silent forever.

## Hazards

### Fog of Forgetting
Zones where your map fades rapidly. Navigate by memory (yours, not the game's).

### Memory Anchors
Glowing points you must remember and return to. Forgetting them closes paths permanently.

### Name Traps
Glyphs on walls. Reading them (looking too long) speaks the name, summoning something.

### Fading Floors
Platforms that exist only while you remember them. Look away too long and they're gone.

## Echoes (Selen-Specific)

**Fader** — Visible only when looking directly at it. Attacks from peripheral vision.
**Whisperer** — Forces you to "speak" names, summoning other threats.
**The Forgotten** — Doesn't know it's an enemy. Confused, sad, dangerous by accident.
**Memory Keeper** — Hoards your lost memories. Killing it restores what you forgot.

---

# ROOM GENERATION ALGORITHM

## Phase 1: Layout

```gdscript
func generate_dungeon(depth_max: int) -> Array[Room]:
    var rooms = []
    var grid = {}  # Vector2i -> Room
    
    # Start with entry room
    var entry = create_room(RoomType.REST, 1)
    entry.position = Vector2i(0, 0)
    rooms.append(entry)
    grid[entry.position] = entry
    
    # Generate main path
    var current = entry
    for depth in range(2, depth_max + 1):
        var next_pos = find_adjacent_empty(current.position, grid)
        var room_type = roll_room_type(depth)
        var room = create_room(room_type, depth)
        room.position = next_pos
        rooms.append(room)
        grid[next_pos] = room
        
        # Connect rooms
        connect_rooms(current, room)
        current = room
    
    # Add branches
    for room in rooms:
        if randf() < 0.3:  # 30% chance for branch
            add_branch(room, grid, rooms)
    
    return rooms

func roll_room_type(depth: int) -> RoomType:
    var weights = get_room_weights(depth)
    return weighted_random(weights)
```

## Phase 2: Populate

```gdscript
func populate_room(room: Room, god: God):
    # Add enemies based on depth and room type
    var enemy_count = calculate_enemy_count(room)
    for i in range(enemy_count):
        var enemy_type = roll_enemy_type(room.depth, god)
        var position = find_spawn_point(room)
        spawn_enemy(enemy_type, position, room)
    
    # Add material
    var material_count = calculate_material_count(room)
    for i in range(material_count):
        var material = generate_material(room.depth, god)
        var position = find_item_point(room)
        place_material(material, position, room)
    
    # Add hazards
    if room.type == RoomType.HAZARD:
        add_hazards(room, god)
    
    # Add theology elements
    add_theology_elements(room, god)
```

## Phase 3: Theology Specifics

```gdscript
func add_theology_elements(room: Room, god: God):
    match god.name:
        "Calyx":
            # Add doors that require payment
            for door in room.doors:
                door.requires_payment = true
                door.payment_types = ["item", "health", "memory"]
            
            # Add threshold zones
            for door in room.doors:
                add_threshold_zone(door.position)
        
        "Vorath":
            # Add feeding basins
            if room.type == RoomType.VAULT:
                add_offering_basin(room)
            
            # Add digestive zones
            if randf() < 0.3:
                add_digestive_zone(room)
        
        "Selen":
            # Add memory anchors
            if room.depth > 5:
                add_memory_anchor(room)
            
            # Add name glyphs
            if randf() < 0.2:
                add_name_glyph(room)
```

---

# VISUAL GENERATION

## Tilemap Creation

Each god's tileset is generated procedurally:

```gdscript
func generate_tileset(god: God) -> TileSet:
    var tileset = TileSet.new()
    
    # Wall tile
    var wall = create_wall_tile(god)
    tileset.add_source(wall)
    
    # Floor tile
    var floor = create_floor_tile(god)
    tileset.add_source(floor)
    
    # Door tile (multiple states)
    var door = create_door_tile(god)
    tileset.add_source(door)
    
    # Hazard tiles
    for hazard_type in god.hazard_types:
        var hazard = create_hazard_tile(god, hazard_type)
        tileset.add_source(hazard)
    
    # Special tiles
    for special in god.special_tiles:
        var tile = create_special_tile(god, special)
        tileset.add_source(tile)
    
    return tileset
```

## Room Rendering

```gdscript
func render_room(room: Room, god: God):
    var tilemap = TileMap.new()
    tilemap.tile_set = god.tileset
    
    # Fill floor
    for x in range(room.width):
        for y in range(room.height):
            tilemap.set_cell(0, Vector2i(x, y), FLOOR_TILE)
    
    # Draw walls
    for wall in room.walls:
        tilemap.set_cell(0, wall.position, WALL_TILE)
    
    # Place doors
    for door in room.doors:
        tilemap.set_cell(0, door.position, DOOR_TILE)
    
    # Add lighting
    add_room_lighting(room, god)
    
    # Add particles
    add_room_particles(room, god)
    
    room.add_child(tilemap)
```

---

# PERFORMANCE NOTES

## Room Loading

Only keep 3 rooms loaded at once:
- Current room
- Adjacent rooms (visible through doors)

Unload rooms beyond that. Reload when needed.

## Enemy Pooling

Pre-instantiate enemies. Reuse rather than spawn/despawn.

## Particle Limits

Cap particles per room at 200. Reduce for mobile.

## LOD for 3D

If using 3D:
- Near: Full detail
- Medium: Reduced geometry
- Far: Silhouettes only
