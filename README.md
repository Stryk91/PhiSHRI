# PhiSHRI

Semantic indexing for AI session continuity. Load context doors, resume work.

## Install

**Windows:**
```powershell
irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex
```

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash
```

## Usage

Restart Claude Desktop after install, then:
```
"What doors are available?"
"Find doors about deployment"
"Open door D05"
```

## Structure

```
PhiSHRI/
├── install.ps1      # Windows installer
├── install.sh       # Linux/macOS installer
├── mcp-server/      # Rust MCP server
└── PhiSHRI/CONTEXTS/  # 500+ knowledge doors
```

## Links

- [MCP Install Guide](https://github.com/Stryk91/PhiSHRI/blob/main/INSTALL_GUIDE.md)
- [MCP Server README](https://github.com/Stryk91/PhiSHRI/blob/main/PhiSHRI_MCP_README.md)

MIT License
