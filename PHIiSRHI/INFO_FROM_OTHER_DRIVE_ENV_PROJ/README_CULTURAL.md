# PhiWave Cultural Frequency Presets

PhiWave v2.0 includes culturally and spiritually significant frequencies.

**Transparency:** These frequencies have varying levels of scientific support. We include them because many users find them meaningful, while being clear about evidence levels.

---

## Quick Reference

### Schumann Resonance (Earth Frequencies)

| Frequency | Name | Scientific Basis | Use Case |
|-----------|------|------------------|----------|
| **7.83 Hz** | Fundamental | ✓ Documented | Grounding, natural rhythm |
| **14.3 Hz** | 2nd Harmonic | ✓ Documented | Alert relaxation |
| **20.8 Hz** | 3rd Harmonic | ✓ Documented | Enhanced awareness |

---

### Solfeggio Frequencies (Ancient Scale)

| Frequency | Name | Scientific Basis | Claimed Effects |
|-----------|------|------------------|-----------------|
| **174 Hz** | Foundation | ⚠ Anecdotal | Pain reduction, security |
| **285 Hz** | Healing | ⚠ Anecdotal | Tissue regeneration |
| **396 Hz** | Liberation | ⚠ Anecdotal | Release guilt/fear |
| **417 Hz** | Change | ⚠ Anecdotal | Breaking patterns |
| **528 Hz** | Miracles | ⚠ Anecdotal | "DNA repair" (unverified) |
| **639 Hz** | Connection | ⚠ Anecdotal | Relationships |
| **741 Hz** | Awakening | ⚠ Anecdotal | Intuition, detox (claimed) |
| **852 Hz** | Intuition | ⚠ Anecdotal | Spiritual insight |
| **963 Hz** | Divine | ⚠ Anecdotal | Universal connection |

---

### Special Tunings

| Frequency | Name | Scientific Basis | Note |
|-----------|------|------------------|------|
| **432 Hz** | Natural Tuning | ⚠ Debated | Alternative to 440 Hz concert pitch |

---

## Schumann Resonance

### What Is It?

The Schumann resonances are **electromagnetic standing waves** in the Earth-ionosphere cavity.

**Discovered:** W.O. Schumann (1952)  
**Measurement:** Confirmed by scientific instruments worldwide  
**Fundamental:** 7.83 Hz (varies slightly by location/time)

### Scientific Status: ✓ VERIFIED

- **Evidence:** Measurable electromagnetic phenomenon
- **Mechanism:** Lightning strikes excite the Earth-ionosphere cavity
- **Harmonics:** 14.3, 20.8, 27.3, 33.8 Hz (documented)

### Why Include It?

**Hypothesis:** Human brainwaves may synchronize with Earth's natural frequency  
**Research:** Limited but suggestive  
**Use case:** "Grounding" practices, natural rhythm alignment

---

### Using Schumann Frequencies

#### As Carrier Frequency:
```python
from phiwave.cultural_presets import get_schumann_fundamental

carrier = get_schumann_fundamental()  # 7.83 Hz
# Too low for carrier - use as beat frequency instead
```

#### As Beat Frequency (Recommended):
```python
from phiwave.modes import generate_binaural

left, right = generate_binaural(
    carrier_hz=180,
    beat_hz=7.83,  # Schumann fundamental
    duration_sec=600
)
```

---

## Solfeggio Frequencies

### What Are They?

Ancient 6-tone musical scale, later expanded to 9 tones.

**Origins:** Claimed to be from Gregorian chants  
**Revival:** Dr. Joseph Puleo (1970s)  
**Modern usage:** Alternative healing, meditation

### Scientific Status: ⚠ ANECDOTAL

- **Evidence:** No peer-reviewed studies on claimed effects
- **Mechanism:** Unproven
- **Popularity:** Widely used in wellness communities

### Why Include Them?

**Transparency:** Many users request these frequencies  
**Subjective effects:** Users report positive experiences  
**Placebo:** Expectation alone can have benefits

**Our stance:** We provide them without endorsing specific claims.

---

### Detailed Solfeggio Guide

#### 174 Hz - Foundation
**Claimed:** Pain reduction, grounding  
**Use as:** Carrier frequency (audible tone)  
**Combine with:** Delta (0.5-4 Hz) beat for deep relaxation

#### 285 Hz - Healing
**Claimed:** Cellular regeneration  
**Use as:** Carrier frequency  
**Combine with:** Theta (4-8 Hz) for restorative meditation

#### 396 Hz - Liberation
**Claimed:** Guilt and fear release  
**Use as:** Carrier frequency  
**Combine with:** Alpha (8-12 Hz) for emotional processing

#### 417 Hz - Change
**Claimed:** Breaking negative patterns  
**Use as:** Carrier frequency  
**Combine with:** Alpha/Beta for transformation work

#### 528 Hz - Miracles ("Love Frequency")
**Claimed:** DNA repair (NOT scientifically verified)  
**Popularity:** Most requested Solfeggio frequency  
**Use as:** Carrier frequency  
**Combine with:** Any beat frequency

**Critical note:** No peer-reviewed evidence for DNA effects.

#### 639 Hz - Connection
**Claimed:** Harmonizing relationships  
**Use as:** Carrier frequency  
**Combine with:** Alpha for social situations

#### 741 Hz - Awakening
**Claimed:** Problem-solving, self-expression  
**Use as:** Carrier frequency  
**Combine with:** Beta (13-30 Hz) for mental clarity

#### 852 Hz - Intuition
**Claimed:** Spiritual awakening, "third eye"  
**Use as:** Carrier frequency  
**Combine with:** Theta for meditation

#### 963 Hz - Divine Connection
**Claimed:** Highest consciousness, crown chakra  
**Use as:** Carrier frequency  
**Combine with:** Gamma (30+ Hz) for peak states

---

### Using Solfeggio in PhiWave

**Example:** 528 Hz carrier with 10 Hz Alpha beat

```python
from phiwave.cultural_presets import get_solfeggio_miracle
from phiwave.modes import generate_binaural

carrier = get_solfeggio_miracle()  # 528 Hz
beat = 10  # Alpha band

left, right = generate_binaural(
    carrier_hz=carrier,
    beat_hz=beat,
    duration_sec=900  # 15 minutes
)
```

**In GUI:**
1. Select "Cultural Frequencies" mode
2. Choose "528 Hz - Miracles"
3. Adjust beat frequency as desired
4. Play or export

---

## 432 Hz Tuning

### What Is It?

Alternative concert pitch (vs. standard 440 Hz A note).

**Standard:** A4 = 440 Hz (international standard since 1939)  
**Alternative:** A4 = 432 Hz (advocated by some musicians)

### Scientific Status: ⚠ DEBATED

- **Evidence:** No consistent proof of superiority
- **Subjective:** Some listeners prefer it
- **Theory:** "Mathematical harmony with nature" (not rigorously proven)

### Why Include It?

**Musical use:** Some composers/artists prefer 432 Hz  
**Subjective preference:** Valid personal choice  
**Exploration:** Interesting to compare

### Using 432 Hz

**As carrier frequency:**
```python
from phiwave.cultural_presets import get_natural_tuning

carrier = get_natural_tuning()  # 432 Hz

left, right = generate_binaural(
    carrier_hz=carrier,
    beat_hz=10,
    duration_sec=600
)
```

**Effect:** Slightly lower pitch than standard tuning (8 Hz difference).

---

## Combining Cultural & Scientific

### Recommended Combinations

**Grounding + Focus:**
- Schumann 7.83 Hz (beat) + 180 Hz carrier
- Scientific basis + traditional frequency

**Creativity + "Love":**
- 528 Hz Solfeggio (carrier) + 10 Hz Alpha (beat)
- Cultural frequency + proven brainwave band

**Deep Meditation:**
- 432 Hz natural tuning (carrier) + 4 Hz Theta (beat)
- Alternative tuning + deep meditation state

---

## Scientific Disclaimer

**What we know:**
- ✓ Schumann resonance exists (measurable)
- ✓ Binaural beats affect brainwaves (research-backed)
- ✓ Musical frequencies affect mood (subjective but real)

**What we don't know:**
- ❌ If 528 Hz repairs DNA
- ❌ If Solfeggio frequencies have unique healing properties
- ❌ If 432 Hz is objectively "better" than 440 Hz

**Our position:**
- Provide cultural frequencies users want
- Be transparent about evidence levels
- Let users explore and decide for themselves

---

## User Reports (Anecdotal)

**528 Hz:**
- "Feels calming"
- "Pleasant tone"
- "Good for meditation"

**Schumann 7.83 Hz:**
- "Grounding effect"
- "Natural feeling"
- "Helps with anxiety"

**432 Hz:**
- "Warmer sound"
- "Less harsh than 440 Hz"
- "Prefer it subjectively"

**Important:** These are subjective experiences. Your mileage may vary.

---

## FAQ

**Q: Are Solfeggio frequencies scientifically proven?**  
A: No. They have cultural/spiritual significance but no peer-reviewed evidence for specific healing claims.

**Q: Does 528 Hz really repair DNA?**  
A: No scientific evidence. This claim originated from alternative health circles, not research labs.

**Q: Is Schumann resonance measurable?**  
A: Yes! It's a real electromagnetic phenomenon. Whether it affects human consciousness is less clear.

**Q: Should I use 432 Hz or 440 Hz?**  
A: Personal preference. Try both and see which you prefer. No objective "right" answer.

**Q: Why include unproven frequencies?**  
A: Transparency. Many users want them. We provide them with clear evidence labels.

**Q: Can these frequencies hurt me?**  
A: No. They're just audio tones. Standard hearing safety applies (don't blast volume).

**Q: Which Solfeggio frequency should I start with?**  
A: 528 Hz is most popular. Or just use standard carriers (180 Hz) with proven beat frequencies.

---

## How to Choose

### Prioritize Science:
- Use standard carriers (100-200 Hz)
- Focus on beat frequencies (Delta, Theta, Alpha, Beta, Gamma)
- Skip cultural frequencies

### Explore Culture:
- Try Schumann 7.83 Hz (it's real + interesting)
- Experiment with Solfeggio if curious
- Use 432 Hz for alternative tuning

### Both:
- Schumann beat + standard carrier
- Solfeggio carrier + proven beat frequency
- Best of both worlds

---

## Preset Library

PhiWave v2.0 includes pre-built combinations:

**"Schumann Grounding"**
- 7.83 Hz beat (Schumann) + 180 Hz carrier
- 20 minutes, Delta/Theta blend

**"Miracle Frequency Meditation"**
- 528 Hz carrier + 8 Hz Theta beat
- 30 minutes, deep meditation

**"Natural Tuning Focus"**
- 432 Hz carrier + 10 Hz Alpha beat
- 15 minutes, focused work

**"Earth Connection"**
- 7.83 Hz beat + 432 Hz carrier
- 40 minutes, grounding session

Access: Presets → Cultural Frequencies

---

## References

### Schumann Resonance:
- Schumann, W.O. (1952). "Über die strahlungslosen Eigenschwingungen einer leitenden Kugel"
- NASA research on Schumann resonance measurements
- Multiple scientific papers confirming phenomenon

### Solfeggio:
- Dr. Joseph Puleo's claims (1970s-90s)
- No peer-reviewed validation found
- Extensive use in alternative healing communities

### 432 Hz:
- Debates in musical communities
- No consensus in acoustics research
- Subjective preference studies inconclusive

---

**Science first. Culture respected. Explore with open eyes.**
