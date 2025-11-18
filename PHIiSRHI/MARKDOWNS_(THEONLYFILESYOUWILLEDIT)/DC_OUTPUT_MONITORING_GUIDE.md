# DC Terminal Output Monitoring System

**Complete solution for Desktop Claude (DC) to monitor and parse Claude Code terminal output.**

---

## Problem Statement

DC cannot:
- ❌ Capture screen output from terminal windows
- ❌ Parse real-time Claude Code responses
- ❌ Automatically verify command execution

**Solution:** Output redirection + file-based monitoring + structured parsing

---

## Quick Start

### Option 1: Automated Logging (Recommended)

**Terminal 1 - Run Claude Code with Logging:**
```powershell
cd C:\Dev
.\run_claude_code_logged.ps1
```

**Terminal 2 - Monitor Output (DC can run this):**
```powershell
cd C:\Dev
.\parse_claude_output.ps1 -Watch
```

### Option 2: Manual Logging

**Run Claude Code with output redirection:**
```powershell
claude 2>&1 | Tee-Object -FilePath "C:\Dev\claude_code_output.log"
```

**Parse output once:**
```powershell
.\parse_claude_output.ps1
```

---

## Scripts Provided

### 1. `run_claude_code_logged.ps1` - Automatic Output Capture

**Purpose:** Wrapper that runs Claude Code and captures all output

**Usage:**
```powershell
# Interactive mode with logging
.\run_claude_code_logged.ps1

# With arguments
.\run_claude_code_logged.ps1 mcp call list_windows

# Custom log file
.\run_claude_code_logged.ps1 -OutputFile "C:\Logs\claude.log"
```

**What it does:**
1. Creates output directory if needed
2. Writes session header with timestamp
3. Runs `claude` with stderr/stdout redirection
4. Uses `Tee-Object` to display AND log simultaneously
5. Writes session footer when complete

**Output Format:**
```
===============================================================================
Claude Code Session Started: 2025-11-15 21:58:30
===============================================================================

[Claude Code output here...]

===============================================================================
Claude Code Session Ended: 2025-11-15 22:05:15
===============================================================================
```

### 2. `parse_claude_output.ps1` - Intelligent Output Parser

**Purpose:** Extracts structured information from Claude Code logs

**Usage:**
```powershell
# Parse once
.\parse_claude_output.ps1

# Continuous monitoring (updates every 3 seconds)
.\parse_claude_output.ps1 -Watch

# Custom files
.\parse_claude_output.ps1 -LogFile "C:\Logs\claude.log" -OutputJson "C:\Logs\parsed.json"

# Faster monitoring (1 second interval)
.\parse_claude_output.ps1 -Watch -WatchInterval 1
```

**Extracts:**
- ✅ **Status** - error, warning, success, active, idle
- ✅ **Errors** - Lines containing error keywords
- ✅ **Warnings** - Lines with warning indicators
- ✅ **Success Messages** - Completion indicators
- ✅ **Tool Calls** - MCP tool invocations
- ✅ **Responses** - JSON responses from tools
- ✅ **Last Activity** - Most recent timestamp

**Output JSON:**
```json
{
  "timestamp": "2025-11-15 21:58:30",
  "status": "success",
  "last_activity": "21:58:25",
  "errors": [],
  "warnings": [],
  "success_messages": [
    "✓ Terminal opened and focused successfully"
  ],
  "tool_calls": [
    "execute_powershell",
    "send_keys"
  ],
  "responses": [
    {"success": true, "keys_sent": 15}
  ]
}
```

### 3. `capture_terminal_output.ps1` - Monitor Helper

**Purpose:** Real-time log file monitoring (optional tool)

**Usage:**
```powershell
# Monitor mode - tail log file continuously
.\capture_terminal_output.ps1 -Monitor

# Show last 50 lines
.\capture_terminal_output.ps1 -Monitor -TailLines 50

# Faster updates (1 second)
.\capture_terminal_output.ps1 -Monitor -MonitorInterval 1
```

**Display:**
```
=== Claude Code Output (Last 100 lines) ===
File: C:\Dev\claude_code_output.log
Size: 45678 bytes | Updated: 21:58:30
--------------------------------------------------------------------------------
[Output content here...]
--------------------------------------------------------------------------------
```

---

## DC Integration Patterns

### Pattern 1: Send Command → Monitor Response

**DC executes:**
```javascript
// Step 1: Start monitoring in background
{
  "name": "execute_powershell",
  "arguments": {
    "command": "Start-Process powershell -ArgumentList '-NoExit', '-Command', 'cd C:\\Dev; .\\parse_claude_output.ps1 -Watch' -WindowStyle Minimized"
  }
}

// Step 2: Send command to Claude Code terminal
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Claude Code",
    "keys": "mcp call list_windows{ENTER}"
  }
}

// Step 3: Wait for response (3-5 seconds)
// (wait 5000ms)

// Step 4: Read parsed output
{
  "name": "read_file",
  "arguments": {
    "path": "C:\\Dev\\claude_output_parsed.json"
  }
}
```

**Result:** DC can read structured JSON with status, errors, and responses

### Pattern 2: Launch Claude Code → Continuous Monitoring

**Terminal 1 (Claude Code with logging):**
```powershell
.\run_claude_code_logged.ps1
```

**Terminal 2 (DC Monitoring - separate window):**
```powershell
.\parse_claude_output.ps1 -Watch -WatchInterval 2
```

**DC reads output every N seconds:**
```json
{
  "name": "read_file",
  "arguments": {
    "path": "C:\\Dev\\claude_output_parsed.json"
  }
}
```

### Pattern 3: Verify Command Execution

**DC workflow:**
```javascript
// 1. Clear old parsed output
{
  "name": "write_file",
  "arguments": {
    "path": "C:\\Dev\\claude_output_parsed.json",
    "content": "{\"status\":\"pending\"}"
  }
}

// 2. Send command
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Claude Code",
    "keys": "mcp call get_clipboard{ENTER}"
  }
}

// 3. Wait for processing
// (wait 3000ms)

// 4. Parse current output
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\parse_claude_output.ps1"
  }
}

// 5. Read parsed result
{
  "name": "read_file",
  "arguments": {
    "path": "C:\\Dev\\claude_output_parsed.json"
  }
}

// 6. Check status
// If status === "success" → command executed
// If status === "error" → check errors array
```

### Pattern 4: Error Detection & Retry

**DC monitors for errors:**
```javascript
async function executeWithRetry(command, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    // Send command
    await send_keys({
      window_title: "Claude Code",
      keys: command + "{ENTER}"
    });

    // Wait for response
    await sleep(3000);

    // Parse output
    await execute_powershell({
      command: "C:\\Dev\\parse_claude_output.ps1"
    });

    // Read result
    const result = await read_file({
      path: "C:\\Dev\\claude_output_parsed.json"
    });

    const parsed = JSON.parse(result.content);

    if (parsed.status === "success") {
      return parsed;  // Success!
    }

    if (parsed.status === "error") {
      console.log(`Attempt ${attempt} failed:`, parsed.errors);
      if (attempt < maxRetries) {
        console.log("Retrying...");
        await sleep(2000);
      }
    }
  }

  throw new Error("Max retries exceeded");
}
```

---

## File Locations

**Log Files (created automatically):**
```
C:\Dev\claude_code_output.log        ← Raw terminal output
C:\Dev\claude_output_parsed.json     ← Structured parsed data
```

**Scripts:**
```
C:\Dev\
├── run_claude_code_logged.ps1       ← Run Claude Code with logging
├── parse_claude_output.ps1          ← Parse output to JSON
├── capture_terminal_output.ps1      ← Monitor helper
└── DC_OUTPUT_MONITORING_GUIDE.md    ← This guide
```

---

## Parsing Logic

### Status Detection

| Status | Trigger Keywords |
|--------|------------------|
| `error` | error, failed, exception, cannot, unable |
| `warning` | warning, warn: |
| `success` | success, ✓, ✅, completed, done, finished |
| `active` | Tool calls detected OR success messages found |
| `idle` | No activity detected |

### Error Extraction

Captures any line containing error indicators:
```
Error: File not found
Failed to execute command
Exception: Invalid path
Cannot read file
Unable to connect
```

### Tool Call Detection

Extracts MCP tool names from JSON:
```json
{"name": "execute_powershell", "arguments": {...}}
```
→ Captured as: `"execute_powershell"`

### Response Parsing

Attempts to parse JSON objects:
```json
{"success": true, "keys_sent": 15}
```
→ Added to `responses` array

---

## Advanced Usage

### Custom Parsing Rules

**Modify `parse_claude_output.ps1` to add custom detection:**

```powershell
# Add custom success pattern
if ($trimmed -match 'deployment complete|build succeeded') {
    $result.success_messages += $trimmed
    $result.status = "success"
}

# Add custom error pattern
if ($trimmed -match 'timeout|connection refused') {
    $result.errors += $trimmed
    $result.status = "error"
}
```

### Integration with State File

**Update mcp_state.json based on parsed output:**

```powershell
# Read parsed output
$parsed = Get-Content "C:\Dev\claude_output_parsed.json" | ConvertFrom-Json

# Read state file
$state = Get-Content "C:\Dev\mcp_state.json" | ConvertFrom-Json

# Update DC entry based on status
if ($parsed.status -eq "error") {
    $state.active_entries."DC>$(Get-Date -Format 'HH:mm:ss|ddMM')>MONITOR>ERROR" =
        "Claude Code error detected: $($parsed.errors[0])"
} elseif ($parsed.status -eq "success") {
    $state.active_entries."DC>$(Get-Date -Format 'HH:mm:ss|ddMM')>MONITOR>ACTV" =
        "Claude Code responding normally - $($parsed.tool_calls.Count) tools called"
}

# Write updated state
$state | ConvertTo-Json -Depth 10 | Out-File "C:\Dev\mcp_state.json" -Encoding UTF8
```

---

## Troubleshooting

### Issue: Log file not created

**Cause:** Claude Code not running with logging

**Solution:**
```powershell
# Verify script is running
Get-Process | Where-Object {$_.CommandLine -like '*run_claude_code_logged*'}

# Or start manually
.\run_claude_code_logged.ps1
```

### Issue: Parsed JSON shows "status": "unknown"

**Cause:** No recognizable patterns in output

**Solution:** Add custom patterns or increase monitoring interval:
```powershell
.\parse_claude_output.ps1 -Watch -WatchInterval 5
```

### Issue: Parser not detecting tool calls

**Cause:** Tool calls not in expected JSON format

**Solution:** Check raw log for actual format:
```powershell
Get-Content C:\Dev\claude_code_output.log -Tail 50
```

### Issue: DC can't read parsed JSON

**Cause:** File locked or doesn't exist

**Solution:**
```powershell
# Check file exists and is readable
Test-Path "C:\Dev\claude_output_parsed.json"
Get-Content "C:\Dev\claude_output_parsed.json"

# Ensure parser ran at least once
.\parse_claude_output.ps1
```

---

## Performance Considerations

### Monitoring Intervals

| Interval | Use Case | CPU Impact |
|----------|----------|------------|
| 1 second | Real-time monitoring | High |
| 2-3 seconds | **Recommended** | Medium |
| 5+ seconds | Background monitoring | Low |

### Log File Size

**Automatic rotation (optional):**
```powershell
# Rotate log if > 10MB
$logFile = "C:\Dev\claude_code_output.log"
if ((Get-Item $logFile).Length -gt 10MB) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Move-Item $logFile "C:\Dev\Logs\claude_code_output_$timestamp.log"
}
```

---

## Complete Workflow Example

**Setup (one time):**
```powershell
# Terminal 1: Start Claude Code with logging
cd C:\Dev
.\run_claude_code_logged.ps1

# Terminal 2: Start continuous parser
cd C:\Dev
.\parse_claude_output.ps1 -Watch -WatchInterval 2
```

**DC Automation (repeatable):**
```javascript
// 1. Send MCP command to Claude Code
await send_keys({
  window_title: "Claude Code",
  keys: "mcp call list_windows{ENTER}"
});

// 2. Wait for processing
await sleep(3000);

// 3. Read parsed result
const result = await read_file({
  path: "C:\\Dev\\claude_output_parsed.json"
});

const parsed = JSON.parse(result.content);

// 4. Act on result
if (parsed.status === "success") {
  console.log("Command executed successfully");
  console.log("Tool calls:", parsed.tool_calls);
  console.log("Responses:", parsed.responses);
} else if (parsed.status === "error") {
  console.error("Errors detected:", parsed.errors);
}
```

---

**Created:** November 15, 2025
**Version:** 1.0.0
**For:** Desktop Claude (DC) monitoring of Claude Code terminal
**Scripts:** 3 PowerShell monitoring utilities

**Related:** [TERMINAL_AUTOMATION.md](TERMINAL_AUTOMATION.md), [WINDOW_AUTOMATION_GUIDE.md](WINDOW_AUTOMATION_GUIDE.md)
