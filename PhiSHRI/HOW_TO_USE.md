# PhiSHRI - How to Use the Door System

**Welcome to PhiSHRI** (Semantic Hash Repository Index) - The Keymaster's Index System for instant AI agent onboarding.

---

## 🚀 Quick Start (30 Seconds)

### Step 1: Read the Index
```
Read: C:\Dev\PhiSRHI\PhiSHRI\INDEX.json
```
This shows all 236 doors organized by category.

### Step 2: Use Door Codes (No Searching Required!)
Door codes are **semantic** - they tell you what they contain:

| Door Code | Meaning | Path |
|-----------|---------|------|
| `D05SILENT_INSTALL` | Deployment door #5 about silent installation | `CONTEXTS/TOOLS/D05SILENT_INSTALL.json` |
| `W115MESSAGE_QUEUE` | Workflow door #115 about message queues | `CONTEXTS/WORKFLOWS/W115MESSAGE_QUEUE.json` |
| `S01SEC` | Security door #1 about security basics | `CONTEXTS/SECURITY/S01SEC.json` |
| `R09FACTORY_PATTERN` | Architecture door #9 about Factory pattern | `CONTEXTS/ARCHITECTURE/R09FACTORY_PATTERN.json` |

### Step 3: Read the Door Directly
```
Read: C:\Dev\PhiSRHI\PhiSHRI\CONTEXTS\TOOLS\D05SILENT_INSTALL.json
```
Every door contains:
- **Summary**: What this door covers
- **Prerequisites**: Doors to read first
- **Related doors**: Connected topics
- **Common patterns**: Quick reference code/commands
- **Known errors**: Pitfalls to avoid
- **Full context path**: Link to detailed PhiDEX guides

---

## 📚 Door Code Reference

### Prefixes Tell You the Category:

| Prefix | Category | Count | Example |
|--------|----------|-------|---------|
| **D** | Deployment Tools | 10 | D05SILENT_INSTALL |
| **T** | Development Tools | 27 | T25DOCKER |
| **8** | Automation Tools | 5 | 827HHWINC# |
| **W** | Workflows | 131 | W115MESSAGE_QUEUE |
| **S** | Security | 18 | S05SECRETS |
| **R** | Architecture | 16 | R09FACTORY_PATTERN |
| **E** | Errors | 13 | E05RETRY |
| **A** | Agents | 9 | A01DC |
| **P** | Projects | 4 | P01WAVE |

### Door Code Ranges (Quick Reference):

**TOOLS (42 doors)**
- D01-D14: Deployment patterns
- T01-T27: Development tools (MCP, VSCode, Docker, K8s, Vault)
- 800-840: Automation tools (Windows MCP, AHK, PowerShell)

**WORKFLOWS (131 doors)**
- W01-W21: Core coordination patterns
- W22-W101: Process workflows
- W102-W114: Testing and performance
- W115-W131: Agent communication patterns

**SECURITY (18 doors)**
- S01-S18: Security patterns (encryption, RBAC, zero trust, pentesting)

**ARCHITECTURE (16 doors)**
- R01-R16: System architecture and design patterns

**ERRORS (13 doors)**
- E01-E13: Error handling patterns

---

## 🎯 How to Navigate (NO Searching Needed!)

### ❌ DON'T DO THIS:
```bash
# Slow and inefficient!
grep -r "silent install" CONTEXTS/
find . -name "*deploy*"
ls CONTEXTS/TOOLS/ | grep -i enterprise
```

### ✅ DO THIS INSTEAD:
```bash
# Fast and direct!
Read: INDEX.json  # See what exists
Read: CONTEXTS/TOOLS/D05SILENT_INSTALL.json  # Direct access
Read: CONTEXTS/TOOLS/D06ENTERPRISE.json  # Follow related_doors
```

---

## 💡 Common Use Cases

### Use Case 1: "How do I deploy software to 500 machines?"

**Optimal Flow:**
1. Read `INDEX.json` → See TOOLS category mentions "enterprise deployment"
2. Read `CONTEXTS/TOOLS/D06ENTERPRISE.json` → Enterprise deployment door
3. Check `prerequisites` field → Read D05SILENT_INSTALL first
4. Check `related_doors` → See D07GPO, D08AUTOPILOT
5. Check `full_context_path` → Read detailed PhiDEX guide if needed

**Time: ~10 seconds, 4 tool calls**

---

### Use Case 2: "How do agents communicate in PhiVector?"

**Optimal Flow:**
1. Read `INDEX.json` → See WORKFLOWS category mentions "agent communication"
2. Read `CONTEXTS/WORKFLOWS/W115MESSAGE_QUEUE.json` → Message queue pattern
3. Check `related_doors` → W116IPC, W117FILE_IPC, W118REQUEST_RESPONSE
4. Read those doors for complete picture

**Time: ~15 seconds, 5 tool calls**

---

### Use Case 3: "What security patterns are available?"

**Optimal Flow:**
1. Read `INDEX.json` → SECURITY category shows 18 doors (S01-S18)
2. Read `CONTEXTS/SECURITY/` doors based on need:
   - S05SECRETS: Secrets management
   - S07ENCRYPTION: Encryption patterns
   - S12RBAC: Role-based access control
   - S16INPUT_SANITIZATION: Input validation

**Time: ~20 seconds, 5 tool calls**

---

## 🔍 Door Anatomy

Every door JSON has this structure:

```json
{
  "door_code": "D05SILENT_INSTALL",
  "semantic_path": "TOOLS.DEPLOYMENT.SILENT",
  "aliases": ["silent install", "unattended install", "quiet mode"],
  "context_bundle": {
    "summary": "One-line description of what this covers",
    "prerequisites": ["D01WIX", "D02SILENT"],  // Read these first
    "related_doors": ["D06ENTERPRISE", "T11CICD"],  // Related topics
    "onboarding": {
      "quick_start": "How to use this immediately",
      "full_context_path": "/PhiDEX/path/to/detailed/guide.md",
      "common_patterns": [
        "Pattern 1: msiexec /i app.msi /quiet",
        "Pattern 2: installer.exe /VERYSILENT"
      ],
      "known_errors": [
        "NSIS /S is case-sensitive",
        "MSI requires /norestart to prevent reboot"
      ]
    },
    "resources": {
      "docs": ["/PhiDEX/DEPLOYMENT_ALMANAC/..."],
      "code": [],
      "tests": []
    },
    "metadata": {
      "tags": ["deployment", "silent", "automation"],
      "agent_affinity": ["VSCC", "DC", "TERMC"]
    }
  }
}
```

---

## 🎓 Best Practices

### 1. **Always Start with INDEX.json**
- Shows what exists
- Avoids blind searching
- Gives door code ranges

### 2. **Use Door Codes Directly**
- They're semantic (self-documenting)
- D05 = 5th deployment door
- W115 = 115th workflow door
- No guessing needed!

### 3. **Follow Prerequisite Chains**
- Doors list prerequisites
- Read foundation doors first
- Builds complete understanding

### 4. **Check Related Doors**
- Doors link to related topics
- Forms a knowledge graph
- Navigate by relationships

### 5. **Trust the System**
- All content extracted from PhiDEX sources
- Zero hallucinations
- Curated and validated

---

## 📊 Performance Targets

- **Onboarding time**: < 5 seconds
- **Lookup time**: < 100ms (direct file read)
- **Context load**: < 500ms
- **Tool calls per query**: 3-5 (optimal)

---

## 🚫 Anti-Patterns to Avoid

### ❌ Searching for Keywords
```bash
grep -r "deployment" CONTEXTS/  # Slow!
find . -name "*deploy*"  # Unnecessary!
```
**Why bad**: Wastes time, finds too many results, misses semantic structure

### ❌ Using Training Data
```
"Based on my training data about deployment..."
```
**Why bad**: May be outdated, not project-specific, hallucination risk

### ❌ Ignoring Prerequisites
```
Read D06ENTERPRISE without reading D05SILENT_INSTALL first
```
**Why bad**: Missing foundational knowledge, incomplete understanding

---

## 🎯 Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│ PHISHRI QUICK REFERENCE                             │
├─────────────────────────────────────────────────────┤
│ 1. Read INDEX.json                                  │
│ 2. Find door code (D05, W115, S01, etc.)           │
│ 3. Read CONTEXTS/{CATEGORY}/{DOORCODE}.json        │
│ 4. Follow prerequisites and related_doors           │
│ 5. Read full_context_path if needed                │
├─────────────────────────────────────────────────────┤
│ DOOR CODE PATTERNS:                                 │
│   D## = Deployment    W## = Workflow                │
│   T## = Tools         S## = Security                │
│   R## = Architecture  E## = Errors                  │
│   A## = Agents        P## = Projects                │
├─────────────────────────────────────────────────────┤
│ TOTAL: 236 doors across 7 categories               │
│ TARGET: 500+ doors by completion                    │
└─────────────────────────────────────────────────────┘
```

---

## 🆘 Troubleshooting

### "I can't find a door for topic X"
1. Check INDEX.json first
2. Look at category descriptions
3. Search door aliases in category folders
4. Check related_doors in similar topics

### "Which door should I read first?"
1. Check prerequisites field
2. Lower numbers are usually foundational (D01, W01, S01)
3. Follow the prerequisite chain

### "The door references a PhiDEX path that doesn't exist"
1. Check alternate paths: `/PhiDEX/` vs `/PHIiSRHI/PhiDEX/`
2. Use Glob to find the guide: `**/*ENTERPRISE*.md`
3. The door JSON has the key info even without the full guide

---

## 📖 Additional Resources

- **INDEX.json**: Master catalog of all doors
- **000START.json**: First-time user onboarding door
- **ARCHITECTURE.md**: System architecture overview
- **DEPLOYMENT_SUMMARY.md**: Deployment workflow documentation

---

**Version**: 1.0.0
**Last Updated**: 2025-11-22
**Maintained By**: VSCC-001
**Questions?** Check door 000START for interactive guidance.
