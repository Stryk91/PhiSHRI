# Windows Path Reference for IDE Claude

**Quick Reference for Path Handling in Different Environments**

## The Problem

When using bash commands in Windows PowerShell / WSL / Git Bash, path handling can be inconsistent. There are two common path formats:

```bash
# UNIX-style (works in WSL/Git Bash)
/e/PythonProjects/PhiWave

# Windows-style (works in PowerShell/CMD)
E:\PythonProjects\PhiWave
```

## The Solution

**Use Windows-style paths with quotes in bash commands:**

```bash
# CORRECT ✓
cd "E:\PythonProjects\PhiWave"
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\PythonProjects\PhiWave\script.ps1"
git -C "E:\PythonProjects\PhiWave" status

# INCORRECT ✗
cd /e/PythonProjects/PhiWave  # May fail in some contexts
cd E:\PythonProjects\PhiWave   # Backslashes confuse bash
```

## Why This Matters

- **PowerShell interop:** Native Windows tools expect `E:\path\to\file` format
- **File operations:** `Test-Path`, `Get-Item` work better with Windows paths
- **Consistency:** Quotes protect against spaces and special characters
- **Reliability:** Works across bash, PowerShell, and Git Bash

## Examples in PhiWave Context

```bash
# Correct: Python from Windows path
python "E:\PythonProjects\PhiWave\demo_app.py"

# Correct: Git in Windows path
git -C "E:\PythonProjects\PhiWave" status
git -C "E:\PythonProjects\PhiWave" commit -m "message"

# Correct: PowerShell script execution
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\PythonProjects\PhiWave\script.ps1"

# Correct: File creation with Write tool
# File path: E:\PythonProjects\PhiWave\file.txt (use backslashes)

# Less reliable: Unix-style paths
cd /e/PythonProjects/PhiWave
```

## IDE Claude's Implementation Guide

When writing bash commands in Claude Code:

1. **Always use absolute Windows paths:** `E:\PythonProjects\PhiWave\...`
2. **Always quote paths:** `"E:\PythonProjects\PhiWave"`
3. **Use backslashes:** `\` not `/` (or escape them in bash strings)
4. **Test with cd first:** If unsure, start with `cd "E:\PythonProjects\PhiWave"` to verify path works

### Pattern Templates

```bash
# Template: Safe cd command
cd "E:\PythonProjects\PhiWave" && [rest of command]

# Template: Python execution
python "E:\PythonProjects\PhiWave\script.py"

# Template: Git operations
git -C "E:\PythonProjects\PhiWave" [git command]

# Template: PowerShell scripts
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\PythonProjects\PhiWave\script.ps1"
```

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `command not found` | Path uses `/e/` instead of `E:\` | Use `E:\` format |
| `No such file or directory` | Path is unquoted with spaces | Add quotes: `"E:\path\to\file"` |
| PowerShell fails | Using forward slashes with PS | Use backslashes: `E:\path` |
| Relative path issues | pwd is in wrong location | Use absolute path with full `E:\...` |

## Environment Notes

**Current PhiWave Setup:**
- Working directory: `E:\PythonProjects\PhiWave`
- Git repo: `E:\PythonProjects\PhiWave\` (local, synced with GitHub)
- Python: Uses Windows Python installation
- Bash: Git Bash / WSL interop

**Recommended approach:** Always use absolute Windows paths with quotes to avoid environment-specific issues.

---

**Reference:** Added Oct 25, 2025 by IDE Claude
**Context:** Windows/bash path consistency for reliable automation
