# PhiWave Agent Forward Plans

**Planning Date:** 2025-10-26
**Planner:** TERMC (Terminal Claude)
**Context:** Post-Phase 4, Polish Phase Tier 1 (20% complete)

---

## Agent Roster

- **TERMC** (me) - Terminal Claude Code (CLI)
- **DESKC** - Desktop Claude (web interface)
- **IDEC** - PyCharm IDE Claude integration
- **Junie** - PyCharm Assistant (GPT-5)
- **analyzer** - Code analysis agent (Python script)

See `AGENT_ROSTER.md` for complete agent documentation.

---

## TERMC (Terminal Claude - Me)

### Role & Capabilities
**Primary**: Terminal operations, git, testing, deployment, coordination
**Platform**: Claude Code CLI
**Access**: Full filesystem, bash, git, MCP tools

### Current Assignments

#### 1. Project Coordination & Planning ⭐⭐⭐
**Status**: ✅ ACTIVE
**Timeline**: Ongoing

Tasks:
- [x] Analyze project status → `PROJECT_STATUS_ANALYSIS.md`
- [x] Create agent forward plans → `AGENT_FORWARD_PLANS.md`
- [ ] Monitor agent hub for status updates
- [ ] Coordinate Polish Phase completion
- [ ] Track progress via agent feed

**How to Execute**:
```bash
# Monitor agent hub
mcp__phiwave-agent-hub__get_messages(limit=20)
mcp__phiwave-agent-hub__get_agent_status()

# Post coordination messages
mcp__phiwave-agent-hub__post_message(
    sender="TERMC",
    content="Status check: Task N progress?",
    msg_type="command"
)
```

#### 2. Git & Version Control ⭐⭐⭐
**Status**: ⚠️ NEEDS ATTENTION
**Timeline**: Immediate

Tasks:
- [ ] Commit untracked files (MCP system, docs)
- [ ] Create .gitignore for temporary files
- [ ] Clean up inconsistent commit messages
- [ ] Tag v0.2.0 after Polish Phase
- [ ] Push all changes to remote

**How to Execute**:
```bash
# Stage and commit MCP system
git add agent_hub.py agent_hub_mcp.py mcp_agent_hub.py
git add *AGENT*.md *MCP*.md START_HERE_AGENTS.md
git commit -m "feat: multi-agent MCP hub system

- TERMC, DESKC, IDEC, Junie, analyzer agents
- SQLite database (agent_hub.db)
- FastMCP server with 8 tools
- Complete documentation suite"

# Stage and commit analysis docs
git add PROJECT_STATUS_ANALYSIS.md AGENT_FORWARD_PLANS.md
git commit -m "docs: comprehensive project analysis and agent plans"

# Push to remote
git push origin main
```

#### 3. Testing Infrastructure ⭐⭐⭐
**Status**: 🔴 CRITICAL GAP
**Timeline**: After Polish Phase (3-4 hours)

Tasks:
- [ ] Create `tests/` directory structure
- [ ] Write audio engine unit tests
- [ ] Write export integration tests
- [ ] Write preset loader tests
- [ ] Configure pytest.ini
- [ ] Add GitHub Actions CI workflow

**How to Execute**:
```bash
# Create test structure
mkdir -p tests/unit tests/integration tests/fixtures

# Write first test
cat > tests/unit/test_audio_engine.py << 'EOF'
"""Unit tests for audio engine"""
import pytest
import numpy as np
from phiwave.audio.engine import generate_binaural_segment

def test_generate_binaural_basic():
    """Test basic binaural generation"""
    audio = generate_binaural_segment(
        base_freq=100.0,
        beat_freq=8.0,
        duration=1.0,
        volume=0.5
    )

    assert audio.shape[1] == 2  # Stereo
    assert audio.dtype == np.float32
    assert np.max(np.abs(audio)) <= 0.5  # Volume constraint
EOF

# Run tests
pytest tests/ -v
```

#### 4. Documentation Updates ⭐⭐
**Status**: ⏳ PENDING
**Timeline**: After Polish Phase (1-2 hours)

Tasks:
- [ ] Update README.md with Phase 4 features
- [ ] Update CLAUDE.md with current state
- [ ] Update CHANGELOG.md with recent changes
- [ ] Create USER_GUIDE.md for end users
- [ ] Add screenshots to docs/

**How to Execute**:
```bash
# Update README
# (Edit README.md to add GUI, export, presets sections)

# Update CHANGELOG
# Add entries for Phase 4 and Polish Phase

# Create user guide
cat > USER_GUIDE.md << 'EOF'
# PhiWave User Guide

## Quick Start
1. Download PhiWave
2. Install: `pip install -r requirements.txt`
3. Run: `python phiwave_gui.py`
...
EOF

# Commit docs
git add README.md CLAUDE.md CHANGELOG.md USER_GUIDE.md
git commit -m "docs: update for Phase 4 and Polish Phase"
```

#### 5. Deployment & Packaging ⭐
**Status**: 📋 FUTURE
**Timeline**: After Polish Phase Tier 2 (2-3 hours)

Tasks:
- [ ] Create PyInstaller spec file
- [ ] Build standalone .exe
- [ ] Test on clean Windows system
- [ ] Create installer with Inno Setup
- [ ] Publish to GitHub Releases

**How to Execute**:
```bash
# Install PyInstaller
pip install pyinstaller

# Create spec file
pyi-makespec --windowed --onefile phiwave_gui.py

# Build
pyinstaller phiwave_gui.spec

# Test
dist/phiwave_gui.exe
```

---

## DESKC (Desktop Claude) - REMOVED FROM TASKFORCE

### Status
**INACTIVE** - All tasks reassigned to IDEC on 2025-10-26

All DESKC assignments have been transferred to IDEC.
See IDEC section below for current task assignments.

---

## IDEC (PyCharm IDE Claude) - POLISH PHASE LEAD

### Role & Capabilities
**Primary**: IDE-assisted development, Polish Phase implementation
**Platform**: PyCharm IDE integration
**Access**: Project context, code navigation, refactoring tools

### Status Update
**REASSIGNED** - Now leads all Polish Phase Tier 1 tasks (formerly DESKC's role)

### Current Assignments

#### 1. Complete Polish Phase Tasks ⭐⭐⭐
**Status**: 🔴 CRITICAL PATH - PRIMARY RESPONSIBILITY
**Timeline**: Immediate (3.5-4.5 hours)

**Task 2: Custom Preset Manager** (1 hour)
- [ ] Create `phiwave/presets/custom_presets.py`
- [ ] Implement `CustomPresetManager` class
- [ ] Add GUI "Save Custom" button
- [ ] Add preset delete functionality
- [ ] Test save/load/delete workflow

**Task 3: WASAPI Exclusive Mode** (1.5 hours)
- [ ] Add `try_wasapi_exclusive()` to `phiwave/audio/player.py`
- [ ] Implement fallback to shared mode
- [ ] Add GUI status indicator
- [ ] Test exclusive mode vs shared mode
- [ ] Verify latency improvement

**Task 5: App Icon Design** (1-2 hours)
- [ ] Design SVG icon (Phi symbol + wave)
- [ ] Create conversion script (SVG → .ico/.png)
- [ ] Integrate icon into GUI
- [ ] Test icon display in taskbar/window
- [ ] Verify icon clarity at 16x16

**How to Execute**:
See `docs/POLISH_PHASE_TIER1_TASKS.md` for detailed specifications.

Post progress to agent hub:
```python
from agent_hub_mcp import post_message

post_message(
    "IDEC",
    "Task 2 complete: CustomPresetManager working, 3 test presets saved",
    "status"
)
```

**Priority**: Start with Task 2 immediately

#### 2. Code Refactoring ⭐
**Status**: ⏳ SECONDARY (after Polish Phase)
**Timeline**: As needed

Tasks:
- [ ] Rename inconsistent functions (camelCase → snake_case)
- [ ] Extract magic numbers to constants
- [ ] Improve type hint coverage
- [ ] Add missing docstrings
- [ ] Simplify complex functions

#### 3. Code Navigation & Debugging Support ⭐
**Status**: 🔄 AS NEEDED
**Timeline**: Opportunistic during Polish Phase

Tasks:
- [ ] Help locate functions for other agents
- [ ] Provide code context when requested
- [ ] Debug issues as they arise
- [ ] Assist with integration testing

---

## Junie (PyCharm Assistant - GPT-5)

### Role & Capabilities
**Primary**: Advanced problem solving, architecture, code review
**Platform**: PyCharm AI Assistant
**Access**: GPT-5 reasoning, code generation, architectural insights

### Current Assignments

#### 1. Audio Validation Task Support ⭐⭐⭐
**Status**: ⏳ PARTIAL
**Timeline**: Immediate (45 minutes)

Tasks:
- [ ] Review existing `phiwave/validation.py`
- [ ] Complete CLI tool `validator.py`
- [ ] Test validation on sample files
- [ ] Verify FFT frequency detection
- [ ] Document validation thresholds

**How to Execute**:
```python
# Review validation.py
# Create validator.py CLI tool (see POLISH_PHASE_TIER1_TASKS.md)
# Test:
python validator.py test_audio.wav

# Post results
from agent_hub_mcp import post_message
post_message("Junie", "Validation tool complete, all checks passing", "status")
```

#### 2. Architecture Review ⭐⭐
**Status**: 🔄 ONGOING
**Timeline**: As needed

Tasks:
- [ ] Review Polish Phase implementations
- [ ] Suggest architectural improvements
- [ ] Identify technical debt
- [ ] Propose refactoring strategies
- [ ] Document design patterns

**How to Execute**:
- Monitor agent hub for completed tasks
- Review code changes
- Post architectural feedback:
```python
post_message(
    "Junie",
    "Task 2 review: CustomPresetManager looks good, suggest adding preset versioning for future compatibility",
    "response"
)
```

#### 3. Advanced Problem Solving ⭐⭐⭐
**Status**: 🔄 SUPPORT ROLE
**Timeline**: As needed

Tasks:
- [ ] Solve complex implementation challenges
- [ ] Debug difficult issues
- [ ] Optimize performance bottlenecks
- [ ] Design new features
- [ ] Review security concerns

**Expertise Areas**:
- Complex algorithms
- Performance optimization
- Design patterns
- Best practices
- GPT-5 advanced reasoning

---

## analyzer (Code Analysis Agent)

### Role & Capabilities
**Primary**: Automated code quality checks, bug detection
**Platform**: Python script (automated)
**Access**: Static analysis tools, pattern matching

### Current Assignments

#### 1. Code Quality Analysis ⭐⭐
**Status**: 🔄 ONGOING
**Timeline**: After each commit

Tasks:
- [ ] Run flake8 linter on new code
- [ ] Check type hint coverage
- [ ] Detect code smells
- [ ] Find unused imports
- [ ] Identify complexity hotspots

**How to Execute**:
```bash
# Automated via analyzer_agent.py
# Monitors agent hub for commit notifications
# Runs analysis and posts results

# Manual run:
flake8 phiwave/ phiwave_gui/ --max-line-length=100
mypy phiwave/ --ignore-missing-imports
```

Post results:
```python
from agent_hub_mcp import post_message

post_message(
    "analyzer",
    "Code analysis complete: 2 style issues, 0 type errors, complexity OK",
    "response"
)
```

#### 2. Bug Detection ⭐⭐
**Status**: 🔄 ONGOING
**Timeline**: Continuous

Tasks:
- [ ] Monitor for error patterns
- [ ] Detect potential bugs
- [ ] Flag unsafe operations
- [ ] Identify edge cases
- [ ] Suggest defensive programming

**Detection Patterns**:
- Division by zero risks
- Null/None dereferences
- Array index out of bounds
- File operation errors
- Threading race conditions

#### 3. Performance Profiling ⭐
**Status**: 📋 FUTURE
**Timeline**: After Polish Phase

Tasks:
- [ ] Profile audio generation
- [ ] Identify bottlenecks
- [ ] Suggest optimizations
- [ ] Benchmark improvements
- [ ] Report performance metrics

---

## Coordination Matrix

### Who Does What

| Task | Primary | Support | Review |
|------|---------|---------|--------|
| **Polish Task 2: Custom Presets** | DESKC | IDEC | Junie |
| **Polish Task 3: WASAPI** | DESKC | TERMC | analyzer |
| **Polish Task 4: Validation** | Junie | TERMC | analyzer |
| **Polish Task 5: Icon** | DESKC | - | TERMC |
| **Git Management** | TERMC | - | - |
| **Testing** | TERMC | Junie | analyzer |
| **Documentation** | TERMC | DESKC | - |
| **Code Review** | Junie | analyzer | - |
| **Refactoring** | IDEC | Junie | analyzer |

### Communication Protocol

**Daily Status Updates**:
```python
# Each agent posts daily summary
post_message(
    "AgentName",
    "Daily summary: Task N at 60%, blocked on X, need Y from Z",
    "status"
)
```

**Task Completion**:
```python
post_message(
    "AgentName",
    "Task N COMPLETE: feature X implemented, tested, committed (hash: abc123)",
    "status"
)
```

**Help Requests**:
```python
post_message(
    "AgentName",
    "Blocked on Task N: issue with X, tried Y, need help from Z",
    "command"
)
```

---

## Timeline & Milestones

### Week 1: Polish Phase Tier 1
**Duration**: 4-5 hours
**Target**: Complete all 5 tasks

| Day | Milestone | Agent |
|-----|-----------|-------|
| Day 1 | Task 2: Custom Presets | DESKC |
| Day 1-2 | Task 3: WASAPI Exclusive | DESKC |
| Day 2 | Task 4: Validation CLI | Junie |
| Day 2-3 | Task 5: App Icon | DESKC |
| Day 3 | Integration testing | TERMC |

### Week 1-2: Documentation & Testing
**Duration**: 4-5 hours
**Target**: Tests + docs updated

| Day | Milestone | Agent |
|-----|-----------|-------|
| Day 4-5 | Write unit tests | TERMC |
| Day 5 | Update docs | TERMC |
| Day 5 | Code review | Junie |
| Day 5 | Quality checks | analyzer |

### Week 2: Polish Tier 2 (Optional)
**Duration**: 3-4 hours
**Target**: UX enhancements

| Day | Milestone | Agent |
|-----|-----------|-------|
| Day 6 | Quick Start auto | DESKC |
| Day 6 | Tooltips | DESKC |
| Day 7 | Demo video | DESKC |
| Day 7 | Split docs | TERMC |

### Week 3+: Packaging & Release
**Duration**: 5-6 hours
**Target**: Installer + distribution

| Day | Milestone | Agent |
|-----|-----------|-------|
| Day 8-9 | PyInstaller setup | TERMC |
| Day 9 | Build .exe | TERMC |
| Day 10 | Release prep | TERMC |
| Day 10 | GitHub Release | TERMC |

---

## Success Criteria

### Polish Phase Tier 1 Complete When:
- [x] Task 1: Audio crossfade ✅
- [ ] Task 2: Custom presets working
- [ ] Task 3: WASAPI exclusive with fallback
- [ ] Task 4: Validation CLI functional
- [ ] Task 5: App icon visible in GUI
- [ ] All tasks committed and pushed
- [ ] No regressions in existing features
- [ ] Integration testing passed

### Project Ready for Beta When:
- [ ] Polish Phase Tier 1 complete
- [ ] Automated tests written (80%+ coverage)
- [ ] Documentation updated
- [ ] No critical bugs
- [ ] Code review passed (Junie)
- [ ] Quality checks passed (analyzer)

### Project Ready for Release When:
- [ ] Beta criteria met
- [ ] Polish Phase Tier 2 complete
- [ ] User guide written
- [ ] Demo video created
- [ ] Installer built and tested
- [ ] GitHub Release published

---

## Agent Communication Examples

### Example 1: Task Progress Update
```python
# DESKC working on Task 2
post_message(
    "DESKC",
    "Task 2 (Custom Presets) at 80%: CustomPresetManager class done, testing save/load",
    "status"
)

# TERMC monitoring
messages = get_messages(limit=5)
# See DESKC's update, respond if needed
post_message("TERMC", "DESKC: Great progress! Let me know when ready for integration test", "response")
```

### Example 2: Help Request
```python
# Junie blocked on Task 4
post_message(
    "Junie",
    "Task 4 blocked: FFT not detecting beat frequency correctly. Need TERMC to test with known audio file",
    "command"
)

# TERMC responds
post_message(
    "TERMC",
    "Junie: Testing validation with 8Hz binaural... FFT detecting 100Hz and 108Hz (correct!). Check your FFT window size?",
    "response"
)
```

### Example 3: Code Review
```python
# DESKC completes task
post_message(
    "DESKC",
    "Task 3 COMPLETE: WASAPI exclusive mode working, commit 1a2b3c4. Ready for review",
    "status"
)

# Junie reviews
post_message(
    "Junie",
    "Task 3 review: Code looks good, tested on 3 devices. Suggest adding retry logic for device busy state",
    "response"
)
```

---

## Emergency Protocols

### If Agent Blocked
1. Post detailed help request to hub
2. Include: what you tried, error messages, context needed
3. Tag specific agent who can help
4. Set status to "blocked"
5. Work on different task while waiting

### If Critical Bug Found
1. Post immediately to hub with "CRITICAL" tag
2. Stop feature work, focus on bug
3. Coordinate with TERMC for testing
4. Junie leads investigation
5. analyzer checks for similar issues

### If Timeline Slipping
1. TERMC posts status check to all agents
2. Each agent reports current progress
3. Adjust task assignments if needed
4. Consider descoping Tier 2 if necessary
5. Focus on critical path (Tier 1 completion)

---

## Next Steps for Each Agent

### TERMC (Immediate)
1. Post this plan to agent hub
2. Commit documentation
3. Monitor hub for agent responses
4. Coordinate Polish Phase kickoff
5. Track progress

### DESKC (Immediate)
1. Read Polish Phase task specs
2. Start Task 2 (Custom Presets)
3. Post progress updates
4. Complete Task 2, move to Task 3
5. Continue through Task 5

### IDEC (As Needed)
1. Monitor hub for refactoring requests
2. Provide code navigation support
3. Help debug issues
4. Run code inspections
5. Apply quick fixes

### Junie (Immediate)
1. Review validation.py
2. Complete validator CLI (Task 4)
3. Test on sample audio
4. Review other agents' work
5. Provide architectural feedback

### analyzer (Continuous)
1. Monitor commits for quality issues
2. Run automated checks
3. Post analysis results
4. Flag potential bugs
5. Track technical debt

---

**Status**: ✅ PLANS COMPLETE
**Document**: AGENT_FORWARD_PLANS.md
**Next**: Post to agent hub and begin execution
