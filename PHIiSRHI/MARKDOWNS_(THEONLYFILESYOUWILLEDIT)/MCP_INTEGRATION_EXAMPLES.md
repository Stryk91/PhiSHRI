# PhiLaunch × MCP Screen Control - Integration Examples

Complete integration guide showing how **ClaudeEyes**, **PhiLaunch CodeGen**, and **MCP Screen Control** work together.

---

## 🎯 The Power Trinity

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ClaudeEyes          CodeGen           MCP Screen Control │
│   (AI Vision)    +    (Code Gen)    +   (AI Interaction)  │
│   ────────────        ──────────         ───────────────── │
│   • Screen capture    • Generate PS1     • Mouse control   │
│   • Region select     • Offline AI       • Keyboard input  │
│   • OCR text          • 50 templates     • Clipboard ops   │
│   • Config save       • Multi-language   • OCR detection   │
│                                                             │
│                    = FULL AUTOMATION                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Example 1: AI-Assisted Form Filling

### Scenario
User asks: *"Fill out this registration form for me"*

### Workflow

**Step 1: ClaudeEyes captures form layout**
```powershell
# User defines regions using ClaudeEyes GUI
# - Input region: Form fields area
# - Response region: Confirmation message area

# Saved to: ClaudeEyes_Config.json
{
  "input": {
    "x1": 450, "y1": 200,
    "x2": 800, "y2": 600
  },
  "response": {
    "x1": 450, "y1": 650,
    "x2": 800, "y2": 700
  }
}
```

**Step 2: MCP Screen Control detects fields**
```python
# AI uses MCP tools to find form fields
result = await mcp.call_tool("find_text_element", {
    "text": "Name:",
    "fuzzy": True
})

# Returns: {"found": True, "element": {"x": 460, "y": 220, ...}}
```

**Step 3: CodeGen creates automation script**
```powershell
# AI generates PowerShell script on-the-fly
./New-CodeFromPrompt.ps1 `
    -Prompt "Fill registration form with name, email, and phone validation" `
    -Language PowerShell `
    -OutputPath "Fill-RegistrationForm.ps1"
```

**Step 4: Execute workflow**
```python
# MCP executes the steps
await mcp.call_tool("click_text_element", {"text": "Name:"})
await mcp.call_tool("type_text", {"text": "John Doe"})
await mcp.call_tool("press_key", {"keys": ["tab"]})
await mcp.call_tool("type_text", {"text": "john@example.com"})
# ... continue for all fields
await mcp.call_tool("click_text_element", {"text": "Submit"})
```

**Step 5: ClaudeEyes reads confirmation**
```ahk
; Capture response region
Send ^!c  ; Hotkey to capture

; AI reads: captured_response.txt
"Registration successful! Welcome, John Doe."
```

---

## Example 2: Automated Data Entry from CSV

### Scenario
User asks: *"Read this CSV and fill the data into the web form"*

### Workflow

**Step 1: Use generated script to parse CSV**
```powershell
# One of the 50 generated scripts
.\Get-CSVData.ps1 -Path "users.csv"

# Returns:
# Name,Email,Phone
# Alice,alice@example.com,555-0001
# Bob,bob@example.com,555-0002
```

**Step 2: Generate form filler script**
```powershell
.\New-CodeFromPrompt.ps1 `
    -Prompt "Fill web form row by row from CSV data with error handling" `
    -Language PowerShell `
    -IncludeTests
```

**Step 3: MCP + ClaudeEyes loop through rows**
```python
# For each CSV row
for row in csv_data:
    # Click first field
    await mcp.call_tool("click_text_element", {"text": "Name:"})
    await mcp.call_tool("type_text", {"text": row["Name"]})

    # Tab to next field
    await mcp.call_tool("press_key", {"keys": ["tab"]})
    await mcp.call_tool("type_text", {"text": row["Email"]})

    # Continue...

    # Submit
    await mcp.call_tool("click_text_element", {"text": "Submit"})

    # Wait for confirmation using ClaudeEyes region
    await mcp.call_tool("take_screenshot", {"region": response_region})
    confirmation = await mcp.call_tool("ocr_screen", {"region": response_region})

    # Log result
    print(f"Row {i}: {confirmation['text']}")
```

---

## Example 3: Continuous Monitoring & Alerts

### Scenario
User asks: *"Monitor this dashboard and alert me if errors appear"*

### Workflow

**Step 1: ClaudeEyes defines monitoring region**
```powershell
# User selects error message area in ClaudeEyes
# Saved as "error_region" in config
```

**Step 2: Generate monitoring script**
```powershell
.\New-CodeFromPrompt.ps1 `
    -Prompt "Monitor screen region and send alert on error pattern" `
    -Language PowerShell `
    -OutputPath "Monitor-Dashboard.ps1"
```

**Step 3: Run continuous monitoring**
```powershell
# Generated script (Monitor-Dashboard.ps1)
while ($true) {
    # Take screenshot of error region
    $screenshot = & "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" `
        "C:\Users\Stryker\Desktop\VSCC_AHK_FILES\CLAUDE_EYES.ahk" `
        -CaptureRegion "error_region"

    # Read text from region
    $text = Get-Content "captured_response.txt"

    # Check for error patterns
    if ($text -match "error|failed|exception") {
        # Send alert
        Show-NotificationToast.ps1 `
            -Title "Dashboard Alert" `
            -Message "Error detected: $text"

        # Log incident
        Add-Content "dashboard_errors.log" `
            "$(Get-Date) - $text"
    }

    Start-Sleep -Seconds 30
}
```

---

## Example 4: Code Generation Based on Screen Content

### Scenario
User: *"Look at this API documentation on screen and generate a client for it"*

### Workflow

**Step 1: ClaudeEyes captures API docs**
```ahk
; Select documentation region
; Capture with Ctrl+Alt+C
```

**Step 2: MCP OCR reads the content**
```python
# AI reads screen content
docs = await mcp.call_tool("ocr_screen", {
    "region": [100, 100, 800, 600]
})

# Parsed text:
# "POST /api/users
#  Body: {name: string, email: string}
#  Returns: {id: number, status: string}"
```

**Step 3: CodeGen creates API client**
```powershell
# AI analyzes docs and generates prompt
.\New-CodeFromPrompt.ps1 `
    -Prompt "Create REST API client for /api/users endpoint with POST method accepting name and email" `
    -Language PowerShell `
    -IncludeDocs `
    -OutputPath "Invoke-UserAPI.ps1"
```

**Step 4: Generated client is ready**
```powershell
# Invoke-UserAPI.ps1 (generated)
function Invoke-UserAPI {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidatePattern('^\w+@\w+\.\w+$')]
        [string]$Email
    )

    $body = @{
        name = $Name
        email = $Email
    } | ConvertTo-Json

    Invoke-RestMethod `
        -Uri "https://api.example.com/api/users" `
        -Method POST `
        -Body $body `
        -ContentType "application/json"
}

# Usage:
# Invoke-UserAPI -Name "Alice" -Email "alice@example.com"
```

---

## Example 5: Multi-Tool Workflow Automation

### Scenario
Complete workflow: **"Scrape data → Process → Generate report → Email"**

### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: MCP Screen Control                                 │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ • Navigate to website                                   │ │
│ │ • Click through pagination                              │ │
│ │ • ClaudeEyes captures data regions                      │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Use Generated Script (Search-FileContent.ps1)      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ • Extract data using regex                              │ │
│ │ • Clean and validate                                    │ │
│ │ • Store in structured format                            │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: CodeGen Creates Report Generator                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ./New-CodeFromPrompt.ps1 \                              │ │
│ │   -Prompt "Generate HTML report with charts from data"  │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 4: Use Generated Script (Show-ChartVisualization.ps1) │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ • Create interactive charts                             │ │
│ │ • Build HTML dashboard                                  │ │
│ │ • Save to file                                          │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 5: MCP + ClaudeEyes Email Report                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ • Open email client                                     │ │
│ │ • Attach report                                         │ │
│ │ • ClaudeEyes confirms send                              │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```powershell
# Master automation script
$workflow = @{
    Step1 = { Invoke-WebScraping }
    Step2 = { Process-Data }
    Step3 = { Generate-Report }
    Step4 = { Send-Email }
}

# Execute each step
foreach ($step in $workflow.Keys | Sort-Object) {
    Write-Host "Executing $step..." -ForegroundColor Cyan

    try {
        & $workflow[$step]
        Write-Host "✅ $step complete" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ $step failed: $_" -ForegroundColor Red
        # ClaudeEyes captures error screen
        # MCP alerts user
        break
    }
}
```

---

## Real-World Use Cases

### 1. **Automated Testing**
- ClaudeEyes defines UI element regions
- MCP clicks through test scenarios
- CodeGen generates test reports
- All actions logged for audit

### 2. **Data Migration**
- MCP extracts data from legacy UI
- Generated scripts transform data
- ClaudeEyes validates migration
- Reports sent automatically

### 3. **Competitive Intelligence**
- MCP monitors competitor websites
- ClaudeEyes captures pricing changes
- CodeGen creates analysis scripts
- Alerts sent on significant changes

### 4. **Customer Support Automation**
- MCP reads support tickets
- ClaudeEyes categorizes issues
- CodeGen creates response templates
- Automated replies for common issues

### 5. **DevOps Monitoring**
- ClaudeEyes watches dashboards
- MCP interacts with monitoring tools
- Generated scripts analyze metrics
- Automated incident response

---

## Integration Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     USER / AI ASSISTANT                      │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                   PHILAUNCH ECOSYSTEM                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ ClaudeEyes   │  │   CodeGen    │  │  MCP Screen  │      │
│  │              │  │              │  │   Control    │      │
│  │ • Regions    │  │ • Templates  │  │ • Mouse      │      │
│  │ • Capture    │◄─┤ • Generate   │◄─┤ • Keyboard   │      │
│  │ • OCR        │  │ • Analyze    │  │ • OCR        │      │
│  │ • Config     │  │ • Refactor   │  │ • Clipboard  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              50 GENERATED POWERSHELL SCRIPTS                 │
│                                                              │
│  • GUI Tools        • Network Ops      • Security           │
│  • UI Automation    • File Ops         • Monitoring         │
│  • System Admin     • Data Processing  • Reporting          │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                    WINDOWS SYSTEM                            │
│  • Screen • Mouse • Keyboard • Clipboard • Processes         │
└──────────────────────────────────────────────────────────────┘
```

---

## Getting Started

### 1. **Setup ClaudeEyes**
```bash
# Launch ClaudeEyes
Start-Process "C:\Users\Stryker\Desktop\VSCC_AHK_FILES\AutoHotkey64.exe" `
    "C:\Users\Stryker\Desktop\VSCC_AHK_FILES\CLAUDE_EYES.ahk"

# Define regions
# - Input region: Where AI types
# - Response region: Where AI reads
# - Save configuration
```

### 2. **Configure MCP**
```json
// claude_desktop_config.json
{
  "mcpServers": {
    "screen-control": {
      "command": "python",
      "args": ["C:/Dev/Windows-MCP-v2/server/screen_mcp_server.py"]
    }
  }
}
```

### 3. **Generate Scripts**
```powershell
# Generate automation scripts as needed
cd C:\Dev\PhiLaunch\codegen
.\New-CodeFromPrompt.ps1 -Prompt "Your automation task"
```

### 4. **Run Integration Tests**
```powershell
# Verify everything works
.\TEST_INTEGRATION_SUITE.ps1
```

### 5. **Start Automating!**
```powershell
# Run the ultimate demo
.\ULTIMATE_INTEGRATION_DEMO.ps1 -DemoScenario All
```

---

## Best Practices

✅ **DO:**
- Define clear screen regions in ClaudeEyes
- Save configurations for reuse
- Use generated scripts as building blocks
- Enable MCP oversight GUI for monitoring
- Test automation workflows before production
- Keep action logs for audit trails

❌ **DON'T:**
- Automate without human oversight
- Skip validation steps
- Ignore error handling
- Run untested scripts in production
- Forget to save ClaudeEyes configs
- Disable safety features

---

## Troubleshooting

**Q: ClaudeEyes not capturing text?**
- A: Increase delay between clicks, check region selection

**Q: CodeGen syntax errors?**
- A: Use PowerShell 7, ignore regex bug (already fixed in latest)

**Q: MCP not connecting?**
- A: Check Claude Desktop config path, restart application

**Q: Generated scripts fail?**
- A: Run with -Verbose to see detailed errors

---

## Next Steps

1. ✅ Install all components
2. ✅ Run integration tests
3. ✅ Try the demo scenarios
4. 🚀 **Start building your own automations!**

---

**PhiLaunch Integration v1.0** - The Cloudless Automation Beast 🚀
