# PhiSHRI MCP Server - Greenfield Development Injection Prompt

**Copy this entire prompt to your AI coder to start the PhiSHRI MCP Rust project from scratch.**

---

## MISSION

Build a **greenfield MCP (Model Context Protocol) server** called `phishri-mcp` in Rust. This server provides AI agents with universal session continuity through semantic "door" codes - enabling instant context loading across sessions with zero drift.

**Critical constraint:** This MUST be built from scratch. Do NOT use any existing MCP server code. Do NOT copy from other MCP implementations. Clean room implementation only. I need 100% IP ownership for commercial release.

---

## WHAT IS PHISHRI?

PhiSHRI (Semantic Hash Repository Index) is a knowledge base of 268+ "doors" - JSON files containing curated context bundles that AI agents can load instantly via semantic codes.

**The problem it solves:**
- Traditional AI sessions lose context → 5-10 minutes to rebuild
- Context drift over sessions → information lost
- Token waste → re-explaining everything

**How PhiSHRI fixes it:**
- Door codes are persistent → "Read D05" gives same content every time
- Session state via bootstrap file → instant resumption
- 83% token reduction across sessions

**Example:**
```
Session 1: Agent reads D05, D06, D07 doors [12K tokens]
Session 2: Agent reads bootstrap + D08 only [5K tokens]
           References D05-D07 without re-reading
Total: 17K tokens vs 120K traditional approach
```

---

## EXISTING ASSETS (DO NOT MODIFY THESE)

**Door files:** 268 JSON files in `PhiSHRI/CONTEXTS/`
- SECURITY/ (25 doors: S01-S25)
- WORKFLOWS/ (145 doors: W01-W145)
- ARCHITECTURE/ (23 doors: R01-R23)
- TOOLS/ (44 doors: T01-T29, D01-D14, 800-840)
- AGENTS/ (9 doors: A00-A09)
- PROJECTS/ (6 doors: 000START, P01-P05)
- ERRORS/ (13 doors: E01-E13)

**Index files:**
- `PhiSHRI/INDEXES/HASH_TABLE.json` - 268 entries mapping door_code → file_path
- `PhiSHRI/INDEXES/SEMANTIC_MAP.json` - 1,292 mappings (aliases/paths → door_code)
- `PhiSHRI/INDEXES/NLP_PATTERNS.json` - Natural language patterns
- `PhiSHRI/INDEXES/ERROR_MATCHER.json` - Error → solution mapping
- `PhiSHRI/INDEXES/PREREQUISITES.json` - Dependency graph

**Bootstrap file:** Session state at `C:\Temp\VSCC_SESSION_BOOTSTRAP.md` (Windows) or `/tmp/phishri_bootstrap.md` (Unix)

---

## DOOR JSON SCHEMA

Every door follows this structure:
```json
{
  "door_code": "D05SILENT_INSTALL",
  "semantic_path": "TOOLS.DEPLOYMENT.SILENT",
  "aliases": ["silent install", "unattended install", "quiet mode"],
  "context_bundle": {
    "summary": "Silent installation patterns for automated software deployment...",
    "prerequisites": ["D01WIX", "D02SILENT"],
    "related_doors": ["D06ENTERPRISE", "D07GPO"],
    "onboarding": {
      "quick_start": "Use /quiet or /silent flags...",
      "full_context_path": "/PhiDEX/DEPLOYMENT_ALMANAC/07_SILENT_INSTALL/...",
      "common_patterns": ["msiexec /i app.msi /quiet /norestart", ...],
      "known_errors": ["NSIS /S is case-sensitive", ...]
    },
    "resources": {
      "docs": [...],
      "code": [...],
      "tests": [],
      "errors": []
    },
    "metadata": {
      "last_updated": "2025-11-22T02:00:00Z",
      "confidence": 1.0,
      "tags": ["deployment", "silent", "automation"],
      "category": "TOOLS",
      "subcategory": "DEPLOYMENT",
      "version": "1.0.0",
      "agent_affinity": ["VSCC", "DC", "TERMC"]
    }
  }
}
```

---

## MCP TOOLS TO IMPLEMENT (10 TOOLS)

### Core Door Operations (4 tools)

**1. phishri_read_door**
```json
{
  "name": "phishri_read_door",
  "description": "Read a specific door by code. Returns complete context bundle.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "door_code": {"type": "string", "description": "Door code (D05, W115, S01, etc.)"}
    },
    "required": ["door_code"]
  }
}
```

**2. phishri_list_doors**
```json
{
  "name": "phishri_list_doors",
  "description": "List available doors, optionally filtered by category.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "category": {"type": "string", "description": "Filter by category: SECURITY, TOOLS, WORKFLOWS, etc."},
      "limit": {"type": "integer", "default": 50}
    }
  }
}
```

**3. phishri_find_door**
```json
{
  "name": "phishri_find_door",
  "description": "Search for doors using natural language query. Returns matches with confidence scores.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {"type": "string", "description": "Search query (e.g., 'enterprise deployment')"},
      "limit": {"type": "integer", "default": 5}
    },
    "required": ["query"]
  }
}
```

**4. phishri_load_chain**
```json
{
  "name": "phishri_load_chain",
  "description": "Load multiple doors with automatic prerequisite resolution.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "door_codes": {"type": "array", "items": {"type": "string"}},
      "include_prerequisites": {"type": "boolean", "default": true}
    },
    "required": ["door_codes"]
  }
}
```

### Session State Operations (3 tools)

**5. phishri_get_bootstrap**
```json
{
  "name": "phishri_get_bootstrap",
  "description": "Get current session state from bootstrap file.",
  "inputSchema": {"type": "object", "properties": {}}
}
```

**6. phishri_update_bootstrap**
```json
{
  "name": "phishri_update_bootstrap",
  "description": "Update session state (progress, completed work, next steps).",
  "inputSchema": {
    "type": "object",
    "properties": {
      "progress": {"type": "string"},
      "batch_completed": {"type": "string"},
      "next_options": {"type": "array", "items": {"type": "string"}}
    }
  }
}
```

**7. phishri_session_checkpoint**
```json
{
  "name": "phishri_session_checkpoint",
  "description": "Create a session checkpoint with loaded doors for easy resumption.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "checkpoint_name": {"type": "string"},
      "doors_loaded": {"type": "array", "items": {"type": "string"}},
      "notes": {"type": "string"}
    },
    "required": ["checkpoint_name", "doors_loaded"]
  }
}
```

### Index Operations (3 tools)

**8. phishri_search_semantic**
```json
{
  "name": "phishri_search_semantic",
  "description": "Search by semantic path (e.g., TOOLS.DEPLOYMENT.SILENT).",
  "inputSchema": {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "Semantic path to resolve"}
    },
    "required": ["path"]
  }
}
```

**9. phishri_get_prerequisites**
```json
{
  "name": "phishri_get_prerequisites",
  "description": "Get prerequisite chain for a door (what to read first).",
  "inputSchema": {
    "type": "object",
    "properties": {
      "door_code": {"type": "string"}
    },
    "required": ["door_code"]
  }
}
```

**10. phishri_rebuild_indexes**
```json
{
  "name": "phishri_rebuild_indexes",
  "description": "Rebuild HASH_TABLE and SEMANTIC_MAP from door files.",
  "inputSchema": {"type": "object", "properties": {}}
}
```

---

## TECHNICAL REQUIREMENTS

### Rust Project Setup
```toml
# Cargo.toml
[package]
name = "phishri-mcp"
version = "0.1.0"
edition = "2021"
license = "MIT"
authors = ["Your Name"]
description = "Universal AI session continuity via semantic door codes"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1", features = ["full"] }
# Add others as needed, but minimize dependencies
```

### Directory Structure
```
phishri-mcp/
├── Cargo.toml
├── src/
│   ├── main.rs              # MCP stdio server entry point
│   ├── mcp/
│   │   ├── mod.rs           # MCP module
│   │   ├── protocol.rs      # JSON-RPC implementation (from scratch!)
│   │   ├── server.rs        # Stdio transport handling
│   │   └── tools.rs         # Tool definitions and schemas
│   ├── door/
│   │   ├── mod.rs           # Door module
│   │   ├── manager.rs       # Door CRUD operations
│   │   ├── schema.rs        # Door struct definitions
│   │   └── loader.rs        # File loading, caching
│   ├── index/
│   │   ├── mod.rs           # Index module
│   │   ├── hash_table.rs    # Door code → path lookup
│   │   ├── semantic_map.rs  # Alias/path → code lookup
│   │   └── builder.rs       # Index rebuilding
│   ├── search/
│   │   ├── mod.rs           # Search module
│   │   ├── nlp.rs           # Fuzzy text matching
│   │   └── prerequisite.rs  # DAG traversal for prereqs
│   ├── session/
│   │   ├── mod.rs           # Session module
│   │   ├── bootstrap.rs     # Bootstrap file management
│   │   └── checkpoint.rs    # Session checkpoints
│   └── config.rs            # Configuration (paths, etc.)
├── tests/
│   ├── door_tests.rs
│   ├── search_tests.rs
│   └── integration_tests.rs
└── README.md
```

### MCP Protocol Implementation (From Scratch)

Implement JSON-RPC 2.0 over stdio:

**Request format:**
```json
{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "phishri_read_door", "arguments": {"door_code": "D05"}}}
```

**Response format:**
```json
{"jsonrpc": "2.0", "id": 1, "result": {"content": [{"type": "text", "text": "...door content..."}]}}
```

**Error format:**
```json
{"jsonrpc": "2.0", "id": 1, "error": {"code": -32000, "message": "Door not found: D99"}}
```

**Stdio transport:**
- Read from stdin (line-buffered, one JSON message per line)
- Write to stdout (responses)
- Stderr for logging only
- Flush after each write

### Performance Targets
- Door read: <50ms
- Index load: <200ms (268 entries)
- NLP search: <500ms (across all doors)
- Chain load: <2s (10 doors with prerequisites)
- Bootstrap update: <100ms

---

## CRITICAL CONSTRAINTS

1. **GREENFIELD ONLY** - No code from existing MCP servers
2. **NO COPYING** - Implement MCP protocol from the spec, not from other implementations
3. **MINIMAL DEPENDENCIES** - Keep Cargo.toml lean (serde, tokio, basics only)
4. **CROSS-PLATFORM** - Must work on Windows, Mac, Linux
5. **NO HALLUCINATIONS** - Read actual door files, don't generate fake content
6. **IMMUTABLE DOORS** - Don't modify door content, only read
7. **MIT LICENSE** - All code must be original, licensable under MIT

---

## CONFIGURATION

The server needs to find PhiSHRI doors. Use these paths:

**Default paths (in order of priority):**
1. Environment variable: `PHISHRI_PATH`
2. Current directory: `./PhiSHRI/`
3. Windows default: `C:\Dev\PhiSHRI\PhiSHRI\`
4. Unix default: `~/PhiSHRI/`

**Bootstrap paths:**
1. Environment variable: `PHISHRI_BOOTSTRAP`
2. Windows: `C:\Temp\VSCC_SESSION_BOOTSTRAP.md`
3. Unix: `/tmp/phishri_bootstrap.md`

---

## STARTING POINT

Begin with:

1. **Create the Cargo project:**
   ```bash
   cargo new phishri-mcp
   cd phishri-mcp
   ```

2. **Implement basic MCP stdio server:**
   - Read JSON from stdin
   - Parse JSON-RPC request
   - Route to tool handlers
   - Return JSON-RPC response

3. **Implement tool discovery:**
   - Respond to `tools/list` with all 10 tools
   - Include proper schemas

4. **Implement first tool (`phishri_read_door`):**
   - Load HASH_TABLE.json
   - Look up door_code
   - Read door file
   - Return content

5. **Test with Claude Desktop:**
   - Add to `claude_desktop_config.json`
   - Verify tool appears
   - Test read_door works

Then continue with remaining tools.

---

## REFERENCE DOCUMENTS

For detailed prompts on each component, see:
`PhiSHRI/MCP_PROMPTS.md` - 50+ implementation prompts organized by phase

For door system details:
- `PhiSHRI/HOW_TO_USE.md` - Usage guide
- `PhiSHRI/ARCHITECTURE.md` - System architecture
- `PhiSHRI/INDEX.json` - Master catalog
- `PhiSHRI/CONTEXTS/PROJECTS/000START.json` - Onboarding door
- `PhiSHRI/CONTEXTS/PROJECTS/P05SESSION_CONT.json` - Session continuity door

---

## SUCCESS CRITERIA

**Phase 1 Complete When:**
- [ ] MCP server starts and responds to tool discovery
- [ ] `phishri_read_door` returns real door content
- [ ] Claude Desktop shows PhiSHRI tools
- [ ] No external MCP code used

**Phase 2 Complete When:**
- [ ] All 10 tools implemented
- [ ] NLP search works with fuzzy matching
- [ ] Prerequisite chains resolve correctly
- [ ] Bootstrap file management works

**Phase 3 Complete When:**
- [ ] Unit tests pass (90%+ coverage)
- [ ] Integration tests pass
- [ ] Performance targets met
- [ ] Documentation complete
- [ ] Ready for release under MIT license

---

## BEGIN

Start by creating the Rust project structure and implementing the MCP stdio protocol handler. The server should:

1. Read from stdin (JSON-RPC messages)
2. Parse and route to handlers
3. Return responses to stdout
4. Log errors to stderr

Show me the initial project structure with:
- `Cargo.toml`
- `src/main.rs` (entry point)
- `src/mcp/protocol.rs` (JSON-RPC handling)
- `src/mcp/server.rs` (stdio transport)

Make sure this compiles and can receive/respond to a basic MCP initialize request.
