# PhiWave Audio Modes

PhiWave v2.0 supports multiple audio generation modes for different use cases and preferences.

## Available Modes

### 1. **Binaural Beats** (Default)
**Mechanism:** Different frequencies sent to each ear  
**How it works:** Brain creates beat frequency from the difference  
**Requirements:** Headphones required  
**Best for:** Classic brainwave entrainment, deep focus

```python
from phiwave.modes import generate_binaural

left, right = generate_binaural(
    carrier_hz=180,
    beat_hz=10,
    duration_sec=300,
    volume=0.5
)
```

---

### 2. **Monaural Beats**
**Mechanism:** Both frequencies mixed in each ear  
**How it works:** Beat created externally before reaching ears  
**Requirements:** Works with speakers OR headphones  
**Best for:** Stronger cortical response, group sessions

**Advantages:**
- No headphones required
- Stronger EEG response than binaural
- Works in noisy environments

```python
from phiwave.modes import generate_monaural

left, right = generate_monaural(
    carrier_hz=180,
    beat_hz=10,
    duration_sec=300,
    volume=0.5
)
```

---

### 3. **Isochronic Tones**
**Mechanism:** Single tone pulsed on/off at beat frequency  
**How it works:** Rhythmic pulses at target brainwave frequency  
**Requirements:** Works with speakers OR headphones  
**Best for:** Most consciously noticeable, meditation timers

**Advantages:**
- Very distinct pulses
- Most "active" feeling
- No phase issues

```python
from phiwave.modes import generate_isochronic

left, right = generate_isochronic(
    carrier_hz=180,
    beat_hz=10,
    duration_sec=300,
    volume=0.5,
    duty_cycle=0.5  # 50% on, 50% off
)
```

---

### 4. **Bilateral Stimulation**
**Mechanism:** Alternating tones between left/right ears  
**How it works:** Creates left-right attention shift  
**Requirements:** Headphones required  
**Best for:** EMDR therapy, anxiety reduction, processing

**Used in:**
- EMDR (Eye Movement Desensitization and Reprocessing)
- Trauma processing
- Bilateral brain activation

```python
from phiwave.modes import generate_bilateral

left, right = generate_bilateral(
    carrier_hz=180,
    beat_hz=2,  # Slower for bilateral (1-4 Hz typical)
    duration_sec=300,
    volume=0.5
)
```

---

### 5. **Pulsed Binaural**
**Mechanism:** Binaural beat + amplitude modulation  
**How it works:** Combines binaural effect with rhythmic pulsing  
**Requirements:** Headphones required  
**Best for:** Enhanced engagement, combining techniques

**Advantages:**
- Dual-mechanism approach
- More noticeable than pure binaural
- Customizable pulse rate

```python
from phiwave.modes import generate_pulsed_binaural

left, right = generate_pulsed_binaural(
    carrier_hz=180,
    beat_hz=10,
    duration_sec=300,
    volume=0.5,
    pulse_hz=2.0  # Pulse envelope frequency
)
```

---

### 6. **Harmonic Stack**
**Mechanism:** Multiple carrier frequencies at harmonic intervals  
**How it works:** Adds harmonics for richer sound  
**Requirements:** Headphones recommended  
**Best for:** Musical quality, complex soundscapes

**Advantages:**
- Richer, more complex sound
- Less "boring" than pure sine waves
- Natural overtones

```python
from phiwave.modes import generate_harmonic_stack

left, right = generate_harmonic_stack(
    carrier_hz=180,
    beat_hz=10,
    duration_sec=300,
    volume=0.5,
    num_harmonics=3  # Number of harmonics to add
)
```

---

## Universal API

All modes can be accessed through a single function:

```python
from phiwave.modes import generate_audio

left, right = generate_audio(
    mode='binaural',  # or 'monaural', 'isochronic', etc.
    carrier_hz=180,
    beat_hz=10,
    duration_sec=300,
    sample_rate=48000,
    volume=0.5
)
```

---

## Mode Comparison Table

| Mode | Headphones? | Speaker? | Strength | Conscious Notice |
|------|-------------|----------|----------|------------------|
| **Binaural** | Required | No | Moderate | Low |
| **Monaural** | Optional | Yes | Strong | Moderate |
| **Isochronic** | Optional | Yes | Strong | High |
| **Bilateral** | Required | No | Moderate | High |
| **Pulsed** | Required | No | Strong | High |
| **Harmonic** | Recommended | Optional | Moderate | Moderate |

---

## Choosing a Mode

### For Focus/Study
- **Best:** Binaural (classic, subtle)
- **Alternative:** Monaural (if no headphones)

### For Meditation
- **Best:** Isochronic (clear pulses for timing)
- **Alternative:** Binaural (less distracting)

### For Relaxation
- **Best:** Harmonic Stack (pleasant tones)
- **Alternative:** Binaural (gentle)

### For Trauma Processing (EMDR)
- **Best:** Bilateral (designed for this)
- **Alternative:** Pulsed Binaural

### For Group Sessions
- **Best:** Monaural or Isochronic (work with speakers)

---

## Scientific Notes

### Binaural Beats
- **Research:** Moderate evidence for anxiety reduction, some for focus
- **Mechanism:** Frequency-following response in brainstem/cortex
- **Limitations:** Requires headphones, subtle effect

### Monaural Beats
- **Research:** Stronger EEG response than binaural in studies
- **Mechanism:** Physical beat, not neurological artifact
- **Advantage:** More robust effect

### Isochronic Tones
- **Research:** Limited but promising for entrainment
- **Mechanism:** Direct rhythmic stimulation
- **Advantage:** Most noticeable consciously

### Bilateral Stimulation
- **Research:** Established in EMDR therapy literature
- **Mechanism:** Bilateral brain activation, calming effect
- **Use case:** Specific to trauma processing protocols

---

## Implementation Notes

All modes:
- Generate at 48kHz sample rate (default)
- Return stereo (left, right) channels
- Support volume adjustment (0.0 to 1.0)
- Apply anti-aliasing
- Prevent clipping

Isochronic mode:
- Applies 5ms smoothing to pulse edges (prevents clicks)
- Configurable duty cycle (default 50%)

Harmonic mode:
- Amplitude decreases with harmonic number (1/n)
- Normalized to prevent clipping

---

## Usage in GUI

The PhiWave GUI (v2.0) includes a mode selector:

1. Open PhiWave
2. Click "Mode" dropdown
3. Select desired mode
4. Configure parameters as normal
5. Play or export

All presets work with all modes - just switch mode and the same beat frequency applies.

---

## Advanced: Custom Modes

You can create custom generation functions:

```python
def my_custom_mode(carrier_hz, beat_hz, duration_sec, sample_rate=48000, volume=0.5):
    """Your custom audio generation"""
    t = np.linspace(0, duration_sec, int(sample_rate * duration_sec))
    
    # Your DSP code here
    left = volume * np.sin(2 * np.pi * carrier_hz * t)
    right = volume * np.sin(2 * np.pi * (carrier_hz + beat_hz) * t)
    
    return left, right

# Register it
from phiwave.modes import MODES
MODES['my_custom'] = my_custom_mode
```

---

## FAQ

**Q: Which mode is "best"?**  
A: Depends on your goal and environment. Binaural is classic and well-researched. Monaural is stronger. Isochronic is most noticeable. Try each!

**Q: Can I use monaural/isochronic without headphones?**  
A: Yes! That's their advantage. Play through speakers.

**Q: Why does bilateral mode sound different?**  
A: It alternates between ears rather than playing both simultaneously. This is intentional for EMDR protocols.

**Q: Do harmonic modes work better?**  
A: Subjective. Some find them more pleasant/musical. No evidence they're more effective for entrainment.

**Q: Can I combine modes?**  
A: Not directly, but you can layer multiple audio files in a DAW.

---

**Science first. Modes for flexibility. Choose what works for you.**
