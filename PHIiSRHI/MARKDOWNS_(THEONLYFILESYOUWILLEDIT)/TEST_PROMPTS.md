# PhiLaunch CodeGen - Test Prompts

Copy and paste these prompts to test the code generation system!

---

## PowerShell Prompts

### 1. Get System Information
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Get system information including CPU, memory, and disk usage" -Language PowerShell
```

### 2. Remove Old Files
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Remove files older than 30 days from a directory" -Language PowerShell -IncludeTests
```

### 3. Set Environment Variable
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Set environment variable with validation" -Language PowerShell
```

### 4. List Running Processes
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Get list of running processes sorted by CPU usage" -Language PowerShell
```

### 5. Test Network Connection
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Test network connectivity to multiple hosts" -Language PowerShell -IncludeTests
```

---

## JavaScript/Node.js Prompts

### 6. Get API Data
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Get data from REST API with error handling" -Language JavaScript
```

### 7. Set Configuration
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Update JSON configuration file" -Language JavaScript -IncludeDocs
```

### 8. Remove Duplicates
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Remove duplicate entries from an array" -Language JavaScript
```

### 9. Run Database Query
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Execute SQL query and return results" -Language JavaScript -IncludeTests
```

---

## Python Prompts

### 10. Get CSV Data
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Read CSV file and return filtered rows" -Language Python
```

### 11. Set File Permissions
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Set file permissions recursively" -Language Python -IncludeTests
```

### 12. Create Backup
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Create compressed backup of directory" -Language Python -IncludeDocs
```

---

## Bash Prompts

### 13. Get Log Entries
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Search log files for error messages" -Language Bash
```

### 14. Remove Empty Directories
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Find and remove empty directories" -Language Bash
```

### 15. Monitor Disk Space
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Check disk space and alert if below threshold" -Language Bash -IncludeTests
```

---

## AutoHotkey v2 Prompts

### 16. Get Active Window
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Get information about the active window" -Language AutoHotkey
```

### 17. Set Hotkey
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Create hotkey to paste text" -Language AutoHotkey
```

### 18. Run Application
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Launch application and wait for it to start" -Language AutoHotkey
```

---

## Advanced Examples with Multiple Options

### 19. Complete Workflow (PowerShell)
```powershell
./New-CodeFromPrompt.ps1 `
    -Prompt "Get list of services that are stopped and need to be running" `
    -Language PowerShell `
    -IncludeTests `
    -IncludeDocs `
    -OutputPath "./output/Get-StoppedServices.ps1"
```

### 20. API Client (JavaScript)
```powershell
./New-CodeFromPrompt.ps1 `
    -Prompt "Create REST API client with authentication and retry logic" `
    -Language JavaScript `
    -IncludeTests `
    -IncludeDocs
```

### 21. File Processor (Python)
```powershell
./New-CodeFromPrompt.ps1 `
    -Prompt "Process text files and extract email addresses" `
    -Language Python `
    -IncludeTests `
    -OutputPath "./output/extract_emails.py"
```

### 22. System Monitor (Bash)
```powershell
./New-CodeFromPrompt.ps1 `
    -Prompt "Monitor system resources and log to file" `
    -Language Bash `
    -IncludeDocs `
    -OutputPath "./output/monitor.sh"
```

---

## Code Analysis Examples

### 23. Security Scan
```powershell
# First generate some code
./New-CodeFromPrompt.ps1 -Prompt "Execute user input as command" -Language PowerShell -OutputPath "./test.ps1"

# Then analyze it for security issues
./Invoke-CodeAnalysis.ps1 -Path "./test.ps1" -SecurityScan
```

### 24. Complete Analysis
```powershell
./Invoke-CodeAnalysis.ps1 `
    -Path "./test.ps1" `
    -SecurityScan `
    -ComplexityMetrics `
    -PerformanceAnalysis `
    -OutputFormat JSON
```

### 25. HTML Report
```powershell
./Invoke-CodeAnalysis.ps1 `
    -Path "./test.ps1" `
    -SecurityScan `
    -OutputFormat HTML > analysis_report.html
```

---

## Refactoring Examples

### 26. Modernize PowerShell
```powershell
./Refactor-Code.ps1 -Path "./test.ps1" -Operation ModernizeSyntax
```

### 27. Extract Function
```powershell
./Refactor-Code.ps1 `
    -Path "./test.ps1" `
    -Operation ExtractFunction `
    -StartLine 10 `
    -EndLine 25
```

### 28. Rename Variable
```powershell
./Refactor-Code.ps1 `
    -Path "./test.ps1" `
    -Operation RenameVariable `
    -TargetName "oldVar" `
    -NewName "newVariable"
```

---

## Test Generation Examples

### 29. Generate Pester Tests
```powershell
./New-TestSuite.ps1 -SourcePath "./test.ps1" -IncludeMocks
```

### 30. Complete Test Suite
```powershell
./New-TestSuite.ps1 `
    -SourcePath "./test.ps1" `
    -IncludeMocks `
    -IncludeFixtures `
    -OutputPath "./tests"
```

---

## Documentation Examples

### 31. Generate API Docs
```powershell
./Build-Documentation.ps1 -Path "./test.ps1" -IncludeExamples
```

### 32. Complete Documentation
```powershell
./Build-Documentation.ps1 `
    -Path "./codegen" `
    -OutputPath "./docs" `
    -GenerateIndex `
    -IncludeChangelog
```

---

## Quick Test Sequence

Run these in order for a complete workflow demonstration:

```powershell
# 1. Generate code
./New-CodeFromPrompt.ps1 -Prompt "Get system uptime and format as human-readable" -Language PowerShell -OutputPath "./Get-Uptime.ps1"

# 2. Analyze it
./Invoke-CodeAnalysis.ps1 -Path "./Get-Uptime.ps1" -SecurityScan -ComplexityMetrics

# 3. Generate tests
./New-TestSuite.ps1 -SourcePath "./Get-Uptime.ps1" -IncludeMocks -OutputPath "./Get-Uptime.Tests.ps1"

# 4. Generate documentation
./Build-Documentation.ps1 -Path "./Get-Uptime.ps1" -IncludeExamples -OutputPath "./Get-Uptime.md"

# 5. Refactor if needed
./Refactor-Code.ps1 -Path "./Get-Uptime.ps1" -Operation ModernizeSyntax
```

---

## Copy-Paste Ready Test Commands

**Simple Test:**
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Get current date and time" -Language PowerShell
```

**With Output File:**
```powershell
./New-CodeFromPrompt.ps1 -Prompt "List all files in directory" -Language PowerShell -OutputPath "./List-Files.ps1"
```

**With Tests:**
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Calculate factorial of a number" -Language PowerShell -IncludeTests
```

**With Everything:**
```powershell
./New-CodeFromPrompt.ps1 -Prompt "Convert temperature between Celsius and Fahrenheit" -Language PowerShell -IncludeTests -IncludeDocs -OutputPath "./Convert-Temperature.ps1"
```

---

## Tips

1. **Start simple** - Try the basic prompts first
2. **Check output** - Generated code is displayed in console by default
3. **Use -OutputPath** - Save to file for testing
4. **Analyze generated code** - Use Invoke-CodeAnalysis.ps1 to check quality
5. **Generate tests** - Use New-TestSuite.ps1 on generated code
6. **Refactor** - Use Refactor-Code.ps1 to improve generated code

---

## Expected Behavior

- **Code Generation**: Should produce syntactically valid code with error handling
- **Security**: Generated code should not have obvious vulnerabilities
- **Tests**: Should include parameter validation, functionality, and error handling tests
- **Documentation**: Should extract function info and generate formatted docs
- **Refactoring**: Should safely modify code with backups

---

**Happy Testing! 🚀**
