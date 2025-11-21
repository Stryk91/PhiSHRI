# PhiSHRI Agent Task Files

Parallel task assignments for AI agents. Each file is a self-contained bootstrap.

## Usage
1. Point your AI agent to this branch
2. Tell it to read the specific task file
3. Agent delivers the specified output file

## Active Tasks

| File | Task | Output | Best Model |
|------|------|--------|------------|
| `AGENT_QA_TESTING.md` | Generate MCP test cases | `QA_TEST_CASES.md` | Qwen 32B |
| `AGENT_DOCS_EXAMPLES.md` | Write example workflows | `EXAMPLE_WORKFLOWS.md` | GPT 4o |
| `AGENT_RESEARCH_CONTINUE.md` | Continue.dev MCP research | `CONTINUE_MCP_RESEARCH.md` | Gemini Pro |
| `AGENT_BRANDING.md` | Icon design specs | `ICON_DESIGN_SPECS.md` | GPT 5.1 |

## Prompt Template
```
Go to branch: claude/repo-audit-and-cleanup-01KsyLWyfM88PXwT3L2cRv33
Read file: .agents/AGENT_[TASK].md
Complete the task and deliver the output file specified.
```

## Rules
- Tasks are non-conflicting (no shared file edits)
- Output goes to project root or specified location
- Agent should NOT modify existing code/doors
- Research tasks = report only, no implementation
