# Polish Phase Tier 1 - Detailed Task Specifications

**Status:** Ready for DESKC execution after Phase 4 completion
**Total Duration:** 5-6 hours across 5 tasks
**Priority:** HIGH - These improve audio quality and user experience significantly

---

## Task 1: Audio Loop Crossfade Fix (30 minutes)

**Problem:** Audio loops click/pop at the boundary when they repeat. Harsh audio artifact.

**Solution:** Apply fade envelope at loop boundary to blend end→start seamlessly.

**File to Modify:** `phiwave/audio/engine.py`

**Implementation:**

```python
import numpy as np

def add_loop_crossfade(audio_buffer: np.ndarray, fade_samples: int = 100) -> np.ndarray:
    """
    Add crossfade at audio loop boundary to eliminate clicks.

    Args:
        audio_buffer: Full audio array (mono or stereo)
        fade_samples: Number of samples for fade transition (default 100 @ 44.1kHz = 2.3ms)

    Returns:
        Audio buffer with applied crossfade
    """
    if len(audio_buffer) < fade_samples * 2:
        return audio_buffer  # Buffer too short to fade

    # Create fade envelopes
    fade_out = np.linspace(1.0, 0.0, fade_samples)
    fade_in = np.linspace(0.0, 1.0, fade_samples)

    # Apply fade to end of buffer
    audio_buffer[-fade_samples:] *= fade_out

    # Apply fade to start of buffer
    audio_buffer[:fade_samples] *= fade_in

    return audio_buffer


# In generate_binaural_segment() and generate_isochronic_segment():
# Before returning audio, add:
#   audio = add_loop_crossfade(audio, fade_samples=100)
```

**Testing:**
1. Generate a 10-second binaural at 8 Hz
2. Play it looped 3 times
3. Listen for clicks/pops at loop boundaries
4. Expected: Smooth, seamless transitions with no artifacts

**Acceptance:** No audible clicks or pops when audio loops.

---

## Task 2: Custom Preset Manager (1 hour)

**Problem:** Users can load built-in presets but can't save their own presets.

**Solution:** Implement save/load system for user-created presets with JSON storage.

**Files to Create/Modify:**
- Create: `phiwave/presets/custom_presets.py` (new file)
- Modify: `phiwave_gui/controls/dropdowns.py` (add save button)

**Implementation:**

```python
# phiwave/presets/custom_presets.py

import json
from pathlib import Path
from dataclasses import dataclass, asdict
from datetime import datetime

@dataclass
class CustomPreset:
    """User-created preset"""
    name: str
    carrier_hz: float
    beat_hz: float
    duration_sec: int
    volume: float
    created_at: str = None

    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now().isoformat()


class CustomPresetManager:
    """Manage user custom presets"""

    def __init__(self, preset_dir: Path = None):
        self.preset_dir = preset_dir or Path.home() / ".phiwave" / "custom_presets"
        self.preset_dir.mkdir(parents=True, exist_ok=True)
        self.presets = self._load_all_presets()

    def _load_all_presets(self) -> dict:
        """Load all custom presets from disk"""
        presets = {}
        for preset_file in self.preset_dir.glob("*.json"):
            try:
                with open(preset_file) as f:
                    data = json.load(f)
                    preset = CustomPreset(**data)
                    presets[preset.name] = preset
            except Exception as e:
                print(f"Error loading preset {preset_file}: {e}")
        return presets

    def save_preset(self, preset: CustomPreset) -> bool:
        """Save preset to disk"""
        try:
            filepath = self.preset_dir / f"{preset.name}.json"
            with open(filepath, 'w') as f:
                json.dump(asdict(preset), f, indent=2)
            self.presets[preset.name] = preset
            return True
        except Exception as e:
            print(f"Error saving preset: {e}")
            return False

    def delete_preset(self, name: str) -> bool:
        """Delete a preset"""
        try:
            filepath = self.preset_dir / f"{name}.json"
            filepath.unlink()
            if name in self.presets:
                del self.presets[name]
            return True
        except Exception as e:
            print(f"Error deleting preset: {e}")
            return False

    def get_preset(self, name: str) -> CustomPreset:
        """Get preset by name"""
        return self.presets.get(name)

    def list_presets(self) -> list:
        """List all custom preset names"""
        return list(self.presets.keys())


# Integration in phiwave_gui:
# Add to PresetSelector in dropdowns.py:
#
# from phiwave.presets.custom_presets import CustomPresetManager
#
# self.custom_preset_mgr = CustomPresetManager()
#
# # Add save button to GUI
# save_btn = tk.Button(preset_frame, text="Save Preset",
#                      command=self.save_current_preset)
# save_btn.pack()
#
# def save_current_preset(self):
#     name = simpledialog.askstring("Save Preset", "Preset name:")
#     if name:
#         preset = CustomPreset(
#             name=name,
#             carrier_hz=self.parent.param_sliders.carrier_var.get(),
#             beat_hz=self.parent.param_sliders.beat_var.get(),
#             duration_sec=self.parent.param_sliders.duration_var.get(),
#             volume=self.parent.param_sliders.volume_var.get()
#         )
#         self.custom_preset_mgr.save_preset(preset)
#         self.update_preset_dropdown()
```

**Testing:**
1. Create 3 different parameter sets
2. Save each as "Test Preset 1/2/3"
3. Verify JSON files created in `~/.phiwave/custom_presets/`
4. Load each saved preset from dropdown
5. Verify parameters match saved values

**Acceptance:** Custom presets persist across sessions; can be loaded and reused.

---

## Task 3: WASAPI Exclusive Mode (1.5 hours)

**Problem:** Standard playback shares audio device with system sounds. Reduces audio quality.

**Solution:** Implement WASAPI exclusive mode for bit-perfect, exclusive access to audio device.

**Files to Create/Modify:**
- Create: `phiwave/io/exclusive_playback.py` (new file)
- Modify: `phiwave_gui/controls/dropdowns.py` (add exclusive mode checkbox)

**Implementation:**

```python
# phiwave/io/exclusive_playback.py

import sounddevice as sd
import numpy as np

class ExclusivePlayback:
    """WASAPI Exclusive mode playback for bit-perfect audio"""

    def __init__(self, device_index: int = None, sample_rate: int = 44100, channels: int = 2):
        self.device_index = device_index
        self.sample_rate = sample_rate
        self.channels = channels
        self.stream = None

    def start_exclusive_stream(self):
        """Start exclusive mode audio stream"""
        try:
            # Use exclusive=True for WASAPI exclusive mode (Windows only)
            self.stream = sd.OutputStream(
                device=self.device_index,
                samplerate=self.sample_rate,
                channels=self.channels,
                blocksize=0,
                exclusive=True,  # WASAPI exclusive mode
                latency='high'  # Reduced latency for exclusive access
            )
            self.stream.start()
            return True
        except Exception as e:
            print(f"Error starting exclusive stream: {e}")
            # Fallback to normal mode
            self.stream = sd.OutputStream(
                device=self.device_index,
                samplerate=self.sample_rate,
                channels=self.channels
            )
            self.stream.start()
            return False

    def play_audio(self, audio_buffer: np.ndarray):
        """Play audio in exclusive mode"""
        if self.stream is None:
            self.start_exclusive_stream()

        try:
            self.stream.write(audio_buffer)
        except Exception as e:
            print(f"Error playing audio: {e}")

    def stop(self):
        """Stop playback and close stream"""
        if self.stream:
            self.stream.stop()
            self.stream.close()
            self.stream = None


# Usage in phiwave_gui:
# Add checkbox in DeviceSelector:
#
# self.exclusive_mode_var = tk.BooleanVar(value=False)
# exclusive_cb = tk.Checkbutton(device_frame, text="Exclusive Mode (WASAPI)",
#                               variable=self.exclusive_mode_var,
#                               bg=COLORS.bg_control, fg=COLORS.text_primary)
# exclusive_cb.pack()
#
# Modify play_buffer() to use exclusive mode when enabled
```

**Testing:**
1. Enable exclusive mode checkbox
2. Play audio - verify it plays without system sounds
3. Try playing system sound while audio plays - should be muted
4. Disable exclusive mode - system sounds should work again
5. Check latency - exclusive mode should have lower latency

**Acceptance:** Exclusive mode works without errors; audio plays without system interference.

---

## Task 4: Audio Validation Tool (1 hour)

**Problem:** No way for users to verify audio quality (frequency content, levels, etc.).

**Solution:** Create FFT-based audio analyzer to display frequency spectrum.

**Files to Create:**
- Create: `phiwave/audio/validator.py` (new file)
- Create: `phiwave/tools/analyze_audio.py` (command-line tool)

**Implementation:**

```python
# phiwave/audio/validator.py

import numpy as np
from scipy.fft import fft, fftfreq

class AudioValidator:
    """Validate and analyze generated audio"""

    @staticmethod
    def analyze_frequency_content(audio_buffer: np.ndarray, sample_rate: int = 44100) -> dict:
        """Analyze frequency content using FFT"""
        # Mono conversion if stereo
        if audio_buffer.ndim > 1:
            audio_buffer = audio_buffer.mean(axis=1)

        # Apply Hann window to reduce spectral leakage
        window = np.hanning(len(audio_buffer))
        windowed = audio_buffer * window

        # Compute FFT
        fft_result = fft(windowed)
        freqs = fftfreq(len(audio_buffer), 1/sample_rate)
        magnitudes = np.abs(fft_result)

        # Find peaks (identify binaural/isochronic beats)
        peaks = self._find_peaks(magnitudes, freqs)

        return {
            "frequency_range": (freqs.min(), freqs.max()),
            "peak_frequencies": peaks,
            "rms_level": np.sqrt(np.mean(audio_buffer**2)),
            "peak_level": np.max(np.abs(audio_buffer)),
            "headroom_db": 20 * np.log10(1.0 / np.max(np.abs(audio_buffer))) if np.max(np.abs(audio_buffer)) > 0 else float('inf')
        }

    @staticmethod
    def _find_peaks(magnitudes: np.ndarray, freqs: np.ndarray, threshold: float = 0.1) -> list:
        """Find significant frequency peaks"""
        # Normalize magnitudes
        norm_mag = magnitudes / np.max(magnitudes)

        # Find peaks above threshold in positive frequencies
        peaks = []
        for i in range(1, len(magnitudes)-1):
            if freqs[i] > 0 and norm_mag[i] > threshold:
                if norm_mag[i] > norm_mag[i-1] and norm_mag[i] > norm_mag[i+1]:
                    peaks.append((freqs[i], norm_mag[i]))

        # Sort by magnitude
        peaks.sort(key=lambda x: x[1], reverse=True)
        return peaks[:10]  # Top 10 peaks

    @staticmethod
    def validate_binaural(audio_buffer: np.ndarray, beat_hz: float, sample_rate: int = 44100) -> dict:
        """Validate binaural beat generation"""
        analysis = AudioValidator.analyze_frequency_content(audio_buffer, sample_rate)

        # Check if beat frequency is present
        beat_detected = any(abs(freq - beat_hz) < 0.5 for freq, _ in analysis["peak_frequencies"])

        return {
            "analysis": analysis,
            "beat_detected": beat_detected,
            "expected_beat_hz": beat_hz,
            "rms_level_ok": analysis["rms_level"] < 0.9,  # Prevent clipping
            "status": "VALID" if beat_detected and analysis["rms_level_ok"] else "INVALID"
        }


# Command-line tool:
# python phiwave/tools/analyze_audio.py --file audio.wav --beat-hz 8
```

**Testing:**
1. Generate 10-second binaural at 8 Hz
2. Run validator on generated audio
3. Verify: 8 Hz peak is detected
4. Verify: RMS level is safe (no clipping)
5. Check output for frequency spectrum

**Acceptance:** Validator correctly identifies beat frequencies and audio levels.

---

## Task 5: App Icon Design & Integration (1-2 hours)

**Problem:** PhiWave uses default Python application icon (generic).

**Solution:** Design custom app icon with glossy chrome+neon theme; integrate into GUI.

**Files to Create/Modify:**
- Create: `assets/app/phiwave_icon.svg` (main icon design)
- Create: `assets/app/phiwave_icon.ico` (Windows executable icon)
- Modify: `phiwave_gui/app.py` (integrate icon into window)

**Implementation:**

```python
# Icon SVG: assets/app/phiwave_icon.svg
# (Design with phi spiral + neon glow, 256x256)

# Integration in phiwave_gui/app.py:

from pathlib import Path

class PhiWaveGUI:
    def __init__(self, root):
        self.root = root
        self.setup_window()
        self.set_app_icon()
        # ... rest of init

    def set_app_icon(self):
        """Set application icon"""
        icon_path = Path(__file__).parent.parent / "assets" / "app" / "phiwave_icon.ico"

        if icon_path.exists():
            try:
                self.root.iconbitmap(str(icon_path))
            except Exception as e:
                print(f"Could not set icon: {e}")
        else:
            print(f"Icon file not found: {icon_path}")
```

**Icon Design Specs:**
- Centered phi (φ) symbol or golden spiral
- Chrome gradient background (#CCCCCC → #111111)
- Neon glow in cyan (#6bd5ff)
- Size: 256x256 pixels (scalable SVG)
- Export to: ICO (32x32, 64x64), PNG (48x48, 64x64)

**Testing:**
1. Generate icon from SVG template
2. Convert to ICO format for Windows
3. Run GUI - verify icon displays in window title bar and taskbar
4. Check appearance at different scales

**Acceptance:** Custom icon displays in GUI; consistent with glossy theme.

---

## Quick Start for DESKC

All tasks are small (30 min - 1.5 hrs each) and self-contained. DESKC can grab any task:

```bash
# Task 1: Crossfade
cd E:\PythonProjects\PhiWave
# Edit phiwave/audio/engine.py, add crossfade function
# Test with: python -c "from phiwave.audio.engine import add_loop_crossfade; print('OK')"

# Task 2: Custom Presets
# Create phiwave/presets/custom_presets.py
# Modify phiwave_gui/controls/dropdowns.py

# Task 3: WASAPI Exclusive
# Create phiwave/io/exclusive_playback.py
# Modify phiwave_gui/controls/dropdowns.py

# Task 4: Audio Validator
# Create phiwave/audio/validator.py
# Create phiwave/tools/analyze_audio.py

# Task 5: App Icon
# Create assets/app/phiwave_icon.svg
# Create assets/app/phiwave_icon.ico
# Modify phiwave_gui/app.py
```

---

## Status

- **Phase 4:** Complete (Junie testing)
- **Glossy Theme:** Complete (IDE Claude)
- **Polish Phase Tier 1:** Ready to execute (DESKC)

All tasks are documented, templated, and ready for immediate implementation.
