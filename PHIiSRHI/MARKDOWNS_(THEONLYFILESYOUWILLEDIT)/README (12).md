# Claude Bootstrap System v1.0

**Universal onboarding and continuity system for multi-instance Claude workflows**

---

## 🎯 Purpose

This system solves the problem of maintaining context and workflow across multiple Claude instances (CLI, Desktop, Web) by providing:

1. **Member Identity** - Each Claude instance knows who it is (TERMC, DC, etc.)
2. **Baseline Configuration** - Consistent role, goals, and operating principles
3. **Context Awareness** - Knowledge of other instances and shared resources
4. **Continuity** - Seamless handoffs between instances with preserved context
5. **Portability** - Works from Dropbox, USB, or any shared location

---

## 📁 System Components

```
claude-bootstrap/
├── README.md                    # This file - Complete documentation
├── claude_bootstrap.sh          # Interactive setup wizard (CLI)
├── claude_member_config.json    # Configuration template
├── onboarding_prompt.md         # Manual onboarding for web/desktop
└── continuity_log.md            # Shared state and handoff tracking
```

---

## 🚀 Quick Start

### For CLI Instances (TERMC)

1. **Navigate to the directory**:
   ```bash
   cd /path/to/claude-bootstrap
   ```

2. **Run setup wizard**:
   ```bash
   ./claude_bootstrap.sh --setup
   ```

3. **Load onboarding prompt**:
   ```bash
   ./claude_bootstrap.sh --load
   ```
   Copy the output and paste it into your Claude chat.

### For Desktop/Web Instances (DC, WEB_CLAUDE)

1. **Open** `onboarding_prompt.md`

2. **Fill in** the bracketed `[FILL IN]` sections with your info:
   - Member name (e.g., DC, WEB_CLAUDE)
   - Role and project details
   - Available tools and access

3. **Copy and paste** the entire prompt into Claude

4. **Confirm** Claude acknowledges the onboarding

---

## 📖 Detailed Usage

### Setup Wizard (CLI)

The bootstrap script provides an interactive wizard:

```bash
./claude_bootstrap.sh --setup
```

**What it does**:
- Detects your environment (WSL2, Docker, Linux, macOS)
- Prompts for member identity (name, type, role)
- Configures baseline and project settings
- Creates initial continuity log entry
- Saves configuration to `claude_member_config.json`

**Options**:
```bash
--setup, -s     Run interactive setup wizard
--load, -l      Display onboarding prompt to copy/paste
--status, -i    Show current configuration status
--help, -h      Show help message
```

### Configuration File

`claude_member_config.json` contains:

```json
{
  "member_info": {
    "name": "TERMC",
    "type": "cli",
    "initialized": true
  },
  "baseline": {
    "primary_role": "Development & Scripting Assistant",
    "communication_style": {...},
    "operating_principles": [...]
  },
  "goals": {
    "current_project": "...",
    "primary_objectives": [...]
  },
  "context_awareness": {
    "other_members": {...},
    "shared_resources": {...}
  }
}
```

### Continuity Log

The `continuity_log.md` file tracks:
- Latest work from each member
- Current project state
- Handoff notes
- Next steps and blockers

**Update the log** when:
- You complete a significant task
- You need to hand off to another member
- You encounter a blocker
- You switch projects

**Template for new entries**:
```markdown
## Entry: [Date/Time]
**Member**: [Your member name]
**Status**: [Active/Completed/Blocked/Handoff]
**Project**: [Current project]

### What Was Done
- [Tasks completed]

### Current State
- [Current status]

### Next Steps
- [ ] [Task 1]

### Context for Next Member
[Important info]

### Handoff
**To**: [Member name]
**Reason**: [Why]
```

---

## 🔄 Workflow Examples

### Scenario 1: Starting a New Project (CLI)

```bash
# 1. Setup member if not already done
./claude_bootstrap.sh --setup

# 2. Load onboarding
./claude_bootstrap.sh --load

# 3. Paste output into Claude Code

# 4. Start working

# 5. Update continuity log when done
# Edit continuity_log.md with your progress
```

### Scenario 2: Continuing Work (Desktop)

```bash
# 1. Check continuity log for latest context
cat continuity_log.md

# 2. Read your onboarding prompt
cat onboarding_prompt.md

# 3. Paste onboarding to Desktop Claude

# 4. Inform Claude:
"Check continuity_log.md for latest context from TERMC"

# 5. Continue work

# 6. Update continuity log when done
```

### Scenario 3: Quick Question (Web)

```bash
# 1. Open onboarding_prompt.md

# 2. Fill in WEB_CLAUDE details

# 3. Paste to claude.ai

# 4. Ask your question

# Note: Web Claude has no file access,
# so you may need to paste relevant context
```

### Scenario 4: Handoff Between Members

**TERMC completes task, hands off to DC**:

```markdown
## Entry: 2025-11-12 14:00
**Member**: TERMC
**Status**: Handoff
**Project**: Script Testing

### What Was Done
- Created system_info_checker.sh
- Tested and verified working
- Script is at /home/STRYK/system_info_checker.sh

### Current State
- Script ready for GUI testing
- Waiting for user to test in GUI

### Next Steps
- [ ] User tests script in GUI
- [ ] Create script #2 if test passes

### Context for Next Member
The script uses common utilities and should show all dependencies as satisfied in the GUI. It's the first of three planned test scripts.

### Handoff
**To**: User (or DC if GUI debugging needed)
**Reason**: Need user to test in GUI before proceeding
```

---

## 🎨 Customization

### Adding New Members

1. **Copy config template**:
   ```bash
   cp claude_member_config.json new_member_config.json
   ```

2. **Edit with new member details**:
   ```json
   {
     "member_info": {
       "name": "NEW_MEMBER",
       "type": "cli/desktop_app/web"
     }
   }
   ```

3. **Run setup** or manually configure

### Modifying Baseline

Edit `claude_member_config.json`:

```json
{
  "baseline": {
    "primary_role": "Your custom role",
    "communication_style": {
      "tone": "casual/professional/technical",
      "verbosity": "low/medium/high"
    },
    "operating_principles": [
      "Your custom principle 1",
      "Your custom principle 2"
    ]
  }
}
```

### Project-Specific Setup

Create different configs for different projects:

```bash
claude-bootstrap/
├── project-A/
│   ├── claude_member_config.json
│   └── continuity_log.md
├── project-B/
│   ├── claude_member_config.json
│   └── continuity_log.md
```

---

## 💾 Portability

### Sharing via Dropbox

1. **Copy to Dropbox**:
   ```bash
   cp -r claude-bootstrap ~/Dropbox/
   ```

2. **Access from any machine**:
   ```bash
   cd ~/Dropbox/claude-bootstrap
   ./claude_bootstrap.sh --status
   ```

3. **Update shared resources path** in config:
   ```json
   {
     "context_awareness": {
       "shared_resources": {
         "dropbox_path": "~/Dropbox/claude-bootstrap"
       }
     }
   }
   ```

### USB Boot Stick

1. **Copy to USB**:
   ```bash
   cp -r claude-bootstrap /media/usb/
   ```

2. **Use from USB**:
   ```bash
   cd /media/usb/claude-bootstrap
   ./claude_bootstrap.sh --setup
   ```

### Git Repository (Advanced)

```bash
cd claude-bootstrap
git init
git add .
git commit -m "Initial bootstrap system"
git remote add origin <your-repo>
git push -u origin main
```

**Note**: Be careful not to commit sensitive information in config files!

---

## 🔧 Troubleshooting

### jq Not Installed

The bootstrap script uses `jq` for JSON parsing. If not available:

```bash
# Install jq
sudo apt-get install jq  # Debian/Ubuntu
brew install jq          # macOS
```

Or manually edit JSON files.

### Script Not Executable

```bash
chmod +x claude_bootstrap.sh
```

### Config File Not Found

```bash
# Check if file exists
ls -la claude_member_config.json

# Re-run setup if missing
./claude_bootstrap.sh --setup
```

### Environment Detection Issues

The script auto-detects WSL2, Docker, Linux, macOS. If detection fails, manually edit the config:

```json
{
  "environment": {
    "platform": "wsl2",
    "container": false
  }
}
```

---

## 🎓 Best Practices

### Do's ✅
- **Always update continuity log** after significant work
- **Be specific** in handoff notes
- **Check continuity log first** when resuming work
- **Customize baseline** for each project
- **Keep configs in sync** across instances

### Don'ts ❌
- **Don't skip onboarding** - it ensures consistency
- **Don't assume context** - always check continuity log
- **Don't commit secrets** to git if using version control
- **Don't modify running config** - use setup wizard

---

## 📚 Advanced Features

### Multiple Projects

Organize by project:

```bash
claude-bootstrap/
├── project-gui-testing/
│   ├── claude_member_config.json
│   └── continuity_log.md
├── project-network-tools/
│   ├── claude_member_config.json
│   └── continuity_log.md
```

### MCP Integration

Add MCP server configs to member config:

```json
{
  "tools_available": {
    "mcp_servers": [
      "github",
      "postgres",
      "filesystem"
    ]
  }
}
```

### Claude Artifacts

Save `onboarding_prompt.md` as a Claude Artifact for quick access in web interface.

---

## 🤝 Contributing

This is your personal workflow system. Customize it to fit your needs!

Ideas for enhancements:
- Automated sync scripts
- Web dashboard for continuity log
- Slack/Discord integration for handoffs
- VS Code extension for quick access

---

## 📄 License

Personal use - customize as needed!

---

## 🆘 Support

For issues or questions:
1. Check troubleshooting section above
2. Review example workflows
3. Examine config file structure
4. Ask any Claude instance for help (they're trained on this system!)

---

**Version**: 1.0.0
**Created**: 2025-11-12
**Author**: TERMC (Terminal Claude)

**End of Documentation**
