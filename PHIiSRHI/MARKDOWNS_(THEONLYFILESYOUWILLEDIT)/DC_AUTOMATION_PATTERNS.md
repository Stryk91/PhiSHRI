# DC Automation Patterns - Copy-Paste Ready

**Version**: 1.0.0
**Purpose**: 20+ proven patterns for DC autonomous operation with current tool limitations
**Usage**: Copy pattern code directly into DC commands/scripts

---

## TABLE OF CONTENTS
1. [File-Based Command Protocol](#1-file-based-command-protocol)
2. [Daemon Communication](#2-daemon-communication)
3. [Process Launch Patterns](#3-process-launch-patterns)
4. [Window Management](#4-window-management)
5. [Keyboard Automation](#5-keyboard-automation)
6. [Error Recovery](#6-error-recovery)
7. [Polling Strategies](#7-polling-strategies)
8. [Multi-Agent Coordination](#8-multi-agent-coordination)
9. [State Management](#9-state-management)
10. [Advanced Patterns](#10-advanced-patterns)

---

## 1. FILE-BASED COMMAND PROTOCOL

### Pattern 1.1: Send Command to Daemon
```powershell
# DC drops a command file for daemon to execute
function Send-DaemonCommand {
    param(
        [string]$Action,
        [hashtable]$Params = @{}
    )

    $commandId = [guid]::NewGuid().ToString().Substring(0, 8)
    $command = @{
        id = $commandId
        action = $Action
        params = $Params
        timestamp = (Get-Date -Format 'o')
    }

    $commandFile = "C:\PhiDEX\commands\daemon\cmd_$commandId.json"
    $command | ConvertTo-Json -Depth 10 | Out-File $commandFile -Encoding UTF8

    return $commandId
}

# Example: Launch Claude Code
$cmdId = Send-DaemonCommand -Action 'launch_claude_code' -Params @{
    logFile = 'C:\PhiDEX\logs\claude_code.log'
}
```

### Pattern 1.2: Wait for Daemon Response
```powershell
# DC polls for response from daemon
function Wait-DaemonResponse {
    param(
        [string]$CommandId,
        [int]$TimeoutSeconds = 60,
        [int]$PollIntervalMs = 200
    )

    $responseFile = "C:\PhiDEX\responses\daemon\response_$CommandId.json"
    $elapsed = 0

    while ($elapsed -lt ($TimeoutSeconds * 1000)) {
        if (Test-Path $responseFile) {
            $response = Get-Content $responseFile -Raw | ConvertFrom-Json
            Remove-Item $responseFile -Force
            return $response
        }

        Start-Sleep -Milliseconds $PollIntervalMs
        $elapsed += $PollIntervalMs
    }

    throw "Timeout waiting for response to command $CommandId"
}

# Example: Launch and wait
$cmdId = Send-DaemonCommand -Action 'launch_claude_code' -Params @{ logFile = 'C:\logs\cc.log' }
$response = Wait-DaemonResponse -CommandId $cmdId -TimeoutSeconds 30
Write-Host "Claude Code PID: $($response.result.processId)"
```

### Pattern 1.3: Fire-and-Forget Command
```powershell
# DC sends command without waiting for response
function Send-DaemonCommandAsync {
    param(
        [string]$Action,
        [hashtable]$Params = @{}
    )

    $commandId = [guid]::NewGuid().ToString().Substring(0, 8)
    $command = @{
        id = $commandId
        action = $Action
        params = $Params
        timestamp = (Get-Date -Format 'o')
    }

    $commandFile = "C:\PhiDEX\commands\daemon\cmd_$commandId.json"
    $command | ConvertTo-Json -Depth 10 | Out-File $commandFile -Encoding UTF8

    # Don't wait - return immediately
    return $commandId
}

# Example: Launch process in background, continue work
Send-DaemonCommandAsync -Action 'execute_powershell_async' -Params @{
    scriptBlock = 'Start-Sleep 30; Write-Host "Done"'
}
Write-Host "Continued immediately while background task runs"
```

---

## 2. DAEMON COMMUNICATION

### Pattern 2.1: Check Daemon Health
```powershell
# Verify daemon is running and responsive
function Test-DaemonHealth {
    # Method 1: Check heartbeat file
    $heartbeatFile = "C:\PhiDEX\status\daemon.heartbeat"

    if (Test-Path $heartbeatFile) {
        $heartbeat = Get-Content $heartbeatFile -Raw | ConvertFrom-Json
        $age = (Get-Date) - [datetime]$heartbeat.timestamp

        if ($age.TotalSeconds -lt 30) {
            return @{ healthy = $true; uptime = $heartbeat.uptime }
        }
    }

    # Method 2: Check mutex
    $mutexExists = $false
    try {
        $mutex = [System.Threading.Mutex]::OpenExisting("Global\PhiDEX_Daemon_Singleton")
        $mutex.Dispose()
        $mutexExists = $true
    }
    catch {
        $mutexExists = $false
    }

    return @{ healthy = $mutexExists; uptime = "unknown" }
}

# Usage
$health = Test-DaemonHealth
if (-not $health.healthy) {
    Write-Host "WARNING: Daemon not responding. Launch manually."
}
```

### Pattern 2.2: Auto-Start Daemon if Not Running
```powershell
# DC ensures daemon is running before sending commands
function Ensure-DaemonRunning {
    $health = Test-DaemonHealth

    if (-not $health.healthy) {
        Write-Host "Daemon not running. Starting..."

        # Launch daemon using script execution (& works per research)
        & 'C:\PhiDEX\dc_daemon.ps1'

        # Wait for startup
        Start-Sleep -Seconds 3

        # Verify
        $health = Test-DaemonHealth
        if (-not $health.healthy) {
            throw "Failed to start daemon"
        }
    }

    Write-Host "Daemon healthy (Uptime: $($health.uptime))"
}

# Usage at start of every DC automation session
Ensure-DaemonRunning
```

### Pattern 2.3: Request-Response Pattern
```powershell
# High-level wrapper for command + wait
function Invoke-DaemonAction {
    param(
        [string]$Action,
        [hashtable]$Params = @{},
        [int]$TimeoutSeconds = 60
    )

    Ensure-DaemonRunning

    $cmdId = Send-DaemonCommand -Action $Action -Params $Params
    $response = Wait-DaemonResponse -CommandId $cmdId -TimeoutSeconds $TimeoutSeconds

    if ($response.status -eq 'error') {
        throw "Daemon error: $($response.error)"
    }

    return $response.result
}

# Usage - single line command
$windowInfo = Invoke-DaemonAction -Action 'get_window_info' -Params @{ windowTitle = 'Claude Code' }
Write-Host "Window found: $($windowInfo.found)"
```

---

## 3. PROCESS LAUNCH PATTERNS

### Pattern 3.1: Launch Claude Code with Logging
```powershell
# DC launches Claude Code and captures PID for monitoring
$result = Invoke-DaemonAction -Action 'launch_claude_code' -Params @{
    logFile = 'C:\PhiDEX\logs\claude_code_$(Get-Date -Format "yyyyMMdd_HHmmss").log'
}

$claudePid = $result.processId
Write-Host "Claude Code launched (PID: $claudePid)"

# Store PID for later reference
$claudePid | Out-File 'C:\PhiDEX\status\claude_code.pid' -Encoding UTF8
```

### Pattern 3.2: Launch Any Process via Daemon
```powershell
# General-purpose process launcher
function Start-ProcessViaDaemon {
    param(
        [string]$ExecutablePath,
        [string]$Arguments = '',
        [ValidateSet('Normal', 'Hidden', 'Minimized', 'Maximized')]
        [string]$WindowStyle = 'Normal'
    )

    $result = Invoke-DaemonAction -Action 'launch_process' -Params @{
        executable = $ExecutablePath
        arguments = $Arguments
        windowStyle = $WindowStyle
    }

    return $result.processId
}

# Example: Launch PowerShell ISE
$isePid = Start-ProcessViaDaemon -ExecutablePath 'powershell_ise.exe' -WindowStyle Normal
```

### Pattern 3.3: Check if Process is Running
```powershell
# Monitor launched process status
function Get-ProcessStatusViaDaemon {
    param([int]$ProcessId)

    $status = Invoke-DaemonAction -Action 'check_process' -Params @{ processId = $ProcessId }
    return $status
}

# Usage with retry logic
$claudePid = Get-Content 'C:\PhiDEX\status\claude_code.pid'
$status = Get-ProcessStatusViaDaemon -ProcessId $claudePid

if (-not $status.running) {
    Write-Host "Claude Code not running, restarting..."
    $newPid = Invoke-DaemonAction -Action 'launch_claude_code' -Params @{}
    $newPid.processId | Out-File 'C:\PhiDEX\status\claude_code.pid'
}
```

---

## 4. WINDOW MANAGEMENT

### Pattern 4.1: Focus Window by Title
```powershell
# DC switches focus to specific window
function Set-WindowFocusViaDaemon {
    param([string]$WindowTitle)

    $result = Invoke-DaemonAction -Action 'focus_window' -Params @{ windowTitle = $WindowTitle }
    return $result.focused
}

# Example: Focus Claude Code window
$focused = Set-WindowFocusViaDaemon -WindowTitle 'Claude Code'
if (-not $focused) {
    Write-Host "WARNING: Could not focus Claude Code window"
}
```

### Pattern 4.2: Window Switching Sequence
```powershell
# DC orchestrates multi-window workflow
function Invoke-WindowSequence {
    # Step 1: Focus editor
    Set-WindowFocusViaDaemon -WindowTitle 'Visual Studio Code' | Out-Null
    Start-Sleep -Milliseconds 500

    # Step 2: Send command to editor
    Invoke-DaemonAction -Action 'send_keys' -Params @{
        windowTitle = 'Visual Studio Code'
        keys = '^+p'  # Ctrl+Shift+P (Command Palette)
    }
    Start-Sleep -Milliseconds 300

    # Step 3: Type command
    Invoke-DaemonAction -Action 'send_keys' -Params @{
        keys = 'Claude: Open Chat~'  # ~ is Enter
    }
    Start-Sleep -Milliseconds 500

    # Step 4: Switch to terminal
    Set-WindowFocusViaDaemon -WindowTitle 'PowerShell' | Out-Null
}

# Execute sequence
Invoke-WindowSequence
```

### Pattern 4.3: Find Window by Process
```powershell
# Locate window for a launched process
function Get-WindowByProcess {
    param([int]$ProcessId)

    $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if ($process) {
        return @{
            found = $true
            windowTitle = $process.MainWindowTitle
            windowHandle = $process.MainWindowHandle
        }
    }
    return @{ found = $false }
}

# Example: Find Claude Code window after launch
$claudePid = Get-Content 'C:\PhiDEX\status\claude_code.pid'
$window = Get-WindowByProcess -ProcessId $claudePid
Write-Host "Window title: $($window.windowTitle)"
```

---

## 5. KEYBOARD AUTOMATION

### Pattern 5.1: Send Text Input
```powershell
# DC sends text to focused application
function Send-TextInput {
    param(
        [string]$Text,
        [string]$WindowTitle = $null
    )

    # Escape special characters for SendKeys
    $escapedText = $Text -replace '\+', '{+}' -replace '\^', '{^}' -replace '%', '{%}' -replace '~', '{~}'

    Invoke-DaemonAction -Action 'send_keys' -Params @{
        windowTitle = $WindowTitle
        keys = $escapedText
    }
}

# Example: Type into Claude Code
Set-WindowFocusViaDaemon -WindowTitle 'Claude Code'
Start-Sleep -Milliseconds 500
Send-TextInput -Text 'Hello from DC automation!'
```

### Pattern 5.2: Keyboard Shortcut Sequences
```powershell
# Common keyboard shortcuts
function Send-KeyboardShortcut {
    param(
        [ValidateSet('Copy', 'Paste', 'Save', 'Undo', 'Redo', 'SelectAll', 'Enter', 'Escape', 'Tab', 'AltTab')]
        [string]$Shortcut,
        [string]$WindowTitle = $null
    )

    $keyMap = @{
        Copy     = '^c'
        Paste    = '^v'
        Save     = '^s'
        Undo     = '^z'
        Redo     = '^y'
        SelectAll = '^a'
        Enter    = '~'
        Escape   = '{ESC}'
        Tab      = '{TAB}'
        AltTab   = '%{TAB}'
    }

    Invoke-DaemonAction -Action 'send_keys' -Params @{
        windowTitle = $WindowTitle
        keys = $keyMap[$Shortcut]
    }
}

# Example: Copy, switch window, paste
Send-KeyboardShortcut -Shortcut 'SelectAll'
Send-KeyboardShortcut -Shortcut 'Copy'
Send-KeyboardShortcut -Shortcut 'AltTab'
Start-Sleep -Milliseconds 300
Send-KeyboardShortcut -Shortcut 'Paste'
```

### Pattern 5.3: Complex Input Sequence
```powershell
# Multi-step input automation
function Invoke-InputSequence {
    param(
        [string]$WindowTitle,
        [hashtable[]]$Steps
    )

    Set-WindowFocusViaDaemon -WindowTitle $WindowTitle | Out-Null
    Start-Sleep -Milliseconds 500

    foreach ($step in $Steps) {
        switch ($step.Type) {
            'Text' {
                Send-TextInput -Text $step.Value
            }
            'Shortcut' {
                Send-KeyboardShortcut -Shortcut $step.Value
            }
            'Keys' {
                Invoke-DaemonAction -Action 'send_keys' -Params @{ keys = $step.Value }
            }
            'Wait' {
                Start-Sleep -Milliseconds $step.Value
            }
        }

        if ($step.DelayAfter) {
            Start-Sleep -Milliseconds $step.DelayAfter
        }
    }
}

# Example: Open file in editor
Invoke-InputSequence -WindowTitle 'Visual Studio Code' -Steps @(
    @{ Type = 'Shortcut'; Value = 'Save'; DelayAfter = 200 }
    @{ Type = 'Keys'; Value = '^o'; DelayAfter = 300 }  # Ctrl+O (Open)
    @{ Type = 'Text'; Value = 'C:\PhiDEX\script.ps1'; DelayAfter = 200 }
    @{ Type = 'Shortcut'; Value = 'Enter' }
)
```

---

## 6. ERROR RECOVERY

### Pattern 6.1: Retry with Exponential Backoff
```powershell
# Robust retry pattern for flaky operations
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$InitialDelayMs = 1000,
        [double]$BackoffMultiplier = 2.0
    )

    $attempt = 0
    $delay = $InitialDelayMs

    while ($attempt -lt $MaxRetries) {
        try {
            return & $ScriptBlock
        }
        catch {
            $attempt++
            if ($attempt -ge $MaxRetries) {
                throw "Failed after $MaxRetries attempts: $_"
            }

            Write-Host "Attempt $attempt failed: $_. Retrying in $($delay)ms..."
            Start-Sleep -Milliseconds $delay
            $delay = [int]($delay * $BackoffMultiplier)
        }
    }
}

# Example: Retry window focus
Invoke-WithRetry -ScriptBlock {
    $focused = Set-WindowFocusViaDaemon -WindowTitle 'Claude Code'
    if (-not $focused) { throw "Window not found" }
    return $focused
}
```

### Pattern 6.2: Graceful Degradation
```powershell
# Try multiple approaches, use first that works
function Invoke-WithFallback {
    param([scriptblock[]]$Approaches)

    foreach ($approach in $Approaches) {
        try {
            $result = & $approach
            if ($result) { return $result }
        }
        catch {
            Write-Host "Approach failed: $_. Trying next..."
        }
    }

    throw "All approaches failed"
}

# Example: Find Claude Code window multiple ways
$windowInfo = Invoke-WithFallback -Approaches @(
    { Invoke-DaemonAction -Action 'get_window_info' -Params @{ windowTitle = 'Claude Code' } }
    { Invoke-DaemonAction -Action 'get_window_info' -Params @{ windowTitle = 'claude-code' } }
    { Get-Process -Name 'claude-code' -ErrorAction Stop | Select-Object -First 1 }
)
```

### Pattern 6.3: Health Check and Auto-Recover
```powershell
# Ensure system is healthy before proceeding
function Assert-SystemHealth {
    # Check daemon
    $daemonHealth = Test-DaemonHealth
    if (-not $daemonHealth.healthy) {
        Write-Host "Daemon unhealthy, restarting..."
        & 'C:\PhiDEX\dc_daemon.ps1'
        Start-Sleep -Seconds 3
    }

    # Check Claude Code
    if (Test-Path 'C:\PhiDEX\status\claude_code.pid') {
        $claudePid = Get-Content 'C:\PhiDEX\status\claude_code.pid'
        $status = Get-ProcessStatusViaDaemon -ProcessId $claudePid

        if (-not $status.running) {
            Write-Host "Claude Code not running, restarting..."
            $result = Invoke-DaemonAction -Action 'launch_claude_code' -Params @{}
            $result.processId | Out-File 'C:\PhiDEX\status\claude_code.pid'
        }
    }
}

# Run at start of automation
Assert-SystemHealth
```

---

## 7. POLLING STRATEGIES

### Pattern 7.1: Poll for File Existence
```powershell
# Wait for file to appear (e.g., process output)
function Wait-FileExists {
    param(
        [string]$FilePath,
        [int]$TimeoutSeconds = 60,
        [int]$PollIntervalMs = 200
    )

    $elapsed = 0
    while ($elapsed -lt ($TimeoutSeconds * 1000)) {
        if (Test-Path $FilePath) {
            return $true
        }
        Start-Sleep -Milliseconds $PollIntervalMs
        $elapsed += $PollIntervalMs
    }

    return $false
}

# Example: Wait for log file
$logFile = 'C:\PhiDEX\logs\claude_code.log'
if (Wait-FileExists -FilePath $logFile -TimeoutSeconds 30) {
    $logContent = Get-Content $logFile -Raw
    Write-Host "Log content: $logContent"
}
```

### Pattern 7.2: Poll for File Content Match
```powershell
# Wait for specific content in file
function Wait-FileContentMatch {
    param(
        [string]$FilePath,
        [string]$Pattern,
        [int]$TimeoutSeconds = 60,
        [int]$PollIntervalMs = 500
    )

    $elapsed = 0
    while ($elapsed -lt ($TimeoutSeconds * 1000)) {
        if (Test-Path $FilePath) {
            $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
            if ($content -match $Pattern) {
                return $true
            }
        }
        Start-Sleep -Milliseconds $PollIntervalMs
        $elapsed += $PollIntervalMs
    }

    return $false
}

# Example: Wait for "Ready" in log
if (Wait-FileContentMatch -FilePath 'C:\logs\app.log' -Pattern 'Server ready') {
    Write-Host "Application started successfully"
}
```

### Pattern 7.3: Event-Driven Polling (Minimal CPU)
```powershell
# Use FileSystemWatcher for efficient waiting
function Wait-FileCreated {
    param(
        [string]$Path,
        [string]$Filter,
        [int]$TimeoutSeconds = 60
    )

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $Path
    $watcher.Filter = $Filter
    $watcher.EnableRaisingEvents = $true

    try {
        $result = Wait-Event -SourceIdentifier FileCreated -Timeout $TimeoutSeconds
        if ($result) {
            return $result.SourceEventArgs.FullPath
        }
        return $null
    }
    finally {
        $watcher.Dispose()
        Get-Event -SourceIdentifier FileCreated -ErrorAction SilentlyContinue | Remove-Event
    }
}

# Example: Wait for response file
$responseFile = Wait-FileCreated -Path 'C:\PhiDEX\responses\daemon' -Filter 'response_*.json' -TimeoutSeconds 30
```

---

## 8. MULTI-AGENT COORDINATION

### Pattern 8.1: DC → VSSC Command
```powershell
# DC sends task to VSSC agent
function Send-VSSCCommand {
    param(
        [string]$Action,
        [hashtable]$Params = @{}
    )

    $commandId = [guid]::NewGuid().ToString().Substring(0, 8)
    $command = @{
        id = $commandId
        action = $Action
        params = $Params
        timestamp = (Get-Date -Format 'o')
        sender = 'DC'
    }

    $commandFile = "C:\PhiDEX\commands\vssc\cmd_$commandId.json"
    $command | ConvertTo-Json -Depth 10 | Out-File $commandFile -Encoding UTF8

    return $commandId
}

# Example: Ask VSSC to prepare environment
$cmdId = Send-VSSCCommand -Action 'prepare_environment' -Params @{
    repository = 'PhiDEX'
    branch = 'main'
}
```

### Pattern 8.2: Wait for Agent Response
```powershell
# DC polls for VSSC response
function Wait-VSSCResponse {
    param(
        [string]$CommandId,
        [int]$TimeoutSeconds = 120
    )

    $responseFile = "C:\PhiDEX\responses\vssc\response_$CommandId.json"
    return Wait-FileExists -FilePath $responseFile -TimeoutSeconds $TimeoutSeconds
}

# Usage
$cmdId = Send-VSSCCommand -Action 'run_tests' -Params @{ suite = 'integration' }
if (Wait-VSSCResponse -CommandId $cmdId -TimeoutSeconds 300) {
    $response = Get-Content "C:\PhiDEX\responses\vssc\response_$cmdId.json" | ConvertFrom-Json
    Write-Host "Test result: $($response.result.status)"
}
```

### Pattern 8.3: Orchestration Flow
```powershell
# DC orchestrates multi-agent workflow
function Invoke-MultiAgentWorkflow {
    Write-Host "=== Multi-Agent Workflow Started ==="

    # Step 1: DC ensures daemon is running
    Assert-SystemHealth

    # Step 2: DC asks VSSC to prepare environment
    $vsscCmd = Send-VSSCCommand -Action 'prepare_environment' -Params @{}
    Wait-VSSCResponse -CommandId $vsscCmd -TimeoutSeconds 60 | Out-Null

    # Step 3: DC launches Claude Code via daemon
    $ccResult = Invoke-DaemonAction -Action 'launch_claude_code' -Params @{}
    $claudePid = $ccResult.processId

    # Step 4: DC waits for Claude Code to be ready
    Start-Sleep -Seconds 5

    # Step 5: DC focuses Claude Code and sends command
    Set-WindowFocusViaDaemon -WindowTitle 'Claude Code' | Out-Null
    Send-TextInput -Text '/ask What is the project structure?'
    Send-KeyboardShortcut -Shortcut 'Enter'

    # Step 6: DC monitors for completion
    Write-Host "Workflow executing. Monitoring..."

    # Step 7: DC collects results from all agents
    Write-Host "=== Workflow Complete ==="
}

# Execute
Invoke-MultiAgentWorkflow
```

---

## 9. STATE MANAGEMENT

### Pattern 9.1: Shared State File
```powershell
# Read/write shared state between agents
function Get-SharedState {
    param([string]$Key)

    $stateFile = 'C:\PhiDEX\status\shared_state.json'
    if (Test-Path $stateFile) {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json -AsHashtable
        return $state[$Key]
    }
    return $null
}

function Set-SharedState {
    param(
        [string]$Key,
        [object]$Value
    )

    $stateFile = 'C:\PhiDEX\status\shared_state.json'
    $state = @{}

    if (Test-Path $stateFile) {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json -AsHashtable
    }

    $state[$Key] = $Value
    $state | ConvertTo-Json -Depth 10 | Out-File $stateFile -Encoding UTF8
}

# Usage
Set-SharedState -Key 'claude_code_pid' -Value 12345
$pid = Get-SharedState -Key 'claude_code_pid'
```

### Pattern 9.2: Lock-Based Coordination
```powershell
# Prevent race conditions with file locks
function Invoke-WithLock {
    param(
        [string]$LockName,
        [scriptblock]$ScriptBlock,
        [int]$TimeoutSeconds = 30
    )

    $lockFile = "C:\PhiDEX\status\$LockName.lock"
    $acquired = $false
    $elapsed = 0

    while (-not $acquired -and $elapsed -lt $TimeoutSeconds) {
        try {
            # Try to create lock file
            $stream = [System.IO.File]::Open($lockFile, 'CreateNew', 'Write', 'None')
            $acquired = $true
            $stream.Close()
        }
        catch {
            Start-Sleep -Milliseconds 100
            $elapsed += 0.1
        }
    }

    if (-not $acquired) {
        throw "Failed to acquire lock: $LockName"
    }

    try {
        return & $ScriptBlock
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

# Example: Safely update shared state
Invoke-WithLock -LockName 'state_update' -ScriptBlock {
    Set-SharedState -Key 'counter' -Value ((Get-SharedState -Key 'counter') + 1)
}
```

### Pattern 9.3: Event Log Pattern
```powershell
# Append-only event log for coordination
function Write-EventLog {
    param(
        [string]$Event,
        [hashtable]$Data = @{}
    )

    $logFile = 'C:\PhiDEX\status\events.log'
    $entry = @{
        timestamp = (Get-Date -Format 'o')
        event = $Event
        data = $Data
    }

    $entryJson = $entry | ConvertTo-Json -Compress
    Add-Content -Path $logFile -Value $entryJson
}

function Get-EventsSince {
    param([datetime]$Since)

    $logFile = 'C:\PhiDEX\status\events.log'
    if (-not (Test-Path $logFile)) { return @() }

    $events = Get-Content $logFile | ForEach-Object {
        $_ | ConvertFrom-Json
    } | Where-Object {
        [datetime]$_.timestamp -gt $Since
    }

    return $events
}

# Usage
Write-EventLog -Event 'claude_code_started' -Data @{ pid = 12345 }
$recentEvents = Get-EventsSince -Since (Get-Date).AddMinutes(-5)
```

---

## 10. ADVANCED PATTERNS

### Pattern 10.1: Async Task Queue
```powershell
# DC queues tasks for background execution
function Add-TaskToQueue {
    param(
        [string]$TaskName,
        [hashtable]$Params
    )

    $taskId = [guid]::NewGuid().ToString().Substring(0, 8)
    $task = @{
        id = $taskId
        name = $TaskName
        params = $Params
        status = 'queued'
        created = (Get-Date -Format 'o')
    }

    $taskFile = "C:\PhiDEX\tasks\queued\task_$taskId.json"
    $task | ConvertTo-Json -Depth 10 | Out-File $taskFile -Encoding UTF8

    return $taskId
}

# Worker picks up tasks
function Invoke-TaskWorker {
    while ($true) {
        $tasks = Get-ChildItem 'C:\PhiDEX\tasks\queued\*.json'

        foreach ($taskFile in $tasks) {
            $task = Get-Content $taskFile.FullName | ConvertFrom-Json

            # Move to processing
            Move-Item $taskFile.FullName "C:\PhiDEX\tasks\processing\$($taskFile.Name)"

            # Execute task
            try {
                $result = & $task.params.scriptBlock
                $task.status = 'completed'
                $task.result = $result
            }
            catch {
                $task.status = 'failed'
                $task.error = $_.Exception.Message
            }

            # Move to completed
            $task | ConvertTo-Json -Depth 10 | Out-File "C:\PhiDEX\tasks\completed\$($taskFile.Name)"
            Remove-Item "C:\PhiDEX\tasks\processing\$($taskFile.Name)" -Force
        }

        Start-Sleep -Seconds 1
    }
}
```

### Pattern 10.2: Workflow State Machine
```powershell
# Complex workflow with state transitions
class Workflow {
    [string]$Id
    [string]$State
    [hashtable]$Context
    [datetime]$LastTransition

    Workflow([string]$id) {
        $this.Id = $id
        $this.State = 'init'
        $this.Context = @{}
        $this.LastTransition = Get-Date
    }

    [void] Transition([string]$newState) {
        Write-Host "Workflow $($this.Id): $($this.State) → $newState"
        $this.State = $newState
        $this.LastTransition = Get-Date
        $this.Save()
    }

    [void] Save() {
        $this | ConvertTo-Json -Depth 10 | Out-File "C:\PhiDEX\workflows\$($this.Id).json"
    }

    static [Workflow] Load([string]$id) {
        $json = Get-Content "C:\PhiDEX\workflows\$id.json" | ConvertFrom-Json
        $wf = [Workflow]::new($id)
        $wf.State = $json.State
        $wf.Context = $json.Context
        $wf.LastTransition = $json.LastTransition
        return $wf
    }
}

# Example: DC automation workflow
$wf = [Workflow]::new((New-Guid).Guid.Substring(0,8))
$wf.Transition('launching_daemon')
Ensure-DaemonRunning
$wf.Transition('launching_claude_code')
$claudeResult = Invoke-DaemonAction -Action 'launch_claude_code'
$wf.Context['claude_pid'] = $claudeResult.processId
$wf.Transition('executing_commands')
# ... more steps ...
$wf.Transition('completed')
```

### Pattern 10.3: Distributed Tracing
```powershell
# Track operations across agents with correlation IDs
function New-TraceContext {
    return @{
        TraceId = [guid]::NewGuid().ToString()
        SpanId = [guid]::NewGuid().ToString().Substring(0, 8)
        ParentSpanId = $null
    }
}

function Start-Span {
    param(
        [hashtable]$Context,
        [string]$Operation
    )

    $span = @{
        TraceId = $Context.TraceId
        SpanId = [guid]::NewGuid().ToString().Substring(0, 8)
        ParentSpanId = $Context.SpanId
        Operation = $Operation
        StartTime = Get-Date -Format 'o'
    }

    return $span
}

function Complete-Span {
    param([hashtable]$Span)

    $Span.EndTime = Get-Date -Format 'o'
    $Span.Duration = ([datetime]$Span.EndTime - [datetime]$Span.StartTime).TotalMilliseconds

    # Log span
    $Span | ConvertTo-Json -Compress | Add-Content 'C:\PhiDEX\traces\traces.jsonl'
}

# Example: Trace multi-step operation
$trace = New-TraceContext
$span1 = Start-Span -Context $trace -Operation 'launch_claude_code'
Invoke-DaemonAction -Action 'launch_claude_code'
Complete-Span -Span $span1

$span2 = Start-Span -Context $trace -Operation 'focus_window'
Set-WindowFocusViaDaemon -WindowTitle 'Claude Code'
Complete-Span -Span $span2
```

---

## QUICK REFERENCE

### Most Common Patterns
```powershell
# 1. Ensure daemon is running
Ensure-DaemonRunning

# 2. Launch Claude Code
$result = Invoke-DaemonAction -Action 'launch_claude_code'
$pid = $result.processId

# 3. Focus window
Set-WindowFocusViaDaemon -WindowTitle 'Claude Code'

# 4. Send text
Send-TextInput -Text 'Hello world'

# 5. Send keyboard shortcut
Send-KeyboardShortcut -Shortcut 'Enter'

# 6. Wait for file
Wait-FileExists -FilePath 'C:\output.txt' -TimeoutSeconds 30

# 7. Check process status
$status = Get-ProcessStatusViaDaemon -ProcessId $pid

# 8. Coordinate with VSSC
$cmdId = Send-VSSCCommand -Action 'run_tests'
Wait-VSSCResponse -CommandId $cmdId

# 9. Error recovery
Invoke-WithRetry -ScriptBlock { /* operation */ }

# 10. Health check
Assert-SystemHealth
```

---

## PATTERN COMBINATIONS

### Complete Autonomous Flow
```powershell
# DC performs end-to-end automation with zero manual intervention
function Invoke-AutonomousSession {
    try {
        # 1. System health
        Assert-SystemHealth

        # 2. Launch Claude Code
        $ccResult = Invoke-DaemonAction -Action 'launch_claude_code' -Params @{
            logFile = "C:\PhiDEX\logs\claude_$(Get-Date -Format 'yyyyMMddHHmmss').log"
        }
        Set-SharedState -Key 'claude_pid' -Value $ccResult.processId

        # 3. Wait for ready
        Wait-FileContentMatch -FilePath $ccResult.logFile -Pattern 'Ready' -TimeoutSeconds 30

        # 4. Focus and interact
        Invoke-WithRetry -ScriptBlock {
            Set-WindowFocusViaDaemon -WindowTitle 'Claude Code'
        }
        Start-Sleep -Milliseconds 500

        # 5. Send command
        Send-TextInput -Text '/ask Analyze the codebase structure'
        Send-KeyboardShortcut -Shortcut 'Enter'

        # 6. Monitor for completion (poll log file)
        while (-not (Wait-FileContentMatch -FilePath $ccResult.logFile -Pattern 'Analysis complete' -TimeoutSeconds 5)) {
            Write-Host "Still processing..."
        }

        # 7. Extract results
        $logContent = Get-Content $ccResult.logFile -Raw
        $results = $logContent | Select-String -Pattern 'Result: (.+)' | ForEach-Object { $_.Matches.Groups[1].Value }

        # 8. Report
        Write-Host "Autonomous session complete. Results: $results"

        return @{ success = $true; results = $results }
    }
    catch {
        Write-Host "Autonomous session failed: $_"
        return @{ success = $false; error = $_.Exception.Message }
    }
}

# Execute autonomous session
$result = Invoke-AutonomousSession
```

---

**END OF PATTERNS LIBRARY**

DC now has 20+ copy-paste ready patterns for autonomous operation.
Deploy daemon, run patterns, achieve autonomy. 🚀
