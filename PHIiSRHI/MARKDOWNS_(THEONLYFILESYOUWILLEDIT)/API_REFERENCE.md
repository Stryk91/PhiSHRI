# Multi-Agent Coordination System - API Reference Guide

## PowerShell Module API (AgentCoordination.psm1)

### Core Management Functions

#### `Initialize-AgentCoordination`
Initialize the multi-agent coordination system.

**Parameters:**
- `SessionId` (string, optional): Unique session identifier. Default: auto-generated
- `SnapshotInterval` (int, optional): Turns between state snapshots. Default: 10

**Returns:** None

**Example:**
```powershell
Initialize-AgentCoordination -SessionId "my_session_001" -SnapshotInterval 5
```

#### `Get-SystemStatus`
Retrieve current system status and metrics.

**Parameters:** None

**Returns:** Hashtable with system status

**Properties:**
- `session_id`: Current session identifier
- `current_turn`: Current turn number
- `active_agent`: Name of currently active agent
- `pending_tasks`: Number of pending tasks
- `active_tasks`: Number of active tasks
- `completed_tasks`: Number of completed tasks
- `total_token_usage`: Cumulative token usage
- `snapshots_available`: Number of available snapshots

**Example:**
```powershell
$status = Get-SystemStatus
Write-Host "Current turn: $($status.current_turn)"
```

#### `Show-SystemStatus`
Display formatted system status to console.

**Parameters:** None

**Returns:** None (displays to console)

**Example:**
```powershell
Show-SystemStatus
```

### State Management Functions

#### `Save-SessionState`
Save current session state to JSON file.

**Parameters:** None

**Returns:** None

**Example:**
```powershell
Save-SessionState
```

#### `Load-SessionState`
Load session state from JSON file.

**Parameters:** None

**Returns:** Boolean indicating success

**Example:**
```powershell
$success = Load-SessionState
if ($success) { Write-Host "State loaded successfully" }
```

#### `Create-StateSnapshot`
Create snapshot of current state for rollback capability.

**Parameters:**
- `Turn` (int, optional): Turn number for snapshot. Default: current turn

**Returns:** None

**Example:**
```powershell
Create-StateSnapshot -Turn 25
```

#### `Rollback-ToSnapshot`
Rollback to previous state snapshot.

**Parameters:**
- `TargetTurn` (int, required): Target turn number to rollback to

**Returns:** Boolean indicating success

**Example:**
```powershell
$success = Rollback-ToSnapshot -TargetTurn 20
```

### Workflow Engine Functions

#### `Advance-Turn`
Advance to next turn in coordination sequence.

**Parameters:**
- `NextAgent` (string, optional): Next agent name. Default: "auto" (sequential)

**Returns:** None

**Valid Agents:** "STRYK", "DC", "VSCC", "auto"

**Example:**
```powershell
Advance-Turn -NextAgent "DC"
Advance-Turn -NextAgent "auto"  # Sequential advance
```

#### `Process-TaskQueue`
Process tasks in queue with priority and dependencies.

**Parameters:** None

**Returns:** None

**Example:**
```powershell
Process-TaskQueue
```

#### `Complete-Task`
Mark task as completed and handle handoffs.

**Parameters:**
- `TaskId` (string, required): Task identifier
- `Results` (hashtable, optional): Task completion results

**Returns:** None

**Example:**
```powershell
Complete-Task -TaskId "task_001" -Results @{status = "success"; output = "completed"}
```

### Messaging Functions

#### `Send-AgentMessage`
Send message to specific agent using file-based IPC.

**Parameters:**
- `TargetAgent` (string, required): Target agent name
- `Message` (hashtable, required): Message content
- `Priority` (string, optional): Message priority. Default: "normal"

**Valid Priorities:** "critical", "high", "normal", "low"
**Valid Agents:** "STRYK", "DC", "VSCC"

**Message Structure:**
```powershell
@{
    type = "task|info|error|handoff"
    content = "Message content"
    data = @{}  # Optional additional data
}
```

**Example:**
```powershell
Send-AgentMessage -TargetAgent "DC" -Message @{
    type = "task"
    content = "Execute window automation"
    data = @{window = "Chrome", action = "click"}
} -Priority "high"
```

#### `Receive-AgentMessage`
Receive messages for current agent.

**Parameters:**
- `AgentName` (string, required): Agent name to receive messages for

**Returns:** Array of message objects

**Example:**
```powershell
$messages = Receive-AgentMessage -AgentName "DC"
foreach ($msg in $messages) {
    Write-Host "Received: $($msg.type) - $($msg.content)"
}
```

### Token Optimization Functions

#### `Optimize-Tokens`
Apply shorthand rules to reduce token usage.

**Parameters:**
- `Text` (string, required): Text to optimize

**Returns:** Optimized string

**Example:**
```powershell
$optimized = Optimize-Tokens -Text "Execute the function for the window"
# Result: "EXEC fn 4 win"
```

#### `Compress-Message`
Compress message using JSON format.

**Parameters:**
- `Message` (hashtable, required): Message to compress

**Returns:** JSON string

**Example:**
```powershell
$compressed = Compress-Message -Message @{type="task"; content="test"}
```

#### `Estimate-Tokens`
Estimate token count for message.

**Parameters:**
- `Text` (string, required): Text to estimate

**Returns:** Integer token count

**Example:**
```powershell
$tokens = Estimate-Tokens -Text "This is a test message"
```

### Error Handling Functions

#### `Detect-AgentUnstall`
Detect if any agent is stalled.

**Parameters:** None

**Returns:** Array of stalled agent names

**Example:**
```powershell
$stalled = Detect-AgentUnstall
if ($stalled.Count -gt 0) {
    Write-Warning "Stalled agents: $($stalled -join ', ')"
}
```

#### `Recover-Agent`
Attempt to recover stalled agent.

**Parameters:**
- `AgentName` (string, required): Agent name to recover

**Returns:** None

**Example:**
```powershell
Recover-Agent -AgentName "DC"
```

## AutoHotkey API

### DC_VSCC_Messaging.ahk

#### Message Injection Functions

**InjectMessage(targetTitle, message)**
Inject message into target window.

**Parameters:**
- `targetTitle` (string): Target window title
- `message` (string): Message content

**Returns:** Boolean success indicator

**Example:**
```autohotkey
success := InjectMessage("ahk_exe Code.exe", "console.log('test')")
```

**SendToVSCC(messageType, data)**
Send message to VSCC agent.

**Parameters:**
- `messageType` (string): Type of message
- `data` (object): Message data

**Example:**
```autohotkey
SendToVSCC("code_ready", {
    code: "console.log('hello')",
    filename: "test.js"
})
```

#### Hotkeys
- `Ctrl+Alt+V`: Send test message to VSCC
- `Ctrl+Alt+M`: Process message queue

### DC_Browser_Messaging.ahk

#### Browser Communication Functions

**InjectBrowserMessage(browserInfo, message)**
Inject JavaScript message into browser console.

**Parameters:**
- `browserInfo` (object): Browser information object
- `message` (object): Message to inject

**Returns:** Boolean success indicator

**Example:**
```autohotkey
browser := FindActiveBrowser()
InjectBrowserMessage(browser, {type: "test", data: "test"})
```

**SendToBrowser(messageType, data)**
Send message to Browser AI.

**Parameters:**
- `messageType` (string): Type of message
- `data` (object): Message data

**Example:**
```autohotkey
SendToBrowser("ui_action", {
    action: "click",
    selector: "#submit-button"
})
```

#### Hotkeys
- `Ctrl+Alt+B`: Send test message to browser
- `Ctrl+Alt+D`: Process browser messages
- `Ctrl+Alt+F`: Find and focus browser

### VSCC_Browser_Messaging.ahk

#### Code Generation Functions

**SendToBrowser(messageType, data)**
Send code/content to browser for execution.

**Parameters:**
- `messageType` (string): Type of message (e.g., "code_execution")
- `data` (object): Code and execution data

**Example:**
```autohotkey
SendToBrowser("code_execution", {
    code: "document.title = 'Updated';",
    execute_immediately: true
})
```

**InjectToVSCode(code, fileName)**
Inject code into VSCode.

**Parameters:**
- `code` (string): Code content
- `fileName` (string): Target filename

**Returns:** Boolean success indicator

**Example:**
```autohotkey
InjectToVSCode("console.log('test');", "test.js")
```

#### Hotkeys
- `Ctrl+Alt+C`: Send test code to browser
- `Ctrl+Alt+V`: Process browser messages
- `Ctrl+Alt+I`: Inject sample script into VSCode

## JSON Schema API

### SESSION_STATE.json Schema

```json
{
  "schema_version": "1.0",
  "session_id": "string",
  "timestamp": "ISO 8601 datetime",
  "turn_counter": "integer",
  "snapshot_interval": "integer",
  "last_snapshot_turn": "integer",
  "active_agents": {
    "STRYK": {
      "status": "idle|active|recovering",
      "last_turn": "integer",
      "context_hash": "string",
      "token_usage": "integer"
    },
    "DC": { /* same structure */ },
    "VSCC": { /* same structure */ }
  },
  "shared_context": {
    "windows": "object",
    "variables": "object", 
    "clipboard": "string"
  },
  "snapshots": "array",
  "token_optimization": {
    "shorthand_rules_active": "boolean",
    "compression_enabled": "boolean",
    "target_tokens_per_turn": "integer"
  }
}
```

### TASK_QUEUE.json Schema

```json
{
  "schema_version": "1.0",
  "queue_id": "string",
  "last_updated": "ISO 8601 datetime",
  "tasks": [
    {
      "task_id": "string",
      "title": "string",
      "priority": "integer (1-4)",
      "assigned_agent": "string",
      "status": "pending|in_progress|completed|failed",
      "created_at": "ISO 8601 datetime",
      "required_turns": "integer",
      "completed_turns": "integer",
      "dependencies": "array",
      "handoff_agent": "string|null",
      "completion_criteria": "object",
      "token_estimate": "integer"
    }
  ]
}
```

### AGENT_REGISTRY.json Schema

```json
{
  "schema_version": "1.0",
  "registry_id": "string",
  "last_updated": "ISO 8601 datetime",
  "agents": {
    "STRYK": {
      "type": "string",
      "capabilities": "array",
      "responsibilities": "array",
      "communication": {
        "preferred_channels": "array",
        "message_format": "string",
        "token_limit": "integer"
      },
      "autohotkey_profile": "string",
      "powershell_module": "string"
    },
    "DC": { /* same structure */ },
    "VSCC": { /* same structure */ }
  },
  "coordination_matrix": {
    "DC↔VSCC": "object",
    "DC↔Browser": "object", 
    "VSCC↔Browser": "object"
  }
}
```

## Configuration API

### config.json Schema

```json
{
  "schema_version": "1.0",
  "system_name": "string",
  "version": "string",
  "environment": {
    "os": "string",
    "powershell_version": "string",
    "autohotkey_version": "string",
    "architecture": "string"
  },
  "paths": {
    "config_dir": "string",
    "logs_dir": "string",
    "cache_dir": "string",
    "temp_dir": "string",
    "scripts_dir": "string"
  },
  "performance": {
    "message_timeout_ms": "integer",
    "max_retries": "integer",
    "snapshot_interval_turns": "integer",
    "max_snapshots": "integer",
    "cleanup_interval_minutes": "integer"
  },
  "coordination": {
    "turn_duration_ms": "integer",
    "handoff_timeout_ms": "integer",
    "unstall_detection_turns": "integer",
    "deadlock_detection_enabled": "boolean"
  },
  "messaging": {
    "compression_enabled": "boolean",
    "encryption_enabled": "boolean",
    "max_message_size_bytes": "integer",
    "message_retention_minutes": "integer"
  },
  "agents": {
    "STRYK": {
      "enabled": "boolean",
      "startup_priority": "integer",
      "resource_limits": {
        "memory_mb": "integer",
        "cpu_percent": "integer"
      }
    },
    "DC": { /* same structure */ },
    "VSCC": { /* same structure */ }
  }
}
```

## Error Codes and Responses

### PowerShell Function Error Codes

| Code | Description | Recovery Action |
|------|-------------|-----------------|
| 1001 | Session initialization failed | Check prerequisites, retry |
| 1002 | State file corrupted | Rollback to snapshot |
| 1003 | Agent communication timeout | Retry with backoff |
| 1004 | Task queue corruption | Rebuild from registry |
| 1005 | Token limit exceeded | Enable emergency mode |

### AutoHotkey Error Codes

| Code | Description | Recovery Action |
|------|-------------|-----------------|
| 2001 | Window not found | Retry with different title |
| 2002 | Injection failed | Fall back to file IPC |
| 2003 | Message queue full | Process queue, retry |
| 2004 | Browser not active | Launch browser, retry |
| 2005 | VSCode not responding | Restart VSCode, retry |

### HTTP-style Status Responses

All API functions return responses in this format:

```powershell
@{
    success = $true|$false
    data = @{}  # Response data
    error = @{
        code = "integer"
        message = "string"
        details = "string"
    }
    timestamp = "ISO 8601 datetime"
}
```

## Usage Examples

### Basic System Initialization

```powershell
# Import the module
Import-Module .\AgentCoordination.psm1

# Initialize the system
Initialize-AgentCoordination -SessionId "demo_session" -SnapshotInterval 5

# Check system status
Show-SystemStatus
```

### Task Creation and Execution

```powershell
# Create a new task (by modifying TASK_QUEUE.json)
$newTask = @{
    task_id = "demo_001"
    title = "Demo Automation Task"
    priority = 2
    assigned_agent = "DC"
    status = "pending"
    created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    required_turns = 3
    completed_turns = 0
    dependencies = @()
    handoff_agent = "VSCC"
    completion_criteria = @{
        windows_found = 1
        actions_completed = @("navigate", "extract")
    }
    token_estimate = 45
}

# Add to task queue (simplified example)
$taskQueue = Get-Content .\TASK_QUEUE.json | ConvertFrom-Json
$taskQueue.tasks += $newTask
$taskQueue | ConvertTo-Json -Depth 10 | Out-File .\TASK_QUEUE.json

# Process the task queue
Process-TaskQueue

# Advance turns manually
Advance-Turn
Advance-Turn
Advance-Turn
```

### Inter-Agent Communication

```powershell
# Send message from STRYK to DC
Send-AgentMessage -TargetAgent "DC" -Message @{
    type = "task"
    content = "EXEC win automation & extract data"
    data = @{
        window = "Chrome"
        url = "https://example.com"
        action = "scrape"
    }
} -Priority "high"

# Check for messages (if you're DC)
$messages = Receive-AgentMessage -AgentName "DC"
foreach ($msg in $messages) {
    Write-Host "From $($msg.from): $($msg.content)"
}
```

### Error Recovery

```powershell
# Detect stalled agents
$stalledAgents = Detect-AgentUnstall
if ($stalledAgents.Count -gt 0) {
    foreach ($agent in $stalledAgents) {
        Write-Warning "Recovering $agent"
        Recover-Agent -AgentName $agent
    }
}

# Rollback to previous snapshot if needed
$success = Rollback-ToSnapshot -TargetTurn 15
if ($success) {
    Write-Host "Successfully rolled back to turn 15"
}
```

### Token Optimization

```powershell
# Optimize text
$original = "Execute the function for the window automation"
$optimized = Optimize-Tokens -Text $original
Write-Host "Original: $original"
Write-Host "Optimized: $optimized"

# Check token usage
$status = Get-SystemStatus
Write-Host "Total tokens used: $($status.total_token_usage)"
if ($status.total_token_usage -gt 100) {
    Write-Warning "High token usage detected!"
}
```

This API reference provides comprehensive documentation for all system components, enabling developers to effectively utilize the multi-agent coordination system for Windows automation tasks.