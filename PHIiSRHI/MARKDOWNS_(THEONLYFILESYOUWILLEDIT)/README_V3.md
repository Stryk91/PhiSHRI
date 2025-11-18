# Windows MCP Server v3.0
**WIN_AUTO_SUITE Integration**

## What's New in v3.0

### New Tools from WIN_AUTO_SUITE Integration

v3.0 integrates the complete Windows Automation Suite, adding 9 new MCP tools:

#### System Management Tools
1. **`get_system_info`** - Comprehensive system information
   - Returns OS, hardware, network, disk, performance metrics
   - Supports JSON, HTML, and Text output formats
   - Based on `Get-SystemInfo.ps1`

2. **`clean_system_files`** - Advanced system cleanup
   - Temp files, browser cache, recycle bin
   - Supports dry-run mode for safety
   - Based on `Clean-SystemFiles.ps1`

3. **`manage_files`** - File organization and management
   - Organize by date/type/size
   - Find duplicates
   - Batch rename with patterns
   - Based on `Manage-Files.ps1`

#### Automation Tools
4. **`backup_user_data`** - Automated backup system
   - Full and incremental backups
   - Compression and verification
   - Retention policy support
   - Based on `Backup-UserData.ps1`

5. **`schedule_task`** - Windows Task Scheduler integration
   - Create/modify/delete scheduled tasks
   - Multiple trigger types (daily, weekly, monthly, startup)
   - Based on `Schedule-Tasks.ps1`

6. **`manage_service`** - Windows service management
   - Start/stop/restart services
   - Change startup types
   - Service monitoring
   - Based on `Manage-Services.ps1`

#### Daemon & Monitoring
7. **`daemon_control`** - Automation daemon management
   - Install/start/stop/status daemon service
   - Background automation engine
   - Based on `AutomationDaemon.ps1`

8. **`file_watcher_add`** - File system monitoring
   - Watch directories for changes
   - Trigger actions on file events
   - Daemon integration

9. **`process_monitor_add`** - Process monitoring
   - Monitor CPU/memory usage
   - Alert on threshold violations
   - Daemon integration

### Architecture

```
┌─────────────────────────────────────┐
│   Claude Desktop (MCP Client)       │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   Windows MCP Server v3 (Rust)      │
│   ├── v2 Tools (10 tools)           │
│   │   ├── File operations           │
│   │   ├── Window automation         │
│   │   ├── Process management        │
│   │   ├── Clipboard ops             │
│   │   └── PowerShell execution      │
│   └── v3 Tools (9 NEW tools)        │
│       ├── System info & cleanup     │
│       ├── File management           │
│       ├── Backup & scheduling       │
│       ├── Service management        │
│       └── Daemon & monitoring       │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   WIN_AUTO_SUITE PowerShell Scripts │
│   Located in: C:\AutomationSuite\   │
└─────────────────────────────────────┘
```

### Tool Count
- **v2 Tools**: 10 tools (100% functional)
- **v3 New Tools**: 9 tools
- **Total**: 19 MCP tools

## Installation

### Prerequisites
1. Windows 10/11
2. PowerShell 7+ (`pwsh.exe` at `E:\pwsh\7\pwsh.exe`)
3. WIN_AUTO_SUITE installed at `C:\AutomationSuite\`

### Setup WIN_AUTO_SUITE
```powershell
# Extract WindowsAutomationSuite.zip to C:\AutomationSuite\
Expand-Archive -Path ".\WindowsAutomationSuite.zip" -DestinationPath "C:\AutomationSuite\"

# Verify installation
ls C:\AutomationSuite\
```

### Build MCP Server v3
```powershell
cd C:\Dev\Windows-MCP-v3
.\build.ps1
```

### Deploy
```powershell
.\deploy.ps1
```

## Usage Examples

### System Information
```json
{
  "tool": "get_system_info",
  "arguments": {
    "format": "json"
  }
}
```

### System Cleanup (Dry Run)
```json
{
  "tool": "clean_system_files",
  "arguments": {
    "dry_run": true,
    "include_browser_cache": true
  }
}
```

### Backup User Data
```json
{
  "tool": "backup_user_data",
  "arguments": {
    "source_paths": ["C:\\Users\\Documents", "C:\\Users\\Pictures"],
    "destination": "D:\\Backups",
    "backup_type": "incremental"
  }
}
```

### Start Automation Daemon
```json
{
  "tool": "daemon_control",
  "arguments": {
    "action": "start"
  }
}
```

### Add File Watcher
```json
{
  "tool": "file_watcher_add",
  "arguments": {
    "path": "C:\\Dev\\Projects",
    "filter": "*.rs",
    "event": "Changed",
    "action_script": "C:\\AutomationSuite\\PowerShell\\Scripts\\Automation\\Backup-UserData.ps1"
  }
}
```

## Migration from v2

v3 is fully backward compatible with v2. All existing v2 tools continue to work exactly as before. Simply deploy v3 to get access to the new automation suite tools.

## Version History

### v3.0.0 (Current)
- ✅ WIN_AUTO_SUITE integration
- ✅ 9 new automation tools
- ✅ Daemon service support
- ✅ File and process monitoring
- ✅ Advanced file management
- ✅ System cleanup and backups

### v2.0.0 (Baseline)
- ✅ 10/10 tools functional (100%)
- ✅ PowerShell 7 integration
- ✅ Window automation
- ✅ File operations
- ✅ Process management

### v1.0.0 (Original)
- Initial release
- Basic functionality

## Credits

**Author**: VSSC
**Version**: 3.0.0
**Based on**: WIN_AUTO_SUITE by Windows Automation Suite Team
**v2 Baseline**: 100% functional (10/10 tools)
**Date**: 2025-11-16
