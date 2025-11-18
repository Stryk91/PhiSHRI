# Windows Automation Suite - Installation Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Component Installation](#component-installation)
4. [Configuration](#configuration)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- **Operating System**: Windows 10 (version 1809 or later) or Windows 11
- **PowerShell**: Version 5.1 or higher
- **Administrator Privileges**: Required for most components
- **.NET Framework**: 4.7.2 or higher
- **Disk Space**: Minimum 500 MB free space

### Required Software
1. **PowerShell 5.1+** (Built into Windows 10/11)
2. **AutoHotkey** (Download from https://www.autohotkey.com/)
3. **Microsoft PowerToys** (Download from https://github.com/microsoft/PowerToys/releases)
4. **SteelSeries Engine** (Optional - for gaming peripherals)

---

## Quick Start

### 1. Extract the Suite
Extract the `WindowsAutomationSuite` folder to a permanent location:
```
Recommended: C:\AutomationSuite\
```

### 2. Set Execution Policy
Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Install PowerShell Module
```powershell
# Navigate to the suite directory
cd C:\AutomationSuite\PowerShell\Modules

# Import the module
Import-Module .\AutomationToolkit.psm1

# Add to profile for automatic loading (optional)
$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force
}
Add-Content -Path $profilePath -Value "Import-Module C:\AutomationSuite\PowerShell\Modules\AutomationToolkit.psm1"
```

### 4. Test Installation
```powershell
# Test system info script
.\PowerShell\Scripts\Core\Get-SystemInfo.ps1

# Test quick system info function
Get-QuickSystemInfo
```

---

## Component Installation

### PowerShell Scripts

#### Core Scripts
Located in `PowerShell\Scripts\Core\`:

1. **Get-SystemInfo.ps1** - System information utility
   ```powershell
   # Basic usage
   .\Get-SystemInfo.ps1
   
   # Export to file
   .\Get-SystemInfo.ps1 -ExportPath "C:\Reports\SystemInfo.txt" -Format Text
   
   # Export as HTML
   .\Get-SystemInfo.ps1 -ExportPath "C:\Reports\SystemInfo.html" -Format HTML
   ```

2. **Clean-SystemFiles.ps1** - System cleanup utility
   ```powershell
   # Dry run (see what would be cleaned)
   .\Clean-SystemFiles.ps1 -DryRun
   
   # Full cleanup
   .\Clean-SystemFiles.ps1 -IncludeBrowserCache -IncludeRecycleBin
   ```

3. **Manage-Files.ps1** - File management utility
   ```powershell
   # Organize files by extension
   .\Manage-Files.ps1 -Action Organize -Path "C:\Downloads" -OrganizeBy Extension
   
   # Find duplicate files
   .\Manage-Files.ps1 -Action FindDuplicates -Path "C:\Documents" -Recursive
   
   # Batch rename
   .\Manage-Files.ps1 -Action Rename -Path "C:\Photos" -Pattern "Vacation_{0:D3}"
   ```

#### Automation Scripts
Located in `PowerShell\Scripts\Automation\`:

1. **Backup-UserData.ps1** - Automated backup utility
   ```powershell
   # Full backup
   .\Backup-UserData.ps1 -SourcePaths "C:\Users\John\Documents","C:\Users\John\Pictures" -DestinationPath "D:\Backups"
   
   # Incremental backup with 7-day retention
   .\Backup-UserData.ps1 -SourcePaths "C:\Projects" -DestinationPath "\\NAS\Backups" -BackupType Incremental -RetentionDays 7
   ```

2. **Schedule-Tasks.ps1** - Task scheduler utility
   ```powershell
   # Create daily backup task
   .\Schedule-Tasks.ps1 -Action Create -TaskName "DailyBackup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Automation\Backup-UserData.ps1" -Schedule Daily -Time "02:00"
   
   # List all tasks
   .\Schedule-Tasks.ps1 -Action List
   ```

#### Administrative Scripts
Located in `PowerShell\Scripts\Admin\`:

1. **Manage-Services.ps1** - Service management utility
   ```powershell
   # Check service status
   .\Manage-Services.ps1 -Action Status -ServiceName "wuauserv"
   
   # List running services
   .\Manage-Services.ps1 -Action List -Filter Running
   
   # Monitor a service
   .\Manage-Services.ps1 -Action Monitor -ServiceName "wuauserv" -MonitorInterval 5
   ```

---

### PowerToys Configuration

#### Installation
1. Download PowerToys from: https://github.com/microsoft/PowerToys/releases
2. Install PowerToys
3. Import the provided configuration:

```powershell
# Backup existing settings (optional)
Copy-Item "$env:LOCALAPPDATA\Microsoft\PowerToys" "$env:LOCALAPPDATA\Microsoft\PowerToys.backup" -Recurse

# Copy custom settings
Copy-Item "C:\AutomationSuite\PowerToys\Configs\PowerToys-Settings.json" "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json"
```

#### FancyZones Setup
1. Open PowerToys Settings
2. Navigate to FancyZones
3. Click "Launch layout editor" (Win+Shift+`)
4. Import custom layouts from `PowerToys\FancyZones\Layouts.json`

**Custom Layouts Included:**
- **Coding Layout** - 3 columns (25% | 50% | 25%)
- **Productivity** - 4 equal quadrants
- **Content Creation** - Main + sidebar (70% | 30%)
- **Video Editing** - Timeline focus layout
- **Research** - 3 horizontal zones
- **Presentation Mode** - 80% main + 20% notes
- **Gaming/Streaming** - Multi-zone layout
- **Ultrawide Coding** - 4 columns optimized
- **Data Analysis** - 6 equal zones
- **Focus Mode** - Centered with margins

**Quick Layout Shortcuts:**
- `Ctrl+Win+Alt+1` - Coding Layout
- `Ctrl+Win+Alt+2` - Productivity Layout
- `Ctrl+Win+Alt+3` - Content Creation
- `Ctrl+Win+Alt+4` - Video Editing
- `Ctrl+Win+Alt+5` - Focus Mode

---

### AutoHotkey Scripts

#### Installation
1. Download AutoHotkey from: https://www.autohotkey.com/
2. Install AutoHotkey v1.1 (not v2)
3. Set up the master script:

```powershell
# Create startup shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AutomationSuite.lnk")
$Shortcut.TargetPath = "C:\AutomationSuite\AutoHotkey\MasterScript.ahk"
$Shortcut.Save()
```

4. Run the script:
   - Double-click `MasterScript.ahk`
   - Or right-click and select "Run Script"

#### Configuration
Edit `AutoHotkey\config.ini` to customize:
```ini
[Settings]
EnableLogging=1
ShowNotifications=1
EnableTextExpansion=1

[WindowManagement]
SnapToEdges=1
MultiMonitorSupport=1
```

#### Hotkey Reference
Press `Win+H` while the script is running to see all available hotkeys.

**Key Features:**
- Window management (snap, move, opacity, always-on-top)
- Application launchers
- Clipboard history (Win+V)
- Text expansion
- Mouse gestures for volume control
- Virtual desktop management

---

### Voice Commands

#### Setup
1. Enable Windows Speech Recognition:
   ```powershell
   cd C:\AutomationSuite\VoiceCommands
   .\VoiceCommandSetup.ps1 -Install
   ```

2. Configure voice commands:
   ```powershell
   .\VoiceCommandSetup.ps1 -Configure
   ```

3. Test voice recognition:
   ```powershell
   .\VoiceCommandSetup.ps1 -Test
   ```

4. Train Windows Speech Recognition:
   - Press `Win+Ctrl+S` to start Speech Recognition
   - Follow the setup wizard
   - Complete the voice training tutorial

#### Usage
Say "Computer" followed by a command:
- "Computer, open browser"
- "Computer, open file explorer"
- "Computer, maximize window"
- "Computer, volume up"
- "Computer, lock computer"

---

### SteelSeries Macros

#### Setup (for SteelSeries peripherals)
1. Install SteelSeries Engine from: https://steelseries.com/engine
2. Open SteelSeries Engine
3. Select your device
4. Navigate to the Macros section
5. Import configurations from `SteelSeries\MacroConfigurations.json`

#### Profiles Included
- **Productivity Profile** - Screenshots, task manager, window management
- **Development Profile** - Terminal, build commands, git shortcuts
- **Media Control Profile** - Playback controls, volume
- **Window Management Profile** - Snap, maximize, minimize
- **Automation Workflow Profile** - Script triggers, system commands

#### Alternative Software
If you don't have SteelSeries peripherals:
- **Razer Synapse** - For Razer devices
- **Logitech G HUB** - For Logitech devices
- **Corsair iCUE** - For Corsair devices
- **AutoHotkey** - Software-based alternative

---

### Daemon Service

#### Installation
```powershell
# Navigate to daemon directory
cd C:\AutomationSuite\DaemonService\Source

# Install as service
.\AutomationDaemon.ps1 -Action Install

# Start the service
.\AutomationDaemon.ps1 -Action Start

# Check status
.\AutomationDaemon.ps1 -Action Status
```

#### Configuration
Edit `DaemonService\Config\daemon-config.json`:

**File Watchers:**
```json
{
  "name": "Downloads Monitor",
  "enabled": true,
  "path": "C:\\Users\\YourUsername\\Downloads",
  "filter": "*.*",
  "events": ["Created", "Changed"],
  "actions": [
    {
      "type": "log",
      "message": "File {FileName} was {EventType}"
    }
  ]
}
```

**Process Watchers:**
```json
{
  "name": "High CPU Monitor",
  "enabled": true,
  "process_name": "*",
  "cpu_threshold": 80,
  "memory_threshold_mb": 2000,
  "actions": [
    {
      "type": "notification",
      "title": "High Resource Usage",
      "message": "{ProcessName} is using {CPU}% CPU"
    }
  ]
}
```

#### Management Commands
```powershell
# Start service
.\AutomationDaemon.ps1 -Action Start

# Stop service
.\AutomationDaemon.ps1 -Action Stop

# Check status
.\AutomationDaemon.ps1 -Action Status

# Uninstall service
.\AutomationDaemon.ps1 -Action Uninstall

# Run in foreground (for testing)
.\AutomationDaemon.ps1 -Action Run
```

---

## Configuration

### Update Paths
After installation, update paths in configuration files:

1. **Daemon Config** (`DaemonService\Config\daemon-config.json`):
   - Replace `C:\\Users\\YourUsername` with your actual username
   - Update backup destinations
   - Adjust monitoring paths

2. **SteelSeries Macros** (`SteelSeries\MacroConfigurations.json`):
   - Update script paths if not using `C:\AutomationSuite`

3. **Voice Commands** (`VoiceCommands\VoiceCommandSetup.ps1`):
   - Update script paths in XML configuration

### Customize Settings

#### PowerShell Module
Add custom functions to `PowerShell\Modules\AutomationToolkit.psm1`

#### AutoHotkey
Add custom hotkeys to `AutoHotkey\MasterScript.ahk`

#### Daemon Service
Add custom watchers and triggers to `DaemonService\Config\daemon-config.json`

---

## Troubleshooting

### PowerShell Scripts Won't Run
**Issue**: "Execution policy" error

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### AutoHotkey Script Not Starting
**Issue**: Script doesn't run on startup

**Solution**:
1. Check if AutoHotkey is installed
2. Verify startup shortcut exists
3. Run script manually to check for errors

### Daemon Service Not Starting
**Issue**: Service fails to start

**Solution**:
```powershell
# Check logs
Get-Content "C:\AutomationSuite\DaemonService\Logs\daemon.log" -Tail 50

# Run in foreground to see errors
.\AutomationDaemon.ps1 -Action Run
```

### Voice Commands Not Working
**Issue**: Commands not recognized

**Solution**:
1. Ensure microphone is enabled and working
2. Complete Windows Speech Recognition training
3. Test with: `.\VoiceCommandSetup.ps1 -Test`

### PowerToys FancyZones Not Working
**Issue**: Windows don't snap to zones

**Solution**:
1. Ensure PowerToys is running (check system tray)
2. Press `Win+Shift+\`` to open zone editor
3. Check if zones are configured for your monitor
4. Hold Shift while dragging windows to snap

### High CPU Usage
**Issue**: Scripts consuming too much CPU

**Solution**:
1. Adjust daemon check intervals in config
2. Disable unnecessary file watchers
3. Reduce process monitoring frequency

---

## Next Steps

1. **Review Documentation**: Read `USAGE_GUIDE.md` for detailed usage instructions
2. **Customize**: Adjust configurations to match your workflow
3. **Test**: Run scripts in safe mode before automating critical tasks
4. **Backup**: Create backups of your configurations
5. **Monitor**: Check logs regularly for issues

---

## Support

For issues or questions:
1. Check the logs in respective component directories
2. Review the troubleshooting section
3. Consult the usage guide for detailed examples

---

**Version**: 1.0  
**Last Updated**: 2024