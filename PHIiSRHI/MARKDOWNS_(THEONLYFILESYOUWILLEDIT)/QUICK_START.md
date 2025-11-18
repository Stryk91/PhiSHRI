# Windows Diagnostics - Quick Start Guide

## Prerequisites

1. **PowerShell 7+** installed
2. **Administrator privileges**
3. **Windows 10 (1809+)** or **Windows 11**

## Installation

```powershell
# Navigate to the diagnostics directory
cd C:\Path\To\PhiLaunch\windows-diagnostics

# Run as Administrator
```

## Basic Commands

### 1. Quick Health Check (2 minutes)

```powershell
.\Invoke-SystemHealthCheck.ps1 -QuickScan
```

**What it checks:**
- Critical services (Windows Installer, TrustedInstaller, Windows Update)
- Disk space on all volumes
- Windows component store health
- UAC configuration
- Temporary files size

### 2. Full System Scan (5-10 minutes)

```powershell
.\Invoke-SystemHealthCheck.ps1 -FullScan -GenerateReport
```

**Additional checks:**
- System File Checker (SFC) scan
- Registry integrity
- Event log analysis (last 24 hours)
- Generates HTML report

### 3. Auto-Repair Mode

```powershell
.\Invoke-SystemHealthCheck.ps1 -AutoRepair -GenerateReport
```

**What it does:**
- Runs full scan
- Automatically repairs detected issues
- Creates system restore point first
- Generates report and repair script

## Common Scenarios

### Installer Won't Run

```powershell
# Check specific installer
.\Invoke-SystemHealthCheck.ps1 -CheckInstaller "C:\Downloads\setup.exe" -GenerateReport

# Repair Windows Installer service
.\scripts\Repair-Services.ps1
```

### System Files Corrupted

```powershell
# Run DISM repair
.\scripts\Repair-DISM.ps1 -UseWindowsUpdate -CreateRestorePoint

# Then run SFC
.\scripts\Repair-SFC.ps1
```

### Low Disk Space

```powershell
# Clean temporary files (older than 30 days)
.\scripts\Clear-TempFiles.ps1 -MaxFileAgeDays 30 -IncludeInstallerCache
```

### Service Keeps Crashing

```powershell
# Fix service configurations
.\scripts\Repair-Services.ps1

# Start real-time monitoring
.\scripts\Start-SystemMonitoring.ps1 -RunInBackground
```

## Scheduled Monitoring

Setup automated daily health checks:

```powershell
# Install scheduled task (runs daily at 2:00 AM)
.\scripts\Install-ScheduledTask.ps1 -Schedule Daily
```

## View Reports

Reports are saved to: `%TEMP%\SystemDiagnostics\`

```powershell
# Open reports folder
explorer "$env:TEMP\SystemDiagnostics"

# View latest report
$latest = Get-ChildItem "$env:TEMP\SystemDiagnostics\Report_*.html" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Start-Process $latest.FullName
```

## Troubleshooting

### "Cannot be loaded because running scripts is disabled"

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### "Access Denied" or Permission Errors

Make sure you're running PowerShell as Administrator:

```powershell
# Right-click PowerShell → "Run as Administrator"
```

### Need Help?

```powershell
# Get help for main tool
Get-Help .\Invoke-SystemHealthCheck.ps1 -Detailed

# Get help for specific repair script
Get-Help .\scripts\Repair-DISM.ps1 -Detailed
```

## What Each Script Does

| Script | Purpose | Time | Reboot |
|--------|---------|------|--------|
| `Repair-DISM.ps1` | Repairs Windows component store | 15-30 min | Maybe |
| `Repair-SFC.ps1` | Repairs system files | 10-20 min | No |
| `Repair-Services.ps1` | Fixes service configurations | <1 min | No |
| `Repair-DiskErrors.ps1` | Schedules disk check | Immediate | Yes |
| `Clear-TempFiles.ps1` | Removes old temp files | 1-5 min | No |

## Configuration

Edit `config/diagnostics_config.json` to customize:
- Which services to monitor
- Disk space thresholds
- Monitoring intervals
- Auto-repair settings

## Support

For detailed documentation, see [README.md](README.md)
