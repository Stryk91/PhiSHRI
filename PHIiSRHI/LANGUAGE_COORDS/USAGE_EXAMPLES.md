# Multi-Agent Coordination System - Usage Examples

## Quick Start Guide

### 1. System Startup

```powershell
# Navigate to the system directory
cd C:\MultiAgentSystem

# Run the startup script
.\Startup.ps1

# Or with custom parameters
.\Startup.ps1 -SessionId "my_session_001" -SnapshotInterval 5 -Verbose
```

### 2. Basic Automation Workflow

```powershell
# Import the coordination module
Import-Module .\AgentCoordination.psm1

# Initialize system
Initialize-AgentCoordination -SessionId "demo_workflow"

# STRYK: Create planning task
$planningTask = @{
    task_id = "plan_001"
    title = "Plan web scraping workflow"
    priority = 1
    assigned_agent = "STRYK"
    status = "pending"
    created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    required_turns = 2
    dependencies = @()
    handoff_agent = "DC"
    completion_criteria = @{
        steps_defined = 3
        agents_assigned = 2
    }
    token_estimate = 30
}

# Add to task queue
$taskQueue = Get-Content .\TASK_QUEUE.json | ConvertFrom-Json
$taskQueue.tasks += $planningTask
$taskQueue | ConvertTo-Json -Depth 10 | Out-File .\TASK_QUEUE.json

# Process task
Process-TaskQueue
```

## Example Workflows

### Example 1: Web Scraping Automation

Complete workflow for scraping data from a website and processing it.

#### Step 1: Strategic Planning (STRYK)

```powershell
# STRYK creates the overall plan
Send-AgentMessage -TargetAgent "DC" -Message @{
    type = "task_assignment"
    content = "EXEC browser nav 2 https://example.com & extract data"
    data = @{
        workflow = "web_scraping"
        target_url = "https://example.com"
        extraction_type = "text_content"
        output_format = "json"
        handoff_to = "VSCC"
    }
} -Priority "high"

Advance-Turn -NextAgent "DC"
```

#### Step 2: Browser Control (DC)

```powershell
# DC receives the task and executes browser automation
# This would typically be handled by the AutoHotkey script
# but here's the manual equivalent:

$browserMessage = @{
    type = "navigation"
    url = "https://example.com"
    action = "extract_all_text"
}

SendToBrowser "navigation", $browserMessage

# After browser completes extraction:
Send-AgentMessage -TargetAgent "VSCC" -Message @{
    type = "handoff"
    content = "DATA extracted frm web - PROC & format"
    data = @{
        source_url = "https://example.com"
        raw_content = $extractedContent
        processing_required = $true
        output_format = "structured_json"
    }
} -Priority "high"
```

#### Step 3: Content Processing (VSCC)

```powershell
# VSCC processes the extracted content
$processingScript = @'
const rawData = window.extractedData;
const processed = {
    title: document.title,
    paragraphs: document.querySelectorAll('p').length,
    links: document.querySelectorAll('a').length,
    wordCount: rawData.split(/\s+/).length,
    timestamp: new Date().toISOString()
};

window.processedData = processed;
console.log("Data processed:", processed);
'@

SendToBrowser "code_execution", @{
    code = $processingScript
    filename = "content_processor.js"
    execute_immediately = $true
}

# Send results back to STRYK
Complete-Task -TaskId "plan_001" -Results @{
    status = "success"
    data_extracted = $true
    processed_records = 1
    final_output = "structured_data.json"
}
```

### Example 2: Multi-Window Automation

Automate interactions across multiple applications simultaneously.

#### Setup Multi-Window Task

```powershell
$multiWindowTask = @{
    task_id = "multiwin_001"
    title = "Cross-app data transfer"
    priority = 2
    assigned_agent = "DC"
    status = "pending"
    created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    required_turns = 5
    dependencies = @()
    handoff_agent = "VSCC"
    completion_criteria = @{
        windows_coordinated = 3
        data_transferred = "success"
    }
    token_estimate = 60
}

# Add to queue and execute
Process-TaskQueue
Advance-Turn
```

#### Cross-Application Coordination

```powershell
# DC coordinates multiple windows
$coordinationMessage = @{
    type = "multi_window_task"
    content = "COORD 3 win: Chrome, VSCode, Notepad"
    data = @{
        windows = @(
            @{name = "Chrome"; role = "data_source"; action = "extract"},
            @{name = "VSCode"; role = "data_processor"; action = "transform"},
            @{name = "Notepad"; role = "output_destination"; action = "save"}
        )
        data_flow = "Chrome -> VSCode -> Notepad"
        sync_required = $true
    }
}

Send-AgentMessage -TargetAgent "DC" -Message $coordinationMessage -Priority "high"
```

### Example 3: Error Recovery Scenario

Demonstrate automatic error detection and recovery.

#### Simulate Agent Stall

```powershell
# Simulate a stalled agent by not advancing turns
Write-Host "Simulating agent stall..."

# Wait for stall detection
for ($i = 1; $i -le 5; $i++) {
    Start-Sleep -Seconds 2
    $status = Get-SystemStatus
    Write-Host "Turn $($status.current_turn): $($status.active_agent)"
}

# Check for stalled agents
$stalled = Detect-AgentUnstall
if ($stalled.Count -gt 0) {
    Write-Warning "Stalled agents detected: $($stalled -join ', ')"
    
    # Auto-recover
    foreach ($agent in $stalled) {
        Write-Host "Recovering $agent..."
        Recover-Agent -AgentName $agent
    }
    
    # Verify recovery
    Start-Sleep -Seconds 3
    Show-SystemStatus
}
```

#### Manual State Rollback

```powershell
# Create a snapshot before risky operation
Create-StateSnapshot -Turn (Get-SystemStatus).current_turn

# Simulate problematic state change
Write-Host "Making problematic changes..."

# Rollback if needed
Write-Host "Rolling back to previous state..."
$snapshots = (Get-Content .\SESSION_STATE.json | ConvertFrom-Json).snapshots
if ($snapshots.Count -gt 0) {
    $lastSnapshot = $snapshots[-1]
    $success = Rollback-ToSnapshot -TargetTurn $lastSnapshot.turn
    
    if ($success) {
        Write-Host "Successfully rolled back to turn $($lastSnapshot.turn)"
    } else {
        Write-Error "Rollback failed"
    }
}
```

### Example 4: Token Optimization Demonstration

Show the difference between optimized and unoptimized communication.

#### Token Usage Comparison

```powershell
# Unoptimized message
$unoptimized = "Execute the function to get the window information and process the data for the application"
Write-Host "Original: $unoptimized"
$originalTokens = Estimate-Tokens -Text $unoptimized
Write-Host "Original tokens: $originalTokens"

# Optimized message
$optimized = Optimize-Tokens -Text $unoptimized
Write-Host "Optimized: $optimized"
$optimizedTokens = Estimate-Tokens -Text $optimized
Write-Host "Optimized tokens: $optimizedTokens"

# Calculate savings
$savings = [math]::Round((1 - $optimizedTokens / $originalTokens) * 100, 1)
Write-Host "Token reduction: $savings%"
```

#### Batch Operations Example

```powershell
# Instead of multiple messages:
Send-AgentMessage -TargetAgent "DC" -Message @{type = "step1", content = "open win"}
Send-AgentMessage -TargetAgent "DC" -Message @{type = "step2", content = "navigate url"}
Send-AgentMessage -TargetAgent "DC" -Message @{type = "step3", content = "extract data"}

# Use batch operation:
$batchMessage = @{
    type = "batch_execution"
    content = "EXEC: open win && navigate url && extract data"
    data = @{
        operations = @(
            @{action = "open_window"; target = "Chrome"},
            @{action = "navigate"; url = "https://example.com"},
            @{action = "extract"; selector = "body"; type = "text"}
        )
        execute_sequence = $true
    }
}

Send-AgentMessage -TargetAgent "DC" -Message $batchMessage -Priority "normal"
```

### Example 5: Custom Agent Configuration

Create and manage custom agent configurations.

#### Custom Task Type

```powershell
# Define custom task for file monitoring
$fileMonitorTask = @{
    task_id = "monitor_001"
    title = "Monitor directory for new files"
    priority = 3
    assigned_agent = "VSCC"
    status = "pending"
    created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    required_turns = 1
    dependencies = @()
    handoff_agent = "DC"
    completion_criteria = @{
        files_detected = ">=0"
        notifications_sent = $true
    }
    custom_config = @{
        monitor_path = ".\watched_files"
        file_types = @("*.txt", "*.json", "*.csv")
        alert_agent = "DC"
        auto_process = $true
    }
    token_estimate = 25
}

# Add custom configuration to agent registry
$registry = Get-Content .\AGENT_REGISTRY.json | ConvertFrom-Json
$registry.agents.VSCC.custom_capabilities += @("file_monitoring")
$registry | ConvertTo-Json -Depth 10 | Out-File .\AGENT_REGISTRY.json
```

## Integration Examples

### Integration with External Scripts

```powershell
# Wrap external PowerShell script in agent coordination
function Invoke-ExternalScriptWithCoordination {
    param(
        [string]$ScriptPath,
        [string]$Agent = "VSCC",
        [hashtable]$Parameters = @{}
    )
    
    # Create coordination task
    $coordTask = @{
        task_id = "external_$((Get-Date).Ticks)"
        title = "Execute external script: $(Split-Path $ScriptPath -Leaf)"
        priority = 3
        assigned_agent = $Agent
        status = "pending"
        created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        required_turns = 2
        dependencies = @()
        handoff_agent = $null
        completion_criteria = @{
            script_executed = $true
            output_captured = $true
        }
        token_estimate = 30
    }
    
    # Send execution message
    Send-AgentMessage -TargetAgent $Agent -Message @{
        type = "external_script"
        content = "EXEC external script: $(Split-Path $ScriptPath -Leaf)"
        data = @{
            script_path = $ScriptPath
            parameters = $Parameters
            capture_output = $true
            timeout_seconds = 60
        }
    } -Priority "normal"
    
    # Monitor execution
    $timeout = 120  # 2 minutes
    $elapsed = 0
    
    while ($elapsed -lt $timeout) {
        $status = Get-SystemStatus
        $task = $status.active_tasks -gt 0
        
        if (!$task) {
            Write-Host "External script execution completed"
            break
        }
        
        Start-Sleep -Seconds 5
        $elapsed += 5
    }
    
    if ($elapsed -ge $timeout) {
        Write-Warning "External script execution timed out"
    }
}

# Usage
Invoke-ExternalScriptWithCoordination -ScriptPath ".\scripts\data_processor.ps1" -Agent "VSCC"
```

### Integration with VSCode Extensions

```powershell
# Send commands to VSCode through VSCC agent
$vscodeCommand = @{
    type = "vscode_command"
    content = "EXEC VSCode cmd & file ops"
    data = @{
        command = "workbench.action.files.saveAll"
        extension = "ms-vscode.powershell"
        additional_commands = @(
            "workbench.action.terminal.new",
            "workbench.action.openSettings"
        )
    }
}

Send-AgentMessage -TargetAgent "VSCC" -Message $vscodeCommand
```

## Performance Testing Examples

### Load Testing Scenario

```powershell
# Create multiple concurrent tasks for testing
function Start-LoadTest {
    param([int]$TaskCount = 10)
    
    Write-Host "Starting load test with $TaskCount tasks..."
    
    for ($i = 1; $i -le $TaskCount; $i++) {
        $loadTestTask = @{
            task_id = "load_test_$i"
            title = "Load test task $i"
            priority = 3
            assigned_agent = @("STRYK", "DC", "VSCC") | Get-Random
            status = "pending"
            created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            required_turns = 2
            dependencies = @()
            handoff_agent = $null
            completion_criteria = @{
                test_completed = $true
                metrics_collected = $true
            }
            token_estimate = 20
        }
        
        # Add to queue
        $taskQueue = Get-Content .\TASK_QUEUE.json | ConvertFrom-Json
        $taskQueue.tasks += $loadTestTask
        $taskQueue | ConvertTo-Json -Depth 10 | Out-File .\TASK_QUEUE.json
    }
    
    # Monitor progress
    $startTime = Get-Date
    $completed = 0
    
    while ($completed -lt $TaskCount) {
        Process-TaskQueue
        Start-Sleep -Seconds 1
        
        $status = Get-SystemStatus
        $completed = $status.completed_tasks
        $elapsed = (Get-Date) - $startTime
        
        Write-Host "Progress: $completed/$TaskCount tasks completed in $($elapsed.TotalSeconds)s"
    }
    
    Write-Host "Load test completed in $($elapsed.TotalSeconds) seconds"
    Show-SystemStatus
}

# Run load test
Start-LoadTest -TaskCount 5
```

### Memory Usage Monitoring

```powershell
# Monitor system memory usage during operation
function Start-MemoryMonitoring {
    param([int]$DurationMinutes = 5)
    
    $endTime = (Get-Date).AddMinutes($DurationMinutes)
    $memoryData = @()
    
    Write-Host "Starting memory monitoring for $DurationMinutes minutes..."
    
    while ((Get-Date) -lt $endTime) {
        $processes = Get-Process | Where-Object { 
            $_.ProcessName -match "AutoHotkey|powershell" 
        }
        
        $totalMemory = ($processes | Measure-Object WorkingSet -Sum).Sum / 1MB
        
        $memoryEntry = @{
            timestamp = Get-Date
            total_memory_mb = [math]::Round($totalMemory, 2)
            process_count = $processes.Count
        }
        
        $memoryData += $memoryEntry
        Write-Host "Memory usage: $($memoryEntry.total_memory_mb) MB across $($memoryEntry.process_count) processes"
        
        Start-Sleep -Seconds 30
    }
    
    # Save monitoring results
    $memoryData | ConvertTo-Json -Depth 3 | Out-File ".\logs\memory_monitoring_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Write-Host "Memory monitoring completed. Results saved to logs."
}

# Start monitoring
Start-MemoryMonitoring -DurationMinutes 3
```

These examples demonstrate various aspects of the multi-agent coordination system, from basic usage to advanced scenarios including error handling, performance testing, and custom integrations.