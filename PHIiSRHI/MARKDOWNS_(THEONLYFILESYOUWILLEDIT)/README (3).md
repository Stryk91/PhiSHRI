# PhiLaunch Control Center GUI

Tactical automation dashboard for PhiLaunch remote execution framework.

## Features

- **Three-Pane Layout**: Script tree | Live output | Quick actions
- **Real-time Monitoring**: System metrics, tmux sessions, live output streaming
- **Automation Integration**: Direct integration with home-control.sh, launch-script.sh, start-long-task.sh
- **Tactical Aesthetic**: Matrix-themed with eye-strain optimized colors
- **Remote Access**: Works via SSH X forwarding from phone/tablet

## Quick Start

```bash
cd ~/philaunch_gui
./launch-gui.sh
```

## Requirements

- Python 3.7+
- PyQt6 (`pip3 install PyQt6`)
- X Server (WSLg on Windows 11, or VcXsrv/Xming on Windows 10)
- tmux (for background task management)

## Remote Access (SSH X Forwarding)

From your phone or another device:

```bash
# With WireGuard connected
ssh -X stryk@192.168.50.149 -p 2222

# Launch GUI
cd ~/philaunch_gui
./launch-gui.sh
```

The GUI will appear on your device!

## Features Overview

### Left Pane: Script Navigation
- Browse automation scripts
- View monitoring scripts
- See running tmux tasks
- Click to select

### Middle Pane: Live Output
- Real-time task output
- System status results
- Timestamped logs
- Auto-scrolling

### Right Pane: Quick Actions
- Run selected script
- Stop active task
- View system logs
- Restart SSH server
- Open phone shortcuts

### Top Toolbar
- CPU usage indicator
- RAM usage indicator
- Active task count
- SSH server status
- Quick action buttons

## Integration with PhiLaunch

The GUI integrates seamlessly with your existing PhiLaunch automation:

- **Scripts**: Automatically detects scripts in ~/automation/ and ~/
- **Tasks**: Shows live tmux sessions from start-long-task.sh
- **Status**: Calls home-control.sh status for system overview
- **Remote**: Works with SSH and WireGuard setup

## Customization

### Colors
Edit `philaunch_colors.py` to customize the color scheme.

### Refresh Interval
Default: 2 seconds. Change in `PhiLaunchControlCenter.__init__()`:
```python
self.refresh_timer.start(2000)  # milliseconds
```

### VS Code Refinements
See `divert.json` for tasks that VS Code Claude can handle:
- Add tooltips and keyboard shortcuts
- Optimize polling and memory usage
- Add advanced features (favorites, history, etc.)

## Architecture

- **Framework**: PyQt6 (modern Qt6 bindings)
- **Pattern**: Single-window frameless design
- **Threading**: Background workers for all I/O operations
- **Signals**: Thread-safe UI updates via PyQt signals

## Files

```
philaunch_gui/
├── philaunch_gui.py      # Main application (800+ lines)
├── philaunch_colors.py   # Color palette constants
├── launch-gui.sh         # Startup script with checks
├── divert.json           # VS Code Claude tasks
└── README.md             # This file
```

## Troubleshooting

### GUI doesn't launch
```bash
# Check X server
echo $DISPLAY  # Should show :0 or similar

# WSL users
wsl --update  # Install WSLg (Windows 11)
```

### PyQt6 not found
```bash
pip3 install PyQt6
```

### Can't see tmux sessions
```bash
# Ensure tmux is installed
sudo apt-get install tmux

# Check existing sessions
tmux list-sessions
```

### SSH X forwarding doesn't work
```bash
# Ensure X11Forwarding is enabled in SSH config
sudo nano /etc/ssh/sshd_config
# Add: X11Forwarding yes
# Add: X11DisplayOffset 10
sudo systemctl restart ssh
```

## Development

Built following PhiVector GUI implementation patterns:
- Frameless window with custom dragging
- Multi-layer background support (ready for textures)
- Factory method pattern for components
- DPI scaling prevention for pixel-perfect rendering
- Thread-safe signal/slot communication

## Credits

- Built for PhiLaunch automation framework
- Based on PhiVector Control Center architecture
- Matrix theme with eye-strain optimizations
- Authors: Stryk, JC, WEBC

---

**Version**: 1.0
**Last Updated**: 2025-11-12
