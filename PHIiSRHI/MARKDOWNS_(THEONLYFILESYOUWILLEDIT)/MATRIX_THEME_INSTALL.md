# Matrix Terminal Theme Installation

**For the ultimate Matrix hacking aesthetic with scanlines, phosphor glow, and CRT effects.**

## Features

- ✓ Pure black background (#000000)
- ✓ Neon green phosphor text (#00FF00)
- ✓ CRT scanline effect
- ✓ Phosphor glow/bloom
- ✓ Screen flicker
- ✓ Vignette (CRT edge darkness)
- ✓ White Rabbit font

---

## Option 1: Windows Terminal (Recommended)

### 1. Install the Theme

1. Open Windows Terminal
2. Press `Ctrl + ,` to open settings
3. Click "Open JSON file" (bottom left)
4. In the `"profiles"` → `"list"` section, add to your Kali profile:

```json
{
    "name": "Kali-Matrix",
    "commandline": "wsl.exe -d kali-linux",
    "colorScheme": "PhiVector Matrix",
    "font": {
        "face": "White Rabbit",
        "size": 12
    },
    "opacity": 95,
    "useAcrylic": false,
    "experimental.retroTerminalEffect": true,
    "experimental.pixelShaderPath": "matrix_scanlines.hlsl"
}
```

### 2. Add the Color Scheme

In the same JSON file, add to `"schemes"`:

```json
{
    "name": "PhiVector Matrix",
    "background": "#000000",
    "foreground": "#00FF00",
    "cursor": "#00FF00",
    "cursorAccent": "#000000",
    "selection": "#003300",
    "selectionBackground": "#00FF00",

    "black": "#000000",
    "red": "#00FF00",
    "green": "#00FF00",
    "yellow": "#00FF00",
    "blue": "#008F11",
    "purple": "#00FF00",
    "cyan": "#00FF00",
    "white": "#00FF00",

    "brightBlack": "#003300",
    "brightRed": "#00FF00",
    "brightGreen": "#00FF00",
    "brightYellow": "#00FF00",
    "brightBlue": "#00CC00",
    "brightPurple": "#00FF00",
    "brightCyan": "#00FF00",
    "brightWhite": "#FFFFFF"
}
```

### 3. Install Scanline Shader (Optional but AWESOME)

1. Copy `matrix_scanlines.hlsl` to:
   ```
   %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\
   ```

2. Update your profile's shader path:
   ```json
   "experimental.pixelShaderPath": "matrix_scanlines.hlsl"
   ```

3. Restart Windows Terminal

---

## Option 2: VS Code Integrated Terminal

1. Open VS Code
2. Press `Ctrl + ,` for settings
3. Click "Open Settings (JSON)" (top right icon)
4. Add the contents of `matrix_vscode_theme.json`

---

## Option 3: Quick Bash Theme (No Install)

For a quick Matrix look without installing:

```bash
# Add to ~/.bashrc
export PS1='\[\033[1;32m\][\u@\h \W]\$\[\033[0m\] '
export LS_COLORS='di=1;32:fi=0;32:ln=1;36:*.txt=0;32'
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'

# Matrix green prompt
clear && echo -e "\033[1;32mThe Matrix has you...\033[0m"
```

---

## Font Setup

**White Rabbit font** should already be installed in your PhiGEN project:
```
E:\PythonProjects\PhiGEN\assets\fonts\White Rabbit\
```

**To install system-wide:**
1. Right-click the font files
2. Select "Install for all users"
3. Restart terminal

---

## Testing the Theme

Run your fake hack script with the theme active:

```bash
~/fake_hack_extended.sh
```

With:
- Matrix theme ✓
- Kali dragon background ✓
- Flyleaf - I'm So Sick ✓
- CRT scanlines ✓
- All 8 fingers ✓

**You are now in the Matrix.**

---

## Advanced: Matrix Rain Background

For the falling code effect behind your terminal:

```bash
# Install cmatrix
sudo apt install cmatrix

# Run in a separate pane/window
cmatrix -C green -u 2 -s
```

Or use your Kali dragon wallpaper at 5-10% opacity with the green variant.

---

## Troubleshooting

**Scanlines not working:**
- Ensure GPU acceleration is enabled in Windows Terminal
- Check shader file path is correct
- Restart Windows Terminal

**Font not showing:**
- Install White Rabbit font system-wide
- Fallback: Use "Consolas" or "Courier New"

**Colors look wrong:**
- Verify color scheme name matches exactly: "PhiVector Matrix"
- Check JSON syntax (no trailing commas)

---

## Pro Tips for Recording

1. **Full screen** Windows Terminal
2. **Disable** desktop wallpaper or use pure black
3. **Hide taskbar** (auto-hide in Windows settings)
4. **OBS settings**:
   - 60 FPS for smooth scanlines
   - Screen capture with cursor visible
   - Audio: System + mic (for Flyleaf + keyboard sounds)
5. **Lighting**: Dim room, green LED strips for ambiance
6. **Camera angle**: Over-the-shoulder shot of furious typing

---

**Welcome to the real world.**
