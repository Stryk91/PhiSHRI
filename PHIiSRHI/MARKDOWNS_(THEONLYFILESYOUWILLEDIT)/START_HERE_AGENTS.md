# PhiWave Agent System - START HERE

## Who's Who? 🤖

```
┌─────────────────────────────────────────────────────────┐
│               KNOW YOUR AGENTS!                         │
└─────────────────────────────────────────────────────────┘

  TERMC        = Terminal Claude (Claude Code - CLI)
  That's me! → I'm your terminal-based assistant

  DESKC        = Desktop Claude (claude.ai web interface)

  IDEC         = PyCharm IDE Claude integration

  Junie        = PyCharm Assistant (she's GPT-5! 🚀)

  analyzer     = Code analysis agent (Python script)
```

## Quick Start

### 1. Check System Status
```python
mcp__phiwave-agent-hub__get_stats()
```

### 2. Post a Message (as TERMC)
```python
mcp__phiwave-agent-hub__post_message(
    sender="TERMC",
    content="Hello from Terminal Claude!",
    msg_type="message"
)
```

### 3. See Who's Active
```python
mcp__phiwave-agent-hub__get_agent_status()
```

### 4. Read Messages
```python
mcp__phiwave-agent-hub__get_messages(limit=10)
```

## How Agents Connect

### I'm TERMC (Terminal Claude)
I use MCP tools directly:
```python
mcp__phiwave-agent-hub__post_message(sender="TERMC", ...)
```

### DESKC (Desktop Claude)
Uses MCP tools from web interface (same as me)

### IDEC, Junie, analyzer
Use Python API:
```python
from agent_hub_mcp import post_message, get_messages
post_message("Junie", "My message", "message")
```

## The Hub

**Database**: `agent_hub.db` (SQLite)
**Server**: `mcp_agent_hub.py` (FastMCP)
**Client**: `agent_hub_mcp.py` (Python API)

All agents read/write to the same database!

## Example Workflow

```
User → TERMC: "Fix the clipping bug"
       │
       ├─→ TERMC posts to hub
       │
       ├─→ DESKC researches issue
       │
       ├─→ analyzer finds the bug
       │
       ├─→ Junie (GPT-5) suggests fix
       │
       ├─→ IDEC implements in PyCharm
       │
       └─→ TERMC tests & commits
```

## Test It Now!

```bash
# Run the demo
python demo_agent_names.py

# Test integration
python test_agent_integration.py

# Direct client test
python agent_hub_mcp.py
```

## Documentation

- **AGENT_ROSTER.md** - Complete agent documentation
- **AGENT_SYSTEM_COMPLETE.md** - Full system overview
- **MCP_QUICK_REFERENCE.md** - Quick API reference
- **AGENT_MCP_MIGRATION.md** - Migration guide

## Remember!

✓ Always use official agent names (TERMC, DESKC, IDEC, Junie)
✓ All agents share one database (agent_hub.db)
✓ I'm TERMC - your terminal Claude
✓ Junie is GPT-5 in PyCharm
✓ Messages flow through central hub

---

**Quick Test**:
```python
mcp__phiwave-agent-hub__get_stats()
# Should show: total_messages, total_agents, unread_messages
```

**Need Help?**
- Check `AGENT_ROSTER.md` for full agent details
- Run `python demo_agent_names.py` to see it in action
- Use `mcp__phiwave-agent-hub__get_agent_status()` to see who's active

---

**Status**: ✓ OPERATIONAL
**Your Agent**: TERMC (Terminal Claude)
**Database**: agent_hub.db
**Ready to collaborate!** 🚀

---

## MCP Integration Setup (New System)

This project now exposes a FastMCP server so all agents (TERMC, DESKC, IDEC, Junie, analyzer) can coordinate through a single hub.

- Server name: PhiWave Agent Hub
- Server id / tool prefix: phiwave-agent-hub
- Database: agent_hub.db (SQLite)

### Start the MCP Server

Option A — STDIO mode (Claude Code / local tools):
```bash
python mcp_agent_hub.py --transport stdio
```

Option B — HTTP mode (for external MCP clients):
```bash
python mcp_agent_hub.py --transport http --port 8000
```

When the server starts, you should see:
```
[MCP] PhiWave Agent Hub MCP Server
[DB] Database: E:\\PythonProjects\\PhiWave\\agent_hub.db
[START] Starting server in STDIO mode (for Claude Code)...
```

### Tool Prefix and Calls
Use the following tool prefix when invoking from MCP-enabled clients:
- Prefix: mcp__phiwave-agent-hub__

Examples:
```python
# Health/stats
mcp__phiwave-agent-hub__get_stats()

# Post a message
mcp__phiwave-agent-hub__post_message(
    sender="TERMC",
    content="Hello from Terminal Claude!",
    msg_type="message",
)

# Read recent messages
mcp__phiwave-agent-hub__get_messages(limit=10, unread_only=False)

# Mark a message processed
mcp__phiwave-agent-hub__mark_processed(message_id=123)

# Agent status and search
mcp__phiwave-agent-hub__get_agent_status()
mcp__phiwave-agent-hub__search_messages(query="junie", limit=5)
```

### Smoke Test (Recommended)
Use the included test to verify the MCP stack end-to-end:
```bash
python mcp_smoke_test.py
```
This will:
- Initialize the DB (if needed)
- Post a test message
- Fetch stats and verify the hub responds

### Junie (PyCharm Assistant) Integration
Junie can participate via MCP tools or the Python client:
- MCP tools (preferred): use the mcp__phiwave-agent-hub__* tools above directly in the IDE’s MCP-enabled environment.
- Python client fallback:
```python
from agent_hub_mcp import post_message, get_messages
post_message("Junie", "QA report ready", "message")
print(get_messages(limit=5))
```

### Tips
- Keep the server running while agents interact.
- All agents must use the canonical names: TERMC, DESKC, IDEC, Junie, analyzer.
- For cleanup in dev: mcp__phiwave-agent-hub__clear_old_messages(days=1)

---
