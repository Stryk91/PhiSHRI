# SSH Server Setup Guide

A simple SSH server for remote command execution in PyCharm.

## Installation

```bash
pip install paramiko
```

## Usage

### Start the Server

```bash
python ssh_server.py
```

The server will start on port 49022 (private port range - secure & no admin needed).

✅ **Benefits:**
- No administrator privileges required
- Much less bot scanning than port 22
- In safe private/dynamic port range (49152-65535)

### Connect from Client

```bash
ssh Stryker91@192.168.50.149 -p 49022
```

**Credentials:**
- Username: `Stryker91`
- Password: `pulsating91888`
- Server IP: `192.168.50.149`
- Port: `49022`

⚠️ **CHANGE THESE IN PRODUCTION!** Edit lines 15-17 in `ssh_server.py`

## Features

- ✅ SSH protocol support via paramiko
- ✅ Command execution with output capture
- ✅ Interactive shell with backspace support
- ✅ Multi-client threading
- ✅ Timeout protection (30 sec per command)
- ✅ Clean exit with 'exit' command

## Security Notes

🔒 **This is a development server**

For production use:
1. Change default username/password (lines 15-17)
2. Use SSH keys instead of password auth
3. Add IP whitelisting
4. Enable logging
5. Run behind firewall
6. Consider using proper SSH daemon (OpenSSH)

## Configuration

Edit `ssh_server.py`:

```python
# Line 15-17: Change credentials
if username == "YOUR_USERNAME" and password == "YOUR_SECURE_PASSWORD":
    return paramiko.AUTH_SUCCESSFUL

# Line 133: Change host/port
start_ssh_server(host='0.0.0.0', port=2222)
```

## Troubleshooting

**Port already in use:**
```bash
# Check what's using port 49022
netstat -ano | findstr :49022

# Change port in ssh_server.py line 150
```

**Connection refused:**
- Check firewall settings (allow port 49022 inbound)
- Ensure server is running: `python ssh_server.py`
- Try local connection first: `ssh Stryker91@127.0.0.1 -p 49022`
- Verify server shows: `[+] SSH Server listening on 0.0.0.0:49022`

**paramiko not found:**
```bash
pip install paramiko
```

## Example Session

```
$ python ssh_server.py
[+] SSH Server listening on 0.0.0.0:2222
[+] Username: admin
[+] Password: password123
[+] Connect with: ssh admin@localhost -p 2222

# In another terminal:
$ ssh admin@localhost -p 2222
admin@localhost's password: password123

Welcome to PyCharm SSH Server!
Type 'exit' to disconnect
$ python --version
Python 3.11.5

$ git status
On branch master
Your branch is up to date with 'origin/master'.

$ exit
Goodbye!
Connection to localhost closed.
```

## Remote Agent Commands

Useful commands for agent coordination:

```bash
# Check agent feed
$ tail -5 docs/agent-feed.jsonl

# Run Python tests
$ python -m pytest tests/

# Start PhiWave GUI
$ python phiwave_gui.py

# Git status
$ git status

# List files
$ ls -la
```

---

**Created:** 2025-10-25
**For:** Remote SSH access to PhiWave development environment
**Security Level:** Development only - not production-ready
