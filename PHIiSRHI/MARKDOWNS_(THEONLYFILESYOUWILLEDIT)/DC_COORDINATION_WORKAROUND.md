# DC Coordination Workaround - File-Based System

**Solution for DC's execution restrictions: synchronous file-based command queue**

---

## Problem Summary

DC **CANNOT**:
- ❌ Spawn new processes (`Start-Process` blocked)
- ❌ Run background jobs (`Start-Job` blocked)
- ❌ Execute scripts asynchronously (all `execute_powershell` is synchronous)
- ❌ Launch persistent monitoring wrappers
- ❌ Use `Start-Sleep` for timing
- ❌ Access non-USERPROFILE paths reliably

DC **CAN**:
- ✅ Execute inline PowerShell commands (synchronous)
- ✅ Read/write files in USERPROFILE
- ✅ Use MCP tools: `send_keys`, `get_window_info`, `read_file`, `write_file`
- ✅ Execute `.ps1` scripts with `& 'path\to\script.ps1'` (but they must return immediately)

---

## Solution: File-Based Command Queue

**Architecture:**
```
DC (restricted) → writes command → queue file
                                      ↓
                            Manual watcher (in Claude terminal)
                                      ↓
                            executes command → writes response → response file
                                                                      ↓
                                                        DC reads response file
```

**Key insight:** DC cannot launch the watcher, but **STRYK can** in a separate terminal. Once running, DC coordinates via files.

---

## Setup (One-Time Manual Step)

**STRYK runs in a separate PowerShell terminal:**

```powershell
cd C:\Dev
.\claude_watcher.ps1
```

**Output:**
```
=== Claude Watcher Started ===
Watching: C:\Dev\claude_command_queue.txt
Responses: C:\Dev\claude_response_latest.json
Interval: 2 seconds

DC can now queue commands. This watcher will execute them.
Press Ctrl+C to stop
--------------------------------------------------------------------------------
```

**Leave this terminal open.** It will execute commands queued by DC.

---

## DC Workflow

### Pattern 1: Send Command & Read Response

**DC executes:**
```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "& 'C:\\Dev\\dc_send_command.ps1' -Command 'Get-Process | Select-Object -First 5 Name, CPU'"
  }
}
```

**Returns immediately:**
```json
{
  "status": "queued",
  "command": "Get-Process | Select-Object -First 5 Name, CPU",
  "timestamp": "22:30:15",
  "queue_file": "C:\\Dev\\claude_command_queue.txt",
  "instruction": "Command queued. Watcher will execute."
}
```

**Wait ~3 seconds** (DC must estimate, cannot use `Start-Sleep`)

**DC reads response:**
```json
{
  "name": "read_file",
  "arguments": {
    "path": "C:\\Dev\\claude_response_latest.json"
  }
}
```

**Response contains:**
```json
{
  "timestamp": "2025-11-15 22:30:16",
  "command": "Get-Process | Select-Object -First 5 Name, CPU",
  "status": "success",
  "output": "Name        CPU\n----        ---\nChrome      45.2\n...",
  "error": null
}
```

---

### Pattern 2: Focus Claude Terminal & Send Keys

**Problem:** DC needs to send MCP commands to Claude but cannot spawn the terminal or monitoring wrapper.

**Workaround:** Use existing Claude terminal + manual watcher

**DC workflow:**

```javascript
// 1. Focus Claude terminal (works - click_window_element)
{
  "name": "get_window_info",
  "arguments": {"window_title": "claude"}
}
// Verify window exists

// 2. Focus it
{
  "name": "click_window_element",
  "arguments": {
    "window_title": "PowerShell",  // Where claude is running
    "x": 500,
    "y": 300
  }
}

// 3. Send MCP command
{
  "name": "send_keys",
  "arguments": {
    "window_title": "PowerShell",
    "keys": "mcp call list_windows{ENTER}"
  }
}

// 4. Wait (must estimate - 3-5 seconds for MCP response)
// (DC cannot sleep, must sequence multiple calls with delays between)

// 5. Queue command to check Claude output log
{
  "name": "execute_powershell",
  "arguments": {
    "command": "& 'C:\\Dev\\dc_send_command.ps1' -Command 'Get-Content C:\\Dev\\claude_code_output.log -Tail 20'"
  }
}

// 6. Read watcher response
{
  "name": "read_file",
  "arguments": {
    "path": "C:\\Dev\\claude_response_latest.json"
  }
}
```

---

### Pattern 3: Check If Watcher Is Running

**DC can verify watcher status:**

```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "Test-Path 'C:\\Dev\\claude_command_queue.txt'"
  }
}
```

**If file exists, watcher likely running.** To confirm execution:

```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "& 'C:\\Dev\\dc_send_command.ps1' -Command 'Write-Host PING'"
  }
}
```

Wait 3 seconds, then:

```json
{
  "name": "read_file",
  "arguments": {
    "path": "C:\\Dev\\claude_response_latest.json"
  }
}
```

**If response.output contains "PING", watcher is active.**

---

## Scripts Provided

### 1. `dc_send_command.ps1` - DC's Command Sender

**Purpose:** Queue commands for watcher to execute

**DC Usage:**
```powershell
& 'C:\Dev\dc_send_command.ps1' -Command 'Your-PowerShell-Command-Here'
```

**What it does:**
1. Appends command to `claude_command_queue.txt` with timestamp
2. Returns immediately with status "queued"
3. Watcher picks up and executes command
4. Watcher writes response to `claude_response_latest.json`

**Parameters:**
- `-Command` (required) - PowerShell command to execute
- `-CommandFile` (optional) - Queue file path (default: `C:\Dev\claude_command_queue.txt`)
- `-ResponseFile` (optional) - Response file path (default: `C:\Dev\claude_response_latest.json`)

### 2. `claude_watcher.ps1` - Manual Watcher (STRYK Runs This)

**Purpose:** Monitor queue file and execute commands

**STRYK runs manually:**
```powershell
.\claude_watcher.ps1
```

**What it does:**
1. Watches `claude_command_queue.txt` every 2 seconds
2. Executes new commands via `Invoke-Expression`
3. Captures output (success or error)
4. Writes JSON response to `claude_response_latest.json`
5. Continues running until Ctrl+C

**Output example:**
```
[22:30:15] New command detected:
  Get-Process | Select-Object -First 5 Name, CPU
  Executing...
  ✓ Success - Response saved
  Output preview:
    Name        CPU
    ----        ---
    Chrome      45.2...
```

---

## File Locations

**Queue & Response:**
```
C:\Dev\
├── claude_command_queue.txt          ← DC writes commands here
├── claude_response_latest.json       ← DC reads responses here
├── claude_code_output.log            ← Claude terminal output (if logging enabled)
└── claude_output_parsed.json         ← Parsed output (if parser running)
```

**Scripts:**
```
C:\Dev\
├── dc_send_command.ps1               ← DC uses this to queue commands
├── claude_watcher.ps1                ← STRYK runs this manually
├── run_claude_code_logged.ps1        ← Optional: Claude with logging
└── parse_claude_output.ps1           ← Optional: Parse Claude output
```

---

## Limitations & Workarounds

### Limitation 1: No Timing Control

**Problem:** DC cannot use `Start-Sleep`

**Workaround:**
- Estimate delays (3-5 seconds typical)
- Poll response file multiple times
- Check `timestamp` field to verify new response

**Example - Polling Pattern:**
```javascript
// Send command
execute_powershell({command: "dc_send_command.ps1 -Command 'test'"})

// Read response attempt 1 (immediate - likely old response)
const r1 = read_file({path: "claude_response_latest.json"})
const t1 = JSON.parse(r1.content).timestamp

// Sequence other work here (3-5 second natural delay)
// ...then read again

// Read response attempt 2 (should be new)
const r2 = read_file({path: "claude_response_latest.json"})
const t2 = JSON.parse(r2.content).timestamp

if (t2 !== t1) {
  // New response received
} else {
  // Still old response, wait more
}
```

### Limitation 2: Cannot Launch Watcher

**Problem:** DC cannot start `claude_watcher.ps1` as background process

**Workaround:** STRYK manually starts watcher in separate terminal (one-time setup)

### Limitation 3: Synchronous Execution Only

**Problem:** Everything blocks until complete

**Workaround:**
- Use watcher for async-like behavior
- DC queues command and returns immediately
- Watcher executes in parallel
- DC polls for response when ready

### Limitation 4: No Process Spawning

**Problem:** Cannot launch new terminals, Claude instances, etc.

**Workaround:**
- Use existing Claude terminal
- Focus it via `click_window_element`
- Send keys via `send_keys`
- Monitor via file-based output logging

---

## Complete Example: DC Sends MCP Command

**Setup (one-time by STRYK):**

Terminal 1:
```powershell
# Start Claude with logging
.\run_claude_code_logged.ps1
```

Terminal 2:
```powershell
# Start command watcher
.\claude_watcher.ps1
```

**DC Automation:**

```javascript
// Step 1: Queue command to check if Claude is responsive
await execute_powershell({
  command: "& 'C:\\Dev\\dc_send_command.ps1' -Command 'Test-Path C:\\Dev\\claude_code_output.log'"
})

// Step 2: Do other work (natural 3-second delay)
await get_window_info({window_title: "claude"})

// Step 3: Read watcher response
const response = await read_file({
  path: "C:\\Dev\\claude_response_latest.json"
})

const result = JSON.parse(response.content)

if (result.status === "success" && result.output.includes("True")) {
  console.log("Claude log file exists - Claude is running")

  // Step 4: Focus Claude terminal
  await click_window_element({
    window_title: "PowerShell",
    x: 500,
    y: 300
  })

  // Step 5: Send MCP command
  await send_keys({
    window_title: "PowerShell",
    keys: "mcp call list_windows{ENTER}"
  })

  // Step 6: Wait for MCP to process (sequence other calls)
  await get_clipboard()  // Arbitrary 1-second operation
  await get_clipboard()  // Another 1-second
  await get_clipboard()  // Total ~3 seconds delay

  // Step 7: Queue command to read Claude output
  await execute_powershell({
    command: "& 'C:\\Dev\\dc_send_command.ps1' -Command 'Get-Content C:\\Dev\\claude_code_output.log -Tail 30'"
  })

  // Step 8: Natural delay
  await get_window_info({window_title: "PowerShell"})

  // Step 9: Read MCP response from log
  const logResponse = await read_file({
    path: "C:\\Dev\\claude_response_latest.json"
  })

  const mpcOutput = JSON.parse(logResponse.content).output
  console.log("MCP Response:", mpcOutput)
}
```

---

## Advantages of This Approach

✅ **Works within DC restrictions**
- No process spawning needed
- No background jobs
- Synchronous execution only
- File-based coordination

✅ **Simple architecture**
- Two files: queue and response
- Two scripts: sender (DC) and watcher (manual)
- Clear separation of concerns

✅ **Reliable**
- Files are atomic operations
- Timestamps prevent stale data
- Easy to debug (just check files)

✅ **Flexible**
- Watcher can execute ANY PowerShell command
- DC can queue complex scripts
- Response includes stdout and stderr

---

## Troubleshooting

### Issue: Response file never updates

**Cause:** Watcher not running

**Check:**
```powershell
Get-Process | Where-Object {$_.CommandLine -like '*claude_watcher*'}
```

**Fix:** Start watcher manually in separate terminal

### Issue: Commands queued but not executed

**Cause:** Watcher cannot read queue file

**Check watcher terminal for errors**

**Fix:** Verify paths in watcher match DC's queue file

### Issue: DC gets old responses

**Cause:** Reading response before watcher completes

**Fix:**
- Check `timestamp` field
- Poll multiple times
- Sequence natural delays between operations

---

## Migration Path

**Current state:** All tools built, but DC cannot orchestrate

**Immediate (manual setup):**
1. STRYK starts `claude_watcher.ps1` in Terminal 2
2. STRYK starts `claude` (with optional logging) in Terminal 1
3. DC uses `dc_send_command.ps1` to queue commands
4. DC reads responses from `claude_response_latest.json`

**Future improvement ideas:**
- Auto-start watcher via scheduled task (if DC can trigger tasks)
- Multiple response files for parallel command tracking
- Command priority queue
- Response archival system

---

**Created:** November 15, 2025
**Version:** 1.0.0
**For:** DC coordination despite execution restrictions
**Scripts:** 2 (sender + watcher)

**This is the workaround for DC's process spawning limitations.**
