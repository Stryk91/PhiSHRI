# E60 - Battle.net Installer Stuck at 5%/45%

## SYMPTOM
Battle.net Setup stuck at 5% or 45%, never progresses.
Agent.exe can't bind to port 1120.

## ROOT CAUSE (SOLVED 2025-12-05)
**IP Helper service (iphlpsvc) was squatting on port 1120.**
- Agent.exe needs port 1120 for IPC with Setup.exe
- Agent falls back to 6881+ if 1120 blocked, but Setup expects 1120
- Result: Setup waits forever for Agent on wrong port

## DIAGNOSIS
```powershell
netstat -ano | findstr ":1120"
# If iphlpsvc (or any other process) owns 1120 → that's the issue
```

## FIX
```powershell
# 1. Stop IP Helper service
Stop-Service iphlpsvc -Force

# 2. Run installer
& "$env:USERPROFILE\Downloads\Battle.net-Setup.exe"

# 3. After install completes, IP Helper restarts on reboot (or manually)
```

## RED HERRINGS (tried, didn't help)
- WSL2 shutdown (`wsl --shutdown`)
- Disabling Hyper-V (`bcdedit /set hypervisorlaunchtype off`)
- `netsh winsock reset` + reboot
- `netsh int ip reset` + reboot
- Disabling Windows Firewall
- Port proxy (`netsh interface portproxy`)
- `.wslconfig` hostAddressLoopback setting
- NAT vs mirrored mode switching

## POST-INSTALL NOTES
- TCP stack settings (BBR2, ECN, MinRTO) remain intact
- Stale port proxy rules can be left or cleaned:
  ```powershell
  netsh interface portproxy show all
  netsh interface portproxy delete v4tov4 listenport=1120 listenaddress=127.0.0.1
  ```

## AGENT CLI FLAGS (reference)
```
--port=         Admin/API port (not IPC)
--adminport=    Admin port
--locale=       Language
--session=      Session ID
--loglevel=     1-4
--skipupdate    Skip self-update
```

## RELATED
- Any app using localhost TCP on specific ports may hit this
- SteelSeries GG had similar issues
