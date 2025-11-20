# PhiSRHI - Semantic Self-Hashing Radial Index 

**The Keymaster's Index - Instant AI Agent Onboarding System**

---

## Overview

PhiSRHI implements **PhiDOOR**, a revolutionary semantic navigation system that enables AI agents to instantly access complete context for any tool, document, error pattern, or project through a radial hash index.

**Goal:** Any AI agent can open a "door" (context bundle) and have complete, executable context in <5 seconds without asking questions.

---

## Quick Start

### For AI Agents

**To use PhiDOOR:**
```
Query: "how to write files on windows"
→ PhiDOOR returns: Complete Windows MCP file operations context
→ Time: <5 seconds
→ You're ready to execute
```

### For Humans

**To build PhiDOOR:**
1. Review documentation in `/docs`
2. Send complete prompt to Cerebras GLM 4.6 357B
3. Receive generated PhiDOOR system
4. Deploy and use

---

## Project Structure

```
PhiSRHI/
├── README.md                      # This file
├── docs/
│   ├── COMBINED_DOCUMENTATION_SUMMARY.md   # Complete knowledge base (13.85 MB)
│   └── [Original markdown files will be copied here]
├── PhiDOOR/
│   ├── CEREBRAS_COMPLETE_PROMPT.md         # Complete Cerebras prompt
│   ├── INDEX.json                          # Master registry (to be generated)
│   ├── SEMANTIC_MAP.json                   # Semantic paths (to be generated)
│   ├── HASH_TABLE.json                     # Hash → location (to be generated)
│   ├── NLP_PATTERNS.json                   # NLP queries (to be generated)
│   ├── ERROR_MATCHER.json                  # Error → solution (to be generated)
│   ├── PREREQUISITES.json                  # Dependency graph (to be generated)
│   ├── README.md                           # PhiDOOR usage guide (to be generated)
│   ├── ARCHITECTURE.md                     # Design docs (to be generated)
│   ├── NAVIGATION_LOGIC.md                 # Implementation guide (to be generated)
│   ├── CONTEXTS/                           # Context bundles (to be generated)
│   │   ├── TOOLS/                          # 8XX codes
│   │   ├── DOCS/                           # EXX codes
│   │   ├── AGENTS/                         # DXX, JXX, TXX, KXX codes
│   │   ├── PROJECTS/                       # PXX codes
│   │   ├── SECURITY/                       # SXX codes
│   │   ├── ARCHITECTURE/                   # AXX codes
│   │   └── META/                           # META codes
│   ├── validation/                         # Validation scripts (to be generated)
│   └── implementation/                     # Navigation logic (to be generated)
└── MARKDOWNS_(THEONLYFILESYOUWILLEDIT)/   # Original consolidated docs
    ├── the_keymaker_theory.md              # PhiDOOR architecture theory
    ├── cerebras_prompt.md                  # Original Cerebras prompt
    └── COMPREHENSIVE_MARKDOWN_SUMMARY.md   # E:\PythonProjects summary
```

---

## The Three-Layer Addressing System

Every context (door) is addressable via three methods:

### 1. Semantic Paths (Human/AI Readable)
```
TOOLS.WINDOWS_MCP.FILE_OPERATIONS
DOCS.ERROR_PATTERNS.POWERSHELL_ENCODING
AGENTS.DC.COORDINATION_PROTOCOLS
PROJECTS.PHIGEN.DISCORD_BOTS
```

### 2. Hash Codes (Short Reference)
```
827HHWINC#  → Windows MCP file operations
E01PWSH     → PowerShell encoding errors
DC1COORD    → DC coordination protocols
PG2DISC     → PhiGEN Discord bot context
```

### 3. Natural Language (Query-Based)
```
"how to write files on windows"     → 827HHWINC#
"powershell utf8 encoding problems" → E01PWSH
"DC VSCC coordination rules"        → DC1COORD
```

**All three resolve to the same complete context bundle.**

---

## Documentation 

**Total:** 1,140 markdown files, 13.85 MB of documentation

---

## How to Generate PhiDOOR

### Prerequisites
- Access to Cerebras GLM 4.6 357B model
- 3M token context window
- 2 VMs for parallel processing

### Steps

1. **Prepare Input Materials**
   ```bash
   # Already done in this repository:
   - CEREBRAS_COMPLETE_PROMPT.md (complete prompt)
   - COMBINED_DOCUMENTATION_SUMMARY.md (13.85 MB summary)
   - the_keymaker_theory.md (architecture theory)
   ```

2. **Copy Original Documentation (Optional)**
   ```bash
   # Copy all markdown files to docs/ for Cerebras to analyze:
   cp E:\PythonProjects\**\*.md docs/E_PythonProjects/
   cp C:\Dev\**\*.md docs/C_Dev/
   ```

3. **Send to Cerebras**
   ```
   Model: Cerebras GLM 4.6 357B
   Context Window: 3M tokens
   VMs: 2 (parallel processing)

   Input:
   1. PhiDOOR/CEREBRAS_COMPLETE_PROMPT.md
   2. docs/COMBINED_DOCUMENTATION_SUMMARY.md
   3. MARKDOWNS_*/the_keymaker_theory.md
   4. (Optional) All original markdown files
   ```

4. **Receive Generated System**
   ```
   Cerebras will generate:
   - All JSON files (INDEX, SEMANTIC_MAP, HASH_TABLE, etc.)
   - 100-500 complete context bundles
   - Navigation logic (Python code)
   - System documentation
   - Validation scripts
   ```

5. **Deploy**
   ```bash
   # Cerebras output will be in PhiDOOR/ directory
   # Ready to use immediately
   ```

---

## Expected Deliverables from Cerebras

### Core System Files
- ✅ INDEX.json (master registry)
- ✅ SEMANTIC_MAP.json (semantic path → hash)
- ✅ HASH_TABLE.json (hash → context location)
- ✅ NLP_PATTERNS.json (natural language queries)
- ✅ ERROR_MATCHER.json (error signatures → solutions)
- ✅ PREREQUISITES.json (dependency graph)

### Context Bundles (100-500)
- ✅ TOOLS/ (8XX codes) - Windows MCP, AHK, CDP, Git
- ✅ DOCS/ (EXX codes) - Error patterns, troubleshooting
- ✅ AGENTS/ (DXX codes) - DC, JC, TERMC, KALIC contexts
- ✅ PROJECTS/ (PXX codes) - PhiGEN, PhiWave, PhiSRHI
- ✅ SECURITY/ (SXX codes) - Encryption, authentication, scanning
- ✅ ARCHITECTURE/ (AXX codes) - Multi-agent, JSONL, MCP
- ✅ META/ (META codes) - Using PhiDOOR itself

### Implementation Code
- ✅ navigation.py (findDoor, semantic search, NLP matching)
- ✅ loader.py (context loading, prerequisite chaining)
- ✅ search.py (NLP queries, error matching)
- ✅ error_handler.py (error-driven navigation)

### Documentation
- ✅ README.md (usage guide)
- ✅ ARCHITECTURE.md (design decisions)
- ✅ NAVIGATION_LOGIC.md (implementation details)
- ✅ VALIDATION.md (test results, benchmarks)

### Validation Suite
- ✅ validate_schema.py (JSON schema validation)
- ✅ validate_dag.py (prerequisite graph checks)
- ✅ validate_references.py (cross-reference verification)
- ✅ benchmark_performance.py (speed tests)

---

## Success Criteria

### Performance Targets
- ✅ Hash lookup: <50ms
- ✅ Semantic lookup: <100ms
- ✅ NLP query: <500ms
- ✅ Context loading: <1 second
- ✅ Complete onboarding: <5 seconds (with prerequisites)

### Quality Targets
- ✅ 100% hash lookup success rate
- ✅ 100% semantic path success rate
- ✅ 90%+ NLP first-query success rate
- ✅ 98%+ NLP with suggestions success rate
- ✅ 85%+ error-driven navigation (documented errors)

### Coverage Targets
- ✅ Every documented tool has a door
- ✅ Every documented error has a solution
- ✅ Every agent has coordination context
- ✅ Every project has onboarding doors
- ✅ Every security pattern has a door

---

## Example Usage

### Scenario 1: Explicit Door Code
```python
>>> phidoor.findDoor("827HHWINC#")
{
  "door_code": "827HHWINC#",
  "semantic_path": "TOOLS.WINDOWS_MCP.FILE_OPERATIONS",
  "quick_start": "Use Windows MCP file operations...",
  "prerequisites": ["827HHSETUP", "SEC02PATH"],
  "examples": [...],
  "errors": [...]
}
# Time: <100ms
# Agent ready to execute
```

### Scenario 2: Semantic Path
```python
>>> phidoor.findDoor("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")
# Resolves to: 827HHWINC#
# Returns: Same context as above
# Time: <100ms
```

### Scenario 3: Natural Language
```python
>>> phidoor.findDoor("how do I write files on windows")
# NLP match score: 0.94
# Resolves to: 827HHWINC#
# Returns: Same context as above
# Time: <500ms
```

### Scenario 4: Error-Driven
```python
>>> phidoor.handleError("UnicodeDecodeError: 'charmap' codec can't decode")
# Matches error pattern: E01PWSH
# Returns: PowerShell encoding error context with solutions
# Time: <200ms
# Agent applies fix automatically
```

### Scenario 5: With Prerequisites
```python
>>> phidoor.loadWithPrerequisites("PG2DISC")
# Checks prerequisites: ["A12ARCH", "SEC01AES", "D01DOCKER"]
# Loads: SEC01AES, D01DOCKER, A12ARCH, PG2DISC (in order)
# Returns: List of 4 context bundles
# Time: <5 seconds total
# Agent has complete context for Discord bot implementation
```

---

## Key Features

### 1. Instant Onboarding
- Complete context in <5 seconds
- No questions asked
- Prerequisites auto-loaded
- Code examples included

### 2. Multi-Method Navigation
- Hash codes (fast, direct)
- Semantic paths (structured, clear)
- Natural language (intuitive, flexible)

### 3. Error Autonomy
- Automatic error → solution routing
- Known errors documented with fixes
- Related errors suggested

### 4. Smart Prerequisites
- DAG-based dependency resolution
- Ordered loading (dependencies first)
- Cycle detection
- Cache optimization

### 5. Cross-Project Intelligence
- Patterns from 10+ projects
- 1,140 source files analyzed
- 13.85 MB knowledge base
- Real-world tested solutions

---

## Innovation Opportunities

Cerebras is encouraged to implement:

### Meta-Contexts
- How to use PhiDOOR itself
- Creating new doors
- System architecture explained

### Learning from Usage
- Track commonly accessed doors
- Identify missing prerequisites
- Suggest new doors
- Auto-update from documentation changes

### Advanced Queries
- Multi-door queries ("auth AND discord")
- Negation ("file ops NOT windows")
- Similarity search ("find doors like X")
- Time-based ("updated last week")

### Predictive Loading
- Pre-load likely next contexts
- Learn from usage patterns
- Optimize cache based on frequency

### Quality Scoring
- Completeness (0.0-1.0)
- Freshness (last updated)
- Usage (access frequency)
- Success (agent execution success rate)

---

## Technical Background

### Source Material Highlights

**E:\PythonProjects:**
- AI_CODER_ENCYCLOPEDIA.md (103 KB) - Multi-agent patterns, 19 security vulnerabilities fixed
- PhiGEN - Discord bots, password vault, AES-256 encryption
- PhiWave - Binaural beats, golden ratio design, Fibonacci frequencies
- FONTBUILDER - 5-file documentation pattern (INDEX, ANALYSIS, GUIDELINES, LOG, SOLUTIONS)

**C:\Dev:**
- PhiDEX Master Codex (506 KB) - 8 comprehensive guides, 1,210+ code examples
- PhiDEX Deployment Almanac (708 KB) - Cross-platform deployment bible
- Windows-MCP v3 - 20+ automation tools
- PhiLaunch - AI response capture (6 methods, 95%+ success)

### Key Technologies
- **Languages:** Python 3.13.7, PowerShell 7+, Rust, JavaScript/TypeScript
- **AI:** Claude API, GPT-4, Ollama (local models)
- **Automation:** AutoHotkey v2, CDP (Chrome DevTools Protocol)
- **Frameworks:** PyQt6, Tkinter, Tauri
- **Infrastructure:** Docker, Git, WSL2

### Proven Patterns
- **Multi-agent coordination** - 66% token efficiency
- **JSONL feeds** - Append-only event logs
- **MCP hubs** - Real-time messaging
- **Security-first** - Automated scanning, pre-commit hooks
- **Golden ratio design** - φ = 1.618 in UI and audio

---

## License & Credits

**Project:** PhiSRHI - Semantic Self-Hashing Radial Index
**Concept:** The Keymaster Theory (radial hash navigation)
**Implementation:** Cerebras GLM 4.6 357B
**Knowledge Base:** 1,140 files from E:\PythonProjects and C:\Dev
**Contributors:** Multi-agent development team (DC, JC, TERMC, KALIC)

**License:** MIT (or specify your license)

---

## Contact & Support

For questions, issues, or contributions:
- Review documentation in `/docs`
- Check PhiDOOR system documentation (after generation)
- Consult original source files in `/MARKDOWNS_*`

---

**Status:** Ready for Cerebras GLM 4.6 357B processing
**Last Updated:** 2025-11-18
**Version:** 1.0.0

**Build The Keymaster. Make instant AI onboarding possible.**
