# PhiWave Agent Hub - Multi-Agent Communication System

File-based JSONL message queue for real-time multi-agent collaboration.

## Architecture

```
docs/agent_hub.jsonl (message queue)
     ↓
agent_hub.py (hub API)
     ↓
┌────────────────┬──────────────────┬───────────────────┐
│ analyzer_agent │ mcp_agent_client │ claude_agent      │
│ (debugging)    │ (junie/status)   │ (API analysis)    │
└────────────────┴──────────────────┴───────────────────┘
```

## Agents

### 1. Analyzer Agent (`analyzer_agent.py`) ✅ COMPLETE

**Purpose:** Code analysis, debugging, error diagnosis

**Keywords:** analyze, debug, error, fix, issue, problem, why, how, explain, trace, stack, exception, help, broken, failing, crash

**Capabilities:**
- Error analysis (ImportError, SyntaxError, AttributeError, TypeError)
- Debug guidance (GUI, threading, audio, file operations)
- Code pattern analysis (presets, export, devices, phases)
- Fix suggestions (imports, freeze, crashes, performance, buttons)

**Response limit:** <150 tokens per message

**Examples:**
```bash
# Error analysis
"Getting ImportError when running GUI"
→ "📦 Import issue. Check: pip list | grep [module]. Run: pip install [missing-module]"

# Debug help
"GUI is freezing when I click play"
→ "⏸️ Fix freeze: Move long task to Thread. Update GUI via root.after(0, func)"

# Code analysis
"analyze the preset system"
→ "📋 Presets: JSON → PresetLoader → GUI dropdown. Check: loader.py, defaults.json"
```

### 2. Junie Agent (`mcp_agent_client.py`) ✅ COMPLETE

**Purpose:** Team status and coordination

**Keywords:** team, status, junie, check

**Responses:**
- "✓ Team online"
- "✓ Acknowledged"

### 3. Claude Agent (`claude_agent.py`) ✅ COMPLETE

**Purpose:** Deep analysis via Claude API with prompt caching

**Features:**
- API-based conversation analysis
- Prompt caching for cost efficiency
- Complex reasoning and code review

## Usage

### Start Agents

```bash
# Terminal 1: Analyzer
python analyzer_agent.py

# Terminal 2: Junie
python mcp_agent_client.py junie

# Terminal 3: Claude (requires API key)
python claude_agent.py
```

### Send Messages

```python
from agent_hub import post_message

# Ask analyzer for help
post_message("stryk91", "debug threading issue in playback")

# Check team status
post_message("stryk91", "team status check")

# Analyze code
post_message("stryk91", "analyze Phase 4 implementation")
```

### View Messages

```python
from agent_hub import get_messages

# Get recent messages
messages = get_messages(limit=10)
for msg in messages:
    print(f"[{msg['sender']}] {msg['content']}")

# Get unread only
unread = get_messages(unread_only=True)
```

### Test Analyzer

```bash
# Send test messages
python test_analyzer.py

# Start analyzer to see responses
python analyzer_agent.py
```

## API Reference

### `agent_hub.py`

```python
# Post message
post_message(sender: str, content: str, msg_type: str = "message") -> dict

# Get messages
get_messages(unread_only: bool = False, limit: int = 10) -> list

# Mark processed
mark_processed(msg_id: int) -> dict

# Get agent status
get_agent_status() -> dict
```

### Agent Base Class

```python
class Agent:
    def __init__(self, name: str, poll_interval: int = 5)
    def should_respond(self, msg: dict) -> bool  # Override
    def get_response(self, msg: dict) -> str     # Override
    async def run()
```

## Message Format

```json
{
  "id": 1730123456789,
  "sender": "stryk91",
  "content": "analyze preset system",
  "type": "message",
  "timestamp": "2025-10-25T15:30:00.123456",
  "processed": false
}
```

## Configuration

**Poll interval:** 5 seconds (adjustable per agent)
**Response limit:** <150 tokens
**Hub file:** `docs/agent_hub.jsonl`
**Dependencies:** Python 3.9+, asyncio (no external packages for base agents)

## Next Tasks (Priority Order)

- [ ] 2. Create `debugger_agent.py` - Logs errors and suggests fixes
- [ ] 3. Add hub viewer: CLI to display conversation in real-time
- [ ] 4. Git integration: Auto-push hub file after each message
- [ ] 5. Phone command formatter: Parse phone commands into hub messages
- [ ] 6. Create `run_all.py`: Starts all agents in one command

## Examples

### Debugging Workflow

```bash
# 1. Post error
python -c "from agent_hub import post_message; post_message('stryk91', 'AttributeError in phiwave_gui.py line 523')"

# 2. Analyzer responds
# → "🔍 Attribute missing. Check: object type, available methods. Print dir(obj)"

# 3. Continue conversation
python -c "from agent_hub import post_message; post_message('stryk91', 'how do I fix threading freeze in GUI?')"

# → "⏸️ Fix freeze: Move long task to Thread. Update GUI via root.after(0, func)"
```

### Multi-Agent Collaboration

```bash
# Start all agents in separate terminals
python analyzer_agent.py &
python mcp_agent_client.py junie &

# Post analysis request
from agent_hub import post_message
post_message("stryk91", "analyze export functionality and check team status")

# Both agents respond:
# analyzer: "💾 Export: generate_segment() → write_wav/flac(). Check: sample_rate=44100"
# junie: "✓ Team online"
```

## Tips

1. **Keep messages focused** - One question/task per message
2. **Use keywords** - Agents trigger on specific keywords
3. **Check responses** - Agents respond within 5-second poll cycle
4. **Monitor hub file** - `tail -f docs/agent_hub.jsonl` for real-time view
5. **Test locally first** - Use `test_analyzer.py` before production

## Troubleshooting

**Agents not responding:**
- Check agent is running: `ps aux | grep agent`
- Verify hub file exists: `ls -la docs/agent_hub.jsonl`
- Check for errors in agent terminal

**Duplicate responses:**
- Normal if multiple agents match keywords
- Each agent processes independently

**Hub file growing large:**
- Archive periodically: `mv docs/agent_hub.jsonl docs/agent_hub_$(date +%Y%m%d).jsonl`
- Start fresh: `> docs/agent_hub.jsonl`

---

**Created:** 2025-10-25
**Status:** Analyzer agent complete, 5 tasks remaining
**Version:** 1.0.0
