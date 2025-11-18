# Windows MCP v3 Integration Guide

## Overview
This guide shows how to complete the WIN_AUTO_SUITE integration into Windows MCP Server v3.

## Status
- ✅ v3 base created from v2
- ✅ Helper function `call_automation_script()` added
- ✅ Automation suite path constant added
- ⏳ NEW TOOLS to be added (pattern below)

## Integration Pattern

Each WIN_AUTO_SUITE PowerShell script becomes an MCP tool using this pattern:

### 1. Add Tool Definition in `get_tools()`

```rust
Tool {
    name: "get_system_info".to_string(),
    description: "Get comprehensive system information".to_string(),
    input_schema: json!({
        "type": "object",
        "properties": {
            "format": {
                "type": "string",
                "enum": ["Text", "JSON", "HTML"],
                "description": "Output format"
            },
            "export_path": {
                "type": "string",
                "description": "Optional path to export results"
            }
        }
    }),
},
```

### 2. Add Tool Handler in `handle_request()` match statement

```rust
"get_system_info" => {
    let format = args.get("format")
        .and_then(|v| v.as_str())
        .unwrap_or("JSON");

    let mut script_args = vec![format!("-Format {}", format)];

    if let Some(export_path) = args.get("export_path").and_then(|v| v.as_str()) {
        script_args.push(format!("-ExportPath '{}'", export_path));
    }

    let script_path = format!("{}\\PowerShell\\Scripts\\Core\\Get-SystemInfo.ps1", AUTOMATION_SUITE_PATH);
    let args_vec: Vec<String> = script_args.iter().map(|s| s.to_string()).collect();
    call_automation_script(&script_path, &args_vec)?
}
```

## Complete Tool List for v3

### Tools to Add

| Tool Name | PowerShell Script | Priority |
|-----------|-------------------|----------|
| ✅ `get_system_info` | `Core/Get-SystemInfo.ps1` | HIGH |
| ✅ `clean_system_files` | `Core/Clean-SystemFiles.ps1` | HIGH |
| ✅ `manage_files` | `Core/Manage-Files.ps1` | MEDIUM |
| ⏳ `backup_user_data` | `Automation/Backup-UserData.ps1` | HIGH |
| ⏳ `schedule_task` | `Automation/Schedule-Tasks.ps1` | MEDIUM |
| ⏳ `manage_service` | `Admin/Manage-Services.ps1` | MEDIUM |
| ⏳ `daemon_control` | `DaemonService/Source/AutomationDaemon.ps1` | HIGH |
| ⏳ `list_directory` | Add new wrapper | LOW |
| ⏳ `run_automation_script` | Generic wrapper | LOW |

## Implementation Steps

### Step 1: Add to `get_tools()` function (around line 623)

Add all 9 new tool definitions after the existing tools, before the closing `]`.

### Step 2: Add to `handle_request()` match (around line 795)

Add all 9 new tool handlers in the `match tool_name` block, before the final `_` (default case).

### Step 3: Update version string

Change line 773 from `"version": "2.0.0"` to `"version": "3.0.0"`

## Example Implementations

### High Priority Tools

#### 1. get_system_info

**Tool Definition:**
```rust
Tool {
    name: "get_system_info".to_string(),
    description: "Get comprehensive system information (OS, hardware, network, disk, performance)".to_string(),
    input_schema: json!({
        "type": "object",
        "properties": {
            "format": {
                "type": "string",
                "enum": ["Text", "JSON", "HTML"],
                "description": "Output format (default: JSON)"
            },
            "export_path": {
                "type": "string",
                "description": "Optional path to save the output"
            }
        }
    }),
},
```

**Handler:**
```rust
"get_system_info" => {
    let format = args.get("format").and_then(|v| v.as_str()).unwrap_or("JSON");
    let mut script_args = vec![format!("-Format {}", format)];
    if let Some(export) = args.get("export_path").and_then(|v| v.as_str()) {
        script_args.push(format!("-ExportPath '{}'", export));
    }
    let script = format!("{}\\PowerShell\\Scripts\\Core\\Get-SystemInfo.ps1", AUTOMATION_SUITE_PATH);
    let args_vec: Vec<String> = script_args.iter().map(|s| s.to_string()).collect();
    call_automation_script(&script, &args_vec)?
}
```

#### 2. clean_system_files

**Tool Definition:**
```rust
Tool {
    name: "clean_system_files".to_string(),
    description: "Clean system files (temp, cache, recycle bin)".to_string(),
    input_schema: json!({
        "type": "object",
        "properties": {
            "dry_run": {
                "type": "boolean",
                "description": "Preview changes without executing (default: true)"
            },
            "include_browser_cache": {
                "type": "boolean",
                "description": "Include browser cache cleanup"
            },
            "include_recycle_bin": {
                "type": "boolean",
                "description": "Empty recycle bin"
            }
        }
    }),
},
```

**Handler:**
```rust
"clean_system_files" => {
    let mut script_args = Vec::new();

    if let Some(dry_run) = args.get("dry_run").and_then(|v| v.as_bool()) {
        if dry_run {
            script_args.push("-DryRun".to_string());
        }
    } else {
        script_args.push("-DryRun".to_string()); // Default to dry run
    }

    if let Some(browser) = args.get("include_browser_cache").and_then(|v| v.as_bool()) {
        if browser {
            script_args.push("-IncludeBrowserCache".to_string());
        }
    }

    if let Some(recycle) = args.get("include_recycle_bin").and_then(|v| v.as_bool()) {
        if recycle {
            script_args.push("-IncludeRecycleBin".to_string());
        }
    }

    let script = format!("{}\\PowerShell\\Scripts\\Core\\Clean-SystemFiles.ps1", AUTOMATION_SUITE_PATH);
    call_automation_script(&script, &script_args)?
}
```

#### 3. backup_user_data

**Tool Definition:**
```rust
Tool {
    name: "backup_user_data".to_string(),
    description: "Backup user data with compression and verification".to_string(),
    input_schema: json!({
        "type": "object",
        "properties": {
            "source_paths": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Array of source paths to backup"
            },
            "destination": {
                "type": "string",
                "description": "Backup destination path"
            },
            "backup_type": {
                "type": "string",
                "enum": ["Full", "Incremental"],
                "description": "Backup type (default: Full)"
            },
            "retention_days": {
                "type": "integer",
                "description": "Number of days to keep backups (default: 30)"
            }
        },
        "required": ["source_paths", "destination"]
    }),
},
```

**Handler:**
```rust
"backup_user_data" => {
    let sources = args.get("source_paths")
        .and_then(|v| v.as_array())
        .ok_or_else(|| "Missing source_paths".to_string())?;

    let destination = args.get("destination")
        .and_then(|v| v.as_str())
        .ok_or_else(|| "Missing destination".to_string())?;

    let backup_type = args.get("backup_type")
        .and_then(|v| v.as_str())
        .unwrap_or("Full");

    let retention = args.get("retention_days")
        .and_then(|v| v.as_i64())
        .unwrap_or(30);

    let source_list: Vec<String> = sources.iter()
        .filter_map(|v| v.as_str().map(|s| format!("'{}'", s)))
        .collect();

    let script_args = vec![
        format!("-SourcePaths {}", source_list.join(",")),
        format!("-DestinationPath '{}'", destination),
        format!("-BackupType {}", backup_type),
        format!("-RetentionDays {}", retention)
    ];

    let script = format!("{}\\PowerShell\\Scripts\\Automation\\Backup-UserData.ps1", AUTOMATION_SUITE_PATH);
    call_automation_script(&script, &script_args)?
}
```

#### 4. daemon_control

**Tool Definition:**
```rust
Tool {
    name: "daemon_control".to_string(),
    description: "Control the automation daemon service".to_string(),
    input_schema: json!({
        "type": "object",
        "properties": {
            "action": {
                "type": "string",
                "enum": ["Install", "Uninstall", "Start", "Stop", "Status", "Run"],
                "description": "Daemon action to perform"
            }
        },
        "required": ["action"]
    }),
},
```

**Handler:**
```rust
"daemon_control" => {
    let action = args.get("action")
        .and_then(|v| v.as_str())
        .ok_or_else(|| "Missing action".to_string())?;

    let script_args = vec![format!("-Action {}", action)];
    let script = format!("{}\\DaemonService\\Source\\AutomationDaemon.ps1", AUTOMATION_SUITE_PATH);
    call_automation_script(&script, &script_args)?
}
```

## Quick Integration Checklist

- [ ] Copy all tool definitions from above into `get_tools()` around line 754 (before the `]`)
- [ ] Copy all handlers from above into `handle_request()` around line 860 (before the `_ => ...` default case)
- [ ] Update version to "3.0.0" on line 773
- [ ] Build: `cargo build --release`
- [ ] Test with a simple tool like `get_system_info`
- [ ] Deploy: `.\deploy.ps1`

## Testing

After implementation, test each tool:

```powershell
# Via Claude Desktop or direct JSON-RPC:

# 1. Test system info
{"method":"tools/call","params":{"name":"get_system_info","arguments":{"format":"JSON"}}}

# 2. Test cleanup (dry run)
{"method":"tools/call","params":{"name":"clean_system_files","arguments":{"dry_run":true}}}

# 3. Test daemon
{"method":"tools/call","params":{"name":"daemon_control","arguments":{"action":"Status"}}}
```

## Notes

- All PowerShell scripts must exist in `C:\AutomationSuite\`
- The `call_automation_script()` helper handles script execution
- PowerShell 7 (`pwsh.exe`) is required for proper UTF-8 handling
- Error handling is automatic through the `?` operator
- All tools return JSON-formatted results

## Next Steps

1. Add remaining tool definitions and handlers
2. Test each tool individually
3. Update README with v3 feature list
4. Create v3-specific test scripts
5. Deploy and verify 19/19 tools working

---

**Version**: 3.0.0
**Author**: VSSC
**Status**: Integration pattern defined, implementation in progress
