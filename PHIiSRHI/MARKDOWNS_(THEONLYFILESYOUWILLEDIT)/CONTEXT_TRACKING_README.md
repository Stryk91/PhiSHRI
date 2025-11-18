# Context Window Tracking - Windows MCP Server

## Overview

The Windows MCP server now includes **real-time context window monitoring** that estimates token usage without requiring API keys.

## New Tool: `get_context_estimate`

### What It Does

Tracks and estimates Claude Desktop conversation token usage by analyzing:
- **Message sizes**: Cumulative characters in/out
- **File operations**: Total bytes read and written
- **PowerShell commands**: Number of executions
- **Conversation turns**: Request/response pairs

### Token Estimation Algorithm

```
estimated_tokens = (total_chars_in + total_chars_out) / 3.5 * 1.15
```

- **Base calculation**: chars ÷ 3.5 (average chars per token)
- **Safety margin**: 1.15x multiplier for overhead

### Status Levels

| Status | Percentage | Description |
|--------|------------|-------------|
| 🟢 GREEN | < 50% | Safe - plenty of context remaining |
| 🟡 YELLOW | 50-85% | Monitor - context window filling up |
| 🔴 RED | > 85% | Warning - consider summarizing conversation |

## Usage

### Call from Claude Desktop

```
Use the get_context_estimate tool
```

### Response Example

```json
{
  "estimated_tokens_used": 45230,
  "total_budget": 190000,
  "percentage_used": "23.81%",
  "conversation_turns": 127,
  "file_operations_total_bytes": 2458392,
  "powershell_commands": 34,
  "status": "GREEN",
  "details": {
    "chars_in": 98234,
    "chars_out": 62108,
    "file_bytes_read": 1893472,
    "file_bytes_written": 564920
  },
  "warning": ""
}
```

## Tracking Details

### What Gets Tracked

1. **Incoming messages** (chars_in)
   - All JSON-RPC requests from Claude Desktop
   - Tool call parameters
   - User prompts

2. **Outgoing messages** (chars_out)
   - All JSON-RPC responses
   - Tool results
   - Error messages

3. **File operations** (file_bytes_read/written)
   - read_file: Tracks bytes read
   - write_file: Tracks bytes written
   - Cumulative totals

4. **PowerShell commands**
   - Count of execute_powershell calls
   - Helps estimate computational overhead

5. **Conversation turns**
   - Number of tools/call requests
   - Indicates conversation depth

### Data Persistence

⚠️ **NOTE**: Context stats are **session-based** and reset when Claude Desktop restarts the MCP server.

For persistent tracking across sessions, check the audit log:
```
C:\Dev\Windows-MCP\audit.log
```

## Integration with Desktop Commander

### Automatic Monitoring

Desktop Commander can call `get_context_estimate` at configurable intervals:

- **Every 25% threshold** (50%, 75%, 85%)
- **Manual check** via user command
- **Pre-summary trigger** when RED status reached

### Example Workflow

```
1. User: "Analyze these 50 files..."
2. VSCC reads all files (context grows)
3. At 50% usage: get_context_estimate → YELLOW
4. At 85% usage: get_context_estimate → RED
5. VSCC: "Context nearing limit - suggest summarizing"
6. User approves summary
7. Context window freed for continued work
```

## Technical Details

### Thread Safety

Uses `Arc<Mutex<ContextStats>>` for thread-safe tracking across all MCP server operations.

### Performance Impact

- **Minimal overhead**: Simple counter increments
- **No external calls**: All calculation is local
- **Non-blocking**: Mutex locks are brief

### Accuracy

Estimation accuracy: **±15% typical variance**

Factors affecting accuracy:
- JSON serialization overhead
- MCP protocol wrappers
- System messages (not tracked)
- Claude's internal formatting

**Still highly useful** for preventing mid-workflow context exhaustion.

## Security

- **No API keys required**
- **No network calls**
- **Local calculation only**
- **Privacy-preserving** (no data leaves machine)

## Limitations

1. **Session-based**: Resets on server restart
2. **Estimation only**: Not exact token count
3. **Doesn't track**:
   - System prompts
   - Tool schemas (sent once)
   - Internal Claude reasoning

## Future Enhancements

- [ ] Persistent stats across sessions (SQLite)
- [ ] Per-tool breakdown of context usage
- [ ] Historical trend analysis
- [ ] Auto-summarization trigger
- [ ] Export stats to CSV/JSON

## Testing

### Manual Test

1. Open Claude Desktop
2. Call `get_context_estimate`
3. Verify status is GREEN (new session)
4. Perform file operations
5. Call again - see numbers increase
6. Verify calculations match expectations

### Expected Values (New Session)

```json
{
  "estimated_tokens_used": ~500-2000,
  "status": "GREEN",
  "conversation_turns": 1,
  "powershell_commands": 0,
  "file_operations_total_bytes": 0
}
```

## Support

For issues or feature requests:
- GitHub: https://github.com/CursorTouch/Windows-MCP
- Audit logs: `C:\Dev\Windows-MCP\audit.log`
- Build info: `cargo --version` output

---

**Built with Rust + MinGW-w64**
**MCP Protocol Version**: 2024-11-05
**Server Version**: 1.0.0 (with context tracking)
