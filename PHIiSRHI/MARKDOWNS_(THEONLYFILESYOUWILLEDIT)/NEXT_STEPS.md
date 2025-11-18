# Next Steps - PhiWave Development

**Last updated:** 2025-10-24
**Current phase:** Foundation setup (Phase 1 complete)

---

## What Just Happened ✅

We've implemented **Phase 1: Foundation** of the workflow improvements:

### Completed Tasks
- ✅ Created **CLAUDE.md** — Claude Code guidance
- ✅ Created **E_DRIVE_MAP.md** — Project structure reference
- ✅ Created **Makefile** — Common development commands
- ✅ Created **.pre-commit-config.yaml** — Automated code formatting/linting
- ✅ Created **CONTRIBUTING.md** — Contributor guide for CLI + Web Claude
- ✅ Created **WORKFLOW_IMPROVEMENTS.md** — Detailed improvements plan
- ✅ Created **CHANGELOG.md** — Release history and versioning
- ✅ Updated **requirements.txt** — Added dev tools (pytest, black, flake8, isort)
- ✅ Renamed directory — `MindstateClone/` → `PhiWave/`
- ✅ Set up GitHub remote — https://github.com/Stryk91/Phiwave.git
- ✅ Committed and pushed to GitHub

---

## Immediate Next Steps (This Week)

### 1. Install Pre-commit Hooks ⚡ (5 minutes)

```bash
cd /e/PythonProjects/PhiWave

# Install pre-commit tool
pip install pre-commit

# Set up git hooks
pre-commit install

# Test it works
pre-commit run --all-files
```

**What this does:** Automatically formats code before commits using Black, isort, and flake8.

---

### 2. Create Tests Directory & Scaffold (15 minutes)

```bash
# Create tests directory
mkdir -p tests

# Create conftest.py for fixtures
cat > tests/conftest.py << 'EOF'
import pytest
import numpy as np

@pytest.fixture
def sample_rate():
    return 44100

@pytest.fixture
def binaural_segment():
    from binaural_presets import generate_binaural_segment
    return generate_binaural_segment(base_freq=100, beat_freq=8, duration=1)

@pytest.fixture
def isochronic_segment():
    from binaural_presets import generate_isochronic_segment
    return generate_isochronic_segment(base_freq=100, beat_freq=8, duration=1)
EOF
```

**Then create `tests/test_binaural.py`:**
```python
import pytest
import numpy as np

class TestBinauralGeneration:
    def test_output_shape(self, binaural_segment):
        assert binaural_segment.ndim == 2
        assert binaural_segment.shape[1] == 2

    def test_volume_constraint(self):
        from binaural_presets import generate_binaural_segment
        seg = generate_binaural_segment(100, 8, 1, volume=0.3)
        assert np.max(np.abs(seg)) <= 0.3

    def test_invalid_beat_raises(self):
        from binaural_presets import generate_binaural_segment
        with pytest.raises(ValueError):
            generate_binaural_segment(100, 20, 1)
```

**Run tests:**
```bash
make test  # or: pytest tests/ -v
```

---

### 3. Test the Makefile (2 minutes)

```bash
make help           # See all commands
make format         # Format code (should pass)
make lint          # Lint code (should pass)
```

---

### 4. Share with Web Claude ✉️

Send web Claude this checklist:
```
✅ PhiWave Workflow Setup Complete!

New development files committed:
- CLAUDE.md (guidance for Claude Code)
- CONTRIBUTING.md (contributor guide)
- WORKFLOW_IMPROVEMENTS.md (dev standards)
- CHANGELOG.md (version history)
- Makefile (common commands)
- .pre-commit-config.yaml (code quality hooks)
- requirements.txt (updated with dev tools)

Next: Review these files and let CLI Claude know if you'd like
to start Phase 2 (modular refactoring).

Repository: https://github.com/Stryk91/Phiwave.git
```

---

## Phase 2: Modular Refactoring (Next Week)

Once pre-commit hooks are working and tests are set up:

### Goal
Extract core audio logic from `binaural_presets.py` into `phiwave/` package structure.

### Tasks
1. Create `phiwave/audio/engine.py` with pure functions
2. Create `phiwave/io/export.py` for file operations
3. Create `phiwave/io/playback.py` wrapper around sounddevice
4. Create `phiwave/presets/loader.py` for JSON preset loading
5. Create comprehensive tests in `tests/`
6. Refactor `binaural_presets.py` to use new modules
7. Verify all existing CLI functionality works identically

### Estimated time: 8-10 hours

### Reference
See **DESIGN.md §1-3** for detailed architecture.

---

## Phase 3: GUI Implementation (Following Week)

### Goal
Build Tkinter GUI for interactive preset and parameter control.

### Tasks
1. Create `ui/gui_tk.py` with Tkinter interface
2. Implement live playback controls (Play, Pause, Stop)
3. Wire preset dropdown to `presets/loader.py`
4. Add export button with file picker
5. Threading for non-blocking playback
6. Device selection UI

### Estimated time: 12-15 hours

### Reference
See **GUI_CONCEPT.md** for UI mockups.

---

## Quick Reference Commands

```bash
# Development workflow
make format        # Auto-format code
make lint         # Check for style issues
make test         # Run tests
make run          # Run CLI

# Git workflow
git checkout -b feature/xyz         # Create branch
git add . && git commit -m "..."    # Commit
git push -u origin feature/xyz      # Push

# Pre-commit hooks
pre-commit install      # One-time setup
pre-commit run --all    # Manual run

# Python environment
pip install -r requirements.txt     # Install deps
python binaural_presets.py         # Run main CLI
```

---

## Success Criteria

Phase 1 is complete when:
- ✅ Pre-commit hooks installed and working
- ✅ Tests directory created with sample tests
- ✅ `make format`, `make lint`, `make test` all pass
- ✅ Web Claude has reviewed docs and is ready to help
- ✅ GitHub repo updated and accessible

Phase 2 is complete when:
- [ ] `phiwave/` package created with core modules
- [ ] 80%+ test coverage for audio and export modules
- [ ] All existing CLI functionality works identically
- [ ] No regressions in binaural/isochronic generation

Phase 3 is complete when:
- [ ] Tkinter GUI built and functional
- [ ] Live playback controls working
- [ ] Export dialog integrated
- [ ] Session save/load (optional)

---

## Asking for Help

### If stuck on...
- **Code style:** See CONTRIBUTING.md (Code Style section)
- **Testing:** See DESIGN.md §4 (Test Plan)
- **Architecture:** See DESIGN.md §1-3
- **Git workflow:** See CONTRIBUTING.md (Workflow sections)

### Escalation path
1. Check relevant .md file
2. Comment in a GitHub PR/Discussion
3. Tag web Claude for input

---

## Files You Should Know

| File | Purpose | Read when? |
|------|---------|-----------|
| **CLAUDE.md** | Claude Code guidance | First! |
| **CONTRIBUTING.md** | Dev standards + Git workflow | Before first PR |
| **WORKFLOW_IMPROVEMENTS.md** | Detailed improvements | For reference |
| **DESIGN.md** | Architecture + test plan | Before Phase 2 |
| **CHANGELOG.md** | Version history | Track releases |
| **Makefile** | Common commands | Daily use |
| **requirements.txt** | Dependencies | When installing |

---

## Remember

- **Pre-commit hooks** save time by catching style issues early
- **Make commands** provide consistency across tools (CLI + Web Claude)
- **Tests** are the safety net for future changes
- **Documentation** (CONTRIBUTING, DESIGN, CLAUDE) prevents miscommunication
- **Git workflow** (branches, PRs) keeps work organized

---

## Questions?

✉️ Ask web Claude via GitHub Discussions or PR comments!

🚀 Ready to build great things with PhiWave!
