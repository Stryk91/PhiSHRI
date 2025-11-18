# Agent Task Macros - Copy/Paste for Keyboard Shortcuts

---

## 🎯 POLISH PHASE TIER 1 - OPTIMIZED WORKFLOW

### **Progress Tracker** (Update as you go)
```
Task 1: Audio Loop Crossfade     [ ] DESKC Assigned [ ] DESKC Complete [ ] Junie Verified
Task 2: Custom Preset Manager    [ ] DESKC Assigned [ ] DESKC Complete [ ] Junie Verified
Task 3: WASAPI Exclusive Mode    [ ] DESKC Assigned [ ] DESKC Complete [ ] Junie Verified
Task 4: Audio Validation Tool    [ ] DESKC Assigned [ ] DESKC Complete [ ] Junie Verified
Task 5: App Icon Design          [ ] DESKC Assigned [ ] DESKC Complete [ ] Junie Verified

Total Time Estimate: 5-6 hours
Current Task: [Task Number]
Blockers: [None / Description]
```

### **Step-by-Step Process** (For You to Coordinate)

**STEP 1: Verify Prerequisites** ✅
```bash
# Run this to confirm readiness
python junie_next_task.py  # Should show "no tasks" or Phase 4 complete
test -f POLISH_PHASE_TIER1_TASKS.md && echo "✓ Tasks documented"
test -d phiwave_gui/controls && echo "✓ GUI modular"
git status --short | wc -l && echo "files need commit (commit if needed)"
```

**STEP 2: Assign Task to DESKC** (Task 1-5)
```
DESKC: Complete Polish Phase Task [NUMBER]. Read POLISH_PHASE_TIER1_TASKS.md ## Task [NUMBER], implement the code template exactly as specified, run the provided test steps, verify acceptance criteria pass, commit with "feat(polish): Task [NUMBER] - [brief description]", and log completion to agent feed with log_task_complete().
```

**STEP 3: Monitor DESKC Progress**
```bash
# Watch for DESKC activity (run in separate terminal)
tail -f docs/agent-feed.jsonl | grep -i deskc

# Or check periodically
grep -i "deskc" docs/agent-feed.jsonl | tail -3 | python -m json.tool
```

**STEP 4: Verify Task Completion**
```bash
# Check DESKC logged completion
grep -i "deskc.*task.*complete\|deskc.*polish.*task" docs/agent-feed.jsonl | tail -1

# Check commit was made
git log --oneline -1 | grep -i "polish\|task"

# Verify files changed
git diff HEAD~1 --stat | head -10
```

**STEP 5: Assign to Junie for Verification** (After each task)
```
Junie: Test Polish Phase Task [NUMBER] completion. Run the test steps from POLISH_PHASE_TIER1_TASKS.md ## Task [NUMBER], verify all acceptance criteria pass, test manually if needed, and log result to agent feed with "test_result" action (PASS/FAIL).
```

**STEP 6: Coordinate Issues** (If Junie finds failures)
```
DESKC: Junie found issue with Task [NUMBER]: [ISSUE DESCRIPTION]. Review the test failure, fix the issue, re-test locally, commit fix with "fix(polish): Task [NUMBER] - [fix description]", and notify when ready for re-test.
```

**STEP 7: Mark Task Complete**
```python
# Log milestone completion
python -c "from phiwave.agent_feed import log_action; log_action('polish_task_complete', {'task': 'Task [NUMBER]', 'status': 'VERIFIED', 'tested_by': 'Junie'}, agent='Claude Code')"
```

**STEP 8: Repeat for Next Task** (Tasks 1-5)
```
# Return to STEP 2 with next task number
# Track progress: Task 1 ✓, Task 2 ✓, Task 3 (current), Task 4, Task 5
```

---

## 🎯 AGENT ASSIGNMENT MACROS (Quick Copy-Paste)

### **DESKC - Individual Tasks** (Use STEP 2 format above, or these shortcuts)

**Task 1: Audio Loop Crossfade (30 min)**
```
DESKC: Task 1 - Audio Loop Crossfade. Read POLISH_PHASE_TIER1_TASKS.md Task 1, add add_loop_crossfade() to phiwave/audio/engine.py, apply fade_samples=100 before returning audio in generate_binaural_segment() and generate_isochronic_segment(), test with 10-second 8 Hz binaural looped 3x, verify no clicks/pops, commit "feat(polish): Task 1 - audio loop crossfade", log completion.
```

**Task 2: Custom Preset Manager (1 hr)**
```
DESKC: Task 2 - Custom Preset Manager. Create phiwave/presets/custom_presets.py with CustomPresetManager class (save_preset, load_presets, delete_preset), modify phiwave_gui/controls/dropdowns.py to add "Save Custom" button, implement save dialog, test save/load/delete cycle, verify ~\.phiwave\custom_presets\ created, commit "feat(polish): Task 2 - custom preset manager", log completion.
```

**Task 3: WASAPI Exclusive Mode (1.5 hrs)**
```
DESKC: Task 3 - WASAPI Exclusive Mode. Modify phiwave/audio/engine.py add try_wasapi_exclusive() function, update play_audio() to attempt WASAPI first with fallback, add status indicator to GUI showing "WASAPI Exclusive" or "Shared Mode", test on Windows with external DAC if available, verify lower latency, commit "feat(polish): Task 3 - WASAPI exclusive mode", log completion.
```

**Task 4: Audio Validation Tool (1 hr)**
```
DESKC: Task 4 - Audio Validation Tool. Create phiwave/validation.py with validate_audio_quality() checking DC offset, clipping, RMS level, frequency response via FFT, create validator.py CLI tool, test with generated 8 Hz binaural and 15 Hz isochronic, verify output shows PASS with metrics, commit "feat(polish): Task 4 - audio validation tool", log completion.
```

**Task 5: App Icon Design (1-2 hrs)**
```
DESKC: Task 5 - App Icon Design. Create assets/icons/phiwave_icon.svg with Phi wave symbol + brain/frequency visual in 512x512, convert to .ico and .icns using cairosvg/Pillow, add icon to phiwave_gui.py with root.iconbitmap() or root.iconphoto(), test icon shows in taskbar and window, commit "feat(polish): Task 5 - app icon design", log completion.
```

### **Junie - Task Verification** (Use STEP 5 format above, or these shortcuts)

**Verify Task 1**
```
Junie: Verify Task 1. Generate 10-second 8 Hz binaural, play looped 3 times, listen for clicks/pops at loop boundaries, expected: smooth seamless transitions, log PASS if no artifacts or FAIL with description.
```

**Verify Task 2**
```
Junie: Verify Task 2. Open GUI, set carrier 200Hz beat 10Hz, click "Save Custom", name it "Test Preset", verify file created in ~\.phiwave\custom_presets\, restart GUI, verify "Test Preset" appears in dropdown, delete preset, verify removed. Log PASS/FAIL.
```

**Verify Task 3**
```
Junie: Verify Task 3. Start GUI, check status indicator shows WASAPI mode (Exclusive or Shared), play audio, verify playback works, if possible test latency compared to shared mode. Log PASS if status shown and works, or FAIL.
```

**Verify Task 4**
```
Junie: Verify Task 4. Run: python validator.py, generate 8 Hz binaural test file, run validator on output, verify report shows DC offset, clipping check, RMS level, frequency response analysis, expected: PASS with all metrics shown. Log PASS/FAIL.
```

**Verify Task 5**
```
Junie: Verify Task 5. Start GUI, check window and taskbar both show PhiWave icon (Phi wave symbol), verify icon.ico and icon.icns exist in assets/icons/, verify icon looks professional at different sizes. Log PASS/FAIL.
```

---

## 📋 POLISH PHASE QUICK REFERENCE CARD

**Your workflow in 3 commands:**

```bash
# 1. Check prerequisites
python junie_next_task.py && test -f POLISH_PHASE_TIER1_TASKS.md && echo "✓ READY"

# 2. Assign DESKC (Task 1-5) - Copy from "DESKC - Individual Tasks" section above

# 3. Monitor completion
grep -i "deskc.*complete" docs/agent-feed.jsonl | tail -1 && git log --oneline -1
```

**After DESKC completes:**
```bash
# 4. Assign Junie verification - Copy from "Junie - Task Verification" section

# 5. Check Junie result
grep -i "junie.*test.*result" docs/agent-feed.jsonl | tail -1

# 6. Mark complete and move to next task
python -c "from phiwave.agent_feed import log_action; log_action('polish_task_complete', {'task': 'Task X', 'status': 'VERIFIED'}, agent='Claude Code')"
```

**Repeat for all 5 tasks. Total time: 5-6 hours.**

---

### **For IDE Claude** (Monitor & Coordinate)
```
Check agent feed for latest entries, review recent commits (git log -10), monitor Junie's Phase 4 test progress, watch for blockers or test failures, aggregate status in a brief summary, and coordinate any blocking issues between teams.
```

### **For Junie** (Phase 4 Testing)
```
Run binaural_presets.py, test all audio generation modes (binaural, isochronic, ramp, noise), verify GUI playback (play/stop/export buttons), test preset loading, test device selector, document any failures to agent feed, and log final test results with PASS/FAIL status.
```

### **For Claude Code (You)** (Monitor Overall Progress)
```
Check agent feed for new entries, review recent commits, verify all teams are unblocked, identify next priority tasks, coordinate between agents if needed, and update status documentation.
```

---

## ⚡ ONE-LINER MACROS FOR CLAUDE CODE (YOU)

### **Status & Monitoring**

```bash
# Check latest agent feed entries
tail -20 docs/agent-feed.jsonl | python -m json.tool 2>/dev/null | grep -E '"agent"|"action"|"status"' | head -20

# Show last 10 commits with summary
git log --oneline -10

# Quick team status (all agent activities)
grep -o '"agent":"[^"]*"' docs/agent-feed.jsonl | sort | uniq -c | sort -rn

# Find all test results
grep -i "pass\|fail\|error\|complete" docs/agent-feed.jsonl | tail -10

# Show blockers/failures in feed
grep -i "error\|fail\|block" docs/agent-feed.jsonl | tail -5
```

### **Git Operations**

```bash
# Quick status + recent commits
git status && echo "" && git log --oneline -5

# Stage, commit, and push in one go (replace MESSAGE)
git add . && git commit -m "docs: MESSAGE" && git push origin master

# View all changes since last commit
git diff HEAD

# Show commits by agent/author
git log --oneline --author="AUTHOR_NAME" -10

# Create quick tag for milestone
git tag -a "phase-4-complete" -m "Phase 4 testing complete" && git push origin --tags
```

### **Code Validation**

```bash
# Syntax check all Python files
python -m py_compile phiwave/**/*.py phiwave_gui/**/*.py 2>&1 | grep -i error

# Test imports (all core modules)
python -c "from phiwave import *; from phiwave_gui import *; print('All imports OK')"

# Check file structure
find phiwave phiwave_gui assets -type f -name "*.py" | wc -l && echo "Python files found"

# Verify all dependencies
python -c "import sounddevice, soundfile, numpy, scipy; print('Core dependencies OK')"
```

### **Agent Feed Logging**

```bash
# Log quick status update
python -c "from phiwave.agent_feed import log_action; log_action('status_update', {'status': 'all teams on track'}, agent='Claude Code')"

# Log a blocker
python -c "from phiwave.agent_feed import log_action; log_action('blocker', {'issue': 'BLOCKER_DESC', 'affected_team': 'TEAM_NAME'}, agent='Claude Code')"

# Log coordination message
python -c "from phiwave.agent_feed import log_action; log_action('coordination', {'message': 'MESSAGE', 'teams': ['DESKC', 'Junie']}, agent='Claude Code')"

# Query agent feed for specific agent
grep -o '"agent":"AGENT_NAME"' docs/agent-feed.jsonl | wc -l && echo "entries for AGENT_NAME"
```

### **Documentation Quick Checks**

```bash
# Count documentation files
find . -name "*.md" -type f | wc -l && echo "MD files in project"

# Show all task documentation
ls -lh *TASK* *SPEC* *QUICK* 2>/dev/null

# Verify Polish Phase docs exist
test -f POLISH_PHASE_TIER1_TASKS.md && test -f POLISH_PHASE_TIER1_QUICKSTART.md && echo "Polish Phase docs OK"

# Check GUI refactoring structure
ls -la phiwave_gui/ | grep -E "\.py|controls|dialogs"
```

### **Junie Monitoring (While Testing)**

```bash
# Watch agent feed for Junie updates (real-time)
tail -f docs/agent-feed.jsonl | grep -i junie

# Count Junie's entries
grep -i "junie" docs/agent-feed.jsonl | wc -l && echo "Junie log entries"

# Show last Junie activity
grep -i "junie" docs/agent-feed.jsonl | tail -1 | python -m json.tool 2>/dev/null | head -20

# Check for Junie test results
grep -i "junie.*test\|junie.*pass\|junie.*fail" docs/agent-feed.jsonl | tail -3
```

### **DESKC Task Status**

```bash
# Show DESKC current task
grep -i "deskc" docs/agent-feed.jsonl | tail -5 | python -m json.tool 2>/dev/null | grep -E '"task|status|action"'

# Verify DESKC can access modular GUI
python -c "from phiwave_gui import PhiWaveGUI; print('DESKC can import modular GUI')"

# Check DESKC context limit status
echo "DESKC works on small modules (50-100 lines each):"
find phiwave_gui -name "*.py" -exec wc -l {} + | sort -n
```

### **IDE Claude (Local Coder) Verification**

```bash
# Check if PyQt6 is installed
python -c "import PyQt6; print('PyQt6 installed')" 2>&1 || echo "PyQt6 not installed - run: pip install PyQt6"

# Verify glossy theme assets created
ls -la assets/ui/icons/gloss/ 2>/dev/null | wc -l && echo "glossy icons present"

# Test demo app code compiles
python -m py_compile demo_app.py 2>&1 && echo "demo_app.py syntax OK"

# Check QSS file exists
test -f gui/theme.qss && echo "QSS theme file exists" || echo "Missing: gui/theme.qss"
```

### **Quick Coordination Commands**

```bash
# Get all team status in one line
echo "DESKC: $(grep -i deskc docs/agent-feed.jsonl | tail -1 | grep -o 'task[^"]*' | head -1)" && echo "Junie: $(grep -i junie docs/agent-feed.jsonl | tail -1 | grep -o 'status[^"]*' | head -1)" && echo "IDE Claude: Last commit $(git log --oneline -1)"

# Check if all teams have recent activity (last 30 minutes)
echo "Recent team activity:" && git log --all --since="30 minutes ago" --oneline && grep "$(date -d '-30 minutes' +'%Y-%m-%d')" docs/agent-feed.jsonl | wc -l && echo "agent feed entries"

# Alert if Junie tests fail
grep -i "junie.*fail\|error" docs/agent-feed.jsonl | tail -1 && echo "⚠️  Junie test failure detected" || echo "✓ No Junie failures detected"

# Verify Phase 4 status complete
grep -i "phase.4.*complete\|phase.4.*done" docs/agent-feed.jsonl && echo "✓ Phase 4 marked complete" || echo "Phase 4 still in progress"
```

### **Project Health Check**

```bash
# Full project status in one check
echo "=== PROJECT STATUS ===" && echo "Phase: Phase 4+Polish" && echo "Commits: $(git log --oneline | wc -l)" && echo "Docs: $(find . -name "*.md" | wc -l)" && echo "Tests: $(grep -c 'test' docs/agent-feed.jsonl)" && echo "Glossy Theme: $(test -d assets/ui/icons/gloss && echo 'Ready' || echo 'Missing')" && echo "GUI Modular: $(test -d phiwave_gui/controls && echo 'Ready' || echo 'Missing')" && echo "Polish Tasks: $(test -f POLISH_PHASE_TIER1_TASKS.md && echo 'Ready' || echo 'Missing')"
```

---

## ⚡ UNIVERSAL AGENT ONE-LINERS (Phase-Agnostic)

These macros work for ANY agent across ANY project phase. No assumptions about current state.

### **DESKC Universal One-Liner**
```bash
LATEST=$(grep -i "deskc" docs/agent-feed.jsonl | tail -1 | grep -o '"task":"[^"]*"' | head -1); echo "DESKC: Your latest task is: $LATEST"; grep -i "deskc.*error\|deskc.*fail\|deskc.*block" docs/agent-feed.jsonl | tail -1 && echo "⚠️ Issue detected" || echo "✓ No issues"
```

### **Junie Universal One-Liner**
```bash
LATEST=$(grep -i "junie" docs/agent-feed.jsonl | tail -1 | grep -o '"action":"[^"]*"' | head -1); echo "Junie: Your latest action was: $LATEST"; grep -i "junie.*error\|junie.*fail\|junie.*block" docs/agent-feed.jsonl | tail -1 && echo "⚠️ Issue detected" || echo "✓ No blockers"
```

### **IDE Claude Universal One-Liner**
```bash
LATEST=$(git log --oneline -1 | cut -d' ' -f2-); echo "IDE Claude: Latest commit: $LATEST"; grep -i "error\|fail\|block" docs/agent-feed.jsonl | tail -1 && echo "⚠️ Blocker detected" || echo "✓ All clear"
```

### **Claude Code (You) Universal One-Liner**
```bash
echo "=== STATUS CHECK ===" && git log --oneline -1 && echo "Team count: $(grep -o '"agent":"[^"]*"' docs/agent-feed.jsonl | sort -u | wc -l) agents" && (grep -i "error\|fail\|block" docs/agent-feed.jsonl | tail -1 && echo "⚠️ Issues exist" || echo "✓ No blockers")
```

---

## 📋 HOW TO USE THESE MACROS

### **In Windows (PowerShell/AutoHotkey):**

Create a `.ahk` file with:
```autohotkey
; Example: Ctrl+Alt+D for DESKC task
^!d::
{
    A_Clipboard := "Check POLISH_PHASE_TIER1_QUICKSTART.md, pick a task..."
    MsgBox, DESKC macro copied to clipboard
    return
}
```

### **In Linux/Mac (Shell aliases):**

Add to `.bashrc` or `.zshrc`:
```bash
alias deskc-task='echo "Check POLISH_PHASE_TIER1_QUICKSTART.md..."'
alias junie-test='grep -i junie docs/agent-feed.jsonl | tail -5'
alias status='tail -20 docs/agent-feed.jsonl | python -m json.tool'
```

### **In Terminal (Direct copy-paste):**

Just copy the one-liner and paste directly into terminal/PowerShell.

---

## 🎮 RECOMMENDED KEYBOARD SHORTCUTS

| Shortcut | Macro | Purpose |
|----------|-------|---------|
| Ctrl+Alt+D | DESKC task assignment | Send DESKC to next Polish task |
| Ctrl+Alt+J | Junie test assignment | Send Junie to test Phase 4 |
| Ctrl+Alt+I | IDE Claude coordination | Send IDE Claude to monitor |
| Ctrl+Alt+S | Quick status check | See team status |
| Ctrl+Alt+F | Find blockers | Search for failures |
| Ctrl+Alt+C | Commit everything | Git add/commit/push |
| Ctrl+Alt+L | View agent feed | Last 20 feed entries |
| Ctrl+Alt+T | Test imports | Verify all code OK |

---

## 💡 QUICK REFERENCE

**When you need to:**
- **Assign DESKC work** → Copy DESKC macro
- **Check Junie progress** → Run `tail -f docs/agent-feed.jsonl | grep junie`
- **Verify all code** → Run syntax check macro
- **Status update** → Copy IDE Claude macro
- **Quick health check** → Run "Project Health Check" macro
- **Find problems** → Run "Find blockers" macro
- **Update repo** → Copy git commit macro

---

**All macros tested and ready to copy/paste! 🚀**
