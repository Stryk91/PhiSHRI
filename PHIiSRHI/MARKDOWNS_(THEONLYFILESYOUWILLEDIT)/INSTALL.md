# PhiLaunch Terminal - Installation Guide

## Prerequisites

### System Requirements

- **Operating System**: Linux (tested on Ubuntu 20.04+, Debian 11+)
- **Python**: 3.7 or higher
- **Display**: X11 or Wayland with OpenGL support
- **RAM**: Minimum 512MB, recommended 1GB+

### Check Python Version

```bash
python3 --version
```

Should output Python 3.7 or higher.

## Installation Steps

### 1. Install System Dependencies

#### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install Python 3 and pip
sudo apt install python3 python3-pip

# Install OpenGL libraries (required for acceleration)
sudo apt install python3-opengl libglu1-mesa

# Install Qt6 dependencies
sudo apt install libxcb-xinerama0 libxcb-cursor0
```

#### Fedora/RHEL

```bash
sudo dnf install python3 python3-pip
sudo dnf install mesa-libGLU
sudo dnf install qt6-qtbase
```

#### Arch Linux

```bash
sudo pacman -S python python-pip
sudo pacman -S glu qt6-base
```

### 2. Install Python Dependencies

```bash
cd /home/user/PhiLaunch/philaunch_terminal

# Install PyQt6 and dependencies
pip3 install -r requirements.txt

# Or install globally (may require sudo)
sudo pip3 install -r requirements.txt
```

### 3. Verify Installation

```bash
# Check PyQt6 installation
python3 -c "import PyQt6.QtWidgets; print('PyQt6 installed successfully!')"

# Check OpenGL support
python3 -c "from PyQt6.QtWidgets import QOpenGLWidget; print('OpenGL support available!')"
```

### 4. Optional: Install Custom Fonts

#### Install White Rabbit Font

```bash
# Download White Rabbit font (example)
mkdir -p ~/.local/share/fonts
# Place White Rabbit font files (.ttf) in ~/.local/share/fonts/
fc-cache -fv  # Rebuild font cache
```

#### Install Kanit Font

```bash
# Kanit is available on Google Fonts
wget https://fonts.google.com/download?family=Kanit -O kanit.zip
unzip kanit.zip -d ~/.local/share/fonts/kanit/
fc-cache -fv
```

### 5. Optional: Install PowerShell 7

For the full PowerShell experience:

#### Ubuntu/Debian (20.04+)

```bash
# Download PowerShell 7.4
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb

# Install package
sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb

# Fix any dependency issues
sudo apt-get install -f

# Verify installation
pwsh --version
```

#### Fedora/RHEL

```bash
# Import Microsoft repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
sudo dnf install powershell

# Verify
pwsh --version
```

#### Arch Linux

```bash
# Install from AUR
yay -S powershell-bin

# Or use snap
sudo snap install powershell --classic
```

## Launch Terminal

### Method 1: Using Launcher Script

```bash
cd /home/user/PhiLaunch/philaunch_terminal
./launch-terminal.sh
```

### Method 2: Direct Python Execution

```bash
cd /home/user/PhiLaunch/philaunch_terminal
python3 philaunch_terminal.py
```

### Method 3: Create Desktop Shortcut

Create `~/.local/share/applications/philaunch-terminal.desktop`:

```desktop
[Desktop Entry]
Name=PhiLaunch Terminal
Comment=OpenGL-accelerated terminal with Matrix theme
Exec=/home/user/PhiLaunch/philaunch_terminal/launch-terminal.sh
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
```

Then:

```bash
chmod +x ~/.local/share/applications/philaunch-terminal.desktop
```

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'PyQt6'"

**Solution**: Install PyQt6:

```bash
pip3 install PyQt6
```

### Issue: "ImportError: libQt6Core.so.6: cannot open shared object file"

**Solution**: Install Qt6 system libraries:

```bash
# Ubuntu/Debian
sudo apt install qt6-base-dev

# Fedora
sudo dnf install qt6-qtbase-devel
```

### Issue: OpenGL errors or black screen

**Solution**: Verify OpenGL drivers are installed:

```bash
# Check OpenGL version
glxinfo | grep "OpenGL version"

# Install Mesa drivers (if needed)
sudo apt install mesa-utils libgl1-mesa-glx
```

### Issue: Terminal text is blurry or pixelated

**Solution**: Check anti-aliasing settings in `terminal_theme.py`:

- Ensure `ANTIALIASING['subpixel'] = True`
- Adjust font size in `TERMINAL_FONTS['size']`
- Try different fonts if White Rabbit is not installed

### Issue: Fonts not found

**Solution**: The terminal will automatically fall back to Courier New or other system monospace fonts. To use custom fonts:

1. Install fonts to `~/.local/share/fonts/`
2. Run `fc-cache -fv`
3. Verify with `fc-list | grep "Font Name"`

### Issue: High CPU usage

**Solution**:
- Reduce cursor blink rate in `terminal_theme.py`
- Disable syntax highlighting for better performance
- Reduce scrollback buffer size

### Issue: Cannot drag borderless window

**Solution**: This is a known limitation on some window managers. Try:

- Using a different window manager (KDE, GNOME, XFCE all work)
- Holding Alt key while dragging (works on most WMs)
- Disable borderless mode in `terminal_theme.py` (set `WINDOW_SETTINGS['borderless'] = False`)

## Performance Optimization

### For Low-End Systems

Edit `terminal_theme.py`:

```python
# Reduce anti-aliasing
ANTIALIASING = {
    'enabled': True,
    'subpixel': False,  # Disable subpixel
    'hinting': 'slight',  # Reduce hinting
}

# Reduce buffer size
TERMINAL_BEHAVIOR = {
    'scroll_buffer': 1000,  # Reduce from 10000
}
```

### For High-End Systems

Edit `terminal_theme.py`:

```python
# Maximum quality
ANTIALIASING = {
    'enabled': True,
    'subpixel': True,
    'hinting': 'full',
    'lcd_filter': 'default',
    'gamma': 1.0,
}
```

## Uninstallation

```bash
# Remove Python packages
pip3 uninstall PyQt6 PyQt6-WebEngine

# Remove application files
rm -rf /home/user/PhiLaunch/philaunch_terminal

# Remove desktop shortcut
rm ~/.local/share/applications/philaunch-terminal.desktop
```

## Getting Help

If you encounter issues:

1. Check the logs (terminal will print errors to stdout)
2. Verify all dependencies are installed
3. Try running with `python3 -v philaunch_terminal.py` for verbose output
4. Open an issue on the PhiLaunch GitHub repository

## Next Steps

After installation, check out:
- [README.md](README.md) - Feature overview and usage
- [terminal_theme.py](terminal_theme.py) - Customize colors and fonts
- [CONFIGURATION.md](CONFIGURATION.md) - Advanced configuration options
