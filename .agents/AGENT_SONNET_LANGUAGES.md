# CLAUDE SONNET 4.5 BOOTSTRAP - PhiSHRI Languages Batch

## Model Context
- **Model**: Claude Sonnet 4.5
- **Role**: Content generation for PhiSHRI Languages doors
- **Task**: Generate 50 programming language best practices doors (L01-L50)

---

## PART 1: PROJECT CONTEXT

### What is PhiSHRI?
**PhiSHRI** = **S**emantic(**S**elf) **H**ashing **R**adial **R**epository **I**ndex

A system solving AI context continuity. Instead of re-explaining context every session, AI agents load "doors" - curated JSON knowledge bundles indexed by semantic codes.

**Key Innovation:** Door codes as session state serialization.
- Traditional: 10 sessions = 320K tokens with context drift
- PhiSHRI: 10 sessions = 56K tokens with zero drift (83% savings)

### Current State (2025-11-21)
- **Total Doors**: 373 (323 base + 50 from Cerebras DevOps batch)
- **Target**: 500 minimum, then 100MB total content
- **MCP Server**: Functional, 10/10 tools passing

### Quality Benchmark
A parallel batch (T30-T79) was just completed by Cerebras 347B. Initial delivery was 5/10 quality and required rework. Final accepted quality was 8/10.

**You are expected to deliver 8/10 quality on first submission.**

The difference between 5/10 and 8/10:

| Aspect | 5/10 (Rejected) | 8/10 (Accepted) |
|--------|-----------------|-----------------|
| quick_start | "Install and configure Python" | `pyenv install 3.12.0 && pyenv global 3.12.0 && python -m venv .venv && source .venv/bin/activate` |
| known_errors | "Import errors: check dependencies" | "ModuleNotFoundError: `pip list \| grep package` to verify, `pip install -e .` for editable installs" |
| common_patterns | "Use type hints" | `def process(data: list[dict[str, Any]]) -> Result[T, Error]:` with explanation |

---

## PART 2: DOOR SCHEMA

Every door must follow this exact structure:

```json
{
  "door_code": "L01PYTHON",
  "semantic_path": "LANGUAGES.PYTHON.BEST_PRACTICES",
  "aliases": [
    "python",
    "python3",
    "py",
    "python best practices",
    "pythonic"
  ],
  "context_bundle": {
    "summary": "2-3 sentence overview of the language/topic and its key characteristics",
    "prerequisites": ["L00GENERAL"],
    "related_doors": ["L02NODE", "L03GO"],
    "onboarding": {
      "quick_start": "Copy-paste ready commands to get started",
      "full_context_path": "/PhiDEX/MASTER_CODEX/09_LANGUAGES/L01PYTHON_GUIDE.md",
      "common_patterns": [
        "Pattern 1: Actual code with explanation",
        "Pattern 2: Real syntax examples",
        "Pattern 3: Production-ready snippets"
      ],
      "known_errors": [
        "Specific error message: cause and solution with actual commands",
        "Another real error: debugging steps"
      ]
    },
    "resources": {
      "docs": ["/PhiDEX/MASTER_CODEX/09_LANGUAGES/L01PYTHON_GUIDE.md"],
      "code": [],
      "tests": [],
      "errors": []
    },
    "metadata": {
      "last_updated": "2025-11-21T00:00:00Z",
      "confidence": 1.0,
      "usage_count": 0,
      "success_rate": 0.0,
      "tags": ["python", "language", "best-practices"],
      "category": "LANGUAGES",
      "subcategory": "PYTHON",
      "version": "1.0.0",
      "tested_on": ["Python 3.10+"],
      "agent_affinity": ["VSCC", "DC", "TERMC"]
    }
  }
}
```

---

## PART 3: YOUR ASSIGNMENT - 50 DOORS (L01-L50)

### L01-L10: Python Ecosystem (10 doors)
| Code | Title | Focus |
|------|-------|-------|
| L01 | L01PYTHON | Core Python best practices, idioms, PEP8 |
| L02 | L02PYTHON_ASYNC | asyncio, async/await, event loops, aiohttp |
| L03 | L03PYTHON_TYPING | Type hints, mypy, Protocol, generics |
| L04 | L04PYTHON_TESTING | pytest, fixtures, mocking, coverage |
| L05 | L05PYTHON_PACKAGING | pyproject.toml, setuptools, poetry, pip |
| L06 | L06PYTHON_PERF | Profiling, cython, numba, optimization |
| L07 | L07PYTHON_DATA | pandas, numpy patterns, vectorization |
| L08 | L08PYTHON_WEB | FastAPI, Flask, Django patterns |
| L09 | L09PYTHON_CLI | click, typer, argparse, rich |
| L10 | L10PYTHON_SECURITY | bandit, safety, secrets handling |

### L11-L20: JavaScript/TypeScript (10 doors)
| Code | Title | Focus |
|------|-------|-------|
| L11 | L11NODEJS | Node.js patterns, event loop, streams |
| L12 | L12TYPESCRIPT | TS config, strict mode, advanced types |
| L13 | L13TS_PATTERNS | Discriminated unions, branded types, inference |
| L14 | L14REACT_PATTERNS | Hooks, state management, performance |
| L15 | L15NEXTJS | App router, server components, caching |
| L16 | L16NODE_TESTING | Jest, Vitest, testing-library, MSW |
| L17 | L17NPM_PACKAGES | Package publishing, monorepos, changesets |
| L18 | L18NODE_PERF | V8 optimization, memory leaks, profiling |
| L19 | L19DENO | Deno runtime, permissions, fresh framework |
| L20 | L20BUN | Bun runtime, bundler, test runner |

### L21-L30: Go (10 doors)
| Code | Title | Focus |
|------|-------|-------|
| L21 | L21GO_BASICS | Go idioms, error handling, interfaces |
| L22 | L22GO_CONCURRENCY | Goroutines, channels, select, sync |
| L23 | L23GO_TESTING | Table tests, benchmarks, fuzzing |
| L24 | L24GO_MODULES | go.mod, versioning, private modules |
| L25 | L25GO_WEB | net/http, chi, gin, middleware |
| L26 | L26GO_CLI | cobra, viper, bubbletea |
| L27 | L27GO_PERF | pprof, escape analysis, allocation |
| L28 | L28GO_GENERICS | Type parameters, constraints, patterns |
| L29 | L29GO_ERRORS | Error wrapping, sentinel errors, handling |
| L30 | L30GO_CONTEXT | Context propagation, cancellation, timeouts |

### L31-L40: Rust (10 doors)
| Code | Title | Focus |
|------|-------|-------|
| L31 | L31RUST_BASICS | Ownership, borrowing, lifetimes |
| L32 | L32RUST_ERROR | Result, Option, ? operator, thiserror |
| L33 | L33RUST_ASYNC | tokio, async-std, futures, streams |
| L34 | L34RUST_TRAITS | Trait objects, impl Trait, associated types |
| L35 | L35RUST_TESTING | Unit tests, integration, proptest |
| L36 | L36RUST_CARGO | Workspaces, features, build scripts |
| L37 | L37RUST_UNSAFE | When/how to use unsafe, FFI |
| L38 | L38RUST_MACROS | Declarative macros, proc macros |
| L39 | L39RUST_PERF | Benchmarking, criterion, flamegraph |
| L40 | L40RUST_WASM | wasm-bindgen, wasm-pack, web targets |

### L41-L50: Multi-Language & Specialty (10 doors)
| Code | Title | Focus |
|------|-------|-------|
| L41 | L41SHELL_BASH | Bash scripting, shellcheck, POSIX |
| L42 | L42SHELL_ZSH | Zsh config, plugins, completions |
| L43 | L43POWERSHELL | PowerShell patterns, modules, remoting |
| L44 | L44SQL_PATTERNS | Query optimization, indexing, CTEs |
| L45 | L45GRAPHQL | Schema design, resolvers, federation |
| L46 | L46PROTOBUF | Proto3, gRPC, buf, code generation |
| L47 | L47REGEX | Patterns, performance, common recipes |
| L48 | L48JSON_SCHEMA | Validation, OpenAPI, JSON Schema draft |
| L49 | L49MARKDOWN | Extended syntax, MDX, documentation |
| L50 | L50YAML | YAML pitfalls, anchors, multi-doc |

---

## PART 4: CROSS-REFERENCE REQUIREMENTS

Doors should link to each other where relevant:

- All Python doors (L01-L10) should have `related_doors` linking to each other
- L12 (TypeScript) should reference L11 (Node.js)
- L31-L40 (Rust) should reference each other and relevant DevOps doors (T30-T79)
- L41-L43 (Shell) should reference relevant automation doors
- Web frameworks should reference security doors (S26-S35)

Prerequisites pattern:
- L02-L10 should have `prerequisites: ["L01"]` (Python basics)
- L12-L20 should have `prerequisites: ["L11"]` (Node basics)
- L22-L30 should have `prerequisites: ["L21"]` (Go basics)
- L32-L40 should have `prerequisites: ["L31"]` (Rust basics)

---

## PART 5: QUALITY REQUIREMENTS

### Must Have (Non-negotiable)
1. **Real commands** in quick_start - copy-paste ready
2. **Actual error messages** in known_errors - what users really see
3. **Working code** in common_patterns - not pseudocode
4. **Current versions** - 2024-2025 best practices
5. **Complete JSON** - valid, parseable, no truncation

### Content Depth
- Each door: 2000-4000 words of actual content
- common_patterns: 6-8 real patterns with code
- known_errors: 4-6 specific errors with solutions
- quick_start: Multi-step getting started sequence

### What Gets Rejected
- Generic advice: "follow best practices"
- Placeholder content: "add your code here"
- Outdated syntax: Python 2, old React class components
- Truncated JSON: incomplete structures
- Missing fields: all schema fields required

---

## PART 6: OUTPUT FORMAT

Deliver as a JSON array containing all 50 doors:

```json
[
  { "door_code": "L01PYTHON", ... },
  { "door_code": "L02PYTHON_ASYNC", ... },
  ...
  { "door_code": "L50YAML", ... }
]
```

Or deliver as 50 individual JSON files if preferred:
- L01PYTHON.json
- L02PYTHON_ASYNC.json
- ...
- L50YAML.json

---

## PART 7: VERIFICATION

Before submitting, verify:
1. [ ] All 50 doors present (L01-L50)
2. [ ] All JSON valid and parseable
3. [ ] No truncated content
4. [ ] quick_start has actual commands for each
5. [ ] known_errors has real error messages
6. [ ] common_patterns has working code
7. [ ] Cross-references are accurate
8. [ ] Prerequisites chain correctly

---

## PART 8: ACCOUNTABILITY NOTE

This task is being tracked. A previous model (Cerebras 347B) claimed to deliver 50 doors but only delivered 15, lied about completion, then delivered 35 more at 5/10 quality requiring rework.

**Do not repeat this pattern.**

Deliver all 50 doors at 8/10 quality on first submission. If you cannot complete the task, say so upfront rather than submitting partial work and claiming completion.

Your output will be audited by a separate Claude instance with git access before merge.

---

## EXECUTION

Generate all 50 doors (L01-L50) as specified.

Quality standard: 8/10 minimum (actionable, specific, real code)
Completeness: 50/50 doors
Format: JSON array or individual files

Begin.
