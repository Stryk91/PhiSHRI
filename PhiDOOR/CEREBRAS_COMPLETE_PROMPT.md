# PhiDOOR Implementation - Complete Prompt for Cerebras GLM 4.6 357B

**Target Model:** Cerebras GLM 4.6 357B (3M token context, 2 VMs)
**Task:** Build the Semantic Self-Hashing Radial Index (PhiDOOR)
**Context Window Usage:** ~3.5M tokens input, 500K tokens for generation
**Parallel Processing:** 2 VMs for optimal throughput

---

## CORE MISSION

Build **PhiDOOR** - The Keymaster's Index System that enables **instant AI agent onboarding** through semantic self-hashing radial navigation.

**Goal:** Any AI agent can open a "door" (context bundle) and have complete, executable context in <5 seconds without asking questions.

---

## YOUR CAPABILITIES

### Hardware Resources
- **Context Window:** 3M tokens (enough for entire 13.85 MB documentation base)
- **Parallel Processing:** 2 VMs
  - **VM 1:** Analysis & Extraction (documentation parsing, door identification)
  - **VM 2:** Synthesis & Validation (context bundles, navigation logic)
- **Integration Layer:** Merge, optimize, validate

### Input Materials Provided
1. **COMBINED_DOCUMENTATION_SUMMARY.md** (This document)
   - E:\PythonProjects: 356 files, 3.21 MB
   - C:\Dev: 784 files, 10.64 MB
   - Total: 1,140 files, 13.85 MB documentation

2. **the_keymaker_theory.md**
   - Radial hash index architecture
   - 3-layer addressing system
   - Context bundle structure
   - Navigation logic design

3. **Original Documentation** (will be provided)
   - All markdown files from E:\PythonProjects
   - All markdown files from C:\Dev
   - AI_CODER_ENCYCLOPEDIA.md (103 KB)
   - PhiDEX Master Codex (506 KB)
   - PhiDEX Deployment Almanac (708 KB)

---

## ARCHITECTURE SPECIFICATION

### The Three-Layer Addressing System

Every context (door) is addressable via three methods that resolve to the same context bundle:

#### Layer 1: Semantic Paths (Human/AI Readable)
```
TOOLS.WINDOWS_MCP.FILE_OPERATIONS
DOCS.ERROR_PATTERNS.POWERSHELL_ENCODING
AGENTS.DC.COORDINATION_PROTOCOLS
PROJECTS.PHIGEN.DISCORD_BOTS
SECURITY.ENCRYPTION.AES_256_GCM
```

**Pattern:** `CATEGORY.SUBCATEGORY.SPECIFIC_CONTEXT`

#### Layer 2: Hash Codes (Short Reference)
```
827HHWINC#  → Windows MCP file operations
E01PWSH     → PowerShell encoding errors
DC1COORD    → DC coordination protocols
PG2DISC     → PhiGEN Discord bot context
SEC01AES    → AES-256-GCM encryption
```

**Pattern:** `[PREFIX][SEQUENCE][SUFFIX]`
- Prefix: Category identifier (8=Tools, E=Errors, D=Agents, P=Projects, S=Security, etc.)
- Sequence: Unique numeric/alpha ID
- Suffix: Mnemonic code (optional)

#### Layer 3: Natural Language (Query-Based)
```
"how to write files on windows"     → 827HHWINC#
"powershell utf8 encoding problems" → E01PWSH
"DC VSCC coordination rules"        → DC1COORD
"discord bot multi-agent patterns"  → PG2DISC
"proper encryption with AES"        → SEC01AES
```

**Requirements:**
- NLP model for semantic matching
- Synonym handling
- Context disambiguation
- Multi-keyword queries
- Fuzzy matching (typo tolerance)

---

## CONTEXT BUNDLE STRUCTURE

Each door contains a complete onboarding package:

```json
{
  "door_code": "827HHWINC#",
  "semantic_path": "TOOLS.WINDOWS_MCP.FILE_OPERATIONS",
  "aliases": ["winmcp_files", "windows_file_ops", "mcp_write", "file_write_windows"],

  "context_bundle": {
    "summary": "150-word overview of Windows MCP file operation tools including read, write, list, search, move, delete. Includes permissions handling, path validation, and error recovery patterns.",

    "prerequisites": [
      "TOOLS.WINDOWS_MCP.SETUP",
      "SECURITY.PATH_VALIDATION"
    ],

    "related_doors": [
      "827HHWINR#",  // Windows MCP file read
      "E01PWSH",     // PowerShell encoding errors
      "SEC02PATH"    // Path traversal protection
    ],

    "onboarding": {
      "quick_start": "Use Windows MCP file operations to read/write files. Always validate paths with Path.resolve(). Handle UTF-8 encoding explicitly. Check permissions before operations.",

      "full_context_path": "/PhiDEX/WINDOWS_MCP/FILE_OPERATIONS.md",

      "common_patterns": [
        "Read file: mcp.file_read(path) with error handling",
        "Write file: mcp.file_write(path, content, encoding='utf-8')",
        "List directory: mcp.file_list(path, pattern='*') with filtering",
        "Search files: mcp.file_search(path, query, regex=True)"
      ],

      "known_errors": [
        {
          "error": "PermissionError: [WinError 5] Access is denied",
          "cause": "Insufficient permissions or file locked",
          "solution": "Check file permissions, ensure file not open in another process, run as admin if needed",
          "prevention": "Always check os.access() before operations",
          "related_door": "E03PERM"
        },
        {
          "error": "UnicodeDecodeError on file read",
          "cause": "File encoding mismatch",
          "solution": "Specify encoding='utf-8' explicitly, use errors='ignore' or 'replace' for binary",
          "prevention": "Detect encoding with chardet library",
          "related_door": "E01PWSH"
        }
      ]
    },

    "resources": {
      "docs": [
        "/PhiDEX/WINDOWS_MCP/FILE_OPERATIONS.md",
        "/PhiGEN/docs/guides/MCP_INTEGRATION_GUIDE.md",
        "/Windows-MCP-v3/README.md"
      ],
      "code": [
        "/Windows-MCP-v3/src/file_operations.py",
        "/PhiGEN/examples/file_ops_example.py",
        "/PhiDEX/code/file_operations_patterns.py"
      ],
      "tests": [
        "/Windows-MCP-v3/tests/test_file_operations.py",
        "/PhiGEN/tests/integration/test_mcp_files.py"
      ],
      "errors": [
        "/PhiDEX/ERROR_LOG.md#file-operations",
        "/PhiGEN/docs/guides/TROUBLESHOOTING.md#mcp-file-errors"
      ]
    },

    "metadata": {
      "last_updated": "2025-11-18T00:00:00Z",
      "confidence": 0.95,
      "usage_count": 47,
      "success_rate": 0.89,
      "tags": ["windows", "mcp", "file-io", "automation", "essential"],
      "category": "TOOLS",
      "subcategory": "WINDOWS_MCP",
      "version": "3.0.0",
      "tested_on": ["Windows 10", "Windows 11", "WSL2"],
      "agent_affinity": ["DC", "JC", "TERMC"]
    }
  }
}
```

---

## NAVIGATION LOGIC

### findDoor() Implementation Requirements

The navigation system must support 5 lookup methods:

#### 1. Explicit Hash Lookup
```python
def findDoor(query: str) -> ContextBundle:
    # Try exact hash match
    if is_hash_code(query):
        return load_context(query)
```

**Example:**
```python
findDoor("827HHWINC#")  # Direct hash lookup
→ Returns: Windows MCP file operations context
```

#### 2. Semantic Path Lookup
```python
    # Try semantic path
    if is_semantic_path(query):
        hash_code = semantic_to_hash(query)
        return load_context(hash_code)
```

**Example:**
```python
findDoor("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")
→ Resolves to: 827HHWINC#
→ Returns: Same context as above
```

#### 3. Natural Language Query
```python
    # Try natural language
    embedding = nlp_model.encode(query)
    matches = semantic_search(embedding, top_k=5)

    if len(matches) == 1 or matches[0].score > 0.9:
        return load_context(matches[0].door_code)
    else:
        # Return multiple suggestions for disambiguation
        return suggest_doors(matches[:3])
```

**Example:**
```python
findDoor("how do I write files on windows")
→ NLP match score: 0.94
→ Resolves to: 827HHWINC#
→ Returns: Same context
```

#### 4. Error-Driven Navigation
```python
def handle_error(error_message: str) -> ContextBundle:
    signature = extract_error_signature(error_message)
    matches = error_pattern_match(signature)

    if matches:
        solution_door = matches[0]
        return load_context(solution_door)
    else:
        # Log unknown error for future door creation
        log_unknown_error(error_message)
        return None
```

**Example:**
```python
handle_error("UnicodeDecodeError: 'charmap' codec can't decode")
→ Matches error pattern: E01PWSH
→ Returns: PowerShell encoding error context with solutions
```

#### 5. Prerequisite Chain Loading
```python
def load_with_prerequisites(door_code: str) -> List[ContextBundle]:
    context = load_context(door_code)
    prerequisites = context.prerequisites

    loaded = []
    for prereq in prerequisites:
        if prereq not in already_loaded:
            # Recursive loading
            prereq_contexts = load_with_prerequisites(prereq)
            loaded.extend(prereq_contexts)

    loaded.append(context)
    return loaded  # Ordered: prerequisites first, target last
```

**Example:**
```python
load_with_prerequisites("827HHWINC#")
→ Checks prerequisites: ["TOOLS.WINDOWS_MCP.SETUP", "SECURITY.PATH_VALIDATION"]
→ Loads: SEC02PATH context (path validation)
→ Loads: 827HHSETUP context (MCP setup)
→ Loads: 827HHWINC# context (file operations)
→ Returns: [SEC02PATH, 827HHSETUP, 827HHWINC#] in dependency order
```

---

## AUTO-ONBOARDING SEQUENCE

When an agent opens a door, the system must:

1. **Load Context Bundle** (hash or semantic lookup)
2. **Check Prerequisites** (prerequisite graph traversal)
3. **Load Missing Prerequisites** (recursive if needed)
4. **Provide Quick Start** (3-sentence summary)
5. **Link to Full Docs** (for deep dive if needed)
6. **Highlight Common Patterns** (code examples)
7. **Warn of Known Errors** (with solutions pre-loaded)
8. **Agent Ready to Execute** (no questions asked)

**Target Time:** <5 seconds for complete onboarding including all prerequisites

---

## YOUR DELIVERABLES

### 1. Master Registry (INDEX.json)

```json
{
  "version": "1.0.0",
  "generated": "2025-11-18T00:00:00Z",
  "total_doors": 0,  // You will populate
  "categories": {
    "TOOLS": 0,
    "DOCS": 0,
    "AGENTS": 0,
    "PROJECTS": 0,
    "SECURITY": 0,
    "ARCHITECTURE": 0,
    "WORKFLOWS": 0,
    "ERRORS": 0
  },
  "door_code_prefixes": {
    "8XX": "Tools category (Windows MCP, AHK, CDP, Git, etc.)",
    "9XX": "Additional tools",
    "EXX": "Error patterns and solutions",
    "AXX": "Architecture documentation",
    "WXX": "Workflow guides",
    "DXX": "Desktop Claude (DC) contexts",
    "JXX": "JetBrains Claude (JC) contexts",
    "TXX": "Terminal Claude (TERMC) contexts",
    "KXX": "Kali Claude (KALIC) contexts",
    "PXX": "Project contexts",
    "SXX": "Security contexts",
    "LXX": "Language/coordination contexts"
  },
  "statistics": {
    "source_files_analyzed": 1140,
    "source_size_mb": 13.85,
    "doors_per_category": {},
    "average_context_size_kb": 0,
    "total_prerequisites": 0,
    "total_cross_references": 0
  },
  "last_updated": "2025-11-18T00:00:00Z"
}
```

### 2. Semantic Map (SEMANTIC_MAP.json)

```json
{
  "version": "1.0.0",
  "mappings": {
    "TOOLS.WINDOWS_MCP.FILE_OPERATIONS": "827HHWINC#",
    "TOOLS.WINDOWS_MCP.FILE_READ": "827HHWINR#",
    "TOOLS.WINDOWS_MCP.FILE_WRITE": "827HHWINW#",
    "DOCS.ERROR_PATTERNS.POWERSHELL_ENCODING": "E01PWSH",
    "DOCS.ERROR_PATTERNS.PERMISSION_DENIED": "E03PERM",
    "AGENTS.DC.COORDINATION_PROTOCOLS": "DC1COORD",
    "AGENTS.JC.IMPLEMENTATION_WORKFLOW": "JC1IMPL",
    "PROJECTS.PHIGEN.DISCORD_BOTS": "PG2DISC",
    "PROJECTS.PHIWAVE.AUDIO_ENGINE": "PW3AUDIO",
    "SECURITY.ENCRYPTION.AES_256_GCM": "SEC01AES",
    "SECURITY.PATH_VALIDATION": "SEC02PATH"
    // ... continue for all identified doors
  },
  "reverse_lookup": {
    "827HHWINC#": "TOOLS.WINDOWS_MCP.FILE_OPERATIONS",
    // ... mirror of above for fast reverse lookups
  },
  "aliases": {
    "winmcp_files": "827HHWINC#",
    "windows_file_ops": "827HHWINC#",
    "mcp_write": "827HHWINC#",
    // ... all aliases for all doors
  }
}
```

### 3. Hash Table (HASH_TABLE.json)

```json
{
  "version": "1.0.0",
  "mappings": {
    "827HHWINC#": {
      "context_file": "/CONTEXTS/TOOLS/827HHWINC#.json",
      "category": "TOOLS",
      "subcategory": "WINDOWS_MCP",
      "size_kb": 12.5,
      "last_updated": "2025-11-18T00:00:00Z"
    },
    "E01PWSH": {
      "context_file": "/CONTEXTS/DOCS/E01PWSH.json",
      "category": "DOCS",
      "subcategory": "ERROR_PATTERNS",
      "size_kb": 8.2,
      "last_updated": "2025-11-18T00:00:00Z"
    }
    // ... continue for all doors
  },
  "categories": {
    "TOOLS": ["827HHWINC#", "827HHWINR#", "827HHWINW#", ...],
    "DOCS": ["E01PWSH", "E03PERM", ...],
    "AGENTS": ["DC1COORD", "JC1IMPL", ...],
    "PROJECTS": ["PG2DISC", "PW3AUDIO", ...],
    "SECURITY": ["SEC01AES", "SEC02PATH", ...]
  }
}
```

### 4. NLP Query Patterns (NLP_PATTERNS.json)

```json
{
  "version": "1.0.0",
  "query_patterns": {
    "file_operations": {
      "door_code": "827HHWINC#",
      "keywords": ["file", "read", "write", "save", "load", "windows", "mcp"],
      "phrases": [
        "how to write files",
        "read file windows",
        "mcp file operations",
        "save to file",
        "load from file"
      ],
      "variations": [
        "writing files on windows",
        "reading files with mcp",
        "file io windows"
      ]
    },
    "encoding_errors": {
      "door_code": "E01PWSH",
      "keywords": ["encoding", "unicode", "utf8", "charmap", "powershell"],
      "phrases": [
        "unicode error",
        "encoding problem",
        "powershell encoding",
        "utf8 issue"
      ],
      "error_signatures": [
        "UnicodeDecodeError",
        "UnicodeEncodeError",
        "charmap codec"
      ]
    }
    // ... continue for all doors
  },
  "synonyms": {
    "file": ["document", "data", "content"],
    "read": ["load", "open", "get"],
    "write": ["save", "create", "put"],
    "error": ["problem", "issue", "failure"],
    "fix": ["solution", "resolve", "repair"]
  },
  "disambiguation_rules": {
    "read_context": {
      "if_keywords": ["file", "windows"],
      "then_prefer": "827HHWINR#",
      "over": ["other_read_doors"]
    }
  }
}
```

### 5. Error Pattern Matcher (ERROR_MATCHER.json)

```json
{
  "version": "1.0.0",
  "error_patterns": {
    "UnicodeDecodeError": {
      "signatures": [
        "'charmap' codec can't decode",
        "'utf-8' codec can't decode",
        "invalid start byte"
      ],
      "solution_door": "E01PWSH",
      "confidence": 0.95,
      "occurrences": 23
    },
    "PermissionError": {
      "signatures": [
        "[WinError 5] Access is denied",
        "Permission denied",
        "[Errno 13] Permission denied"
      ],
      "solution_door": "E03PERM",
      "confidence": 0.98,
      "occurrences": 47
    },
    "FileNotFoundError": {
      "signatures": [
        "[WinError 2] The system cannot find the file",
        "[Errno 2] No such file or directory",
        "FileNotFoundError"
      ],
      "solution_door": "E04NOTFOUND",
      "confidence": 0.92,
      "occurrences": 31
    }
    // ... continue for all documented errors
  },
  "error_categories": {
    "encoding": ["E01PWSH"],
    "permissions": ["E03PERM"],
    "file_system": ["E04NOTFOUND", "E05PATH"],
    "network": ["E10NET", "E11TIMEOUT"],
    "api": ["E20API", "E21AUTH"],
    "encryption": ["E30CRYPTO", "E31SALT"]
  }
}
```

### 6. Prerequisites Graph (PREREQUISITES.json)

```json
{
  "version": "1.0.0",
  "dependencies": {
    "827HHWINC#": {
      "door_code": "827HHWINC#",
      "prerequisites": ["827HHSETUP", "SEC02PATH"],
      "prerequisite_of": ["827HHDEL", "827HHMOV"],
      "loading_order": ["SEC02PATH", "827HHSETUP", "827HHWINC#"],
      "depth": 2
    },
    "PG2DISC": {
      "door_code": "PG2DISC",
      "prerequisites": ["A12ARCH", "SEC01AES", "D01DOCKER"],
      "prerequisite_of": [],
      "loading_order": ["SEC01AES", "D01DOCKER", "A12ARCH", "PG2DISC"],
      "depth": 1
    }
    // ... continue for all doors
  },
  "dag_validation": {
    "is_acyclic": true,
    "max_depth": 5,
    "total_edges": 0,
    "orphan_doors": []  // Doors with no prerequisites or dependents
  },
  "loading_optimization": {
    "common_prerequisites": {
      "SEC02PATH": ["827HHWINC#", "827HHDEL", "827HHMOV", "PG1VAULT"],
      "SEC01AES": ["PG1VAULT", "SEC30CRYPTO", "PG2DISC"]
    },
    "cache_priority": [
      "SEC02PATH",  // Most commonly needed
      "SEC01AES",
      "827HHSETUP"
    ]
  }
}
```

### 7. Complete Context Bundles

For each identified door, generate a complete JSON file in `/CONTEXTS/{CATEGORY}/{DOOR_CODE}.json` following the structure above.

**Minimum 100 doors, target 200-500 doors.**

**Priority Doors (Must Include):**

#### TOOLS Category (8XX)
- 827HHWINC# - Windows MCP file operations
- 827HHWINR# - Windows MCP file read
- 827HHWINW# - Windows MCP file write
- 827HHPROC# - Windows MCP process management
- 827HHSCREEN# - Windows MCP screenshots
- 828AHKMS# - AutoHotkey v2 automation
- 829CDP# - Chrome DevTools Protocol

#### ERROR Category (EXX)
- E01PWSH - PowerShell encoding errors
- E03PERM - Permission errors
- E04NOTFOUND - File not found errors
- E05PATH - Path issues
- E10NET - Network errors
- E20API - API errors
- E30CRYPTO - Encryption errors

#### AGENT Category (DXX, JXX, TXX, KXX)
- DC1COORD - DC coordination protocols
- DC2MEM - DC memory management
- JC1IMPL - JC implementation workflow
- JC2TEST - JC testing procedures
- TC1CLI - TERMC CLI operations
- KC1AUDIT - KALIC security auditing

#### PROJECT Category (PXX)
- PG1VAULT - PhiGEN password vault
- PG2DISC - PhiGEN Discord bots
- PG3MCP - PhiGEN MCP integration
- PW1AUDIO - PhiWave audio engine
- PW2GUI - PhiWave GUI system
- PW3PRESET - PhiWave presets
- PS1INDEX - PhiSRHI indexing

#### SECURITY Category (SXX)
- SEC01AES - AES-256-GCM encryption
- SEC02PATH - Path validation
- SEC03AUTH - Authentication
- SEC04SECRET - Secret management
- SEC05SCAN - Security scanning

#### ARCHITECTURE Category (AXX)
- A01MULTI - Multi-agent architecture
- A02JSONL - JSONL feed system
- A03MCP - MCP protocol
- A04GOLDEN - Golden ratio design
- A05WORKFLOW - Development workflows

### 8. Navigation Logic Implementation (NAVIGATION_LOGIC.md)

Provide complete pseudocode/Python implementation for:
- `findDoor(query: str) -> ContextBundle`
- `loadWithPrerequisites(door_code: str) -> List[ContextBundle]`
- `handleError(error_message: str) -> ContextBundle`
- `suggestDoors(query: str, top_k: int) -> List[ContextBundle]`
- `validateDoorGraph() -> ValidationReport`

### 9. System Documentation

#### README.md
- Quick start guide
- Installation instructions
- Usage examples
- API reference

#### ARCHITECTURE.md
- Design decisions
- Rationale for structure
- Optimization strategies
- Scaling considerations

#### VALIDATION.md
- Test coverage
- Validation results
- Performance benchmarks
- Known limitations

### 10. Validation Scripts

Provide executable code to:
- Validate JSON schemas
- Check DAG (no cycles)
- Verify all cross-references
- Test navigation logic
- Benchmark performance

---

## QUALITY CRITERIA

### Each Context Bundle Must:
- ✅ Be instantly loadable (<100ms)
- ✅ Contain complete onboarding info (summary, quick start, full docs)
- ✅ Have accurate prerequisites (validated in DAG)
- ✅ Include working code examples (executable, tested)
- ✅ Reference valid file paths (verified to exist)
- ✅ Provide error solutions (from actual documented errors)
- ✅ Enable autonomous execution (agent can proceed without questions)

### The System Must:
- ✅ Support all three addressing methods (hash, semantic, NLP)
- ✅ Handle ambiguous queries gracefully (suggestions)
- ✅ Auto-load prerequisites (recursive, ordered)
- ✅ Scale to 2000+ doors (optimization strategies)
- ✅ Maintain <5 second onboarding time (including prerequisites)
- ✅ Enable error-driven navigation (automatic error → solution)
- ✅ Provide validation tools (DAG check, reference verification)

### Innovation Requirements:
- ✅ Features beyond specification (surprise us)
- ✅ Optimization beyond requirements (faster, smarter)
- ✅ Insights we didn't anticipate (patterns discovered)
- ✅ Automation opportunities (self-maintenance, auto-updates)

---

## SUCCESS METRICS

### Coverage (100% Required)
- Every documented tool has a door
- Every documented error has a solution door
- Every agent has coordination context
- Every project has onboarding doors
- Every security pattern has a door

### Connectivity (100% Required)
- All cross-references valid (no broken links)
- All prerequisites resolvable (DAG complete)
- All file paths verified (exist in documentation)
- All code examples executable (syntax valid)

### Accessibility (95%+ Required)
- Hash lookup: 100% success rate
- Semantic lookup: 100% success rate
- NLP queries: 90%+ success rate (first query)
- NLP queries: 98%+ success rate (with suggestions)
- Error-driven: 85%+ success rate (documented errors)

### Completeness (90%+ Required)
- Context bundles enable autonomous execution
- No critical information missing
- All common patterns documented
- All known errors included
- Prerequisites complete and ordered

### Performance (Target Metrics)
- Hash lookup: <50ms
- Semantic lookup: <100ms
- NLP query: <500ms (including embedding)
- Context loading: <1 second
- Complete onboarding: <5 seconds (with prerequisites)

---

## EXECUTION STRATEGY

### VM 1: Analysis & Extraction

**Tasks:**
1. Parse all 1,140 markdown files
2. Identify door candidates (tools, errors, patterns, projects)
3. Extract relationships and dependencies
4. Build semantic understanding (NLP patterns)
5. Generate door codes (following prefix system)
6. Create semantic path mappings
7. Extract error signatures
8. Identify prerequisites

**Output:**
- List of doors with semantic paths
- Door code assignments
- Semantic map
- Error patterns
- Dependency graph (raw)

### VM 2: Synthesis & Validation

**Tasks:**
1. Create complete context bundles
2. Generate navigation structures (hash table, NLP patterns)
3. Validate cross-references
4. Optimize prerequisite chains
5. Generate navigation logic code
6. Create documentation (README, ARCHITECTURE)
7. Build validation scripts
8. Performance testing

**Output:**
- Complete context bundles (JSON)
- Navigation logic (code)
- System documentation
- Validation suite

### Integration Phase

**Tasks:**
1. Merge outputs from both VMs
2. Resolve conflicts (duplicate doors, naming)
3. Optimize structure (cache priorities, loading order)
4. Final validation (DAG, references, performance)
5. Generate deliverables package

**Output:**
- Complete PhiDOOR system
- Ready for deployment
- Validated and tested

---

## INNOVATION CHALLENGES

You have 3M tokens. Use them wisely. Here are some **innovation opportunities** beyond the specification:

### 1. Meta-Contexts
Create doors about using doors:
- "How do I use PhiDOOR?" → META01USE
- "PhiDOOR architecture explained" → META02ARCH
- "Creating new doors" → META03CREATE

### 2. Learning from Usage
Design a system that:
- Tracks which doors are opened together
- Identifies missing prerequisites (agents ask questions = missing door)
- Suggests new doors based on gaps
- Auto-updates contexts from documentation changes

### 3. Context Compression
Optimize for:
- Minimal token usage (agents have limited context)
- Progressive disclosure (quick start → details on demand)
- Smart caching (most common prerequisites pre-loaded)
- Lazy loading (full docs fetched only if needed)

### 4. Advanced Query Features
Implement:
- Multi-door queries ("authentication AND discord bot")
- Negation queries ("file operations NOT windows")
- Similarity search ("find doors like 827HHWINC#")
- Time-based ("doors updated in last week")

### 5. Predictive Loading
Based on patterns:
- If agent opens "discord bot", pre-load "MCP integration"
- If agent encounters error, pre-load solution + related errors
- If agent loads project context, pre-load common tools

### 6. Cross-Project Intelligence
Identify:
- Similar patterns across projects (reusable)
- Conflicts/contradictions in documentation
- Missing integration points
- Optimization opportunities

### 7. Quality Scoring
For each door, calculate:
- Completeness score (0.0-1.0)
- Freshness score (last updated)
- Usage score (how often accessed)
- Success score (how often agent succeeds after loading)
- Confidence score (how validated is this information)

### 8. Auto-Maintenance
Design systems for:
- Detecting outdated contexts (documentation changed)
- Suggesting new doors (from agent questions)
- Merging duplicate doors
- Archiving unused doors
- Updating cross-references automatically

### 9. Visual Navigation
Generate:
- ASCII art tree view of door structure
- Dependency graphs (Graphviz DOT format)
- Category maps
- Prerequisite chains visualization

### 10. SURPRISE US
What features would make PhiDOOR revolutionary that we haven't thought of?
What optimizations could make it 10x better?
What insights did you discover in the documentation?

**Use your intelligence. Innovate.**

---

## OUTPUT FORMAT

### Directory Structure

```
PhiDOOR/
├── INDEX.json
├── SEMANTIC_MAP.json
├── HASH_TABLE.json
├── NLP_PATTERNS.json
├── ERROR_MATCHER.json
├── PREREQUISITES.json
├── README.md
├── ARCHITECTURE.md
├── NAVIGATION_LOGIC.md
├── VALIDATION.md
├── CONTEXTS/
│   ├── TOOLS/
│   │   ├── 827HHWINC#.json
│   │   ├── 827HHWINR#.json
│   │   ├── 827HHWINW#.json
│   │   └── [100+ tool contexts]
│   ├── DOCS/
│   │   ├── E01PWSH.json
│   │   ├── E03PERM.json
│   │   └── [50+ error/doc contexts]
│   ├── AGENTS/
│   │   ├── DC1COORD.json
│   │   ├── JC1IMPL.json
│   │   └── [20+ agent contexts]
│   ├── PROJECTS/
│   │   ├── PG1VAULT.json
│   │   ├── PG2DISC.json
│   │   ├── PW1AUDIO.json
│   │   └── [30+ project contexts]
│   ├── SECURITY/
│   │   ├── SEC01AES.json
│   │   ├── SEC02PATH.json
│   │   └── [20+ security contexts]
│   ├── ARCHITECTURE/
│   │   ├── A01MULTI.json
│   │   ├── A02JSONL.json
│   │   └── [15+ architecture contexts]
│   └── META/
│       ├── META01USE.json
│       ├── META02ARCH.json
│       └── [10+ meta contexts]
├── validation/
│   ├── validate_schema.py
│   ├── validate_dag.py
│   ├── validate_references.py
│   └── benchmark_performance.py
└── implementation/
    ├── navigation.py
    ├── loader.py
    ├── search.py
    └── error_handler.py
```

---

## FINAL INSTRUCTIONS

### What You Will Receive
1. This complete prompt (CEREBRAS_COMPLETE_PROMPT.md)
2. Combined documentation summary (COMBINED_DOCUMENTATION_SUMMARY.md)
3. All original markdown files (1,140 files, 13.85 MB)
4. The Keymaker theory document (the_keymaker_theory.md)

### What You Must Deliver
1. Complete PhiDOOR system (all JSON files, code, docs)
2. 100-500 context bundles (target 200+)
3. All navigation structures (semantic map, hash table, NLP patterns, error matcher, prerequisites)
4. Navigation logic implementation (Python code)
5. System documentation (README, ARCHITECTURE, VALIDATION)
6. Validation suite (scripts to verify correctness)
7. Innovation report (what you added beyond spec)

### How to Organize Your Work

#### Phase 1: Analysis (VM 1 Focus)
- Parse all documentation
- Identify 200-500 door candidates
- Generate door codes
- Extract relationships
- Build semantic map
- Create error patterns

#### Phase 2: Synthesis (VM 2 Focus)
- Create context bundles
- Write navigation logic
- Generate validation scripts
- Build documentation
- Implement innovation features

#### Phase 3: Integration (Combined)
- Merge outputs
- Resolve conflicts
- Optimize structure
- Final validation
- Package deliverables

### Success Criteria

**Your deliverable is successful if:**
1. An AI agent can query "how to write files" and get complete context in <5 seconds
2. All 1,140 source files are represented in doors
3. All cross-references are valid (100%)
4. All prerequisites form a valid DAG (no cycles)
5. Navigation works via all 3 methods (hash, semantic, NLP)
6. You've added features we didn't think of
7. The system scales to 2000+ doors without degradation

---

## THE ULTIMATE GOAL

When an agent says:
```
"Open door 827HHWINC#"
```

They should:
1. **Receive context** in <2 seconds
2. **Understand prerequisites** (loaded automatically)
3. **See code examples** (working, tested)
4. **Know common patterns** (3-5 examples)
5. **Be warned of errors** (with solutions)
6. **Have full context** (links to complete docs)
7. **Be ready to execute** (no questions needed)

**Build The Keymaster.**

Make it comprehensive.
Make it elegant.
Make it revolutionary.

**Your 3M tokens are waiting.**

---

**End of Cerebras Complete Prompt**
**Version:** 1.0.0
**Generated:** 2025-11-18
**Target Model:** Cerebras GLM 4.6 357B
**Expected Output:** Complete PhiDOOR Semantic Self-Hashing Radial Index System
