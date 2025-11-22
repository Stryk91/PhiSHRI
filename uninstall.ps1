#Requires -Version 5.1
<#
.SYNOPSIS
    Uninstaller for PhiSHRI - Semantic Self-Hashing Radial Repository Index

.DESCRIPTION
    Removes PhiSHRI installation from the system.

.PARAMETER KeepConfig
    Keep Claude Desktop configuration (don't remove MCP server entry)

.PARAMETER Force
    Skip confirmation prompt

.NOTES
    Version: 1.0.0
    Author: Stryk91
#>

[CmdletBinding()]
param(
    [string]$InstallPath = "$env:USERPROFILE\.phishri",
    [switch]$KeepConfig,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

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

# Banner
Write-Host ""
Write-Host "  PhiSHRI Uninstaller" -ForegroundColor Cyan
Write-Host "  ===================" -ForegroundColor DarkGray
Write-Host ""

# Check if installed
if (-not (Test-Path $InstallPath)) {
    Write-Status "PhiSHRI not found at $InstallPath" "WARNING"
    Write-Status "Nothing to uninstall" "INFO"
    exit 0
}

# Read version info if available
$versionFile = "$InstallPath\version.json"
if (Test-Path $versionFile) {
    $versionInfo = Get-Content $versionFile | ConvertFrom-Json
    Write-Status "Found PhiSHRI v$($versionInfo.version) installed on $($versionInfo.installed)"
    Write-Status "Doors: $($versionInfo.doors)"
}

# Confirmation
if (-not $Force) {
    Write-Host ""
    $confirm = Read-Host "Remove PhiSHRI from $InstallPath? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Status "Uninstall cancelled" "INFO"
        exit 0
    }
}

# Remove installation directory
Write-Status "Removing PhiSHRI installation..."
try {
    Remove-Item -Path $InstallPath -Recurse -Force
    Write-Status "Installation directory removed" "SUCCESS"
} catch {
    Write-Status "Failed to remove installation: $_" "ERROR"
    exit 1
}

# Claude Desktop config reminder
if (-not $KeepConfig) {
    Write-Host ""
    Write-Status "Remember to remove the 'phishri' entry from Claude Desktop config:" "WARNING"
    Write-Host "  %APPDATA%\Claude\claude_desktop_config.json" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "PhiSHRI uninstalled successfully" -ForegroundColor Green
Write-Host ""
