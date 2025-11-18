# PhiWave Audio Quality & EQ System

PhiWave v2.0 includes audio quality validation and headphone EQ compensation.

## Quick Start

### Validate Your Audio

**One-Click Test:**

1. Open Settings (⚙️ icon)
2. Click "Test Audio Quality"
3. Wait 3 seconds
4. See result: ✓ PERFECT or ⚠ WARNING

**What it tests:** Verifies PhiWave generates frequencies with <0.1 Hz error.

---

## Audio Backend Selection

### WASAPI Exclusive Mode (Recommended)

**What it does:** Bypasses Windows audio processing for bit-perfect output

**Advantages:**
- No Windows audio effects (Dolby, EQ, etc.)
- Zero resampling artifacts
- Lowest latency
- Perfect frequency accuracy

**Disadvantages:**
- Locks audio device (other apps can't use it)
- Windows only

**When to use:**
- Critical listening sessions
- Maximum accuracy needed
- You want pristine, unprocessed audio

**How to enable:**
1. Settings → Audio Backend
2. Select "WASAPI Exclusive"
3. Test with one-click validator

---

### Shared Mode (Default)

**What it does:** Uses Windows audio stack (normal mode)

**Advantages:**
- Other apps can use audio simultaneously
- No setup required
- Works everywhere

**Disadvantages:**
- Windows may resample/process audio
- Potential for small frequency errors (<0.5 Hz typically)

**When to use:**
- Casual listening
- You need other audio apps running (Spotify, YouTube, etc.)
- Good enough for most use cases

---

## Headphone EQ Profiles

### Why EQ Matters

Different headphones have different frequency responses:
- **ANC headphones** boost bass (makes beats feel "punchier" than intended)
- **Budget earbuds** weak sub-bass (<60 Hz)
- **Open-back** generally flat (trust them)

PhiWave's EQ compensates for these differences.

---

### Available Profiles

#### 1. **Open-Back (Default)**
**Target hardware:** Sennheiser HD 6XX, Beyerdynamic DT 990, AKG K701  
**EQ:** Flat (no adjustments)  
**When to use:** Studio headphones, audiophile cans, anything with flat response

#### 2. **Closed-Back**
**Target hardware:** Portable headphones, gaming headsets  
**EQ:** +1dB @ 60-200Hz (compensate for sealed ear cups)  
**When to use:** Non-ANC closed headphones

#### 3. **ANC/Noise-Cancelling**
**Target hardware:** Sony WH-1000XM, Bose QC, Apple AirPods Max  
**EQ:** -3dB @ 40-150Hz, high-pass @ 30Hz  
**Special:** Shifts carrier frequencies up 40Hz to avoid ANC bass boost zone  
**When to use:** ANY headphones with active noise cancellation

---

### Selecting a Profile

1. Settings → Headphone Type
2. Choose your headphone category
3. Done!

**Not sure?** Use "Open-Back" as default. It works for most headphones.

---

## Advanced EQ (Power Users)

### Custom 5-Band EQ

**Access:** Settings → Advanced EQ Settings

**Bands:**
- 60 Hz (Sub-bass)
- 200 Hz (Bass)
- 1 kHz (Midrange)
- 4 kHz (Presence)
- 10 kHz (Air)

**Range:** ±12dB per band

**Use cases:**
- Compensate for specific headphone models
- Personal preference adjustments
- Room acoustics compensation

---

### Saving Custom Profiles

1. Adjust EQ bands to your liking
2. Click "Save Profile"
3. Name it (e.g., "My Sony WH-1000XM5")
4. Load anytime from Profile Library

### Sharing Profiles

Export as JSON:
```json
{
  "name": "My Custom Profile",
  "description": "Tuned for Sony WH-1000XM5",
  "eq_bands": {
    "60": -2,
    "200": -1,
    "1000": 0,
    "4000": 0,
    "10000": 1
  }
}
```

Share with other PhiWave users!

---

## Technical Details

### Sample Rate

**Default:** 48kHz (professional standard)  
**Options:** 44.1kHz, 48kHz, 96kHz (in Advanced Settings)

**Recommendation:** Use 48kHz unless you have a specific reason to change.

**Auto-matching:** PhiWave detects your device's native sample rate and matches it automatically in WASAPI Exclusive mode.

---

### Bit Depth

**Default:** 16-bit (more than sufficient for binaural beats)  
**Options:** 16-bit, 24-bit (in Advanced Settings)

**Why 16-bit is fine:** Binaural beats are simple sine waves. 16-bit provides 96dB dynamic range - way more than needed.

---

### EQ Implementation

**Filter type:** Parametric peaking filters (scipy.signal.iirpeak)  
**Q factor:** 1.0 (moderate bandwidth)  
**Normalization:** Automatic to prevent clipping

**Processing order:**
1. Generate pure audio
2. Apply EQ
3. Apply high-pass filter (if ANC mode)
4. Normalize

---

## Validation Details

### Quick Validation

**Duration:** 3 seconds  
**Method:** FFT analysis of exported WAV file  
**Tolerance:** 0.1 Hz

**What it checks:**
- Carrier frequency accuracy
- File export integrity
- No Windows audio mangling

---

### Detailed Validation

**Duration:** 10 seconds  
**Tests:**
1. Sample count accuracy
2. Frequency precision (FFT)
3. Phase alignment (L/R channels)
4. Amplitude consistency
5. No clipping

**Access:** Settings → Advanced → Detailed Validation

---

## Troubleshooting

### Validation Failed

**"Error: 2.5 Hz"**

Likely causes:
- Windows audio effects enabled
- Incorrect sample rate
- System resampling

**Fix:**
1. Switch to WASAPI Exclusive mode
2. Disable Windows "Audio Enhancements"
3. Re-run validation

---

### WASAPI Exclusive Won't Enable

**"Device is already in use"**

**Cause:** Another app is using your audio device

**Fix:**
1. Close Spotify, YouTube, Chrome, etc.
2. Retry
3. Or use Shared Mode instead

---

### Audio Sounds "Wrong"

**Possible issues:**
- Wrong headphone profile selected
- Custom EQ too extreme
- Volume too low/high

**Fix:**
1. Reset EQ to default
2. Select correct headphone profile
3. Test with one-click validator

---

## FAQ

**Q: Do I need WASAPI Exclusive?**  
A: No. Shared mode works fine for 99% of use cases. Exclusive mode is for perfectionists.

**Q: Will EQ make a big difference?**  
A: Depends on your headphones. ANC compensation is most noticeable. Open-back needs no EQ.

**Q: Can I use PhiWave's EQ with other audio?**  
A: No, EQ only applies to PhiWave-generated audio.

**Q: Should I enable high-pass filter?**  
A: Only if using ANC mode. Otherwise, no need.

**Q: My headphones aren't listed - which profile?**  
A: Start with "Open-Back". If they have ANC, use "ANC". If closed but no ANC, use "Closed-Back".

**Q: Does validation prove my headphones work correctly?**  
A: No. It proves PhiWave's generation is accurate. Headphone quality is separate.

---

## Best Practices

### For Maximum Quality:

1. ✅ Use WASAPI Exclusive mode
2. ✅ Select correct headphone profile
3. ✅ Run one-click validation
4. ✅ Match sample rate to your DAC
5. ✅ Use quality headphones (20Hz-20kHz response)

### For Casual Use:

1. ✅ Use Shared mode (default)
2. ✅ Select headphone profile once
3. ✅ Enjoy!

---

## Technical Specifications

**EQ:**
- Type: 5-band parametric
- Range: ±12dB
- Bands: 60, 200, 1000, 4000, 10000 Hz
- Q Factor: 1.0

**Audio Backend:**
- Shared Mode: Windows MME/WASAPI
- Exclusive Mode: WASAPI Exclusive
- Sample Rates: 44.1, 48, 96 kHz
- Bit Depths: 16, 24-bit

**Validation:**
- Method: FFT analysis
- Precision: 0.001 Hz theoretical, 0.1 Hz tolerance
- Duration: 3-10 seconds
- Export format: WAV (temporary)

---

**Bit-perfect audio. Transparent compensation. Your hardware, your choice.**
