# E:\ DRIVE ENVIRONMENT MAP
## COMPREHENSIVE PYTHON & DEV TOOLS REFERENCE
**Generated:** 2025-11-05
**Purpose:** Eliminate context waste from path discovery

---

## 📍 PYTHON INSTALLATIONS

### System Python Installations
```
1. E:\Python\python.exe
   Version: Python 3.13.7
   Type: System Install (Latest)
   Packages: cryptography, pillow (BASIC ONLY)
   ❌ DO NOT USE for PhiGEN - Missing cairosvg, PyQt6, PySide6

2. E:\a111\system\python\python.exe
   Version: Python 3.10.6
   Type: System Install (Older)
   ❌ DO NOT USE - Outdated version

3. E:\Utilities\MINGSYS2\ucrt64\bin\python.exe
   Version: Python 3.12.11
   Type: MSYS2 System Python
   Packages: Minimal (no cairosvg, PyQt)
   ❌ DO NOT USE for PhiGEN
```

### Project Virtual Environments

```
✅ PhiGEN Project (PRIMARY)
   Python: E:\PythonProjects\PhiGEN\.venv\Scripts\python.exe
   Version: Python 3.13.7
   Pip: E:\PythonProjects\PhiGEN\.venv\Scripts\pip.exe
   Activate: E:\PythonProjects\PhiGEN\.venv\Scripts\activate

   📦 INSTALLED PACKAGES:
   ✓ CairoSVG 2.8.2          (SVG rendering)
   ✓ cryptography 46.0.3     (Encryption)
   ✓ pillow 11.3.0           (Image processing)
   ✓ PyQt6 6.10.0            (GUI framework)
   ✓ PyQt6-Qt6 6.10.0        (Qt bindings)
   ✓ PyQt6_sip 13.10.2       (Qt SIP module)
   ✓ PySide6 6.10.0          (Alternative Qt framework)
   ✓ PySide6_Addons 6.10.0   (Qt addons)
   ✓ PySide6_Essentials 6.10.0 (Qt essentials)

✅ PhiWave Project
   Python: E:\PythonProjects\PhiWave\.venv\Scripts\python.exe
   Version: Python 3.13.7
   Has: Agent Hub, MCP tools

✅ FONTBUILDER Project
   Python: E:\PythonProjects\FONTBUILDER\.venv\Scripts\python.exe
   Version: Python 3.13.7
   Has: Font analysis tools

✅ STRYKMCP Project
   Python: E:\PythonProjects\STRYKMCP\.venv\Scripts\python.exe
   Version: Python 3.13.7
   Has: MCP server tools
```

---

## 🎯 PHIGEN PROJECT - QUICK REFERENCE

### Correct Commands
```bash
# ✅ ALWAYS USE THESE FOR PHIGEN:
Python: E:\PythonProjects\PhiGEN\.venv\Scripts\python.exe
Pip: E:\PythonProjects\PhiGEN\.venv\Scripts\pip.exe

# From bash in PhiGEN directory:
python [script.py]  # Uses venv if activated
python -m pip install [package]

# SVG to PNG rendering (cairosvg):
python convert_svg.py [input.svg] [output.png] [scale]
```

### Critical Environment Setup
```bash
# For cairosvg to work, Cairo DLL must be in PATH:
export PATH="/e/Utilities/MINGSYS2/ucrt64/bin:$PATH"

# This is handled automatically in convert_svg.py helper script
```

### Project Structure
```
E:\PythonProjects\PhiGEN\
├── .venv\                      # Virtual environment
├── FONTS\                      # Font files
├── TEMPSVG\                    # Temporary SVG files
├── ui\                         # UI files
├── convert_svg.py              # SVG conversion helper (uses cairosvg)
├── password_vault_app.py       # Main app entry point
├── password_vault_backend.py   # Backend logic
├── preview_fonts.py            # Font preview tool
├── qt_config.py                # Qt configuration
└── setup_qt.py                 # Qt setup script
```

---

## 🔧 DEV TOOLS & UTILITIES

### Git
```
Location: /mingw64/bin/git (in PATH)
Also at: E:\a111\system\git\bin\git.exe
Version: 2.51.1.windows.1
✅ Available globally
```

### ImageMagick
```
Location: C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick
Version: ImageMagick 7.1.2-7 Q16-HDRI x64
Command: magick
✅ Available in PATH
⚠️ Use cairosvg for SVG rendering (better CSS support)
```

### FontForge
```
Location: E:\FONTFORGE\FontForgeBuilds\bin\fontforge.exe
✅ Available for font editing
```

### Cairo Libraries (CRITICAL for cairosvg)
```
Location: E:\Utilities\MINGSYS2\ucrt64\bin\
Files:
  - libcairo-2.dll
  - libcairo-gobject-2.dll
  - libcairo-script-interpreter-2.dll
  - libpangocairo-1.0-0.dll

⚠️ MUST be in PATH for cairosvg to work
```

### MSYS2 Environment
```
Location: E:\Utilities\MINGSYS2\
Bin directory: E:\Utilities\MINGSYS2\ucrt64\bin\
Contains: Cairo DLLs, Python 3.12.11, various GTK/Qt tools
Purpose: Provides Cairo libraries for cairosvg
```

### Other Tools
```
Nmap: E:\Utilities\nmap.exe
Zenmap: E:\Utilities\zenmap\
```

---

## 📁 PROJECT DIRECTORY MAP

```
E:\PythonProjects\
├── PhiGEN\              # Password vault & generator (MAIN PROJECT)
├── PhiWave\             # Agent hub & MCP tools
├── FONTBUILDER\         # Font analysis tools
├── STRYKMCP\            # MCP server
├── HFLLLM\              # (Unknown)
├── KeyboardGIF\         # (Unknown)
├── MindstateClone\      # (Unknown)
├── .obsidian\           # Obsidian notes
└── [Various utilities]

E:\FONTFORGE\            # FontForge installation
E:\Utilities\            # System utilities (MSYS2, nmap, etc.)
E:\Python\               # System Python 3.13.7
E:\a111\                 # Old system tools (Python 3.10.6, Git)
```

---

## 🚨 COMMON ISSUES & SOLUTIONS

### Issue: "Module 'cairosvg' not found"
```
❌ Problem: Using wrong Python interpreter
✅ Solution: Use PhiGEN venv Python:
   E:\PythonProjects\PhiGEN\.venv\Scripts\python.exe

✅ Or activate venv first:
   source E:/PythonProjects/PhiGEN/.venv/Scripts/activate
```

### Issue: "cairocffi cannot find libcairo-2.dll"
```
❌ Problem: Cairo DLL not in PATH
✅ Solution 1: Add MSYS2 to PATH:
   export PATH="/e/Utilities/MINGSYS2/ucrt64/bin:$PATH"

✅ Solution 2: Use convert_svg.py helper script
   (automatically sets PATH)
```

### Issue: "Wrong Python version"
```
❌ Problem: Using system Python instead of venv
✅ Solution: Always use full path or activate venv:
   /e/PythonProjects/PhiGEN/.venv/Scripts/python.exe
```

### Issue: "Package not found in pip list"
```
❌ Problem: Checking wrong Python's packages
✅ Solution: Use PhiGEN venv pip:
   E:\PythonProjects\PhiGEN\.venv\Scripts\pip.exe list

   Or with activated venv:
   pip list
```

### Issue: "ImageMagick CSS parsing errors with SVG"
```
❌ Problem: ImageMagick has poor CSS support
✅ Solution: ALWAYS use cairosvg instead:
   python convert_svg.py [input.svg] [output.png] [scale]
```

---

## 📋 PACKAGE INSTALLATION GUIDE

### Installing in PhiGEN venv
```bash
# Method 1: Activate venv first
source E:/PythonProjects/PhiGEN/.venv/Scripts/activate
pip install [package-name]

# Method 2: Direct pip path
E:/PythonProjects/PhiGEN/.venv/Scripts/pip.exe install [package-name]

# Method 3: Using python -m pip
E:/PythonProjects/PhiGEN/.venv/Scripts/python.exe -m pip install [package-name]
```

### Installing from requirements.txt
```bash
cd /e/PythonProjects/PhiGEN
source .venv/Scripts/activate
pip install -r requirements.txt
```

---

## 🎨 SVG RENDERING WORKFLOW

### Preferred Method: cairosvg
```bash
# Using helper script (recommended):
python convert_svg.py "input.svg" "output.png" 8  # 8x scale

# Direct cairosvg (requires PATH setup):
export PATH="/e/Utilities/MINGSYS2/ucrt64/bin:$PATH"
python -c "import cairosvg; cairosvg.svg2png(url='input.svg', write_to='output.png', scale=8)"
```

### Fallback Method: ImageMagick
```bash
# Only if cairosvg unavailable:
magick input.svg -density 768 output.png  # 8x density (96*8)

# Note: May produce CSS parsing warnings
```

---

## ✅ CRITICAL RULES

1. **ALWAYS use PhiGEN venv Python for PhiGEN work**
   - Path: `E:\PythonProjects\PhiGEN\.venv\Scripts\python.exe`

2. **ALWAYS use cairosvg for SVG rendering**
   - NOT ImageMagick (poor CSS support)

3. **ALWAYS check documented paths before assuming locations**
   - Don't rediscover what's already documented

4. **NEVER use system Python for PhiGEN**
   - Missing critical packages: cairosvg, PyQt6, PySide6

5. **NEVER install PhiGEN packages in system Python**
   - Use venv to keep project isolated

6. **ALWAYS export MSYS2 to PATH for cairosvg**
   - Or use convert_svg.py helper script

---

## 📝 MAINTENANCE NOTES

### Last Updated: 2025-11-05
### Verified Locations:
- [x] Python installations scanned
- [x] Package installations verified
- [x] Dev tools located
- [x] Project structures mapped
- [x] Common issues documented

### Future Updates:
- Add this file to any new workspace sessions
- Update when new packages installed
- Update when new projects added
- Update when tools relocated

---

## 🔗 QUICK LINKS

- PhiGEN Project Root: `E:\PythonProjects\PhiGEN\`
- PhiGEN Venv Python: `E:\PythonProjects\PhiGEN\.venv\Scripts\python.exe`
- Cairo DLLs: `E:\Utilities\MINGSYS2\ucrt64\bin\`
- System Python: `E:\Python\python.exe` (Don't use for PhiGEN)
- ImageMagick: `C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick`
- FontForge: `E:\FONTFORGE\FontForgeBuilds\bin\fontforge.exe`

---

**END OF ENVIRONMENT MAP**

✅ Save this file permanently
✅ Reference before any Python/tool operations
✅ Update when environment changes