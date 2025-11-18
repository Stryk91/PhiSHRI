# Agent MCP Migration Guide

## Overview

Migrate your agents from the old JSONL-based hub (`agent_hub.py`) to the new SQLite MCP hub (`mcp_agent_hub.py`) with **zero code changes**.

## The Two Systems

### OLD: JSONL File-Based (agent_hub.py)
- **Storage**: `docs/agent-feed.jsonl`
- **Format**: One JSON object per line
- **Pros**: Simple, human-readable
- **Cons**: No indexing, slow searches, file locking issues

### NEW: SQLite MCP Server (mcp_agent_hub.py)
- **Storage**: `agent_hub.db` (SQLite database)
- **Format**: Structured database with indexes
- **Pros**: Fast, concurrent, MCP-compatible, queryable
- **Cons**: Binary format

## Migration Steps

### Step 1: Use the Drop-In Replacement

Replace this import:
```python
from agent_hub import get_messages, post_message, mark_processed, get_agent_status
```

With this:
```python
from agent_hub_mcp import get_messages, post_message, mark_processed, get_agent_status
```

**That's it!** The API is 100% compatible.

### Step 2: Test Your Agent

```bash
# Test the connection
python agent_hub_mcp.py

# Run your agent
python your_agent.py
```

### Step 3: Verify Messages Appear in Both Systems

```bash
# Via Python
python -c "from agent_hub_mcp import get_stats; print(get_stats())"

# Via MCP tools (in Claude Code)
# Use mcp__phiwave-agent-hub__get_stats
```

## Example Migration

### Before (analyzer_agent.py - Line 8):
```python
from agent_hub import get_messages, post_message, mark_processed
```

### After:
```python
from agent_hub_mcp import get_messages, post_message, mark_processed
```

## API Compatibility Matrix

| Function | Old API | New API | Compatible |
|----------|---------|---------|------------|
| `post_message(sender, content, type)` | ✓ | ✓ | ✓ |
| `get_messages(recipient, unread_only, limit)` | ✓ | ✓ | ✓ |
| `mark_processed(msg_id)` | ✓ | ✓ | ✓ |
| `get_agent_status()` | ✓ | ✓ | ✓ |
| `post_direct_message(sender, recipient, content, type)` | ✓ | ✓ | ✓ |

## How It Works

The `agent_hub_mcp.py` module:
1. Connects directly to the same SQLite database the MCP server uses
2. Exposes the same function signatures as the old `agent_hub.py`
3. Reads/writes to the `messages` table
4. No MCP protocol overhead (direct SQL queries)

## Advantages

✓ **Zero code changes** for existing agents
✓ **Shared database** with MCP server (same messages visible everywhere)
✓ **Concurrent access** (SQLite handles locking)
✓ **Fast queries** (indexed by timestamp, sender, processed status)
✓ **MCP integration** (Claude Code can see agent messages)

## Testing Checklist

- [ ] Agent can post messages
- [ ] Agent can read messages
- [ ] Agent can mark messages as processed
- [ ] Messages appear in Claude Code MCP tools
- [ ] No import errors
- [ ] Agent runs without crashes

## Agents to Migrate

Current agents using old system:
- `analyzer_agent.py` (line 9)
- `claude_agent.py` (line 8)
- `mcp_agent_client.py` (line 8)

## Running Multiple Agents

```bash
# Terminal 1: Start MCP server (for Claude Code integration)
python mcp_agent_hub.py

# Terminal 2: Start analyzer agent
python analyzer_agent.py

# Terminal 3: Start claude agent
python claude_agent.py

# All agents share the same database!
```

## Troubleshooting

### "Database is locked"
SQLite handles concurrent reads. If you see this, check:
- No agent is holding a transaction open
- Use `with get_db()` context manager (auto-closes)

### "No such table: messages"
The MCP server initializes the database. Run once:
```bash
python mcp_agent_hub.py
# Ctrl+C after it starts
```

### Messages not appearing
Check both systems are using the same database:
```python
from agent_hub_mcp import get_stats
print(get_stats()["db_path"])
# Should be: E:\PythonProjects\PhiWave\agent_hub.db
```

## Next Steps

1. Migrate `analyzer_agent.py` (example below)
2. Migrate `claude_agent.py`
3. Migrate `mcp_agent_client.py`
4. Create new agents using `agent_hub_mcp` from the start
5. Deprecate old `agent_hub.py` (JSONL system)

---

## Full Example: Migrated Analyzer Agent

```python
"""
Analyzer Agent - Migrated to MCP hub
"""

import asyncio
from agent_hub_mcp import get_messages, post_message, mark_processed  # <- Changed

class Analyzer:
    def __init__(self, name: str = "analyzer", poll_interval: int = 5):
        self.name = name
        self.poll_interval = poll_interval
        self.processed_ids = set()

    def should_respond(self, msg: dict) -> bool:
        keywords = ["analyze", "debug", "error", "fix"]
        return any(kw in msg["content"].lower() for kw in keywords)

    def get_response(self, msg: dict) -> str:
        return "✓ Analyzer ready. Specify: analyze/debug/error/fix + details"

    async def run(self):
        print(f"🚀 {self.name} agent started (MCP hub)")
        try:
            while True:
                msgs = get_messages(unread_only=True)
                for msg in msgs:
                    if msg["id"] in self.processed_ids:
                        continue

                    if self.should_respond(msg):
                        response = self.get_response(msg)
                        print(f"\n📨 [{msg['sender']}] {msg['content']}")
                        print(f"📤 [{self.name}] {response}\n")
                        post_message(self.name, response, "response")

                    mark_processed(msg["id"])
                    self.processed_ids.add(msg["id"])

                await asyncio.sleep(self.poll_interval)
        except KeyboardInterrupt:
            print(f"\n✋ {self.name} stopped")

if __name__ == "__main__":
    analyzer = Analyzer()
    asyncio.run(analyzer.run())
```

The only change: **Line 5** imports from `agent_hub_mcp` instead of `agent_hub`.
