# PhiLaunch Phone Shortcuts (Android Optimized)

**Connection**: `ssh stryk@192.168.50.149 -p 2222`

---

## Quick Status & Monitoring

### System Status
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh status'
```

### List Available Scripts
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh list-scripts'
```

### List Running Tasks
```
ssh stryk@192.168.50.149 -p 2222 'tmux list-sessions'
```

### View Recent Logs
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh logs'
```

---

## Run PhiLaunch Scripts

### WoW Monitor
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh wow_monitor.sh'
```

### WoW Quick Check
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh wow_quick_check.sh'
```

### System Info Check
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh system_info_checker.sh'
```

### Status Monitor
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh status_monitor.sh'
```

---

## Background Tasks

### Start Background Task
```
ssh stryk@192.168.50.149 -p 2222
~/automation/start-long-task.sh TASKNAME 'command here'
exit
```

### Check Background Tasks
```
ssh stryk@192.168.50.149 -p 2222 'tmux list-sessions'
```

### Attach to Task (interactive)
```
ssh stryk@192.168.50.149 -p 2222
tmux attach -t TASKNAME
# Ctrl+B then D to detach
```

### Kill Background Task
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh kill-task TASKNAME'
```

---

## System Commands

### Restart SSH Server
```
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh restart-ssh'
```

### Free Memory Info
```
ssh stryk@192.168.50.149 -p 2222 'free -h'
```

### Disk Usage
```
ssh stryk@192.168.50.149 -p 2222 'df -h /'
```

### Uptime
```
ssh stryk@192.168.50.149 -p 2222 'uptime -p'
```

### Network Info
```
ssh stryk@192.168.50.149 -p 2222 'hostname -I'
```

### Process List (top 10)
```
ssh stryk@192.168.50.149 -p 2222 'ps aux --sort=-%mem | head -11'
```

---

## File Operations

### Download File
```
scp -P 2222 stryk@192.168.50.149:/home/STRYK/file.txt ~/storage/downloads/
```

### Upload File
```
scp -P 2222 ~/storage/downloads/file.txt stryk@192.168.50.149:/home/STRYK/
```

### List Files
```
ssh stryk@192.168.50.149 -p 2222 'ls -lh /home/STRYK/'
```

### View File Content
```
ssh stryk@192.168.50.149 -p 2222 'cat /home/STRYK/file.txt'
```

---

## Git Operations

### Git Status
```
ssh stryk@192.168.50.149 -p 2222 'cd /home/STRYK && git status'
```

### Git Pull Latest
```
ssh stryk@192.168.50.149 -p 2222 'cd /home/STRYK && git pull origin main'
```

### Git Commit All
```
ssh stryk@192.168.50.149 -p 2222 'cd /home/STRYK && git add . && git commit -m "Update from phone" && git push'
```

---

## Port Forwarding

### Forward Web Service (8080)
```
ssh -L 8080:localhost:8080 stryk@192.168.50.149 -p 2222
```

### Forward Multiple Ports
```
ssh -L 8080:localhost:8080 -L 3000:localhost:3000 stryk@192.168.50.149 -p 2222
```

### Background Tunnel
```
ssh -N -f -L 8080:localhost:8080 stryk@192.168.50.149 -p 2222
```

---

## WireGuard VPN for WAN Access

**LAN vs WAN:**
- **LAN** (192.168.50.149): Works when on home WiFi
- **WAN** (from anywhere): Requires WireGuard VPN connection first

### Using WireGuard

**1. Install WireGuard on Android:**
```
Download from Google Play Store or F-Droid
https://www.wireguard.com/install/
```

**2. Add Your Config:**
- Import your existing .conf file
- Or scan QR code from your WireGuard server

**3. Connect Workflow:**
```bash
# 1. Enable WireGuard VPN on phone (tap to connect in app)
# 2. Once connected, you're "on the network" at 192.168.50.x
# 3. Use all SSH commands normally:
ssh stryk@192.168.50.149 -p 2222
pcstatus
pcwow
# etc.

# 4. Disconnect WireGuard when done
```

**Key Point:** Once WireGuard is connected, ALL the shortcuts below work exactly the same whether you're home or away!

**Alternative - WireGuard in Termux:**
```bash
# Install in Termux (requires root or kernel support)
pkg install wireguard-tools

# Add config
nano ~/.wireguard/wg0.conf

# Connect
wg-quick up wg0

# Disconnect
wg-quick down wg0
```

---

## ANDROID SETUP GUIDE

### 1. Install Termux
```
Download from F-Droid (recommended) or Google Play
https://f-droid.org/en/packages/com.termux/
```

### 2. Setup Termux
```bash
# Update packages
pkg update && pkg upgrade

# Install SSH client
pkg install openssh

# Enable storage access
termux-setup-storage

# Create SSH config directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### 3. Add Aliases to Termux

Edit `~/.bashrc` in Termux:
```bash
nano ~/.bashrc
```

Add these lines:
```bash
# PhiLaunch PC Shortcuts
alias pc='ssh stryk@192.168.50.149 -p 2222'
alias pcstatus='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/home-control.sh status"'
alias pctasks='ssh stryk@192.168.50.149 -p 2222 "tmux list-sessions"'
alias pcscripts='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/home-control.sh list-scripts"'
alias pclogs='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/home-control.sh logs"'
alias pcwow='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/launch-script.sh wow_monitor.sh"'
alias pcwowcheck='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/launch-script.sh wow_quick_check.sh"'
alias pcsysinfo='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/launch-script.sh system_info_checker.sh"'
alias pcmem='ssh stryk@192.168.50.149 -p 2222 "free -h"'
alias pcdisk='ssh stryk@192.168.50.149 -p 2222 "df -h /"'
alias pcup='ssh stryk@192.168.50.149 -p 2222 "uptime -p"'
alias pcgit='ssh stryk@192.168.50.149 -p 2222 "cd /home/STRYK && git status"'
alias pckill='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/home-control.sh kill-task "'
```

Save and reload:
```bash
source ~/.bashrc
```

Now just type: **`pcstatus`**, **`pcwow`**, etc.

---

## 4. Termux:Widget (Home Screen Shortcuts)

**Install Termux:Widget:**
```
Download from F-Droid
https://f-droid.org/en/packages/com.termux.widget/
```

**Create shortcut scripts:**
```bash
# Create widget directory
mkdir -p ~/.shortcuts

# PC Status
cat > ~/.shortcuts/pc-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh status'
EOF

# WoW Monitor
cat > ~/.shortcuts/wow-monitor.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/start-long-task.sh wow "./wow_monitor.sh"'
echo "WoW monitor started in background"
EOF

# Check Tasks
cat > ~/.shortcuts/check-tasks.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
ssh stryk@192.168.50.149 -p 2222 'tmux list-sessions'
EOF

# Make executable
chmod +x ~/.shortcuts/*.sh
```

**Add to home screen:**
1. Long-press home screen
2. Add Widget → Termux:Widget
3. Tap the shortcut to run

---

## 5. Termux:Tasker Integration

**Install Termux:Tasker:**
```
Download from F-Droid
https://f-droid.org/en/packages/com.termux.tasker/
```

**Example Tasker Task:**
1. New Task → "Check PC Status"
2. Add Action → Plugin → Termux:Tasker
3. Configuration:
   - Executable: `/data/data/com.termux/files/home/.shortcuts/pc-status.sh`
4. Can trigger from:
   - Time (check status every hour)
   - Location (check when home)
   - Button press
   - Voice command

---

## 6. Quick Settings Tile (Android 7+)

**Using Tasker + AutoTools:**
1. Create Tasker task (as above)
2. Install AutoTools
3. Create Quick Settings Tile
4. Link to Termux script
5. One-tap access from notification shade

---

## 7. Gboard Text Shortcuts

**Setup in Gboard:**
1. Settings → Dictionary → Personal dictionary
2. Add shortcuts:

| Shortcut | Phrase |
|----------|--------|
| `@pcstat` | `ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh status'` |
| `@pcwow` | `ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh wow_monitor.sh'` |
| `@pctask` | `ssh stryk@192.168.50.149 -p 2222 'tmux list-sessions'` |
| `@pcssh` | `ssh stryk@192.168.50.149 -p 2222` |

Type `@pcstat` → auto-expands to full command → paste in Termux

---

## 8. SSH Key Setup (Password-less login)

**Generate key on Android:**
```bash
# In Termux
ssh-keygen -t ed25519 -C "android-phone"

# Copy public key to PC
ssh-copy-id -p 2222 stryk@192.168.50.149

# Or manually:
cat ~/.ssh/id_ed25519.pub
# Copy output, then on PC:
# echo "PASTE_KEY_HERE" >> ~/.ssh/authorized_keys
```

Now SSH without password!

---

## 9. ConnectBot Alternative

If you prefer a GUI SSH app:
- **JuiceSSH** (recommended)
- **ConnectBot**
- **Termius**

**Setup in JuiceSSH:**
1. Create Connection
   - Nickname: "PhiLaunch PC"
   - Host: 192.168.50.149
   - Port: 2222
   - Username: stryk
2. Save connection
3. Create Snippets for common commands
4. Add to home screen

---

## Quick Reference Table

| What | Termux Command |
|------|----------------|
| Connect | `pc` |
| Status | `pcstatus` |
| Tasks | `pctasks` |
| Scripts | `pcscripts` |
| WoW | `pcwow` |
| Logs | `pclogs` |
| Memory | `pcmem` |
| Disk | `pcdisk` |
| Git | `pcgit` |

---

## Troubleshooting

### "Connection refused"
```bash
# Check if SSH server is running
ssh stryk@192.168.50.149 -p 2222 'sudo systemctl status ssh'
```

### "Permission denied"
```bash
# Check password or SSH key
# Re-enter password or regenerate key
```

### "Host not found"
```bash
# Check IP address changed
# On PC: hostname -I
# Update shortcuts with new IP
```

---

**Last Updated**: 2025-11-12
**For**: Android with Termux
