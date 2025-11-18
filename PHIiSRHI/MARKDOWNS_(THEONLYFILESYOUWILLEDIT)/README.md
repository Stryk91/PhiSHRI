# Windows System Diagnostics & Repair Tool

Intelligent diagnostics system that automatically detects and repairs common Windows issues affecting installers, services, and system stability.

## Features

### System Health Scanner
- **SFC/DISM Integration**: Automated System File Checker and DISM repairs with progress tracking
- **Service Status Checker**: Validates critical Windows services (Windows Installer, TrustedInstaller, Windows Update)
- **Registry Integrity**: Scans for corrupted registry hives and permission issues
- **Disk Health**: Checks for filesystem errors, bad sectors, and low disk space
- **UAC Validation**: Verifies UAC settings and detects misconfigurations
- **Temp Directory Cleanup**: Clears corrupted temp files blocking installers

### Installer Troubleshooting
- **Installer Type Detection**: MSI, NSIS, Squirrel, Electron, InstallShield, InnoSetup, WiX
- **Event Log Capture**: Detailed error logs from Windows Event Viewer
- **CBS Log Analysis**: Parse SFC failures from CBS.log
- **Code Signing Validation**: Verify digital signatures and SmartScreen status
- **Group Policy Checks**: Detect policies blocking installations

### Automated Repair Workflows
- DISM RestoreHealth with Windows Update fallback
- Service startup type correction
- Registry permission repair
- Component store reset for severe corruption
- Automatic restore point creation

### Real-time Monitoring
- Background service health checks (every 5 minutes)
- Event log watcher for critical errors
- Disk space threshold alerts
- Service crash detection and auto-restart
- Performance counter tracking (CPU, RAM, disk I/O)

### Reporting
- HTML diagnostic report with color-coded severity levels
- Root cause analysis with recommendations
- Auto-generated PowerShell repair scripts
- Reboot requirement detection

## Requirements

- **OS**: Windows 10 (1809+) or Windows 11
- **PowerShell**: 7.0 or higher
- **Privileges**: Administrator (required for repair operations)
- **Optional**: Internet connection (for DISM Windows Update source)

## Installation

1. Clone or download the repository
2. Navigate to the `windows-diagnostics` directory
3. Run PowerShell 7+ as Administrator

## Quick Start

### Basic Health Check (Quick Scan)

```powershell
.\Invoke-SystemHealthCheck.ps1 -QuickScan
```

Completes in ~2 minutes. Checks:
- Critical services status
- Disk space
- DISM component store health
- UAC configuration

### Comprehensive Scan

```powershell
.\Invoke-SystemHealthCheck.ps1 -FullScan -GenerateReport
```

Completes in 5-10 minutes. Includes:
- All quick scan checks
- Full SFC scan
- Registry integrity
- Event log analysis (24 hours)
- HTML report generation

### Auto-Repair Mode

```powershell
.\Invoke-SystemHealthCheck.ps1 -FullScan -AutoRepair -GenerateReport
```

Automatically repairs detected issues without prompting for confirmation. Creates system restore point before repairs.

### Analyze Specific Installer

```powershell
.\Invoke-SystemHealthCheck.ps1 -CheckInstaller "C:\Path\To\Installer.exe" -GenerateReport
```

Analyzes installer type, code signature, and recent installation errors.

## Individual Repair Scripts

Run specific repairs independently:

### DISM Repair

```powershell
.\scripts\Repair-DISM.ps1 -UseWindowsUpdate -CreateRestorePoint
```

Runs DISM /RestoreHealth to repair Windows component store.

**Options:**
- `-UseWindowsUpdate`: Download missing files from Windows Update
- `-CreateRestorePoint`: Create restore point before repair

### SFC Repair

```powershell
.\scripts\Repair-SFC.ps1 -CreateRestorePoint
```

Runs System File Checker to repair corrupted system files.

**Options:**
- `-VerifyOnly`: Only scan, don't repair
- `-CreateRestorePoint`: Create restore point before repair

### Service Repair

```powershell
.\scripts\Repair-Services.ps1
```

Fixes critical service startup types and starts stopped services.

**Default services checked:**
- msiserver (Windows Installer)
- TrustedInstaller
- wuauserv (Windows Update)
- CryptSvc (Cryptographic Services)
- BITS (Background Intelligent Transfer Service)
- AppXSvc (AppX Deployment Service)

### Disk Error Repair

```powershell
.\scripts\Repair-DiskErrors.ps1 -DriveLetter C -FixErrors
```

Schedules disk check on next reboot (for system drive).

**Options:**
- `-DriveLetter`: Drive to check (e.g., C, D)
- `-FixErrors`: Fix filesystem errors
- `-ScanForBadSectors`: Deep scan for bad sectors (slow)

### Temp Files Cleanup

```powershell
.\scripts\Clear-TempFiles.ps1 -MaxFileAgeDays 30 -IncludeInstallerCache
```

Removes old temporary files to free space.

**Options:**
- `-MaxFileAgeDays`: Only delete files older than X days (default: 30)
- `-IncludeInstallerCache`: Also clean Windows Installer cache
- `-IncludeDownloads`: Clean old files from Downloads folder

## Scheduled Monitoring

### Install Scheduled Task

```powershell
.\scripts\Install-ScheduledTask.ps1 -Schedule Daily
```

Creates scheduled task that runs health checks automatically:
- **Daily**: Runs at 2:00 AM every day
- **Weekly**: Runs every Monday at 2:00 AM
- **Startup**: Runs 5 minutes after system startup

### Start Real-time Monitoring

```powershell
.\scripts\Start-SystemMonitoring.ps1 -CheckIntervalMinutes 5 -RunInBackground
```

Starts background monitoring service that watches for:
- Service failures (auto-restart if configured)
- Low disk space alerts
- Critical system events
- High CPU/RAM usage

**View monitoring logs:**
```powershell
Get-Content "$env:TEMP\SystemDiagnostics\Monitoring\monitoring_$(Get-Date -Format 'yyyyMMdd').log" -Wait
```

## Configuration

Edit `config/diagnostics_config.json` to customize:

### Key Settings

```json
{
  "systemChecks": {
    "services": {
      "criticalServices": ["msiserver", "TrustedInstaller", "wuauserv"],
      "checkInterval": 300,
      "autoRestart": true
    },
    "disk": {
      "minFreeSpaceGB": 10,
      "alertThresholdPercent": 15
    }
  },
  "automatedRepairs": {
    "requireConfirmation": true,
    "createRestorePoint": true
  },
  "monitoring": {
    "backgroundChecks": {
      "intervalMinutes": 5
    }
  }
}
```

## Output Files

All output is saved to: `%TEMP%\SystemDiagnostics\`

### Generated Files
- `Report_YYYYMMDD_HHMMSS.html` - HTML diagnostic report
- `AutoRepair_YYYYMMDD_HHMMSS.ps1` - Auto-generated repair script
- `events.json` - Event log analysis results
- `Logs\monitoring_YYYYMMDD.log` - Monitoring service logs

## HTML Report Features

The generated HTML report includes:
- **Overall health badge** (Healthy/Warning/Critical)
- **System file integrity** results with SFC/DISM status
- **Service status table** with health indicators
- **Disk space visualization** with progress bars
- **Registry integrity** status by hive
- **Event log summary** with counts by severity
- **Recommended actions** in priority order
- **Auto-generated repair script** for one-click fixes

## Troubleshooting

### "Access Denied" Errors

Ensure you're running PowerShell as Administrator:
```powershell
Start-Process pwsh -Verb RunAs
```

### "Execution Policy" Errors

Temporarily allow script execution:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### DISM Fails with Error 0x800f081f

Network connectivity issue. Run with offline source:
```powershell
.\scripts\Repair-DISM.ps1
```

Or specify Windows installation media:
```powershell
dism /Online /Cleanup-Image /RestoreHealth /Source:D:\sources\install.wim
```

### Services Keep Failing

Check Event Viewer for root cause:
```powershell
Get-WinEvent -LogName System -MaxEvents 50 | Where-Object {$_.LevelDisplayName -eq "Error"}
```

### Low Disk Space Prevents Repairs

Run temp cleanup first:
```powershell
.\scripts\Clear-TempFiles.ps1 -MaxFileAgeDays 7 -IncludeInstallerCache -IncludeDownloads
```

## Success Metrics

The system is designed to meet these targets:
- **Detection Accuracy**: ≥90% for known issues
- **Repair Success Rate**: ≥80% without manual intervention
- **Scan Completion Time**: <5 minutes for full system check
- **False Alarm Rate**: <5% (no unnecessary repairs)

## Advanced Usage

### Custom Service List

```powershell
.\scripts\Repair-Services.ps1 -ServiceNames "wuauserv","BITS","AppXSvc"
```

### Parallel Repair Execution

```powershell
# Start multiple repairs in parallel
$jobs = @()
$jobs += Start-Job { .\scripts\Repair-SFC.ps1 }
$jobs += Start-Job { .\scripts\Repair-Services.ps1 }
$jobs += Start-Job { .\scripts\Clear-TempFiles.ps1 }

# Wait for all jobs to complete
$jobs | Wait-Job | Receive-Job
```

### Integration with CI/CD

```powershell
# Run health check and fail pipeline if critical issues found
$results = .\Invoke-SystemHealthCheck.ps1 -QuickScan

if ($results.Services | Where-Object { -not $_.IsHealthy }) {
    Write-Error "Critical services are unhealthy"
    exit 1
}
```

## Module Functions

Import the modules directly for custom scripting:

```powershell
Import-Module .\modules\SystemDiagnostics.psm1

# Test specific components
$services = Test-CriticalServices
$disk = Test-DiskHealth
$integrity = Test-SystemFileIntegrity -QuickCheck

# Run automated repair
Invoke-AutomatedRepair -CreateRestorePoint

# Start monitoring
Start-SystemHealthMonitoring -IntervalMinutes 5
```

## Security Considerations

- All repair operations require Administrator privileges
- System restore points are created before repairs (when enabled)
- Non-destructive scans run without confirmation
- Sensitive operations prompt for confirmation (unless `-AutoRepair`)
- All changes are logged for audit purposes

## Support & Contributing

For issues, feature requests, or contributions:
1. Check existing issues in the repository
2. Create detailed bug reports with logs and error messages
3. Test on clean Windows installation when possible

## License

Part of the PhiLaunch project. See main repository for license details.

## Version History

### 1.0.0 (2025-01-17)
- Initial release
- Full diagnostic and repair capabilities
- HTML report generation
- Scheduled monitoring
- Auto-repair workflows

## Credits

Developed as part of the PhiLaunch project to provide robust Windows system diagnostics and automated repair capabilities.
