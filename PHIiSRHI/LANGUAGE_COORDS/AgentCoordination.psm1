# AgentCoordination.psm1 - Multi-Agent Coordination System
# Version 1.0 - Windows Automation Framework

using namespace System.Text.Json

# Module Variables
$Script:SessionState = $null
$Script:TaskQueue = $null
$Script:AgentRegistry = $null
$Script:ConfigPath = ".\config"
$Script:SessionStatePath = "$ConfigPath\SESSION_STATE.json"
$Script:TaskQueuePath = "$ConfigPath\TASK_QUEUE.json"
$Script:AgentRegistryPath = "$ConfigPath\AGENT_REGISTRY.json"

# Token Optimization Rules
$Script:ShorthandRules = @{
    "the" = ""
    "and" = "&"
    "for" = "4"
    "to" = "2"
    "you" = "u"
    "window" = "win"
    "application" = "app"
    "function" = "fn"
    "variable" = "var"
    "execute" = "exec"
    "process" = "proc"
    "message" = "msg"
    "coordination" = "coord"
    "automation" = "auto"
    "management" = "mgmt"
    "optimization" = "opt"
    "validation" = "val"
}

#region State Management Functions

function Initialize-AgentCoordination {
    <#
    .SYNOPSIS
    Initialize the multi-agent coordination system
    #>
    param(
        [string]$SessionId = "sess_$((Get-Date).Ticks)",
        [int]$SnapshotInterval = 10
    )
    
    # Create config directory
    if (!(Test-Path $ConfigPath)) {
        New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null
    }
    
    # Initialize Session State
    $Script:SessionState = @{
        schema_version = "1.0"
        session_id = $SessionId
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        turn_counter = 0
        snapshot_interval = $SnapshotInterval
        last_snapshot_turn = 0
        active_agents = @{
            STRYK = @{ status = "idle"; last_turn = 0; context_hash = ""; token_usage = 0 }
            DC = @{ status = "idle"; last_turn = 0; context_hash = ""; token_usage = 0 }
            VSCC = @{ status = "idle"; last_turn = 0; context_hash = ""; token_usage = 0 }
        }
        shared_context = @{ windows = @{}; variables = @{}; clipboard = "" }
        snapshots = @()
        token_optimization = @{
            shorthand_rules_active = $true
            compression_enabled = $true
            target_tokens_per_turn = 50
        }
    }
    
    Save-SessionState
    Write-Host "Agent coordination initialized: $SessionId"
}

function Save-SessionState {
    <#
    .SYNOPSIS
    Save current session state to JSON file
    #>
    $Script:SessionState.timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $Script:SessionState | ConvertTo-Json -Depth 10 | Out-File -FilePath $SessionStatePath -Encoding UTF8
}

function Load-SessionState {
    <#
    .SYNOPSIS
    Load session state from JSON file
    #>
    if (Test-Path $SessionStatePath) {
        $Script:SessionState = Get-Content $SessionStatePath | ConvertFrom-Json
        return $true
    }
    return $false
}

function Create-StateSnapshot {
    <#
    .SYNOPSIS
    Create snapshot of current state for rollback capability
    #>
    param([int]$Turn = $Script:SessionState.turn_counter)
    
    $snapshot = @{
        turn = $Turn
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        session_state = $Script:SessionState | ConvertTo-Json -Compress -Depth 10
        task_queue = $Script:TaskQueue | ConvertTo-Json -Compress -Depth 10
    }
    
    $Script:SessionState.snapshots += $snapshot
    $Script:SessionState.last_snapshot_turn = $Turn
    
    # Keep only last 10 snapshots to manage memory
    if ($Script:SessionState.snapshots.Count -gt 10) {
        $Script:SessionState.snapshots = $Script:SessionState.snapshots[-10..-1]
    }
    
    Save-SessionState
    Write-Host "State snapshot created at turn $Turn"
}

function Rollback-ToSnapshot {
    <#
    .SYNOPSIS
    Rollback to previous state snapshot
    #>
    param([int]$TargetTurn)
    
    $snapshot = $Script:SessionState.snapshots | Where-Object { $_.turn -eq $TargetTurn }
    if ($snapshot) {
        $Script:SessionState = $snapshot.session_state | ConvertFrom-Json
        Save-SessionState
        Write-Host "Rolled back to turn $TargetTurn"
        return $true
    }
    return $false
}

#endregion

#region Token Optimization Functions

function Optimize-Tokens {
    <#
    .SYNOPSIS
    Apply shorthand rules to reduce token usage
    #>
    param([string]$Text)
    
    if (!$Script:SessionState.token_optimization.shorthand_rules_active) {
        return $Text
    }
    
    $optimized = $Text.ToLower()
    foreach ($rule in $Script:ShorthandRules.GetEnumerator()) {
        $optimized = $optimized -replace "\b$($rule.Name)\b", $rule.Value
    }
    
    return $optimized
}

function Compress-Message {
    <#
    .SYNOPSIS
    Compress message using JSON format
    #>
    param([hashtable]$Message)
    
    if ($Script:SessionState.token_optimization.compression_enabled) {
        return $Message | ConvertTo-Json -Compress
    }
    return $Message | ConvertTo-Json
}

function Estimate-Tokens {
    <#
    .SYNOPSIS
    Estimate token count for message
    #>
    param([string]$Text)
    
    # Rough estimation: ~4 characters per token
    return [math]::Ceiling($Text.Length / 4)
}

#endregion

#region Messaging and IPC Functions

function Send-AgentMessage {
    <#
    .SYNOPSIS
    Send message to specific agent using file-based IPC
    #>
    param(
        [string]$TargetAgent,
        [hashtable]$Message,
        [string]$Priority = "normal"
    )
    
    # Optimize message content
    $optimizedMessage = @{
        from = $Script:SessionState.active_agents.GetEnumerator().Where({$_.Value.status -eq "active"}).Name
        to = $TargetAgent
        turn = $Script:SessionState.turn_counter
        priority = $Priority
        content = Optimize-Tokens -Text ($Message.content ?? "")
        type = $Message.type ?? "info"
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    
    # Write to message file
    $messageFile = "$ConfigPath\msg_${TargetAgent}_$((Get-Date).Ticks).json"
    $optimizedMessage | ConvertTo-Json -Compress | Out-File -FilePath $messageFile -Encoding UTF8
    
    # Send PowerShell alert based on message type
    switch ($Message.type) {
        "completion" { Invoke-Alert -Type "completion" }
        "info" { Invoke-Alert -Type "info" }
        "critical" { Invoke-Alert -Type "critical" }
        default { Invoke-Alert -Type "info" }
    }
    
    Write-Host "Message sent to $TargetAgent"
}

function Receive-AgentMessage {
    <#
    .SYNOPSIS
    Receive messages for current agent
    #>
    param([string]$AgentName)
    
    $messageFiles = Get-ChildItem "$ConfigPath\msg_${AgentName}_*.json" | Sort-Object LastWriteTime
    $messages = @()
    
    foreach ($file in $messageFiles) {
        $message = Get-Content $file.FullName | ConvertFrom-Json
        $messages += $message
        
        # Clean up processed message
        Remove-Item $file.FullName
    }
    
    return $messages
}

function Invoke-Alert {
    <#
    .SYNOPSIS
    Send PowerShell audio alert for different message types
    #>
    param([string]$Type = "info")
    
    switch ($Type) {
        "completion" {
            # 800Hz beep for task completion
            [console]::beep(800, 200)
        }
        "info" {
            # 600Hz beep for info
            [console]::beep(600, 150)
        }
        "critical" {
            # 1000Hz triple-beep for critical
            [console]::beep(1000, 100)
            Start-Sleep -Milliseconds 100
            [console]::beep(1000, 100)
            Start-Sleep -Milliseconds 100
            [console]::beep(1000, 100)
        }
    }
}

#endregion

#region Workflow Engine Functions

function Advance-Turn {
    <#
    .SYNOPSIS
    Advance to next turn in coordination sequence
    #>
    param([string]$NextAgent = "auto")
    
    $Script:SessionState.turn_counter++
    
    # Determine next active agent
    if ($NextAgent -eq "auto") {
        $agents = @("STRYK", "DC", "VSCC")
        $currentAgentIndex = $agents.IndexOf($Script:SessionState.active_agents.GetEnumerator().Where({$_.Value.current_turn -eq $true}).Name)
        $nextAgentIndex = ($currentAgentIndex + 1) % $agents.Count
        $NextAgent = $agents[$nextAgentIndex]
    }
    
    # Update agent statuses
    foreach ($agent in $Script:SessionState.active_agents.GetEnumerator()) {
        $agent.Value.current_turn = ($agent.Name -eq $NextAgent)
        if ($agent.Value.current_turn) {
            $agent.Value.status = "active"
            $agent.Value.last_turn = $Script:SessionState.turn_counter
        } else {
            $agent.Value.status = "idle"
        }
    }
    
    # Check if snapshot is needed
    if ($Script:SessionState.turn_counter - $Script:SessionState.last_snapshot_turn -ge $Script:SessionState.snapshot_interval) {
        Create-StateSnapshot
    }
    
    Save-SessionState
    Write-Host "Turn $($Script:SessionState.turn_counter): $NextAgent active"
}

function Process-TaskQueue {
    <#
    .SYNOPSIS
    Process tasks in queue with priority and dependencies
    #>
    $readyTasks = $Script:TaskQueue.tasks | Where-Object { 
        $_.status -eq "pending" -and 
        ($_.dependencies.Count -eq 0 -or $true) # TODO: Check dependencies
    } | Sort-Object priority
    
    foreach ($task in $readyTasks) {
        $assignedAgent = $Script:SessionState.active_agents[$task.assigned_agent]
        if ($assignedAgent.status -eq "active") {
            $task.status = "in_progress"
            $task.started_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            
            # Send task to agent
            Send-AgentMessage -TargetAgent $task.assigned_agent -Message @{
                type = "task"
                content = "EXEC task $($task.task_id): $($task.title)"
                data = $task
            } -Priority $task.priority
            
            break # Process one task per turn
        }
    }
    
    Save-TaskQueue
}

function Complete-Task {
    <#
    .SYNOPSIS
    Mark task as completed and handle handoffs
    #>
    param(
        [string]$TaskId,
        [hashtable]$Results = @{}
    )
    
    $task = $Script:TaskQueue.tasks | Where-Object { $_.task_id -eq $TaskId }
    if ($task) {
        $task.status = "completed"
        $task.completed_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        $task.results = $Results
        
        # Handle handoff
        if ($task.handoff_agent) {
            Send-AgentMessage -TargetAgent $task.handoff_agent -Message @{
                type = "handoff"
                content = "HANDOFF from $($task.assigned_agent): $($task.title)"
                data = @{
                    source_task = $TaskId
                    completion_results = $Results
                }
            } -Priority "high"
        }
        
        # Send completion alert
        Send-AgentMessage -TargetAgent "STRYK" -Message @{
            type = "completion"
            content = "TASK COMPLETE: $($task.title)"
            data = $Results
        }
        
        Save-TaskQueue
        Write-Host "Task $TaskId completed"
    }
}

#endregion

#region Error Handling and Recovery

function Detect-AgentUnstall {
    <#
    .SYNOPSIS
    Detect if any agent is stalled
    #>
    $currentTurn = $Script:SessionState.turn_counter
    $stalledAgents = @()
    
    foreach ($agent in $Script:SessionState.active_agents.GetEnumerator()) {
        if ($currentTurn - $agent.Value.last_turn -gt 3) {
            $stalledAgents += $agent.Name
        }
    }
    
    if ($stalledAgents.Count -gt 0) {
        Write-Warning "Stalled agents detected: $($stalledAgents -join ', ')"
        return $stalledAgents
    }
    
    return @()
}

function Recover-Agent {
    <#
    .SYNOPSIS
    Attempt to recover stalled agent
    #>
    param([string]$AgentName)
    
    # Reset agent state
    $Script:SessionState.active_agents[$AgentName].status = "recovering"
    $Script:SessionState.active_agents[$AgentName].last_turn = $Script:SessionState.turn_counter
    
    # Send recovery message
    Send-AgentMessage -TargetAgent $AgentName -Message @{
        type = "recovery"
        content = "RECOVERY: Resetting agent state"
        data = @{
            original_turn = $Script:SessionState.turn_counter
            recovery_action = "state_reset"
        }
    } -Priority "critical"
    
    Write-Host "Recovery initiated for $AgentName"
}

#endregion

#region Utility Functions

function Save-TaskQueue {
    $Script:TaskQueue.last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $Script:TaskQueue | ConvertTo-Json -Depth 10 | Out-File -FilePath $TaskQueuePath -Encoding UTF8
}

function Load-TaskQueue {
    if (Test-Path $TaskQueuePath) {
        $Script:TaskQueue = Get-Content $TaskQueuePath | ConvertFrom-Json
        return $true
    }
    return $false
}

function Get-SystemStatus {
    <#
    .SYNOPSIS
    Get current system status and metrics
    #>
    return @{
        session_id = $Script:SessionState.session_id
        current_turn = $Script:SessionState.turn_counter
        active_agent = $Script:SessionState.active_agents.GetEnumerator().Where({$_.Value.status -eq "active"}).Name
        pending_tasks = ($Script:TaskQueue.tasks | Where-Object { $_.status -eq "pending" }).Count
        active_tasks = ($Script:TaskQueue.tasks | Where-Object { $_.status -eq "in_progress" }).Count
        completed_tasks = ($Script:TaskQueue.tasks | Where-Object { $_.status -eq "completed" }).Count
        total_token_usage = ($Script:SessionState.active_agents.Values | ForEach-Object { $_.token_usage } | Measure-Object -Sum).Sum
        snapshots_available = $Script:SessionState.snapshots.Count
    }
}

function Show-SystemStatus {
    <#
    .SYNOPSIS
    Display formatted system status
    #>
    $status = Get-SystemStatus
    
    Write-Host "=== Agent Coordination System Status ===" -ForegroundColor Cyan
    Write-Host "Session: $($status.session_id)"
    Write-Host "Turn: $($status.current_turn)"
    Write-Host "Active Agent: $($status.active_agent)"
    Write-Host "Tasks: $($status.pending_tasks) pending, $($status.active_tasks) active, $($status.completed_tasks) completed"
    Write-Host "Token Usage: $($status.total_token_usage)"
    Write-Host "Snapshots: $($status.snapshots_available)"
    Write-Host "========================================" -ForegroundColor Cyan
}

#endregion

# Export module functions
Export-ModuleMember -Function @(
    'Initialize-AgentCoordination',
    'Save-SessionState',
    'Load-SessionState',
    'Create-StateSnapshot',
    'Rollback-ToSnapshot',
    'Optimize-Tokens',
    'Compress-Message',
    'Estimate-Tokens',
    'Send-AgentMessage',
    'Receive-AgentMessage',
    'Invoke-Alert',
    'Advance-Turn',
    'Process-TaskQueue',
    'Complete-Task',
    'Detect-AgentUnstall',
    'Recover-Agent',
    'Get-SystemStatus',
    'Show-SystemStatus'
)