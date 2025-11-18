# PhiVector - AI Automation That Works The First Time

**"The fastest way to do something is to do it once. No matter how slow you are."**

Welcome to PhiVector - a lean, file-based multi-agent coordination system built by a former bricklayer who thinks in pipelines.

---

## What This Is

PhiVector lets you coordinate multiple AI agents (Desktop Claude, VS Code, WSL/Kali, Browser, etc.) using simple scripts and files. No enterprise bloat. No dashboards for the sake of dashboards. Just practical automation that works.

**Core Features:**
- File-based message bus (JSON in folders)
- PowerShell + AutoHotkey automation
- Cost optimization (free-tier rotation, token batching)
- Multi-agent coordination
- CASCADE Protocol (systematic problem-solving)

---

## Quick Start (5 Minutes)

### 1. Extract the Package
```powershell
# Extract phivector-v1.0.zip to your preferred location
# Example: C:\phivector
```

### 2. Install Dependencies
```powershell
# Python 3.8+ required
python --version

# Install Python dependencies
pip install -r requirements.txt

# Optional: Install AutoHotkey for desktop automation
# Download from: https://www.autohotkey.com/
```

### 3. Configure Your Setup
```powershell
# Copy the example config
cp config.example.json config.json

# Edit config.json with your settings:
# - AI provider API keys
# - Agent paths
# - Cost limits
```

### 4. Test Basic Coordination
```powershell
# Run the test script
python test_coordination.py

# You should see agents communicating via files
```

### 5. Try an Example Workflow
```powershell
# Run a basic workflow
.\examples\basic_workflow.ps1

# This demonstrates:
# - File-based messaging
# - Agent coordination
# - Cost tracking
```

---

## Directory Structure

```
phivector/
├── mcp_bridge/           # Core coordination system
│   ├── message_router.py      # File-based message routing
│   ├── capability_manager.py  # Agent capability tracking
│   └── cost_optimizer.py      # Token/cost optimization
├── scripts/              # Automation scripts
│   ├── remote_mcp_admin.sh    # SSH-based admin
│   └── *.ps1                  # PowerShell utilities
├── examples/             # Ready-to-use workflows
│   ├── basic_workflow.ps1
│   ├── cost_rotation_example.ps1
│   └── agent_coordination_example.ps1
├── docs/                 # Documentation
│   ├── CASCADE_PROTOCOL.md
│   ├── QUICKSTART.md
│   └── TROUBLESHOOTING.md
├── config.example.json   # Example configuration
└── requirements.txt      # Python dependencies
```

---

## Core Concepts

### 1. File-Based Message Bus
Agents communicate by dropping JSON files into folders:
```
phivector_mcp/
├── agents/
│   ├── dc/inbox/         # Desktop Claude receives messages here
│   ├── vscc/inbox/       # VS Code Claude receives messages here
│   └── [agent]/inbox/    # Each agent has inbox/outbox/processed
```

### 2. Agent Coordination
Each agent has:
- **Capabilities** (what tools it can run)
- **Inbox** (incoming messages)
- **Outbox** (sent messages)
- **Processed** (completed messages)

### 3. Cost Optimization
The system automatically:
- Rotates between free-tier providers
- Batches similar requests
- Caches shared context
- Tracks token usage

### 4. CASCADE Protocol
Systematic problem-solving through binary decision trees:
1. Can I make a solution? → Yes/No
2. Multiple steps? → Yes/No
3. Can I script it? → Yes/No
4. In database? → Yes/No
5. Execute → Complete?

See `docs/CASCADE_PROTOCOL.md` for full details.

---

## Example Workflows

### Example 1: Basic File Processing
```powershell
# Process a file with AI
.\examples\basic_workflow.ps1 -FilePath "document.txt" -Agent "vscc"

# This will:
# 1. Send file to VS Code Claude
# 2. Get AI response
# 3. Save result to output/
```

### Example 2: Cost-Optimized Batch
```powershell
# Process multiple files with cost optimization
.\examples\cost_rotation_example.ps1 -Folder "documents/"

# This will:
# 1. Batch similar files
# 2. Rotate between free-tier providers
# 3. Track token usage
# 4. Generate cost report
```

### Example 3: Multi-Agent Coordination
```powershell
# Coordinate multiple agents on a task
.\examples\agent_coordination_example.ps1 -Task "analyze_project"

# This will:
# 1. Break task into subtasks
# 2. Assign to appropriate agents
# 3. Coordinate execution
# 4. Aggregate results
```

---

## Configuration

### Basic Config (config.json)
```json
{
  "providers": {
    "anthropic": {
      "api_key": "your-key-here",
      "daily_limit": 1000
    },
    "openrouter": {
      "api_key": "your-key-here",
      "daily_limit": 5000
    }
  },
  "agents": {
    "dc": {
      "enabled": true,
      "tools": ["desktop_automation", "file_operations"]
    },
    "vscc": {
      "enabled": true,
      "tools": ["code_analysis", "execute_code"]
    }
  },
  "optimization": {
    "rotation_threshold": 0.9,
    "batch_size": 5,
    "cache_ttl": 3600
  }
}
```

### Agent-Specific Config
Each agent can have its own `capabilities.json`:
```json
{
  "name": "DesktopClaude",
  "tools": [
    {
      "name": "desktop_automation",
      "description": "Execute AutoHotkey macros"
    }
  ],
  "cost_model": "free_tier",
  "max_tokens_per_request": 4096
}
```

---

## Customization

### Adding a New Agent
1. Create agent directory: `phivector_mcp/agents/newagent/`
2. Add capabilities.json
3. Update config.json
4. Test with: `python test_agent.py newagent`

### Adding a New Tool
1. Define tool in agent's capabilities.json
2. Implement tool handler
3. Test with example workflow

### Adding a New Provider
1. Add provider config to config.json
2. Update cost_optimizer.py with provider limits
3. Test rotation with: `python test_rotation.py`

---

## Troubleshooting

### Common Issues

**Issue: Agents not receiving messages**
```powershell
# Check directory structure
python check_setup.py

# Verify permissions
icacls phivector_mcp\agents\*\inbox
```

**Issue: Cost optimizer not rotating**
```powershell
# Check provider limits
python check_limits.py

# Reset daily counters
python reset_counters.py
```

**Issue: Scripts not executing**
```powershell
# Check PowerShell execution policy
Get-ExecutionPolicy

# Set to RemoteSigned if needed
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

See `docs/TROUBLESHOOTING.md` for more details.

---

## Advanced Usage

### Remote Administration
```bash
# SSH into remote agent
./scripts/remote_mcp_admin.sh list

# Deploy tool to agent
./scripts/remote_mcp_admin.sh deploy dc new_tool.ps1

# Monitor resources
./scripts/remote_mcp_admin.sh monitor 60 10
```

### Custom Workflows
Create your own workflows by:
1. Copying an example
2. Modifying agent assignments
3. Adding custom logic
4. Testing incrementally

### Integration with Existing Tools
PhiVector works with:
- VS Code extensions
- AutoHotkey scripts
- PowerShell modules
- WSL/Linux tools
- Any tool with file I/O

---

## Performance Tips

1. **Batch Similar Tasks**: Use cost optimizer to batch similar requests
2. **Cache Context**: Reuse shared context across requests
3. **Rotate Providers**: Let the system rotate between free tiers
4. **Monitor Usage**: Check cost reports regularly
5. **Optimize Prompts**: Shorter prompts = fewer tokens

---

## Support

**Text-based support:**
- Email: [your email]
- Discord: [your discord if you set one up]
- GitHub Issues: [your repo if public]

**Response time:** Usually within 24 hours

**Async preferred** - I don't like phone calls

---

## Updates

This package includes **lifetime updates**. 

To update:
```powershell
# Check for updates
python check_updates.py

# Download latest version
# Extract and replace files (keep your config.json)
```

---

## License

MIT License - Do whatever you want with it.

See LICENSE file for full details.

---

## Philosophy

**"The fastest way to do something is to do it once. No matter how slow you are."**

This system is built on bricklaying principles:
- Min-max through doing it right
- Stage materials (data) properly
- Plan the sequence (workflow)
- Execute clean (no rework)
- Don't pull walls down (no breaking changes)

If something doesn't work the first time, it's a bug. Let me know and I'll fix it.

---

## What's Next?

1. **Run the examples** to see how it works
2. **Customize for your workflow** using the examples as templates
3. **Read CASCADE_PROTOCOL.md** to understand the problem-solving framework
4. **Join the community** [if you set one up] to share workflows

---

## Credits

Built by a former bricklayer who got tired of clicking through bullshit.

23 days into learning AI automation, I built this because nothing else worked the way I wanted.

Now it's yours. Make it better.

---

**Questions?** Text me: [your contact]

**Want custom work?** See services_one_pager.md

**Found a bug?** Let me know and I'll fix it.