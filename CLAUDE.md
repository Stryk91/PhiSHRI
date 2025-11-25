# PhiSHRI - Claude Code Bootstrap

## Project Overview
PhiSHRI (Phi-Symbol Semantic Hashing Radial Index) is an MCP (Model Context Protocol) server that provides a curated knowledge base of "doors" - structured JSON files containing technical documentation, patterns, and solutions.

## Current State (2025-11-25)
- **523 doors** in knowledge base across CONTEXTS categories
- **Tauri GUI installer** working in dev mode with hot-reload
- **Single repo** containing both knowledge base and MCP server source
- Version: **0.0.1**

## Repository Structure
```
PhiSHRI/
├── install.ps1          # Windows installer
├── install.sh           # Linux/macOS installer
├── mcp-server/          # Rust MCP server source
│   ├── src/
│   └── Cargo.toml
├── gui/                 # Tauri v2 GUI installer
│   ├── src/             # Frontend (HTML/CSS/JS)
│   ├── src-tauri/       # Rust backend
│   └── package.json
├── PhiSHRI/             # Knowledge base
│   └── CONTEXTS/        # 523 JSON door files
└── schema/              # Door JSON schemas
```

## GUI Installer Status
- **Framework**: Tauri v2 with Vite frontend
- **Location**: `gui/` folder
- **Dev command**: `cd gui && npm run tauri dev`
- **Port**: 1420 (Vite dev server)

### Recent Fixes Applied
1. `tauri::Emitter` trait import (v2 changed from Manager)
2. Shell plugin config (removed `scope`, using `open: true`)
3. Vite `root: 'src'` for correct index.html location
4. HTML entity escaping (`&lt;`) in ASCII art
5. Generated all platform icons via `npx tauri icon`

### Dependencies
- GUI downloads `install.ps1` from GitHub at runtime
- Not standalone - wraps the existing PowerShell installer

## Key Commands
```bash
# Install PhiSHRI (Linux/macOS)
curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash

# Install PhiSHRI (Windows PowerShell)
irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex

# Run GUI dev mode
cd gui && npm run tauri dev

# Build GUI release
cd gui && npm run tauri build

# Build MCP server from source
cd mcp-server && cargo build --release
```

## Installation Paths
- Root: `~/.phishri/`
- Binary: `~/.phishri/bin/phishri-mcp` (Linux/macOS) or `phishri-mcp.exe` (Windows)
- Knowledge: `~/.phishri/knowledge/CONTEXTS/`

## Next Steps
- [ ] Build Windows .exe and macOS GUI installers
- [ ] Add Windows/macOS GUI links to releases
- [ ] Consider custom app icon (currently placeholder Phi symbol)
