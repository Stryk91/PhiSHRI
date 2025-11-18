# Cerebras 380B Tool Generation Prompts
## High-Value Development Tasks for DC-VSCC Automation Suite

---

## Prompt 1: Advanced Cross-Agent Coordination Framework

**Task:** Create a comprehensive multi-agent coordination system for Windows automation that enables three AI agents (STRYK, DC, VSCC) to collaborate efficiently with minimal token usage.

**Requirements:**
1. Design a JSON-based state management system that tracks:
   - Active tasks with turn-based progression (snapshot every 10 turns)
   - Agent responsibilities and handoff protocols
   - Context preservation across sessions
   - Token usage optimization (target: 66% reduction)

2. Implement a bidirectional messaging protocol using:
   - AutoHotkey v2 scripts for window-based message injection
   - File-based IPC for asynchronous coordination
   - PowerShell alert system (800Hz beep for task completion, 600Hz for info, 1000Hz triple-beep for critical)

3. Create turn-based workflow engine with:
   - Automatic context snapshots at configurable intervals
   - Session state rollback capability
   - Task queue management with priority levels
   - Completion verification and validation

4. Build token optimization layer:
   - 20 shorthand rules (abbrev common terms, drop articles, use symbols)
   - Compressed communication format (JSON over verbose text)
   - Batch command execution (use && not multiple messages)
   - Context-aware variable expansion

5. Implement error handling and recovery:
   - Failed tool execution retry logic with exponential backoff
   - Agent unstall detection and automatic recovery
   - Coordination deadlock detection
   - Fallback communication channels

**Deliverables:**
- Complete PowerShell module: `AgentCoordination.psm1` with functions for state management, messaging, and workflow control
- AutoHotkey v2 scripts: bidirectional messaging templates for DC↔VSCC, DC↔Browser AIs, VSCC↔Browser AIs
- JSON schemas: `SESSION_STATE.json`, `TASK_QUEUE.json`, `AGENT_REGISTRY.json`
- Documentation: Architecture diagram, API reference, usage examples, troubleshooting guide

**Technical Constraints:**
- Windows 10/11 compatibility
- Must work with AutoHotkey v2 (not v1 syntax)
- PowerShell 7+ for modern cmdlets
- File-based coordination (no network dependencies)
- Token budget: max 50 tokens per turn after optimization

**Success Metrics:**
- Token usage reduction: ≥66% compared to baseline
- Message delivery latency: <500ms for file-based IPC
- Context preservation: 100% across session boundaries
- Error recovery: automatic unstall within 3 turns

---

## Prompt 2: Browser Automation & AI Response Capture System

**Task:** Build a comprehensive browser automation framework that captures AI responses from web-based AI services (Claude, ChatGPT, Perplexity, Gemini, etc.) using Chrome DevTools Protocol.

**Requirements:**
1. Multi-method response capture system:
   - **WebSocket interception**: Capture streaming responses via CDP `Network.webSocketFrameReceived` events
   - **Server-Sent Events (SSE)**: Monitor `text/event-stream` responses for real-time updates
   - **Network monitoring**: Intercept fetch/xhr API calls with response body parsing
   - **Console API capture**: Hook console.log/debug/info for logged responses
   - **MutationObserver injection**: Detect DOM changes when AI adds content to page
   - **Periodic DOM scraping**: Fallback XPath/CSS selector-based extraction

2. Cross-browser support:
   - Chrome/Chromium via CDP (primary)
   - Edge via CDP (chromium-based)
   - Firefox via Marionette protocol (secondary)
   - Brave via CDP (privacy-focused option)

3. AI service detection and adaptation:
   - Auto-detect AI platform from URL/DOM structure
   - Platform-specific capture strategies (WebSocket for Claude, API polling for ChatGPT, etc.)
   - Response format normalization (convert all to unified JSON schema)
   - Conversation threading and turn tracking

4. Response processing pipeline:
   - Stream buffering for incomplete responses
   - Markdown/HTML parsing and cleaning
   - Code block extraction with language detection
   - Metadata capture (timestamp, model, tokens, latency)
   - Deduplication for multiple capture methods

5. AHK integration for message injection:
   - Coordinate-based text input clicking
   - Clipboard-based message passing
   - Enter key automation for submission
   - Window focus and maximize handling
   - Multi-monitor coordinate translation

**Deliverables:**
- Node.js capture engine: `ai_response_capture.js` with all 6 capture methods
- Platform adapters: `adapters/claude.js`, `adapters/chatgpt.js`, `adapters/perplexity.js`, `adapters/gemini.js`
- AHK messaging library: `AIMessaging.ahk` with functions for each platform
- Response normalizer: converts all formats to unified schema
- Real-time monitor: console UI showing live capture events
- Storage layer: SQLite database for conversation history
- Configuration: `capture_config.json` for per-platform settings

**Technical Constraints:**
- Chromium debug port: 9222 (configurable)
- Node.js 18+ with ESM modules
- Puppeteer-core (no bundled Chromium)
- AutoHotkey v2 for Windows automation
- Zero dependencies on browser extensions

**Success Metrics:**
- Response capture rate: ≥95% for all platforms
- Latency: <100ms from AI response to capture
- False positive rate: <1% (no duplicate captures)
- Platform coverage: 5+ AI services supported

---

## Prompt 3: Windows System Diagnostics & Repair Toolkit

**Task:** Create an intelligent diagnostics system that automatically detects and repairs common Windows issues affecting installers, services, and system stability.

**Requirements:**
1. System health scanner:
   - **SFC/DISM integration**: Run System File Checker and DISM repairs with progress tracking
   - **Service status checker**: Validate critical services (Windows Installer, TrustedInstaller, Windows Update)
   - **Registry integrity**: Scan for corrupted registry hives and repair
   - **Disk health**: Check for filesystem errors, bad sectors, quota issues
   - **UAC validation**: Verify UAC settings and correct misconfigurations
   - **Temp directory cleanup**: Clear corrupted temp files blocking installers

2. Installer troubleshooting:
   - Detect installer type (MSI, NSIS, Squirrel, Electron, InstallShield)
   - Test installer execution in sandbox environment
   - Capture detailed error logs from Windows Event Viewer
   - Analyze CBS.log for SFC failures
   - Check for Group Policy restrictions blocking installations
   - Verify code signing certificates and SmartScreen status

3. Automated repair workflows:
   - DISM RestoreHealth with fallback to Windows Update source
   - Service startup type correction (Manual→Automatic where needed)
   - Registry permission repair for HKLM\SOFTWARE keys
   - Windows Update catalog download for missing system files
   - Component store reset for severe corruption

4. Real-time monitoring:
   - Background service health checks (every 5 minutes)
   - Event log watcher for critical errors
   - Disk space threshold alerts
   - Service crash detection and auto-restart
   - Performance counter tracking (CPU, RAM, disk I/O)

5. Reporting and recommendations:
   - HTML diagnostic report with color-coded severity levels
   - Root cause analysis with confidence scores
   - Step-by-step repair instructions for manual intervention
   - PowerShell script generation for batch repairs
   - Reboot requirement detection and scheduling

**Deliverables:**
- PowerShell module: `SystemDiagnostics.psm1` with scan, repair, and monitoring functions
- CLI tool: `Invoke-SystemHealthCheck.ps1` for one-command diagnostics
- Scheduled task template: runs health checks automatically
- Event log parser: extracts relevant errors from Application/System logs
- Repair scripts: individual PS1 files for each repair type
- Dashboard: HTML report generator with charts and graphs
- Configuration: `diagnostics_config.json` for thresholds and schedules

**Technical Constraints:**
- Requires admin privileges for repair operations
- PowerShell 7+ for parallel job execution
- Windows 10 1809+ for DISM compatibility
- Must preserve system state before repairs (rollback capability)
- Non-destructive scans (no changes without confirmation)

**Success Metrics:**
- Detection accuracy: ≥90% for known issues
- Repair success rate: ≥80% without manual intervention
- Scan completion time: <5 minutes for full system check
- False alarm rate: <5% (no unnecessary repairs)

---

## Prompt 4: Persistent Task Execution Framework with Daemon Integration

**Task:** Build a robust background task execution system that survives reboots, handles long-running operations, and integrates with Windows Task Scheduler and custom daemon services.

**Requirements:**
1. Daemon service architecture:
   - PowerShell-based daemon runner: `AutomationDaemon.ps1`
   - Task queue persistence (survive process termination)
   - Health monitoring with automatic restart on crash
   - Log rotation and compression (max 100MB per log)
   - Remote management via named pipes

2. Task execution engine:
   - Support for PowerShell scripts, executables, AHK scripts, Node.js apps
   - Parallel task execution with configurable concurrency limits
   - Task dependencies and prerequisite validation
   - Timeout handling with graceful termination
   - Retry logic with exponential backoff (max 5 retries)
   - Task priority levels (Critical, High, Normal, Low, Idle)

3. State management:
   - Task history database (SQLite)
   - Execution logs with stdout/stderr capture
   - Result caching for idempotent operations
   - Checkpoint/resume for long-running tasks
   - Progress tracking with percentage completion

4. Windows integration:
   - Task Scheduler wrapper for scheduled execution
   - Windows Service installation and management
   - Event log integration for system-level logging
   - Performance counter publishing
   - WMI provider for remote monitoring

5. Monitoring and alerting:
   - Taskbar flash notifications for completion
   - Email/webhook alerts for failures
   - Real-time dashboard (web-based or console)
   - Resource usage tracking (CPU, memory, disk per task)
   - Deadlock detection and automatic task cancellation

**Deliverables:**
- Daemon core: `AutomationDaemon.ps1` with service wrapper
- Task client: `Submit-Task.ps1` for adding tasks to queue
- Task definitions: JSON schema for task configuration
- Service installer: `Install-AutomationService.ps1`
- Monitoring tools: `Get-TaskStatus.ps1`, `Watch-TaskQueue.ps1`
- Alert module: `TaskAlerts.psm1` with notification providers
- Web dashboard: Lightweight HTTP server for real-time monitoring
- Documentation: Service architecture, API reference, deployment guide

**Technical Constraints:**
- Must run as Windows Service or standalone process
- Support for both user-level and system-level execution
- Graceful shutdown (wait for task completion, max 30 seconds)
- Cross-session persistence (task queue survives logoff/reboot)
- Minimal external dependencies (only PowerShell built-ins)

**Success Metrics:**
- Task completion rate: ≥98% (excluding expected failures)
- Daemon uptime: ≥99.9% (self-healing from crashes)
- Task latency: <1 second from submission to execution start
- Resource overhead: <50MB RAM, <2% CPU when idle

---

## Prompt 5: Intelligent Code Generation & Refactoring Assistant

**Task:** Create an AI-assisted code generation system that produces production-ready PowerShell, JavaScript, and AutoHotkey scripts based on natural language descriptions, with built-in testing and validation.

**Requirements:**
1. Code generation engine:
   - Natural language to code translation
   - Multi-language support (PowerShell, JavaScript, AutoHotkey v2, Python, Bash)
   - Context-aware completion (understands existing codebase)
   - Design pattern application (singleton, factory, observer, etc.)
   - Error handling injection (try-catch, parameter validation)
   - Logging and debugging instrumentation

2. Code analysis and validation:
   - Static analysis (PSScriptAnalyzer for PowerShell, ESLint for JS)
   - Security scanning (detect command injection, XSS, path traversal)
   - Performance profiling (identify bottlenecks)
   - Complexity metrics (cyclomatic complexity, nesting depth)
   - Dependency analysis (unused imports, circular dependencies)

3. Refactoring capabilities:
   - Extract function/method from code block
   - Rename variables/functions across files
   - Convert callbacks to async/await
   - Optimize loops and conditionals
   - Remove dead code and unused variables
   - Modernize syntax (PowerShell v5 → v7, AHK v1 → v2)

4. Testing framework integration:
   - Unit test generation (Pester for PowerShell, Jest for JS)
   - Mock data creation for test cases
   - Code coverage analysis
   - Integration test scaffolding
   - Snapshot testing for UI components

5. Documentation generation:
   - Inline comment generation with context
   - Markdown API documentation
   - Parameter descriptions and examples
   - Usage guides with code samples
   - Changelog generation from git commits

**Deliverables:**
- Code generator: `New-CodeFromPrompt.ps1` with natural language parsing
- Analyzer: `Invoke-CodeAnalysis.ps1` with multi-language support
- Refactoring tools: `Refactor-Code.ps1` with various transformation options
- Test generator: `New-TestSuite.ps1` for automated test creation
- Documentation builder: `Build-Documentation.ps1` for API docs
- VS Code extension: syntax highlighting and IntelliSense integration
- Configuration: `codegen_config.json` for style preferences and rules

**Technical Constraints:**
- Must work offline (no cloud API calls required)
- Support incremental code generation (append to existing files)
- Preserve code formatting and style conventions
- Safe refactoring (no breaking changes without confirmation)
- Version control integration (git status awareness)

**Success Metrics:**
- Code correctness: ≥95% (generated code passes validation)
- Test coverage: ≥80% for generated code
- Refactoring safety: 100% (no unintended behavior changes)
- Documentation completeness: ≥90% (all public functions documented)

---

## Usage Instructions

**For each prompt:**
1. Copy the entire prompt (including Requirements and Deliverables sections)
2. Paste into Cerebras 380B interface
3. Add context: "Generate production-ready code for Windows 10/11 environment. Focus on robustness, error handling, and comprehensive documentation. Output should be copy-paste ready with no placeholders."
4. Review output and test thoroughly before integration
5. Document any modifications needed for your specific setup

**Optimization tips:**
- These prompts are designed to maximize value per task slot
- Each prompt generates multiple files and a complete subsystem
- Outputs can be directly integrated into the AutomationSuite framework
- Request code review and security analysis as follow-up tasks

**Integration priority:**
1. **Prompt 3** (Diagnostics) - Solves immediate installer issues
2. **Prompt 2** (Browser Automation) - Completes AI response capture
3. **Prompt 1** (Coordination) - Enhances DC-VSCC collaboration
4. **Prompt 4** (Task Execution) - Improves reliability
5. **Prompt 5** (Code Gen) - Accelerates future development
