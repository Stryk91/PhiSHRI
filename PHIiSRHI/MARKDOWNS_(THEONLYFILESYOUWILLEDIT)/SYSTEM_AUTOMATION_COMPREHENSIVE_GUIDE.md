# System Automation Comprehensive Guide
**Research Compiled: 2025**

A comprehensive guide covering PowerShell automation, Bash scripting optimization, Windows automation, and cross-platform scripting techniques.

---

## Table of Contents

1. [PowerShell Automation Cookbooks](#1-powershell-automation-cookbooks)
2. [Bash Scripting Optimization](#2-bash-scripting-optimization)
3. [Windows Automation](#3-windows-automation)
4. [Cross-Platform Scripts](#4-cross-platform-scripts)

---

## 1. PowerShell Automation Cookbooks

### 1.1 PowerShell 7+ Best Practices (2024-2025)

#### Key Principles

**Security Best Practices:**
- Always follow the principle of least privilege
- Run scripts with minimum necessary permissions
- Never hardcode sensitive information (passwords, API keys)
- Use the Microsoft.PowerShell.SecretManagement module for credentials
- Implement proper error handling and logging

**Code Quality Standards:**
- Use approved verbs (Get, Set, New, Remove, etc.)
- Follow naming conventions: Verb-Noun format
- Write modular, reusable functions
- Include comment-based help for functions
- Use meaningful variable names

**Performance Optimization:**
- Use pipeline processing instead of intermediate variables
- Utilize parallel processing with ForEach-Object -Parallel
- Avoid unnecessary variable assignments
- Use .NET methods for intensive operations
- Consider using runspaces for concurrent tasks

**Source:** [Toxigon PowerShell Best Practices 2024](https://toxigon.com/powershell-best-practices-for-2024)

---

### 1.2 Essential PowerShell One-Liners

#### System Information

```powershell
# Get installed applications (32-bit and 64-bit)
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
                 HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Format-Table -AutoSize

# Get system uptime
(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

# Get disk usage
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free,
    @{Name="UsedGB";Expression={[math]::Round($_.Used/1GB,2)}},
    @{Name="FreeGB";Expression={[math]::Round($_.Free/1GB,2)}}

# Get installed Windows updates
Get-HotFix | Sort-Object InstalledOn -Descending |
    Select-Object HotFixID, Description, InstalledOn -First 20

# Get top 10 processes by CPU usage
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet
```

#### User and Permission Management

```powershell
# Get local administrators
Get-LocalGroupMember -Group "Administrators"

# Get all local users
Get-LocalUser | Select-Object Name, Enabled, LastLogon

# Find files modified in last 7 days
Get-ChildItem -Path C:\ImportantFolder -Recurse |
    Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-7)}

# Get folder size
(Get-ChildItem -Path "C:\Folder" -Recurse |
    Measure-Object -Property Length -Sum).Sum / 1GB
```

#### Network Operations

```powershell
# Test network connectivity with detailed output
Test-NetConnection -ComputerName google.com -Port 443 -InformationLevel Detailed

# Get active network connections
Get-NetTCPConnection -State Established |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State

# Get DNS cache
Get-DnsClientCache | Format-Table -AutoSize

# Flush DNS cache
Clear-DnsClientCache

# Get network adapter information
Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MacAddress
```

#### Service Management

```powershell
# Get all running services
Get-Service | Where-Object {$_.Status -eq "Running"} | Sort-Object DisplayName

# Restart a service
Restart-Service -Name "Spooler" -Force

# Get service dependencies
Get-Service -Name "Spooler" | Select-Object -ExpandProperty DependentServices

# Set service to automatic startup
Set-Service -Name "Spooler" -StartupType Automatic
```

**Sources:**
- [TurboGeek PowerShell One-Liners](https://www.turbogeek.co.uk/powershell-server-management/)
- [Stack Overflow - Useful PowerShell One-Liners](https://stackoverflow.com/questions/615287/useful-powershell-one-liners)
- [19 PowerShell One-Liners Every Admin Should Know](https://wholesalebackup.com/19-powershell-one-liners-every-admin-should-know/)

---

### 1.3 Error Handling Patterns

#### Try-Catch-Finally Template

```powershell
function Invoke-SafeOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    try {
        # Set strict error handling
        $ErrorActionPreference = 'Stop'

        # Risky operation
        $content = Get-Content -Path $FilePath

        # Process content
        $result = $content | Where-Object {$_ -match "pattern"}

        return $result
    }
    catch [System.IO.FileNotFoundException] {
        # Handle specific exception
        Write-Error "File not found: $FilePath"
        Write-Log -Message "FileNotFoundException: $FilePath" -Level Error
        return $null
    }
    catch [System.UnauthorizedAccessException] {
        # Handle permission errors
        Write-Error "Access denied to: $FilePath"
        return $null
    }
    catch {
        # Handle all other exceptions
        Write-Error "An unexpected error occurred: $($_.Exception.Message)"
        Write-Log -Message $_.Exception -Level Error
        throw  # Re-throw if you want to propagate the error
    }
    finally {
        # Cleanup code that always runs
        $ErrorActionPreference = 'Continue'
        Write-Verbose "Operation completed for $FilePath"
    }
}
```

#### Advanced Error Handling Best Practices

```powershell
# Convert non-terminating errors to terminating errors
Get-ChildItem -Path "C:\NonExistent" -ErrorAction Stop

# Use trap for script-level error handling
trap {
    Write-Error "Script error: $_"
    Write-Log -Message $_ -Level Critical
    # Continue or Break
    Continue
}

# Validate parameters
function Set-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]$ConfigPath,

        [ValidateRange(1,100)]
        [int]$Threshold = 50
    )

    # Function body
}

# Error logging function
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [ValidateSet('Info','Warning','Error','Critical')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    # Write to console
    switch ($Level) {
        'Warning' { Write-Warning $logMessage }
        'Error' { Write-Error $logMessage }
        'Critical' { Write-Error $logMessage }
        default { Write-Verbose $logMessage }
    }

    # Append to log file
    $logMessage | Out-File -FilePath "C:\Logs\script.log" -Append
}
```

**Best Practices:**
1. Keep try blocks small - one operation at a time
2. Catch specific exceptions before general ones
3. Use Finally for cleanup (closing connections, files)
4. Log errors for debugging and auditing
5. Use -ErrorAction Stop to convert non-terminating to terminating errors
6. Don't suppress important errors silently
7. Validate input parameters early

**Sources:**
- [Microsoft Learn - Try Catch Finally](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally)
- [LazyAdmin - Try Catch Finally](https://lazyadmin.nl/powershell/try-catch-finally/)
- [Microsoft Learn - Everything About Exceptions](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions)

---

### 1.4 PowerShell Security Best Practices

#### Credential Management

```powershell
# WRONG - Never do this!
$password = "MyPassword123"
$username = "admin"

# CORRECT - Use SecureString (temporary, in-memory)
$securePassword = Read-Host "Enter password" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# BETTER - Use SecretManagement module
# Install modules
Install-Module -Name Microsoft.PowerShell.SecretManagement
Install-Module -Name Microsoft.PowerShell.SecretStore

# Register a vault
Register-SecretVault -Name LocalStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

# Store a secret
$secret = Read-Host "Enter secret" -AsSecureString
Set-Secret -Name "MyAPIKey" -Secret $secret

# Retrieve a secret
$apiKey = Get-Secret -Name "MyAPIKey" -AsPlainText

# For credentials
$cred = Get-Secret -Name "ServiceAccount"
```

#### Azure Key Vault Integration

```powershell
# Install Az module
Install-Module -Name Az.KeyVault

# Connect to Azure
Connect-AzAccount

# Retrieve secret from Azure Key Vault
$secret = Get-AzKeyVaultSecret -VaultName "MyVault" -Name "DatabasePassword"
$secretValue = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText

# Use in connection string
$connectionString = "Server=myserver;Database=mydb;User=$username;Password=$secretValue"
```

#### Environment Variables for CI/CD

```powershell
# Read from environment variable (injected by CI/CD)
$apiKey = $env:API_KEY

if ([string]::IsNullOrEmpty($apiKey)) {
    throw "API_KEY environment variable not set"
}

# Use the credential
Invoke-RestMethod -Uri "https://api.example.com" -Headers @{
    "Authorization" = "Bearer $apiKey"
}
```

#### Secure Automation Script Template

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$VaultName = "ProductionVault"
)

# Set strict mode
Set-StrictMode -Version Latest

# Import required modules
Import-Module Az.KeyVault -ErrorAction Stop

try {
    # Authenticate using managed identity (for Azure)
    Connect-AzAccount -Identity

    # Retrieve secrets
    $dbPassword = Get-AzKeyVaultSecret -VaultName $VaultName -Name "DbPassword" -AsPlainText
    $apiKey = Get-AzKeyVaultSecret -VaultName $VaultName -Name "ApiKey" -AsPlainText

    # Create credential object
    $securePassword = ConvertTo-SecureString $dbPassword -AsPlainText -Force
    $dbCredential = New-Object System.Management.Automation.PSCredential ("dbuser", $securePassword)

    # Use credentials
    # ... perform operations ...

    Write-Output "Operation completed successfully"
}
catch {
    Write-Error "Failed to retrieve secrets: $_"
    throw
}
finally {
    # Clear sensitive variables
    if ($dbPassword) { Clear-Variable dbPassword }
    if ($apiKey) { Clear-Variable apiKey }
}
```

**Key Security Principles:**
1. Never hardcode credentials in scripts
2. Use SecretManagement for local secrets
3. Use Azure Key Vault or similar for production
4. Leverage managed identities in cloud environments
5. Use environment variables for CI/CD pipelines
6. Clear sensitive variables after use
7. Implement proper access controls and audit logging
8. Use HTTPS for all remote connections
9. Follow principle of least privilege

**Sources:**
- [Secure Password Management in PowerShell](https://www.secureideas.com/blog/secure-password-management-in-powershell-best-practices)
- [Microsoft Learn - SecretManagement](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/using-secrets-in-automation)
- [PowerShell Secrets Management](https://attuneops.io/powershell-secrets-management/)

---

### 1.5 PowerShell Script Template

```powershell
<#
.SYNOPSIS
    Brief description of script purpose

.DESCRIPTION
    Detailed description of what the script does

.PARAMETER ComputerName
    Target computer name(s)

.PARAMETER Credential
    Credentials to use for authentication

.EXAMPLE
    .\MyScript.ps1 -ComputerName "SERVER01" -Verbose

.EXAMPLE
    .\MyScript.ps1 -ComputerName "SERVER01","SERVER02" -Credential (Get-Credential)

.NOTES
    Author: Your Name
    Date: 2025-01-15
    Version: 1.0
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ComputerName,

    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,100)]
    [int]$Timeout = 30
)

begin {
    # Set strict mode and error handling
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # Initialize variables
    $scriptPath = $PSScriptRoot
    $logFile = Join-Path $scriptPath "script_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

    # Import required modules
    $requiredModules = @('ActiveDirectory', 'GroupPolicy')
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -Name $module -ListAvailable)) {
            throw "Required module '$module' is not installed"
        }
        Import-Module $module
    }

    # Helper function for logging
    function Write-Log {
        param([string]$Message, [string]$Level = 'Info')
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        $logEntry | Out-File -FilePath $logFile -Append

        switch ($Level) {
            'Error' { Write-Error $Message }
            'Warning' { Write-Warning $Message }
            default { Write-Verbose $Message }
        }
    }

    Write-Log "Script started"
    $results = @()
}

process {
    foreach ($computer in $ComputerName) {
        try {
            Write-Log "Processing $computer"

            # WhatIf support
            if ($PSCmdlet.ShouldProcess($computer, "Perform operation")) {

                # Build session options
                $sessionParams = @{
                    ComputerName = $computer
                    ErrorAction = 'Stop'
                }

                if ($Credential) {
                    $sessionParams.Credential = $Credential
                }

                # Test connectivity
                if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
                    throw "Computer $computer is not reachable"
                }

                # Perform operations
                $result = Invoke-Command @sessionParams -ScriptBlock {
                    # Remote operations here
                    [PSCustomObject]@{
                        ComputerName = $env:COMPUTERNAME
                        Status = "Success"
                        Timestamp = Get-Date
                    }
                }

                $results += $result
                Write-Log "Successfully processed $computer" -Level Info
            }
        }
        catch {
            Write-Log "Failed to process ${computer}: $_" -Level Error
            $results += [PSCustomObject]@{
                ComputerName = $computer
                Status = "Failed"
                Error = $_.Exception.Message
                Timestamp = Get-Date
            }
        }
    }
}

end {
    Write-Log "Script completed"
    Write-Log "Total computers processed: $($results.Count)"

    # Output results
    return $results | Format-Table -AutoSize
}
```

---

## 2. Bash Scripting Optimization

### 2.1 Bash Best Practices

#### Essential Script Headers

```bash
#!/bin/bash
# Script: script_name.sh
# Description: What this script does
# Author: Your Name
# Date: 2025-01-15
# Version: 1.0

# Strict mode - exit on errors
set -euo pipefail

# Enable extended debugging (optional)
# set -x

# Trap errors and cleanup
trap 'echo "Error on line $LINENO"; cleanup; exit 1' ERR
trap 'cleanup; exit 0' EXIT SIGINT SIGTERM

# Cleanup function
cleanup() {
    # Remove temporary files, close connections, etc.
    [[ -f "$temp_file" ]] && rm -f "$temp_file"
}
```

#### Understanding Error Handling Options

```bash
# set -e (errexit) - Exit immediately if a command exits with non-zero status
set -e
command_that_might_fail  # Script exits here if it fails

# set -u (nounset) - Treat unset variables as errors
set -u
echo "$undefined_var"  # This will cause an error

# set -o pipefail - Return exit code of first failed command in pipeline
set -o pipefail
command1 | command2 | command3  # Fails if any command fails, not just the last

# Bash 4.4+ - inherit errexit in command substitution
shopt -s inherit_errexit
result=$(failing_command)  # Will now trigger errexit

# Complete strict mode
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true  # Ignore if not available
```

**Important Gotcha - Local Variables:**

```bash
# WRONG - errexit won't trigger
local result=$(failing_command)  # 'local' succeeds even if command fails

# CORRECT - Split declaration and assignment
local result
result=$(failing_command)  # Now errexit will trigger if command fails
```

**Sources:**
- [Writing Safer Bash](https://elder.dev/posts/safer-bash/)
- [Mastering Linux Error Handling](https://tech-champion.com/linux/mastering-linux-error-handling-set-euo-pipefail-explained/)

---

### 2.2 Performance Optimization Techniques

#### Use Built-in Commands Over External Tools

```bash
# SLOW - External command
basename /path/to/file.txt
dirname /path/to/file.txt

# FAST - Parameter expansion (10-20x faster)
filename="${filepath##*/}"      # basename
directory="${filepath%/*}"       # dirname
extension="${filename##*.}"      # get extension
name="${filename%.*}"           # get name without extension

# SLOW - Using cut
echo "field1:field2:field3" | cut -d: -f2

# FAST - Parameter expansion
string="field1:field2:field3"
IFS=: read -ra fields <<< "$string"
echo "${fields[1]}"
```

#### Minimize External Command Calls in Loops

```bash
# SLOW - Calls external process for each file
for file in *.txt; do
    wc -l < "$file"
done

# FASTER - Single process
wc -l *.txt

# SLOW - Multiple grep calls
for pattern in "${patterns[@]}"; do
    grep "$pattern" file.txt
done

# FASTER - Single grep with multiple patterns
grep -E "$(IFS='|'; echo "${patterns[*]}")" file.txt
```

#### Use Bash Built-ins for Arithmetic

```bash
# SLOW - External command
result=$(expr 5 + 3)

# FAST - Bash arithmetic (100x faster)
result=$((5 + 3))

# SLOW - bc for simple operations
result=$(echo "5 + 3" | bc)

# FAST - Use (( )) for arithmetic
(( result = 5 + 3 ))
(( counter++ ))
if (( value > 10 )); then
    echo "Value is greater than 10"
fi
```

#### Avoid Useless Cat

```bash
# SLOW - Unnecessary cat
cat file.txt | grep pattern

# FAST - Direct input redirection
grep pattern file.txt
grep pattern < file.txt

# SLOW
for line in $(cat file.txt); do
    echo "$line"
done

# FAST - Read file directly
while IFS= read -r line; do
    echo "$line"
done < file.txt
```

#### Use mapfile/readarray for Large Files

```bash
# SLOW - Loop reading
lines=()
while IFS= read -r line; do
    lines+=("$line")
done < file.txt

# FAST - mapfile (Bash 4+)
mapfile -t lines < file.txt

# Access elements
echo "${lines[0]}"  # First line
echo "${#lines[@]}" # Number of lines
```

#### Globbing vs ls

```bash
# SLOW - Unnecessary ls
for file in $(ls *.txt); do
    process "$file"
done

# FAST - Use globbing
for file in *.txt; do
    [[ -f "$file" ]] || continue  # Skip if no matches
    process "$file"
done

# Check if files exist
shopt -s nullglob  # Expand to nothing if no matches
files=(*.txt)
if (( ${#files[@]} > 0 )); then
    echo "Found ${#files[@]} files"
fi
shopt -u nullglob
```

#### Parallel Processing

```bash
# Process files in parallel using GNU parallel
parallel process_file ::: *.txt

# Or with xargs (more portable)
find . -name "*.txt" -print0 | xargs -0 -P 4 -n 1 process_file

# Background jobs (built-in)
for file in *.txt; do
    process_file "$file" &

    # Limit concurrent jobs
    while (( $(jobs -r | wc -l) >= 4 )); do
        wait -n  # Wait for any job to complete
    done
done
wait  # Wait for all remaining jobs
```

#### Use Arrays Efficiently

```bash
# Build array efficiently
files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find . -type f -print0)

# Process array
for file in "${files[@]}"; do
    process "$file"
done

# Array manipulation
array=("one" "two" "three")
echo "${array[0]}"        # First element
echo "${array[@]}"        # All elements
echo "${#array[@]}"       # Array length
echo "${array[@]:1:2}"    # Slice: elements 1-2
```

**Performance Tips Summary:**
1. Use built-in commands instead of external tools (20x faster)
2. Avoid loops with external commands
3. Use (( )) for arithmetic instead of expr/bc
4. Use parameter expansion instead of sed/awk for simple operations
5. Use mapfile for reading files into arrays
6. Use globbing instead of ls
7. Consider parallel processing for I/O bound tasks
8. Minimize file I/O operations

**Sources:**
- [The Unix School - 10 Performance Tips](https://www.theunixschool.com/2012/06/10-tips-to-improve-performance-of-shell.html)
- [Stack Overflow - Bash Optimization](https://stackoverflow.com/questions/67057/bash-script-optimization-of-processing-speed)
- [Stop Writing Slow Bash Scripts](https://dev.to/heinanca/stop-writing-slow-bash-scripts-performance-optimization-techniques-that-actually-work-181b)

---

### 2.3 Bash Script Template with Argument Parsing

```bash
#!/bin/bash
#
# Script Template with Best Practices
# Description: Template for robust bash scripts
# Author: Your Name
# Version: 1.0

# Strict error handling
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# Script directory and name
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_VERSION="1.0"

# Default values
VERBOSE=0
DRY_RUN=0
OUTPUT_FILE=""
INPUT_FILE=""

# Colors for output
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

#######################################
# Print usage information
#######################################
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Description of what the script does

OPTIONS:
    -i, --input FILE      Input file (required)
    -o, --output FILE     Output file (optional)
    -v, --verbose         Enable verbose output
    -d, --dry-run         Dry run mode
    -h, --help            Show this help message
    -V, --version         Show version

EXAMPLES:
    $SCRIPT_NAME -i input.txt -o output.txt
    $SCRIPT_NAME --input data.csv --verbose

EOF
}

#######################################
# Logging functions
#######################################
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    if (( VERBOSE )); then
        echo -e "${BLUE}[DEBUG]${NC} $*" >&2
    fi
}

#######################################
# Error handling
#######################################
cleanup() {
    local exit_code=$?

    # Cleanup temporary files
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "$TEMP_DIR" ]]; then
        log_debug "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi

    if (( exit_code != 0 )); then
        log_error "Script failed with exit code: $exit_code"
    fi
}

error_handler() {
    local line_number=$1
    log_error "Error occurred in script at line: $line_number"
}

# Set up traps
trap 'cleanup' EXIT
trap 'error_handler ${LINENO}' ERR
trap 'log_warning "Script interrupted"; exit 130' INT TERM

#######################################
# Argument parsing with getopts
#######################################
parse_arguments() {
    # No arguments provided
    if (( $# == 0 )); then
        usage
        exit 1
    fi

    while (( $# > 0 )); do
        case "$1" in
            -i|--input)
                INPUT_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                echo "$SCRIPT_NAME version $SCRIPT_VERSION"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

#######################################
# Validate arguments
#######################################
validate_arguments() {
    # Check required arguments
    if [[ -z "$INPUT_FILE" ]]; then
        log_error "Input file is required"
        usage
        exit 1
    fi

    # Check if input file exists
    if [[ ! -f "$INPUT_FILE" ]]; then
        log_error "Input file does not exist: $INPUT_FILE"
        exit 1
    fi

    # Check if input file is readable
    if [[ ! -r "$INPUT_FILE" ]]; then
        log_error "Input file is not readable: $INPUT_FILE"
        exit 1
    fi

    log_debug "Input file: $INPUT_FILE"
    log_debug "Output file: ${OUTPUT_FILE:-stdout}"
    log_debug "Verbose: $VERBOSE"
    log_debug "Dry run: $DRY_RUN"
}

#######################################
# Check dependencies
#######################################
check_dependencies() {
    local deps=("awk" "sed" "grep")
    local missing=()

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        log_error "Missing required dependencies: ${missing[*]}"
        exit 1
    fi
}

#######################################
# Main function
#######################################
main() {
    log_info "Starting $SCRIPT_NAME"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d -t "${SCRIPT_NAME}.XXXXXX")
    log_debug "Created temporary directory: $TEMP_DIR"

    # Your main logic here
    if (( DRY_RUN )); then
        log_warning "Running in dry-run mode - no changes will be made"
    fi

    # Process input file
    log_info "Processing input file: $INPUT_FILE"

    # Example processing
    local line_count
    line_count=$(wc -l < "$INPUT_FILE")
    log_info "Found $line_count lines in input file"

    # More processing...

    log_success "Script completed successfully"
}

#######################################
# Entry point
#######################################
parse_arguments "$@"
validate_arguments
check_dependencies
main
```

#### Using getopts (POSIX-compatible)

```bash
#!/bin/bash

# getopts example (short options only)
while getopts ":i:o:vdh" opt; do
    case $opt in
        i)
            INPUT_FILE="$OPTARG"
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        v)
            VERBOSE=1
            ;;
        d)
            DRY_RUN=1
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument"
            exit 1
            ;;
        \?)
            echo "Error: Invalid option -${OPTARG}"
            exit 1
            ;;
    esac
done

# Shift to get remaining arguments
shift $((OPTIND - 1))

# Remaining arguments are in $@
```

**Sources:**
- [Bash Best Practices Cheat Sheet](https://bertvv.github.io/cheat-sheets/Bash.html)
- [Shell Script Best Practices](https://sharats.me/posts/shell-script-best-practices/)
- [GitHub - Template for getopts](https://gist.github.com/abalter/4f1375985b99b84e62fcc0d63ef83174)

---

### 2.4 Common Bash Recipes

#### Safe File Processing

```bash
# Process files safely with null delimiter
find . -type f -name "*.txt" -print0 | while IFS= read -r -d '' file; do
    echo "Processing: $file"
done

# Read file line by line preserving whitespace
while IFS= read -r line || [[ -n "$line" ]]; do
    echo "$line"
done < "$input_file"

# Process CSV file
while IFS=, read -r col1 col2 col3; do
    echo "Column 1: $col1, Column 2: $col2, Column 3: $col3"
done < data.csv
```

#### Safe Temporary Files

```bash
# Create temporary file
temp_file=$(mktemp) || exit 1
trap 'rm -f "$temp_file"' EXIT

# Create temporary directory
temp_dir=$(mktemp -d) || exit 1
trap 'rm -rf "$temp_dir"' EXIT

# Use temporary file
echo "data" > "$temp_file"
process_file "$temp_file"
```

#### String Manipulation

```bash
string="Hello World"

# Length
echo "${#string}"  # 11

# Substring
echo "${string:0:5}"  # Hello

# Replace first occurrence
echo "${string/World/Bash}"  # Hello Bash

# Replace all occurrences
string="foo bar foo"
echo "${string//foo/baz}"  # baz bar baz

# Remove prefix
filename="path/to/file.txt"
echo "${filename##*/}"  # file.txt

# Remove suffix
echo "${filename%.*}"  # path/to/file

# Uppercase/Lowercase (Bash 4+)
echo "${string^^}"  # HELLO WORLD
echo "${string,,}"  # hello world

# Default values
echo "${VARIABLE:-default}"  # Use default if unset
echo "${VARIABLE:=default}"  # Assign default if unset
```

#### Associative Arrays (Bash 4+)

```bash
# Declare associative array
declare -A config

# Set values
config[host]="localhost"
config[port]="8080"
config[user]="admin"

# Access values
echo "${config[host]}"

# Iterate over keys
for key in "${!config[@]}"; do
    echo "$key: ${config[$key]}"
done

# Check if key exists
if [[ -v config[host] ]]; then
    echo "Host is configured"
fi
```

---

## 3. Windows Automation

### 3.1 WMI and CIM Cmdlets

#### Important Note
**Get-WmiObject is deprecated. Use Get-CimInstance instead!**

WMI cmdlets were removed in PowerShell 6+. CIM cmdlets are the modern replacement and work across PowerShell 5.1 and 7+.

#### Basic CIM Operations

```powershell
# Get operating system information
Get-CimInstance -ClassName Win32_OperatingSystem |
    Select-Object Caption, Version, OSArchitecture, LastBootUpTime

# Get computer system information
Get-CimInstance -ClassName Win32_ComputerSystem |
    Select-Object Name, Manufacturer, Model, TotalPhysicalMemory

# Get BIOS information
Get-CimInstance -ClassName Win32_BIOS |
    Select-Object SerialNumber, SMBIOSBIOSVersion, Manufacturer

# Get disk information
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
        @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
        @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
        @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}

# Get network adapter configuration
Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" |
    Select-Object Description, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder

# Get installed software
Get-CimInstance -ClassName Win32_Product |
    Select-Object Name, Version, Vendor, InstallDate |
    Sort-Object Name

# Get running processes
Get-CimInstance -ClassName Win32_Process |
    Select-Object ProcessId, Name,
        @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSetSize/1MB,2)}},
        CreationDate

# Get services
Get-CimInstance -ClassName Win32_Service |
    Select-Object Name, DisplayName, State, StartMode, StartName

# Get CPU information
Get-CimInstance -ClassName Win32_Processor |
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
```

#### Remote CIM Operations

```powershell
# Create CIM session (more efficient for multiple queries)
$cimSession = New-CimSession -ComputerName "SERVER01"

# Run multiple queries using same session
$os = Get-CimInstance -CimSession $cimSession -ClassName Win32_OperatingSystem
$disk = Get-CimInstance -CimSession $cimSession -ClassName Win32_LogicalDisk

# Close session
Remove-CimSession -CimSession $cimSession

# With credentials
$credential = Get-Credential
$cimSession = New-CimSession -ComputerName "SERVER01" -Credential $credential

# Query multiple computers
$computers = "SERVER01", "SERVER02", "SERVER03"
$sessions = New-CimSession -ComputerName $computers

Get-CimInstance -CimSession $sessions -ClassName Win32_OperatingSystem |
    Select-Object PSComputerName, Caption, LastBootUpTime

Remove-CimSession -CimSession $sessions
```

#### Common WMI/CIM Classes

```powershell
# System Classes
Win32_OperatingSystem      # OS information
Win32_ComputerSystem       # Computer hardware info
Win32_BIOS                 # BIOS information
Win32_Processor            # CPU information
Win32_PhysicalMemory       # RAM information

# Storage Classes
Win32_LogicalDisk          # Logical drives
Win32_DiskDrive            # Physical drives
Win32_Volume               # Volumes

# Network Classes
Win32_NetworkAdapter       # Network adapters
Win32_NetworkAdapterConfiguration  # Network configuration
Win32_NetworkConnection    # Network connections

# Software Classes
Win32_Product              # Installed software (slow!)
Win32_QuickFixEngineering  # Windows updates
Win32_StartupCommand       # Startup programs

# Process/Service Classes
Win32_Process              # Processes
Win32_Service              # Services
Win32_ScheduledJob         # Scheduled tasks

# User/Group Classes
Win32_UserAccount          # User accounts
Win32_Group                # Groups
Win32_GroupUser            # Group membership
```

#### Advanced CIM Queries

```powershell
# Filter with WQL
Get-CimInstance -ClassName Win32_Service -Filter "State='Running' AND StartMode='Auto'" |
    Select-Object Name, DisplayName

# Get service dependencies
$service = Get-CimInstance -ClassName Win32_Service -Filter "Name='Spooler'"
Get-CimAssociatedInstance -InputObject $service -ResultClassName Win32_Service

# Invoke CIM method
$params = @{
    ClassName = 'Win32_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'notepad.exe' }
}
Invoke-CimMethod @params

# Stop a process
$process = Get-CimInstance -ClassName Win32_Process -Filter "Name='notepad.exe'"
Invoke-CimMethod -InputObject $process -MethodName 'Terminate'

# Event monitoring
Register-CimIndicationEvent -ClassName Win32_ProcessStartTrace -SourceIdentifier "ProcessStart"
# Later: Unregister-Event -SourceIdentifier "ProcessStart"
```

**Sources:**
- [Microsoft Learn - Working with WMI](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/07-working-with-wmi)
- [PowerShell WMI Commands](https://powershell.one/wmi/commands)
- [Adam the Automator - PowerShell WMI](https://adamtheautomator.com/powershell-wmi/)

---

### 3.2 Registry Automation

#### Important Security Notes
1. **Always backup the registry before making changes**
2. **Test on non-production systems first**
3. **Run PowerShell as Administrator when required**
4. **Avoid modifying critical system keys**

#### Registry Navigation

```powershell
# Registry drives are automatically available
Get-PSDrive -PSProvider Registry

# Available drives:
# HKLM: - HKEY_LOCAL_MACHINE
# HKCU: - HKEY_CURRENT_USER

# Navigate like a file system
Set-Location HKLM:\SOFTWARE
Get-ChildItem
```

#### Reading Registry Values

```powershell
# Get registry key
Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Get specific registry value
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir"

# Get all values in a key
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Check if registry key exists
Test-Path -Path "HKLM:\SOFTWARE\MyApp"

# Get value using .NET
[Microsoft.Win32.Registry]::GetValue("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir", $null)
```

#### Creating Registry Keys and Values

```powershell
# Create new registry key
New-Item -Path "HKLM:\SOFTWARE\MyApp" -Force

# Create nested keys
New-Item -Path "HKLM:\SOFTWARE\MyApp\Settings\Database" -Force

# Create registry value (String)
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Version" -Value "1.0" -PropertyType String

# Create different value types
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Enabled" -Value 1 -PropertyType DWord
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "LicenseKey" -Value "ABC-123" -PropertyType String
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Features" -Value @("Feature1","Feature2") -PropertyType MultiString
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "BinaryData" -Value ([byte[]](0x01,0x02,0x03)) -PropertyType Binary

# Property Types:
# - String (REG_SZ)
# - ExpandString (REG_EXPAND_SZ)
# - Binary (REG_BINARY)
# - DWord (REG_DWORD) - 32-bit
# - QWord (REG_QWORD) - 64-bit
# - MultiString (REG_MULTI_SZ)
```

#### Modifying Registry Values

```powershell
# Set/Update registry value
Set-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Version" -Value "1.1"

# Update multiple values
$values = @{
    "Version" = "1.2"
    "Enabled" = 1
    "InstallDate" = (Get-Date).ToString("yyyy-MM-dd")
}

foreach ($key in $values.Keys) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name $key -Value $values[$key]
}

# Rename registry value
Rename-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "OldName" -NewName "NewName"
```

#### Deleting Registry Keys and Values

```powershell
# Remove registry value
Remove-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "ObsoleteValue"

# Remove registry key (must be empty)
Remove-Item -Path "HKLM:\SOFTWARE\MyApp\ObsoleteKey"

# Remove registry key and all subkeys recursively
Remove-Item -Path "HKLM:\SOFTWARE\MyApp" -Recurse -Force

# Safe deletion with confirmation
if (Test-Path "HKLM:\SOFTWARE\MyApp") {
    Remove-Item -Path "HKLM:\SOFTWARE\MyApp" -Recurse -Confirm
}
```

#### Backing Up and Restoring Registry

```powershell
# Export registry key to file
reg export "HKLM\SOFTWARE\MyApp" "C:\Backup\myapp_backup.reg"

# Import registry file
reg import "C:\Backup\myapp_backup.reg"

# Export using PowerShell (to XML)
Get-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" | Export-Clixml -Path "C:\Backup\myapp_backup.xml"

# Import from XML
$backup = Import-Clixml -Path "C:\Backup\myapp_backup.xml"
```

#### Registry Permissions

```powershell
# Get ACL for registry key
$acl = Get-Acl -Path "HKLM:\SOFTWARE\MyApp"
$acl | Format-List

# Add permission for a user
$acl = Get-Acl -Path "HKLM:\SOFTWARE\MyApp"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule(
    "DOMAIN\User",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl -Path "HKLM:\SOFTWARE\MyApp" -AclObject $acl

# Remove permission
$acl.RemoveAccessRule($rule)
Set-Acl -Path "HKLM:\SOFTWARE\MyApp" -AclObject $acl
```

#### Common Registry Automation Tasks

```powershell
# Disable Windows Defender real-time monitoring (requires admin)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" `
                 -Name "DisableRealtimeMonitoring" -Value 1

# Set environment variable via registry
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" `
                 -Name "MY_VARIABLE" -Value "MyValue"

# Configure automatic login (security risk!)
$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $path -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $path -Name "DefaultUserName" -Value "username"
Set-ItemProperty -Path $path -Name "DefaultPassword" -Value "password"

# Disable UAC (requires restart)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                 -Name "EnableLUA" -Value 0

# Change registered owner
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" `
                 -Name "RegisteredOwner" -Value "Company Name"
```

#### Safe Registry Modification Template

```powershell
function Set-RegistryValue {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        $Value,

        [ValidateSet('String','ExpandString','Binary','DWord','QWord','MultiString')]
        [string]$Type = 'String',

        [switch]$Backup
    )

    try {
        # Create backup if requested
        if ($Backup) {
            $backupPath = "$env:TEMP\registry_backup_$(Get-Date -Format 'yyyyMMddHHmmss').xml"
            if (Test-Path $Path) {
                Get-ItemProperty -Path $Path | Export-Clixml -Path $backupPath
                Write-Verbose "Backup created: $backupPath"
            }
        }

        # Ensure key exists
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            Write-Verbose "Created registry key: $Path"
        }

        # Set value with WhatIf support
        if ($PSCmdlet.ShouldProcess("$Path\$Name", "Set registry value to $Value")) {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
            Write-Verbose "Set $Path\$Name = $Value"
        }
    }
    catch {
        Write-Error "Failed to set registry value: $_"
        throw
    }
}

# Usage
Set-RegistryValue -Path "HKCU:\SOFTWARE\MyApp" -Name "Setting1" -Value "Value1" -Backup -Verbose
```

**Sources:**
- [SharePoint Diary - Manage Windows Registry](https://www.sharepointdiary.com/2021/04/manage-windows-registry-in-powershell.html)
- [Windows OS Hub - Registry Management](https://woshub.com/how-to-access-and-manage-windows-registry-with-powershell/)
- [Netwrix - PowerShell Create Registry Key](https://netwrix.com/en/resources/blog/powershell-create-registry-key/)

---

### 3.3 Task Scheduler Automation

#### Creating Scheduled Tasks

```powershell
# Basic scheduled task creation

# 1. Define the action (what to run)
$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -NonInteractive -WindowStyle Hidden -File "C:\Scripts\backup.ps1"'

# 2. Define the trigger (when to run)
# Daily at 3 AM
$trigger = New-ScheduledTaskTrigger -Daily -At 3AM

# 3. Define settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# 4. Define principal (who runs it)
$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

# 5. Register the task
Register-ScheduledTask `
    -TaskName "Daily Backup" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Performs daily backup at 3 AM"
```

#### Various Trigger Examples

```powershell
# Run at system startup
$trigger = New-ScheduledTaskTrigger -AtStartup

# Run at user logon
$trigger = New-ScheduledTaskTrigger -AtLogon

# Run once at specific time
$trigger = New-ScheduledTaskTrigger -Once -At "2025-01-15 14:30:00"

# Weekly on specific days
$trigger = New-ScheduledTaskTrigger `
    -Weekly `
    -At 3AM `
    -DaysOfWeek Monday,Wednesday,Friday

# Monthly on specific day
$trigger = New-ScheduledTaskTrigger `
    -Weekly `
    -WeeksInterval 4 `
    -DaysOfWeek Sunday `
    -At 2AM

# On idle
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfIdle -IdleDuration 00:10:00

# Multiple triggers
$trigger1 = New-ScheduledTaskTrigger -Daily -At 3AM
$trigger2 = New-ScheduledTaskTrigger -AtStartup
$triggers = @($trigger1, $trigger2)

Register-ScheduledTask -TaskName "MyTask" -Action $action -Trigger $triggers
```

#### Action Examples

```powershell
# Run PowerShell script
$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-ExecutionPolicy Bypass -File "C:\Scripts\script.ps1"'

# Run executable with arguments
$action = New-ScheduledTaskAction `
    -Execute 'C:\Program Files\MyApp\app.exe' `
    -Argument '--automated --logfile "C:\Logs\app.log"'

# Run with working directory
$action = New-ScheduledTaskAction `
    -Execute 'python.exe' `
    -Argument 'script.py' `
    -WorkingDirectory 'C:\Scripts'

# Multiple actions
$action1 = New-ScheduledTaskAction -Execute 'backup.exe'
$action2 = New-ScheduledTaskAction -Execute 'notify.exe' -Argument '--complete'
$actions = @($action1, $action2)
```

#### Advanced Settings

```powershell
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `           # Allow on battery
    -DontStopIfGoingOnBatteries `        # Don't stop when switching to battery
    -StartWhenAvailable `                # Start as soon as possible if missed
    -RunOnlyIfNetworkAvailable `         # Require network
    -ExecutionTimeLimit (New-TimeSpan -Hours 2) `  # Kill after 2 hours
    -RestartCount 3 `                    # Retry 3 times on failure
    -RestartInterval (New-TimeSpan -Minutes 5) `   # Wait 5 min between retries
    -Priority 4                          # Priority (0-10, lower = higher priority)
```

#### Managing Scheduled Tasks

```powershell
# Get scheduled task
Get-ScheduledTask -TaskName "Daily Backup"

# Get all tasks
Get-ScheduledTask | Select-Object TaskName, State, LastRunTime, NextRunTime

# Get task info
Get-ScheduledTaskInfo -TaskName "Daily Backup"

# Enable/Disable task
Enable-ScheduledTask -TaskName "Daily Backup"
Disable-ScheduledTask -TaskName "Daily Backup"

# Start task immediately
Start-ScheduledTask -TaskName "Daily Backup"

# Stop running task
Stop-ScheduledTask -TaskName "Daily Backup"

# Remove task
Unregister-ScheduledTask -TaskName "Daily Backup" -Confirm:$false

# Export task to XML
Export-ScheduledTask -TaskName "Daily Backup" | Out-File -FilePath "C:\Backup\task.xml"

# Import task from XML
Register-ScheduledTask -Xml (Get-Content "C:\Backup\task.xml" | Out-String) -TaskName "Daily Backup"
```

#### Complete Automation Example

```powershell
function New-MaintenanceTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TaskName,

        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,

        [Parameter(Mandatory=$false)]
        [string]$TriggerTime = "03:00",

        [Parameter(Mandatory=$false)]
        [ValidateSet('SYSTEM','LocalService','NetworkService')]
        [string]$RunAs = 'SYSTEM'
    )

    try {
        # Validate script exists
        if (-not (Test-Path $ScriptPath)) {
            throw "Script not found: $ScriptPath"
        }

        # Remove existing task if it exists
        if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
            Write-Warning "Task '$TaskName' already exists. Removing..."
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }

        # Create action
        $action = New-ScheduledTaskAction `
            -Execute 'powershell.exe' `
            -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

        # Create trigger
        $trigger = New-ScheduledTaskTrigger -Daily -At $TriggerTime

        # Create settings
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -ExecutionTimeLimit (New-TimeSpan -Hours 1)

        # Create principal
        $principal = New-ScheduledTaskPrincipal `
            -UserId $RunAs `
            -LogonType ServiceAccount `
            -RunLevel Highest

        # Register task
        $task = Register-ScheduledTask `
            -TaskName $TaskName `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Principal $principal `
            -Description "Automated maintenance task created $(Get-Date -Format 'yyyy-MM-dd')"

        Write-Output "Successfully created scheduled task: $TaskName"
        return $task
    }
    catch {
        Write-Error "Failed to create scheduled task: $_"
        throw
    }
}

# Usage
New-MaintenanceTask `
    -TaskName "System Cleanup" `
    -ScriptPath "C:\Scripts\cleanup.ps1" `
    -TriggerTime "02:00" `
    -RunAs "SYSTEM"
```

**Sources:**
- [SharePoint Diary - Create Scheduled Tasks](https://www.sharepointdiary.com/2022/06/create-scheduled-task-in-powershell.html)
- [Microsoft Learn - New-ScheduledTask](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtask)
- [LazyAdmin - PowerShell Scheduled Task](https://lazyadmin.nl/powershell/how-to-create-a-powershell-scheduled-task/)

---

### 3.4 PowerShell Remoting and WinRM

#### Enabling PowerShell Remoting

```powershell
# Enable remoting (run as Administrator)
Enable-PSRemoting -Force

# Enable on non-domain computers
Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Configure TrustedHosts (for workgroup)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "SERVER01,SERVER02" -Force
# Or allow all (security risk!)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Check WinRM status
Test-WSMan -ComputerName localhost

# Configure firewall
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
```

#### One-to-One Remoting

```powershell
# Enter interactive session
Enter-PSSession -ComputerName SERVER01

# With credentials
$cred = Get-Credential
Enter-PSSession -ComputerName SERVER01 -Credential $cred

# Exit session
Exit-PSSession
```

#### One-to-Many Remoting

```powershell
# Run command on single computer
Invoke-Command -ComputerName SERVER01 -ScriptBlock {
    Get-Service | Where-Object {$_.Status -eq 'Running'}
}

# Run on multiple computers
$computers = "SERVER01", "SERVER02", "SERVER03"
Invoke-Command -ComputerName $computers -ScriptBlock {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
}

# With credentials
Invoke-Command -ComputerName $computers -Credential $cred -ScriptBlock {
    Get-EventLog -LogName System -Newest 10
}

# Pass parameters to remote script
Invoke-Command -ComputerName SERVER01 -ScriptBlock {
    param($ServiceName)
    Get-Service -Name $ServiceName
} -ArgumentList "Spooler"
```

#### Persistent Sessions (Best Performance)

```powershell
# Create session
$session = New-PSSession -ComputerName SERVER01

# Run multiple commands using same session
Invoke-Command -Session $session -ScriptBlock { Get-Process }
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Invoke-Command -Session $session -ScriptBlock { Get-EventLog System -Newest 10 }

# Interactive with persistent session
Enter-PSSession -Session $session

# Close session when done
Remove-PSSession -Session $session

# Multiple sessions
$sessions = New-PSSession -ComputerName $computers
Invoke-Command -Session $sessions -ScriptBlock {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        CPU = (Get-WmiObject Win32_Processor).LoadPercentage
    }
}
Remove-PSSession -Session $sessions
```

#### Advanced Remoting Scenarios

```powershell
# Run local script on remote computer
Invoke-Command -ComputerName SERVER01 -FilePath "C:\Scripts\local_script.ps1"

# Background jobs
$job = Invoke-Command -ComputerName SERVER01 -ScriptBlock {
    Start-Sleep -Seconds 30
    Get-Process
} -AsJob

# Check job status
Get-Job

# Get job results
Receive-Job -Job $job
Remove-Job -Job $job

# Disconnected sessions (PowerShell 3+)
$session = New-PSSession -ComputerName SERVER01
Invoke-Command -Session $session -ScriptBlock {
    # Long running task
    Start-Sleep -Seconds 3600
} -InDisconnectedSession

# Reconnect later
$session = Get-PSSession -ComputerName SERVER01
Connect-PSSession -Session $session

# Copy files using sessions
$session = New-PSSession -ComputerName SERVER01
Copy-Item -Path "C:\Local\file.txt" -Destination "C:\Remote\" -ToSession $session
Copy-Item -Path "C:\Remote\result.log" -Destination "C:\Local\" -FromSession $session
```

#### Security Best Practices

```powershell
# Use HTTPS (requires certificate)
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
Enter-PSSession -ComputerName SERVER01 -UseSSL -SessionOption $sessionOption

# Use CredSSP for double-hop (security implications!)
Enable-WSManCredSSP -Role Client -DelegateComputer "SERVER01"
# On remote server:
Enable-WSManCredSSP -Role Server

# Use with CredSSP
Invoke-Command -ComputerName SERVER01 -Credential $cred -Authentication CredSSP -ScriptBlock {
    # Can now access network resources from remote computer
    Get-ChildItem \\FILESERVER\Share
}

# JEA (Just Enough Administration) - Constrained endpoints
# Create session configuration file
New-PSSessionConfigurationFile -Path .\RestrictedSession.pssc -SessionType RestrictedRemoteServer

# Register endpoint
Register-PSSessionConfiguration -Name "RestrictedEndpoint" -Path .\RestrictedSession.pssc

# Connect to constrained endpoint
Enter-PSSession -ComputerName localhost -ConfigurationName RestrictedEndpoint
```

#### Troubleshooting

```powershell
# Test remoting
Test-WSMan -ComputerName SERVER01

# Check WinRM configuration
Get-Item WSMan:\localhost\Client\TrustedHosts
Get-PSSessionConfiguration

# Enable detailed logging
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpListener -Value true

# Check firewall
Get-NetFirewallRule -Name "WINRM*" | Select-Object Name, Enabled, Direction

# View session diagnostics
Get-PSSession | Format-List *
```

**Sources:**
- [Microsoft Learn - PowerShell Remoting](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/08-powershell-remoting)
- [Adam the Automator - PSRemoting](https://adamtheautomator.com/psremoting/)
- [Microsoft Learn - WinRM Security](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/winrm-security)

---

## 4. Cross-Platform Scripts

### 4.1 Platform Detection

#### PowerShell Platform Detection

```powershell
# PowerShell 6+ automatic variables
if ($IsWindows) {
    Write-Host "Running on Windows"
}
elseif ($IsLinux) {
    Write-Host "Running on Linux"
}
elseif ($IsMacOS) {
    Write-Host "Running on macOS"
}

# PowerShell 5.1 compatibility
function Get-OperatingSystem {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) { return "Windows" }
        elseif ($IsLinux) { return "Linux" }
        elseif ($IsMacOS) { return "macOS" }
    }
    else {
        # PowerShell 5.1 is Windows only
        return "Windows"
    }
}

# Cross-platform path handling
$configPath = if ($IsWindows) {
    "$env:APPDATA\MyApp\config.json"
}
else {
    "$HOME/.config/myapp/config.json"
}

# Platform-specific commands
$processes = if ($IsWindows) {
    Get-Process | Select-Object Name, CPU, WS
}
else {
    Get-Process | Select-Object Name, CPU, WorkingSet
}
```

#### Bash Platform Detection

```bash
#!/bin/bash

# Method 1: Using uname
detect_os_uname() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*)    echo "Cygwin";;
        MINGW*)     echo "MinGW";;
        MSYS*)      echo "MSYS";;
        *)          echo "Unknown";;
    esac
}

# Method 2: Using $OSTYPE variable
detect_os_ostype() {
    case "$OSTYPE" in
        linux*)     echo "Linux";;
        darwin*)    echo "macOS";;
        bsd*)       echo "BSD";;
        msys*)      echo "Windows";;
        solaris*)   echo "Solaris";;
        *)          echo "Unknown: $OSTYPE";;
    esac
}

# Method 3: Comprehensive detection
detect_platform() {
    local os=""
    local arch=""

    # Detect OS
    case "$(uname -s)" in
        Linux*)     os="linux";;
        Darwin*)    os="macos";;
        CYGWIN*)    os="windows";;
        MINGW*)     os="windows";;
        MSYS*)      os="windows";;
        *)          os="unknown";;
    esac

    # Detect architecture
    case "$(uname -m)" in
        x86_64)     arch="x86_64";;
        aarch64|arm64) arch="arm64";;
        armv7l)     arch="armv7";;
        i686|i386)  arch="x86";;
        *)          arch="unknown";;
    esac

    echo "${os}_${arch}"
}

# Usage
OS=$(detect_os_uname)
PLATFORM=$(detect_platform)

echo "Operating System: $OS"
echo "Platform: $PLATFORM"

# Platform-specific behavior
if [[ "$OS" == "Linux" ]]; then
    # Linux-specific commands
    sudo apt update
elif [[ "$OS" == "macOS" ]]; then
    # macOS-specific commands
    brew update
elif [[ "$OS" == *"Windows"* ]] || [[ "$OS" == "MSYS" ]]; then
    # Windows-specific commands
    echo "Running on Windows"
fi
```

#### Detecting WSL

```bash
# Detect Windows Subsystem for Linux
is_wsl() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        return 0  # Is WSL
    else
        return 1  # Not WSL
    fi
}

# Detect WSL version
get_wsl_version() {
    if [[ -f /proc/version ]]; then
        if grep -qi "microsoft-standard" /proc/version; then
            echo "WSL2"
        elif grep -qi "microsoft" /proc/version; then
            echo "WSL1"
        else
            echo "Not WSL"
        fi
    fi
}

# Usage
if is_wsl; then
    WSL_VERSION=$(get_wsl_version)
    echo "Running in $WSL_VERSION"

    # WSL-specific logic
    # Access Windows files
    cd /mnt/c/Users/$USER/Documents
else
    echo "Running in native Linux"
fi
```

**Sources:**
- [Stack Overflow - Detect OS in Bash](https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script)
- [Stack Overflow - Detect OS in PowerShell](https://stackoverflow.com/questions/64893785/how-to-detect-linux-or-macos-or-windows-in-powershell)

---

### 4.2 Cross-Platform Path Handling

#### PowerShell

```powershell
# Join paths (cross-platform)
$configPath = Join-Path $HOME "config" "app.json"

# Path separator
$separator = [System.IO.Path]::DirectorySeparatorChar  # \ on Windows, / on Unix

# Combine multiple paths
$fullPath = [System.IO.Path]::Combine($HOME, "Documents", "MyApp", "data.txt")

# Convert Windows path to Unix (in WSL scenarios)
function ConvertTo-UnixPath {
    param([string]$WindowsPath)

    # Convert C:\Users\... to /mnt/c/Users/...
    if ($WindowsPath -match '^([A-Z]):\\(.*)') {
        $drive = $matches[1].ToLower()
        $path = $matches[2] -replace '\\', '/'
        return "/mnt/$drive/$path"
    }
    return $WindowsPath
}

# Get temp directory (cross-platform)
$tempDir = if ($IsWindows) {
    $env:TEMP
}
else {
    "/tmp"
}

# User home directory
$homeDir = $HOME  # Works on all platforms
```

#### Bash

```bash
# Path separator
SEP="/"
[[ "$OSTYPE" == "msys" ]] && SEP="\\"

# Home directory
HOME_DIR="$HOME"  # Works on all platforms

# Temp directory
TEMP_DIR="${TMPDIR:-/tmp}"

# Join paths
join_path() {
    local IFS='/'
    echo "$*"
}

config_path=$(join_path "$HOME" "config" "app.json")

# Convert Windows path to Unix (for WSL)
win_to_unix_path() {
    local path="$1"

    # C:\Path\To\File -> /mnt/c/path/to/file
    if [[ "$path" =~ ^([A-Za-z]):(.*)$ ]]; then
        local drive="${BASH_REMATCH[1],,}"  # Lowercase
        local rest="${BASH_REMATCH[2]}"
        rest="${rest//\\//}"  # Replace \ with /
        echo "/mnt/$drive$rest"
    else
        echo "$path"
    fi
}

# Convert Unix path to Windows (for WSL)
unix_to_win_path() {
    local path="$1"

    # /mnt/c/path -> C:\path
    if [[ "$path" =~ ^/mnt/([a-z])/(.*)$ ]]; then
        local drive="${BASH_REMATCH[1]^^}:"  # Uppercase with :
        local rest="${BASH_REMATCH[2]}"
        rest="${rest//\//\\}"  # Replace / with \
        echo "$drive\\$rest"
    else
        echo "$path"
    fi
}
```

---

### 4.3 Cross-Platform Script Template

#### PowerShell Cross-Platform Template

```powershell
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Cross-platform PowerShell script template
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile
)

# Detect platform
$IsWindowsEnv = $IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)
$IsLinuxEnv = $IsLinux
$IsMacEnv = $IsMacOS

# Platform-specific paths
$AppDataPath = if ($IsWindowsEnv) {
    Join-Path $env:APPDATA "MyApp"
}
elseif ($IsLinuxEnv) {
    Join-Path $HOME ".config/myapp"
}
elseif ($IsMacEnv) {
    Join-Path $HOME "Library/Application Support/MyApp"
}

# Ensure directory exists
if (-not (Test-Path $AppDataPath)) {
    New-Item -ItemType Directory -Path $AppDataPath -Force | Out-Null
}

# Default config file location
if (-not $ConfigFile) {
    $ConfigFile = Join-Path $AppDataPath "config.json"
}

# Platform-specific command execution
function Invoke-PlatformCommand {
    param([string]$Task)

    switch ($Task) {
        "update" {
            if ($IsWindowsEnv) {
                Write-Host "Updating on Windows..."
                # winget upgrade --all
            }
            elseif ($IsLinuxEnv) {
                Write-Host "Updating on Linux..."
                # sudo apt update && sudo apt upgrade
            }
            elseif ($IsMacEnv) {
                Write-Host "Updating on macOS..."
                # brew update && brew upgrade
            }
        }

        "open" {
            $url = "https://example.com"
            if ($IsWindowsEnv) {
                Start-Process $url
            }
            elseif ($IsLinuxEnv) {
                & xdg-open $url
            }
            elseif ($IsMacEnv) {
                & open $url
            }
        }
    }
}

# Main logic
Write-Host "Running on: $(if ($IsWindowsEnv) {'Windows'} elseif ($IsLinuxEnv) {'Linux'} else {'macOS'})"
Write-Host "Config path: $ConfigFile"
Write-Host "AppData path: $AppDataPath"

# Cross-platform file operations
$data = @{
    Platform = if ($IsWindowsEnv) {"Windows"} elseif ($IsLinuxEnv) {"Linux"} else {"macOS"}
    Timestamp = Get-Date -Format "o"
    User = $env:USER ?? $env:USERNAME
    Home = $HOME
}

$data | ConvertTo-Json | Out-File -FilePath $ConfigFile -Encoding UTF8

Write-Host "Configuration saved successfully"
```

#### Bash Cross-Platform Template

```bash
#!/usr/bin/env bash
#
# Cross-platform Bash script template
# Works on Linux, macOS, Windows (Git Bash, WSL, Cygwin)

set -euo pipefail

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW*|MSYS*)  echo "windows";;
        *)          echo "unknown";;
    esac
}

# Platform-specific paths
get_app_data_dir() {
    local platform="$1"

    case "$platform" in
        linux)
            echo "$HOME/.config/myapp"
            ;;
        macos)
            echo "$HOME/Library/Application Support/MyApp"
            ;;
        windows)
            echo "$HOME/AppData/Roaming/MyApp"
            ;;
        *)
            echo "$HOME/.myapp"
            ;;
    esac
}

# Platform-specific commands
run_platform_command() {
    local command="$1"
    local platform="$2"

    case "$command" in
        update)
            case "$platform" in
                linux)
                    echo "Updating on Linux..."
                    # sudo apt update && sudo apt upgrade
                    ;;
                macos)
                    echo "Updating on macOS..."
                    # brew update && brew upgrade
                    ;;
                windows)
                    echo "Updating on Windows..."
                    # winget upgrade --all
                    ;;
            esac
            ;;

        open_browser)
            local url="${2:-https://example.com}"
            case "$platform" in
                linux)
                    xdg-open "$url" 2>/dev/null || true
                    ;;
                macos)
                    open "$url"
                    ;;
                windows)
                    cmd.exe /c start "$url" 2>/dev/null || start "$url"
                    ;;
            esac
            ;;
    esac
}

# Check if command exists (cross-platform)
command_exists() {
    command -v "$1" &> /dev/null
}

# Main script
main() {
    local platform
    platform=$(detect_platform)

    echo "Platform detected: $platform"

    # Get app data directory
    local app_data_dir
    app_data_dir=$(get_app_data_dir "$platform")

    # Create directory if it doesn't exist
    mkdir -p "$app_data_dir"

    local config_file="$app_data_dir/config.json"

    echo "Config file: $config_file"

    # Create config file
    cat > "$config_file" << EOF
{
    "platform": "$platform",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "user": "${USER:-$USERNAME}",
    "home": "$HOME"
}
EOF

    echo "Configuration saved successfully"

    # Platform-specific logic
    if [[ "$platform" == "linux" ]]; then
        echo "Running Linux-specific code..."
    elif [[ "$platform" == "macos" ]]; then
        echo "Running macOS-specific code..."
    elif [[ "$platform" == "windows" ]]; then
        echo "Running Windows-specific code..."
    fi

    # Check for required commands
    local required_commands=("git" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            echo "Error: Required command '$cmd' not found" >&2
            exit 1
        fi
    done

    echo "All required commands found"
}

# Run main function
main "$@"
```

---

### 4.4 Best Practices for Cross-Platform Scripts

#### General Guidelines

1. **Use Portable Commands**
   - Prefer POSIX-compliant commands
   - Avoid GNU-specific extensions when possible
   - Test on target platforms

2. **Handle Path Differences**
   - Use path joining functions
   - Don't hardcode path separators
   - Use environment variables for special directories

3. **Line Endings**
   - Configure git to handle line endings: `git config core.autocrlf true` (Windows) or `input` (Unix)
   - Use LF (\n) for shell scripts
   - Be aware of CRLF issues in Windows

4. **Encoding**
   - Use UTF-8 without BOM for maximum compatibility
   - Be explicit about encoding in PowerShell

5. **Shebang Lines**
   ```bash
   #!/usr/bin/env bash    # Portable (finds bash in PATH)
   #!/bin/bash            # Less portable (hardcoded path)
   ```

6. **Shell Options**
   - Use `set -euo pipefail` for safer scripts
   - Document platform-specific requirements

7. **Testing**
   - Test on all target platforms
   - Use Docker containers for cross-platform testing
   - Consider using GitHub Actions for automated testing

#### POSIX Compliance Tips

```bash
# POSIX-compliant (works everywhere)
#!/bin/sh
[ -f "$file" ] && echo "File exists"

# Bash-specific (won't work in pure POSIX sh)
#!/bin/bash
[[ -f "$file" ]] && echo "File exists"

# POSIX-compliant string comparison
if [ "$var" = "value" ]; then
    echo "Match"
fi

# Bash-specific (more features but less portable)
if [[ "$var" == "value" ]]; then
    echo "Match"
fi
```

**Sources:**
- [Cross-Platform Bash Scripting](https://www.plcourses.com/cross-platform-bash-scripting/)
- [Stack Overflow - Cross-Platform Scripts](https://stackoverflow.com/questions/42362596/cross-platform-shell-scripts)
- [Portable Shell Scripting](https://www.oreilly.com/library/view/bash-cookbook/0596526784/ch15s03.html)

---

## Quick Reference Cheat Sheets

### PowerShell Command Cheat Sheet

```powershell
# File System
Get-ChildItem                   # List files (ls, dir)
Set-Location                    # Change directory (cd)
Copy-Item                       # Copy files
Move-Item                       # Move files
Remove-Item                     # Delete files
New-Item                        # Create files/folders
Test-Path                       # Check if exists

# Processes & Services
Get-Process                     # List processes
Stop-Process                    # Kill process
Get-Service                     # List services
Start-Service                   # Start service
Stop-Service                    # Stop service
Restart-Service                 # Restart service

# System Information
Get-CimInstance Win32_OperatingSystem
Get-CimInstance Win32_ComputerSystem
Get-CimInstance Win32_LogicalDisk
Get-HotFix                      # Windows updates

# Network
Test-Connection                 # Ping
Test-NetConnection              # Advanced connectivity test
Get-NetAdapter                  # Network adapters
Get-NetIPAddress                # IP addresses

# Remote Management
Enter-PSSession                 # Interactive remote session
Invoke-Command                  # Run command remotely
New-PSSession                   # Create persistent session

# Filtering & Sorting
Where-Object {$_.Property -eq "Value"}
Select-Object Property1, Property2
Sort-Object -Property Name
Group-Object -Property Status
Measure-Object -Property Size -Sum

# Help
Get-Help CommandName
Get-Help CommandName -Examples
Get-Help CommandName -Full
Get-Command *keyword*
Get-Member                      # Object properties/methods
```

### Bash Command Cheat Sheet

```bash
# File System
ls -la                          # List files
cd /path                        # Change directory
cp source dest                  # Copy
mv source dest                  # Move
rm file                         # Remove
mkdir dir                       # Create directory
touch file                      # Create file

# Text Processing
grep pattern file               # Search text
sed 's/old/new/g' file         # Replace text
awk '{print $1}' file          # Process columns
cut -d: -f1 /etc/passwd        # Cut fields
sort file                       # Sort lines
uniq file                       # Remove duplicates
wc -l file                      # Count lines

# Process Management
ps aux                          # List processes
kill PID                        # Kill process
killall name                    # Kill by name
top                             # Process monitor
htop                            # Better process monitor
jobs                            # Background jobs
fg                              # Foreground job

# System Information
uname -a                        # System info
df -h                           # Disk usage
free -h                         # Memory usage
uptime                          # System uptime
whoami                          # Current user

# Network
ping host                       # Test connectivity
curl url                        # HTTP client
wget url                        # Download file
ss -tuln                        # Network connections
ip addr                         # IP addresses

# Permissions
chmod 755 file                  # Change permissions
chown user:group file           # Change owner
chgrp group file                # Change group

# Compression
tar -czf archive.tar.gz dir/    # Compress
tar -xzf archive.tar.gz         # Extract
gzip file                       # Compress file
gunzip file.gz                  # Decompress file

# Redirection
command > file                  # Redirect stdout
command 2> file                 # Redirect stderr
command &> file                 # Redirect both
command >> file                 # Append stdout
command < file                  # Input from file
cmd1 | cmd2                     # Pipe output
```

---

## Additional Resources

### Official Documentation
- [Microsoft PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)

### Community Resources
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [GitHub - Awesome PowerShell](https://github.com/janikvonrotz/awesome-powershell)
- [GitHub - Awesome Shell](https://github.com/alebcay/awesome-shell)
- [shellcheck.net](https://www.shellcheck.net/) - Shell script analyzer

### Learning Platforms
- [Microsoft Learn - PowerShell](https://learn.microsoft.com/en-us/training/browse/?terms=PowerShell)
- [Linux Journey](https://linuxjourney.com/)
- [Bash Academy](https://www.bash.academy/)

### Tools
- **ShellCheck** - Static analysis for shell scripts
- **PSScriptAnalyzer** - Static analysis for PowerShell
- **Visual Studio Code** - IDE with excellent PowerShell/Bash support

---

## Summary of Key Takeaways

### PowerShell
- Use PowerShell 7+ for cross-platform compatibility
- Always implement proper error handling with try-catch-finally
- Never hardcode credentials - use SecretManagement or Key Vault
- Use CIM cmdlets instead of deprecated WMI cmdlets
- Leverage remoting for efficient multi-computer management

### Bash
- Always use `set -euo pipefail` for safer scripts
- Prefer built-in commands over external tools for performance
- Use parameter expansion instead of sed/awk for simple operations
- Test scripts with ShellCheck for common issues
- Follow POSIX standards for maximum portability

### Cross-Platform
- Use platform detection at the start of scripts
- Handle paths correctly using platform-specific separators
- Test on all target platforms before deployment
- Document platform-specific requirements clearly
- Consider Docker containers for consistent environments

### Security
- Follow principle of least privilege
- Never commit secrets to version control
- Implement proper logging and auditing
- Validate all input parameters
- Use secure communication protocols (HTTPS, SSH)

---

**Document Version:** 1.0
**Last Updated:** 2025-01-15
**Compiled By:** System Automation Research

**All source URLs and references are cited throughout this document.**
