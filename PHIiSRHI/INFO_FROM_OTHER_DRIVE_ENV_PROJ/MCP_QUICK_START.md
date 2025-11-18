# PhiWave MCP Server - Quick Start Guide

**Status:** ✅ **READY TO USE**
**Last Updated:** 2025-10-26

---

## 🚀 Quick Start (2 Steps)

### Before Starting Claude Code:

```batch
# Step 1: Run the loader
LOAD_MCP.bat

# Step 2: Start Claude Code
claude
```

That's it! The MCP tools will be loaded automatically.

---

## ✅ Verification

Once Claude Code starts, ask:

> "Are the MCP tools for phiwave-agent-hub loaded?"

You should see confirmation of 8 tools available:
- `mcp__phiwave_agent_hub__get_stats`
- `mcp__phiwave_agent_hub__post_message`
- `mcp__phiwave_agent_hub__get_messages`
- `mcp__phiwave_agent_hub__mark_processed`
- `mcp__phiwave_agent_hub__get_agent_status`
- `mcp__phiwave_agent_hub__get_conversation`
- `mcp__phiwave_agent_hub__search_messages`
- `mcp__phiwave_agent_hub__clear_old_messages`

---

## 📋 What Was Fixed

### The Problem
Every time you reloaded Claude Code, the MCP configuration was lost due to a Windows path bug in `claude mcp add` that stripped backslashes from file paths.

### The Solution
Created automated scripts that fix the paths using PowerShell:

1. **`LOAD_MCP.bat`** - Main script (run this before Claude Code)
2. **`fix_mcp_paths.ps1`** - PowerShell fixer (called by LOAD_MCP.bat)
3. **`test_mcp_ready.bat`** - Optional pre-flight check (7 tests)

### Test Results
✅ All systems verified and working:
- Python 3.13.7 ✓
- MCP server script ✓
- Database (12 KB) ✓
- Configuration paths ✓
- MCP connection ✓

---

## 📚 Documentation

| File | Description |
|------|-------------|
| **MCP_QUICK_START.md** | This file - quick start guide |
| **MCP_PERSISTENCE_FIX.md** | Detailed problem analysis and solution |
| **MCP_TEST_RESULTS.md** | Complete test results and verification |
| **AFTER_RELOAD_INSTRUCTIONS.txt** | Instructions for after reload |
| **test_mcp_after_reload.md** | Full test plan (8 steps) |

---

## 🔧 Troubleshooting

### MCP tools not loaded?
```batch
# Exit Claude Code, then:
LOAD_MCP.bat
claude
```

### Want to verify before starting?
```batch
test_mcp_ready.bat
```

### Check MCP server status manually?
```batch
claude mcp list
```

Expected output:
```
phiwave-agent-hub: E:\PythonProjects\PhiWave\.venv\Scripts\python.exe
                   E:\PythonProjects\PhiWave\mcp_agent_hub.py
                   - ✓ Connected
```

---

## 🎯 Next Steps

Once MCP tools are loaded, you can:

1. **Test the agent hub:**
   - `mcp__phiwave_agent_hub__get_stats` - See current stats
   - `mcp__phiwave_agent_hub__post_message` - Send a test message
   - `mcp__phiwave_agent_hub__get_messages` - Retrieve messages

2. **Integrate with agents:**
   - Connect Junie agent to the hub
   - Set up agent-to-agent messaging
   - Build real-time communication workflows

3. **GUI integration:**
   - Display agent status in phiwave_gui.py
   - Show live message feed
   - Add message send controls

---

## ⚙️ Technical Details

### MCP Server
- **Name:** phiwave-agent-hub
- **Transport:** stdio (Claude Code compatible)
- **Database:** agent_hub.db (SQLite)
- **Python:** .venv/Scripts/python.exe (3.13.7)
- **FastMCP:** Installed in virtual environment

### Why LOAD_MCP.bat?
The `claude mcp add` command has a bug on Windows that strips backslashes:
- Input: `E:\PythonProjects\...`
- Saved: `E:PythonProjects...` ❌

Our PowerShell script bypasses this by directly editing the JSON config with correct paths.

---

## 📞 Support

If you encounter issues:

1. Check **MCP_PERSISTENCE_FIX.md** for detailed troubleshooting
2. Run **test_mcp_ready.bat** to diagnose problems
3. Verify database exists: `dir agent_hub.db`
4. Test server standalone: `.venv\Scripts\python.exe mcp_agent_hub.py --transport stdio`

---

**Remember:** Run `LOAD_MCP.bat` before each new Claude Code session!

✅ Status: Ready for production use
📅 Last tested: 2025-10-26
🎉 All systems operational
