# Mindstate Clone — GUI Concept Design

## Design Philosophy

**Efficiency = Quality / Time applied to UI:**
- **Quality** = User achieves goal (play/export session) without errors
- **Time** = Clicks + cognitive load to reach goal

**Target:** 3-click workflow for preset playback, 5-click for custom session export.

---

## 1. Information Architecture

### Mental Model
User's decision tree maps to visual hierarchy:

```
1. WHAT do I want? (Mode/Preset) → Top bar
   ↓
2. HOW do I tune it? (Parameters) → Middle section
   ↓
3. WHEN do I act? (Transport controls) → Bottom bar
```

**Analogy:** Mixing console layout — source selection (top), channel strip (middle), master section (bottom).

---

## 2. Layout Wireframe

### Main Window (600×500px)

```
┌─────────────────────────────────────────────────────────────┐
│ Mindstate Clone                                    [─][□][×]│
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ MODE SELECTOR                                           │ │
│ │ ⚫ Binaural    ⚪ Isochronic    ⚪ Layered (future)      │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                               │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ PRESET                                                  │ │
│ │ [BN Fib 8 - Golden Alpha ▾]                  [↻ Reset] │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                               │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ PARAMETERS                                              │ │
│ │                                                         │ │
│ │ Carrier Frequency    Beat Frequency      Volume        │ │
│ │ ┌──────┐ Hz          ┌──────┐ Hz         ┌──────┐     │ │
│ │ │ 100  │             │ 8.00 │            │ 0.25 │     │ │
│ │ └──────┘             └──────┘            └──────┘     │ │
│ │ [────●────] 60-125   [──●────] 0.5-15   [──●────]    │ │
│ │                                           0.0────1.0   │ │
│ │                                                         │ │
│ │ Duration (seconds)                                     │ │
│ │ ┌──────┐                                               │ │
│ │ │ 420  │  [▾ 7:00]  ← Minutes:Seconds display         │ │
│ │ └──────┘                                               │ │
│ │ [────────●────────] 60-1800                           │ │
│ │                                                         │ │
│ │ ┌───────────────────────────────────────────────────┐ │ │
│ │ │ ISO MODE ONLY (grayed when Binaural selected)    │ │ │
│ │ │ Pulse Sharpness      Off-Gain Floor              │ │ │
│ │ │ ┌──────┐             ┌──────┐                     │ │ │
│ │ │ │ 2.0  │             │ 0.00 │                     │ │ │
│ │ │ └──────┘             └──────┘                     │ │ │
│ │ │ [──●────] 1.0-6.0    [●─────] 0.0-0.3            │ │ │
│ │ └───────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                               │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ BACKGROUND NOISE (Experimental)                         │ │
│ │ [None ▾]  Mix Level: [●──────] 0% ← Disabled when None │ │
│ │ Options: None, White, Pink, Brown                       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                               │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ TRANSPORT                                               │ │
│ │ [▶ Play] [⏸ Pause] [⏹ Stop]          Elapsed: 00:00   │ │
│ │                                                         │ │
│ │ [💾 Export WAV...]  [🔊 Audio Devices...]             │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                               │
│ Status: Ready  |  Tip: Headphones required for binaural     │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Component Specifications

### 3.1 Mode Selector (Radio Buttons)
```python
modes = [
    ("Binaural", "Stereo L/R frequency offset - requires headphones"),
    ("Isochronic", "Mono carrier with amplitude pulses - works on speakers"),
    ("Layered", "Future: combine multiple frequencies")
]
```

**Behavior:**
- Switching modes preserves carrier/beat/volume where possible
- Isochronic mode reveals sharpness/floor controls
- Binaural mode grays out ISO-specific parameters
- Tooltip on hover shows 1-line description

**Efficiency gain:** User doesn't need to remember mode differences — UI reveals/hides relevant controls.

---

### 3.2 Preset Dropdown

**Categories (collapsible menu):**
```
Binaural - Fibonacci
├─ BN Fib 1 - Deep Sleep (1 Hz, 480s)
├─ BN Fib 2 - Sleep (2 Hz, 480s)
├─ BN Fib 3 - Deep Meditation (3 Hz, 420s)
├─ BN Fib 5 - Meditation (5 Hz, 420s)
├─ BN Fib 8 - Golden Alpha (8 Hz, 420s) ★ Default
└─ BN Fib 13 - Active Alpha (13 Hz, 420s)

Binaural - Golden Ratio
├─ BN Pure Phi 1.618 (480s)
├─ BN Double Phi ~3.236 (420s)
├─ BN Schumann 7.83 (420s)
└─ BN Golden Sleep ~2.618 (600s)

Isochronic - Core
├─ ISO Fib 3 - Deep Meditation
├─ ISO Fib 5 - Meditation
├─ ISO Fib 8 - Golden Alpha
├─ ISO Pure Phi 1.618
└─ ISO Schumann 7.83

Ramps (Multi-Segment)
├─ BN Fibonacci Ramp 3→5→8→13 (480s total)
└─ ISO Fibonacci Ramp 3→5→8→13 (480s total)

─────────────────
Custom (use sliders below)
```

**Behavior:**
- Selecting preset → auto-fills all parameters + switches mode if needed
- "Custom" option → enables all sliders, no auto-fill
- ★ indicates default preset on app launch
- Reset button → revert to last selected preset

**Efficiency:** Categorization reduces scan time. Most users pick preset → click Play (2 clicks).

---

### 3.3 Parameter Controls

#### Dual-Input Pattern (Spinbox + Slider)
**Why both?**
- **Slider** = fast approximate tuning (mouse/touch)
- **Spinbox** = precise entry (keyboard, copy-paste)

**Example: Carrier Frequency**
```
Carrier Frequency
┌──────┐ Hz
│ 100  │ ← Spinbox (editable, validates on blur)
└──────┘
[────●────] ← Slider (60-125 Hz range)
   60  125
```

**Validation:**
- Out-of-range spinbox entry → red border + tooltip "Must be 60-125"
- Slider physically constrains to valid range
- Both inputs stay synchronized bidirectionally

**Efficiency:** Power users type, casual users drag. Both paths < 2s to target value.

---

#### Visual Feedback on Sliders

**Volume Slider:**
```
Volume
┌──────┐
│ 0.25 │
└──────┘
[▓▓▓▓▓░░░░░] ← Filled portion shows current level
0.0────────1.0
```
- Color-coded: Green (0-0.5), Yellow (0.5-0.7), Red (0.7-1.0)
- Warns against hearing damage at high volumes

**Duration Slider:**
```
Duration (seconds)
┌──────┐
│ 420  │  [▾ 7:00] ← Live MM:SS conversion
└──────┘
[────────●────────]
60s           1800s (30min)
```
- Logarithmic scale? No — linear is more intuitive for time
- Notches at 5min, 10min, 15min for quick selection

---

### 3.4 Isochronic-Specific Panel

**Collapsible section (accordion pattern):**

```
┌─────────────────────────────────────────────────────┐
│ ▼ ISOCHRONIC MODE OPTIONS                           │
├─────────────────────────────────────────────────────┤
│ Pulse Sharpness                                     │
│ ┌──────┐  [──●────] 1.0-6.0                        │
│ │ 2.0  │  Higher = narrower peaks                   │
│ └──────┘  (affects duty cycle)                      │
│                                                      │
│ Off-Gain Floor                                      │
│ ┌──────┐  [●─────] 0.0-0.3                         │
│ │ 0.00 │  0.0 = silence between pulses              │
│ └──────┘  >0.0 = softer "off" state                 │
└─────────────────────────────────────────────────────┘
```

**Behavior:**
- Auto-collapses when Binaural mode selected
- Default state: expanded (since ISO is simpler for beginners)

---

### 3.5 Transport Controls

```
┌─────────────────────────────────────────────────────┐
│ [▶ Play] [⏸ Pause] [⏹ Stop]     Elapsed: 00:00    │
│                                  Remaining: 07:00   │
│ Progress: [▓▓▓░░░░░░░░░░░░░] 32%                   │
└─────────────────────────────────────────────────────┘
```

**Button states:**
- Play → disabled during playback, enabled when stopped
- Pause → visible only during playback
- Stop → enabled during playback/pause

**Progress bar:**
- Clickable → seek to position (future feature)
- Updates every 0.5s to avoid UI thrashing

**Efficiency:** No confirmation dialogs for Play/Stop (user can always stop immediately).

---

### 3.6 Export & Utilities

```
[💾 Export WAV...]  [🔊 Audio Devices...]  [? Help]
```

**Export workflow:**
1. User clicks Export WAV
2. Dialog: "Export current settings or generate now?"
   - ⚪ Use current parameters (instant)
   - ⚪ Generate with custom duration: [____] seconds
3. File picker: default name = `mindstate_<preset>_<timestamp>.wav`
4. Progress bar during file write
5. Success notification: "Exported to [path]"

**Audio Devices dialog:**
```
┌──────────────────────────────────────────────┐
│ Select Audio Output Device                   │
├──────────────────────────────────────────────┤
│ ⚫ [0] Speakers (Realtek HD Audio)           │
│ ⚪ [3] Headphones (USB Audio Device)         │
│ ⚪ [5] HDMI Audio (NVIDIA)                   │
│                                              │
│ [Test] ← Plays 1s sine tone to verify       │
│ [Set as Default]  [Cancel]                  │
└──────────────────────────────────────────────┘
```

---

## 4. Color Scheme & Typography

### Palette (Dark Theme Default)
```
Background:    #1E1E1E (VS Code dark)
Panels:        #252526 (slight elevation)
Borders:       #3E3E42 (subtle separation)
Text:          #CCCCCC (primary)
Text Muted:    #858585 (labels)
Accent:        #007ACC (focus/selection)
Success:       #4EC9B0 (play button, valid)
Warning:       #CE9178 (high volume)
Error:         #F44747 (validation fail)
```

**Light theme:** Invert values, accent stays blue.

**Rationale:** Dark theme reduces eye strain during long sessions. Matches PyCharm default.

---

### Typography
```
Headings:      Segoe UI Semibold, 11pt
Body:          Segoe UI Regular, 10pt
Monospace:     Consolas, 9pt (for Hz/time values)
```

**Accessibility:** All text ≥ 10pt, contrast ratio > 4.5:1 (WCAG AA).

---

## 5. Interaction Patterns

### 5.1 Keyboard Shortcuts
```
Space       → Play/Pause toggle
Ctrl+S      → Export WAV dialog
Ctrl+R      → Reset to preset
Ctrl+D      → Open device selector
Esc         → Stop playback
F1          → Help documentation

Arrow Keys  → Navigate between controls
Tab         → Focus next control
Enter       → Activate focused button
```

**Efficiency:** Power users never touch mouse for common actions.

---

### 5.2 Parameter Linking (Future)

**Lock icon between Carrier and Beat:**
```
Carrier [100] Hz 🔓 Beat [8.0] Hz
```
- **Unlocked (default):** Independent adjustment
- **Locked:** Maintains ratio (e.g., beat = carrier × 0.08)
  - Useful for exploring harmonic relationships

**Efficiency:** Prevents accidental ratio disruption when experimenting.

---

### 5.3 Undo/Redo (Future)

```
Edit → Undo (Ctrl+Z)
Edit → Redo (Ctrl+Y)
```

**Applies to:** Parameter changes, preset switches. Not playback state.

**Implementation:** Command pattern with 20-step history.

---

## 6. Advanced Features (Expandable Sections)

### 6.1 Waveform Preview (Optional)
```
┌─────────────────────────────────────────────────────┐
│ ▼ WAVEFORM PREVIEW (first 2 seconds)               │
├─────────────────────────────────────────────────────┤
│  1.0│ Left  ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲                │
│  0.0├──────────────────────────────────            │
│ -1.0│       ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱                │
│     │                                              │
│  1.0│ Right ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲ (phase offset) │
│  0.0├──────────────────────────────────            │
│ -1.0│       ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱                │
│     └──────────────────────────────────────        │
│       0s    0.5s    1.0s    1.5s    2.0s          │
└─────────────────────────────────────────────────────┘
```

**Implementation:** matplotlib embedded canvas, updates on parameter change.

**Cost/Benefit:** 
- **Cost:** +150 lines, matplotlib dependency
- **Benefit:** Visual confirmation for advanced users
- **Decision:** Defer to v2.0

---

### 6.2 Ramp Editor (Visual Timeline)
```
┌─────────────────────────────────────────────────────┐
│ RAMP TIMELINE                                       │
├─────────────────────────────────────────────────────┤
│ [3Hz ▓▓] [5Hz ▓▓▓] [8Hz ▓▓▓▓] [13Hz ▓▓▓▓▓]       │
│ 0s   120s    240s     360s      480s               │
│                                                     │
│ [+ Add Segment]  [✕ Delete]  [⇅ Reorder]          │
└─────────────────────────────────────────────────────┘
```

**Interaction:**
- Drag segment edges → adjust duration
- Click segment → edit beat frequency in popup
- Drag segments → reorder sequence

**Complexity:** High. Requires canvas drawing + hit detection.

**Decision:** Defer to v2.0 or separate "Ramp Studio" tool.

---

## 7. Error Handling & User Feedback

### 7.1 Validation Feedback

**Real-time validation (on blur/change):**
```
Carrier Frequency
┌──────┐ Hz
│ 200  │ ← Red border + shake animation
└──────┘
⚠ Must be between 60-125 Hz
```

**Status bar messages:**
- ✅ "Parameters valid"
- ⚠ "Carrier exceeds safe range"
- ❌ "Invalid beat frequency"

---

### 7.2 Playback Errors

**Dialog for critical failures:**
```
┌────────────────────────────────────────┐
│ ⚠ Audio Device Error                  │
├────────────────────────────────────────┤
│ Could not initialize audio output.     │
│                                        │
│ Possible causes:                       │
│ • Device unplugged                     │
│ • Driver conflict                      │
│ • Sample rate mismatch                 │
│                                        │
│ [Open Device Settings]  [Retry]  [OK] │
└────────────────────────────────────────┘
```

**Non-blocking notifications:**
- Toast (bottom-right, 3s): "Playback started"
- Persistent banner (top): "Headphones recommended for binaural mode"

---

## 8. Implementation Notes (Tkinter)

### Widget Mapping
```python
Mode Selector      → ttk.Radiobutton (Tk-themed)
Preset Dropdown    → ttk.Combobox with custom renderer
Parameter Sliders  → ttk.Scale + tk.Spinbox (coupled)
Transport Buttons  → tk.Button with Unicode symbols
Progress Bar       → ttk.Progressbar (indeterminate during playback)
```

### Threading Model
```
Main Thread (UI)  → User interactions, widget updates
Audio Thread      → sounddevice playback (blocking)
Export Thread     → File I/O (scipy.io.wavfile)
```

**Communication:** `queue.Queue` for thread-safe messaging.

**Example: Play button click**
```python
def on_play_clicked():
    # Validate params
    if not validate_all_params():
        show_error("Invalid parameters")
        return
    
    # Disable UI during playback
    play_button.config(state=tk.DISABLED)
    stop_button.config(state=tk.NORMAL)
    
    # Generate buffer in main thread (fast enough)
    buffer = generate_binaural_segment(...)
    
    # Start playback thread
    playback_thread = threading.Thread(
        target=play_buffer_threaded,
        args=(buffer, progress_callback),
        daemon=True
    )
    playback_thread.start()

def progress_callback(elapsed_sec):
    # Called from audio thread
    root.after(0, update_progress_bar, elapsed_sec)
```

---

### Layout Manager: Grid
```python
# Main window grid
root.grid_rowconfigure(1, weight=1)  # Parameters expand
root.grid_columnconfigure(0, weight=1)

# Row 0: Mode selector
# Row 1: Preset dropdown
# Row 2: Parameters (weight=1 → expands)
# Row 3: Noise controls
# Row 4: Transport
# Row 5: Status bar
```

**Rationale:** Grid is more predictable than pack for complex layouts. Avoid place (breaks with window resize).

---

## 9. Accessibility Considerations

### WCAG 2.1 Level AA Compliance

**Visual:**
- Color contrast ≥ 4.5:1 for all text
- Focus indicators (2px blue outline) on all interactive elements
- No color-only information (icons + text labels)

**Motor:**
- Click targets ≥ 44×44px (touch-friendly)
- Keyboard navigation for all actions
- No time-limited interactions

**Cognitive:**
- Consistent button placement (Play always leftmost)
- Confirmation dialogs for destructive actions (future: delete preset)
- Error messages specify corrective action ("Enter value 60-125")

---

## 10. Prototype Evaluation Metrics

**Before user testing:**

| Metric | Target | Measurement |
|--------|--------|-------------|
| Preset playback | ≤ 2 clicks | Click counter |
| Custom session export | ≤ 5 clicks | Click counter |
| Parameter validation feedback | < 1s latency | Timer on blur event |
| UI responsiveness during playback | < 50ms button lag | Threading stress test |
| First-time user success rate | > 80% complete task | n=10 users, moderated test |

**Task scenarios for user testing:**
1. "Play the Golden Alpha preset" (expect 2 clicks)
2. "Create a 10-minute session at 100Hz carrier, 5Hz beat, export as WAV" (expect 5 clicks)
3. "Switch from binaural to isochronic mode and adjust pulse sharpness" (expect 3 clicks)

---

## 11. Future Enhancements (Post-MVP)

### Priority Queue
1. **Session history** — Recently played presets, quick-replay
2. **Favorites** — Star presets, custom ordering
3. **Batch export** — Generate all Fibonacci presets as WAV files
4. **Real-time spectrum analyzer** — FFT visualization during playback
5. **Mobile companion app** — Remote control via LAN (websocket)
6. **Preset sharing** — Export/import JSON, community library

---

## 12. Mockup Gallery

### Light Theme Variant
```
┌─────────────────────────────────────────────────────────────┐
│ Mindstate Clone                                    [─][□][×]│
├─────────────────────────────────────────────────────────────┤
│ [Light theme uses white background, dark text]              │
│ Accent color remains blue (#007ACC)                         │
│ Sliders use gray fill instead of colored                    │
│                                                              │
│ Automatically follows system theme on Windows 11/macOS      │
└─────────────────────────────────────────────────────────────┘
```

### Compact Mode (Future)
```
┌──────────────────────────────┐
│ Mindstate Clone     [─][□][×]│
├──────────────────────────────┤
│ [BN Fib 8 ▾]  [▶] [⏹] 00:00│
│ Carrier: 100  Beat: 8.0      │
│ Volume: ▓▓▓░░░ 0.25          │
│ [💾] [🔊]                    │
└──────────────────────────────┘
```
- Toggle via View → Compact Mode (Ctrl+Shift+C)
- Hides advanced parameters, shows only essentials
- Target: 300×200px window for second monitor

---

## 13. Technical Debt Prevention

**Issues to avoid from monolithic CLI:**

1. **Magic numbers** → All dimensions/colors in `theme.py` constants
2. **Callback hell** → Use command pattern for button actions
3. **State synchronization** → Single `AppState` dataclass, observers update UI
4. **Hardcoded presets** → Load from JSON, hot-reload on file change

**Example: AppState pattern**
```python
@dataclass
class AppState:
    mode: str = "binaural"
    carrier_hz: float = 100.0
    beat_hz: float = 8.0
    volume: float = 0.25
    duration_sec: int = 420
    # ... other params
    
    def to_dict(self) -> dict:
        return asdict(self)
    
    def validate(self) -> list[str]:
        errors = []
        if not (60 <= self.carrier_hz <= 125):
            errors.append("Carrier out of range")
        # ... other checks
        return errors

# In GUI
app_state = AppState()

def on_carrier_changed(value):
    app_state.carrier_hz = value
    update_all_observers()  # Refresh dependent widgets
```

---

## 14. Development Timeline

**Assuming 1 developer, 4h/day focused work:**

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1: Core UI skeleton | 2 days | Mode selector, preset dropdown, basic layout |
| Phase 2: Parameter controls | 3 days | All sliders + spinboxes, validation |
| Phase 3: Transport logic | 2 days | Play/pause/stop, threading, progress bar |
| Phase 4: Export functionality | 1 day | WAV export dialog, file I/O |
| Phase 5: Polish & testing | 2 days | Keyboard shortcuts, tooltips, error handling |
| **Total** | **10 days** | **MVP GUI** |

**Post-MVP (optional):**
- Noise layer controls: +1 day
- Waveform preview: +2 days
- Ramp editor: +5 days
- Dark/light theme toggle: +1 day

---

## Appendix: Design Rationale Summary

**Why Tkinter over alternatives?**

| Framework | Pros | Cons | Decision |
|-----------|------|------|----------|
| Tkinter | Native Python, no deps, fast prototyping | Dated look (fixable with ttk) | ✅ Use |
| PyQt | Professional look, mature | GPL/Commercial license, 50MB | ❌ Overkill |
| Kivy | Modern, touch-first | Steeper learning curve, 30MB | ❌ Overkill |
| Web (Electron) | Cross-platform UI | 200MB bundle, complexity | ❌ Overkill |

**Tkinter + ttk themes = 90% of PyQt aesthetics, 10% of complexity.**

---

**Why dual input (slider + spinbox)?**

Analogy: Volume knob (analog) + numeric display (digital) on audio equipment. Users naturally switch between coarse (twist knob) and fine (type number) adjustments. GUI should support both motor patterns.

---

**Why collapsible sections?**

Information density paradox: 
- Too sparse → excessive scrolling (time cost)
- Too dense → cognitive overload (quality cost)

Solution: Progressive disclosure. Show essentials by default, reveal complexity on demand. Accordion panels optimize efficiency = quality / time.
