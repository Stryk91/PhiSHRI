# PhiSync: Multi-Agent Coordination Codex
## The Definitive Guide to AI Agent Orchestration & State Synchronization

**Version:** 1.0.0 (Core Coordination - Part 1 of 3)
**Last Updated:** 2025-11-15
**Status:** Production Ready

---

## Executive Summary

**PhiSync** is the comprehensive knowledge base for multi-agent coordination, specifically optimized for **PhiVector AI Infrastructure** (DC, VSSC, KALIC, WEBC, CMDC). This codex compiles proven patterns from distributed systems research, production microservices architectures, and workflow orchestration platforms into actionable, copy-paste-ready implementations.

### What You'll Find Here

**Three Core Domains** (v1.0 - Core Coordination):
1. **Agent Communication Protocols** - File-based IPC, message patterns, pub/sub, request/response
2. **Workflow Orchestration Patterns** - DAG execution, parallel tasks, pipelines, human-in-the-loop
3. **State Synchronization & Management** - Consistency models, CRDTs, vector clocks, locking

**Coming in v2.0** (Error Recovery & Resilience):
- Error Handling & Recovery
- Role-Based Agent Architectures
- Resource Contention & Scheduling

**Coming in v3.0** (Testing & Operations):
- Multi-Agent Testing & Validation
- Real-World Coordination Patterns
- Agent Lifecycle Management
- Human-in-the-Loop Integration

### Why PhiSync Exists

**The Problem:**
- No unified guide for AI agent coordination
- Distributed systems research is academic and inaccessible
- Workflow orchestration tools (Airflow, Temporal) assume network communication
- **PhiVector agents must coordinate via file system only**

**The Solution:**
PhiSync translates distributed systems theory into practical, **file-based IPC patterns** that work within PhiVector's constraints:
- ✅ No direct process communication
- ✅ No blocking/sleeping (agents poll)
- ✅ Windows-first (PowerShell primary)
- ✅ File system as message bus
- ✅ MCP tools for local operations

---

## Quick Start

### 1. Understand Your Architecture

PhiVector operates as a **hub-and-spoke** model:

```
                    ┌─────────────────────────────────┐
                    │         DC (Orchestrator)       │
                    │  - Coordinates workflows        │
                    │  - Delegates to specialists     │
                    │  - Aggregates results           │
                    └─────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │  WEBC   │         │  VSSC   │         │  KALIC  │
    │Research │         │ Build   │         │ Audit   │
    │Specialist│        │Specialist│        │Specialist│
    └─────────┘         └─────────┘         └─────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                         ┌────▼────┐
                         │  CMDC   │
                         │Terminal │
                         │Automation│
                         └─────────┘
```

**Communication:**
- All agents communicate via **files** in `C:\PhiVector\ipc\`
- DC sends commands to agent inboxes
- Agents write responses to outboxes
- Shared state stored in `C:\PhiVector\ipc\shared\state\`

### 2. Set Up IPC Directory Structure

Run this PowerShell script to create the coordination infrastructure:

```powershell
# Create PhiVector IPC directory structure
$ipcRoot = "C:\PhiVector\ipc"

$agents = @("dc", "vssc", "kalic", "webc", "cmdc")
$directories = @("inbox", "outbox", "inbox\processed")

foreach ($agent in $agents) {
    foreach ($dir in $directories) {
        $path = Join-Path $ipcRoot "$agent\$dir"
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }

    # Create agent state file
    $stateFile = Join-Path $ipcRoot "$agent\state.json"
    @{
        agent = $agent
        status = "initialized"
        lastUpdate = Get-Date -Format "o"
    } | ConvertTo-Json | Out-File $stateFile -Encoding UTF8
}

# Create shared directories
$sharedDirs = @("events", "state", "locks", "state\snapshots")
foreach ($dir in $sharedDirs) {
    New-Item -Path (Join-Path $ipcRoot "shared\$dir") -ItemType Directory -Force | Out-Null
}

# Create dead letter queue
New-Item -Path (Join-Path $ipcRoot "dlq\archive") -ItemType Directory -Force | Out-Null

Write-Host "PhiSync IPC infrastructure created at: $ipcRoot"
```

### 3. Choose Your Starting Point

**New to multi-agent coordination?**
→ Start with [Agent Communication Protocols](01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md)
- Learn message passing basics
- Implement request/response pattern
- Set up pub/sub for events

**Building complex workflows?**
→ Jump to [Workflow Orchestration Patterns](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md)
- Design DAG workflows
- Implement parallel execution
- Add human approval gates

**Dealing with state conflicts?**
→ Read [State Synchronization & Management](03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md)
- Understand consistency models
- Implement CRDTs
- Use optimistic locking

### 4. Copy-Paste Your First Workflow

**Scenario:** DC delegates research to WEBC, waits for response

```powershell
# DC: Send research request to WEBC
function Request-Research {
    param([string]$Topic)

    $requestId = [guid]::NewGuid().ToString()
    $request = @{
        id = $requestId
        timestamp = Get-Date -Format "o"
        from = "dc"
        to = "webc"
        type = "request"
        payload = @{
            command = "research"
            topic = $Topic
            depth = "comprehensive"
        }
    } | ConvertTo-Json -Depth 10

    # Write to WEBC's inbox
    $inboxPath = "C:\PhiVector\ipc\webc\inbox\req-$requestId.json"
    $request | Out-File -FilePath $inboxPath -Encoding UTF8

    Write-Host "Research request sent: $requestId"

    # Wait for response (poll WEBC's outbox)
    $deadline = (Get-Date).AddMinutes(10)
    while ((Get-Date) -lt $deadline) {
        $responseFile = "C:\PhiVector\ipc\webc\outbox\resp-$requestId.json"

        if (Test-Path $responseFile) {
            $response = Get-Content $responseFile | ConvertFrom-Json
            Remove-Item $responseFile -Force
            Write-Host "Research completed!"
            return $response.payload
        }

        Start-Sleep -Milliseconds 500  # Poll every 500ms
    }

    throw "Research request timed out after 10 minutes"
}

# Usage
$researchResults = Request-Research -Topic "OAuth2 best practices 2025"
Write-Host "Found $($researchResults.sources.Count) sources"
```

**Next:** Add error handling, implement retry logic, integrate with workflows
→ See [Agent Communication Protocols - Pattern Catalog](01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md#pattern-catalog)

---

## Architecture Principles

### 1. File System as Message Bus

**Why:** PhiVector agents cannot communicate directly (different processes, contexts, machines)

**How:**
- **Inboxes** = Agent-specific directories for incoming commands
- **Outboxes** = Agent-specific directories for responses
- **Shared state** = Common directory for coordinated state
- **Locks** = Temporary files to ensure exclusive access

**Example Directory:**
```
C:\PhiVector\ipc\
├── dc\
│   ├── inbox\          # DC receives commands here
│   │   ├── req-abc123.json
│   │   └── processed\  # Archived after processing
│   ├── outbox\         # DC sends responses here
│   │   └── resp-abc123.json
│   └── state.json      # DC's internal state
├── vssc\
│   ├── inbox\
│   ├── outbox\
│   └── state.json
├── shared\
│   ├── events\         # Broadcast events (pub/sub)
│   ├── state\          # Shared workflow state
│   └── locks\          # File-based mutexes
└── dlq\                # Dead letter queue (failed messages)
```

### 2. Polling Instead of Blocking

**Constraint:** DC cannot use `Thread.Sleep` or blocking waits in many contexts

**Solution:** Exponential backoff polling

```powershell
# Poll inbox with exponential backoff
$delay = 100  # Start with 100ms
$maxDelay = 5000  # Cap at 5 seconds

while ($true) {
    $messages = Get-ChildItem "$inboxPath\*.json" -ErrorAction SilentlyContinue

    if ($messages) {
        return $messages  # Messages found!
    }

    Start-Sleep -Milliseconds $delay
    $delay = [Math]::Min($delay * 2, $maxDelay)  # Double delay, cap at max
}
```

**Benefits:**
- Low latency when messages arrive quickly (starts at 100ms)
- Low CPU usage when idle (backs off to 5s)
- Simple to implement

### 3. Eventual Consistency with Strong Convergence

**Reality:** File system operations are not atomic across multiple files

**Strategy:**
- **Within single file:** Use atomic write (write to temp, rename)
- **Across files:** Use eventual consistency (accept temporary divergence)
- **When strong consistency needed:** File-based locking

**Example: Atomic Single-File Update**
```powershell
# Read-modify-write with atomic commit
$state = Get-Content "state.json" | ConvertFrom-Json -AsHashtable
$state.counter++

# Write to temp file, then atomic rename
$tempFile = "state.json.tmp"
$state | ConvertTo-Json | Out-File $tempFile -Encoding UTF8
Move-Item $tempFile "state.json" -Force  # Atomic rename
```

### 4. Idempotency by Default

**Principle:** Operations should be safe to retry

**Implementation:**
- Include unique message IDs
- Track processed message IDs
- Deduplicate based on ID

```powershell
# Idempotent message processing
$processedIds = Get-Content "processed-ids.txt" -ErrorAction SilentlyContinue

foreach ($messageFile in Get-ChildItem "$inboxPath\*.json") {
    $message = Get-Content $messageFile.FullName | ConvertFrom-Json

    if ($message.id -in $processedIds) {
        # Already processed - skip
        Remove-Item $messageFile.FullName -Force
        continue
    }

    # Process message
    Process-Message $message

    # Mark as processed
    $message.id | Add-Content "processed-ids.txt"
    Remove-Item $messageFile.FullName -Force
}
```

---

## Common Workflows

### Workflow 1: Research → Build → Audit → Deploy

**Participants:** WEBC, DC, VSSC, KALIC, CMDC

**Flow:**
```
1. DC → WEBC: Research request (OAuth2 best practices)
2. WEBC → DC: Research results (synthesized findings)
3. DC → VSSC: Build request (implement OAuth2 module)
4. VSSC → DC: Build complete (artifact path)
5. DC → KALIC: Security audit request
6. KALIC → DC: Audit results (vulnerabilities found: 0)
7. DC → STRYK: Approval request (if vulnerabilities > 0)
8. STRYK → DC: Approval granted
9. DC → CMDC: Deploy request (production environment)
10. CMDC → DC: Deployment complete
```

**Implementation:**
→ See [Workflow Orchestration - Code Examples](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#code-examples)

### Workflow 2: Parallel Data Processing (Scatter-Gather)

**Participants:** DC, CMDC (multiple workers)

**Flow:**
```
1. DC partitions large dataset into N chunks
2. DC → CMDC (worker 1): Process chunk 1
   DC → CMDC (worker 2): Process chunk 2
   DC → CMDC (worker 3): Process chunk 3
   (parallel execution)
3. CMDC workers → DC: Partial results
4. DC merges results
```

**Use Case:** Analyzing 10,000 log entries, scanning 1,000 files, processing batch data

**Implementation:**
→ See [Workflow Orchestration - Scatter-Gather Pattern](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#pattern-3-scatter-gather-data-partitioning)

### Workflow 3: Vulnerability Fix with Approval

**Participants:** KALIC, DC, STRYK, VSSC, CMDC

**Flow:**
```
1. KALIC scans codebase → finds high-severity vulnerability
2. KALIC → DC: Vulnerability alert (broadcast event)
3. DC → STRYK: Approval request (auto-fix vulnerability?)
4. STRYK → DC: Approval granted
5. DC → VSSC: Implement fix
6. VSSC → DC: Fix complete
7. DC → CMDC: Run regression tests
8. CMDC → DC: Tests passed
9. DC → KALIC: Verify fix
10. KALIC → DC: Vulnerability resolved
11. DC → CMDC: Deploy to production
```

**Implementation:**
→ See [Workflow Orchestration - Template 3](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#template-3-vulnerability-fix-with-regression-test)

---

## Integration with PhiVector Entities

### DC (Desktop Claude) - The Orchestrator

**Role:** Coordinate workflows, delegate to specialists, aggregate results

**Communication Patterns:**
- Request/Response: Send tasks to specialists, wait for results
- State Files: Track workflow progress
- Approval Gates: Request STRYK decisions

**Limitations:**
- Cannot do deep research (delegate to WEBC)
- Cannot write complex code (delegate to VSSC)
- Cannot perform security audits (delegate to KALIC)

**Example:**
```powershell
# DC orchestrates feature implementation
function Implement-Feature {
    param([string]$FeatureName)

    # Step 1: Research (delegate to WEBC)
    $research = Send-Command -To "webc" -Payload @{
        command = "research"
        topic = "$FeatureName best practices"
    }

    # Step 2: Synthesize requirements (DC's role)
    $requirements = Synthesize-Requirements -ResearchData $research

    # Step 3: Implement (delegate to VSSC)
    $build = Send-Command -To "vssc" -Payload @{
        command = "implement"
        requirements = $requirements
    }

    # Step 4: Audit (delegate to KALIC)
    $audit = Send-Command -To "kalic" -Payload @{
        command = "audit"
        target = $build.artifactPath
    }

    # Step 5: Approve (human-in-the-loop)
    if ($audit.vulnerabilitiesFound -gt 0) {
        Request-HumanApproval -Context $audit
    }

    # Step 6: Deploy (delegate to CMDC)
    Send-Command -To "cmdc" -Payload @{
        command = "deploy"
        artifact = $build.artifactPath
    }
}
```

### VSSC (VSCode Claude) - The Builder

**Role:** Implement features, fix bugs, build tools

**Communication Patterns:**
- Worker: Receives build requests from DC
- Response: Returns artifact paths, build logs

**Example Inbox Message:**
```json
{
  "id": "build-001",
  "from": "dc",
  "to": "vssc",
  "payload": {
    "command": "build_tool",
    "toolName": "log_analyzer",
    "requirements": {
      "inputs": ["log_file_path"],
      "outputs": ["error_count", "warnings"],
      "language": "PowerShell"
    }
  }
}
```

### KALIC (Kali Claude) - The Auditor

**Role:** Security scanning, vulnerability detection, penetration testing

**Communication Patterns:**
- Publisher: Broadcasts vulnerability alerts
- Worker: On-demand security audits

**Example Event Publication:**
```json
{
  "eventType": "vulnerability_found",
  "publisher": "kalic",
  "severity": "high",
  "data": {
    "type": "SQL_INJECTION",
    "file": "user_query.ps1",
    "line": 42,
    "remediation": "Use parameterized queries"
  }
}
```

### WEBC (Web Claude) - The Researcher

**Role:** Parallel web research, knowledge compilation

**Communication Patterns:**
- Worker: Receives research requests
- Long-running: May take minutes for comprehensive research

**Example:**
```powershell
# WEBC processes research request
$request = Get-Content "C:\PhiVector\ipc\webc\inbox\req-123.json" | ConvertFrom-Json

# Execute parallel searches (WEBC's specialty)
$results = Invoke-ParallelWebSearch -Queries $request.payload.queries

# Synthesize findings
$synthesis = Synthesize-ResearchResults -Results $results

# Return to DC
$response = @{
    id = [guid]::NewGuid().ToString()
    correlationId = $request.id
    payload = $synthesis
} | ConvertTo-Json -Depth 10

$response | Out-File "C:\PhiVector\ipc\webc\outbox\resp-$($request.id).json"
```

### CMDC (Claude Code) - The Executor

**Role:** Terminal automation, MCP tool execution, deployment

**Communication Patterns:**
- Worker: Executes commands, returns output
- Fire-and-forget: Non-critical logging, monitoring

**Example:**
```powershell
# CMDC executes deployment command
$request = Get-Content "C:\PhiVector\ipc\cmdc\inbox\req-456.json" | ConvertFrom-Json

# Execute deployment script
$output = & $request.payload.script

# Return result
@{
    id = [guid]::NewGuid().ToString()
    correlationId = $request.id
    payload = @{
        exitCode = $LASTEXITCODE
        stdout = $output
    }
} | ConvertTo-Json | Out-File "C:\PhiVector\ipc\cmdc\outbox\resp-$($request.id).json"
```

---

## Navigation Guide

### By Experience Level

**Beginner** (New to multi-agent systems)
1. Read [Agent Communication - Conceptual Overview](01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md#conceptual-overview)
2. Implement [Command Queue Pattern](01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md#pattern-1-command-queue-requestresponse)
3. Try [Quick Start Workflow](#4-copy-paste-your-first-workflow)

**Intermediate** (Building workflows)
1. Review [Workflow Orchestration - DAG Fundamentals](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#dag-workflow-fundamentals)
2. Implement [Parallel Fan-Out Pattern](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#pattern-2-parallel-fan-out--fan-in)
3. Add [Human Approval Gates](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#pattern-7-human-in-the-loop-approval)

**Advanced** (Dealing with state conflicts)
1. Study [Consistency Models](03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md#consistency-models)
2. Implement [CRDTs](03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md#crdt-conflict-free-replicated-data-types)
3. Design [Event Sourcing](03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md#pattern-4-event-sourcing)

### By Problem

**"Messages not being received"**
→ [Agent Communication - Troubleshooting Guide](01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md#troubleshooting-guide)

**"Workflow deadlocked"**
→ [Workflow Orchestration - Troubleshooting](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#troubleshooting-guide)

**"State conflicts/corruption"**
→ [State Synchronization - Troubleshooting](03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md#troubleshooting-guide)

**"Need approval workflow"**
→ [Workflow Orchestration - Human-in-the-Loop Pattern](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#pattern-7-human-in-the-loop-approval)

**"Handling failures"**
→ [Workflow Orchestration - Retry Pattern](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#pattern-5-retry-with-exponential-backoff)
→ [Workflow Orchestration - Saga Pattern](02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md#pattern-6-saga-pattern-compensating-transactions)

---

## Glossary

**Agent** - Autonomous AI entity (DC, VSSC, KALIC, WEBC, CMDC) that performs specialized tasks

**Coordination** - Process of managing dependencies and communication between agents

**Correlation ID** - Unique identifier linking related messages across workflow

**CRDT** - Conflict-Free Replicated Data Type; data structure that automatically resolves conflicts

**DAG** - Directed Acyclic Graph; workflow representation with tasks (nodes) and dependencies (edges)

**Dead Letter Queue (DLQ)** - Storage for messages that failed processing

**Eventual Consistency** - Guarantee that all agents eventually see same state (after synchronization period)

**Fan-Out/Fan-In** - Pattern where multiple tasks execute in parallel (fan-out) then merge results (fan-in)

**Idempotent** - Operation that produces same result when executed multiple times

**IPC** - Inter-Process Communication; how separate processes exchange data

**Orchestration** - Centralized coordination where one agent (DC) manages workflow

**Choreography** - Decentralized coordination where agents react to events independently

**State** - Data that changes over time and must be shared between agents

**Strong Consistency** - Guarantee that all agents see same data immediately

**Vector Clock** - Mechanism for tracking causality in distributed systems

**Workflow** - Multi-step process involving multiple agents

---

## Roadmap

### v1.0 - Core Coordination ✅ (Current Release)
- ✅ Agent Communication Protocols
- ✅ Workflow Orchestration Patterns
- ✅ State Synchronization & Management

### v2.0 - Error Recovery & Resilience (WEBC-2)
- ⏳ Error Handling & Recovery
- ⏳ Role-Based Agent Architectures
- ⏳ Resource Contention & Scheduling

### v3.0 - Testing & Operations (WEBC-3)
- ⏳ Multi-Agent Testing & Validation
- ⏳ Real-World Coordination Patterns
- ⏳ Agent Lifecycle Management
- ⏳ Human-in-the-Loop Integration (expanded)

---

## Contributing

PhiSync is maintained by the PhiVector team. To suggest improvements:

1. **Report issues** - Document bugs, unclear sections, or missing patterns
2. **Submit patterns** - Share working coordination patterns you've developed
3. **Request examples** - Identify workflows needing more code examples

**Contact:** Via PhiVector GitHub repository or STRYK directly

---

## License

PhiSync is part of the PhiVector AI Infrastructure project.

**Usage:**
- ✅ Use in PhiVector projects
- ✅ Adapt for your multi-agent systems
- ✅ Share with attribution

**Restrictions:**
- ❌ Claim as original work
- ❌ Remove attribution

---

## Acknowledgments

PhiSync synthesizes knowledge from:
- **Academic Research:** Actor model (Hewitt), CSP (Hoare), CRDTs (Shapiro), Vector Clocks (Lamport)
- **Industry Platforms:** Apache Airflow, Temporal.io, Prefect, Kubernetes
- **Architecture Patterns:** Microsoft Azure Architecture Center, AWS Well-Architected Framework
- **Production Systems:** Netflix (Chaos Engineering), Google (Borg, Chubby), Facebook (Apollo)

Special thanks to the distributed systems community for decades of research that makes multi-agent coordination possible.

---

**End of PhiSync Framework Overview**

**Next Steps:**
1. Set up [IPC directory structure](#2-set-up-ipc-directory-structure)
2. Read [Agent Communication Protocols](01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md)
3. Implement your first workflow using [Quick Start](#4-copy-paste-your-first-workflow)

**Questions?** Consult the [troubleshooting guides](#by-problem) or contact PhiVector team.

---

**PhiSync v1.0 - Core Coordination**
*Empowering autonomous AI collaboration through proven distributed systems patterns*
