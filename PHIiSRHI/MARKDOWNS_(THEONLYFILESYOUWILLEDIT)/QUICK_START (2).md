# Quick Start Guide - Windows Automation Suite

Get up and running in 5 minutes!

## Step 1: Extract Files (30 seconds)
Extract the `WindowsAutomationSuite` folder to:
```
C:\AutomationSuite\
```

## Step 2: Enable PowerShell Scripts (30 seconds)
Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Step 3: Download Required Software (2 minutes)
Download and install:
- **AutoHotkey**: https://www.autohotkey.com/
- **PowerToys**: https://github.com/microsoft/PowerToys/releases

## Step 4: Start AutoHotkey (10 seconds)
Double-click: `C:\AutomationSuite\AutoHotkey\MasterScript.ahk`

## Step 5: Test It! (1 minute)
Try these:
- Press `Win+H` to see all hotkeys
- Press `Win+Alt+Left` to snap window left
- Press `Win+V` to see clipboard history
- Type `ddate` and press Space to insert current date

## What's Next?

### For Developers
```powershell
# Activate coding layout
Press Ctrl+Win+Alt+1

# Open terminal
Press Win+Ctrl+Shift+T
```

### For Power Users
```powershell
# Get system info
cd C:\AutomationSuite\PowerShell\Scripts\Core
.\Get-SystemInfo.ps1

# Clean system
.\Clean-SystemFiles.ps1 -DryRun
```

### For Automation
```powershell
# Install daemon service
cd C:\AutomationSuite\DaemonService\Source
.\AutomationDaemon.ps1 -Action Install
.\AutomationDaemon.ps1 -Action Start
```

## Essential Hotkeys

| Hotkey | Action |
|--------|--------|
| `Win+H` | Show all hotkeys |
| `Win+Alt+Arrow` | Snap windows |
| `Win+V` | Clipboard history |
| `Win+Ctrl+Shift+T` | Open terminal |
| `Ctrl+Win+Alt+1-5` | Switch FancyZones layouts |

## Need Help?

- **Full Installation**: See [INSTALLATION_GUIDE.md](Documentation/INSTALLATION_GUIDE.md)
- **Usage Examples**: See [USAGE_GUIDE.md](Documentation/USAGE_GUIDE.md)
- **Troubleshooting**: See [README.md](README.md#troubleshooting)

---

**You're all set! Press Win+H to see what you can do.**