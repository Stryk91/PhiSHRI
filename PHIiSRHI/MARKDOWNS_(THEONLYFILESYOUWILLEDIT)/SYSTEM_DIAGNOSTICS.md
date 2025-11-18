# System Diagnostics Report

**Date:** 2025-11-15
**Issues Detected:** 3 critical

---

## 🔴 Issue 1: PowerShell 5.1 Broken

### Error:
```
Could not load file or assembly 'System.Management.Automation, Version=3.0.0.0,
Culture=neutral, PublicKeyToken=31bf3856ad364e35' or one of its dependencies.
The system cannot find the file specified.
```

### Location:
- **Broken:** `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- **Working:** `E:\pwsh\7\pwsh.exe` (PowerShell 7)

### Impact:
- Windows PowerShell (v5.1) cannot start
- Scripts calling `powershell.exe` fail
- Our MCP server uses `powershell` command (may be affected)

### Root Cause:
.NET Framework assembly corruption or missing Windows Update

### Fix Options:

**Option 1: Use PowerShell 7 (Immediate)**
```bash
# Update MCP server to use pwsh instead of powershell
sed -i 's/"powershell"/"E:\\\\pwsh\\\\7\\\\pwsh.exe"/g' src/main.rs
cargo build --release
```

**Option 2: Repair .NET Framework**
```powershell
# Run as Admin
DISM.exe /Online /Cleanup-image /Restorehealth
sfc /scannow
```

**Option 3: Reinstall PowerShell 5.1**
- Windows Update
- Repair Windows features

---

## 🔴 Issue 2: WSL Bashrc Syntax Error

### Error:
```
-bash: /home/STRYK/.bashrc: line 157: `PATH=/home/STRYK/.local/bin:...'
```

### Location:
- **File:** `/home/STRYK/.bashrc` (WSL filesystem)
- **Line:** 157
- **Issue:** Unclosed quote or syntax error in PATH assignment

### Impact:
- WSL bash sessions fail to start properly
- Environment variables not loaded in WSL

### Fix:
```bash
# From WSL terminal:
nano /home/STRYK/.bashrc
# Go to line 157
# Fix PATH syntax (likely missing quote or escape character)
```

**Common fixes:**
- Check for unescaped spaces
- Verify quote matching
- Remove duplicate PATH definitions

---

## 🔴 Issue 3: PowerToys WebView2 Crash

### Error:
```
System.Runtime.InteropServices.COMException (0x8000FFFF): Catastrophic failure
at Microsoft.Web.WebView2.Core.CoreWebView2Environment.CreateCoreWebView2ControllerAsync
```

### Location:
- **Component:** PowerToys Monaco Preview Handler
- **Module:** `PowerToys.MonacoPreviewHandler.dll`
- **Version:** 0.95.1.0

### Impact:
- Code file previews in Explorer crash
- Preview pane shows error dialog
- Does NOT affect MCP server operation

### Fix Options:

**Option 1: Disable Monaco Preview**
- PowerToys Settings → File Explorer → Disable Monaco for code files

**Option 2: Repair WebView2**
```powershell
# Download and reinstall
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" `
  -OutFile "$env:TEMP\webview2.exe"
Start-Process "$env:TEMP\webview2.exe" -Wait
```

**Option 3: Restart PowerToys**
```powershell
Stop-Process -Name "PowerToys" -Force
Start-Process "C:\Program Files\PowerToys\PowerToys.exe"
```

---

## 📊 System Status Summary

| Component | Status | Impact | Priority |
|-----------|--------|--------|----------|
| PowerShell 5.1 | 🔴 BROKEN | MCP server may fail | **HIGH** |
| PowerShell 7 | ✅ WORKING | Alternative available | N/A |
| WSL Bash | 🔴 BROKEN | WSL sessions fail | MEDIUM |
| Git Bash | ✅ WORKING | Current shell OK | N/A |
| PowerToys Preview | 🔴 BROKEN | UI annoyance only | LOW |
| Rust MCP Server | ✅ WORKING | Production ready | N/A |

---

## 🎯 Recommended Actions (Priority Order)

### 1. Fix MCP Server PowerShell Dependency (CRITICAL)

**Current code:**
```rust
Command::new("powershell")  // This is BROKEN
```

**Fixed code:**
```rust
Command::new("E:\\pwsh\\7\\pwsh.exe")  // Use working PowerShell 7
```

**Or make it smart:**
```rust
let ps_cmd = if Path::new("E:\\pwsh\\7\\pwsh.exe").exists() {
    "E:\\pwsh\\7\\pwsh.exe"
} else {
    "powershell"  // Fallback
};
Command::new(ps_cmd)
```

### 2. Repair Windows PowerShell 5.1 (MEDIUM)

Run Windows System File Checker:
```cmd
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

Then check Windows Update for .NET Framework updates.

### 3. Fix WSL Bashrc (MEDIUM)

Edit `/home/STRYK/.bashrc` line 157 - likely missing quote or escape.

### 4. Ignore PowerToys Issue (LOW)

Just close the dialog. It's cosmetic.

---

## 🔧 Immediate Tactical Fix for MCP Server

**UPDATE RUST CODE TO USE PWSH:**
