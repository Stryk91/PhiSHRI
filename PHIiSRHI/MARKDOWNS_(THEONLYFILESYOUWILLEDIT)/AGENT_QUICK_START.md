# Agent Quick Start Commands

**Date:** 2025-10-24
**Status:** Ready to Execute

---

## One-Line Commands to Start Tasks

### Junie - Phase 4 Final Testing & Sign-Off

```bash
cd E:\PythonProjects\PhiWave && python binaural_presets.py
```
**What to do:** Select option 18 (Continuous Ramp), enter test params, verify no error. Then run full test suite and complete QA report.

---

### DESKC - GUI Enhancements

```bash
cd E:\PythonProjects\PhiWave && python phiwave_gui.py
```
**What to do:** Test GUI locally, implement enhancements (based on phiwave_gui.py review), commit changes with `git commit -m "feat: GUI enhancement - [description]"`, log to agent feed.

---

### Claude Code - Monitor & Coordinate

```bash
cd E:\PythonProjects\PhiWave && tail -f docs/agent-feed.jsonl | grep -E "Junie|DESKC|error|fail|complete"
```
**What to do:** Monitor agent feed for status updates, watch for blockers, aggregate progress, coordinate teams.

---

### IDE Claude - Standby/Consultation

```bash
cd E:\PythonProjects\PhiWave && git log --oneline -10 && echo "Ready for questions"
```
**What to do:** Review latest commits, available for architecture questions, code review, or emergency fixes.

---

## Next Phase - Polish Phase Tier 1

### When Phase 4 Complete, Start Polish with:

**DESKC - Audio Crossfade Fix:**
```bash
cd E:\PythonProjects\PhiWave && python -c "from phiwave.audio import engine; help(engine)" && echo "Ready to implement crossfade"
```

**DESKC - Custom Presets:**
```bash
cd E:\PythonProjects\PhiWave && mkdir -p phiwave/presets/custom && echo "Custom presets dir ready"
```

**DESKC - WASAPI Exclusive Mode:**
```bash
cd E:\PythonProjects\PhiWave && python -c "import sounddevice as sd; print(f'Audio devices: {len(sd.query_devices())}'); print('WASAPI ready')"
```

**DESKC - Audio Validation:**
```bash
cd E:\PythonProjects\PhiWave && python -c "from scipy import signal; from scipy.fft import fft; print('FFT analysis ready')"
```

---

## Repository Commands

**Check Status:**
```bash
cd E:\PythonProjects\PhiWave && git status && git log --oneline -3
```

**Push Changes:**
```bash
cd E:\PythonProjects\PhiWave && git add . && git commit -m "YOUR MESSAGE" && git push origin master
```

**View Agent Feed:**
```bash
cd E:\PythonProjects\PhiWave && tail -20 docs/agent-feed.jsonl
```

---

## Phase 4 Complete When All These Are Done:

```bash
# Junie completes this:
cd E:\PythonProjects\PhiWave && python binaural_presets.py  # Select 18, verify PASS

# DESKC completes this:
cd E:\PythonProjects\PhiWave && python phiwave_gui.py  # Test GUI enhancements

# Log completion:
cd E:\PythonProjects\PhiWave && echo '{"timestamp":"'$(date -u +'%Y-%m-%dT%H:%M:%SZ')'","agent":"YOUR_AGENT","action":"phase_4_complete","details":{"status":"DONE"}}' >> docs/agent-feed.jsonl
```

---

**Ready to go! Execute your command and get to work! 🚀**

