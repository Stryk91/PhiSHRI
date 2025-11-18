# Agent Communication Protocols
## PhiSync Multi-Agent Coordination Codex - Domain 1

**Version:** 1.0.0
**Last Updated:** 2025-11-15
**Target:** PhiVector AI Infrastructure (DC, VSSC, KALIC, WEBC, CMDC)

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Conceptual Overview](#conceptual-overview)
3. [PhiVector Communication Architecture](#phivector-communication-architecture)
4. [Pattern Catalog](#pattern-catalog)
5. [Code Examples](#code-examples)
6. [Decision Matrices](#decision-matrices)
7. [Anti-Patterns](#anti-patterns)
8. [Performance Considerations](#performance-considerations)
9. [Security Implications](#security-implications)
10. [Troubleshooting Guide](#troubleshooting-guide)
11. [PhiVector-Specific Applications](#phivector-specific-applications)
12. [References](#references)

---

## Executive Summary

Agent communication is the backbone of multi-agent coordination. In distributed systems, agents must exchange messages, synchronize state, and coordinate actions without blocking or creating bottlenecks.

### Key Takeaways
- **File-based IPC is mandatory** for PhiVector (agents cannot communicate directly)
- **Asynchronous messaging** prevents blocking and enables scalability
- **Message serialization** (JSON, MessagePack) balances human-readability and performance
- **Dead letter queues** ensure no message is lost during failures
- **Protocol selection** impacts latency, throughput, and complexity

### When to Use This Guide
- Designing communication between DC, VSSC, KALIC, WEBC, or CMDC
- Implementing request/response or pub/sub patterns
- Troubleshooting message delivery failures
- Optimizing inter-agent latency or throughput

### Quick Decision Tree
```
Need real-time coordination?
├─ Yes → Use command queue pattern with file polling
└─ No → Use state file synchronization pattern

Need response from specific agent?
├─ Yes → Request/response with correlation IDs
└─ No → Fire-and-forget broadcast pattern

Multiple agents need same message?
├─ Yes → Publish/subscribe via shared state files
└─ No → Direct message queue (unicast)
```

---

## Conceptual Overview

### Message Passing Fundamentals

**Actor Model:** Each agent is an autonomous actor with:
- **Private state** (no shared memory)
- **Mailbox** (incoming message queue)
- **Behaviors** (how to process messages)
- **Ability to create** other actors and send messages

**CSP (Communicating Sequential Processes):** Process-based model where:
- Communication happens through **channels** (not direct messaging)
- Channels can be **synchronous** (blocking) or **buffered** (async)
- Inspired Go's goroutines and Clojure's core.async

**PhiVector Adaptation:** File system as message bus
- **Agents** = DC, VSSC, KALIC, WEBC, CMDC processes
- **Mailboxes** = Agent-specific directories with numbered message files
- **Channels** = Shared state files or command queues
- **No blocking** = Agents poll for new messages (cannot sleep)

### Communication Patterns

#### 1. Request/Response
**Use Case:** DC asks VSSC to build a tool and needs confirmation
**Mechanism:**
- DC writes request to `vssc/inbox/req-{uuid}.json`
- VSSC processes and writes `vssc/outbox/resp-{uuid}.json`
- DC polls outbox for matching correlation ID

**Advantages:**
- Clear causality (request → response)
- Timeout handling (if no response in N seconds)
- Easy to debug (correlate requests to responses)

**Disadvantages:**
- Introduces coupling (requester must wait)
- Potential for orphaned requests (responder crashes)

#### 2. Publish/Subscribe
**Use Case:** KALIC broadcasts vulnerability findings to all interested agents
**Mechanism:**
- KALIC writes to `shared/events/vuln-{timestamp}.json`
- DC, VSSC poll `shared/events/` for new files
- Each agent processes independently

**Advantages:**
- Loose coupling (publisher doesn't know subscribers)
- Scalable (add subscribers without changing publisher)
- Event-driven architecture

**Disadvantages:**
- No delivery guarantees (subscriber may miss events)
- Requires cleanup strategy (old events pile up)
- Harder to trace message flow

#### 3. Fire-and-Forget
**Use Case:** DC logs diagnostic info without needing confirmation
**Mechanism:**
- DC writes to `logs/dc-{timestamp}.log`
- No response expected or waited for

**Advantages:**
- Minimal latency (no waiting)
- Simple implementation
- Non-blocking

**Disadvantages:**
- No failure detection
- Cannot confirm processing
- Risk of silent failures

#### 4. Dead Letter Queue
**Use Case:** Message processing fails, need to retry later
**Mechanism:**
- Agent attempts to process `inbox/msg-123.json`
- Processing fails → move to `inbox/dlq/msg-123.json`
- Separate process retries DLQ messages with backoff

**Advantages:**
- Prevents message loss
- Enables debugging (inspect failed messages)
- Supports retry strategies

**Disadvantages:**
- Requires additional monitoring
- DLQ can grow unbounded without cleanup
- Retry logic adds complexity

---

## PhiVector Communication Architecture

### Constraints
1. **No direct process communication** (agents run in separate contexts)
2. **No blocking operations** (DC cannot use `Thread.Sleep` in many contexts)
3. **File system is the bus** (all IPC via files)
4. **Windows-first** (PowerShell scripting, Windows file locks)
5. **MCP tools** for file operations (CMDC primary executor)

### Directory Structure
```
C:\PhiVector\ipc\
├── dc\
│   ├── inbox\          # Incoming commands for DC
│   ├── outbox\         # DC responses/results
│   └── state.json      # DC's current state
├── vssc\
│   ├── inbox\
│   ├── outbox\
│   └── state.json
├── kalic\
│   ├── inbox\
│   ├── outbox\
│   └── state.json
├── webc\
│   ├── inbox\
│   ├── outbox\
│   └── state.json
├── cmdc\
│   ├── inbox\
│   ├── outbox\
│   └── state.json
├── shared\
│   ├── events\         # Broadcast events (pub/sub)
│   ├── state\          # Shared state files
│   └── locks\          # File-based mutexes
└── dlq\                # Dead letter queue (failed messages)
```

### Message Format (JSON)
```json
{
  "id": "uuid-v4",
  "timestamp": "2025-11-15T10:30:00Z",
  "from": "dc",
  "to": "vssc",
  "type": "request",
  "correlationId": "parent-uuid",
  "payload": {
    "command": "build_tool",
    "parameters": {
      "toolName": "vulnerability_scanner",
      "language": "PowerShell"
    }
  },
  "metadata": {
    "priority": "high",
    "timeout": 300,
    "retryCount": 0
  }
}
```

### Polling Strategy
Since agents cannot block/sleep, use polling with exponential backoff:

**PowerShell Example:**
```powershell
function Poll-Inbox {
    param(
        [string]$InboxPath,
        [int]$MaxPolls = 60,
        [int]$InitialDelayMs = 100
    )

    $delay = $InitialDelayMs
    for ($i = 0; $i -lt $MaxPolls; $i++) {
        $messages = Get-ChildItem "$InboxPath\*.json" -ErrorAction SilentlyContinue

        if ($messages) {
            return $messages
        }

        # Exponential backoff: 100ms, 200ms, 400ms, 800ms, max 5s
        Start-Sleep -Milliseconds $delay
        $delay = [Math]::Min($delay * 2, 5000)
    }

    return $null  # Timeout
}
```

**Key Points:**
- Start with short delay (100ms) for responsiveness
- Double delay each iteration (exponential backoff)
- Cap at max delay (5s) to prevent infinite waits
- Return after max polls to prevent indefinite blocking

---

## Pattern Catalog

### Pattern 1: Command Queue (Request/Response)

**Intent:** Agent A sends command to Agent B and waits for response

**Structure:**
```
DC (Orchestrator)              VSSC (Worker)
    |                              |
    |---(1) Write command.json---->|
    |     to vssc/inbox            |
    |                              |
    |     (2) Poll vssc/outbox ----|
    |     for response             |
    |                              |
    |<--(3) Read response.json-----|
    |     from vssc/outbox         |
```

**Implementation:**
```powershell
# DC: Send command to VSSC
function Send-Command {
    param(
        [string]$To,
        [hashtable]$Payload,
        [int]$TimeoutSeconds = 60
    )

    $id = [guid]::NewGuid().ToString()
    $message = @{
        id = $id
        timestamp = Get-Date -Format "o"
        from = "dc"
        to = $To
        type = "request"
        payload = $Payload
    } | ConvertTo-Json -Depth 10

    # Write to target inbox
    $inboxPath = "C:\PhiVector\ipc\$To\inbox\req-$id.json"
    $message | Out-File -FilePath $inboxPath -Encoding UTF8

    # Poll for response
    $outboxPath = "C:\PhiVector\ipc\$To\outbox"
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        $response = Get-Content "$outboxPath\resp-$id.json" -ErrorAction SilentlyContinue
        if ($response) {
            Remove-Item "$outboxPath\resp-$id.json" -Force
            return ($response | ConvertFrom-Json)
        }
        Start-Sleep -Milliseconds 500
    }

    throw "Timeout waiting for response from $To"
}

# VSSC: Process commands
function Process-Inbox {
    param([string]$InboxPath)

    Get-ChildItem "$InboxPath\req-*.json" | ForEach-Object {
        $request = Get-Content $_.FullName | ConvertFrom-Json

        try {
            # Execute command
            $result = Invoke-Command -Request $request

            # Write response
            $response = @{
                id = [guid]::NewGuid().ToString()
                timestamp = Get-Date -Format "o"
                correlationId = $request.id
                type = "response"
                success = $true
                payload = $result
            } | ConvertTo-Json -Depth 10

            $outboxPath = "C:\PhiVector\ipc\vssc\outbox\resp-$($request.id).json"
            $response | Out-File -FilePath $outboxPath -Encoding UTF8

            # Archive processed request
            Move-Item $_.FullName -Destination "C:\PhiVector\ipc\vssc\inbox\processed\$($_.Name)"
        }
        catch {
            # Error handling - move to DLQ
            Move-Item $_.FullName -Destination "C:\PhiVector\ipc\dlq\$($_.Name)"
            Write-Error "Failed to process request $($request.id): $_"
        }
    }
}
```

**When to Use:**
- Need confirmation of task completion
- Require return value from worker
- Want timeout/retry logic

**Avoid When:**
- High throughput needed (blocking reduces throughput)
- No response needed (use fire-and-forget)

---

### Pattern 2: Broadcast Events (Pub/Sub)

**Intent:** Agent publishes event that multiple subscribers can consume

**Structure:**
```
KALIC (Publisher)                  Subscribers
    |                              DC  VSSC  WEBC
    |                              |    |     |
    |---(1) Write event.json------>|----+-----|
    |     to shared/events         |    |     |
    |                              |    |     |
    |     (2) Each subscriber      |    |     |
    |     polls and processes      |    |     |
```

**Implementation:**
```powershell
# KALIC: Publish event
function Publish-Event {
    param(
        [string]$EventType,
        [hashtable]$Data
    )

    $event = @{
        id = [guid]::NewGuid().ToString()
        timestamp = Get-Date -Format "o"
        publisher = "kalic"
        eventType = $EventType
        data = $Data
    } | ConvertTo-Json -Depth 10

    $eventFile = "C:\PhiVector\ipc\shared\events\$EventType-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $event | Out-File -FilePath $eventFile -Encoding UTF8
}

# DC: Subscribe and process events
function Subscribe-Events {
    param(
        [string[]]$EventTypes,
        [scriptblock]$Handler
    )

    $eventsPath = "C:\PhiVector\ipc\shared\events"
    $lastCheck = Get-Date

    while ($true) {
        $newEvents = Get-ChildItem $eventsPath -Filter "*.json" |
            Where-Object { $_.LastWriteTime -gt $lastCheck -and $EventTypes -contains ($_.BaseName -split '-')[0] }

        foreach ($eventFile in $newEvents) {
            $event = Get-Content $eventFile.FullName | ConvertFrom-Json
            & $Handler $event

            # Mark as processed by this subscriber
            $processedMarker = "$($eventFile.FullName).dc-processed"
            New-Item $processedMarker -ItemType File -Force | Out-Null
        }

        $lastCheck = Get-Date
        Start-Sleep -Milliseconds 1000
    }
}

# Usage
Subscribe-Events -EventTypes @("vulnerability_found", "scan_complete") -Handler {
    param($event)
    Write-Host "Received event: $($event.eventType) from $($event.publisher)"
    # Handle event...
}
```

**When to Use:**
- Multiple agents need same information
- Loose coupling desired (publisher doesn't know subscribers)
- Event-driven workflows

**Avoid When:**
- Need guaranteed delivery to specific agent (use request/response)
- Messages are large (file I/O overhead)

---

### Pattern 3: State File Synchronization

**Intent:** Agents share state via periodically updated files

**Structure:**
```
Agent A                           Agent B
    |                                 |
    |--(1) Update state.json--------->|
    |                                 |
    |<--(2) Poll and read state.json--|
    |                                 |
    |--(3) Update state.json--------->|
    |                                 |
```

**Implementation:**
```powershell
# Shared state structure
$sharedState = @{
    version = 1
    lastUpdate = Get-Date -Format "o"
    updatedBy = "dc"
    data = @{
        currentWorkflow = "vulnerability_scan"
        activeAgents = @("dc", "kalic", "vssc")
        approvalRequired = $false
    }
}

# Write state with atomic update
function Update-SharedState {
    param(
        [hashtable]$StateUpdates,
        [string]$Agent
    )

    $stateFile = "C:\PhiVector\ipc\shared\state\workflow-state.json"
    $lockFile = "C:\PhiVector\ipc\shared\locks\workflow-state.lock"

    # Acquire lock
    while (Test-Path $lockFile) {
        Start-Sleep -Milliseconds 50
    }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        # Read current state
        $current = @{}
        if (Test-Path $stateFile) {
            $current = Get-Content $stateFile | ConvertFrom-Json -AsHashtable
        }

        # Merge updates
        foreach ($key in $StateUpdates.Keys) {
            $current.data[$key] = $StateUpdates[$key]
        }

        $current.version++
        $current.lastUpdate = Get-Date -Format "o"
        $current.updatedBy = $Agent

        # Atomic write (write to temp, then rename)
        $tempFile = "$stateFile.tmp"
        $current | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
        Move-Item $tempFile $stateFile -Force
    }
    finally {
        # Release lock
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

# Read state
function Get-SharedState {
    $stateFile = "C:\PhiVector\ipc\shared\state\workflow-state.json"

    if (Test-Path $stateFile) {
        return Get-Content $stateFile | ConvertFrom-Json
    }

    return $null
}
```

**When to Use:**
- Shared state changes infrequently (not real-time)
- Multiple agents need consistent view
- Simple coordination needed

**Avoid When:**
- High-frequency updates (file I/O bottleneck)
- Need transactional updates (risk of race conditions)

---

### Pattern 4: Dead Letter Queue with Retry

**Intent:** Failed messages are preserved and retried with exponential backoff

**Structure:**
```
Agent Inbox                       Dead Letter Queue
    |                                    |
    |--(1) Process message fails-------->|
    |                                    |
    |<--(2) Retry handler moves back-----|
    |     message after delay            |
    |                                    |
    |--(3) Process succeeds or------>Archive
    |     max retries exceeded--------->|
```

**Implementation:**
```powershell
# Move to DLQ on failure
function Move-ToDLQ {
    param(
        [string]$MessagePath,
        [string]$ErrorMessage
    )

    $message = Get-Content $MessagePath | ConvertFrom-Json -AsHashtable
    $message.metadata.retryCount++
    $message.metadata.lastError = $ErrorMessage
    $message.metadata.dlqTimestamp = Get-Date -Format "o"

    $dlqPath = "C:\PhiVector\ipc\dlq\$(Split-Path $MessagePath -Leaf)"
    $message | ConvertTo-Json -Depth 10 | Out-File $dlqPath -Encoding UTF8

    Remove-Item $MessagePath -Force
}

# Retry handler (runs as separate process)
function Start-DLQRetryHandler {
    param(
        [int]$MaxRetries = 3,
        [int]$BaseDelaySeconds = 60
    )

    $dlqPath = "C:\PhiVector\ipc\dlq"

    while ($true) {
        Get-ChildItem "$dlqPath\*.json" | ForEach-Object {
            $message = Get-Content $_.FullName | ConvertFrom-Json -AsHashtable

            # Check if ready for retry (exponential backoff)
            $dlqTime = [DateTime]::Parse($message.metadata.dlqTimestamp)
            $retryCount = $message.metadata.retryCount
            $delaySeconds = $BaseDelaySeconds * [Math]::Pow(2, $retryCount - 1)

            if ((Get-Date) -gt $dlqTime.AddSeconds($delaySeconds)) {
                if ($retryCount -le $MaxRetries) {
                    # Move back to inbox for retry
                    $originalInbox = "C:\PhiVector\ipc\$($message.to)\inbox\$(Split-Path $_.FullName -Leaf)"
                    Move-Item $_.FullName $originalInbox -Force
                    Write-Host "Retrying message $($message.id) (attempt $retryCount)"
                }
                else {
                    # Max retries exceeded - archive
                    $archivePath = "C:\PhiVector\ipc\dlq\archive\$(Split-Path $_.FullName -Leaf)"
                    Move-Item $_.FullName $archivePath -Force
                    Write-Warning "Message $($message.id) exceeded max retries - archived"
                }
            }
        }

        Start-Sleep -Seconds 30  # Check DLQ every 30 seconds
    }
}
```

**When to Use:**
- Critical messages cannot be lost
- Transient failures expected (network, resource contention)
- Need audit trail of failures

**Avoid When:**
- Messages are time-sensitive (stale after delay)
- Failures are permanent (retrying won't help)

---

### Pattern 5: Correlation IDs for Tracing

**Intent:** Track message flow through multi-agent workflows

**Structure:**
```
STRYK Request
    └── correlationId: "workflow-123"
         |
         ├── DC → WEBC (correlationId: "workflow-123")
         │    └── WEBC → DC (correlationId: "workflow-123")
         |
         ├── DC → VSSC (correlationId: "workflow-123")
         │    └── VSSC → DC (correlationId: "workflow-123")
         |
         └── DC → KALIC (correlationId: "workflow-123")
              └── KALIC → DC (correlationId: "workflow-123")
```

**Implementation:**
```powershell
# Generate and propagate correlation IDs
function New-WorkflowContext {
    param([string]$InitiatedBy)

    return @{
        correlationId = [guid]::NewGuid().ToString()
        initiatedBy = $InitiatedBy
        startTime = Get-Date -Format "o"
        trace = @()
    }
}

function Send-TracedMessage {
    param(
        [string]$To,
        [hashtable]$Payload,
        [hashtable]$Context
    )

    # Add trace entry
    $Context.trace += @{
        timestamp = Get-Date -Format "o"
        from = "dc"
        to = $To
        action = $Payload.command
    }

    $message = @{
        id = [guid]::NewGuid().ToString()
        timestamp = Get-Date -Format "o"
        from = "dc"
        to = $To
        type = "request"
        correlationId = $Context.correlationId
        payload = $Payload
        context = $Context
    } | ConvertTo-Json -Depth 10

    $inboxPath = "C:\PhiVector\ipc\$To\inbox\req-$($message.id).json"
    $message | Out-File -FilePath $inboxPath -Encoding UTF8
}

# Search traces by correlation ID
function Get-WorkflowTrace {
    param([string]$CorrelationId)

    $allMessages = Get-ChildItem "C:\PhiVector\ipc\*\*\*.json" -Recurse
    $related = $allMessages | ForEach-Object {
        $msg = Get-Content $_.FullName | ConvertFrom-Json
        if ($msg.correlationId -eq $CorrelationId) {
            return $msg
        }
    }

    return $related | Sort-Object timestamp
}
```

**When to Use:**
- Debugging complex multi-agent workflows
- Compliance/audit requirements
- Performance analysis

**Avoid When:**
- Simple single-agent operations
- Performance-critical paths (adds overhead)

---

## Code Examples

### Example 1: DC Orchestrates WEBC Research → VSSC Implementation

**Scenario:** STRYK requests "Research and implement OAuth2 login"

```powershell
# DC: Orchestrate workflow
function Start-FeatureWorkflow {
    param(
        [string]$FeatureRequest,
        [string]$InitiatedBy = "STRYK"
    )

    # Create workflow context
    $context = New-WorkflowContext -InitiatedBy $InitiatedBy
    Write-Host "Starting workflow $($context.correlationId): $FeatureRequest"

    # Step 1: WEBC research
    $researchPayload = @{
        command = "research"
        topic = "OAuth2 implementation best practices 2025"
        depth = "comprehensive"
    }

    $researchResult = Send-TracedMessage -To "webc" -Payload $researchPayload -Context $context
    Wait-ForResponse -CorrelationId $context.correlationId -From "webc" -TimeoutSeconds 300

    # Step 2: DC synthesizes requirements from research
    $requirements = Synthesize-Requirements -ResearchData $researchResult

    # Step 3: VSSC implements
    $buildPayload = @{
        command = "implement"
        requirements = $requirements
        language = "PowerShell"
        outputPath = "C:\PhiVector\tools\oauth2-module.psm1"
    }

    $buildResult = Send-TracedMessage -To "vssc" -Payload $buildPayload -Context $context
    Wait-ForResponse -CorrelationId $context.correlationId -From "vssc" -TimeoutSeconds 600

    # Step 4: KALIC audits (if security-sensitive)
    $auditPayload = @{
        command = "security_audit"
        targetFile = "C:\PhiVector\tools\oauth2-module.psm1"
        scope = @("injection", "authentication", "session_management")
    }

    $auditResult = Send-TracedMessage -To "kalic" -Payload $auditPayload -Context $context
    Wait-ForResponse -CorrelationId $context.correlationId -From "kalic" -TimeoutSeconds 300

    # Step 5: Decision point
    if ($auditResult.vulnerabilitiesFound -gt 0) {
        # Request STRYK approval
        Request-HumanApproval -Context $context -Issue "Security vulnerabilities found" -Details $auditResult
    }

    Write-Host "Workflow $($context.correlationId) completed"
    return $context
}
```

### Example 2: KALIC Broadcasts Vulnerability Alert

```powershell
# KALIC: Publish vulnerability event
function Publish-VulnerabilityAlert {
    param(
        [string]$TargetFile,
        [string]$VulnerabilityType,
        [string]$Severity,
        [hashtable]$Details
    )

    $event = @{
        id = [guid]::NewGuid().ToString()
        timestamp = Get-Date -Format "o"
        publisher = "kalic"
        eventType = "vulnerability_found"
        data = @{
            targetFile = $TargetFile
            vulnerabilityType = $VulnerabilityType
            severity = $Severity
            details = $Details
            remediationRequired = ($Severity -in @("high", "critical"))
        }
    } | ConvertTo-Json -Depth 10

    $eventFile = "C:\PhiVector\ipc\shared\events\vulnerability_found-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $event | Out-File -FilePath $eventFile -Encoding UTF8

    Write-Host "Published vulnerability alert: $VulnerabilityType in $TargetFile"
}

# DC: Subscribe and handle alerts
Subscribe-Events -EventTypes @("vulnerability_found") -Handler {
    param($event)

    if ($event.data.remediationRequired) {
        # High/critical severity - notify STRYK
        $notification = @{
            type = "security_alert"
            severity = $event.data.severity
            message = "Vulnerability found: $($event.data.vulnerabilityType) in $($event.data.targetFile)"
            actionRequired = "Review and approve remediation"
        }

        # Write to STRYK's notification queue
        $notification | ConvertTo-Json | Out-File "C:\PhiVector\ipc\stryk\notifications\alert-$(Get-Date -Format 'HHmmss').json"

        # Pause workflow pending approval
        Update-SharedState -StateUpdates @{
            approvalRequired = $true
            pendingApproval = $notification
        } -Agent "dc"
    }
    else {
        # Low/medium severity - auto-remediate
        $remediationPayload = @{
            command = "fix_vulnerability"
            targetFile = $event.data.targetFile
            vulnerabilityType = $event.data.vulnerabilityType
            autoFix = $true
        }

        Send-Command -To "vssc" -Payload $remediationPayload
    }
}
```

---

## Decision Matrices

### Choosing Communication Pattern

| Requirement | Pattern | Latency | Reliability | Complexity |
|-------------|---------|---------|-------------|------------|
| Need response from specific agent | Request/Response | Medium | High | Medium |
| Broadcast to multiple agents | Pub/Sub | Low | Medium | Low |
| No response needed | Fire-and-Forget | Very Low | Low | Very Low |
| Shared state updates | State File Sync | High | Medium | Low |
| Guaranteed delivery | DLQ + Retry | High | Very High | High |
| Workflow tracing | Correlation IDs | Medium | N/A | Medium |

### Serialization Format Selection

| Format | Human-Readable | Size | Parse Speed | Use Case |
|--------|----------------|------|-------------|----------|
| JSON | ✅ Yes | Large | Slow | Config, debugging, small messages |
| MessagePack | ❌ No | Small | Fast | High-throughput, large payloads |
| CBOR | ❌ No | Small | Fast | Binary data, IoT, embedded |
| Protocol Buffers | ❌ No | Smallest | Fastest | Performance-critical, versioned schemas |

**PhiVector Recommendation:** JSON for simplicity and debuggability (STRYK can inspect files directly)

---

## Anti-Patterns

### ❌ Anti-Pattern 1: Busy Waiting Without Backoff

**Problem:**
```powershell
# BAD: Constantly hammers file system
while (-not (Test-Path $responseFile)) {
    # No delay - 100% CPU usage
}
```

**Solution:**
```powershell
# GOOD: Exponential backoff
$delay = 100
while (-not (Test-Path $responseFile)) {
    Start-Sleep -Milliseconds $delay
    $delay = [Math]::Min($delay * 2, 5000)
}
```

### ❌ Anti-Pattern 2: No Timeout on Blocking Operations

**Problem:**
```powershell
# BAD: Waits forever if response never comes
while (-not (Test-Path $responseFile)) {
    Start-Sleep -Milliseconds 500
}
```

**Solution:**
```powershell
# GOOD: Timeout after reasonable duration
$deadline = (Get-Date).AddSeconds(60)
while ((Get-Date) -lt $deadline) {
    if (Test-Path $responseFile) { break }
    Start-Sleep -Milliseconds 500
}

if (-not (Test-Path $responseFile)) {
    throw "Timeout waiting for response"
}
```

### ❌ Anti-Pattern 3: No Message Deduplication

**Problem:**
```powershell
# BAD: Processes same message multiple times
Get-ChildItem $inboxPath | ForEach-Object {
    Process-Message $_
    # Message still exists - will process again!
}
```

**Solution:**
```powershell
# GOOD: Move or delete after processing
Get-ChildItem $inboxPath | ForEach-Object {
    Process-Message $_
    Move-Item $_ -Destination "$processedPath\$($_.Name)" -Force
}
```

### ❌ Anti-Pattern 4: Race Conditions on Shared State

**Problem:**
```powershell
# BAD: Read-modify-write without locking
$state = Get-Content $stateFile | ConvertFrom-Json
$state.counter++
$state | ConvertTo-Json | Out-File $stateFile
# Another agent could update between read and write!
```

**Solution:**
```powershell
# GOOD: File-based locking
$lockFile = "$stateFile.lock"
while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
New-Item $lockFile -ItemType File | Out-Null

try {
    $state = Get-Content $stateFile | ConvertFrom-Json
    $state.counter++
    $state | ConvertTo-Json | Out-File $stateFile
}
finally {
    Remove-Item $lockFile -Force
}
```

### ❌ Anti-Pattern 5: No Error Context in DLQ

**Problem:**
```powershell
# BAD: Just moves to DLQ without context
Move-Item $messageFile -Destination $dlqPath
```

**Solution:**
```powershell
# GOOD: Enrich with error details
$message = Get-Content $messageFile | ConvertFrom-Json -AsHashtable
$message.error = @{
    timestamp = Get-Date -Format "o"
    message = $_.Exception.Message
    stackTrace = $_.ScriptStackTrace
}
$message | ConvertTo-Json -Depth 10 | Out-File "$dlqPath\$($messageFile.Name)"
Remove-Item $messageFile -Force
```

---

## Performance Considerations

### Latency Optimization

**File System Overhead:**
- JSON serialization: ~1-5ms per message
- File write: ~5-20ms (SSD), ~50-200ms (HDD)
- File read: ~1-10ms (SSD), ~20-100ms (HDD)

**Polling Interval Trade-offs:**
| Interval | CPU Usage | Responsiveness | Use Case |
|----------|-----------|----------------|----------|
| 50ms | High | Excellent | Real-time coordination |
| 500ms | Medium | Good | Standard workflows |
| 2s | Low | Acceptable | Background tasks |
| 10s | Very Low | Poor | Non-critical monitoring |

**Recommendations:**
1. **Start with 500ms** for general-purpose workflows
2. **Use exponential backoff** to reduce CPU during idle periods
3. **Batch message processing** (read multiple files at once)
4. **Use RAM disk** for high-frequency IPC (e.g., `ImDisk` on Windows)

### Throughput Optimization

**Benchmark (JSON messages, 1KB payload):**
- Single-threaded: ~200 msg/sec
- Multi-threaded (4 workers): ~600 msg/sec
- With batching (10 msg/batch): ~1,200 msg/sec

**Strategies:**
1. **Batch writes:** Buffer messages and write multiple at once
2. **Use MessagePack:** 2-3x faster serialization than JSON
3. **Parallel processing:** Multiple worker processes for inbox
4. **Async I/O:** Use PowerShell `-Async` where possible

---

## Security Implications

### Trust Boundaries

**Threat Model:**
- **Malicious agent:** Compromised agent sends crafted messages
- **File system access:** Attacker with file access can inject messages
- **TOCTOU attacks:** Time-of-check to time-of-use file modifications

**Mitigations:**

1. **Message Signing (HMAC):**
```powershell
function Sign-Message {
    param([hashtable]$Message, [string]$SharedSecret)

    $payload = $Message | ConvertTo-Json -Compress
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($SharedSecret)
    $signature = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($payload))

    $Message.signature = [Convert]::ToBase64String($signature)
    return $Message
}

function Verify-Message {
    param([hashtable]$Message, [string]$SharedSecret)

    $receivedSig = $Message.signature
    $Message.Remove('signature')

    $payload = $Message | ConvertTo-Json -Compress
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($SharedSecret)
    $expectedSig = [Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($payload)))

    return $receivedSig -eq $expectedSig
}
```

2. **Input Validation:**
```powershell
function Validate-Message {
    param([hashtable]$Message)

    # Required fields
    if (-not $Message.id -or -not $Message.from -or -not $Message.to) {
        throw "Missing required fields"
    }

    # Valid agent names
    $validAgents = @("dc", "vssc", "kalic", "webc", "cmdc", "stryk")
    if ($Message.from -notin $validAgents -or $Message.to -notin $validAgents) {
        throw "Invalid agent name"
    }

    # Timestamp freshness (prevent replay attacks)
    $msgTime = [DateTime]::Parse($Message.timestamp)
    if ((Get-Date) - $msgTime -gt [TimeSpan]::FromMinutes(5)) {
        throw "Message too old (possible replay attack)"
    }

    # Payload size limit
    $payloadSize = ($Message.payload | ConvertTo-Json).Length
    if ($payloadSize -gt 1MB) {
        throw "Payload exceeds size limit"
    }
}
```

3. **File Permissions:**
```powershell
# Restrict inbox access to specific agents
$inboxPath = "C:\PhiVector\ipc\vssc\inbox"
$acl = Get-Acl $inboxPath
$acl.SetAccessRuleProtection($true, $false)  # Disable inheritance

# Grant access only to DC and VSSC
$dcSID = (New-Object System.Security.Principal.NTAccount("PhiVector\DC")).Translate([System.Security.Principal.SecurityIdentifier])
$vsscSID = (New-Object System.Security.Principal.NTAccount("PhiVector\VSSC")).Translate([System.Security.Principal.SecurityIdentifier])

$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($dcSID, "Write", "Allow")))
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($vsscSID, "FullControl", "Allow")))

Set-Acl $inboxPath $acl
```

---

## Troubleshooting Guide

### Issue 1: Messages Not Being Received

**Symptoms:**
- Agent polls inbox but finds no messages
- Sender confirms writing to inbox

**Diagnostics:**
```powershell
# Check file exists
Test-Path "C:\PhiVector\ipc\vssc\inbox\req-123.json"

# Check file permissions
Get-Acl "C:\PhiVector\ipc\vssc\inbox" | Format-List

# Check file content
Get-Content "C:\PhiVector\ipc\vssc\inbox\req-123.json"

# Check locks
Get-ChildItem "C:\PhiVector\ipc\shared\locks"
```

**Common Causes:**
1. **Wrong path:** Typo in inbox directory
2. **Permissions:** Agent cannot read inbox
3. **Timing:** Message processed before diagnostic check
4. **Lock not released:** Stuck lock file prevents processing

**Solutions:**
- Verify paths match in sender and receiver
- Check ACLs with `Get-Acl`
- Add logging at write and read points
- Implement lock timeout/cleanup

### Issue 2: High Latency (Slow Response)

**Symptoms:**
- Request/response taking >5 seconds
- High CPU usage during polling

**Diagnostics:**
```powershell
# Measure file I/O performance
Measure-Command {
    $data = @{test="data"} | ConvertTo-Json
    $data | Out-File "C:\temp\test.json"
    Get-Content "C:\temp\test.json"
}

# Check disk queue length
Get-Counter '\PhysicalDisk(*)\Avg. Disk Queue Length'

# Profile polling loop
Measure-Command { Poll-Inbox -InboxPath "C:\PhiVector\ipc\vssc\inbox" }
```

**Common Causes:**
1. **HDD instead of SSD:** 10x slower file I/O
2. **Too-frequent polling:** 100% CPU usage
3. **Large JSON payloads:** Slow serialization
4. **Antivirus scanning:** Delays file operations

**Solutions:**
- Use SSD or RAM disk for IPC files
- Implement exponential backoff polling
- Switch to MessagePack for large payloads
- Exclude IPC directories from antivirus scans

### Issue 3: Lost Messages

**Symptoms:**
- Message written but never processed
- No trace in inbox, outbox, or DLQ

**Diagnostics:**
```powershell
# Search all IPC directories
Get-ChildItem "C:\PhiVector\ipc" -Recurse -Filter "*.json" |
    Where-Object { $_.Name -match "msg-123" }

# Check recycle bin
Get-ChildItem "C:\`$Recycle.Bin" -Recurse -ErrorAction SilentlyContinue

# Audit file deletions (requires audit policy)
Get-WinEvent -LogName Security | Where-Object { $_.Id -eq 4663 }
```

**Common Causes:**
1. **Exception during processing:** Message deleted before handling
2. **No DLQ:** Failed messages lost
3. **Cleanup script too aggressive:** Deletes pending messages
4. **Disk full:** Write fails silently

**Solutions:**
- Move to DLQ before attempting processing
- Always use try/finally to ensure cleanup
- Implement retention policy (keep processed messages 24h)
- Monitor disk space

---

## PhiVector-Specific Applications

### DC as Orchestrator

**Role:** Coordinate workflows across specialized agents
**Pattern:** Hub-and-spoke (DC at center, agents as spokes)

**Example Workflow:**
```
STRYK: "Build secure REST API for user management"
    ↓
[DC] Decomposes into tasks:
    ├─→ [WEBC] Research REST API security best practices 2025
    ├─→ [VSSC] Implement API controllers and auth
    ├─→ [KALIC] Security audit (OWASP Top 10 check)
    └─→ [DC] Synthesize results, request STRYK approval
```

**Communication Patterns:**
- Request/Response for task delegation
- State files for workflow progress
- Correlation IDs for end-to-end tracing

### VSSC as Development Specialist

**Role:** Build tools, fix bugs, implement features
**Pattern:** Worker (receives commands, returns results)

**Example Inbox Message:**
```json
{
  "id": "vssc-task-001",
  "from": "dc",
  "to": "vssc",
  "type": "request",
  "payload": {
    "command": "build_tool",
    "toolName": "log_analyzer",
    "requirements": {
      "inputs": ["log_file_path"],
      "outputs": ["error_count", "warning_count", "summary"],
      "language": "PowerShell"
    }
  }
}
```

**Communication Patterns:**
- Request/Response for build tasks
- Pub/Sub to notify DC of build completion
- DLQ for failed builds (syntax errors, missing dependencies)

### KALIC as Security Auditor

**Role:** Scan for vulnerabilities, audit code
**Pattern:** Publisher (broadcasts findings), Worker (on-demand scans)

**Example Event Publication:**
```json
{
  "eventType": "vulnerability_found",
  "publisher": "kalic",
  "data": {
    "severity": "high",
    "type": "SQL_INJECTION",
    "file": "C:\\PhiVector\\tools\\user_query.ps1",
    "line": 42,
    "remediation": "Use parameterized queries instead of string concatenation"
  }
}
```

**Communication Patterns:**
- Pub/Sub for vulnerability alerts
- Request/Response for on-demand audits
- State files for scan progress

### WEBC as Research Specialist

**Role:** Parallel web research, knowledge compilation
**Pattern:** Worker (receives research requests, returns synthesized results)

**Example Research Task:**
```powershell
# DC → WEBC: Research request
$researchRequest = @{
    command = "research"
    topic = "CRDT conflict resolution algorithms"
    queries = @(
        "CRDT conflict-free replicated data types 2025",
        "operational transformation vs CRDT",
        "vector clocks distributed systems"
    )
    synthesize = $true
    maxSources = 15
}

Send-Command -To "webc" -Payload $researchRequest -TimeoutSeconds 600

# WEBC → DC: Research results
$researchResult = @{
    topic = "CRDT conflict resolution algorithms"
    summary = "CRDTs enable conflict-free replication using commutative operations..."
    keyFindings = @(
        "State-based vs operation-based CRDTs",
        "Vector clocks track causality",
        "Strong eventual consistency guaranteed"
    )
    sources = @(...)
    synthesizedDocument = "C:\\PhiVector\\research\\crdt-summary.md"
}
```

**Communication Patterns:**
- Request/Response for research tasks
- Fire-and-forget for background compilation
- State files for research progress (long-running)

### CMDC as Terminal Automation

**Role:** Execute MCP tools, run commands
**Pattern:** Worker (receives shell commands, returns output)

**Example Command Execution:**
```powershell
# DC → CMDC: Execute git commit
$cmdRequest = @{
    command = "execute"
    shell = "powershell"
    script = @"
        cd C:\PhiVector\tools
        git add user_auth.psm1
        git commit -m "Add OAuth2 authentication module"
        git push origin main
"@
    timeout = 60
}

Send-Command -To "cmdc" -Payload $cmdRequest

# CMDC → DC: Execution result
$cmdResult = @{
    exitCode = 0
    stdout = "[main abc123] Add OAuth2 authentication module\n1 file changed, 150 insertions(+)"
    stderr = ""
    duration = 2.3
}
```

**Communication Patterns:**
- Request/Response for command execution
- DLQ for failed commands (nonzero exit codes)
- Correlation IDs for multi-step operations

---

## References

### Academic & Research
1. **Hewitt, C., Bishop, P., & Steiger, R. (1973).** "A Universal Modular ACTOR Formalism for Artificial Intelligence." IJCAI.
2. **Hoare, C. A. R. (1978).** "Communicating Sequential Processes." Communications of the ACM, 21(8), 666-677.
3. **Shapiro, M., Preguiça, N., Baquero, C., & Zawirski, M. (2011).** "Conflict-free Replicated Data Types." SSS 2011.
4. **Fidge, C. (1988).** "Timestamps in Message-Passing Systems That Preserve the Partial Ordering." Australian Computer Science Communications, 10(1), 56-66.

### Industry Best Practices
5. **Martin Fowler.** "Event-Driven Architecture." martinfowler.com/articles/201701-event-driven.html
6. **Microsoft Azure Architecture Center.** "Asynchronous messaging patterns." docs.microsoft.com/azure/architecture/patterns/
7. **AWS Well-Architected Framework.** "Messaging and event-driven architecture." aws.amazon.com/architecture/well-architected/
8. **Google Cloud.** "Service orchestration patterns." cloud.google.com/blog/topics/developers-practitioners/service-orchestration

### Tools & Frameworks
9. **gRPC Documentation.** "Core concepts, architecture and lifecycle." grpc.io/docs/what-is-grpc/core-concepts/
10. **Apache Kafka.** "Event streaming platform." kafka.apache.org
11. **RabbitMQ.** "Messaging that just works." rabbitmq.com
12. **Redis Pub/Sub.** "Publish/subscribe messaging." redis.io/docs/manual/pubsub/

### PhiVector-Specific
13. **PowerShell Documentation.** "About Jobs." docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_jobs
14. **Windows File Locking.** "File access and file sharing." docs.microsoft.com/windows/win32/fileio/file-access-and-file-sharing
15. **MCP (Model Context Protocol).** Anthropic's local tool execution protocol.

---

**End of Agent Communication Protocols Guide**

**Next Steps:**
- Proceed to [Workflow Orchestration Patterns](../02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md)
- Review [PhiSync Framework Overview](../README.md) for integration guidance
- Consult [State Synchronization Guide](../03_STATE_SYNCHRONIZATION/STATE_MANAGEMENT_GUIDE.md) for shared state patterns

**Feedback:** Report issues or suggest improvements to STRYK or via PhiVector GitHub repository.
