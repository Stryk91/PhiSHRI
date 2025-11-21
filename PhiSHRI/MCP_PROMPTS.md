# PhiSHRI MCP Development Prompts

**Purpose:** Ready-to-use prompts for AI agents helping build PhiSHRI MCP server from scratch.

---

## 1. Architecture & Design Prompts

### P1.1: Initial Rust Project Structure
```
I'm building a PhiSHRI MCP server from scratch in Rust. This will be a greenfield project (no dependencies on existing MCP servers) implementing the MCP stdio protocol.

Requirements:
- Implement MCP JSON-RPC protocol from spec
- Manage 500+ door files (JSON format)
- Provide 10 MCP tools for door operations
- Session state management via bootstrap files
- Fast NLP search across door content
- Parallel door loading with prerequisite resolution

Create the initial Cargo.toml and src/ directory structure with:
1. Main MCP stdio server
2. Door manager module (CRUD operations)
3. Index manager (HASH_TABLE, SEMANTIC_MAP)
4. NLP matcher (fuzzy search)
5. Bootstrap manager (session state)
6. Prerequisite resolver (door chains)
7. MCP protocol handler (JSON-RPC)

Show file tree and explain each module's responsibility.
```

### P1.2: MCP Protocol Implementation Design
```
Design a clean-room implementation of MCP stdio protocol in Rust for PhiSHRI.

Reference the MCP spec (https://modelcontextprotocol.io/docs/specification/basic/transports#stdio)

Need to implement:
- JSON-RPC 2.0 message format
- Request/Response/Notification handling
- Tool discovery (list available tools)
- Tool execution (call handlers)
- Error handling (standard error codes)
- Stdio transport (read from stdin, write to stdout)

Show the core trait definitions and message structures. No external MCP library dependencies - build from scratch.
```

### P1.3: Door Index Architecture
```
Design the indexing system for PhiSHRI doors:

Current state:
- 268 door files in CONTEXTS/ subdirectories
- HASH_TABLE.json: door_code → file_path (268 entries)
- SEMANTIC_MAP.json: aliases/paths → door_code (1,292 mappings)

Need efficient in-memory structures for:
1. Door code lookup (O(1) by hash)
2. Semantic path search (O(1) by path)
3. Fuzzy NLP matching (fast text search)
4. Prerequisite graph traversal (DAG)
5. Category filtering (by prefix: S##, W##, R##, etc.)

Design Rust structs and algorithms. Target: <100ms lookup, <500ms NLP search across 500+ doors.
```

---

## 2. Implementation Prompts

### P2.1: Door Manager Implementation
```
Implement the door manager module for PhiSHRI MCP.

Location: PhiSHRI/CONTEXTS/ (7 subdirectories: SECURITY/, TOOLS/, WORKFLOWS/, etc.)
Format: JSON files with schema:
{
  "door_code": "D05SILENT_INSTALL",
  "semantic_path": "TOOLS.DEPLOYMENT.SILENT",
  "aliases": ["silent install", "unattended"],
  "context_bundle": {
    "summary": "...",
    "prerequisites": ["D01WIX"],
    "related_doors": ["D06ENTERPRISE"],
    "onboarding": {...},
    "resources": {...},
    "metadata": {...}
  }
}

Implement:
1. read_door(door_code: &str) -> Result<Door>
2. write_door(door: &Door) -> Result<()>
3. list_doors(category: Option<&str>) -> Vec<DoorCode>
4. validate_door(door: &Door) -> Result<()>
5. get_prerequisites(door_code: &str) -> Vec<DoorCode>

Use serde_json for parsing. Handle errors gracefully. Return structured errors for MCP.
```

### P2.2: Index Builder Implementation
```
Implement index rebuilding for PhiSHRI (replaces Python script).

Input: 268+ door files in PhiSHRI/CONTEXTS/
Output:
- HASH_TABLE.json: {"mappings": {"D05SILENT_INSTALL": "CONTEXTS/TOOLS/D05SILENT_INSTALL.json", ...}}
- SEMANTIC_MAP.json: {"mappings": {"TOOLS.DEPLOYMENT.SILENT": "D05SILENT_INSTALL", "silent install": "D05SILENT_INSTALL", ...}}

Requirements:
1. Scan all CONTEXTS subdirectories recursively
2. Parse each JSON door file
3. Extract door_code, semantic_path, aliases
4. Build hash table (code → path)
5. Build semantic map (path + aliases → code)
6. Write indexes as pretty-printed JSON
7. Report: files scanned, success/error counts

Implement rebuild_indexes() -> Result<IndexStats>. Handle malformed JSON gracefully.
```

### P2.3: NLP Fuzzy Matcher Implementation
```
Implement NLP fuzzy matching for door search in PhiSHRI.

Requirements:
1. Search across door codes, semantic paths, aliases, summaries
2. Handle typos (edit distance ≤2)
3. Case-insensitive
4. Return results with confidence scores (0.0-1.0)
5. Sort by relevance
6. Target: <500ms for 500 doors

Example queries:
- "deployment" → [D05SILENT_INSTALL (0.95), D06ENTERPRISE (0.92), ...]
- "securty" (typo) → [S01SEC (0.85), S05SECRETS (0.82), ...]
- "how to write files windows" → [800WINMCP (0.88), ...]

Use algorithms: TF-IDF, Levenshtein distance, or similar. No external ML libraries - keep it simple and fast.

Implement fuzzy_search(query: &str, limit: usize) -> Vec<SearchResult>
```

### P2.4: Bootstrap Manager Implementation
```
Implement session state management via bootstrap file.

Bootstrap location: C:\Temp\VSCC_SESSION_BOOTSTRAP.md (Windows) or /tmp/phishri_bootstrap.md (Unix)

Operations needed:
1. read_bootstrap() -> Result<BootstrapState>
2. write_bootstrap(state: &BootstrapState) -> Result<()>
3. update_progress(completed: &str, next: &str) -> Result<()>
4. get_current_doors() -> Vec<DoorCode>
5. append_batch_completion(batch: &BatchInfo) -> Result<()>

Bootstrap structure (Markdown):
- Mission context
- Current progress (door counts)
- Last batch completed (detailed)
- Next batch options (5 suggestions)
- Important notes and commands

Parse Markdown sections, update programmatically. Maintain human-readable format.
```

### P2.5: Prerequisite Resolver Implementation
```
Implement door prerequisite chain resolution (DAG traversal).

Each door has prerequisites field: ["D01WIX", "D02SILENT"]
Need to:
1. Load door and all prerequisites recursively
2. Topological sort (prerequisites first)
3. Detect circular dependencies
4. Parallel loading where possible
5. Cache loaded doors (don't re-read)

Example: load_chain("D06ENTERPRISE")
→ Loads: [D01WIX, D02SILENT, D05SILENT_INSTALL, D06ENTERPRISE] in correct order

Implement:
- resolve_prerequisites(door_code: &str) -> Result<Vec<DoorCode>> (sorted)
- load_chain(door_code: &str) -> Result<Vec<Door>> (parallel where possible)
- detect_cycles(door_code: &str) -> Option<Vec<DoorCode>>

Use async/await for parallel loading. Target: <2 seconds for 10-door chain.
```

---

## 3. MCP Tool Implementation Prompts

### P3.1: phishri_read_door Tool
```
Implement the phishri_read_door MCP tool.

Tool definition:
{
  "name": "phishri_read_door",
  "description": "Read a specific door by code (e.g., D05SILENT_INSTALL). Returns complete door context bundle.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "door_code": {"type": "string", "description": "Door code (D05, W115, S01, etc.)"}
    },
    "required": ["door_code"]
  }
}

Implementation:
1. Validate door_code format (regex: ^[A-Z0-9]{2,10}$)
2. Look up in HASH_TABLE
3. Read JSON file from disk
4. Parse and validate schema
5. Return full door content as JSON string
6. Handle errors: door not found, malformed JSON, file read errors

Return MCP tool result format with content and optional error.
```

### P3.2: phishri_find_door Tool
```
Implement the phishri_find_door MCP tool for NLP search.

Tool definition:
{
  "name": "phishri_find_door",
  "description": "Search for doors using natural language query. Returns top matches with confidence scores.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {"type": "string", "description": "Search query (e.g., 'enterprise deployment')"},
      "limit": {"type": "integer", "default": 5, "description": "Max results to return"}
    },
    "required": ["query"]
  }
}

Implementation:
1. Use fuzzy_search from NLP matcher
2. Search across door codes, paths, aliases, summaries
3. Return top N results with:
   - door_code
   - semantic_path
   - confidence (0.0-1.0)
   - matched_field (what matched: "alias", "summary", etc.)
   - snippet (excerpt showing match)
4. Sort by confidence descending

Handle empty results gracefully. Return as JSON array.
```

### P3.3: phishri_load_chain Tool
```
Implement the phishri_load_chain MCP tool for parallel loading.

Tool definition:
{
  "name": "phishri_load_chain",
  "description": "Load multiple doors in parallel with automatic prerequisite resolution.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "door_codes": {
        "type": "array",
        "items": {"type": "string"},
        "description": "List of door codes to load"
      },
      "include_prerequisites": {
        "type": "boolean",
        "default": true,
        "description": "Automatically load prerequisites"
      }
    },
    "required": ["door_codes"]
  }
}

Implementation:
1. For each door code, resolve prerequisites if enabled
2. Build complete list (deduped)
3. Topologically sort by dependencies
4. Load in parallel where no dependency conflicts
5. Return array of doors in load order
6. Include metadata: total_doors, load_time_ms, prerequisite_count

Use async/await with tokio or async-std. Target: <2s for 10 doors.
```

### P3.4: phishri_session_state Tools
```
Implement session state management tools.

Tool 1: phishri_get_bootstrap
{
  "name": "phishri_get_bootstrap",
  "description": "Get current session state from bootstrap file",
  "inputSchema": {"type": "object", "properties": {}}
}
Returns: {current_doors: 268, last_batch: "8A", next_options: [...]}

Tool 2: phishri_update_bootstrap
{
  "name": "phishri_update_bootstrap",
  "description": "Update session state (progress, completed work, next steps)",
  "inputSchema": {
    "type": "object",
    "properties": {
      "progress_update": {"type": "string"},
      "batch_completed": {"type": "string"},
      "next_batch_options": {"type": "array", "items": {"type": "string"}}
    }
  }
}

Implementation:
1. Read bootstrap Markdown file
2. Parse sections (regex or simple string matching)
3. Update relevant sections
4. Write back preserving format
5. Return success/error
```

---

## 4. Testing & Validation Prompts

### P4.1: Unit Test Suite
```
Create comprehensive unit tests for PhiSHRI MCP components.

Test modules needed:
1. door_manager_tests.rs
   - read_door: valid code, invalid code, malformed JSON
   - write_door: create new, overwrite existing, invalid schema
   - list_doors: all, by category, empty results
   - validate_door: schema validation edge cases

2. index_builder_tests.rs
   - rebuild_indexes: full rebuild, incremental, error handling
   - hash_table correctness (268 entries)
   - semantic_map correctness (1,292 mappings)

3. nlp_matcher_tests.rs
   - fuzzy_search: exact matches, typos, synonyms
   - confidence scoring accuracy
   - performance (500 doors in <500ms)

4. prerequisite_resolver_tests.rs
   - linear chain, branching, circular detection
   - parallel loading correctness
   - cache effectiveness

Use cargo test. Generate test data fixtures. Target: 95%+ coverage.
```

### P4.2: Integration Testing
```
Create integration tests for PhiSHRI MCP server end-to-end.

Test scenarios:
1. Server startup and tool discovery
   - Start server, send initialize request
   - Verify all 10 tools are listed
   - Check tool schemas are correct

2. Door read workflow
   - Call phishri_read_door("D05SILENT_INSTALL")
   - Verify complete door returned
   - Check parsing correctness

3. Search workflow
   - Call phishri_find_door("deployment")
   - Verify top results include D05, D06
   - Check confidence scores reasonable

4. Chain loading workflow
   - Call phishri_load_chain(["D06ENTERPRISE"])
   - Verify prerequisites loaded (D05, D01, D02)
   - Check load order correct

5. Session state workflow
   - Get bootstrap, update progress, verify changes

Use MCP client library or raw JSON-RPC over stdio. Mock external dependencies.
```

### P4.3: Performance Benchmarking
```
Create performance benchmarks for PhiSHRI MCP.

Benchmark targets:
1. Door read: <50ms (single door)
2. Index load: <200ms (268 entries)
3. NLP search: <500ms (500 doors)
4. Chain load: <2s (10 doors with prerequisites)
5. Bootstrap update: <100ms

Use criterion.rs for benchmarking. Test with realistic data:
- 268 current doors
- 500 projected doors
- 1,000+ semantic map entries

Identify bottlenecks:
- File I/O (use caching?)
- JSON parsing (use simd-json?)
- String matching (optimize algorithm?)

Generate benchmark report with graphs.
```

---

## 5. Debugging & Troubleshooting Prompts

### P5.1: MCP Protocol Debugging
```
I'm getting MCP protocol errors when testing PhiSHRI server. Help me debug.

Error symptoms:
[Describe: connection refused, malformed JSON, tool not found, etc.]

Current implementation:
[Paste relevant code]

MCP stdio transport requirements:
- Read from stdin line-by-line (JSON-RPC messages)
- Write to stdout (JSON-RPC responses)
- Stderr for logging only
- One message per line
- UTF-8 encoding

Debug checklist:
1. JSON-RPC format correct? (id, jsonrpc: "2.0", method, params)
2. Stdio buffering issues? (flush after write)
3. Error handling complete? (proper error objects)
4. Tool schemas valid? (match inputSchema spec)

Help me identify the issue and fix it.
```

### P5.2: Door Index Corruption
```
PhiSHRI indexes (HASH_TABLE or SEMANTIC_MAP) are corrupted or out of sync. Help me diagnose and fix.

Symptoms:
- Door not found errors for existing doors
- Semantic search returns wrong results
- Index counts don't match door file count

Current state:
- Expected doors: 268
- HASH_TABLE entries: [check]
- SEMANTIC_MAP entries: [check]
- Actual files in CONTEXTS/: [check]

Debug steps:
1. Validate JSON syntax (jq . HASH_TABLE.json)
2. Check for missing entries (compare file list vs index)
3. Check for duplicate entries (unique door codes?)
4. Verify semantic_path → door_code mappings

Provide commands to validate and rebuild indexes correctly.
```

### P5.3: Performance Bottleneck
```
PhiSHRI MCP is slower than expected. Help me profile and optimize.

Current performance:
- Door read: [X]ms (target: <50ms)
- NLP search: [X]ms (target: <500ms)
- Chain load: [X]s (target: <2s)

Possible issues:
- File I/O blocking (use async?)
- JSON parsing slow (use faster parser?)
- Index loading on every request (cache in memory?)
- String matching inefficient (better algorithm?)
- No parallelization (use tokio spawn?)

Profiling approach:
1. Use cargo flamegraph or perf
2. Identify hot paths
3. Add timing instrumentation
4. Compare with baseline

Help me identify bottlenecks and implement optimizations.
```

---

## 6. Documentation Prompts

### P6.1: API Documentation
```
Generate comprehensive API documentation for PhiSHRI MCP server.

Include:
1. Overview and architecture
2. Installation (cargo install phishri-mcp)
3. Configuration (bootstrap location, door paths)
4. MCP tool reference:
   - Tool name, description
   - Input schema with examples
   - Output format
   - Error codes
   - Example usage (JSON-RPC request/response)
5. Performance characteristics
6. Troubleshooting guide

Format: Markdown with code examples. Target audience: developers integrating PhiSHRI MCP.
```

### P6.2: User Guide
```
Create a user guide for AI agents using PhiSHRI MCP.

Include:
1. What is PhiSHRI? (session continuity protocol)
2. How to connect (MCP client setup)
3. Common workflows:
   - Reading a door by code
   - Searching for doors
   - Loading prerequisite chains
   - Managing session state
4. Best practices:
   - When to use which tool
   - Parallel loading strategies
   - Session checkpoint patterns
5. Examples:
   - Resume work from previous session
   - Handoff between agents
   - Cross-platform continuity

Format: Tutorial style with step-by-step examples.
```

---

## 7. Advanced Feature Prompts

### P7.1: Door Versioning
```
Design a door versioning system for PhiSHRI.

Requirements:
- Doors can be updated over time (content changes)
- Maintain history of changes (who, when, what)
- Allow rollback to previous versions
- Semantic versioning (major.minor.patch)
- Backward compatibility (old door codes still work)

Proposed structure:
- Add "version" field to door JSON
- Store history in HISTORY/ subdirectory
- Update HASH_TABLE with version info
- Tool: phishri_get_door_version(door_code, version)

Design the schema and migration path from current (unversioned) doors.
```

### P7.2: Remote Door Repository
```
Design a remote door repository for PhiSHRI (network MCP).

Requirements:
- Central door server (HTTP API)
- Local caching for offline use
- Sync protocol (pull updates)
- Team sharing (multiple agents, same doors)
- Access control (public vs private doors)

Architecture:
- Server: REST API for door CRUD
- Client: MCP server with remote backend
- Sync: periodic pull, webhooks for push
- Cache: local SQLite for offline

Design API endpoints and sync protocol. Consider: authentication, versioning, conflict resolution.
```

### P7.3: Door Analytics
```
Implement usage analytics for PhiSHRI doors.

Track:
- Door read frequency (which doors used most)
- Search queries (what users search for)
- Prerequisite paths (common chains)
- Session patterns (typical workflows)
- Performance metrics (read times, search times)

Storage:
- Local SQLite database
- Append-only event log
- Aggregate statistics

Tools to add:
- phishri_get_stats() → usage summary
- phishri_popular_doors(limit) → top N doors
- phishri_session_patterns() → common workflows

Privacy: No user identification, aggregate only. Opt-in analytics.
```

---

## 8. Quick Fix Prompts

### P8.1: "Dependency Hell"
```
I'm getting Rust dependency conflicts in Cargo.toml. Help me resolve.

Error:
[Paste cargo build error]

Current dependencies:
[Paste Cargo.toml [dependencies] section]

Need compatible versions for:
- serde + serde_json (JSON parsing)
- tokio (async runtime)
- Other [specify]

Provide compatible version set and explain why conflicts occurred.
```

### P8.2: "JSON Parse Errors"
```
Getting JSON parsing errors when reading door files.

Error: [Paste error message]
Door file: [Which door]

Common issues:
- Unescaped quotes in strings
- Trailing commas
- Unicode issues
- Invalid escape sequences

Provide regex or tool to validate all 268 door files and fix common issues.
```

### P8.3: "MCP Client Can't Connect"
```
MCP client can't connect to PhiSHRI server. Debugging stdio transport.

Client: [Claude Desktop / VSCode / Custom]
Server: Running phishri-mcp in terminal

Symptoms:
- No response to initialize
- Connection timeout
- Tool discovery fails

Debug approach:
1. Test server manually (echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | phishri-mcp)
2. Check stderr for errors
3. Verify stdio not buffered
4. Test with simple MCP client

Help me diagnose and fix connection issues.
```

---

## 9. Code Review Prompts

### P9.1: Rust Idioms Review
```
Review my PhiSHRI Rust code for idiomatic patterns.

Code:
[Paste code section]

Check for:
- Error handling (Result types used correctly?)
- Ownership/borrowing (unnecessary clones?)
- Iterator patterns (for vs iter().map()?)
- Option handling (unwrap vs pattern matching?)
- Async/await usage (blocking calls in async?)
- Naming conventions (snake_case, CamelCase?)

Suggest improvements for readability and performance.
```

### P9.2: Security Review
```
Security review of PhiSHRI MCP server.

Concerns:
- File system access (path traversal attacks?)
- Input validation (door_code injection?)
- Resource limits (DOS via large chains?)
- Privilege escalation (writing to arbitrary paths?)
- Information disclosure (error messages reveal paths?)

Code to review:
[Paste sensitive sections: file I/O, path handling, etc.]

Identify vulnerabilities and suggest mitigations.
```

---

## 10. Optimization Prompts

### P10.1: Memory Optimization
```
Optimize memory usage for PhiSHRI MCP server handling 500+ doors.

Current memory profile:
- Index structures: [estimate MB]
- Door cache: [estimate MB]
- Search index: [estimate MB]

Optimization strategies:
- Use Cow<str> for zero-copy where possible
- Lazy load doors (don't cache all in memory)
- Compress search index (suffix array?)
- Share string data (Arc<str>?)

Profile with cargo-bloat and optimize largest consumers.
```

### P10.2: Build Size Optimization
```
Reduce PhiSHRI MCP binary size for distribution.

Current: [X] MB
Target: <10 MB

Optimization techniques:
- Strip symbols (cargo build --release)
- Use upx compression
- Minimize dependencies (remove unused features)
- Link-time optimization (lto = true)
- Binary size profiling (cargo-bloat)

Provide Cargo.toml profile settings and build commands for minimal size.
```

---

## Usage Instructions

**How to use these prompts:**

1. **Choose the relevant prompt** for your current task
2. **Fill in placeholders** [in brackets] with actual data
3. **Paste into AI agent** (Claude Desktop, VS Code Claude, etc.)
4. **Iterate** - if response isn't perfect, follow up with clarifications
5. **Save output** to appropriate file/module

**Best practices:**
- Use one prompt at a time (focused tasks)
- Provide context (paste relevant code, errors)
- Combine prompts for complex tasks (P2.1 + P4.1 for implementation + tests)
- Update prompts as project evolves

**Priority order for initial implementation:**
1. P1.1, P1.2 (Architecture)
2. P2.1, P2.2 (Core functionality)
3. P3.1, P3.2 (Basic MCP tools)
4. P4.1, P4.2 (Testing)
5. P6.1, P6.2 (Documentation)
6. Advanced features as needed

---

**Created:** 2024-11-22
**Version:** 1.0
**For:** PhiSHRI MCP Server Development
