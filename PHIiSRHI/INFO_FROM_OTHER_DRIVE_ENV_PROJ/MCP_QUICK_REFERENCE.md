# MCP Agent Hub - Quick Reference

## Agent Identities (IMPORTANT!)

- **TERMC** = Terminal Claude (Claude Code - that's me!)
- **DESKC** = Desktop Claude (web interface claude.ai)
- **IDEC** = PyCharm IDE Claude
- **Junie** = PyCharm assistant (she's GPT-5!)

Always use these names when posting messages!

## Your Server Entry Point

**File**: `mcp_agent_hub.py`
**Object**: `mcp` (line 15)
**Config**: `.mcp.json`

```json
{
  "mcpServers": {
    "phiwave-agent-hub": {
      "type": "stdio",
      "command": "python.exe",
      "args": ["E:\\PythonProjects\\PhiWave\\mcp_agent_hub.py"]
    }
  }
}
```

## Python Agent API (agent_hub_mcp.py)

```python
from agent_hub_mcp import get_messages, post_message, mark_processed

# Post message (use correct agent names!)
post_message("TERMC", "Message from terminal Claude", "message")
post_message("DESKC", "Message from desktop Claude", "message")
post_message("IDEC", "Message from PyCharm IDE", "message")
post_message("Junie", "Message from GPT-5 assistant", "message")

# Get unread messages
messages = get_messages(unread_only=True, limit=10)

# Process message
mark_processed(message_id)
```

## Claude Code MCP Tools (TERMC - that's me!)

```python
# Get recent messages
mcp__phiwave-agent-hub__get_messages(limit=10, unread_only=False)

# Post message (I'm TERMC!)
mcp__phiwave-agent-hub__post_message(
    sender="TERMC",
    content="Task completed",
    msg_type="status"
)

# Get stats
mcp__phiwave-agent-hub__get_stats()

# Get agent status
mcp__phiwave-agent-hub__get_agent_status()

# Search messages
mcp__phiwave-agent-hub__search_messages(query="error", limit=10)

# Get conversation with specific agent
mcp__phiwave-agent-hub__get_conversation(agent_name="analyzer", limit=20)

# Mark as processed
mcp__phiwave-agent-hub__mark_processed(message_id=123)

# Clean up old messages
mcp__phiwave-agent-hub__clear_old_messages(days=7)
```

## Message Types

- `"message"` - General communication
- `"command"` - Action request (task assignment)
- `"response"` - Reply to command
- `"log"` - Status/debug info
- `"test"` - Testing/smoke tests
- `"status"` - System status update

## Testing Commands

```bash
# Test database client
python agent_hub_mcp.py

# Test full integration
python test_agent_integration.py

# Run an agent
python analyzer_agent.py
```

## One-Line Migration

Change this:
```python
from agent_hub import get_messages, post_message, mark_processed
```

To this:
```python
from agent_hub_mcp import get_messages, post_message, mark_processed
```

## Database Location

`E:\PythonProjects\PhiWave\agent_hub.db` (SQLite)

## Current Stats

- Total messages: 13
- Active agents: 4
- Unread messages: 10
- Status: Operational ✓

## FastMCP Entry Points (Not Currently Used)

Your server uses direct Python execution via `if __name__ == "__main__"`.

If you wanted to use `fastmcp run`, you could use:

```bash
# Inferred (looks for 'mcp', 'server', or 'app' object)
fastmcp run mcp_agent_hub.py

# Explicit object
fastmcp run mcp_agent_hub.py:mcp

# Factory function (if you had a create_server() function)
fastmcp run mcp_agent_hub.py:create_server
```

Your current setup is preferred for your use case (direct control over initialization).

## Documentation

- **Agent roster**: `AGENT_ROSTER.md` ← **READ THIS FIRST!**
- **Full guide**: `MCP_AGENT_INTEGRATION_SUMMARY.md`
- **Migration**: `AGENT_MCP_MIGRATION.md`
- **Quick start**: `MCP_QUICK_START.md`
- **Server setup**: `MCP_SERVER_SETUP.md`

---

**Remember The Agent Names!**
- **TERMC** (me) - Terminal Claude Code
- **DESKC** - Desktop Claude (web)
- **IDEC** - PyCharm IDE Claude
- **Junie** - PyCharm assistant (GPT-5)

**Quick Check**: Is MCP working?
```python
mcp__phiwave-agent-hub__get_stats()
# Should return: {"total_messages": N, "total_agents": M, ...}
```
