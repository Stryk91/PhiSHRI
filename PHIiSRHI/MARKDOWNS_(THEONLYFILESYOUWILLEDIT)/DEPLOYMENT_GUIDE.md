# AI Response Capture System - Deployment Guide

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [Security Considerations](#security-considerations)
6. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Windows 11 Host
- Windows 11 (build 22000 or later)
- Windows Terminal 1.23.12811.0 or later
- Administrator privileges
- PowerShell 5.1 or PowerShell 7+

### WSL2 (Kali Linux)
- WSL2 enabled
- Kali Linux distribution installed
- Root access via sudo
- Minimum 2GB free disk space

### Required Tools

**Windows:**
- PowerShell (built-in)
- Python 3.8+ (optional, for unified manager)

**WSL2/Kali:**
- tcpdump
- iptables
- strace
- jq
- tshark
- python3
- bpftrace (optional, for eBPF)

---

## Installation

### Step 1: Install Prerequisites on WSL2

```bash
# Update package list
sudo apt update

# Install required tools
sudo apt install -y tcpdump iptables strace jq tshark python3 python3-pip

# Optional: Install eBPF tools for advanced capture
sudo apt install -y bpftrace bpfcc-tools linux-headers-$(uname -r)

# Verify installations
tcpdump --version
tshark --version
python3 --version
```

### Step 2: Set Up Capture Directory

From WSL2:

```bash
# Navigate to PhiLaunch directory
cd /home/user/PhiLaunch

# Verify ai_capture directory exists
ls -la ai_capture/

# Set proper permissions
sudo chown -R $USER:$USER ai_capture/
chmod 755 ai_capture/capture_engine/*.sh
chmod 755 ai_capture/capture_engine/*.py
chmod 755 ai_capture/tools/*.py

# Create storage directories
mkdir -p ai_capture/storage/{raw,parsed}
chmod 700 ai_capture/storage  # Secure storage
```

### Step 3: Configure PowerShell Execution Policy (Windows)

From Windows Terminal (PowerShell as Administrator):

```powershell
# Allow PowerShell script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Navigate to WSL directory (adjust path to your Windows user)
cd \\wsl$\Debian\home\user\PhiLaunch\ai_capture\capture_engine

# Verify script exists
ls pty_interceptor.ps1
```

---

## Configuration

### Edit Capture Configuration

```bash
# Edit main config
nano ai_capture/config/capture_config.yaml

# Edit filters
nano ai_capture/config/filters.yaml
```

### Key Configuration Options

**capture_config.yaml:**

```yaml
# Enable/disable capture engines
engines:
  pty_capture:
    enabled: true
  kernel_capture:
    enabled: true
  network_capture:
    enabled: true

# Set retention period
storage:
  retention:
    days: 7
    auto_cleanup: true

# Security settings
security:
  local_only: true
  allow_external_network: false
  require_admin: true
```

### SSL Key Logging (Optional)

To capture and decrypt HTTPS traffic:

```bash
# In WSL2, add to ~/.bashrc
echo 'export SSLKEYLOGFILE=/home/user/PhiLaunch/ai_capture/storage/raw/sslkeys.log' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $SSLKEYLOGFILE
```

This will log SSL/TLS keys for decryption in Wireshark.

---

## Usage

### Method 1: Unified Capture (Recommended)

Run the unified Python orchestrator that manages all capture layers:

```bash
# Start unified capture
sudo python3 ai_capture/capture_engine/unified_capture.py -v

# Options:
#   -v              Verbose output
#   --no-pty        Disable PTY capture
#   --no-kernel     Disable kernel capture
#   --status        Show status

# Stop: Press Ctrl+C
```

### Method 2: Individual Capture Engines

#### A. Windows Terminal PTY Capture

From Windows Terminal (PowerShell as Administrator):

```powershell
# Navigate to capture engine directory
cd \\wsl$\Debian\home\user\PhiLaunch\ai_capture\capture_engine

# Run PTY interceptor
.\pty_interceptor.ps1 -Verbose

# Stop: Press Ctrl+C
```

#### B. WSL2 Kernel Capture

From WSL2 terminal:

```bash
# Run kernel probe
sudo ai_capture/capture_engine/kernel_probe.sh

# Stop: Press Ctrl+C
```

### View Captured Data

#### List All Captures

```bash
# View list of all capture sessions
python3 ai_capture/tools/viewer.py list
```

#### View Specific Session

```bash
# View most recent capture (AI responses only)
python3 ai_capture/tools/viewer.py view

# View by session ID
python3 ai_capture/tools/viewer.py view -s abc123def456

# View by index (from list)
python3 ai_capture/tools/viewer.py view -i 1

# View all entries (not just AI responses)
python3 ai_capture/tools/viewer.py view -a

# Limit entries
python3 ai_capture/tools/viewer.py view -m 50
```

#### Search Captures

```bash
# Search for specific text
python3 ai_capture/tools/viewer.py search -q "claude"

# Case-sensitive search
python3 ai_capture/tools/viewer.py search -q "Response" -c
```

### Analyze Captured Data

```bash
# Analyze all captures
python3 ai_capture/tools/analyzer.py --all

# Analyze specific session
python3 ai_capture/tools/analyzer.py -s abc123def456
```

---

## Capture Workflow Example

### Scenario: Capture Claude AI Response in Windows Terminal

1. **Start Kernel Capture (WSL2)**

   ```bash
   # In WSL2 terminal
   sudo python3 ai_capture/capture_engine/unified_capture.py -v
   ```

2. **Interact with AI**

   ```bash
   # In another WSL2 terminal, use any AI tool
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: $ANTHROPIC_API_KEY" \
     -d '{"model": "claude-3-5-sonnet-20241022", "messages": [...]}'

   # Or use Claude CLI
   claude "Explain quantum computing"
   ```

3. **Stop Capture**

   ```bash
   # Press Ctrl+C in capture terminal
   ```

4. **View Results**

   ```bash
   # List captures
   python3 ai_capture/tools/viewer.py list

   # View latest
   python3 ai_capture/tools/viewer.py view

   # Search for specific content
   python3 ai_capture/tools/viewer.py search -q "quantum"
   ```

---

## Security Considerations

### 1. Data Encryption

All captured data is stored locally with restricted permissions:

```bash
# Verify storage permissions
ls -la ai_capture/storage/
# Should show: drwx------ (700)

# Captured files should be readable only by owner
chmod 600 ai_capture/storage/raw/*
```

### 2. Network Isolation

The system is designed for **LAN-only** operation:

```yaml
# In capture_config.yaml
security:
  local_only: true
  allow_external_network: false
```

### 3. Sensitive Data Filtering

Sensitive patterns are automatically excluded:

```yaml
# In filters.yaml
filters:
  exclude:
    - "password"
    - "secret"
    - "token"
    - "api_key"
```

**Manual Review:**
Always review captured data before sharing:

```bash
# Search for potential secrets
python3 ai_capture/tools/viewer.py search -q "password"
python3 ai_capture/tools/viewer.py search -q "api_key"
```

### 4. Data Retention

Automatic cleanup prevents accumulation:

```yaml
storage:
  retention:
    days: 7
    auto_cleanup: true
```

Manual cleanup:

```bash
# Delete old captures
find ai_capture/storage/raw -name "*.jsonl" -mtime +7 -delete
find ai_capture/storage/raw -name "*.pcap" -mtime +7 -delete
```

### 5. Access Control

Limit access to capture system:

```bash
# Restrict directory access
sudo chown root:root ai_capture/capture_engine/kernel_probe.sh
sudo chmod 700 ai_capture/capture_engine/kernel_probe.sh

# Only allow sudo execution
sudo visudo
# Add: yourusername ALL=(ALL) NOPASSWD: /home/user/PhiLaunch/ai_capture/capture_engine/kernel_probe.sh
```

---

## Troubleshooting

### Issue 1: Permission Denied

**Error:**
```
[!] This script must be run as root
```

**Solution:**
```bash
# Run with sudo
sudo python3 ai_capture/capture_engine/unified_capture.py

# Or for kernel probe
sudo ai_capture/capture_engine/kernel_probe.sh
```

### Issue 2: tcpdump Not Found

**Error:**
```
tcpdump: command not found
```

**Solution:**
```bash
# Install tcpdump
sudo apt update
sudo apt install -y tcpdump
```

### Issue 3: No Captures Appearing

**Debug Steps:**

1. **Check if capture is running:**
   ```bash
   ps aux | grep -E "tcpdump|unified_capture|kernel_probe"
   ```

2. **Check output directory:**
   ```bash
   ls -la ai_capture/storage/raw/
   ```

3. **Verify network interface:**
   ```bash
   ip addr show
   # Look for eth0 or similar

   # Update in kernel_probe.sh if needed:
   CAPTURE_INTERFACE="eth0"  # Change to your interface
   ```

4. **Check for errors in log:**
   ```bash
   tail -f ai_capture/storage/raw/unified_*.log
   ```

### Issue 4: PowerShell Script Won't Run

**Error:**
```
pty_interceptor.ps1 cannot be loaded because running scripts is disabled
```

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify
Get-ExecutionPolicy
```

### Issue 5: No AI Responses Detected

**Possible Causes:**

1. **Filters too restrictive** - Edit `filters.yaml`
2. **Wrong network interface** - Check interface in config
3. **Encrypted traffic** - Set up SSLKEYLOGFILE

**Debug:**
```bash
# View all entries (not just AI responses)
python3 ai_capture/tools/viewer.py view -a

# Search broadly
python3 ai_capture/tools/viewer.py search -q "response"
```

### Issue 6: High Disk Usage

**Solution:**

```bash
# Check disk usage
du -sh ai_capture/storage/

# Reduce retention period in config:
# storage.retention.days: 7 -> 3

# Manual cleanup
find ai_capture/storage/raw -name "*.pcap" -mtime +1 -delete
```

---

## Advanced: Wireshark Decryption

To decrypt captured HTTPS traffic in Wireshark:

1. **Capture with SSL keys:**
   ```bash
   export SSLKEYLOGFILE=/home/user/PhiLaunch/ai_capture/storage/raw/sslkeys.log
   # Run your AI client
   ```

2. **Open in Wireshark:**
   ```bash
   # On Windows
   wireshark.exe \\wsl$\Debian\home\user\PhiLaunch\ai_capture\storage\raw\capture_*.pcap
   ```

3. **Configure Wireshark:**
   - Edit → Preferences → Protocols → TLS
   - (Pre-)Master-Secret log filename: Browse to `sslkeys.log`
   - Click OK

4. **View decrypted traffic:**
   - Right-click packet → Follow → HTTP Stream
   - Should show decrypted HTTPS content

---

## Support

For issues or questions:

1. Check logs: `ai_capture/storage/raw/*.log`
2. Review configuration: `ai_capture/config/*.yaml`
3. Test individual components separately
4. Check system requirements

---

## Security Notice

⚠️ **WARNING**: This tool captures sensitive data including AI responses and network traffic.

- Only use on your own systems
- Do not share captured data without review
- Ensure compliance with applicable laws and terms of service
- Keep captured data secure and encrypted
- Follow proper data retention policies

---

**Version:** 1.0
**Last Updated:** 2025-11-16
**Platform:** Windows 11 + WSL2 Kali Linux
