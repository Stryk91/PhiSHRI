# PhiLaunch AI-Assisted Code Generation System

A comprehensive, **offline-capable** code generation and analysis system for PowerShell, JavaScript, AutoHotkey v2, Python, and Bash.

## Features

### 🎯 Core Capabilities

- **Natural Language Code Generation** - Generate production-ready code from plain English descriptions
- **Multi-Language Support** - PowerShell, JavaScript, Python, Bash, AutoHotkey v2
- **Intelligent Command Classification** - Auto-detects operation types (get, set, remove, run, test, new)
- **Offline Operation** - No cloud APIs required, works completely locally
- **Context-Aware** - Understands project structure and coding patterns
- **Remote Execution Ready** - All tools support SSH/remote execution per PhiLaunch standards

### 🔍 Code Analysis

- **Security Scanning** - Detects OWASP Top 10 vulnerabilities
- **Static Analysis** - Code quality and best practices
- **Complexity Metrics** - Cyclomatic complexity, nesting depth
- **Performance Analysis** - Identifies bottlenecks
- **Dependency Analysis** - Unused imports, circular dependencies

### 🔧 Refactoring Tools

- Extract function from code block
- Rename variables/functions across files
- Optimize loops and conditionals
- Remove dead code
- Modernize syntax (PowerShell v5→v7, AHK v1→v2)
- Simplify conditions

### 🧪 Testing Framework

- **Automated Test Generation** - Pester, Jest, pytest, bats
- **Mock Generation** - Automatic mock objects for dependencies
- **Fixture Creation** - Sample data for tests
- **Coverage Tracking** - 80% coverage target

### 📚 Documentation Generation

- API documentation in Markdown/HTML/JSON
- Inline comment generation
- Usage examples
- Changelog from git commits

## Quick Start

### Installation

```bash
# Clone or navigate to PhiLaunch directory
cd /home/user/PhiLaunch/codegen

# Ensure PowerShell 7+ is installed
pwsh --version
```

### Basic Usage

#### 1. Generate Code

```powershell
# Generate a PowerShell function
./New-CodeFromPrompt.ps1 -Prompt "Get list of running processes sorted by CPU usage" -Language PowerShell

# Generate with tests and docs
./New-CodeFromPrompt.ps1 `
    -Prompt "Remove files older than 30 days" `
    -Language Bash `
    -IncludeTests `
    -IncludeDocs `
    -OutputPath "./cleanup.sh"
```

#### 2. Analyze Code

```powershell
# Security scan
./Invoke-CodeAnalysis.ps1 -Path "./MyScript.ps1" -SecurityScan

# Complete analysis
./Invoke-CodeAnalysis.ps1 `
    -Path "./src" `
    -SecurityScan `
    -ComplexityMetrics `
    -PerformanceAnalysis `
    -OutputFormat JSON > analysis.json
```

#### 3. Refactor Code

```powershell
# Rename variable
./Refactor-Code.ps1 `
    -Path "./script.ps1" `
    -Operation RenameVariable `
    -TargetName "oldVar" `
    -NewName "newVar"

# Extract function
./Refactor-Code.ps1 `
    -Path "./script.ps1" `
    -Operation ExtractFunction `
    -StartLine 50 `
    -EndLine 75

# Modernize syntax
./Refactor-Code.ps1 `
    -Path "./legacy.ps1" `
    -Operation ModernizeSyntax
```

#### 4. Generate Tests

```powershell
# Generate Pester tests
./New-TestSuite.ps1 -SourcePath "./Get-SystemInfo.ps1" -IncludeMocks

# Generate Jest tests with fixtures
./New-TestSuite.ps1 `
    -SourcePath "./api.js" `
    -Framework Jest `
    -IncludeMocks `
    -IncludeFixtures
```

#### 5. Build Documentation

```powershell
# Document single file
./Build-Documentation.ps1 -Path "./script.ps1" -IncludeExamples

# Document entire project
./Build-Documentation.ps1 `
    -Path "./codegen" `
    -OutputPath "./docs" `
    -GenerateIndex `
    -IncludeChangelog
```

## Command Categories

The system auto-classifies prompts into categories for better code generation:

| Category | Verbs | Use Case |
|----------|-------|----------|
| **get** | Get, Read, List, Find, Search, Query | Retrieval operations |
| **set** | Set, Update, Modify, Configure, Change | Modification operations |
| **remove** | Remove, Delete, Clear, Clean, Purge | Deletion operations |
| **run** | Start, Invoke, Execute, Run, Launch | Execution operations |
| **test** | Test, Validate, Verify, Check, Assert | Validation operations |
| **new** | New, Create, Initialize, Build, Generate | Creation operations |

## Configuration

Edit `config/codegen_config.json` to customize:

- Language-specific style preferences
- Security scanning rules
- Complexity thresholds
- Test framework settings
- Documentation format
- Code generation options

### Example Configuration

```json
{
  "code_generation": {
    "max_function_length": 50,
    "require_documentation": true,
    "generate_tests": true,
    "test_coverage_target": 80,
    "include_error_handling": true,
    "include_logging": true
  },
  "security": {
    "scan_level": "strict",
    "check_owasp_top10": true
  }
}
```

## Templates

Custom templates for each language are in `templates/`:

```
templates/
├── powershell/
│   ├── get_template.ps1
│   ├── set_template.ps1
│   ├── remove_template.ps1
│   └── invoke_template.ps1
├── javascript/
│   ├── get_template.js
│   ├── set_template.js
│   └── run_template.js
├── python/
│   ├── get_template.py
│   └── set_template.py
├── bash/
│   └── get_template.sh
└── autohotkey/
    └── get_template.ahk
```

## VS Code Integration

### Setup

1. Copy snippets: `cp vscode-extension/philaunch-codegen.code-snippets ~/.config/Code/User/snippets/`
2. Merge settings: `cat vscode-extension/settings.json >> .vscode/settings.json`
3. Add keybindings: `cat vscode-extension/keybindings.json >> ~/.config/Code/User/keybindings.json`

### Snippets

- `philaunch-gen` - Generate code
- `philaunch-analyze` - Analyze code
- `philaunch-refactor` - Refactor code
- `philaunch-test` - Generate tests
- `philaunch-docs` - Build documentation

### Keyboard Shortcuts

- `Ctrl+Alt+G` - Generate Code
- `Ctrl+Alt+A` - Analyze Code
- `Ctrl+Alt+T` - Generate Tests

## Examples

Complete examples are in `examples/`:

```bash
# Run all examples
./examples/example_usage.sh

# Run complete workflow
pwsh ./examples/example_workflow.ps1
```

## Remote Execution (SSH)

All tools support remote execution per PhiLaunch guidelines:

```bash
# Generate code remotely
ssh user@host 'pwsh ~/PhiLaunch/codegen/New-CodeFromPrompt.ps1 -Prompt "..." -Language PowerShell'

# Analyze code remotely
ssh user@host 'pwsh ~/PhiLaunch/codegen/Invoke-CodeAnalysis.ps1 -Path ./script.ps1 -SecurityScan'

# Run in background with tmux
ssh user@host 'tmux new -d "pwsh ~/PhiLaunch/codegen/Build-Documentation.ps1 -Path . -OutputPath ./docs"'
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│          Natural Language Input                      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│     Command Classifier (get/set/remove/run/...)     │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│          Template Engine + Pattern Matching         │
│  ┌──────────────┬──────────────┬─────────────────┐  │
│  │  PowerShell  │  JavaScript  │  Python/Bash... │  │
│  └──────────────┴──────────────┴─────────────────┘  │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│           Code Enhancement Layer                     │
│  ┌────────────┬──────────────┬──────────────────┐   │
│  │  Error     │  Security    │  Logging         │   │
│  │  Handling  │  Validation  │  Injection       │   │
│  └────────────┴──────────────┴──────────────────┘   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│              Generated Code                          │
└─────────────────────────────────────────────────────┘
```

## Offline Operation

This system works **100% offline** using:

- **Pattern Matching** - Regex-based code analysis
- **Template System** - Pre-built code templates
- **Rule-Based Analysis** - Local security and quality rules
- **No External APIs** - All processing happens locally

## Success Metrics

| Metric | Target | Method |
|--------|--------|--------|
| Code Correctness | ≥95% | Passes static analysis |
| Test Coverage | ≥80% | Auto-generated tests |
| Refactoring Safety | 100% | No breaking changes |
| Documentation | ≥90% | All public functions documented |

## Troubleshooting

### PowerShell Execution Policy

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Missing Dependencies

```bash
# Install PowerShell 7+
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

## Contributing

Contributions welcome! Please:

1. Follow PhiLaunch project guidelines (remote-first, automation-ready)
2. Add tests for new features
3. Update documentation
4. Ensure offline capability

## License

Part of the PhiLaunch project.

## Support

- Issues: Create issue in PhiLaunch repository
- Documentation: See `docs/` directory
- Examples: See `examples/` directory

---

**PhiLaunch CodeGen v1.0.0** - Automation First, Always.
