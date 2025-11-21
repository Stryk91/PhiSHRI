# VSCC PhiSHRI Onboarding Guide
## How to Get Back On Track When You Forget Everything

**Last Updated**: 2025-11-22
**Created By**: VSCC-001 (after experiencing this exact problem)
**Project**: PhiSHRI Door Generation (500+ context doors)

---

## THE PROBLEM

You're a new VSCC session. User says "bro wtf why do u only have 2 past conversations" or "we were up to door 6A".

**You have NO IDEA what they're talking about.**

This document fixes that.

---

## THE SOLUTION: BOOTSTRAP FILES

Everything you need is in **C:\Temp\VSCC_SESSION_BOOTSTRAP.md**

### EMERGENCY QUICK START (2 minutes)

1. **Read this file FIRST:**
   ```
   C:\Temp\VSCC_SESSION_BOOTSTRAP.md
   ```

2. **Check current status:**
   ```
   C:\Temp\VSSC_RESPONSE.txt
   ```

3. **See what DC said:**
   ```
   C:\Temp\DC_RESPONSE.txt
   ```

4. **You're now up to speed. Continue the batch.**

---

## WHO ARE YOU?

**Agent ID**: VSCC-001
**Project**: PhiSHRI (Semantic Hash Repository Index)
**Role**: Door generation from PhiDEX markdown files
**Goal**: Generate 500+ context doors (JSON files)
**Partner**: DC (Desktop Claude) - coordinates via C:\Temp files

---

## WHAT IS PhiSHRI?

**Purpose**: The Keymaster's Index System for instant AI agent onboarding

**Structure**:
- Each "door" = JSON context bundle
- Doors organized by category (WORKFLOWS, TOOLS, SECURITY, etc.)
- Agents load doors to instantly understand topics
- Target: 500+ doors minimum

**Current Progress** (check bootstrap for exact numbers):
- Baseline: 51 doors
- Batch 1A-5A: 125 doors added
- Total: 176 doors as of Batch 5A completion
- Remaining: ~324 doors to reach 500

---

## THE BATCH WORKFLOW

This is how door generation works:

### Step 1: You Generate Doors (30 per batch)
- Read markdown from `C:\Dev\CODEX\PhiDEX\`
- Extract real content (ZERO hallucinations)
- Create JSON door files in `C:\Dev\PhiSRHI\PhiSHRI\CONTEXTS\[CATEGORY]\`

### Step 2: You Create Next Bootstrap
- Update `C:\Temp\VSCC_SESSION_BOOTSTRAP.md`
- Include next batch door codes
- Update progress stats

### Step 3: User Compacts Session
- User saves/summarizes the session
- Documents what was accomplished

### Step 4: Next Session Launches
- New VSCC instance (you!) reads bootstrap
- Continues from where we left off
- Repeat cycle

**That's the loop. Simple.**

---

## CRITICAL FILE LOCATIONS

### Bootstrap & Coordination
```
C:\Temp\VSCC_SESSION_BOOTSTRAP.md   ← READ THIS FIRST (has everything)
C:\Temp\VSSC_RESPONSE.txt            ← Your responses to DC (typo, should be VSCC)
C:\Temp\DC_RESPONSE.txt              ← DC's responses to you
```

### PhiSHRI Repository
```
C:\Dev\PhiSRHI\                      ← Root (typo in folder name, ignore for now)
  └─ PhiSHRI\                         ← Actual project folder
      ├─ CONTEXTS\                    ← All door JSON files here
      │   ├─ WORKFLOWS\               ← W## doors
      │   ├─ TOOLS\                   ← T##, 8##, D## doors
      │   ├─ AGENTS\                  ← A## doors
      │   ├─ SECURITY\                ← S## doors
      │   ├─ PROJECTS\                ← P## doors
      │   ├─ ARCHITECTURE\            ← R## doors
      │   └─ ERRORS\                  ← E## doors
      └─ INDEX.json                   ← Update after each batch
```

### Source Material (PhiDEX)
```
C:\Dev\CODEX\PhiDEX\                 ← Where markdown source files live
  └─ MASTER_CODEX\                   ← Primary source for door content
```

### Your Continuity Log
```
C:\Dev\PhiSRHI\PHIiSRHI\MARKDOWNS_(THEONLYFILESYOUWILLEDIT)\VSCC_CONTINUITY.md
```

---

## PROJECT NAMING CONFUSION (FIX LATER)

**The Typo Problem**:
- Folder: `C:\Dev\PhiSRHI\` (wrong spelling)
- Project: `PhiSHRI\` (correct spelling)
- Files mention both

**What To Do**: Treat them as **interchangeable** for now. We'll reconcile later.

**Also**:
- Files say "VSSC" (wrong)
- Should be "VSCC" (correct)
- You are VSCC, not VSSC
- We'll fix typos later without breaking workflow

---

## DOOR CODE NAMING CONVENTION

Format: `[PREFIX][SEQUENCE][SUFFIX]`

**Prefixes**:
- **W##** = Workflows (W01-W200+)
- **T##** = Tools (T01-T99)
- **8##** = Tools (800-899)
- **D##** = Documentation (D01-D99)
- **A##** = Agents (A01-A99)
- **P##** = Projects (P01-P99)
- **R##** = Architecture (R01-R99)
- **S##** = Security (S01-S99)
- **E##** = Errors (E01-E99)

**Examples**:
- `W102UNIT_TESTING` - Workflow 102, Unit Testing
- `R09FACTORY_PATTERN` - Architecture 09, Factory Pattern
- `S16INPUT_SANITIZATION` - Security 16, Input Sanitization
- `T21PROMETHEUS` - Tool 21, Prometheus

---

## DOOR JSON STRUCTURE

Every door follows this template:

```json
{
  "door_code": "W102UNIT_TESTING",
  "semantic_path": "WORKFLOWS.TESTING.UNIT",
  "aliases": ["unit test", "unittest", "testing"],
  "context_bundle": {
    "summary": "One-sentence from actual file content",
    "prerequisites": ["W01COORD", "T05MCP_ARCH"],
    "related_doors": ["W103INTEGRATION_TESTING"],
    "onboarding": {
      "quick_start": "How-to from real markdown",
      "full_context_path": "/PhiDEX/MASTER_CODEX/04_TESTING/file.md",
      "common_patterns": ["Pattern 1 from file", "Pattern 2"],
      "known_errors": []
    },
    "resources": {
      "docs": ["/PhiDEX/actual/path.md"],
      "code": [],
      "tests": [],
      "errors": []
    },
    "metadata": {
      "last_updated": "2025-11-22T00:00:00Z",
      "confidence": 1.0,
      "usage_count": 0,
      "success_rate": 0.0,
      "tags": ["testing", "unit", "workflows"],
      "category": "WORKFLOWS",
      "subcategory": "TESTING",
      "version": "1.0.0",
      "tested_on": ["Windows 10", "Windows 11"],
      "agent_affinity": ["VSCC", "DC"]
    }
  }
}
```

---

## QUALITY CONTROLS (CRITICAL)

### ZERO HALLUCINATIONS PROTOCOL

1. **Read actual markdown file BEFORE creating door**
2. **Extract real patterns/content ONLY**
3. **Verify door_code uniqueness** (no duplicates)
4. **Validate JSON structure** (must parse correctly)
5. **Cross-reference prerequisites** (doors must exist)

**If you didn't read the markdown, you're hallucinating. Stop and read it.**

---

## WHEN USER SAYS "DOOR 6A"

They mean **Batch 6A** (the 6th batch of doors).

**NOT** a specific door like S06 (Security Door 06).

**Batch naming**:
- Batch 1A = First batch (25 doors)
- Batch 2A = Second batch (25 doors)
- ...
- Batch 6A = Sixth batch (30 doors)
- Batch 7A = Seventh batch (30 doors)

Check the bootstrap to see which batch is next.

---

## COMMUNICATION PROTOCOL WITH DC

### File-Based Messaging
1. **You write to**: `C:\Temp\VSSC_RESPONSE.txt` (yes, typo, use it anyway)
2. **DC writes to**: `C:\Temp\DC_RESPONSE.txt`
3. **Turn-based**: Wait for DC's response before next action

### Message Format
Keep it concise:
```
VSCC → DC: Batch 6A complete. 206 total doors (41.2%).
Bootstrap ready for Batch 7A. - VSCC
```

---

## TYPICAL BATCH GENERATION WORKFLOW

### 1. Read Bootstrap
```bash
Read: C:\Temp\VSCC_SESSION_BOOTSTRAP.md
```

- Current progress? (e.g., 176 doors)
- Next batch codes? (e.g., W102-W114, R09-R16, etc.)
- Source files? (which markdown to read)

### 2. Read Source Material
```bash
Read: C:\Dev\CODEX\PhiDEX\MASTER_CODEX\04_TESTING\TESTING_COMPREHENSIVE_GUIDE.md
```

- Extract REAL patterns
- Note prerequisites
- Identify common errors

### 3. Generate Doors
```bash
Create: C:\Dev\PhiSRHI\PhiSHRI\CONTEXTS\WORKFLOWS\W102UNIT_TESTING.json
Create: C:\Dev\PhiSRHI\PhiSHRI\CONTEXTS\WORKFLOWS\W103INTEGRATION_TESTING.json
...
```

- 30 doors per batch (Batch 6A+)
- Validate JSON structure
- Check uniqueness

### 4. Update INDEX.json
```bash
Edit: C:\Dev\PhiSRHI\PhiSHRI\INDEX.json
```

- Update `total_doors` count
- Update category counts
- Update `last_updated` timestamp

### 5. Create Next Bootstrap
```bash
Edit: C:\Temp\VSCC_SESSION_BOOTSTRAP.md
```

- Update progress (e.g., 206 doors)
- List next batch codes (Batch 7A)
- Update source file priorities

### 6. Message DC
```bash
Write: C:\Temp\VSSC_RESPONSE.txt
```

- Report completion
- State total doors
- Confirm bootstrap ready

---

## COMMON CONFUSION SCENARIOS

### "We were up to door 6A"
**Translation**: We completed Batch 5A. Next is Batch 6A (30 doors).

**Action**: Read bootstrap, see Batch 6A door codes, generate them.

---

### "Check the logs and bootstrap"
**Translation**: Read these files:
- `C:\Temp\VSCC_SESSION_BOOTSTRAP.md` (main bootstrap)
- `C:\Temp\VSSC_RESPONSE.txt` (your last response)
- Optionally: Continuity logs in MARKDOWNS folder

**Action**: Read those files, get context, continue work.

---

### "Where do session compacts get saved?"
**Translation**: How does the bootstrap/compact workflow work?

**Answer**:
1. You create bootstrap with next batch info
2. User compacts the session (saves summary)
3. Next session, new VSCC reads bootstrap
4. Cycle repeats

**Location**: Bootstrap at `C:\Temp\VSCC_SESSION_BOOTSTRAP.md`

---

### "500+ doors claim but only 176 found"
**Translation**: We're GENERATING 500+ doors. Currently at 176. Not done yet.

**Action**: Check bootstrap for progress. Continue generating batches.

---

## PERFORMANCE EXPECTATIONS

### Target Metrics
- **Onboarding time**: <5 seconds (read bootstrap)
- **Door lookup**: <100ms (after generation)
- **Context load**: <500ms
- **Batch generation**: ~30 doors per session

### Progress Tracking
- Check `total_doors` in INDEX.json
- Bootstrap shows current batch
- Target: 500+ doors minimum (may go higher)

---

## WHAT TO DO RIGHT NOW

If you're reading this because you're confused:

1. **Read bootstrap**: `C:\Temp\VSCC_SESSION_BOOTSTRAP.md`
2. **Check your last response**: `C:\Temp\VSSC_RESPONSE.txt`
3. **See DC's message**: `C:\Temp\DC_RESPONSE.txt`
4. **Understand current state**: How many doors? Which batch next?
5. **Continue the work**: Generate next batch of doors
6. **Update bootstrap**: Prepare for next session
7. **Message DC**: Report completion

**You're VSCC-001. You generate PhiSHRI doors. You work with DC. Now get to it.**

---

## TROUBLESHOOTING

### "Bootstrap file not found"
**Problem**: `C:\Temp\VSCC_SESSION_BOOTSTRAP.md` doesn't exist

**Solution**: Check these locations:
- `C:\Temp\VSSC_SESSION_BOOTSTRAP.md` (typo version)
- Previous VSCC response in `C:\Temp\VSSC_RESPONSE.txt`
- Ask user for current batch status

---

### "Door codes don't match INDEX.json"
**Problem**: INDEX.json says 176 doors but you find different count

**Solution**:
- INDEX.json may be outdated
- Count actual files: `find PhiSHRI/CONTEXTS -name "*.json" | wc -l`
- Update INDEX.json to match reality

---

### "PhiDEX markdown files not found"
**Problem**: Can't find source material at `C:\Dev\CODEX\PhiDEX\`

**Solution**:
- Verify path: `ls C:/Dev/CODEX/PhiDEX/`
- Check alternate: `C:\Dev\PhiDEX\`
- Ask user for correct PhiDEX location

---

## FINAL NOTES

### Remember
- You are **VSCC** (not VSSC - that's a typo)
- Project is **PhiSHRI** (not PhiSRHI folder - that's also a typo)
- Agent ID: **VSCC-001** for this project
- Partner: **DC** (Desktop Claude)
- Goal: **500+ doors** minimum

### The Loop
1. Read bootstrap
2. Generate batch (~30 doors)
3. Update INDEX.json
4. Create next bootstrap
5. Message DC
6. User compacts session
7. Repeat

### Quality Over Speed
- ZERO hallucinations
- Read actual markdown files
- Extract real patterns only
- Validate JSON structure
- Cross-reference prerequisites

---

**Document created**: 2025-11-22
**By**: VSCC-001
**After experiencing**: Complete context loss and confusion
**Purpose**: Never be confused again

**This is your lifeline. Use it.**
