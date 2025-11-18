# SSH Remote Control - Quick Reference

## Connection Info
- **Host**: 192.168.50.149 (LAN) - Use with WireGuard for WAN
- **Port**: 2222
- **User**: stryk
- **Auth**: Use SSH keys (recommended) - See setup.sh for config

> ⚠️ **NOTE**: This is a legacy reference file. Use `./setup.sh` to configure your personal settings, then run `./tools/generate-phone-shortcuts.sh` to create personalized shortcuts.

## 1. Quick Script Execution (from phone)

### System Status
```bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh status'
```

### List Available Scripts
```bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh list-scripts'
```

### Run Any PhiLaunch Script
```bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh wow_monitor.sh'
```

### One-liner Commands
```bash
ssh stryk@192.168.50.149 -p 2222 'ls -lh'
ssh stryk@192.168.50.149 -p 2222 'free -h'
ssh stryk@192.168.50.149 -p 2222 'df -h'
```

## 2. Long Running Tasks

### Start a Background Task
```bash
ssh stryk@192.168.50.149 -p 2222
~/automation/start-long-task.sh download "curl -O https://example.com/bigfile.zip"
exit
```

### Check Running Tasks
```bash
ssh stryk@192.168.50.149 -p 2222 'tmux list-sessions'
```

### Attach to Running Task
```bash
ssh stryk@192.168.50.149 -p 2222
tmux attach -t download
# Press Ctrl+B then D to detach without stopping
```

### Kill a Task
```bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh kill-task download'
```

## 3. Port Forwarding / Tunneling

### Forward PC Web Service to Phone
```bash
# From phone terminal:
ssh -L 8080:localhost:8080 stryk@192.168.50.149 -p 2222
# Now browse to http://localhost:8080 on phone
```

### Access Multiple Services
```bash
ssh -L 8080:localhost:8080 -L 3000:localhost:3000 stryk@192.168.50.149 -p 2222
```

### Background Tunnel (No Shell)
```bash
ssh -N -f -L 8080:localhost:8080 stryk@192.168.50.149 -p 2222
# Runs in background, keeps tunnel alive
```

### Reverse Tunnel (PC Access Phone)
```bash
ssh -R 9000:localhost:8080 stryk@192.168.50.149 -p 2222
# Your PC can now access phone's port 8080 via localhost:9000
```

## 4. Home Automation Examples

### Start WoW Monitor Remotely
```bash
ssh stryk@192.168.50.149 -p 2222
~/automation/start-long-task.sh wow-monitor './wow_monitor.sh'
exit
```

### Check System Before Bed
```bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/home-control.sh status'
```

### Run Script and Disconnect
```bash
ssh stryk@192.168.50.149 -p 2222 'bash ~/automation/launch-script.sh system_info_checker.sh' > ~/phone-output.txt
```

## 5. File Transfer

### Download from PC to Phone
```bash
scp -P 2222 stryk@192.168.50.149:/home/STRYK/file.txt ~/Downloads/
```

### Upload from Phone to PC
```bash
scp -P 2222 ~/photo.jpg stryk@192.168.50.149:/home/STRYK/
```

### Download Entire Directory
```bash
scp -r -P 2222 stryk@192.168.50.149:/home/STRYK/scripts/ ~/Downloads/
```

## 6. Useful Aliases (add to phone terminal)

```bash
alias pc='ssh stryk@192.168.50.149 -p 2222'
alias pcstatus='ssh stryk@192.168.50.149 -p 2222 "bash ~/automation/home-control.sh status"'
alias pctasks='ssh stryk@192.168.50.149 -p 2222 "tmux list-sessions"'
```

Then use: `pc` to connect, `pcstatus` for quick status, etc.

## Tips
- Use `screen` or `tmux` for persistent sessions
- Add `-o ServerAliveInterval=60` to keep connection alive
- Use `nohup` for commands that should survive SSH disconnect
- Check firewall if connection fails from other devices
