# Startup.ps1 - Multi-Agent Coordination System Bootstrap
# Version 1.0 - System initialization and agent startup

param(
    [string]$SessionId = "",
    [int]$SnapshotInterval = 10,
    [switch]$Verbose = $false,
    [switch]$Debug = $false
)

# Configuration
$ConfigFile = ".\config.json"
$CoordinationRulesFile = ".\coordination_rules.json"
$TokenOptimizationFile = ".\token_optimization.json"
$AgentCoordinationModule = ".\AgentCoordination.psm1"
$LogDirectory = ".\logs"

# Initialize logging
function Write-StartupLog {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Write-Host $logEntry -ForegroundColor $(
        switch ($Level) {
            "ERROR" { "Red" }
            "WARN" { "Yellow" }
            "INFO" { "Green" }
            "DEBUG" { "Cyan" }
            default { "White" }
        }
    )
    
    # Write to log file
    if (!(Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }
    Add-Content -Path "$LogDirectory\startup.log" -Value $logEntry
}

function Test-SystemPrerequisites {
    Write-StartupLog "Checking system prerequisites..."
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 7) {
        Write-StartupLog "PowerShell 7+ required. Current version: $psVersion" "ERROR"
        return $false
    }
    Write-StartupLog "PowerShell version: $psVersion ✓"
    
    # Check AutoHotkey installation
    try {
        $ahkPath = Get-Command "AutoHotkey64.exe" -ErrorAction Stop
        Write-StartupLog "AutoHotkey found: $($ahkPath.Source) ✓"
    } catch {
        Write-StartupLog "AutoHotkey v2 not found. Please install AutoHotkey v2." "ERROR"
        return $false
    }
    
    # Check Windows version
    $windowsVersion = [System.Environment]::OSVersion.Version
    if ($windowsVersion.Major -lt 10) {
        Write-StartupLog "Windows 10/11 required. Current version: $($windowsVersion.Major)" "ERROR"
        return $false
    }
    Write-StartupLog "Windows version: $($windowsVersion.Major).$($windowsVersion.Minor) ✓"
    
    # Check file permissions
    try {
        $testFile = ".\permissions_test.tmp"
        "test" | Out-File -FilePath $testFile -ErrorAction Stop
        Remove-Item $testFile -ErrorAction Stop
        Write-StartupLog "File permissions: OK ✓"
    } catch {
        Write-StartupLog "Insufficient file permissions" "ERROR"
        return $false
    }
    
    return $true
}

function Initialize-Directories {
    Write-StartupLog "Creating directory structure..."
    
    $directories = @(
        ".\config",
        ".\logs", 
        ".\cache",
        ".\temp",
        ".\scripts",
        ".\backup"
    )
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-StartupLog "Created directory: $dir"
        }
    }
}

function Load-Configuration {
    Write-StartupLog "Loading configuration files..."
    
    # Load main config
    if (Test-Path $ConfigFile) {
        $global:SystemConfig = Get-Content $ConfigFile | ConvertFrom-Json
        Write-StartupLog "Loaded main configuration ✓"
    } else {
        Write-StartupLog "Main configuration file not found: $ConfigFile" "ERROR"
        return $false
    }
    
    # Load coordination rules
    if (Test-Path $CoordinationRulesFile) {
        $global:CoordinationRules = Get-Content $CoordinationRulesFile | ConvertFrom-Json
        Write-StartupLog "Loaded coordination rules ✓"
    } else {
        Write-StartupLog "Coordination rules file not found: $CoordinationRulesFile" "ERROR"
        return $false
    }
    
    # Load token optimization rules
    if (Test-Path $TokenOptimizationFile) {
        $global:TokenOptimization = Get-Content $TokenOptimizationFile | ConvertFrom-Json
        Write-StartupLog "Loaded token optimization rules ✓"
    } else {
        Write-StartupLog "Token optimization file not found: $TokenOptimizationFile" "WARN"
    }
    
    return $true
}

function Initialize-AgentCoordination {
    Write-StartupLog "Initializing Agent Coordination Module..."
    
    if (Test-Path $AgentCoordinationModule) {
        try {
            Import-Module $AgentCoordinationModule -Force
            Write-StartupLog "Agent Coordination Module loaded ✓"
            
            # Initialize the coordination system
            $sessionId = if ($SessionId) { $SessionId } else { "sess_$((Get-Date).Ticks)" }
            Initialize-AgentCoordination -SessionId $sessionId -SnapshotInterval $SnapshotInterval
            Write-StartupLog "Coordination system initialized with session: $sessionId"
            
            return $true
        } catch {
            Write-StartupLog "Failed to load Agent Coordination Module: $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-StartupLog "Agent Coordination Module not found: $AgentCoordinationModule" "ERROR"
        return $false
    }
}

function Start-AgentServices {
    Write-StartupLog "Starting agent services..."
    
    # Start DC-VSCC messaging service
    try {
        $dcVsccScript = ".\DC_VSCC_Messaging.ahk"
        if (Test-Path $dcVsccScript) {
            Start-Process "AutoHotkey64.exe" -ArgumentList $dcVsccScript -WindowStyle Hidden
            Write-StartupLog "DC-VSCC messaging service started ✓"
        } else {
            Write-StartupLog "DC-VSCC script not found: $dcVsccScript" "WARN"
        }
    } catch {
        Write-StartupLog "Failed to start DC-VSCC service: $($_.Exception.Message)" "ERROR"
    }
    
    # Start DC-Browser messaging service
    try {
        $dcBrowserScript = ".\DC_Browser_Messaging.ahk"
        if (Test-Path $dcBrowserScript) {
            Start-Process "AutoHotkey64.exe" -ArgumentList $dcBrowserScript -WindowStyle Hidden
            Write-StartupLog "DC-Browser messaging service started ✓"
        } else {
            Write-StartupLog "DC-Browser script not found: $dcBrowserScript" "WARN"
        }
    } catch {
        Write-StartupLog "Failed to start DC-Browser service: $($_.Exception.Message)" "ERROR"
    }
    
    # Start VSCC-Browser messaging service
    try {
        $vsccBrowserScript = ".\VSCC_Browser_Messaging.ahk"
        if (Test-Path $vsccBrowserScript) {
            Start-Process "AutoHotkey64.exe" -ArgumentList $vsccBrowserScript -WindowStyle Hidden
            Write-StartupLog "VSCC-Browser messaging service started ✓"
        } else {
            Write-StartupLog "VSCC-Browser script not found: $vsccBrowserScript" "WARN"
        }
    } catch {
        Write-StartupLog "Failed to start VSCC-Browser service: $($_.Exception.Message)" "ERROR"
    }
}

function Initialize-TaskQueue {
    Write-StartupLog "Initializing task queue..."
    
    # Load existing task queue or create default
    if (Test-Path ".\TASK_QUEUE.json") {
        $taskQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
        Write-StartupLog "Loaded existing task queue with $($taskQueue.tasks.Count) tasks"
    } else {
        # Create initial task queue
        $initialTaskQueue = @{
            schema_version = "1.0"
            queue_id = "queue_$((Get-Date).Ticks)"
            last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            tasks = @(
                @{
                    task_id = "init_001"
                    title = "System Health Check"
                    priority = 1
                    assigned_agent = "STRYK"
                    status = "pending"
                    created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
                    required_turns = 2
                    completed_turns = 0
                    dependencies = @()
                    handoff_agent = $null
                    completion_criteria = @{
                        agents_responding = 3
                        services_running = 3
                    }
                    token_estimate = 25
                }
            )
        }
        
        $initialTaskQueue | ConvertTo-Json -Depth 10 | Out-File -FilePath ".\TASK_QUEUE.json" -Encoding UTF8
        Write-StartupLog "Created initial task queue"
    }
}

function Start-Monitoring {
    Write-StartupLog "Starting system monitoring..."
    
    # Create monitoring script
    $monitorScript = @'
# System monitoring script
$ coordinationModule = ".\AgentCoordination.psm1"
Import-Module $coordinationModule

while ($true) {
    try {
        $status = Get-SystemStatus
        
        # Check for stalled agents
        $stalledAgents = Detect-AgentUnstall
        if ($stalledAgents.Count -gt 0) {
            foreach ($agent in $stalledAgents) {
                Write-Warning "Recovering stalled agent: $agent"
                Recover-Agent -AgentName $agent
            }
        }
        
        # Check token usage
        if ($status.total_token_usage -gt 100) {
            Write-Warning "High token usage detected: $($status.total_token_usage)"
        }
        
        # Log status every 10 iterations
        if ($status.current_turn % 10 -eq 0) {
            Write-Host "Status Check - Turn $($status.current_turn), Active: $($status.active_agent), Tasks: $($status.pending_tasks) pending"
        }
        
        Start-Sleep -Seconds 5
    } catch {
        Write-Error "Monitoring error: $($_.Exception.Message)"
        Start-Sleep -Seconds 10
    }
}
'@
    
    # Start monitoring in background
    $monitorJob = Start-Job -ScriptBlock $monitorScript
    Write-StartupLog "System monitoring started (Job ID: $($monitorJob.Id)) ✓"
}

function Show-StartupSummary {
    Write-StartupLog "=== MULTI-AGENT COORDINATION SYSTEM STARTUP COMPLETE ===" "INFO"
    
    try {
        $status = Get-SystemStatus
        Write-Host "Session ID: $($status.session_id)" -ForegroundColor Cyan
        Write-Host "Current Turn: $($status.current_turn)" -ForegroundColor Cyan
        Write-Host "Active Agent: $($status.active_agent)" -ForegroundColor Green
        Write-Host "Pending Tasks: $($status.pending_tasks)" -ForegroundColor Yellow
        Write-Host "System Status: OPERATIONAL" -ForegroundColor Green
    } catch {
        Write-Host "System Status: CHECK REQUIRED" -ForegroundColor Yellow
    }
    
    Write-Host "`nAvailable Commands:" -ForegroundColor White
    Write-Host "  Get-SystemStatus        - Show current system status" -ForegroundColor Gray
    Write-Host "  Show-SystemStatus       - Display formatted status" -ForegroundColor Gray
    Write-Host "  Advance-Turn            - Move to next turn" -ForegroundColor Gray
    Write-Host "  Process-TaskQueue       - Process pending tasks" -ForegroundColor Gray
    Write-Host "  Send-AgentMessage       - Send message to agent" -ForegroundColor Gray
    Write-Host "  Create-StateSnapshot    - Create state snapshot" -ForegroundColor Gray
    Write-Host "`nPress Ctrl+C to stop monitoring services" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan
}

# Main startup sequence
try {
    Write-StartupLog "=== MULTI-AGENT COORDINATION SYSTEM STARTUP ==="
    
    if (!(Test-SystemPrerequisites)) {
        Write-StartupLog "Prerequisites check failed. Aborting startup." "ERROR"
        exit 1
    }
    
    Initialize-Directories
    
    if (!(Load-Configuration)) {
        Write-StartupLog "Configuration loading failed. Aborting startup." "ERROR"
        exit 1
    }
    
    if (!(Initialize-AgentCoordination)) {
        Write-StartupLog "Agent coordination initialization failed. Aborting startup." "ERROR"
        exit 1
    }
    
    Initialize-TaskQueue
    Start-AgentServices
    Start-Monitoring
    
    Show-StartupSummary
    
    # Keep the script running to maintain services
    try {
        while ($true) {
            Start-Sleep -Seconds 30
            
            # Periodic health check
            if ($Verbose) {
                $status = Get-SystemStatus
                Write-StartupLog "Health Check - Turn $($status.current_turn), Active: $($status.active_agent)" "DEBUG"
            }
        }
    } finally {
        Write-StartupLog "Shutting down coordination system..." "WARN"
        # Cleanup code here if needed
    }
    
} catch {
    Write-StartupLog "Startup failed: $($_.Exception.Message)" "ERROR"
    exit 1
}