# AUTO-UPDATE MECHANISMS GUIDE

A comprehensive reference for implementing automatic updates across desktop and web applications, covering frameworks, strategies, distribution methods, and security best practices.

---

## Table of Contents

1. [Frameworks](#frameworks)
2. [Update Strategies](#update-strategies)
3. [Distribution Methods](#distribution-methods)
4. [Implementation Examples](#implementation-examples)
5. [Security Best Practices](#security-best-practices)
6. [Testing & Rollback](#testing--rollback)

---

## FRAMEWORKS

### Sparkle (macOS)

Sparkle is the de-facto standard for macOS application updates. It uses appcast feeds (XML) and EdDSA cryptographic signing.

**Key Features:**
- EdDSA (Ed25519) signature verification
- Automatic key management in Keychain
- Appcast XML feed format
- Delta update support
- User-friendly update UI

**Appcast XML Format:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
     xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
     xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>MyApp Updates</title>
    <link>https://example.com</link>
    <description>Updates for MyApp</description>

    <item>
      <title>Version 2.0.0</title>
      <description>
        <![CDATA[
          <h2>Release Notes:</h2>
          <ul>
            <li>Major feature: Dark mode support</li>
            <li>Performance improvements</li>
            <li>Bug fixes</li>
          </ul>
        ]]>
      </description>
      <pubDate>Fri, 15 Nov 2025 10:00:00 +0000</pubDate>
      <sparkle:version>2.0.0</sparkle:version>
      <sparkle:shortVersionString>2.0.0</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>10.13</sparkle:minimumSystemVersion>
      <enclosure
        url="https://releases.example.com/MyApp-2.0.0.tar.gz"
        length="25000000"
        type="application/octet-stream"
        sparkle:edSignature="SIGNATURE_HERE"
        sparkle:dsaSignature="DEPRECATED_SIGNATURE" />
    </item>

    <!-- Previous versions for backwards compatibility -->
    <item>
      <title>Version 1.9.0</title>
      <sparkle:version>1.9.0</sparkle:version>
      <sparkle:shortVersionString>1.9.0</sparkle:shortVersionString>
      <enclosure
        url="https://releases.example.com/MyApp-1.9.0.tar.gz"
        length="24000000"
        type="application/octet-stream"
        sparkle:edSignature="SIGNATURE_HERE" />
    </item>
  </channel>
</rss>
```

**Generate EdDSA Keys (Run Once):**

```bash
# Generate EdDSA keys
./bin/generate_keys

# Output: save ed25519-pub.pem and ed25519-priv.pem
# Private key is stored in Keychain automatically
```

**Generating Appcast with Signatures:**

```bash
# Generate appcast with automatic EdDSA signing
./bin/generate_appcast /path/to/releases/folder

# Output: appcast.xml with EdDSA signatures populated
```

**Swift Integration Example:**

```swift
import Sparkle

@main
struct MyApp: App {
    @StateObject var updater = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(updater)
        }
    }
}

// Check for updates manually
struct SettingsView: View {
    @EnvironmentObject var updater: SPUStandardUpdaterController

    var body: some View {
        Button("Check for Updates") {
            updater.checkForUpdates()
        }
    }
}
```

---

### Squirrel (Windows/macOS)

Squirrel is the default update framework for Electron applications on Windows. It emphasizes silent, automatic updates without user prompts.

**Key Features:**
- No admin privileges required for updates
- Supports delta updates via bsdiff
- Works with electron-builder
- RELEASES file format for version management
- Spawns helper processes for background updates

**RELEASES File Format:**

```
19A87DB5D4B48F6CDEBCC59589D47F55779BAF80 MyApp-1.2.0-full.nupkg 52428800
8F3A34D5E2B98F6CDEBCC59589D47F55779BAF80 MyApp-1.2.0-delta.nupkg 5242880
```

**Squirrel Startup Handler (Node.js):**

```javascript
// main.js
const { app, BrowserWindow } = require('electron');
const { autoUpdater } = require('electron-updater');
const path = require('path');

// Handle Squirrel events on Windows startup
if (require('electron-squirrel-startup')) return;

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 768,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  });

  mainWindow.loadFile('index.html');

  // Setup auto-updater
  autoUpdater.checkForUpdatesAndNotify();
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

// Listen to update events
autoUpdater.on('update-available', () => {
  console.log('Update available');
});

autoUpdater.on('update-downloaded', () => {
  console.log('Update downloaded, will install on quit');
});

autoUpdater.on('error', (err) => {
  console.error('Auto-updater error:', err);
});
```

---

### electron-updater

Complete auto-update solution for Electron apps with support for multiple hosting providers.

**Key Features:**
- Multi-provider support (GitHub, S3, custom servers)
- Automatic build metadata generation
- Delta update support
- Staged rollouts
- Code signing verification
- Native macOS code signing support

**Installation:**

```bash
npm install electron-updater --save
npm install electron-builder --save-dev
```

**Complete Setup Example:**

```javascript
// main.js
const { app, BrowserWindow, ipcMain } = require('electron');
const { autoUpdater } = require('electron-updater');
const log = require('electron-log');
const path = require('path');

// Setup logging
log.transports.file.level = 'info';
autoUpdater.logger = log;

let mainWindow;

// Configure update provider
autoUpdater.checkForUpdatesAndNotify();

// For custom server setup (instead of GitHub)
/*
autoUpdater.setFeedURL({
  provider: 'generic',
  url: 'https://updates.example.com/releases'
});
*/

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 768,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true
    }
  });

  mainWindow.loadFile('index.html');
}

app.on('ready', createWindow);

// Auto-update events
autoUpdater.on('checking-for-update', () => {
  mainWindow.webContents.send('update-status', 'Checking for updates...');
});

autoUpdater.on('update-available', (info) => {
  log.info('Update available:', info);
  mainWindow.webContents.send('update-available', info);
});

autoUpdater.on('update-not-available', () => {
  mainWindow.webContents.send('update-status', 'No updates available');
});

autoUpdater.on('download-progress', (progressObj) => {
  log.info('Download progress:', progressObj.percent + '%');
  mainWindow.webContents.send('download-progress', {
    percent: progressObj.percent,
    bytesPerSecond: progressObj.bytesPerSecond,
    transferred: progressObj.transferred,
    total: progressObj.total
  });
});

autoUpdater.on('update-downloaded', (info) => {
  log.info('Update downloaded');
  mainWindow.webContents.send('update-downloaded');
});

autoUpdater.on('error', (err) => {
  log.error('Auto-updater error:', err);
  mainWindow.webContents.send('update-error', err.message);
});

// IPC handlers for update control
ipcMain.handle('quit-and-install', async () => {
  autoUpdater.quitAndInstall();
});

ipcMain.handle('check-for-updates', async () => {
  return await autoUpdater.checkForUpdatesAndNotify();
});
```

**Preload Script (IPC Bridge):**

```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('updateAPI', {
  onUpdateStatus: (callback) => {
    ipcRenderer.on('update-status', (event, data) => callback(data));
  },
  onUpdateAvailable: (callback) => {
    ipcRenderer.on('update-available', (event, data) => callback(data));
  },
  onDownloadProgress: (callback) => {
    ipcRenderer.on('download-progress', (event, data) => callback(data));
  },
  onUpdateDownloaded: (callback) => {
    ipcRenderer.on('update-downloaded', () => callback());
  },
  onUpdateError: (callback) => {
    ipcRenderer.on('update-error', (event, error) => callback(error));
  },
  checkForUpdates: () => ipcRenderer.invoke('check-for-updates'),
  quitAndInstall: () => ipcRenderer.invoke('quit-and-install')
});
```

**Frontend React Component:**

```javascript
// UpdateNotifier.jsx
import React, { useState, useEffect } from 'react';

export function UpdateNotifier() {
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [downloadProgress, setDownloadProgress] = useState(0);
  const [updateDownloaded, setUpdateDownloaded] = useState(false);
  const [status, setStatus] = useState('');

  useEffect(() => {
    // Listen for update events
    window.updateAPI?.onUpdateStatus(setStatus);
    window.updateAPI?.onUpdateAvailable(() => setUpdateAvailable(true));
    window.updateAPI?.onDownloadProgress(setDownloadProgress);
    window.updateAPI?.onUpdateDownloaded(() => setUpdateDownloaded(true));
  }, []);

  const handleInstall = () => {
    window.updateAPI?.quitAndInstall();
  };

  if (updateDownloaded) {
    return (
      <div className="update-banner success">
        <p>Update ready to install</p>
        <button onClick={handleInstall}>Install and Restart</button>
      </div>
    );
  }

  if (updateAvailable && downloadProgress > 0) {
    return (
      <div className="update-banner downloading">
        <p>Downloading update: {Math.round(downloadProgress)}%</p>
        <div className="progress-bar">
          <div
            className="progress-fill"
            style={{ width: `${downloadProgress}%` }}
          />
        </div>
      </div>
    );
  }

  if (status) {
    return <div className="update-status">{status}</div>;
  }

  return null;
}
```

**Package.json Configuration:**

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "description": "My Electron App",
  "main": "main.js",
  "homepage": "https://example.com",
  "repository": {
    "type": "git",
    "url": "https://github.com/user/my-app.git"
  },
  "build": {
    "appId": "com.example.myapp",
    "files": [
      "main.js",
      "preload.js",
      "dist/",
      "node_modules/"
    ],
    "win": {
      "target": [
        "nsis",
        "portable"
      ]
    },
    "mac": {
      "target": [
        "dmg",
        "zip"
      ],
      "certificateFile": "path/to/certificate.p12",
      "certificatePassword": "password"
    },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "createDesktopShortcut": true
    },
    "publish": {
      "provider": "github",
      "owner": "user",
      "repo": "my-app"
    }
  }
}
```

---

### WinSparkle (Windows)

Windows-native alternative inspired by macOS Sparkle, emphasizing GUI-first approach and modern security.

**Key Features:**
- EdDSA (Ed25519) signing support
- GUI-driven update dialogs
- Appcast XML format compatible with Sparkle
- C API for multiple language support
- x86, x64, and ARM64 support
- Deprecated DSA signing still supported

**C++ Integration Example:**

```cpp
// main.cpp
#include <windows.h>
#include "winsparkle.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow)
{
    // Initialize WinSparkle with your app details
    // Called once at application startup

    // Set the appcast URL
    win_sparkle_set_appcast_url("https://updates.example.com/appcast.xml");

    // Set error reporting email (optional)
    win_sparkle_set_error_callback(ErrorCallback);

    // Initialize WinSparkle
    win_sparkle_init();

    // Check for updates periodically
    // This happens in the background automatically
    // Default: check once per day

    // Your application main window and event loop here

    return 0;
}

void ErrorCallback(const char* errorMessage)
{
    MessageBoxA(NULL, errorMessage, "Update Error", MB_OK | MB_ICONERROR);
}
```

**NuGet Package Installation:**

```bash
# Install WinSparkle via NuGet
Install-Package WinSparkle

# This provides:
# - WinSparkle.dll for your target architecture
# - Header files for C++ integration
```

---

### Omaha Protocol (Google Update System)

Enterprise-grade update system used by Google Chrome, Microsoft Edge, and Google products. Runs as a separate service managing multiple applications.

**Key Features:**
- Separate update service process
- Supports multiple applications
- Differential updates
- Anonymous device counting
- Enterprise control policies
- Windows and macOS support

**Omaha Protocol Request (XML over HTTP POST):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<request protocol="3.1"
         shell_version="1.3.36.11"
         ismachine="1"
         sessionid="{SESSIONID}"
         userid="{USERID}"
         installsource="other">
  <os version="10.0" platform="win" sp="Service Pack 1"/>
  <app appid="{APPID}" version="1.0.0.0" nextversion="" brand="">
    <updatecheck/>
    <data name="install" index="1"/>
  </app>
</request>
```

**Omaha Protocol Response (Server):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<response protocol="3.1" server="prod">
  <daystart elapsed_seconds="1234"/>
  <app appid="{APPID}" status="ok">
    <updatecheck status="ok">
      <urls>
        <url codebase="https://updates.example.com/download/"/>
      </urls>
      <manifest version="2.0.0.0"
                action="update"
                productsearch="https://www.google.com/search?q=">
        <packages>
          <package name="app_2.0.0.0.exe"
                   size="52428800"
                   hash="abc123def456"
                   needsadmin="false"/>
        </packages>
        <actions>
          <action event="install" run="app_2.0.0.0.exe" args="/install"/>
          <action event="postinstall" run="app.exe" args="--post-install"/>
        </actions>
      </manifest>
    </updatecheck>
  </app>
</response>
```

**Implementing Omaha Client (C#):**

```csharp
using System;
using System.Net.Http;
using System.Xml.Linq;
using System.Threading.Tasks;

public class OmahaUpdateClient
{
    private readonly string _appId;
    private readonly string _updateUrl;
    private readonly HttpClient _httpClient;

    public OmahaUpdateClient(string appId, string updateUrl)
    {
        _appId = appId;
        _updateUrl = updateUrl;
        _httpClient = new HttpClient();
    }

    public async Task<UpdateInfo> CheckForUpdatesAsync(string currentVersion)
    {
        // Create Omaha request
        var request = CreateOmahaRequest(currentVersion);

        var content = new StringContent(request, System.Text.Encoding.UTF8, "application/x-www-form-urlencoded");
        var response = await _httpClient.PostAsync(_updateUrl, content);

        if (!response.IsSuccessStatusCode)
            return null;

        var responseContent = await response.Content.ReadAsStringAsync();
        return ParseOmahaResponse(responseContent);
    }

    private string CreateOmahaRequest(string version)
    {
        var request = new XElement("request",
            new XAttribute("protocol", "3.1"),
            new XAttribute("shell_version", "1.3.36.11"),
            new XAttribute("ismachine", "1"),
            new XAttribute("sessionid", Guid.NewGuid().ToString()),
            new XElement("os",
                new XAttribute("version", "10.0"),
                new XAttribute("platform", "win")),
            new XElement("app",
                new XAttribute("appid", _appId),
                new XAttribute("version", version),
                new XElement("updatecheck")));

        return $"request={Uri.EscapeDataString(request.ToString())}";
    }

    private UpdateInfo ParseOmahaResponse(string responseXml)
    {
        try
        {
            var doc = XDocument.Parse(responseXml);
            var updateCheckElement = doc.Root?.Element("app")?.Element("updatecheck");

            if (updateCheckElement?.Attribute("status")?.Value != "ok")
                return null;

            var manifestElement = updateCheckElement.Element("manifest");
            var packageElement = manifestElement?.Element("packages")?.Element("package");

            if (packageElement == null)
                return null;

            return new UpdateInfo
            {
                Version = manifestElement.Attribute("version")?.Value,
                DownloadUrl = doc.Root.Element("app")
                    .Element("updatecheck")
                    .Element("urls")
                    .Element("url")
                    .Attribute("codebase")?.Value + packageElement.Attribute("name")?.Value,
                FileSize = long.Parse(packageElement.Attribute("size")?.Value ?? "0"),
                Hash = packageElement.Attribute("hash")?.Value,
                InstallerPath = packageElement.Attribute("name")?.Value
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error parsing Omaha response: {ex.Message}");
            return null;
        }
    }
}

public class UpdateInfo
{
    public string Version { get; set; }
    public string DownloadUrl { get; set; }
    public long FileSize { get; set; }
    public string Hash { get; set; }
    public string InstallerPath { get; set; }
}
```

---

## UPDATE STRATEGIES

### Full Binary Replacement

Complete replacement of the application binary. Simple but requires larger downloads.

**Advantages:**
- Simple implementation
- No state tracking required
- Fast installation
- Guaranteed consistency

**Disadvantages:**
- Larger download size
- Longer download times
- Higher bandwidth costs

**Implementation:**

```javascript
// Download and install full update
async function installFullUpdate(updateInfo) {
  const downloadPath = path.join(app.getPath('userData'), 'update.zip');

  // Download full binary
  console.log(`Downloading ${formatBytes(updateInfo.size)}...`);
  await downloadFile(updateInfo.downloadUrl, downloadPath);

  // Verify checksum
  const checksum = await calculateSHA256(downloadPath);
  if (checksum !== updateInfo.expectedChecksum) {
    throw new Error('Checksum verification failed');
  }

  // Extract and backup current version
  const backupPath = path.join(app.getPath('userData'), `backup-${app.getVersion()}`);
  await fs.promises.cp(process.execPath, backupPath);

  // Extract update
  await extractZip(downloadPath, app.getAppPath());

  // Cleanup
  await fs.promises.unlink(downloadPath);

  return true;
}

function formatBytes(bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  let size = bytes;
  let unitIndex = 0;

  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }

  return `${size.toFixed(2)} ${units[unitIndex]}`;
}
```

---

### Delta Updates (Binary Differencing)

Only download the differences between versions using bsdiff or similar algorithms.

**Advantages:**
- Significantly smaller download (1-10% of full binary)
- Reduced bandwidth costs
- Faster downloads
- Ideal for large applications

**Disadvantages:**
- More complex implementation
- Requires both old and new binary versions
- Slower patching process
- Fallback to full update required

**Bsdiff Implementation:**

```javascript
// Using bsdiff library
const bsdiff = require('bsdiff');
const fs = require('fs');
const crypto = require('crypto');

// On server: Generate delta from version 1.0 to 2.0
async function generateDeltaPatch(oldBinaryPath, newBinaryPath, outputPath) {
  const oldBinary = await fs.promises.readFile(oldBinaryPath);
  const newBinary = await fs.promises.readFile(newBinaryPath);

  // Create delta patch
  const patch = await bsdiff(oldBinary, newBinary);

  // Save patch
  await fs.promises.writeFile(outputPath, patch);

  // Calculate patch info
  const patchSize = patch.length;
  const patchHash = crypto.createHash('sha256').update(patch).digest('hex');
  const compression = ((1 - patchSize / newBinary.length) * 100).toFixed(2);

  console.log(`Delta patch created:`);
  console.log(`  Size: ${(patchSize / 1024 / 1024).toFixed(2)} MB`);
  console.log(`  Full size: ${(newBinary.length / 1024 / 1024).toFixed(2)} MB`);
  console.log(`  Compression: ${compression}%`);
  console.log(`  Hash: ${patchHash}`);

  return { patchHash, patchSize };
}

// On client: Apply delta patch
async function applyDeltaPatch(oldBinaryPath, patchPath, outputPath) {
  const bspatch = require('bspatch');
  const oldBinary = await fs.promises.readFile(oldBinaryPath);
  const patch = await fs.promises.readFile(patchPath);

  // Apply patch
  const newBinary = await bspatch(oldBinary, patch);

  // Save new binary
  await fs.promises.writeFile(outputPath, newBinary);

  console.log(`Delta patch applied successfully`);
}

// Metadata format for delta updates
const deltaUpdateMetadata = {
  version: "2.0.0",
  type: "delta",
  baseVersion: "1.0.0",
  patchSize: 5242880,
  patchHash: "abc123def456...",
  newBinaryHash: "xyz789abc123...",
  compressionRatio: 78.5,
  fallbackUrl: "https://releases.example.com/app-2.0.0-full.zip"
};
```

---

### Staged Rollouts

Gradually roll out updates to users in phases to catch issues early.

**Advantages:**
- Risk mitigation
- Early issue detection
- Gradual user experience transition
- Easy rollback if needed

**Disadvantages:**
- Longer update process
- Complex coordination logic
- Version fragmentation temporarily

**Implementation:**

```javascript
// Staged rollout configuration
const stagingConfig = {
  stages: [
    {
      name: "Canary",
      percentUsers: 1,
      duration: "12h",
      monitoring: {
        crashRate: 0.01,
        errorRate: 0.05,
        performanceThreshold: 0.9
      }
    },
    {
      name: "Early Access",
      percentUsers: 5,
      duration: "24h",
      monitoring: {
        crashRate: 0.02,
        errorRate: 0.10,
        performanceThreshold: 0.85
      }
    },
    {
      name: "General Release",
      percentUsers: 100,
      duration: "unlimited",
      monitoring: {
        crashRate: 0.05,
        errorRate: 0.15
      }
    }
  ]
};

// Server-side update eligibility check
function shouldUpdateUser(userId, versionInfo, userMetrics) {
  const currentStage = versionInfo.currentStage;
  const stagingRule = stagingConfig.stages[currentStage];

  // Determine user group based on userId
  const userGroup = getUserGroup(userId, stagingRule.percentUsers);

  // Check monitoring metrics
  if (!meetsMonitoringCriteria(userMetrics, stagingRule.monitoring)) {
    console.log(`Update rolled back: monitoring criteria not met`);
    return false;
  }

  // Check user eligibility
  return userGroup <= stagingRule.percentUsers;
}

function getUserGroup(userId, percentUsers) {
  // Consistent hash-based grouping
  const hash = parseInt(userId.substring(0, 8), 16);
  const group = (hash % 100) + 1;
  return group;
}

function meetsMonitoringCriteria(metrics, thresholds) {
  return (
    metrics.crashRate <= thresholds.crashRate &&
    metrics.errorRate <= thresholds.errorRate &&
    (!thresholds.performanceThreshold ||
     metrics.performanceScore >= thresholds.performanceThreshold)
  );
}

// Client receiving update response
function handleStagedUpdateResponse(response) {
  if (response.status === 'update-available') {
    const rolloutInfo = response.rolloutInfo;

    console.log(`Update available: ${rolloutInfo.version}`);
    console.log(`Current rollout stage: ${rolloutInfo.stage} (${rolloutInfo.percentage}% of users)`);

    if (rolloutInfo.isEligible) {
      scheduleUpdate(response.updateUrl);
    } else {
      scheduleRetryCheck(rolloutInfo.retryAfter);
    }
  }
}
```

---

### Rollback Mechanisms

Ability to revert to a previous version if an update causes critical issues.

**Advantages:**
- Quick issue resolution
- Reduces user impact
- Confidence in rapid deployments
- Automated issue detection

**Disadvantages:**
- Complex state management
- Database schema migration challenges
- Storage overhead for backup versions

**Implementation:**

```javascript
// Automatic rollback mechanism
const rollbackConfig = {
  enabled: true,
  triggers: [
    {
      type: 'crash-threshold',
      threshold: 0.10,
      timeWindow: '5m'
    },
    {
      type: 'error-rate',
      threshold: 0.15,
      timeWindow: '10m'
    },
    {
      type: 'performance-degradation',
      threshold: 0.7,
      timeWindow: '5m'
    }
  ],
  keepVersions: 3,
  backupStoragePath: '/var/backups/app-versions'
};

class VersionManager {
  constructor() {
    this.versions = [];
    this.currentVersion = null;
    this.metrics = {};
  }

  async backupCurrentVersion() {
    const currentPath = process.execPath;
    const version = app.getVersion();
    const backupPath = path.join(
      rollbackConfig.backupStoragePath,
      `app-${version}-${Date.now()}.backup`
    );

    await fs.promises.mkdir(rollbackConfig.backupStoragePath, { recursive: true });
    await fs.promises.cp(currentPath, backupPath);

    this.versions.push({
      version,
      timestamp: Date.now(),
      backupPath,
      metrics: { crashes: 0, errors: 0 }
    });

    // Keep only last N versions
    if (this.versions.length > rollbackConfig.keepVersions) {
      const oldVersion = this.versions.shift();
      await fs.promises.unlink(oldVersion.backupPath);
    }

    console.log(`Version ${version} backed up to ${backupPath}`);
  }

  async restoreVersion(versionNumber) {
    const versionRecord = this.versions.find(v => v.version === versionNumber);

    if (!versionRecord) {
      throw new Error(`Version ${versionNumber} not found in backups`);
    }

    console.log(`Restoring version ${versionNumber}...`);

    // Verify backup integrity
    const backupExists = await fs.promises.stat(versionRecord.backupPath);
    if (!backupExists) {
      throw new Error(`Backup file not found at ${versionRecord.backupPath}`);
    }

    // Stop all app processes
    await this.stopAppProcesses();

    // Restore binary
    const appPath = process.execPath;
    await fs.promises.cp(versionRecord.backupPath, appPath, { force: true });

    console.log(`Version ${versionNumber} restored successfully`);

    // Restart app
    app.relaunch();
    app.exit(0);
  }

  async stopAppProcesses() {
    // Platform-specific process stopping
    if (process.platform === 'win32') {
      // Windows: use taskkill
      return new Promise((resolve, reject) => {
        require('child_process').exec(
          `taskkill /F /IM ${path.basename(process.execPath)}`,
          (error) => {
            if (error && error.code !== 1) {
              reject(error);
            } else {
              resolve();
            }
          }
        );
      });
    }
  }

  recordMetrics(crashes, errors, performanceScore) {
    this.metrics = { crashes, errors, performanceScore };
    this.checkRollbackTriggers();
  }

  async checkRollbackTriggers() {
    for (const trigger of rollbackConfig.triggers) {
      let shouldRollback = false;

      switch (trigger.type) {
        case 'crash-threshold':
          if (this.metrics.crashes / this.metrics.sessionCount > trigger.threshold) {
            shouldRollback = true;
          }
          break;
        case 'error-rate':
          if (this.metrics.errors / this.metrics.requestCount > trigger.threshold) {
            shouldRollback = true;
          }
          break;
        case 'performance-degradation':
          if (this.metrics.performanceScore < trigger.threshold) {
            shouldRollback = true;
          }
          break;
      }

      if (shouldRollback) {
        console.log(`Rollback triggered: ${trigger.type}`);
        const previousVersion = this.versions[this.versions.length - 2];
        if (previousVersion) {
          await this.restoreVersion(previousVersion.version);
        }
      }
    }
  }
}
```

---

### Update Channels (Stable/Beta/Nightly)

Parallel update tracks for different user preferences and risk tolerance.

**Advantages:**
- Segmented user testing
- Risk management
- Early adopter feedback
- Version stability control

**Disadvantages:**
- Version fragmentation
- Support complexity
- Separate release processes

**Implementation:**

```javascript
// Update channel configuration
const updateChannels = {
  stable: {
    feedUrl: 'https://updates.example.com/appcast-stable.xml',
    releaseFrequency: '4 weeks',
    testingPeriod: '8 weeks',
    minStabilityScore: 0.95
  },
  beta: {
    feedUrl: 'https://updates.example.com/appcast-beta.xml',
    releaseFrequency: '2 weeks',
    testingPeriod: '2 weeks',
    minStabilityScore: 0.80
  },
  nightly: {
    feedUrl: 'https://updates.example.com/appcast-nightly.xml',
    releaseFrequency: 'daily',
    testingPeriod: 'none',
    minStabilityScore: 0.00
  }
};

// User preferences
const userChannelPreferences = {
  userId: 'user123',
  channel: 'beta', // Can be 'stable', 'beta', or 'nightly'
  autoUpdate: true,
  updateWindow: {
    startHour: 22,
    endHour: 6 // Download between 10 PM - 6 AM
  }
};

// Update channel selection
class UpdateChannelManager {
  constructor() {
    this.currentChannel = userChannelPreferences.channel;
  }

  getFeedUrl() {
    return updateChannels[this.currentChannel].feedUrl;
  }

  async checkForUpdates() {
    const feedUrl = this.getFeedUrl();
    const response = await fetch(feedUrl);
    const appcast = await response.text();

    return this.parseAppcast(appcast);
  }

  async setChannel(newChannel) {
    if (!updateChannels[newChannel]) {
      throw new Error(`Invalid channel: ${newChannel}`);
    }

    this.currentChannel = newChannel;
    userChannelPreferences.channel = newChannel;

    console.log(`Update channel changed to ${newChannel}`);
    console.log(`Release frequency: ${updateChannels[newChannel].releaseFrequency}`);

    // Check for updates in new channel
    await this.checkForUpdates();
  }

  parseAppcast(appcastXml) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(appcastXml, 'text/xml');

    const items = doc.querySelectorAll('item');
    const updates = [];

    items.forEach(item => {
      const version = item.querySelector('sparkle\\:version')?.textContent;
      const title = item.querySelector('title')?.textContent;
      const description = item.querySelector('description')?.textContent;
      const enclosure = item.querySelector('enclosure');

      if (version && enclosure) {
        updates.push({
          version,
          title,
          description,
          url: enclosure.getAttribute('url'),
          length: enclosure.getAttribute('length'),
          signature: enclosure.getAttribute('sparkle:edSignature')
        });
      }
    });

    return updates;
  }

  getChannelMetadata() {
    return {
      current: this.currentChannel,
      metadata: updateChannels[this.currentChannel],
      warning: this.currentChannel === 'nightly'
        ? 'Nightly builds may be unstable'
        : null
    };
  }
}

// UI for channel selection
function renderChannelSelector() {
  const channels = Object.keys(updateChannels);

  return `
    <div class="channel-selector">
      <label>Update Channel:</label>
      <select id="channelSelect">
        ${channels.map(channel => `
          <option value="${channel}" ${userChannelPreferences.channel === channel ? 'selected' : ''}>
            ${channel.charAt(0).toUpperCase() + channel.slice(1)}
            <small>${updateChannels[channel].releaseFrequency}</small>
          </option>
        `).join('')}
      </select>
    </div>
  `;
}
```

---

## DISTRIBUTION METHODS

### GitHub Releases Integration

Most common distribution method for open-source projects using Electron.

**Setup:**

```bash
# 1. Create GitHub token with 'repo' scope
# 2. Set GITHUB_TOKEN environment variable
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxx

# 3. Build and publish with electron-builder
npm run electron-builder -- --publish always
```

**Build Configuration:**

```json
{
  "build": {
    "publish": {
      "provider": "github",
      "owner": "myusername",
      "repo": "myapp",
      "releaseType": "release"
    },
    "files": [
      "dist/**/*",
      "!dist/**/*.map"
    ]
  }
}
```

**Assets Generated:**

```
releases/
  ├── latest.yml              # Latest version metadata
  ├── latest-mac.yml          # macOS latest
  ├── latest-linux.yml        # Linux latest
  ├── MyApp-1.0.0-full.nupkg  # Windows full installer
  ├── MyApp-1.0.0.exe         # Windows installer
  ├── MyApp-1.0.0.exe.blockmap # Update delta info
  ├── MyApp-1.0.0.dmg         # macOS installer
  ├── MyApp-1.0.0.tar.gz      # Linux installer
  └── MyApp-1.0.0-mac.zip     # macOS portable
```

---

### S3/CDN Hosting

Hosting updates on S3 with CloudFront CDN for global distribution.

**Implementation:**

```javascript
// Upload builds to S3
const AWS = require('aws-sdk');
const fs = require('fs');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
});

async function uploadBuildToS3(filePath, buildMetadata) {
  const fileContent = fs.readFileSync(filePath);
  const fileName = path.basename(filePath);

  const params = {
    Bucket: 'my-app-releases',
    Key: `releases/${buildMetadata.version}/${fileName}`,
    Body: fileContent,
    ContentType: 'application/octet-stream',
    Metadata: {
      'app-version': buildMetadata.version,
      'release-date': new Date().toISOString(),
      'platform': buildMetadata.platform
    },
    CacheControl: 'max-age=31536000' // 1 year cache
  };

  try {
    const result = await s3.upload(params).promise();
    console.log(`Uploaded ${fileName} to ${result.Location}`);
    return result.Location;
  } catch (error) {
    console.error(`Upload failed: ${error.message}`);
    throw error;
  }
}

// Generate metadata file
async function generateS3Metadata(builds) {
  const metadata = {
    latest: {
      version: builds[0].version,
      releaseDate: builds[0].releaseDate,
      files: {
        win64: builds[0].win64Url,
        macos: builds[0].macosUrl,
        linux: builds[0].linuxUrl
      }
    },
    releases: builds.map(build => ({
      version: build.version,
      releaseDate: build.releaseDate,
      releaseNotes: build.releaseNotes,
      files: {
        win64: build.win64Url,
        macos: build.macosUrl,
        linux: build.linuxUrl
      }
    }))
  };

  // Upload metadata
  const params = {
    Bucket: 'my-app-releases',
    Key: 'metadata.json',
    Body: JSON.stringify(metadata, null, 2),
    ContentType: 'application/json'
  };

  await s3.upload(params).promise();
}

// Generic provider configuration
const genericUpdateConfig = {
  provider: 'generic',
  url: 'https://releases.example.com/releases',
  // OR use CloudFront CDN
  // url: 'https://d123456.cloudfront.net/releases'
  channel: 'latest'
};
```

---

### Self-Hosted Server

Complete control with your own update server.

**Node.js/Express Implementation:**

```javascript
// update-server.js
const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const app = express();

// In-memory release database
const releases = [
  {
    version: '2.0.0',
    platform: 'win32-x64',
    releaseDate: '2025-11-15',
    filename: 'MyApp-2.0.0-x64.exe',
    size: 52428800,
    hash: 'abc123def456...',
    releaseNotes: 'Major feature release',
    minVersion: '1.0.0'
  },
  {
    version: '2.0.0',
    platform: 'darwin',
    releaseDate: '2025-11-15',
    filename: 'MyApp-2.0.0.dmg',
    size: 78643200,
    hash: 'xyz789abc123...',
    releaseNotes: 'Major feature release'
  }
];

// Check for updates endpoint
app.get('/api/update/:platform/:version', (req, res) => {
  const { platform, version } = req.params;

  // Find newer release
  const latestRelease = releases
    .filter(r => r.platform === platform && r.version > version)
    .sort((a, b) => {
      const aVersion = a.version.split('.').map(Number);
      const bVersion = b.version.split('.').map(Number);
      return bVersion[0] - aVersion[0] || bVersion[1] - aVersion[1];
    })[0];

  if (!latestRelease) {
    return res.json({ updateAvailable: false });
  }

  // Check minimum version requirement
  if (version < latestRelease.minVersion) {
    return res.json({
      updateAvailable: true,
      mandatory: true,
      reason: 'Security update required'
    });
  }

  res.json({
    updateAvailable: true,
    version: latestRelease.version,
    releaseDate: latestRelease.releaseDate,
    releaseNotes: latestRelease.releaseNotes,
    downloadUrl: `https://updates.example.com/files/${latestRelease.filename}`,
    fileSize: latestRelease.size,
    checksum: latestRelease.hash,
    checksumAlgorithm: 'sha256'
  });
});

// Download file endpoint with resume support
app.get('/files/:filename', (req, res) => {
  const filepath = path.join('/var/releases', req.params.filename);
  const stat = fs.statSync(filepath);
  const filesize = stat.size;
  const range = req.headers.range;

  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : filesize - 1;

    res.writeHead(206, {
      'Content-Range': `bytes ${start}-${end}/${filesize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': end - start + 1,
      'Content-Type': 'application/octet-stream'
    });

    fs.createReadStream(filepath, { start, end }).pipe(res);
  } else {
    res.writeHead(200, {
      'Content-Length': filesize,
      'Content-Type': 'application/octet-stream',
      'Accept-Ranges': 'bytes'
    });
    fs.createReadStream(filepath).pipe(res);
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

app.listen(3000, () => {
  console.log('Update server running on port 3000');
});
```

**Client Connection:**

```javascript
// client-update.js
const { autoUpdater } = require('electron-updater');

autoUpdater.setFeedURL({
  provider: 'generic',
  url: 'https://updates.example.com/api/update'
});

// Check for updates
autoUpdater.checkForUpdates();
```

---

### Package Manager Updates

Distribute through system package managers.

**Snap Package (Linux):**

```yaml
# snapcraft.yaml
name: myapp
version: '2.0.0'
summary: My Application
description: |
  Full description of the application

base: core22
confinement: strict

apps:
  myapp:
    command: bin/myapp
    plugs:
      - home
      - network
      - network-bind

parts:
  myapp:
    plugin: dump
    source: ./dist/
    organize:
      '*': bin/
```

**Publish to Snap Store:**

```bash
# Build snap
snapcraft snap --output=myapp.snap

# Login to Snap Store
snapcraft login

# Upload
snapcraft upload --release=stable myapp.snap
```

**Homebrew (macOS):**

```ruby
# Formula: myapp.rb
class Myapp < Formula
  desc "My application"
  homepage "https://example.com"
  url "https://releases.example.com/MyApp-2.0.0.tar.gz"
  sha256 "abc123def456..."

  def install
    bin.install "MyApp"
  end

  def caveats
    "Automatic updates are handled by the application"
  end
end
```

**Chocolatey (Windows):**

```xml
<!-- myapp.nuspec -->
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>myapp</id>
    <version>2.0.0</version>
    <title>My Application</title>
    <authors>Your Name</authors>
    <description>My awesome application</description>
    <projectUrl>https://example.com</projectUrl>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
```

---

## IMPLEMENTATION EXAMPLES

### Complete Electron Auto-Update Setup

End-to-end implementation of electron-updater with GitHub Releases.

**File Structure:**

```
my-electron-app/
├── main.js
├── preload.js
├── src/
│   ├── components/
│   │   └── UpdateNotifier.jsx
│   └── App.jsx
├── public/
│   ├── index.html
│   └── icon.png
├── package.json
└── electron-builder.yml
```

**main.js (Complete):**

```javascript
const { app, BrowserWindow, ipcMain, Menu } = require('electron');
const { autoUpdater } = require('electron-updater');
const log = require('electron-log');
const path = require('path');
const isDev = require('electron-is-dev');

// Configure logging
log.transports.file.level = 'info';
autoUpdater.logger = log;

let mainWindow;
let updateAvailable = false;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      enableRemoteModule: false
    }
  });

  const startUrl = isDev
    ? 'http://localhost:3000'
    : `file://${path.join(__dirname, '../build/index.html')}`;

  mainWindow.loadURL(startUrl);

  if (isDev) {
    mainWindow.webContents.openDevTools();
  }

  // Handle window closed
  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.on('ready', () => {
  createWindow();
  setupAutoUpdater();
  createMenu();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

// Auto-updater setup
function setupAutoUpdater() {
  // Configure provider (GitHub by default from package.json)
  if (!isDev) {
    autoUpdater.checkForUpdatesAndNotify();
  }

  autoUpdater.on('checking-for-update', () => {
    log.info('Checking for updates...');
    mainWindow.webContents.send('update-status', 'Checking for updates...');
  });

  autoUpdater.on('update-available', (info) => {
    log.info('Update available:', info);
    updateAvailable = true;
    mainWindow.webContents.send('update-available', {
      version: info.version,
      releaseDate: info.releaseDate,
      releaseNotes: info.releaseNotes
    });
  });

  autoUpdater.on('update-not-available', () => {
    log.info('Update not available');
    mainWindow.webContents.send('update-not-available');
  });

  autoUpdater.on('download-progress', (progressObj) => {
    const progress = {
      percent: Math.round(progressObj.percent),
      bytesPerSecond: progressObj.bytesPerSecond,
      transferred: progressObj.transferred,
      total: progressObj.total
    };
    log.info(`Download progress: ${progress.percent}%`);
    mainWindow.webContents.send('download-progress', progress);
  });

  autoUpdater.on('update-downloaded', (info) => {
    log.info('Update downloaded');
    mainWindow.webContents.send('update-downloaded', {
      version: info.version
    });
  });

  autoUpdater.on('error', (error) => {
    log.error('Auto-updater error:', error);
    mainWindow.webContents.send('update-error', error.message);
  });

  // Manual check interval (12 hours)
  setInterval(() => {
    if (!isDev) {
      autoUpdater.checkForUpdates();
    }
  }, 12 * 60 * 60 * 1000);
}

// IPC Handlers
ipcMain.handle('check-for-updates', async () => {
  return await autoUpdater.checkForUpdates();
});

ipcMain.handle('quit-and-install', () => {
  autoUpdater.quitAndInstall();
});

// Application Menu
function createMenu() {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Exit',
          click: () => {
            app.quit();
          }
        }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'Check for Updates',
          click: () => {
            autoUpdater.checkForUpdates();
          }
        },
        {
          label: 'About',
          click: () => {
            const { version } = require('./package.json');
            const message = `My App v${version}\nBuilt with Electron ${process.versions.electron}`;
            require('electron').dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: 'About',
              message
            });
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}
```

**electron-builder.yml:**

```yaml
appId: com.example.myapp
productName: My App

directories:
  buildResources: public
  output: dist

files:
  - from: .
    to: .
    filter:
      - package.json
      - main.js
      - preload.js
  - from: build
    to: app/build
    filter:
      - '**/*'
  - from: node_modules
    to: app/node_modules
    filter:
      - '**/*'

win:
  target:
    - nsis
    - portable
  certificateFile: path/to/certificate.p12
  certificatePassword: ${CSC_KEY_PASSWORD}
  signingHashAlgorithms:
    - sha256
    - sha1

nsis:
  oneClick: false
  allowToChangeInstallationDirectory: true
  createDesktopShortcut: true
  createStartMenuShortcut: true
  shortcutName: My App

mac:
  target:
    - dmg
    - zip
  signingIdentity: Developer ID Application
  notarize:
    teamId: XXXXXXXXXX

dmg:
  sign: false

linux:
  target:
    - AppImage
    - deb
  category: Utility

publish:
  provider: github
  owner: yourname
  repo: my-app
  releaseType: release
```

**preload.js:**

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('updateAPI', {
  onUpdateStatus: (callback) => {
    ipcRenderer.on('update-status', (event, data) => callback(data));
  },
  onUpdateAvailable: (callback) => {
    ipcRenderer.on('update-available', (event, data) => callback(data));
  },
  onUpdateNotAvailable: (callback) => {
    ipcRenderer.on('update-not-available', () => callback());
  },
  onDownloadProgress: (callback) => {
    ipcRenderer.on('download-progress', (event, data) => callback(data));
  },
  onUpdateDownloaded: (callback) => {
    ipcRenderer.on('update-downloaded', (event, data) => callback(data));
  },
  onUpdateError: (callback) => {
    ipcRenderer.on('update-error', (event, error) => callback(error));
  },
  checkForUpdates: () => ipcRenderer.invoke('check-for-updates'),
  quitAndInstall: () => ipcRenderer.invoke('quit-and-install'),
  getAppVersion: () => ipcRenderer.invoke('get-app-version')
});
```

**UpdateNotifier.jsx (React Component):**

```jsx
import React, { useState, useEffect } from 'react';
import './UpdateNotifier.css';

export function UpdateNotifier() {
  const [status, setStatus] = useState('idle');
  const [updateInfo, setUpdateInfo] = useState(null);
  const [downloadProgress, setDownloadProgress] = useState(0);

  useEffect(() => {
    const { updateAPI } = window;

    updateAPI.onUpdateStatus((message) => {
      setStatus('checking');
      console.log('Update status:', message);
    });

    updateAPI.onUpdateAvailable((info) => {
      setStatus('available');
      setUpdateInfo(info);
      console.log('Update available:', info);
    });

    updateAPI.onUpdateNotAvailable(() => {
      setStatus('up-to-date');
    });

    updateAPI.onDownloadProgress((progress) => {
      setStatus('downloading');
      setDownloadProgress(progress.percent);
    });

    updateAPI.onUpdateDownloaded((info) => {
      setStatus('ready');
      setUpdateInfo(info);
    });

    updateAPI.onUpdateError((error) => {
      setStatus('error');
      console.error('Update error:', error);
    });

    return () => {
      // Cleanup listeners
    };
  }, []);

  const handleInstall = async () => {
    await window.updateAPI.quitAndInstall();
  };

  const handleCheckUpdates = async () => {
    setStatus('checking');
    await window.updateAPI.checkForUpdates();
  };

  const getStatusMessage = () => {
    switch (status) {
      case 'checking':
        return '🔄 Checking for updates...';
      case 'available':
        return `✨ Update available: v${updateInfo?.version}`;
      case 'downloading':
        return `⬇️ Downloading: ${downloadProgress}%`;
      case 'ready':
        return `✅ Ready to install v${updateInfo?.version}`;
      case 'up-to-date':
        return '✓ You are up to date';
      case 'error':
        return '❌ Update check failed';
      default:
        return null;
    }
  };

  if (status === 'idle') {
    return null;
  }

  return (
    <div className={`update-notifier update-${status}`}>
      <div className="update-message">
        <p>{getStatusMessage()}</p>
        {updateInfo?.releaseNotes && (
          <details>
            <summary>Release Notes</summary>
            <p>{updateInfo.releaseNotes}</p>
          </details>
        )}
      </div>
      <div className="update-actions">
        {status === 'ready' && (
          <button onClick={handleInstall} className="btn-primary">
            Install and Restart
          </button>
        )}
        {status === 'up-to-date' && (
          <button onClick={handleCheckUpdates} className="btn-secondary">
            Check Again
          </button>
        )}
      </div>
    </div>
  );
}
```

---

### Tauri Updater

Tauri's approach to application updates.

**Installation:**

```bash
cd your-tauri-app
cargo add tauri-plugin-updater
```

**Cargo.toml Configuration:**

```toml
[dependencies]
tauri = { version = "2.0", features = ["shell-open", "window-close"] }
tauri-plugin-updater = "2.0"
```

**src-tauri/tauri.conf.json:**

```json
{
  "productName": "my-app",
  "version": "1.0.0",
  "identifier": "com.example.myapp",
  "build": {
    "devUrl": "http://localhost:5173",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      {
        "title": "My App",
        "width": 1024,
        "height": 768,
        "resizable": true,
        "fullscreen": false
      }
    ],
    "security": {
      "csp": null
    }
  },
  "bundle": {
    "active": true,
    "targets": [
      "msi",
      "dmg",
      "deb"
    ],
    "updater": {
      "active": true,
      "endpoints": [
        "https://releases.example.com/updates/{{target}}/{{current_version}}"
      ],
      "dialog": true,
      "pubkey": "YOUR_PUBLIC_KEY_HERE"
    }
  }
}
```

**Rust Code (src-tauri/src/main.rs):**

```rust
use tauri::Manager;
use tauri_plugin_updater::UpdaterExt;

#[tokio::main]
async fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_updater::Builder::new().build())
        .setup(|app| {
            let app_handle = app.handle().clone();

            // Check for updates on startup
            tauri::async_runtime::spawn(async move {
                update_app(app_handle).await;
            });

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![check_for_updates, install_update])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

#[tauri::command]
async fn check_for_updates(
    app: tauri::AppHandle,
) -> Result<bool, String> {
    let update = app
        .updater()
        .check()
        .await
        .map_err(|e| e.to_string())?;

    Ok(update.is_update_available())
}

#[tauri::command]
async fn install_update(
    app: tauri::AppHandle,
) -> Result<(), String> {
    let update = app
        .updater()
        .check()
        .await
        .map_err(|e| e.to_string())?;

    if update.is_update_available() {
        update
            .download_and_install()
            .await
            .map_err(|e| e.to_string())?;

        app.restart();
    }

    Ok(())
}

async fn update_app(app: tauri::AppHandle) {
    match app.updater().check().await {
        Ok(update) => {
            if update.is_update_available() {
                println!("Update available: {}", update.latest_version());
                // Trigger auto-update
                let _ = update.download_and_install().await;
            }
        }
        Err(e) => {
            eprintln!("Update check failed: {}", e);
        }
    }
}
```

**Frontend (TypeScript/Svelte):**

```typescript
// src/lib/updateStore.ts
import { writable } from 'svelte/store';
import { invoke } from '@tauri-apps/api/tauri';
import { relaunch } from '@tauri-apps/api/process';

export const updateAvailable = writable(false);
export const updateDownloading = writable(false);

export async function checkForUpdates() {
  try {
    const available = await invoke<boolean>('check_for_updates');
    updateAvailable.set(available);
    return available;
  } catch (error) {
    console.error('Failed to check for updates:', error);
    return false;
  }
}

export async function installUpdate() {
  try {
    updateDownloading.set(true);
    await invoke('install_update');
    await relaunch();
  } catch (error) {
    console.error('Failed to install update:', error);
    updateDownloading.set(false);
  }
}
```

---

## SECURITY BEST PRACTICES

### Signature Verification

Ensure update integrity and authenticity.

**Implementation:**

```javascript
const crypto = require('crypto');
const fs = require('fs');

class SignatureVerifier {
  constructor(publicKeyPath) {
    this.publicKey = fs.readFileSync(publicKeyPath, 'utf-8');
  }

  // Verify Ed25519 signature
  verifyEdDSA(updatePath, signature) {
    const nacl = require('tweetnacl');
    const updateBuffer = fs.readFileSync(updatePath);
    const pubKeyBuffer = Buffer.from(this.publicKey.replace(/-----.*/g, '').replace(/\n/g, ''), 'base64');
    const signatureBuffer = Buffer.from(signature, 'base64');

    return nacl.sign.detached.verify(updateBuffer, signatureBuffer, pubKeyBuffer);
  }

  // Verify RSA-SHA256 signature (legacy)
  verifyRSA(updatePath, signature) {
    const updateBuffer = fs.readFileSync(updatePath);
    const verifier = crypto.createVerify('RSA-SHA256');
    verifier.update(updateBuffer);
    return verifier.verify(this.publicKey, Buffer.from(signature, 'base64'));
  }

  // Verify HMAC-SHA256
  verifyHMAC(updatePath, signature, secret) {
    const updateBuffer = fs.readFileSync(updatePath);
    const computed = crypto
      .createHmac('sha256', secret)
      .update(updateBuffer)
      .digest('base64');
    return computed === signature;
  }
}

// Usage
const verifier = new SignatureVerifier('/path/to/public.key');

try {
  const isValid = verifier.verifyEdDSA(
    '/path/to/update.zip',
    'SIGNATURE_FROM_SERVER'
  );

  if (!isValid) {
    throw new Error('Signature verification failed');
  }

  console.log('Update verified successfully');
} catch (error) {
  console.error('Verification failed:', error.message);
  // Abort update
}
```

### HTTPS Enforcement

Always use HTTPS for update downloads.

```javascript
// Enforce HTTPS
const updateConfig = {
  // ✓ Good - HTTPS
  feedUrl: 'https://updates.example.com/releases',
  downloadUrl: 'https://releases.example.com/app.zip',

  // ✗ Bad - HTTP
  // feedUrl: 'http://updates.example.com/releases',
};

// Validate URLs at startup
function validateUpdateUrls(config) {
  const requiredFields = ['feedUrl', 'downloadUrl'];

  for (const field of requiredFields) {
    const url = config[field];

    if (!url) {
      throw new Error(`Missing required field: ${field}`);
    }

    if (!url.startsWith('https://')) {
      throw new Error(`${field} must use HTTPS: ${url}`);
    }
  }
}

// Implement certificate pinning
const https = require('https');
const tls = require('tls');

const pinnedCert = `-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAJC1/iNAZwqDMA0GCSqGSIb3...
-----END CERTIFICATE-----`;

const httpsAgent = new https.Agent({
  ca: [pinnedCert],
  checkServerIdentity: (servername, cert) => {
    // Verify certificate matches pinned cert
    const certFingerprint = crypto
      .createHash('sha256')
      .update(cert.raw)
      .digest('hex');

    const pinnedFingerprint = crypto
      .createHash('sha256')
      .update(pinnedCert)
      .digest('hex');

    if (certFingerprint !== pinnedFingerprint) {
      throw new Error('Certificate mismatch - possible MITM attack');
    }
  }
});

// Use pinned certificate for update downloads
https.get(updateUrl, { agent: httpsAgent }, (res) => {
  // Handle response
});
```

### Checksum Validation

Verify file integrity after download.

```javascript
const crypto = require('crypto');
const fs = require('fs');

class ChecksumValidator {
  static calculateHash(filePath, algorithm = 'sha256') {
    return new Promise((resolve, reject) => {
      const hash = crypto.createHash(algorithm);
      const stream = fs.createReadStream(filePath);

      stream.on('error', reject);
      stream.on('data', data => hash.update(data));
      stream.on('end', () => resolve(hash.digest('hex')));
    });
  }

  static async verifyChecksum(filePath, expectedChecksum, algorithm = 'sha256') {
    try {
      const calculatedChecksum = await this.calculateHash(filePath, algorithm);

      if (calculatedChecksum.toLowerCase() !== expectedChecksum.toLowerCase()) {
        throw new Error(
          `Checksum mismatch!\nExpected: ${expectedChecksum}\nActual: ${calculatedChecksum}`
        );
      }

      console.log(`✓ Checksum verified: ${calculatedChecksum}`);
      return true;
    } catch (error) {
      console.error('Checksum verification failed:', error.message);
      throw error;
    }
  }

  // Multiple hashing for redundancy
  static async verifyMultipleChecksums(filePath, checksums) {
    for (const [algorithm, expectedHash] of Object.entries(checksums)) {
      await this.verifyChecksum(filePath, expectedHash, algorithm);
    }
    return true;
  }
}

// Usage
async function downloadAndVerifyUpdate(downloadUrl, checksums) {
  const downloadPath = '/tmp/update.zip';

  // Download file
  await downloadFile(downloadUrl, downloadPath);

  // Verify multiple checksums
  try {
    await ChecksumValidator.verifyMultipleChecksums(downloadPath, {
      sha256: checksums.sha256,
      sha512: checksums.sha512
    });
    console.log('Update file verified successfully');
  } catch (error) {
    fs.unlinkSync(downloadPath); // Delete corrupted file
    throw error;
  }
}
```

---

## TESTING & ROLLBACK

### Testing Update Process

Simulate and test updates in development.

```javascript
// test-update.js
const { autoUpdater } = require('electron-updater');
const path = require('path');

// Configure test update server
autoUpdater.setFeedURL({
  provider: 'generic',
  url: 'http://localhost:3000/updates'
});

// Create mock update server
const express = require('express');
const app = express();

app.get('/updates/:platform/:version', (req, res) => {
  const { version } = req.params;

  if (version === '1.0.0') {
    // Provide test update
    res.json({
      version: '1.0.1',
      files: [{
        url: 'http://localhost:3000/app-1.0.1.zip',
        sha512: 'test-hash'
      }],
      releaseDate: new Date().toISOString(),
      releaseNotes: 'Test update'
    });
  } else {
    res.json({ version: 'no-update' });
  }
});

app.use(express.static('test-releases'));

const server = app.listen(3000, () => {
  console.log('Mock update server running on port 3000');
});

// Test update check
autoUpdater.checkForUpdates().then(result => {
  console.log('Update check result:', result);

  if (result?.updateInfo) {
    console.log('✓ Update available:', result.updateInfo.version);
  } else {
    console.log('✗ No update available');
  }
});

autoUpdater.on('error', err => {
  console.error('Update error:', err);
  server.close();
  process.exit(1);
});
```

### Monitoring & Metrics

Track update success rates and issues.

```javascript
// metrics.js
const fs = require('fs');
const path = require('path');

class UpdateMetrics {
  constructor(metricsPath) {
    this.metricsPath = metricsPath;
    this.data = this.loadMetrics();
  }

  loadMetrics() {
    try {
      return JSON.parse(fs.readFileSync(this.metricsPath, 'utf-8'));
    } catch {
      return {
        checksStarted: 0,
        checksSuccessful: 0,
        updatesAvailable: 0,
        updatesCompleted: 0,
        updatesFailed: 0,
        errors: []
      };
    }
  }

  saveMetrics() {
    fs.writeFileSync(this.metricsPath, JSON.stringify(this.data, null, 2));
  }

  recordCheckStarted() {
    this.data.checksStarted++;
    this.saveMetrics();
  }

  recordCheckSuccessful() {
    this.data.checksSuccessful++;
    this.saveMetrics();
  }

  recordUpdateAvailable() {
    this.data.updatesAvailable++;
    this.saveMetrics();
  }

  recordUpdateCompleted() {
    this.data.updatesCompleted++;
    this.saveMetrics();
  }

  recordUpdateFailed(error) {
    this.data.updatesFailed++;
    this.data.errors.push({
      timestamp: new Date().toISOString(),
      message: error.message,
      stack: error.stack
    });
    this.saveMetrics();
  }

  getMetrics() {
    return {
      ...this.data,
      successRate: this.data.checksSuccessful / this.data.checksStarted || 0,
      updateCompletionRate: this.data.updatesCompleted / this.data.updatesAvailable || 0
    };
  }
}

module.exports = UpdateMetrics;
```

---

## CONCLUSION

Implementing robust auto-update mechanisms requires careful consideration of:

1. **Framework Selection**: Choose based on platform requirements and distribution strategy
2. **Update Strategy**: Balance between binary size, complexity, and user experience
3. **Distribution**: Leverage CDNs and package managers for reliability
4. **Security**: Always verify signatures, use HTTPS, and validate checksums
5. **Testing**: Thoroughly test update process before deployment
6. **Monitoring**: Track metrics to catch issues early

Keep your update system simple, secure, and reliable to ensure users always have the latest version.

---

*Last Updated: November 15, 2025*
