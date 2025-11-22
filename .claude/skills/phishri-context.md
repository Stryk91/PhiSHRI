# Skill: PhiSHRI Context

## When to Activate
- Working with door files
- Index operations
- Session bootstrap management
- PhiSHRI-specific development

## PhiSHRI Overview

**Purpose:** AI session continuity through addressable knowledge doors.

**Key Insight:** Door codes replace context re-explanation.
```
Traditional: "Let me explain the project again..."
PhiSHRI: "Resume: D05, S26, T30"
```

## Door System

### Door Code Format
| Prefix | Category | Example |
|--------|----------|---------|
| W## | Workflows | W01COORD, W185RATELIMIT |
| T## | Tools | T30JENKINS, T79PLATFORM_TEAMS |
| S## | Security | S01INPUT_VALIDATION, S55WAF |
| L## | Languages | L01PYTHON, L50YAML |
| R## | Architecture | R01MULTI, R35ESB |
| E## | Errors | E01PERM, E23DATA_CORRUPTION |
| A## | Agents | A01DC, A09KALIC |
| P## | Projects | P01WAVE, P04SHRI |
| 8## | Windows MCP | 800WINMCP, 820PWSH |

### Door JSON Schema (v1.1)
```json
{
  "door_code": "T50PROMETHEUS",
  "semantic_path": "TOOLS.OBSERVABILITY.PROMETHEUS",
  "aliases": ["prometheus", "promql", "prom"],
  "context_bundle": {
    "summary": "2-3 sentence description",
    "prerequisites": ["T26KUBERNETES"],
    "related_doors": ["T51GRAFANA", "T52JAEGER"],
    "onboarding": {
      "quick_start": "Copy-paste ready commands",
      "common_patterns": ["Pattern 1", "Pattern 2"],
      "known_errors": ["Error: cause and solution"]
    }
  },
  "verification": {
    "status": "verified|unverified|outdated",
    "sources": [{"title": "", "url": "", "accessed": ""}],
    "tested_versions": ["Prometheus 2.45+"],
    "confidence_score": 0.95
  },
  "metadata": {
    "last_updated": "2025-11-21T00:00:00Z",
    "version": "1.1.0",
    "category": "TOOLS",
    "subcategory": "OBSERVABILITY",
    "tags": ["prometheus", "monitoring"]
  }
}
```

### Directory Structure
```
PhiSHRI/
├── INDEX.json                  # Master catalog (500 doors)
├── INDEXES/
│   ├── HASH_TABLE.json        # door_code → file_path
│   └── SEMANTIC_MAP.json      # aliases → door_code
└── CONTEXTS/
    ├── WORKFLOWS/             # 205 doors
    ├── TOOLS/                 # 81 doors
    ├── SECURITY/              # 55 doors
    ├── LANGUAGES/             # 50 doors
    ├── ARCHITECTURE/          # 45 doors
    ├── ERRORS/                # 23 doors
    ├── AGENTS/                # 19 doors
    └── PROJECTS/              # 6 doors
```

## Index Operations

### HASH_TABLE.json
Maps door codes to file paths:
```json
{
  "version": "1.0.0",
  "total_doors": 500,
  "mappings": {
    "D05SILENT_INSTALL": "CONTEXTS/TOOLS/D05SILENT_INSTALL.json",
    "W01COORD": "CONTEXTS/WORKFLOWS/W01COORD.json"
  }
}
```

### SEMANTIC_MAP.json
Maps aliases to door codes:
```json
{
  "version": "1.0.0",
  "total_mappings": 2568,
  "mappings": {
    "prometheus": "T50PROMETHEUS",
    "prom": "T50PROMETHEUS",
    "promql": "T50PROMETHEUS",
    "silent install": "D05SILENT_INSTALL"
  }
}
```

### Rebuilding Indexes
```python
# Scan all CONTEXTS/*/*.json
# Extract door_code from each file
# Build HASH_TABLE mappings
# Extract aliases for SEMANTIC_MAP
# Validate no duplicate codes
```

## Bootstrap (Session State)

Location: `~/.phishri/sessions/{agent_id}/bootstrap.json`

```json
{
  "session_id": "abc123",
  "agent_id": "VSCC",
  "created": "2025-11-21T10:00:00Z",
  "updated": "2025-11-21T14:30:00Z",
  "loaded_doors": ["D05", "S26", "T30"],
  "progress": "Working on installer script",
  "checkpoints": [
    {"name": "pre-refactor", "doors": ["D05"], "timestamp": "..."}
  ]
}
```

## Quality Standards

### Door Content Requirements
- `quick_start`: Real commands, copy-paste ready
- `common_patterns`: Actual code, not pseudocode
- `known_errors`: Real error messages with solutions
- `sources`: Official docs when verified

### Validation Checks
- [ ] Valid JSON
- [ ] Required fields present
- [ ] door_code matches filename
- [ ] Prerequisites exist in HASH_TABLE
- [ ] No circular prerequisites
