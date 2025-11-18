# Mindstate Clone — Architecture & Design

## 1. Architecture Split

### Current State
Single monolithic file (`binaural_presets.py`, ~330 lines) mixing audio generation, playback, UI, and preset logic.

### Proposed Structure

```
MindstateClone/
├─ audio/
│  ├─ __init__.py
│  ├─ engine.py          # Core signal generation (binaural, isochronic)
│  ├─ noise.py           # Background noise generators (white, pink, brown)
│  └─ effects.py         # Future: filters, reverb, spatial
├─ io/
│  ├─ __init__.py
│  ├─ export.py          # WAV/FLAC file export
│  └─ playback.py        # sounddevice wrapper, device management
├─ presets/
│  ├─ __init__.py
│  ├─ loader.py          # JSON/CSV preset loading
│  └─ defaults.py        # Hardcoded Fibonacci/Phi presets
├─ ui/
│  ├─ __init__.py
│  ├─ cli.py             # Current CLI menu (refactored)
│  └─ gui_tk.py          # Tkinter GUI (new)
├─ utils/
│  ├─ __init__.py
│  └─ validation.py      # Parameter validation logic
├─ tests/
│  ├─ test_engine.py
│  ├─ test_noise.py
│  ├─ test_export.py
│  └─ test_validation.py
├─ config.py             # Global constants, sample rates
├─ main_cli.py           # CLI entry point
└─ main_gui.py           # GUI entry point (future)
```

---

## 2. Module Responsibilities

### `audio/engine.py`
**Core signal generation with zero I/O dependencies.**

**Responsibilities:**
- `generate_binaural_segment()` — Stereo L/R frequency differential
- `generate_isochronic_segment()` — Mono carrier × amplitude gate
- `apply_fade()` — Fade-in/out window generation (extract shared logic)
- `validate_segment_params()` — Moved from inline checks

**Key principle:** Pure functions: `(params) → np.ndarray`. No side effects, no `print()`, no `sd.play()`.

**Rationale:** Enables unit testing, export workflows, and GUI preview generation without playback coupling.

---

### `audio/noise.py`
**Background noise generation for masking/ambience.**

**Responsibilities:**
- `generate_white_noise(duration, volume, sample_rate)` — Uniform spectrum
- `generate_pink_noise(duration, volume, sample_rate)` — 1/f power spectrum
- `generate_brown_noise(duration, volume, sample_rate)` — 1/f² spectrum
- `mix_layers(buffers: list[np.ndarray], weights: list[float])` — Combine noise + tones

**Design notes:**
- Pink/brown use spectral shaping via FFT filtering or IIR filters (scipy.signal)
- All generators return `(N, 2)` stereo arrays for consistency
- `mix_layers()` normalizes to prevent clipping after summation

---

### `io/export.py`
**File I/O for session recording.**

**Responsibilities:**
- `export_wav(buffer, filepath, sample_rate, bit_depth=16)` — PCM WAV
- `export_flac(buffer, filepath, sample_rate)` — Lossless compression
- `export_session_metadata(filepath, session_data: dict)` — JSON sidecar file

**Dependencies:** `scipy.io.wavfile` for WAV, `soundfile` or `pydub` for FLAC.

**Edge cases:**
- Clipping prevention: auto-normalize if `max(abs(buffer)) > 1.0`
- Stereo validation: reject mono buffers or auto-convert
- File overwrite confirmation in CLI/GUI layers (not in export logic)

---

### `io/playback.py`
**Playback abstraction over sounddevice.**

**Responsibilities:**
- `play_buffer(buffer, sample_rate, blocking=True)` — Current wrapper, extracted
- `list_devices()` → `list[dict]` — Device enumeration
- `set_default_device(index)` — Persist device selection
- `stop_playback()` — Non-blocking stop for GUI

**Why separate from engine:** Playback is I/O-bound and platform-dependent. Engine stays testable without audio hardware.

---

### `ui/gui_tk.py`
**Tkinter GUI with live controls.**

**Layout:**
```
┌─────────────────────────────────────┐
│ [Mode: Binaural ▾] [Preset: Fib 8 ▾]│
├─────────────────────────────────────┤
│ Carrier: [100] Hz  Beat: [8.0] Hz  │
│ Volume:  [▓▓▓▓▓░░░░░] 0.25         │
│ Duration: [420] sec                 │
├─────────────────────────────────────┤
│ [▶ Play]  [⏸ Pause]  [⏹ Stop]      │
│ [💾 Export WAV]  [🔊 Devices]       │
├─────────────────────────────────────┤
│ Noise Layer: [None ▾] Mix: 0%      │
│ ISO Sharpness: 2.0  Floor: 0.0     │
└─────────────────────────────────────┘
```

**Event flow:**
1. User selects preset → populate fields via `presets/loader.py`
2. User clicks Play → validate params → `audio/engine.py` → `io/playback.py`
3. User clicks Export → prompt filepath → `io/export.py`

**Threading:** Playback runs in background thread to avoid UI freeze. Stop button sends interrupt signal.

---

## 3. Data Schemas

### Preset Schema (JSON)

```json
{
  "schema_version": "1.0",
  "presets": [
    {
      "id": "bn_fib_8",
      "name": "BN Fib 8 - Golden Alpha",
      "mode": "binaural",
      "carrier_hz": 100.0,
      "beat_hz": 8.0,
      "duration_sec": 420,
      "volume": 0.25,
      "tags": ["fibonacci", "alpha", "focus"],
      "description": "Fibonacci 8Hz binaural for relaxed focus"
    },
    {
      "id": "iso_schumann",
      "name": "ISO Schumann 7.83",
      "mode": "isochronic",
      "carrier_hz": 100.0,
      "beat_hz": 7.83,
      "duration_sec": 420,
      "volume": 0.25,
      "pulse_sharpness": 2.0,
      "off_gain": 0.0,
      "tags": ["schumann", "grounding"],
      "description": "Schumann resonance isochronic for grounding"
    }
  ]
}
```

**Validation rules:**
- `carrier_hz`: (0, 125]
- `beat_hz`: (0, 15]
- `volume`: (0, 1]
- `pulse_sharpness` (ISO only): [1.0, 10.0]
- `off_gain` (ISO only): [0, 0.9)

---

### Session Schema (JSON)

Used for export metadata and future session replay.

```json
{
  "schema_version": "1.0",
  "session": {
    "timestamp": "2025-10-21T14:32:00Z",
    "duration_total_sec": 420,
    "segments": [
      {
        "start_sec": 0,
        "duration_sec": 420,
        "mode": "binaural",
        "carrier_hz": 100.0,
        "beat_hz": 8.0,
        "volume": 0.25
      }
    ],
    "noise_layers": [
      {
        "type": "pink",
        "volume": 0.1,
        "mix_ratio": 0.15
      }
    ],
    "sample_rate": 44100,
    "export_format": "wav",
    "notes": "Morning focus session"
  }
}
```

**Use cases:**
- Save alongside exported WAV as `session_name.json`
- Future: load session → regenerate exact audio → replay or re-export

---

### Ramp Sequence Schema

For multi-segment frequency progressions (e.g., Fibonacci ramp).

```json
{
  "ramp_id": "fibonacci_meditation",
  "name": "Fibonacci Ramp 3→5→8→13",
  "mode": "binaural",
  "carrier_hz": 100.0,
  "volume": 0.25,
  "segments": [
    {"beat_hz": 3.0, "duration_sec": 120, "label": "Deep Meditation"},
    {"beat_hz": 5.0, "duration_sec": 120, "label": "Meditation"},
    {"beat_hz": 8.0, "duration_sec": 120, "label": "Alpha Focus"},
    {"beat_hz": 13.0, "duration_sec": 120, "label": "Active Alpha"}
  ],
  "crossfade_sec": 0.0,
  "description": "Progressive entrainment from delta to alpha"
}
```

**Future enhancement:** `crossfade_sec > 0` → smooth frequency interpolation between segments.

---

## 4. Test Plan

### 4.1 Envelope & Fade Testing

**Objective:** Verify click-free transitions and correct amplitude shaping.

**Test cases:**

#### T1: Fade-in/out symmetry
```python
def test_fade_symmetry():
    seg = generate_binaural_segment(100, 8, 10, fade_time=0.5)
    fade_samples = int(0.5 * 44100)
    
    # Check first 0.5s ramps from 0 → 1
    assert np.allclose(seg[0, 0], 0.0, atol=1e-3)
    assert np.allclose(seg[fade_samples-1, 0], seg[fade_samples-1, 0], atol=1e-2)
    
    # Check last 0.5s ramps from 1 → 0
    assert np.allclose(seg[-1, 0], 0.0, atol=1e-3)
```

#### T2: No clipping in fade zone
```python
def test_fade_no_clip():
    seg = generate_binaural_segment(100, 8, 5, volume=0.9)
    assert np.max(np.abs(seg)) <= 0.9
```

#### T3: Isochronic gate shape
```python
def test_iso_gate_shape():
    # Generate 1Hz isochronic for 2 seconds (2 full pulses)
    seg = generate_isochronic_segment(100, 1.0, 2.0, pulse_sharpness=2.0, off_gain=0.0)
    
    # Extract envelope by taking abs of one channel
    envelope = np.abs(seg[:, 0])
    
    # Find peaks (should be ~2 at 1-second intervals)
    from scipy.signal import find_peaks
    peaks, _ = find_peaks(envelope, height=0.5)
    assert len(peaks) == 2
    
    # Verify off_gain floor (should approach 0 between pulses)
    min_amp = np.min(envelope[1000:20000])  # Skip fade-in
    assert min_amp < 0.05
```

#### T4: Pulse sharpness effect
```python
def test_pulse_sharpness():
    seg_sharp = generate_isochronic_segment(100, 5, 1, pulse_sharpness=4.0)
    seg_soft = generate_isochronic_segment(100, 5, 1, pulse_sharpness=1.5)
    
    # Higher sharpness → narrower duty cycle → lower RMS
    assert np.sqrt(np.mean(seg_sharp**2)) < np.sqrt(np.mean(seg_soft**2))
```

---

### 4.2 Ramp Continuity Testing

**Objective:** Ensure multi-segment ramps have no discontinuities.

#### T5: Segment boundary continuity
```python
def test_ramp_boundaries():
    seg1 = generate_binaural_segment(100, 3, 5)
    seg2 = generate_binaural_segment(100, 5, 5)
    
    # Last sample of seg1 should fade to ~0
    assert np.abs(seg1[-1, 0]) < 0.01
    
    # First sample of seg2 should start at ~0
    assert np.abs(seg2[0, 0]) < 0.01
```

#### T6: Frequency accuracy in ramps
```python
def test_ramp_frequency_accuracy():
    # Generate 3Hz binaural for 1 second
    seg = generate_binaural_segment(100, 3, 1)
    
    # FFT to verify 3Hz beat (difference between L/R)
    from scipy.fft import rfft, rfftfreq
    diff_signal = seg[:, 1] - seg[:, 0]
    fft = np.abs(rfft(diff_signal))
    freqs = rfftfreq(len(diff_signal), 1/44100)
    
    # Peak should be at 3Hz ±0.1Hz
    peak_freq = freqs[np.argmax(fft)]
    assert 2.9 <= peak_freq <= 3.1
```

---

### 4.3 Clipping Prevention

**Objective:** No sample exceeds [-1, 1] range under any parameter combination.

#### T7: Volume boundary test
```python
@pytest.mark.parametrize("volume", [0.05, 0.25, 0.5, 0.8, 1.0])
def test_no_clip_at_volumes(volume):
    seg_bn = generate_binaural_segment(100, 8, 1, volume=volume)
    seg_iso = generate_isochronic_segment(100, 8, 1, volume=volume)
    
    assert np.max(np.abs(seg_bn)) <= volume
    assert np.max(np.abs(seg_iso)) <= volume
```

#### T8: Noise mixing clipping
```python
def test_noise_mix_no_clip():
    tone = generate_binaural_segment(100, 8, 1, volume=0.5)
    noise = generate_pink_noise(1, volume=0.5)
    
    # mix_layers should normalize if sum > 1.0
    mixed = mix_layers([tone, noise], weights=[1.0, 0.3])
    assert np.max(np.abs(mixed)) <= 1.0
```

---

### 4.4 Edge Cases & Validation

#### T9: Parameter validation
```python
def test_invalid_params():
    with pytest.raises(ValueError):
        generate_binaural_segment(200, 8, 1)  # carrier > MAX_CARRIER
    
    with pytest.raises(ValueError):
        generate_binaural_segment(100, 20, 1)  # beat > MAX_BEAT
    
    with pytest.raises(ValueError):
        generate_isochronic_segment(100, 8, 1, pulse_sharpness=15)  # sharpness > 10
```

#### T10: Zero-duration handling
```python
def test_zero_duration():
    with pytest.raises(ValueError):
        generate_binaural_segment(100, 8, 0)
```

#### T11: Extreme fade times
```python
def test_fade_exceeds_duration():
    # If fade_time > duration/2, should auto-clamp
    seg = generate_binaural_segment(100, 8, 1, fade_time=2.0)
    # Should not raise, fade should be clamped to 0.5s
    assert seg.shape[0] == 44100
```

---

### 4.5 Export Format Testing

#### T12: WAV file integrity
```python
def test_wav_export():
    seg = generate_binaural_segment(100, 8, 2)
    export_wav(seg, "/tmp/test.wav", 44100)
    
    # Re-load and verify
    from scipy.io import wavfile
    rate, data = wavfile.read("/tmp/test.wav")
    
    assert rate == 44100
    assert data.shape[0] == 2 * 44100  # 2 seconds
    assert data.shape[1] == 2  # Stereo
```

#### T13: FLAC export
```python
def test_flac_export():
    seg = generate_isochronic_segment(100, 5, 3)
    export_flac(seg, "/tmp/test.flac", 44100)
    
    import soundfile as sf
    data, rate = sf.read("/tmp/test.flac")
    assert rate == 44100
    assert data.shape == seg.shape
```

---

### 4.6 Performance Benchmarks

#### T14: Buffer generation speed
```python
def test_generation_speed():
    import time
    
    start = time.perf_counter()
    seg = generate_binaural_segment(100, 8, 300)  # 5 minutes
    elapsed = time.perf_counter() - start
    
    # Should generate faster than real-time
    assert elapsed < 1.0  # <1s to generate 5min audio
```

#### T15: Memory footprint
```python
def test_memory_usage():
    # 30 minutes @ 44.1kHz stereo float32 = ~12MB
    seg = generate_isochronic_segment(100, 8, 1800)
    expected_mb = 1800 * 44100 * 2 * 4 / (1024**2)
    
    actual_mb = seg.nbytes / (1024**2)
    assert abs(actual_mb - expected_mb) < 1  # Within 1MB
```

---

## 5. Migration Strategy

### Phase 1: Extract core (no breakage)
1. Create `audio/engine.py` with pure functions
2. Keep `binaural_presets.py` as wrapper calling new modules
3. Run existing CLI to verify behavioral equivalence

### Phase 2: Add noise & export
1. Implement `audio/noise.py`
2. Implement `io/export.py`
3. Add CLI commands: `--export session.wav`, `--noise pink 0.15`

### Phase 3: GUI
1. Build `ui/gui_tk.py` with basic playback controls
2. Wire to `presets/loader.py` for dropdown population
3. Add export button with file picker dialog

### Phase 4: Presets & sessions
1. Convert hardcoded presets to JSON in `presets/defaults.json`
2. Implement `presets/loader.py` with validation
3. Add session save/load in GUI

---

## 6. Success Metrics

**Efficiency = Quality / Time:**

1. **Code maintainability:** Module split reduces single-file complexity from 330 → <150 lines per file
2. **Test coverage:** Target 85% on `audio/` and `io/` modules
3. **Feature velocity:** Noise layer addition estimated 2h (vs. 6h in monolith due to coupling)
4. **Zero regressions:** All existing CLI presets work identically post-refactor

**Quality indicators:**
- No clipping detected in automated tests across 1000 random parameter combinations
- GUI responsiveness: <50ms lag on Play/Stop buttons (threading requirement)
- Export speed: Generate + write 30min session in <5s

---

## 7. Open Questions

1. **Crossfade algorithm:** Linear interpolation of beat frequency, or exponential? (Affects ramp smoothness)
2. **Preset taxonomy:** Should we support user-defined categories beyond Fibonacci/Phi? (JSON tags extensible)
3. **Real-time modulation:** Future feature to change beat frequency during playback without restart?
4. **Mobile export:** Should we target Android/iOS, or stay desktop-only? (Affects GUI framework choice)

---

## Appendix A: Analogy System

**For systematizers:**

- **Current codebase** = single conveyor belt with mixed tasks
- **Proposed architecture** = assembly line with specialized stations:
  - `audio/engine.py` = fabrication (raw materials → components)
  - `io/export.py` = packaging (components → shippable product)
  - `ui/gui_tk.py` = showroom (customer interaction layer)

**Benefits of separation:**
- Replace one station without stopping the line
- Test each station in isolation (unit tests)
- Parallelize development (audio team ≠ UI team)

---

## Appendix B: File Size Estimates

Post-refactor, approximate line counts:

| Module | Lines | Complexity |
|--------|-------|------------|
| `audio/engine.py` | 120 | Medium (math-heavy) |
| `audio/noise.py` | 80 | Low (repetitive generators) |
| `io/export.py` | 60 | Low (scipy wrappers) |
| `io/playback.py` | 50 | Low (sounddevice wrapper) |
| `ui/gui_tk.py` | 200 | Medium (Tk boilerplate) |
| `presets/loader.py` | 70 | Low (JSON validation) |
| `tests/` | 300 | Low (repetitive fixtures) |
| **Total** | **880** | vs. current 330 |

**Efficiency paradox:** More lines, but lower cognitive load per file = faster feature development.
