# S00 - KALIC Session Boot Bundle

## PURPOSE
Essential context for KALIC (Claude Code terminal agent) session initialization.
Load this door at session start to prime context.

## IDENTITY
- **Agent:** KALIC (terminal agent, Claude Code)
- **Sibling:** DC (Claude Desktop)
- **Operator:** STRYK
- **Communication:** WM_COPYDATA via Carbyne (see P15AGENT_BRIDGE_MCP)

## BRAIN REGIONS
| File | Purpose |
|------|---------|
| frontal.md | Decision checklist - check BEFORE acting |
| temporal.md | Learnings - ADD after solving problems |
| parietal.md | Paths & navigation |
| cerebellum.md | Execution commands |
| brainstem.md | DO NOTs & survival rules |

## CRITICAL PATHS
```
cargo:      /mnt/c/Users/Stryker_LOCAL/.cargo/bin/cargo.exe
ahk:        /mnt/c/Program Files/AHK/v2/AutoHotkey64.exe
ahk_scripts: /mnt/x/AHK  SCRIPTS/  (TWO SPACES!)
dc_msg:     /mnt/c/Windows/System32/cmd.exe /c 'C:\PhiDEX\scripts\kalic_msg.bat "MSG"'
powershell: /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
brain:      /mnt/c/PhiDEX/kalic_brain/
schemas:    /mnt/c/PhiDEX/tool_schemas/
```

## SESSION CHECKLIST
1. Check semantic_links.json for routing rules
2. Read frontal.md before first action
3. After solving problems → add to temporal.md
4. If confused → re-read brainstem.md

## QUICK DOOR REFERENCES
- P15AGENT_BRIDGE_MCP → DC-KALIC messaging
- E59WM_COPYDATA_FREEZE → Why SendMessage kills desktop
- T850CLAUDE_HOOKS → Hook config, events, I/O format
- F01LAUNCHER_RECOVERY → Fix launcher after npm update

## PREREQUISITES
None - this is a bootstrap door.
