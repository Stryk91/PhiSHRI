# Windows MCP - Window Automation & Workflow Guide

**Complete reference for window focusing, clipboard operations, and keyboard automation using the Windows MCP server.**

---

## 📋 Table of Contents

1. [Quick Reference](#quick-reference)
2. [Window Management](#window-management)
3. [Clipboard Workflows](#clipboard-workflows)
4. [Keyboard Automation](#keyboard-automation)
5. [Complete Workflow Examples](#complete-workflow-examples)
6. [PowerShell Integration](#powershell-integration)
7. [AutoHotkey Patterns](#autohotkey-patterns)
8. [PowerToys Integration](#powertoys-integration)
9. [Troubleshooting](#troubleshooting)

---

## Quick Reference

### Available MCP Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `list_windows` | List all visible windows | None |
| `get_window_info` | Get window details | `window_title` (fuzzy match) |
| `send_keys` | Send keyboard input | `keys`, `window_title` (optional), `delay_ms` |
| `get_clipboard` | Read clipboard text | None |
| `set_clipboard` | Write clipboard text | `content` |
| `execute_powershell` | Run PowerShell commands | `command`, `timeout` |

### Special Key Syntax

```
Regular text:  "Hello World"
Special keys:  {ENTER}, {TAB}, {ESC}, {BACKSPACE}, {DELETE}
Navigation:    {LEFT}, {RIGHT}, {UP}, {DOWN}, {HOME}, {END}
Page:          {PAGEUP}, {PAGEDOWN}
Modifiers:     {CTRL}, {SHIFT}, {ALT}, {WIN}
```

---

## Window Management

### 1. List All Open Windows

**MCP Call:**
```json
{
  "name": "list_windows",
  "arguments": {}
}
```

**Response:**
```json
{
  "windows": [
    {"title": "Google Chrome", "hwnd": 123456},
    {"title": "Visual Studio Code", "hwnd": 234567},
    {"title": "Notepad", "hwnd": 345678}
  ]
}
```

### 2. Get Detailed Window Information

**MCP Call (Fuzzy Match):**
```json
{
  "name": "get_window_info",
  "arguments": {
    "window_title": "chrome"
  }
}
```

**Response:**
```json
{
  "title": "Google Chrome - Stack Overflow",
  "process_name": "chrome.exe",
  "process_id": 12345,
  "hwnd": 987654,
  "is_focused": true,
  "position": {"x": 100, "y": 50},
  "size": {"width": 1920, "height": 1080}
}
```

**Use Cases:**
- Verify window exists before automation
- Check if window is focused
- Get window position for screenshot coordination
- Validate process name for security

### 3. Focus Window Before Automation

**Pattern 1: Using send_keys with window_title**
```json
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Notepad",
    "keys": "Hello World{ENTER}"
  }
}
```
*Note: MCP server automatically focuses the window before sending keys*

**Pattern 2: Using PowerShell**
```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "$wshell = New-Object -ComObject WScript.Shell; $wshell.AppActivate('Notepad')"
  }
}
```

**Pattern 3: Manual Focus + Delay**
```powershell
# Focus window and wait
Add-Type -AssemblyName System.Windows.Forms
$window = [System.Windows.Forms.Application]::OpenForms | Where-Object {$_.Text -like '*Chrome*'}
$window.Activate()
Start-Sleep -Milliseconds 500
```

---

## Clipboard Workflows

### 1. Copy Text to Clipboard

**MCP Call:**
```json
{
  "name": "set_clipboard",
  "arguments": {
    "content": "Text to copy"
  }
}
```

**Response:**
```json
{
  "success": true,
  "bytes": 12
}
```

### 2. Read Clipboard Content

**MCP Call:**
```json
{
  "name": "get_clipboard",
  "arguments": {}
}
```

**Response:**
```json
{
  "content": "Current clipboard text"
}
```

### 3. Copy-Paste Workflow

**Example: Copy from Browser to Notepad**

```javascript
// Step 1: Focus browser and select all
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "{CTRL}a{CTRL}c"
  }
}

// Step 2: Wait for clipboard
// (Add 500ms delay in workflow)

// Step 3: Focus Notepad and paste
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Notepad",
    "keys": "{CTRL}v"
  }
}
```

**Alternative: Direct Clipboard Transfer**

```javascript
// Step 1: Get clipboard from source
{
  "name": "get_clipboard",
  "arguments": {}
}
// Returns: {"content": "Source text"}

// Step 2: Set clipboard for destination
{
  "name": "set_clipboard",
  "arguments": {
    "content": "Modified text from source"
  }
}

// Step 3: Paste in destination
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Destination App",
    "keys": "{CTRL}v"
  }
}
```

---

## Keyboard Automation

### 1. Basic Text Input

**Simple Text:**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "Hello, World!"
  }
}
```

**Multi-line Text:**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "Line 1{ENTER}Line 2{ENTER}Line 3"
  }
}
```

### 2. Keyboard Shortcuts

**Ctrl+S (Save):**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{CTRL}s"
  }
}
```

**Ctrl+Shift+N (New Incognito Window in Chrome):**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{CTRL}{SHIFT}n"
  }
}
```

**Alt+F4 (Close Window):**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{ALT}{F4}"
  }
}
```

**Win+R (Run Dialog):**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{WIN}r"
  }
}
```

### 3. Navigation Keys

**Tab Navigation:**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{TAB}{TAB}{ENTER}"
  }
}
```

**Arrow Keys (Menu Navigation):**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{DOWN}{DOWN}{ENTER}"
  }
}
```

**Home/End (Line Navigation):**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{HOME}Select this line{END}"
  }
}
```

### 4. Advanced Sequences

**Delete Line and Type New:**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{HOME}{SHIFT}{END}{DELETE}New line content"
  }
}
```

**Select All and Replace:**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{CTRL}a{DELETE}Replacement text"
  }
}
```

---

## Complete Workflow Examples

### Workflow 1: Open Notepad and Write File

```javascript
// Step 1: Open Run dialog
{
  "name": "send_keys",
  "arguments": {
    "keys": "{WIN}r"
  }
}

// Wait 200ms

// Step 2: Type notepad and open
{
  "name": "send_keys",
  "arguments": {
    "keys": "notepad{ENTER}"
  }
}

// Wait 500ms for Notepad to open

// Step 3: Type content
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Notepad",
    "keys": "This is a test file.{ENTER}Created by Windows MCP."
  }
}

// Step 4: Save file (Ctrl+S)
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Notepad",
    "keys": "{CTRL}s"
  }
}

// Wait 300ms for Save dialog

// Step 5: Type filename and save
{
  "name": "send_keys",
  "arguments": {
    "keys": "C:\\Temp\\test.txt{ENTER}"
  }
}
```

### Workflow 2: Search Google and Copy Result

```javascript
// Step 1: Focus Chrome
{
  "name": "get_window_info",
  "arguments": {
    "window_title": "Chrome"
  }
}

// Step 2: Open new tab
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "{CTRL}t"
  }
}

// Step 3: Type search query
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "Windows automation PowerShell{ENTER}"
  }
}

// Wait 2000ms for page load

// Step 4: Select all text
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "{CTRL}a{CTRL}c"
  }
}

// Step 5: Read clipboard
{
  "name": "get_clipboard",
  "arguments": {}
}
```

### Workflow 3: Fill Web Form

```javascript
// Step 1: Focus browser on form page
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "{TAB}John Doe{TAB}john@example.com{TAB}555-1234{ENTER}"
  }
}
```

**With Clipboard for Long Text:**
```javascript
// Step 1: Prepare long text in clipboard
{
  "name": "set_clipboard",
  "arguments": {
    "content": "Very long text that would be tedious to type..."
  }
}

// Step 2: Focus form field and paste
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "{TAB}{TAB}{CTRL}v{TAB}"
  }
}
```

### Workflow 4: Transfer Data Between Apps

```javascript
// Step 1: Copy from Excel
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Excel",
    "keys": "{CTRL}c"
  }
}

// Step 2: Get clipboard content
{
  "name": "get_clipboard",
  "arguments": {}
}
// Process/transform data in Claude

// Step 3: Set modified content
{
  "name": "set_clipboard",
  "arguments": {
    "content": "Processed data"
  }
}

// Step 4: Paste in destination
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Word",
    "keys": "{CTRL}v"
  }
}
```

---

## PowerShell Integration

### Pattern 1: Hybrid MCP + PowerShell

**Focus window via PowerShell, automate via MCP:**

```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.Interaction]::AppActivate('Notepad')"
  }
}
```

Then use MCP send_keys:
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "Text to insert"
  }
}
```

### Pattern 2: PowerShell for Complex Window Logic

**Get window by PID:**
```powershell
$processId = 12345
$sig = '[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);'
Add-Type -MemberDefinition $sig -Name WinAPI -Namespace Win32
$process = Get-Process -Id $processId
[Win32.WinAPI]::SetForegroundWindow($process.MainWindowHandle)
```

**Minimize all windows except target:**
```powershell
$targetTitle = "Visual Studio Code"
Get-Process | Where-Object {$_.MainWindowTitle -and $_.MainWindowTitle -ne $targetTitle} |
    ForEach-Object {
        $sig = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
        Add-Type -MemberDefinition $sig -Name WinAPI -Namespace Win32
        [Win32.WinAPI]::ShowWindow($_.MainWindowHandle, 6) # SW_MINIMIZE
    }
```

### Pattern 3: Clipboard via PowerShell

**Read clipboard:**
```powershell
Get-Clipboard
```

**Write clipboard:**
```powershell
Set-Clipboard -Value "Text to copy"
```

**Monitor clipboard changes:**
```powershell
$previousClipboard = Get-Clipboard
while ($true) {
    Start-Sleep -Milliseconds 500
    $currentClipboard = Get-Clipboard
    if ($currentClipboard -ne $previousClipboard) {
        Write-Host "Clipboard changed: $currentClipboard"
        $previousClipboard = $currentClipboard
    }
}
```

---

## AutoHotkey Patterns

### AHK Script Integration

**Launch AHK script via MCP:**
```json
{
  "name": "execute_powershell",
  "arguments": {
    "command": "Start-Process 'C:\\AutoHotkey\\AutoHotkey.exe' -ArgumentList 'C:\\Scripts\\automation.ahk'"
  }
}
```

### Common AHK Equivalents in MCP

| AHK Command | MCP Equivalent |
|-------------|----------------|
| `WinActivate, Notepad` | `send_keys` with `window_title: "Notepad"` |
| `Send, Hello` | `send_keys` with `keys: "Hello"` |
| `Send, ^c` | `send_keys` with `keys: "{CTRL}c"` |
| `Clipboard := "text"` | `set_clipboard` with `content: "text"` |
| `MsgBox, %Clipboard%` | `get_clipboard` |
| `Sleep, 1000` | Add delay in workflow (1000ms) |

### AHK Hotkey Triggers

**Example AHK Script (C:\Scripts\mcp_bridge.ahk):**
```autohotkey
; Trigger MCP automation with Ctrl+Shift+M
^+m::
    ; Call PowerShell to invoke MCP tool
    RunWait, powershell.exe -Command "& {claude-code mcp call send_keys --keys 'Automated text'}"
return

; Copy and process clipboard with Ctrl+Shift+C
^+c::
    Send, ^c
    Sleep, 100
    clipboard_content := clipboard
    ; Send to MCP for processing
    RunWait, powershell.exe -Command "& {claude-code mcp call set_clipboard --content '" . clipboard_content . "'}"
return
```

---

## PowerToys Integration

### PowerToys Run Integration

**Launch apps via MCP then automate:**

```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{ALT}{SPACE}notepad{ENTER}"
  }
}
```
*Note: Alt+Space opens PowerToys Run*

### FancyZones + Window Automation

**Get window info, then move with PowerToys:**

```javascript
// Step 1: Get window details
{
  "name": "get_window_info",
  "arguments": {
    "window_title": "Chrome"
  }
}

// Step 2: Use PowerToys shortcuts to move window
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Chrome",
    "keys": "{WIN}{CTRL}{ALT}1"  // Move to FancyZone 1
  }
}
```

### PowerToys Keyboard Manager

**Remap keys for MCP workflows:**

1. Open PowerToys Keyboard Manager
2. Remap key combinations to trigger workflows:
   - `Ctrl+Shift+1` → Run MCP automation script
   - `Ctrl+Shift+2` → Copy to MCP clipboard

**Execute from MCP:**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "{CTRL}{SHIFT}1"
  }
}
```

### PowerToys Color Picker + Clipboard

```javascript
// Step 1: Trigger color picker (Win+Shift+C default)
{
  "name": "send_keys",
  "arguments": {
    "keys": "{WIN}{SHIFT}c"
  }
}

// Wait for user to pick color

// Step 2: Read clipboard (color copied automatically)
{
  "name": "get_clipboard",
  "arguments": {}
}
// Returns: {"content": "#FF5733"}
```

---

## Troubleshooting

### Issue: Window Not Found

**Symptom:**
```json
{
  "error": "No window found matching: chrome"
}
```

**Solution 1: List all windows first**
```json
{
  "name": "list_windows",
  "arguments": {}
}
```

**Solution 2: Use exact title**
```json
{
  "name": "get_window_info",
  "arguments": {
    "window_title": "Google Chrome"  // Full title
  }
}
```

### Issue: Keys Not Sending

**Symptom:** send_keys succeeds but nothing happens

**Solution 1: Add window focus**
```json
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Target App",  // Explicitly focus
    "keys": "Text"
  }
}
```

**Solution 2: Increase delay**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "Text",
    "delay_ms": 50  // Default is 10ms
  }
}
```

**Solution 3: Check window state**
```powershell
# Via PowerShell
Get-Process | Where-Object {$_.MainWindowTitle -like '*Target*'} |
    Select-Object Id, MainWindowTitle, Responding
```

### Issue: Clipboard Empty

**Symptom:**
```json
{
  "content": ""
}
```

**Solution: Verify clipboard has text**
```powershell
Get-Clipboard
```

**Check clipboard history (Win 11):**
- Press `Win+V` to open clipboard history
- Ensure text format (not image/file)

### Issue: Special Keys Not Working

**Symptom:** `{ENTER}` appears as literal text

**Solution: Check syntax**
```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "Correct{ENTER}"  // ✅ Correct
  }
}
```

```json
{
  "name": "send_keys",
  "arguments": {
    "keys": "Incorrect{Enter}"  // ❌ Case-sensitive
  }
}
```

### Issue: Window Focus Race Condition

**Symptom:** Keys sent before window focused

**Solution: Add delays in workflow**
```javascript
// Step 1: Focus window
{
  "name": "send_keys",
  "arguments": {
    "window_title": "Notepad",
    "keys": ""  // Empty keys just to focus
  }
}

// Wait 300ms

// Step 2: Send actual keys
{
  "name": "send_keys",
  "arguments": {
    "keys": "Now this works"
  }
}
```

---

## Advanced Patterns

### Pattern: Batch Window Operations

```javascript
// Get list of all windows
const windows = await mcp_call("list_windows");

// Filter Chrome windows
const chromeWindows = windows.windows.filter(w =>
  w.title.includes("Chrome")
);

// Close all except first
for (let i = 1; i < chromeWindows.length; i++) {
  await mcp_call("send_keys", {
    window_title: chromeWindows[i].title,
    keys: "{ALT}{F4}"
  });
}
```

### Pattern: Clipboard Pipeline

```javascript
// Multi-stage clipboard processing
async function clipboardPipeline(transformFn) {
  // 1. Get current clipboard
  const result = await mcp_call("get_clipboard");

  // 2. Transform data
  const transformed = transformFn(result.content);

  // 3. Set back to clipboard
  await mcp_call("set_clipboard", {
    content: transformed
  });

  return transformed;
}

// Usage: Convert clipboard to uppercase
await clipboardPipeline(text => text.toUpperCase());
```

### Pattern: Window Focus Queue

```javascript
// Focus windows in sequence with automation
const sequence = [
  {window: "Chrome", action: "{CTRL}t"},
  {window: "VSCode", action: "{CTRL}s"},
  {window: "Notepad", action: "{CTRL}v"}
];

for (const step of sequence) {
  await mcp_call("send_keys", {
    window_title: step.window,
    keys: step.action
  });
  await sleep(500);  // Wait between steps
}
```

---

## Best Practices

### ✅ Do's

1. **Always verify window exists** before automation
   ```javascript
   const info = await mcp_call("get_window_info", {window_title: "Target"});
   if (info.error) {
     console.error("Window not found");
     return;
   }
   ```

2. **Use delays between steps** (200-500ms typical)

3. **Use clipboard for large text** instead of send_keys

4. **Test special keys** in isolation first

5. **Log all automation steps** for debugging

### ❌ Don'ts

1. **Don't assume window focus** - always check `is_focused`

2. **Don't send keys too fast** - use `delay_ms` parameter

3. **Don't rely on window position** - it may change

4. **Don't automate password fields** - security risk

5. **Don't ignore errors** - handle window not found gracefully

---

## Quick Command Reference

### Window Operations
```bash
# List windows
list_windows

# Get window details (fuzzy match)
get_window_info --window_title "chrome"

# Check if window is focused
get_window_info --window_title "notepad" | jq .is_focused
```

### Keyboard Operations
```bash
# Simple text
send_keys --keys "Hello World"

# With special keys
send_keys --keys "Line 1{ENTER}Line 2"

# Target specific window
send_keys --window_title "Notepad" --keys "Targeted text"

# Keyboard shortcut
send_keys --keys "{CTRL}s"
```

### Clipboard Operations
```bash
# Read clipboard
get_clipboard

# Write clipboard
set_clipboard --content "Copy this text"

# Copy-paste workflow
send_keys --window_title "Source" --keys "{CTRL}a{CTRL}c"
send_keys --window_title "Dest" --keys "{CTRL}v"
```

---

**Created:** November 15, 2025
**Version:** 1.0.0
**For:** Windows MCP Server v1.0.0 (Phase 4)
**Total Tools Covered:** 6 automation tools

**Questions?** Check [PhiDEX UI Automation Guide](C:\Dev\CODEX\PhiDEX\MASTER_CODEX\07_UI_AUTOMATION\UI_AUTOMATION_COMPREHENSIVE_GUIDE.md) for advanced patterns.
