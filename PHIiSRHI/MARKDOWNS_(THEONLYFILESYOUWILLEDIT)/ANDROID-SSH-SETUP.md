# Android SSH to Windows 11 via WireGuard VPN

## Architecture

```
Android Phone (WireGuard Client)
    ↓ VPN Tunnel
Router (WireGuard Server + DHCP)
    ↓ LAN
Windows 11 Desktop (SSH Server)
```

**IP Scheme**:
- WireGuard subnet: `10.0.0.0/24` (example)
- Android phone WireGuard IP: `10.0.0.2`
- Router LAN IP: `192.168.1.1`
- Windows 11 LAN IP: `192.168.1.X` (determine actual)
- Router WireGuard IP: `10.0.0.1`

---

## Prerequisites Check

### Router
- [ ] WireGuard server running
- [ ] Android client config exists and connected
- [ ] DHCP server active
- [ ] Firewall rules allow VPN → LAN traffic

### Windows 11
- [ ] Static IP or DHCP reservation
- [ ] PowerShell admin access
- [ ] Windows Firewall accessible

### Android 11
- [ ] WireGuard app installed and connected
- [ ] SSH client app (Termux/JuiceSSH/ConnectBot)
- [ ] Can ping router over VPN

---

## Step 1: Windows 11 SSH Server Setup

### 1.1 Install OpenSSH Server

**PowerShell (Admin)**:
```powershell
# Check if installed
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

# Install if not present
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start and enable service
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Verify running
Get-Service sshd
```

### 1.2 Configure SSH Server

**Edit**: `C:\ProgramData\ssh\sshd_config`

```bash
Port 22
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes  # Change to 'no' after key setup
PermitEmptyPasswords no
MaxAuthTries 3
AllowUsers YourWindowsUsername  # Replace with actual username
```

**Restart service**:
```powershell
Restart-Service sshd
```

### 1.3 Windows Firewall Rule

```powershell
# Add firewall rule for SSH from VPN subnet
New-NetFirewallRule -Name "SSH-VPN-Access" `
    -DisplayName "SSH Access from WireGuard VPN" `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -Action Allow `
    -LocalPort 22 `
    -RemoteAddress 10.0.0.0/24  # Adjust to your VPN subnet
```

### 1.4 Get Windows IP

```powershell
# Find LAN IP
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}
```

**Note this IP**: `192.168.1.X`

---

## Step 2: Android SSH Client Setup

### 2.1 Install SSH Client

**Option A: Termux** (Recommended)
```
Play Store → Termux
```

**Option B: JuiceSSH** (GUI)
```
Play Store → JuiceSSH
```

### 2.2 Termux Configuration

```bash
# Update packages
pkg update && pkg upgrade

# Install OpenSSH client
pkg install openssh

# Test connection (password auth)
ssh WindowsUsername@192.168.1.X  # Replace with Windows IP
```

### 2.3 JuiceSSH Configuration

1. Open JuiceSSH
2. Connections → New
3. Nickname: `Windows Desktop`
4. Type: SSH
5. Address: `192.168.1.X`
6. Port: `22`
7. Identity: Create new with username
8. Save → Connect

---

## Step 3: WireGuard VPN Configuration

### 3.1 Verify Android VPN Connection

**Android WireGuard App**:
- Enable tunnel
- Verify: `Transfer` shows data moving
- Check assigned IP: Should be `10.0.0.X`

### 3.2 Router WireGuard Config Check

**Router CLI/SSH**:
```bash
# Check WireGuard status
wg show

# Check allowed IPs for Android peer
# Should include: 10.0.0.2/32 and 192.168.1.0/24 (LAN subnet)
```

**Required Android Peer Config on Router**:
```ini
[Peer]
PublicKey = <android-public-key>
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 25
```

### 3.3 Android WireGuard Config Check

**File**: `/data/data/com.wireguard.android/files/<config>.conf`

```ini
[Interface]
PrivateKey = <android-private-key>
Address = 10.0.0.2/24
DNS = 192.168.1.1

[Peer]
PublicKey = <router-public-key>
Endpoint = <router-public-ip>:51820
AllowedIPs = 10.0.0.0/24, 192.168.1.0/24  # CRITICAL: Must include LAN subnet
PersistentKeepalive = 25
```

**Key Setting**: `AllowedIPs` MUST include LAN subnet `192.168.1.0/24`

---

## Step 4: Router Routing & Firewall

### 4.1 Enable IP Forwarding

```bash
# Check if enabled
sysctl net.ipv4.ip_forward

# Enable if 0
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p
```

### 4.2 Firewall Rules (iptables)

```bash
# Allow VPN → LAN traffic
iptables -A FORWARD -i wg0 -o eth0 -s 10.0.0.0/24 -d 192.168.1.0/24 -j ACCEPT
iptables -A FORWARD -i eth0 -o wg0 -s 192.168.1.0/24 -d 10.0.0.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

### 4.3 Verify Routing Table

```bash
# Check routes
ip route show

# Should see:
# 10.0.0.0/24 dev wg0
# 192.168.1.0/24 dev eth0 (or br0)
```

---

## Step 5: SSH Key Authentication (Recommended)

### 5.1 Generate Key on Android (Termux)

```bash
# Generate ED25519 key (secure, small)
ssh-keygen -t ed25519 -C "android-phone"

# Location: ~/.ssh/id_ed25519
# Leave passphrase empty for convenience (or set one)

# View public key
cat ~/.ssh/id_ed25519.pub
```

### 5.2 Copy Public Key to Windows

**Method A: Manual**
1. Copy output of `cat ~/.ssh/id_ed25519.pub`
2. On Windows, open PowerShell:
```powershell
# Create .ssh directory if needed
mkdir $env:USERPROFILE\.ssh -Force

# Append public key to authorized_keys
Add-Content -Path $env:USERPROFILE\.ssh\authorized_keys -Value "ssh-ed25519 AAAA... android-phone"

# Set correct permissions
icacls $env:USERPROFILE\.ssh\authorized_keys /inheritance:r /grant:r "$env:USERNAME:F"
```

**Method B: ssh-copy-id** (from Termux)
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub WindowsUsername@192.168.1.X
```

### 5.3 Test Key Authentication

```bash
# From Termux
ssh -i ~/.ssh/id_ed25519 WindowsUsername@192.168.1.X
```

### 5.4 Disable Password Auth

**Windows**: Edit `C:\ProgramData\ssh\sshd_config`
```bash
PasswordAuthentication no
```

**Restart SSH**:
```powershell
Restart-Service sshd
```

---

## Step 6: Testing & Validation

### 6.1 Connection Test from Android

**In Termux**:
```bash
# 1. Test VPN connectivity
ping -c 4 10.0.0.1  # Router VPN IP

# 2. Test LAN routing
ping -c 4 192.168.1.1  # Router LAN IP

# 3. Test Windows reachability
ping -c 4 192.168.1.X  # Windows IP

# 4. Test SSH port
nc -zv 192.168.1.X 22

# 5. SSH connection
ssh WindowsUsername@192.168.1.X
```

### 6.2 Verify Windows Logs

**PowerShell**:
```powershell
# Check SSH logs
Get-EventLog -LogName Application -Source OpenSSH-Server-Service -Newest 10

# Check active SSH sessions
Get-NetTCPConnection -LocalPort 22 -State Established
```

### 6.3 Debug Connection Issues

**Verbose SSH output**:
```bash
ssh -vvv WindowsUsername@192.168.1.X
```

**Check Windows firewall**:
```powershell
Get-NetFirewallRule -Name "SSH-VPN-Access" | Format-List
```

**Test from router**:
```bash
# SSH from router to Windows (verify LAN SSH works)
ssh WindowsUsername@192.168.1.X
```

---

## Step 7: PhiLaunch Integration

### 7.1 Add Windows Connection to Config

**Edit**: `config/philaunch.conf`
```bash
# Windows Desktop SSH Connection
WINDOWS_HOST="192.168.1.X"
WINDOWS_USER="YourWindowsUsername"
WINDOWS_SSH_PORT="22"
WINDOWS_SSH_CONN="${WINDOWS_USER}@${WINDOWS_HOST}"
```

### 7.2 Create Windows Control Script

**File**: `automation/windows-control.sh`
```bash
#!/bin/bash
source "$(dirname "$0")/../config/load-config.sh"

case "$1" in
    status)
        ssh -p ${WINDOWS_SSH_PORT} ${WINDOWS_SSH_CONN} 'systeminfo | findstr /C:"OS Name" /C:"System Boot Time"'
        ;;
    uptime)
        ssh -p ${WINDOWS_SSH_PORT} ${WINDOWS_SSH_CONN} 'powershell "Get-CimInstance Win32_OperatingSystem | Select LastBootUpTime"'
        ;;
    reboot)
        ssh -p ${WINDOWS_SSH_PORT} ${WINDOWS_SSH_CONN} 'shutdown /r /t 0'
        ;;
    *)
        echo "Usage: $0 {status|uptime|reboot}"
        exit 1
        ;;
esac
```

### 7.3 Create Termux Shortcut

**File**: `~/.shortcuts/windows-ssh.sh`
```bash
#!/data/data/com.termux/files/usr/bin/bash
ssh -i ~/.ssh/id_ed25519 WindowsUsername@192.168.1.X
```

```bash
chmod +x ~/.shortcuts/windows-ssh.sh
```

**Create widget**: Long-press home screen → Widgets → Termux:Widget → Select shortcut

---

## Step 8: Security Hardening

### 8.1 Windows SSH Server Hardening

**Edit**: `C:\ProgramData\ssh\sshd_config`
```bash
# Only allow key auth
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no

# Limit login attempts
MaxAuthTries 3
MaxSessions 2

# Disable unused features
X11Forwarding no
AllowTcpForwarding no
PermitTunnel no

# Timeout settings
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
SyslogFacility AUTH
LogLevel VERBOSE
```

### 8.2 WireGuard Security

**Router**:
```bash
# Verify peer isolation
iptables -A FORWARD -i wg0 -o wg0 -j DROP  # Prevent VPN peer-to-peer

# Rate limiting
iptables -A INPUT -p udp --dport 51820 -m limit --limit 10/min -j ACCEPT
iptables -A INPUT -p udp --dport 51820 -j DROP
```

### 8.3 Android Security

**Termux**:
```bash
# Protect SSH keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Set passphrase on key (optional)
ssh-keygen -p -f ~/.ssh/id_ed25519
```

### 8.4 Windows Firewall Restriction

**Limit to VPN subnet only**:
```powershell
Set-NetFirewallRule -Name "SSH-VPN-Access" -RemoteAddress 10.0.0.0/24
```

---

## Step 9: Troubleshooting

### Issue: Cannot SSH to Windows

**Check 1**: Windows SSH service running
```powershell
Get-Service sshd
```

**Check 2**: Firewall rule active
```powershell
Get-NetFirewallRule -Name "SSH-VPN-Access"
```

**Check 3**: Port listening
```powershell
netstat -an | findstr :22
```

**Check 4**: Test from router
```bash
ssh WindowsUsername@192.168.1.X
```

### Issue: VPN connected but cannot reach LAN

**Check 1**: Android `AllowedIPs` includes LAN
```ini
AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
```

**Check 2**: Router IP forwarding enabled
```bash
sysctl net.ipv4.ip_forward  # Should be 1
```

**Check 3**: Router firewall allows VPN→LAN
```bash
iptables -L FORWARD -v -n | grep wg0
```

**Check 4**: Ping Windows from router
```bash
ping 192.168.1.X
```

### Issue: Key authentication failing

**Check 1**: Authorized keys file permissions (Windows)
```powershell
icacls $env:USERPROFILE\.ssh\authorized_keys
# Should show ONLY your username with full control
```

**Check 2**: Key format correct
```bash
# Public key should start with: ssh-ed25519 or ssh-rsa
cat ~/.ssh/id_ed25519.pub
```

**Check 3**: SSH logs on Windows
```powershell
Get-EventLog -LogName Application -Source OpenSSH* -Newest 20
```

**Check 4**: Verbose SSH output
```bash
ssh -vvv -i ~/.ssh/id_ed25519 WindowsUsername@192.168.1.X
```

### Issue: Connection drops frequently

**Fix**: Increase keepalive intervals

**Android WireGuard**:
```ini
PersistentKeepalive = 25
```

**Termux SSH config** (`~/.ssh/config`):
```bash
Host windows-desktop
    HostName 192.168.1.X
    User WindowsUsername
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

---

## Step 10: Quick Reference Commands

### Android (Termux)

```bash
# Check VPN status
wg show

# Test connectivity
ping -c 4 192.168.1.X

# SSH connection
ssh WindowsUsername@192.168.1.X

# SSH with config
ssh windows-desktop

# Copy file TO Windows
scp file.txt WindowsUsername@192.168.1.X:C:/Users/YourUser/

# Copy file FROM Windows
scp WindowsUsername@192.168.1.X:C:/Users/YourUser/file.txt ./
```

### Windows (PowerShell)

```powershell
# Check SSH service
Get-Service sshd

# Restart SSH
Restart-Service sshd

# View active connections
Get-NetTCPConnection -LocalPort 22 -State Established

# Check firewall
Get-NetFirewallRule -Name "SSH-VPN-Access" | Format-List

# View SSH logs
Get-EventLog -LogName Application -Source OpenSSH* -Newest 10
```

### Router

```bash
# WireGuard status
wg show

# Check connections
wg show wg0 latest-handshakes

# View routing
ip route show

# Check firewall
iptables -L -v -n
```

---

## Summary Checklist

**Windows 11**:
- [ ] OpenSSH Server installed and running
- [ ] sshd_config configured (port, auth methods)
- [ ] Firewall rule allows SSH from VPN subnet
- [ ] Static IP assigned or DHCP reservation
- [ ] SSH keys added to authorized_keys
- [ ] Password auth disabled (after key setup)

**Android 11**:
- [ ] WireGuard VPN connected
- [ ] AllowedIPs includes LAN subnet
- [ ] SSH client installed (Termux/JuiceSSH)
- [ ] SSH keys generated
- [ ] Can ping Windows IP
- [ ] Can SSH to Windows

**Router**:
- [ ] WireGuard server running
- [ ] IP forwarding enabled
- [ ] Firewall allows VPN→LAN traffic
- [ ] Android peer configured correctly
- [ ] Routing table includes VPN and LAN subnets

**Test Flow**:
1. Android → Router VPN ✓
2. Android → Router LAN IP ✓
3. Android → Windows IP ✓
4. Android → Windows SSH ✓

---

## Network Diagram

```
┌─────────────────────┐
│   Android Phone     │
│  10.0.0.2 (WireGuard)│
│  SSH Client (Termux)│
└──────────┬──────────┘
           │ WireGuard Tunnel
           │ (Encrypted)
           ↓
┌─────────────────────┐
│   Router/Gateway    │
│  WireGuard Server   │
│  10.0.0.1 (VPN)     │
│  192.168.1.1 (LAN)  │
│  DHCP Server        │
└──────────┬──────────┘
           │ LAN Ethernet/WiFi
           │
┌──────────┴──────────┐
│  Windows 11 Desktop │
│  192.168.1.X (LAN)  │
│  SSH Server (Port22)│
│  OpenSSH-Server     │
└─────────────────────┘
```

---

## Performance Tips

1. **Use ED25519 keys** - Faster than RSA
2. **Enable compression** - Add `Compression yes` to ssh_config
3. **Use SSH multiplexing** - Reuse connections
4. **Mosh alternative** - Consider `mosh` for better mobile experience
5. **Port knocking** - Add extra security layer (optional)

## Next Steps After Setup

- [ ] Test connection from different locations
- [ ] Set up SSH config file for easy connection
- [ ] Create Termux widget shortcuts
- [ ] Integrate with PhiLaunch automation scripts
- [ ] Set up tmux sessions for persistent connections
- [ ] Configure automatic VPN reconnection on Android
- [ ] Test file transfers (scp/sftp)
- [ ] Document any custom Windows commands needed
