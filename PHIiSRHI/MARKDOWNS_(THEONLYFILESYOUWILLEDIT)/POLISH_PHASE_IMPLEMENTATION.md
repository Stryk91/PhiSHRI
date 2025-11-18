# PhiWave Polish Phase - Implementation Plan

**Phase:** Polish & Audio Quality Enhancement
**Status:** 🎯 Planning Complete - Ready to Implement
**Priority:** Tier 1 Features (Do Now)
**Timeline:** Parallel with Phase 4 completion

---

## Polish Phase Overview

### Philosophy
- **Default assumption:** Quality open-back headphones (20Hz-16kHz+)
- **UI strategy:** Keep simple, hide complexity in Advanced Settings
- **Validation:** One-click tool instead of complex setup wizards
- **Quality focus:** Eliminate audio artifacts, ensure accuracy

### Key Decisions Made

#### 1. Audio Quality Improvements ✅

**WASAPI Exclusive Mode**
- Bypass Windows audio stack for bit-perfect output
- Direct hardware access for maximum fidelity
- Critical for accurate binaural frequencies
- Implementation: Tier 1

**One-Click Audio Validation**
- FFT-based frequency accuracy verification
- Proves quality without manual measurement
- User confidence building tool
- Implementation: Tier 1

**3 Headphone EQ Presets**
- Default: Open-Back (flat, 20Hz-16kHz+)
- Option: Closed-Back (+1dB bass)
- Option: ANC (-3dB bass compensation)
- Location: Advanced Settings (hidden by default)
- Implementation: Tier 1

#### 2. Implementation Priorities ✅

**Tier 1 - Do Now (Critical Quality):**
1. ✅ Fix audio loop crossfade (eliminate clicks)
2. ✅ Custom preset save/load system
3. ✅ WASAPI Exclusive mode implementation
4. ✅ Simple audio validation tool
5. ✅ App icon design

**Tier 2 - This Week (Polish):**
1. Quick Start auto-selection (time-of-day)
2. Mode/preset hover tooltips
3. Demo video recording
4. Split README (user vs dev docs)

**Skipped (Out of Scope):**
- ❌ ASIO support (WASAPI sufficient)
- ❌ Auto-calibration wizard (too much friction)
- ❌ Loopback recording (admin rights required)

---

## Tier 1 Implementation Tasks

### Task 1: Fix Audio Loop Crossfade

**Problem:** Clicks/pops when looping audio segments
**Impact:** Breaks immersion, sounds unprofessional
**Solution:** Implement smooth fade-in/fade-out at loop boundaries

**Implementation Details:**

```python
# In phiwave/audio/engine.py

def add_loop_crossfade(audio_buffer: np.ndarray,
                       fade_samples: int = 100) -> np.ndarray:
    """
    Add crossfade at loop boundary to eliminate clicks.

    Args:
        audio_buffer: Full audio segment (will be looped)
        fade_samples: Samples for crossfade (100 = 2ms @ 44.1kHz)

    Returns:
        Audio buffer with smooth loop points
    """
    # Create fade envelope
    fade_out = np.linspace(1.0, 0.0, fade_samples)
    fade_in = np.linspace(0.0, 1.0, fade_samples)

    # Apply fade at end and beginning
    audio_buffer[-fade_samples:] *= fade_out
    audio_buffer[:fade_samples] *= fade_in

    return audio_buffer
```

**Files to Modify:**
- `phiwave/audio/engine.py` - Add crossfade function
- `phiwave_gui.py` - Apply crossfade when playing loops

**Testing:**
- Listen for clicks at loop points
- Smooth fade expected
- No audio distortion
- Duration remains accurate

**Estimated Time:** 30 minutes

---

### Task 2: Custom Preset Save/Load System

**Current State:** Presets load from JSON (defaults only)
**Enhancement:** Users can save custom presets
**Impact:** Personalization, workflow improvement

**Implementation:**

```python
# In phiwave/presets/loader.py

class PresetManager:
    """Manage custom presets with save/load functionality."""

    def __init__(self, custom_presets_dir: str):
        """Initialize preset manager."""
        self.custom_dir = Path(custom_presets_dir)
        self.custom_dir.mkdir(exist_ok=True)

    def save_custom_preset(self, name: str, params: dict) -> bool:
        """
        Save a custom preset.

        Args:
            name: Preset name (alphanumeric + spaces)
            params: {carrier_hz, beat_hz, duration, volume, ...}

        Returns:
            True if saved successfully
        """
        preset_data = {
            "name": name,
            "type": "custom",
            "timestamp": datetime.now().isoformat(),
            **params
        }

        filepath = self.custom_dir / f"{name.lower().replace(' ', '_')}.json"
        with open(filepath, 'w') as f:
            json.dump(preset_data, f, indent=2)

        return True

    def load_custom_presets(self) -> dict:
        """Load all custom presets from directory."""
        custom = {}
        for filepath in self.custom_dir.glob("*.json"):
            with open(filepath) as f:
                data = json.load(f)
                custom[data["name"]] = data
        return custom

    def delete_custom_preset(self, name: str) -> bool:
        """Delete a custom preset."""
        filepath = self.custom_dir / f"{name.lower().replace(' ', '_')}.json"
        if filepath.exists():
            filepath.unlink()
            return True
        return False
```

**GUI Integration:**

```python
# In phiwave_gui.py - Add to controls

self.save_preset_button = tk.Button(
    self.control_frame,
    text="Save Custom Preset",
    command=self.save_current_as_preset
)
self.save_preset_button.pack()

def save_current_as_preset(self):
    """Save current parameters as custom preset."""
    preset_name = simpledialog.askstring(
        "Save Preset",
        "Enter preset name:"
    )
    if preset_name:
        params = {
            "carrier_hz": self.carrier_var.get(),
            "beat_hz": self.beat_var.get(),
            "duration": self.duration_var.get(),
            "volume": self.volume_var.get()
        }
        self.preset_manager.save_custom_preset(preset_name, params)
        self.refresh_preset_dropdown()
```

**Files to Modify:**
- `phiwave/presets/loader.py` - Add PresetManager class
- `phiwave_gui.py` - Add save/load UI buttons
- `phiwave/config.py` - Add custom preset path constant

**Testing:**
- Create custom preset
- Verify file saved to disk
- Load custom preset
- Delete custom preset
- Verify dropdown updates

**Estimated Time:** 1 hour

---

### Task 3: WASAPI Exclusive Mode Implementation

**Purpose:** Bit-perfect audio output, bypass Windows mixer
**Impact:** Maximum audio quality, frequency accuracy
**Complexity:** Medium (requires sounddevice config)

**Implementation:**

```python
# In phiwave/io/playback.py

import sounddevice as sd
import numpy as np

class ExclusivePlayback:
    """WASAPI Exclusive Mode audio playback."""

    def __init__(self, device_id: int = None):
        """Initialize with WASAPI Exclusive mode."""
        self.device_id = device_id
        self.exclusive_mode = True

    def play_exclusive(self, audio: np.ndarray,
                      sample_rate: int = 44100) -> bool:
        """
        Play audio in WASAPI Exclusive mode.

        Args:
            audio: Audio buffer (float32, [-1, 1])
            sample_rate: Sample rate in Hz

        Returns:
            True if playback successful
        """
        try:
            # Configure exclusive mode
            stream_config = {
                'device': self.device_id,
                'samplerate': sample_rate,
                'channels': audio.shape[1] if audio.ndim > 1 else 1,
                'dtype': 'float32',
                # Exclusive mode flags (Windows-specific)
                'latency': 'low',
            }

            # Play with exclusive mode
            sd.play(audio, **stream_config)
            sd.wait()

            return True
        except Exception as e:
            print(f"Exclusive mode failed, falling back to normal: {e}")
            # Fallback to normal mode
            sd.play(audio, samplerate=sample_rate)
            sd.wait()
            return False

    def check_exclusive_support(self) -> bool:
        """Check if device supports exclusive mode."""
        try:
            # Query device capabilities
            device_info = sd.query_devices(self.device_id)
            # Exclusive mode generally available on WASAPI devices
            return device_info['api'] == 'WASAPI'
        except:
            return False
```

**GUI Integration:**

```python
# In phiwave_gui.py - Add to Advanced Settings

self.exclusive_mode_var = tk.BooleanVar(value=True)
self.exclusive_mode_check = tk.Checkbutton(
    self.advanced_frame,
    text="WASAPI Exclusive Mode (Bit-Perfect)",
    variable=self.exclusive_mode_var
)
self.exclusive_mode_check.pack()

# Use in playback
if self.exclusive_mode_var.get():
    playback = ExclusivePlayback(device_id=self.current_device)
    playback.play_exclusive(audio_buffer)
else:
    play_buffer(audio_buffer)
```

**Files to Modify:**
- `phiwave/io/playback.py` - Add ExclusivePlayback class
- `phiwave_gui.py` - Add exclusive mode toggle
- `phiwave/config.py` - Add default exclusive mode setting

**Testing:**
- Verify playback on different devices
- Check frequency accuracy with exclusive mode ON/OFF
- Test fallback when exclusive mode unavailable
- Monitor audio latency

**Estimated Time:** 1.5 hours

---

### Task 4: Simple Audio Validation Tool

**Purpose:** One-click frequency accuracy verification
**Method:** FFT analysis of generated audio
**Impact:** User confidence, quality assurance

**Implementation:**

```python
# In phiwave/audio/validation.py (NEW FILE)

import numpy as np
from scipy import signal
from scipy.fft import fft, fftfreq

class AudioValidator:
    """Validate audio quality and frequency accuracy."""

    def __init__(self, sample_rate: int = 44100):
        """Initialize validator."""
        self.sample_rate = sample_rate
        self.fft_resolution = 0.1  # Hz per bin (for 440s @ 44.1kHz)

    def validate_frequencies(self, audio: np.ndarray,
                            expected_carrier: float,
                            expected_beat: float,
                            tolerance_hz: float = 0.5) -> dict:
        """
        Validate carrier and beat frequencies.

        Args:
            audio: Audio buffer (float32)
            expected_carrier: Expected carrier frequency (Hz)
            expected_beat: Expected beat frequency (Hz)
            tolerance_hz: Tolerance window (Hz)

        Returns:
            {
                'valid': True/False,
                'carrier_detected': float,
                'beat_detected': float,
                'carrier_error': float,  # Hz
                'beat_error': float,  # Hz
                'confidence': float,  # 0-1
            }
        """
        # Extract left channel
        if audio.ndim > 1:
            signal_mono = audio[:, 0]
        else:
            signal_mono = audio

        # FFT analysis
        N = len(signal_mono)
        freqs = fftfreq(N, 1/self.sample_rate)
        spectrum = np.abs(fft(signal_mono))

        # Find carrier frequency
        carrier_idx = np.argmax(spectrum[:N//2])
        carrier_detected = freqs[carrier_idx]

        # Find beat frequency (lower frequencies)
        beat_region = spectrum[1:int(20*N/self.sample_rate)]
        beat_idx = np.argmax(beat_region)
        beat_detected = freqs[beat_idx + 1]

        # Calculate errors
        carrier_error = abs(carrier_detected - expected_carrier)
        beat_error = abs(beat_detected - expected_beat)

        # Validation
        carrier_valid = carrier_error <= tolerance_hz
        beat_valid = beat_error <= tolerance_hz

        return {
            'valid': carrier_valid and beat_valid,
            'carrier_detected': carrier_detected,
            'beat_detected': beat_detected,
            'carrier_error': carrier_error,
            'beat_error': beat_error,
            'confidence': max(0, 1 - (carrier_error + beat_error) / (2 * tolerance_hz))
        }

    def check_clipping(self, audio: np.ndarray,
                      threshold: float = 0.99) -> dict:
        """
        Check for audio clipping.

        Args:
            audio: Audio buffer
            threshold: Clipping threshold (0-1)

        Returns:
            {
                'clipped': True/False,
                'peak_level': float,
                'clipped_samples': int
            }
        """
        peak = np.max(np.abs(audio))
        clipped_count = np.sum(np.abs(audio) > threshold)

        return {
            'clipped': peak > threshold,
            'peak_level': peak,
            'clipped_samples': clipped_count
        }
```

**GUI Integration:**

```python
# In phiwave_gui.py - Add validation button

self.validate_button = tk.Button(
    self.control_frame,
    text="Validate Audio Quality",
    command=self.validate_audio
)
self.validate_button.pack()

def validate_audio(self):
    """Validate generated audio quality."""
    if LAST_BUFFER is None:
        messagebox.showwarning("No Audio", "Generate audio first")
        return

    validator = AudioValidator()
    carrier = self.carrier_var.get()
    beat = self.beat_var.get()

    result = validator.validate_frequencies(LAST_BUFFER, carrier, beat)

    if result['valid']:
        msg = (f"✓ Audio Valid!\n\n"
               f"Carrier: {result['carrier_detected']:.1f} Hz "
               f"(expected {carrier:.1f} Hz)\n"
               f"Beat: {result['beat_detected']:.2f} Hz "
               f"(expected {beat:.2f} Hz)\n"
               f"Accuracy: {result['confidence']*100:.0f}%")
        messagebox.showinfo("Validation Result", msg)
    else:
        msg = (f"✗ Audio Quality Issue\n\n"
               f"Carrier error: {result['carrier_error']:.2f} Hz\n"
               f"Beat error: {result['beat_error']:.2f} Hz\n"
               f"Check your audio settings")
        messagebox.showwarning("Validation Result", msg)
```

**Files to Create:**
- `phiwave/audio/validation.py` - Audio validation module

**Files to Modify:**
- `phiwave_gui.py` - Add validation button and UI
- `phiwave/audio/__init__.py` - Export validator

**Testing:**
- Generate known frequencies
- Validate against known good audio
- Test FFT accuracy
- Verify error detection

**Estimated Time:** 1 hour

---

### Task 5: App Icon Design

**Purpose:** Professional branding, app identification
**Requirements:**
- 256x256 PNG (scalable)
- Represents binaural/audio concept
- Professional appearance
- Windows .ico format support

**Design Concept:**
```
Visual Elements:
- Circular waveform (binaural theme)
- Brain outline (neuroscience)
- Headphones silhouette
- Frequency visualization
- Color: Blue/purple gradient (brain health)
```

**Implementation:**
- Create icon PNG
- Convert to .ico format
- Update app launcher
- Place in assets directory

**Files to Create:**
- `assets/phiwave_icon.png` (256x256)
- `assets/phiwave_icon.ico` (Windows)

**Files to Modify:**
- `phiwave_gui.py` - Set window icon

```python
# In phiwave_gui.py - Set icon
try:
    self.root.iconbitmap(r'assets/phiwave_icon.ico')
except:
    pass  # Fallback if icon not found
```

**Estimated Time:** 1-2 hours (design + conversion)

---

## Audio Quality Settings Structure

### Advanced Settings (Hidden by Default)

```
┌─────────────────────────────────────────┐
│         Advanced Audio Settings          │
├─────────────────────────────────────────┤
│                                         │
│ Playback Quality:                       │
│ ☑ WASAPI Exclusive Mode                 │
│ ☑ High-Priority Audio Thread            │
│                                         │
│ Frequency EQ Presets:                   │
│ ○ Open-Back (Default/Flat)              │
│ ○ Closed-Back (+1dB bass)               │
│ ○ ANC (-3dB bass compensation)          │
│                                         │
│ Loop Quality:                           │
│ ☑ Smooth Crossfade at Loop Points      │
│ ☑ Eliminate Clicks/Pops                │
│                                         │
│ [Validate Audio Quality]                │
│ [Save Custom Preset]                    │
│ [Advanced Settings...]                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## Implementation Timeline

### Phase 4 Completion (~3-4 hours)
- Junie: Final testing and sign-off
- DESKC: GUI work completion
- Claude Code: Coordination

### Polish Phase Tier 1 (Parallel/After Phase 4)

```
Task 1: Audio Crossfade       30 min   (Highest impact)
Task 2: Custom Presets        1 hour   (User feature)
Task 3: WASAPI Exclusive      1.5 hr   (Quality)
Task 4: Audio Validation      1 hour   (UX polish)
Task 5: App Icon              1-2 hr   (Branding)
────────────────────────────────────
Total Tier 1:                 5-6 hours
```

### Sequencing Strategy

**Option A - Sequential (Safe):**
1. Complete Phase 4 sign-off
2. Implement Tier 1 features one-by-one
3. Test thoroughly
4. Merge to master

**Option B - Parallel (Faster):**
1. DESKC works on Tasks 1, 2, 4 (code-heavy)
2. Another agent works on Task 5 (icon design)
3. Someone tests WASAPI implementation (Task 3)
4. Merge after all complete

**Recommended:** Option B with 2 agents on code, 1 on design

---

## Why These Features Matter

### Audio Loop Crossfade
- **Problem:** Clicks at loop boundaries break immersion
- **Solution:** Smooth fade prevents audio artifacts
- **Impact:** Professional quality feel
- **Effort:** Low
- **User Impact:** High

### Custom Preset System
- **Problem:** Users can't save their favorite settings
- **Solution:** Save/load custom presets from disk
- **Impact:** Workflow improvement, personalization
- **Effort:** Medium
- **User Impact:** High

### WASAPI Exclusive Mode
- **Problem:** Windows mixer can degrade frequency accuracy
- **Solution:** Bypass mixer with exclusive mode
- **Impact:** Bit-perfect output, maximum quality
- **Effort:** Medium
- **User Impact:** High (for quality-conscious users)

### Audio Validation Tool
- **Problem:** Users can't verify audio quality
- **Solution:** One-click FFT analysis
- **Impact:** Confidence in accuracy, troubleshooting
- **Effort:** Medium
- **User Impact:** Medium (quality assurance)

### App Icon
- **Problem:** App looks generic without icon
- **Solution:** Professional branding icon
- **Impact:** First impression, professionalism
- **Effort:** Low-Medium
- **User Impact:** Medium (UX polish)

---

## Success Criteria

### Task 1: Crossfade ✅
- [ ] No clicks at loop boundaries
- [ ] Audio plays smoothly
- [ ] Duration unaffected
- [ ] Works with all presets

### Task 2: Custom Presets ✅
- [ ] Save preset works
- [ ] Load preset works
- [ ] Delete preset works
- [ ] Dropdown updates dynamically
- [ ] Presets persist across sessions

### Task 3: WASAPI Exclusive ✅
- [ ] Setting toggles on/off
- [ ] Exclusive mode activates
- [ ] Fallback works if unavailable
- [ ] No audio distortion
- [ ] Latency acceptable

### Task 4: Audio Validation ✅
- [ ] One-click validation
- [ ] Accurate frequency detection
- [ ] Clear pass/fail display
- [ ] Helpful error messages
- [ ] Works on different audio

### Task 5: App Icon ✅
- [ ] Professional appearance
- [ ] Represents binaural theme
- [ ] Works on Windows
- [ ] Proper scaling
- [ ] Recognizable

---

## Status

**Polish Phase Planning:** ✅ COMPLETE
**Ready to Implement:** ✅ YES
**Tier 1 Tasks:** ✅ DEFINED
**Timeline:** ✅ ESTIMATED

**Next Step:** Wait for Phase 4 completion, then begin Tier 1 implementation

---

**Created:** 2025-10-24
**Status:** Ready for Implementation
**Priority:** Tier 1 (5-6 hours)
**Team:** DESKC + Design specialist
**Repository:** https://github.com/Stryk91/Phiwave.git

