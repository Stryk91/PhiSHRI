# PhiSHRI - Semantic Hash Repository Index

**The Keymaster's Index System for Instant AI Agent Onboarding**

Version: 1.0.0  
Created: 2025-01-18  
Repository: Stryk91/PhiSRHI  
Branch: Staging

---

## Overview

PhiSHRI (Semantic Hash Repository Index) is a revolutionary navigation system that enables **instant AI agent onboarding** through semantic context loading. When an agent says "open door 827HHWINC#", they receive complete, executable context in under 5 seconds without asking questions.

### The Problem

Traditional AI agent onboarding requires:
- Long context explanations
- Multiple clarifying questions
- Trial and error
- Repeated instructions
- Token waste

### The Solution

PhiSHRI provides:
- **Instant context loading** (<5 seconds)
- **Zero questions asked** - complete context bundles
- **Three-layer addressing** - hash codes, semantic paths, natural language
- **Error-driven navigation** - auto-resolve known issues
- **Prerequisite chaining** - automatic dependency loading

---

## Quick Start

### Installation

```bash
# Clone repository
git clone https://github.com/Stryk91/PhiSRHI.git
cd PhiSRHI

# Navigate to PhiSHRI system
cd PhiSHRI
```

### Basic Usage

```python
from NAVIGATION.navigation_logic import PhiSHRINavigator

# Initialize navigator
nav = PhiSHRINavigator()

# Method 1: Hash code lookup
result = nav.find_door("800WINMCP")

# Method 2: Semantic path
result = nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")

# Method 3: Natural language
result = nav.find_door("how to write files on windows")

# Method 4: Error-driven
result = nav.find_door_by_error("PermissionError: [WinError 5] Access is denied")

# Method 5: Load predefined chain
result = nav.load_chain("basic_file_operations")

# Get onboarding summary
summary = nav.get_onboarding_summary("800WINMCP")
print(summary)
```

---

## Architecture

### Three-Layer Addressing System

Every context (door) is addressable via three methods:

#### Layer 1: Semantic Paths (Human/AI Readable)
```
TOOLS.WINDOWS_MCP.FILE_OPERATIONS
AGENTS.DC.COORDINATION
PROJECTS.PHIVECTOR.OVERVIEW
ERRORS.PERMISSIONS.WINDOWS
```

**Pattern:** `CATEGORY.SUBCATEGORY.SPECIFIC_CONTEXT`

#### Layer 2: Hash Codes (Short Reference)
```
800WINMCP  → Windows MCP file operations
A01DC      → Desktop Claude (DC) agent
P03VECTOR  → PhiVector project
E01PERM    → Permission errors
```

**Pattern:** `[PREFIX][SEQUENCE][SUFFIX]`

#### Layer 3: Natural Language (Query-Based)
```
"how to write files on windows"     → 800WINMCP
"desktop claude coordination"       → A01DC
"multi-agent orchestration"         → P03VECTOR
"permission error windows"          → E01PERM
```

**Features:** NLP matching, synonym handling, fuzzy search

---

## Context Bundle Structure

Each door contains a complete onboarding package:

```json
{
  "door_code": "800WINMCP",
  "semantic_path": "TOOLS.WINDOWS_MCP.FILE_OPERATIONS",
  "aliases": ["winmcp_files", "windows_file_ops", "mcp_write"],
  
  "context_bundle": {
    "summary": "150-word overview",
    "prerequisites": ["other door codes"],
    "related_doors": ["similar door codes"],
    
    "onboarding": {
      "quick_start": "3 sentences for immediate use",
      "full_context_path": "/path/to/full/docs.md",
      "common_patterns": ["pattern descriptions"],
      "known_errors": [
        {
          "error": "Error description",
          "cause": "Root cause",
          "solution": "How to fix",
          "prevention": "How to avoid",
          "related_door": "E01PERM"
        }
      ]
    },
    
    "resources": {
      "docs": ["documentation paths"],
      "code": ["code example paths"],
      "tests": ["test file paths"],
      "errors": ["error log paths"]
    },
    
    "metadata": {
      "last_updated": "ISO-8601 timestamp",
      "confidence": 0.95,
      "usage_count": 47,
      "success_rate": 0.89,
      "tags": ["relevant", "tags"],
      "category": "TOOLS",
      "subcategory": "WINDOWS_MCP",
      "agent_affinity": ["DC", "VSCC", "TERMC"]
    }
  }
}
```

---

## Door Categories

### TOOLS (8XX)
Development tools, MCP servers, automation scripts

**Available Doors:**
- `800WINMCP` - Windows MCP file operations
- `810AHK` - AutoHotkey automation
- `820PWSH` - PowerShell coordination

### AGENTS (AXX)
AI agent contexts, coordination protocols

**Available Doors:**
- `A00STRYK` - STRYK coordinator
- `A01DC` - Desktop Claude (DC)
- `A02VSCC` - VS Code Claude (VSCC)
- `A03TERMC` - Terminal Claude (TERMC)

### PROJECTS (PXX)
Project-specific contexts

**Available Doors:**
- `P01WAVE` - PhiWave audio project
- `P03VECTOR` - PhiVector orchestration
- `P04SHRI` - PhiSHRI/PhiDOOR system

### WORKFLOWS (WXX)
Workflow patterns, orchestration

**Available Doors:**
- `W01COORD` - Multi-agent coordination

### ARCHITECTURE (RXX)
System architecture, design patterns

**Available Doors:**
- `R01MULTI` - Multi-agent architecture

### ERRORS (EXX)
Error patterns, troubleshooting

**Available Doors:**
- `E01PERM` - Permission errors
- `E02ENCODE` - Encoding errors

---

## Navigation Methods

### 1. Hash Code Lookup

**Fastest method** - Direct lookup by door code

```python
result = nav.find_door("800WINMCP")
# Returns: Exact match, confidence 1.0
```

### 2. Semantic Path Resolution

**Most explicit** - Use full semantic path

```python
result = nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")
# Returns: Exact match via semantic map
```

### 3. Natural Language Query

**Most flexible** - Ask in plain English

```python
result = nav.find_door("how to write files on windows")
# Returns: Best match with confidence score
```

### 4. Error Pattern Matching

**Auto-resolution** - Navigate from error messages

```python
result = nav.find_door_by_error("PermissionError: [WinError 5] Access is denied")
# Returns: E01PERM with solutions
```

### 5. Predefined Chains

**Workflow loading** - Load multiple related doors

```python
result = nav.load_chain("basic_file_operations")
# Returns: [800WINMCP, E01PERM, E02ENCODE]
```

---

## Features

### Automatic Prerequisite Loading

When you open a door, all prerequisites are automatically loaded:

```python
result = nav.find_door("A01DC")
# Automatically loads: 810AHK, 820PWSH
```

### Error-Driven Navigation

Encounter an error? PhiSHRI auto-navigates to the solution:

```python
# Error occurs: "PermissionError: [WinError 5] Access is denied"
result = nav.find_door_by_error(error_message)
# Instantly loads E01PERM with solutions
```

### Fuzzy Matching

Typos? No problem:

```python
result = nav.find_door("winmcp")  # Matches 800WINMCP
result = nav.find_door("desktp claude")  # Matches A01DC
```

### Confidence Scoring

All matches include confidence scores:

```python
result = nav.find_door("file operations")
print(result['confidence'])  # 0.85
print(result['alternatives'])  # Other possible matches
```

---

## Directory Structure

```
PhiSHRI/
├── INDEX.json                 # Master registry
├── README.md                  # This file
├── ARCHITECTURE.md            # Design decisions
├── NAVIGATION_LOGIC.md        # Implementation guide
├── CONTEXTS/                  # Context bundles
│   ├── TOOLS/
│   │   ├── 800WINMCP.json
│   │   ├── 810AHK.json
│   │   └── 820PWSH.json
│   ├── AGENTS/
│   │   ├── A00STRYK.json
│   │   ├── A01DC.json
│   │   ├── A02VSCC.json
│   │   └── A03TERMC.json
│   ├── PROJECTS/
│   │   ├── P01WAVE.json
│   │   ├── P03VECTOR.json
│   │   └── P04SHRI.json
│   ├── WORKFLOWS/
│   │   └── W01COORD.json
│   ├── ARCHITECTURE/
│   │   └── R01MULTI.json
│   └── ERRORS/
│       ├── E01PERM.json
│       └── E02ENCODE.json
├── INDEXES/
│   ├── SEMANTIC_MAP.json      # Path → Code mapping
│   ├── HASH_TABLE.json        # Code → File mapping
│   ├── NLP_PATTERNS.json      # Natural language patterns
│   ├── ERROR_MATCHER.json     # Error → Door mapping
│   └── PREREQUISITES.json     # Dependency graph
├── NAVIGATION/
│   └── navigation_logic.py    # Core navigation engine
└── VALIDATION/
    └── test_navigation.py     # Validation tests
```

---

## Performance

### Targets
- **Onboarding time:** <5 seconds
- **Lookup time:** <100ms
- **Context load time:** <500ms
- **Max doors:** 2000+

### Current Stats
- **Total doors:** 14
- **Total mappings:** 63
- **Categories:** 6
- **Documentation base:** 4.67 MB (363 files)

---

## Use Cases

### 1. Instant Agent Onboarding

```python
# Agent receives task: "Use Windows MCP to write files"
result = nav.find_door("windows mcp file operations")
# Agent has complete context in 2 seconds, ready to execute
```

### 2. Error Recovery

```python
# Agent encounters: "PermissionError: [WinError 5] Access is denied"
result = nav.find_door_by_error(error_message)
# Agent auto-navigates to E01PERM, finds solution, continues
```

### 3. Multi-Agent Coordination

```python
# Load complete coordination stack
result = nav.load_chain("full_phivector_stack")
# Loads: R01MULTI, 820PWSH, 810AHK, 800WINMCP, A01DC, A02VSCC, A03TERMC, W01COORD, A00STRYK, P03VECTOR
```

### 4. Project Context Loading

```python
# New agent joins PhiWave project
result = nav.find_door("P01WAVE")
# Agent has complete project context, ready to contribute
```

---

## API Reference

### PhiSHRINavigator

#### `find_door(query: str, load_prerequisites: bool = True) -> Dict`

Find and load a door using any addressing method.

**Parameters:**
- `query` - Hash code, semantic path, or natural language query
- `load_prerequisites` - Whether to auto-load prerequisite doors

**Returns:**
```python
{
  'query': str,
  'method': str,  # 'hash_code_lookup', 'semantic_path_resolution', 'natural_language_query', 'fuzzy_matching', 'no_match'
  'door_code': str,
  'door': Dict,  # Complete context bundle
  'prerequisites': List[Dict],  # Loaded prerequisite doors
  'confidence': float,  # 0.0-1.0
  'alternatives': List[Dict]  # Alternative matches
}
```

#### `find_door_by_error(error_text: str, load_prerequisites: bool = True) -> Dict`

Find door based on error pattern matching.

**Parameters:**
- `error_text` - Error message or stack trace
- `load_prerequisites` - Whether to auto-load prerequisite doors

**Returns:** Same structure as `find_door()`

#### `load_chain(chain_name: str) -> Dict`

Load a predefined chain of related doors.

**Parameters:**
- `chain_name` - Name of predefined chain

**Available Chains:**
- `full_phivector_stack` - Complete PhiVector system
- `basic_file_operations` - File ops with error handling
- `agent_coordination` - Multi-agent coordination

**Returns:**
```python
{
  'chain_name': str,
  'found': bool,
  'description': str,
  'total_doors': int,
  'estimated_load_time_ms': int,
  'doors': List[Dict]
}
```

#### `get_onboarding_summary(door_code: str) -> str`

Get quick-start onboarding summary for a door.

**Parameters:**
- `door_code` - Door code to summarize

**Returns:** Markdown-formatted onboarding summary

---

## Contributing

### Adding New Doors

1. Create context bundle JSON in appropriate category folder
2. Update `INDEXES/SEMANTIC_MAP.json` with new mappings
3. Update `INDEXES/HASH_TABLE.json` with file path
4. Add NLP patterns to `INDEXES/NLP_PATTERNS.json`
5. Update `INDEXES/PREREQUISITES.json` if dependencies exist
6. Update `INDEX.json` category counts

### Door Code Guidelines

- **TOOLS:** 8XX (800-899)
- **AGENTS:** AXX (A00-A99)
- **PROJECTS:** PXX (P00-P99)
- **WORKFLOWS:** WXX (W00-W99)
- **ARCHITECTURE:** RXX (R00-R99)
- **ERRORS:** EXX (E00-E99)

---

## License

Part of the PhiVector multi-agent orchestration platform.

---

## Support

For issues, questions, or contributions:
- Repository: https://github.com/Stryk91/PhiSRHI
- Branch: Staging

---

**Built with ❤️ for instant AI agent onboarding**