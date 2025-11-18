# AI Response Capture System

**Capture AI responses from Windows Terminal and WSL2 before kernel encryption**

---

## Quick Start

### 1. Install Prerequisites (WSL2)

```bash
sudo apt update
sudo apt install -y tcpdump iptables strace jq tshark python3
```

### 2. Start Capture

```bash
# Run unified capture system
sudo python3 ai_capture/capture_engine/unified_capture.py -v
```

### 3. Use AI Tools

In another terminal, interact with any AI service (Claude, ChatGPT, etc.)

### 4. View Results

```bash
# List captures
python3 ai_capture/tools/viewer.py list

# View latest capture
python3 ai_capture/tools/viewer.py view

# Search
python3 ai_capture/tools/viewer.py search -q "your query"

# Analyze
python3 ai_capture/tools/analyzer.py --all
```

---

## What Does It Do?

This system captures AI responses **before encryption** at multiple layers:

1. **PTY Layer** - Windows Terminal I/O streams (PowerShell)
2. **Kernel Layer** - WSL2 network/syscall tracing (eBPF/tcpdump)
3. **Network Layer** - Pre-TLS packet capture

### Architecture

```
Windows Terminal → ConPTY → WSL2 Bridge → Kali Linux → AI Service
       ↓              ↓           ↓              ↓
    [Capture 1]  [Capture 2]  [Capture 3]   [Storage]
```

---

## Features

✅ Multi-layer capture (PTY, kernel, network)
✅ Pre-encryption interception
✅ AI response detection and filtering
✅ Automatic sensitive data filtering
✅ JSON-based storage with metadata
✅ Analysis and search tools
✅ Auto-cleanup and retention policies
✅ LAN-only, no external uploads

---

## System Components

### Capture Engines

- **`pty_interceptor.ps1`** - Windows Terminal PTY capture (PowerShell)
- **`kernel_probe.sh`** - WSL2 kernel capture (Bash + tcpdump + eBPF)
- **`unified_capture.py`** - Unified orchestration (Python)

### Tools

- **`viewer.py`** - View and search captured data
- **`analyzer.py`** - Statistics and analysis

### Configuration

- **`capture_config.yaml`** - Main configuration
- **`filters.yaml`** - Capture filters and patterns

---

## Directory Structure

```
ai_capture/
├── capture_engine/
│   ├── pty_interceptor.ps1        # Windows PTY capture
│   ├── kernel_probe.sh            # WSL2 kernel capture
│   └── unified_capture.py         # Orchestration
├── storage/
│   ├── raw/                       # Raw captures (JSONL + PCAP)
│   └── parsed/                    # Parsed JSON
├── config/
│   ├── capture_config.yaml        # Configuration
│   └── filters.yaml               # Filters
├── tools/
│   ├── viewer.py                  # Viewer
│   └── analyzer.py                # Analyzer
├── DEPLOYMENT_GUIDE.md            # Full deployment guide
└── README.md                      # This file
```

---

## Usage Examples

### Capture Claude Response

```bash
# Terminal 1: Start capture
sudo python3 ai_capture/capture_engine/unified_capture.py -v

# Terminal 2: Use Claude
claude "Explain quantum entanglement"

# Terminal 1: Stop capture (Ctrl+C)

# View results
python3 ai_capture/tools/viewer.py view
```

### Search for Specific Content

```bash
# Search all captures
python3 ai_capture/tools/viewer.py search -q "quantum"

# Case-sensitive search
python3 ai_capture/tools/viewer.py search -q "Claude" -c
```

### Analyze Captures

```bash
# Full analysis
python3 ai_capture/tools/analyzer.py --all

# Specific session
python3 ai_capture/tools/analyzer.py -s abc123def456
```

---

## Configuration

Edit `config/capture_config.yaml`:

```yaml
# Enable/disable capture layers
engines:
  pty_capture: true
  kernel_capture: true
  network_capture: true

# Data retention
storage:
  retention:
    days: 7
    auto_cleanup: true

# Security
security:
  local_only: true
  require_admin: true
```

---

## Security

🔒 **LAN Only** - No external network access
🔒 **Encrypted Storage** - AES-256-GCM
🔒 **Auto-Filter** - Excludes passwords, API keys, secrets
🔒 **Restricted Access** - File permissions 0600
🔒 **Auto-Cleanup** - 7-day retention by default

---

## Requirements

### Windows 11
- Windows Terminal 1.23.12811.0+
- Administrator privileges
- PowerShell 5.1+

### WSL2 Kali Linux
- tcpdump, iptables, tshark
- Python 3.8+
- Root access (sudo)

---

## Troubleshooting

**Permission denied?**
```bash
sudo python3 ai_capture/capture_engine/unified_capture.py
```

**No captures appearing?**
```bash
# Check logs
tail -f ai_capture/storage/raw/*.log

# Verify interface
ip addr show
```

**PowerShell script won't run?**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for full troubleshooting guide.

---

## Documentation

- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Complete installation and configuration
- **[Architecture](AI_RESPONSE_CAPTURE_ARCHITECTURE.md)** - System design and schematics

---

## Command Reference

### Capture Commands

```bash
# Start unified capture
sudo python3 ai_capture/capture_engine/unified_capture.py -v

# Start kernel capture only
sudo ai_capture/capture_engine/kernel_probe.sh

# Start PTY capture only (Windows PowerShell)
.\ai_capture\capture_engine\pty_interceptor.ps1 -Verbose
```

### Viewer Commands

```bash
# List all captures
python3 ai_capture/tools/viewer.py list

# View latest
python3 ai_capture/tools/viewer.py view

# View by session ID
python3 ai_capture/tools/viewer.py view -s SESSION_ID

# View by index
python3 ai_capture/tools/viewer.py view -i 1

# View all entries (not just AI responses)
python3 ai_capture/tools/viewer.py view -a

# Search
python3 ai_capture/tools/viewer.py search -q "query"
```

### Analyzer Commands

```bash
# Analyze all
python3 ai_capture/tools/analyzer.py --all

# Analyze specific session
python3 ai_capture/tools/analyzer.py -s SESSION_ID
```

---

## License

This tool is for authorized security research and development only.

⚠️ **Use responsibly:**
- Only on your own systems
- Comply with applicable laws
- Respect AI service terms of service
- Secure captured data appropriately

---

## Author

Built for PhiLaunch project
Platform: Windows 11 + WSL2 Kali Linux
Target: Windows Terminal 1.23.12811.0

---

**Version:** 1.0
**Last Updated:** 2025-11-16
