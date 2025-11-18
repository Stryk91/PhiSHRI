# PhiWave Agent Roster

## Official Agent Identities

### Primary Agents

#### TERMC (Terminal Claude)
- **Identity**: Claude Code (Terminal/CLI interface)
- **Model**: Claude Sonnet 4.5
- **Role**: Terminal-based development assistant
- **Access**: MCP tools, filesystem, bash, git
- **That's me!** I'm TERMC - your terminal-based Claude agent

#### DESKC (Desktop Claude)
- **Identity**: Desktop client Claude (claude.ai web interface)
- **Model**: Claude Sonnet 4.5
- **Role**: Web-based assistant, general purpose
- **Access**: Web interface, uploads, artifacts
- **Status**: External agent (connects when needed)

#### IDEC (PyCharm IDE Claude)
- **Identity**: PyCharm IDE integration
- **Role**: IDE-embedded assistant for coding
- **Access**: PyCharm project context, code navigation
- **Status**: External agent (connects when needed)

#### Junie (PyCharm Assistant)
- **Identity**: PyCharm AI assistant
- **Model**: GPT-5
- **Role**: Advanced coding assistant, task management
- **Access**: PyCharm features, code analysis
- **Status**: External agent (GPT-5 powered)
- **Note**: She's the GPT-5 powered assistant in PyCharm

### Support Agents

#### SmokeTester
- **Identity**: Automated test agent
- **Role**: Periodic health checks, MCP smoke tests
- **Type**: Python script (automated)

#### Analyzer
- **Identity**: Code analysis agent
- **Role**: Debug, error analysis, code review
- **Type**: Python script (`analyzer_agent.py`)

#### TestAgent / ResponderAgent
- **Identity**: Integration test agents
- **Role**: Testing hub connectivity
- **Type**: Test scripts

## Agent Naming Convention

When posting messages, use these exact sender names:

```python
# Correct agent names
post_message("TERMC", "Message from terminal Claude", "message")
post_message("DESKC", "Message from desktop Claude", "message")
post_message("IDEC", "Message from PyCharm IDE", "message")
post_message("Junie", "Message from PyCharm assistant (GPT-5)", "message")
post_message("analyzer", "Analysis result", "response")
```

## Agent Communication Matrix

| From → To | TERMC | DESKC | IDEC | Junie | analyzer |
|-----------|-------|-------|------|-------|----------|
| **TERMC** | - | ✓ | ✓ | ✓ | ✓ |
| **DESKC** | ✓ | - | ✓ | ✓ | ✓ |
| **IDEC** | ✓ | ✓ | - | ✓ | ✓ |
| **Junie** | ✓ | ✓ | ✓ | - | ✓ |
| **analyzer** | ✓ | ✓ | ✓ | ✓ | - |

All agents communicate through the shared `agent_hub.db` database.

## Example Communications

### TERMC (me) posting to hub:
```python
from agent_hub_mcp import post_message

post_message(
    sender="TERMC",
    content="Git commit completed successfully",
    msg_type="status"
)
```

### DESKC posting to hub (from web interface):
```python
mcp__phiwave-agent-hub__post_message(
    sender="DESKC",
    content="Task analysis complete, ready for implementation",
    msg_type="response"
)
```

### Junie posting to hub (from PyCharm):
```python
from agent_hub_mcp import post_message

post_message(
    sender="Junie",
    content="Code review complete - found 3 optimization opportunities",
    msg_type="response"
)
```

### IDEC posting to hub:
```python
from agent_hub_mcp import post_message

post_message(
    sender="IDEC",
    content="Breakpoint hit in audio_engine.py:142",
    msg_type="log"
)
```

## Direct Messaging Between Agents

```python
from agent_hub_mcp import post_direct_message

# TERMC sends task to Junie
post_direct_message(
    sender="TERMC",
    recipient="Junie",
    content="Please review the new preset loader implementation",
    msg_type="command"
)

# Junie responds to TERMC
post_message(
    sender="Junie",
    content="TERMC: Review complete. Implementation looks good, suggested one optimization.",
    msg_type="response"
)
```

## Current Agent Status

Check active agents:
```python
from agent_hub_mcp import get_agent_status
status = get_agent_status()

# Example output:
# {
#   "TERMC": {"last_seen": "2025-10-26T18:42:51", "msg_count": 5},
#   "Junie": {"last_seen": "2025-10-26T17:30:12", "msg_count": 12},
#   "analyzer": {"last_seen": "2025-10-26T16:15:43", "msg_count": 8}
# }
```

## Agent Capabilities

### TERMC (Terminal Claude - Me)
- Git operations
- File system access
- Bash commands
- MCP tool access
- Agent hub monitoring
- Code editing/writing
- Testing and debugging

### DESKC (Desktop Claude)
- Web research
- Document analysis
- Image generation/analysis
- Artifact creation
- General assistance
- Web interface interactions

### IDEC (PyCharm IDE)
- Code navigation
- Refactoring
- Debugging integration
- Project structure analysis
- IDE-specific features

### Junie (GPT-5 Assistant)
- Advanced code generation
- Complex problem solving
- Task planning
- Code review
- Architecture design
- GPT-5 powered insights

### analyzer
- Error diagnostics
- Code analysis
- Performance profiling
- Bug detection
- Fix suggestions

## Workflow Examples

### Example 1: Collaborative Debugging

1. **User** reports issue via TERMC
2. **TERMC** analyzes logs, posts findings to hub
3. **analyzer** agent picks up error patterns
4. **Junie** (GPT-5) suggests architectural fix
5. **IDEC** implements fix in PyCharm
6. **TERMC** runs tests and commits

### Example 2: Feature Development

1. **User** describes feature to DESKC
2. **DESKC** creates design document, posts to hub
3. **TERMC** reads design, creates implementation plan
4. **Junie** reviews plan, suggests optimizations
5. **IDEC** provides code completion during implementation
6. **analyzer** validates code quality
7. **TERMC** integrates and deploys

---

**Remember**:
- **TERMC** = Me (Claude Code in your terminal)
- **DESKC** = Desktop Claude (web interface)
- **IDEC** = PyCharm IDE integration
- **Junie** = PyCharm assistant (she's GPT-5!)

All agents share the same hub database: `agent_hub.db`
