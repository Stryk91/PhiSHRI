# E: Drive Structure Map

Generated: 2025-10-24

## Overview

Your E: drive contains development tools and Python projects totaling ~7.5 GB.

```
E:/
├── Pycharm/                          (3.5 GB) - PyCharm IDE installation
│   └── PyCharm 2025.2.3/
├── Python/                           (2.5 GB) - System Python installation
│   ├── Lib/                          - Standard library
│   ├── DLLs/
│   ├── Scripts/
│   └── binaural_beats.py             - Old binaural beats script
├── PythonProjects/                   (960 MB) - Main development directory
├── pycharm-2025.2.3.exe              (984 MB) - PyCharm installer
├── GROKOL/                           (25 MB)  - Grokol project files
├── Mindstateclone/                   (32 KB)  - Old Obsidian vault
├── avast! sandbox/                   (7.6 MB) - Antivirus sandbox
├── School/                           (7.6 MB) - School projects
├── MapData/                          (4 KB)
├── $RECYCLE.BIN/                     (29 MB)
└── System Volume Information/        (28 KB)
```

---

## PythonProjects Directory (PRIMARY)

### Main Structure
```
PythonProjects/
├── PhiWave/                          ⭐ ACTIVE PROJECT
│   ├── binaural_presets.py           - Main entry point (~500 lines)
│   ├── export.py                     - WAV/FLAC export functions
│   ├── noise.py                      - White/Pink/Brown noise generators
│   ├── binaural_basic.py             - Older simple binaural implementation
│   ├── requirements.txt               - numpy, scipy, sounddevice, soundfile
│   ├── presets.json                  - Preset storage (partial)
│   ├── CLAUDE.md                     - Claude Code guidance ✅ (just created)
│   ├── README.md                     - Quick start guide
│   ├── DESIGN.md                     - Architecture & refactoring roadmap
│   ├── GUI_CONCEPT.md                - Tkinter GUI mockups
│   ├── Visual Design.md              - Color schemes & branding
│   ├── evaluation.md.md              - Evaluation notes
│   ├── audio/
│   │   └── noise.py                  - Shim re-exporting top-level noise.py
│   ├── phiwave/                      - Planned modular structure
│   │   ├── audio/
│   │   │   ├── __init__.py
│   │   │   └── engine.py             - Core signal generation
│   │   ├── config.py
│   │   └── presets/
│   │       ├── defaults.json
│   │       └── loader.py
│   ├── phiwave_gui.py                - GUI implementation (staged)
│   ├── docs/
│   │   ├── presets.md                - Preset reference
│   │   ├── protocols.md              - Frequency protocols & research
│   │   ├── research.md               - Scientific background
│   │   ├── authoring.md              - Custom preset creation guide
│   │   └── hello.txt
│   ├── 2_Specs/                      - Specification documents
│   │   ├── presets.json.md
│   │   ├── session_examples.json.md
│   │   ├── session_packs.json
│   │   └── session_packs.json.md
│   ├── .git/                         - Git repository
│   ├── .venv/                        - Virtual environment (excluded from git)
│   ├── .obsidian/                    - Obsidian vault config
│   ├── __pycache__/
│   ├── phiwave_complete.tar
│   └── phiwave_complete.tar.gz
│
├── MindstateClone/                   ⚠️ OLD (Locked, being replaced by PhiWave)
│   └── .obsidian/
│
├── HFLLLM/                           - Separate project
│   └── miniphy.py                    - Mini Python learning project
│
├── KeyboardGIF/                      - Separate project
│   └── create_stryker_gif.py         - GIF creation tool
│
├── binaural_beats.py                 - Root-level test script
├── BUILDING_INSTRUCTIONS.md
├── FEATURES_OVERVIEW.txt
├── INSTALLATION_GUIDE.md
├── QUICK_START.txt
├── README.md
└── requirements.txt
```

---

## PhiWave Project Details

### What is it?
Audio synthesis tool generating **binaural beats** and **isochronic tones** using Fibonacci numbers and golden ratio.

**Key features:**
- Binaural mode: stereo L/R frequency differential (requires headphones)
- Isochronic mode: carrier pulsed with smooth amplitude envelope
- Presets: Fibonacci (1, 2, 3, 5, 8, 13 Hz), Golden Ratio, Schumann (7.83 Hz)
- Safety: fade-in/out, volume control, frequency constraints

### Key Files

| File | Purpose | Status |
|------|---------|--------|
| `binaural_presets.py` | Main entry point, audio engines, CLI menu | ✅ Active |
| `noise.py` | White/Pink/Brown noise generators | ✅ Active |
| `export.py` | WAV/FLAC file export | ✅ Active |
| `CLAUDE.md` | Claude Code guidance (this session) | ✅ New |
| `DESIGN.md` | Refactoring roadmap (4 phases) | 📋 Reference |
| `phiwave/` | Planned modular structure | 🔄 In progress |
| `phiwave_gui.py` | GUI implementation | ⏳ Staged |

### Git Remote
```
Repository: https://github.com/Stryk91/Phiwave.git
Branch: master
Status: Up to date with origin
```

### Virtual Environment
```
Location: /e/PythonProjects/PhiWave/.venv
Python: System install at E:\Python\python.exe
Manager: pip
Dependencies:
  - numpy       (numerical arrays)
  - scipy       (signal processing)
  - sounddevice (audio playback)
  - soundfile   (WAV/FLAC export)
```

### How to Run
```bash
# Install dependencies
pip install numpy scipy sounddevice soundfile

# Run interactive menu
python binaural_presets.py

# Or import and use programmatically
from binaural_presets import play_binaural
play_binaural(base_freq=100.0, beat_freq=8.0, duration=300)
```

---

## Other Projects

### HFLLLM/miniphy.py
Small Python learning/utility script.

### KeyboardGIF/create_stryker_gif.py
GIF creation tool.

---

## System Tools

### Python Installation
- **Location:** `E:\Python\`
- **Version:** Recent (tools available in /Scripts)
- **Size:** 2.5 GB (includes full standard library)

### PyCharm IDE
- **Location:** `E:\Pycharm\PyCharm 2025.2.3\`
- **Version:** 2025.2.3
- **Size:** 3.5 GB (IDE + plugins)
- **Installer:** `pycharm-2025.2.3.exe` (984 MB, not yet run)

---

## Disk Usage Summary

| Item | Size |
|------|------|
| PyCharm IDE | 3.5 GB |
| Python system | 2.5 GB |
| PyCharm installer | 984 MB |
| PythonProjects | 960 MB |
| GROKOL | 25 MB |
| Avast sandbox | 7.6 MB |
| School projects | 7.6 MB |
| Recycle Bin | 29 MB |
| **Total** | **~7.5 GB** |

---

## Development Setup Notes

### For Web Claude
If web Claude needs to work on **PhiWave**, provide these URLs:
- **GitHub repo:** https://github.com/Stryk91/Phiwave.git
- **CLAUDE.md:** Available in repo (just pushed)
- **Key docs:** DESIGN.md, README.md, CLAUDE.md

### Local Development
- **IDE:** PyCharm (configured with project venv)
- **Python:** `E:\Python\python.exe`
- **Terminal:** Windows Terminal / PowerShell
- **Git:** Configured with origin remote

### Next Steps
1. Delete old `MindstateClone/` directory (currently locked)
2. Complete Phase 2 of DESIGN.md (modular refactoring)
3. Implement automated tests (see DESIGN.md section 4)
4. Build Tkinter GUI (Phase 3)

---

## Directory Timestamps

- **Last updated:** 2025-10-24 09:36 (PhiWave copy)
- **MindstateClone:** Locked (being deprecated)
- **Other projects:** Untouched

