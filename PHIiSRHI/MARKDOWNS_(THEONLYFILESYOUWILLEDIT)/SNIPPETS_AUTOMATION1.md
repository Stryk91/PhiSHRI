# Curated Library of 50 Windows PowerShell One-Liners for AI Agent Automation

---

## 1. File System Operations (10)

```powershell
# Description: Recursive file search with name filter
# Use case: Find all .log files under a directory tree
Get-ChildItem -Path "C:\Logs" -Recurse -Filter *.log -File
# Description: Recursive file search with content filter
# Use case: Find files containing a specific string
Get-ChildItem -Path "C:\Projects" -Recurse -File | Select-String -Pattern "ERROR" | Select-Object -Unique Path

powershell

# Description: Recursive file search by size
# Use case: Find files larger than 100 MB
Get-ChildItem -Path "C:\Data" -Recurse -File | Where-Object Length -gt 100MB

powershell

# Description: Batch rename with sequence numbering
# Use case: Rename all .txt files to file_001.txt, file_002.txt, etc.
$i=1; Get-ChildItem "C:\Temp" -Filter *.txt | Sort-Object Name | ForEach-Object{Rename-Item $_ -NewName ("file_{0:D3}{1}" -f $i++, $_.Extension)}

powershell

# Description: Batch rename replacing text in filenames
# Use case: Replace "draft" with "final" in all filenames
Get-ChildItem "C:\Docs" -File | Where-Object Name -like "*draft*" | ForEach-Object{Rename-Item $_ -NewName ($_.Name -replace "draft","final")}

powershell

# Description: Calculate total size of a directory
# Use case: Get folder size in MB for reporting
"{0:N2} MB" -f ((Get-ChildItem "C:\Data" -Recurse -File | Measure-Object Length -Sum).Sum / 1MB)

powershell

# Description: List top 20 largest files in a directory tree
# Use case: Identify space hogs for cleanup
Get-ChildItem "C:\Data" -Recurse -File | Sort-Object Length -Descending | Select-Object FullName, @{N="SizeMB";E={[math]::Round($_.Length/1MB,2)}} -First 20

powershell

# Description: Detect duplicate files by hash
# Use case: Find files with identical content for deduplication
Get-ChildItem "C:\Data" -Recurse -File | Get-FileHash | Group-Object Hash | Where-Object Count -gt 1 | ForEach-Object{$_.Group | Select-Object Path,Hash}

powershell

# Description: Show NTFS permissions for a folder
# Use case: Audit access rights on a directory
Get-Acl "C:\Secure" | Select-Object -ExpandProperty Access | Select-Object IdentityReference,FileSystemRights,AccessControlType

powershell

# Description: Grant read access to a user on a folder
# Use case: Automate permission assignment
$acl=Get-Acl "C:\Shared";$rule=New-Object System.Security.AccessControl.FileSystemAccessRule("DOMAIN\User","ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow");$acl.AddAccessRule($rule);Set-Acl "C:\Shared" $acl

2. Process Management (10)

powershell

# Description: Kill processes by name pattern
# Use case: Force-close all Chrome processes
Get-Process | Where-Object ProcessName -like "chrome*" | Stop-Process -Force

powershell

# Description: Kill processes using a specific port
# Use case: Free up TCP port 8080
Get-NetTCPConnection -LocalPort 8080 -State Listen | ForEach-Object{Stop-Process -Id $_.OwningProcess -Force}

powershell

# Description: Monitor top 10 CPU-consuming processes
# Use case: Live CPU usage inspection
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name,Id,CPU,WS

powershell

# Description: Monitor processes by memory usage
# Use case: Find high RAM consumers
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name,Id,@{N="MemoryMB";E={[math]::Round($_.WorkingSet64/1MB,2)}}

powershell

# Description: Start a process elevated (UAC prompt)
# Use case: Run notepad as administrator
Start-Process "notepad.exe" -Verb RunAs

powershell

# Description: Start a process with arguments and hidden window
# Use case: Launch background worker silently
Start-Process "C:\Tools\worker.exe" -ArgumentList "/silent" -WindowStyle Hidden

powershell

# Description: Show process tree (parent-child relationships)
# Use case: Inspect spawn chains
Get-Process | Select-Object Id,ProcessName,@{N="ParentId";E={(Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)").ParentProcessId}} | Sort-Object ParentId,Id

powershell

# Description: List services with running/stopped state
# Use case: Quick service status overview
Get-Service | Select-Object Status,Name,DisplayName | Sort-Object Status,Name

powershell

# Description: Restart a specific service and wait
# Use case: Safely restart a flaky service
Restart-Service -Name "Spooler" -Force -PassThru | Wait-Process

powershell

# Description: Monitor a service and auto-start if stopped
# Use case: Simple watchdog loop (run in background)
while($true){$s=Get-Service -Name "MyService";if($s.Status -ne "Running"){Start-Service $s.Name};Start-Sleep -Seconds 30}

3. Network Operations (10)

powershell

# Description: Simple TCP port scan on a host
# Use case: Check if common ports are open
1,22,80,443,3389 | ForEach-Object{if(Test-NetConnection -ComputerName "example.com" -Port $_ -WarningAction SilentlyContinue).TcpTestSucceeded{"Port $_ open"}else{"Port $_ closed"}}

powershell

# Description: Scan port range on a local host
# Use case: Find open ports between 8000-8010
8000..8010 | ForEach-Object{if(Test-NetConnection -ComputerName "localhost" -Port $_ -WarningAction SilentlyContinue).TcpTestSucceeded{$_}}

powershell

# Description: DNS A record lookup
# Use case: Resolve hostname to IP
Resolve-DnsName "example.com" -Type A | Select-Object Name,IPAddress

powershell

# Description: Reverse DNS lookup
# Use case: Resolve IP to hostname
Resolve-DnsName "8.8.8.8" -Type PTR | Select-Object NameHost

powershell

# Description: Get network adapter IP configuration
# Use case: Inspect IPs, gateways, DNS servers
Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv6Address,IPv4DefaultGateway,DnsServer

powershell

# Description: Show active network connections with owning process
# Use case: Inspect network activity per process
Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess | Sort-Object LocalPort

powershell

# Description: List inbound firewall rules for a port
# Use case: Check firewall rules for RDP (3389)
Get-NetFirewallRule -Direction Inbound | Where-Object{(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_).LocalPort -eq 3389} | Select-Object Name,Enabled,Action

powershell

# Description: Add inbound firewall rule for a specific port
# Use case: Allow TCP 8080 traffic
New-NetFirewallRule -DisplayName "Allow_TCP_8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow

powershell

# Description: Disable a firewall rule by name
# Use case: Temporarily turn off a custom rule
Get-NetFirewallRule -DisplayName "Allow_TCP_8080" | Disable-NetFirewallRule

powershell

# Description: Continuous ping with timestamp
# Use case: Monitor connectivity over time
while($true){"{0:HH:mm:ss} - {1}" -f (Get-Date),(Test-NetConnection "8.8.8.8").PingSucceeded;Start-Sleep 5}

4. System Information (10)

powershell

# Description: Get basic CPU and RAM info
# Use case: Record hardware specs for inventory
Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,NumberOfLogicalProcessors,@{N="RAM_GB";E={[math]::Round($_.TotalPhysicalMemory/1GB,2)}}

powershell

# Description: Get detailed CPU model and speed
# Use case: Hardware capability reporting
Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,@{N="MaxClockGHz";E={[math]::Round($_.MaxClockSpeed/1000,2)}}

powershell

# Description: List physical disks and size
# Use case: Disk inventory with size in GB
Get-PhysicalDisk | Select-Object FriendlyName,MediaType,SerialNumber,@{N="SizeGB";E={[math]::Round($_.Size/1GB,2)}},HealthStatus

powershell

# Description: Detect Windows version and build
# Use case: Validate OS requirements
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").PSObject.Properties | Where-Object Name -in "ProductName","ReleaseId","DisplayVersion","CurrentBuild","CurrentBuildNumber"

powershell

# Description: List installed software from registry
# Use case: Basic software inventory (64-bit view)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher | Sort-Object DisplayName

powershell

# Description: List installed software (32-bit on 64-bit OS)
# Use case: Include WOW6432Node applications
Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher | Sort-Object DisplayName

powershell

# Description: Show environment variables
# Use case: Audit environment for automation
Get-ChildItem Env: | Sort-Object Name

powershell

# Description: Set a persistent user environment variable
# Use case: Configure PATH-like variables for tools
[System.Environment]::SetEnvironmentVariable("MY_TOOL_HOME","C:\Tools","User")

powershell

# Description: Check disk health via SMART status
# Use case: Detect failing disks (basic)
Get-CimInstance Win32_DiskDrive | Select-Object Model,SerialNumber,Status,Partitions,@{N="SizeGB";E={[math]::Round($_.Size/1GB,2)}}

powershell

# Description: Check filesystem free space
# Use case: Ensure sufficient free space on drives
Get-PSDrive -PSProvider FileSystem | Select-Object Name,@{N="UsedGB";E={[math]::Round(($_.Used/1GB),2)}},@{N="FreeGB";E={[math]::Round(($_.Free/1GB),2)}}

5. Automation Helpers (10)

powershell

# Description: Wait until a file exists
# Use case: Block script until output file is created
while(-not (Test-Path "C:\Temp\output.txt")){Start-Sleep -Seconds 2}

powershell

# Description: Wait until a process exits
# Use case: Block until an external tool finishes
Get-Process -Name "mysqld" -ErrorAction SilentlyContinue | Wait-Process

powershell

# Description: Create a scheduled task to run a script daily
# Use case: Automate a script at 2 AM every day
$action=New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"C:\Scripts\job.ps1`"";$trigger=New-ScheduledTaskTrigger -Daily -At 2am;Register-ScheduledTask -TaskName "DailyJob" -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest

powershell

# Description: Run a one-time scheduled task in 5 minutes
# Use case: Delayed script execution
$time=(Get-Date).AddMinutes(5);$action=New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"C:\Scripts\job.ps1`"";$trigger=New-ScheduledTaskTrigger -Once -At $time;Register-ScheduledTask -TaskName "RunOnceJob" -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest

powershell

# Description: Create or update a registry value (string)
# Use case: Configure application settings in registry
New-Item -Path "HKCU:\Software\MyApp" -Force | Out-Null;New-ItemProperty -Path "HKCU:\Software\MyApp" -Name "ConfigPath" -Value "C:\Config" -PropertyType String -Force | Out-Null

powershell

# Description: Delete a registry value
# Use case: Clean up obsolete configuration
Remove-ItemProperty -Path "HKCU:\Software\MyApp" -Name "ConfigPath" -ErrorAction SilentlyContinue

powershell

# Description: Copy text to clipboard
# Use case: Programmatically set clipboard contents
"Automation complete at $(Get-Date)" | Set-Clipboard

powershell

# Description: Get text from clipboard
# Use case: Use clipboard content in automation
$text = Get-Clipboard; $text

powershell

# Description: Minimize all top-level windows
# Use case: Clear desktop view for screen capture
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd,int nCmdShow);
[DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
[DllImport("user32.dll")] public static extern bool EnumWindows(Func<IntPtr,int,bool> lpEnumFunc,IntPtr lParam);
}
"@;[Win32]::EnumWindows({param($h,$p) if([Win32]::IsWindowVisible($h)){[Win32]::ShowWindowAsync($h,2)|Out-Null};$true},[IntPtr]::Zero)

powershell

# Description: Activate a window by title substring
# Use case: Bring a specific app to foreground
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W32 {
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
[DllImport("user32.dll")] public static extern bool EnumWindows(Func<IntPtr,int,bool> lpEnumFunc,IntPtr lParam);
[DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd,System.Text.StringBuilder text,int count);
}
"@;$title="Notepad";[W32]::EnumWindows({param($h,$p)$sb=New-Object System.Text.StringBuilder 256;[W32]::GetWindowText($h,$sb,256)|Out-Null;if($sb.ToString() -like "*$title*"){[W32]::SetForegroundWindow($h)|Out-Null;return $false};$true},[IntPtr]::Zero)