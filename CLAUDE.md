# PhiSHRI - Claude Code Bootstrap

## Project Overview
PhiSHRI (Phi-Symbol Human-Readable Intelligence) is an MCP (Model Context Protocol) server that provides a curated knowledge base of "doors" - structured JSON files containing technical documentation, patterns, and solutions.

## Current State (2025-11-22)
- **523 doors** in knowledge base across CONTEXTS categories
- **Tauri GUI installer** working in dev mode with hot-reload
- Version: **0.0.1**

## Repository Structure
```
PhiSRHI/
├── install.ps1          # Main PowerShell installer
├── uninstall.ps1        # Uninstaller script
├── CONTEXTS/            # Knowledge base doors (523 JSON files)
│   ├── development/
│   ├── security/
│   ├── automation/
│   └── ...
├── gui/                 # Tauri v2 GUI installer (NEW)
│   ├── src/             # Frontend (HTML/CSS/JS)
│   ├── src-tauri/       # Rust backend
│   └── package.json
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
```powershell
# Install PhiSHRI (PowerShell)
irm https://phishri.dev/install | iex

# Run GUI dev mode
cd gui && npm run tauri dev

# Build GUI release
cd gui && npm run tauri build
```

## Installation Paths
- Root: `~/.phishri/`
- Binary: `~/.phishri/bin/phishri-mcp.exe`
- Knowledge: `~/.phishri/knowledge/CONTEXTS/`

## Next Steps
- [ ] Build release version of GUI installer
- [ ] Create GitHub release with .msi/.exe
- [ ] Add GUI installer link to README
- [ ] Consider custom app icon (currently placeholder Phi symbol)
