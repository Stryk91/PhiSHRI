# PhiLaunch Terminal

A custom terminal emulator with PhiLaunch's Matrix-inspired theme, OpenGL acceleration, and PowerShell 7-inspired features.

## Features

- **Borderless Window Design** - Sleek, modern UI with custom title bar
- **OpenGL 3D Acceleration** - Hardware-accelerated text rendering
- **Maximum Anti-Aliasing** - Enhanced subpixel rendering for crisp text
- **PhiLaunch Theme** - Soft fade Matrix colors optimized for eye comfort
- **PowerShell-like Features**:
  - Command history (Up/Down arrows)
  - Tab completion
  - ANSI color support
  - Syntax highlighting
  - 10,000 line scrollback buffer

## Installation

### Requirements

- Python 3.7+
- PyQt6 >= 6.4.0
- Linux/Unix system with PTY support

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Optional: Install PowerShell 7

The terminal works with any shell (bash, zsh, etc.), but you can install PowerShell 7 for the full experience:

```bash
# Download and install PowerShell 7 (Ubuntu/Debian)
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb
sudo dpkg -i powershell_7.4.0-1.deb_amd64.deb
sudo apt-get install -f
```

## Usage

### Launch Terminal

```bash
./launch-terminal.sh
```

Or directly with Python:

```bash
python3 philaunch_terminal.py
```

### Keyboard Shortcuts

- **Ctrl+C** - Interrupt (SIGINT)
- **Ctrl+D** - End of file (exit shell)
- **Ctrl+L** - Clear screen
- **Ctrl+W** - Delete word backward
- **Up/Down** - Command history navigation
- **Tab** - Auto-completion
- **Ctrl+Shift+C** - Copy selection (planned)
- **Ctrl+Shift+V** - Paste (planned)

### Window Controls

- **Minimize** - Click − button in title bar
- **Maximize** - Click □ button in title bar
- **Close** - Click ✕ button in title bar
- **Drag** - Click and drag title bar to move window

## Font Configuration

The terminal uses:
- **Primary Font**: White Rabbit (monospace terminal text)
  - Fallback: Courier New
- **Emphasis Font**: Kanit Regular (UI elements, title bar)

To install custom fonts, place them in the `fonts/` directory and they will be loaded automatically.

## Theme

Colors are based on PhiLaunch's Soft Fade Matrix theme:

- **Background**: Lifted blacks (#0D0D0D) for reduced eye strain
- **Foreground**: Soft gray (#CCCCCC) for readability
- **Accent**: Matrix green (#00EE00) for highlights
- **ANSI Colors**: Full 16-color palette support

## Architecture

```
philaunch_terminal/
├── philaunch_terminal.py    # Main window & UI
├── terminal_pty.py           # PTY backend for shell interaction
├── terminal_renderer.py      # OpenGL-accelerated text renderer
├── terminal_theme.py         # Theme integration & colors
├── launch-terminal.sh        # Launcher script
├── requirements.txt          # Python dependencies
└── fonts/                    # Custom fonts directory
```

## Future Enhancements

- [ ] SSH integration (connect to remote hosts)
- [ ] MCP (Model Context Protocol) integration
- [ ] Copy/paste support
- [ ] Split panes
- [ ] Tabs for multiple sessions
- [ ] Custom keybindings
- [ ] Configurable transparency
- [ ] Ligature support
- [ ] GPU-accelerated scrolling

## License

Part of the PhiLaunch automation suite.
