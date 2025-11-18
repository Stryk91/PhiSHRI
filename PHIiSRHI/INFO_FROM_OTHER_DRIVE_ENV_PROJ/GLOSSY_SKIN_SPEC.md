# PhiWave Glossy Chrome + Neon UI Skin

**Project Brief:** Implement glossy "chrome + neon" GUI skin and icons for PhiWave

**Status:** Asset generation scripts ready | PyQt6 integration pending

---

## Quick Start

### 1. Generate Assets (PowerShell)

Run from: `E:\PythonProjects\PhiWave`

```powershell
# Core icons (play, pause, stop, export, settings, info, device)
.\write_gloss_icons.ps1

# Additional icons (volume, mute, load, save, ramp, layer, noise, phi, fibonacci, schumann, export-all)
.\write_gloss_icons_more.ps1

# Skin assets (9-slice frame, panel backgrounds, separators)
.\write_gloss_skin.ps1
```

**Output Structure:**
```
assets/ui/icons/gloss/
├── play.svg, pause.svg, stop.svg
├── export.svg, export-all.svg, settings.svg, info.svg, device.svg
├── volume.svg, mute.svg
├── load.svg, save.svg
├── ramp.svg, layer.svg, noise.svg
├── phi.svg, fibonacci.svg, schumann.svg
└── [18+ total icons, all with chrome + neon glow]

assets/ui/skin/gloss/
├── frame_9.svg (14px margin for 9-slice stretching)
├── panel_bg.svg (tiled panel background)
├── separator_h.svg (6px horizontal divider)
└── separator_v.svg (6px vertical divider)
```

---

## 2. Integration (PyQt6 Preferred)

### Option A: PyQt6 (Recommended)

**Create a new demo app:**

```bash
pip install PyQt6
python demo_app.py
```

**QSS Theme File** (`gui/theme.qss`):

```qss
/* PhiWave Glossy Theme */

QMainWindow {
    background-color: #0F0F0F;
    border-image: url(assets/ui/skin/gloss/frame_9.svg) 14 14 14 14 stretch stretch;
    margin: 14px;
    border-radius: 4px;
}

QWidget {
    background-color: #0F0F0F;
    color: #E8E8E8;
}

QFrame#panel {
    background-image: url(assets/ui/skin/gloss/panel_bg.svg);
    border: 1px solid #6bd5ff;
    border-radius: 2px;
}

QFrame#separator_h {
    background-image: url(assets/ui/skin/gloss/separator_h.svg);
    min-height: 6px;
    max-height: 6px;
}

QFrame#separator_v {
    background-image: url(assets/ui/skin/gloss/separator_v.svg);
    min-width: 6px;
    max-width: 6px;
}

QPushButton {
    background-color: #222222;
    color: #E8E8E8;
    border: 2px solid #6bd5ff;
    border-radius: 4px;
    padding: 6px;
    qproperty-icon: url(assets/ui/icons/gloss/play.svg);
    qproperty-iconSize: 24px 24px;
}

QPushButton:hover {
    background-color: #333333;
    border: 2px solid #00ffff;
}

QPushButton:pressed {
    background-color: #111111;
    border: 2px solid #6bd5ff;
}

QToolBar {
    background-image: url(assets/ui/skin/gloss/panel_bg.svg);
    border-bottom: 1px solid #6bd5ff;
    spacing: 8px;
    padding: 6px;
}

QLabel {
    color: #E8E8E8;
}

QSlider::groove:horizontal {
    background-color: #1a1a1a;
    height: 4px;
    border-radius: 2px;
    border: 1px solid #6bd5ff;
}

QSlider::handle:horizontal {
    background-color: #555555;
    border: 1px solid #6bd5ff;
    width: 12px;
    margin: -4px 0;
    border-radius: 6px;
}

QSlider::handle:horizontal:hover {
    background-color: #00ffff;
}
```

**Demo App** (`demo_app.py`):

```python
import sys
from pathlib import Path
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout,
    QHBoxLayout, QPushButton, QToolBar, QFrame
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QIcon
from PyQt6.QtSvg import QSvgRenderer
from PyQt6.QtGui import QPixmap, QPainter

class PhiWaveGlossyDemo(QMainWindow):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("PhiWave Glossy Chrome+Neon Theme")
        self.setGeometry(100, 100, 1024, 768)

        # Load stylesheet
        stylesheet_path = Path("gui/theme.qss")
        if stylesheet_path.exists():
            with open(stylesheet_path) as f:
                self.setStyleSheet(f.read())

        # Central widget
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)

        # Toolbar with icons
        toolbar = self.addToolBar("Main")
        toolbar.setObjectName("MainToolbar")

        icon_dir = Path("assets/ui/icons/gloss")
        for icon_name in ["play.svg", "pause.svg", "stop.svg", "export.svg"]:
            icon_path = icon_dir / icon_name
            if icon_path.exists():
                # Create pixmap from SVG
                renderer = QSvgRenderer(str(icon_path))
                pixmap = QPixmap(24, 24)
                pixmap.fill(Qt.GlobalColor.transparent)
                painter = QPainter(pixmap)
                renderer.render(painter)
                painter.end()

                btn = QPushButton(icon_name.replace(".svg", ""))
                btn.setIcon(QIcon(pixmap))
                btn.setIconSize(24, 24))
                toolbar.addWidget(btn)

        # Two content panels with separator
        container = QWidget()
        h_layout = QHBoxLayout(container)

        # Left panel
        left_panel = QFrame()
        left_panel.setObjectName("panel")
        left_panel.setMinimumWidth(300)
        h_layout.addWidget(left_panel)

        # Vertical separator
        sep_v = QFrame()
        sep_v.setObjectName("separator_v")
        h_layout.addWidget(sep_v)

        # Right panel
        right_panel = QFrame()
        right_panel.setObjectName("panel")
        h_layout.addWidget(right_panel)

        layout.addWidget(container)
        self.show()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    demo = PhiWaveGlossyDemo()
    sys.exit(app.exec())
```

**Run Demo:**
```bash
cd E:\PythonProjects\PhiWave
python demo_app.py
```

---

### Option B: Tkinter + PNG Rasterization

If PyQt6 is unavailable, rasterize SVGs to PNG first:

```bash
pip install cairosvg pillow

python << 'EOF'
from pathlib import Path
from cairosvg import svg2png

svg_dir = Path("assets/ui/icons/gloss")
png_dir = Path("assets/ui/icons/gloss_png")
png_dir.mkdir(exist_ok=True)

for svg_file in svg_dir.glob("*.svg"):
    png_file = png_dir / svg_file.with_suffix(".png").name
    svg2png(url=str(svg_file), write_to=str(png_file), output_width=24, output_height=24)
    print(f"✓ {svg_file.name} → {png_file.name}")
EOF
```

Then use PNG files in Tkinter buttons:
```python
from PIL import Image
import tkinter as tk

img = Image.open("assets/ui/icons/gloss_png/play.png")
photo = ImageTk.PhotoImage(img)
btn = tk.Button(window, image=photo, command=on_play)
btn.image = photo  # Keep reference
btn.pack()
```

---

## 3. Design Specifications

### Colors
- **Chrome Base:** #CCCCCC → #999999 → #555555 → #333333 → #111111 (gradient)
- **Neon Glow:** #6bd5ff (cyan) with optional #00ffff (bright cyan) for highlights
- **Background:** #0F0F0F, #1A1A1A, #222222 (dark palette)
- **Text:** #E8E8E8 (light gray)

### Dimensions
- **Icons:** 24x24px (scalable SVG)
- **Frame Margins:** 14px (for 9-slice)
- **Separators:** 6px (h/v)
- **Panel Corners:** 2-4px border-radius

### Effects
- **Gradient:** Linear chrome effect (top-left to bottom-right)
- **Glow Filter:** Gaussian blur (stdDeviation=2) with reduced opacity (0.3-0.6)
- **Noise/Texture:** Subtle fractal noise on panels (optional)

---

## 4. Acceptance Criteria

- ✅ Icons render crisp at 1.0x and 1.5–2.0x scaling (SVG scalability)
- ✅ 9-slice frame stretches cleanly without visible seams
- ✅ Separators align pixel-perfect
- ✅ Toolbar buttons display glossy icons with proper hover/pressed states
- ✅ No external network/fonts required (all local SVGs)
- ✅ Accent glow is #6bd5ff throughout

---

## 5. Next Steps

1. **Generate Assets:**
   ```powershell
   .\write_gloss_icons.ps1
   .\write_gloss_icons_more.ps1
   .\write_gloss_skin.ps1
   ```

2. **Create Demo App:**
   - Copy `demo_app.py` code above
   - Install PyQt6: `pip install PyQt6`
   - Create `gui/theme.qss` with QSS code above
   - Run: `python demo_app.py`

3. **Verify Rendering:**
   - Test at 1.0x, 1.5x, 2.0x zoom levels
   - Check button hover/pressed states
   - Verify no seams in 9-slice frame

4. **Integrate into phiwave_gui:**
   - Apply glossy theme to modular GUI modules
   - Update button/control styling
   - Add icon references

---

## 6. File Locations

```
E:\PythonProjects\PhiWave/
├── write_gloss_icons.ps1          # Core icons generator
├── write_gloss_icons_more.ps1     # Additional icons generator
├── write_gloss_skin.ps1           # Skin assets generator
├── demo_app.py                    # PyQt6 demo application
├── gui/
│   └── theme.qss                  # PyQt6 stylesheet
├── assets/
│   └── ui/
│       ├── icons/
│       │   ├── gloss/             # Glossy icon SVGs (24 total)
│       │   └── gloss_png/         # PNG rasterized (optional)
│       └── skin/
│           └── gloss/             # Frame, panels, separators
└── README_skin.md                 # User documentation
```

---

## Notes

- **Accent Glow:** #6bd5ff is used throughout. To theme for magenta (#FF00FF) or lime (#00FF00), update stop-color in SVG gradients.
- **Asset Paths:** Keep exactly as defined so future code can reference consistently.
- **Performance:** SVGs scale cleanly without rasterization; use PNG fallback only for Tkinter.

---

**Status:** Ready to execute. Generate assets with PowerShell scripts, test with PyQt6 demo, then integrate into phiwave_gui package.
