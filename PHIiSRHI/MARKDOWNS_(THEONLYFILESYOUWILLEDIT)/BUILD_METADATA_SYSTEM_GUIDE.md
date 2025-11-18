# Build Metadata System - Complete Guide

## Overview

This system provides **SHA-256 hash tracking, build timestamps, git commit tracking, and build reason documentation** for all builds. This is the **only true way** to verify build authenticity and track versions across your projects.

## Key Principle

> **"The only true way is cross reference SHA key, also build date and reason should be in the metadata of the build when its built"**

This system eliminates ambiguity about versions by embedding cryptographic proof of identity in every build.

## System Components

### 1. BUILD_METADATA_GENERATOR.ps1
**Purpose:** Generates comprehensive metadata for any binary

**Usage:**
```powershell
.\BUILD_METADATA_GENERATOR.ps1 `
    -BinaryPath ".\build\windows-mcp-server.exe" `
    -BuildReason "Release v3.0.2 - Production ready" `
    -OutputPath ".\build\BUILD_METADATA.json"
```

**Metadata Generated:**
- **SHA-256 hash** of binary (cryptographic fingerprint)
- **Git commit hash** and branch (source code identity)
- **Build timestamp** (ISO 8601 format)
- **Build reason** (human-readable purpose)
- **Build tools** (cargo, rustc, PowerShell versions)
- **Dependencies** (from Cargo.lock or equivalent)
- **Build machine** (hostname, user, OS)
- **Binary metadata** (size, creation time)

### 2. BUILD_TEMPLATE_WITH_METADATA.ps1
**Purpose:** Template showing how to integrate metadata into your build process

**Copy this file to your project and customize:**
```powershell
# Copy template to your project
Copy-Item C:\Dev\BUILD_TEMPLATE_WITH_METADATA.ps1 C:\Dev\YourProject\BUILD.ps1

# Edit BUILD.ps1 to add your actual build commands
# Replace the placeholder sections with:
#   - Your actual build command (cargo build, Invoke-ps2exe, etc.)
#   - Your test command (cargo test, Invoke-Pester, etc.)
```

**Features:**
- Pre-build validation (checks Git status)
- Build execution (customizable)
- Test execution (optional)
- Automatic metadata generation
- VERSION.txt creation (human-readable)
- Final verification

### 3. VERIFY_BUILD.ps1
**Purpose:** Verifies any binary against its BUILD_METADATA.json

**Usage:**
```powershell
.\VERIFY_BUILD.ps1 -BinaryPath ".\build\windows-mcp-server.exe"
# Auto-detects BUILD_METADATA.json in same directory

# Or specify metadata path explicitly:
.\VERIFY_BUILD.ps1 `
    -BinaryPath ".\build\windows-mcp-server.exe" `
    -MetadataPath ".\build\BUILD_METADATA.json"
```

**Verification Checks:**
- SHA-256 hash matches metadata
- Binary size matches metadata
- Displays full build context
- Exit code 0 = verified, 1 = failed

## Quick Start Guide

### Step 1: Create BUILD.ps1 for Your Project

```powershell
# Navigate to your project
cd C:\Dev\YourProject

# Copy the template
Copy-Item C:\Dev\BUILD_TEMPLATE_WITH_METADATA.ps1 .\BUILD.ps1

# Edit BUILD.ps1 and replace placeholder sections:
```

**For Rust projects:**
```powershell
# Replace STEP 2 build section with:
Write-Host "  Building Rust project..." -ForegroundColor Cyan
cargo build --release
$binaryPath = ".\target\release\your-binary.exe"
Write-Host "  Build completed: $binaryPath" -ForegroundColor Green
```

**For PowerShell projects:**
```powershell
# Replace STEP 2 build section with:
Write-Host "  Compiling PowerShell to executable..." -ForegroundColor Cyan
Invoke-ps2exe -InputFile ".\src\main.ps1" -OutputFile "$OutputDir\your-app.exe" -noConsole
$binaryPath = "$OutputDir\your-app.exe"
Write-Host "  Build completed: $binaryPath" -ForegroundColor Green
```

### Step 2: Run Your First Build

```powershell
# Development build
.\BUILD.ps1 -BuildReason "Development build - testing feature X"

# Release build
.\BUILD.ps1 `
    -BuildReason "Release v3.0.2 - Production ready" `
    -Configuration Release

# Quick build without tests
.\BUILD.ps1 -SkipTests -BuildReason "Quick iteration - UI changes"
```

### Step 3: Verify Your Build

```powershell
# Verify the build
.\VERIFY_BUILD.ps1 -BinaryPath ".\build-output\your-binary.exe"

# Expected output:
#   SHA-256 MATCH
#   Size MATCH
#   Overall Status: VERIFIED
```

### Step 4: Distribute with Metadata

**Always distribute these together:**
1. `your-binary.exe` (the executable)
2. `BUILD_METADATA.json` (the proof of authenticity)
3. `VERSION.txt` (human-readable info)

```powershell
# Example: Create distribution package
$distroDir = ".\Distribution\YourApp-v3.0.2"
New-Item -ItemType Directory -Path $distroDir -Force

Copy-Item .\build-output\your-binary.exe $distroDir\
Copy-Item .\build-output\BUILD_METADATA.json $distroDir\
Copy-Item .\build-output\VERSION.txt $distroDir\
Copy-Item .\README.md $distroDir\

Compress-Archive -Path $distroDir -DestinationPath ".\YourApp-v3.0.2.zip"
```

## Metadata Schema (v1.0.0)

```json
{
  "binary_sha256": "abc123...",              // SHA-256 hash (cryptographic identity)
  "binary_path": ".\\build\\app.exe",        // Relative path to binary
  "binary_size_bytes": 544768,               // Exact size in bytes
  "binary_size_mb": 0.52,                    // Size in MB
  "binary_created": "2025-11-18T05:55:00Z",  // Binary creation time
  "binary_modified": "2025-11-18T05:55:00Z", // Binary modification time

  "build_timestamp": "2025-11-18T05:55:00Z", // When build occurred (UTC)
  "build_reason": "Release v3.0.2",          // Why this build was created
  "build_machine": "DESKTOP-ABC123",         // Hostname where built
  "build_user": "username",                  // User who built it
  "build_os": "Windows 10.0.26120",          // Operating system
  "build_architecture": "x64",               // Architecture

  "git_commit_sha": "def456...",             // Git commit (source identity)
  "git_branch": "main",                      // Git branch
  "git_clean_working_dir": true,             // True if no uncommitted changes
  "git_uncommitted_changes": false,          // True if dirty build

  "project_version": "3.0.2",                // From Cargo.toml or equivalent
  "project_root": "C:\\Dev\\YourProject",    // Project root directory

  "cargo_version": "cargo 1.75.0",           // Cargo version (if Rust)
  "rustc_version": "rustc 1.75.0",           // Rustc version (if Rust)
  "powershell_version": "7.4.0",             // PowerShell version

  "dependencies": {                          // Dependencies with versions
    "serde": "1.0.195",
    "tokio": "1.35.1"
  },

  "ci_pipeline": "manual",                   // CI/CD info (future)
  "ci_build_number": null,
  "ci_job_url": null,

  "additional": {},                          // User-provided metadata

  "metadata_schema_version": "1.0.0"         // Schema version
}
```

## Version Verification Process

### The CORRECT Way (SHA-256 + Build Date + Version)

```powershell
# Step 1: Read metadata
$metadata = Get-Content "BUILD_METADATA.json" | ConvertFrom-Json

# Step 2: Compute current SHA-256
$currentHash = (Get-FileHash "binary.exe" -Algorithm SHA256).Hash

# Step 3: Compare
if ($currentHash -eq $metadata.binary_sha256) {
    Write-Host "VERIFIED: Binary is authentic"
    Write-Host "Built: $($metadata.build_timestamp)"
    Write-Host "Reason: $($metadata.build_reason)"
    Write-Host "Version: $($metadata.project_version)"
    Write-Host "Git Commit: $($metadata.git_commit_sha)"
} else {
    Write-Host "FAILED: Binary has been modified or replaced!"
}
```

### The WRONG Way (Folder Timestamps)

```powershell
# ❌ UNRELIABLE - Don't do this!
$folder = Get-Item "C:\Dev\Project"
$lastModified = $folder.LastWriteTime

# Problem: Folder timestamps change when ANY file is added/modified
# Example: Adding a README.md updates folder timestamp but not code!
```

### Why This Matters

**Real-world example from this project:**
- Windows-MCP-v2 folder was modified Nov 18 (ClaudeShellWrapper added today)
- Windows-MCP-v3 folder was modified Nov 17
- **Folder timestamps alone suggested v2 was newer**
- **Cargo.toml + binary timestamps revealed truth: v3 (3.0.2) > v2 (2.0.0)**

**Lesson:** Folder timestamps lie. SHA keys + build metadata = truth.

## Integration Examples

### Example 1: Windows-MCP-v3 (Rust Project)

```powershell
# BUILD.ps1 for Windows-MCP-v3
param(
    [string]$BuildReason = "Development build"
)

# Build Rust binary
cargo build --release
$binary = ".\target\release\windows-mcp-server.exe"

# Generate metadata
& C:\Dev\BUILD_METADATA_GENERATOR.ps1 `
    -BinaryPath $binary `
    -BuildReason $BuildReason `
    -OutputPath ".\target\release\BUILD_METADATA.json"

# Run tests
cargo test

Write-Host "Build complete! Binary: $binary"
```

### Example 2: PhiLaunch (Python + PowerShell)

```powershell
# BUILD.ps1 for PhiLaunch
param(
    [string]$BuildReason = "Development build"
)

# Package Python application
pyinstaller --onefile .\src\main.py --name PhiLaunch

$binary = ".\dist\PhiLaunch.exe"

# Generate metadata
& C:\Dev\BUILD_METADATA_GENERATOR.ps1 `
    -BinaryPath $binary `
    -BuildReason $BuildReason `
    -OutputPath ".\dist\BUILD_METADATA.json" `
    -AdditionalMetadata @{
        PythonVersion = (python --version)
        PyInstallerVersion = (pyinstaller --version)
    }

Write-Host "Build complete! Binary: $binary"
```

### Example 3: CI/CD Integration

```powershell
# .github/workflows/build.yml (GitHub Actions)
# Or equivalent in your CI system

# In your CI build script:
$buildReason = "CI Build #$env:GITHUB_RUN_NUMBER - $env:GITHUB_REF_NAME"

& .\BUILD.ps1 -BuildReason $buildReason -Configuration Release

# Verify build
& C:\Dev\VERIFY_BUILD.ps1 -BinaryPath ".\build-output\app.exe"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build verification failed!"
    exit 1
}

# Upload artifacts (binary + metadata together)
# ... your CI upload commands ...
```

## Best Practices

### 1. Always Build with Metadata
- **Never** distribute a binary without BUILD_METADATA.json
- Metadata is proof of authenticity

### 2. Clean Builds Only in Production
- Development: Dirty builds are OK
- Production/Release: **Always** build from clean Git state
- Check `git_clean_working_dir` in metadata

### 3. Meaningful Build Reasons
```powershell
# Good build reasons:
"Release v3.0.2 - Production ready"
"Hotfix for crash in startup sequence (Issue #42)"
"Beta v3.1.0-rc1 - Testing new API"
"Development build - investigating memory leak"

# Bad build reasons:
"test"
"build"
"fixing stuff"
```

### 4. Version in Metadata
- Metadata contains `build_timestamp` and `project_version`
- Use these to track "when" and "what version"
- Git commit SHA tracks "which source code"

### 5. Store Metadata with Artifacts
```
Distribution/
├── windows-mcp-server.exe
├── BUILD_METADATA.json     ← Always include
├── VERSION.txt             ← Human-readable
└── README.md
```

## Troubleshooting

### Problem: "BUILD_METADATA_GENERATOR.ps1 not found"
**Solution:**
```powershell
# Ensure script is at C:\Dev\BUILD_METADATA_GENERATOR.ps1
# Or update path in your BUILD.ps1:
$metadataScript = "C:\Path\To\BUILD_METADATA_GENERATOR.ps1"
& $metadataScript -BinaryPath $binary -BuildReason "..."
```

### Problem: "Git information not available"
**Solution:**
- Ensure Git is installed and in PATH
- Ensure project is a Git repository (`git init` if needed)
- Metadata will still be generated, but without Git info

### Problem: "SHA-256 verification failed"
**Causes:**
1. Binary was modified after build
2. Binary was replaced with different file
3. Metadata is from a different binary

**Solution:**
- Rebuild from source
- Generate new metadata
- Never edit binary after metadata generation

### Problem: "Cargo.toml not found"
**Solution:**
- For non-Rust projects, this is expected
- Metadata will skip Cargo-specific fields
- For Rust projects, ensure Cargo.toml is in project root

## Future Enhancements

### Planned Features:
1. **Code signing integration** (Authenticode for Windows)
2. **Multi-binary projects** (track multiple executables)
3. **Dependency vulnerability scanning** (check dependencies for CVEs)
4. **Build reproducibility** (deterministic builds)
5. **Artifact registry integration** (push to Artifactory, Nexus, etc.)

### Schema Evolution:
- Current: v1.0.0
- Future versions will add fields, never remove
- `metadata_schema_version` enables compatibility checking

## Summary

This build metadata system provides:
- **Cryptographic proof of identity** (SHA-256)
- **Source code traceability** (Git commit)
- **Build context** (when, why, who, where)
- **Tool versions** (reproducibility)
- **Dependencies** (supply chain tracking)

**Result:** No more ambiguity about versions. Every build is uniquely identified and verifiable.

---

**Created:** 2025-11-18
**System Version:** 1.0.0
**Location:** C:\Dev\BUILD_METADATA_SYSTEM_GUIDE.md
