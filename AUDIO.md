# SALVAGE THEOLOGY: AUDIO
## Sound Design and Synthesis Specifications

---

# AUDIO PHILOSOPHY

The gods are dead but not silent. Sound in Salvage Theology should feel:

- **Sacred** — Reverberant, vast, like sound in a cathedral
- **Alien** — Frequencies that feel wrong, harmonics that don't resolve
- **Beautiful** — Even the danger should sound gorgeous
- **Overwhelming** — Scale conveyed through audio, not just visuals

---

# TECHNICAL APPROACH

## Primary: Procedural Synthesis

Most sounds generated in real-time using Godot's audio tools:
- `AudioStreamGenerator` for synthesized tones
- `AudioEffectReverb` for space
- `AudioEffectDistortion` for divine corruption
- `AudioEffectChorus` for ethereal quality

## Secondary: Minimal Samples

Some sounds are difficult to synthesize well:
- Footsteps (use free samples, process heavily)
- UI clicks (can synthesize or sample)
- Voice fragments (if any — process beyond recognition)

**Sample Sources (Free):**
- Freesound.org
- Sonniss GDC bundles
- CC0 sound libraries

---

# AMBIENT LAYERS

## The Void (Between Gods)

**Layer 1: Deep Space Drone**
```gdscript
# Low frequency hum, barely audible
func create_void_drone() -> AudioStreamGenerator:
    var stream = AudioStreamGenerator.new()
    stream.mix_rate = 44100.0
    
    # In _process or audio thread:
    # Generate sine wave at 30-40 Hz
    # Add slow LFO for volume (0.02 Hz)
    # Very low volume (0.1)
```

**Layer 2: Distant Stars**
```gdscript
# Occasional high sparkle sounds
# Random timing, random pitch in high range
# Sparse, lonely

func trigger_star_sound():
    var freq = randf_range(2000, 8000)
    var duration = randf_range(0.1, 0.3)
    play_sine_blip(freq, duration, 0.05)  # Very quiet
```

**Layer 3: Your Breathing**
```gdscript
# Rhythmic filtered noise
# Inhale: noise sweep low to high
# Exhale: noise sweep high to low
# Tempo matches oxygen level

func play_breathing():
    var breath_rate = 4.0  # seconds per cycle at full oxygen
    if oxygen_low:
        breath_rate = 2.0  # faster when low
    
    # Inhale
    sweep_noise(200, 800, breath_rate * 0.4)
    await timer(breath_rate * 0.1)
    # Exhale
    sweep_noise(800, 200, breath_rate * 0.5)
```

---

## Inside a God

Each god has unique ambient sound built from layers:

### CALYX (Thresholds)

**Layer 1: Resonant Space**
```gdscript
# Multiple sine waves at harmonic intervals
# Creates sense of vast enclosed space

var calyx_frequencies = [55, 110, 165, 220, 330]  # A harmonic series

func create_calyx_ambient():
    for freq in calyx_frequencies:
        var osc = create_oscillator(freq, "sine")
        osc.volume = 0.02
        add_effect(osc, reverb_large)
```

**Layer 2: Door Resonance**
```gdscript
# When near doors, they hum
# Frequency based on door state

func get_door_hum_freq(door) -> float:
    match door.state:
        LOCKED: return 220  # A3
        UNLOCKED: return 330  # E4
        OPEN: return 440  # A4
```

**Layer 3: Threshold Whisper**
```gdscript
# White noise, heavily filtered
# Sounds like wind through a doorway

func create_threshold_whisper():
    var noise = create_noise("white")
    var filter = AudioEffectBandPassFilter.new()
    filter.cutoff_hz = 1000
    filter.resonance = 2.0
    add_effect(noise, filter)
    noise.volume = 0.03
```

### VORATH (Appetite)

**Layer 1: Digestive Rumble**
```gdscript
# Low frequency rumbling, organic
# Irregular rhythm like a stomach

func create_vorath_rumble():
    var base_freq = 40
    var osc = create_oscillator(base_freq, "sine")
    
    # Add irregular LFO
    var lfo = create_oscillator(0.1, "sine")  # Very slow
    lfo.connect_to(osc.frequency)
    lfo.amplitude = 10  # ±10 Hz variation
    
    # Add secondary "gurgle"
    var gurgle_timer = Timer.new()
    gurgle_timer.wait_time = randf_range(3, 8)
    gurgle_timer.timeout.connect(play_gurgle)
```

**Layer 2: Golden Hum**
```gdscript
# Warm, rich harmonics
# Almost pleasant, almost appetizing

var vorath_frequencies = [82.5, 165, 247.5, 330, 412.5]  # E series, warm

func create_vorath_warmth():
    for freq in vorath_frequencies:
        var osc = create_oscillator(freq, "triangle")  # Warmer than sine
        osc.volume = 0.015
```

**Layer 3: Hunger Pulse**
```gdscript
# Rhythmic throb that increases when resources are low
# Like a heartbeat, but wrong

func create_hunger_pulse():
    var rate = 0.8  # Beats per second, base
    
    # Speed up when player is "appetizing" (carrying material)
    rate += player.material_count * 0.1
    
    # Create pulse
    var envelope = create_envelope(0.05, 0.1, 0.0, 0.2)  # Sharp attack
    var osc = create_oscillator(60, "sine")
    apply_envelope(osc, envelope)
    trigger_at_rate(rate)
```

### SELEN (Forgetting)

**Layer 1: Fade Drone**
```gdscript
# Sound that seems to disappear
# Volume envelope that constantly fades and returns

func create_selen_fade():
    var osc = create_oscillator(220, "sine")
    
    # Constant fade in/out
    var tween = create_tween().set_loops()
    tween.tween_property(osc, "volume", 0.03, 4.0)
    tween.tween_property(osc, "volume", 0.0, 4.0)
```

**Layer 2: Memory Echoes**
```gdscript
# Fragments of other sounds, heavily delayed and reverbed
# Things you heard before, coming back distorted

func create_memory_echo():
    var delay = AudioEffectDelay.new()
    delay.tap1_active = true
    delay.tap1_delay_ms = 2000
    delay.tap1_level_db = -6
    delay.tap2_active = true
    delay.tap2_delay_ms = 4000
    delay.tap2_level_db = -12
    
    var reverb = AudioEffectReverb.new()
    reverb.room_size = 0.9
    reverb.wet = 0.7
    
    # Route occasional game sounds through this
```

**Layer 3: Silence Pressure**
```gdscript
# The sound of silence being... heavy
# Very low frequency, almost felt not heard

func create_silence_pressure():
    var osc = create_oscillator(20, "sine")  # Below hearing, felt
    osc.volume = 0.1  # Enough to feel subwoofers
    
    # Gets louder the longer you're silent
    if player.silence_timer > 3.0:
        osc.volume = 0.2
```

---

# SOUND EFFECTS

## Player Sounds

### Footsteps
```gdscript
# Option 1: Synthesized
func play_footstep_synth():
    var noise = create_noise("pink")
    var filter = AudioEffectLowPassFilter.new()
    filter.cutoff_hz = 500
    var envelope = create_envelope(0.01, 0.05, 0.0, 0.1)
    play_with_envelope(noise, envelope, filter)
    # Add slight pitch variation
    filter.cutoff_hz = randf_range(400, 600)

# Option 2: Sample-based (recommended)
var footstep_samples = [
    preload("res://audio/sfx/step1.wav"),
    preload("res://audio/sfx/step2.wav"),
    preload("res://audio/sfx/step3.wav"),
]

func play_footstep():
    var sample = footstep_samples[randi() % footstep_samples.size()]
    var player = AudioStreamPlayer.new()
    player.stream = sample
    player.pitch_scale = randf_range(0.9, 1.1)
    player.volume_db = -10
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
```

### Dodge/Dash
```gdscript
func play_dodge():
    # Whoosh sound - filtered noise sweep
    var noise = create_noise("white")
    var filter = AudioEffectHighPassFilter.new()
    
    # Sweep filter from low to high
    var tween = create_tween()
    tween.tween_property(filter, "cutoff_hz", 200, 0.0)
    tween.tween_property(filter, "cutoff_hz", 4000, 0.2)
    
    play_for_duration(noise, 0.25, filter)
```

### Attack
```gdscript
func play_attack():
    # Sharp transient + short tone
    
    # Transient (click)
    var click = create_oscillator(1000, "square")
    var click_env = create_envelope(0.001, 0.02, 0.0, 0.02)
    play_with_envelope(click, click_env)
    
    # Tone (whoosh)
    var tone = create_oscillator(300, "sawtooth")
    var tone_env = create_envelope(0.01, 0.1, 0.0, 0.1)
    tone.frequency_slide(-200, 0.15)  # Pitch drops
    play_with_envelope(tone, tone_env)
```

### Damage Taken
```gdscript
func play_damage():
    # Distorted thud + warning tone
    
    # Thud
    var thud = create_oscillator(80, "sine")
    var thud_env = create_envelope(0.01, 0.1, 0.3, 0.2)
    var distortion = AudioEffectDistortion.new()
    distortion.mode = AudioEffectDistortion.MODE_OVERDRIVE
    distortion.drive = 0.5
    play_with_envelope(thud, thud_env, distortion)
    
    # Warning beep
    var beep = create_oscillator(880, "square")
    var beep_env = create_envelope(0.01, 0.05, 0.0, 0.05)
    play_with_envelope(beep, beep_env)
```

### Death
```gdscript
func play_death():
    # All frequencies collapse downward
    # Represents consciousness fading
    
    var voices = []
    for i in range(5):
        var freq = 400 + (i * 200)
        var osc = create_oscillator(freq, "sine")
        voices.append(osc)
    
    # All slide down to nothing
    for osc in voices:
        var tween = create_tween()
        tween.tween_property(osc, "frequency", 20, 2.0)
        tween.tween_property(osc, "volume", 0, 2.0)
    
    # Add reverb tail
    var reverb = AudioEffectReverb.new()
    reverb.room_size = 1.0
    reverb.wet = 0.8
```

## Echo (Enemy) Sounds

### Watcher - Detected
```gdscript
func play_watcher_alert():
    # Rising tone - "it sees you"
    var osc = create_oscillator(300, "sine")
    var tween = create_tween()
    tween.tween_property(osc, "frequency", 600, 0.5)
    
    var env = create_envelope(0.1, 0.3, 0.5, 0.3)
    play_with_envelope(osc, env)
    
    # Add ethereal quality
    var chorus = AudioEffectChorus.new()
    chorus.voice_count = 3
```

### Guardian - Warning
```gdscript
func play_guardian_warning():
    # Deep, ominous chord
    var frequencies = [55, 82.5, 110, 165]  # Power chord, low
    
    for freq in frequencies:
        var osc = create_oscillator(freq, "sawtooth")
        var filter = AudioEffectLowPassFilter.new()
        filter.cutoff_hz = 400
        osc.volume = 0.1
        play_sustained(osc, filter)
    
    # Pulsing volume
    pulse_volume(0.5)  # Hz
```

### Seeker - Dash
```gdscript
func play_seeker_dash():
    # Quick aggressive sweep
    var osc = create_oscillator(800, "sawtooth")
    var tween = create_tween()
    tween.tween_property(osc, "frequency", 200, 0.15)
    
    var env = create_envelope(0.01, 0.1, 0.0, 0.05)
    play_with_envelope(osc, env)
```

### Remnant - Presence
```gdscript
func play_remnant_ambience():
    # Distorted version of player breathing
    # Uncomfortable mirror
    
    var breath = create_breathing_sound()
    var distortion = AudioEffectDistortion.new()
    distortion.mode = AudioEffectDistortion.MODE_CLIP
    distortion.drive = 0.7
    
    var pitch_shift = AudioEffectPitchShift.new()
    pitch_shift.pitch_scale = 0.8  # Lower, wrong
    
    apply_effects(breath, [distortion, pitch_shift])
```

## Divine Material Sounds

### Pickup
```gdscript
func play_material_pickup(grade: MaterialGrade):
    # Shimmering tone, pitch based on grade
    var base_freq = 400 + (grade * 100)  # Higher grade = higher pitch
    
    # Multiple detuned oscillators for shimmer
    for i in range(3):
        var detune = (i - 1) * 5  # -5, 0, +5 Hz
        var osc = create_oscillator(base_freq + detune, "sine")
        var env = create_envelope(0.01, 0.2, 0.3, 0.5)
        play_with_envelope(osc, env)
    
    # Add sparkle
    for i in range(5):
        await get_tree().create_timer(0.05).timeout
        var sparkle_freq = randf_range(2000, 4000)
        play_blip(sparkle_freq, 0.05)
```

### Corruption Gain
```gdscript
func play_corruption_gain():
    # Unsettling low tone with overtones
    var fundamental = 60
    var osc1 = create_oscillator(fundamental, "sine")
    var osc2 = create_oscillator(fundamental * 1.5, "sine")  # Dissonant
    var osc3 = create_oscillator(fundamental * 2.1, "sine")  # More dissonant
    
    osc1.volume = 0.1
    osc2.volume = 0.05
    osc3.volume = 0.03
    
    var env = create_envelope(0.5, 0.5, 0.5, 1.0)
    play_with_envelope([osc1, osc2, osc3], env)
```

## Theology Sounds

### Door Payment
```gdscript
func play_door_payment(payment_type: String):
    match payment_type:
        "item":
            # Crunch/dissolve sound
            play_dissolve()
        "health":
            # Wet, visceral
            play_blood_payment()
        "memory":
            # Reverse reverb, fading
            play_memory_fade()

func play_memory_fade():
    # Sound that plays backwards into silence
    var osc = create_oscillator(600, "sine")
    var reverb = AudioEffectReverb.new()
    reverb.room_size = 0.9
    
    # Reverse envelope (fade in from reverb tail)
    var env = create_envelope(1.0, 0.5, 0.0, 0.01)
    play_with_envelope(osc, env, reverb)
```

### Theology Violation
```gdscript
func play_violation():
    # Harsh, alarming, divine anger
    
    # Distorted chord
    var frequencies = [100, 150, 200, 350]  # Dissonant cluster
    for freq in frequencies:
        var osc = create_oscillator(freq, "sawtooth")
        var distortion = AudioEffectDistortion.new()
        distortion.drive = 0.8
        osc.volume = 0.15
        play_with_effects(osc, [distortion])
    
    # Harsh transient
    var noise = create_noise("white")
    var env = create_envelope(0.001, 0.1, 0.0, 0.1)
    play_with_envelope(noise, env)
```

## UI Sounds

### Menu Navigate
```gdscript
func play_menu_nav():
    var osc = create_oscillator(800, "sine")
    var env = create_envelope(0.01, 0.03, 0.0, 0.03)
    play_with_envelope(osc, env)
```

### Menu Select
```gdscript
func play_menu_select():
    # Two-tone confirmation
    var osc1 = create_oscillator(600, "sine")
    var osc2 = create_oscillator(800, "sine")
    
    var env = create_envelope(0.01, 0.05, 0.0, 0.05)
    play_with_envelope(osc1, env)
    await get_tree().create_timer(0.08).timeout
    play_with_envelope(osc2, env)
```

### Warning (Low Resource)
```gdscript
func play_warning():
    # Repeating beep
    var osc = create_oscillator(880, "square")
    var env = create_envelope(0.01, 0.05, 0.0, 0.05)
    
    for i in range(3):
        play_with_envelope(osc, env)
        await get_tree().create_timer(0.15).timeout
```

---

# MUSIC SYSTEM

## Approach: Generative Layers

No composed tracks. Music emerges from layered systems that respond to game state.

## Base Layer (Always Playing)

```gdscript
class_name MusicSystem

var base_drone: AudioStreamPlayer
var tension_layer: AudioStreamPlayer
var depth_layer: AudioStreamPlayer
var god_layer: AudioStreamPlayer

func _ready():
    create_base_drone()
    
func create_base_drone():
    # Fundamental tone that's always present
    # Changes based on current god
    
    base_drone = AudioStreamPlayer.new()
    var generator = AudioStreamGenerator.new()
    generator.mix_rate = 44100
    base_drone.stream = generator
    add_child(base_drone)
    base_drone.play()
    
    # Generate in _process
```

## Tension Layer

```gdscript
func update_tension_layer(tension: float):
    # tension: 0.0 (safe) to 1.0 (danger)
    
    if tension < 0.3:
        tension_layer.volume_db = -80  # Silent
    else:
        tension_layer.volume_db = lerp(-20, -6, tension)
        
        # Add more dissonant overtones at high tension
        var dissonance = tension * 20  # Cents of detuning
        set_detune(tension_layer, dissonance)
```

## Depth Layer

```gdscript
func update_depth_layer(depth: int):
    # Deeper = more ominous
    
    var depth_normalized = depth / 10.0
    
    # Lower fundamental frequency
    var freq = lerp(110, 55, depth_normalized)
    set_frequency(depth_layer, freq)
    
    # Add more sub-harmonics
    var sub_volume = depth_normalized * 0.1
    set_sub_volume(sub_volume)
```

## God-Specific Layer

```gdscript
func set_god_music(god_name: String):
    match god_name:
        "Calyx":
            # Clean, resonant, doorway echoes
            god_layer.set_harmonic_series([1, 2, 3, 4, 5])
            god_layer.set_reverb(0.8)
            god_layer.set_base_freq(110)  # A2
            
        "Vorath":
            # Warm, pulsing, hungry
            god_layer.set_harmonic_series([1, 1.5, 2, 3])  # Includes 5th
            god_layer.set_pulse_rate(0.8)
            god_layer.set_base_freq(82.5)  # E2
            
        "Selen":
            # Fading, uncertain, peaceful-sad
            god_layer.set_harmonic_series([1, 2, 4, 8])  # Octaves only
            god_layer.set_fade_behavior(true)
            god_layer.set_base_freq(130.8)  # C3
```

## Combat Music

```gdscript
func enter_combat():
    # Increase tension
    tension_target = 0.8
    
    # Add rhythmic element
    start_combat_pulse()
    
func start_combat_pulse():
    var pulse_rate = 2.0  # Hz
    
    while in_combat:
        play_combat_hit()
        await get_tree().create_timer(1.0 / pulse_rate).timeout

func play_combat_hit():
    var osc = create_oscillator(80, "sine")
    var env = create_envelope(0.01, 0.05, 0.0, 0.1)
    play_with_envelope(osc, env)
```

---

# AUDIO BUS SETUP

```gdscript
# Godot audio bus configuration

# Master
#   ├── Music
#   │     ├── Drone
#   │     ├── Tension  
#   │     └── God
#   ├── SFX
#   │     ├── Player
#   │     ├── Enemies
#   │     └── Environment
#   ├── UI
#   └── Ambience

func setup_audio_buses():
    # Master effects
    AudioServer.add_bus_effect(0, AudioEffectLimiter.new())
    
    # Music bus - heavy reverb
    var music_bus = AudioServer.get_bus_index("Music")
    var reverb = AudioEffectReverb.new()
    reverb.room_size = 0.8
    reverb.wet = 0.3
    AudioServer.add_bus_effect(music_bus, reverb)
    
    # SFX bus - lighter reverb
    var sfx_bus = AudioServer.get_bus_index("SFX")
    var sfx_reverb = AudioEffectReverb.new()
    sfx_reverb.room_size = 0.5
    sfx_reverb.wet = 0.2
    AudioServer.add_bus_effect(sfx_bus, sfx_reverb)
    
    # Ambience bus - very wet
    var amb_bus = AudioServer.get_bus_index("Ambience")
    var amb_reverb = AudioEffectReverb.new()
    amb_reverb.room_size = 0.95
    amb_reverb.wet = 0.5
    AudioServer.add_bus_effect(amb_bus, amb_reverb)
```

---

# IMPLEMENTATION NOTES

## Performance

- Limit simultaneous sounds to 16
- Pool AudioStreamPlayer nodes
- Use `AudioStreamGenerator` for drones (no file loading)
- Lower sample rates for background sounds (22050 Hz is fine)

## Spatial Audio (If 3D)

```gdscript
# Use AudioStreamPlayer3D for positioned sounds
var spatial_player = AudioStreamPlayer3D.new()
spatial_player.unit_size = 10.0  # Distance scaling
spatial_player.max_distance = 50.0
spatial_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
```

## Dynamic Range

- Drones: -20 to -12 dB
- SFX: -12 to -6 dB  
- UI: -15 to -10 dB
- Music stings: -10 to -3 dB
- Mastering limiter at -1 dB

## Free Sample Sources

If synthesis isn't enough:

- **Freesound.org** — CC0 and CC-BY sounds
- **Sonniss GDC Audio Bundles** — Professional quality, free yearly
- **OpenGameArt.org** — Game-specific sounds
- **BBC Sound Effects** — Massive library, free for non-commercial

Process all samples heavily to match the synthesized aesthetic.
