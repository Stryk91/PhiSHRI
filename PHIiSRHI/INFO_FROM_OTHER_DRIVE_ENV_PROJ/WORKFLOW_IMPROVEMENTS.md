# Workflow Improvements for PhiWave Development

Generated: 2025-10-24
Current setup: Claude Code + Web Claude + GitHub

---

## 1. Development Tooling

### A. Add Pre-commit Hooks ✅ RECOMMENDED
Automatically lint/format code before commits to maintain quality.

**Setup:**
```bash
pip install pre-commit black flake8 isort
pre-commit install
```

**Create `.pre-commit-config.yaml`:**
```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.12.0
    hooks:
      - id: black
        language_version: python3
        args: [--line-length=100]

  - repo: https://github.com/PyCQA/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: [--profile=black]

  - repo: https://github.com/PyCQA/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        args: [--max-line-length=100, --extend-ignore=E203,W503]
```

**Benefits:**
- Consistent code style across CLI and web Claude commits
- Catches syntax errors before they reach GitHub
- Auto-formats imports and line length

---

### B. Makefile for Common Commands ✅ RECOMMENDED
Single source of truth for development tasks.

**Create `Makefile`:**
```makefile
.PHONY: install test lint format run clean help

help:
	@echo "PhiWave development commands:"
	@echo "  make install    - Install dependencies in venv"
	@echo "  make lint       - Run flake8 linter"
	@echo "  make format     - Auto-format code (black, isort)"
	@echo "  make test       - Run pytest (when available)"
	@echo "  make run        - Run main CLI"
	@echo "  make clean      - Remove cache/artifacts"

install:
	pip install -r requirements.txt
	pip install pre-commit black flake8 isort pytest

lint:
	flake8 binaural_presets.py export.py noise.py

format:
	black binaural_presets.py export.py noise.py
	isort binaural_presets.py export.py noise.py

test:
	pytest tests/ -v

run:
	python binaural_presets.py

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage htmlcov
```

**Usage:**
```bash
make format && make lint && make test
```

**Benefits:**
- Easy onboarding for web Claude
- Consistent development commands
- IDE can trigger `make run` or `make test` easily

---

### C. GitHub Actions CI/CD ✅ RECOMMENDED
Automated testing and linting on every push.

**Create `.github/workflows/tests.yml`:**
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    strategy:
      matrix:
        python-version: ['3.11', '3.12']

    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest black flake8 isort

      - name: Format check
        run: black --check binaural_presets.py export.py noise.py

      - name: Lint
        run: flake8 binaural_presets.py export.py noise.py

      - name: Tests
        run: pytest tests/ -v --tb=short
```

**Benefits:**
- Catch issues before they reach main branch
- Ensures code quality across Python versions
- Automated feedback on pull requests

---

## 2. Documentation & Knowledge Management

### A. Update CLAUDE.md with Decision Log ✅ NEW SECTION

Add a "Development Decisions" section to track why certain choices were made:

```markdown
## Development Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| Monolithic `binaural_presets.py` → modular `phiwave/` | Better testability, team development | 2025-10-24 | Phase 2 |
| sounddevice over pyaudio | Cross-platform, PortAudio backend | 2025-10-24 | Active |
| soundfile for export (not scipy) | FLAC support, better maintenance | 2025-10-24 | Active |
| JSON presets over YAML | Simpler, built-in json module | TBD | Planned |
| Tkinter GUI over PyQt | Minimal dependencies, built-in | Phase 3 | Planned |
```

**Benefits:**
- Web Claude understands trade-offs
- Prevents re-litigating old decisions
- Tracks evolution of architecture

---

### B. Create CONTRIBUTING.md ✅ NEW FILE

Guide for both Claude instances on contributing:

```markdown
# Contributing to PhiWave

## Workflow for CLI Claude (this instance)

1. **Research & Planning**
   - Use CLAUDE.md for context
   - Check DESIGN.md for roadmap
   - Read WORKFLOW_IMPROVEMENTS.md for standards

2. **Implementation**
   - Create feature branch: `git checkout -b feature/xyz`
   - Follow code style: `make format && make lint`
   - Commit frequently with clear messages

3. **Testing**
   - Run `make test` before push
   - Update tests for new features
   - Verify no regressions

4. **Handoff to Web Claude**
   - Push to feature branch
   - Create PR with detailed description
   - Include test results in PR body

## Workflow for Web Claude

1. **Code Review**
   - Review code changes
   - Run tests locally
   - Check architecture alignment with DESIGN.md

2. **Feedback**
   - Comment on PR with suggestions
   - Request changes if needed
   - Approve when ready

3. **Merge & Release**
   - Merge to master
   - Update CHANGELOG.md
   - Tag version if appropriate

## Code Style

- **Line length:** 100 characters
- **Formatter:** Black
- **Linter:** Flake8 + isort
- **Docstrings:** Google-style
- **Type hints:** Preferred for new code

## Testing

- Unit tests in `tests/` directory
- Minimum 80% coverage for `audio/` and `io/` modules
- Test envelope/fade logic (see DESIGN.md §4.1)
- Test parameter validation edge cases

## Commit Messages

Format: `type: brief description`

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

Examples:
```
feat: add pink noise generator
fix: prevent click artifacts on fade boundary
docs: update preset reference in docs/presets.md
refactor: extract fade logic to audio/effects.py
test: add envelope symmetry test
chore: update requirements.txt
```

## Questions?

- Check CLAUDE.md Q&A section
- Review DESIGN.md sections 1-3 (architecture)
- Look at WORKFLOW_IMPROVEMENTS.md (this file)
```

---

## 3. Testing Infrastructure

### A. Unit Tests Scaffold ✅ RECOMMENDED

**Create `tests/test_engine.py`:**
```python
import pytest
import numpy as np
from binaural_presets import generate_binaural_segment, generate_isochronic_segment

class TestBinauralGeneration:
    def test_output_shape(self):
        seg = generate_binaural_segment(100, 8, 5)
        assert seg.shape == (44100 * 5, 2)  # 5 seconds stereo

    def test_volume_respected(self):
        seg = generate_binaural_segment(100, 8, 1, volume=0.3)
        assert np.max(np.abs(seg)) <= 0.3

    @pytest.mark.parametrize("beat", [0.5, 1, 5, 13, 15])
    def test_valid_beats(self, beat):
        seg = generate_binaural_segment(100, beat, 1)
        assert seg.shape[0] == 44100

    def test_invalid_beat_raises(self):
        with pytest.raises(ValueError):
            generate_binaural_segment(100, 20, 1)  # beat > 15 Hz

class TestIsochronicGeneration:
    def test_pulse_sharpness_effect(self):
        seg_sharp = generate_isochronic_segment(100, 5, 1, pulse_sharpness=4.0)
        seg_soft = generate_isochronic_segment(100, 5, 1, pulse_sharpness=1.5)

        # Sharper pulse → lower RMS
        rms_sharp = np.sqrt(np.mean(seg_sharp**2))
        rms_soft = np.sqrt(np.mean(seg_soft**2))
        assert rms_sharp < rms_soft
```

**Create `tests/conftest.py`:**
```python
import pytest
import numpy as np

@pytest.fixture
def sample_binaural():
    from binaural_presets import generate_binaural_segment
    return generate_binaural_segment(100, 8, 1)

@pytest.fixture
def sample_isochronic():
    from binaural_presets import generate_isochronic_segment
    return generate_isochronic_segment(100, 8, 1)
```

**Benefits:**
- Catch regressions early
- Validate audio quality constraints
- Satisfy DESIGN.md test plan (§4)

---

### B. Add pytest to Requirements ✅ QUICK WIN

Update `requirements.txt`:
```
numpy
scipy
sounddevice
soundfile
pytest>=7.0  # Added for testing
black>=23.0  # Added for formatting
flake8>=6.0  # Added for linting
isort>=5.0   # Added for import sorting
```

---

## 4. Git Workflow Enhancements

### A. Add Branch Protection Rules (GitHub Settings)

For `master` branch:
- ✅ Require pull request reviews (1 approval)
- ✅ Require status checks to pass (CI/CD)
- ✅ Require branches to be up to date
- ✅ Dismiss stale pull request approvals when new commits pushed

**Benefit:** Prevents accidental merges, ensures quality gates.

---

### B. Create CHANGELOG.md ✅ NEW FILE

Track releases and features:

```markdown
# Changelog

## [Unreleased]
- feat: modular audio engine (Phase 2 in progress)
- feat: JSON preset loader (Phase 4 planned)

## [0.2.0] - 2025-10-24
- feat: Isochronic mode with pulse sharpness control
- feat: Pink/Brown noise generators
- feat: WAV/FLAC export support
- fix: Fade envelope clicks on short segments
- docs: Add CLAUDE.md guidance for Claude Code

## [0.1.0] - 2025-10-20
- feat: Binaural beat generation with presets
- feat: Fibonacci and Golden Ratio frequency sets
- feat: Interactive CLI menu
- feat: Fade-in/out safety mechanism
```

**Benefit:** Web Claude sees version history and planned releases.

---

## 5. Directory & Project Organization

### A. Clean Up Artifacts ✅ IMMEDIATE

Remove/commit these files:
```bash
# Delete (large, auto-generated)
rm -f phiwave_complete.tar
rm -f phiwave_complete.tar.gz

# Commit remaining
git add -A
git commit -m "chore: clean up artifacts and tarballs"
```

---

### B. Reorganize Tests ✅ RECOMMENDED

```
PhiWave/
├── phiwave/              # Main package
│   ├── __init__.py
│   ├── audio/
│   ├── io/
│   └── presets/
├── tests/                # Unit tests (create if missing)
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_audio_engine.py
│   ├── test_export.py
│   ├── test_noise.py
│   └── test_presets.py
├── examples/             # Example scripts (create if missing)
│   ├── custom_session.py
│   ├── export_preset.py
│   └── stream_with_noise.py
├── docs/
├── binaural_presets.py   # Keep for backward compatibility
├── requirements.txt
├── Makefile
├── .pre-commit-config.yaml
├── CLAUDE.md
├── DESIGN.md
├── CONTRIBUTING.md       # NEW
├── CHANGELOG.md          # NEW
└── WORKFLOW_IMPROVEMENTS.md  # THIS FILE
```

---

## 6. IDE/Editor Integration

### A. PyCharm Settings (Local)

In `.idea/misc.xml` or PyCharm settings:
- ✅ Set Python interpreter to project `.venv`
- ✅ Enable Black integration: Settings → Tools → Python → Black
- ✅ Enable isort: Settings → Tools → Python → isort
- ✅ Run pre-commit on commit: VCS → Git → Commit → checkboxes

**Benefit:** Auto-format on save, pre-commit runs automatically.

---

### B. Claude Code Settings (`.claude/commands/`)

Create reusable commands for both instances:

**Create `.claude/commands/test.md`**
```markdown
# /test
Run the test suite

Runs pytest with coverage report and fails on quality issues.
```

**Create `.claude/commands/format.md`**
```markdown
# /format
Format and lint code

Runs black, isort, and flake8 across the codebase.
```

---

## 7. Communication & Handoffs

### A. Use GitHub Discussions ✅ NEW FEATURE

Enable Discussions in repo settings. Create:
- **Ideas & Questions:** Where should we add feature X?
- **Architecture:** Discuss design decisions
- **Blockers:** What's preventing progress?

**Benefit:** Async communication between Claude instances without PRs.

---

### B. PR Template (`.github/pull_request_template.md`) ✅ NEW FILE

```markdown
## Description
Brief explanation of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] No regressions observed

## Checklist
- [ ] Code follows style guide (black, isort, flake8)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] All tests pass (`make test`)

## References
Closes #(issue number) or relates to DESIGN.md §(section)
```

---

## 8. Development Speed Optimizations

### A. Lazy Loading in binaural_presets.py ✅ OPTIONAL

Currently imports all modules. Consider lazy import for faster CLI startup:

```python
def main():
    # Import inside function for faster CLI response
    import sounddevice as sd
    import numpy as np
    # ... rest of code
```

---

### B. Cache Audio Generation ✅ OPTIONAL

For testing, cache generated segments to disk:

```python
import hashlib
import json

def _cache_key(base_freq, beat_freq, duration, volume):
    data = f"{base_freq}_{beat_freq}_{duration}_{volume}"
    return hashlib.md5(data.encode()).hexdigest()

def generate_cached(base_freq, beat_freq, duration, volume=0.25):
    key = _cache_key(base_freq, beat_freq, duration, volume)
    cache_file = f"cache/{key}.npy"

    if os.path.exists(cache_file):
        return np.load(cache_file)

    buf = generate_binaural_segment(base_freq, beat_freq, duration, volume)
    os.makedirs("cache", exist_ok=True)
    np.save(cache_file, buf)
    return buf
```

---

## 9. Documentation Automation

### A. Auto-generate API Docs ✅ OPTIONAL

Install `pdoc`:
```bash
pip install pdoc
```

Generate docs:
```bash
pdoc phiwave/ -o docs/api
```

Creates HTML API reference automatically from docstrings.

---

### B. Add Docstring Examples ✅ RECOMMENDED

Update function docstrings with examples:

```python
def generate_binaural_segment(base_freq, beat_freq, duration, ...):
    """
    Generate stereo binaural beat segment.

    Args:
        base_freq: Carrier frequency (60-125 Hz)
        beat_freq: Beat frequency (0.5-15 Hz)
        duration: Duration in seconds

    Returns:
        Stereo numpy array with shape (N, 2)

    Example:
        >>> seg = generate_binaural_segment(100, 8, 300)
        >>> play_buffer(seg)  # Play 5-minute session

        >>> export.write_wav("session.wav", seg, 44100)
    """
```

---

## 10. Quick Wins (Easy to Implement Now)

| Task | Time | Impact | Status |
|------|------|--------|--------|
| Add `Makefile` | 10 min | High | Ready |
| Add `.pre-commit-config.yaml` | 5 min | High | Ready |
| Create `CONTRIBUTING.md` | 15 min | Medium | Ready |
| Create `CHANGELOG.md` | 10 min | Medium | Ready |
| Add pytest to requirements | 2 min | High | Ready |
| Create `tests/conftest.py` skeleton | 10 min | High | Ready |
| Clean up tar artifacts | 5 min | Low | Ready |
| Add PR template | 5 min | Medium | Ready |

---

## Implementation Roadmap

### Phase 1: Foundation (This Week)
- [ ] Add Makefile
- [ ] Add `.pre-commit-config.yaml` + pre-commit hooks
- [ ] Create CONTRIBUTING.md
- [ ] Create CHANGELOG.md
- [ ] Update requirements.txt (add test/lint tools)
- [ ] Create tests/ directory with conftest.py

### Phase 2: Automation (Next Week)
- [ ] Set up GitHub Actions CI/CD
- [ ] Add branch protection rules
- [ ] Create PR template
- [ ] Clean up artifacts (tar files)

### Phase 3: Polish (Following Week)
- [ ] Add docstring examples to functions
- [ ] Generate API docs (pdoc)
- [ ] Create example scripts in examples/
- [ ] Update CLAUDE.md with decision log

---

## Summary

**Key improvements for better CLI ↔ Web Claude workflow:**

1. **Consistency:** Makefile, pre-commit hooks, code formatter
2. **Quality:** Pytest, linting, type hints, GitHub Actions
3. **Knowledge:** CONTRIBUTING.md, decision log, docstring examples
4. **Efficiency:** Branch protection, PR templates, GitHub Discussions
5. **Organization:** Clean directory structure, CHANGELOG, examples

**Estimated effort:** 2-3 hours for Phase 1 implementation
**Expected ROI:** 30-40% faster feature development, fewer regressions

---

## Questions?

See CLAUDE.md or ask web Claude via GitHub Discussions!
