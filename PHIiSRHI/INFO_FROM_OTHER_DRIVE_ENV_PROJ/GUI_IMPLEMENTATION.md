# PhiWave Integrated GUI - Implementation Guide

## Overview

The integrated GUI (`phiwave_integrated_gui.py`) combines the beautiful wireframe mockup design with full PhiWave audio engine functionality. This implementation provides a modern, glassmorphic interface for generating and playing binaural beats and isochronic tones.

## Features Implemented

### ✅ Core Functionality
- **Audio Engine Integration**: Full connection to PhiWave's modular audio engine
- **Multi-threading**: Non-blocking playback using QThread to keep UI responsive
- **Real-time Controls**: Live parameter adjustment for carrier, beat, duration, and volume
- **Mode Selection**: Support for Isochronic, Binaural, Monaural, and Bilateral modes
- **Preset System**: Quick access to 5 pre-configured frequency protocols
- **Export Capability**: Save sessions to WAV or FLAC format

### 🎨 Visual Design
- **Glassmorphic Theme**: Modern dark UI with semi-transparent glass cards
- **Animated Waveform**: Real-time dual-channel wave visualization
- **SVG Icon Support**: Mode buttons automatically load SVG icons from assets
- **Golden Accent Colors**: #D4AF37 and #F5E6B3 accent palette
- **Responsive Layout**: Scales properly at different window sizes

### 🎛️ UI Components

#### Header
- **PhiWave Branding**: Large golden logo text
- **Status Chip**: Shows current state (Ready, Playing, Generating, etc.)
- **Device Selector**: Choose audio output device with WASAPI support
  - Lists all available audio devices
  - 🎧 icon indicates WASAPI-capable devices
  - Automatically routes audio to selected device
  - Attempts WASAPI Exclusive mode for low-latency playback
- **Sample Rate Selector**: Choose audio quality (44.1 kHz - 192 kHz)
  - 44.1 kHz (CD Quality) - Default, recommended for most users
  - 48 kHz (Professional) - Industry standard for video
  - 88.2 kHz (Hi-Res) - High-resolution audio
  - 96 kHz (Studio) - Studio mastering quality
  - 192 kHz (Ultra Hi-Res) - Maximum quality (large files)
- **Metadata Display**: Shows audio format (32-bit float)

#### Mode Selection
- Four mode buttons with icons:
  - Isochronic (pulsed tones - speakers OK)
  - Binaural (stereo differential - headphones required)
  - Monaural (single-ear tones)
  - Bilateral (both ears independently)

#### Waveform Visualizer
- Animated dual-wave display
- Grid overlay for visual reference
- Phase-shifted waves representing L/R channels

#### Parameter Controls
**Left Column:**
- Carrier Frequency: 60-125 Hz (default 100 Hz)
- Beat Frequency: 0.5-15 Hz (default 8 Hz)

**Right Column:**
- Duration: 60-3600 seconds (default 300s / 5 min)
- Volume: 0-100% (default 25%)

Each control has:
- Label
- Spinbox for precise entry
- Slider for quick adjustment
- Bidirectional sync between spinbox and slider

#### Preset Buttons
- **Deep Sleep**: 2 Hz Delta (30 min)
- **Meditation**: 5 Hz Theta (20 min)
- **Calm Focus**: 8 Hz Alpha (15 min)
- **Cognitive**: 10 Hz Alpha (15 min)
- **Flow**: 13 Hz Beta (20 min)

#### Transport Controls
- **⟲** Loop (placeholder)
- **◀** Previous preset (placeholder)
- **▶** Play/Pause (fully functional)
- **■** Stop (fully functional)
- **💾** Export session (fully functional)
- Progress slider (placeholder for future timeline scrubbing)
- Time display showing current / total time

#### Footer
- DC offset indicator
- Headroom meter
- **Safe Mode checkbox**: Enforces frequency safety limits

## Running the GUI

```bash
# Make sure you're in the project directory with venv activated
cd E:\PythonProjects\PhiWave
.venv\Scripts\activate

# Launch the integrated GUI
python phiwave_integrated_gui.py
```

## Usage Instructions

### Basic Workflow
1. **Select Audio Device**: Choose your preferred output device from the dropdown
   - WASAPI devices (marked with 🎧) provide exclusive mode for best quality
   - "Default Output (System)" uses your system's default device
2. **Select Sample Rate** (optional): Choose audio quality
   - 44.1 kHz is recommended for most users (good quality, smaller files)
   - Higher rates (96 kHz, 192 kHz) for archival/audiophile use
3. **Select Mode**: Click one of the mode buttons (Isochronic recommended for first use)
4. **Adjust Parameters**: Use sliders or spinboxes to set:
   - Carrier frequency (base tone)
   - Beat frequency (entrainment rate)
   - Duration (session length)
   - Volume (start low!)
5. **Play**: Click ▶ button to generate and play audio
   - Audio generates at selected sample rate
   - Audio automatically routes to your selected device
   - WASAPI exclusive mode attempted for low-latency playback
6. **Export** (optional): Click 💾 to save the session to a file
   - Files saved with correct sample rate metadata

### Using Presets
- Click any preset button to instantly load recommended settings
- Status chip will show "Loaded: [Preset Name]"
- Adjust parameters further if desired
- Click Play to start

### Safety Features
- **Safe Mode** (enabled by default):
  - Enforces MAX_BEAT_HZ (15 Hz) limit
  - Enforces MAX_CARRIER_HZ (125 Hz) limit
  - Shows warning dialog if limits exceeded
- **Fade-in/out**: Automatically applied to prevent audio clicks
- **Volume Control**: Starts at conservative 25% by default

### Binaural Mode Warning
When selecting Binaural mode:
- Status changes to "Headphones Required"
- Binaural beats only work with stereo headphones
- Left and right channels have different frequencies
- Brain perceives the difference as the "beat"

## Architecture

### Key Classes

**PhiWaveGUI (QMainWindow)**
- Main application window
- Manages all UI state and audio parameters
- Handles user interactions and preset loading

**WaveformVisualizer (QWidget)**
- Custom painted widget for waveform display
- 60 FPS animation via QTimer
- Draws dual sine waves with phase offset

**GlassCard (QFrame)**
- Reusable glassmorphic container
- Styled with semi-transparent background
- Rounded corners and subtle borders

**ModeButton (QPushButton)**
- Custom button with SVG icon support
- Auto-loads icons from `assets/ui/skin/`
- Checkable for selection state

**AudioThread (QThread)**
- Background thread for non-blocking playback
- Emits signals on completion or error
- Prevents UI freezing during long sessions

### Audio Integration

The GUI connects to PhiWave's modular engine:

```python
from phiwave.audio.engine import (
    generate_binaural_segment,
    generate_isochronic_segment,
)
from phiwave.io.playback import play_buffer, stop_playback
from phiwave.io.export import write_wav, write_flac
from phiwave.config import SAMPLE_RATE, DEFAULT_VOLUME, etc.
```

**Audio Generation Flow:**
1. User clicks Play
2. Safety checks (if enabled)
3. Call `generate_binaural_segment()` or `generate_isochronic_segment()`
4. Create AudioThread with buffer
5. Start playback in background
6. Update UI status
7. Wait for completion signal

**Export Flow:**
1. User clicks Export (💾)
2. Open file dialog (WAV/FLAC)
3. Call `write_wav()` or `write_flac()`
4. Show success message

## SVG Asset Integration

Mode buttons automatically load SVG icons:

```python
svg_path = self.assets_dir / "isochronic_icon.svg"
btn = ModeButton("Isochronic", svg_path)
```

**Expected Asset Locations:**
- `assets/ui/skin/isochronic_icon.svg`
- `assets/ui/skin/binaural_icon.svg`
- `assets/ui/skin/monaural.svg`
- `assets/ui/skin/bilateral_icon.svg`

Icons are:
- Rendered at 20x20 pixels
- Displayed to the left of mode text
- Gracefully degrade if files missing

## Customization

### Adding New Presets

Edit the `self.presets` dictionary in `__init__`:

```python
self.presets = {
    "My Custom": {
        "carrier": 110,
        "beat": 7.83,  # Schumann resonance
        "duration": 600
    },
    # ... existing presets
}
```

Then rebuild the preset buttons in `_build_presets()`.

### Changing Theme Colors

Edit the stylesheet in `apply_styles()`:

```python
# Brand color
#brand { color: #YOUR_COLOR; }

# Accent gradient
QSlider::sub-page:horizontal {
    background: qlineargradient(...);
}
```

### Adding More Modes

1. Add mode to `mode_configs` in `_build_modes()`
2. Create corresponding SVG icon
3. Implement audio generation in `_start_playback()`

## Known Limitations

### Not Yet Implemented
- **Loop functionality**: ⟲ button is placeholder
- **Previous/Next preset**: ◀ ▶▶ buttons are placeholders
- **Progress timeline**: Slider doesn't track playback position
- **Real-time parameter modulation**: Can't change parameters during playback
- **Monaural/Bilateral modes**: Currently fall back to isochronic

### Future Enhancements
- Live FFT spectrum analyzer
- Session save/load with JSON metadata
- Playlist support for sequential sessions
- Real-time volume/frequency ramping
- Noise mixing controls (white/pink/brown)
- EEG-style brainwave visualization
- MIDI controller support
- Plugin architecture for custom generators

## Troubleshooting

### "Audio modules not available"
- Ensure PhiWave packages are installed
- Check virtual environment is activated
- Verify `phiwave/` package structure exists

### GUI launches but no audio plays
- Check system audio device is working
- Try selecting different device from dropdown
- Verify volume isn't muted in OS

### Playback is choppy
- Reduce duration for testing
- Close other audio applications
- Check CPU usage during generation

### SVG icons don't appear
- Verify `assets/ui/skin/` directory exists
- Check file names match exactly (case-sensitive)
- PyQt6 SVG support requires `PyQt6.QtSvg` module

## Development Notes

### Testing Checklist
- [x] GUI launches without errors
- [x] Mode selection works
- [x] Sliders update spinboxes bidirectionally
- [x] Presets load parameters correctly
- [x] Play button generates audio
- [x] Stop button terminates playback
- [x] Export creates valid WAV/FLAC files
- [x] Safe Mode enforces limits
- [ ] All 4 modes generate unique audio
- [ ] Progress bar tracks playback
- [ ] Loop functionality works

### Code Quality
- Type hints on method signatures
- Docstrings on all classes and key methods
- Error handling with try/except
- Thread safety for audio playback
- Graceful degradation if assets missing

### Performance
- Waveform runs at 60 FPS (16ms timer)
- Audio generation is non-blocking
- UI remains responsive during playback
- No memory leaks on repeated play/stop

## Credits

**Design**: Based on `layout_mockup.py` wireframe
**Audio Engine**: PhiWave modular architecture (binaural_presets.py)
**Framework**: PyQt6
**Icons**: PhiWave Modern Assets collection
**Theme**: Glassmorphic dark with golden accents

---

For questions or issues, refer to:
- `CLAUDE.md` - Project overview
- `DESIGN.md` - Architecture roadmap
- `GUI_CONCEPT.md` - Original UI mockups