# Multi-Agent Coordination System - Troubleshooting Guide

## Common Issues and Solutions

### 1. System Startup Problems

#### Issue: PowerShell Module Not Found
**Symptoms:**
```
Import-Module : The specified module 'AgentCoordination.psm1' was not loaded
```

**Causes:**
- Module file not in current directory
- Execution policy restrictions
- PowerShell version incompatibility

**Solutions:**
```powershell
# Check if module exists
Test-Path ".\AgentCoordination.psm1"

# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify PowerShell version
$PSVersionTable.PSVersion

# Import with full path
Import-Module ".\AgentCoordination.psm1" -Force
```

#### Issue: AutoHotkey Scripts Not Starting
**Symptoms:**
- AutoHotkey processes not visible in Task Manager
- Messages not being exchanged between agents
- Error: "AutoHotkey64.exe not found"

**Causes:**
- AutoHotkey v2 not installed
- Incorrect AutoHotkey executable path
- Script syntax errors

**Solutions:**
```powershell
# Check AutoHotkey installation
Get-Command "AutoHotkey64.exe" -ErrorAction SilentlyContinue

# Test script syntax manually
AutoHotkey64.exe ".\DC_VSCC_Messaging.ahk"

# Install AutoHotkey v2 if missing
# Download from: https://www.autohotkey.com/

# Check script for v1 syntax (remove if exists)
# Look for: #If, #Hotstring, old command syntax
```

#### Issue: Configuration Files Missing or Corrupted
**Symptoms:**
```
Get-Content : Cannot find path '...\config.json'
```

**Causes:**
- Files deleted or moved
- JSON syntax errors
- File permission issues

**Solutions:**
```powershell
# Recreate default configuration
Copy-Item ".\backup\config.json" ".\config.json" -ErrorAction SilentlyContinue

# Validate JSON syntax
try {
    $config = Get-Content ".\config.json" | ConvertFrom-Json
    Write-Host "Configuration is valid"
} catch {
    Write-Error "Configuration JSON is invalid: $($_.Exception.Message)"
}

# Check file permissions
Get-Acl ".\config.json" | Format-List
```

### 2. Agent Communication Issues

#### Issue: Messages Not Delivered Between Agents
**Symptoms:**
- Tasks stuck in "pending" status
- Agents not responding to messages
- Handoff failures

**Causes:**
- Message files not being created
- File system permission issues
- AutoHotkey injection failures

**Diagnostic Steps:**
```powershell
# Check message directories
Get-ChildItem ".\config\msg_*.json" | Sort-Object LastWriteTime

# Check file permissions
icacls ".\config" /grant Users:(F)

# Test manual message creation
$testMessage = @{
    from = "test"
    to = "DC"
    type = "test"
    content = "Test message"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
}
$testMessage | ConvertTo-Json | Out-File ".\config\msg_DC_test.json"

# Verify message reception
$messages = Receive-AgentMessage -AgentName "DC"
$messages
```

#### Issue: Agent Stalling Detection
**Symptoms:**
- Agent status remains "active" for multiple turns
- System warnings about stalled agents
- Tasks not progressing

**Causes:**
- Agent process hung or crashed
- Message processing loop broken
- Resource exhaustion

**Solutions:**
```powershell
# Check for stalled agents
$stalled = Detect-AgentUnstall
if ($stalled.Count -gt 0) {
    Write-Warning "Stalled agents: $($stalled -join ', ')"
    
    # Force recovery
    foreach ($agent in $stalled) {
        Write-Host "Recovering $agent..."
        Recover-Agent -AgentName $agent
    }
}

# Check AutoHotkey processes
Get-Process | Where-Object { $_.ProcessName -match "autohotkey" } | Format-Table Name, Id, WorkingSet

# Restart stuck processes
Stop-Process -Name "AutoHotkey64" -Force -ErrorAction SilentlyContinue
Start-Process "AutoHotkey64.exe" -ArgumentList ".\DC_VSCC_Messaging.ahk" -WindowStyle Hidden
```

#### Issue: Browser Integration Failures
**Symptoms:**
- Messages not reaching browser
- Console injection failures
- Browser automation not working

**Causes:**
- Browser not running or not accessible
- Developer tools not open
- Security restrictions

**Solutions:**
```powershell
# Check if browser is running
Get-Process | Where-Object { $_.ProcessName -match "chrome|firefox|msedge" }

# Test browser detection manually
# Run: .\DC_Browser_Messaging.ahk
# Press Ctrl+Alt+F to test browser detection

# Verify developer tools can be opened
# In browser: Press F12, switch to Console tab
# Test: console.log("Browser console working")

# Check browser security settings
# Chrome: Settings > Privacy and security > Site settings
# Allow JavaScript and popups if restricted
```

### 3. Performance Issues

#### Issue: High Memory Usage
**Symptoms:**
- System becoming slow
- Memory usage exceeding limits
- AutoHotkey processes consuming excessive RAM

**Causes:**
- Memory leaks in scripts
- Too many cached files
- Snapshots not being cleaned up

**Solutions:**
```powershell
# Monitor memory usage
Get-Process | Where-Object { $_.ProcessName -match "autohotkey|powershell" } | 
    Select-Object Name, Id, @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet/1MB, 2)}}

# Clean up cache files
Get-ChildItem ".\cache\*" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue

# Limit snapshot history
$sessionState = Get-Content ".\SESSION_STATE.json" | ConvertFrom-Json
$sessionState.snapshots = $sessionState.snapshots[-5..-1]  # Keep last 5
$sessionState | ConvertTo-Json -Depth 10 | Out-File ".\SESSION_STATE.json"

# Restart services if memory > 1GB
$totalMemory = (Get-Process | Where-Object { $_.ProcessName -match "autohotkey" } | 
    Measure-Object WorkingSet -Sum).Sum / 1MB
if ($totalMemory -gt 1000) {
    Write-Warning "High memory usage detected: $([math]::Round($totalMemory, 2)) MB"
    # Consider system restart
}
```

#### Issue: Slow Message Processing
**Symptoms:**
- Messages taking >500ms to deliver
- Turns advancing slowly
- Poor responsiveness

**Causes:**
- Disk I/O bottlenecks
- Large message sizes
- Antivirus interference

**Solutions:**
```powershell
# Test file I/O performance
$testFile = ".\temp\iotest.txt"
Measure-Command {
    "test" | Out-File $testFile
    $content = Get-Content $testFile
    Remove-Item $testFile
}

# Check message file sizes
Get-ChildItem ".\config\msg_*.json" | 
    Select-Object Name, @{Name="SizeKB";Expression={[math]::Round($_.Length/1KB, 2)}}

# Compress large messages
# Ensure token optimization is enabled
$sessionState = Get-Content ".\SESSION_STATE.json" | ConvertFrom-Json
$sessionState.token_optimization.compression_enabled = $true
$sessionState | ConvertTo-Json -Depth 10 | Out-File ".\SESSION_STATE.json"

# Add antivirus exclusion if needed
# Exclude: .\config\, .\cache\, .\temp\ folders
```

### 4. State Management Issues

#### Issue: Session State Corruption
**Symptoms:**
- System failing to load session state
- Turn counter reset unexpectedly
- Agent status inconsistent

**Causes:**
- Incomplete file writes
- Disk errors
- Concurrent access conflicts

**Solutions:**
```powershell
# Validate session state JSON
try {
    $sessionState = Get-Content ".\SESSION_STATE.json" | ConvertFrom-Json
    Write-Host "Session state is valid"
} catch {
    Write-Error "Session state corrupted: $($_.Exception.Message)"
    
    # Try to recover from backup
    if (Test-Path ".\backup\SESSION_STATE.json") {
        Copy-Item ".\backup\SESSION_STATE.json" ".\SESSION_STATE.json"
        Write-Host "Recovered from backup"
    } else {
        # Reinitialize
        Initialize-AgentCoordination -SessionId "recovery_session"
        Write-Host "Reinitialized session"
    }
}

# Check for required fields
$requiredFields = @("session_id", "turn_counter", "active_agents", "shared_context")
$missingFields = $requiredFields | Where-Object { !$sessionState.PSObject.Properties.Name -contains $_ }
if ($missingFields) {
    Write-Warning "Missing fields: $($missingFields -join ', ')"
}
```

#### Issue: Snapshot Rollback Failures
**Symptoms:**
- Unable to rollback to previous state
- Snapshot files missing or invalid
- Recovery not working

**Causes:**
- Snapshot files deleted
- Insufficient permissions
- Corrupted snapshot data

**Solutions:**
```powershell
# Check available snapshots
$sessionState = Get-Content ".\SESSION_STATE.json" | ConvertFrom-Json
$snapshots = $sessionState.snapshots
Write-Host "Available snapshots: $($snapshots.Count)"

# List snapshot details
$snapshots | ForEach-Object {
    Write-Host "Turn $($_.turn): $($_.timestamp)"
}

# Test rollback to specific snapshot
if ($snapshots.Count -gt 0) {
    $targetSnapshot = $snapshots[-1]  # Last snapshot
    $success = Rollback-ToSnapshot -TargetTurn $targetSnapshot.turn
    if ($success) {
        Write-Host "Successfully rolled back to turn $($targetSnapshot.turn)"
    } else {
        Write-Error "Rollback failed"
    }
}

# Force create new snapshot if needed
Create-StateSnapshot -Turn (Get-SystemStatus).current_turn
```

### 5. Token Optimization Issues

#### Issue: Token Usage Exceeds Limits
**Symptoms:**
- Warnings about high token usage
- Messages being truncated
- Performance degradation

**Causes:**
- Optimization rules disabled
- Large message payloads
- Insufficient shorthand application

**Solutions:**
```powershell
# Check optimization settings
$tokenOpt = Get-Content ".\token_optimization.json" | ConvertFrom-Json
Write-Host "Optimization enabled: $($tokenOpt.enabled)"
Write-Host "Target tokens per turn: $($tokenOpt.target_tokens_per_turn)"

# Test optimization manually
$testText = "Execute the function to process the data for the application window"
Write-Host "Original: $testText"
Write-Host "Tokens: $(Estimate-Tokens -Text $testText)"

$optimized = Optimize-Tokens -Text $testText
Write-Host "Optimized: $optimized"
Write-Host "Tokens: $(Estimate-Tokens -Text $optimized)"

# Enable all optimization features
$tokenOpt.compression_enabled = $true
$tokenOpt.enabled = $true
$tokenOpt | ConvertTo-Json -Depth 3 | Out-File ".\token_optimization.json"
```

### 6. Integration Issues

#### Issue: VSCode Integration Not Working
**Symptoms:**
- Code injection failing
- VSCode not responding to commands
- File operations not working

**Causes:**
- VSCode not running
- Incorrect window targeting
- Extension conflicts

**Solutions:**
```powershell
# Check if VSCode is running
Get-Process | Where-Object { $_.ProcessName -eq "Code" }

# Test VSCode window detection
# Run: .\VSCC_Browser_Messaging.ahk
# Press Ctrl+Alt+I to test injection

# Check VSCode extensions
code --list-extensions | Where-Object { $_ -match "powershell" }

# Restart VSCode if needed
Stop-Process -Name "Code" -Force -ErrorAction SilentlyContinue
Start-Process "code" -ArgumentList "."
```

#### Issue: File System Permissions
**Symptoms:**
- Unable to create/write files
- Access denied errors
- Configuration updates failing

**Causes:**
- Insufficient user permissions
- Antivirus blocking
- File locks

**Solutions:**
```powershell
# Check current permissions
whoami
icacls "." | Format-List

# Grant full permissions to current user
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
icacls "." /grant "$user`:(F)" /T

# Test file creation
"test" | Out-File ".\temp\permission_test.txt" -ErrorAction Stop
Remove-Item ".\temp\permission_test.txt"

# Check for file locks
Get-Process | Where-Object { $_.MainWindowTitle -match "config|session" }
```

## Diagnostic Tools

### System Health Check Script

```powershell
function Test-SystemHealth {
    Write-Host "=== MULTI-AGENT SYSTEM HEALTH CHECK ===" -ForegroundColor Cyan
    
    $issues = @()
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        $issues += "PowerShell 7+ required (current: $($PSVersionTable.PSVersion.Major))"
    } else {
        Write-Host "✓ PowerShell version: $($PSVersionTable.PSVersion.Major)" -ForegroundColor Green
    }
    
    # Check AutoHotkey
    try {
        $ahk = Get-Command "AutoHotkey64.exe" -ErrorAction Stop
        Write-Host "✓ AutoHotkey found: $($ahk.Source)" -ForegroundColor Green
    } catch {
        $issues += "AutoHotkey v2 not found"
    }
    
    # Check module files
    $requiredFiles = @(
        ".\AgentCoordination.psm1",
        ".\config.json",
        ".\coordination_rules.json",
        ".\token_optimization.json",
        ".\DC_VSCC_Messaging.ahk",
        ".\DC_Browser_Messaging.ahk",
        ".\VSCC_Browser_Messaging.ahk"
    )
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Host "✓ File exists: $file" -ForegroundColor Green
        } else {
            $issues += "Missing file: $file"
        }
    }
    
    # Check processes
    $ahkProcesses = Get-Process | Where-Object { $_.ProcessName -match "autohotkey" }
    Write-Host "✓ AutoHotkey processes running: $($ahkProcesses.Count)" -ForegroundColor Green
    
    # Check directories
    $requiredDirs = @(".\config", ".\logs", ".\cache", ".\temp")
    foreach ($dir in $requiredDirs) {
        if (Test-Path $dir) {
            Write-Host "✓ Directory exists: $dir" -ForegroundColor Green
        } else {
            $issues += "Missing directory: $dir"
        }
    }
    
    # Check configuration validity
    try {
        $config = Get-Content ".\config.json" | ConvertFrom-Json
        Write-Host "✓ Configuration valid" -ForegroundColor Green
    } catch {
        $issues += "Configuration JSON invalid"
    }
    
    # Summary
    Write-Host "`n=== HEALTH CHECK SUMMARY ===" -ForegroundColor Cyan
    if ($issues.Count -eq 0) {
        Write-Host "✓ System is healthy" -ForegroundColor Green
    } else {
        Write-Host "✗ Issues found: $($issues.Count)" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "  - $issue" -ForegroundColor Yellow
        }
    }
    
    return $issues.Count -eq 0
}

# Run health check
Test-SystemHealth
```

### Message Flow Debugger

```powershell
function Start-MessageDebugger {
    param([int]$DurationMinutes = 2)
    
    Write-Host "=== MESSAGE FLOW DEBUGGER ===" -ForegroundColor Cyan
    Write-Host "Monitoring message flow for $DurationMinutes minutes..."
    
    $endTime = (Get-Date).AddMinutes($DurationMinutes)
    $messageStats = @{
        total_sent = 0
        total_received = 0
        by_agent = @{}
    }
    
    while ((Get-Date) -lt $endTime) {
        # Check for new message files
        $messageFiles = Get-ChildItem ".\config\msg_*.json" -ErrorAction SilentlyContinue
        
        foreach ($file in $messageFiles) {
            try {
                $message = Get-Content $file.FullName | ConvertFrom-Json
                
                # Update statistics
                $messageStats.total_sent++
                
                $agent = $message.to
                if (!$messageStats.by_agent.ContainsKey($agent)) {
                    $messageStats.by_agent[$agent] = @{sent = 0; received = 0}
                }
                $messageStats.by_agent[$agent].sent++
                
                Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $($message.from) → $($message.to): $($message.type)" -ForegroundColor Gray
                
                # Clean up processed message (for demo)
                Remove-Item $file.FullName -ErrorAction SilentlyContinue
            } catch {
                Write-Warning "Invalid message file: $($file.Name)"
            }
        }
        
        Start-Sleep -Seconds 2
    }
    
    # Display summary
    Write-Host "`n=== MESSAGE FLOW SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total messages processed: $($messageStats.total_sent)"
    
    foreach ($agent in $messageStats.by_agent.Keys) {
        $stats = $messageStats.by_agent[$agent]
        Write-Host "Agent $agent`: $($stats.sent) sent, $($stats.received) received"
    }
}

# Start debugger
Start-MessageDebugger -DurationMinutes 1
```

## Emergency Procedures

### Complete System Reset

```powershell
function Reset-SystemCompletely {
    Write-Warning "This will reset the entire coordination system!"
    $confirm = Read-Host "Are you sure? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "Reset cancelled"
        return
    }
    
    Write-Host "Stopping all processes..."
    Get-Process | Where-Object { $_.ProcessName -match "autohotkey" } | Stop-Process -Force
    
    Write-Host "Cleaning up files..."
    Get-ChildItem ".\config\msg_*.json" | Remove-Item -Force
    Get-ChildItem ".\cache\*" | Remove-Item -Recurse -Force
    Get-ChildItem ".\temp\*" | Remove-Item -Recurse -Force
    
    Write-Host "Resetting configuration..."
    if (Test-Path ".\backup\SESSION_STATE.json") {
        Copy-Item ".\backup\SESSION_STATE.json" ".\SESSION_STATE.json"
    }
    
    Write-Host "System reset complete. Restart with .\Startup.ps1"
}
```

### Emergency Mode Activation

```powershell
function Enable-EmergencyMode {
    Write-Host "Activating emergency mode..."
    
    # Disable non-essential features
    $sessionState = Get-Content ".\SESSION_STATE.json" | ConvertFrom-Json
    $sessionState.token_optimization.target_tokens_per_turn = 100
    $sessionState | ConvertTo-Json -Depth 10 | Out-File ".\SESSION_STATE.json"
    
    # Clear task queue except critical tasks
    $taskQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
    $taskQueue.tasks = $taskQueue.tasks | Where-Object { $_.priority -eq 1 }
    $taskQueue | ConvertTo-Json -Depth 10 | Out-File ".\TASK_QUEUE.json"
    
    Write-Host "Emergency mode activated - limited functionality available"
}
```

This troubleshooting guide provides comprehensive solutions for common issues, diagnostic tools, and emergency procedures to maintain system reliability.