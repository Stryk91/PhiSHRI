# PhiWave Project Index

**Last Updated:** 2025-10-30
**Purpose:** Quick navigation guide for agents working on PhiWave

---

## 🎯 Quick Reference

### Need to...
- **Generate audio?** → `phiwave/audio/engine.py`
- **Play audio?** → `phiwave/io/playback.py`
- **Export audio?** → `phiwave/io/export.py`
- **Load presets?** → `phiwave/presets/loader.py`
- **Custom presets?** → `phiwave/presets/custom_presets.py`
- **Validate audio?** → `phiwave/validation.py` + `validator.py`
- **GUI changes?** → `phiwave_gui/` (see GUI section below)
- **Agent communication?** → `mcp_agent_hub.py` or `agent_hub_mcp.py`
- **Run tests?** → `tests/` directory
- **Configuration?** → `phiwave/config.py` + `phiwave_gui/config.py`

---

## 📂 Core Audio System

### Audio Generation
- **`phiwave/audio/engine.py`** (PRIMARY)
  - `generate_binaural_segment()` - Binaural beat generation
  - `generate_isochronic_segment()` - Isochronic tone generation
  - `apply_fade()` - Fade in/out envelopes
  - Pure functions, no side effects

- **`phiwave/audio/engine_enhanced.py`**
  - Enhanced engine with crossfading
  - Loop seamless audio generation
  - Used for advanced features

- **`noise.py`** (top-level)
  - `white_noise()`, `pink_noise()`, `brown_noise()`
  - Background noise generation
  - Returns mono float32 arrays

- **`audio/noise.py`** (legacy shim)
  - Re-exports from top-level `noise.py`
  - Kept for backward compatibility

### Audio I/O
- **`phiwave/io/playback.py`** (PRIMARY)
  - `play_buffer()` - Main playback function (returns audio mode)
  - `try_wasapi_exclusive()` - WASAPI exclusive mode attempt
  - `get_current_audio_mode()` - Query current mode
  - `stop_playback()`, `wait_for_playback()` - Playback control
  - `list_output_devices()`, `set_output_device()` - Device management

- **`phiwave/io/export.py`**
  - `write_wav()` - Export to WAV (32-bit float)
  - `write_flac()` - Export to FLAC (16/24-bit)
  - Pure I/O, no side effects

- **`export.py`** (top-level, legacy)
  - Old export functions
  - Use `phiwave/io/export.py` instead

### Audio Quality
- **`phiwave/validation.py`** (PRIMARY)
  - `quick_validation()` - Fast FFT frequency check
  - `detailed_validation()` - Comprehensive test suite
  - `export_validation_report()` - Generate markdown reports
  - DC offset, clipping, RMS, phase alignment checks

- **`validator.py`** (CLI wrapper)
  - Command-line tool for validation
  - Usage: `python validator.py test.wav`
  - Uses functions from `phiwave/validation.py`

---

## 🎨 GUI System

### Main Application
- **`phiwave_gui.py`** (ENTRY POINT)
  - Run: `python phiwave_gui.py`
  - Imports and runs `PhiWaveGUI` from `phiwave_gui/app.py`

- **`phiwave_gui/app.py`** (PRIMARY)
  - `PhiWaveGUI` class - Main application window
  - Integrates all controls (sliders, buttons, dropdowns)
  - Handles play/stop logic
  - Threading for non-blocking playback
  - Captures audio mode from `play_buffer()`

### GUI Controls
- **`phiwave_gui/controls/sliders.py`**
  - `ParameterSliders` class
  - Carrier frequency, beat frequency, duration, volume
  - Real-time value updates

- **`phiwave_gui/controls/buttons.py`**
  - `PlaybackControls` class
  - Play/Stop buttons
  - Status label
  - **`audio_mode_label`** - Shows WASAPI mode
  - **`set_audio_mode()`** - Update audio mode indicator

- **`phiwave_gui/controls/dropdowns.py`**
  - `PresetSelector` class
  - Mode dropdown (Binaural/Isochronic)
  - Preset dropdown with built-in + custom presets
  - **"💾 Save Custom"** button
  - **"🗑 Delete"** button (custom presets only)
  - Custom presets marked with ⭐

### GUI Dialogs
- **`phiwave_gui/dialogs/export.py`**
  - `ExportDialog` - File export interface
  - WAV/FLAC format selection

- **`phiwave_gui/dialogs/canvas.py`**
  - Waveform visualization (future)

- **`phiwave_gui/dialogs/layout.py`**
  - Layout utilities

### GUI Configuration
- **`phiwave_gui/config.py`**
  - `COLORS` - Color scheme (dark theme)
  - `SPACING` - Layout spacing constants
  - `FONTS` - Font settings
  - Golden ratio design system

---

## 🎵 Preset System

### Preset Loading
- **`phiwave/presets/loader.py`** (PRIMARY)
  - `PresetLoader` class
  - Loads built-in presets from `defaults.json`
  - `list_presets()`, `get_preset()`, `get_ramp()`

- **`phiwave/presets/defaults.json`**
  - Built-in preset definitions
  - 18 presets, 2 ramps
  - Fibonacci, Golden Ratio, Schumann, etc.

### Custom Presets
- **`phiwave/presets/custom_presets.py`** (NEW - Task 2)
  - `CustomPresetManager` class
  - CRUD operations for user presets
  - Saves to `~/.phiwave/custom_presets.json`
  - Validation using `VALIDATION_RANGES`
  - Export/import individual presets

- **`~/.phiwave/custom_presets.json`** (user home)
  - User-created custom presets
  - Persists across sessions

### Legacy Presets
- **`binaural_presets.py`** (legacy)
  - Old monolithic preset system
  - Still functional for CLI use
  - GUI uses new preset system

- **`presets.json`** (top-level, legacy)
  - Old preset format
  - Being phased out

---

## 🤖 Agent System (MCP)

### MCP Server
- **`mcp_agent_hub.py`** (PRIMARY MCP SERVER)
  - FastMCP server exposing agent hub via MCP protocol
  - 8 MCP tools: post_message, get_messages, mark_processed, etc.
  - Entry point: `fastmcp.FastMCP("phiwave-agent-hub")`
  - Uses SQLite backend: `agent_hub.db`

- **`.mcp.json`**
  - MCP server configuration for Claude Code
  - Defines connection to `mcp_agent_hub.py`

### Direct Agent Access
- **`agent_hub_mcp.py`** (DIRECT ACCESS)
  - Drop-in replacement for agents without MCP
  - Direct SQLite access (no MCP overhead)
  - 100% API compatible with MCP tools
  - Use this for PyCharm/terminal agents

- **`agent_hub.py`** (legacy)
  - Old agent hub implementation
  - Being replaced by MCP system

### Agent Tools
- **`mcp_agent_client.py`**
  - Client library for agents to connect to hub
  - Example usage patterns

- **`send_agent_message.py`**
  - Quick utility to post messages
  - Usage: `python send_agent_message.py AGENT_NAME "message"`

### Agent Identity Files
- **`claude_agent.py`** - TERMC (Terminal Claude)
- **`analyzer_agent.py`** - analyzer (code quality)
- **`phiwave/agent_junie.py`** - Junie (GPT-5 assistant)
- **`phiwave/agent_messenger.py`** - Messaging utilities

### Agent Feed System
- **`phiwave/agent_feed.py`**
  - Agent activity logging
  - Append-only JSONL feed
  - Tracks all agent actions

---

## 🧪 Testing

### Test Files
- **`tests/test_audio_engine.py`**
  - Core audio generation tests
  - FFT frequency validation
  - Amplitude checks

- **`tests/test_validation_tool.py`**
  - Validation system tests
  - CLI tool tests

- **`test_custom_presets.py`**
  - Custom preset manager tests
  - Add, list, search, rename, delete

- **`test_gui_integration.py`**
  - GUI integration tests
  - Widget interaction tests

- **`test_loop_crossfade.py`**
  - Crossfade functionality tests
  - Task 1 verification

- **`test_mcp_full_suite.py`**
  - Comprehensive MCP system tests
  - Hub communication tests

- **`mcp_smoke_test.py`**
  - Quick MCP health check
  - Run after reloads

### QA Logs
- **`qa_log_phase4_gui_success.py`**
  - Phase 4 GUI completion QA report

---

## ⚙️ Configuration

### Application Config
- **`phiwave/config.py`** (PRIMARY)
  - `SAMPLE_RATE` = 44100
  - `VALIDATION_RANGES` - Parameter limits
  - `DEFAULT_FADE_TIME` = 0.5
  - Audio generation constants

- **`phiwave_gui/config.py`**
  - GUI-specific configuration
  - Colors, spacing, fonts
  - Dark theme settings

### Agent Config
- **`.claude/settings.local.json`**
  - Claude Code permissions
  - Auto-approve rules (brave mode)

- **`.ide_claude/guidelines.md`**
  - IDEC (PyCharm) agent guidelines

- **`.junie/guidelines.md`**
  - Junie (GPT-5) agent guidelines

- **`.junie/regression-baseline.json`**
  - Test regression baseline

### Project Config
- **`requirements.txt`** (PRIMARY)
  - Production dependencies
  - numpy, scipy, sounddevice, soundfile

- **`requirements_all.txt`**
  - All dependencies including dev tools

---

## 📖 Documentation

### Main Docs
- **`README.md`** - Project overview, quick start
- **`CLAUDE.md`** - Instructions for Claude Code
- **`START_HERE.md`** - New contributor guide
- **`CHANGELOG.md`** - Version history

### Design Docs
- **`DESIGN.md`** - Refactoring roadmap, architecture
- **`GUI_CONCEPT.md`** - GUI design mockups
- **`Visual Design.md`** - Branding, color schemes

### Agent Docs
- **`AGENT_FORWARD_PLANS.md`** - Current agent assignments
- **`AGENT_ROSTER.md`** - Agent identities and roles
- **`AGENT_MACROS.md`** - Common agent commands
- **`AGENT_QUICK_START.md`** - Agent onboarding
- **`docs/AGENT_MESSAGING_SYSTEM.md`** - Hub usage guide
- **`docs/QUICK_REFERENCE_AGENT_MESSAGING.md`** - API reference

### Polish Phase Docs
- **`POLISH_PHASE_STATUS.md`** (LIVE DASHBOARD)
  - Real-time task tracking
  - Agent status updates
  - Progress: 60% (3/5 tasks)

- **`POLISH_PHASE_OVERVIEW.md`** - Phase description
- **`docs/POLISH_PHASE_TIER1_TASKS.md`** - Detailed task specs
- **`TASK2_CUSTOM_PRESETS_COMPLETE.md`** - Task 2 report

### Phase Completion Docs
- **`PHASE4_COMPLETION_REPORT.md`** - Phase 4 wrap-up
- **`GUI_PHASE3_COMPLETE.md`** - Phase 3 GUI completion
- **`GUI_INTEGRATION_COMPLETE.md`** - GUI integration report

### MCP Docs
- **`MCP_QUICK_START.md`** - MCP setup guide
- **`MCP_SERVER_SETUP.md`** - Server configuration
- **`AGENT_HUB_README.md`** - Hub system overview
- **`MCP_PERSISTENCE_FIX.md`** - Database persistence notes

### Audio Docs
- **`docs/presets.md`** - Preset reference
- **`docs/protocols.md`** - Frequency protocols
- **`docs/research.md`** - Scientific background
- **`docs/authoring.md`** - Custom preset creation
- **`README_AUDIO_QUALITY.md`** - Audio quality specs
- **`README_MODES.md`** - Mode descriptions

### Task Reports
- **`.junie/test-reports/`** - Junie's test reports
  - `polish_phase_tier1_task1_test_report.md`
  - `phase4_qa_report.md`
  - `phase4_gui_smoke.md`

---

## 🔧 Utilities & Scripts

### Conversion Scripts
- **`scripts/convert_icon.py`**
  - SVG → .ico/.png conversion
  - Multi-size icon generation

### Demo Scripts
- **`demo_app.py`** - Simple demo application
- **`demo_agent_names.py`** - Agent identity demo
- **`phiwave/demo_agent_messaging.py`** - Messaging demo

### Legacy Scripts
- **`binaural_basic.py`** - Basic binaural generator
- **`check_my_tasks.py`** - Task checker utility
- **`junie_next_task.py`** - Junie task assignment

### Remote Control
- **`ssh_server.py`** - SSH command server
- **`phiwave/remote_command_processor.py`** - Remote control
- **`phiwave/integrated_remote_processor.py`** - Integrated remote
- **`SSH_SERVER_README.md`** - SSH server docs
- **`REMOTE_PHONE_CONTROL.md`** - Phone control guide

---

## 📁 Directory Structure

```
PhiWave/
├── phiwave/                    # Core audio library
│   ├── audio/                  # Audio generation
│   │   ├── engine.py          # PRIMARY audio engine
│   │   ├── engine_enhanced.py # Enhanced features
│   │   └── __init__.py
│   ├── io/                     # Input/Output
│   │   ├── playback.py        # PRIMARY playback (WASAPI)
│   │   ├── export.py          # File export
│   │   └── __init__.py
│   ├── presets/                # Preset system
│   │   ├── loader.py          # Built-in presets
│   │   ├── custom_presets.py  # Custom presets (Task 2)
│   │   ├── defaults.json      # Preset data
│   │   └── __init__.py
│   ├── config.py               # Audio config
│   ├── validation.py           # Audio validation
│   ├── modes.py                # Mode definitions
│   └── agent_*.py              # Agent utilities
│
├── phiwave_gui/                # GUI application
│   ├── controls/               # UI controls
│   │   ├── sliders.py         # Parameter sliders
│   │   ├── buttons.py         # Play/Stop/Mode indicator
│   │   └── dropdowns.py       # Preset/Mode dropdowns
│   ├── dialogs/                # Dialog windows
│   │   ├── export.py          # Export dialog
│   │   └── canvas.py          # Visualization
│   ├── app.py                  # PRIMARY - Main GUI app
│   ├── config.py               # GUI config (colors/fonts)
│   └── __init__.py
│
├── tests/                      # Test suite
│   ├── test_audio_engine.py
│   ├── test_validation_tool.py
│   └── ...
│
├── docs/                       # Documentation
│   ├── AGENT_MESSAGING_SYSTEM.md
│   ├── POLISH_PHASE_TIER1_TASKS.md
│   ├── presets.md
│   ├── protocols.md
│   └── ...
│
├── .claude/                    # Claude Code config
│   ├── settings.local.json    # Permissions
│   └── custom_instructions.md
│
├── .ide_claude/                # IDEC (PyCharm) config
├── .junie/                     # Junie config & reports
├── scripts/                    # Utility scripts
├── audio/                      # Legacy audio (noise.py shim)
│
├── phiwave_gui.py              # GUI ENTRY POINT
├── validator.py                # Validator CLI
├── mcp_agent_hub.py            # MCP SERVER
├── agent_hub_mcp.py            # Direct hub access
├── agent_hub.db                # SQLite database
│
├── README.md                   # Project README
├── CLAUDE.md                   # Claude instructions
├── POLISH_PHASE_STATUS.md      # LIVE STATUS DASHBOARD
├── PROJECT_INDEX.md            # THIS FILE
├── requirements.txt            # Dependencies
└── .mcp.json                   # MCP config
```

---

## 🎯 Common Workflows

### 1. Generate & Play Audio
```python
from phiwave.audio.engine import generate_binaural_segment
from phiwave.io.playback import play_buffer

audio = generate_binaural_segment(
    base_freq=100,
    beat_freq=8,
    duration=60,
    volume=0.25
)
mode = play_buffer(audio, sample_rate=44100)
print(f"Playing in: {mode}")
```

### 2. Export Audio
```python
from phiwave.io.export import write_wav
write_wav("output.wav", audio, sample_rate=44100)
```

### 3. Validate Audio
```python
from phiwave.validation import quick_validation
result = quick_validation(carrier_hz=180, beat_hz=10)
print(result['message'])
```

### 4. Load Preset
```python
from phiwave.presets.loader import PresetLoader
loader = PresetLoader()
presets = loader.list_presets()
preset = loader.get_preset("bn_alpha_8hz")
```

### 5. Custom Preset
```python
from phiwave.presets.custom_presets import CustomPresetManager
manager = CustomPresetManager()
manager.add_preset(
    name="My Focus",
    carrier_hz=100,
    beat_hz=10,
    duration_sec=600,
    volume=0.3
)
```

### 6. Agent Hub Message
```python
from agent_hub_mcp import post_message
post_message("TERMC", "Task complete", "status")
```

---

## 🚀 Entry Points

### Run GUI
```bash
python phiwave_gui.py
```

### Run Validator
```bash
python validator.py audio_file.wav
```

### Run Preset CLI (legacy)
```bash
python binaural_presets.py
```

### Run MCP Server
```bash
python mcp_agent_hub.py
```

### Run Tests
```bash
pytest tests/
```

---

## 🔍 Search Tips for Agents

### Find by Feature
- **WASAPI exclusive mode** → `phiwave/io/playback.py:104` (`try_wasapi_exclusive()`)
- **Custom presets** → `phiwave/presets/custom_presets.py:15` (`CustomPresetManager`)
- **Audio mode indicator** → `phiwave_gui/controls/buttons.py:78` (`audio_mode_label`)
- **Preset save button** → `phiwave_gui/controls/dropdowns.py` (search "Save Custom")
- **Binaural generation** → `phiwave/audio/engine.py:45` (`generate_binaural_segment()`)
- **Validation** → `phiwave/validation.py:13` (`quick_validation()`)

### Find by Import
- Import `generate_binaural_segment` → From `phiwave.audio.engine`
- Import `play_buffer` → From `phiwave.io.playback`
- Import `CustomPresetManager` → From `phiwave.presets.custom_presets`
- Import `PresetLoader` → From `phiwave.presets.loader`
- Import `post_message` → From `agent_hub_mcp` or use MCP tool

---

## 📊 Current State

**Version:** 2.0 (Phase 4 complete, Polish Phase in progress)
**Polish Phase:** 60% complete (3/5 tasks done)
**Last Major Work:** WASAPI Exclusive Mode GUI integration
**Active Branch:** main
**Latest Commit:** 9695612 (Task 3 complete)

**Completed Tasks:**
- ✅ Task 1: Audio Loop Crossfade
- ✅ Task 2: Custom Preset Manager
- ✅ Task 3: WASAPI Exclusive Mode

**In Progress:**
- 🔄 Task 4: Audio Validator CLI (Junie)
- 🔄 Task 5: App Icon Design (IDEC)

---

## 🆘 Troubleshooting

### Can't find audio generation code?
→ `phiwave/audio/engine.py`

### Can't find playback code?
→ `phiwave/io/playback.py`

### Can't find GUI main app?
→ `phiwave_gui/app.py`

### Can't find preset loading?
→ `phiwave/presets/loader.py` (built-in) or `custom_presets.py` (custom)

### Can't find agent hub?
→ `mcp_agent_hub.py` (MCP) or `agent_hub_mcp.py` (direct)

### Can't find task status?
→ `POLISH_PHASE_STATUS.md` (live dashboard)

### Can't find tests?
→ `tests/` directory

### Can't find documentation?
→ `docs/` directory, or main docs in root

---

**End of Project Index**
For questions, check `CLAUDE.md` or ask TERMC (coordinator).
