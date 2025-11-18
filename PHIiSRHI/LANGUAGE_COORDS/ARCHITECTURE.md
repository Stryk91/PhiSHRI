# Multi-Agent Windows Coordination System - Architecture Documentation

## Overview

The Multi-Agent Windows Coordination System is a sophisticated framework designed to enable three AI agents (STRYK, DC, VSCC) to collaborate efficiently on Windows automation tasks. The system emphasizes minimal token usage, robust error handling, and seamless agent coordination through turn-based workflows.

## System Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    COORDINATION LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │    STRYK    │  │      DC     │  │    VSCC     │              │
│  │ Coordinator  │  │ Controller  │  │   Editor    │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│         │                │                │                    │
│         └────────────────┼────────────────┘                    │
│                          │                                     │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           POWERSHELL COORDINATION ENGINE                    │ │
│  │  • State Management  • Workflow Control  • Token Opt        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────┼─────────────────────────────────────┐
│    MESSAGING LAYER      │     EXECUTION LAYER                 │
├─────────────────────────┼─────────────────────────────────────┤
│  ┌─────────────────────┐│  ┌─────────────────────────────────┐ │
│  │   AUTOHOTKEY BRIDGE  ││  │     WINDOWS INTEGRATION          │ │
│  │  • Window Injection  ││  │  • Process Control               │ │
│  │  • File IPC          ││  │  • UI Automation                 │ │
│  │  • Message Queues    ││  │  • VSCode API                    │ │
│  └─────────────────────┘│  └─────────────────────────────────┘ │
└─────────────────────────┴─────────────────────────────────────┘
                          │
┌─────────────────────────┼─────────────────────────────────────┐
│    STORAGE LAYER        │     MONITORING LAYER                │
├─────────────────────────┼─────────────────────────────────────┤
│  ┌─────────────────────┐│  ┌─────────────────────────────────┐ │
│  │   JSON STATE STORE   ││  │     SYSTEM HEALTH                │ │
│  │  • Session State     ││  │  • Performance Metrics           │ │
│  │  • Task Queue        ││  │  • Error Recovery                │ │
│  │  • Agent Registry    ││  │  • Token Usage Tracking          │ │
│  └─────────────────────┘│  └─────────────────────────────────┘ │
└─────────────────────────┴─────────────────────────────────────┘
```

### Agent Responsibilities

#### STRYK (Strategic Coordinator)
- **Role**: Master coordinator and decision maker
- **Responsibilities**:
  - Workflow orchestration and task distribution
  - Deadlock detection and resolution
  - Token usage optimization
  - Error recovery and system health monitoring
  - Session state management
- **Communication**: PowerShell alerts, file-based IPC
- **Resource Limits**: 128MB RAM, 25% CPU

#### DC (Desktop Controller)
- **Role**: UI automation and message routing
- **Responsibilities**:
  - Window management and control
  - Cross-application message injection
  - User input simulation
  - Browser automation coordination
  - Inter-agent message routing
- **Communication**: AutoHotkey window injection, file IPC
- **Resource Limits**: 256MB RAM, 50% CPU

#### VSCC (Visual Code Coordinator)
- **Role**: Code generation and file operations
- **Responsibilities**:
  - Dynamic code generation and execution
  - File system operations
  - Content analysis and processing
  - VSCode integration and API usage
  - Script deployment and validation
- **Communication**: VSCode API, file IPC
- **Resource Limits**: 512MB RAM, 75% CPU

## Communication Protocols

### Turn-Based Coordination

The system operates on a turn-based model where only one agent is active at any given time:

```
Turn 1: STRYK (Planning) → Turn 2: DC (Execution) → Turn 3: VSCC (Processing) → Turn 4: STRYK...
```

- **Turn Duration**: 1000ms maximum
- **Auto-Advance**: Enabled by default
- **Stall Detection**: 3 turns without activity triggers recovery

### Message Types

1. **Task Messages**: Work assignments and completions
2. **Handoff Messages**: Agent transition coordination
3. **Error Messages**: Failure reports and recovery requests
4. **Status Messages**: Health checks and state updates
5. **Data Messages**: Content and results exchange

### Communication Channels

#### DC ↔ VSCC (AutoHotkey Injection)
- **Protocol**: Window-based message injection
- **Target**: VSCode window for direct code injection
- **Fallback**: File-based message queue
- **Latency**: <500ms

#### DC ↔ Browser AI (Window Messages)
- **Protocol**: Browser console injection via developer tools
- **Target**: Chrome/Firefox/Edge console
- **Fallback**: JavaScript file injection
- **Latency**: <500ms

#### VSCC ↔ Browser AI (File-Based)
- **Protocol**: JSON file exchange in shared directory
- **Target**: Browser agent file monitoring
- **Fallback**: Direct browser injection
- **Latency**: <500ms

## State Management

### Session State Structure

```json
{
  "session_id": "sess_001",
  "turn_counter": 0,
  "active_agents": {
    "STRYK": {"status": "active", "token_usage": 0},
    "DC": {"status": "idle", "token_usage": 0},
    "VSCC": {"status": "idle", "token_usage": 0}
  },
  "shared_context": {
    "windows": {},
    "variables": {},
    "clipboard": ""
  },
  "snapshots": [...]
}
```

### Task Queue Structure

```json
{
  "tasks": [
    {
      "task_id": "task_001",
      "priority": 1,
      "assigned_agent": "DC",
      "status": "pending",
      "dependencies": [],
      "handoff_agent": "VSCC",
      "completion_criteria": {...}
    }
  ]
}
```

## Token Optimization Strategy

### Shorthand Rules (20+ abbreviations)
- Common words: "the" → "", "and" → "&", "for" → "4"
- Technical terms: "function" → "fn", "variable" → "var"
- System terms: "coordination" → "coord", "automation" → "auto"

### Compression Techniques
1. **JSON over verbose text**: Structured data format
2. **Symbol replacement**: Use operators instead of words
3. **Batch operations**: Combine multiple commands
4. **Context variables**: Reuse common references

### Target Metrics
- **Baseline**: 150 tokens per turn
- **Target**: 50 tokens per turn (66% reduction)
- **Maximum**: 75 tokens in emergency mode

## Error Handling and Recovery

### Error Classification
1. **Network/Communication**: Retry with exponential backoff
2. **File System**: Retry with linear backoff
3. **Agent Errors**: Immediate recovery attempt
4. **System Errors**: Maximum retry with escalation

### Recovery Strategies
1. **Agent Reset**: Clear agent state and reinitialize
2. **Task Requeue**: Move failed tasks to retry queue
3. **State Rollback**: Revert to last known good snapshot
4. **Emergency Mode**: Degraded functionality with minimal features

### Deadlock Prevention
- **Circular Dependencies**: Forbidden by design
- **Mutual Exclusion**: Time-limited locks
- **Hold and Wait**: Minimized through queuing
- **No Preemption**: Limited exceptions for critical tasks

## Performance Characteristics

### Latency Targets
- **Message Delivery**: <500ms for file-based IPC
- **Agent Handoff**: <500ms coordination time
- **State Snapshot**: <200ms creation time
- **Recovery Response**: <3 turns for unstall recovery

### Resource Utilization
- **Memory Usage**: <896MB total (128+256+512 MB per agent)
- **CPU Usage**: <150% total across all agents
- **Disk I/O**: Minimal, optimized for SSD
- **Network**: None required (local file-based)

### Scalability Limits
- **Concurrent Tasks**: 50 maximum in queue
- **Active Sessions**: 1 per system instance
- **Message Rate**: 10 messages per second per channel
- **Snapshot History**: 10 rolling snapshots

## Security Considerations

### Isolation
- **Agent Sandboxing**: Each agent operates in isolated context
- **File Permissions**: Restricted access to coordination directories
- **Process Isolation**: Separate processes for AutoHotkey scripts
- **Memory Boundaries**: Enforced per-agent limits

### Data Protection
- **Local Storage Only**: No network data transmission
- **Temporary Files**: Automatic cleanup after configurable intervals
- **Sensitive Data**: Exclusion from snapshots and logs
- **Access Control**: Windows user permission enforcement

## Integration Points

### External Dependencies
- **PowerShell 7+**: Core coordination engine
- **AutoHotkey v2**: Window injection and UI automation
- **VSCode**: Code execution and file operations
- **Web Browsers**: Content extraction and automation

### API Interfaces
- **PowerShell Module**: `AgentCoordination.psm1`
- **AutoHotkey Scripts**: Inter-agent messaging
- **JSON Schemas**: Configuration and state management
- **File System**: IPC and coordination storage

## Deployment Architecture

### Directory Structure
```
/multi-agent-system/
├── AgentCoordination.psm1      # Core PowerShell module
├── Startup.ps1                 # System bootstrap
├── config/
│   ├── config.json            # System configuration
│   ├── coordination_rules.json # Handoff and workflow rules
│   ├── token_optimization.json # Token reduction rules
│   ├── SESSION_STATE.json     # Current session state
│   ├── TASK_QUEUE.json        # Task management
│   └── AGENT_REGISTRY.json    # Agent definitions
├── scripts/
│   ├── DC_VSCC_Messaging.ahk   # DC↔VSCC communication
│   ├── DC_Browser_Messaging.ahk # DC↔Browser communication
│   └── VSCC_Browser_Messaging.ahk # VSCC↔Browser communication
├── logs/                       # System logs
├── cache/                      # Temporary content storage
├── temp/                       # Runtime temporary files
└── backup/                     # State snapshots
```

### Runtime Processes
1. **PowerShell Main Process**: Coordination engine
2. **AutoHotkey DC-VSCC**: Window injection service
3. **AutoHotkey DC-Browser**: Browser communication service
4. **AutoHotkey VSCC-Browser**: Content coordination service
5. **Background Monitor**: Health and performance tracking

## Monitoring and Observability

### Key Metrics
- **Turn Progress**: Current turn number and active agent
- **Task Status**: Pending, active, and completed task counts
- **Token Usage**: Per-agent and total token consumption
- **Error Rates**: Failure types and recovery success
- **Performance**: Message latency and response times

### Health Checks
- **Agent Availability**: Ping/response verification
- **Service Status**: AutoHotkey process monitoring
- **Resource Usage**: Memory and CPU threshold alerts
- **Disk Space**: Storage availability warnings
- **System Load**: Performance impact monitoring

This architecture provides a robust, scalable foundation for multi-agent Windows automation while maintaining strict token efficiency requirements and comprehensive error handling capabilities.