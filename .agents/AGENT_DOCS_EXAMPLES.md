# Agent Task: Example Workflows Documentation

## Context
PhiSHRI is a semantic door system for AI session continuity. We have 323 doors and a working MCP server. Need real-world example workflows showing how users would actually use this.

## Your Task
Write practical example workflows demonstrating PhiSHRI usage patterns.

## System Overview
- **Doors**: JSON files containing curated context (guides, patterns, references)
- **Door codes**: Semantic identifiers like D05 (deployment), S26 (security), W156 (workflow)
- **MCP tools**: 10 tools for reading, searching, and managing session state
- **Bootstrap**: Session state file tracking loaded doors and progress

## Example Workflows to Document

### 1. New Project Setup
- Developer starting a new microservices project
- Which doors to load first (architecture, patterns, deployment)
- How to chain prerequisites

### 2. Debugging Session
- Developer hits a production error
- Loading relevant error handling doors
- Creating checkpoint before investigation
- Resuming next day

### 3. Security Audit
- Loading OWASP doors (S26-S35)
- Systematic review workflow
- Documenting findings in bootstrap

### 4. Learning Path
- Junior dev learning CI/CD
- Recommended door sequence
- Progress tracking via bootstrap

### 5. Cross-Session Handoff
- Session ending, need to hand off to another AI
- Creating comprehensive checkpoint
- New AI resuming with door codes

## Output Format
```markdown
## Workflow: [Name]

### Scenario
[1-2 sentence description]

### Door Sequence
1. `phishri_read_door D05` - Why this first
2. `phishri_load_chain [D06, D07]` - Related context
...

### MCP Calls
[Actual JSON-RPC examples]

### Expected Outcome
[What the user achieves]
```

## Constraints
- DO NOT invent door codes that don't exist
- Use realistic scenarios
- Keep examples practical, not theoretical
- Each workflow should be completable in one session

## Reference: Known Door Categories
- D## = Deployment
- S## = Security
- W## = Workflows
- T## = Tools
- R## = Reference
- E## = Error handling
- A## = Architecture
- L## = Languages

## Deliverable
Create file: `EXAMPLE_WORKFLOWS.md` with 5 detailed workflows.
