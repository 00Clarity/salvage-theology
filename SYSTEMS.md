# SALVAGE THEOLOGY: SYSTEMS
## Game Mechanics, Formulas, and Progression

---

# RESOURCE SYSTEMS

## Oxygen

**What it is:** Your suit's air supply. The divine atmosphere is unbreathable.

**Behavior:**
- Maximum: 100 units (upgradeable)
- Depletion: 1 unit per second (base rate)
- Depletion increases with depth: `rate = 1 + (depth * 0.1)`
- At Depth 10: 2 units per second

**Refill Sources:**
- Oxygen caches (fixed locations): +50
- Oxygen canisters (inventory): +25
- Rest rooms: Full refill
- Extraction: Resets to full

**At Zero:**
- 10-second grace period (gasping)
- Then forced extraction OR
- Death if extraction unavailable

```gdscript
class_name OxygenSystem

var oxygen: float = 100.0
var max_oxygen: float = 100.0
var base_depletion_rate: float = 1.0

func _process(delta):
    var depth_modifier = 1.0 + (current_depth * 0.1)
    var rate = base_depletion_rate * depth_modifier
    
    oxygen -= rate * delta
    oxygen = clamp(oxygen, 0, max_oxygen)
    
    if oxygen <= 0:
        trigger_suffocation()

func refill(amount: float):
    oxygen = min(oxygen + amount, max_oxygen)
    spawn_refill_effect()

func trigger_suffocation():
    if not suffocating:
        suffocating = true
        grace_timer = 10.0
        show_warning("OXYGEN CRITICAL")
        start_gasping_effects()
```

---

## Light

**What it is:** Your visor's filter against divine radiance.

**Behavior:**
- Maximum: 100 units (upgradeable)
- Depletion: 0 in normal areas
- Depletion in high-divinity zones: 5 units per second
- Near divine material: 2 units per second
- Can be turned off manually (conserves light, but...)

**At Zero:**
- You see the "true form" of things
- Sanity drains rapidly (5 per second)
- BUT: You can see hidden things (secrets, traps, true paths)
- Some puzzles require this state

**Refill Sources:**
- Light caches: +30
- Light cells (inventory): +20
- Rest rooms: Full refill
- Leaving high-divinity zone: Stops drain, doesn't refill

```gdscript
class_name LightSystem

var light: float = 100.0
var max_light: float = 100.0
var filter_active: bool = true

func _process(delta):
    if not filter_active:
        return  # No drain when off, but sanity drains instead
    
    var drain = calculate_drain()
    light -= drain * delta
    light = clamp(light, 0, max_light)
    
    if light <= 0:
        enter_true_sight()

func calculate_drain() -> float:
    var drain = 0.0
    
    # Check zone
    if is_in_high_divinity_zone():
        drain += 5.0
    
    # Check nearby material
    var nearby_material = get_nearby_divine_material()
    drain += nearby_material.size() * 0.5
    
    return drain

func enter_true_sight():
    true_sight_active = true
    apply_true_sight_shader()
    reveal_hidden_elements()
    sanity_system.set_drain_multiplier(5.0)
```

---

## Sanity

**What it is:** Your mental coherence in the face of the divine.

**Behavior:**
- Maximum: 100 units (upgradeable)
- Depletion sources:
  - Witnessing impossible geometry: -5 per instance
  - Reading divine text: -10 per inscription
  - Extended time in god (>10 min): -1 per minute
  - True sight active: -5 per second
  - Near Remnant (corrupted salvager): -2 per second

**Low Sanity Effects:**
- 75-50%: Mild hallucinations (shadows move, sounds misheard)
- 50-25%: Moderate hallucinations (fake enemies, UI glitches)
- 25-1%: Severe hallucinations (reality breaks, god speaks to you)
- 0%: Transformation (not death — you become something else)

**Refill Sources:**
- Rest rooms: +30
- Meditation (stand still for 10s): +5
- Completing a theology puzzle: +10
- Extraction: Full refill

```gdscript
class_name SanitySystem

var sanity: float = 100.0
var max_sanity: float = 100.0
var drain_multiplier: float = 1.0

signal sanity_changed(new_value)
signal hallucination_triggered(severity)
signal transformation_triggered

func drain(amount: float, source: String):
    sanity -= amount * drain_multiplier
    sanity = clamp(sanity, 0, max_sanity)
    emit_signal("sanity_changed", sanity)
    
    check_hallucinations()
    
    if sanity <= 0:
        trigger_transformation()

func check_hallucinations():
    if sanity <= 75 and sanity > 50:
        if randf() < 0.1:  # 10% chance per check
            emit_signal("hallucination_triggered", "mild")
    elif sanity <= 50 and sanity > 25:
        if randf() < 0.2:
            emit_signal("hallucination_triggered", "moderate")
    elif sanity <= 25 and sanity > 0:
        if randf() < 0.3:
            emit_signal("hallucination_triggered", "severe")

func trigger_transformation():
    emit_signal("transformation_triggered")
    # Player becomes part of the god
    # This character is now an NPC in future runs
    # Run ends, special ending
```

---

## Corruption

**What it is:** Divine material changing you from within.

**Behavior:**
- Maximum: 100 units (when full, transformation occurs)
- Gain sources:
  - Carrying divine material: +0.1 per second per unit of material
  - Taking damage from Echoes: +5 per hit
  - Using divine abilities: +10 per use
  - In Vorath (exchange rule): Variable based on material value

**Corruption Effects:**
- 25%: Unlock Tier 1 divine ability, slight visual change
- 50%: Unlock Tier 2 divine ability, moderate visual change
- 75%: Unlock Tier 3 divine ability, significant visual change
- 100%: Full transformation (run ends, character becomes NPC)

**Reduction:**
- Purification stations (rare): -25
- Dropping divine material: Stops gain from that material
- Nothing fully removes corruption gained

**Divine Abilities (Unlocked by Corruption):**
- **Tier 1 (25%):** Divine Sight — see through walls briefly
- **Tier 2 (50%):** Divine Step — short teleport
- **Tier 3 (75%):** Divine Word — stun all enemies in room

Using abilities increases corruption further. Risk/reward.

```gdscript
class_name CorruptionSystem

var corruption: float = 0.0
const MAX_CORRUPTION: float = 100.0

var tier_1_unlocked: bool = false
var tier_2_unlocked: bool = false
var tier_3_unlocked: bool = false

func _process(delta):
    # Passive gain from carried material
    var material_value = player.get_total_material_value()
    var passive_gain = material_value * 0.001 * delta
    add_corruption(passive_gain)

func add_corruption(amount: float):
    corruption += amount
    corruption = clamp(corruption, 0, MAX_CORRUPTION)
    
    check_tier_unlocks()
    update_visual_corruption()
    
    if corruption >= MAX_CORRUPTION:
        trigger_full_transformation()

func check_tier_unlocks():
    if corruption >= 25 and not tier_1_unlocked:
        tier_1_unlocked = true
        unlock_ability("divine_sight")
        show_unlock_notification("Divine Sight unlocked")
    
    if corruption >= 50 and not tier_2_unlocked:
        tier_2_unlocked = true
        unlock_ability("divine_step")
        show_unlock_notification("Divine Step unlocked")
    
    if corruption >= 75 and not tier_3_unlocked:
        tier_3_unlocked = true
        unlock_ability("divine_word")
        show_unlock_notification("Divine Word unlocked")

func update_visual_corruption():
    var t = corruption / MAX_CORRUPTION
    # Shift player colors toward current god's palette
    player.set_corruption_visual(t)
```

---

# COMBAT SYSTEM

## Overview

Combat is real-time with optional pause for ability selection. It's NOT the focus — navigation and theology are primary.

## Player Stats

```gdscript
# Base stats (before equipment)
var max_health: float = 100.0
var move_speed: float = 200.0  # pixels per second
var attack_damage: float = 20.0
var attack_speed: float = 1.0  # attacks per second
var dodge_distance: float = 100.0
var dodge_cooldown: float = 1.0  # seconds
```

## Attack System

```gdscript
func attack():
    if attack_on_cooldown:
        return
    
    # Check theology restrictions
    if current_god.restricts_violence():
        show_warning("Violence forbidden here")
        return
    
    # Perform attack
    var targets = get_targets_in_range()
    for target in targets:
        if target.is_in_group("echo"):
            # Check sacred starving (Vorath)
            if target.is_starving and current_god.name == "Vorath":
                violate_theology("sacred_starving")
            else:
                deal_damage(target, calculate_damage())
    
    start_attack_cooldown()
    spawn_attack_effect()

func calculate_damage() -> float:
    var damage = attack_damage
    damage *= equipment_damage_multiplier
    damage *= corruption_damage_bonus()  # Corruption can increase damage
    return damage

func corruption_damage_bonus() -> float:
    # More corrupted = more damage (but at what cost?)
    return 1.0 + (corruption / 200.0)  # Up to 1.5x at max corruption
```

## Dodge System

```gdscript
func dodge(direction: Vector2):
    if dodge_on_cooldown:
        return
    if is_in_threshold and current_god.name == "Calyx":
        return  # Can't dodge from threshold
    
    # Invincibility frames
    invincible = true
    
    # Move
    var target_pos = position + direction.normalized() * dodge_distance
    var tween = create_tween()
    tween.tween_property(self, "position", target_pos, 0.2)
    
    # End invincibility
    await get_tree().create_timer(0.3).timeout
    invincible = false
    
    start_dodge_cooldown()
```

## Enemy Combat

```gdscript
class_name EchoBase

var max_health: float = 50.0
var health: float = max_health
var damage: float = 15.0
var speed: float = 100.0
var attack_range: float = 30.0
var attack_cooldown: float = 2.0

func take_damage(amount: float):
    health -= amount
    spawn_hit_effect()
    
    if health <= max_health * 0.2:
        enter_starving_state()  # For Vorath theology
    
    if health <= 0:
        die()

func die():
    drop_loot()
    spawn_death_effect()
    
    # Increase player corruption slightly
    player.corruption_system.add_corruption(2)
    
    queue_free()
```

## Damage Types

```gdscript
enum DamageType {
    PHYSICAL,    # Standard attacks
    DIVINE,      # From Echoes, theology violations
    CORRUPTION,  # Damages sanity too
    SUFFOCATION, # From low oxygen
    THEOLOGICAL  # From rule violations (often instant)
}

func take_damage(amount: float, type: DamageType):
    match type:
        DamageType.PHYSICAL:
            health -= amount
        DamageType.DIVINE:
            health -= amount
            sanity -= amount * 0.5
        DamageType.CORRUPTION:
            health -= amount * 0.5
            sanity -= amount
        DamageType.THEOLOGICAL:
            health -= amount  # Usually very high or instant
            flash_screen_red()
            show_theology_violation()
```

---

# PROGRESSION SYSTEMS

## Within a Run

### Depth Progression

Each depth level increases:
- Enemy difficulty: `health *= 1.1`, `damage *= 1.1`
- Enemy density: `+0.5 enemies per room`
- Material value: `value *= 1.2`
- Resource drain: See oxygen system
- Theology complexity: More rules interact

### Equipment Found

Equipment can be found in vaults or dropped by elite enemies:

```gdscript
enum EquipmentSlot {
    SUIT,     # Defense, resource capacity
    VISOR,    # Light capacity, special sight modes
    TOOL,     # Mining speed, material quality
    PACK,     # Inventory size
    WEAPON    # Damage, attack speed
}

class_name Equipment

var slot: EquipmentSlot
var name: String
var rarity: int  # 1-5
var stats: Dictionary  # "health_max": 10, "damage": 5, etc.
var special: String  # Special ability if any
```

### Loot Tables

```gdscript
# Drop chances by depth
func get_equipment_chance(depth: int) -> float:
    return 0.05 + (depth * 0.02)  # 5% at depth 1, 25% at depth 10

func get_equipment_rarity(depth: int) -> int:
    var roll = randf()
    if depth >= 8 and roll < 0.1:
        return 5  # Legendary
    if depth >= 6 and roll < 0.2:
        return 4  # Epic
    if depth >= 4 and roll < 0.4:
        return 3  # Rare
    if depth >= 2 and roll < 0.6:
        return 2  # Uncommon
    return 1  # Common
```

## Between Runs

### Currency

**Credits** — Standard currency, earned by selling material
**Residue** — Rare currency, earned from deep runs or special events

### Persistent Upgrades

```gdscript
# Upgrade categories
var upgrades = {
    "oxygen_max": {
        "levels": 5,
        "cost_per_level": [100, 200, 400, 800, 1600],
        "effect_per_level": 10  # +10 max oxygen per level
    },
    "light_max": {
        "levels": 5,
        "cost_per_level": [100, 200, 400, 800, 1600],
        "effect_per_level": 10
    },
    "health_max": {
        "levels": 5,
        "cost_per_level": [150, 300, 600, 1200, 2400],
        "effect_per_level": 20
    },
    "corruption_resistance": {
        "levels": 3,
        "cost_per_level": [500, 1000, 2000],
        "effect_per_level": 0.1  # 10% slower corruption gain
    },
    "starting_equipment": {
        "levels": 10,
        "cost_per_level": [200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000],
        "effect": "Unlock starting equipment options"
    }
}
```

### Unlockables

```gdscript
# Unlocked by achievements/milestones
var unlockables = {
    "god_vorath": {
        "requirement": "Reach Calyx Core",
        "unlocks": "Access to Vorath"
    },
    "god_selen": {
        "requirement": "Reach Vorath Core",
        "unlocks": "Access to Selen"
    },
    "faction_church": {
        "requirement": "Find Church symbol 3 times",
        "unlocks": "Church of the Open Wound faction"
    },
    "divine_ability_tier_4": {
        "requirement": "Fully corrupt 3 characters",
        "unlocks": "Tier 4 divine abilities"
    }
}
```

### Character Persistence

```gdscript
# When a character is corrupted/transformed
func save_corrupted_character(character: Character):
    var ghost = {
        "name": character.name,
        "appearance": character.appearance_data,
        "corruption_source": current_god.name,
        "final_depth": current_depth,
        "items_held": character.inventory.serialize(),
        "memories": character.learned_theology
    }
    
    Global.corrupted_characters.append(ghost)
    save_to_disk()

# When generating a dungeon
func place_remnants():
    for ghost in Global.corrupted_characters:
        if ghost.corruption_source == current_god.name:
            if randf() < 0.3:  # 30% chance to appear
                spawn_remnant(ghost)
```

---

# FACTION SYSTEM

## Reputation

Each faction has a reputation value: -100 to +100

```gdscript
var faction_reputation = {
    "threshold_industries": 0,
    "feast_collective": 0,
    "church_of_the_open_wound": 0,
    "unlicensed": 0
}

func modify_reputation(faction: String, amount: int):
    faction_reputation[faction] += amount
    faction_reputation[faction] = clamp(faction_reputation[faction], -100, 100)
    
    check_reputation_thresholds(faction)

func check_reputation_thresholds(faction: String):
    var rep = faction_reputation[faction]
    
    if rep >= 50 and not faction_ally_unlocked[faction]:
        unlock_faction_ally(faction)
    if rep >= 75 and not faction_shop_unlocked[faction]:
        unlock_faction_shop(faction)
    if rep <= -50:
        faction_becomes_hostile(faction)
```

## Faction Benefits

**Threshold Industries (Reputation 50+):**
- Access to advanced equipment
- Intel on dungeon layouts
- Emergency extraction service

**Feast Collective (Reputation 50+):**
- Better prices for material
- Free healing between runs
- Crew members for hire

**Church of the Open Wound (Reputation 50+):**
- Theology insights (rules revealed early)
- Corruption management
- Access to "living god" storyline

**Unlicensed (Reputation 50+):**
- Black market equipment
- Forbidden divine abilities
- Information on other factions' secrets

---

# ECONOMY

## Divine Material Values

```gdscript
enum MaterialGrade {
    FRAGMENT,   # Common, depths 1-3, value 10-25
    SHARD,      # Uncommon, depths 3-6, value 25-75
    CRYSTAL,    # Rare, depths 5-8, value 75-200
    HEART,      # Epic, depths 7-10, value 200-500
    ESSENCE     # Legendary, cores only, value 500-1000
}

func calculate_material_value(grade: MaterialGrade, god: God, depth: int) -> int:
    var base = get_base_value(grade)
    var depth_bonus = depth * 5
    var god_modifier = god.material_modifier  # Some gods have rarer material
    
    return int(base * god_modifier) + depth_bonus
```

## Selling

```gdscript
func sell_material(material: Material, faction: String) -> int:
    var base_price = material.value
    var reputation_bonus = faction_reputation[faction] * 0.005  # Up to 50% bonus
    var final_price = int(base_price * (1.0 + reputation_bonus))
    
    player.credits += final_price
    return final_price
```

## Buying

Equipment and supplies have costs based on rarity and usefulness.

```gdscript
var shop_items = {
    "oxygen_canister": {"cost": 25, "effect": "Restores 25 oxygen"},
    "light_cell": {"cost": 30, "effect": "Restores 20 light"},
    "medkit": {"cost": 50, "effect": "Restores 40 health"},
    "purification_dose": {"cost": 200, "effect": "Removes 25 corruption"},
    "basic_weapon": {"cost": 100, "rarity": 1},
    "advanced_weapon": {"cost": 300, "rarity": 2},
    "rare_weapon": {"cost": 600, "rarity": 3}
}
```

---

# THEOLOGY VIOLATION SYSTEM

## How Violations Work

```gdscript
func violate_theology(rule: String):
    var punishment = get_punishment(current_god.name, rule)
    
    match punishment.type:
        "damage":
            player.take_damage(punishment.amount, DamageType.THEOLOGICAL)
        "resource_drain":
            drain_all_resources(punishment.amount)
        "enemy_spawn":
            spawn_enemies(punishment.enemy_type, punishment.count)
        "teleport":
            teleport_player_to(punishment.destination)
        "instant_death":
            player.die("Theological violation: " + rule)
    
    show_violation_message(current_god.name, rule)
    increment_violation_counter()

func get_punishment(god: String, rule: String) -> Dictionary:
    var punishments = {
        "Calyx": {
            "no_payment": {"type": "teleport", "destination": "entrance"},
            "closed_door": {"type": "damage", "amount": 9999},  # Instant death
            "direct_path": {"type": "damage", "amount": 10}  # Per second
        },
        "Vorath": {
            "sacred_starving": {"type": "resource_drain", "amount": 0.3},
            "no_offering": {"type": "enemy_spawn", "enemy_type": "Maw", "count": 2}
        },
        "Selen": {
            "spoke_forbidden_name": {"type": "enemy_spawn", "enemy_type": "Named", "count": 1},
            "forgot_anchor": {"type": "teleport", "destination": "random"}
        }
    }
    
    return punishments[god][rule]
```

---

# SAVE SYSTEM

## Run Data (Not Saved)

Current run is lost on death/exit:
- Current position
- Current inventory
- Current resources
- Current depth

## Persistent Data (Saved)

```gdscript
var save_data = {
    # Progression
    "credits": 0,
    "residue": 0,
    "upgrades": {},
    "unlockables": [],
    
    # Factions
    "faction_reputation": {},
    
    # Characters
    "corrupted_characters": [],
    
    # Knowledge
    "theology_discovered": {},  # What rules you've learned
    "gods_visited": [],
    "deepest_depths": {},  # Per god
    
    # Statistics
    "runs_completed": 0,
    "total_material_collected": 0,
    "total_deaths": 0,
    "total_transformations": 0
}

func save_game():
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func load_game():
    if FileAccess.file_exists("user://save.json"):
        var file = FileAccess.open("user://save.json", FileAccess.READ)
        save_data = JSON.parse_string(file.get_as_text())
        file.close()
```

---

# FORMULAS SUMMARY

```
OXYGEN DRAIN = 1 + (depth × 0.1) per second
LIGHT DRAIN = 5/sec in high-divinity, 0.5/sec per nearby material
CORRUPTION GAIN = material_value × 0.001 per second
ENEMY HEALTH = base × (1.1 ^ depth)
ENEMY DAMAGE = base × (1.1 ^ depth)
MATERIAL VALUE = base_value × god_modifier + (depth × 5)
SELL PRICE = material_value × (1 + reputation × 0.005)
EQUIPMENT DROP CHANCE = 0.05 + (depth × 0.02)
```
