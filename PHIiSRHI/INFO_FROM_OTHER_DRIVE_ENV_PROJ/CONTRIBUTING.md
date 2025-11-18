# Contributing to PhiWave

Thanks for contributing! This guide covers the workflow for both Claude Code (CLI) and Web Claude.

## Quick Start

```bash
# 1. Install dev dependencies
make install

# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Make changes, format, and test
make format
make lint
make test

# 4. Commit with clear messages
git commit -m "feat: add new feature"

# 5. Push and create PR
git push -u origin feature/your-feature-name
```

---

## Workflow for Claude Code (CLI Instance)

### 1. Before You Start
- Read **CLAUDE.md** for project context
- Review **DESIGN.md** for architecture and planned phases
- Check **WORKFLOW_IMPROVEMENTS.md** for development standards
- Look at existing code to match style

### 2. Implementation
- Create a feature branch: `git checkout -b feature/xyz`
- Write code following the style guide (see below)
- Add docstrings and examples for new functions
- Keep functions small and focused (under 50 lines when possible)

### 3. Code Quality
```bash
# Format code
make format

# Check linting
make lint

# Run tests (if available)
make test
```

All three must pass before committing.

### 4. Commit & Push
```bash
git add .
git commit -m "type: brief description"
git push -u origin feature/branch-name
```

See **Commit Message Format** section below.

### 5. Handoff to Web Claude
- Push to feature branch (do NOT merge to master)
- Include test results in PR description
- Web Claude will review, test, and merge

---

## Workflow for Web Claude

### 1. Code Review
- Review changes for architectural alignment (DESIGN.md §1-3)
- Run `make test` and `make lint` locally
- Check that new code includes docstrings and examples
- Verify no regressions in existing functionality

### 2. Feedback
- Request changes if code doesn't match style or fails tests
- Suggest improvements for clarity or performance
- Approve when ready to merge

### 3. Merge to Master
```bash
# After approval, merge PR
git switch master
git pull
git merge --squash feature/branch-name
git commit -m "Your PR description"
git push
```

### 4. Update Documentation
- Update **CHANGELOG.md** with new features/fixes
- Update **DESIGN.md** if architecture changed
- Add examples to **docs/** if relevant

---

## Code Style

### Line Length
- **Maximum:** 100 characters (enforced by Black)
- **Rationale:** Better for split-screen terminals and readability

### Formatting
- **Formatter:** Black (runs via `make format`)
- **Import sorting:** isort (runs via `make format`)
- **Linter:** Flake8 (runs via `make lint`)

### Naming Conventions
- Functions: `lowercase_with_underscores`
- Classes: `PascalCase`
- Constants: `UPPER_CASE_WITH_UNDERSCORES`
- Private functions: `_leading_underscore`

### Docstrings
Use Google-style format with examples:

```python
def generate_binaural_segment(base_freq, beat_freq, duration,
                              volume=0.25, sample_rate=44100):
    """
    Generate a stereo binaural beat segment.

    Left channel contains pure carrier; right channel contains
    carrier + beat frequency. Includes fade-in/out to prevent clicks.

    Args:
        base_freq (float): Carrier frequency in Hz (60-125 Hz)
        beat_freq (float): Beat frequency in Hz (0.5-15 Hz)
        duration (float): Duration in seconds
        volume (float): Output volume 0-1. Default 0.25
        sample_rate (int): Sample rate in Hz. Default 44100

    Returns:
        np.ndarray: Stereo audio with shape (num_samples, 2)

    Raises:
        ValueError: If frequencies or duration are invalid

    Example:
        >>> # Generate 5-minute Golden Alpha preset
        >>> buf = generate_binaural_segment(100, 8.0, 300)
        >>> play_buffer(buf)
    """
```

### Type Hints (Preferred for New Code)
```python
from typing import Optional, Tuple
import numpy as np

def mix_audio(tone: np.ndarray, noise: np.ndarray,
              ratio: float = 0.7) -> np.ndarray:
    """Mix two audio buffers with given ratio."""
    return tone * ratio + noise * (1 - ratio)
```

---

## Testing

### Running Tests
```bash
make test          # Run all tests
pytest tests/ -v   # Verbose output
pytest tests/test_audio_engine.py::TestBinauralGeneration  # Specific test
```

### Writing Tests

Create test file in `tests/` directory:

```python
import pytest
import numpy as np
from binaural_presets import generate_binaural_segment

class TestBinauralGeneration:
    def test_output_shape(self):
        """Test that output has correct shape."""
        seg = generate_binaural_segment(100, 8, 5)
        assert seg.ndim == 2
        assert seg.shape[1] == 2  # Stereo

    def test_volume_constraint(self):
        """Test that volume parameter is respected."""
        seg = generate_binaural_segment(100, 8, 1, volume=0.3)
        assert np.max(np.abs(seg)) <= 0.3

    @pytest.mark.parametrize("beat_hz", [0.5, 1, 5, 13, 15])
    def test_valid_beat_frequencies(self, beat_hz):
        """Test valid beat frequencies don't raise."""
        seg = generate_binaural_segment(100, beat_hz, 1)
        assert seg.shape[0] > 0

    def test_invalid_beat_raises_error(self):
        """Test that invalid beat frequencies raise ValueError."""
        with pytest.raises(ValueError):
            generate_binaural_segment(100, 20, 1)  # 20 Hz > MAX_BEAT
```

### Test Coverage Goal
- Target **80%+ coverage** for `audio/` and `export.py` modules
- Test edge cases and parameter validation
- See **DESIGN.md §4** for comprehensive test plan

---

## Commit Message Format

Use **conventional commits** format:

```
<type>: <brief description>

<optional longer explanation>
```

### Types
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code reorganization (no behavior change)
- `test:` - Adding/updating tests
- `chore:` - Build, CI, dependencies

### Examples
```
feat: add pink noise background layer option

fix: prevent fade click artifacts on sub-second segments

docs: add custom preset creation guide in docs/authoring.md

refactor: extract fade envelope logic to audio/effects.py

test: add envelope symmetry test for binaural generation

chore: update scipy requirement to >=1.11
```

### Rules
- Keep first line under 72 characters
- Use imperative mood ("add" not "adds")
- Reference issues/sections: `fix: issue #12`, `relates to DESIGN.md §3`

---

## Pre-commit Hooks

Pre-commit hooks automatically run before each commit:

```bash
# Install hooks (one-time)
pre-commit install

# Manually run all hooks
pre-commit run --all-files

# Update hooks
pre-commit autoupdate
```

Hooks will:
- Format code with Black
- Sort imports with isort
- Check with Flake8
- Trim whitespace
- Check for merge conflicts

If a hook fails, it will block the commit and show errors.

---

## Pull Request Process

### Before Creating PR
- [ ] Code follows style guide: `make format && make lint`
- [ ] Tests pass: `make test`
- [ ] No new warnings or errors
- [ ] Docstrings added to new functions
- [ ] CHANGELOG.md updated (if feature)

### PR Description Template

```markdown
## Description
Brief explanation of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Testing Performed
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] No regressions observed

## Architecture Impact
- Does this align with DESIGN.md phases? (Yes/No)
- Does this change module boundaries? (Yes/No)
- Related sections: DESIGN.md §X

## Checklist
- [ ] Code formatted: `make format`
- [ ] Tests passing: `make test`
- [ ] Linting passes: `make lint`
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
```

---

## Review Checklist (For Web Claude)

- [ ] Code follows style guide
- [ ] Tests are adequate and pass
- [ ] Docstrings present for new functions
- [ ] No breaking changes or they're documented
- [ ] Aligns with DESIGN.md roadmap
- [ ] CHANGELOG.md updated appropriately
- [ ] No secrets or sensitive data exposed
- [ ] Performance concerns addressed (if applicable)

---

## Asking for Help

### Questions?
1. Check **CLAUDE.md** (Q&A section)
2. Review **DESIGN.md** (architecture decisions)
3. Ask in GitHub Discussions (if available)
4. Comment on the PR itself

### Getting Stuck?
1. Push your current work to a branch (don't force push)
2. Create a PR with `[WIP]` prefix
3. Describe the blocker
4. Tag web Claude for input

---

## Resources

- **CLAUDE.md** - Project context for Claude Code
- **DESIGN.md** - Architecture, refactoring roadmap, test plan
- **WORKFLOW_IMPROVEMENTS.md** - Development standards and improvements
- **CHANGELOG.md** - Release history and planned features
- **docs/** - Presets, protocols, research background

---

## Questions or Suggestions?

This workflow is a living document. If you have suggestions to improve it:
1. Create an issue on GitHub
2. Start a discussion in GitHub Discussions
3. Comment in a PR

Thanks for contributing to PhiWave!
