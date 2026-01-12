# T850 - Claude Code Hooks

## CONFIG LOCATION
```
~/.claude/settings.json
```

## STRUCTURE
```json
{
  "hooks": {
    "<EventType>": [
      {
        "matcher": "<pattern>",
        "hooks": [
          {"type": "command", "command": "/path/to/script.sh"}
        ]
      }
    ]
  }
}
```

## EVENT TYPES

| Event | Matcher Options | Input Fields |
|-------|-----------------|--------------|
| SessionStart | `startup`, `resume`, `clear`, `compact` | session_id, transcript_path, source |
| PreToolUse | Tool name (`Bash`, `Write`, `Edit`) or `*` | tool_name, tool_input, cwd |
| PostToolUse | Tool name or `*` | tool_name, tool_input, tool_result |
| Stop | - | transcript_path |
| SubagentStop | - | agent_id, transcript_path |

## HOOK I/O

**Input:** JSON on stdin
```json
{"tool_name":"Bash","tool_input":{"command":"rm -rf /"},"cwd":"/home/user"}
```

**Output:** JSON to stdout
```json
{"permissionDecision":"allow"}
{"permissionDecision":"deny","message":"Blocked by brainstem"}
{"permissionDecision":"ask"}
{"hookSpecificOutput":{"additionalContext":"Loaded config..."}}
```

## EXIT CODES
- `0` = allow / success
- `2` = deny (stderr shown to Claude)

## PRETOOLUSE: MODIFY INPUT
```json
{"toolInput":{"command":"modified-command"}}
```

## EXAMPLES

### Block dangerous commands
```bash
#!/bin/bash
INPUT=$(cat)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if echo "$TOOL_INPUT" | grep -qE 'rm -rf|format|mkfs'; then
  echo '{"permissionDecision":"deny","message":"Destructive command blocked"}'
  exit 2
fi
echo '{"permissionDecision":"allow"}'
```

### Load context on startup
```bash
#!/bin/bash
CONFIG=$(cat /path/to/config.json | jq -c .)
echo '{"hookSpecificOutput":{"additionalContext":"Config: '"$CONFIG"'"}}'
```

## KALIC IMPLEMENTATION
- Scripts: `/mnt/c/PhiDEX/kalic_brain/hooks/scripts/`
- pre_tool_check.sh → checks semantic_links.json BLOCK keywords
- session_start.sh → loads semantic_links.json into context
