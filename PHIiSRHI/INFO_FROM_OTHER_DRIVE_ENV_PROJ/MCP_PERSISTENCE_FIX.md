# MCP Server Persistence Fix

## The Problem

Every time you reload Claude Code, the MCP server configuration is lost and needs to be reconfigured manually. This happens because:

1. **Windows path bug:** `claude mcp add` strips backslashes from paths
   - Given: `E:\PythonProjects\PhiWave\.venv\Scripts\python.exe`
   - Saved: `E:PythonProjectsPhiWave.venvScriptspython.exe` ❌
   - Result: MCP server fails to connect

2. **Project config not auto-loaded:** The `.mcp.json` file in your project root has correct paths, but Claude Code doesn't automatically load project-level MCP configs on startup

3. **User scope config corrupted:** The user-level config (`C:\Users\Stryker\.claude.json`) gets the corrupted paths and fails to start the MCP server

## The Solution

Use the **automated loader script** before starting each Claude Code session:

### Quick Start

```batch
# Run this BEFORE starting Claude Code
LOAD_MCP.bat
```

This script:
1. ✅ Removes any corrupted MCP configurations
2. ✅ Re-adds the MCP server with correct paths
3. ✅ Verifies the configuration loaded successfully

### What the Script Does

```batch
# Cleans up old configs
claude mcp remove "phiwave-agent-hub" -s user
claude mcp remove "phiwave-agent-hub" -s local

# Re-adds with correct paths
claude mcp add --scope user --transport stdio phiwave-agent-hub -- ^
  E:\PythonProjects\PhiWave\.venv\Scripts\python.exe ^
  E:\PythonProjects\PhiWave\mcp_agent_hub.py

# Shows status
claude mcp list
```

## Workflow

### Every Time You Start Claude Code:

1. **Run the loader:**
   ```batch
   LOAD_MCP.bat
   ```

2. **Start Claude Code:**
   ```batch
   claude
   ```

3. **Verify MCP tools are loaded:**
   ```
   Ask Claude: "Are the MCP tools loaded?"
   Expected: Tools like mcp__phiwave_agent_hub__get_stats should be visible
   ```

## Alternative: Manual Configuration

If you prefer to configure manually (not recommended):

```batch
# Remove corrupted configs
claude mcp remove "phiwave-agent-hub" -s user
claude mcp remove "phiwave-agent-hub" -s local

# Add fresh config
claude mcp add --scope user --transport stdio phiwave-agent-hub -- E:\PythonProjects\PhiWave\.venv\Scripts\python.exe E:\PythonProjects\PhiWave\mcp_agent_hub.py

# Verify
claude mcp list
```

## Troubleshooting

### MCP Server Shows "Failed to connect"

Check these:
1. **Python path is correct:**
   ```batch
   E:\PythonProjects\PhiWave\.venv\Scripts\python.exe --version
   ```

2. **MCP server runs standalone:**
   ```batch
   .venv\Scripts\python.exe mcp_agent_hub.py --transport stdio
   ```

3. **Database exists:**
   ```batch
   dir agent_hub.db
   ```

4. **FastMCP is installed:**
   ```batch
   .venv\Scripts\pip show fastmcp
   ```

### MCP Tools Not Visible in Claude Code

1. **Re-run the loader:**
   ```batch
   LOAD_MCP.bat
   ```

2. **Reload Claude Code** (Ctrl+D then restart)

3. **Check if server is registered:**
   ```batch
   claude mcp list
   ```

## Files Involved

| File | Scope | Persists? | Auto-loaded? | Notes |
|------|-------|-----------|--------------|-------|
| `.mcp.json` | Project | ✅ Yes | ❌ No | Correct paths, but not used |
| `C:\Users\Stryker\.claude.json` | User | ⚠️ Corrupted | ✅ Yes | Gets corrupted paths from `claude mcp add` |
| `LOAD_MCP.bat` | N/A | N/A | N/A | **Solution:** Re-adds config each session |

## Future Improvement

Once the Windows path bug is fixed in `claude mcp add`, the user-level configuration should persist correctly across reloads without needing the loader script.

**Track the bug report:** https://github.com/anthropics/claude-code/issues (if filed)

## See Also

- `AFTER_RELOAD_INSTRUCTIONS.txt` - Step-by-step instructions for after reload
- `test_mcp_after_reload.md` - Full test plan for MCP integration
- `MCP_SERVER_SETUP.md` - Original setup documentation
