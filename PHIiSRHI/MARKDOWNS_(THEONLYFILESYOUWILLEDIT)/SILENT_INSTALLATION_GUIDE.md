# Silent Installation Guide

Complete reference for deploying software silently across Windows, macOS, Linux, and enterprise environments.

---

## Table of Contents

1. [Windows](#windows)
2. [macOS](#macos)
3. [Linux](#linux)
4. [Configuration Management](#configuration-management)
5. [Enterprise Deployment Scripts](#enterprise-deployment-scripts)

---

## Windows

### MSI Installation with msiexec

#### Basic Silent Installation

```cmd
msiexec /i "C:\path\to\installer.msi" /quiet /norestart
```

#### With Logging

```cmd
msiexec.exe /i "C:\path\to\installer.msi" /quiet /norestart /L*V "C:\logs\installation.log"
```

#### UI Level Flags

| Flag | Description |
|------|-------------|
| `/qn` | No UI (most silent) |
| `/quiet` | Quiet mode (no user interaction) |
| `/passive` | Unattended mode (shows progress bar) |
| `/qb` | Basic UI |
| `/qb!` | Basic UI with no cancel button |
| `/qr` | Reduced UI |
| `/qf` | Full UI |

#### Additional Parameters

| Parameter | Description |
|-----------|-------------|
| `/norestart` | Don't restart after installation |
| `/L*V` | Verbose logging (use `/L*` for all information) |
| `/L` | Log file path: `/L*V "C:\package.log"` |
| `PROPERTY=value` | Custom installation properties |

#### Complete Example

```cmd
msiexec.exe /i "C:\packages\MyApp.msi" /quiet /norestart /L*V "E:\logs\myapp_install.log"
```

---

### Inno Setup Silent Installation

```cmd
"C:\path\to\installer.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
```

#### Inno Setup Flags

| Flag | Description |
|------|-------------|
| `/SILENT` | Hide wizard and background, show progress window |
| `/VERYSILENT` | Hide everything including progress window |
| `/SUPPRESSMSGBOXES` | Suppress message boxes |
| `/NORESTART` | Don't restart system |
| `/SP-` | Suppress initial confirmation dialog |
| `/DIR="C:\CustomPath"` | Specify installation directory |
| `/LOG="C:\logs\install.log"` | Log file path |

#### Complete Example

```cmd
"C:\installers\MyApp_Setup.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR="C:\Program Files\MyApp" /LOG="C:\logs\myapp.log"
```

---

### NSIS Silent Installation

```cmd
"C:\path\to\installer.exe" /S /D=C:\CustomPath
```

#### NSIS Flags

| Flag | Description |
|------|-------------|
| `/S` | Silent mode (case-sensitive) |
| `/D=path` | Set installation directory (no quotes even with spaces, must be last) |

#### Important Notes

- NSIS is case-sensitive (`/S` works, `/s` does not)
- `/D` parameter must be the last parameter
- Do not quote the path even if it contains spaces

#### Complete Example

```cmd
"C:\installers\MyApp_Setup.exe" /S /D=C:\Program Files\MyApp
```

---

### Chocolatey Silent Automation

```powershell
choco install git -y
```

#### Key Flags

| Flag | Description |
|------|-------------|
| `-y` or `--confirm` | Automatically confirm all prompts |
| `-s` or `--source` | Specify custom package source |
| `--version` | Install specific version |
| `--no-progress` | Don't show progress bar |

#### Installing Multiple Packages

```powershell
choco install git nodejs python visualstudiocode -y
```

#### Creating a Chocolatey Installation Script

```powershell
# Installation script for multiple packages
$packages = @(
    'git',
    'nodejs',
    'visualstudiocode',
    'python',
    'putty'
)

foreach ($package in $packages) {
    Write-Host "Installing $package..."
    choco install $package -y
}

Write-Host "All packages installed successfully!"
```

#### Important Note

The `-y` flag handles Chocolatey's prompts, but the underlying software must be packaged with silent installation arguments (`/S`, `/quiet`, `/qn`) to be truly silent.

---

### Group Policy Object (GPO) Deployment

#### Configure GPO for Silent Installation

1. Open Group Policy Editor (`gpedit.msc`)
2. Navigate to: **Computer Configuration > Policies > Software Settings > Software installation**
3. Right-click and select **New > Package**
4. Select the MSI file
5. Choose deployment method:
   - **Assigned**: Installed automatically on startup
   - **Published**: Available in Add/Remove Programs

#### GPO Deployment Script

```powershell
# Deploy MSI via GPO (administrator context required)
$msiPath = "\\server\share\installers\MyApp.msi"
$logPath = "C:\Logs\deployment.log"

# This command is executed by GPO
# Software is always installed silently when assigned via GPO
```

#### Important Notes

- When assigned via GPO, MSI packages install silently automatically
- MSI property values can be set in GPO deployment settings
- Group Policy refreshes every 90 minutes by default (or manually via `gpupdate /force`)

---

### SCCM/Intune Deployment

#### SCCM Silent Deployment

```powershell
# Command line for SCCM deployment
msiexec.exe /i MyApp.msi /quiet /norestart

# Or for EXE installers
MyApp_Setup.exe /S /D=C:\Program Files\MyApp
```

#### Intune Win32 App Deployment

```powershell
# Install command in Intune
msiexec.exe /i MyApp.msi /quiet /norestart

# Uninstall command
msiexec.exe /x MyApp.msi /quiet /norestart
```

#### Intune Configuration Steps

1. Create Win32 app in Intune console
2. Upload installer (MSI or EXE converted to .INTUNEWIN)
3. Set install command: `msiexec.exe /i MyApp.msi /quiet /norestart`
4. Assign to device/user groups
5. Monitor installation status

#### Detection Rule Example

```powershell
# PowerShell detection script
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{PRODUCT-GUID}"
if (Test-Path $regPath) {
    exit 0  # App installed
} else {
    exit 1  # App not installed
}
```

---

### PowerShell Desired State Configuration (DSC)

#### Basic DSC Configuration for MSI Installation

```powershell
Configuration SoftwareInstallation {
    param(
        [string]$ComputerName = 'localhost'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName {
        Package MyApplication {
            Name      = 'My Application'
            ProductId = '{12345678-1234-1234-1234-123456789012}'
            Path      = 'C:\packages\MyApp.msi'
            Ensure    = 'Present'
            Arguments = '/quiet /norestart'
        }
    }
}

# Compile configuration
SoftwareInstallation -ComputerName 'localhost'

# Apply configuration
Start-DscConfiguration -Path .\SoftwareInstallation -Wait -Verbose
```

#### DSC with Chocolatey Integration

```powershell
Configuration ChocolateyInstallation {
    param(
        [string]$ComputerName = 'localhost'
    )

    Import-DscResource -ModuleName cChoco

    Node $ComputerName {
        cChocoInstaller InstallChocolatey {
            InstallDir = 'C:\ProgramData\chocolatey'
        }

        cChocoPackageInstaller Git {
            Name      = 'git'
            DependsOn = '[cChocoInstaller]InstallChocolatey'
        }

        cChocoPackageInstaller NodeJS {
            Name      = 'nodejs'
            Version   = '18.0.0'
            DependsOn = '[cChocoInstaller]InstallChocolatey'
        }
    }
}

# Compile and apply
ChocolateyInstallation -ComputerName 'localhost'
Start-DscConfiguration -Path .\ChocolateyInstallation -Wait -Verbose
```

#### DSC Benefits

- **Idempotent**: Safe to run repeatedly
- **Declarative**: Describe desired state, not steps
- **Configurable**: Easy to manage at scale
- **Auditable**: Built-in logging and compliance checking

---

## macOS

### Native installer Command (pkg files)

#### Basic Silent Installation

```bash
sudo installer -verboseR -pkg "/path/to/installer.pkg" -target /
```

#### Installer Command Options

| Option | Description |
|--------|-------------|
| `-pkg` | Path to package to install |
| `-target` | Install target (/ for system volume) |
| `-verboseR` | Verbose and suppress standard output redirects |
| `-allowUntrusted` | Allow installation from untrusted sources |
| `-volinfo` | Display volume information |

#### Installation to Specific Location

```bash
sudo installer -pkg "/path/to/MyApp.pkg" -target "/Volumes/MacHD"
```

#### Check Installation Status

```bash
# Verify package receipt
pkgutil --pkg-info com.example.myapp

# List all installed packages
pkgutil --packages
```

---

### Homebrew Silent Installation

#### Installing Homebrew (Non-interactive)

```bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Installing Packages Silently

```bash
# Basic quiet installation
brew install --quiet git

# Update and install
brew update
brew install --quiet nodejs python3
```

#### Homebrew Installation Script

```bash
#!/bin/bash

# Install Homebrew non-interactively
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update package list
brew update

# Install common packages
packages=(
    "git"
    "nodejs"
    "python@3.11"
    "cmake"
    "wget"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    brew install --quiet "$package"
done

echo "Homebrew installation completed!"
```

#### Important Notes

- `NONINTERACTIVE=1` skips some prompts but may still require sudo password
- `--quiet` flag may not suppress all warnings
- Homebrew primarily targets package installation, not full OS configuration

---

### Jamf Pro MDM Deployment

#### Basic Jamf Configuration (Jamf Script)

```bash
#!/bin/bash

# Jamf script to install pkg silently
PACKAGE_PATH="/private/tmp/MyApp.pkg"
LOG_PATH="/var/log/jamf_install.log"

# Install package
/usr/sbin/installer -pkg "$PACKAGE_PATH" -target / -verboseR >> "$LOG_PATH" 2>&1

# Check installation status
if [ $? -eq 0 ]; then
    echo "Installation completed successfully"
    exit 0
else
    echo "Installation failed"
    exit 1
fi
```

#### Jamf Policy Configuration Steps

1. Upload package to Jamf Distribution Points
2. Create new policy in Jamf Pro console
3. In **Packages** section:
   - Select package and priority
   - Enable "Action when missing": Install
4. In **Scope** section:
   - Select target computers/groups
5. In **Maintenance** section:
   - Set recurrence (optional)
6. Save and deploy

#### Jamf Script Example with Version Check

```bash
#!/bin/bash

APP_BUNDLE="/Applications/MyApp.app"
APP_VERSION="1.5.0"
PACKAGE_PATH="/private/tmp/MyApp.pkg"

# Check if app exists and version
if [ -d "$APP_BUNDLE" ]; then
    INSTALLED_VERSION=$(/usr/libexec/mdls -name kMDItemVersion "$APP_BUNDLE" | awk '{print $3}' | tr -d '"')

    if [ "$INSTALLED_VERSION" == "$APP_VERSION" ]; then
        echo "App already at target version"
        exit 0
    fi
fi

# Install or update
/usr/sbin/installer -pkg "$PACKAGE_PATH" -target / -verboseR
```

---

### macOS DEP/ADE Deployment

#### Automated Device Enrollment (ADE) Setup

1. **Configure in Jamf Pro**:
   - Settings > Device Management Settings > Automated Device Enrollment
   - Add Apple MDM server configuration

2. **Create enrollment profile with packages**:
   ```xml
   <!-- Example configuration payload -->
   <key>Software</key>
   <array>
       <dict>
           <key>PackageURL</key>
           <string>https://jamf-server/packages/MyApp.pkg</string>
       </dict>
   </array>
   ```

3. **DEP Device Flow**:
   - Device enrolls during setup assistant
   - Jamf policies activate automatically
   - Packages and scripts install without user interaction

#### MDM Profile with Software Deployment

```bash
#!/bin/bash

# Wait for MDM to be enrolled
until system_profiler SPConfigurationProfileDataType | grep -q "com.apple.mdm"; do
    sleep 5
done

echo "Device enrolled in MDM"

# Jamf agent will handle policy installation
# No additional action needed - policies deploy automatically
```

---

## Linux

### APT (Debian/Ubuntu)

#### Non-interactive Installation

```bash
DEBIAN_FRONTEND=noninteractive apt-get -y install package-name
```

#### With Advanced Options

```bash
DEBIAN_FRONTEND=noninteractive apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  install package-name
```

#### Update and Install

```bash
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install package-name
```

#### Install Multiple Packages

```bash
DEBIAN_FRONTEND=noninteractive apt-get -y install \
  git \
  curl \
  wget \
  nano \
  htop
```

#### APT Installation Script

```bash
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Update package lists
apt-get update

# Upgrade existing packages
apt-get -y upgrade

# Install packages
packages=(
    "git"
    "curl"
    "wget"
    "build-essential"
    "python3-pip"
    "nodejs"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "$package"
done

echo "APT installation completed!"
```

#### Handling Configuration Files

```bash
# Force use of default configuration
-o Dpkg::Options::="--force-confdef"

# Force keep old configuration
-o Dpkg::Options::="--force-confold"

# Force use of new configuration
-o Dpkg::Options::="--force-confnew"
```

---

### YUM/DNF (RHEL/CentOS/Fedora)

#### Silent Installation

```bash
yum install -y package-name
```

or with DNF (newer):

```bash
dnf install -y package-name
```

#### Install Multiple Packages

```bash
yum install -y \
  git \
  curl \
  wget \
  gcc \
  make \
  python3
```

#### Update System and Install

```bash
yum update -y
yum install -y package-name
```

#### YUM Installation Script

```bash
#!/bin/bash

# Update system packages
yum update -y

# Install packages
packages=(
    "git"
    "curl"
    "wget"
    "gcc"
    "make"
    "python3"
    "nodejs"
    "docker"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    yum install -y "$package"
done

echo "YUM installation completed!"
```

#### YUM Advanced Options

| Flag | Description |
|------|-------------|
| `-y` | Assume yes to all questions |
| `--quiet` | Quiet output |
| `--nogpgcheck` | Skip GPG signature check |
| `--disablerepo` | Disable repository |
| `--enablerepo` | Enable repository |

---

### Package Manager Detection Script

```bash
#!/bin/bash

# Detect package manager and install package
install_package() {
    if command -v apt-get &> /dev/null; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get -y install "$1"
    elif command -v yum &> /dev/null; then
        yum install -y "$1"
    elif command -v dnf &> /dev/null; then
        dnf install -y "$1"
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm "$1"
    else
        echo "No supported package manager found"
        return 1
    fi
}

# Usage
install_package "curl"
```

---

## Configuration Management

### Ansible Playbooks

#### Basic Package Installation Playbook

```yaml
---
- name: Install packages on all systems
  hosts: all
  become: yes

  tasks:
    - name: Update package cache (Debian/Ubuntu)
      apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_os_family == "Debian"

    - name: Update package cache (RedHat/CentOS)
      yum:
        name: "*"
        state: latest
      when: ansible_os_family == "RedHat"

    - name: Install packages on Debian/Ubuntu
      apt:
        name:
          - git
          - curl
          - wget
          - build-essential
          - python3-dev
        state: present
      when: ansible_os_family == "Debian"

    - name: Install packages on RedHat/CentOS
      yum:
        name:
          - git
          - curl
          - wget
          - gcc
          - python3-devel
        state: present
      when: ansible_os_family == "RedHat"
```

#### Advanced Playbook with Variables

```yaml
---
- name: Deploy application with silent installation
  hosts: webservers
  become: yes

  vars:
    packages:
      common:
        - git
        - curl
        - wget
      development:
        - gcc
        - make
        - python3-dev
      services:
        - nginx
        - postgresql

  tasks:
    - name: Update package manager
      package:
        name: "*"
        state: latest

    - name: Install common packages
      package:
        name: "{{ packages.common }}"
        state: present

    - name: Install development tools
      package:
        name: "{{ packages.development }}"
        state: present
      when: deploy_development | default(false)

    - name: Install and start services
      block:
        - name: Install services
          package:
            name: "{{ packages.services }}"
            state: present

        - name: Enable and start services
          systemd:
            name: "{{ item }}"
            enabled: yes
            state: started
          loop: "{{ packages.services }}"
```

#### Playbook with Custom Repository

```yaml
---
- name: Install packages from custom repository
  hosts: all
  become: yes

  tasks:
    - name: Add custom repository key
      apt_key:
        url: https://example.com/gpg.key
        state: present
      when: ansible_os_family == "Debian"

    - name: Add custom repository
      apt_repository:
        repo: "deb https://example.com/ubuntu {{ ansible_distribution_release }} main"
        state: present
      when: ansible_os_family == "Debian"

    - name: Update and install from custom repo
      apt:
        update_cache: yes
        name:
          - custom-package
          - another-package
        state: present
      when: ansible_os_family == "Debian"
```

---

### Puppet Manifests

#### Basic Package Installation Manifest

```puppet
# manifests/init.pp

class package_management {

  package { 'git':
    ensure => present,
  }

  package { 'curl':
    ensure => present,
  }

  package { 'wget':
    ensure => installed,
  }
}

# Include the class
include package_management
```

#### Advanced Manifest with OS Detection

```puppet
# manifests/packages.pp

class system_packages {
  case $facts['os']['family'] {
    'Debian': {
      $packages = [
        'git',
        'curl',
        'wget',
        'build-essential',
        'python3-dev',
      ]

      exec { 'apt-update':
        command => '/usr/bin/apt-get update',
        unless  => '/usr/bin/test -f /var/lib/apt/periodic/update-success-stamp',
      }

      package { $packages:
        ensure  => installed,
        require => Exec['apt-update'],
      }
    }

    'RedHat': {
      $packages = [
        'git',
        'curl',
        'wget',
        'gcc',
        'python3-devel',
      ]

      package { $packages:
        ensure => installed,
      }
    }

    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }
}

include system_packages
```

#### Manifest with Service Management

```puppet
# manifests/webserver.pp

class webserver {

  package { 'nginx':
    ensure => present,
  }

  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => Package['nginx'],
  }

  package { 'certbot':
    ensure => present,
  }
}

include webserver
```

---

### Chef Recipes

#### Basic Package Installation Recipe

```ruby
# recipes/default.rb

package 'git' do
  action :install
end

package 'curl' do
  action :install
end

package %w(wget nano htop) do
  action :install
end
```

#### Recipe with Platform Detection

```ruby
# recipes/packages.rb

case node['os']
when 'linux'
  case node['platform_family']
  when 'debian'
    package %w(
      git
      curl
      wget
      build-essential
      python3-dev
    ) do
      action :install
    end

  when 'rhel'
    package %w(
      git
      curl
      wget
      gcc
      python3-devel
    ) do
      action :install
    end
  end
end
```

#### Advanced Recipe with Attributes

```ruby
# recipes/deploy.rb
# attributes/default.rb contains:
# default['packages']['common'] = ['git', 'curl', 'wget']
# default['packages']['dev'] = ['gcc', 'make', 'python3-dev']

# Install common packages
node['packages']['common'].each do |pkg|
  package pkg do
    action :install
  end
end

# Install development packages if development flag is set
if node['development'] == true
  node['packages']['dev'].each do |pkg|
    package pkg do
      action :install
    end
  end
end

# Manage services
service 'nginx' do
  supports restart: true
  action [:enable, :start]
end
```

---

### Salt States

#### Basic Package Installation State

```yaml
# salt/top.sls
base:
  'os:Linux':
    - common_packages

# salt/common_packages/init.sls
common_packages:
  pkg.installed:
    - pkgs:
      - git
      - curl
      - wget
      - nano
```

#### Advanced State with OS Detection

```yaml
# salt/packages.sls

{% if grains['os_family'] == 'Debian' %}
debian_packages:
  pkg.installed:
    - pkgs:
      - git
      - curl
      - wget
      - build-essential
      - python3-dev

{% elif grains['os_family'] == 'RedHat' %}
redhat_packages:
  pkg.installed:
    - pkgs:
      - git
      - curl
      - wget
      - gcc
      - python3-devel
{% endif %}
```

#### State with Service Management

```yaml
# salt/webserver.sls

nginx:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - pkg: nginx

curl:
  pkg.installed: []

wget:
  pkg.installed: []
```

#### Complex State with Custom Repository

```yaml
# salt/custom_repo.sls

custom_repo:
  pkgrepo.managed:
    - humanname: Custom Repository
    - baseurl: https://example.com/repo/
    - gpgkey: https://example.com/gpg.key
    - gpgcheck: 1

custom_packages:
  pkg.installed:
    - pkgs:
      - custom-app
      - custom-lib
    - require:
      - pkgrepo: custom_repo
```

---

## Enterprise Deployment Scripts

### PowerShell Enterprise Deployment Script

```powershell
# Enterprise-Deployment.ps1
# Silent deployment script for multiple MSI packages across enterprise

param(
    [string]$PackagePath = "\\server\share\packages",
    [string]$LogPath = "C:\Logs\Deployment",
    [bool]$Restart = $false
)

# Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Create log directory if it doesn't exist
if (!(Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

function Write-DeploymentLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path "$LogPath\deployment_$(Get-Date -Format 'yyyyMMdd').log" -Value $logMessage
    Write-Host $logMessage
}

function Install-SoftwarePackage {
    param(
        [string]$PackageName,
        [string]$MsiPath,
        [string]$Arguments = ""
    )

    $logFile = "$LogPath\${PackageName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

    try {
        Write-DeploymentLog "Installing $PackageName from $MsiPath"

        $argumentList = @(
            "/i"
            "`"$MsiPath`""
            "/quiet"
            "/norestart"
            "/L*V"
            "`"$logFile`""
        )

        if ($Arguments) {
            $argumentList += $Arguments.Split()
        }

        $process = Start-Process -FilePath "msiexec.exe" `
                                  -ArgumentList $argumentList `
                                  -Wait `
                                  -NoNewWindow `
                                  -PassThru

        if ($process.ExitCode -eq 0) {
            Write-DeploymentLog "Successfully installed $PackageName" -Level "SUCCESS"
            return $true
        } else {
            Write-DeploymentLog "Installation of $PackageName failed with exit code $($process.ExitCode)" -Level "ERROR"
            return $false
        }
    } catch {
        Write-DeploymentLog "Exception installing $PackageName : $_" -Level "ERROR"
        return $false
    }
}

function Install-ChocoPackage {
    param(
        [string]$PackageName,
        [string]$Version = ""
    )

    try {
        Write-DeploymentLog "Installing $PackageName via Chocolatey"

        if ($Version) {
            & choco install $PackageName -y --version=$Version
        } else {
            & choco install $PackageName -y
        }

        if ($LASTEXITCODE -eq 0) {
            Write-DeploymentLog "Successfully installed $PackageName" -Level "SUCCESS"
            return $true
        } else {
            Write-DeploymentLog "Installation of $PackageName failed" -Level "ERROR"
            return $false
        }
    } catch {
        Write-DeploymentLog "Exception installing $PackageName : $_" -Level "ERROR"
        return $false
    }
}

# Main deployment
Write-DeploymentLog "=== Starting Enterprise Deployment ===" -Level "INFO"

# Example: Install multiple MSI packages
$packages = @(
    @{ Name = "MyApp"; Path = "$PackagePath\MyApp.msi" },
    @{ Name = "SecurityAgent"; Path = "$PackagePath\SecurityAgent.msi"; Args = "INSTALL_UPDATES=1" }
)

$installSuccessCount = 0
$installFailureCount = 0

foreach ($package in $packages) {
    if (Install-SoftwarePackage -PackageName $package.Name -MsiPath $package.Path -Arguments $package.Args) {
        $installSuccessCount++
    } else {
        $installFailureCount++
    }

    Start-Sleep -Seconds 2
}

# Install Chocolatey packages if Choco is available
if (Test-Path "$env:ProgramData\Chocolatey\bin\choco.exe") {
    Write-DeploymentLog "Chocolatey found, installing packages"

    $chocoPackages = @("git", "nodejs", "python")
    foreach ($pkg in $chocoPackages) {
        if (Install-ChocoPackage -PackageName $pkg) {
            $installSuccessCount++
        } else {
            $installFailureCount++
        }
    }
}

# Summary
Write-DeploymentLog "=== Deployment Complete ===" -Level "INFO"
Write-DeploymentLog "Successful: $installSuccessCount | Failed: $installFailureCount" -Level "INFO"

# Restart if requested and necessary
if ($Restart -and $installFailureCount -eq 0) {
    Write-DeploymentLog "Restarting system in 5 minutes..." -Level "WARNING"
    shutdown /r /t 300 /c "Enterprise software deployment completed. Restarting system."
} else {
    Write-DeploymentLog "System restart not initiated" -Level "INFO"
}

exit ($installFailureCount -gt 0 ? 1 : 0)
```

#### Usage

```powershell
# Run with default parameters
.\Enterprise-Deployment.ps1

# Run with custom package path
.\Enterprise-Deployment.ps1 -PackagePath "\\fileserver\software\packages" -LogPath "C:\DeploymentLogs"

# Run with automatic restart
.\Enterprise-Deployment.ps1 -Restart $true
```

---

### Bash Enterprise Deployment Script

```bash
#!/bin/bash

# enterprise-deployment.sh
# Silent deployment script for enterprise Linux environments

set -euo pipefail

# Configuration
PACKAGE_PATH="${1:-.}"
LOG_DIR="${2:-/var/log/deployment}"
ENVIRONMENT="${3:-production}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        INFO)
            echo -e "${BLUE}[$timestamp] [INFO]${NC} $message" | tee -a "$LOG_DIR/deployment.log"
            ;;
        SUCCESS)
            echo -e "${GREEN}[$timestamp] [SUCCESS]${NC} $message" | tee -a "$LOG_DIR/deployment.log"
            ;;
        WARNING)
            echo -e "${YELLOW}[$timestamp] [WARNING]${NC} $message" | tee -a "$LOG_DIR/deployment.log"
            ;;
        ERROR)
            echo -e "${RED}[$timestamp] [ERROR]${NC} $message" | tee -a "$LOG_DIR/deployment.log"
            ;;
    esac
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Install package using appropriate package manager
install_package() {
    local package=$1
    local distro=$2

    log INFO "Installing package: $package"

    case $distro in
        debian|ubuntu)
            export DEBIAN_FRONTEND=noninteractive
            if ! apt-get update &>/dev/null; then
                log ERROR "Failed to update package lists"
                return 1
            fi

            if apt-get install -y -o Dpkg::Options::="--force-confdef" \
                                  -o Dpkg::Options::="--force-confold" \
                                  "$package" &>/dev/null; then
                log SUCCESS "Successfully installed $package"
                return 0
            else
                log ERROR "Failed to install $package"
                return 1
            fi
            ;;

        rhel|centos|fedora)
            if yum install -y "$package" &>/dev/null; then
                log SUCCESS "Successfully installed $package"
                return 0
            else
                log ERROR "Failed to install $package"
                return 1
            fi
            ;;

        arch)
            if pacman -Sy --noconfirm "$package" &>/dev/null; then
                log SUCCESS "Successfully installed $package"
                return 0
            else
                log ERROR "Failed to install $package"
                return 1
            fi
            ;;

        *)
            log ERROR "Unsupported distribution: $distro"
            return 1
            ;;
    esac
}

# Install packages with custom script
install_custom_package() {
    local script_path=$1
    local package_name=$2

    if [ ! -f "$script_path" ]; then
        log ERROR "Installation script not found: $script_path"
        return 1
    fi

    log INFO "Running custom installation script for $package_name"

    if bash "$script_path" >> "$LOG_DIR/${package_name}.log" 2>&1; then
        log SUCCESS "Custom installation completed for $package_name"
        return 0
    else
        log ERROR "Custom installation failed for $package_name"
        return 1
    fi
}

# Main deployment
main() {
    log INFO "========================================"
    log INFO "Starting Enterprise Deployment"
    log INFO "Environment: $ENVIRONMENT"
    log INFO "Package Path: $PACKAGE_PATH"
    log INFO "========================================"

    local distro=$(detect_distro)
    log INFO "Detected distribution: $distro"

    if [ "$distro" = "unknown" ]; then
        log ERROR "Unable to detect Linux distribution"
        return 1
    fi

    # Ensure running as root
    if [ "$EUID" -ne 0 ]; then
        log ERROR "This script must be run as root"
        return 1
    fi

    local success_count=0
    local failure_count=0

    # Update package manager
    log INFO "Updating package manager"
    case $distro in
        debian|ubuntu)
            export DEBIAN_FRONTEND=noninteractive
            apt-get update || log WARNING "Failed to update package lists"
            ;;
        rhel|centos|fedora)
            yum update -y || log WARNING "Failed to update package lists"
            ;;
    esac

    # Define packages to install
    local packages=(
        "curl"
        "wget"
        "git"
        "nano"
        "htop"
    )

    # Install each package
    for package in "${packages[@]}"; do
        if install_package "$package" "$distro"; then
            ((success_count++))
        else
            ((failure_count++))
        fi
    done

    # Install custom packages if scripts exist
    if [ -d "$PACKAGE_PATH/custom" ]; then
        for script in "$PACKAGE_PATH/custom"/*.sh; do
            if [ -f "$script" ]; then
                package_name=$(basename "$script" .sh)
                if install_custom_package "$script" "$package_name"; then
                    ((success_count++))
                else
                    ((failure_count++))
                fi
            fi
        done
    fi

    # Deployment summary
    log INFO "========================================"
    log INFO "Deployment Summary"
    log INFO "Successful installations: $success_count"
    log INFO "Failed installations: $failure_count"
    log INFO "========================================"

    return $([ $failure_count -eq 0 ] && echo 0 || echo 1)
}

# Run main function
main "$@"
exit $?
```

#### Usage

```bash
# Run with defaults
sudo bash enterprise-deployment.sh

# Run with custom paths
sudo bash enterprise-deployment.sh "/opt/packages" "/var/log/deployment" "production"

# Run with environment-specific configuration
sudo bash enterprise-deployment.sh "/packages/prod" "/logs/prod" "production"
```

---

## Best Practices Summary

### General Principles

1. **Always use absolute paths** to avoid path resolution issues
2. **Implement comprehensive logging** for troubleshooting and audit trails
3. **Handle errors gracefully** with meaningful exit codes and error messages
4. **Test in non-production environments** before enterprise deployment
5. **Document custom properties** and configuration parameters
6. **Use version pinning** for reproducible deployments
7. **Implement rollback procedures** for failed installations
8. **Monitor deployment status** across all systems
9. **Collect installation metrics** for compliance and reporting
10. **Maintain updated documentation** of deployment procedures

### Platform-Specific Recommendations

**Windows**:
- Use `/quiet /norestart` combination for most scenarios
- Implement detailed logging with `/L*V` flag
- Leverage GPO for domain-joined machines
- Use Intune for modern cloud-managed devices

**macOS**:
- Test PKG installations in isolated environment first
- Use Jamf Pro for reliable MDM deployment
- Implement detection scripts for version management
- Support both Intel and Apple Silicon architectures

**Linux**:
- Use distribution detection for cross-platform scripts
- Set appropriate environment variables (`DEBIAN_FRONTEND`, etc.)
- Implement package manager abstraction for flexibility
- Handle configuration file conflicts with appropriate flags

### Enterprise Considerations

- Implement change tracking and audit logging
- Use configuration management tools for consistency
- Deploy to test group before production rollout
- Maintain compliance documentation
- Plan for system reboots and maintenance windows
- Implement inventory tracking and reporting
- Use pull-based rather than push-based deployments when possible

---

## Troubleshooting

### Common Issues and Solutions

#### Windows: MSI Installation Fails with Exit Code 1603
- Check log file for detailed error: `/L*V "logfile.log"`
- Verify installer path uses absolute paths and quotes
- Check system requirements and permissions
- Ensure Windows Installer service is running

#### macOS: Package Installation Hangs
- Check system logs: `log stream --predicate 'process == "installer"'`
- Verify package integrity: `pkgutil --check-signature package.pkg`
- Ensure sufficient disk space available
- Check for pending system updates

#### Linux: APT Installation Fails with "Hash Sum Mismatch"
- Update package lists: `apt-get update`
- Clear cache: `apt-get clean && apt-get autoclean`
- Use `-o Acquire::HTTP::Proxy` if behind proxy
- Check network connectivity to repositories

---

## References

- Microsoft: [Windows Installer Command Line Options](https://learn.microsoft.com/windows/win32/msi/command-line-options)
- Inno Setup: [Setup Command Line](https://jrsoftware.org/ishelp/topic_setupcmdline.htm)
- NSIS: [Reference/SilentInstall](https://nsis.sourceforge.io/Reference/SilentInstall)
- Ansible: [Package Module Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html)
- Puppet: [Package Resource Type](https://puppet.com/docs/puppet/latest/types/package.html)
- Chef: [Package Resource](https://docs.chef.io/resources/package/)
- SaltStack: [Package Management](https://docs.saltproject.io/en/latest/ref/states/all/salt.states.pkg.html)
- Jamf: [Installation and Configuration](https://www.jamf.com/resources/product-documentation/)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Maintainer**: System Administration Team

