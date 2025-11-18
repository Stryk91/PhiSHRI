# Windows Automation Suite - Phase 2

A comprehensive automation and productivity toolkit for Windows 10/11 featuring PowerShell scripts, AutoHotkey automation, PowerToys integration, voice commands, peripheral macros, and a background daemon service.

## 🚀 Features

### 1. PowerShell Script Library
- **Core Utilities**: System information, file management, system cleanup
- **Automation Scripts**: Automated backups, scheduled tasks, network tools
- **Administrative Tools**: Service management, user administration
- **Reusable Module**: Import functions into any PowerShell session

### 2. PowerToys Configuration
- **Pre-configured Settings**: Optimized PowerToys configuration
- **FancyZones Layouts**: 10 custom window layouts for different workflows
- **Quick Layout Switching**: Keyboard shortcuts for instant layout changes
- **Productivity Focused**: Layouts for coding, content creation, video editing, and more

### 3. AutoHotkey Scripts
- **Window Management**: Snap, move, resize windows with hotkeys
- **Application Launchers**: Quick access to frequently used apps
- **Clipboard History**: Access last 10 clipboard items
- **Text Expansion**: Auto-expand shortcuts into full text
- **Mouse Gestures**: Volume control and more via mouse
- **Virtual Desktop Management**: Navigate and manage virtual desktops

### 4. Voice Commands
- **Hands-Free Operation**: Control Windows with voice
- **Application Control**: Launch apps, manage windows
- **System Commands**: Lock, shutdown, volume control
- **Custom Scripts**: Trigger automation scripts via voice
- **Windows Speech Recognition**: Native integration

### 5. SteelSeries Macros
- **5 Pre-configured Profiles**: Productivity, Development, Media, Window Management, Automation
- **Programmable Actions**: Complex multi-step macros
- **Quick Access**: Trigger scripts and commands from G-keys
- **Alternative Software Support**: Works with Razer, Logitech, Corsair

### 6. Daemon Service
- **File System Monitoring**: Watch folders for changes
- **Process Monitoring**: Alert on high CPU/memory usage
- **Automated Actions**: Trigger scripts based on events
- **Background Operation**: Runs as Windows service
- **Configurable Triggers**: JSON-based configuration

## 📋 Requirements

- **OS**: Windows 10 (1809+) or Windows 11
- **PowerShell**: 5.1 or higher (built-in)
- **Administrator Rights**: Required for most features
- **.NET Framework**: 4.7.2 or higher
- **Disk Space**: 500 MB minimum

## 📦 Installation

### Quick Start

1. **Extract the suite** to a permanent location:
   ```
   C:\AutomationSuite\
   ```

2. **Set PowerShell execution policy**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Install required software**:
   - [AutoHotkey](https://www.autohotkey.com/) - For hotkey automation
   - [Microsoft PowerToys](https://github.com/microsoft/PowerToys/releases) - For FancyZones and utilities
   - [SteelSeries Engine](https://steelseries.com/engine) - Optional, for gaming peripherals

4. **Import PowerShell module**:
   ```powershell
   Import-Module C:\AutomationSuite\PowerShell\Modules\AutomationToolkit.psm1
   ```

5. **Run AutoHotkey script**:
   - Double-click `AutoHotkey\MasterScript.ahk`

6. **Install daemon service** (optional):
   ```powershell
   cd C:\AutomationSuite\DaemonService\Source
   .\AutomationDaemon.ps1 -Action Install
   .\AutomationDaemon.ps1 -Action Start
   ```

For detailed installation instructions, see [INSTALLATION_GUIDE.md](Documentation/INSTALLATION_GUIDE.md)

## 📖 Documentation

- **[Installation Guide](Documentation/INSTALLATION_GUIDE.md)** - Complete installation instructions
- **[Usage Guide](Documentation/USAGE_GUIDE.md)** - Detailed usage examples and workflows
- **[Troubleshooting](Documentation/INSTALLATION_GUIDE.md#troubleshooting)** - Common issues and solutions

## 🎯 Quick Examples

### PowerShell Scripts

```powershell
# Get system information
.\PowerShell\Scripts\Core\Get-SystemInfo.ps1

# Clean system files
.\PowerShell\Scripts\Core\Clean-SystemFiles.ps1 -IncludeBrowserCache

# Organize downloads by extension
.\PowerShell\Scripts\Core\Manage-Files.ps1 -Action Organize -Path "C:\Downloads" -OrganizeBy Extension

# Create automated backup
.\PowerShell\Scripts\Automation\Backup-UserData.ps1 -SourcePaths "C:\Documents" -DestinationPath "D:\Backups"

# Schedule daily cleanup
.\PowerShell\Scripts\Automation\Schedule-Tasks.ps1 -Action Create -TaskName "DailyCleanup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Core\Clean-SystemFiles.ps1" -Schedule Daily -Time "02:00"
```

### AutoHotkey Hotkeys

- `Win+Alt+Left/Right/Up/Down` - Snap windows
- `Win+Ctrl+T` - Toggle always on top
- `Win+V` - Clipboard history
- `Win+Ctrl+Shift+T` - Open terminal
- `Win+H` - Show all hotkeys

### FancyZones Layouts

- `Ctrl+Win+Alt+1` - Coding Layout (3 columns)
- `Ctrl+Win+Alt+2` - Productivity (4 quadrants)
- `Ctrl+Win+Alt+3` - Content Creation (70/30 split)
- `Ctrl+Win+Alt+4` - Video Editing
- `Ctrl+Win+Alt+5` - Focus Mode

### Voice Commands

Say "Computer" followed by:
- "open browser"
- "maximize window"
- "volume up"
- "lock computer"
- "run backup"

## 📁 Directory Structure

```
WindowsAutomationSuite/
├── PowerShell/
│   ├── Modules/
│   │   └── AutomationToolkit.psm1
│   └── Scripts/
│       ├── Core/
│       │   ├── Get-SystemInfo.ps1
│       │   ├── Clean-SystemFiles.ps1
│       │   └── Manage-Files.ps1
│       ├── Automation/
│       │   ├── Backup-UserData.ps1
│       │   └── Schedule-Tasks.ps1
│       └── Admin/
│           └── Manage-Services.ps1
├── PowerToys/
│   ├── Configs/
│   │   └── PowerToys-Settings.json
│   └── FancyZones/
│       └── Layouts.json
├── AutoHotkey/
│   ├── MasterScript.ahk
│   └── config.ini
├── VoiceCommands/
│   └── VoiceCommandSetup.ps1
├── SteelSeries/
│   └── MacroConfigurations.json
├── DaemonService/
│   ├── Source/
│   │   └── AutomationDaemon.ps1
│   ├── Config/
│   │   └── daemon-config.json
│   └── Logs/
└── Documentation/
    ├── INSTALLATION_GUIDE.md
    └── USAGE_GUIDE.md
```

## 🔧 Configuration

### Update Paths

After installation, update paths in configuration files:

1. **Daemon Config**: `DaemonService\Config\daemon-config.json`
   - Replace `C:\Users\YourUsername` with your actual username
   - Update monitoring paths and backup destinations

2. **SteelSeries Macros**: `SteelSeries\MacroConfigurations.json`
   - Update script paths if not using `C:\AutomationSuite`

3. **Voice Commands**: `VoiceCommands\VoiceCommandSetup.ps1`
   - Adjust script paths in XML configuration

### Customize Settings

- **PowerShell Module**: Add custom functions to `AutomationToolkit.psm1`
- **AutoHotkey**: Modify hotkeys in `MasterScript.ahk`
- **Daemon Service**: Add watchers and triggers in `daemon-config.json`
- **PowerToys**: Adjust settings via PowerToys Settings UI

## 🎨 Use Cases

### For Developers
- **Coding Layout**: 3-column layout with file explorer, editor, and terminal
- **Git Macros**: Quick git commands via keyboard/peripheral
- **Auto-backup**: Trigger backups on file changes
- **Process Monitoring**: Alert on high resource usage

### For Content Creators
- **Content Creation Layout**: 70/30 split for main work and tools
- **Video Editing Layout**: Optimized for timeline and preview
- **Media Controls**: Volume and playback via macros
- **File Organization**: Auto-organize downloads by type

### For Power Users
- **Productivity Layout**: 4 quadrants for multitasking
- **Window Management**: Snap and move windows efficiently
- **Clipboard History**: Access previous clipboard items
- **Text Expansion**: Quick shortcuts for common phrases

### For System Administrators
- **Service Management**: Control Windows services
- **Scheduled Tasks**: Automate maintenance tasks
- **System Monitoring**: Track resource usage
- **Automated Cleanup**: Regular system maintenance

## 🔐 Security Considerations

1. **Review Scripts**: Always review scripts before running
2. **Least Privilege**: Use admin rights only when necessary
3. **Backup Configurations**: Keep backups of working configs
4. **Test Safely**: Test automation in non-production environment
5. **Monitor Logs**: Regularly check logs for issues

## 🐛 Troubleshooting

### PowerShell Scripts Won't Run
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### AutoHotkey Not Starting
- Verify AutoHotkey is installed
- Check startup shortcut exists
- Run script manually to see errors

### Daemon Service Issues
```powershell
# Check logs
Get-Content "C:\AutomationSuite\DaemonService\Logs\daemon.log" -Tail 50

# Run in foreground
.\AutomationDaemon.ps1 -Action Run
```

### Voice Commands Not Working
- Ensure microphone is enabled
- Complete Windows Speech Recognition training
- Test with: `.\VoiceCommandSetup.ps1 -Test`

For more troubleshooting, see [INSTALLATION_GUIDE.md](Documentation/INSTALLATION_GUIDE.md#troubleshooting)

## 📊 Component Overview

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **PowerShell Scripts** | System automation | File management, backups, cleanup, service control |
| **PowerToys** | Window management | FancyZones layouts, Color Picker, PowerRename |
| **AutoHotkey** | Hotkey automation | Window snapping, app launchers, text expansion |
| **Voice Commands** | Hands-free control | Application control, system commands |
| **SteelSeries Macros** | Peripheral automation | Quick access to scripts and commands |
| **Daemon Service** | Background monitoring | File watching, process monitoring, triggers |

## 🔄 Integration

All components work together seamlessly:

1. **Daemon** monitors file changes → triggers **PowerShell backup script**
2. **AutoHotkey** hotkey → launches **PowerShell script** → shows **notification**
3. **Voice command** → activates **FancyZones layout** → opens **applications**
4. **SteelSeries macro** → runs **PowerShell cleanup** → logs to **daemon**

## 📝 Best Practices

1. **Start Small**: Enable one component at a time
2. **Test First**: Use dry-run modes before automating
3. **Backup Configs**: Keep copies of working configurations
4. **Monitor Logs**: Check logs regularly for issues
5. **Update Paths**: Ensure all paths are correct for your system
6. **Document Changes**: Keep notes on customizations

## 🚦 Getting Started Checklist

- [ ] Extract suite to permanent location
- [ ] Set PowerShell execution policy
- [ ] Install AutoHotkey
- [ ] Install PowerToys
- [ ] Import PowerShell module
- [ ] Run AutoHotkey script
- [ ] Configure FancyZones layouts
- [ ] Update paths in configuration files
- [ ] Test individual components
- [ ] Install daemon service (optional)
- [ ] Set up voice commands (optional)
- [ ] Configure peripheral macros (optional)

## 📚 Additional Resources

- **PowerShell Documentation**: https://docs.microsoft.com/powershell/
- **AutoHotkey Documentation**: https://www.autohotkey.com/docs/
- **PowerToys Documentation**: https://docs.microsoft.com/windows/powertoys/
- **Windows Speech Recognition**: https://support.microsoft.com/windows/speech-recognition

## 🤝 Support

For issues or questions:
1. Check the logs in respective component directories
2. Review the [Troubleshooting](Documentation/INSTALLATION_GUIDE.md#troubleshooting) section
3. Consult the [Usage Guide](Documentation/USAGE_GUIDE.md) for detailed examples

## 📄 License

This automation suite is provided as-is for personal and commercial use.

## ⚠️ Disclaimer

- Always test scripts in a safe environment before production use
- Backup important data before running cleanup or automation scripts
- Review all scripts and configurations before deployment
- Use at your own risk - no warranty provided

---

**Version**: 1.0  
**Phase**: 2  
**Created**: 2024  
**Author**: Windows Automation Suite Team

---

## 🎉 Quick Win Examples

### Example 1: Daily Automated Backup
```powershell
# Create scheduled task for daily backup at 2 AM
.\PowerShell\Scripts\Automation\Schedule-Tasks.ps1 -Action Create -TaskName "DailyBackup" -ScriptPath "C:\AutomationSuite\PowerShell\Scripts\Automation\Backup-UserData.ps1" -Schedule Daily -Time "02:00" -RunAsAdmin
```

### Example 2: Auto-Organize Downloads
Configure daemon to organize downloads automatically when files are added.

### Example 3: One-Click System Cleanup
Assign SteelSeries G-key to run system cleanup script.

### Example 4: Voice-Activated Backup
Say "Computer, run backup" to start backup process.

### Example 5: Productivity Workspace
Press `Ctrl+Win+Alt+2` to activate 4-quadrant layout for multitasking.

---

**Ready to boost your productivity? Start with the [Installation Guide](Documentation/INSTALLATION_GUIDE.md)!**