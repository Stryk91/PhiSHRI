# PhiSHRI - Semantic Self-Hashing Radial Index

> v0.0.1 - Early Development

**AI session continuity via semantic door codes.** Load context, resume work, zero re-explanation.

---

## Install

### Windows
```powershell
irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex
```

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash
```

### GUI Installer (Download & Run)

| Platform | Download |
|----------|----------|
| **Windows** | [PhiSHRI-Installer.exe](https://github.com/Stryk91/PhiSHRI/releases/latest/download/PhiSHRI-Installer.exe) |
| **Linux** | [PhiSHRI-Installer.AppImage](https://github.com/Stryk91/PhiSHRI/releases/latest/download/PhiSHRI-Installer.AppImage) |
| **Linux (Debian)** | [PhiSHRI-Installer.deb](https://github.com/Stryk91/PhiSHRI/releases/latest/download/PhiSHRI-Installer.deb) |
| **macOS** | [PhiSHRI-Installer.dmg](https://github.com/Stryk91/PhiSHRI/releases/latest/download/PhiSHRI-Installer.dmg) |

---

## What It Does

PhiSHRI provides persistent context "doors" - JSON bundles your AI can load to resume work without re-explaining everything.

```
Session 1: "Help with deployment" -> AI reads D05, D06, D07 [12K tokens]
Session 2: "Resume"  -> AI Reads Index , AI picks up with every aspect of the last of any conversation it had with user without processing 50,000 Words [Fractional Tokens]
```

**500+ doors** across 8 categories. **60-75%% token reduction. Zero context drift.**

---

## Quick Start

After install, restart Claude Desktop. Then:

```
You: "What doors are available?"
You: "Find doors about deployment"
You: "Open door D05"
```

---

## Verify / Uninstall

**Windows:**
```powershell
.\install.ps1 -Verify
.\install.ps1 -Uninstall
```

**Linux/macOS:**
```bash
~/.phishri/bin/phishri-mcp --version
curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash -s -- --uninstall
```

---

## Links

- [MCP Server Repo](https://github.com/Stryk91/PhiSHRI_MCP) - Rust MCP implementation
- [Documentation](https://stryk91.github.io/PhiSHRI/)
- [Issues](https://github.com/Stryk91/PhiSHRI/issues)

---

## License

MIT - See [LICENSE](LICENSE)

---

**Contact:** PhiVector@pm.me | Discord: lordcain
