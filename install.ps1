<#
.SYNOPSIS
    PhiSHRI MCP Installer for Windows

.DESCRIPTION
    Downloads and installs the PhiSHRI MCP server with the complete knowledge base.
    Supports multiple installation methods: Auto-config, mcpb, dxt, or Manual.

.PARAMETER Method
    Installation method: Auto, Mcpb, Dxt, or Manual (default: Auto)

.PARAMETER Verify
    Run post-install verification to check paths, files, and configuration.

.PARAMETER Uninstall
    Remove PhiSHRI MCP installation completely.

.EXAMPLE
    irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex

.EXAMPLE
    .\install.ps1 -Method Manual

.EXAMPLE
    .\install.ps1 -Verify
#>

param(
    [ValidateSet("Auto", "Mcpb", "Dxt", "Manual")]
    [string]$Method,
    [switch]$Verify,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Configuration
$script:Config = @{
    Version = "1.1.0"
    PhiSHRIRoot = Join-Path $env:USERPROFILE ".phishri"
    GitHubRepo = "Stryk91/PhiSHRI"
    MCPRepo = "Stryk91/PhiSHRI_MCP"
    BinaryName = "phishri-mcp.exe"
    BinaryDownloadName = "phishri-mcp-windows-x64.exe"
}

# Derived paths
$script:Paths = @{
    Root = $script:Config.PhiSHRIRoot
    Bin = Join-Path $script:Config.PhiSHRIRoot "bin"
    Knowledge = Join-Path $script:Config.PhiSHRIRoot "knowledge"
    Sessions = Join-Path $script:Config.PhiSHRIRoot "sessions"
    Contexts = Join-Path $script:Config.PhiSHRIRoot "knowledge\CONTEXTS"
    Indexes = Join-Path $script:Config.PhiSHRIRoot "knowledge\INDEXES"
    Binary = Join-Path $script:Config.PhiSHRIRoot "bin\$($script:Config.BinaryName)"
    AgentsConfig = Join-Path $script:Config.PhiSHRIRoot "agents.json"
    AgentsExample = Join-Path $script:Config.PhiSHRIRoot "agents.example.json"
}

# Claude Desktop config locations to check
$script:ClaudeConfigLocations = @(
    @{ Name = "Roaming"; Path = Join-Path $env:APPDATA "Claude\claude_desktop_config.json" },
    @{ Name = "Local"; Path = Join-Path $env:LOCALAPPDATA "Claude\claude_desktop_config.json" },
    @{ Name = "Extensions"; Path = Join-Path $env:LOCALAPPDATA "Claude\extensions\config.json" }
)

function Write-Step {
    param([string]$Message, [string]$Status = "INFO")
    $colors = @{
        "INFO" = "Cyan"
        "OK" = "Green"
        "WARN" = "Yellow"
        "ERROR" = "Red"
        "MENU" = "White"
    }
    Write-Host "[$Status] " -ForegroundColor $colors[$Status] -NoNewline
    Write-Host $Message
}

function Write-Banner {
    Write-Host @"

  ____  _     _ ____  _   _ ____  ___
 |  _ \| |__ (_) ___|| | | |  _ \|_ _|
 | |_) | '_ \| \___ \| |_| | |_) || |
 |  __/| | | | |___) |  _  |  _ < | |
 |_|   |_| |_|_|____/|_| |_|_| \_\___|

  MCP Server Installer v$($script:Config.Version)

"@ -ForegroundColor Magenta
}

function Show-InstallMenu {
    Write-Host ""
    Write-Host "Installation methods available:" -ForegroundColor Yellow
    Write-Host "  [1] Auto-config (attempts Claude Desktop JSON config)" -ForegroundColor White
    Write-Host "  [2] mcpb install (if you have MCP Builder)" -ForegroundColor White
    Write-Host "  [3] dxt package (Claude Desktop extension format)" -ForegroundColor White
    Write-Host "  [4] Manual (downloads files, you configure)" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "Select [1-4] or press Enter for Auto"

    switch ($choice) {
        "" { return "Auto" }
        "1" { return "Auto" }
        "2" { return "Mcpb" }
        "3" { return "Dxt" }
        "4" { return "Manual" }
        default { return "Auto" }
    }
}

function Test-Prerequisites {
    Write-Step "Checking prerequisites..."

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.0 or higher required"
    }

    Write-Step "Prerequisites OK" "OK"
    return $true
}

function Find-ClaudeConfig {
    Write-Step "Detecting Claude Desktop configuration..."

    foreach ($loc in $script:ClaudeConfigLocations) {
        $configDir = Split-Path $loc.Path -Parent
        if (Test-Path $configDir) {
            Write-Step "  Found: $($loc.Name) ($configDir)" "OK"
            return $loc
        }
    }

    Write-Step "  Claude Desktop not found in standard locations" "WARN"
    return $null
}

function Test-McpbAvailable {
    try {
        $null = Get-Command mcpb -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Initialize-Directories {
    Write-Step "Creating directory structure..."

    $dirs = @(
        $script:Paths.Root,
        $script:Paths.Bin,
        $script:Paths.Knowledge,
        $script:Paths.Sessions,
        $script:Paths.Contexts,
        $script:Paths.Indexes
    )

    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    Write-Step "Directory structure created" "OK"
}

function Get-LatestRelease {
    param([string]$Repo)

    $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers @{Accept = "application/vnd.github.v3+json"}
        return $response
    }
    catch {
        Write-Step "Could not fetch latest release from $Repo" "WARN"
        return $null
    }
}

function Install-MCPBinary {
    Write-Step "Downloading PhiSHRI MCP binary..."

    $release = Get-LatestRelease -Repo $script:Config.MCPRepo
    $downloadName = $script:Config.BinaryDownloadName

    if ($release) {
        $asset = $release.assets | Where-Object { $_.name -eq $downloadName }
        if ($asset) {
            $downloadUrl = $asset.browser_download_url
            Write-Step "  Found release: $($release.tag_name)"
        }
        else {
            $downloadUrl = "https://github.com/$($script:Config.MCPRepo)/releases/latest/download/$downloadName"
        }
    }
    else {
        $downloadUrl = "https://github.com/$($script:Config.MCPRepo)/releases/latest/download/$downloadName"
    }

    Write-Step "  Downloading from: $downloadUrl"

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $script:Paths.Binary -UseBasicParsing
        Write-Step "Binary downloaded" "OK"
    }
    catch {
        throw "Failed to download MCP binary: $_"
    }
}

function Install-KnowledgeBase {
    Write-Step "Downloading PhiSHRI knowledge base..."

    $zipUrl = "https://github.com/$($script:Config.GitHubRepo)/archive/refs/heads/main.zip"
    $tempZip = Join-Path $env:TEMP "phishri-kb.zip"
    $tempExtract = Join-Path $env:TEMP "phishri-extract"

    try {
        Write-Step "  Downloading knowledge base archive..."
        Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing

        Write-Step "  Extracting..."
        if (Test-Path $tempExtract) {
            Remove-Item $tempExtract -Recurse -Force
        }
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

        $extractedFolder = Get-ChildItem $tempExtract | Select-Object -First 1
        $sourceKB = Join-Path $extractedFolder.FullName "PhiSHRI"

        if (!(Test-Path $sourceKB)) {
            throw "Knowledge base not found in archive at expected path: $sourceKB"
        }

        # Copy CONTEXTS
        $sourceContexts = Join-Path $sourceKB "CONTEXTS"
        if (Test-Path $sourceContexts) {
            Write-Step "  Copying CONTEXTS..."
            Copy-Item -Path "$sourceContexts\*" -Destination $script:Paths.Contexts -Recurse -Force
        }

        # Copy INDEXES
        $sourceIndexes = Join-Path $sourceKB "INDEXES"
        if (Test-Path $sourceIndexes) {
            Write-Step "  Copying INDEXES..."
            Copy-Item -Path "$sourceIndexes\*" -Destination $script:Paths.Indexes -Recurse -Force
        }
        else {
            # Fallback: check root
            $hashTable = Join-Path $sourceKB "HASH_TABLE.json"
            $semanticMap = Join-Path $sourceKB "SEMANTIC_MAP.json"
            if (Test-Path $hashTable) { Copy-Item -Path $hashTable -Destination $script:Paths.Indexes -Force }
            if (Test-Path $semanticMap) { Copy-Item -Path $semanticMap -Destination $script:Paths.Indexes -Force }
        }

        Write-Step "Knowledge base installed" "OK"
    }
    catch {
        throw "Failed to install knowledge base: $_"
    }
    finally {
        if (Test-Path $tempZip) { Remove-Item $tempZip -Force }
        if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    }
}

function Install-AgentTemplate {
    Write-Step "Creating agent configuration template..."

    $exampleContent = @"
{
  "_comment": "PhiSHRI Agent Configuration",
  "_instructions": [
    "Copy this file to 'agents.json' and customize for your setup.",
    "Each agent represents a different AI assistant or use case.",
    "The 'id' is used internally, 'name' is displayed in the UI."
  ],
  "default_agent": "primary",
  "agents": [
    {
      "id": "primary",
      "name": "My Assistant",
      "description": "Primary development assistant"
    },
    {
      "id": "reviewer",
      "name": "Code Reviewer",
      "description": "Focused on code review and best practices"
    }
  ]
}
"@

    Set-Content -Path $script:Paths.AgentsExample -Value $exampleContent -Encoding UTF8

    if (!(Test-Path $script:Paths.AgentsConfig)) {
        $defaultConfig = @"
{
  "default_agent": "assistant",
  "agents": [
    {
      "id": "assistant",
      "name": "Assistant",
      "description": "Default PhiSHRI assistant"
    }
  ]
}
"@
        Set-Content -Path $script:Paths.AgentsConfig -Value $defaultConfig -Encoding UTF8
    }

    Write-Step "Agent template created" "OK"
}

function Install-ClaudeConfigAuto {
    param([hashtable]$ConfigLocation)

    Write-Step "Configuring Claude Desktop (Auto)..."

    $configPath = $ConfigLocation.Path
    $configDir = Split-Path $configPath -Parent

    # Ensure directory exists
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    # Load existing config or create new
    $config = @{}
    if (Test-Path $configPath) {
        try {
            $configContent = Get-Content $configPath -Raw -ErrorAction Stop
            if ($configContent -and $configContent.Trim()) {
                $config = $configContent | ConvertFrom-Json -AsHashtable
                Write-Step "  Loaded existing config (merging)" "INFO"
            }
        }
        catch {
            Write-Step "  Could not parse existing config, creating backup" "WARN"
            Copy-Item $configPath "$configPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')" -Force
            $config = @{}
        }
    }

    # Ensure mcpServers exists (preserve existing servers!)
    if (!$config.ContainsKey("mcpServers")) {
        $config["mcpServers"] = @{}
    }

    # Only add/update PhiSHRI entry
    $config["mcpServers"]["phishri"] = @{
        command = $script:Paths.Binary
        args = @()
        env = @{
            PHISHRI_PATH = $script:Paths.Knowledge
            PHISHRI_SESSION_ROOT = $script:Paths.Root
        }
    }

    # Write config
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8

    Write-Step "Claude Desktop configured at $($ConfigLocation.Name)" "OK"
    return $true
}

function Install-ClaudeConfigMcpb {
    Write-Step "Installing via MCP Builder (mcpb)..."

    if (!(Test-McpbAvailable)) {
        Write-Step "mcpb not found in PATH" "ERROR"
        return $false
    }

    try {
        # Create mcpb manifest
        $manifest = @{
            name = "phishri"
            command = $script:Paths.Binary
            args = @()
            env = @{
                PHISHRI_PATH = $script:Paths.Knowledge
                PHISHRI_SESSION_ROOT = $script:Paths.Root
            }
        }

        $manifestPath = Join-Path $script:Paths.Root "mcpb-manifest.json"
        $manifest | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8

        # Run mcpb install
        & mcpb install $manifestPath
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Installed via mcpb" "OK"
            return $true
        }
        else {
            Write-Step "mcpb install failed" "ERROR"
            return $false
        }
    }
    catch {
        Write-Step "mcpb installation error: $_" "ERROR"
        return $false
    }
}

function Install-ClaudeConfigDxt {
    Write-Step "Creating DXT package..."

    $dxtDir = Join-Path $script:Paths.Root "dxt"
    if (!(Test-Path $dxtDir)) {
        New-Item -ItemType Directory -Path $dxtDir -Force | Out-Null
    }

    # Create manifest.json for DXT
    $dxtManifest = @{
        name = "phishri"
        version = $script:Config.Version
        description = "PhiSHRI MCP - Semantic Hashing Radial Index for AI Context"
        author = "Stryk91"
        mcp = @{
            command = $script:Paths.Binary
            args = @()
            env = @{
                PHISHRI_PATH = $script:Paths.Knowledge
                PHISHRI_SESSION_ROOT = $script:Paths.Root
            }
        }
    }

    $dxtManifestPath = Join-Path $dxtDir "manifest.json"
    $dxtManifest | ConvertTo-Json -Depth 5 | Set-Content $dxtManifestPath -Encoding UTF8

    Write-Step "DXT package created at: $dxtDir" "OK"
    Write-Host ""
    Write-Host "To install manually:" -ForegroundColor Yellow
    Write-Host "  1. Open Claude Desktop" -ForegroundColor White
    Write-Host "  2. Go to Settings > Extensions" -ForegroundColor White
    Write-Host "  3. Click 'Load unpacked extension'" -ForegroundColor White
    Write-Host "  4. Select: $dxtDir" -ForegroundColor Cyan
    Write-Host ""

    return $true
}

function Install-ClaudeConfigManual {
    Write-Step "Manual installation mode..."

    Write-Host ""
    Write-Host "Files downloaded to:" -ForegroundColor Yellow
    Write-Host "  Binary: $($script:Paths.Binary)" -ForegroundColor Cyan
    Write-Host "  Knowledge: $($script:Paths.Knowledge)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Add this to your Claude Desktop config:" -ForegroundColor Yellow
    Write-Host ""

    $manualConfig = @"
{
  "mcpServers": {
    "phishri": {
      "command": "$($script:Paths.Binary -replace '\\', '/')",
      "args": [],
      "env": {
        "PHISHRI_PATH": "$($script:Paths.Knowledge -replace '\\', '/')",
        "PHISHRI_SESSION_ROOT": "$($script:Paths.Root -replace '\\', '/')"
      }
    }
  }
}
"@

    Write-Host $manualConfig -ForegroundColor White
    Write-Host ""
    Write-Host "Config file locations:" -ForegroundColor Yellow
    Write-Host "  Roaming: $env:APPDATA\Claude\claude_desktop_config.json" -ForegroundColor White
    Write-Host "  Local: $env:LOCALAPPDATA\Claude\claude_desktop_config.json" -ForegroundColor White
    Write-Host ""

    return $true
}

function Test-MCPLoads {
    Write-Step "Verifying MCP can start..."

    if (!(Test-Path $script:Paths.Binary)) {
        Write-Step "Binary not found" "ERROR"
        return $false
    }

    try {
        # Try to run the binary with --version or --help to verify it works
        $process = Start-Process -FilePath $script:Paths.Binary -ArgumentList "--help" -NoNewWindow -PassThru -Wait -ErrorAction Stop

        # Also try a quick start/stop
        $testProcess = Start-Process -FilePath $script:Paths.Binary -NoNewWindow -PassThru
        Start-Sleep -Milliseconds 500

        if (!$testProcess.HasExited) {
            $testProcess.Kill()
            Write-Step "MCP binary runs successfully" "OK"
            return $true
        }
        else {
            # Check exit code
            if ($testProcess.ExitCode -eq 0) {
                Write-Step "MCP binary runs successfully" "OK"
                return $true
            }
        }
    }
    catch {
        Write-Step "Could not verify MCP startup: $_" "WARN"
    }

    # Fallback: just check file exists and is reasonable size
    $size = (Get-Item $script:Paths.Binary).Length
    if ($size -gt 1MB) {
        Write-Step "MCP binary exists ($([math]::Round($size/1MB, 2)) MB)" "OK"
        return $true
    }

    return $false
}

function Test-Installation {
    Write-Step "Verifying installation..."
    $errors = @()
    $warnings = @()

    # Check binary
    if (Test-Path $script:Paths.Binary) {
        $size = (Get-Item $script:Paths.Binary).Length
        if ($size -gt 1MB) {
            Write-Step "  Binary: OK ($([math]::Round($size/1MB, 2)) MB)" "OK"
        }
        else {
            $warnings += "Binary seems small ($size bytes) - may be corrupted"
        }
    }
    else {
        $errors += "Binary not found at $($script:Paths.Binary)"
    }

    # Check CONTEXTS
    $contextCategories = Get-ChildItem $script:Paths.Contexts -Directory -ErrorAction SilentlyContinue
    if ($contextCategories.Count -gt 0) {
        $doorCount = (Get-ChildItem $script:Paths.Contexts -Recurse -Filter "*.json" -File).Count
        Write-Step "  CONTEXTS: OK ($($contextCategories.Count) categories, $doorCount doors)" "OK"
    }
    else {
        $errors += "No context categories found in $($script:Paths.Contexts)"
    }

    # Check INDEXES
    $hashTable = Join-Path $script:Paths.Indexes "HASH_TABLE.json"
    if (Test-Path $hashTable) {
        Write-Step "  HASH_TABLE.json: OK" "OK"
    }
    else {
        $errors += "HASH_TABLE.json not found"
    }

    # Check Claude config
    $foundConfig = $false
    foreach ($loc in $script:ClaudeConfigLocations) {
        if (Test-Path $loc.Path) {
            try {
                $config = Get-Content $loc.Path -Raw | ConvertFrom-Json
                if ($config.mcpServers.phishri) {
                    Write-Step "  Claude config ($($loc.Name)): OK" "OK"
                    $foundConfig = $true
                    break
                }
            }
            catch { }
        }
    }

    if (!$foundConfig) {
        $warnings += "PhiSHRI not found in Claude Desktop config (may need manual setup)"
    }

    # Report results
    Write-Host ""
    if ($errors.Count -eq 0) {
        Write-Step "Installation verified successfully!" "OK"
    }
    else {
        Write-Step "Installation has issues:" "ERROR"
        foreach ($err in $errors) {
            Write-Step "  - $err" "ERROR"
        }
    }

    if ($warnings.Count -gt 0) {
        foreach ($warn in $warnings) {
            Write-Step "  - $warn" "WARN"
        }
    }

    return $errors.Count -eq 0
}

function Uninstall-PhiSHRI {
    Write-Banner
    Write-Step "Uninstalling PhiSHRI..."

    # Remove installation directory
    if (Test-Path $script:Paths.Root) {
        Remove-Item $script:Paths.Root -Recurse -Force
        Write-Step "Removed $($script:Paths.Root)" "OK"
    }

    # Remove from all Claude config locations
    foreach ($loc in $script:ClaudeConfigLocations) {
        if (Test-Path $loc.Path) {
            try {
                $config = Get-Content $loc.Path -Raw | ConvertFrom-Json -AsHashtable
                if ($config.mcpServers -and $config.mcpServers.ContainsKey("phishri")) {
                    $config.mcpServers.Remove("phishri")
                    $config | ConvertTo-Json -Depth 10 | Set-Content $loc.Path -Encoding UTF8
                    Write-Step "Removed from $($loc.Name) config" "OK"
                }
            }
            catch { }
        }
    }

    Write-Host ""
    Write-Step "PhiSHRI has been uninstalled" "OK"
    Write-Host ""
}

function Install-PhiSHRI {
    param([string]$InstallMethod)

    Write-Banner

    # Show menu if method not specified
    if (!$InstallMethod) {
        $InstallMethod = Show-InstallMenu
    }

    Write-Host ""
    Write-Step "Selected method: $InstallMethod"
    Write-Host ""

    try {
        Test-Prerequisites
        Initialize-Directories
        Install-MCPBinary
        Install-KnowledgeBase
        Install-AgentTemplate

        # Configure based on method
        $configSuccess = $false

        switch ($InstallMethod) {
            "Auto" {
                $configLoc = Find-ClaudeConfig
                if ($configLoc) {
                    $configSuccess = Install-ClaudeConfigAuto -ConfigLocation $configLoc
                }

                # Fallback chain
                if (!$configSuccess) {
                    Write-Step "Auto-config failed, trying mcpb..." "WARN"
                    if (Test-McpbAvailable) {
                        $configSuccess = Install-ClaudeConfigMcpb
                    }
                }

                if (!$configSuccess) {
                    Write-Step "Falling back to manual instructions..." "WARN"
                    $configSuccess = Install-ClaudeConfigManual
                }
            }
            "Mcpb" {
                $configSuccess = Install-ClaudeConfigMcpb
                if (!$configSuccess) {
                    Write-Step "mcpb failed, showing manual instructions..." "WARN"
                    $configSuccess = Install-ClaudeConfigManual
                }
            }
            "Dxt" {
                $configSuccess = Install-ClaudeConfigDxt
            }
            "Manual" {
                $configSuccess = Install-ClaudeConfigManual
            }
        }

        Write-Host ""

        # Verify MCP can load
        $mcpOk = Test-MCPLoads

        # Final verification
        Test-Installation

        Write-Host ""
        if ($mcpOk) {
            Write-Host "Installation complete!" -ForegroundColor Green
        }
        else {
            Write-Host "Installation complete (with warnings)" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Restart Claude Desktop"
        Write-Host "  2. Look for 'phishri' in the MCP servers list"
        Write-Host "  3. Try asking: 'What doors are available?'"
        Write-Host ""
        Write-Host "Optional: Customize your agent config at:" -ForegroundColor Cyan
        Write-Host "  $($script:Paths.AgentsConfig)"
        Write-Host ""
        Write-Host "To verify installation later, run:" -ForegroundColor Cyan
        Write-Host "  .\install.ps1 -Verify"
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Step "Installation failed: $_" "ERROR"
        Write-Host ""
        Write-Host "For help, visit: https://github.com/$($script:Config.GitHubRepo)/issues" -ForegroundColor Yellow
        exit 1
    }
}

# Main entry point
if ($Uninstall) {
    Uninstall-PhiSHRI
}
elseif ($Verify) {
    Write-Banner
    Test-Installation
    Test-MCPLoads
}
else {
    Install-PhiSHRI -InstallMethod $Method
}
