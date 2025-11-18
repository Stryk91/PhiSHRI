# PhiLaunch Project Guidelines

## Core Principle

**WORKFLOW AND AUTOMATION FIRST - ALWAYS**

Every feature, script, and tool in this project must prioritize:
1. **Cross-device accessibility** - Works from PC, phone, tablet, anywhere
2. **Remote execution** - Can be triggered and monitored from any location
3. **Automation-ready** - Can be scripted, scheduled, or chained
4. **Platform agnostic** - Works across Windows, Linux, WSL, mobile
5. **No manual intervention** - If it can be automated, it must be automated

## Design Philosophy

### Remote First
- All scripts must be SSH-accessible
- All tasks must support background execution
- All processes must be monitorable remotely

### Device Independent
- No assumptions about which device you're using
- Support for terminal-only interfaces (phone SSH)
- Web interfaces where beneficial
- CLI always available as fallback

### Automation Layers
1. **Direct execution** - Run scripts manually when needed
2. **Remote execution** - Trigger from any device via SSH
3. **Scheduled execution** - Cron jobs for recurring tasks
4. **Event-driven execution** - Triggers based on system events
5. **API-driven execution** - External tools can trigger tasks

### Documentation Standard
Every script must include:
- Purpose and use case
- Remote execution examples
- Integration points
- Automation examples
- Cross-platform notes

## Implementation Standards

### SSH Integration Required
- All new scripts go in `/home/STRYK/automation/` or organized subdirs
- Must be callable via SSH one-liners
- Support for tmux/screen background execution
- Status reporting capability

### Logging Required
- All long-running tasks must log output
- Logs accessible via SSH
- Status checks available
- Progress monitoring built-in

### Error Handling
- Graceful failures with clear messages
- Recovery procedures documented
- Remote troubleshooting possible

### Testing Checklist
Before committing any new feature:
- [ ] Works via direct execution
- [ ] Works via SSH one-liner
- [ ] Can run in background (tmux/screen)
- [ ] Status is monitorable remotely
- [ ] Errors are logged and accessible
- [ ] Documentation includes remote examples
- [ ] Tested from non-PC device (phone/tablet)

## Project Structure

```
/home/STRYK/
├── automation/          # Main automation scripts
│   ├── home-control.sh  # Central control hub
│   ├── launch-script.sh # Script launcher
│   └── start-long-task.sh # Background task manager
├── remote-scripts/      # Quick execution scripts
├── workflows/           # Multi-step automation workflows
└── api/                 # API endpoints for external integration
```

## Examples of Good Practice

### ✅ Good: SSH-Accessible Script
```bash
#!/bin/bash
# monitor-system.sh
# Usage: ssh user@host 'bash ~/automation/monitor-system.sh'
# Can run in background: ~/automation/start-long-task.sh monitor './monitor-system.sh'

echo "Starting system monitor..."
# Script content
```

### ❌ Bad: Local-Only Script
```bash
#!/bin/bash
# This only works if you're sitting at the PC
notify-send "Task complete"  # Won't work over SSH
```

### ✅ Good: Cross-Device Compatible
```bash
# Check if running over SSH or locally, adapt behavior
if [ -n "$SSH_CONNECTION" ]; then
    echo "Task complete" | tee -a ~/task.log
else
    notify-send "Task complete"
fi
```

## Future Automation Goals

- [ ] Web dashboard for monitoring all tasks
- [ ] Mobile app integration
- [ ] Webhook support for external triggers
- [ ] Voice assistant integration
- [ ] Auto-discovery of running tasks
- [ ] Distributed task execution across multiple machines
- [ ] Cloud backup integration for logs and configs
- [ ] API gateway for external tool integration

## Contributors

- Stryk
- JC
- WEBC

---

**Remember:** If you're manually doing something more than twice, it should be automated.
If it can't be done remotely, it's not done right.
