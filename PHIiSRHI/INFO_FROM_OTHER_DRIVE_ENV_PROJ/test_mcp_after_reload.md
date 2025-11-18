# MCP Server Test Plan - After Claude Code Reload

## Session Context
**Date:** 2025-10-26
**Task:** Testing the PhiWave Agent Hub MCP server integration with Claude Code

## What We Completed Before Reload

1. **Fixed Unicode encoding issues** in:
   - `mcp_smoke_test.py` - Changed checkmarks to [OK] tags
   - `mcp_agent_hub.py` - Changed emoji to [MCP], [DB], [START] tags

2. **Verified local functionality**:
   - Ran smoke test successfully: `python mcp_smoke_test.py`
   - Database: `E:\PythonProjects\PhiWave\agent_hub.db` (3 messages, 1 agent)
   - All CRUD operations working

3. **MCP Server Configuration**:
   - File: `.mcp.json` (project-scoped)
   - Server name: `phiwave-agent-hub`
   - Transport: stdio
   - Command: `.venv\Scripts\python.exe mcp_agent_hub.py`

4. **Server startup verified**:
   - Tested with `--transport stdio` flag
   - FastMCP banner displayed correctly
   - No errors during initialization

## Expected MCP Tools (After Reload)

These tools should be available with the `mcp__phiwave_agent_hub__` prefix:

1. **post_message**(sender: str, content: str, msg_type: str = "message")
2. **get_messages**(limit: int = 10, unread_only: bool = False)
3. **mark_processed**(message_id: int)
4. **get_agent_status**()
5. **get_conversation**(agent_name: str, limit: int = 20)
6. **search_messages**(query: str, limit: int = 10)
7. **clear_old_messages**(days: int = 7)
8. **get_stats**()

## Test Sequence

### Test 1: Verify MCP Connection
Check if tools are available by asking Claude Code:
"Are the MCP tools for phiwave-agent-hub loaded?"

Expected: Claude should confirm the tools are available and may list them.

### Test 2: Get Current Stats
Use: `mcp__phiwave_agent_hub__get_stats`

Expected output:
```json
{
  "total_messages": 3,
  "total_agents": 1,
  "unread_messages": 3,
  "db_path": "E:\\PythonProjects\\PhiWave\\agent_hub.db"
}
```

### Test 3: Post a Test Message
Use: `mcp__phiwave_agent_hub__post_message`

Parameters:
- sender: "ClaudeCode"
- content: "MCP integration test - post-reload verification"
- msg_type: "log"

Expected: Should return message ID and timestamp.

### Test 4: Retrieve Recent Messages
Use: `mcp__phiwave_agent_hub__get_messages`

Parameters:
- limit: 5
- unread_only: false

Expected: Should include the message just posted.

### Test 5: Get Agent Status
Use: `mcp__phiwave_agent_hub__get_agent_status`

Expected: Should show "SmokeTester" and "ClaudeCode" agents with message counts.

### Test 6: Search Messages
Use: `mcp__phiwave_agent_hub__search_messages`

Parameters:
- query: "test"
- limit: 10

Expected: Should return messages containing "test".

### Test 7: Mark Message as Processed
Use: `mcp__phiwave_agent_hub__mark_processed`

Parameters:
- message_id: [use ID from Test 3]

Expected: Should confirm message marked as processed.

### Test 8: Verify Unread Count Changed
Use: `mcp__phiwave_agent_hub__get_stats`

Expected: unread_messages should be 1 less than before.

## Success Criteria

✓ All 8 MCP tools are accessible
✓ Can post messages from Claude Code to hub
✓ Can retrieve and search messages
✓ Can mark messages as processed
✓ Statistics update correctly
✓ No errors during any operation

## If Tests Fail

1. **Tools not available:**
   - Check: `claude mcp list` (should show phiwave-agent-hub)
   - Verify: `.mcp.json` exists in project root
   - Retry: Reload Claude Code again

2. **Server errors:**
   - Check: `python mcp_agent_hub.py --transport stdio` runs without errors
   - Verify: FastMCP installed: `.venv\Scripts\pip show fastmcp`

3. **Database errors:**
   - Check: `agent_hub.db` exists
   - Verify: `python mcp_smoke_test.py` passes

## Next Steps After Successful Test

1. Integrate with Junie agent (`phiwave/agent_junie.py`)
2. Create agent messaging demos
3. Build real-time agent communication workflows
4. Connect to GUI for live agent status display

## Quick Command Reference

```bash
# Reload Claude Code
RELOAD_CLAUDE.bat

# Test local API directly
python mcp_smoke_test.py

# Test server startup
.venv\Scripts\python.exe mcp_agent_hub.py --transport stdio

# Check database
sqlite3 agent_hub.db "SELECT * FROM messages;"
```
