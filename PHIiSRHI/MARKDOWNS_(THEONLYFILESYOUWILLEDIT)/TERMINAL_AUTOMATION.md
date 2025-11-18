# Terminal Automation Scripts - Usage Guide

Quick reference for opening and automating terminal windows via MCP.

---

## Scripts Provided

### 1. `open_terminal.ps1` - Full-featured terminal launcher
- Opens Windows Terminal, PowerShell 7, PowerShell, or CMD
- Brings window to foreground automatically
- Supports custom working directory, commands, and admin mode

### 2. `focus_terminal.ps1` - Quick launcher for MCP
- Simplified script for fast terminal opening
- Auto-detects best available terminal
- Optimized for MCP automation workflows

---

## Quick Start

### Open Terminal and Focus (Simple)

**Via MCP execute_powershell:**
```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\focus_terminal.ps1"
  }
}
```

**Via PowerShell:**
```powershell
.\focus_terminal.ps1
```

---

## open_terminal.ps1 - Advanced Usage

### Basic Examples

**1. Open Windows Terminal:**
```powershell
.\open_terminal.ps1
```

**2. Open PowerShell 7:**
```powershell
.\open_terminal.ps1 -TerminalType PowerShell7
```

**3. Open in Specific Directory:**
```powershell
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\MyProject"
```

**4. Open with Command:**
```powershell
.\open_terminal.ps1 -Command "Get-Process | Select-Object -First 10"
```

**5. Open as Administrator:**
```powershell
.\open_terminal.ps1 -Admin
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TerminalType` | String | `WindowsTerminal` | Terminal type: `WindowsTerminal`, `PowerShell7`, `PowerShell`, `CMD` |
| `-WorkingDirectory` | String | Current directory | Starting directory for terminal |
| `-Command` | String | Empty | Command to execute on startup |
| `-Admin` | Switch | False | Run as administrator |

### Via MCP

**Open Windows Terminal in Dev folder:**
```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\open_terminal.ps1 -WorkingDirectory 'C:\\Dev' -TerminalType WindowsTerminal"
  }
}
```

**Open PowerShell with command:**
```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\open_terminal.ps1 -TerminalType PowerShell -Command 'Get-ChildItem'"
  }
}
```

---

## MCP Workflow Patterns

### Pattern 1: Open Terminal → Send Keys

```javascript
// Step 1: Open terminal and focus
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\focus_terminal.ps1 -Directory 'C:\\Dev'"
  }
}

// Wait 1000ms for terminal to open and focus

// Step 2: Send commands via keyboard
{
  "name": "send_keys",
  "arguments": {
    "window_title": "PowerShell",  // or "Terminal" for Windows Terminal
    "keys": "cargo build --release{ENTER}"
  }
}
```

### Pattern 2: Open Terminal → Copy-Paste

```javascript
// Step 1: Copy command to clipboard
{
  "name": "set_clipboard",
  "arguments": {
    "content": "npm install && npm run build"
  }
}

// Step 2: Open terminal
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\focus_terminal.ps1"
  }
}

// Wait 1000ms

// Step 3: Paste and execute
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Terminal",
    "keys": "{CTRL}v{ENTER}"
  }
}
```

### Pattern 3: Multi-Terminal Workflow

```javascript
// Open Terminal 1 for backend
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\open_terminal.ps1 -WorkingDirectory 'C:\\Dev\\backend' -Command 'npm run dev'"
  }
}

// Wait 2000ms

// Open Terminal 2 for frontend
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\open_terminal.ps1 -WorkingDirectory 'C:\\Dev\\frontend' -Command 'npm run dev'"
  }
}
```

### Pattern 4: Open Terminal → Get Window Info

```javascript
// Step 1: Open terminal
{
  "name": "execute_powershell",
  "arguments": {
    "command": "C:\\Dev\\Windows-MCP\\focus_terminal.ps1"
  }
}

// Wait 1000ms

// Step 2: Get window details for automation
{
  "name": "get_window_info",
  "arguments": {
    "window_title": "Terminal"
  }
}
// Returns: {title, process_id, hwnd, is_focused, position, size}

// Step 3: Verify focused
// Check if response.is_focused === true before sending keys
```

---

## Terminal Detection Logic

Scripts automatically detect and use the best available terminal:

**Preference Order:**
1. **Windows Terminal** (`wt.exe`) - Modern, tabbed interface
2. **PowerShell 7** (`pwsh.exe`) - Cross-platform PowerShell
3. **Windows PowerShell** (`powershell.exe`) - Built-in
4. **CMD** (`cmd.exe`) - Fallback

**Fallback Chain:**
```
WindowsTerminal → PowerShell7 → PowerShell → CMD
```

---

## Window Focusing API

Both scripts use Windows API for reliable window focusing:

```csharp
[DllImport("user32.dll")]
public static extern bool SetForegroundWindow(IntPtr hWnd);

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
```

**Focus Process:**
1. Find process by name
2. Get main window handle
3. Restore window if minimized (`ShowWindow` with `SW_RESTORE`)
4. Bring to foreground (`SetForegroundWindow`)
5. Verify focus successful

**Timing:**
- Default wait: 500ms after launch
- Max focus attempt: 5 seconds
- Retry interval: 100ms

---

## Common Use Cases

### 1. Run Build Command

```powershell
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\MyProject" -Command "cargo build"
```

### 2. Start Dev Server

```powershell
.\open_terminal.ps1 -Command "npm run dev"
```

### 3. Open Multiple Terminals

```powershell
# Terminal 1 - Backend
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\backend"

# Terminal 2 - Frontend
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\frontend"

# Terminal 3 - Database
.\open_terminal.ps1 -Command "docker-compose up"
```

### 4. Admin Tasks

```powershell
.\open_terminal.ps1 -Admin -Command "Get-Service | Where-Object {$_.Status -eq 'Stopped'}"
```

### 5. Quick Directory Navigation

```powershell
.\focus_terminal.ps1 -Directory "C:\Windows\System32"
```

---

## Integration with MCP Tools

### Combine with send_keys

```javascript
// Open terminal
await mcp_call("execute_powershell", {
  command: "C:\\Dev\\Windows-MCP\\focus_terminal.ps1"
});

await sleep(1000);

// Type commands
await mcp_call("send_keys", {
  window_title: "Terminal",
  keys: "git status{ENTER}git pull{ENTER}"
});
```

### Combine with clipboard

```javascript
// Prepare complex command
const longCommand = `
Get-ChildItem -Recurse |
  Where-Object {$_.Extension -eq '.log'} |
  Select-Object Name, Length, LastWriteTime |
  Sort-Object LastWriteTime -Descending |
  Format-Table
`;

// Copy to clipboard
await mcp_call("set_clipboard", {content: longCommand});

// Open terminal
await mcp_call("execute_powershell", {
  command: "C:\\Dev\\Windows-MCP\\focus_terminal.ps1"
});

await sleep(1000);

// Paste and run
await mcp_call("send_keys", {
  window_title: "Terminal",
  keys: "{CTRL}v{ENTER}"
});
```

### Combine with window info

```javascript
// Open terminal
await mcp_call("execute_powershell", {
  command: "C:\\Dev\\Windows-MCP\\focus_terminal.ps1"
});

await sleep(1000);

// Get window details
const info = await mcp_call("get_window_info", {
  window_title: "Terminal"
});

console.log(`Terminal PID: ${info.process_id}`);
console.log(`Focused: ${info.is_focused}`);
console.log(`Position: ${info.position.x}, ${info.position.y}`);

// Automation only if focused
if (info.is_focused) {
  await mcp_call("send_keys", {
    keys: "echo 'Ready for automation'{ENTER}"
  });
}
```

---

## Troubleshooting

### Issue: Terminal Opens But Not Focused

**Cause:** Windows focus stealing prevention

**Solution 1:** Increase wait time
```powershell
.\open_terminal.ps1
Start-Sleep -Seconds 2  # Give Windows time to allow focus
```

**Solution 2:** Use focus_terminal.ps1 (has longer built-in delay)
```powershell
.\focus_terminal.ps1
```

### Issue: "Cannot find wt.exe"

**Cause:** Windows Terminal not installed

**Solution:** Script auto-falls back to PowerShell
```
WindowsTerminal not found. Falling back to PowerShell
```

Or install Windows Terminal:
```powershell
winget install Microsoft.WindowsTerminal
```

### Issue: send_keys Not Working After Open

**Cause:** Race condition - keys sent before window ready

**Solution:** Add delays
```javascript
// Open terminal
await execute_powershell({command: "focus_terminal.ps1"});

// Wait for terminal to be ready
await sleep(1500);  // Increase if needed

// Now send keys
await send_keys({keys: "echo test{ENTER}"});
```

### Issue: Wrong Terminal Window Focused

**Cause:** Multiple terminal instances

**Solution:** Use specific window title
```javascript
// Get exact title
const info = await get_window_info({window_title: "Terminal"});

// Use exact title for send_keys
await send_keys({
  window_title: info.title,  // Exact match
  keys: "commands here"
});
```

---

## Performance Tips

### 1. Use focus_terminal.ps1 for Speed

**Faster:**
```powershell
.\focus_terminal.ps1
```

**Slower (more features):**
```powershell
.\open_terminal.ps1 -TerminalType WindowsTerminal
```

### 2. Minimize Delays

```javascript
// Too conservative (slow)
await sleep(2000);

// Optimal for most cases
await sleep(1000);

// Fast but may race
await sleep(500);
```

### 3. Reuse Existing Terminals

Instead of opening new terminals, focus existing:
```json
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Terminal",
    "keys": "{ENTER}clear{ENTER}new command{ENTER}"
  }
}
```

---

## Script Locations

```
C:\Dev\Windows-MCP\
├── open_terminal.ps1          # Full-featured launcher
├── focus_terminal.ps1         # Quick launcher
├── TERMINAL_AUTOMATION.md     # This guide
└── WINDOW_AUTOMATION_GUIDE.md # General automation reference
```

---

## Examples Collection

### Developer Workflow

```powershell
# Open project, run build, run tests
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\MyProject" -Command "cargo build && cargo test"
```

### System Administration

```powershell
# Open admin terminal for service management
.\open_terminal.ps1 -Admin -Command "Get-Service | Where-Object {$_.Status -eq 'Running'}"
```

### Multi-Environment Setup

```powershell
# Backend
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\backend" -TerminalType PowerShell7

# Frontend
.\open_terminal.ps1 -WorkingDirectory "C:\Dev\frontend" -TerminalType PowerShell7

# Database
.\open_terminal.ps1 -Command "docker-compose up database"
```

### Quick Commands

```powershell
# Git status in project
.\focus_terminal.ps1 -Directory "C:\Dev\MyRepo"
# Then use send_keys for: git status{ENTER}

# Navigate to logs
.\focus_terminal.ps1 -Directory "C:\Logs"

# Open at current location
.\focus_terminal.ps1
```

---

**Created:** November 15, 2025
**Version:** 1.0.0
**For:** Windows MCP Server v1.0.0
**Scripts:** 2 terminal automation utilities

**See also:** [WINDOW_AUTOMATION_GUIDE.md](WINDOW_AUTOMATION_GUIDE.md) for complete MCP automation patterns
