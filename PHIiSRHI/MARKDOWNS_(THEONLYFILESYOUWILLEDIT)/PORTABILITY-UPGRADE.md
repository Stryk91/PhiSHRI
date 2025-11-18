# PhiLaunch Portability Upgrade Guide

## What Changed?

PhiLaunch is now **100% portable** across different environments! All hardcoded values (usernames, IPs, ports) have been extracted to a central configuration system.

### Before (Hardcoded)
```bash
ssh stryk@192.168.50.149 -p 2222
LOG_FILE="/home/STRYK/wow_connection.log"
```

### After (Configurable)
```bash
ssh ${PHILAUNCH_SSH_CONN} -p ${PHILAUNCH_SSH_PORT}
LOG_FILE="${PHILAUNCH_LOG_DIR}/wow_connection.log"
```

## New Features

✨ **Interactive Setup Wizard** - One command setup for your environment
✨ **Automatic Phone Shortcut Generator** - Creates personalized Termux commands
✨ **Secure by Default** - Config files auto-protected in .gitignore
✨ **Fallback Support** - Scripts work even without config (with defaults)
✨ **Multi-Environment** - Easy switching between home/work/VPN configs

## Quick Migration (2 Minutes)

### Step 1: Run Setup Wizard

```bash
cd ~/PhiLaunch
./setup.sh
```

Follow the prompts. The wizard will:
- Detect your current username, IP, and SSH port
- Ask you to confirm or customize
- Generate `config/philaunch.conf`
- Test your SSH connection
- Update `.gitignore` automatically

### Step 2: Generate Phone Shortcuts

```bash
./tools/generate-phone-shortcuts.sh
```

This creates `PHONE-SHORTCUTS-PERSONAL.md` with commands using YOUR configuration.

### Step 3: Update Termux (Phone)

Open the generated file and copy the new aliases to your phone's Termux:

```bash
# On your phone (Termux)
nano ~/.bashrc

# Add the aliases from PHONE-SHORTCUTS-PERSONAL.md
# Then reload:
source ~/.bashrc
```

### Step 4: Done!

Everything now uses your personal config. No more hardcoded values!

---

## What Was Changed

### New Files Created

```
PhiLaunch/
├── config/
│   ├── philaunch.conf.example   # Template (commit to git)
│   ├── philaunch.conf           # Your config (gitignored)
│   ├── load-config.sh           # Config loader
│   └── README.md                # Config documentation
├── tools/
│   └── generate-phone-shortcuts.sh  # Shortcut generator
├── setup.sh                     # Setup wizard
└── PORTABILITY-UPGRADE.md       # This file
```

### Updated Scripts

These scripts now use the config system:

- ✅ `automation/home-control.sh`
- ✅ `automation/launch-script.sh`
- ✅ `wow_monitor.sh`
- ✅ `remote-scripts/tunnel-helper.sh`

### Updated `.gitignore`

Added protection for:
- `config/philaunch.conf` (your personal config)
- `config/*.backup.*` (backup configs)
- `PHONE-SHORTCUTS-PERSONAL.md` (personalized shortcuts)
- `logs/` directory (log files)

---

## Configuration Variables Reference

### Connection Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `PHILAUNCH_USER` | SSH username | `stryk` |
| `PHILAUNCH_HOST` | Server IP (LAN) | `192.168.50.149` |
| `PHILAUNCH_SSH_PORT` | SSH port | `2222` |
| `PHILAUNCH_SSH_CONN` | Full connection string | `stryk@192.168.50.149` |

### Directory Paths

| Variable | Description | Example |
|----------|-------------|---------|
| `PHILAUNCH_HOME` | Installation directory | `/home/stryk/PhiLaunch` |
| `PHILAUNCH_AUTOMATION_DIR` | Automation scripts | `/home/stryk/PhiLaunch/automation` |
| `PHILAUNCH_REMOTE_SCRIPTS_DIR` | Remote scripts | `/home/stryk/PhiLaunch/remote-scripts` |
| `PHILAUNCH_LOG_DIR` | Log directory | `/home/stryk/PhiLaunch/logs` |

### Monitoring Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `WOW_SERVER_IP` | WoW server to monitor | `103.4.115.248` |
| `MONITOR_INTERVAL` | Check interval (seconds) | `60` |

---

## Backward Compatibility

**All old scripts still work!** Updated scripts include fallback defaults if config is not found.

However, you should run `./setup.sh` to get the full benefits:
- Portability across machines
- Easy updates to connection info
- Automatic phone shortcut generation
- Protection of sensitive data

---

## Advanced Usage

### Multiple Environments

Running PhiLaunch on multiple machines (home PC, work laptop, cloud server)?

**Option 1: Separate Configs**

```bash
# On each machine, run setup with that machine's values
./setup.sh
```

**Option 2: Environment Switching**

```bash
# Create configs for each environment
./setup.sh  # Follow prompts for "home"
mv config/philaunch.conf config/philaunch-home.conf

./setup.sh  # Follow prompts for "work"
mv config/philaunch.conf config/philaunch-work.conf

# Switch between them
ln -sf philaunch-home.conf config/philaunch.conf
# or
ln -sf philaunch-work.conf config/philaunch.conf

# Regenerate shortcuts after switching
./tools/generate-phone-shortcuts.sh
```

### Custom Variables

Add your own custom variables to `config/philaunch.conf`:

```bash
# My custom settings
MY_CUSTOM_SERVER="example.com"
MY_API_KEY="xxx"  # Be careful with secrets!

# Export so scripts can use them
export MY_CUSTOM_SERVER
export MY_API_KEY
```

Then use in scripts:

```bash
source "${SCRIPT_DIR}/../config/load-config.sh"
curl "https://${MY_CUSTOM_SERVER}/api?key=${MY_API_KEY}"
```

### Debugging

Enable debug mode to see what config values are loaded:

```bash
# Edit config
nano config/philaunch.conf

# Change this line:
DEBUG_MODE="true"

# Now run any script to see debug output
./automation/home-control.sh status
```

---

## Migrating Custom Scripts

Have custom scripts that still use hardcoded values?

### Find Them

```bash
# Find scripts with hardcoded username
grep -r "stryk@" . --include="*.sh" --exclude-dir=.git

# Find hardcoded IPs
grep -r "192.168.50.149" . --include="*.sh" --exclude-dir=.git

# Find hardcoded paths
grep -r "/home/STRYK" . --include="*.sh" --exclude-dir=.git
```

### Update Them

Add config loading at the top:

```bash
#!/bin/bash
# My Custom Script

# Load PhiLaunch configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/load-config.sh"  # Adjust path as needed

# Now use variables instead of hardcoded values
ssh -p "${PHILAUNCH_SSH_PORT}" "${PHILAUNCH_SSH_CONN}" 'uptime'
```

Replace hardcoded values:

| Old (Hardcoded) | New (Variable) |
|-----------------|----------------|
| `stryk@192.168.50.149` | `${PHILAUNCH_SSH_CONN}` |
| `-p 2222` | `-p ${PHILAUNCH_SSH_PORT}` |
| `/home/STRYK` | `${PHILAUNCH_HOME}` |
| `/home/STRYK/logs` | `${PHILAUNCH_LOG_DIR}` |

---

## Troubleshooting

### "Config file not found" error

```bash
# Run setup wizard
./setup.sh

# Or manually copy example
cp config/philaunch.conf.example config/philaunch.conf
nano config/philaunch.conf
```

### Scripts still show old hardcoded values

Some scripts haven't been updated yet. To update:

```bash
# Check if script loads config
head -20 your-script.sh | grep "load-config"

# If not, add config loading (see "Migrating Custom Scripts" above)
```

### Phone shortcuts don't work

```bash
# Regenerate with your current config
./tools/generate-phone-shortcuts.sh

# Copy new shortcuts to Termux
cat PHONE-SHORTCUTS-PERSONAL.md
```

### Want to reset everything

```bash
# Backup first (optional)
cp config/philaunch.conf config/philaunch.conf.backup

# Re-run setup wizard
./setup.sh
```

---

## Security Best Practices

### ✅ DO

- Run `./setup.sh` on each machine
- Keep `philaunch.conf` private (it's auto-gitignored)
- Use SSH keys instead of passwords
- Review generated configs before using

### ❌ DON'T

- Commit `config/philaunch.conf` to git
- Share `PHONE-SHORTCUTS-PERSONAL.md` publicly
- Store passwords in config files
- Use the same config on public/private networks without updating

---

## Benefits Summary

### For You

- ✅ **No more manual find-and-replace** when changing IPs
- ✅ **Works on any machine** after running `./setup.sh`
- ✅ **Auto-generated phone shortcuts** personalized for you
- ✅ **Secure by default** - sensitive data protected

### For Others Using PhiLaunch

- ✅ **One command setup**: `./setup.sh`
- ✅ **No hardcoded values** to manually change
- ✅ **Clear documentation** in `config/README.md`
- ✅ **Works out of the box** on their environment

---

## Next Steps

1. ✅ Run `./setup.sh` (if you haven't already)
2. ✅ Run `./tools/generate-phone-shortcuts.sh`
3. ✅ Update Termux aliases on your phone
4. ✅ Test connection: `ssh ${PHILAUNCH_SSH_CONN} -p ${PHILAUNCH_SSH_PORT}`
5. ✅ Star/share PhiLaunch if you find it useful! 🚀

---

**Questions?** Check `config/README.md` for detailed documentation.

**Last Updated:** 2025-11-12
