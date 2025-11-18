# PhiWave Remote Phone Control

Control Claude Code and PhiWave development from your Android phone via Termux + Git.

---

## 🚀 Quick Start (From Your Phone)

### Step 1: One-Time Setup in Termux

```bash
# Install git if not already installed
pkg install git

# Clone the repo
cd ~
git clone https://github.com/Stryk91/Phiwave.git
cd Phiwave

# Configure git (if not done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 2: Send a Command

**Method A: Edit file directly (Quick)**
```bash
cd ~/Phiwave
git pull origin master

# Add your command
echo '{"command": "status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl

# Push command
git add docs/remote-commands.jsonl
git commit -m "cmd: status check"
git push origin master
```

**Method B: Use nano editor (More control)**
```bash
cd ~/Phiwave
git pull origin master

# Open file in nano
nano docs/remote-commands.jsonl

# Add line at the end (Ctrl+O to save, Ctrl+X to exit):
{"command": "YOUR_COMMAND", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}

# Push command
git add docs/remote-commands.jsonl
git commit -m "cmd: YOUR_COMMAND"
git push origin master
```

### Step 3: Check Results

Wait 10-30 seconds, then:
```bash
cd ~/Phiwave
git pull origin master

# View command results
tail -5 docs/remote-commands.jsonl
```

---

## 📋 Available Commands

Copy-paste these JSON commands into `docs/remote-commands.jsonl`:

### **status** - Get latest commit
```json
{"command": "status", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}
```

### **git status** - Check working tree
```json
{"command": "git status", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}
```

### **team status** - See agent activity
```json
{"command": "team status", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}
```

### **check feed** - Last 5 feed entries
```json
{"command": "check feed", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}
```

### **run tests** - Queue Junie testing
```json
{"command": "run tests", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}
```

### **run polish task 1** - Queue DESKC task (1-5)
```json
{"command": "run polish task 1", "timestamp": "2025-10-25T12:00:00Z", "status": "pending"}
```

---

## ⚡ Phone Quick Commands (One-Liners)

Save these as Termux shortcuts or aliases:

```bash
# Add to ~/.bashrc in Termux
alias phiwave='cd ~/Phiwave && git pull'
alias status='cd ~/Phiwave && git pull && echo "{\"command\": \"status\", \"timestamp\": \"$(date -Iseconds)\", \"status\": \"pending\"}" >> docs/remote-commands.jsonl && git add docs/remote-commands.jsonl && git commit -m "cmd: status" && git push'
alias teamstatus='cd ~/Phiwave && git pull && echo "{\"command\": \"team status\", \"timestamp\": \"$(date -Iseconds)\", \"status\": \"pending\"}" >> docs/remote-commands.jsonl && git add docs/remote-commands.jsonl && git commit -m "cmd: team status" && git push'
alias results='cd ~/Phiwave && git pull && tail -5 docs/remote-commands.jsonl'
```

Then from Termux, just type:
```bash
status        # Send status command
teamstatus    # Send team status command
results       # Check command results
```

---

## 🔧 How It Works

1. **You (Phone)**: Add command to `docs/remote-commands.jsonl` with `"status": "pending"`
2. **Git**: Push changes to GitHub
3. **Claude Code (Desktop)**: Monitors file every 10 seconds
4. **Claude Code**: Executes command when detected
5. **Claude Code**: Updates command with `"status": "completed"` and results
6. **Claude Code**: Commits updated results to GitHub
7. **You (Phone)**: Pull latest changes to see results

```
Phone → Git Push → GitHub → Desktop Claude Code → Executes → Git Push → GitHub → Phone Pull → Results
```

---

## 📱 Termux Widgets (Advanced)

Create one-tap shortcuts on your Android home screen:

### Setup:
1. Install **Termux:Widget** from F-Droid or Play Store
2. Create scripts in `~/.shortcuts/`

### Example Widget Script: `~/.shortcuts/phiwave-status.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
cd ~/Phiwave
git pull origin master
echo '{"command": "status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl
git commit -m "cmd: status"
git push origin master
echo "Status command sent!"
sleep 2
```

Make executable:
```bash
chmod +x ~/.shortcuts/phiwave-status.sh
```

Now add widget to home screen → tap to send command!

---

## 🎯 Command Examples

### Example 1: Check Project Status
```bash
cd ~/Phiwave
git pull
echo '{"command": "status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl && git commit -m "cmd: status" && git push

# Wait 30 seconds, then check result:
git pull
tail -1 docs/remote-commands.jsonl | python -m json.tool
```

### Example 2: Assign DESKC Task
```bash
cd ~/Phiwave
git pull
echo '{"command": "run polish task 2", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl && git commit -m "cmd: polish task 2" && git push
```

### Example 3: Check Team Activity
```bash
cd ~/Phiwave
git pull
echo '{"command": "team status", "timestamp": "'$(date -Iseconds)'", "status": "pending"}' >> docs/remote-commands.jsonl
git add docs/remote-commands.jsonl && git commit -m "cmd: team status" && git push

# Check results after 30 seconds:
git pull && tail -1 docs/remote-commands.jsonl
```

---

## 🛠️ Troubleshooting

### Command not executing?
1. Check Claude Code is running on desktop
2. Verify command processor script is active
3. Check command format (valid JSON)
4. Ensure `"status": "pending"` is set

### Git push failing?
```bash
# Authenticate GitHub
git config credential.helper store
git pull  # Enter credentials when prompted
```

### Can't see results?
```bash
# Force pull latest changes
cd ~/Phiwave
git fetch origin
git reset --hard origin/master
tail -5 docs/remote-commands.jsonl
```

---

## 🎮 Command Processor (Desktop - For Reference)

On your desktop, Claude Code monitors commands with:
```bash
cd E:\PythonProjects\PhiWave
python phiwave/remote_command_processor.py
```

This runs automatically and processes commands every 10 seconds.

---

## 💡 Tips

- **Use timestamp**: Helps identify your commands in the queue
- **One command at a time**: Wait for completion before sending next
- **Check results**: Always `git pull` before checking `tail -5 docs/remote-commands.jsonl`
- **Keep short**: Long commands may fail; keep under 100 characters

---

## 📚 Command Reference Card (Print This!)

```
┌─────────────────────────────────────────────────────┐
│ PhiWave Phone Commands - Quick Reference           │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Send Command:                                       │
│   cd ~/Phiwave && git pull                         │
│   echo '{"command": "COMMAND", ...}' >> ...       │
│   git add . && git commit -m "cmd" && git push    │
│                                                     │
│ Check Results (30 sec later):                      │
│   cd ~/Phiwave && git pull                         │
│   tail -5 docs/remote-commands.jsonl              │
│                                                     │
│ Quick Commands:                                     │
│   status       - Latest commit                      │
│   git status   - Working tree                       │
│   team status  - Agent activity                     │
│   check feed   - Last 5 entries                     │
│   run tests    - Queue Junie                        │
│   run polish task N - Queue DESKC (N=1-5)          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

**Status:** Remote phone control system ready! 🚀

Send your first command and check results in ~30 seconds.
