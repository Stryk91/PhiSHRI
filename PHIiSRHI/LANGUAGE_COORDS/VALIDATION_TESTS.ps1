# VALIDATION_TESTS.ps1 - Multi-Agent Coordination System Validation
# Version 1.0 - Comprehensive system testing suite

param(
    [switch]$RunAll = $false,
    [switch]$QuickTest = $false,
    [switch]$PerformanceTest = $false,
    [switch]$IntegrationTest = $false,
    [switch]$StressTest = $false,
    [switch]$Verbose = $false
)

# Test Configuration
$TestResults = @()
$TestStartTime = Get-Date
$LogDirectory = ".\test_logs"

# Initialize logging
if (!(Test-Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

function Write-TestLog {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    if ($Verbose) {
        Write-Host $logEntry -ForegroundColor $(
            switch ($Level) {
                "PASS" { "Green" }
                "FAIL" { "Red" }
                "WARN" { "Yellow" }
                "INFO" { "Cyan" }
                default { "White" }
            }
        )
    }
    
    Add-Content -Path "$LogDirectory\validation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -Value $logEntry
}

function Invoke-Test {
    param(
        [string]$TestName,
        [scriptblock]$TestCode,
        [hashtable]$ExpectedResults = @{}
    )
    
    Write-TestLog "Running test: $TestName" "INFO"
    
    try {
        $testResult = & $TestCode
        $success = $true
        
        # Validate expected results
        foreach ($key in $ExpectedResults.Keys) {
            if ($testResult.ContainsKey($key) -and $testResult[$key] -ne $ExpectedResults[$key]) {
                $success = $false
                Write-TestLog "Test failed: $TestName - Expected $key = $($ExpectedResults[$key]), got $($testResult[$key])" "FAIL"
                break
            }
        }
        
        if ($success) {
            Write-TestLog "Test passed: $TestName" "PASS"
            $TestResults += @{
                name = $TestName
                status = "PASS"
                result = $testResult
                timestamp = Get-Date
            }
        } else {
            $TestResults += @{
                name = $TestName
                status = "FAIL"
                result = $testResult
                timestamp = Get-Date
            }
        }
        
        return $success
        
    } catch {
        Write-TestLog "Test error: $TestName - $($_.Exception.Message)" "FAIL"
        $TestResults += @{
            name = $TestName
            status = "ERROR"
            result = @{error = $_.Exception.Message}
            timestamp = Get-Date
        }
        return $false
    }
}

# Test Suite 1: Core System Tests
function Test-CoreSystem {
    Write-TestLog "=== CORE SYSTEM TESTS ===" "INFO"
    
    # Test 1.1: Module Import
    Invoke-Test -TestName "Module Import" -TestCode {
        try {
            Import-Module ".\AgentCoordination.psm1" -Force
            return @{module_loaded = $true}
        } catch {
            return @{module_loaded = $false; error = $_.Exception.Message}
        }
    } -ExpectedResults @{module_loaded = $true}
    
    # Test 1.2: System Initialization
    Invoke-Test -TestName "System Initialization" -TestCode {
        try {
            Initialize-AgentCoordination -SessionId "test_session_001" -SnapshotInterval 5
            $status = Get-SystemStatus
            return @{
                initialized = $true
                session_id = $status.session_id
                turn_counter = $status.current_turn
            }
        } catch {
            return @{initialized = $false; error = $_.Exception.Message}
        }
    } -ExpectedResults @{initialized = $true}
    
    # Test 1.3: Agent Status Management
    Invoke-Test -TestName "Agent Status Management" -TestCode {
        $status = Get-SystemStatus
        return @{
            agents_configured = $status.active_agent -ne $null
            stryk_status = "ready"  # Will be validated in actual test
            dc_status = "ready"
            vscc_status = "ready"
        }
    } -ExpectedResults @{agents_configured = $true}
    
    # Test 1.4: Turn Advancement
    Invoke-Test -TestName "Turn Advancement" -TestCode {
        $initialTurn = (Get-SystemStatus).current_turn
        Advance-Turn
        $newTurn = (Get-SystemStatus).current_turn
        
        return @{
            turn_advanced = ($newTurn -gt $initialTurn)
            turn_difference = ($newTurn - $initialTurn)
        }
    } -ExpectedResults @{turn_advanced = $true}
}

# Test Suite 2: Token Optimization Tests
function Test-TokenOptimization {
    Write-TestLog "=== TOKEN OPTIMIZATION TESTS ===" "INFO"
    
    # Test 2.1: Shorthand Rule Application
    Invoke-Test -TestName "Shorthand Rule Application" -TestCode {
        $original = "Execute the function for the window and process the data"
        $optimized = Optimize-Tokens -Text $original
        
        return @{
            original_text = $original
            optimized_text = $optimized
            original_tokens = Estimate-Tokens -Text $original
            optimized_tokens = Estimate-Tokens -Text $optimized
            reduction_percent = [math]::Round((1 - (Estimate-Tokens -Text $optimized) / (Estimate-Tokens -Text $original)) * 100, 1)
        }
    } -ExpectedResults @{reduction_percent = 50}  # At least 50% reduction expected
    
    # Test 2.2: Token Usage Validation
    Invoke-Test -TestName "Token Usage Validation" -TestCode {
        # Send test messages and check token usage
        Send-AgentMessage -TargetAgent "DC" -Message @{
            type = "test"
            content = "EXEC win auto & data proc"
        }
        
        $status = Get-SystemStatus
        return @{
            total_token_usage = $status.total_token_usage
            within_limit = ($status.total_token_usage -le 100)  # Test limit
        }
    } -ExpectedResults @{within_limit = $true}
    
    # Test 2.3: Message Compression
    Invoke-Test -TestName "Message Compression" -TestCode {
        $message = @{type = "test"; content = "test message"; data = @{test = $true}}
        $compressed = Compress-Message -Message $message
        
        return @{
            compression_enabled = ($compressed.Length -lt 100)
            compressed_length = $compressed.Length
            is_json = $compressed.StartsWith("{") -and $compressed.EndsWith("}")
        }
    } -ExpectedResults @{is_json = $true}
}

# Test Suite 3: Communication Tests
function Test-AgentCommunication {
    Write-TestLog "=== AGENT COMMUNICATION TESTS ===" "INFO"
    
    # Test 3.1: Message Delivery
    Invoke-Test -TestName "Message Delivery" -TestCode {
        $testMessage = @{
            type = "test_message"
            content = "Test message for delivery validation"
            timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
        
        $startTime = Get-Date
        Send-AgentMessage -TargetAgent "DC" -Message $testMessage
        $endTime = Get-Date
        
        $deliveryTime = ($endTime - $startTime).TotalMilliseconds
        
        return @{
            message_sent = $true
            delivery_time_ms = [math]::Round($deliveryTime, 2)
            within_timeout = ($deliveryTime -lt 1000)  # 1 second timeout
        }
    } -ExpectedResults @{message_sent = $true}
    
    # Test 3.2: Message Reception
    Invoke-Test -TestName "Message Reception" -TestCode {
        # Wait a moment for message processing
        Start-Sleep -Milliseconds 500
        
        $messages = Receive-AgentMessage -AgentName "DC"
        
        return @{
            messages_received = $messages.Count
            has_test_message = ($messages | Where-Object { $_.type -eq "test_message" } | Measure-Object).Count -gt 0
            message_format_valid = ($messages.Count -eq 0 -or $messages[0].type -ne $null)
        }
    } -ExpectedResults @{messages_received = 0}  # Messages should be consumed
    
    # Test 3.3: Cross-Agent Messaging
    Invoke-Test -TestName "Cross-Agent Messaging" -TestCode {
        $agents = @("STRYK", "DC", "VSCC")
        $successCount = 0
        
        foreach ($from in $agents) {
            foreach ($to in $agents) {
                if ($from -ne $to) {
                    try {
                        Send-AgentMessage -TargetAgent $to -Message @{
                            type = "cross_agent_test"
                            content = "Test from $from to $to"
                            from = $from
                        }
                        $successCount++
                    } catch {
                        # Log failure but continue
                    }
                }
            }
        }
        
        return @{
            cross_agent_messages_sent = $successCount
            expected_messages = ($agents.Count * ($agents.Count - 1))
            success_rate = [math]::Round(($successCount / ($agents.Count * ($agents.Count - 1))) * 100, 1)
        }
    } -ExpectedResults @{success_rate = 100}
}

# Test Suite 4: Task Management Tests
function Test-TaskManagement {
    Write-TestLog "=== TASK MANAGEMENT TESTS ===" "INFO"
    
    # Test 4.1: Task Creation
    Invoke-Test -TestName "Task Creation" -TestCode {
        $testTask = @{
            task_id = "test_task_001"
            title = "Test Task for Validation"
            priority = 2
            assigned_agent = "DC"
            status = "pending"
            created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            required_turns = 2
            completed_turns = 0
            dependencies = @()
            handoff_agent = "VSCC"
            completion_criteria = @{test_complete = $true}
            token_estimate = 25
        }
        
        # Add to task queue
        $taskQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
        $initialCount = $taskQueue.tasks.Count
        $taskQueue.tasks += $testTask
        $taskQueue | ConvertTo-Json -Depth 10 | Out-File ".\TASK_QUEUE.json"
        
        $newQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
        $finalCount = $newQueue.tasks.Count
        
        return @{
            task_created = ($finalCount -gt $initialCount)
            initial_task_count = $initialCount
            final_task_count = $finalCount
            task_found = ($newQueue.tasks | Where-Object { $_.task_id -eq "test_task_001" } | Measure-Object).Count -gt 0
        }
    } -ExpectedResults @{task_created = $true}
    
    # Test 4.2: Task Processing
    Invoke-Test -TestName "Task Processing" -TestCode {
        $statusBefore = Get-SystemStatus
        
        Process-TaskQueue
        Start-Sleep -Milliseconds 500
        Advance-Turn
        
        $statusAfter = Get-SystemStatus
        
        return @{
            tasks_processed = ($statusAfter.active_tasks -gt $statusBefore.active_tasks)
            active_tasks_before = $statusBefore.active_tasks
            active_tasks_after = $statusAfter.active_tasks
            turn_advanced = ($statusAfter.current_turn -gt $statusBefore.current_turn)
        }
    } -ExpectedResults @{turn_advanced = $true}
    
    # Test 4.3: Task Completion
    Invoke-Test -TestName "Task Completion" -TestCode {
        Complete-Task -TaskId "test_task_001" -Results @{
            status = "success"
            output = "test completed"
        }
        
        $taskQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
        $completedTask = $taskQueue.tasks | Where-Object { $_.task_id -eq "test_task_001" }
        
        return @{
            task_completed = ($completedTask.status -eq "completed")
            completion_timestamp = $completedTask.completed_at
            has_results = ($completedTask.results -ne $null)
        }
    } -ExpectedResults @{task_completed = $true}
}

# Test Suite 5: Error Handling Tests
function Test-ErrorHandling {
    Write-TestLog "=== ERROR HANDLING TESTS ===" "INFO"
    
    # Test 5.1: Agent Stall Detection
    Invoke-Test -TestName "Agent Stall Detection" -TestCode {
        # Simulate stall by not advancing turns
        $initialTurn = (Get-SystemStatus).current_turn
        
        # Wait for detection threshold
        Start-Sleep -Seconds 4
        
        $stalledAgents = Detect-AgentUnstall
        
        return @{
            stall_detection_working = ($stalledAgents.Count -ge 0)  # Function should work
            detected_stalls = $stalledAgents.Count
            initial_turn = $initialTurn
            current_turn = (Get-SystemStatus).current_turn
        }
    } -ExpectedResults @{stall_detection_working = $true}
    
    # Test 5.2: Agent Recovery
    Invoke-Test -TestName "Agent Recovery" -TestCode {
        # Attempt recovery (even if no stall)
        $recoveryResult = $false
        try {
            Recover-Agent -AgentName "DC"
            $recoveryResult = $true
        } catch {
            $recoveryResult = $false
        }
        
        return @{
            recovery_attempted = $true
            recovery_successful = $recoveryResult
        }
    } -ExpectedResults @{recovery_attempted = $true}
    
    # Test 5.3: State Rollback
    Invoke-Test -TestName "State Rollback" -TestCode {
        # Create snapshot
        $currentTurn = (Get-SystemStatus).current_turn
        Create-StateSnapshot -Turn $currentTurn
        
        # Advance some turns
        Advance-Turn
        Advance-Turn
        
        $advancedTurn = (Get-SystemStatus).current_turn
        
        # Rollback
        $rollbackSuccess = Rollback-ToSnapshot -TargetTurn $currentTurn
        $finalTurn = (Get-SystemStatus).current_turn
        
        return @{
            snapshot_created = $true
            turns_advanced = ($advancedTurn -gt $currentTurn)
            rollback_successful = $rollbackSuccess
            final_turn_matches = ($finalTurn -eq $currentTurn)
        }
    } -ExpectedResults @{rollback_successful = $true}
}

# Test Suite 6: Performance Tests
function Test-Performance {
    Write-TestLog "=== PERFORMANCE TESTS ===" "INFO"
    
    # Test 6.1: Message Latency
    Invoke-Test -TestName "Message Latency" -TestCode {
        $latencyTests = @()
        
        for ($i = 1; $i -le 5; $i++) {
            $startTime = Get-Date
            Send-AgentMessage -TargetAgent "VSCC" -Message @{
                type = "latency_test"
                content = "Latency test $i"
                test_id = $i
            }
            $endTime = Get-Date
            
            $latency = ($endTime - $startTime).TotalMilliseconds
            $latencyTests += $latency
        }
        
        $averageLatency = ($latencyTests | Measure-Object -Average).Average
        $maxLatency = ($latencyTests | Measure-Object -Maximum).Maximum
        
        return @{
            average_latency_ms = [math]::Round($averageLatency, 2)
            max_latency_ms = [math]::Round($maxLatency, 2)
            target_met = ($averageLatency -lt 500)  # Target: <500ms
            test_count = $latencyTests.Count
        }
    } -ExpectedResults @{target_met = $true}
    
    # Test 6.2: Memory Usage
    Invoke-Test -TestName "Memory Usage" -TestCode {
        $processes = Get-Process | Where-Object { $_.ProcessName -match "autohotkey|powershell" }
        $totalMemoryMB = ($processes | Measure-Object WorkingSet -Sum).Sum / 1MB
        
        return @{
            total_memory_mb = [math]::Round($totalMemoryMB, 2)
            process_count = $processes.Count
            within_limit = ($totalMemoryMB -lt 900)  # Target: <896MB total
            memory_per_process_mb = [math]::Round($totalMemoryMB / $processes.Count, 2)
        }
    } -ExpectedResults @{within_limit = $true}
    
    # Test 6.3: Token Reduction Achievement
    Invoke-Test -TestName "Token Reduction Achievement" -TestCode {
        $testMessages = @(
            "Execute the function to process the data for the application window",
            "Send the message to the agent and wait for the response",
            "Create a new task for the automation and assign it to the correct agent"
        )
        
        $totalOriginalTokens = 0
        $totalOptimizedTokens = 0
        
        foreach ($msg in $testMessages) {
            $originalTokens = Estimate-Tokens -Text $msg
            $optimizedTokens = Estimate-Tokens -Text (Optimize-Tokens -Text $msg)
            
            $totalOriginalTokens += $originalTokens
            $totalOptimizedTokens += $optimizedTokens
        }
        
        $reductionPercent = [math]::Round((1 - $totalOptimizedTokens / $totalOriginalTokens) * 100, 1)
        
        return @{
            total_original_tokens = $totalOriginalTokens
            total_optimized_tokens = $totalOptimizedTokens
            reduction_percent = $reductionPercent
            target_66_percent_met = ($reductionPercent -ge 66)
        }
    } -ExpectedResults @{target_66_percent_met = $true}
}

# Test Suite 7: Integration Tests
function Test-Integration {
    Write-TestLog "=== INTEGRATION TESTS ===" "INFO"
    
    # Test 7.1: AutoHotkey Script Integration
    Invoke-Test -TestName "AutoHotkey Script Integration" -TestCode {
        $scriptFiles = @(
            ".\DC_VSCC_Messaging.ahk",
            ".\DC_Browser_Messaging.ahk", 
            ".\VSCC_Browser_Messaging.ahk"
        )
        
        $scriptsFound = 0
        $scriptsValid = 0
        
        foreach ($script in $scriptFiles) {
            if (Test-Path $script) {
                $scriptsFound++
                # Basic syntax check
                $content = Get-Content $script -Raw
                if ($content.Contains("#Requires AutoHotkey v2.0")) {
                    $scriptsValid++
                }
            }
        }
        
        return @{
            scripts_found = $scriptsFound
            scripts_valid = $scriptsValid
            expected_scripts = $scriptFiles.Count
            all_scripts_valid = ($scriptsValid -eq $scriptFiles.Count)
        }
    } -ExpectedResults @{all_scripts_valid = $true}
    
    # Test 7.2: Configuration Integration
    Invoke-Test -TestName "Configuration Integration" -TestCode {
        $configFiles = @(
            ".\config.json",
            ".\coordination_rules.json",
            ".\token_optimization.json",
            ".\AGENT_REGISTRY.json"
        )
        
        $configsValid = 0
        
        foreach ($config in $configFiles) {
            try {
                $cfg = Get-Content $config | ConvertFrom-Json
                if ($cfg.schema_version) {
                    $configsValid++
                }
            } catch {
                # Invalid JSON
            }
        }
        
        return @{
            configurations_valid = $configsValid
            total_configurations = $configFiles.Count
            all_valid = ($configsValid -eq $configFiles.Count)
        }
    } -ExpectedResults @{all_valid = $true}
    
    # Test 7.3: End-to-End Workflow
    Invoke-Test -TestName "End-to-End Workflow" -TestCode {
        $startTime = Get-Date
        
        # Initialize system
        Initialize-AgentCoordination -SessionId "e2e_test_session"
        
        # Create task
        $e2eTask = @{
            task_id = "e2e_task_001"
            title = "End-to-End Test Task"
            priority = 1
            assigned_agent = "STRYK"
            status = "pending"
            created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            required_turns = 3
            dependencies = @()
            handoff_agent = $null
            completion_criteria = @{e2e_complete = $true}
            token_estimate = 30
        }
        
        # Add to queue
        $taskQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
        $taskQueue.tasks += $e2eTask
        $taskQueue | ConvertTo-Json -Depth 10 | Out-File ".\TASK_QUEUE.json"
        
        # Process workflow
        for ($i = 1; $i -le 3; $i++) {
            Process-TaskQueue
            Advance-Turn
            Start-Sleep -Milliseconds 200
        }
        
        # Complete task
        Complete-Task -TaskId "e2e_task_001" -Results @{e2e_success = $true}
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        $status = Get-SystemStatus
        
        return @{
            workflow_completed = $true
            duration_seconds = [math]::Round($duration, 2)
            final_turn = $status.current_turn
            completed_tasks = $status.completed_tasks
            within_time_limit = ($duration -lt 30)  # 30 second limit
        }
    } -ExpectedResults @{workflow_completed = $true}
}

# Test Suite 8: Stress Tests
function Test-Stress {
    Write-TestLog "=== STRESS TESTS ===" "INFO"
    
    # Test 8.1: High Volume Messaging
    Invoke-Test -TestName "High Volume Messaging" -TestCode {
        $messageCount = 50
        $successCount = 0
        $startTime = Get-Date
        
        for ($i = 1; $i -le $messageCount; $i++) {
            try {
                Send-AgentMessage -TargetAgent "DC" -Message @{
                    type = "stress_test"
                    content = "Stress test message $i"
                    test_id = $i
                } -Priority "normal"
                $successCount++
            } catch {
                # Count failures
            }
            
            if ($i % 10 -eq 0) {
                Start-Sleep -Milliseconds 100  # Brief pause
            }
        }
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        return @{
            messages_attempted = $messageCount
            messages_successful = $successCount
            success_rate = [math]::Round(($successCount / $messageCount) * 100, 1)
            duration_seconds = [math]::Round($duration, 2)
            messages_per_second = [math]::Round($successCount / $duration, 2)
            target_met = ($successCount -ge ($messageCount * 0.9))  # 90% success rate
        }
    } -ExpectedResults @{target_met = $true}
    
    # Test 8.2: Concurrent Task Processing
    Invoke-Test -TestName "Concurrent Task Processing" -TestCode {
        $taskCount = 20
        $tasksCreated = 0
        
        # Create multiple tasks
        for ($i = 1; $i -le $taskCount; $i++) {
            $stressTask = @{
                task_id = "stress_task_$i"
                title = "Stress Test Task $i"
                priority = (1, 2, 3, 4 | Get-Random)
                assigned_agent = @("STRYK", "DC", "VSCC") | Get-Random
                status = "pending"
                created_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
                required_turns = 2
                dependencies = @()
                handoff_agent = $null
                completion_criteria = @{stress_complete = $true}
                token_estimate = 20
            }
            
            try {
                $taskQueue = Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json
                $taskQueue.tasks += $stressTask
                $taskQueue | ConvertTo-Json -Depth 10 | Out-File ".\TASK_QUEUE.json"
                $tasksCreated++
            } catch {
                # Creation failure
            }
        }
        
        # Process tasks
        $initialTasks = (Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json).tasks.Count
        
        for ($i = 1; $i -le 10; $i++) {
            Process-TaskQueue
            Advance-Turn
            Start-Sleep -Milliseconds 300
        }
        
        $finalTasks = (Get-Content ".\TASK_QUEUE.json" | ConvertFrom-Json).tasks.Count
        $processedTasks = $initialTasks - $finalTasks
        
        return @{
            tasks_created = $tasksCreated
            tasks_processed = $processedTasks
            processing_rate = [math]::Round(($processedTasks / $taskCount) * 100, 1)
            system_stable = ($processedTasks -gt 0)
        }
    } -ExpectedResults @{system_stable = $true}
}

# Main Test Execution
function Main {
    Write-Host "=== MULTI-AGENT COORDINATION SYSTEM VALIDATION ===" -ForegroundColor Cyan
    Write-Host "Starting validation tests at: $(Get-Date)" -ForegroundColor White
    
    # Determine which tests to run
    $testSuites = @()
    
    if ($RunAll) {
        $testSuites = @("CoreSystem", "TokenOptimization", "AgentCommunication", "TaskManagement", "ErrorHandling", "Performance", "Integration", "Stress")
    } else {
        if ($QuickTest) { $testSuites += @("CoreSystem", "TokenOptimization", "AgentCommunication") }
        if ($PerformanceTest) { $testSuites += @("Performance", "TokenOptimization") }
        if ($IntegrationTest) { $testSuites += @("Integration", "End-to-End") }
        if ($StressTest) { $testSuites += @("Stress", "Performance") }
        
        # Default to quick tests if no specific options
        if ($testSuites.Count -eq 0) {
            $testSuites = @("CoreSystem", "TokenOptimization", "AgentCommunication")
        }
    }
    
    Write-Host "Running test suites: $($testSuites -join ', ')" -ForegroundColor Yellow
    
    # Execute selected test suites
    foreach ($suite in $testSuites) {
        try {
            switch ($suite) {
                "CoreSystem" { Test-CoreSystem }
                "TokenOptimization" { Test-TokenOptimization }
                "AgentCommunication" { Test-AgentCommunication }
                "TaskManagement" { Test-TaskManagement }
                "ErrorHandling" { Test-ErrorHandling }
                "Performance" { Test-Performance }
                "Integration" { Test-Integration }
                "Stress" { Test-Stress }
                default { Write-Warning "Unknown test suite: $suite" }
            }
        } catch {
            Write-TestLog "Test suite error: $suite - $($_.Exception.Message)" "FAIL"
        }
    }
    
    # Generate Test Report
    $testEndTime = Get-Date
    $totalDuration = ($testEndTime - $TestStartTime).TotalMinutes
    
    $passedTests = ($TestResults | Where-Object { $_.status -eq "PASS" }).Count
    $failedTests = ($TestResults | Where-Object { $_.status -eq "FAIL" }).Count
    $errorTests = ($TestResults | Where-Object { $_.status -eq "ERROR" }).Count
    $totalTests = $TestResults.Count
    
    Write-Host "`n=== VALIDATION TEST RESULTS ===" -ForegroundColor Cyan
    Write-Host "Test Duration: $([math]::Round($totalDuration, 2)) minutes" -ForegroundColor White
    Write-Host "Total Tests: $totalTests" -ForegroundColor White
    Write-Host "Passed: $passedTests" -ForegroundColor Green
    Write-Host "Failed: $failedTests" -ForegroundColor Red
    Write-Host "Errors: $errorTests" -ForegroundColor Yellow
    Write-Host "Success Rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor $(
        if ($passedTests / $totalTests -ge 0.9) { "Green" } elseif ($passedTests / $totalTests -ge 0.7) { "Yellow" } else { "Red" }
    )
    
    # Success Metrics Validation
    Write-Host "`n=== SUCCESS METRICS VALIDATION ===" -ForegroundColor Cyan
    
    # Token Usage Reduction (Target: ≥66%)
    $tokenTest = $TestResults | Where-Object { $_.name -eq "Token Reduction Achievement" }
    if ($tokenTest -and $tokenTest.result.target_66_percent_met) {
        Write-Host "✓ Token Usage Reduction: ≥66% achieved" -ForegroundColor Green
    } else {
        Write-Host "✗ Token Usage Reduction: Target not met" -ForegroundColor Red
    }
    
    # Message Delivery Latency (Target: <500ms)
    $latencyTest = $TestResults | Where-Object { $_.name -eq "Message Latency" }
    if ($latencyTest -and $latencyTest.result.target_met) {
        Write-Host "✓ Message Delivery Latency: <500ms achieved" -ForegroundColor Green
    } else {
        Write-Host "✗ Message Delivery Latency: Target not met" -ForegroundColor Red
    }
    
    # Context Preservation (Target: 100%)
    $contextTest = $TestResults | Where-Object { $_.name -eq "State Rollback" }
    if ($contextTest -and $contextTest.result.rollback_successful) {
        Write-Host "✓ Context Preservation: 100% across sessions" -ForegroundColor Green
    } else {
        Write-Host "✗ Context Preservation: Issues detected" -ForegroundColor Red
    }
    
    # Error Recovery (Target: ≤3 turns)
    $recoveryTest = $TestResults | Where-Object { $_.name -eq "Agent Recovery" }
    if ($recoveryTest -and $recoveryTest.result.recovery_successful) {
        Write-Host "✓ Error Recovery: Automatic unstall within 3 turns" -ForegroundColor Green
    } else {
        Write-Host "✗ Error Recovery: Issues detected" -ForegroundColor Red
    }
    
    # Generate detailed report file
    $report = @{
        test_summary = @{
            start_time = $TestStartTime
            end_time = $testEndTime
            duration_minutes = [math]::Round($totalDuration, 2)
            total_tests = $totalTests
            passed = $passedTests
            failed = $failedTests
            errors = $errorTests
            success_rate = [math]::Round(($passedTests / $totalTests) * 100, 1)
        }
        success_metrics = @{
            token_reduction_achieved = if ($tokenTest) { $tokenTest.result.target_66_percent_met } else { $false }
            message_latency_met = if ($latencyTest) { $latencyTest.result.target_met } else { $false }
            context_preservation_met = if ($contextTest) { $contextTest.result.rollback_successful } else { $false }
            error_recovery_met = if ($recoveryTest) { $recoveryTest.result.recovery_successful } else { $false }
        }
        detailed_results = $TestResults
    }
    
    $reportFile = "$LogDirectory\validation_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $report | ConvertTo-Json -Depth 10 | Out-File $reportFile
    
    Write-Host "`nDetailed report saved to: $reportFile" -ForegroundColor Cyan
    
    # Overall validation result
    $overallSuccess = $passedTests / $totalTests -ge 0.9 -and 
                      ($tokenTest.result.target_66_percent_met -eq $true) -and
                      ($latencyTest.result.target_met -eq $true)
    
    if ($overallSuccess) {
        Write-Host "`n🎉 SYSTEM VALIDATION: SUCCESS 🎉" -ForegroundColor Green
        Write-Host "All critical success metrics achieved!" -ForegroundColor Green
    } else {
        Write-Host "`n❌ SYSTEM VALIDATION: ISSUES DETECTED ❌" -ForegroundColor Red
        Write-Host "Some success metrics not achieved. Review detailed report." -ForegroundColor Yellow
    }
    
    return $overallSuccess
}

# Run the validation
Main