# Setup Guide

Complete guide for setting up the AI Response Capture Framework.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Installation Steps](#installation-steps)
3. [Browser Configuration](#browser-configuration)
4. [Testing the Setup](#testing-the-setup)
5. [Troubleshooting](#troubleshooting)

## System Requirements

### Required Software
- **Node.js**: Version 18.0.0 or higher
- **npm**: Version 9.0.0 or higher
- **Chrome/Chromium**: Latest stable version
- **AutoHotkey v2**: For Windows automation (Windows only)

### Operating Systems
- Windows 10/11 (full support including AHK)
- macOS 10.15+ (CDP capture only)
- Linux (Ubuntu 20.04+, CDP capture only)

### Hardware
- RAM: Minimum 4GB, recommended 8GB+
- Storage: 500MB for framework + database
- Network: Internet connection for AI platforms

## Installation Steps

### Step 1: Clone or Download

```bash
# If using git
git clone <repository-url>
cd ai-response-capture-framework

# Or download and extract ZIP
```

### Step 2: Install Node.js Dependencies

```bash
npm install
```

This installs:
- puppeteer-core (CDP client)
- ws (WebSocket support)
- better-sqlite3 (database)
- chalk (colored console output)
- marked (markdown parsing)
- cheerio (HTML parsing)

### Step 3: Create Data Directory

```bash
mkdir -p data
```

### Step 4: Configure Settings

Edit `capture_config.json` if needed:

```json
{
  "cdp": {
    "host": "localhost",
    "port": 9222
  },
  "storage": {
    "database_path": "./data/conversations.db"
  }
}
```

## Browser Configuration

### Chrome/Chromium Setup

#### Windows

1. **Create a batch file** `start-chrome-debug.bat`:

```batch
@echo off
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%\chrome-debug"
```

2. **Run the batch file** to start Chrome with debugging enabled

#### macOS

1. **Create a shell script** `start-chrome-debug.sh`:

```bash
#!/bin/bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug
```

2. **Make it executable and run**:

```bash
chmod +x start-chrome-debug.sh
./start-chrome-debug.sh
```

#### Linux

1. **Create a shell script** `start-chrome-debug.sh`:

```bash
#!/bin/bash
google-chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug
```

2. **Make it executable and run**:

```bash
chmod +x start-chrome-debug.sh
./start-chrome-debug.sh
```

### Verify Chrome Debug Port

Open a new terminal and check if Chrome is listening:

```bash
# Windows (PowerShell)
Test-NetConnection -ComputerName localhost -Port 9222

# macOS/Linux
nc -zv localhost 9222
# or
curl http://localhost:9222/json
```

You should see a JSON response with open tabs.

### Edge Setup (Alternative)

```bash
# Windows
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%\edge-debug"

# macOS
/Applications/Microsoft\ Edge.app/Contents/MacOS/Microsoft\ Edge --remote-debugging-port=9222 --user-data-dir=/tmp/edge-debug
```

### Brave Setup (Alternative)

```bash
# Windows
"C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%\brave-debug"

# macOS
/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser --remote-debugging-port=9222 --user-data-dir=/tmp/brave-debug
```

## Testing the Setup

### Test 1: Verify CDP Connection

```bash
node -e "
const puppeteer = require('puppeteer-core');
(async () => {
  try {
    const browser = await puppeteer.connect({
      browserURL: 'http://localhost:9222'
    });
    console.log('✓ CDP connection successful!');
    const pages = await browser.pages();
    console.log('✓ Found', pages.length, 'open tabs');
    await browser.disconnect();
  } catch (error) {
    console.error('✗ CDP connection failed:', error.message);
  }
})();
"
```

### Test 2: Run Basic Capture

1. **Start Chrome with debugging** (if not already running)

2. **Open an AI platform** in Chrome:
   - https://claude.ai
   - https://chat.openai.com
   - https://perplexity.ai

3. **Run the capture framework**:

```bash
npm start
```

4. **Send a test message** in the AI platform

5. **Check console output** for capture events

### Test 3: Run Monitor

```bash
npm run monitor
```

You should see:
- Framework initialization
- Platform detection
- Live capture events when you interact with AI

### Test 4: Check Database

```bash
node -e "
const Database = require('better-sqlite3');
const db = new Database('./data/conversations.db');
const count = db.prepare('SELECT COUNT(*) as count FROM messages').get();
console.log('Messages in database:', count.count);
db.close();
"
```

## AutoHotkey Setup (Windows Only)

### Step 1: Install AutoHotkey v2

1. Download from: https://www.autohotkey.com/
2. Install AutoHotkey v2 (not v1.1)
3. Verify installation: `ahk --version`

### Step 2: Configure Coordinates

The default coordinates may not match your screen resolution. To find correct coordinates:

1. **Run the coordinate finder**:

```ahk
; Save as find-coordinates.ahk
#Requires AutoHotkey v2.0

F1:: {
    MouseGetPos(&x, &y)
    MsgBox("Current position: " x ", " y)
}
```

2. **Press F1** while hovering over input fields
3. **Update coordinates** in `ahk/AIMessaging.ahk`

### Step 3: Test AHK Integration

```bash
# Run example script
ahk\example-usage.ahk
```

Press `Ctrl+Shift+Q` to test quick message input.

## Configuration Tips

### Optimize for Your Setup

1. **Adjust buffer timeout** if responses are cut off:
```json
"capture": {
  "buffer_timeout": 3000  // Increase for slower responses
}
```

2. **Disable unused capture methods** for better performance:
```json
"capture": {
  "methods": {
    "websocket": true,
    "sse": true,
    "network": false,  // Disable if not needed
    "console": false,
    "mutation": true,
    "dom_scraping": false
  }
}
```

3. **Adjust DOM scraping interval**:
```json
"capture": {
  "dom_scraping_interval": 1000  // Less frequent = lower CPU usage
}
```

### Platform-Specific Selectors

If selectors don't match (AI platforms update their UI), update in config:

```json
"platforms": {
  "claude": {
    "selectors": {
      "message_container": "div[data-test-render-count]",  // Update if changed
      "input_field": "div[contenteditable='true']",
      "submit_button": "button[aria-label*='Send']"
    }
  }
}
```

To find new selectors:
1. Open Chrome DevTools (F12)
2. Use Element Picker (Ctrl+Shift+C)
3. Click on the element
4. Copy selector from DevTools

## Troubleshooting

### Issue: "Failed to connect to CDP"

**Solutions:**
1. Verify Chrome is running with `--remote-debugging-port=9222`
2. Check if port 9222 is available: `netstat -an | grep 9222`
3. Try a different port in config and Chrome startup
4. Disable firewall temporarily to test

### Issue: "No platform detected"

**Solutions:**
1. Ensure you're on a supported AI platform URL
2. Check URL patterns in `capture_config.json`
3. Manually navigate to AI platform after starting capture
4. Check console for detection logs

### Issue: "No responses captured"

**Solutions:**
1. Enable debug logging: `"log_level": "debug"` in config
2. Check if capture methods are enabled
3. Verify selectors match current page structure
4. Try different capture methods
5. Check browser console for errors

### Issue: "Database locked"

**Solutions:**
1. Close other instances of the framework
2. Delete `data/conversations.db-wal` and `data/conversations.db-shm`
3. Restart the framework

### Issue: "AHK script not working"

**Solutions:**
1. Verify AutoHotkey v2 is installed (not v1.1)
2. Run as Administrator
3. Check window title patterns match your browser
4. Adjust coordinates for your screen resolution
5. Try clipboard method instead of typing

### Issue: "High CPU usage"

**Solutions:**
1. Disable DOM scraping: `"dom_scraping": false`
2. Increase scraping interval: `"dom_scraping_interval": 2000`
3. Disable unused capture methods
4. Close unnecessary browser tabs

### Issue: "Duplicate captures"

**Solutions:**
1. Increase deduplication window: `"deduplication_window": 2000`
2. Disable redundant capture methods
3. Check buffer timeout settings

## Next Steps

After successful setup:

1. **Read the API documentation** in README.md
2. **Explore examples** in `src/index.js`
3. **Customize platform adapters** for your needs
4. **Set up monitoring** for production use
5. **Configure database backups**

## Support

If you encounter issues not covered here:
1. Check the main README.md
2. Review console logs with debug level
3. Check GitHub issues
4. Create a new issue with logs and configuration