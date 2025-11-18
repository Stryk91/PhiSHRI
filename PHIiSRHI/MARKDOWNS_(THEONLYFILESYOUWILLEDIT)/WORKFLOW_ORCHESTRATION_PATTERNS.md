# Workflow Orchestration Patterns
## PhiSync Multi-Agent Coordination Codex - Domain 2

**Version:** 1.0.0
**Last Updated:** 2025-11-15
**Target:** PhiVector AI Infrastructure (DC, VSSC, KALIC, WEBC, CMDC)

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Conceptual Overview](#conceptual-overview)
3. [DAG Workflow Fundamentals](#dag-workflow-fundamentals)
4. [Pattern Catalog](#pattern-catalog)
5. [Code Examples](#code-examples)
6. [Decision Matrices](#decision-matrices)
7. [Anti-Patterns](#anti-patterns)
8. [Performance Considerations](#performance-considerations)
9. [Security Implications](#security-implications)
10. [Troubleshooting Guide](#troubleshooting-guide)
11. [PhiVector Workflow Templates](#phivector-workflow-templates)
12. [References](#references)

---

## Executive Summary

Workflow orchestration is the art of coordinating multiple agents to execute complex, multi-step tasks efficiently. A well-designed orchestration strategy determines task execution order, handles dependencies, manages failures, and optimizes resource utilization.

### Key Takeaways
- **DAGs (Directed Acyclic Graphs)** model workflows with clear dependencies
- **Orchestration vs Choreography**: Centralized control vs distributed coordination
- **DC is the orchestrator** in PhiVector (hub-and-spoke pattern)
- **Parallel execution** maximizes throughput for independent tasks
- **Dependency resolution** ensures tasks execute in correct order

### When to Use This Guide
- Designing multi-agent workflows (3+ agents coordinating)
- Optimizing task execution order for performance
- Implementing complex approval/review pipelines
- Troubleshooting workflow deadlocks or bottlenecks
- Scaling to 10+ coordinated agents

### Quick Decision Tree
```
Tasks have dependencies?
├─ Yes → Use DAG workflow engine
└─ No → Execute all in parallel

Need centralized control?
├─ Yes → Orchestration (DC coordinates)
└─ No → Choreography (event-driven)

Human approval required?
├─ Yes → Add approval node in DAG
└─ No → Fully automated workflow

Failure of one task should stop all?
├─ Yes → Sequential with error propagation
└─ No → Best-effort parallel execution
```

---

## Conceptual Overview

### What is Workflow Orchestration?

**Orchestration** refers to centralized coordination where a single **orchestrator** (DC in PhiVector) manages:
- **Task distribution** to workers
- **Dependency resolution** (task execution order)
- **State tracking** (which tasks completed, failed, or pending)
- **Error handling** (retry, compensate, or abort)
- **Result aggregation** (collect outputs from workers)

**Choreography** refers to decentralized coordination where:
- Agents independently react to events
- No central coordinator
- Emergent behavior from agent interactions

**PhiVector Model:** Hybrid approach
- **DC orchestrates** high-level workflows (centralized control)
- **Agents choreograph** internal tasks (decentralized execution)

### DAG (Directed Acyclic Graph) Fundamentals

A **DAG** represents workflows as:
- **Nodes** = Tasks (individual units of work)
- **Edges** = Dependencies (Task B depends on Task A)
- **Acyclic** = No circular dependencies (prevents deadlocks)

**Example DAG:**
```
        [Start]
           |
      [Research] (WEBC)
           |
     [Synthesize] (DC)
          / \
         /   \
   [Implement] [Audit]
    (VSSC)     (KALIC)
         \   /
          \ /
      [Approve] (STRYK)
           |
       [Deploy] (CMDC)
           |
        [End]
```

**Key Properties:**
- **Topological ordering:** Tasks can be sorted such that dependencies come first
- **Parallelization:** Tasks without dependencies can run concurrently (Implement + Audit)
- **Critical path:** Longest path determines minimum workflow duration

---

## DAG Workflow Fundamentals

### Task Dependencies

**Types of Dependencies:**

1. **Data dependency:** Task B needs output from Task A
   - Example: `Synthesize` needs research results from `Research`

2. **Control dependency:** Task B executes only if Task A succeeds
   - Example: `Deploy` only if `Approve` returns "yes"

3. **Resource dependency:** Tasks compete for same resource
   - Example: Two agents cannot write to same file simultaneously

4. **Temporal dependency:** Task B waits for Task A regardless of output
   - Example: `Audit` waits for `Implement` to finish before scanning code

### Dependency Resolution Algorithms

**Kahn's Algorithm (Topological Sort):**
```python
def topological_sort(graph):
    in_degree = {node: 0 for node in graph}
    for node in graph:
        for neighbor in graph[node]:
            in_degree[neighbor] += 1

    queue = [node for node in graph if in_degree[node] == 0]
    result = []

    while queue:
        node = queue.pop(0)
        result.append(node)

        for neighbor in graph[node]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    if len(result) != len(graph):
        raise Exception("Cycle detected in DAG")

    return result
```

**PowerShell Implementation:**
```powershell
function Resolve-Dependencies {
    param([hashtable]$TaskGraph)

    # Calculate in-degree (number of dependencies)
    $inDegree = @{}
    foreach ($task in $TaskGraph.Keys) {
        $inDegree[$task] = 0
    }

    foreach ($task in $TaskGraph.Keys) {
        foreach ($dependent in $TaskGraph[$task].DependsOn) {
            $inDegree[$dependent]++
        }
    }

    # Queue tasks with no dependencies
    $queue = @()
    foreach ($task in $inDegree.Keys) {
        if ($inDegree[$task] -eq 0) {
            $queue += $task
        }
    }

    $executionOrder = @()
    while ($queue.Count -gt 0) {
        $current = $queue[0]
        $queue = $queue[1..($queue.Count-1)]
        $executionOrder += $current

        # Reduce in-degree for dependents
        foreach ($dependent in $TaskGraph[$current].DependsOn) {
            $inDegree[$dependent]--
            if ($inDegree[$dependent] -eq 0) {
                $queue += $dependent
            }
        }
    }

    if ($executionOrder.Count -ne $TaskGraph.Count) {
        throw "Circular dependency detected in workflow"
    }

    return $executionOrder
}
```

### Parallel Execution

**Identifying Parallelizable Tasks:**
```powershell
function Get-ParallelTasks {
    param([hashtable]$TaskGraph, [array]$Completed)

    $ready = @()
    foreach ($task in $TaskGraph.Keys) {
        if ($task -in $Completed) { continue }

        # Check if all dependencies completed
        $allDepsComplete = $true
        foreach ($dep in $TaskGraph[$task].DependsOn) {
            if ($dep -notin $Completed) {
                $allDepsComplete = $false
                break
            }
        }

        if ($allDepsComplete) {
            $ready += $task
        }
    }

    return $ready
}
```

**Execution Strategy:**
```powershell
function Execute-DAGWorkflow {
    param([hashtable]$TaskGraph)

    $completed = @()
    $running = @{}

    while ($completed.Count -lt $TaskGraph.Count) {
        # Get tasks ready to execute
        $ready = Get-ParallelTasks -TaskGraph $TaskGraph -Completed $completed

        # Start ready tasks
        foreach ($task in $ready) {
            if ($task -notin $running.Keys) {
                $running[$task] = Start-Task -Task $TaskGraph[$task]
            }
        }

        # Check for completed tasks
        foreach ($task in $running.Keys) {
            if (Test-TaskComplete -TaskHandle $running[$task]) {
                $result = Get-TaskResult -TaskHandle $running[$task]
                $TaskGraph[$task].Result = $result
                $completed += $task
                $running.Remove($task)
            }
        }

        Start-Sleep -Milliseconds 100  # Poll interval
    }

    return $TaskGraph
}
```

---

## Pattern Catalog

### Pattern 1: Sequential Pipeline

**Intent:** Execute tasks one after another in strict order

**Use Case:** Each task requires output from previous task

**Structure:**
```
[Task A] → [Task B] → [Task C] → [Task D]
```

**Implementation:**
```powershell
function Execute-SequentialPipeline {
    param([array]$Tasks)

    $result = $null
    foreach ($task in $Tasks) {
        Write-Host "Executing: $($task.Name)"
        $result = & $task.Action -Input $result

        if ($task.ValidateResult -and -not (& $task.ValidateResult $result)) {
            throw "Task $($task.Name) validation failed"
        }
    }

    return $result
}

# Example: Research → Synthesize → Implement pipeline
$pipeline = @(
    @{
        Name = "Research"
        Action = { param($Input) Invoke-WebcResearch -Topic "OAuth2 best practices" }
        ValidateResult = { param($r) $r.Sources.Count -ge 5 }
    },
    @{
        Name = "Synthesize"
        Action = { param($Input) Invoke-DcSynthesis -ResearchData $Input }
        ValidateResult = { param($r) $r.Requirements.Count -gt 0 }
    },
    @{
        Name = "Implement"
        Action = { param($Input) Invoke-VsscBuild -Requirements $Input }
        ValidateResult = { param($r) Test-Path $r.OutputFile }
    }
)

$finalResult = Execute-SequentialPipeline -Tasks $pipeline
```

**When to Use:**
- Tasks have strict data dependencies
- Need simple error handling (abort on first failure)
- Workflow is inherently sequential

**Avoid When:**
- Tasks are independent (use parallel instead)
- Need partial results (use fan-out/fan-in)

---

### Pattern 2: Parallel Fan-Out / Fan-In

**Intent:** Execute multiple independent tasks concurrently, then aggregate results

**Use Case:** Multiple agents working on independent subtasks

**Structure:**
```
           [Start]
              |
         [Fan-Out]
        /    |    \
    [Task1] [Task2] [Task3]
        \    |    /
         [Fan-In]
              |
           [End]
```

**Implementation:**
```powershell
function Execute-ParallelFanOut {
    param(
        [array]$Tasks,
        [scriptblock]$Aggregator
    )

    # Fan-out: Start all tasks
    $jobs = @{}
    foreach ($task in $Tasks) {
        Write-Host "Starting: $($task.Name)"

        # Send command to agent
        $msgId = Send-Command -To $task.Agent -Payload $task.Payload
        $jobs[$task.Name] = @{
            Agent = $task.Agent
            MessageId = $msgId
            StartTime = Get-Date
        }
    }

    # Wait for all tasks to complete
    $results = @{}
    while ($jobs.Count -gt 0) {
        foreach ($taskName in $jobs.Keys) {
            $job = $jobs[$taskName]
            $responseFile = "C:\PhiVector\ipc\$($job.Agent)\outbox\resp-$($job.MessageId).json"

            if (Test-Path $responseFile) {
                $response = Get-Content $responseFile | ConvertFrom-Json
                $results[$taskName] = $response.payload
                $jobs.Remove($taskName)
                Write-Host "Completed: $taskName"
                break
            }

            # Timeout check
            if ((Get-Date) - $job.StartTime -gt [TimeSpan]::FromMinutes(10)) {
                throw "Task $taskName timed out"
            }
        }

        Start-Sleep -Milliseconds 500
    }

    # Fan-in: Aggregate results
    return & $Aggregator $results
}

# Example: Parallel security scans
$scanTasks = @(
    @{
        Name = "StaticAnalysis"
        Agent = "kalic"
        Payload = @{ command = "static_scan"; target = "C:\PhiVector\tools" }
    },
    @{
        Name = "DependencyCheck"
        Agent = "kalic"
        Payload = @{ command = "dependency_audit"; manifest = "packages.json" }
    },
    @{
        Name = "LicenseAudit"
        Agent = "kalic"
        Payload = @{ command = "license_check"; sourceDir = "C:\PhiVector\tools" }
    }
)

$aggregatedResults = Execute-ParallelFanOut -Tasks $scanTasks -Aggregator {
    param($results)

    $totalIssues = 0
    $allIssues = @()

    foreach ($scan in $results.Keys) {
        $totalIssues += $results[$scan].issuesFound
        $allIssues += $results[$scan].issues
    }

    return @{
        totalIssues = $totalIssues
        allIssues = $allIssues
        scansCompleted = $results.Keys.Count
    }
}
```

**When to Use:**
- Tasks are independent and can run concurrently
- Need to maximize throughput
- Results require aggregation (merge, summarize)

**Avoid When:**
- Tasks have dependencies (use DAG instead)
- Resource contention likely (use sequential or throttled parallel)

---

### Pattern 3: Scatter-Gather (Data Partitioning)

**Intent:** Split large dataset, process partitions in parallel, gather results

**Use Case:** Processing large log files, datasets, or batch operations

**Structure:**
```
    [Large Dataset]
          |
      [Scatter]
      /   |   \
   [P1]  [P2]  [P3]  (Process partitions)
      \   |   /
      [Gather]
          |
     [Merged Result]
```

**Implementation:**
```powershell
function Execute-ScatterGather {
    param(
        [array]$Data,
        [int]$PartitionCount = 4,
        [string]$WorkerAgent,
        [hashtable]$ProcessPayload,
        [scriptblock]$Merger
    )

    # Scatter: Partition data
    $partitionSize = [Math]::Ceiling($Data.Count / $PartitionCount)
    $partitions = @()

    for ($i = 0; $i -lt $PartitionCount; $i++) {
        $start = $i * $partitionSize
        $end = [Math]::Min(($i + 1) * $partitionSize, $Data.Count)

        if ($start -lt $Data.Count) {
            $partitions += @{
                Id = $i
                Data = $Data[$start..($end-1)]
            }
        }
    }

    # Process partitions in parallel
    $jobs = @{}
    foreach ($partition in $partitions) {
        $payload = $ProcessPayload.Clone()
        $payload.partition = $partition

        $msgId = Send-Command -To $WorkerAgent -Payload $payload
        $jobs[$partition.Id] = $msgId
    }

    # Gather results
    $partitionResults = @{}
    while ($jobs.Count -gt 0) {
        foreach ($partitionId in $jobs.Keys) {
            $msgId = $jobs[$partitionId]
            $responseFile = "C:\PhiVector\ipc\$WorkerAgent\outbox\resp-$msgId.json"

            if (Test-Path $responseFile) {
                $response = Get-Content $responseFile | ConvertFrom-Json
                $partitionResults[$partitionId] = $response.payload.result
                $jobs.Remove($partitionId)
                break
            }
        }

        Start-Sleep -Milliseconds 500
    }

    # Merge results
    return & $Merger $partitionResults
}

# Example: Analyze 10,000 log entries
$logEntries = Get-Content "C:\logs\app.log"

$analysisResult = Execute-ScatterGather `
    -Data $logEntries `
    -PartitionCount 4 `
    -WorkerAgent "cmdc" `
    -ProcessPayload @{ command = "analyze_logs" } `
    -Merger {
        param($results)

        $totalErrors = 0
        $totalWarnings = 0
        $uniqueErrors = @()

        foreach ($partitionId in $results.Keys) {
            $totalErrors += $results[$partitionId].errorCount
            $totalWarnings += $results[$partitionId].warningCount
            $uniqueErrors += $results[$partitionId].uniqueErrors
        }

        return @{
            totalErrors = $totalErrors
            totalWarnings = $totalWarnings
            uniqueErrors = ($uniqueErrors | Select-Object -Unique)
        }
    }
```

**When to Use:**
- Large datasets that can be partitioned
- Processing is CPU-intensive
- Order of processing doesn't matter (embarrassingly parallel)

**Avoid When:**
- Data partitioning is complex or expensive
- Partitions have dependencies
- Merging results is more expensive than single-threaded processing

---

### Pattern 4: Conditional Branching

**Intent:** Execute different tasks based on runtime conditions

**Use Case:** Approval workflows, error handling, environment-specific logic

**Structure:**
```
      [Task A]
          |
     [Decision]
       /    \
 [True]    [False]
   /          \
[Task B]    [Task C]
   \          /
    [Converge]
```

**Implementation:**
```powershell
function Execute-ConditionalWorkflow {
    param(
        [scriptblock]$Condition,
        [hashtable]$TrueBranch,
        [hashtable]$FalseBranch
    )

    # Evaluate condition
    $conditionResult = & $Condition

    if ($conditionResult) {
        Write-Host "Condition true - executing true branch"
        return Invoke-Task -Task $TrueBranch
    }
    else {
        Write-Host "Condition false - executing false branch"
        return Invoke-Task -Task $FalseBranch
    }
}

# Example: Deploy with approval for production
function Deploy-WithApproval {
    param(
        [string]$Environment,
        [string]$Artifact
    )

    Execute-ConditionalWorkflow `
        -Condition {
            return $Environment -eq "production"
        } `
        -TrueBranch @{
            Name = "ProductionDeployWithApproval"
            Action = {
                # Request STRYK approval
                $approval = Request-HumanApproval -Message "Deploy $Artifact to production?"

                if ($approval.approved) {
                    Invoke-Deployment -Environment $Environment -Artifact $Artifact
                }
                else {
                    throw "Deployment cancelled by user"
                }
            }
        } `
        -FalseBranch @{
            Name = "NonProductionDeploy"
            Action = {
                # Auto-deploy to dev/staging
                Invoke-Deployment -Environment $Environment -Artifact $Artifact
            }
        }
}
```

**When to Use:**
- Workflow logic depends on runtime data
- Human approval required for certain paths
- Environment-specific behavior (dev vs production)

**Avoid When:**
- Branching logic is complex (use state machine instead)
- Too many branches (refactor into separate workflows)

---

### Pattern 5: Retry with Exponential Backoff

**Intent:** Automatically retry failed tasks with increasing delays

**Use Case:** Transient failures (network, resource unavailable)

**Structure:**
```
[Task] → (Fail) → Wait 1s → [Retry 1] → (Fail) → Wait 2s → [Retry 2] → (Fail) → Wait 4s → [Retry 3]
```

**Implementation:**
```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$Task,
        [int]$MaxRetries = 3,
        [int]$BaseDelayMs = 1000,
        [array]$RetriableErrors = @("timeout", "unavailable", "busy")
    )

    $attempt = 0
    while ($attempt -le $MaxRetries) {
        try {
            return & $Task
        }
        catch {
            $errorMsg = $_.Exception.Message
            $isRetriable = $false

            foreach ($retriable in $RetriableErrors) {
                if ($errorMsg -like "*$retriable*") {
                    $isRetriable = $true
                    break
                }
            }

            if (-not $isRetriable -or $attempt -eq $MaxRetries) {
                throw  # Non-retriable error or max retries exceeded
            }

            $attempt++
            $delayMs = $BaseDelayMs * [Math]::Pow(2, $attempt - 1)

            # Add jitter (randomness) to prevent thundering herd
            $jitter = Get-Random -Minimum 0 -Maximum ($delayMs * 0.1)
            $totalDelay = $delayMs + $jitter

            Write-Warning "Task failed (attempt $attempt/$MaxRetries): $errorMsg. Retrying in $($totalDelay)ms..."
            Start-Sleep -Milliseconds $totalDelay
        }
    }
}

# Example: Call VSSC with retry
$buildResult = Invoke-WithRetry -MaxRetries 3 -Task {
    Send-Command -To "vssc" -Payload @{ command = "build"; project = "UserAuth" } -TimeoutSeconds 60
}
```

**When to Use:**
- Transient failures expected (network, external services)
- Idempotent operations (retrying doesn't cause side effects)
- Non-critical timing (delays acceptable)

**Avoid When:**
- Failures are permanent (syntax errors, missing files)
- Non-idempotent operations (retrying causes duplication)
- Real-time requirements (cannot afford delays)

---

### Pattern 6: Saga Pattern (Compensating Transactions)

**Intent:** Coordinate multi-step workflows with rollback capability

**Use Case:** Multi-agent transactions where partial completion must be undone

**Structure:**
```
[Step 1] → [Step 2] → [Step 3] (Fail) → [Compensate 2] → [Compensate 1]
```

**Implementation:**
```powershell
function Execute-Saga {
    param([array]$Steps)

    $completed = @()

    try {
        foreach ($step in $Steps) {
            Write-Host "Executing: $($step.Name)"
            $result = & $step.Action

            $completed += @{
                Step = $step
                Result = $result
            }
        }

        return $completed[-1].Result  # Return final result
    }
    catch {
        Write-Error "Saga failed at step $($step.Name): $_"
        Write-Host "Rolling back completed steps..."

        # Compensate in reverse order
        for ($i = $completed.Count - 1; $i -ge 0; $i--) {
            $compensate = $completed[$i].Step.Compensate

            if ($compensate) {
                try {
                    Write-Host "Compensating: $($completed[$i].Step.Name)"
                    & $compensate $completed[$i].Result
                }
                catch {
                    Write-Error "Compensation failed for $($completed[$i].Step.Name): $_"
                }
            }
        }

        throw  # Re-throw original error
    }
}

# Example: Multi-agent deployment with rollback
$deploymentSaga = @(
    @{
        Name = "BuildArtifact"
        Action = { Invoke-VsscBuild -Project "UserAuth" }
        Compensate = { param($result) Remove-Item $result.ArtifactPath -Force }
    },
    @{
        Name = "SecurityScan"
        Action = { Invoke-KalicScan -Target $buildResult.ArtifactPath }
        Compensate = $null  # No compensation needed
    },
    @{
        Name = "Deploy"
        Action = {
            Invoke-CmdcDeploy -Artifact $buildResult.ArtifactPath -Environment "production"
        }
        Compensate = { param($result) Invoke-CmdcRollback -DeploymentId $result.DeploymentId }
    }
)

Execute-Saga -Steps $deploymentSaga
```

**When to Use:**
- Multi-step workflows with failure risk
- Operations need rollback capability
- Maintaining consistency across agents

**Avoid When:**
- Compensation logic is complex or impossible
- Operations are idempotent (can safely retry instead)

---

### Pattern 7: Human-in-the-Loop Approval

**Intent:** Pause workflow for human decision before proceeding

**Use Case:** Security-critical operations, production deployments, budget approvals

**Structure:**
```
[Automated Tasks] → [Approval Gate] → (Wait for STRYK) → [Proceed or Abort]
```

**Implementation:**
```powershell
function Request-HumanApproval {
    param(
        [string]$Message,
        [hashtable]$Context,
        [int]$TimeoutMinutes = 60
    )

    $approvalId = [guid]::NewGuid().ToString()
    $approvalRequest = @{
        id = $approvalId
        timestamp = Get-Date -Format "o"
        message = $Message
        context = $Context
        status = "pending"
    } | ConvertTo-Json -Depth 10

    # Write to STRYK's approval queue
    $approvalFile = "C:\PhiVector\ipc\stryk\approvals\$approvalId.json"
    $approvalRequest | Out-File $approvalFile -Encoding UTF8

    # Notify STRYK (e.g., desktop notification, email)
    Send-Notification -To "STRYK" -Message $Message -Type "approval_required"

    # Wait for approval or timeout
    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)
    while ((Get-Date) -lt $deadline) {
        if (Test-Path "$approvalFile.approved") {
            $approval = Get-Content "$approvalFile.approved" | ConvertFrom-Json
            Remove-Item $approvalFile -Force
            Remove-Item "$approvalFile.approved" -Force
            return $approval
        }

        if (Test-Path "$approvalFile.rejected") {
            $rejection = Get-Content "$approvalFile.rejected" | ConvertFrom-Json
            Remove-Item $approvalFile -Force
            Remove-Item "$approvalFile.rejected" -Force
            throw "Approval rejected: $($rejection.reason)"
        }

        Start-Sleep -Seconds 5
    }

    # Timeout - default action (reject for safety)
    Remove-Item $approvalFile -Force
    throw "Approval request timed out after $TimeoutMinutes minutes"
}

# Example: Approve vulnerability fix
function Fix-Vulnerability {
    param([hashtable]$Vulnerability)

    if ($Vulnerability.severity -in @("high", "critical")) {
        # Require approval for high/critical fixes
        $approval = Request-HumanApproval `
            -Message "Approve automatic fix for $($Vulnerability.type)?" `
            -Context $Vulnerability

        if (-not $approval.approved) {
            Write-Host "Fix rejected - manual review required"
            return
        }
    }

    # Apply fix
    Invoke-VsscFix -Vulnerability $Vulnerability
}
```

**When to Use:**
- Security-critical operations
- High-risk deployments
- Budget/resource approvals
- Compliance requirements

**Avoid When:**
- Fully automated workflows desired
- Approval latency unacceptable
- Decision can be automated with rules

---

## Code Examples

### Example 1: Complete DAG Workflow Engine

```powershell
# Define workflow as DAG
$workflow = @{
    Research = @{
        Agent = "webc"
        Payload = @{ command = "research"; topic = "GraphQL vs REST 2025" }
        DependsOn = @()
    }
    Synthesize = @{
        Agent = "dc"
        Payload = @{ command = "synthesize" }
        DependsOn = @("Research")
    }
    ImplementAPI = @{
        Agent = "vssc"
        Payload = @{ command = "implement"; component = "api" }
        DependsOn = @("Synthesize")
    }
    ImplementUI = @{
        Agent = "vssc"
        Payload = @{ command = "implement"; component = "ui" }
        DependsOn = @("Synthesize")
    }
    SecurityAudit = @{
        Agent = "kalic"
        Payload = @{ command = "audit" }
        DependsOn = @("ImplementAPI", "ImplementUI")
    }
    Deploy = @{
        Agent = "cmdc"
        Payload = @{ command = "deploy"; environment = "production" }
        DependsOn = @("SecurityAudit")
    }
}

# Execute workflow
function Execute-DAGWorkflow {
    param([hashtable]$Workflow)

    $completed = @()
    $running = @{}
    $results = @{}

    while ($completed.Count -lt $Workflow.Count) {
        # Find tasks ready to execute
        $ready = @()
        foreach ($task in $Workflow.Keys) {
            if ($task -in $completed -or $task -in $running.Keys) {
                continue
            }

            # Check dependencies
            $allDepsComplete = $true
            foreach ($dep in $Workflow[$task].DependsOn) {
                if ($dep -notin $completed) {
                    $allDepsComplete = $false
                    break
                }
            }

            if ($allDepsComplete) {
                $ready += $task
            }
        }

        # Start ready tasks (parallel execution)
        foreach ($task in $ready) {
            Write-Host "Starting task: $task"

            # Inject dependencies' results into payload
            foreach ($dep in $Workflow[$task].DependsOn) {
                $Workflow[$task].Payload["${dep}_result"] = $results[$dep]
            }

            $msgId = Send-Command -To $Workflow[$task].Agent -Payload $Workflow[$task].Payload
            $running[$task] = @{
                MessageId = $msgId
                Agent = $Workflow[$task].Agent
                StartTime = Get-Date
            }
        }

        # Check for completed tasks
        foreach ($task in $running.Keys) {
            $job = $running[$task]
            $responseFile = "C:\PhiVector\ipc\$($job.Agent)\outbox\resp-$($job.MessageId).json"

            if (Test-Path $responseFile) {
                $response = Get-Content $responseFile | ConvertFrom-Json
                $results[$task] = $response.payload
                $completed += $task
                $running.Remove($task)

                Write-Host "Completed task: $task"
                break
            }

            # Timeout check (10 minutes per task)
            if ((Get-Date) - $job.StartTime -gt [TimeSpan]::FromMinutes(10)) {
                throw "Task $task timed out"
            }
        }

        Start-Sleep -Milliseconds 500
    }

    return $results
}

# Run workflow
$workflowResults = Execute-DAGWorkflow -Workflow $workflow
```

---

### Example 2: Research → Build → Audit → Deploy Pipeline

```powershell
function Invoke-FeatureDeploymentPipeline {
    param(
        [string]$FeatureName,
        [string]$ResearchTopic
    )

    $context = New-WorkflowContext -InitiatedBy "STRYK"
    Write-Host "Starting deployment pipeline for: $FeatureName"

    # Stage 1: Research (WEBC)
    Write-Host "[1/5] Research phase..."
    $researchResult = Invoke-WithRetry -Task {
        Send-Command -To "webc" -Payload @{
            command = "research"
            topic = $ResearchTopic
            depth = "comprehensive"
        } -TimeoutSeconds 300
    }

    # Stage 2: Synthesize requirements (DC)
    Write-Host "[2/5] Synthesizing requirements..."
    $requirements = Synthesize-Requirements -ResearchData $researchResult

    # Stage 3: Implement (VSSC)
    Write-Host "[3/5] Implementation phase..."
    $buildResult = Invoke-WithRetry -Task {
        Send-Command -To "vssc" -Payload @{
            command = "implement"
            featureName = $FeatureName
            requirements = $requirements
        } -TimeoutSeconds 600
    }

    # Stage 4: Security audit (KALIC)
    Write-Host "[4/5] Security audit..."
    $auditResult = Send-Command -To "kalic" -Payload @{
        command = "security_audit"
        targetFiles = $buildResult.files
        scope = @("injection", "authentication", "authorization", "session", "crypto")
    } -TimeoutSeconds 300

    # Decision point: Approve if vulnerabilities found
    if ($auditResult.vulnerabilitiesFound -gt 0) {
        Write-Host "Security vulnerabilities found - requesting approval"

        $approval = Request-HumanApproval `
            -Message "Deploy $FeatureName with $($auditResult.vulnerabilitiesFound) vulnerabilities?" `
            -Context @{
                feature = $FeatureName
                vulnerabilities = $auditResult.vulnerabilities
                severity = $auditResult.maxSeverity
            }

        if (-not $approval.approved) {
            throw "Deployment cancelled - security issues must be resolved"
        }
    }

    # Stage 5: Deploy (CMDC)
    Write-Host "[5/5] Deployment phase..."
    $deployResult = Send-Command -To "cmdc" -Payload @{
        command = "deploy"
        artifact = $buildResult.artifactPath
        environment = "production"
        rollbackOnError = $true
    } -TimeoutSeconds 180

    Write-Host "Pipeline complete - $FeatureName deployed successfully"
    return @{
        feature = $FeatureName
        deploymentId = $deployResult.deploymentId
        duration = (Get-Date) - $context.startTime
    }
}
```

---

## Decision Matrices

### Workflow Pattern Selection

| Scenario | Pattern | Parallelization | Complexity | Fault Tolerance |
|----------|---------|----------------|------------|-----------------|
| Each task needs previous output | Sequential Pipeline | None | Low | Low (fails fast) |
| Independent tasks, aggregate results | Fan-Out/Fan-In | High | Medium | High (partial success) |
| Large dataset processing | Scatter-Gather | High | Medium | Medium |
| Conditional logic required | Branching | Low | Medium | Medium |
| Transient failures expected | Retry with Backoff | None | Low | High |
| Need rollback capability | Saga | Low | High | Very High |
| Human approval needed | Approval Gate | None | Medium | High |

### Orchestration vs Choreography

| Factor | Orchestration (DC-centric) | Choreography (Event-driven) |
|--------|----------------------------|------------------------------|
| Control | Centralized (DC coordinates) | Decentralized (agents react) |
| Coupling | Tight (DC knows all agents) | Loose (agents independent) |
| Debugging | Easy (single control flow) | Hard (emergent behavior) |
| Scalability | Limited (DC bottleneck) | High (no central bottleneck) |
| Use Case | Complex multi-step workflows | Simple event reactions |

**PhiVector Recommendation:** Orchestration (DC-centric) for clarity and debuggability

---

## Anti-Patterns

### ❌ Anti-Pattern 1: No Dependency Tracking

**Problem:**
```powershell
# BAD: Assumes tasks complete in launch order
Start-Task "ImplementAPI"
Start-Task "SecurityAudit"  # Starts before ImplementAPI finishes!
```

**Solution:**
```powershell
# GOOD: Explicit dependency tracking
$apiResult = Start-Task "ImplementAPI"
Wait-TaskComplete $apiResult
Start-Task "SecurityAudit" -DependsOn $apiResult
```

### ❌ Anti-Pattern 2: No Timeout on Blocking Operations

**Problem:**
```powershell
# BAD: Waits forever if task never completes
while ($running.Count -gt 0) {
    # Check for completed tasks...
}
```

**Solution:**
```powershell
# GOOD: Timeout for entire workflow
$deadline = (Get-Date).AddMinutes(30)
while ($running.Count -gt 0 -and (Get-Date) -lt $deadline) {
    # Check for completed tasks...
}

if ($running.Count -gt 0) {
    throw "Workflow timed out with $($running.Count) tasks still running"
}
```

### ❌ Anti-Pattern 3: Circular Dependencies

**Problem:**
```powershell
# BAD: Task A depends on Task B, Task B depends on Task A
$workflow = @{
    TaskA = @{ DependsOn = @("TaskB") }
    TaskB = @{ DependsOn = @("TaskA") }
}
```

**Solution:**
```powershell
# GOOD: Detect cycles before execution
$executionOrder = Resolve-Dependencies -TaskGraph $workflow
# Throws exception if cycle detected
```

### ❌ Anti-Pattern 4: No Error Context Propagation

**Problem:**
```powershell
# BAD: Task fails but no context for debugging
try {
    Execute-Task $task
}
catch {
    Write-Error "Task failed"  # Which task? What was the input?
}
```

**Solution:**
```powershell
# GOOD: Rich error context
try {
    Execute-Task $task
}
catch {
    $errorContext = @{
        taskName = $task.Name
        agent = $task.Agent
        payload = $task.Payload
        timestamp = Get-Date -Format "o"
        errorMessage = $_.Exception.Message
        stackTrace = $_.ScriptStackTrace
    }

    $errorContext | ConvertTo-Json | Out-File "C:\PhiVector\logs\task-errors\$($task.Name)-$(Get-Date -Format 'yyyyMMddHHmmss').json"
    throw
}
```

---

## Performance Considerations

### Critical Path Analysis

The **critical path** is the longest sequence of dependent tasks, determining minimum workflow duration.

**Example:**
```
Task A (5s) → Task B (10s) → Task D (5s) = 20s (critical path)
Task A (5s) → Task C (3s) → Task D (5s) = 13s
```
**Minimum workflow time: 20 seconds** (limited by critical path)

**Optimization Strategy:**
1. Identify critical path tasks
2. Optimize those tasks first (biggest impact)
3. Parallelize non-critical tasks (no impact on total time)

### Parallel Execution Limits

**Amdahl's Law:** Maximum speedup limited by sequential portion

```
Speedup = 1 / (S + (1 - S) / N)

Where:
  S = Sequential portion (0 to 1)
  N = Number of parallel workers
```

**Example:**
- 50% of workflow is parallelizable (S = 0.5)
- With 4 workers: Speedup = 1 / (0.5 + 0.5/4) = 1.6x
- With infinite workers: Max speedup = 2x

**Recommendation:** Diminishing returns beyond 4-6 parallel agents for typical PhiVector workflows

---

## Security Implications

### Workflow Tampering

**Threat:** Malicious actor modifies workflow definition to skip security audits

**Mitigation:**
```powershell
# Sign workflow definitions
$workflowHash = (Get-FileHash -Path "workflow.json" -Algorithm SHA256).Hash
$signature = Sign-Data -Data $workflowHash -Key $privateKey

# Verify before execution
if (-not (Verify-Signature -Data $workflowHash -Signature $signature -Key $publicKey)) {
    throw "Workflow signature invalid - possible tampering"
}
```

### Approval Bypass

**Threat:** Agent bypasses human approval gate

**Mitigation:**
```powershell
# Cryptographic proof of approval
function Request-HumanApproval {
    param([string]$Message)

    $approvalId = [guid]::NewGuid().ToString()
    # ... request approval ...

    # Approval includes signed token
    $approval = Wait-ForApproval $approvalId
    $approvalToken = $approval.token

    # Verify token was signed by STRYK's private key
    if (-not (Verify-ApprovalToken -Token $approvalToken -Signer "STRYK")) {
        throw "Invalid approval token"
    }

    return $approval
}
```

---

## Troubleshooting Guide

### Issue 1: Workflow Deadlock

**Symptoms:**
- Workflow hangs with no tasks completing
- All agents waiting for dependencies

**Diagnostics:**
```powershell
# Check for circular dependencies
$executionOrder = Resolve-Dependencies -TaskGraph $workflow
# If this throws, circular dependency exists

# Visualize dependencies
Export-WorkflowGraph -Workflow $workflow -OutputPath "C:\temp\workflow.dot"
# Use Graphviz to render DAG
```

**Solution:** Remove circular dependencies

### Issue 2: Task Timeout

**Symptoms:**
- Task exceeds timeout limit
- Workflow aborts prematurely

**Diagnostics:**
```powershell
# Profile task execution time
Measure-Command { Execute-Task $task }

# Check agent responsiveness
Test-AgentHealth -Agent "vssc"
```

**Solution:** Increase timeout for long-running tasks or optimize task

---

## PhiVector Workflow Templates

### Template 1: Research → Implement → Audit → Deploy

```powershell
$researchBuildAuditDeploy = @{
    Research = @{
        Agent = "webc"
        Payload = @{ command = "research"; topic = $topic }
        DependsOn = @()
    }
    Implement = @{
        Agent = "vssc"
        Payload = @{ command = "implement" }
        DependsOn = @("Research")
    }
    Audit = @{
        Agent = "kalic"
        Payload = @{ command = "audit" }
        DependsOn = @("Implement")
    }
    Approve = @{
        Agent = "stryk"
        Payload = @{ command = "approve" }
        DependsOn = @("Audit")
    }
    Deploy = @{
        Agent = "cmdc"
        Payload = @{ command = "deploy" }
        DependsOn = @("Approve")
    }
}
```

### Template 2: Parallel Research with Synthesis

```powershell
$parallelResearch = @{
    ResearchAPI = @{
        Agent = "webc"
        Payload = @{ command = "research"; topic = "API design" }
        DependsOn = @()
    }
    ResearchSecurity = @{
        Agent = "webc"
        Payload = @{ command = "research"; topic = "API security" }
        DependsOn = @()
    }
    ResearchPerformance = @{
        Agent = "webc"
        Payload = @{ command = "research"; topic = "API performance" }
        DependsOn = @()
    }
    Synthesize = @{
        Agent = "dc"
        Payload = @{ command = "synthesize" }
        DependsOn = @("ResearchAPI", "ResearchSecurity", "ResearchPerformance")
    }
}
```

### Template 3: Vulnerability Fix with Regression Test

```powershell
$vulnerabilityFix = @{
    IdentifyVuln = @{
        Agent = "kalic"
        Payload = @{ command = "scan"; target = $target }
        DependsOn = @()
    }
    ImplementFix = @{
        Agent = "vssc"
        Payload = @{ command = "fix_vulnerability" }
        DependsOn = @("IdentifyVuln")
    }
    RegressionTest = @{
        Agent = "cmdc"
        Payload = @{ command = "run_tests"; suite = "regression" }
        DependsOn = @("ImplementFix")
    }
    VerifyFix = @{
        Agent = "kalic"
        Payload = @{ command = "verify_fix" }
        DependsOn = @("ImplementFix")
    }
    Deploy = @{
        Agent = "cmdc"
        Payload = @{ command = "deploy" }
        DependsOn = @("RegressionTest", "VerifyFix")
    }
}
```

---

## References

1. **Apache Airflow Documentation.** "DAG workflows." airflow.apache.org
2. **Temporal.io.** "Workflow patterns." temporal.io/workflows
3. **Prefect.** "Orchestration patterns." prefect.io/patterns
4. **Microsoft Azure.** "Orchestration vs choreography." docs.microsoft.com/azure/architecture/patterns/
5. **AWS Step Functions.** "State machines." aws.amazon.com/step-functions/
6. **Netflix Tech Blog.** "Orchestration at scale." netflixtechblog.com
7. **Martin Fowler.** "Patterns of Enterprise Application Architecture."

---

**End of Workflow Orchestration Patterns Guide**

**Next Steps:**
- Review [State Synchronization Guide](../03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md)
- See [Agent Communication Protocols](../01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md)
- Consult [PhiSync Framework Overview](../README.md)
