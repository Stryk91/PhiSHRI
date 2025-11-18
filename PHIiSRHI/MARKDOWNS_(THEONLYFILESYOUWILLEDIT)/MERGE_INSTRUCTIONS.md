# PhiSync Branch Merge Instructions

## Overview

This repository contains PhiSync codex content across 3 branches covering 10 knowledge domains. This guide consolidates them into a clean `main` branch.

## Current Branch Structure

**Remote Branches on GitHub:**
1. `claude/phisync-multi-agent-codex-01NgkDHiJeW3CdcJB7T5wjGu` - Domains 1-3
2. `claude/phisync-webc2-domains-4-7-01JmajMwpU8mfDDnuVNKczTF` - Domains 4-7
3. `claude/phisync-webc3-domains-8-10-018FvJhYEJ3GWoWB7QewW4Xh` - Domains 8-10
4. `claude/phidex-repository-work-01KPNLJKAT2vaXVk9xXT5G3F` - Default branch
5. `claude/webc-autonomous-daemon-research-011i8oU5iRDToucNGxa56mk6` - Research

**Goal:** Merge all PhiSync branches → Create clean `main` branch → Delete feature branches

## Execution Steps

### Step 1: Run Merge Script

Execute the merge script to consolidate all PhiSync branches:

```powershell
cd C:\Dev\CODEX\PhiDEX
.\phisync_merge.ps1
```

**What it does:**
1. Fetches all remote branches
2. Creates `phisync-complete` branch
3. Merges all 3 PhiSync branches in order (no conflicts expected - different domains)
4. Creates `main` branch from `phisync-complete`
5. Checks out `main` branch

**Expected Output:** Clean `main` branch with all 10 PhiSync domains integrated

### Step 2: Verify Content

Check that all PhiSync content is present:

```powershell
# Check directory structure
Get-ChildItem -Recurse -Directory | Where-Object { $_.Name -match "phisync|domain" }

# Check commit history
git log --oneline --graph --all -20

# Verify all 10 domains are present
ls *.md | Select-String -Pattern "domain"
```

### Step 3: Run Cleanup Script

After verifying content, clean up old branches:

```powershell
.\phisync_cleanup.ps1
```

**What it does:**
1. Verifies you're on `main` branch
2. Pushes `main` to GitHub
3. Deletes local feature branches
4. Prompts for confirmation to delete remote branches
5. Deletes remote feature branches (if confirmed)

**Warning:** Step 4 deletes branches from GitHub. Review carefully before confirming.

### Step 4: Set Default Branch (Manual)

Go to GitHub repository settings and set `main` as the default branch:

1. Navigate to: https://github.com/Stryk91/PhiDEX/settings/branches
2. Change default branch from `claude/phidex-repository-work-...` to `main`
3. Confirm the change

### Step 5: Final Verification

```powershell
# Verify only main branch exists locally
git branch

# Verify main is pushed and tracked
git status

# Verify all PhiSync content is accessible
git log --oneline --all -10
```

## Troubleshooting

### Git Commands Not Working

If you encounter "git not recognized" errors:

1. **Using DC (with fixed MCP server):**
   - Restart Claude Desktop to load the new MCP server binary
   - Use DC's `execute_powershell` tool to run the scripts

2. **Using regular PowerShell:**
   - Ensure Git is in your PATH
   - Try: `& "C:\Program Files\Git\cmd\git.exe" --version`

### Merge Conflicts

If merge conflicts occur (unlikely for different domain files):

```powershell
# View conflicts
git status

# Resolve manually or use a merge tool
git mergetool

# After resolving
git add .
git commit -m "Resolve merge conflicts"
```

### Fork Bomb Error

If you see "BUG (fork bomb): C:\Program Files\Git\bin\git.exe":

This is a known issue with the current environment. Use one of these workarounds:

1. **Run scripts through DC** with the fixed MCP server
2. **Use Git Bash** instead of PowerShell
3. **Use a different terminal** (Windows Terminal, VS Code terminal)

## Success Criteria

✅ All PhiSync branches merged into `main`
✅ All 10 knowledge domains present in `main`
✅ `main` branch pushed to GitHub
✅ Old feature branches deleted (local + remote)
✅ `main` set as default branch on GitHub
✅ Clean repository structure

## Rollback Plan

If something goes wrong:

```powershell
# Abort any in-progress merge
git merge --abort

# Reset to original state
git checkout claude/phidex-repository-work-01KPNLJKAT2vaXVk9xXT5G3F

# Delete failed branches
git branch -D main phisync-complete
```

## Notes

- The merge scripts use `--no-ff` to preserve branch history
- Commit messages clearly identify which domains were merged
- Feature branches are preserved on remote until cleanup script confirmation
- All operations are logged to git history for auditability

## Created

2025-11-16 - Automated PhiSync consolidation scripts
