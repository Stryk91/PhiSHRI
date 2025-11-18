# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PhiWave** is a Python audio synthesis tool that generates **binaural beats** and **isochronic tones** using Fibonacci numbers and the golden ratio. The project focuses on frequency-based entrainment for meditation, relaxation, and focus.

- **Binaural mode:** Left/right frequency differential via stereo channels (requires headphones)
- **Isochronic mode:** Single carrier pulsed with smooth amplitude envelope (works on speakers/headphones)
- **Presets:** Fibonacci (1, 2, 3, 5, 8, 13 Hz), Golden Ratio multiples (1.618, 3.236, etc.), Schumann (7.83 Hz), and custom ramps

**Key constraints enforced in code:**
- Beat frequencies: 0.5–15 Hz
- Carrier frequencies: 60–125 Hz
- Safety: fade-in/out to prevent clicks, volume control

---

## How to Run

### Quick Start
```bash
# 1. Install dependencies (venv recommended)
pip install numpy scipy sounddevice soundfile

# 2. Run the interactive menu
python binaural_presets.py

# 3. Use headphones for binaural; start with low volume
```

### Alternative: Test specific presets programmatically
```python
from binaural_presets import play_binaural, play_isochronic

# Play a 5-minute Golden Alpha binaural (100 Hz carrier, 8 Hz beat)
play_binaural(base_freq=100.0, beat_freq=8.0, duration=300)

# Play isochronic with custom sharpness
play_isochronic(base_freq=100.0, beat_freq=5.0, duration=300,
                pulse_sharpness=2.5, off_gain=0.1)
```

---

## Codebase Architecture

### Current Structure
```
MindstateClone/
├── binaural_presets.py       # Main entry point: audio engines, menu system
├── audio/
│   └── noise.py              # Shim re-exporting from top-level noise.py
├── noise.py                  # White/Pink/Brown noise generators (scipy.signal)
├── export.py                 # WAV/FLAC file export via soundfile
├── presets.json              # (Partial) preset storage
├── requirements.txt          # numpy, scipy, sounddevice, soundfile
└── docs/
    ├── presets.md            # Preset reference
    ├── protocols.md          # Frequency protocols & research notes
    ├── research.md           # Scientific background
    └── authoring.md          # Custom preset creation guide
```

### Design Phases
The DESIGN.md document outlines a **refactoring roadmap** moving from monolith to modular structure:
- **Phase 1:** Extract audio engines to `audio/engine.py` (pure functions)
- **Phase 2:** Add noise mixing (`audio/noise.py`) and export pipelines (`io/export.py`)
- **Phase 3:** Build Tkinter GUI (`ui/gui_tk.py`) with live playback controls
- **Phase 4:** Convert presets to JSON schema with loader (`presets/loader.py`)

**Current state:** Phases 1–2 partially implemented; `binaural_presets.py` is still the main entry point.

---

## Key Modules & Responsibilities

### `binaural_presets.py` (Main)
**~500 lines, monolithic**

Core responsibilities:
- **Audio generation:** `generate_binaural_segment()`, `generate_isochronic_segment()`
- **Playback:** `play_buffer()`, `play_binaural()`, `play_isochronic()`
- **Menus:** Interactive CLI with preset selection and custom mode
- **Utilities:** Input validation, device listing, fade envelope application

**Key functions:**
- `generate_binaural_segment(base_freq, beat_freq, duration, volume, fade_time, noise_type, noise_mix)` → stereo np.ndarray
  - Left channel: pure carrier
  - Right channel: carrier + beat frequency
  - Fade-in/out to prevent clicks
- `generate_isochronic_segment(base_freq, beat_freq, duration, ..., pulse_sharpness, off_gain)` → stereo np.ndarray
  - Carrier modulated by smooth amplitude gate at beat frequency
  - `pulse_sharpness` (1–6): tightens pulse envelope
  - `off_gain` (0–0.3): floor volume between pulses
- `play_buffer(buffer)` → blocks until playback complete via sounddevice

### `noise.py` (Top-level)
**~70 lines**

Background noise generators for masking/ambience:
- `white_noise(n, seed)` → uniform spectrum
- `pink_noise(n, seed)` → 1/f spectrum (IIR filter: Paul Kellet coefficients)
- `brown_noise(n, seed)` → 1/f² spectrum (cumsum + high-pass)
- `make_noise(type, n, seed)` → router function

**Exports mono float32 arrays.** Currently used in `binaural_presets.py` to blend with tones.

### `export.py`
**~45 lines**

File I/O wrapper:
- `write_wav(path, buffer, sample_rate)` → PCM 32-bit float WAV via soundfile
- `write_flac(path, buffer, sample_rate, bits)` → FLAC (16/24-bit) via soundfile
- `_sanitize(buffer)` → clip to [-1.0, 1.0] and ensure stereo shape (N, 2)

**Design:** Pure I/O, no side effects (no print statements).

### `audio/noise.py` (Shim)
**~5 lines**

Re-exports `make_noise` from top-level `noise.py` to enable `from audio.noise import make_noise` import path. Part of refactoring strategy to organize modules under `audio/` namespace.

---

## Common Development Tasks

### Add a New Preset
1. **Hardcoded:** Edit `presets_menu()` in `binaural_presets.py` (lines ~308–407)
   ```python
   binaural_items = [
       ("Name", base_freq_hz, beat_hz, duration_sec),
       ...
   ]
   ```

2. **JSON storage:** Edit `presets.json` (future; currently minimal)
   ```json
   {
     "presets": [
       {
         "id": "bn_custom",
         "name": "Custom Binaural",
         "mode": "binaural",
         "carrier_hz": 100.0,
         "beat_hz": 8.0,
         "duration_sec": 420,
         "volume": 0.25
       }
     ]
   }
   ```

### Export a Session to WAV
```python
from binaural_presets import generate_binaural_segment
from export import write_wav

# Generate 10 minutes of audio
buf = generate_binaural_segment(base_freq=100, beat_freq=8, duration=600)

# Export
write_wav("session.wav", buf, sample_rate=44100)
```

### Mix Tone + Background Noise
```python
import numpy as np
from binaural_presets import generate_binaural_segment
from noise import make_noise

tone = generate_binaural_segment(100, 8, 300, volume=0.7)
noise = make_noise("pink", n=300 * 44100)

# Simple mix (no normalization)
mixed = tone + noise * 0.3  # 70% tone, 30% pink noise
```

### Test Audio Quality
The DESIGN.md includes a comprehensive test plan (section 4). Currently, tests are not automated; manual verification includes:
- **Fade symmetry:** Check `generate_binaural_segment(..., fade_time=0.5)` output starts/ends near 0
- **No clipping:** Verify `max(abs(buffer)) <= volume` for any parameter combo
- **Frequency accuracy:** FFT analysis of generated segments vs. expected beat frequency
- **Ramp continuity:** Ensure adjacent segments don't have discontinuous jumps

---

## Safety & Constraints

**Hardcoded in code:**
- `MAX_BEAT = 15.0` Hz — upper limit for entrainment safety
- `MAX_CARRIER = 125.0` Hz — avoid high-frequency hearing damage
- `DEFAULT_VOLUME = 0.25` — start conservatively
- `FADE_TIME = 0.5` — 500ms fade to prevent clicks

**User-facing warnings:**
- "Headphones required for binaural"
- "Start with low volume"
- Device troubleshooting via `list_output_devices()`

---

## Documentation & References

Key files in `docs/`:
- **presets.md** — Detailed preset descriptions, frequency meanings
- **protocols.md** — Frequency protocols (Schumann, Theta, Alpha, etc.)
- **research.md** — Scientific citations on binaural beats and entrainment
- **authoring.md** — Guide for creating custom presets

Key files in root:
- **DESIGN.md** — Refactoring roadmap (phases 1–4, test plan, data schemas)
- **GUI_CONCEPT.md** — UI mockups for future Tkinter GUI
- **Visual Design.md** — Color schemes, branding
- **README.md** — Quick start, features, troubleshooting

---

## Roadmap & Future Work

**Short-term (Phase 2):**
- [ ] Refactor audio engines to `audio/engine.py` with pure functions
- [ ] Implement JSON preset loader with validation
- [ ] Add automated test suite (see DESIGN.md section 4)

**Medium-term (Phase 3):**
- [ ] Build Tkinter GUI with mode/preset dropdowns and live controls
- [ ] Add export button with file picker dialog
- [ ] Implement session save/load (JSON + WAV pair)

**Long-term (Phase 4):**
- [ ] Frequency ramping with crossfades inside single buffer
- [ ] Multi-voice layering (e.g., Phi Trinity carriers)
- [ ] Visualizer (matplotlib FFT or spectrum analyzer)
- [ ] Real-time parameter modulation during playback

---

## Dependency Notes

**Required:** numpy, scipy, sounddevice, soundfile

**Optional (future):**
- `pytest` — automated testing
- `tkinter` — built-in with Python (GUI)
- `matplotlib` — visualization
- `soundfile` — already installed for FLAC

**Audio backend:** sounddevice uses PortAudio (cross-platform); auto-detects system audio device.

---

## Known Issues & Gotchas

1. **Import path confusion:** `audio/noise.py` is a shim re-exporting from top-level `noise.py`. During refactoring, ensure both paths work during transition.

2. **Streaming playback not implemented:** Current `play_buffer()` blocks; future non-blocking API planned in Phase 3 (threading for GUI responsiveness).

3. **Preset JSON not yet enforced:** `presets.json` exists but is not loaded by default; menu still uses hardcoded tuples in `presets_menu()`.

4. **No session replay:** Export creates WAV but no metadata to reconstruct exact segment sequence; future enhancement to save alongside `.json` sidecar.

5. **Noise array dimensionality:** `noise.py` returns mono (1D), but `generate_binaural_segment()` expects 2D stereo. Code handles this implicitly; refactoring should standardize to always return (N, 2).

---

## Q&A for Future Development

**Q: How do I add a new noise type?**
A: Implement a new function in `noise.py` (e.g., `blue_noise(n, seed)`) and add a case in `make_noise()` router.

**Q: How do I support custom user presets?**
A: Load JSON from a user config directory, validate against schema in DESIGN.md section 3, and dynamically populate `presets_menu()`.

**Q: How do I add GUI support?**
A: Follow Phase 3 in DESIGN.md; create `ui/gui_tk.py` with Tkinter, run playback in a background thread, and wire `Stop` button to raise `STREAM_STOP` flag.

**Q: Can I export to MP3?**
A: Not currently; `soundfile` doesn't support MP3. Use `pydub` with ffmpeg backend, or stick to WAV/FLAC.

**Q: How do I test fade logic?**
A: See DESIGN.md test plan, section 4.1 (envelope & fade testing). Manually verify first/last fade_samples match expected ramp.
