# PhiWave GUI Enhancement - IDE Claude Action Plan

**Agent:** IDE Claude
**Goal:** Complete Phase 2 GUI visual enhancements
**Estimated Total Time:** 12-15 hours
**Starting Point:** Phase 1 complete (elite buttons integrated)

---

## Context Refresh

**Current State:**
- Elite buttons working (commit feb286f)
- Design system expanded (23 colors, Fibonacci spacing)
- Asset generation pipeline operational
- GUI running at `phiwave_gui.py` (standalone)

**What We're Building:**
Premium AV equipment aesthetic with golden ratio foundation. All visual elements follow Fibonacci spacing (3, 5, 8, 13, 21, 34px) and frequency-color mapping.

---

## Phase 2 Implementation Plan

### SESSION 1: Golden Sliders (90 minutes)

**Objective:** Transform all sliders to use golden ratio styling with frequency-mapped colors.

**Steps:**

1. **Create custom slider style** (30 min)
   ```python
   # Add to phiwave_gui.py after FONTS class
   def configure_slider_style(root):
       style = ttk.Style()
       style.theme_use('clam')

       # Golden track
       style.configure('Golden.Horizontal.Scale',
                      background='#C9A961',
                      troughcolor='#1A1A1A',
                      borderwidth=0,
                      sliderlength=21,  # Fibonacci
                      sliderrelief='flat')

       # Hover state
       style.map('Golden.Horizontal.Scale',
                background=[('active', '#FFB300')])
   ```

2. **Update frequency sliders with color mapping** (40 min)
   - Carrier slider: Static gold
   - Beat slider: Dynamic color based on value
   - Add value labels that change color with frequency
   ```python
   def on_beat_change(self, value):
       freq = float(value)
       color = get_frequency_color(freq)  # From animation.py
       self.beat_label.config(fg=color)
   ```

3. **Style duration and volume sliders** (20 min)
   - Duration: Cyan (#00ACC1)
   - Volume: Red gradient (quiet→loud)
   - Add hover effects (144ms transition)

**Files to modify:**
- `phiwave_gui.py` lines ~400-500 (slider creation)
- Import `get_frequency_color` from `phiwave_gui/animation.py`

**Test checklist:**
- [ ] All sliders display golden styling
- [ ] Beat slider label changes color (test 5Hz=blue, 13Hz=teal)
- [ ] Hover effects work (brighter on mouse-over)
- [ ] Values update smoothly

---

### SESSION 2: Textured Backgrounds (60 minutes)

**Objective:** Apply gradient backgrounds to control panels.

**Steps:**

1. **Load gradient assets** (15 min)
   ```python
   # Add to __init__ after elite button loading
   self.gradient_vertical = None
   try:
       grad_path = Path(__file__).parent / "assets/ui/gradients/golden_gradient_vertical.png"
       self.gradient_vertical = tk.PhotoImage(file=str(grad_path))
   except Exception as e:
       print(f"[GRADIENT] Could not load: {e}")
   ```

2. **Apply to parameter panel** (20 min)
   ```python
   def create_parameter_controls(self):
       # Background canvas with gradient
       bg_canvas = tk.Canvas(self.left_frame, width=280, height=400,
                            bg=COLORS.bg_control, highlightthickness=0)
       bg_canvas.pack()

       if self.gradient_vertical:
           # Tile gradient vertically
           for y in range(0, 400, 512):
               bg_canvas.create_image(140, y, image=self.gradient_vertical)

       # Frame on top of canvas
       controls_frame = tk.Frame(bg_canvas, bg='', ...)
       controls_frame.place(x=0, y=0)
   ```

3. **Apply to playback and export sections** (25 min)
   - Same pattern as parameter panel
   - Ensure text remains readable over gradient

**Files to modify:**
- `phiwave_gui.py` lines ~340-580 (panel creation methods)

**Test checklist:**
- [ ] Gradients visible behind all panels
- [ ] Text clearly readable
- [ ] Gradients fallback to solid color if missing
- [ ] No performance issues (should be instant)

---

### SESSION 3: Status LED Indicator (90 minutes)

**Objective:** Replace text status with animated LED indicator.

**Steps:**

1. **Create StatusLED class** (40 min)
   ```python
   # New file: phiwave_gui/controls/status_led.py

   class StatusLED:
       def __init__(self, parent):
           self.canvas = tk.Canvas(parent, width=34, height=34,
                                  bg=COLORS.bg_control, highlightthickness=0)
           self.state = 'ready'
           self.pulse_id = None
           self.pulse_alpha = 1.0

       def set_state(self, state):
           # States: ready, generating, playing, stopped, error
           self.state = state
           self.redraw()

           if state in ['generating', 'error']:
               self.start_pulse()
           else:
               self.stop_pulse()

       def redraw(self):
           self.canvas.delete('all')
           colors = {
               'ready': '#43A047',      # Green
               'generating': '#FFB300', # Amber (pulsing)
               'playing': '#FFB300',    # Amber (solid)
               'stopped': '#E57373',    # Red
               'error': '#F44336'       # Red (pulsing)
           }
           color = colors.get(self.state, '#888888')

           # Outer glow
           self.canvas.create_oval(8, 8, 26, 26, fill=color, outline='')
           # Inner bright spot
           self.canvas.create_oval(13, 13, 21, 21, fill='#FFFFFF', outline='')

       def start_pulse(self):
           # Pulse between 100% and 40% opacity over 610ms
           ...
   ```

2. **Integrate into GUI** (30 min)
   - Replace `self.status_label` with `self.status_led`
   - Add text label next to LED (optional)
   - Update all status changes to call `status_led.set_state()`

3. **Wire up to playback states** (20 min)
   - `on_play_clicked()` → set_state('generating')
   - After buffer generated → set_state('playing')
   - `on_stop_clicked()` → set_state('stopped')
   - `on_playback_complete()` → set_state('ready')

**Files to create:**
- `phiwave_gui/controls/status_led.py`

**Files to modify:**
- `phiwave_gui.py` (replace status label with LED)

**Test checklist:**
- [ ] LED shows green when ready
- [ ] LED pulses amber during generation
- [ ] LED solid amber during playback
- [ ] LED turns green after playback completes
- [ ] LED blinks red on errors

---

### SESSION 4: Preset Dropdown Enhancement (45 minutes)

**Objective:** Add frequency colors to preset dropdown.

**Steps:**

1. **Modify preset names to include frequency indicators** (25 min)
   ```python
   def update_preset_dropdown(self):
       if not self.preset_loader:
           return

       preset_items = []
       for preset in self.preset_loader.presets:
           beat_hz = preset['beat_hz']
           color = get_frequency_color(beat_hz)

           # Add colored dot using Unicode
           dot = '●'
           name = f"{dot} {preset['name']} ({beat_hz}Hz)"
           preset_items.append(name)

       self.preset_combo['values'] = preset_items
   ```

2. **Style combobox** (20 min)
   ```python
   style = ttk.Style()
   style.configure('Golden.TCombobox',
                  fieldbackground='#242424',
                  background='#C9A961',
                  foreground='#E8E8E8',
                  arrowcolor='#C9A961')

   self.preset_combo = ttk.Combobox(..., style='Golden.TCombobox')
   ```

**Files to modify:**
- `phiwave_gui.py` lines ~275-300 (preset dropdown)

**Test checklist:**
- [ ] Dropdown shows colored dots
- [ ] Colors match frequency (5Hz=blue, 8Hz=cyan, etc.)
- [ ] Dropdown styled with golden theme
- [ ] Preset selection still works correctly

---

### SESSION 5: Progress Bar with Dynamic Colors (60 minutes)

**Objective:** Add playback progress bar that changes color with frequency.

**Steps:**

1. **Create progress bar widget** (25 min)
   ```python
   # Add below playback buttons
   self.progress_var = tk.DoubleVar(value=0)

   # Time display
   self.time_label = tk.Label(controls_frame,
                             text="00:00 / 00:00",
                             bg=COLORS.bg_control,
                             fg=COLORS.text_secondary,
                             font=(FONTS.family, FONTS.size_small))
   self.time_label.pack(pady=(SPACING.sm, 0))

   # Progress bar (custom canvas)
   self.progress_canvas = tk.Canvas(controls_frame,
                                    width=235, height=5,
                                    bg=COLORS.bg_app,
                                    highlightthickness=0)
   self.progress_canvas.pack(pady=SPACING.xs)
   ```

2. **Implement progress tracking** (20 min)
   ```python
   def update_progress(self):
       if not hasattr(self, 'playback_start_time'):
           return

       elapsed = time.time() - self.playback_start_time
       duration = self.duration_var.get()
       progress = min(elapsed / duration, 1.0)

       # Update progress bar
       freq_color = get_frequency_color(self.beat_var.get())
       self.progress_canvas.delete('all')
       width = int(235 * progress)
       self.progress_canvas.create_rectangle(0, 0, width, 5,
                                            fill=freq_color, outline='')

       # Update time display
       elapsed_str = f"{int(elapsed//60):02d}:{int(elapsed%60):02d}"
       total_str = f"{int(duration//60):02d}:{int(duration%60):02d}"
       self.time_label.config(text=f"{elapsed_str} / {total_str}")

       if progress < 1.0:
           self.root.after(100, self.update_progress)
   ```

3. **Wire to playback** (15 min)
   - Call `update_progress()` when playback starts
   - Stop updates on stop/complete
   - Reset to 0 on stop

**Files to modify:**
- `phiwave_gui.py` (playback section + progress tracking)

**Test checklist:**
- [ ] Progress bar appears below buttons
- [ ] Bar fills gradually during playback
- [ ] Color matches beat frequency
- [ ] Time display accurate (MM:SS / MM:SS)
- [ ] Resets on stop

---

### SESSION 6: Wave Background Animation (Optional - 90 minutes)

**Objective:** Add subtle animated sine wave to background.

**Steps:**

1. **Extend background canvas** (40 min)
   ```python
   def _draw_wave_pattern(self):
       self.wave_phase = 0
       self.wave_lines = []

       # Draw 3 wave layers at different frequencies
       for i in range(3):
           line_id = self.canvas.create_line(
               0, 0, 0, 0,  # Will update in animation
               fill=COLORS.border_subtle,
               width=1,
               smooth=True
           )
           self.wave_lines.append(line_id)

       self.animate_wave()

   def animate_wave(self):
       if not hasattr(self, 'beat_var'):
           return

       beat_hz = self.beat_var.get()
       color = get_frequency_color(beat_hz)

       # Calculate wave points
       points = []
       for x in range(0, WINDOW_WIDTH, 8):
           y_base = WINDOW_HEIGHT / 2
           y = y_base + 20 * math.sin(
               2 * math.pi * beat_hz * x / 500 + self.wave_phase
           )
           points.extend([x, y])

       # Update line
       self.canvas.coords(self.wave_lines[0], *points)
       self.canvas.itemconfig(self.wave_lines[0], fill=color)

       self.wave_phase += PHI / 100
       self.root.after(33, self.animate_wave)  # 30fps
   ```

2. **Add pause on blur** (20 min)
   - Stop animation when window loses focus
   - Resume on focus

3. **Opacity control** (30 min)
   - Keep waves very subtle (5-10% opacity)
   - Use stipple pattern if direct opacity not available

**Files to modify:**
- `phiwave_gui.py` (background canvas methods)

**Test checklist:**
- [ ] Subtle waves visible in background
- [ ] Wave frequency matches beat frequency
- [ ] Color changes with frequency
- [ ] Animation pauses when window minimized
- [ ] CPU usage <5%

---

## Quick Implementation Order

**Recommended sequence (minimum viable visual polish):**

1. **Golden Sliders** (90 min) - Immediate visual impact
2. **Status LED** (90 min) - Professional feedback
3. **Preset Colors** (45 min) - Easy win
4. **Progress Bar** (60 min) - User experience
5. **Textured Backgrounds** (60 min) - Polish layer

**Total: 5.75 hours for core enhancements**

Skip wave animation if time-constrained (can add later).

---

## Session Workflow

**For each session:**

1. **Read session objectives** (5 min)
2. **Implement changes** (follow steps)
3. **Test manually** (run checklist)
4. **Commit changes** (descriptive message)
5. **Post to agent hub** (brief update)

**Between sessions:**
- Keep GUI running in background for quick testing
- Use `git status` frequently
- Push after each session completion

---

## Code Snippets Reference

**Get frequency color:**
```python
from phiwave_gui.animation import get_frequency_color
color = get_frequency_color(8.0)  # Returns '#00ACC1' (cyan)
```

**Fibonacci timing:**
```python
from phiwave_gui.animation import ANIMATION
self.root.after(ANIMATION.fast, callback)  # 144ms
```

**Load assets safely:**
```python
try:
    img = tk.PhotoImage(file=str(path))
except Exception as e:
    print(f"[ASSET] Failed: {e}")
    img = None
```

**Apply golden gradient:**
```python
style = ttk.Style()
style.configure('Golden.TScale', background='#C9A961')
```

---

## Files You'll Touch Most

**Primary:**
- `phiwave_gui.py` (main GUI file, ~850 lines)
  - Lines 340-400: Parameter controls
  - Lines 570-630: Playback controls
  - Lines 710-790: Playback logic

**Secondary:**
- `phiwave_gui/animation.py` (import helpers from here)
- `phiwave_gui/config.py` (color constants)

**New files to create:**
- `phiwave_gui/controls/status_led.py` (LED class)

---

## Testing Protocol

**After each session:**

1. Launch GUI: `.venv/Scripts/python.exe phiwave_gui.py`
2. Visual inspection: Check styling applied correctly
3. Interaction test: Click/drag all controls
4. Frequency test: Change beat frequency, verify colors update
5. Playback test: Play → Stop → verify states
6. Error handling: Remove an asset file, check fallback works

**Final integration test:**
1. Fresh launch
2. Load preset
3. Adjust all sliders
4. Play full session
5. Export to WAV
6. Verify all visual elements working

---

## Success Criteria

**Phase 2 Complete When:**
- [ ] All sliders use golden styling
- [ ] Beat frequency changes slider label color
- [ ] Gradient backgrounds visible on panels
- [ ] Status LED shows proper states (ready/playing/error)
- [ ] Preset dropdown has frequency colors
- [ ] Progress bar fills during playback with dynamic color
- [ ] No visual glitches or performance issues
- [ ] Graceful fallbacks if assets missing

**Stretch Goals:**
- [ ] Wave background animation
- [ ] Button glow effects on press
- [ ] Smooth transitions (Fibonacci timing)

---

## Command Quick Reference

```bash
# Launch GUI
.venv/Scripts/python.exe phiwave_gui.py

# Regenerate assets if needed
.venv/Scripts/python.exe scripts/generate_ui_assets.py
.venv/Scripts/python.exe scripts/generate_elite_png.py

# Git workflow
git status
git add <files>
git commit -m "feat: <description>"
git push origin main

# Check what's running
# (List background processes if needed)
```

---

## Post to Agent Hub After Each Session

```python
mcp__phiwave-agent-hub__post_message(
    sender="IDE Claude",
    content="Session N complete: [what you did]. Next: [what's next]."
)
```

---

## Notes & Tips

**Performance:**
- Assets load once at startup (~200ms total)
- Animations at 30fps (33ms frame time) max
- Keep CPU <5% during playback + animation

**Styling Priorities:**
1. Color (most impactful)
2. Spacing (Fibonacci)
3. Timing (animations)
4. Gradients (polish)

**If You Get Stuck:**
- Check `PROJECT_SUMMARY.md` for context
- Review `GUI_VISUAL_ENHANCEMENT_PLAN.md` for original vision
- Test each change immediately (fail fast)
- Commit working increments (not all at once)

**Remember:**
- Golden ratio = φ = 1.618
- Fibonacci: 3, 5, 8, 13, 21, 34
- Timing: 89, 144, 233, 377, 610 ms
- Frequency colors: 1Hz=purple, 5Hz=blue, 8Hz=cyan, 13Hz=teal, 21Hz=green

---

## Let's Build! 🎨

Start with Session 1 (Golden Sliders) - 90 minutes to visual impact!
