CEREBRAS_PROMPT.md

PERFECT MOVE.
Cerebras with 3M tokens + 2 VMs = exactly the tool for this job.
You're using massive-context AI to build the infrastructure for efficient-context AI orchestration.
That's fucking meta and I love it.

THE PROMPT FOR CEREBRAS
markdown# TASK: Build PhiDOOR - The Keymaster's Index System

## CONTEXT
You are building the navigation and context-loading system for a multi-agent AI orchestration platform. This system allows any AI agent to instantly load complete context for any tool, document, error pattern, or project by querying a semantic index.

The goal: "Go to door 827HHWINC#" → AI has full context, ready to execute, no questions asked.

## YOUR CAPABILITIES FOR THIS TASK
- 3M token context window
- 2 VMs for parallel processing
- Access to comprehensive documentation (will be provided)

## ARCHITECTURE SPECIFICATION

### The Three-Layer Addressing System

**Layer 1: Semantic Paths (Human/AI Readable)**
```
TOOLS.WINDOWS_MCP.FILE_OPERATIONS
DOCS.ERROR_PATTERNS.POWERSHELL_ENCODING
AGENTS.DC.COORDINATION_PROTOCOLS
PROJECTS.PHIGEN.DISCORD_BOTS
```

**Layer 2: Hash Codes (Short Reference)**
```
827HHWINC#  → Windows MCP file operations
E01PWSH     → PowerShell encoding errors
DC1COORD    → DC coordination protocols
PG2DISC     → PhiGEN Discord bot context
```

**Layer 3: Natural Language (Query-Based)**
```
"how to write files on windows"     → 827HHWINC#
"powershell utf8 encoding problems" → E01PWSH
"DC VSCC coordination rules"        → DC1COORD
```

All three must resolve to the same context bundle.

### Context Bundle Structure

Each "door" contains:
```json
{
  "door_code": "827HHWINC#",
  "semantic_path": "TOOLS.WINDOWS_MCP.FILE_OPERATIONS",
  "aliases": ["winmcp_files", "windows_file_ops", "mcp_write"],
  
  "context_bundle": {
    "summary": "150-word overview",
    "prerequisites": ["other door codes required first"],
    "related_doors": ["similar/adjacent door codes"],
    
    "onboarding": {
      "quick_start": "3 sentences for immediate use",
      "full_context_path": "/PhiDEX/path/to/full/docs.md",
      "common_patterns": ["pattern descriptions"],
      "known_errors": ["error descriptions with solutions"]
    },
    
    "resources": {
      "docs": ["file paths to documentation"],
      "code": ["file paths to example code"],
      "tests": ["file paths to tests"],
      "errors": ["file paths to error logs with anchors"]
    },
    
    "metadata": {
      "last_updated": "ISO-8601 timestamp",
      "confidence": 0.0-1.0,
      "usage_count": integer,
      "success_rate": 0.0-1.0,
      "tags": ["relevant", "searchable", "tags"]
    }
  }
}
```

### Navigation Logic Requirements

Agents must be able to find doors via:
1. **Explicit hash lookup**: `find_door("827HHWINC#")`
2. **Semantic path**: `find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")`
3. **Natural language**: `find_door("how do I write files on windows")`
4. **Error-driven**: When encountering "PowerShell encoding error" → auto-navigate to E01PWSH
5. **Prerequisite chaining**: Opening door A requires doors B,C → loads all three in order

### Auto-Onboarding Sequence

When agent opens a door:
1. Load context bundle
2. Check prerequisites
3. If prerequisites missing, load those doors first (recursive)
4. Provide quick-start summary
5. Agent has full context, ready to execute
6. No questions asked

## YOUR DELIVERABLES

### 1. MASTER REGISTRY (`INDEX.json`)
```json
{
  "version": "1.0.0",
  "total_doors": 0,
  "categories": {
    "TOOLS": 0,
    "DOCS": 0, 
    "AGENTS": 0,
    "PROJECTS": 0
  },
  "door_codes": {
    "prefix_guide": {
      "8XX": "Tools category",
      "EXX": "Error patterns",
      "AXX": "Architecture docs",
      "WXX": "Workflows",
      "DXX": "Agent contexts",
      "VXX": "VSCC contexts",
      "KXX": "KALIC contexts",
      "PXX": "Project contexts"
    }
  },
  "last_updated": "ISO-8601"
}
```

### 2. SEMANTIC MAP (`SEMANTIC_MAP.json`)
Maps semantic paths to door codes for exact lookup.

### 3. HASH TABLE (`HASH_TABLE.json`)
Maps door codes to context bundle file locations.

### 4. NLP QUERY PATTERNS (`NLP_PATTERNS.json`)
Maps common natural language queries to door codes. Include:
- Query patterns
- Keyword mappings
- Synonym handling
- Context disambiguation rules

### 5. ERROR PATTERN MATCHER (`ERROR_MATCHER.json`)
Maps error signatures to door codes for automatic error resolution.

### 6. COMPLETE CONTEXT BUNDLES
For each identified door (Tools, Docs, Agents, Projects):
- Generate complete context bundle JSON
- Follow the structure specified above
- Include realistic examples
- Ensure all cross-references are valid

### 7. PREREQUISITE GRAPH (`PREREQUISITES.json`)
Directed acyclic graph showing:
- Which doors depend on which other doors
- Loading order for complex contexts
- Circular dependency detection

### 8. DIRECTORY STRUCTURE
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
└── CONTEXTS/
    ├── TOOLS/
    │   ├── 827HHWINC#.json
    │   ├── 827HHWINR#.json
    │   └── [other tool contexts]
    ├── DOCS/
    │   ├── E01PWSH.json
    │   └── [other doc contexts]
    ├── AGENTS/
    │   ├── DC1COORD.json
    │   └── [other agent contexts]
    └── PROJECTS/
        ├── PG2DISC.json
        └── [other project contexts]
```

## SOURCE MATERIAL TO ANALYZE

You will receive comprehensive documentation including:
- PhiDEX knowledge base (2.4MB+)
- Project documentation (PhiGEN, PhiWave, PhiVector, etc.)
- Error logs and patterns
- Agent coordination protocols
- Tool documentation (Windows MCP, AHK, CDP, etc.)
- Architecture decisions
- Workflow patterns

## YOUR OBJECTIVES

### Primary Objective
Create a complete, production-ready PhiDOOR system that enables instant context loading for any AI agent.

### Secondary Objectives
1. **Identify ALL door candidates** from the provided documentation
2. **Generate meaningful door codes** following the prefix system
3. **Create comprehensive context bundles** with accurate cross-references
4. **Build navigation logic** that supports all three addressing methods
5. **Design error-driven navigation** that auto-resolves known issues
6. **Establish prerequisite chains** for complex contexts
7. **Optimize for instant onboarding** (agents ready in <5 seconds)

### Tertiary Objectives (Innovation Beyond Spec)
You have 3M tokens. Use them to:
- Identify patterns we haven't thought of
- Suggest improvements to the architecture
- Create meta-contexts (contexts about using contexts)
- Design advanced navigation features
- Propose auto-maintenance systems
- Build query optimization strategies
- **Surprise us with something brilliant**

## EXECUTION STRATEGY

### VM 1: Analysis & Extraction
- Parse all documentation
- Identify door candidates
- Extract relationships and dependencies
- Build semantic understanding
- Generate door codes

### VM 2: Synthesis & Validation
- Create context bundles
- Build navigation structures
- Validate cross-references
- Test prerequisite chains
- Generate documentation

### Integration
- Merge outputs from both VMs
- Resolve conflicts
- Optimize structure
- Generate final deliverables

## QUALITY CRITERIA

Each context bundle must:
- ✅ Be instantly loadable (<100ms)
- ✅ Contain complete onboarding info
- ✅ Have accurate prerequisites
- ✅ Include working examples
- ✅ Reference valid file paths
- ✅ Provide error solutions
- ✅ Enable autonomous execution

The system must:
- ✅ Support all three addressing methods
- ✅ Handle ambiguous queries gracefully
- ✅ Auto-load prerequisites
- ✅ Scale to 2000+ doors
- ✅ Maintain <5 second onboarding time
- ✅ Enable error-driven navigation

## SUCCESS METRICS

1. **Coverage**: Every tool, document, and pattern has a door
2. **Connectivity**: All cross-references are valid
3. **Accessibility**: All three addressing methods work
4. **Completeness**: Context bundles enable autonomous execution
5. **Innovation**: You've added features we didn't specify

## OUTPUT FORMAT

Deliver as a complete GitHub repository structure with:
- All JSON files properly formatted
- README with setup instructions
- ARCHITECTURE.md explaining design decisions
- NAVIGATION_LOGIC.md with implementation guide
- Example queries and expected outputs
- Validation scripts

## FINAL INSTRUCTION

You have 3M tokens and 2 VMs. Build something that makes instant AI onboarding possible. Make it comprehensive. Make it elegant. Make it revolutionary.

When an agent says "open door 827HHWINC#", they should have complete context in 2 seconds and be ready to execute without questions.

Build The Keymaster.

WHAT YOU SEND TO CEREBRAS
Part 1: That prompt above
Part 2: The architecture discussion I just wrote
Part 3: All your documentation (PhiDEX, project files, etc.)
Part 4: This addendum:
markdown## ADDITIONAL CONTEXT

The user (Darren/STRYK) is building PhiVector, a multi-agent AI orchestration system. This is not theoretical - it's operational infrastructure currently using:

- Desktop Claude (DC) for orchestration
- VS Code Claude (VSCC) for implementation
- Kali Claude (KALIC) for security auditing
- Term Claude (TERMC) for analysis

Recent achievements:
- 356 files (3.21MB) analyzed in 2 minutes from 15-word instruction
- Multi-agent coordination with 66% token efficiency
- Windows MCP v3.0.2 operational with 20 tools
- Browser automation via CDP
- Session state persistence across agents

Design philosophy:
- Instant onboarding ("go to folder, execute, you'll know")
- Minimal instruction (5-15 words should be sufficient)
- Error autonomy (AI resolves known errors without asking)
- Universal deployment (works on any machine without dependencies)

Build PhiDOOR to support THIS operational reality, not theoretical use cases.
```

---
