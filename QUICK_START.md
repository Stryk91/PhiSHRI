# PhiSRHI/PhiDOOR - Quick Start Guide

**Goal:** Get PhiDOOR (Semantic Self-Hashing Radial Index) up and running

---

## For AI Agents: Using PhiDOOR (After Generation)

### Simple Usage
```python
import phidoor

# Method 1: Hash code (fastest)
context = phidoor.findDoor("827HHWINC#")

# Method 2: Semantic path
context = phidoor.findDoor("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")

# Method 3: Natural language
context = phidoor.findDoor("how to write files on windows")

# All three return the same complete context bundle
```

### With Prerequisites
```python
# Automatically loads all required prerequisite contexts
contexts = phidoor.loadWithPrerequisites("PG2DISC")

# Returns list in dependency order:
# [SEC01AES, D01DOCKER, A12ARCH, PG2DISC]
```

### Error-Driven Navigation
```python
try:
    # Your code that might fail
    file_ops()
except UnicodeDecodeError as e:
    # PhiDOOR automatically finds solution
    solution = phidoor.handleError(str(e))
    # Apply fix and continue
```

---

## For Humans: Building PhiDOOR

### Step 1: Review Materials

**Already prepared in this repository:**
```
C:\Dev\PhiSRHI/
├── README.md                                    # Project overview
├── QUICK_START.md                               # This file
├── docs/
│   └── COMBINED_DOCUMENTATION_SUMMARY.md        # Complete knowledge base
├── PhiDOOR/
│   └── CEREBRAS_COMPLETE_PROMPT.md              # Full Cerebras prompt
└── MARKDOWNS_(THEONLYFILESYOUWILLEDIT)/
    ├── the_keymaker_theory.md                   # Architecture theory
    ├── cerebras_prompt.md                       # Original prompt
    └── COMPREHENSIVE_MARKDOWN_SUMMARY.md        # E:\PythonProjects summary
```

### Step 2: Access Cerebras GLM 4.6 357B

**Requirements:**
- Model: Cerebras GLM 4.6 357B
- Context window: 3M tokens
- Processing: 2 VMs (parallel)

### Step 3: Send Complete Prompt

**Input to Cerebras:**
1. Open: `C:\Dev\PhiSRHI\PhiDOOR\CEREBRAS_COMPLETE_PROMPT.md`
2. Include: `C:\Dev\PhiSRHI\docs\COMBINED_DOCUMENTATION_SUMMARY.md`
3. Include: `C:\Dev\PhiSRHI\MARKDOWNS_*\the_keymaker_theory.md`
4. (Optional) Include all original markdown files from:
   - E:\PythonProjects (356 files, 3.21 MB)
   - C:\Dev (784 files, 10.64 MB)

**Total input:** ~3.5M tokens (well within 3M context window)

### Step 4: Receive Generated System

**Cerebras will generate:**
```
PhiDOOR/
├── INDEX.json                      # Master registry (100-500 doors)
├── SEMANTIC_MAP.json               # Semantic path mappings
├── HASH_TABLE.json                 # Hash code lookups
├── NLP_PATTERNS.json               # Natural language patterns
├── ERROR_MATCHER.json              # Error signature matching
├── PREREQUISITES.json              # Dependency graph (DAG)
├── README.md                       # Usage documentation
├── ARCHITECTURE.md                 # Design decisions
├── NAVIGATION_LOGIC.md             # Implementation guide
├── CONTEXTS/
│   ├── TOOLS/       (8XX codes)   # 30-100 tool contexts
│   ├── DOCS/        (EXX codes)   # 20-50 error/doc contexts
│   ├── AGENTS/      (DXX codes)   # 10-20 agent contexts
│   ├── PROJECTS/    (PXX codes)   # 20-40 project contexts
│   ├── SECURITY/    (SXX codes)   # 10-20 security contexts
│   ├── ARCHITECTURE/(AXX codes)   # 10-15 architecture contexts
│   └── META/        (META codes)  # 5-10 meta contexts
├── validation/
│   ├── validate_schema.py         # JSON schema checks
│   ├── validate_dag.py            # Prerequisite graph validation
│   ├── validate_references.py    # Cross-reference verification
│   └── benchmark_performance.py  # Performance testing
└── implementation/
    ├── navigation.py              # Navigation logic
    ├── loader.py                  # Context loader
    ├── search.py                  # NLP search
    └── error_handler.py           # Error matching
```

### Step 5: Deploy

**Installation:**
```bash
# Navigate to PhiDOOR directory
cd C:\Dev\PhiSRHI\PhiDOOR

# Install Python package (Cerebras will generate setup.py)
pip install -e .

# Or use directly
python -m phidoor.navigation findDoor "827HHWINC#"
```

**Validation:**
```bash
# Run validation suite
python validation/validate_schema.py
python validation/validate_dag.py
python validation/validate_references.py
python validation/benchmark_performance.py

# All should pass with 100% success
```

---

## Key Concepts

### The Three Addressing Methods

#### 1. Hash Codes (Direct, Fast)
```
827HHWINC#  → Windows MCP file operations
E01PWSH     → PowerShell encoding errors
DC1COORD    → DC coordination protocols
PG2DISC     → PhiGEN Discord bots
```

**Use when:** You know exact door code (from docs, previous lookup, or agent communication)

#### 2. Semantic Paths (Structured, Clear)
```
TOOLS.WINDOWS_MCP.FILE_OPERATIONS
DOCS.ERROR_PATTERNS.POWERSHELL_ENCODING
AGENTS.DC.COORDINATION_PROTOCOLS
PROJECTS.PHIGEN.DISCORD_BOTS
```

**Use when:** You want human-readable, hierarchical navigation

#### 3. Natural Language (Intuitive, Flexible)
```
"how to write files on windows"
"powershell utf8 encoding problems"
"DC VSCC coordination rules"
"discord bot multi-agent patterns"
```

**Use when:** You're exploring or don't know exact path

### Context Bundle Contents

Every door provides:
- **Summary** (150 words) - Quick overview
- **Prerequisites** (list of door codes) - What to load first
- **Related Doors** (3-5 codes) - Similar/adjacent contexts
- **Quick Start** (3 sentences) - Immediate usage
- **Common Patterns** (3-5 examples) - Code snippets
- **Known Errors** (with solutions) - Troubleshooting
- **Resources** (docs, code, tests) - Full documentation links
- **Metadata** (updated, confidence, usage) - Quality metrics

### Navigation Flow

```
1. Query (hash, semantic, or NLP)
   ↓
2. PhiDOOR resolves to door code
   ↓
3. Load context bundle
   ↓
4. Check prerequisites
   ↓
5. Load missing prerequisites (recursive)
   ↓
6. Return complete context
   ↓
7. Agent ready to execute (<5 seconds)
```

---

## Common Scenarios

### Scenario 1: Agent Needs to Implement Feature

**Agent:** "I need to implement authentication for the Discord bot"

**PhiDOOR Process:**
1. NLP query: "authentication discord bot"
2. Matches: PG2DISC (PhiGEN Discord bots)
3. Prerequisites: A12ARCH, SEC01AES, D01DOCKER
4. Loads all 4 contexts in order
5. Agent has: Architecture guide, encryption patterns, Docker setup, Discord bot implementation
6. Time: <5 seconds
7. Agent implements without asking questions

### Scenario 2: Agent Encounters Error

**Agent:** Runs code, gets error: "UnicodeDecodeError: 'charmap' codec can't decode"

**PhiDOOR Process:**
1. Error matcher identifies signature
2. Matches: E01PWSH (PowerShell encoding errors)
3. Loads solution context
4. Provides: Root cause, fix code, prevention strategy
5. Agent applies fix automatically
6. Time: <1 second

### Scenario 3: Human Developer Onboarding

**Developer:** "I'm new to the project, where do I start with Windows MCP?"

**PhiDOOR Process:**
1. Query: "TOOLS.WINDOWS_MCP.SETUP" (or "windows mcp getting started")
2. Loads: 827HHSETUP context
3. Shows: Prerequisites (Python, env setup), quick start (3 sentences), full docs link
4. Developer follows quick start, references full docs if needed
5. Time: <2 seconds

### Scenario 4: Cross-Project Pattern Discovery

**Agent:** "Show me all contexts related to encryption"

**PhiDOOR Process:**
1. Tag search: "encryption"
2. Returns: SEC01AES, SEC30CRYPTO, PG1VAULT (password vault), etc.
3. Agent sees: AES-256-GCM best practices, common pitfalls, real-world implementations
4. Can identify: Similar patterns, reusable code, potential improvements
5. Time: <1 second

---

## Performance Expectations

### Lookup Speed
- Hash code lookup: **<50ms**
- Semantic path lookup: **<100ms**
- NLP query (simple): **<500ms**
- NLP query (complex): **<1 second**

### Loading Speed
- Single context: **<1 second**
- With 3 prerequisites: **<3 seconds**
- Complete onboarding: **<5 seconds**

### Success Rates
- Hash lookup: **100%** (if valid code)
- Semantic path: **100%** (if valid path)
- NLP first query: **90%+** (correct door)
- NLP with suggestions: **98%+** (user selects from 3 options)
- Error-driven: **85%+** (for documented errors)

---

## Quality Indicators

### Green Flags (System is Healthy)
- ✅ All validation scripts pass
- ✅ No circular dependencies in prerequisite graph
- ✅ All cross-references resolve correctly
- ✅ Performance benchmarks meet targets
- ✅ Context bundles load successfully
- ✅ NLP queries return sensible matches

### Red Flags (Need Investigation)
- ❌ Validation scripts fail
- ❌ Circular dependencies detected
- ❌ Broken cross-references (404s)
- ❌ Slow performance (>5s onboarding)
- ❌ Missing prerequisites
- ❌ Low NLP match scores (<0.7)

---

## Troubleshooting

### Issue: "Door not found"

**Possible causes:**
- Invalid door code (typo)
- Door not yet created (gap in coverage)
- Semantic path mismatch

**Solutions:**
1. Check INDEX.json for valid door codes
2. Try NLP query instead: findDoor("describe what you need")
3. Check SEMANTIC_MAP.json for valid paths
4. Request door creation (file issue)

### Issue: "Circular dependency detected"

**Possible causes:**
- Door A requires Door B, Door B requires Door A
- Invalid prerequisite graph

**Solutions:**
1. Run: `python validation/validate_dag.py`
2. Review PREREQUISITES.json for cycle
3. Remove circular reference
4. Restructure dependencies (create intermediate door)

### Issue: "Slow performance (>10 seconds)"

**Possible causes:**
- Too many prerequisites (deep chain)
- Large context bundles (>50KB each)
- Network latency (loading from remote)

**Solutions:**
1. Run: `python validation/benchmark_performance.py`
2. Optimize prerequisite chains (flatten if possible)
3. Cache frequently used contexts
4. Use local storage (not remote)

### Issue: "NLP query returns wrong door"

**Possible causes:**
- Ambiguous query
- Insufficient NLP training
- Keywords match multiple doors

**Solutions:**
1. Use more specific query: "windows mcp file write" not just "file write"
2. Check NLP_PATTERNS.json for keyword conflicts
3. Add disambiguation rules
4. Use semantic path instead (explicit)

---

## Next Steps

### For Users
1. Wait for Cerebras to generate PhiDOOR
2. Install and validate system
3. Start using in agents
4. Provide feedback on missing doors

### For Developers
1. Review generated context bundles
2. Verify code examples work
3. Test navigation logic
4. Add new doors as needed

### For Contributors
1. Identify gaps in coverage
2. Suggest new door categories
3. Improve NLP patterns
4. Optimize performance

---

## Resources

### Documentation
- **Main README:** `C:\Dev\PhiSRHI\README.md`
- **Combined Summary:** `C:\Dev\PhiSRHI\docs\COMBINED_DOCUMENTATION_SUMMARY.md`
- **Cerebras Prompt:** `C:\Dev\PhiSRHI\PhiDOOR\CEREBRAS_COMPLETE_PROMPT.md`
- **Architecture Theory:** `C:\Dev\PhiSRHI\MARKDOWNS_*\the_keymaker_theory.md`

### Source Material
- **E:\PythonProjects:** 356 files, 3.21 MB (PhiGEN, PhiWave, FONTBUILDER)
- **C:\Dev:** 784 files, 10.64 MB (PhiLaunch, PhiDEX, Windows-MCP)
- **Total:** 1,140 files, 13.85 MB documentation

### Key Concepts
- **Radial hash index** - One hallway, infinite doors
- **3-layer addressing** - Hash, semantic, NLP
- **Context bundles** - Complete onboarding packages
- **Prerequisite chaining** - Auto-load dependencies
- **Error-driven navigation** - Auto-resolve known errors

---

**Status:** Ready for Cerebras GLM 4.6 357B
**Version:** 1.0.0
**Last Updated:** 2025-11-18

**Build The Keymaster. Enable instant AI onboarding.**
