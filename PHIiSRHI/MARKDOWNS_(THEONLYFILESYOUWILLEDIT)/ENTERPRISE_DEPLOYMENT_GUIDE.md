# Enterprise Deployment Guide

**Last Updated:** November 2024

A comprehensive guide to modern enterprise deployment strategies, tools, and best practices for managing large-scale IT infrastructure across Windows, macOS, iOS, and Android devices.

---

## Table of Contents

1. [Mass Deployment Tools](#mass-deployment-tools)
2. [Configuration Management](#configuration-management)
3. [Zero-Touch Deployment](#zero-touch-deployment)
4. [Monitoring and Compliance](#monitoring-and-compliance)
5. [Network Considerations](#network-considerations)
6. [Integration Strategies](#integration-strategies)

---

## Mass Deployment Tools

Enterprise organizations require robust tools for deploying applications, patches, and configurations across hundreds or thousands of devices. This section covers the leading deployment platforms.

### SCCM/MECM (Microsoft Endpoint Configuration Manager)

**Overview:**
Microsoft Endpoint Configuration Manager (formerly SCCM) is an on-premises solution for managing Windows environments, particularly effective in hybrid scenarios combining traditional infrastructure with cloud services.

**Key Features:**
- Application deployment and patching
- Software update management (WSUS integration)
- Operating system deployment (OSD)
- Configuration baseline management
- Works with BranchCache for WAN optimization

**Use Cases:**
- On-premises Windows device management
- Legacy infrastructure with branch offices
- Hybrid cloud scenarios
- Complex security baseline enforcement

**Setup Guide:**

```powershell
# MECM Site Server Installation Prerequisites
# 1. Windows Server 2019 or 2022
# 2. SQL Server 2019 or 2022
# 3. .NET Framework 4.8
# 4. IIS for application catalog

# Example: Enable BranchCache for MECM Distribution Points
# In Distribution Point properties -> Configure for BranchCache

# Create a distribution point group for branch locations
New-CMDistributionPointGroup -Name "Branch_Offices_DPG"

# Add distribution points to the group
Add-CMDistributionPointToGroup -DistributionPointGroupName "Branch_Offices_DPG" `
  -DistributionPointName "DP-BRANCH-01"

# Deploy application with prerequisite checking
New-CMApplicationDeployment -ApplicationName "Microsoft Office 365" `
  -CollectionName "All Windows Devices" `
  -DeploymentAction Install `
  -Purpose Required `
  -AllowRepairApp $True `
  -PreDeploy $True
```

**Configuration Example:**

```xml
<!-- Application deployment configuration in MECM -->
<?xml version="1.0" encoding="utf-8"?>
<AppMgmtDigest version="1.0" xmlns="http://schemas.microsoft.com/SystemCenterConfigurationManager/2012/AppMgmtDigest">
  <Application AuthoringScopeId="admin" LogicalName="Adobe_Reader_2024"
    xmlns="http://schemas.microsoft.com/SystemCenterConfigurationManager/2012/AppMgmtDigest">
    <DisplayInfo DefaultLanguage="en-US">
      <Info Language="en-US">
        <Title>Adobe Reader 2024</Title>
        <Description>PDF Reader for Enterprise</Description>
      </Info>
    </DisplayInfo>
    <DeploymentType AuthoringScopeId="admin" LogicalName="AdobeReader_Win32">
      <DeploymentTypeSpecificData>
        <MSIData>
          <MSIProductID>{AC76BA86-7AD7-1033-7B44-AC0F074E4100}</MSIProductID>
          <MSIFileName>AdobeReader2024.msi</MSIFileName>
          <MSIInstallParameters>ALLUSERS=1 /quiet /norestart</MSIInstallParameters>
        </MSIData>
      </DeploymentTypeSpecificData>
    </DeploymentType>
  </Application>
</AppMgmtDigest>
```

---

### Microsoft Intune

**Overview:**
Microsoft Intune is a cloud-native Mobile Device Management (MDM) and Unified Endpoint Management (UEM) solution for managing modern workforces with BYOD support and deep Microsoft 365 integration.

**Key Features:**
- Cloud-based Windows, iOS, Android, and macOS management
- Mobile Application Management (MAM)
- Conditional Access integration
- Compliance policies
- Win32 application deployment
- Autopilot integration

**Use Cases:**
- Cloud-first organizations
- Hybrid work environments
- BYOD scenarios
- Zero-touch provisioning
- Third-party integration (Jamf for macOS)

**Setup Guide:**

```powershell
# Intune Deployment Configuration

# 1. Windows Win32 App Deployment
# Create .intunewin file from application installer
# Use: IntuneWinAppUtil.exe -c "C:\Apps\Setup.exe" -o "C:\Output"

# 2. Create Win32 App in Intune (PowerShell example)
$appName = "Microsoft Edge Enterprise"
$appVersion = "131.0.0"
$setupFile = "MicrosoftEdgeEnterpriseX64.msi"
$installCommand = "msiexec.exe /i `"MicrosoftEdgeEnterpriseX64.msi`" /quiet /norestart"
$uninstallCommand = "msiexec.exe /x `"{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}`" /quiet /norestart"

# 3. Create Compliance Policy (PowerShell)
$compliancePolicy = @{
  "@odata.type" = "#microsoft.graph.iosCompliancePolicy"
  displayName = "iOS Compliance Requirements"
  description = "Enterprise iOS device requirements"
  isScheduledActionEnabled = $true
  passwordBlockSimple = $true
  passwordMinimumLength = 6
  passwordMinimumComplexCharacters = 2
  osMinimumVersion = "15.0"
  osMaximumVersion = "18.0"
  storageRequireEncryption = $true
  disableAppClipBlocking = $false
}

# 4. Deploy Conditional Access Policy
# Require compliant devices for Microsoft 365 access
# Block legacy authentication
# Require MFA for high-risk sign-ins
```

**Configuration Example:**

```json
{
  "displayName": "Enterprise Compliance Policy - Windows",
  "description": "Required compliance settings for all corporate devices",
  "rules": [
    {
      "ruleType": "passwordRequired",
      "enabled": true,
      "minLength": 14,
      "requireNumbers": true,
      "requireSpecialCharacters": true,
      "requireUppercase": true,
      "requireLowercase": true
    },
    {
      "ruleType": "osMinimumVersion",
      "enabled": true,
      "version": "21H2"
    },
    {
      "ruleType": "firewallEnabled",
      "enabled": true,
      "firewallType": "windowsDefender"
    },
    {
      "ruleType": "antivirusEnabled",
      "enabled": true,
      "antivirusType": "windowsDefender"
    },
    {
      "ruleType": "storageEncryption",
      "enabled": true,
      "encryptionType": "bitlocker"
    }
  ]
}
```

---

### Jamf Pro

**Overview:**
Jamf Pro is the industry-leading endpoint management platform for Apple devices, trusted by 71% of Fortune 500 companies. It provides complete lifecycle management for macOS, iOS, iPadOS, and tvOS.

**Key Features:**
- Apple device management (macOS, iOS, iPad, Apple TV)
- 190+ software titles in Jamf App Catalog
- Advanced patch management
- Conditional Access integration with Intune
- Zero-trust security capabilities
- Apple Business Manager/Apple School Manager integration

**Use Cases:**
- Dedicated Apple environments
- Hybrid Windows + Apple deployments (with Intune)
- Educational institutions
- Creative studios and design agencies
- Secure BYOD for iOS/iPad

**Setup Guide:**

```bash
#!/bin/bash
# Jamf Pro Initial Configuration

# 1. Create Distribution Point
# Navigate to Settings > System Settings > Distribution Points
# Add on-premise or cloud-hosted distribution points

# 2. Configure Apple Business Manager/Apple School Manager
# Link ABM/ASM account to Jamf Pro
# Configure automated device enrollment

# 3. Create Jamf Pro Users with proper scopes
# Create Admin/Read Only users
# Assign OrgUnit and policy scopes

# 4. Example: Deploy application via Jamf
curl -X POST \
  https://jss-hostname.jamfcloud.com/JSSResource/computergroups \
  -H "Content-Type: application/xml" \
  -u username:password \
  -d '<?xml version="1.0" encoding="UTF-8"?><computer_group>
    <name>Marketing-Department</name>
    <criteria>
      <criterion>
        <name>Department</name>
        <priority>0</priority>
        <and_or>and</and_or>
        <search_type>is</search_type>
        <value>Marketing</value>
      </criterion>
    </criteria>
  </computer_group>'

# 5. Configuration Profile Example
# Create through Jamf Pro UI: Settings > Configuration Profiles
# Profile examples:
# - Wi-Fi (certificate-based authentication)
# - VPN (AnyConnect, F5, etc.)
# - Restrictions (disable certain features)
# - Passcode (policy enforcement)
```

**Configuration Profile Example (macOS):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>PayloadDisplayName</key>
      <string>WiFi Configuration</string>
      <key>PayloadIdentifier</key>
      <string>com.jamf.wifi.corporate</string>
      <key>PayloadType</key>
      <string>com.apple.wifi.managed</string>
      <key>SSID_STR</key>
      <string>CorporateNetwork</string>
      <key>AutoJoin</key>
      <true/>
      <key>EAPClientConfiguration</key>
      <dict>
        <key>EAPClientEnabled</key>
        <true/>
        <key>EAPProtocolType</key>
        <string>EAP-TLS</string>
        <key>TTLSInnerAuthentication</key>
        <string>PAP</string>
        <key>PayloadCertificateAnchorUUID</key>
        <array>
          <string>{certificate-uuid}</string>
        </array>
      </dict>
    </dict>
  </array>
  <key>PayloadDescription</key>
  <string>Configures WiFi settings for corporate network access</string>
  <key>PayloadDisplayName</key>
  <string>Corporate WiFi</string>
  <key>PayloadIdentifier</key>
  <string>com.jamf.profiles.wifi</string>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>{generated-uuid}</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
</plist>
```

---

### PDQ Deploy

**Overview:**
PDQ Deploy is a Windows-focused deployment solution for on-premises environments, enabling rapid application and patch deployment without cloud dependency. Best suited for traditional Windows shops.

**Key Features:**
- 200+ pre-built software packages
- Schedule deployments by time, interval, or machine availability
- Windows update management
- Custom script deployment
- Agentless architecture
- Bundle creation and maintenance

**Use Cases:**
- Pure Windows environments
- Organizations avoiding cloud deployment tools
- Third-party application patching
- Script-based configuration
- MSP (Managed Service Provider) deployments

**Setup Guide:**

```powershell
# PDQ Deploy Installation and Configuration

# 1. System Requirements
# - Windows 10/11 or Windows Server 2019+
# - .NET Framework 4.7.2+
# - Local admin rights for deployment

# 2. Install PDQ Deploy
# Download from https://www.pdq.com/pdq-deploy/
# Run installer: PDQDeploySetup.exe
# Choose Enterprise (multi-admin) or Standard (single admin)

# 3. Configure Deployment Package (PowerShell example)
$packageName = "Adobe Reader 2024"
$installerPath = "\\FileServer\Installs\AdobeReader\AdobeReader2024.msi"
$installCommand = "msiexec.exe /i `"AdobeReader2024.msi`" /quiet /norestart ALLUSERS=1"
$uninstallCommand = "msiexec.exe /x `"{AC76BA86-7AD7-1033-7B44-AC0F074E4100}`" /quiet /norestart"

# 4. Create Deployment Schedule
# Example: Deploy security patches weekly on Sunday 2 AM
# Condition: Computer is Online AND Last Deployment Success

# 5. Configure Failure Handling
# Retry on failure: 3 attempts with 60-second intervals
# Send notifications to admin on failure
```

**PDQ Deploy Package Configuration:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<Package Name="Microsoft Office 365 Apps for Enterprise"
  Version="131.0"
  Publisher="Microsoft">
  <Step Number="1" Name="Installation" Type="Command">
    <Command Exe="msiexec.exe"
      Parameters="/i &quot;OfficeSetup.msi&quot; /quiet /norestart"
      Wait="True"
      HideWindow="True"
      SuccessCodes="0,3010" />
  </Step>
  <Step Number="2" Name="Post-Install Configuration" Type="PowerShell">
    <Script>
      # Disable telemetry
      reg add "HKCU\Software\Microsoft\Office\16.0\Common"
        /v SendTelemetry /t REG_DWORD /d 3 /f

      # Configure auto-update settings
      reg add "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
        /v UpdatesEnabled /t REG_SZ /d True /f
    </Script>
  </Step>
</Package>
```

---

### Ansible Tower / Red Hat Ansible Automation Platform

**Overview:**
Ansible Tower (now Red Hat Ansible Automation Platform) provides an enterprise-grade interface for Ansible infrastructure automation, adding centralized control, scheduling, RBAC, and audit logging.

**Key Features:**
- Agentless automation
- Web-based console and REST API
- Role-Based Access Control (RBAC)
- Job scheduling and notification
- Credential management vault
- Inventory management
- Supports Windows, Linux, macOS

**Use Cases:**
- Infrastructure-as-Code (IaC) deployments
- Multi-platform configuration management
- CI/CD pipeline integration
- Cross-platform automation
- DevOps environments

**Setup Guide:**

```bash
#!/bin/bash
# Red Hat Ansible Automation Platform Setup

# 1. Installation Prerequisites
# - RHEL 8+ or CentOS 8+
# - 4GB RAM minimum (8GB+ recommended)
# - 40GB disk space
# - Python 3.8+

# 2. Download and Install
mkdir -p /opt/ansible-automation
cd /opt/ansible-automation
wget https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
tar xzf ansible-tower-setup-latest.tar.gz
cd ansible-tower-setup-*/

# 3. Configure inventory file
cat > inventory << EOF
[all:vars]
admin_user='admin'
admin_password='your-strong-password'
pg_password='your-db-password'
rabbitmq_password='your-rabbitmq-password'
secret_key='your-secret-key'
license_type=enterprise

[local]
localhost ansible_connection=local
EOF

# 4. Run the installer
./setup.sh

# 5. Access Ansible Tower
# https://your-tower-hostname
# Login with admin credentials

# 6. Create Execution Environment
# Ansible Tower uses execution environments for running playbooks

# 7. Example Playbook: Deploy Windows Updates via Intune
```

**Ansible Playbook Example:**

```yaml
---
- name: Deploy Configuration via Ansible Automation Platform
  hosts: all
  gather_facts: yes

  vars:
    deployment_package: "Microsoft.Office.2024.x64"
    deployment_env: "Production"

  tasks:
    - name: Check system requirements
      assert:
        that:
          - ansible_distribution in ['CentOS', 'RedHat', 'Ubuntu', 'Debian']
          - ansible_memtotal_mb >= 4096
        fail_msg: "System does not meet deployment requirements"

    - name: Configure deployment repository
      yum_repository:
        name: corp-deployment-repo
        description: Corporate Deployment Repository
        baseurl: "https://repo.corp.internal/deployment/"
        gpgcheck: yes
        state: present
      when: ansible_os_family == "RedHat"

    - name: Deploy application package
      package:
        name: "{{ deployment_package }}"
        state: present
        update_cache: yes
      notify:
        - Restart application
        - Log deployment

    - name: Configure firewall rules
      firewalld:
        service: "{{ item }}"
        permanent: yes
        state: enabled
      loop:
        - http
        - https
      when: ansible_os_family == "RedHat"

    - name: Generate deployment report
      template:
        src: deployment_report.j2
        dest: /var/log/deployment/{{ inventory_hostname }}_{{ ansible_date_time.iso8601 }}.log
      vars:
        deployment_status: "Successful"
        timestamp: "{{ ansible_date_time.iso8601 }}"

  handlers:
    - name: Restart application
      service:
        name: app-service
        state: restarted

    - name: Log deployment
      shell: |
        echo "Deployment completed at $(date)" >> /var/log/deployment.log
```

---

### Puppet Enterprise

**Overview:**
Puppet Enterprise is an agentless and agent-based infrastructure automation platform with enterprise governance, enabling declarative configuration management at scale.

**Key Features:**
- Declarative configuration management
- Agent-based (remote execution) and agentless (SSH) modes
- Enterprise console with dashboard
- Puppet Orchestrator for workflow automation
- Policy enforcement engine
- Compliance reporting and remediation

**Use Cases:**
- Large-scale infrastructure management
- Multi-cloud deployments
- Compliance and policy enforcement
- Persistent configuration drift prevention

**Setup Guide:**

```bash
#!/bin/bash
# Puppet Enterprise Installation (7.x/2025.x)

# 1. System Requirements
# - RHEL/CentOS 7+ or Ubuntu 18.04+
# - 4GB RAM (8GB+ for production)
# - 10GB+ disk space

# 2. Download Puppet Enterprise
cd /tmp
wget https://s3.amazonaws.com/pe-releases/2025.2.0/puppet-enterprise-2025.2.0-el-7-x86_64.tar.gz
tar xzf puppet-enterprise-2025.2.0-el-7-x86_64.tar.gz
cd puppet-enterprise-2025.2.0-el-7-x86_64

# 3. Create pe.conf configuration
cat > pe.conf << EOF
---
pe_install::puppet_master_host: "%{::trusted.certname}"
console_admin_password: "your-strong-password"
puppet_enterprise::profile::master::code_manager_auto_configure: true
puppet_enterprise::profile::master::file_sync_enabled: true
EOF

# 4. Run installer
sudo ./puppet-enterprise-installer -c pe.conf

# 5. Access Puppet Enterprise Console
# https://your-puppet-master:443
# Login with admin credentials

# 6. Install Puppet agent on nodes
curl -k https://your-puppet-master:8140/packages/current/install.bash | sudo bash
```

**Puppet Manifest Example:**

```puppet
# Site manifest for enterprise configuration management

node 'web-server-01.prod.corp' {
  # Define web server configuration
  include::apache::mod::ssl
  include::apache::mod::rewrite

  class { 'apache':
    default_mods => true,
    default_vhost => false,
  }

  apache::vhost { 'corporate-portal':
    port    => 443,
    docroot => '/var/www/html',
    ssl     => true,
    ssl_cert    => '/etc/ssl/certs/corp-portal.crt',
    ssl_key     => '/etc/ssl/private/corp-portal.key',
    ssl_ca      => '/etc/ssl/certs/ca-bundle.crt',
  }

  # Configure firewall
  firewall { '100 allow https':
    dport  => 443,
    proto  => tcp,
    action => accept,
  }
}

node 'database-server-01.prod.corp' {
  # Database configuration
  class { 'mysql::server':
    root_password           => hiera('mysql_root_password'),
    remove_default_accounts => true,
    override_options        => {
      'mysqld' => {
        'bind-address' => '10.0.1.50',
        'max_connections' => 500,
      }
    }
  }
}

# Default configuration
node default {
  # Basic node configuration
  file { '/etc/motd':
    ensure  => file,
    content => "Managed by Puppet Enterprise\n",
  }

  # Ensure key packages are installed
  package { ['curl', 'wget', 'vim', 'openssh-clients']:
    ensure => present,
  }
}
```

---

### Chef Automate

**Overview:**
Chef Automate provides a unified platform for infrastructure automation, compliance management, and visibility across on-premises and cloud environments.

**Key Features:**
- Chef Infra for configuration management
- Chef Habitat for application packaging
- Chef Inspect for compliance scanning
- Compliance remediation
- Visibility dashboard
- Unified workflow automation

**Use Cases:**
- Complex infrastructure environments
- Compliance-driven deployments
- Application-infrastructure convergence
- Multi-cloud automation

**Setup Guide:**

```bash
#!/bin/bash
# Chef Automate Installation

# 1. System Requirements
# - Linux (RHEL, CentOS, Ubuntu 18.04+)
# - 8GB+ RAM
# - 80GB+ disk space

# 2. Download Chef Automate
mkdir -p /opt/chef-automate
cd /opt/chef-automate
curl https://packages.chef.io/files/stable/chef-automate/4.12.0/ubuntu/22.04/chef-automate_4.12.0-1_amd64.deb \
  -o chef-automate_4.12.0-1_amd64.deb
sudo dpkg -i chef-automate_4.12.0-1_amd64.deb

# 3. Initialize Chef Automate
sudo chef-automate init-config

# 4. Deploy Chef Automate
sudo chef-automate deploy config.toml --airgap-bundle automate-airgap-bundle.aib

# 5. Access Chef Automate
# https://your-automate-hostname
# Token-based authentication

# 6. Connect Chef Infra Servers
# Register existing Chef Infra Servers with Chef Automate

# 7. Deploy Chef Agent to nodes
knife bootstrap 10.0.1.100 -x ubuntu -P password --node-name web-server-01
```

**Chef Recipe Example:**

```ruby
# Chef recipe for enterprise application deployment

# Define variables
app_version = '3.2.1'
app_user = 'appservice'
app_group = 'appservice'
app_home = '/opt/corporate-app'

# Create service account
user app_user do
  comment 'Corporate Application Service Account'
  home '/var/lib/appservice'
  shell '/bin/false'
  manage_home true
end

group app_group do
  members [app_user]
  action :manage
end

# Download and extract application
remote_file "#{Chef::Config[:file_cache_path]}/corporate-app-#{app_version}.tar.gz" do
  source "https://artifacts.corp.internal/corporate-app-#{app_version}.tar.gz"
  checksum 'sha256:abc123def456...'
  action :create
end

bash 'extract_application' do
  code <<-EOH
    mkdir -p #{app_home}
    tar xzf #{Chef::Config[:file_cache_path]}/corporate-app-#{app_version}.tar.gz \
      -C #{app_home} --strip-components=1
  EOH
  only_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/corporate-app-#{app_version}.tar.gz") }
end

# Set permissions
directory app_home do
  owner app_user
  group app_group
  mode '0755'
  recursive true
end

# Configure systemd service
systemd_unit 'corporate-app.service' do
  content({
    Unit: {
      Description: 'Corporate Application Service',
      After: 'network.target',
    },
    Service: {
      Type: 'simple',
      User: app_user,
      Group: app_group,
      ExecStart: "#{app_home}/bin/app-start.sh",
      Restart: 'always',
      RestartSec: 10,
    },
    Install: {
      WantedBy: 'multi-user.target',
    },
  })
  action [:create, :enable, :start]
end
```

---

## Configuration Management

Configuration management tools maintain consistent system state and enforce organizational policies across the infrastructure.

### Group Policy (GPO)

**Overview:**
Group Policy is a Windows-based infrastructure for centralized management of user and computer settings in Active Directory environments.

**Key Features:**
- Centralized policy management
- User and computer configuration separation
- Folder redirection and offline files
- Software installation via GPO
- Security policy enforcement
- Audit and compliance tracking

**Best Practices (2024):**

1. **OU Structure Design**
   - Separate users and computers into different OUs
   - Create OUs by department, location, or function
   - Align with organizational structure for clarity

2. **GPO Naming Convention**
   ```
   [C/U]-[Function]-[Environment]-[Version]
   Examples:
   - C-SecurityBaseline-Production-v1
   - U-PasswordPolicy-All-v2
   - C-WindowsUpdates-Staging-v1
   ```

3. **Default Domain Policy Usage**
   - Use ONLY for:
     - Account policies
     - Password policies
     - Account lockout policies
     - Kerberos policies
   - Apply all other settings to separate GPOs

4. **Performance Optimization**
   - Disable unused user/computer configurations
   - Balance GPO size (large GPOs process faster but harder to troubleshoot)
   - Use block inheritance sparingly
   - Link GPOs at OU level, not domain level

**Setup and Configuration:**

```powershell
# Group Policy Management via PowerShell

# 1. Create OU Structure
New-ADOrganizationalUnit -Name "Workstations" -Path "DC=corp,DC=com"
New-ADOrganizationalUnit -Name "Windows10" -Path "OU=Workstations,DC=corp,DC=com"
New-ADOrganizationalUnit -Name "Windows11" -Path "OU=Workstations,DC=corp,DC=com"
New-ADOrganizationalUnit -Name "Servers" -Path "DC=corp,DC=com"
New-ADOrganizationalUnit -Name "Services" -Path "OU=Servers,DC=corp,DC=com"

# 2. Create GPOs
New-GPO -Name "C-SecurityBaseline-Windows11-v1" -Comment "Windows 11 Security Baseline"
New-GPO -Name "U-PasswordPolicy-Enterprise-v1" -Comment "Enterprise Password Requirements"
New-GPO -Name "C-Bitlocker-Required-v1" -Comment "Bitlocker Enforcement"

# 3. Link GPOs to OUs
New-GPLink -Name "C-SecurityBaseline-Windows11-v1" `
  -Target "OU=Windows11,OU=Workstations,DC=corp,DC=com" `
  -LinkEnabled Yes

# 4. Configure Security Baseline Settings
$gpo = Get-GPO -Name "C-SecurityBaseline-Windows11-v1"
Set-GPRegistryValue -Guid $gpo.Id -Key "HKLM\Software\Policies\Microsoft\Windows\System" `
  -ValueName "EnableWindowsUpdate" -Type DWord -Value 1

# 5. Force Group Policy Update
gpupdate /force /sync

# 6. Verify GPO Application
Get-ADComputer -SearchBase "OU=Windows11,OU=Workstations,DC=corp,DC=com" -Filter "*" |
  ForEach-Object {
    Write-Host "Checking $_"
    Invoke-Command -ComputerName $_.Name -ScriptBlock {
      gpresult /h C:\gpreport.html /scope:computer
    }
  }
```

**GPO Example: Windows Security Baseline**

```powershell
# Import LGPO Tool for batch GPO application
# Download: https://www.microsoft.com/en-us/download/details.aspx?id=55319

# Create GPO backup
Backup-GPO -Name "C-SecurityBaseline-Windows11-v1" `
  -Path "C:\GPOBackups\SecurityBaseline"

# Export to LGPO format for mass deployment
Export-GPO -Name "C-SecurityBaseline-Windows11-v1" `
  -Path "C:\GPOExport\" -Comment "Security Baseline Export"

# Apply GPO settings locally (for testing)
# Copy LGPO.exe and policy files to target machine
C:\lgpo\LGPO.exe /g C:\Policies\SecurityBaseline
```

---

### macOS Configuration Profiles

**Overview:**
macOS configuration profiles are XML files containing settings and restrictions deployed via MDM solutions (Jamf Pro, Microsoft Intune, SimpleMDM, etc.).

**Key Features:**
- Certificate-based authentication
- VPN and Wi-Fi configuration
- Password policy enforcement
- Application restrictions
- FileVault encryption enforcement
- System Extension approvals

**Configuration Profile Creation:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <!-- Security & Privacy Settings -->
    <dict>
      <key>PayloadDisplayName</key>
      <string>Security Settings</string>
      <key>PayloadIdentifier</key>
      <string>com.corp.security</string>
      <key>PayloadType</key>
      <string>com.apple.ManagedClient.preferences</string>
      <key>PayloadUUID</key>
      <string>{UUID-1}</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>Forced</key>
      <array>
        <dict>
          <key>mcx_preference_settings</key>
          <dict>
            <key>com.apple.screensaver</key>
            <dict>
              <key>askForPassword</key>
              <integer>1</integer>
              <key>askForPasswordDelay</key>
              <integer>0</integer>
              <key>idleTime</key>
              <integer>300</integer>
            </dict>
            <key>com.apple.LaunchServices</key>
            <dict>
              <key>LSQuarantine</key>
              <true/>
            </dict>
          </dict>
        </dict>
      </array>
    </dict>

    <!-- FileVault Encryption -->
    <dict>
      <key>PayloadDisplayName</key>
      <string>FileVault Encryption</string>
      <key>PayloadIdentifier</key>
      <string>com.corp.filevault</string>
      <key>PayloadType</key>
      <string>com.apple.MCX.FileVault2</string>
      <key>PayloadUUID</key>
      <string>{UUID-2}</string>
      <key>Enable</key>
      <string>On</string>
      <key>Defer</key>
      <true/>
      <key>DeferForceAtUserLoginMaxBypassAttempts</key>
      <integer>5</integer>
      <key>ShowRecoveryKey</key>
      <true/>
    </dict>

    <!-- Passcode Policy -->
    <dict>
      <key>PayloadDisplayName</key>
      <string>Passcode Policy</string>
      <key>PayloadIdentifier</key>
      <string>com.corp.passcode</string>
      <key>PayloadType</key>
      <string>com.apple.mobiledevice.user</string>
      <key>PayloadUUID</key>
      <string>{UUID-3}</string>
      <key>allowSimple</key>
      <false/>
      <key>forcePIN</key>
      <true/>
      <key>maxFailedAttempts</key>
      <integer>6</integer>
      <key>maxPinLifetime</key>
      <integer>180</integer>
      <key>minComplexChars</key>
      <integer>1</integer>
      <key>minLength</key>
      <integer>6</integer>
      <key>requireAlphanumeric</key>
      <true/>
    </dict>
  </array>

  <key>PayloadDescription</key>
  <string>Enterprise macOS Configuration Profile</string>
  <key>PayloadDisplayName</key>
  <string>Corporate macOS Settings</string>
  <key>PayloadIdentifier</key>
  <string>com.corp.macos.configuration</string>
  <key>PayloadRemovalDisallowed</key>
  <false/>
  <key>PayloadScope</key>
  <string>System</string>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>{MAIN-UUID}</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
</plist>
```

**iMazing Profile Editor:**
- Free macOS tool for creating/editing configuration profiles
- GUI-based approach (no XML editing required)
- Download: https://imazing.com/profile-editor

---

### SaltStack

**Overview:**
SaltStack is an event-driven infrastructure automation and configuration management platform supporting thousands of nodes with minimal overhead.

**Key Features:**
- Event-driven architecture
- Remote execution (salt command)
- Configuration management (states)
- Orchestration
- Masterless mode support
- Python-based customization

**Basic Setup:**

```bash
#!/bin/bash
# SaltStack Installation and Configuration

# 1. Install SaltStack Master
sudo apt-get update
sudo apt-get install salt-master

# 2. Configure Master (edit /etc/salt/master)
# Key settings:
# - interface: 0.0.0.0 (listen on all interfaces)
# - publish_port: 4505
# - ret_port: 4506
# - file_roots: /srv/salt
# - pillar_roots: /srv/pillar

# 3. Start Salt Master
sudo systemctl enable salt-master
sudo systemctl start salt-master

# 4. Install Salt Minion on target nodes
sudo apt-get install salt-minion

# 5. Configure Minion (edit /etc/salt/minion)
# Key settings:
# - master: <salt-master-ip>
# - id: <minion-id>

# 6. Start Minion
sudo systemctl enable salt-minion
sudo systemctl start salt-minion

# 7. Accept Minion Keys on Master
sudo salt-key -L  # List pending keys
sudo salt-key -A  # Accept all keys
sudo salt-key -a <minion-id>  # Accept specific key

# 8. Test connectivity
sudo salt '*' test.ping
```

**Salt State Example:**

```yaml
# /srv/salt/webserver/init.sls
# Deploy and configure web server

install-apache:
  pkg.installed:
    - names:
      - apache2
      - apache2-utils
      - libapache2-mod-wsgi

apache2-service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: install-apache

install-dependencies:
  pkg.installed:
    - names:
      - python3
      - python3-pip
      - python3-dev

configure-apache-modules:
  apache_module.enabled:
    - names:
      - rewrite
      - ssl
      - wsgi
      - proxy
    - require:
      - pkg: install-apache

# Deploy application
/var/www/corporate-app:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 755

copy-application:
  file.recurse:
    - name: /var/www/corporate-app
    - source: salt://webserver/files/app
    - user: www-data
    - group: www-data
    - require:
      - file: /var/www/corporate-app
```

---

### Terraform

**Overview:**
Terraform is an Infrastructure-as-Code (IaC) tool for provisioning and managing cloud and on-premises infrastructure resources.

**Key Features:**
- Multi-cloud support (AWS, Azure, GCP, etc.)
- Declarative configuration
- State management
- Module system for reusability
- Plan and apply workflow
- Drift detection

**Terraform Configuration Example:**

```hcl
# Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-enterprise-${var.environment}"
  location = "East US"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "subnet-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Compute Instances
resource "azurerm_virtual_machine_scale_set" "web" {
  name                = "vmss-web-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  upgrade_policy_mode = "Rolling"

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 3
  }

  os_profile {
    computer_name_prefix = "web"
    admin_username       = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
}
```

---

## Zero-Touch Deployment

Zero-touch deployment enables employees to unbox devices and begin working with minimal IT intervention. Devices self-configure based on pre-configured policies and applications.

### Windows Autopilot

**Overview:**
Windows Autopilot is Microsoft's zero-touch provisioning solution for Windows 10/11 devices, enabling automatic enrollment in Microsoft Intune and configuration via cloud policies.

**How It Works:**
1. Device boots and connects to network
2. Autopilot detects device and retrieves pre-configured profile
3. Device enrolls in Intune
4. Configuration profiles and applications auto-deploy
5. User logs in with corporate credentials

**Prerequisites:**
- Microsoft Intune subscription
- Azure AD tenant
- Windows 10/11 Pro/Enterprise/Education

**Setup Guide:**

```powershell
# Windows Autopilot Configuration

# 1. Register devices with Autopilot
# Options:
#   a) Manufacturer registration (OEM pre-registration)
#   b) CSV import via Intune
#   c) Partner registration

# 2. Create CSV for device registration
# Required columns: Device Serial Number, Windows Product ID, IMEI, Hardware ID
# Export from Intune or use Get-WindowsAutoPilotInfo script

# Download and run device hash collector
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/microsoft/windows-itpro-docs/public/windows/deployment/windows-autopilot/get-windowsautopilotinfo.ps1" `
  -OutFile Get-WindowsAutopilotInfo.ps1

.\Get-WindowsAutopilotInfo.ps1 -OutputFile autopilot-devices.csv -Append

# 3. Upload CSV to Intune
# Navigate to: Devices > Windows > Windows enrollment > Devices > Import
# Upload autopilot-devices.csv

# 4. Create Autopilot Deployment Profile
# In Intune: Devices > Windows > Windows enrollment > Deployment Profiles
# Configure settings:
$AutopilotProfile = @{
  DisplayName = "Corporate Windows 11 Standard"
  Description = "Standard deployment for corporate devices"
  DeviceNameTemplate = "CORP-{SERIAL}" # Custom naming
  EnrollmentStatusPage = $true
  BlockDeviceResetOnInstall = $true
  LanguageRegionConfigure = $true
  SkipEula = $true
  SkipCorpSignin = $false
  DiagnosticDataAccentColor = "SkipDiagnosticData"
}

# 5. Create Autopilot Group
$AutopilotGroup = @{
  DisplayName = "Autopilot - Corporate"
  MembershipRuleProcessing = "Dynamic"
  GroupTypes = "DynamicMembership"
  MembershipRule = "(device.deviceCategory -eq `"Corporate`")"
}

# 6. Create Device Configuration Profile
# Configure Windows settings, security baseline, etc.

# 7. Test Deployment
# Reset a test device: Settings > System > Recovery > Reset this PC
# Device will begin Autopilot provisioning flow

# 8. Customize ESP (Enrollment Status Page)
# Configure: Devices > Windows > Device enrollment > Enrollment Status Page
# Show progress, block device usage until ready, etc.

# 9. Monitor Deployments
# Devices > Windows > Windows enrollment > Deployment Profiles > Select Profile
# View enrollment status and troubleshoot issues
```

**Autopilot Troubleshooting:**

```powershell
# On device during/after Autopilot deployment

# 1. Check device registration
# Settings > System > About
# Look for "Enrollment status" section

# 2. View Autopilot diagnostics page
# Press Shift+F10 at OOBE to open command prompt
Get-AutopilotDiagnostics

# 3. Review logs
Get-WindowsAutoPilotDiagnostics -Online -OutputFile C:\autop-diag.txt

# 4. Check device sync status
dsregcmd /status

# 5. Verify MDM enrollment
Get-MdmDiagnosticData

# 6. Collect traces for Microsoft
tracelog -start "autprov" -p "{E4F68870-5AE8-4E5B-9CE9-2B81606E2843}" -ets
# Reproduce issue
tracelog -stop "autprov" -ets
```

---

### Apple DEP/ABM (Automated Device Enrollment / Apple Business Manager)

**Overview:**
Apple Device Enrollment Program (now Automated Device Enrollment/ADE) and Apple Business Manager (ABM) enable zero-touch provisioning of Apple devices through pre-enrollment and configuration.

**How It Works:**
1. Devices purchased through authorized Apple resellers
2. Organization links Apple Business Manager account
3. Devices automatically enroll in MDM at first setup
4. Configuration profiles and applications deploy automatically
5. User completes setup assistant with managed settings

**Prerequisites:**
- Apple Business Manager account (free)
- MDM solution (Jamf Pro, Intune, SimpleMDM, etc.)
- Devices purchased from authorized Apple reseller

**Setup Guide:**

```bash
#!/bin/bash
# Apple DEP/ABM Configuration (with Jamf Pro example)

# 1. Enroll in Apple Business Manager
# Visit: https://business.apple.com
# Sign in with Apple ID
# Complete organization verification
# Accept terms and conditions

# 2. Generate DEP server token in ABM
# Settings > Device Management Settings
# Select your MDM server (Jamf Pro)
# Download .p7m token file

# 3. Configure Jamf Pro
# Settings > Global Management > Apple Business Manager
# Upload DEP token (.p7m file)

# 4. Configure Automated Device Enrollment settings
# In Jamf Pro: Settings > Global Management > Apple Business Manager
# Configure:
# - Default MDM server
# - User-initiated enrollment
# - Skip Setup Assistant screens
# - Assign configuration profiles

# 5. Create Jamf Pro Automated Device Enrollment profile
curl -X POST \
  https://jss.corp.jamfcloud.com/JSSResource/MobileDevicePreEnrollment \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -u username:password \
  -d '{
    "name": "Corporate iPad DEP Profile",
    "supportEmails": ["it-support@corp.com"],
    "department": "Information Technology",
    "supervisorAccountCreation": true,
    "supervisorAccountPassword": "TempPassword123!",
    "language": "en",
    "showMDMTerms": false,
    "showWelcomeScreen": true,
    "requireAuthentication": true,
    "iphone": {
      "supervised": true
    },
    "ipad": {
      "supervised": true
    }
  }'

# 6. Add devices to ABM (automatic via reseller)
# Devices appear in ABM within 24-48 hours of purchase
# Verify in Apple Business Manager > Devices

# 7. Assign devices to MDM
# In Jamf Pro: Devices > Enrolled Devices > All Devices
# Or use API to bulk assign:
for device_serial in $(cat device_serials.txt); do
  curl -X POST \
    "https://jss.corp.jamfcloud.com/JSSResource/MobileDevicePreEnrollment?serial=$device_serial" \
    -H "Content-Type: application/json" \
    -u username:password
done

# 8. Monitor device enrollment
# Jamf Pro: Dashboards > Device enrollment
# Apple Business Manager: Devices > Assignment status

# 9. Deploy configuration profiles via ADE
# Create configuration profiles in Jamf Pro
# Link to DEP profile
# Profiles auto-deploy at first device enrollment
```

---

### Android Zero-Touch

**Overview:**
Android Enterprise Zero-Touch Enrollment enables automated provisioning of Android devices through Google's partner ecosystem.

**Key Features:**
- Automatic enrollment in Mobile Device Management
- Pre-configured apps and policies
- Works with any Android EMM partner
- Supports dedicated devices, corporate-owned multi-user, and BYOD modes

**Setup:**

```bash
#!/bin/bash
# Android Zero-Touch Configuration

# 1. Enroll in Android Zero-Touch
# Visit: https://zero-touch.googlebapis.com
# Sign in with Google account
# Add organization

# 2. Create configuration
curl -X POST https://zerotouch.googleapis.com/v1/organizations/[ORG_ID]/configurations \
  -H "Authorization: Bearer [ACCESS_TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "[CUSTOMER_ID]",
    "displayName": "Corporate Device Config",
    "dpcResourcePath": "enterprises/[ENTERPRISE_ID]/devicePolicies/[POLICY_NAME]",
    "isDefault": true
  }'

# 3. Upload device list (CSV from reseller)
# File format: device_identifier,customer_identifier
curl -X POST https://zerotouch.googleapis.com/upload \
  -F "file=@devices.csv" \
  -H "Authorization: Bearer [ACCESS_TOKEN]"

# 4. Assign configuration to devices
curl -X POST https://zerotouch.googleapis.com/v1/organizations/[ORG_ID]/devices:applyConfiguration \
  -H "Authorization: Bearer [ACCESS_TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{
    "configuration": "organizations/[ORG_ID]/configurations/[CONFIG_ID]",
    "device": {
      "deviceIdentifier": "device_serial_123"
    }
  }'

# 5. Verify setup
# Android Zero-Touch Portal: Devices tab
# Confirm device status and configuration assignment
```

---

### PXE Boot & WDS (Windows Deployment Services)

**Overview:**
PXE (Preboot Execution Environment) and WDS enable network-based OS deployment for bare-metal provisioning at scale.

**Prerequisites:**
- WDS server (Windows Server 2019/2022)
- DHCP with PXE options configured
- Network interface cards supporting PXE
- Boot images and OS images

**Setup Guide:**

```powershell
# Windows Deployment Services Configuration

# 1. Install WDS Role
Install-WindowsFeature WDS -IncludeManagementTools

# 2. Configure WDS Server
# Open WDS Management Console
# Configure paths for boot/install images
# Network boot program location typically: \\wds-server\RemoteInstall

# 3. Add Boot Images
# Import Windows PE image for 64-bit
# Add-WdsBootImage -Path "C:\WDS\boot\boot.wim" `
#   -NewImageName "Windows PE x64"

# 4. Add Install Images
# Import Windows 11 installation image
# Add-WdsInstallImage -Path "C:\WDS\sources\install.wim" `
#   -ImageGroup "Windows 11" `
#   -NewImageName "Windows 11 Enterprise"

# 5. Configure DHCP Options for PXE
# DHCP Server > Scope Options > Add
# Option 066 (Boot Server Host Name): wds-server.corp.com
# Option 067 (Boot File Name): \boot\x64\wdsnbp.exe

# 6. Create Capture Image for custom Windows deployments
# Create reference device with desired configuration
# Boot from WDS PXE
# Capture image for future deployments

# 7. Configure Client Unattend Answers
# Create unattend.xml for automated setup
# Configure in WDS: Properties > Client tab

# 8. Test PXE Boot
# Set target device to boot from network (PXE)
# Device should discover WDS server and begin deployment

# Example PowerShell for mass PXE deployment
$imageGroup = "Windows 11"
$imageName = "Windows 11 Enterprise"
$computers = @(
  "CORP-WS-001",
  "CORP-WS-002",
  "CORP-WS-003"
)

foreach ($computer in $computers) {
  # In production, you would:
  # 1. Set computer to PXE boot in BIOS
  # 2. Power on device
  # 3. Device boots from WDS and deploys OS
  # 4. Runs unattend.xml for automated configuration
}
```

**Example Unattend.xml (WDS):**

```xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="generalize">
    <component name="Microsoft-Windows-PnpSysprep" processorArchitecture="amd64">
      <PersistAllDeviceInstalls>false</PersistAllDeviceInstalls>
    </component>
  </settings>
  <settings pass="specialize">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64">
      <ComputerName>*</ComputerName>
      <CopyProfile>true</CopyProfile>
    </component>
    <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64">
      <Identification>
        <Credentials>
          <Domain>corp.com</Domain>
          <Password>JoinPassword123!</Password>
          <Username>wds-joiner</Username>
        </Credentials>
        <JoinDomain>corp.com</JoinDomain>
      </Identification>
    </component>
  </settings>
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64">
      <AutoLogon>
        <Password>
          <Value>AutoLogPassword123!</Value>
          <PlainText>true</PlainText>
        </Password>
        <LogonCount>1</LogonCount>
        <Username>Administrator</Username>
      </AutoLogon>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <CommandLine>powershell.exe -ExecutionPolicy Bypass -NoProfile -File C:\Deploy\PostDeploy.ps1</CommandLine>
          <Order>1</Order>
        </SynchronousCommand>
      </FirstLogonCommands>
    </component>
  </settings>
</unattend>
```

---

## Monitoring and Compliance

Enterprise deployments require visibility into device status, software inventory, and compliance with organizational policies.

### Deployment Reporting

**Key Metrics:**
- Deployment success/failure rates
- Device compliance status
- Application installation progress
- Policy application status
- Hardware inventory
- Software licenses in use

**Reporting Tools:**

**1. Intune Reporting:**
```powershell
# Query Intune device compliance via Microsoft Graph
$uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies"
$policies = Invoke-MgGraphRequest -Uri $uri

# Get compliance status for devices
$complianceUri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies/{id}/deviceStatusOverview"
$status = Invoke-MgGraphRequest -Uri $complianceUri

# Export to CSV
$status | Export-Csv -Path "device-compliance-report.csv"
```

**2. MECM/SCCM Reporting:**
```sql
-- SQL Query for deployment status in SCCM
SELECT
  dv.Name,
  da.DisplayName,
  dad.StatusCode,
  dad.LastStatusTime,
  CASE
    WHEN dad.StatusCode = 0 THEN 'Unknown'
    WHEN dad.StatusCode = 1 THEN 'Targeted'
    WHEN dad.StatusCode = 2 THEN 'Initiated'
    WHEN dad.StatusCode = 3 THEN 'Received'
    WHEN dad.StatusCode = 4 THEN 'Failed'
    WHEN dad.StatusCode = 5 THEN 'Retry'
    ELSE 'Other'
  END as Status
FROM
  dbo.Device_Inventory dv
  JOIN dbo.Application_Deployment_Assignments ada ON dv.ResourceID = ada.ResourceID
  JOIN dbo.Application_Deployments ad ON ada.AssignmentID = ad.AssignmentID
  JOIN dbo.v_DeploymentStatus dad ON ad.DeploymentID = dad.DeploymentID
ORDER BY
  da.DisplayName, dv.Name
```

**3. Jamf Pro Reporting:**
```bash
#!/bin/bash
# Get device compliance report from Jamf Pro

# Query Jamf API for mobile device inventory
curl -X GET \
  "https://jss.jamfcloud.com/JSSResource/mobiledevices" \
  -H "Accept: application/json" \
  -u username:password | jq '.mobile_devices[]' > devices.json

# Query specific device details
curl -X GET \
  "https://jss.jamfcloud.com/JSSResource/mobiledevices/id/{device_id}" \
  -H "Accept: application/json" \
  -u username:password | jq '.mobile_device' > device_detail.json
```

---

### Compliance Scanning

**Compliance Frameworks:**
- CIS (Center for Internet Security) Benchmarks
- NIST Cybersecurity Framework
- ISO 27001
- HIPAA (healthcare)
- PCI DSS (payment cards)
- SOC 2

**Compliance Scanning Tools:**

**1. Microsoft Intune Compliance Policies:**
```powershell
# Create Windows 10 Compliance Policy
$compliancePolicy = @{
  "@odata.type" = "#microsoft.graph.windows10CompliancePolicy"
  displayName = "Windows 10 CIS Benchmark"
  description = "CIS Baseline for Windows 10"
  passwordRequired = $true
  passwordMinimumLength = 14
  passwordRequiredType = "complex"
  passwordMinimumCharacterSetCount = 3
  passwordExpirationDays = 90
  passwordPreviousPasswordBlockCount = 24
  osMinimumVersion = "21H2"
  osMaximumVersion = "23H2"
  storageRequireEncryption = $true
  firewallEnabled = $true
  firewallBlockAllIncoming = $false
  antivirusEnabled = $true
  antivirusType = "windowsDefender"
  defenderEnabled = $true
  defenderVersion = "latest"
  securityBlockJailbrokenDevices = $true
  securityEnableNotifications = $true
}

# Create policy via Microsoft Graph
Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies" `
  -Method POST `
  -Body ($compliancePolicy | ConvertTo-Json)
```

**2. Chef Compliance Scanning:**
```ruby
# Chef InSpec profile for compliance testing
# profiles/linux-baseline/controls/example.rb

control '1.1.1' do
  impact 1.0
  title 'Ensure mounting of cramfs filesystems is disabled'
  desc 'Removing support for uncommon filesystems reduces the local attack surface of the system.'

  describe kernel_module('cramfs') do
    it { should_not be_loaded }
  end

  describe file('/etc/modprobe.d/cramfs.conf') do
    its('content') { should match(%r{^install cramfs /bin/true$}) }
  end
end
```

**3. Puppet Compliance Remediation:**
```puppet
# Puppet class for compliance enforcement
class compliance::linux_hardening {

  # Ensure key file permissions
  file { '/etc/passwd':
    mode => '0644',
  }

  file { '/etc/shadow':
    mode => '0000',
    owner => 'root',
    group => 'shadow',
  }

  # Configure sudo access
  file { '/etc/sudoers.d/admins':
    content => @(EOF),
      # Require password for sudo
      Defaults use_pty
      Defaults logfile="/var/log/sudo.log"
      EOF
    mode => '0440',
  }

  # Disable unnecessary services
  service { ['avahi-daemon', 'cups']:
    ensure => 'stopped',
    enable => false,
  }
}
```

---

### Software Inventory

**Inventory Management:**

**1. Intune Hardware Inventory:**
```powershell
# Export device hardware inventory from Intune
$uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$select=id,deviceName,manufacturer,model,osVersion,totalStorageSpace,freeStorageSpace"
$devices = Invoke-MgGraphRequest -Uri $uri -Method GET

$devices.value | Export-Csv -Path "hardware-inventory.csv" -NoTypeInformation
```

**2. SCCM Software Metering:**
```sql
-- Query installed software on all devices
SELECT
  dv.Name,
  ar.DisplayName,
  ar.Version,
  COUNT(*) as DeviceCount
FROM
  dbo.Add_Remove_Programs ar
  JOIN dbo.Device_Inventory dv ON ar.ResourceID = dv.ResourceID
GROUP BY
  ar.DisplayName, ar.Version, dv.Name
ORDER BY
  ar.DisplayName, DeviceCount DESC
```

**3. PDQ Inventory:**
```powershell
# PDQ Inventory provides real-time software/hardware inventory
# Query via REST API

$headers = @{
  'Authorization' = 'Bearer ' + $token
  'Content-Type' = 'application/json'
}

# Get all computers
$response = Invoke-RestMethod -Uri "https://pdq-server:7464/api/computers" `
  -Headers $headers `
  -Method GET

# Get software installed on specific computer
$response = Invoke-RestMethod -Uri "https://pdq-server:7464/api/computers/{computerId}/applications" `
  -Headers $headers `
  -Method GET

# Export to CSV
$response.applications | Export-Csv -Path "software-inventory.csv"
```

---

## Network Considerations

Enterprise deployments span distributed networks with bandwidth constraints and high latency. Optimization technologies reduce WAN utilization and improve deployment speeds.

### BITS (Background Intelligent Transfer Service)

**Overview:**
BITS is a Windows service for asynchronous file transfer with built-in throttling, pause/resume capabilities, and peer-caching integration.

**Key Features:**
- Bandwidth throttling
- Pause and resume transfers
- Automatic retry with backoff
- Integration with BranchCache
- Priority-based scheduling

**Configuration:**

```powershell
# BITS Configuration for Application Deployment

# 1. Configure BITS throttling for Intune updates
reg add "HKLM\Software\Policies\Microsoft\Windows\BITS" `
  /v MaxTransferRateOnSchedule /t REG_DWORD /d 10240 /f  # 10 Mbps

# 2. Enable peer caching (Delivery Optimization)
reg add "HKLM\Software\Policies\Microsoft\Windows\DeliveryOptimization" `
  /v DODownloadMode /t REG_DWORD /d 99 /f  # LAN + Internet peer caching

# 3. Configure BranchCache compatibility
reg add "HKLM\Software\Policies\Microsoft\Windows\DeliveryOptimization" `
  /v DOModifyOnMeteredConnection /t REG_DWORD /d 0 /f

# 4. Monitor BITS jobs
Get-BitsTransfer | Format-Table DisplayName, State, Owner, CreationTime

# 5. Suspend/Resume BITS job
Suspend-BitsTransfer -BitsJob (Get-BitsTransfer -Owner "SYSTEM")[0]
Resume-BitsTransfer -BitsJob (Get-BitsTransfer -Owner "SYSTEM")[0]
```

---

### BranchCache

**Overview:**
BranchCache caches content at branch office locations, reducing WAN bandwidth by serving content from local cache instead of the main office.

**Modes:**
1. **Distributed:** Each branch machine caches content peer-to-peer
2. **Hosted:** Central cache server at branch office

**Setup:**

```powershell
# BranchCache Configuration for Enterprise Deployments

# 1. Enable BranchCache on content servers (main office)
Enable-BCHostedServer -RegisterSCP

# 2. Enable BranchCache on clients
Enable-BCDistributed

# 3. Configure hosted cache server at branch
Install-WindowsFeature BranchCache
Enable-BCHostedServer

# 4. Register hosted cache server
netsh branchcache set cachedatadir -path "D:\BranchCache"
netsh branchcache set servicestarttype auto
net start BranchCache

# 5. Configure BITS to use BranchCache
reg add "HKLM\Software\Policies\Microsoft\Windows\BITS" `
  /v BranchCacheEnabled /t REG_DWORD /d 1 /f

# 6. Configure MECM Distribution Point for BranchCache
# In MECM console: Administration > Distribution Points > Properties
# Configure: Content tab > Enable BranchCache

# 7. Monitor BranchCache performance
Get-BCStatus
Get-BCDataCache
Get-BCNetworkConfiguration

# 8. Clear cache (if needed)
Clear-BCCache -Force
```

---

### Distribution Points & Content Management

**Overview:**
Distributing content across geographically dispersed distribution points ensures rapid, reliable application and update delivery.

**Best Practices:**

```powershell
# MECM Distribution Point Strategy

# 1. Create Distribution Point Groups for geographic regions
New-CMDistributionPointGroup -Name "North-America-DPG" `
  -Description "Distribution Points covering North America"

New-CMDistributionPointGroup -Name "Europe-DPG" `
  -Description "Distribution Points covering Europe"

# 2. Add distribution points to groups
Add-CMDistributionPointToGroup -DistributionPointGroupName "North-America-DPG" `
  -DistributionPointName "DP-NYC-01.corp.com"

Add-CMDistributionPointToGroup -DistributionPointGroupName "North-America-DPG" `
  -DistributionPointName "DP-LAX-01.corp.com"

# 3. Configure package distribution
Start-CMContentDistribution -ApplicationName "Microsoft Office 365" `
  -DistributionPointGroupName "North-America-DPG"

# 4. Monitor distribution status
Get-CMDistributionStatus -ApplicationName "Microsoft Office 365" |
  Where-Object {$_.State -eq 'Failed'} |
  Select-Object Name, State, NumberFailed

# 5. Prioritize critical updates
Update-CMDistributionPoint -DistributionPointName "DP-HQ-01.corp.com" `
  -Priority High

# 6. Configure pull distribution points
# Pull Distribution Points fetch content from parent DP instead of pushing
# Reduces main office bandwidth usage
New-CMDistributionPoint -SiteCode P01 `
  -ServerName "dp-branch-01.corp.com" `
  -ClientCommunicationType "HTTP" `
  -AssumeAccount "CORP\MECM-Service" `
  -PullDistributionPoint `
  -SourceDistributionPoint "DP-HQ-01.corp.com"
```

---

### CDN (Content Delivery Network)

**Overview:**
CDNs distribute content globally through strategically placed edge servers, reducing latency and bandwidth costs.

**Microsoft Connected Cache:**
```powershell
# Microsoft Connected Cache Enterprise (2024+)

# 1. Install Microsoft Connected Cache
# Prerequisites: Windows Server 2019/2022, 4GB RAM, 100GB+ disk

# 2. Configure Azure and Intune
# Register cache server in Intune
# Create distribution group in Azure

# 3. Deploy Microsoft Connected Cache via Intune
# Create Win32 app in Intune with Connected Cache installer
# Deploy to cache servers in branch offices

# 4. Configure BITS to use Microsoft Connected Cache
# Automatically detected by Delivery Optimization on Windows clients
# No client configuration needed

# 5. Monitor cache effectiveness
# Device Health dashboard in Intune
# Track bandwidth savings and cache hit rates
```

**Third-Party CDN Integration (Akamai, Cloudflare, etc.):**
```powershell
# Configure MECM to use CDN for updates

# 1. Set up CDN endpoint
# Many organizations use CDN for OS images, large packages

# 2. Configure MECM to deliver from CDN
# Task sequences can reference CDN URLs for large binaries
# Example: https://cdn.corp.com/deployments/Windows11.iso

# 3. Monitor CDN usage
# View reports in MECM for package distribution
# Track download times and success rates
```

---

## Integration Strategies

### Multi-Platform Deployment Workflow

**Scenario: Deploy Microsoft Office across Windows + macOS + iOS**

```powershell
# Intune + Jamf Pro Integrated Deployment

# Windows Devices (via Intune)
$officeApp = @{
  "@odata.type" = "#microsoft.graph.win32LobApp"
  displayName = "Microsoft Office 2024"
  description = "Office 365 Applications"
  fileName = "Office2024Setup.exe"
  installCommandLine = "setup.exe /configure deploy.xml"
  uninstallCommandLine = "setup.exe /configure deploy-remove.xml"
  owner = "IT Department"
}

# macOS Devices (via Jamf Pro)
# 1. Create macOS app package (.dmg or .pkg)
# 2. Upload to Jamf App Catalog
# 3. Create Jamf policy: Trigger > Enrollment Complete
# 4. Deploy to device/group/user

# iOS Devices (via Intune or Jamf)
$iosApp = @{
  "@odata.type" = "#microsoft.graph.iosVppApp"
  displayName = "Microsoft Office for iPad"
  bundleId = "com.microsoft.office.outlook"
  vppTokenId = "token-id"
  usesVppTokenLicensing = $true
}

# Deploy using application assignments
```

### Compliance Across Platforms

```powershell
# Enforce consistent security baseline across Windows, Mac, iOS, Android

# Windows Compliance Policy (Intune)
$windowsCompliance = @{
  displayName = "Enterprise CIS Baseline"
  passwordRequired = $true
  passwordMinimumLength = 14
  osMinimumVersion = "21H2"
  storageRequireEncryption = $true
  firewallEnabled = $true
}

# macOS Compliance Policy (via Configuration Profile)
# Configuration Profile > Restrictions > Require:
# - FileVault encryption
# - Minimum password length: 14
# - Automatic logout after 5 minutes
# - Disable remote login

# iOS/iPadOS Compliance Policy
$iosCompliance = @{
  displayName = "iOS Security Requirements"
  osMinimumVersion = "16.0"
  osMaximumVersion = "18.0"
  storageRequireEncryption = $true
  passcodeRequired = $true
  passcodeMinimumLength = 6
}
```

---

## Quick Reference Checklist

### Pre-Deployment Planning
- [ ] Define target device scope (Windows/Mac/iOS/Android)
- [ ] Identify deployment tools (cloud vs. on-premises)
- [ ] Plan network bandwidth requirements
- [ ] Establish change management process
- [ ] Create rollback/recovery procedures
- [ ] Define success metrics and monitoring

### Configuration Setup
- [ ] Deploy/configure enrollment servers (MECM, Jamf, etc.)
- [ ] Configure cloud services (Intune, Apple Business Manager)
- [ ] Set up distribution infrastructure (DPs, CDN)
- [ ] Create baseline security policies
- [ ] Configure automated deployment rules
- [ ] Establish monitoring and reporting

### Deployment Execution
- [ ] Create application packages
- [ ] Configure device groups/collections
- [ ] Test in pilot group (5-10% devices)
- [ ] Monitor pilot deployments
- [ ] Phase rollout to broader audiences
- [ ] Collect feedback and adjust

### Post-Deployment
- [ ] Monitor compliance and health
- [ ] Review deployment logs
- [ ] Update documentation
- [ ] Plan maintenance updates
- [ ] Conduct post-mortem analysis
- [ ] Prepare for next deployment cycle

---

## Additional Resources

- **Microsoft Intune Documentation:** https://learn.microsoft.com/en-us/mem/intune/
- **Jamf Pro Documentation:** https://learn.jamf.com/
- **Ansible Automation Platform:** https://www.redhat.com/en/technologies/management/ansible
- **Chef Automate:** https://docs.chef.io/chef_automate/
- **Puppet Enterprise:** https://puppet.com/docs/
- **Windows Autopilot:** https://learn.microsoft.com/en-us/windows/deployment/windows-autopilot/
- **Apple Business Manager:** https://support.apple.com/en-us/HT201318
- **PDQ Deploy:** https://www.pdq.com/documentation/
- **SaltStack Documentation:** https://docs.saltproject.io/

---

**Document Version:** 1.0
**Last Updated:** November 2024
**Maintained By:** Enterprise IT Operations

