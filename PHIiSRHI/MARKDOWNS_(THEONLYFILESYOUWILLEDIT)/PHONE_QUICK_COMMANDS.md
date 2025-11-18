# PhiWave Phone Quick Commands

Ultra-fast commands for working with Claude Code from your Android phone.

---

## 📱 SETUP (One-Time)

### 1. Add Aliases to Termux

```bash
# Open bashrc
nano ~/.bashrc

# Paste these aliases at the end:
alias phiwave='cd ~/Phiwave && git pull origin main'
alias cmd='cd ~/Phiwave && echo "{\"command\": \"\$1\", \"timestamp\": \"$(date -Iseconds)\", \"status\": \"pending\"}" >> docs/remote-commands.jsonl && git add docs/remote-commands.jsonl && git commit -m "cmd: \$1" && git push origin main'
alias result='cd ~/Phiwave && git pull origin main && tail -1 docs/remote-commands.jsonl'
alias results='cd ~/Phiwave && git pull origin main && tail -5 docs/remote-commands.jsonl'

# Save: Ctrl+O, Enter, Ctrl+X

# Reload bashrc
source ~/.bashrc
```

---

## ⚡ SUPER QUICK COMMANDS

### Check Project Status
```bash
phiwave && cmd "status"
# Wait 30 seconds
result
```

### Check Team Activity
```bash
phiwave && cmd "team status"
# Wait 30 seconds
result
```

### Check Agent Feed
```bash
phiwave && cmd "check feed"
# Wait 30 seconds
result
```

### Git Status
```bash
phiwave && cmd "git status"
# Wait 30 seconds
result
```

### Run Tests (Junie)
```bash
phiwave && cmd "run tests"
```

### Assign Polish Task to DESKC
```bash
phiwave && cmd "run polish task 1"
# Replace 1 with task number (1-5)
```

---

## 🎯 CUSTOM COMMANDS

You can send ANY natural language command:

```bash
phiwave
echo '{"command": "YOUR CUSTOM COMMAND HERE", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl
git commit -m "cmd: custom"
git push origin main
```

### Example Custom Commands:

**"Read POLISH_PHASE_TIER1_TASKS.md and summarize"**
```bash
phiwave
echo '{"command": "read POLISH_PHASE_TIER1_TASKS.md and summarize", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl && git commit -m "cmd: read tasks" && git push origin main
```

**"Check if Junie has any test failures"**
```bash
phiwave
echo '{"command": "check if Junie has test failures", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl && git commit -m "cmd: check junie" && git push origin main
```

**"Show last 10 commits"**
```bash
phiwave
echo '{"command": "show last 10 commits", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl && git commit -m "cmd: commits" && git push origin main
```

---

## 🔥 ONE-LINER ULTRA-FAST COMMANDS

Copy these exactly as-is into Termux:

### Status Check
```bash
cd ~/Phiwave && git pull origin main && echo '{"command": "status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl && git add docs/remote-commands.jsonl && git commit -m "cmd: status" && git push origin main && sleep 40 && git pull origin main && tail -1 docs/remote-commands.jsonl
```

### Team Status
```bash
cd ~/Phiwave && git pull origin main && echo '{"command": "team status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl && git add docs/remote-commands.jsonl && git commit -m "cmd: team" && git push origin main && sleep 40 && git pull origin main && tail -1 docs/remote-commands.jsonl
```

### Check Feed
```bash
cd ~/Phiwave && git pull origin main && echo '{"command": "check feed", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl && git add docs/remote-commands.jsonl && git commit -m "cmd: feed" && git push origin main && sleep 40 && git pull origin main && tail -1 docs/remote-commands.jsonl
```

---

## 📋 TERMUX WIDGETS (Home Screen Shortcuts)

### Setup:
1. Install **Termux:Widget** from F-Droid
2. Create `~/.shortcuts/` directory
3. Add scripts below
4. Add widget to home screen

### Widget 1: Status Check
`~/.shortcuts/phiwave-status.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
cd ~/Phiwave
git pull origin main
echo '{"command": "status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl
git commit -m "cmd: status"
git push origin main
echo "Status command sent! Check result in 1 minute."
sleep 2
```

### Widget 2: Team Status
`~/.shortcuts/phiwave-team.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
cd ~/Phiwave
git pull origin main
echo '{"command": "team status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl
git commit -m "cmd: team"
git push origin main
echo "Team status command sent!"
sleep 2
```

### Widget 3: Check Results
`~/.shortcuts/phiwave-results.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
cd ~/Phiwave
git pull origin main
echo "=== LAST 3 COMMANDS ==="
tail -3 docs/remote-commands.jsonl
sleep 5
```

Make executable:
```bash
chmod +x ~/.shortcuts/*.sh
```

---

## 🎮 WORKFLOW EXAMPLES

### Example 1: Quick Health Check
```bash
# Send command
phiwave && cmd "status"

# Wait 30-60 seconds while having coffee

# Check result
result
```

### Example 2: Before Leaving House
```bash
# Assign DESKC a task
phiwave && cmd "run polish task 1"

# Check team status
phiwave && cmd "team status"

# Later, check results
results
```

### Example 3: During Commute
```bash
# Check if tests passed
phiwave && cmd "check feed"

# Wait 1 minute

# View result
result
```

---

## 💡 PRO TIPS

1. **Always pull before pushing:**
   ```bash
   phiwave  # This does git pull
   ```

2. **Check multiple results:**
   ```bash
   results  # Shows last 5 commands
   ```

3. **Wait 30-60 seconds** after sending command for auto-processing

4. **Use Termux widgets** for one-tap commands from home screen

5. **Save frequent commands** as bash functions:
   ```bash
   # Add to ~/.bashrc
   check_status() {
       phiwave && cmd "status" && sleep 40 && result
   }
   ```

---

## 🔧 TROUBLESHOOTING

### Command not processing?
```bash
# Check if monitor is running on desktop
# Double-click: start_remote_monitor.bat
```

### Can't push to GitHub?
```bash
# Re-authenticate
cd ~/Phiwave
git pull  # Enter credentials when prompted
```

### See command but no result?
```bash
# Wait longer (up to 2 minutes)
# Or check desktop monitor is running
```

---

## 📚 AVAILABLE COMMANDS

| Command | What It Does |
|---------|-------------|
| `status` | Latest commit |
| `git status` | Working tree status |
| `team status` | Agent activity count |
| `check feed` | Last 5 feed entries |
| `run tests` | Queue Junie testing |
| `run polish task N` | Queue DESKC task (1-5) |

**Custom commands:** You can send ANY text command and Claude Code will try to interpret it!

---

## 🚀 FASTEST POSSIBLE WORKFLOW

1. **Desktop**: Leave `start_remote_monitor.bat` running
2. **Phone**: Use Termux widgets (one tap!)
3. **Result**: Auto-processed in 30-60 seconds

**Example:** Tap "Status Check" widget → Wait 1 min → Tap "Check Results" widget → Done! ✅

---

**Status:** Phone control system fully operational! 📱🚀
