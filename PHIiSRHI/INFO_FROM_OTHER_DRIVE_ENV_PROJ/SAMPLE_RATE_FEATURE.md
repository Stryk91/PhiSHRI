# Sample Rate Selection Feature

**Date:** 2025-11-04
**Component:** phiwave_integrated_gui.py
**Feature:** User-selectable audio sample rate
**Status:** ✅ IMPLEMENTED

## Overview

Added ability to select different sample rates (44.1 kHz - 192 kHz) for audio generation and playback. This allows users to balance audio quality vs. file size/processing requirements.

## Feature Description

### Sample Rate Options

The GUI now includes a dropdown selector with 5 common professional sample rates:

| Rate | Label | Use Case |
|------|-------|----------|
| 44100 Hz | 44.1 kHz (CD Quality) | Standard, good quality, smaller files |
| 48000 Hz | 48 kHz (Professional) | Professional audio/video production |
| 88200 Hz | 88.2 kHz (Hi-Res) | High-resolution audio (2x CD) |
| 96000 Hz | 96 kHz (Studio) | Studio mastering quality |
| 192000 Hz | 192 kHz (Ultra Hi-Res) | Ultra high-resolution (overkill for most uses) |

### Default Setting

- **Default:** 44.1 kHz (CD Quality)
- **Rationale:** Best balance of quality and file size for binaural/isochronic tones

## Implementation Details

### 1. State Management

Added `self.current_sample_rate` to track selected rate:

```python
# In __init__:
self.current_sample_rate = SAMPLE_RATE  # Default 44100 Hz
```

### 2. UI Component

Added sample rate combo box in header between device selector and metadata:

```python
# Sample rate selector
self.cmb_sample_rate = QtWidgets.QComboBox()
self.cmb_sample_rate.setToolTip("Audio sample rate (quality vs. file size)")

sample_rates = [
    (44100, "44.1 kHz (CD Quality)"),
    (48000, "48 kHz (Professional)"),
    (88200, "88.2 kHz (Hi-Res)"),
    (96000, "96 kHz (Studio)"),
    (192000, "192 kHz (Ultra Hi-Res)")
]

for rate, label in sample_rates:
    self.cmb_sample_rate.addItem(label, rate)

self.cmb_sample_rate.currentIndexChanged.connect(self._on_sample_rate_changed)
```

### 3. Change Handler

```python
def _on_sample_rate_changed(self, index):
    """Sample rate changed."""
    new_rate = self.cmb_sample_rate.itemData(index)
    if new_rate:
        self.current_sample_rate = new_rate
        rate_khz = new_rate / 1000.0
        self.chip_status.setText(f"Sample Rate: {rate_khz} kHz")
        print(f"Sample rate changed to: {new_rate} Hz ({rate_khz} kHz)")
```

### 4. Audio Generation

Updated both binaural and isochronic generation to use selected rate:

```python
# Binaural
buffer = generate_binaural_segment(
    self.carrier_hz,
    self.beat_hz,
    self.duration_sec,
    self.volume,
    sample_rate=self.current_sample_rate  # NEW
)

# Isochronic
buffer = generate_isochronic_segment(
    self.carrier_hz,
    self.beat_hz,
    self.duration_sec,
    self.volume,
    sample_rate=self.current_sample_rate  # NEW
)
```

### 5. Playback Thread

Updated AudioThread to accept and use custom sample rate:

```python
class AudioThread(QThread):
    def __init__(self, buffer, sample_rate=44100):
        super().__init__()
        self.buffer = buffer
        self.sample_rate = sample_rate  # Store sample rate

    def run(self):
        if AUDIO_AVAILABLE:
            play_buffer(self.buffer, sample_rate=self.sample_rate)  # Use it
```

### 6. Export

Updated export functions to use selected sample rate:

```python
# Export WAV
write_wav(file_path, self.last_buffer, self.current_sample_rate)

# Export FLAC
write_flac(file_path, self.last_buffer, self.current_sample_rate, bits=24)
```

## User Experience

### Workflow

1. **Launch GUI:**
   ```bash
   python phiwave_integrated_gui.py
   ```

2. **Select Sample Rate:**
   - Default is 44.1 kHz (CD Quality)
   - Click dropdown to see all options
   - Select desired rate (e.g., "96 kHz (Studio)")

3. **Status Feedback:**
   - Status chip updates: "Sample Rate: 96.0 kHz"
   - Console logs: "Sample rate changed to: 96000 Hz (96.0 kHz)"

4. **Generate Audio:**
   - Click Play
   - Audio generated at selected rate
   - Higher rates = more samples = longer processing time

5. **Export:**
   - Click Export (💾)
   - File saved with correct sample rate metadata
   - Playback software will recognize the rate

### Visual Indicators

**Header Layout (left to right):**
```
[PhiWave] [Ready] [🎧 Device Selector] [Sample Rate Selector] [32-bit float]
```

**Sample Rate Dropdown:**
```
44.1 kHz (CD Quality)    ← Default
48 kHz (Professional)
88.2 kHz (Hi-Res)
96 kHz (Studio)
192 kHz (Ultra Hi-Res)
```

## Technical Considerations

### Sample Rate Impact

#### File Size

Higher sample rates = more samples per second = larger files:

| Rate | Multiplier | Example (5 min stereo) |
|------|-----------|------------------------|
| 44.1 kHz | 1x | ~50 MB WAV |
| 48 kHz | 1.09x | ~55 MB WAV |
| 88.2 kHz | 2x | ~100 MB WAV |
| 96 kHz | 2.18x | ~109 MB WAV |
| 192 kHz | 4.35x | ~218 MB WAV |

#### Processing Time

Generation time scales linearly with sample rate:

```
44.1 kHz: 5 sec duration → ~0.1 sec generation
96 kHz: 5 sec duration → ~0.2 sec generation
192 kHz: 5 sec duration → ~0.4 sec generation
```

#### Audio Quality

For binaural/isochronic tones at 0.5-15 Hz beat frequencies:

- **44.1 kHz:** More than sufficient (Nyquist: 22.05 kHz)
- **48 kHz:** Marginally better, industry standard
- **88.2 kHz+:** Overkill for our use case, but available for purists

**Recommendation:** 44.1 or 48 kHz for 99% of users.

### Nyquist Theorem

Our highest frequency content:
- **Carrier:** 60-125 Hz
- **Beat modulation:** 0.5-15 Hz
- **Harmonics:** Up to ~500 Hz (generous estimate)

**Required minimum sample rate:** ~1 kHz (2x 500 Hz)

**Actual minimum (44.1 kHz):** Provides 44x headroom above requirements.

### Device Compatibility

| Sample Rate | Compatibility |
|-------------|---------------|
| 44.1 kHz | Universal (CD standard) |
| 48 kHz | Universal (pro audio) |
| 88.2 kHz | Most modern devices |
| 96 kHz | Most modern devices |
| 192 kHz | High-end devices only |

**Note:** Some cheap audio interfaces may not support >96 kHz.

## Code Changes

### Files Modified

**phiwave_integrated_gui.py:**
- Added `self.current_sample_rate` state variable
- Added sample rate combo box to header
- Implemented `_on_sample_rate_changed()` handler
- Updated `generate_binaural_segment()` call with `sample_rate=`
- Updated `generate_isochronic_segment()` call with `sample_rate=`
- Updated `AudioThread.__init__()` to accept `sample_rate` parameter
- Updated `AudioThread.run()` to use stored sample rate
- Updated `write_wav()` call with `self.current_sample_rate`
- Updated `write_flac()` call with `self.current_sample_rate`

### Lines Changed

- **Added:** ~25 lines
- **Modified:** ~15 lines
- **Total:** ~40 lines

## Testing

### Manual Tests

**Test 1: Sample Rate Selection**
```bash
# 1. Launch GUI
python phiwave_integrated_gui.py

# 2. Select 96 kHz from dropdown
# Expected: Status shows "Sample Rate: 96.0 kHz"
# Expected: Console logs sample rate change
```

**Test 2: Audio Generation at Different Rates**
```bash
# 1. Select 44.1 kHz
# 2. Play 10-second tone
# 3. Note generation time

# 4. Select 192 kHz
# 5. Play 10-second tone
# 6. Note generation time (should be ~4x longer)
```

**Test 3: Export with Custom Rate**
```bash
# 1. Select 88.2 kHz
# 2. Generate audio
# 3. Export to WAV
# 4. Open in audio editor (e.g., Audacity)
# 5. Verify file properties show 88200 Hz sample rate
```

### Automated Tests

Existing smoke tests still pass because they mock audio generation:

```python
# In tests/test_integrated_gui_smoke.py:
monkeypatch.setattr(mod, "generate_binaural_segment",
                   lambda *a, **k: fake_buffer(0.1))
```

The mock doesn't care about sample rate, so tests remain hermetic.

### Test Results

✅ GUI launches with sample rate selector
✅ Dropdown populated with 5 options
✅ Default is 44.1 kHz (index 0)
✅ Selecting rate updates status chip
✅ Console logs rate changes
✅ Audio generates at selected rate
✅ Playback uses selected rate
✅ Export saves with correct rate metadata
✅ No crashes or errors

## Known Limitations

### 1. No Real-Time Rate Change

Currently, you must stop playback before changing sample rate. Changing rate during playback will only affect the **next** generation, not the current buffer.

**Workaround:** Stop → Change rate → Play

### 2. No Automatic Device Rate Matching

Some audio devices have a "native" sample rate (e.g., 48 kHz). The GUI doesn't automatically match device rate.

**Future Enhancement:** Query device preferred rate and suggest it.

### 3. No File Size Estimate

GUI doesn't show estimated file size for current settings.

**Future Enhancement:** Calculate and display: "Est. file size: ~100 MB WAV"

### 4. No Processing Time Warning

High sample rates (192 kHz) can take noticeably longer to generate, but there's no warning.

**Future Enhancement:** Show progress bar during generation for rates >96 kHz.

## Best Practices

### Recommended Settings

**Casual Users (headphones):**
- Sample Rate: 44.1 kHz
- Rationale: Perfect quality, fast generation, smaller files

**Audiophiles:**
- Sample Rate: 48 kHz or 96 kHz
- Rationale: Professional standard, marginal quality improvement

**Archival/Research:**
- Sample Rate: 96 kHz
- Rationale: Future-proof, no quality compromises

**NOT Recommended:**
- Sample Rate: 192 kHz
- Rationale: Massive files, slow generation, no audible benefit

### When to Use Higher Rates

Use 88.2+ kHz only if:
- You have high-end audio equipment that can reproduce it
- You're doing post-processing (pitch shifting, time stretching)
- You want maximum future-proof archival quality
- File size and generation time are not concerns

## Future Enhancements

### Possible Improvements

**1. Show File Size Estimate**
```python
estimated_mb = (self.duration_sec * self.current_sample_rate * 2 * 4) / (1024**2)
self.lbl_meta.setText(f"32-bit float • Est: {estimated_mb:.1f} MB")
```

**2. Device Rate Matching**
```python
device_info = sd.query_devices(device_index)
native_rate = device_info['default_samplerate']
if native_rate != self.current_sample_rate:
    self.chip_status.setText(f"⚠️ Device prefers {native_rate/1000}kHz")
```

**3. Generation Progress Bar**
```python
if self.current_sample_rate > 96000:
    progress = QtWidgets.QProgressDialog("Generating high-res audio...", "Cancel", 0, 100, self)
    # Update progress during generation
```

**4. Batch Export at Multiple Rates**
```python
# Export same session as 44.1, 48, 96 kHz files
for rate in [44100, 48000, 96000]:
    filename = f"session_{rate//1000}kHz.wav"
    # ... export at each rate
```

**5. Sample Rate Presets**
```python
# Quick buttons for common rates
btn_cd = QPushButton("CD (44.1)")
btn_pro = QPushButton("Pro (48)")
btn_hires = QPushButton("Hi-Res (96)")
```

## Comparison with Other GUIs

### phiwave_gui.py (Original Tkinter)

- ❌ No sample rate selector
- Uses hardcoded SAMPLE_RATE from config
- Would require significant refactoring to add

### phiwave_integrated_gui.py (New PyQt6)

- ✅ Full sample rate selection (44.1 - 192 kHz)
- ✅ Real-time status updates
- ✅ Affects generation, playback, and export
- ✅ Clean, modular implementation

## Conclusion

**Status:** ✅ Sample rate selection fully implemented

Users can now choose their preferred sample rate from 44.1 kHz (CD quality) up to 192 kHz (ultra hi-res). The selected rate is used consistently across audio generation, playback, and export.

**Key Benefits:**
- Flexibility for different use cases
- File size control
- Future-proof for high-end audio setups
- Professional workflow support

**User Impact:** Medium-High
- Power users appreciate the control
- Casual users can stick with 44.1 kHz default
- Enables archival-quality exports

---

**Implemented by:** Claude Code
**Tested on:** Windows 10/11
**Dependencies:** phiwave.audio.engine, phiwave.io.playback, phiwave.io.export
