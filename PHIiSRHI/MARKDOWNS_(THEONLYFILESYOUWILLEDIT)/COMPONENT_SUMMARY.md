# Component Summary - Windows Automation Suite

## Overview
This document provides a quick reference for all components in the Windows Automation Suite.

---

## 1. PowerShell Scripts

### Location
`PowerShell/Scripts/`

### Components

#### Core Scripts (`Core/`)
| Script | Purpose | Key Parameters |
|--------|---------|----------------|
| `Get-SystemInfo.ps1` | System information | `-ExportPath`, `-Format` |
| `Clean-SystemFiles.ps1` | System cleanup | `-IncludeBrowserCache`, `-IncludeRecycleBin`, `-DryRun` |
| `Manage-Files.ps1` | File management | `-Action`, `-Path`, `-OrganizeBy`, `-Pattern` |

#### Automation Scripts (`Automation/`)
| Script | Purpose | Key Parameters |
|--------|---------|----------------|
| `Backup-UserData.ps1` | Automated backups | `-SourcePaths`, `-DestinationPath`, `-BackupType`, `-RetentionDays` |
| `Schedule-Tasks.ps1` | Task scheduler | `-Action`, `-TaskName`, `-ScriptPath`, `-Schedule` |

#### Admin Scripts (`Admin/`)
| Script | Purpose | Key Parameters |
|--------|---------|----------------|
| `Manage-Services.ps1` | Service management | `-Action`, `-ServiceName`, `-StartupType`, `-Filter` |

### PowerShell Module
**Location**: `PowerShell/Modules/AutomationToolkit.psm1`

**Key Functions**:
- `Get-QuickSystemInfo` - Quick system summary
- `Get-DiskSpaceInfo` - Disk space information
- `Get-LargeFiles` - Find large files
- `Get-OldFiles` - Find old files
- `Get-ProcessInfo` - Process information
- `Get-NetworkInfo` - Network adapter info
- `Invoke-QuickCleanup` - Quick cleanup

---

## 2. PowerToys Configuration

### Location
`PowerToys/`

### Files
- `Configs/PowerToys-Settings.json` - Main PowerToys configuration
- `FancyZones/Layouts.json` - Custom zone layouts

### FancyZones Layouts

| Layout | Shortcut | Description |
|--------|----------|-------------|
| Coding Layout | `Ctrl+Win+Alt+1` | 3 columns (25% \| 50% \| 25%) |
| Productivity | `Ctrl+Win+Alt+2` | 4 equal quadrants |
| Content Creation | `Ctrl+Win+Alt+3` | Main + sidebar (70% \| 30%) |
| Video Editing | `Ctrl+Win+Alt+4` | Timeline focus layout |
| Focus Mode | `Ctrl+Win+Alt+5` | Centered with margins |

### PowerToys Features Configured
- **PowerToys Run**: `Alt+Space` launcher
- **FancyZones**: Window management
- **Color Picker**: `Win+Shift+C`
- **PowerRename**: Context menu integration
- **Keyboard Manager**: Key remapping
- **Text Extractor**: `Win+Shift+T`
- **Mouse Utilities**: Find my mouse, highlighter
- **Always On Top**: `Win+Ctrl+T`

---

## 3. AutoHotkey Scripts

### Location
`AutoHotkey/`

### Files
- `MasterScript.ahk` - Main automation script
- `config.ini` - Configuration file

### Hotkey Categories

#### Window Management
| Hotkey | Action |
|--------|--------|
| `Win+Alt+Left` | Snap left |
| `Win+Alt+Right` | Snap right |
| `Win+Alt+Up` | Maximize |
| `Win+Alt+Down` | Center |
| `Win+Ctrl+Left/Right` | Move to monitor |
| `Win+Ctrl+T` | Always on top toggle |
| `Win+Ctrl+O` | Opacity toggle |

#### Application Launchers
| Hotkey | Application |
|--------|-------------|
| `Win+Ctrl+Shift+T` | Terminal |
| `Win+Ctrl+Shift+E` | File Explorer |
| `Win+Ctrl+Shift+N` | Notepad |
| `Win+Ctrl+Shift+B` | Browser |
| `Win+Ctrl+Shift+C` | Calculator |

#### Clipboard
| Hotkey | Action |
|--------|--------|
| `Win+V` | Show history |
| `Win+Ctrl+Shift+V` | Clear history |

#### Text Expansion
- `ddate` → Current date
- `ttime` → Current time
- `@gmail` → @gmail.com
- `brb` → be right back
- `ty` → thank you

#### Mouse Gestures
- `MButton+WheelUp` → Volume up
- `MButton+WheelDown` → Volume down
- `MButton` → Mute toggle

---

## 4. Voice Commands

### Location
`VoiceCommands/`

### Files
- `VoiceCommandSetup.ps1` - Setup and configuration script

### Command Categories

#### Application Control
- "Computer, open browser"
- "Computer, open file explorer"
- "Computer, open notepad"
- "Computer, open calculator"
- "Computer, open terminal"

#### Window Management
- "Computer, minimize window"
- "Computer, maximize window"
- "Computer, close window"
- "Computer, switch window"

#### System Commands
- "Computer, lock computer"
- "Computer, show desktop"
- "Computer, open task manager"

#### Volume Control
- "Computer, volume up"
- "Computer, volume down"
- "Computer, mute"

#### Custom Scripts
- "Computer, run backup"
- "Computer, system information"

---

## 5. SteelSeries Macros

### Location
`SteelSeries/`

### Files
- `MacroConfigurations.json` - Macro definitions

### Profiles

#### Productivity Profile
| Key | Action |
|-----|--------|
| G1 | Screenshot |
| G2 | Task Manager |
| G3 | Lock Workstation |
| G4 | Show Desktop |
| G5 | Previous Virtual Desktop |
| G6 | Next Virtual Desktop |

#### Development Profile
| Key | Action |
|-----|--------|
| G1 | Open Terminal |
| G2 | Run Build |
| G3 | Git Status |
| G4 | Comment Block |
| G5 | Console.log() |
| G6 | Format Document |

#### Media Control Profile
| Key | Action |
|-----|--------|
| G1 | Play/Pause |
| G2 | Next Track |
| G3 | Previous Track |
| G4 | Volume Up |
| G5 | Volume Down |
| G6 | Mute |

#### Window Management Profile
| Key | Action |
|-----|--------|
| G1 | Snap Left |
| G2 | Snap Right |
| G3 | Maximize |
| G4 | Minimize |
| G5 | Close Window |
| G6 | Switch Window |

#### Automation Workflow Profile
| Key | Action |
|-----|--------|
| G1 | System Cleanup |
| G2 | System Info |
| G3 | Start Backup |
| G4 | PowerToys Settings |
| G5 | Restart Explorer |

---

## 6. Daemon Service

### Location
`DaemonService/`

### Files
- `Source/AutomationDaemon.ps1` - Main daemon script
- `Config/daemon-config.json` - Configuration file
- `Logs/daemon.log` - Log file

### Features

#### File System Monitoring
- Watch folders for changes
- Trigger actions on file events
- Support for multiple watchers
- Configurable filters and events

#### Process Monitoring
- Monitor CPU and memory usage
- Alert on threshold violations
- Track specific processes
- Configurable check intervals

#### Scheduled Tasks
- Daily, weekly, monthly schedules
- Time-based execution
- Script and command support

#### Triggers
- Disk space monitoring
- Network connectivity checks
- Custom event triggers

### Management Commands
```powershell
.\AutomationDaemon.ps1 -Action Install   # Install service
.\AutomationDaemon.ps1 -Action Start     # Start service
.\AutomationDaemon.ps1 -Action Stop      # Stop service
.\AutomationDaemon.ps1 -Action Status    # Check status
.\AutomationDaemon.ps1 -Action Uninstall # Remove service
.\AutomationDaemon.ps1 -Action Run       # Run in foreground
```

---

## Integration Points

### Component Interactions

```
┌─────────────────┐
│  User Input     │
│  (Hotkey/Voice) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────┐
│  AutoHotkey     │────▶│  PowerShell  │
│  Voice Commands │     │  Scripts     │
└─────────────────┘     └──────┬───────┘
         │                     │
         │                     ▼
         │              ┌──────────────┐
         │              │  Daemon      │
         │              │  Service     │
         │              └──────┬───────┘
         │                     │
         ▼                     ▼
┌─────────────────┐     ┌──────────────┐
│  PowerToys      │     │  System      │
│  FancyZones     │     │  Actions     │
└─────────────────┘     └──────────────┘
```

### Example Workflows

1. **Automated Backup**
   - Daemon detects file change
   - Triggers PowerShell backup script
   - Logs action and sends notification

2. **Quick Cleanup**
   - User presses SteelSeries G-key
   - Runs PowerShell cleanup script
   - AutoHotkey shows completion notification

3. **Workspace Setup**
   - Voice command activates FancyZones layout
   - AutoHotkey launches applications
   - Windows snap to designated zones

---

## File Locations Reference

```
C:\AutomationSuite\
├── PowerShell\
│   ├── Modules\AutomationToolkit.psm1
│   └── Scripts\
│       ├── Core\*.ps1
│       ├── Automation\*.ps1
│       └── Admin\*.ps1
├── PowerToys\
│   ├── Configs\PowerToys-Settings.json
│   └── FancyZones\Layouts.json
├── AutoHotkey\
│   ├── MasterScript.ahk
│   └── config.ini
├── VoiceCommands\
│   └── VoiceCommandSetup.ps1
├── SteelSeries\
│   └── MacroConfigurations.json
├── DaemonService\
│   ├── Source\AutomationDaemon.ps1
│   ├── Config\daemon-config.json
│   └── Logs\daemon.log
└── Documentation\
    ├── README.md
    ├── QUICK_START.md
    ├── INSTALLATION_GUIDE.md
    ├── USAGE_GUIDE.md
    └── COMPONENT_SUMMARY.md
```

---

## Quick Reference Commands

### PowerShell
```powershell
# Import module
Import-Module C:\AutomationSuite\PowerShell\Modules\AutomationToolkit.psm1

# System info
Get-QuickSystemInfo

# Cleanup
.\Clean-SystemFiles.ps1 -DryRun

# Backup
.\Backup-UserData.ps1 -SourcePaths "C:\Documents" -DestinationPath "D:\Backups"
```

### Daemon Service
```powershell
# Install and start
.\AutomationDaemon.ps1 -Action Install
.\AutomationDaemon.ps1 -Action Start

# Check status
.\AutomationDaemon.ps1 -Action Status

# View logs
Get-Content ..\Logs\daemon.log -Tail 50
```

### Voice Commands
```powershell
# Setup
.\VoiceCommandSetup.ps1 -Install
.\VoiceCommandSetup.ps1 -Configure
.\VoiceCommandSetup.ps1 -Test
```

---

**Version**: 1.0  
**Last Updated**: 2024