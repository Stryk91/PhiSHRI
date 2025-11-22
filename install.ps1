#Requires -Version 5.1
<#
.SYNOPSIS
    One-shot installer for PhiSHRI - Semantic Self-Hashing Radial Repository Index

.DESCRIPTION
    Downloads and installs PhiSHRI MCP server and context doors for Claude Desktop.

    Usage: irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex

.NOTES
    Version: 1.0.0
    Author: Stryk91
    Repository: https://github.com/Stryk91/PhiSHRI
#>

[CmdletBinding()]
param(
    [string]$InstallPath = "$env:USERPROFILE\.phishri",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Configuration
$McpRepoUrl = "https://github.com/Stryk91/PhiSHRI_MCP"
$McpBinaryUrl = "$McpRepoUrl/releases/latest/download/phishri-mcp-windows-x64.exe"
$PhiSHRIRepoUrl = "https://github.com/Stryk91/PhiSHRI"
$PhiSHRIArchiveUrl = "$PhiSHRIRepoUrl/archive/refs/heads/main.zip"

function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Test-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Banner
Write-Host ""
Write-Host "  PhiSHRI Installer v1.0.0" -ForegroundColor Cyan
Write-Host "  Semantic Self-Hashing Radial Repository Index" -ForegroundColor DarkCyan
Write-Host "  =============================================" -ForegroundColor DarkGray
Write-Host ""

# Check if already installed
if ((Test-Path $InstallPath) -and -not $Force) {
    Write-Status "PhiSHRI already installed at $InstallPath" "WARNING"
    Write-Status "Use -Force to reinstall, or run uninstall.ps1 first" "INFO"
    exit 0
}

# Create install directory
Write-Status "Creating install directory: $InstallPath"
if (Test-Path $InstallPath) {
    Remove-Item -Path $InstallPath -Recurse -Force
}
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallPath\bin" -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallPath\contexts" -Force | Out-Null

# Download MCP binary
Write-Status "Downloading PhiSHRI MCP server..."
$mcpBinaryPath = "$InstallPath\bin\phishri-mcp.exe"
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($McpBinaryUrl, $mcpBinaryPath)
    Write-Status "MCP binary downloaded successfully" "SUCCESS"
} catch {
    Write-Status "Failed to download MCP binary: $_" "ERROR"
    exit 1
}

# Verify binary exists and has content
if (-not (Test-Path $mcpBinaryPath) -or (Get-Item $mcpBinaryPath).Length -eq 0) {
    Write-Status "MCP binary download failed or file is empty" "ERROR"
    exit 1
}

# Download PhiSHRI content
Write-Status "Downloading PhiSHRI context doors..."
$tempZip = "$env:TEMP\phishri-main.zip"
$tempExtract = "$env:TEMP\phishri-extract"

try {
    $webClient.DownloadFile($PhiSHRIArchiveUrl, $tempZip)

    # Extract
    if (Test-Path $tempExtract) {
        Remove-Item -Path $tempExtract -Recurse -Force
    }
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    # Copy PhiSHRI content
    $sourcePath = "$tempExtract\PhiSHRI-main\PhiSHRI"
    if (Test-Path $sourcePath) {
        Copy-Item -Path "$sourcePath\*" -Destination "$InstallPath\contexts" -Recurse -Force
        Write-Status "Context doors installed successfully" "SUCCESS"
    } else {
        Write-Status "PhiSHRI content not found in archive" "WARNING"
    }

    # Cleanup
    Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Write-Status "Failed to download PhiSHRI content: $_" "ERROR"
    # Continue anyway - MCP binary is more important
}

# Count installed doors
$doorCount = 0
$contextsPath = "$InstallPath\contexts\CONTEXTS"
if (Test-Path $contextsPath) {
    $doorCount = (Get-ChildItem -Path $contextsPath -Filter "*.json" -Recurse).Count
}

# Create version file
@{
    version = "1.0.0"
    installed = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    doors = $doorCount
    mcp_binary = $mcpBinaryPath
} | ConvertTo-Json | Set-Content -Path "$InstallPath\version.json"

# Output Claude Desktop config
Write-Host ""
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "Install path: $InstallPath" -ForegroundColor White
Write-Host "MCP binary:   $mcpBinaryPath" -ForegroundColor White
Write-Host "Doors:        $doorCount" -ForegroundColor White
Write-Host ""
Write-Host "Add this to your Claude Desktop config:" -ForegroundColor Yellow
Write-Host "(%APPDATA%\Claude\claude_desktop_config.json)" -ForegroundColor DarkGray
Write-Host ""
Write-Host @"
{
  "mcpServers": {
    "phishri": {
      "command": "$($mcpBinaryPath -replace '\\', '\\\\')",
      "args": ["--doors-path", "$($InstallPath -replace '\\', '\\\\')\\\\contexts"]
    }
  }
}
"@ -ForegroundColor Cyan
Write-Host ""
Write-Status "Restart Claude Desktop to activate PhiSHRI" "INFO"
Write-Host ""
