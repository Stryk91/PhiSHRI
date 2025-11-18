# Example Workflows - Windows Automation Suite

This document provides real-world examples of how to use the Windows Automation Suite components together.

---

## Workflow 1: Developer's Daily Setup

### Scenario
You're a developer who wants to automatically set up your workspace each morning.

### Components Used
- FancyZones (Coding Layout)
- AutoHotkey (Application Launchers)
- PowerShell (System Info)

### Steps
1. **Activate Coding Layout**
   ```
   Press: Ctrl+Win+Alt+1
   ```

2. **Launch Applications**
   ```
   Press: Win+Ctrl+Shift+T (Terminal)
   Press: Win+Ctrl+Shift+B (Browser)
   Press: Win+Ctrl+Shift+E (File Explorer)
   ```

3. **Check System Status**
   ```powershell
   Get-QuickSystemInfo
   ```

4. **Windows Auto-Snap**
   - Drag Terminal to left zone (25%)
   - Drag VS Code to center zone (50%)
   - Drag Browser to right zone (25%)

---

## Workflow 2: Automated Photo Organization

### Scenario
Automatically organize photos when downloaded.

### Components Used
- Daemon Service (File Watcher)
- PowerShell (File Management)

### Configuration
Edit `DaemonService/Config/daemon-config.json`:

```json
{
  "name": "Photo Organizer",
  "enabled": true,
  "path": "C:\\Users\\YourUsername\\Downloads",
  "filter": "*.jpg;*.png;*.gif;*.heic",
  "events": ["Created"],
  "actions": [
    {
      "type": "log",
      "message": "New photo detected: {FileName}"
    },
    {
      "type": "script",
      "path": "C:\\AutomationSuite\\PowerShell\\Scripts\\Core\\Manage-Files.ps1",
      "arguments": "-Action Organize -Path 'C:\\Users\\YourUsername\\Downloads' -OrganizeBy Date -Filter '*.jpg;*.png;*.gif'"
    }
  ]
}
```

### Result
Photos are automatically organized into date-based folders when downloaded.

---

## Workflow 3: Weekly Backup Routine

### Scenario
Automated weekly backups with cleanup.

### Components Used
- PowerShell (Backup Script, Scheduled Tasks)
- Daemon Service (Monitoring)

### Setup
```powershell
# Create weekly backup task
.\Schedule-Tasks.ps1 -Action Create `
  -TaskName "WeeklyBackup" `
  -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Automation\Backup-UserData.ps1" `
  -Schedule Weekly `
  -Time "02:00" `
  -RunAsAdmin

# Create cleanup task (runs after backup)
.\Schedule-Tasks.ps1 -Action Create `
  -TaskName "PostBackupCleanup" `
  -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Core\Clean-SystemFiles.ps1" `
  -Schedule Weekly `
  -Time "03:00" `
  -RunAsAdmin
```

### Monitoring
Configure daemon to log backup completion:
```json
{
  "name": "Backup Monitor",
  "enabled": true,
  "path": "D:\\Backups",
  "filter": "*.zip",
  "events": ["Created"],
  "actions": [
    {
      "type": "notification",
      "title": "Backup Complete",
      "message": "Weekly backup created: {FileName}"
    }
  ]
}
```

---

## Workflow 4: Content Creator's Setup

### Scenario
Video editing workspace with media controls.

### Components Used
- FancyZones (Video Editing Layout)
- SteelSeries Macros (Media Controls)
- AutoHotkey (Window Management)

### Setup
1. **Activate Video Editing Layout**
   ```
   Press: Ctrl+Win+Alt+4
   ```

2. **Configure SteelSeries Profile**
   - Switch to "Media Control Profile"
   - G1: Play/Pause
   - G2: Next Track
   - G4-G6: Volume controls

3. **Launch Applications**
   - Video editor → Top-left zone (preview)
   - Effects panel → Top-right zone
   - Timeline → Bottom zone

### Usage
- Use G-keys for media playback while editing
- Use `Win+Alt+Arrow` to adjust window positions
- Use `Win+Ctrl+O` to make reference window semi-transparent

---

## Workflow 5: System Maintenance Automation

### Scenario
Automated system maintenance with monitoring.

### Components Used
- Daemon Service (Process Monitoring)
- PowerShell (Cleanup, System Info)
- Scheduled Tasks

### Configuration

**Daily Cleanup Task**:
```powershell
.\Schedule-Tasks.ps1 -Action Create `
  -TaskName "DailyMaintenance" `
  -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Core\Clean-SystemFiles.ps1" `
  -Schedule Daily `
  -Time "02:00" `
  -RunAsAdmin
```

**Process Monitoring**:
```json
{
  "name": "High Resource Alert",
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

**Weekly System Report**:
```powershell
.\Schedule-Tasks.ps1 -Action Create `
  -TaskName "WeeklyReport" `
  -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Core\Get-SystemInfo.ps1" `
  -Schedule Weekly `
  -Time "09:00"
```

---

## Workflow 6: Voice-Controlled Workspace

### Scenario
Hands-free computer control while multitasking.

### Components Used
- Voice Commands
- PowerShell Scripts
- AutoHotkey

### Setup
```powershell
# Configure voice commands
cd C:\AutomationSuite\VoiceCommands
.\VoiceCommandSetup.ps1 -Install
.\VoiceCommandSetup.ps1 -Configure
```

### Usage Examples
```
"Computer, open browser"          → Opens default browser
"Computer, maximize window"       → Maximizes active window
"Computer, volume up"             → Increases volume
"Computer, run backup"            → Starts backup script
"Computer, system information"    → Shows system info
"Computer, lock computer"         → Locks workstation
```

### Tips
- Train voice recognition for better accuracy
- Speak clearly and at normal pace
- Use consistent phrasing
- Minimize background noise

---

## Workflow 7: Multi-Monitor Productivity

### Scenario
Efficiently manage windows across multiple monitors.

### Components Used
- FancyZones (Multiple Layouts)
- AutoHotkey (Window Movement)
- PowerToys

### Setup
1. **Configure FancyZones for Each Monitor**
   - Monitor 1: Coding Layout
   - Monitor 2: Productivity Layout

2. **Use Hotkeys for Window Movement**
   ```
   Win+Ctrl+Left  → Move window to left monitor
   Win+Ctrl+Right → Move window to right monitor
   Win+Alt+Arrow  → Snap within current monitor
   ```

3. **Quick Layout Switching**
   ```
   Ctrl+Win+Alt+1 → Coding layout (Monitor 1)
   Ctrl+Win+Alt+2 → Productivity layout (Monitor 2)
   ```

---

## Workflow 8: Gaming/Streaming Setup

### Scenario
Quick setup for gaming and streaming.

### Components Used
- FancyZones (Gaming/Streaming Layout)
- SteelSeries Macros
- AutoHotkey

### Configuration
1. **Activate Gaming Layout**
   ```
   Press: Ctrl+Win+Alt+4 (or create custom layout)
   ```

2. **Configure Macros**
   - G1: Start/Stop recording
   - G2: Mute microphone
   - G3: Switch scenes
   - G4: Show chat
   - G5: Volume controls

3. **Window Arrangement**
   - Game: Center-top (main area)
   - OBS: Bottom strip
   - Chat: Side panel
   - Alerts: Corner overlay

---

## Workflow 9: Research and Writing

### Scenario
Organize research materials and write documents.

### Components Used
- FancyZones (Research Layout)
- AutoHotkey (Text Expansion)
- PowerShell (File Organization)

### Setup
1. **Activate Research Layout**
   ```
   Press: Ctrl+Win+Alt+3 (or use custom 3-zone layout)
   ```

2. **Use Text Expansion**
   ```
   Type: ddate     → Inserts current date
   Type: @gmail    → Expands to @gmail.com
   Type: fyi       → Expands to "for your information"
   ```

3. **Organize Research Files**
   ```powershell
   .\Manage-Files.ps1 -Action Organize `
     -Path "C:\Research" `
     -OrganizeBy Date `
     -Recursive
   ```

---

## Workflow 10: Quick System Recovery

### Scenario
Quickly recover from system issues.

### Components Used
- AutoHotkey (Quick Access)
- PowerShell (Service Management)
- SteelSeries Macros

### Quick Actions

**Restart Explorer**:
```
Press: SteelSeries G5 (Automation Profile)
Or manually:
Ctrl+Shift+Esc → Find explorer.exe → End Task → File → Run → explorer.exe
```

**Check System Status**:
```powershell
Get-QuickSystemInfo
Get-DiskSpaceInfo
```

**Restart Problematic Service**:
```powershell
.\Manage-Services.ps1 -Action Restart -ServiceName "servicename"
```

**Emergency Cleanup**:
```powershell
.\Clean-SystemFiles.ps1 -IncludeBrowserCache -IncludeRecycleBin
```

---

## Tips for Creating Your Own Workflows

1. **Start Simple**: Begin with one component and add more as needed
2. **Test Thoroughly**: Always test workflows in a safe environment
3. **Document Changes**: Keep notes on customizations
4. **Use Variables**: Leverage daemon variables for flexibility
5. **Monitor Logs**: Check logs to ensure workflows are working
6. **Iterate**: Refine workflows based on actual usage
7. **Backup Configs**: Save working configurations before changes

---

## Troubleshooting Workflows

### Workflow Not Triggering
1. Check daemon service is running
2. Verify paths in configuration
3. Check logs for errors
4. Test components individually

### Performance Issues
1. Reduce check intervals
2. Disable unused watchers
3. Optimize script execution
4. Monitor resource usage

### Integration Problems
1. Verify all components are installed
2. Check file paths are correct
3. Test each component separately
4. Review integration logs

---

**Version**: 1.0  
**Last Updated**: 2024