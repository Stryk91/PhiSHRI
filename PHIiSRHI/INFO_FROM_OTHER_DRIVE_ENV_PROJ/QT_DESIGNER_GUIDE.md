# Qt Designer Workflow Guide

## Overview

PhiWave now has a **visual GUI design workflow**:
- **You design**: Edit `phiwave_qt.ui` in Qt Designer (drag-and-drop interface)
- **I code**: All logic lives in `phiwave_gui_qt.py` (connects UI to audio engine)

## Files

- `phiwave_qt.ui` - UI layout (XML format, edit with Qt Designer)
- `phiwave_gui_qt.py` - Python code that loads .ui and handles logic
- `QT_DESIGNER_GUIDE.md` - This guide

## Quick Start

### 1. Install Qt Designer

**Option A: Standalone Qt Design Studio (Recommended)**
- Download from: https://www.qt.io/download-qt-installer-oss
- Install "Qt Design Studio" or full Qt SDK
- Designer will be at: `C:\Qt\Tools\QtDesigner\designer.exe`

**Option B: Via MSYS2 (Already Installed)**
```bash
# In MSYS2 UCRT64 terminal
pacman -S mingw-w64-ucrt-x86_64-qt6-tools

# Launch designer
/ucrt64/bin/designer.exe
```

### 2. Edit UI in Designer

1. Open Qt Designer
2. File → Open → `E:\PythonProjects\PhiWave\phiwave_qt.ui`
3. Drag widgets from left panel to canvas
4. Edit properties in right panel
5. File → Save
6. Close Designer

### 3. Run GUI

```bash
.venv/Scripts/python.exe phiwave_gui_qt.py
```

The Python script auto-loads your UI changes!

## Current UI Structure

```
PhiWaveWindow (QMainWindow)
├── Title Label (QLabel)
├── Mode Selection (QGroupBox)
│   ├── Binaural Radio (QRadioButton)
│   └── Isochronic Radio (QRadioButton)
├── Preset Dropdown (QComboBox)
├── Parameters Panel (QGroupBox)
│   ├── Carrier Slider (QSlider) - 60-125 Hz
│   ├── Beat Slider (QSlider) - 0.5-15 Hz
│   ├── Duration Slider (QSlider) - 1-60 min
│   └── Volume Slider (QSlider) - 0-100%
├── Progress Bar (QProgressBar)
└── Button Row (QHBoxLayout)
    ├── Play Button (QPushButton)
    ├── Stop Button (QPushButton)
    └── Export Button (QPushButton)
```

## Widget Object Names (Important!)

**DO NOT change these object names** in Qt Designer - the Python code references them:

- `carrierSlider` → Carrier frequency control
- `beatSlider` → Beat frequency control
- `durationSlider` → Duration control
- `volumeSlider` → Volume control
- `carrierValueLabel` → Displays carrier value
- `beatValueLabel` → Displays beat value
- `durationValueLabel` → Displays duration
- `volumeValueLabel` → Displays volume
- `playButton` → Start playback
- `stopButton` → Stop playback
- `exportButton` → Export to WAV/FLAC
- `progressBar` → Shows playback progress
- `presetCombo` → Preset selection
- `binauralRadio` → Binaural mode
- `isochronicRadio` → Isochronic mode

## Adding New Widgets

### Example: Add a Noise Mix Slider

**In Qt Designer:**
1. Drag `QSlider` (Horizontal) onto canvas
2. Set Object Name: `noiseMixSlider`
3. Set min: 0, max: 100, value: 0
4. Drag `QLabel` for display value
5. Set Object Name: `noiseMixValueLabel`
6. Save .ui file

**In phiwave_gui_qt.py:**
```python
# In _connect_signals():
self.noiseMixSlider.valueChanged.connect(self._on_noise_mix_changed)

# Add handler:
def _on_noise_mix_changed(self, value):
    self.noiseMixValueLabel.setText(f"{value}%")
    self.presetCombo.setCurrentIndex(0)  # Switch to Custom

# In _update_displays():
noise_mix = self.noiseMixSlider.value()
self.noiseMixValueLabel.setText(f"{noise_mix}%")

# In _on_play_clicked():
noise_mix = self.noiseMixSlider.value()
# Pass noise_mix to generate_binaural_segment(...)
```

## Styling

**Golden Ratio Spacing** (already applied in .ui):
- Margins: 21px
- Spacing: 13px, 8px (Fibonacci numbers)
- Button size: 148×44px (golden ratio)
- Slider thumb: 21px diameter
- Slider track: 13px height

**Colors** (defined in .ui styleSheet):
- Background: `#0A0A0A` (near-black)
- Foreground: `#C9A961` (golden)
- Accent: `#FFB300` (bright gold)
- Hover: `#FFA000` (pressed gold)
- Track: `#1A1A1A` (dark gray)

**Frequency Colors** (dynamic, handled in Python):
- Delta (<4 Hz): `#9C27B0` (purple)
- Theta (4-8 Hz): `#673AB7` (deep purple)
- Alpha (8-13 Hz): `#FFB300` (golden)
- Beta (13-30 Hz): `#FF5722` (orange-red)
- Gamma (>30 Hz): `#F44336` (red)

## Customization Examples

### Change Window Size
In Qt Designer:
1. Click on `PhiWaveWindow` (top-level widget)
2. In Property Editor → geometry → width/height
3. Recommended: 800×600 (default), 1024×768, or 1280×720

### Add New Button
1. Drag `QPushButton` from Widget Box
2. Set Object Name: `myNewButton`
3. Set text: "My Action"
4. In Python, connect signal:
   ```python
   self.myNewButton.clicked.connect(self._on_my_action)
   ```

### Change Font
1. Select widget in Designer
2. Property Editor → font → Point Size
3. Or add to styleSheet: `font-size: 14pt;`

### Add Icon to Button
1. In Designer, set button text: `💾 Export` (use Unicode emoji)
2. Or in Python, load from Modern Assets:
   ```python
   from phiwave_guiutils.ui_assets import load_image
   icon_img = load_image("export", size=32)
   if icon_img:
       self.exportButton.setIcon(QIcon(QPixmap(icon_img)))
   ```

## Modern Assets Integration

The Modern Assets (premium SVG buttons) can be integrated as:

### Option 1: Set Button Background (CSS)
```python
self.playButton.setStyleSheet(f"""
    QPushButton {{
        background-image: url('assets/Modern Assets/play_button_default.png');
        background-repeat: no-repeat;
        background-position: center;
        border: none;
    }}
    QPushButton:hover {{
        background-image: url('assets/Modern Assets/play_button_hover.png');
    }}
""")
```

### Option 2: Use QLabel with Hover States
(Current Tkinter approach - can be adapted to Qt with event filters)

## Testing Workflow

1. Edit .ui in Designer
2. Save
3. Run: `.venv/Scripts/python.exe phiwave_gui_qt.py`
4. Test UI changes
5. Repeat

**No need to restart Designer** - just save and re-run Python script.

## Debugging

### UI Won't Load
- Check `phiwave_qt.ui` is in same directory as `phiwave_gui_qt.py`
- Verify object names match between .ui and .py
- Run: `.venv/Scripts/python.exe phiwave_gui_qt.py` and check error output

### Widget Not Responding
- Verify signal is connected in `_connect_signals()`
- Check object name in Designer matches Python code
- Add print statement to handler to test:
  ```python
  def _on_my_widget_changed(self, value):
      print(f"Widget changed: {value}")  # Debug output
      ...
  ```

### Styling Not Applied
- Check styleSheet property in Designer
- Qt uses CSS-like syntax but with Qt-specific properties
- Use Qt documentation: https://doc.qt.io/qt-6/stylesheet-reference.html

## Next Steps

**Phase 3 Enhancements** (Ready to implement):
- [ ] Status LED indicator (green/red/yellow)
- [ ] Noise mix slider + combo (white/pink/brown)
- [ ] Session save/load buttons
- [ ] Preset editor dialog
- [ ] Frequency ramp scheduler
- [ ] Modern Assets button integration
- [ ] Wave animation background (custom widget)

## Resources

- **Qt Designer Manual**: https://doc.qt.io/qt-6/qtdesigner-manual.html
- **Qt Widgets**: https://doc.qt.io/qt-6/qtwidgets-index.html
- **Qt Stylesheets**: https://doc.qt.io/qt-6/stylesheet-reference.html
- **PyQt6 Docs**: https://www.riverbankcomputing.com/static/Docs/PyQt6/

## Troubleshooting

### "No module named 'PyQt6.uic'"
Already installed with PyQt6, but if missing:
```bash
.venv/Scripts/python.exe -m pip install PyQt6
```

### "Could not find Qt Designer"
Download from qt.io or install via MSYS2 (see Quick Start above).

### "Audio modules not available"
The Python code gracefully handles missing audio modules. To fix:
```bash
.venv/Scripts/python.exe -m pip install numpy scipy sounddevice soundfile
```

---

**You're now set up for visual GUI design!** Edit `phiwave_qt.ui` in Designer, and I'll handle the Python logic. 🎨
