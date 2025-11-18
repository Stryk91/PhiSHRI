# Complete Python Package Requirements

**For:** PhiWave Phase 2 Modular Refactoring + Phase 3 GUI + Testing

**Install all with:**
```bash
pip install -r requirements_all.txt
```

---

## By Category

### CORE AUDIO (Required - Already in requirements.txt)
```
numpy>=1.24.0           # Numerical arrays, signal processing
scipy>=1.11.0           # Signal filtering, FFT, DSP
sounddevice>=0.4.6      # Audio playback (PortAudio backend)
soundfile>=0.12.1       # WAV/FLAC file I/O
```

### DEVELOPMENT & LINTING (Required for Phase 2)
```
pytest>=7.0.0           # Unit testing framework
pytest-cov>=4.0.0       # Code coverage reports
black>=23.0.0           # Code formatter (line length: 100)
flake8>=6.0.0           # Linter
isort>=5.12.0           # Import sorting
pre-commit>=3.0.0       # Pre-commit git hooks
```

### GUI (Required for Phase 3 - comes with Python)
```
tkinter                 # Built-in with Python 3 (no pip install needed)
```

### TYPE CHECKING (Recommended - catch bugs early)
```
mypy>=1.5.0            # Static type checker
types-setuptools       # Type stubs for setuptools
```

### DOCUMENTATION (Optional but recommended)
```
pdoc>=13.0.0           # Auto-generate API docs from docstrings
sphinx>=7.0.0          # Professional documentation generator
sphinx-rtd-theme       # ReadTheDocs theme for Sphinx
```

### UTILITIES (Nice to have)
```
click>=8.1.0           # CLI framework (if building CLI commands)
pydantic>=2.0.0        # Data validation (for config files)
python-dotenv>=1.0.0   # Environment variable loading
```

### PERFORMANCE & PROFILING (Optional - for optimization)
```
line-profiler>=4.0.0   # Profile function line-by-line
memory-profiler>=0.60  # Analyze memory usage
```

---

## Quick Install Commands

### Minimal (just audio, no testing)
```bash
pip install numpy scipy sounddevice soundfile
```

### Development (audio + testing + linting)
```bash
pip install -r requirements.txt
```

### Complete (everything for Phase 2-3)
```bash
pip install numpy scipy sounddevice soundfile pytest pytest-cov black flake8 isort pre-commit mypy pdoc
```

### Full (with all optional packages)
```bash
pip install numpy scipy sounddevice soundfile pytest pytest-cov black flake8 isort pre-commit mypy pdoc sphinx sphinx-rtd-theme click pydantic python-dotenv line-profiler memory-profiler
```

---

## Phase 2 Specific (Modular Refactoring)

**Must have:**
- numpy, scipy, sounddevice, soundfile (audio generation)
- pytest, pytest-cov (unit testing)
- black, flake8, isort (code quality)
- pre-commit (enforcing quality)
- mypy (type checking - CRITICAL for refactoring)

**Should have:**
- pdoc (generate API docs for new modules)

**Can skip:**
- GUI packages (not needed for Phase 2)
- Profiling packages (optimize later)

---

## Phase 3 Specific (GUI)

**Must have:**
- tkinter (built-in, no install)
- numpy, scipy, sounddevice, soundfile (audio)
- pytest (test GUI)

**Should have:**
- black, flake8 (code quality)
- mypy (type hints for GUI code)

**Can skip:**
- Profiling (optimize later if needed)

---

## Installation Steps

### 1. Check Python version
```bash
python --version  # Should be 3.10+
```

### 2. Activate virtual environment
```bash
# Windows
.venv\Scripts\activate

# Mac/Linux
source .venv/bin/activate
```

### 3. Install requirements
```bash
# Option A: Just core + dev tools
pip install -r requirements.txt

# Option B: Add type checking
pip install -r requirements.txt mypy

# Option C: Everything
pip install numpy scipy sounddevice soundfile pytest pytest-cov black flake8 isort pre-commit mypy pdoc
```

### 4. Verify installation
```bash
pip list | grep -E "numpy|scipy|sounddevice|pytest|black|mypy"
```

### 5. Test imports
```bash
python -c "import numpy, scipy, sounddevice, soundfile, pytest; print('Core OK')"
python -c "import black, flake8, mypy; print('Dev tools OK')"
```

---

## Potential Roadblocks & Solutions

### Issue: `sounddevice` fails on Windows
**Solution:**
```bash
pip install --upgrade sounddevice
# Or: pip install sounddevice --force-reinstall
```

### Issue: `scipy` takes forever to install
**Solution:**
```bash
# Use pre-built wheels (faster)
pip install --only-binary :all: scipy
```

### Issue: `mypy` reports false positives
**Solution:**
```bash
# Create mypy.ini in project root:
[mypy]
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
ignore_missing_imports = True
```

### Issue: `pre-commit` hook fails
**Solution:**
```bash
# Skip for now, test manually
make format && make lint
```

### Issue: `pytest` can't find modules
**Solution:**
```bash
# Run from project root
pytest tests/ -v
# Or add to pytest.ini:
[pytest]
testpaths = tests
python_files = test_*.py
```

---

## Complete requirements_all.txt

Create this file for one-command install:

```
# Core audio
numpy>=1.24.0
scipy>=1.11.0
sounddevice>=0.4.6
soundfile>=0.12.1

# Development & testing
pytest>=7.0.0
pytest-cov>=4.0.0
black>=23.0.0
flake8>=6.0.0
isort>=5.12.0
pre-commit>=3.0.0

# Type checking
mypy>=1.5.0
types-setuptools

# Documentation
pdoc>=13.0.0

# Utilities (optional)
click>=8.1.0
pydantic>=2.0.0
python-dotenv>=1.0.0
```

Save as: `E:\PythonProjects\PhiWave\requirements_all.txt`

Then install:
```bash
pip install -r requirements_all.txt
```

---

## Tkinter Note

**For GUI (Phase 3):**
- tkinter comes built-in with Python
- No pip install needed
- Verify with: `python -c "import tkinter; print('Tkinter OK')"`
- If missing on Linux: `sudo apt install python3-tk`
- Already included on Windows Python installations

---

## Version Compatibility

**Python versions tested:**
- 3.10 ✅
- 3.11 ✅
- 3.12 ✅

**Recommended:** Python 3.11 or 3.12 (best balance of features + stability)

---

## Summary

**Minimum for Phase 2:**
```bash
pip install -r requirements.txt mypy
```

**Everything for Phase 2-3:**
```bash
pip install -r requirements_all.txt
```

**No roadblocks if you install everything above!** 🚀
