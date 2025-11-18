# Windows Automation Suite - Usage Guide

## Table of Contents
1. [PowerShell Scripts](#powershell-scripts)
2. [PowerToys & FancyZones](#powertoys--fancyzones)
3. [AutoHotkey Automation](#autohotkey-automation)
4. [Voice Commands](#voice-commands)
5. [SteelSeries Macros](#steelseries-macros)
6. [Daemon Service](#daemon-service)
7. [Integration Examples](#integration-examples)
8. [Best Practices](#best-practices)

---

## PowerShell Scripts

### System Information

#### Get Comprehensive System Info
```powershell
# Display in console
.\Get-SystemInfo.ps1

# Export to text file
.\Get-SystemInfo.ps1 -ExportPath "C:\Reports\SystemInfo.txt" -Format Text

# Export to HTML report
.\Get-SystemInfo.ps1 -ExportPath "C:\Reports\SystemInfo.html" -Format HTML

# Export to JSON
.\Get-SystemInfo.ps1 -ExportPath "C:\Reports\SystemInfo.json" -Format JSON
```

#### Quick System Info (Module Function)
```powershell
# Import module first
Import-Module C:\AutomationSuite\PowerShell\Modules\AutomationToolkit.psm1

# Get quick system summary
Get-QuickSystemInfo

# Get disk space info
Get-DiskSpaceInfo

# Get network info
Get-NetworkInfo
```

### System Cleanup

#### Dry Run (Preview)
```powershell
# See what would be cleaned without deleting
.\Clean-SystemFiles.ps1 -DryRun
```

#### Basic Cleanup
```powershell
# Clean temp files and Windows cache
.\Clean-SystemFiles.ps1
```

#### Full Cleanup
```powershell
# Include browser cache and recycle bin
.\Clean-SystemFiles.ps1 -IncludeBrowserCache -IncludeRecycleBin

# With custom log path
.\Clean-SystemFiles.ps1 -IncludeBrowserCache -LogPath "C:\Logs\Cleanup.log"
```

### File Management

#### Organize Files
```powershell
# Organize by file extension
.\Manage-Files.ps1 -Action Organize -Path "C:\Downloads" -OrganizeBy Extension

# Organize by date
.\Manage-Files.ps1 -Action Organize -Path "C:\Documents" -OrganizeBy Date -Recursive

# Organize by size
.\Manage-Files.ps1 -Action Organize -Path "C:\Media" -OrganizeBy Size
```

#### Find Duplicate Files
```powershell
# Find duplicates in folder
.\Manage-Files.ps1 -Action FindDuplicates -Path "C:\Photos"

# Find duplicates recursively
.\Manage-Files.ps1 -Action FindDuplicates -Path "C:\Documents" -Recursive

# Find specific file types
.\Manage-Files.ps1 -Action FindDuplicates -Path "C:\Music" -Filter "*.mp3" -Recursive
```

#### Batch Rename Files
```powershell
# Rename with pattern (Photo_001, Photo_002, etc.)
.\Manage-Files.ps1 -Action Rename -Path "C:\Photos\Vacation" -Pattern "Vacation_{0:D3}"

# Rename specific file types
.\Manage-Files.ps1 -Action Rename -Path "C:\Documents" -Pattern "Report_{0:D2}" -Filter "*.pdf"
```

### Automated Backups

#### Full Backup
```powershell
# Backup single folder
.\Backup-UserData.ps1 -SourcePaths "C:\Users\John\Documents" -DestinationPath "D:\Backups"

# Backup multiple folders
.\Backup-UserData.ps1 -SourcePaths "C:\Users\John\Documents","C:\Users\John\Pictures","C:\Projects" -DestinationPath "D:\Backups"

# Backup with verification
.\Backup-UserData.ps1 -SourcePaths "C:\Important" -DestinationPath "\\NAS\Backups" -Verify
```

#### Incremental Backup
```powershell
# Incremental backup (only changed files)
.\Backup-UserData.ps1 -SourcePaths "C:\Projects" -DestinationPath "D:\Backups" -BackupType Incremental

# With custom retention
.\Backup-UserData.ps1 -SourcePaths "C:\Data" -DestinationPath "D:\Backups" -BackupType Incremental -RetentionDays 7
```

### Scheduled Tasks

#### Create Tasks
```powershell
# Daily backup at 2 AM
.\Schedule-Tasks.ps1 -Action Create -TaskName "DailyBackup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Automation\Backup-UserData.ps1" -Schedule Daily -Time "02:00" -RunAsAdmin

# Weekly cleanup on Sunday
.\Schedule-Tasks.ps1 -Action Create -TaskName "WeeklyCleanup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Core\Clean-SystemFiles.ps1" -Schedule Weekly -Time "03:00"

# Run at startup
.\Schedule-Tasks.ps1 -Action Create -TaskName "StartupScript" -ScriptPath "C:\Scripts\Startup.ps1" -Schedule Startup
```

#### Manage Tasks
```powershell
# List all tasks
.\Schedule-Tasks.ps1 -Action List

# Enable/disable task
.\Schedule-Tasks.ps1 -Action Enable -TaskName "DailyBackup"
.\Schedule-Tasks.ps1 -Action Disable -TaskName "DailyBackup"

# Delete task
.\Schedule-Tasks.ps1 -Action Delete -TaskName "OldTask"

# Export task
.\Schedule-Tasks.ps1 -Action Export -TaskName "DailyBackup" -ExportPath "C:\Backups\task.xml"
```

### Service Management

#### Check Service Status
```powershell
# Get detailed service info
.\Manage-Services.ps1 -Action Status -ServiceName "wuauserv"

# List all services
.\Manage-Services.ps1 -Action List -Filter All

# List only running services
.\Manage-Services.ps1 -Action List -Filter Running

# List stopped services
.\Manage-Services.ps1 -Action List -Filter Stopped
```

#### Control Services
```powershell
# Start service
.\Manage-Services.ps1 -Action Start -ServiceName "wuauserv"

# Stop service
.\Manage-Services.ps1 -Action Stop -ServiceName "wuauserv"

# Restart service
.\Manage-Services.ps1 -Action Restart -ServiceName "wuauserv"

# Change startup type
.\Manage-Services.ps1 -Action SetStartup -ServiceName "wuauserv" -StartupType Manual
```

#### Monitor Services
```powershell
# Monitor service in real-time
.\Manage-Services.ps1 -Action Monitor -ServiceName "wuauserv" -MonitorInterval 5

# Check dependencies
.\Manage-Services.ps1 -Action Dependencies -ServiceName "wuauserv"
```

---

## PowerToys & FancyZones

### PowerToys Run (Alt+Space)

#### Quick Launcher
- `Alt+Space` - Open PowerToys Run
- Type application name to launch
- Use direct activation phrases:
  - `>` - Programs (e.g., `>notepad`)
  - `=` - Calculator (e.g., `=2+2`)
  - `$` - Shell commands (e.g., `$ipconfig`)
  - `.` - Window switcher (e.g., `.chrome`)
  - `/` - Folder navigation (e.g., `/documents`)
  - `?` - Web search (e.g., `?weather`)
  - `:` - Registry (e.g., `:HKLM`)
  - `!` - Services (e.g., `!wuauserv`)
  - `@` - Time/Date (e.g., `@now`)
  - `%%` - Unit converter (e.g., `%%100 USD to EUR`)

### FancyZones

#### Using Zones
1. **Drag with Shift**: Hold `Shift` while dragging windows to snap to zones
2. **Quick Layouts**: Use `Ctrl+Win+Alt+[1-5]` to switch layouts
3. **Zone Editor**: Press `Win+Shift+\`` to open layout editor

#### Custom Layouts

**Coding Layout (Ctrl+Win+Alt+1)**
- Left: File explorer (25%)
- Center: Code editor (50%)
- Right: Terminal/output (25%)

**Productivity Layout (Ctrl+Win+Alt+2)**
- Four equal quadrants for multitasking

**Content Creation (Ctrl+Win+Alt+3)**
- Main workspace (70%)
- Side panel for tools (30%)

**Video Editing (Ctrl+Win+Alt+4)**
- Preview (top-left, 60%x70%)
- Tools (top-right, 60%x30%)
- Timeline (bottom, 40%x100%)

**Focus Mode (Ctrl+Win+Alt+5)**
- Single centered zone with margins

### Color Picker (Win+Shift+C)
1. Press `Win+Shift+C`
2. Click on any color on screen
3. Color code copied to clipboard
4. View color history in picker

### PowerRename
1. Select files in Explorer
2. Right-click → PowerRename
3. Use regex for advanced renaming
4. Preview changes before applying

### Image Resizer
1. Select images in Explorer
2. Right-click → Resize pictures
3. Choose preset or custom size
4. Images resized in place or new folder

### Text Extractor (Win+Shift+T)
1. Press `Win+Shift+T`
2. Select area with text
3. Text extracted and copied to clipboard

---

## AutoHotkey Automation

### Window Management

#### Snap Windows
- `Win+Alt+Left` - Snap to left half
- `Win+Alt+Right` - Snap to right half
- `Win+Alt+Up` - Maximize window
- `Win+Alt+Down` - Center window

#### Multi-Monitor
- `Win+Ctrl+Left` - Move window to left monitor
- `Win+Ctrl+Right` - Move window to right monitor

#### Window Properties
- `Win+Ctrl+T` - Toggle always on top
- `Win+Ctrl+O` - Toggle window opacity (78% / 100%)

### Application Launchers
- `Win+Ctrl+Shift+T` - Windows Terminal
- `Win+Ctrl+Shift+E` - File Explorer
- `Win+Ctrl+Shift+N` - Notepad
- `Win+Ctrl+Shift+B` - Default Browser
- `Win+Ctrl+Shift+C` - Calculator

### Clipboard Management

#### Clipboard History
- `Win+V` - Show clipboard history (last 10 items)
- Select item to paste
- `Win+Ctrl+Shift+V` - Clear clipboard history

### Text Expansion

#### Date & Time
- `ddate` → Current date (YYYY-MM-DD)
- `ttime` → Current time (HH:MM:SS)
- `ddatetime` → Date and time

#### Email Shortcuts
- `@gmail` → @gmail.com
- `@outlook` → @outlook.com
- `@yahoo` → @yahoo.com

#### Common Phrases
- `brb` → be right back
- `omw` → on my way
- `ty` → thank you
- `lmk` → let me know
- `fyi` → for your information
- `asap` → as soon as possible

#### Programming
- `func` → function
- `ret` → return
- `cons` → console.log();
- `comm` → /* */

#### Symbols
- `shrug` → ¯\_(ツ)_/¯
- `check` → ✓
- `cross` → ✗
- `arrow` → →

### Mouse Gestures
- `Middle Button + Wheel Up` - Volume up
- `Middle Button + Wheel Down` - Volume down
- `Middle Button Click` - Mute toggle

### Virtual Desktops
- `Win+Ctrl+Left` - Previous desktop
- `Win+Ctrl+Right` - Next desktop
- `Win+Ctrl+D` - New desktop
- `Win+Ctrl+F4` - Close desktop

### Script Control
- `Win+H` - Show hotkey help
- Right-click tray icon → Suspend to pause hotkeys
- Right-click tray icon → Reload to restart script

---

## Voice Commands

### Setup & Training
1. Press `Win+Ctrl+S` to start Speech Recognition
2. Complete voice training for better accuracy
3. Say "Computer" to activate listening mode
4. Speak command clearly

### Available Commands

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

#### Text Editing
- "Computer, select all"
- "Computer, copy that"
- "Computer, paste that"
- "Computer, undo that"

#### Custom Scripts
- "Computer, run backup"
- "Computer, system information"

### Tips for Better Recognition
- Speak clearly and at normal pace
- Use consistent phrasing
- Train voice recognition regularly
- Minimize background noise
- Use a quality microphone

---

## SteelSeries Macros

### Profile Switching
1. Open SteelSeries Engine
2. Select your device
3. Choose profile from dropdown
4. Macros automatically assigned to G-keys

### Productivity Profile
- **G1**: Quick Screenshot (Win+Shift+S)
- **G2**: Task Manager (Ctrl+Shift+Esc)
- **G3**: Lock Workstation (Win+L)
- **G4**: Show Desktop (Win+D)
- **G5**: Previous Virtual Desktop
- **G6**: Next Virtual Desktop

### Development Profile
- **G1**: Open Terminal
- **G2**: Run Build (npm run build)
- **G3**: Git Status
- **G4**: Insert Comment Block
- **G5**: Console.log()
- **G6**: Format Document (Shift+Alt+F)

### Media Control Profile
- **G1**: Play/Pause
- **G2**: Next Track
- **G3**: Previous Track
- **G4**: Volume Up
- **G5**: Volume Down
- **G6**: Mute Toggle

### Window Management Profile
- **G1**: Snap Left
- **G2**: Snap Right
- **G3**: Maximize
- **G4**: Minimize
- **G5**: Close Window
- **G6**: Switch Window

### Automation Workflow Profile
- **G1**: Run System Cleanup
- **G2**: Get System Info
- **G3**: Start Backup
- **G4**: Open PowerToys Settings
- **G5**: Restart Explorer

---

## Daemon Service

### Starting the Daemon
```powershell
# Start service
.\AutomationDaemon.ps1 -Action Start

# Run in foreground (for testing)
.\AutomationDaemon.ps1 -Action Run
```

### Monitoring

#### File System Monitoring
The daemon watches specified folders and triggers actions on file events:

**Example: Downloads Monitor**
- Watches: `C:\Users\YourUsername\Downloads`
- Events: File created, changed, deleted
- Actions: Log event, show notification

**Example: Document Backup Trigger**
- Watches: `C:\Users\YourUsername\Documents\*.docx`
- Events: File changed
- Actions: Trigger backup script

#### Process Monitoring
Monitors system processes and alerts on threshold violations:

**Example: High CPU Monitor**
- Monitors: All processes
- Thresholds: CPU > 80%, Memory > 2GB
- Actions: Log warning, show notification

**Example: Chrome Memory Monitor**
- Monitors: Chrome processes
- Thresholds: Memory > 1.5GB
- Actions: Log usage statistics

### Configuration

#### Adding File Watcher
Edit `daemon-config.json`:
```json
{
  "name": "My Custom Watcher",
  "enabled": true,
  "path": "C:\\MyFolder",
  "filter": "*.txt",
  "include_subdirectories": false,
  "events": ["Created", "Changed"],
  "actions": [
    {
      "type": "log",
      "message": "File {FileName} was {EventType}"
    },
    {
      "type": "script",
      "path": "C:\\Scripts\\ProcessFile.ps1",
      "arguments": "-FilePath '{FullPath}'"
    }
  ]
}
```

#### Adding Process Watcher
```json
{
  "name": "Monitor Specific App",
  "enabled": true,
  "process_name": "myapp",
  "cpu_threshold": 50,
  "memory_threshold_mb": 500,
  "check_interval": 30,
  "actions": [
    {
      "type": "notification",
      "title": "High Usage Alert",
      "message": "{ProcessName} using {CPU}% CPU"
    }
  ]
}
```

### Variables
Use variables in actions:
- `{FileName}` - File name
- `{FullPath}` - Full file path
- `{EventType}` - Event type (Created, Changed, etc.)
- `{Timestamp}` - Event timestamp
- `{ProcessName}` - Process name
- `{CPU}` - CPU usage percentage
- `{Memory}` - Memory usage in MB

### Viewing Logs
```powershell
# View recent logs
Get-Content "C:\AutomationSuite\DaemonService\Logs\daemon.log" -Tail 50

# Monitor logs in real-time
Get-Content "C:\AutomationSuite\DaemonService\Logs\daemon.log" -Wait
```

---

## Integration Examples

### Example 1: Automated Photo Organization
**Scenario**: Automatically organize photos when added to Downloads

**Setup**:
1. Configure daemon file watcher for Downloads
2. Trigger file management script on new images
3. Organize by date into folders

**Daemon Config**:
```json
{
  "name": "Photo Organizer",
  "enabled": true,
  "path": "C:\\Users\\YourUsername\\Downloads",
  "filter": "*.jpg;*.png;*.gif",
  "events": ["Created"],
  "actions": [
    {
      "type": "script",
      "path": "C:\\AutomationSuite\\PowerShell\\Scripts\\Core\\Manage-Files.ps1",
      "arguments": "-Action Organize -Path 'C:\\Users\\YourUsername\\Downloads' -OrganizeBy Date"
    }
  ]
}
```

### Example 2: Daily Backup Workflow
**Scenario**: Automated daily backups with cleanup

**Setup**:
1. Create scheduled task for backup
2. Create scheduled task for cleanup
3. Configure email notifications (optional)

**Commands**:
```powershell
# Create backup task
.\Schedule-Tasks.ps1 -Action Create -TaskName "DailyBackup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Automation\Backup-UserData.ps1" -Schedule Daily -Time "02:00" -RunAsAdmin

# Create cleanup task
.\Schedule-Tasks.ps1 -Action Create -TaskName "DailyCleanup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Core\Clean-SystemFiles.ps1" -Schedule Daily -Time "03:00" -RunAsAdmin
```

### Example 3: Development Workflow
**Scenario**: Streamlined coding environment

**Setup**:
1. Use FancyZones Coding Layout (Ctrl+Win+Alt+1)
2. AutoHotkey for quick app switching
3. SteelSeries macros for git commands
4. Voice commands for common tasks

**Workflow**:
1. Press `Ctrl+Win+Alt+1` to activate coding layout
2. Use `Win+Ctrl+Shift+T` to open terminal
3. Press G-key macro for git status
4. Say "Computer, run backup" before major changes

### Example 4: Resource Monitoring
**Scenario**: Alert on high resource usage

**Setup**:
1. Configure daemon process watcher
2. Set CPU and memory thresholds
3. Trigger notifications and logging

**Daemon Config**:
```json
{
  "name": "Resource Monitor",
  "enabled": true,
  "process_name": "*",
  "cpu_threshold": 80,
  "memory_threshold_mb": 2000,
  "check_interval": 10,
  "actions": [
    {
      "type": "notification",
      "title": "High Resource Usage",
      "message": "{ProcessName} using {CPU}% CPU and {Memory}MB RAM"
    },
    {
      "type": "log",
      "message": "Resource alert: {ProcessName} - CPU: {CPU}%, Memory: {Memory}MB"
    }
  ]
}
```

---

## Best Practices

### Security
1. **Run with Least Privilege**: Only use admin rights when necessary
2. **Review Scripts**: Always review scripts before running
3. **Backup Configurations**: Keep backups of working configurations
4. **Test in Safe Mode**: Test automation in non-production environment
5. **Monitor Logs**: Regularly check logs for suspicious activity

### Performance
1. **Optimize Check Intervals**: Don't check too frequently
2. **Disable Unused Watchers**: Turn off watchers you don't need
3. **Limit Recursive Searches**: Use targeted paths
4. **Clean Logs Regularly**: Prevent log files from growing too large
5. **Use Incremental Backups**: Save time and space

### Maintenance
1. **Update Regularly**: Keep scripts and tools updated
2. **Review Scheduled Tasks**: Ensure tasks are still needed
3. **Clean Old Backups**: Remove outdated backup files
4. **Test Restorations**: Verify backups work
5. **Document Changes**: Keep notes on customizations

### Troubleshooting
1. **Check Logs First**: Most issues are logged
2. **Run in Foreground**: Test daemon in foreground mode
3. **Verify Paths**: Ensure all paths are correct
4. **Test Individually**: Test components separately
5. **Disable and Re-enable**: Try disabling problematic components

---

**Version**: 1.0  
**Last Updated**: 2024