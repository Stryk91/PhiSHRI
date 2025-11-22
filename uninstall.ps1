<#
.SYNOPSIS
    PhiSHRI MCP Uninstaller for Windows

.DESCRIPTION
    Removes the PhiSHRI MCP server installation completely.
    Removes binary, knowledge base, sessions, and Claude Desktop configuration.

.PARAMETER KeepSessions
    Keep session data when uninstalling (preserves ~/.phishri/sessions/)

.EXAMPLE
    .\uninstall.ps1

.EXAMPLE
    .\uninstall.ps1 -KeepSessions
#>

param(
    [switch]$KeepSessions
)

$ErrorActionPreference = "Stop"

# Configuration
$PhiSHRIRoot = Join-Path $env:USERPROFILE ".phishri"

function Write-Step {
    param([string]$Message, [string]$Status = "INFO")
    $colors = @{
        "INFO" = "Cyan"
        "OK" = "Green"
        "WARN" = "Yellow"
        "ERROR" = "Red"
    }
    Write-Host "[$Status] " -ForegroundColor $colors[$Status] -NoNewline
    Write-Host $Message
}

function Get-ClaudeConfigPath {
    $possiblePaths = @(
        (Join-Path $env:APPDATA "Claude\claude_desktop_config.json"),
        (Join-Path $env:LOCALAPPDATA "Claude\claude_desktop_config.json")
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

Write-Host @"

  ____  _     _ ____  _   _ ____  ___
 |  _ \| |__ (_) ___|| | | |  _ \|_ _|
 | |_) | '_ \| \___ \| |_| | |_) || |
 |  __/| | | | |___) |  _  |  _ < | |
 |_|   |_| |_|_|____/|_| |_|_| \_\___|

  MCP Server Uninstaller

"@ -ForegroundColor Magenta

Write-Step "Uninstalling PhiSHRI..."

# Remove from Claude config first
$claudeConfig = Get-ClaudeConfigPath
if ($claudeConfig -and (Test-Path $claudeConfig)) {
    try {
        $config = Get-Content $claudeConfig -Raw | ConvertFrom-Json -AsHashtable
        if ($config.mcpServers -and $config.mcpServers.ContainsKey("phishri")) {
            $config.mcpServers.Remove("phishri")
            $config | ConvertTo-Json -Depth 10 | Set-Content $claudeConfig -Encoding UTF8
            Write-Step "Removed PhiSHRI from Claude Desktop config" "OK"
        }
        else {
            Write-Step "PhiSHRI not found in Claude config" "INFO"
        }
    }
    catch {
        Write-Step "Could not update Claude config: $_" "WARN"
    }
}
else {
    Write-Step "Claude Desktop config not found" "INFO"
}

# Remove installation directory
if (Test-Path $PhiSHRIRoot) {
    if ($KeepSessions) {
        # Remove everything except sessions
        $sessionsPath = Join-Path $PhiSHRIRoot "sessions"

        Get-ChildItem $PhiSHRIRoot -Force | Where-Object { $_.Name -ne "sessions" } | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force
            Write-Step "Removed $($_.Name)"
        }

        if (Test-Path $sessionsPath) {
            Write-Step "Kept sessions directory at $sessionsPath" "INFO"
        }
    }
    else {
        Remove-Item $PhiSHRIRoot -Recurse -Force
        Write-Step "Removed $PhiSHRIRoot" "OK"
    }
}
else {
    Write-Step "PhiSHRI installation not found at $PhiSHRIRoot" "INFO"
}

Write-Host ""
Write-Step "PhiSHRI has been uninstalled" "OK"
Write-Host ""
Write-Host "To reinstall, run:" -ForegroundColor Cyan
Write-Host "  irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex"
Write-Host ""
