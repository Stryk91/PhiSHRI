#!/bin/bash
# ============================================================================
# PhiSHRI Session Hooks Installer
# ============================================================================
# Installs hooks for continuous session logging + pre-compaction dumps
#
# Usage: ./install-session-hooks.sh
# ============================================================================

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
DUMP_DIR="$CLAUDE_DIR/session-dumps"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          PhiSHRI Session Hooks Installer                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

# Create directories
mkdir -p "$HOOKS_DIR" "$DUMP_DIR"
echo "✓ Created directories"

# ============================================================================
# Hook Scripts
# ============================================================================

# Session Start - Initialize log file
cat > "$HOOKS_DIR/session-start.sh" << 'SCRIPT'
#!/bin/bash
# Initialize session log when Claude Code starts

DUMP_DIR="$HOME/.claude/session-dumps"
SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"
SESSION_FILE="$DUMP_DIR/${SESSION_ID}.md"

# Create session file
cat > "$SESSION_FILE" << EOF
# Claude Code Session Log
**Started:** $(date -Iseconds)
**Session ID:** $SESSION_ID

---

## Actions Log

EOF

# Store session ID for other hooks
echo "$SESSION_FILE" > "$DUMP_DIR/.current_session"
echo "Session logging started: $SESSION_FILE" >&2
SCRIPT
chmod +x "$HOOKS_DIR/session-start.sh"

# Post Tool Use - Log every significant action
cat > "$HOOKS_DIR/post-tool-log.sh" << 'SCRIPT'
#!/bin/bash
# Log tool usage to current session file

DUMP_DIR="$HOME/.claude/session-dumps"
CURRENT_SESSION=$(cat "$DUMP_DIR/.current_session" 2>/dev/null)

if [ -z "$CURRENT_SESSION" ] || [ ! -f "$CURRENT_SESSION" ]; then
    exit 0  # No active session, skip
fi

# Read tool info from stdin (JSON)
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
TOOL_RESULT=$(echo "$TOOL_INPUT" | jq -r '.result // "" | tostring | .[0:200]' 2>/dev/null)

# Append to session log
cat >> "$CURRENT_SESSION" << EOF
### $(date +%H:%M:%S) - $TOOL_NAME
\`\`\`
${TOOL_RESULT}...
\`\`\`

EOF
SCRIPT
chmod +x "$HOOKS_DIR/post-tool-log.sh"

# Pre-Compact - Final dump before compaction
cat > "$HOOKS_DIR/pre-compact.sh" << 'SCRIPT'
#!/bin/bash
# Emergency context dump before compaction

DUMP_DIR="$HOME/.claude/session-dumps"
CURRENT_SESSION=$(cat "$DUMP_DIR/.current_session" 2>/dev/null)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -n "$CURRENT_SESSION" ] && [ -f "$CURRENT_SESSION" ]; then
    # Mark session as compacted
    cat >> "$CURRENT_SESSION" << EOF

---

## ⚠️ COMPACTION TRIGGERED
**Time:** $(date -Iseconds)
**Reason:** Context limit reached

*Content above this line represents pre-compaction state*

---
EOF

    # Copy to compaction archive
    cp "$CURRENT_SESSION" "$DUMP_DIR/compacted_${TIMESTAMP}.md"
    echo "Pre-compaction dump saved" >&2
fi
SCRIPT
chmod +x "$HOOKS_DIR/pre-compact.sh"

# Session End - Finalize and archive
cat > "$HOOKS_DIR/session-end.sh" << 'SCRIPT'
#!/bin/bash
# Finalize session log

DUMP_DIR="$HOME/.claude/session-dumps"
CURRENT_SESSION=$(cat "$DUMP_DIR/.current_session" 2>/dev/null)

if [ -n "$CURRENT_SESSION" ] && [ -f "$CURRENT_SESSION" ]; then
    cat >> "$CURRENT_SESSION" << EOF

---

## Session Ended
**Time:** $(date -Iseconds)
**Status:** Normal termination
EOF

    echo "Session finalized: $CURRENT_SESSION" >&2
    rm -f "$DUMP_DIR/.current_session"
fi
SCRIPT
chmod +x "$HOOKS_DIR/session-end.sh"

echo "✓ Created hook scripts"

# ============================================================================
# Settings Configuration
# ============================================================================

# Create or update settings.json with hooks
HOOKS_CONFIG='{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/post-tool-log.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-compact.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/session-end.sh"
          }
        ]
      }
    ]
  }
}'

if [ -f "$SETTINGS_FILE" ]; then
    # Merge with existing settings
    EXISTING=$(cat "$SETTINGS_FILE")
    echo "$EXISTING" | jq --argjson hooks "$(echo "$HOOKS_CONFIG" | jq '.hooks')" '.hooks = $hooks' > "$SETTINGS_FILE.tmp"
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "✓ Updated existing settings.json"
else
    echo "$HOOKS_CONFIG" | jq '.' > "$SETTINGS_FILE"
    echo "✓ Created settings.json"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete                       ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║                                                                ║"
echo "║  Session logs will be saved to:                               ║"
echo "║    ~/.claude/session-dumps/                                   ║"
echo "║                                                                ║"
echo "║  Hooks installed:                                             ║"
echo "║    • SessionStart  → Initialize session log                   ║"
echo "║    • PostToolUse   → Log Edit/Write/Bash actions             ║"
echo "║    • PreCompact    → Emergency dump before compaction        ║"
echo "║    • SessionEnd    → Finalize session archive                ║"
echo "║                                                                ║"
echo "║  Restart Claude Code for hooks to take effect.                ║"
echo "║                                                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
