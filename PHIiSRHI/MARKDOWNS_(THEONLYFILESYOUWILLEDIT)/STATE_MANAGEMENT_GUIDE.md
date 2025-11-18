# State Synchronization & Management
## PhiSync Multi-Agent Coordination Codex - Domain 3

**Version:** 1.0.0
**Last Updated:** 2025-11-15
**Target:** PhiVector AI Infrastructure (DC, VSSC, KALIC, WEBC, CMDC)

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Conceptual Overview](#conceptual-overview)
3. [Consistency Models](#consistency-models)
4. [Pattern Catalog](#pattern-catalog)
5. [Code Examples](#code-examples)
6. [Decision Matrices](#decision-matrices)
7. [Anti-Patterns](#anti-patterns)
8. [Performance Considerations](#performance-considerations)
9. [Security Implications](#security-implications)
10. [Troubleshooting Guide](#troubleshooting-guide)
11. [PhiVector State Management](#phivector-state-management)
12. [References](#references)

---

## Executive Summary

State synchronization ensures multiple agents maintain a consistent view of shared data. In distributed systems, achieving consistency requires careful trade-offs between availability, performance, and correctness.

### Key Takeaways
- **File-based state** is primary mechanism in PhiVector (no shared memory)
- **Eventual consistency** tolerates temporary divergence for availability
- **Strong consistency** guarantees all agents see same state (with performance cost)
- **CRDT (Conflict-Free Replicated Data Types)** enable automatic conflict resolution
- **Vector clocks** track causality and detect conflicts
- **Locking** prevents concurrent modification but reduces concurrency

### When to Use This Guide
- Designing shared state between agents
- Resolving state conflicts
- Implementing transactional updates
- Troubleshooting state inconsistencies
- Optimizing state synchronization performance

### Quick Decision Tree
```
Can tolerate temporary inconsistency?
├─ Yes → Eventual consistency (higher performance)
└─ No → Strong consistency (lower performance)

Concurrent updates expected?
├─ Yes → Use CRDTs or vector clocks
└─ No → Simple last-write-wins

Need atomic multi-file updates?
├─ Yes → Two-phase commit or saga pattern
└─ No → Single-file atomic write

State fits in memory?
├─ Yes → In-memory cache with file persistence
└─ No → Stream-based processing
```

---

## Conceptual Overview

### State in Distributed Systems

**State** = Data that changes over time and must be shared between agents

**Challenges:**
1. **Concurrent modifications:** Multiple agents update same state simultaneously
2. **Network partitions:** Agents temporarily disconnected from shared storage
3. **Failure handling:** Agent crashes mid-update, leaving partial state
4. **Ordering:** Updates from different agents arrive in different orders
5. **Scalability:** State synchronization overhead grows with agent count

### CAP Theorem

**CAP Theorem:** Distributed system can provide at most 2 of 3 guarantees:
- **Consistency (C):** All agents see same data at same time
- **Availability (A):** System responds to requests even during failures
- **Partition Tolerance (P):** System continues despite network failures

**PhiVector Reality:** Network partitions rare (all agents on same machine), prioritize **C + A**

**Trade-off:**
- **CP (Consistency + Partition Tolerance):** Strong consistency, may refuse requests during failures
- **AP (Availability + Partition Tolerance):** Always available, may show stale data

### Consistency Models

#### 1. Strong Consistency
**Guarantee:** All agents see updates in same order, immediately

**Mechanism:** Locking, consensus algorithms (Paxos, Raft)

**Example:**
```
Agent A writes X=1
Agent B reads X → Always sees X=1 (never stale value)
```

**Cost:** High latency (coordination overhead), reduced availability

#### 2. Eventual Consistency
**Guarantee:** All agents eventually converge to same state (if no new updates)

**Mechanism:** Asynchronous replication, conflict resolution

**Example:**
```
Agent A writes X=1
Agent B reads X → May see old value temporarily
After sync period → All agents see X=1
```

**Benefit:** Low latency, high availability

#### 3. Causal Consistency
**Guarantee:** Causally related updates seen in order, concurrent updates may differ

**Mechanism:** Vector clocks, happens-before relationships

**Example:**
```
Agent A writes X=1, then Y=2
Agent B reads → Sees X=1 before Y=2 (causality preserved)
Agent C writes Z=3 concurrently → Order of Z relative to X/Y undefined
```

**Balance:** Stronger than eventual, weaker than strong

---

## Consistency Models

### Last-Write-Wins (LWW)

**Mechanism:** Timestamp each update, latest timestamp wins

**Implementation:**
```powershell
function Update-StateL WW {
    param(
        [string]$StateFile,
        [hashtable]$Updates
    )

    $lockFile = "$StateFile.lock"

    # Acquire lock
    while (Test-Path $lockFile) {
        Start-Sleep -Milliseconds 50
    }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        # Read current state
        $state = @{}
        if (Test-Path $StateFile) {
            $state = Get-Content $StateFile | ConvertFrom-Json -AsHashtable
        }

        # Apply updates if newer
        $currentTimestamp = (Get-Date).ToUniversalTime()
        foreach ($key in $Updates.Keys) {
            $existingTimestamp = $state["${key}_timestamp"]

            if (-not $existingTimestamp -or $currentTimestamp -gt [DateTime]::Parse($existingTimestamp)) {
                $state[$key] = $Updates[$key]
                $state["${key}_timestamp"] = $currentTimestamp.ToString("o")
            }
        }

        # Atomic write
        $tempFile = "$StateFile.tmp"
        $state | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
        Move-Item $tempFile $StateFile -Force
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}
```

**Pros:**
- Simple to implement
- No conflict resolution needed
- Low overhead

**Cons:**
- May lose updates (concurrent writes, latest wins arbitrarily)
- Clock skew issues (if agent clocks not synchronized)

**Use When:** Conflicts rare, losing occasional update acceptable

---

### Vector Clocks

**Purpose:** Track causality and detect concurrent updates

**Mechanism:** Each agent maintains counter, increments on update

**Vector Clock Structure:**
```json
{
  "value": "X=1",
  "vectorClock": {
    "dc": 3,
    "vssc": 1,
    "kalic": 0
  }
}
```

**Comparison Rules:**
- **Clock A > Clock B** (A causally after B): `A[agent] >= B[agent]` for all agents, `A[x] > B[x]` for at least one
- **Clock A || Clock B** (concurrent): Neither A > B nor B > A

**Implementation:**
```powershell
function Update-StateVectorClock {
    param(
        [string]$StateFile,
        [string]$Agent,
        [hashtable]$Updates
    )

    $lockFile = "$StateFile.lock"
    while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        # Read current state
        $state = @{
            data = @{}
            vectorClock = @{ dc = 0; vssc = 0; kalic = 0; webc = 0; cmdc = 0 }
        }

        if (Test-Path $StateFile) {
            $state = Get-Content $StateFile | ConvertFrom-Json -AsHashtable
        }

        # Increment this agent's clock
        $state.vectorClock[$Agent]++

        # Apply updates
        foreach ($key in $Updates.Keys) {
            $state.data[$key] = $Updates[$key]
        }

        # Write back
        $tempFile = "$StateFile.tmp"
        $state | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
        Move-Item $tempFile $StateFile -Force
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

function Compare-VectorClocks {
    param(
        [hashtable]$ClockA,
        [hashtable]$ClockB
    )

    $aGreater = $false
    $bGreater = $false

    foreach ($agent in $ClockA.Keys) {
        if ($ClockA[$agent] -gt $ClockB[$agent]) {
            $aGreater = $true
        }
        if ($ClockA[$agent] -lt $ClockB[$agent]) {
            $bGreater = $true
        }
    }

    if ($aGreater -and -not $bGreater) {
        return "A_AFTER_B"  # A causally after B
    }
    elseif ($bGreater -and -not $aGreater) {
        return "B_AFTER_A"  # B causally after A
    }
    elseif ($aGreater -and $bGreater) {
        return "CONCURRENT"  # Concurrent updates - conflict!
    }
    else {
        return "EQUAL"
    }
}
```

**Pros:**
- Detects concurrent updates accurately
- No clock synchronization needed
- Preserves causality

**Cons:**
- Vector grows with agent count
- Doesn't resolve conflicts (only detects)

**Use When:** Need to detect conflicts for manual/CRDT resolution

---

### CRDT (Conflict-Free Replicated Data Types)

**Purpose:** Data structures that automatically resolve conflicts

**Property:** Concurrent updates commute (order doesn't matter)

**Types:**

#### 1. G-Counter (Grow-Only Counter)
**Use Case:** Count events (page views, errors)

**Structure:**
```json
{
  "dc": 5,
  "vssc": 3,
  "kalic": 1
}
// Total = 5 + 3 + 1 = 9
```

**Implementation:**
```powershell
function Increment-GCounter {
    param(
        [string]$CounterFile,
        [string]$Agent,
        [int]$Amount = 1
    )

    $lockFile = "$CounterFile.lock"
    while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        $counter = @{ dc = 0; vssc = 0; kalic = 0; webc = 0; cmdc = 0 }

        if (Test-Path $CounterFile) {
            $counter = Get-Content $CounterFile | ConvertFrom-Json -AsHashtable
        }

        # Increment this agent's counter
        $counter[$Agent] += $Amount

        # Write back
        $tempFile = "$CounterFile.tmp"
        $counter | ConvertTo-Json | Out-File $tempFile -Encoding UTF8
        Move-Item $tempFile $CounterFile -Force
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

function Get-GCounterValue {
    param([string]$CounterFile)

    $counter = Get-Content $CounterFile | ConvertFrom-Json -AsHashtable
    $total = 0

    foreach ($agent in $counter.Keys) {
        $total += $counter[$agent]
    }

    return $total
}
```

#### 2. LWW-Element-Set (Add/Remove Set)
**Use Case:** Set of elements where adds/removes conflict

**Structure:**
```json
{
  "adds": {
    "item1": "2025-11-15T10:00:00Z",
    "item2": "2025-11-15T10:05:00Z"
  },
  "removes": {
    "item1": "2025-11-15T10:10:00Z"
  }
}
// item1 removed (remove timestamp > add timestamp)
// item2 present
```

**Implementation:**
```powershell
function Add-LWWSetElement {
    param(
        [string]$SetFile,
        [string]$Element
    )

    $lockFile = "$SetFile.lock"
    while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        $set = @{ adds = @{}; removes = @{} }

        if (Test-Path $SetFile) {
            $set = Get-Content $SetFile | ConvertFrom-Json -AsHashtable
        }

        $set.adds[$Element] = (Get-Date).ToUniversalTime().ToString("o")

        $tempFile = "$SetFile.tmp"
        $set | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
        Move-Item $tempFile $SetFile -Force
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

function Remove-LWWSetElement {
    param(
        [string]$SetFile,
        [string]$Element
    )

    $lockFile = "$SetFile.lock"
    while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        $set = Get-Content $SetFile | ConvertFrom-Json -AsHashtable
        $set.removes[$Element] = (Get-Date).ToUniversalTime().ToString("o")

        $tempFile = "$SetFile.tmp"
        $set | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
        Move-Item $tempFile $SetFile -Force
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

function Get-LWWSetElements {
    param([string]$SetFile)

    $set = Get-Content $SetFile | ConvertFrom-Json -AsHashtable
    $elements = @()

    foreach ($element in $set.adds.Keys) {
        $addTime = [DateTime]::Parse($set.adds[$element])
        $removeTime = $null

        if ($set.removes.ContainsKey($element)) {
            $removeTime = [DateTime]::Parse($set.removes[$element])
        }

        # Element present if not removed, or add timestamp > remove timestamp
        if (-not $removeTime -or $addTime -gt $removeTime) {
            $elements += $element
        }
    }

    return $elements
}
```

**Pros:**
- Automatic conflict resolution
- No coordination needed
- Eventually consistent

**Cons:**
- Limited data types (counters, sets, registers)
- May not match application semantics (bias toward adds)

**Use When:** Data fits CRDT model, automatic resolution acceptable

---

## Pattern Catalog

### Pattern 1: File-Based Mutex (Exclusive Access)

**Intent:** Ensure only one agent modifies state at a time

**Structure:**
```
Agent A                        Agent B
   |                              |
   |--Create lock file---------->X (lock exists, wait)
   |                              |
   |--Modify state-------------->|
   |                              |
   |--Delete lock file---------->|
   |                              |
   |                              |--Create lock file (succeeds)
   |                              |
   |                              |--Modify state
```

**Implementation:**
```powershell
function Invoke-WithFileLock {
    param(
        [string]$LockFile,
        [scriptblock]$Action,
        [int]$TimeoutSeconds = 30
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    # Try to acquire lock
    while ((Get-Date) -lt $deadline) {
        try {
            # Atomic lock creation (fails if exists)
            New-Item $LockFile -ItemType File -ErrorAction Stop | Out-Null

            try {
                # Execute protected action
                return & $Action
            }
            finally {
                # Always release lock
                Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            # Lock exists - wait and retry
            Start-Sleep -Milliseconds 100
        }
    }

    throw "Failed to acquire lock within $TimeoutSeconds seconds"
}

# Usage
Invoke-WithFileLock -LockFile "C:\PhiVector\ipc\shared\locks\workflow-state.lock" -Action {
    # Critical section - exclusive access guaranteed
    $state = Get-Content "C:\PhiVector\ipc\shared\state\workflow-state.json" | ConvertFrom-Json -AsHashtable
    $state.counter++
    $state | ConvertTo-Json | Out-File "C:\PhiVector\ipc\shared\state\workflow-state.json"
}
```

**When to Use:**
- Need guaranteed exclusive access
- Updates are small and fast (minimize lock time)
- Strong consistency required

**Avoid When:**
- Updates are slow (long lock time reduces concurrency)
- High contention (many agents competing)

---

### Pattern 2: Optimistic Locking (Compare-and-Swap)

**Intent:** Allow concurrent reads, detect conflicts on write

**Structure:**
```
Agent A reads state (version 5)
Agent B reads state (version 5)
Agent A writes (expects version 5, increments to 6) → Success
Agent B writes (expects version 5, but current is 6) → Conflict! Retry
```

**Implementation:**
```powershell
function Update-StateOptimistic {
    param(
        [string]$StateFile,
        [scriptblock]$UpdateFunction,
        [int]$MaxRetries = 3
    )

    for ($attempt = 0; $attempt -lt $MaxRetries; $attempt++) {
        # Read current state
        $state = @{ version = 0; data = @{} }
        if (Test-Path $StateFile) {
            $state = Get-Content $StateFile | ConvertFrom-Json -AsHashtable
        }

        $expectedVersion = $state.version

        # Apply updates
        $newData = & $UpdateFunction $state.data

        # Prepare new state
        $newState = @{
            version = $expectedVersion + 1
            data = $newData
        }

        # Atomic compare-and-swap
        $lockFile = "$StateFile.lock"
        while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
        New-Item $lockFile -ItemType File -Force | Out-Null

        try {
            # Re-read to check version
            $currentState = @{ version = 0 }
            if (Test-Path $StateFile) {
                $currentState = Get-Content $StateFile | ConvertFrom-Json -AsHashtable
            }

            if ($currentState.version -ne $expectedVersion) {
                # Version changed - conflict detected
                Remove-Item $lockFile -Force
                Write-Warning "Optimistic lock conflict (expected v$expectedVersion, found v$($currentState.version)) - retrying..."
                Start-Sleep -Milliseconds (100 * ($attempt + 1))
                continue
            }

            # Version matches - commit update
            $tempFile = "$StateFile.tmp"
            $newState | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
            Move-Item $tempFile $StateFile -Force

            Remove-Item $lockFile -Force
            return $newState
        }
        catch {
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            throw
        }
    }

    throw "Optimistic update failed after $MaxRetries attempts"
}

# Usage
Update-StateOptimistic -StateFile "C:\PhiVector\ipc\shared\state\workflow.json" -UpdateFunction {
    param($data)

    # Apply updates to data
    $data.tasksPending--
    $data.tasksCompleted++

    return $data
}
```

**When to Use:**
- Conflicts rare (most updates succeed first try)
- High read-to-write ratio
- Prefer availability over strict locking

**Avoid When:**
- Conflicts common (many retries reduce performance)
- Update function is expensive (retry cost high)

---

### Pattern 3: State Snapshots & Checkpoints

**Intent:** Periodically save complete state for recovery

**Structure:**
```
Continuous updates → State file
Every N minutes → Copy to snapshot
On failure → Restore from latest snapshot
```

**Implementation:**
```powershell
function Save-StateSnapshot {
    param(
        [string]$StateFile,
        [string]$SnapshotDir
    )

    if (-not (Test-Path $StateFile)) {
        Write-Warning "State file not found: $StateFile"
        return
    }

    # Create snapshot directory
    if (-not (Test-Path $SnapshotDir)) {
        New-Item $SnapshotDir -ItemType Directory -Force | Out-Null
    }

    # Generate snapshot filename with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $snapshotFile = Join-Path $SnapshotDir "snapshot-$timestamp.json"

    # Copy state file atomically
    Copy-Item $StateFile $snapshotFile -Force

    Write-Host "Snapshot saved: $snapshotFile"

    # Cleanup old snapshots (keep last 10)
    $snapshots = Get-ChildItem $SnapshotDir -Filter "snapshot-*.json" | Sort-Object LastWriteTime -Descending
    if ($snapshots.Count -gt 10) {
        $snapshots[10..($snapshots.Count-1)] | Remove-Item -Force
    }
}

function Restore-StateSnapshot {
    param(
        [string]$SnapshotDir,
        [string]$StateFile
    )

    # Find latest snapshot
    $latestSnapshot = Get-ChildItem $SnapshotDir -Filter "snapshot-*.json" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestSnapshot) {
        throw "No snapshots found in $SnapshotDir"
    }

    Write-Host "Restoring state from: $($latestSnapshot.FullName)"
    Copy-Item $latestSnapshot.FullName $StateFile -Force
}

# Snapshot daemon (runs in background)
function Start-SnapshotDaemon {
    param(
        [string]$StateFile,
        [string]$SnapshotDir,
        [int]$IntervalMinutes = 15
    )

    while ($true) {
        Save-StateSnapshot -StateFile $StateFile -SnapshotDir $SnapshotDir
        Start-Sleep -Seconds ($IntervalMinutes * 60)
    }
}
```

**When to Use:**
- State is critical (data loss unacceptable)
- Recovery from failures needed
- Audit/compliance requires historical state

**Avoid When:**
- State changes very frequently (snapshot overhead high)
- Storage limited (snapshots consume space)

---

### Pattern 4: Event Sourcing

**Intent:** Store state changes as sequence of events, reconstruct current state by replaying

**Structure:**
```
Events:
  [1] TaskCreated { taskId: "t1", name: "Research" }
  [2] TaskStarted { taskId: "t1", agent: "webc" }
  [3] TaskCompleted { taskId: "t1", result: {...} }

Current State = Replay events 1→2→3
```

**Implementation:**
```powershell
function Append-Event {
    param(
        [string]$EventLog,
        [hashtable]$Event
    )

    # Add sequence number and timestamp
    $Event.sequence = (Get-EventCount -EventLog $EventLog) + 1
    $Event.timestamp = Get-Date -Format "o"

    # Append to event log (atomic)
    $lockFile = "$EventLog.lock"
    while (Test-Path $lockFile) { Start-Sleep -Milliseconds 50 }
    New-Item $lockFile -ItemType File -Force | Out-Null

    try {
        $Event | ConvertTo-Json -Compress | Add-Content $EventLog -Encoding UTF8
    }
    finally {
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
}

function Get-EventCount {
    param([string]$EventLog)

    if (-not (Test-Path $EventLog)) {
        return 0
    }

    return (Get-Content $EventLog | Measure-Object -Line).Lines
}

function Replay-Events {
    param(
        [string]$EventLog,
        [int]$FromSequence = 1
    )

    $state = @{
        tasks = @{}
        agents = @{}
    }

    if (-not (Test-Path $EventLog)) {
        return $state
    }

    Get-Content $EventLog | ForEach-Object {
        $event = $_ | ConvertFrom-Json -AsHashtable

        if ($event.sequence -lt $FromSequence) {
            return  # Skip events before starting sequence
        }

        # Apply event to state
        switch ($event.type) {
            "TaskCreated" {
                $state.tasks[$event.taskId] = @{
                    name = $event.name
                    status = "pending"
                }
            }
            "TaskStarted" {
                $state.tasks[$event.taskId].status = "running"
                $state.tasks[$event.taskId].agent = $event.agent
            }
            "TaskCompleted" {
                $state.tasks[$event.taskId].status = "completed"
                $state.tasks[$event.taskId].result = $event.result
            }
        }
    }

    return $state
}

# Usage
Append-Event -EventLog "C:\PhiVector\ipc\shared\events\workflow.log" -Event @{
    type = "TaskCreated"
    taskId = "task-001"
    name = "ResearchOAuth2"
    agent = "webc"
}

# Reconstruct current state
$currentState = Replay-Events -EventLog "C:\PhiVector\ipc\shared\events\workflow.log"
```

**When to Use:**
- Need complete audit trail (who changed what, when)
- Time-travel queries (state at any point in time)
- Multiple views of same data (different projections)

**Avoid When:**
- Event log grows unbounded (need compaction strategy)
- Replay is slow (optimize with snapshots)

---

## Code Examples

### Example 1: Workflow State Machine with Atomic Transitions

```powershell
# Workflow states: pending → running → (completed | failed)
$workflowStates = @("pending", "running", "completed", "failed")

function Transition-WorkflowState {
    param(
        [string]$WorkflowId,
        [string]$FromState,
        [string]$ToState,
        [hashtable]$Metadata = @{}
    )

    $stateFile = "C:\PhiVector\ipc\shared\state\workflow-$WorkflowId.json"

    Update-StateOptimistic -StateFile $stateFile -UpdateFunction {
        param($data)

        # Validate transition
        if ($data.state -ne $FromState) {
            throw "Invalid state transition: expected $FromState, found $($data.state)"
        }

        # Valid transitions
        $validTransitions = @{
            pending = @("running")
            running = @("completed", "failed")
            completed = @()
            failed = @()
        }

        if ($ToState -notin $validTransitions[$FromState]) {
            throw "Invalid transition: $FromState → $ToState"
        }

        # Apply transition
        $data.state = $ToState
        $data.lastTransition = Get-Date -Format "o"
        $data.metadata = $Metadata

        return $data
    }
}

# Usage
Transition-WorkflowState -WorkflowId "wf-001" -FromState "pending" -ToState "running" -Metadata @{
    agent = "webc"
    startTime = Get-Date -Format "o"
}
```

### Example 2: Multi-File Transaction (Two-Phase Commit)

```powershell
function Execute-MultiFileTransaction {
    param(
        [hashtable[]]$Operations  # Array of @{ File = "..."; Updates = @{...} }
    )

    $transactionId = [guid]::NewGuid().ToString()
    $preparedFiles = @()

    try {
        # Phase 1: Prepare (write to temp files)
        foreach ($op in $Operations) {
            $tempFile = "$($op.File).tx-$transactionId"

            # Read current state
            $state = @{}
            if (Test-Path $op.File) {
                $state = Get-Content $op.File | ConvertFrom-Json -AsHashtable
            }

            # Apply updates
            foreach ($key in $op.Updates.Keys) {
                $state[$key] = $op.Updates[$key]
            }

            # Write to temp file
            $state | ConvertTo-Json -Depth 10 | Out-File $tempFile -Encoding UTF8
            $preparedFiles += @{ File = $op.File; TempFile = $tempFile }
        }

        # Phase 2: Commit (rename temp files)
        foreach ($prepared in $preparedFiles) {
            Move-Item $prepared.TempFile $prepared.File -Force
        }

        Write-Host "Transaction $transactionId committed successfully"
    }
    catch {
        # Rollback: Delete temp files
        foreach ($prepared in $preparedFiles) {
            if (Test-Path $prepared.TempFile) {
                Remove-Item $prepared.TempFile -Force
            }
        }

        throw "Transaction $transactionId failed: $_"
    }
}

# Usage: Update workflow state and agent state atomically
Execute-MultiFileTransaction -Operations @(
    @{
        File = "C:\PhiVector\ipc\shared\state\workflow-001.json"
        Updates = @{ status = "completed"; completedAt = Get-Date -Format "o" }
    },
    @{
        File = "C:\PhiVector\ipc\vssc\state.json"
        Updates = @{ tasksCompleted = 5; lastTask = "workflow-001" }
    }
)
```

---

## Decision Matrices

### Consistency Model Selection

| Requirement | Model | Latency | Availability | Conflict Risk |
|-------------|-------|---------|--------------|---------------|
| Bank account balance | Strong | High | Low | None |
| Real-time chat | Causal | Medium | High | Low |
| Analytics dashboard | Eventual | Low | Very High | Acceptable |
| Shopping cart | CRDT | Low | High | Auto-resolved |

### Locking Strategy Selection

| Scenario | Strategy | Throughput | Latency | Complexity |
|----------|----------|------------|---------|------------|
| Rare updates, strong consistency needed | Pessimistic (file lock) | Low | High | Low |
| Common reads, rare conflicts | Optimistic (versioning) | High | Low | Medium |
| High contention | Queue-based | Medium | Medium | High |
| No contention | Lock-free (CRDT) | Very High | Very Low | High |

---

## Anti-Patterns

### ❌ Anti-Pattern 1: No Conflict Detection

**Problem:**
```powershell
# BAD: Overwrites without checking for concurrent modifications
$state = Get-Content $stateFile | ConvertFrom-Json
$state.counter++
$state | ConvertTo-Json | Out-File $stateFile
# Another agent's concurrent update lost!
```

**Solution:** Use versioning or locking

### ❌ Anti-Pattern 2: Unbounded State Growth

**Problem:**
```powershell
# BAD: Appends to event log indefinitely
Append-Event -EventLog "events.log" -Event $event
# Event log grows to gigabytes...
```

**Solution:** Implement compaction (snapshots + truncate old events)

---

## Performance Considerations

**File I/O Latency:**
- JSON deserialization: ~1-5ms (1KB file)
- File write (SSD): ~5-20ms
- File lock acquisition: ~1-50ms (contention-dependent)

**Optimization:**
- Use RAM disk for hot state files
- Batch updates (reduce file I/O frequency)
- Cache state in memory, persist periodically

---

## Security Implications

**Threat:** Malicious agent corrupts shared state

**Mitigation:**
- Validate updates (schema, range checks)
- Sign state files (detect tampering)
- Immutable event log (append-only)

---

## Troubleshooting Guide

### Issue: State File Corrupted

**Symptoms:** JSON parse errors, missing fields

**Diagnostics:**
```powershell
# Validate JSON
try {
    Get-Content $stateFile | ConvertFrom-Json
}
catch {
    Write-Error "Corrupted state file: $_"
}
```

**Solution:** Restore from snapshot

---

## PhiVector State Management

### Centralized State Directory Structure
```
C:\PhiVector\ipc\shared\state\
├── workflow-{id}.json          # Per-workflow state
├── agent-health.json           # Agent heartbeats
├── approval-queue.json         # Pending approvals
└── snapshots\                  # Periodic backups
```

### Agent Heartbeat (Liveness Detection)
```powershell
function Send-Heartbeat {
    param([string]$Agent)

    Update-StateOptimistic -StateFile "C:\PhiVector\ipc\shared\state\agent-health.json" -UpdateFunction {
        param($data)

        $data[$Agent] = @{
            lastSeen = Get-Date -Format "o"
            status = "alive"
        }

        return $data
    }
}

# Detect dead agents
function Get-DeadAgents {
    param([int]$TimeoutSeconds = 60)

    $health = Get-Content "C:\PhiVector\ipc\shared\state\agent-health.json" | ConvertFrom-Json -AsHashtable
    $threshold = (Get-Date).AddSeconds(-$TimeoutSeconds)

    $deadAgents = @()
    foreach ($agent in $health.Keys) {
        $lastSeen = [DateTime]::Parse($health[$agent].lastSeen)

        if ($lastSeen -lt $threshold) {
            $deadAgents += $agent
        }
    }

    return $deadAgents
}
```

---

## References

1. **Shapiro, M., et al.** "Conflict-free Replicated Data Types." SSS 2011.
2. **Lamport, L.** "Time, Clocks, and the Ordering of Events in a Distributed System." CACM 1978.
3. **Vogels, W.** "Eventually Consistent." ACM Queue 2008.
4. **Brewer, E.** "CAP Twelve Years Later: How the 'Rules' Have Changed." IEEE Computer 2012.
5. **Terry, D., et al.** "Managing Update Conflicts in Bayou, a Weakly Connected Replicated Storage System." SOSP 1995.

---

**End of State Synchronization & Management Guide**

**Next Steps:**
- Review [Agent Communication Protocols](../01_AGENT_COMMUNICATION/AGENT_COMMUNICATION_PROTOCOLS.md)
- See [Workflow Orchestration Patterns](../02_WORKFLOW_ORCHESTRATION/WORKFLOW_ORCHESTRATION_PATTERNS.md)
- Consult [PhiSync Framework Overview](../README.md)
