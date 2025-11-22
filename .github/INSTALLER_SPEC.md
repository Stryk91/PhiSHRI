# PhiSHRI One-Shot Installer Spec

## Goal
Single command installation that works on any Windows machine without prerequisites.

## User Experience

### Target
```powershell
# User runs this ONE command
irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex
```

### Output
```
PhiSHRI Installer v1.0
======================
[1/5] Detecting system... Windows 11 x64
[2/5] Downloading phishri-mcp.exe... done (2.3 MB)
[3/5] Creating directory structure... done
[4/5] Downloading knowledge base (500 doors)... done (15 MB)
[5/5] Configuring environment... done

Installation complete!

PhiSHRI installed to: C:\Users\<user>\.phishri\
MCP binary: C:\Users\<user>\.phishri\bin\phishri-mcp.exe
Doors: C:\Users\<user>\.phishri\doors\ (500 doors)

To use with Claude Desktop, add to claude_desktop_config.json:
{
  "mcpServers": {
    "phishri": {
      "command": "C:\\Users\\<user>\\.phishri\\bin\\phishri-mcp.exe",
      "env": { "PHISHRI_PATH": "C:\\Users\\<user>\\.phishri\\doors" }
    }
  }
}

Test: phishri-mcp --version
Docs: https://github.com/Stryk91/PhiSHRI
```

---

## Directory Structure (Post-Install)

```
C:\Users\<user>\.phishri\
├── bin\
│   └── phishri-mcp.exe          # MCP server binary
├── doors\
│   ├── INDEX.json               # Master catalog
│   ├── INDEXES\
│   │   ├── HASH_TABLE.json      # Door code mappings
│   │   └── SEMANTIC_MAP.json    # Alias mappings
│   └── CONTEXTS\
│       ├── WORKFLOWS\           # 205 doors
│       ├── TOOLS\               # 81 doors
│       ├── SECURITY\            # 55 doors
│       ├── LANGUAGES\           # 50 doors
│       ├── ARCHITECTURE\        # 45 doors
│       ├── ERRORS\              # 23 doors
│       ├── AGENTS\              # 19 doors
│       └── PROJECTS\            # 6 doors
├── sessions\                    # Bootstrap files go here
│   └── .gitkeep
├── config.json                  # User config (optional)
└── VERSION                      # Installed version marker
```

---

## Install Script Logic (PowerShell)

```powershell
# install.ps1

$ErrorActionPreference = "Stop"
$Version = "1.0.0"
$InstallDir = "$env:USERPROFILE\.phishri"
$BinDir = "$InstallDir\bin"
$DoorsDir = "$InstallDir\doors"
$GithubRepo = "Stryk91/PhiSHRI"
$McpRepo = "Stryk91/PhiSHRI_MCP"  # Or wherever the binary release is

Write-Host "PhiSHRI Installer v$Version" -ForegroundColor Cyan
Write-Host "=" * 30

# 1. Detect system
Write-Host "[1/5] Detecting system... " -NoNewline
$arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
Write-Host "Windows $arch" -ForegroundColor Green

# 2. Download MCP binary
Write-Host "[2/5] Downloading phishri-mcp.exe... " -NoNewline
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$mcpUrl = "https://github.com/$McpRepo/releases/latest/download/phishri-mcp-windows-$arch.exe"
Invoke-WebRequest -Uri $mcpUrl -OutFile "$BinDir\phishri-mcp.exe"
Write-Host "done" -ForegroundColor Green

# 3. Create directory structure
Write-Host "[3/5] Creating directory structure... " -NoNewline
New-Item -ItemType Directory -Force -Path "$InstallDir\sessions" | Out-Null
Write-Host "done" -ForegroundColor Green

# 4. Download doors
Write-Host "[4/5] Downloading knowledge base... " -NoNewline
$zipUrl = "https://github.com/$GithubRepo/archive/refs/heads/main.zip"
$tempZip = "$env:TEMP\phishri-doors.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip
Expand-Archive -Path $tempZip -DestinationPath $env:TEMP -Force
Move-Item -Path "$env:TEMP\PhiSHRI-main\PhiSHRI" -Destination $DoorsDir -Force
Remove-Item -Path $tempZip -Force
Remove-Item -Path "$env:TEMP\PhiSHRI-main" -Recurse -Force
Write-Host "done (500 doors)" -ForegroundColor Green

# 5. Configure environment
Write-Host "[5/5] Configuring environment... " -NoNewline
# Add to PATH (user level)
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$BinDir", "User")
}
# Set PHISHRI_PATH
[Environment]::SetEnvironmentVariable("PHISHRI_PATH", $DoorsDir, "User")
# Write version file
$Version | Out-File -FilePath "$InstallDir\VERSION" -Encoding UTF8
Write-Host "done" -ForegroundColor Green

# Output success
Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "PhiSHRI installed to: $InstallDir"
Write-Host "MCP binary: $BinDir\phishri-mcp.exe"
Write-Host "Doors: $DoorsDir (500 doors)"
Write-Host ""
Write-Host "To use with Claude Desktop, add to claude_desktop_config.json:"
$configJson = @"
{
  "mcpServers": {
    "phishri": {
      "command": "$($BinDir -replace '\\', '\\\\')\phishri-mcp.exe",
      "env": { "PHISHRI_PATH": "$($DoorsDir -replace '\\', '\\\\')" }
    }
  }
}
"@
Write-Host $configJson -ForegroundColor Yellow
Write-Host ""
Write-Host "Test: phishri-mcp --version"
Write-Host "Docs: https://github.com/$GithubRepo"
```

---

## Release Artifacts Needed

### GitHub Release (PhiSHRI_MCP repo):
```
phishri-mcp-v1.0.0-windows-x64.exe
phishri-mcp-v1.0.0-windows-x86.exe
phishri-mcp-v1.0.0-linux-x64
phishri-mcp-v1.0.0-darwin-x64
phishri-mcp-v1.0.0-darwin-arm64
```

### Build commands:
```bash
# Windows
cargo build --release --target x86_64-pc-windows-msvc
cargo build --release --target i686-pc-windows-msvc

# Linux
cargo build --release --target x86_64-unknown-linux-gnu

# macOS
cargo build --release --target x86_64-apple-darwin
cargo build --release --target aarch64-apple-darwin
```

---

## Uninstall Script

```powershell
# uninstall.ps1
$InstallDir = "$env:USERPROFILE\.phishri"

Write-Host "Removing PhiSHRI..." -NoNewline
Remove-Item -Path $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
[Environment]::SetEnvironmentVariable("PHISHRI_PATH", $null, "User")
Write-Host "done" -ForegroundColor Green
Write-Host "PhiSHRI has been uninstalled."
```

---

## Testing Checklist

- [ ] Fresh Windows 10 VM - install from scratch
- [ ] Fresh Windows 11 VM - install from scratch
- [ ] Verify phishri-mcp.exe runs without Visual C++ runtime errors
- [ ] Verify Claude Desktop integration works
- [ ] Verify all 500 doors accessible via MCP
- [ ] Test uninstall leaves no artifacts
- [ ] Test reinstall over existing installation

---

## Future: GUI Installer (Optional)

If PowerShell one-liner isn't friendly enough:
- Inno Setup or NSIS for .exe installer
- Wizard UI with progress bar
- Desktop shortcut option
- Start menu entry
- Associate .phishri file extension

---

## Priority

1. **MVP:** PowerShell script that works (this doc)
2. **v1.1:** Cross-platform bash script for Linux/Mac
3. **v1.2:** GUI installer for non-technical users
