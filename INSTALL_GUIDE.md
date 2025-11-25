# How to Install PhiSHRI

## What is PhiSHRI?

PhiSHRI is a plugin for Claude AI that gives it a memory. Instead of explaining your project every time, Claude can load "doors" - saved context bundles that let it pick up where you left off.

---

## Before You Start

You need **Claude Desktop** installed first. If you don't have it:
1. Go to https://claude.ai/download
2. Download for your computer (Windows, Mac, or Linux)
3. Install it and sign in

---

## Installation Instructions

### Windows

**Option A: One-Click Installer (Easiest)**

1. Go to https://github.com/Stryk91/PhiSHRI/releases
2. Download `PhiSHRI-Installer.exe`
3. Double-click it
4. Click "Install PhiSHRI"
5. Wait for it to finish
6. Close and reopen Claude Desktop

**Option B: PowerShell Script**

1. Go to https://github.com/Stryk91/PhiSHRI/releases
2. Download `install.ps1`
3. Right-click the file
4. Click "Run with PowerShell"
5. If it asks about permissions, type `Y` and press Enter
6. Wait for it to finish
7. Close and reopen Claude Desktop

**Option C: One-Line Command (Advanced)**

1. Press `Windows key + X`
2. Click "Terminal" or "PowerShell"
3. Copy and paste this line:
   ```
   irm https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1 | iex
   ```
4. Press Enter
5. Wait for it to finish
6. Close and reopen Claude Desktop

---

### Mac

**Option A: Terminal Script (Recommended)**

1. Go to https://github.com/Stryk91/PhiSHRI/releases
2. Download `install.sh`
3. Open Finder and go to your Downloads folder
4. Open Terminal:
   - Press `Command + Space`
   - Type `Terminal`
   - Press Enter
5. Type these commands (press Enter after each):
   ```
   cd ~/Downloads
   chmod +x install.sh
   ./install.sh
   ```
6. Wait for it to finish
7. Close and reopen Claude Desktop

**Option B: One-Line Command**

1. Open Terminal:
   - Press `Command + Space`
   - Type `Terminal`
   - Press Enter
2. Copy and paste this line:
   ```
   curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash
   ```
3. Press Enter
4. Wait for it to finish
5. Close and reopen Claude Desktop

---

### Linux

**Option A: AppImage (Universal - Works on Any Linux)**

1. Go to https://github.com/Stryk91/PhiSHRI/releases
2. Download `PhiSHRI-Installer.AppImage`
3. Open your file manager
4. Right-click the file
5. Go to Properties > Permissions
6. Check "Allow executing file as program" (or similar)
7. Double-click the AppImage to run it
8. Click "Install PhiSHRI"
9. Close and reopen Claude Desktop

**Option B: Debian/Ubuntu (.deb)**

1. Go to https://github.com/Stryk91/PhiSHRI/releases
2. Download `phishri-installer.deb`
3. Double-click the file
4. Click "Install" in the software center
5. Open the installed app
6. Click "Install PhiSHRI"
7. Close and reopen Claude Desktop

**Option C: Terminal Script**

1. Open Terminal (usually `Ctrl + Alt + T`)
2. Copy and paste this line:
   ```
   curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash
   ```
3. Press Enter
4. Wait for it to finish
5. Close and reopen Claude Desktop

---

## How Do I Know It Worked?

1. Open Claude Desktop
2. Start a new conversation
3. Type: `What PhiSHRI doors are available?`
4. If Claude lists categories and doors, it worked!

If Claude says it doesn't know what PhiSHRI is:
- Make sure you closed and reopened Claude Desktop
- Try the installation again
- Check the Troubleshooting section below

---

## How to Use PhiSHRI

Once installed, just talk to Claude normally. Try these:

- "What doors do you have?"
- "Search for doors about security"
- "Open door D05"
- "List all categories"

Claude will automatically use PhiSHRI to load relevant context.

---

## Troubleshooting

### "Claude doesn't know about PhiSHRI"

1. Make sure you completely closed Claude Desktop (check system tray)
2. Reopen Claude Desktop
3. Try again

### "The installer won't run" (Windows)

Windows might block downloaded scripts. To fix:
1. Right-click `install.ps1`
2. Click "Properties"
3. At the bottom, check "Unblock"
4. Click OK
5. Try running it again

### "Permission denied" (Mac/Linux)

You need to make the script executable:
```
chmod +x install.sh
```
Then run it again.

### "curl not found" (Linux)

Install curl first:
```
sudo apt install curl
```
Then try the install command again.

### Still not working?

1. Go to https://github.com/Stryk91/PhiSHRI/issues
2. Click "New Issue"
3. Describe what happened
4. Include your operating system (Windows 10, Mac, Ubuntu, etc.)

---

## Uninstall

### Windows
```
.\install.ps1 -Uninstall
```

### Mac/Linux
```
curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash -s -- --uninstall
```

---

## Questions?

- Email: PhiVector@pm.me
- Discord: lordcain
- GitHub: https://github.com/Stryk91/PhiSHRI/issues
