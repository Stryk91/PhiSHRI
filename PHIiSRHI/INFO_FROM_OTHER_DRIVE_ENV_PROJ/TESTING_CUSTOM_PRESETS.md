# 🧪 Testing Guide: Custom Preset Manager

## Quick Test (5 minutes)

### 1. Launch GUI
```batch
python phiwave_gui.py
```

### 2. Save a Custom Preset
1. **Adjust sliders** to your preferred values:
   - Carrier: 150 Hz
   - Beat: 10 Hz (Alpha)
   - Duration: 10 minutes
   - Volume: 30%

2. **Click "💾 Save Custom"** button

3. **Enter name** in dialog:
   ```
   My Focus Session
   ```

4. **Click OK**

5. **Verify:**
   - Preset appears in dropdown
   - Marked with ⭐ star
   - Appears in "My Custom Presets" section at top
   - Delete button becomes enabled

### 3. Delete the Custom Preset
1. **Select** the custom preset you just created (⭐ My Focus Session)

2. **Click "🗑 Delete"** button

3. **Confirm deletion** in dialog

4. **Verify:**
   - Preset removed from dropdown
   - Selection returns to "Custom"
   - Delete button becomes disabled

### 4. Test Persistence
1. **Create another custom preset** (any values, any name)

2. **Close the GUI** completely

3. **Reopen GUI:**
   ```batch
   python phiwave_gui.py
   ```

4. **Verify:**
   - Custom preset still appears in dropdown
   - Still marked with ⭐
   - Can still be deleted

## Visual Guide

```
┌─────────────────────────────────────┐
│  PhiWave GUI                        │
├─────────────────────────────────────┤
│                                     │
│  Preset:                            │
│  ┌───────────────────────────────┐ │
│  │ Custom                      ▼ │ │  ← Dropdown
│  └───────────────────────────────┘ │
│                                     │
│  ┌──────────────┐  ┌──────────┐   │
│  │ 💾 Save Custom│  │ 🗑 Delete│   │  ← New buttons
│  └──────────────┘  └──────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Dropdown with Custom Preset:
```
┌─────────────────────────────────────┐
│ Custom                              │
│ ─ My Custom Presets ─               │  ← New section
│   ⭐ My Focus Session (10.0 Hz)     │  ← Custom preset
│   ⭐ Deep Meditation (5.0 Hz)       │
│ ─ Binaural - Fibonacci ─            │  ← Built-in presets
│   BN Fib 8 (8.0 Hz)                 │
│   BN Fib 13 (13.0 Hz)               │
└─────────────────────────────────────┘
```

## Expected Behavior

### Save Custom Button
- ✅ Always enabled
- ✅ Opens name input dialog
- ✅ Validates preset name (non-empty)
- ✅ Saves immediately to disk
- ✅ Updates dropdown instantly
- ✅ Shows success message
- ✅ Shows error if validation fails

### Delete Button
- ✅ Disabled when "Custom" selected
- ✅ Disabled when built-in preset selected
- ✅ Enabled only when custom preset (⭐) selected
- ✅ Shows confirmation dialog
- ✅ Removes from dropdown on confirm
- ✅ Saves changes to disk immediately

### Dropdown
- ✅ Custom presets at top
- ✅ Marked with ⭐ star
- ✅ Built-in presets below
- ✅ Grouped by category
- ✅ Shows beat frequency in parentheses

## Validation Tests

### Valid Presets (Should Save)
```
✅ Carrier: 100 Hz, Beat: 8 Hz, Duration: 300s, Volume: 0.25
✅ Carrier: 125 Hz, Beat: 15 Hz, Duration: 1800s, Volume: 1.0
✅ Carrier: 60 Hz, Beat: 0.5 Hz, Duration: 10s, Volume: 0.05
```

### Invalid Presets (Should Reject)
```
❌ Beat: 50 Hz (too high, max is 15 Hz)
❌ Carrier: 40 Hz (too low, min is 60 Hz)
❌ Volume: 1.5 (too high, max is 1.0)
❌ Duration: 5s (too short, min is 10s)
```

## Error Messages

You should see helpful error messages for:
- Empty preset name
- Invalid parameters (out of range)
- File system errors
- Duplicate names (auto-resolved with suffix)

## File Location

Check that the file was created:

**Windows:**
```
C:\Users\<YourUsername>\.phiwave\custom_presets.json
```

**Contents should look like:**
```json
{
  "schema_version": "1.0",
  "last_updated": "2025-10-26T...",
  "custom_presets": [
    {
      "id": "custom_my_focus_session",
      "name": "My Focus Session",
      "category": "Custom",
      "mode": "binaural",
      "carrier_hz": 150.0,
      "beat_hz": 10.0,
      "duration_sec": 600,
      "volume": 0.3,
      "tags": ["custom", "user-created"],
      "description": "Custom preset: 10.0Hz binaural at 150.0Hz carrier"
    }
  ],
  "custom_ramps": []
}
```

## Common Issues

### Delete Button Stays Disabled
- **Cause:** Built-in preset selected
- **Fix:** Select a custom preset (marked with ⭐)

### Custom Preset Not Appearing
- **Cause:** Save failed or validation error
- **Fix:** Check console for error messages

### Preset Lost After Restart
- **Cause:** File system permissions or wrong path
- **Fix:** Check `~/.phiwave/` directory exists and is writable

## Advanced Testing

### Test Automated Script
```batch
python test_custom_presets.py
```

Should output:
```
============================================================
Testing Custom Preset Manager
============================================================

1. Creating CustomPresetManager...
   ✓ Manager created

2. Adding test presets...
   ✓ Added: Deep Focus Alpha
   ✓ Added: Quick Meditation
   ✓ Added: Energy Boost Beta

[... more tests ...]

✓ All tests passed!
```

## Success Criteria

All of these should work:
- [ ] Can save custom preset with any valid parameters
- [ ] Custom preset persists after app restart
- [ ] Custom preset appears at top of dropdown with ⭐
- [ ] Can delete custom preset with confirmation
- [ ] Delete button only enabled for custom presets
- [ ] Error messages shown for invalid parameters
- [ ] Success messages shown on save
- [ ] File created in correct location
- [ ] No crashes or exceptions

---

**If all tests pass:** ✅ Task 2 is complete and working!

**If issues found:** Report them with specific steps to reproduce.
