# PhiSHRI Project Instructions

## Session Startup Protocol

When starting a new session in this project, **ALWAYS** follow this startup sequence:

1. **Read the bootstrap file FIRST:**
   ```
   Read: C:\Temp\VSCC_SESSION_BOOTSTRAP.md
   ```
   This contains:
   - Current progress (293 doors as of Batch 10A)
   - What was last completed
   - Next batch options
   - All commands and workflows needed

2. **Verify current state:**
   ```
   Read: C:\Dev\PhiSHRI\PhiSHRI\INDEX.json
   ```
   Check `total_doors` field matches bootstrap file

3. **Load PhiSHRI overview if first time:**
   ```
   Read: C:\Dev\PhiSHRI\PhiSHRI\CONTEXTS\PROJECTS\000START.json
   Read: C:\Dev\PhiSHRI\PhiSHRI\CONTEXTS\PROJECTS\P05SESSION_CONT.json
   ```

4. **Ready to continue work!**
   - Ask user which batch direction to pursue (5 options in bootstrap)
   - Or follow explicit user instructions

## Key Facts
- **Project:** PhiSHRI (Semantic Hash Repository Index)
- **Current state:** 293 doors total (207 remaining to 500)
- **Goal:** 500+ doors
- **Folder name:** PhiSHRI (NOT PhiSRHI - old typo)
- **Bootstrap location:** C:\Temp\VSCC_SESSION_BOOTSTRAP.md
- **Rebuild indexes command:** `cd /c/Temp && python rebuild_phishri_indexes.py`
- **Enterprise narrative:** Security (S26-S35) + DevOps (T30-T44) = CTO pitch complete

## Zero Hallucinations Protocol
All door content must be extracted from PhiDEX source files only. Never invent content.

## Efficiency Patterns
- Use parallel Read calls (5-7 doors in single message)
- Generate doors via Python scripts for batch operations
- Rebuild indexes after adding doors
- Update bootstrap file after completing each batch
