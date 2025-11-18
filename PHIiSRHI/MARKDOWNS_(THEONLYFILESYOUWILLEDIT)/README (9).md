# PhiLaunch Configuration System

This directory contains the PhiLaunch configuration system that makes the project portable across different environments.

## Quick Start

### First Time Setup

Run the interactive setup wizard:

```bash
cd /path/to/PhiLaunch
./setup.sh
```

The wizard will:
1. Detect your environment (username, IP, SSH port)
2. Ask for configuration values
3. Generate `config/philaunch.conf`
4. Test your SSH connection
5. Update `.gitignore` to protect sensitive data

### Manual Setup

If you prefer manual configuration:

```bash
cd config
cp philaunch.conf.example philaunch.conf
nano philaunch.conf  # Edit with your values
```

## Files

- **`philaunch.conf.example`** - Template with all available settings
- **`philaunch.conf`** - Your personal config (auto-generated, gitignored)
- **`load-config.sh`** - Helper script to load config in other scripts
- **`README.md`** - This file

## Configuration Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `PHILAUNCH_USER` | SSH username | `your-username` |
| `PHILAUNCH_HOST` | Server IP (LAN) | `192.168.1.100` |
| `PHILAUNCH_SSH_PORT` | SSH port | `2222` |
| `PHILAUNCH_HOME` | Installation directory | `/home/user/PhiLaunch` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `WOW_SERVER_IP` | WoW server for monitoring | `103.4.115.248` |
| `MONITOR_INTERVAL` | Check interval (seconds) | `60` |
| `WIREGUARD_INTERFACE` | VPN interface name | `wg0` |
| `ENABLE_WAN_WARNINGS` | Show VPN reminders | `true` |
| `DEBUG_MODE` | Verbose logging | `false` |

## Using Config in Scripts

Add this to the top of your scripts:

```bash
#!/bin/bash

# Load PhiLaunch configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/load-config.sh"

# Now use the variables
echo "Connecting to $PHILAUNCH_SSH_CONN on port $PHILAUNCH_SSH_PORT"
ssh -p "$PHILAUNCH_SSH_PORT" "$PHILAUNCH_SSH_CONN" 'uptime'
```

## Security

**IMPORTANT:** Never commit `philaunch.conf` to version control!

The config file contains:
- Your username
- Your IP address
- Other personal information

The setup wizard automatically adds it to `.gitignore`.

To verify protection:
```bash
git status config/philaunch.conf
# Should show: "Untracked files" or not appear at all
```

## Updating Configuration

### Re-run Setup Wizard

```bash
./setup.sh
```

The wizard will backup your old config before creating a new one.

### Manual Edit

```bash
nano config/philaunch.conf
```

### Generate New Phone Shortcuts

After changing config, regenerate phone shortcuts:

```bash
./tools/generate-phone-shortcuts.sh
```

This creates `PHONE-SHORTCUTS-PERSONAL.md` with your updated connection info.

## Troubleshooting

### "Config file not found" error

**Problem:** Scripts can't find `config/philaunch.conf`

**Solution:**
```bash
# Run setup wizard
./setup.sh

# Or copy example manually
cp config/philaunch.conf.example config/philaunch.conf
nano config/philaunch.conf
```

### "Missing required variables" error

**Problem:** Config file exists but missing values

**Solution:**
```bash
# Check which variables are empty
cat config/philaunch.conf | grep '=""'

# Edit and fill in missing values
nano config/philaunch.conf
```

### Scripts still use hardcoded values

**Problem:** Old scripts not updated to use config

**Solution:**
```bash
# Check if script sources config
head -20 path/to/script.sh | grep "load-config.sh"

# If not found, add this after the shebang:
# Load PhiLaunch configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/load-config.sh"
```

## Migration Guide

### For Existing Users

If you were using PhiLaunch before the config system:

1. **Backup your old settings:**
   ```bash
   # Note your current values
   echo "My username: $USER"
   hostname -I  # Your IP
   grep "Port" /etc/ssh/sshd_config  # SSH port
   ```

2. **Run setup wizard:**
   ```bash
   ./setup.sh
   ```

3. **Enter your values when prompted**

4. **Update phone shortcuts:**
   ```bash
   ./tools/generate-phone-shortcuts.sh
   ```

5. **Copy new shortcuts to Termux:**
   - Open `PHONE-SHORTCUTS-PERSONAL.md`
   - Copy aliases to Termux `~/.bashrc`
   - Update Termux:Widget scripts

### Preserving Custom Scripts

If you have custom scripts with hardcoded values:

```bash
# Find all scripts with hardcoded username
grep -r "stryk@" /path/to/PhiLaunch --include="*.sh"

# Find hardcoded IPs
grep -r "192.168" /path/to/PhiLaunch --include="*.sh"
```

Then update each script to use config variables.

## Advanced Usage

### Environment-Specific Configs

For multiple environments (home, work, VPN):

```bash
# Create separate configs
cp config/philaunch.conf config/philaunch-home.conf
cp config/philaunch.conf config/philaunch-work.conf

# Edit each
nano config/philaunch-home.conf
nano config/philaunch-work.conf

# Switch between them
ln -sf philaunch-home.conf config/philaunch.conf
# or
ln -sf philaunch-work.conf config/philaunch.conf
```

### Debugging Config Loading

Enable debug mode:

```bash
echo 'DEBUG_MODE="true"' >> config/philaunch.conf
```

Then run any script to see config loading details.

## Support

If you encounter issues:

1. Check this README
2. Run `./setup.sh` again
3. Verify `.gitignore` protects `config/philaunch.conf`
4. Check file permissions: `ls -la config/`

---

**Last Updated:** 2025-11-12
