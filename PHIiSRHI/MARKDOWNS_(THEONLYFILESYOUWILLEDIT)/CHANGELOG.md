# Changelog

All notable changes to PhiWave are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned (Phase 2-4)
- **Modular architecture:** Refactor `binaural_presets.py` into `phiwave/` package structure
- **JSON preset system:** Load presets from `presets.json` with validation
- **Automated tests:** Comprehensive test suite (see DESIGN.md §4)
- **GUI:** Tkinter interface with real-time playback controls
- **Advanced features:** Frequency ramping, multi-voice layering, visualizer

---

## [0.2.0] - 2025-10-24

### Added
- **Documentation**
  - CLAUDE.md: Guidance for Claude Code instances
  - WORKFLOW_IMPROVEMENTS.md: Development standards and tooling
  - CONTRIBUTING.md: Contributor guide for CLI + Web Claude workflows
  - E_DRIVE_MAP.md: Complete project structure reference
  - CHANGELOG.md: This file

- **Development Tooling**
  - Makefile: Common commands (install, lint, format, test, run, clean)
  - .pre-commit-config.yaml: Black, isort, flake8, trailing whitespace hooks
  - Testing infrastructure: pytest configuration ready (requires Phase 2 tests)

- **Code Quality**
  - Type hints and docstring examples in key functions
  - Pre-commit hooks for automated code formatting and linting
  - Flake8 linter configuration (max 100 char line length)

### Changed
- Renamed project directory: `MindstateClone/` → `PhiWave/`
- Updated requirements.txt with dev tools (pytest, black, flake8, isort)

### Fixed
- N/A (first organized release)

---

## [0.1.0] - 2025-10-20

### Added
- **Core Audio Engines**
  - `generate_binaural_segment()`: Stereo L/R frequency differential
  - `generate_isochronic_segment()`: Pulsed carrier with envelope control
  - Fade-in/out mechanisms to prevent audio clicks

- **Presets & Modes**
  - Fibonacci presets: 1, 2, 3, 5, 8, 13 Hz
  - Golden Ratio presets: 1.618, 3.236, 4.854, 6.472, 8.090 Hz
  - Schumann resonance: 7.83 Hz
  - Golden Sleep: ~2.618 Hz (phi + 1)
  - Ramp sequences: Fibonacci 3→5→8→13 Hz progression

- **Background Noise**
  - White noise generator
  - Pink noise generator (1/f spectrum via IIR filter)
  - Brown noise generator (1/f² spectrum via integration)

- **Export & I/O**
  - WAV export (32-bit float via soundfile)
  - FLAC export (16/24-bit PCM via soundfile)
  - Automatic clipping prevention

- **User Interface**
  - Interactive CLI menu with preset selection
  - Custom mode for arbitrary parameters
  - Device listing and troubleshooting
  - Audio device selection support

- **Safety Features**
  - Frequency constraints: beats 0.5–15 Hz, carriers 60–125 Hz
  - Volume control: safe default 0.25 (25%)
  - Parameter validation with clear error messages
  - Fade time safety (auto-clamps to duration/2)

- **Documentation**
  - README.md: Quick start and feature overview
  - DESIGN.md: Architecture, refactoring roadmap, test plan (14 detailed tests)
  - GUI_CONCEPT.md: Tkinter UI mockups
  - Visual Design.md: Color schemes and branding
  - docs/presets.md: Preset frequency reference
  - docs/protocols.md: Frequency protocols and research
  - docs/research.md: Scientific background on binaural beats
  - docs/authoring.md: Guide for creating custom presets

- **Project Structure**
  - Git repository with .gitignore
  - Python virtual environment (venv)
  - Requirements.txt for dependency management
  - Obsidian vault for development notes

### Technical Details
- Language: Python 3.10+
- Audio backend: sounddevice (PortAudio)
- Signal processing: numpy, scipy
- Sample rate: 44.1 kHz (configurable)
- Audio format: 32-bit float stereo
- Safety: Input validation, fade envelopes, clipping prevention

---

## Version History

### Pre-release Development
- Initial monolithic implementation in `binaural_presets.py`
- Binaural beat generation with preset system
- Isochronic mode with pulse sharpness control
- Noise layers (white, pink, brown)
- WAV/FLAC export functionality

---

## Future Releases (Planned)

### 0.3.0 - Modular Architecture
- Modular package structure (`phiwave/audio`, `phiwave/io`, etc.)
- Comprehensive test suite (pytest, 85%+ coverage)
- JSON preset loader with validation
- Session save/load with metadata sidecar

### 0.4.0 - GUI & Advanced Features
- Tkinter GUI with live playback controls
- Frequency ramping with crossfades
- Multi-voice layering (phi trinity)
- Real-time parameter modulation

### 0.5.0 - Polish & Distribution
- Audio visualizer (matplotlib spectrum)
- Mobile export (Android/iOS target)
- Binary releases (PyInstaller)
- Package distribution (PyPI)

---

## Notes for Developers

### Semantic Versioning
- **MAJOR:** Breaking API changes or major refactors
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes (backward compatible)

### Release Process
1. Update version in `__init__.py` (when created)
2. Update CHANGELOG.md with new section
3. Create git tag: `git tag v0.X.Y`
4. Push: `git push && git push --tags`
5. Create GitHub Release from tag

### Maintenance
- Keep pre-commit hooks up to date: `pre-commit autoupdate`
- Review dependencies quarterly for security updates
- Monitor GitHub issues and discussions
- Update documentation as features evolve

---

## Contributing

See **CONTRIBUTING.md** for guidelines on submitting PRs and issues.

---

## License

Personal/learning use. Do not distribute audio as medical claims.

See README.md for full license information.
