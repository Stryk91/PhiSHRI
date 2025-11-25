# PhiSHRI MCP Server

Semantic knowledge base for AI session continuity. Access 450+ context "doors" to maintain state across sessions.

## Quick Install

**One-liner (recommended):**
```powershell
irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex
```

This downloads the pre-built binary + knowledge base and configures Claude Desktop automatically.

**GUI Installer:**
Download from [Releases](https://github.com/Stryk91/PhiSHRI/releases) and run the installer.

**Other methods:**
- mcpb (MCP Builder)
- DXT extension package
- Manual configuration

See [Installation Guide](https://stryk91.github.io/PhiSHRI/) for all options.

---

## What It Does

PhiSHRI provides persistent context "doors" - JSON bundles your AI can load to resume work without re-explaining everything.

```
"Open door T01" → Loads MCP development context
"Open door E05" → Loads retry/error handling patterns
"Open door S01" → Loads security best practices
```

**450+ doors** across 8 categories: Security, Workflows, Architecture, Tools, Agents, Projects, Errors, Deployment.

## Why Use It

| Without PhiSHRI | With PhiSHRI |
|-----------------|--------------|
| Re-explain project context every session | Load door, continue where you left off |
| Waste tokens on repetitive setup | Pre-built context bundles |
| Context drift over long projects | Persistent semantic anchors |
| Each agent starts fresh | Shared knowledge base |

## Tools Available

Once installed, your AI has access to:

| Tool | Purpose |
|------|---------|
| `open_door` | Load a specific context door |
| `search_doors` | Find relevant doors by keyword |
| `list_categories` | Browse available categories |
| `save_session` | Checkpoint current progress |
| `load_session` | Resume from checkpoint |

## Building From Source

Only if you need to modify the server:

```bash
git clone https://github.com/Stryk91/PhiSHRI_MCP
cd PhiSHRI_MCP
cargo build --release
```

Binary outputs to `target/release/phishri-mcp.exe`

## Links

- [Main Repo](https://github.com/Stryk91/PhiSHRI) - Knowledge base + installers
- [Documentation](https://stryk91.github.io/PhiSHRI/)
- [Issues](https://github.com/Stryk91/PhiSHRI/issues)

## License

MIT
