# PhiWave

Binaural and isochronic audio generator with presets inspired by the Fibonacci sequence and the golden ratio. Includes a Tkinter GUI, a CLI, audio export utilities, and a small automated test suite.

Repository: https://github.com/Stryk91/Phiwave.git

Last updated: 2025-11-04


## Overview

PhiWave generates brainwave‑entrainment style audio either as:
- Binaural beats (stereo: left=carrier, right=carrier+beat; headphones required)
- Isochronic tones (amplitude‑pulsed carrier; works on speakers or headphones)

Core capabilities:
- 0.5–15 Hz beat frequencies, 60–125 Hz carriers
- Presets (Fibonacci, golden ratio, Schumann 7.83 Hz, etc.)
- Ramps and basic crossfades
- WAV/FLAC export
- Device enumeration and playback via sounddevice
- Tkinter GUI for interactive control, CLI for quick runs

Safety notes:
- Start with low volume
- If you feel discomfort, stop immediately
- Do not use while driving or operating machinery


## Tech Stack

- Language: Python (3.9–3.12 recommended; 3.13 may work but some audio stacks are still maturing)
- GUI: Tkinter (phiwave_gui.py). A PyQt layout exists in assets but Tkinter is the primary GUI used now.
- Audio DSP: numpy, scipy
- Audio I/O: sounddevice (PortAudio), soundfile
- Packaging/Deps: pip + requirements files
- Tests: pytest
- Formatting/Linting: black, isort, flake8


## Requirements

Choose one of the dependency sets:
- Core runtime only: requirements.txt
- Full dev/test/docs: requirements_all.txt

On Windows PowerShell (recommended):

```
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -U pip wheel
pip install -r requirements_all.txt
```

If you only need runtime dependencies:
```powershell
pip install -r requirements.txt
```


## Project Structure

High‑level layout (trimmed to key items):

```
PhiWave/
├── phiwave/                 # Main package
│   ├── audio/
│   │   └── engine.py        # Signal generation (binaural/isochronic, ramps)
│   ├── io/
│   │   ├── export.py        # WAV/FLAC export
│   │   └── playback.py      # Playback and device enumeration
│   ├── presets/
│   │   ├── loader.py        # Preset loading from JSON
│   │   └── defaults.json    # Preset data (if present)
│   ├── agent_feed.py        # JSONL logging utility
│   ├── config.py            # Constants (e.g., SAMPLE_RATE)
│   └── __init__.py
├── phiwave_gui.py           # Main Tkinter GUI
├── binaural_presets.py      # CLI interface
├── tests/                   # Pytest suite
├── requirements.txt         # Core deps
├── requirements_all.txt     # Dev/Test/Docs deps
├── docs/                    # Documentation and agent feed
└── .junie/                  # QA workspace for automated testing
```

Notes:
- Additional GUI assets and helper modules exist (phiwave_gui/, assets/, etc.).
- Batch scripts are provided for convenience on Windows.


## How to Run

- GUI (Tkinter):
  ```powershell
  python phiwave_gui.py
  ```

- CLI (menu‑driven presets):
  ```powershell
  python binaural_presets.py --help
  python binaural_presets.py
  ```

- Quick smoke test (engine + export):
  ```
from phiwave.audio.engine import generate_binaural_segment
from phiwave.io.export import write_wav
from phiwave.config import SAMPLE_RATE
import tempfile, pathlib

audio = generate_binaural_segment(100, 8, 1, volume=0.1, sample_rate=SAMPLE_RATE)
with tempfile.TemporaryDirectory() as tmp:
    p = pathlib.Path(tmp) / "t.wav"
    write_wav(p, audio, SAMPLE_RATE)
    print("ok:", p.exists(), p.stat().st_size > 1000)
```

- Device enumeration (troubleshooting):
  ```
from phiwave.io.playback import list_output_devices
list_output_devices()
```

Tips:
- Headphones required for binaural mode; not required for isochronic.
- If no sound, list devices and set sd.default.device to the correct index.


## Scripts (Windows convenience)

The repo includes helper scripts; commonly used:
- LAUNCH_GUI.bat → launches phiwave_gui.py
- RUN_PHIWAVE.bat, RUN_PHIWAVE_GUI(1).bat, RUN_GUI_DEBUG.bat → alternate launchers
- INSTALL_PHIWAVE.bat → bootstrap installation

These are optional; you can always run via python commands shown above.


## Environment Variables

- PHIWAVE_AGENT_FEED: Full path to the JSONL agent feed. If unset, the default is docs/agent-feed.jsonl (or a project‑specific absolute path on the maintainer’s machine). Used by phiwave.agent_feed.log_action().

Example:
```powershell
$env:PHIWAVE_AGENT_FEED = "E:\\PythonProjects\\PhiWave\\docs\\agent-feed.jsonl"
```


## Testing

Run all tests:
```powershell
pytest -q
```

Verbose with short tracebacks:
```powershell
pytest tests -v --tb=short
```

Run a single test:
```powershell
pytest tests\test_audio_engine.py::test_generate_binaural_segment_basic_properties -q
```

Suggested regression checks (fast):
```
from phiwave.audio.engine import generate_binaural_segment, generate_isochronic_segment
from phiwave.io.export import write_wav, write_flac
from phiwave.presets.loader import PresetLoader
from phiwave.config import SAMPLE_RATE
import tempfile, pathlib

# Engine
buf1 = generate_binaural_segment(100, 8, 0.25, volume=0.1, sample_rate=SAMPLE_RATE)
buf2 = generate_isochronic_segment(100, 5, 0.25, volume=0.1, sample_rate=SAMPLE_RATE)
print(buf1.shape, buf2.shape)

# Export
with tempfile.TemporaryDirectory() as tmp:
    p = pathlib.Path(tmp)
    write_wav(p/'t.wav', buf1, SAMPLE_RATE)
    write_flac(p/'t.flac', buf1, SAMPLE_RATE)
    print('export ok')

# Presets
loader = PresetLoader()
print('presets:', len(loader.presets))
```


## Features (summary)

- Binaural mode
  - Left=carrier, Right=carrier+beat; stereo required
- Isochronic mode
  - Pulse sharpness and floor controls
- Presets
  - Fibonacci: 1, 2, 3, 5, 8, 13 Hz
  - Golden ratio multiples: 1.618, 3.236, 4.854, 6.472, 8.090 Hz
  - Schumann: 7.83 Hz, Golden Sleep ~2.618 Hz
- Ramps
  - Fibonacci 3 → 5 → 8 → 13 (binaural and isochronic)
- Safety
  - Fade‑in/out and volume constraints


## Legacy and housekeeping

- Root-level export.py is now a deprecated shim that re-exports the canonical API from `phiwave.io.export`. Please update imports to:
  
  from phiwave.io.export import write_wav, write_flac
  
- A summary of deprecated/legacy items is kept in docs/LEGACY.md. Refer to it when cleaning up paths or scripts.

## Troubleshooting

- Clicks in audio
  - Lower pulse_sharpness (1.5–2.0)
  - Add off_gain (0.05–0.15)
  - Keep fade_time around 0.5 s
- Stutters
  - Try SAMPLE_RATE=48000
  - Close other audio apps
- No sound / wrong device
  - Run device enumeration and set sd.default.device


## Contributing / Code Quality

- Style: PEP8; format with Black (line length 100) and organize imports with isort
- Lint: flake8
- Type hints where practical; docstrings on public APIs
- No print() in production paths; use logging or agent feed where applicable

Dev helpers:
```powershell
black .
isort . --profile black
flake8 --max-line-length 100
pytest -v --tb=short
```


## License

No explicit LICENSE file is present in this repository at the time of writing.
- TODO: Confirm intended license with the maintainer (MIT/Apache-2.0/BSD-3-Clause/etc.) and add a LICENSE file.
- Until then, assume “all rights reserved” by the project authors. Do not redistribute audio as medical claims.


## Acknowledgments

- PortAudio via sounddevice
- numpy/scipy communities


## Appendix: Related Utilities

This repo includes additional utilities for development and team workflows (agent hub, QA helpers) and optional tools such as password_vault_app.py. These are not required to run PhiWave but may be useful; see the respective .bat files and source modules for usage.
