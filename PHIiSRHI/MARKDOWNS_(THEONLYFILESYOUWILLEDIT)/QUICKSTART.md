# PhiLaunch Terminal - Quick Start Guide

Get up and running with PhiLaunch Terminal in 5 minutes!

## Prerequisites

- Linux system (Ubuntu, Debian, Fedora, Arch, etc.)
- Python 3.7 or higher
- Display with OpenGL support

## Installation (5 Steps)

### Step 1: Check Python

```bash
python3 --version
```

Should show Python 3.7 or higher. If not installed:

```bash
# Ubuntu/Debian
sudo apt install python3 python3-pip

# Fedora
sudo dnf install python3 python3-pip

# Arch
sudo pacman -S python python-pip
```

### Step 2: Install PyQt6

```bash
pip3 install PyQt6
```

Or with sudo for system-wide installation:

```bash
sudo pip3 install PyQt6
```

### Step 3: Install System Dependencies

```bash
# Ubuntu/Debian
sudo apt install python3-opengl libglu1-mesa libxcb-xinerama0 libxcb-cursor0

# Fedora
sudo dnf install mesa-libGLU qt6-qtbase

# Arch
sudo pacman -S glu qt6-base
```

### Step 4: Verify Installation

```bash
cd /home/user/PhiLaunch/philaunch_terminal
python3 test_terminal.py
```

Should show most tests passing.

### Step 5: Launch!

```bash
./launch-terminal.sh
```

🎉 **You're done!** The terminal should open.

## First Commands

Try these commands to test the terminal:

```bash
# Basic commands
ls
pwd
echo "Hello PhiLaunch!"

# Test colors
ls --color=auto
python3 -c "print('\x1b[31mRed\x1b[0m \x1b[32mGreen\x1b[0m \x1b[34mBlue\x1b[0m')"

# Test scrolling
cat /var/log/syslog
# or
journalctl -n 100

# Test command history
# Press Up/Down arrows to navigate previous commands

# Test tab completion
# Type "ls /ho" and press Tab

# Test clear screen
# Press Ctrl+L
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Ctrl+C** | Interrupt current command |
| **Ctrl+D** | Exit shell (or EOF) |
| **Ctrl+L** | Clear screen |
| **Ctrl+W** | Delete word backward |
| **Up/Down** | Navigate command history |
| **Tab** | Auto-complete |
| **Ctrl+Shift+C** | Copy (planned) |
| **Ctrl+Shift+V** | Paste (planned) |

## Window Controls

- **Drag title bar** to move window
- **− button** to minimize
- **□ button** to maximize/restore
- **✕ button** to close

## Customization

### Change Font Size

Edit `terminal_theme.py`:

```python
TERMINAL_FONTS = {
    'size': 14,  # Change from 12 to 14 (or any size)
    ...
}
```

### Change Colors

Edit `terminal_theme.py`:

```python
TERMINAL_COLORS = {
    'background': '#000000',  # Pure black instead of #0D0D0D
    'foreground': '#FFFFFF',  # Pure white instead of #CCCCCC
    ...
}
```

### Disable Borderless Mode

Edit `terminal_theme.py`:

```python
WINDOW_SETTINGS = {
    'borderless': False,  # Change from True to False
    ...
}
```

## Troubleshooting

### "No module named 'PyQt6'"

```bash
pip3 install PyQt6
# Or
sudo pip3 install PyQt6
```

### "libQt6Core.so.6: cannot open shared object file"

```bash
# Ubuntu/Debian
sudo apt install qt6-base-dev

# Fedora
sudo dnf install qt6-qtbase-devel
```

### Terminal window is blank or black

Check OpenGL support:

```bash
glxinfo | grep "OpenGL version"
```

If not installed:

```bash
sudo apt install mesa-utils libgl1-mesa-glx
```

### Text is blurry

1. Install custom fonts (White Rabbit, Kanit)
2. Adjust font size in `terminal_theme.py`
3. Check anti-aliasing settings are enabled

### Cannot drag window

Some window managers don't support dragging frameless windows. Try:

- Hold **Alt** key while dragging
- Set `borderless: False` in `terminal_theme.py`

## Next Steps

- Read [README.md](README.md) for full feature list
- Check [INSTALL.md](INSTALL.md) for detailed installation
- See [OVERVIEW.md](OVERVIEW.md) for technical details
- Install [PowerShell 7](INSTALL.md#optional-install-powershell-7) for full experience

## Getting Help

1. Check the documentation files in this directory
2. Run tests: `python3 test_terminal.py`
3. Check logs: Terminal prints errors to stdout
4. Open an issue on GitHub

## Enjoy!

You now have a beautiful, hardware-accelerated terminal with:

✓ Matrix theme
✓ Borderless design
✓ OpenGL acceleration
✓ Maximum anti-aliasing
✓ PowerShell-like features
✓ Full ANSI color support

Happy hacking! 🚀
