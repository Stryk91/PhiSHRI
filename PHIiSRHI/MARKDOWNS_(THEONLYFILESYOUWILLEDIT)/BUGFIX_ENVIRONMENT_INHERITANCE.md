# Windows MCP Server - Environment Variable Inheritance Fix

## Problem Description

The Windows MCP server's `execute_powershell` tool was failing to execute git commands and other user-installed tools with errors like:

- `"git" not recognized as an internal or external command`
- PATH-dependent tools not being found
- Working directory commands (cd, Set-Location) not persisting

## Root Cause

The `execute_powershell` function in `src/main.rs` was spawning PowerShell processes using `Command::new()` without explicitly inheriting the user's environment variables. This resulted in PowerShell running with a minimal/default environment that didn't include:

1. User's PATH variable (containing git, cargo, and other installed tools)
2. Other user-defined environment variables
3. System environment variables

## The Fix

**File**: `src/main.rs:652-660`

**Before** (line 653-658):
```rust
let mut child = Command::new(ps_path)
    .args(["-NoProfile", "-NonInteractive", "-Command", command])
    .stdout(Stdio::piped())
    .stderr(Stdio::piped())
    .spawn()
    .map_err(|e| format!("Failed to spawn PowerShell: {}", e))?;
```

**After**:
```rust
let mut child = Command::new(ps_path)
    .args(["-NoProfile", "-NonInteractive", "-Command", command])
    .stdout(Stdio::piped())
    .stderr(Stdio::piped())
    .env_clear()  // Start with clean environment
    .envs(std::env::vars())  // Inherit all user environment variables including PATH
    .spawn()
    .map_err(|e| format!("Failed to spawn PowerShell: {}", e))?;
```

## What Changed

1. Added `.env_clear()` to start with a clean slate
2. Added `.envs(std::env::vars())` to inherit all environment variables from the parent process (the MCP server itself, which runs in the user's context)

This ensures that PowerShell commands executed through the MCP server have access to:
- The user's PATH (with git, cargo, python, etc.)
- User environment variables
- System environment variables
- Custom environment configurations

## Validation

After rebuilding the server (`cargo build --release`), the following should now work:

1. **Git commands**: `git status`, `git branch`, `git log`, etc.
2. **PATH-based tools**: Any tool in user's PATH (cargo, python, node, etc.)
3. **Environment variable access**: `$env:PATH`, `$env:USERPROFILE`, etc.
4. **Working directory persistence**: While cd still doesn't persist between tool calls (each execute_powershell is a new process), you can use `cd path; git status` in a single command

## Testing Commands

Test these through DC's `execute_powershell` tool:

```powershell
# Test PATH inheritance
git --version

# Test environment variable access
$env:PATH

# Test combined operations
cd "C:\Dev\CODEX\PhiDEX"; git status

# Test using -C flag (alternative to cd)
git -C "C:\Dev\CODEX\PhiDEX" branch -a
```

## Impact

- **Breaking Changes**: None
- **Security Impact**: No change - still validates commands through `validate_powershell_command()`
- **Performance Impact**: Negligible - `std::env::vars()` is a fast operation
- **Compatibility**: Improved - now matches behavior users expect from their terminal

## Build Instructions

After making this change:

```bash
cargo build --release
```

Binary location: `target/x86_64-pc-windows-gnu/release/windows-mcp-server.exe`

## Claude Desktop Integration

If using with Claude Desktop, restart the application after replacing the binary to pick up the changes.

## Date

Fixed: 2025-11-16
