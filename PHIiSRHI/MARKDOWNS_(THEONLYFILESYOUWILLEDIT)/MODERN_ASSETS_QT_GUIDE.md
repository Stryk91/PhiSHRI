# Using Modern Assets in Qt Designer

## Quick Start

The Modern Assets are now **automatically applied** when you run the GUI! The Python code loads them and applies them to the Play, Stop, and Export buttons.

Just run:
```bash
.venv/Scripts/python.exe phiwave_gui_qt.py
```

You'll see the premium button graphics with hover/pressed/disabled states! ✨

## Available Assets

Located in: `assets/Modern Assets/`

### Button States (148×44px PNG)
- **Play Button**: `play_button_{default,hover,pressed,disabled}.png`
- **Stop Button**: `stop_button_{default,hover,pressed,disabled}.png`
- **Export Button**: `export_button_{default,hover,pressed,disabled}.png`

All converted from SVG, ready to use!

## How It Works

The `phiwave_gui_qt.py` file automatically:
1. Loads the .ui file from Qt Designer
2. Finds the playButton, stopButton, exportButton widgets
3. Applies CSS stylesheets with background images for each state
4. Handles hover, pressed, and disabled states automatically

## Adding New Custom Buttons in Qt Designer

### Method 1: Let Python Apply Assets (Recommended)

1. **In Qt Designer**:
   - Drag `QPushButton` onto canvas
   - Set Object Name to: `playButton`, `stopButton`, or `exportButton`
   - Save .ui file

2. **Python automatically applies the graphics!**
   - No additional code needed if using standard names

### Method 2: Manual Image Button

1. **In Qt Designer**:
   - Drag `QPushButton` onto canvas
   - Right-click button → "Change styleSheet..."
   - Add this CSS:
   ```css
   QPushButton {
       border: none;
       background-image: url('assets/Modern Assets/play_button_default.png');
       background-repeat: no-repeat;
       background-position: center;
       min-width: 148px;
       min-height: 44px;
   }
   QPushButton:hover {
       background-image: url('assets/Modern Assets/play_button_hover.png');
   }
   QPushButton:pressed {
       background-image: url('assets/Modern Assets/play_button_pressed.png');
   }
   ```

3. **Clear button text** (Property Editor → text → empty)

### Method 3: Use as Icon

1. **In Qt Designer**:
   - Select button
   - Property Editor → icon → Choose File
   - Navigate to: `assets/Modern Assets/play_button_default.png`
   - Set iconSize: 148×44

**Note**: This method only shows one state (no hover/pressed effects)

## Adding Your Own Custom Graphics

### Step 1: Create Your Images

Create PNG files with these dimensions:
- **Buttons**: 148×44px (golden ratio proportion)
- **Icons**: 32×32px, 48×48px, or 64×64px
- **Backgrounds**: Any size (will tile or stretch)

### Step 2: Place in Assets Folder

```
assets/
  └── Modern Assets/
      ├── my_custom_button_default.png
      ├── my_custom_button_hover.png
      ├── my_custom_button_pressed.png
      └── my_custom_button_disabled.png
```

### Step 3A: Auto-Apply (Easiest)

Tell me the button name and I'll add it to `phiwave_gui_qt.py`:

```python
# I'll add this to _apply_modern_assets():
set_button_images(self.myCustomButton, "my_custom")
```

### Step 3B: Manual Apply in Designer

In styleSheet property:
```css
QPushButton {
    background-image: url('assets/Modern Assets/my_custom_button_default.png');
}
QPushButton:hover {
    background-image: url('assets/Modern Assets/my_custom_button_hover.png');
}
```

## Image Formats Supported

✅ **PNG** - Best for buttons with transparency
✅ **JPG** - Good for backgrounds
✅ **SVG** - Can be used but needs conversion to PNG first
❌ **GIF** - Limited support

## Tips & Tricks

### Transparent Backgrounds
- Use PNG with alpha channel
- Set button `border: none;` and `background: transparent;`

### Scaling Images
Qt will scale images to fit button size. To prevent distortion:
```css
background-size: contain;  /* Scale to fit, maintain aspect ratio */
background-size: cover;    /* Fill entire button */
background-size: 100% 100%; /* Stretch to exact size */
```

### Tiled Backgrounds
For panel backgrounds:
```css
QGroupBox {
    background-image: url('assets/texture.png');
    background-repeat: repeat;  /* Tile the image */
}
```

### Center Logo
For window branding:
```css
QMainWindow {
    background-image: url('assets/logo.png');
    background-repeat: no-repeat;
    background-position: center;
}
```

## Viewing Assets in Designer

**Resource Browser Method** (Advanced):
1. Create Qt Resource file (.qrc) - already created as `phiwave_resources.qrc`
2. In Designer: Resource Browser panel
3. Click "Edit Resources" → Add Resource File
4. Select `phiwave_resources.qrc`
5. Now you can select assets from Resource Browser

**Direct Path Method** (Simple):
- Just type the file path in styleSheet property
- Designer won't preview it, but it works when you run the Python script

## Testing Your Changes

1. Edit .ui in Designer (add/move widgets)
2. Save
3. Run: `.venv/Scripts/python.exe phiwave_gui_qt.py`
4. See changes instantly!

No need to restart Designer or recompile anything.

## Troubleshooting

### Images Not Showing
- Check file path (use forward slashes: `assets/Modern Assets/file.png`)
- Verify PNG files exist in correct location
- Make sure button has correct object name

### Images Stretched/Distorted
- Check image dimensions match button size
- Add `background-size: contain;` to styleSheet

### Hover Not Working
- Ensure `:hover` state is defined in styleSheet
- Check button is enabled (not disabled)

### Want Different Assets?
Just tell me:
- What images you want to add
- Where they're located
- What buttons they should apply to

I'll integrate them immediately! 🎨

---

**Your Modern Assets are ready to use!** Just run the Qt GUI and you'll see them in action. Add more buttons in Designer and tell me what graphics to apply.
