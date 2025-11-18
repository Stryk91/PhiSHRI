# AI Response Capture System - Architecture & Implementation Guide

## Overview
This system captures AI responses in WSL2/Windows 11 environments **before kernel-level encryption**, focusing on Terminal 1.23.12811.0 communication between Kali Linux WSL and VS Code.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     WINDOWS 11 HOST                              │
│                                                                   │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │  Windows Terminal│◄────────┤   VS Code        │              │
│  │  (1.23.12811.0)  │         │   Terminal       │              │
│  └────────┬─────────┘         └────────┬─────────┘              │
│           │                             │                        │
│           │ PTY/ConPTY                 │ PTY/ConPTY            │
│           ▼                             ▼                        │
│  ┌─────────────────────────────────────────────────┐            │
│  │        CAPTURE LAYER 1: PTY Interceptor         │            │
│  │  (Hooks ConPTY before TLS/encryption)           │            │
│  └─────────────────┬───────────────────────────────┘            │
│                    │                                             │
│                    ▼                                             │
│  ┌─────────────────────────────────────────────────┐            │
│  │     WSL2 HyperV-Socket Bridge (9P/vsock)        │            │
│  └─────────────────┬───────────────────────────────┘            │
│                    │                                             │
│  ┌─────────────────▼───────────────────────────────┐            │
│  │  CAPTURE LAYER 2: Network Bridge Tap            │            │
│  │  (vEthernet WSL - before encryption)            │            │
│  └─────────────────┬───────────────────────────────┘            │
└────────────────────┼─────────────────────────────────────────────┘
                     │
         ┌───────────▼──────────┐
         │   WSL2 INSTANCE      │
         │   (Kali Linux)       │
         │                      │
         │  ┌────────────────┐  │
         │  │  CAPTURE LAYER │  │
         │  │  3: Kernel Tap │  │
         │  │  (eBPF/iptables)│  │
         │  └────────────────┘  │
         │          │           │
         │          ▼           │
         │  ┌────────────────┐  │
         │  │  AI Client     │  │
         │  │  Process       │  │
         │  └────────────────┘  │
         └──────────────────────┘
                     │
                     ▼
         ┌────────────────────┐
         │  STORAGE LAYER     │
         │  - Raw captures    │
         │  - Parsed JSON     │
         │  - Metadata DB     │
         └────────────────────┘
```

## Capture Layers

### Layer 1: PTY/ConPTY Interceptor (Windows Terminal)
**Location**: Windows 11 Host
**Capture Point**: Before TLS/SSL encryption
**Method**: DLL injection or ETW (Event Tracing for Windows)

**Implementation**:
- Hooks `ConPTY` API calls
- Intercepts `ReadConsoleOutputCharacterW` and `WriteConsoleInputW`
- Captures raw terminal I/O streams

### Layer 2: WSL2 Network Bridge Tap
**Location**: Hyper-V vSwitch (vEthernet WSL)
**Capture Point**: Pre-encryption network layer
**Method**: Packet capture on virtual network adapter

**Implementation**:
- Captures packets on `vEthernet (WSL)` adapter
- Filters traffic to/from WSL2 VM
- Extracts payloads before TLS handshake

### Layer 3: WSL2 Kernel-Level Capture
**Location**: Inside WSL2 (Kali Linux)
**Capture Point**: Application layer, pre-encryption
**Method**: eBPF probes, iptables, ptrace

**Implementation**:
- eBPF probes on socket send/recv
- LD_PRELOAD hooks for libc functions
- Process-level syscall tracing

## Implementation Priority

**Focus**: Layer 1 (Terminal I/O Capture) - Simplest and most reliable

## Technical Specifications

### Capture Requirements
- **Latency**: < 10ms overhead
- **Storage**: Rotating logs, max 10GB
- **Format**: JSON with metadata + raw binary
- **Encryption**: AES-256 for stored data
- **LAN Only**: No external network access

### Data Structure
```json
{
  "timestamp": "2025-11-16T12:34:56.789Z",
  "capture_layer": "PTY",
  "direction": "output",
  "process": {
    "pid": 12345,
    "name": "bash",
    "cmdline": "/bin/bash"
  },
  "terminal": {
    "type": "Windows Terminal",
    "version": "1.23.12811.0",
    "session_id": "abc123"
  },
  "data": {
    "raw": "base64_encoded_content",
    "decoded": "actual text content",
    "length": 1024
  },
  "metadata": {
    "source_ip": "172.28.144.1",
    "dest_ip": "172.28.159.23",
    "protocol": "vsock",
    "encrypted": false
  }
}
```

## Security Considerations

1. **Local Only**: All capture stays on LAN, no cloud uploads
2. **Encryption**: Captured data encrypted at rest
3. **Access Control**: Admin-only file permissions
4. **Audit Trail**: All access logged
5. **Retention Policy**: Auto-delete after 7 days

## File Structure

```
/home/user/PhiLaunch/
├── ai_capture/
│   ├── capture_engine/
│   │   ├── pty_interceptor.ps1        # Windows PTY capture
│   │   ├── wsl2_bridge_tap.sh         # Network bridge capture
│   │   ├── kernel_probe.sh            # eBPF/iptables capture
│   │   └── unified_capture.py         # Orchestration
│   ├── storage/
│   │   ├── raw/                       # Raw binary captures
│   │   ├── parsed/                    # Parsed JSON
│   │   └── metadata.db                # SQLite metadata
│   ├── config/
│   │   ├── capture_config.yaml        # Configuration
│   │   └── filters.yaml               # Capture filters
│   └── tools/
│       ├── viewer.py                  # Capture viewer
│       ├── analyzer.py                # Analysis tools
│       └── exporter.py                # Export utilities
```

## Next Steps

1. ✅ Architecture design complete
2. ⏳ Implement Layer 1: PTY Interceptor
3. ⏳ Implement storage layer
4. ⏳ Create management tools
5. ⏳ Write deployment guide
