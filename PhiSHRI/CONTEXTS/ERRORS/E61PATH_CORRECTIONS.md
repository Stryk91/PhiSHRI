# E61 - KALIC Path Corrections

## PURPOSE
Canonical paths for KALIC. Reference this when unsure about tool locations.

## THE MISTAKES
These wrong paths get used repeatedly - DO NOT USE:

| WRONG | RIGHT |
|-------|-------|
| `~/.cargo/bin/cargo` | `/mnt/c/Users/Stryker_LOCAL/.cargo/bin/cargo.exe` |
| `/mnt/x/AHK SCRIPTS/` | `/mnt/x/AHK  SCRIPTS/` (TWO spaces!) |
| `pwsh` or `pwsh.exe` | `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` |
| `powershell` | `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` |

## CANONICAL PATH TABLE
```
TOOL            PATH
----            ----
cargo           /mnt/c/Users/Stryker_LOCAL/.cargo/bin/cargo.exe
rustc           /mnt/c/Users/Stryker_LOCAL/.cargo/bin/rustc.exe
ahk             /mnt/c/Program Files/AHK/v2/AutoHotkey64.exe
ahk_scripts     /mnt/x/AHK  SCRIPTS/
powershell      /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
cmd             /mnt/c/Windows/System32/cmd.exe
kalic_msg       /mnt/c/PhiDEX/scripts/kalic_msg.bat
brain           /mnt/c/PhiDEX/kalic_brain/
tool_schemas    /mnt/c/PhiDEX/tool_schemas/
carbyne         /mnt/x/carbyne-cli/target/release/carbyne.exe
```

## WHY THESE MATTER
- **cargo**: Linux cargo won't build Windows binaries
- **AHK SCRIPTS**: Double space in name - filesystem, not typo
- **pwsh7**: Not installed. PowerShell 5.1 via WindowsPowerShell path only

## SENDING TO DC
```bash
# CORRECT - use batch wrapper
/mnt/c/Windows/System32/cmd.exe /c 'C:\PhiDEX\scripts\kalic_msg.bat "YOUR MESSAGE"'

# WRONG - PowerShell Start-Process breaks on double-space paths
powershell.exe -Command "Start-Process..."  # NO!
```

## RELATED
- S00KALIC_SESSION_BOOT - full session context
- cerebellum.md - execution commands
