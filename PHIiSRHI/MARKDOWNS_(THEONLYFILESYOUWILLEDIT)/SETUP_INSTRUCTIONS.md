# VS Code Setup for WoW Addon Development
*Complete Installation and Configuration Guide*

---

## Part 1: Install Required Software

### 1. Visual Studio Code
**Download and install VS Code:**
- Visit: https://code.visualstudio.com/
- Download the Windows installer
- Run installer with default settings
- Launch VS Code after installation

---

### 2. Lua 5.1 Installation (Windows)

**Option A: Using Chocolatey (Recommended)**
```powershell
# Install Chocolatey (if not already installed)
# Run PowerShell as Administrator:
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Lua 5.1
choco install lua --version=5.1.5 -y

# Verify installation
lua5.1 -v
```

**Option B: Manual Installation**
1. Download Lua binaries from: http://luabinaries.sourceforge.net/
2. Download: `lua-5.1.5_Win64_bin.zip`
3. Extract to: `C:\Program Files\Lua\5.1\`
4. Add to PATH:
   - Open System Properties → Environment Variables
   - Edit `Path` variable
   - Add: `C:\Program Files\Lua\5.1`
5. Restart terminal and verify: `lua5.1 -v`

---

### 3. LuaRocks Installation

**Download and Install:**
```powershell
# Download LuaRocks installer
# Visit: https://luarocks.org/releases/

# Or use Chocolatey:
choco install luarocks -y

# Verify installation
luarocks --version
```

---

### 4. Install Lua Development Tools

**Install LuaCheck (Linter):**
```powershell
luarocks install luacheck
```

**Install Busted (Testing Framework):**
```powershell
luarocks install busted
```

**Install LuaFileSystem (Optional but recommended):**
```powershell
luarocks install luafilesystem
```

**Verify installations:**
```powershell
luacheck --version
busted --version
```

---

## Part 2: Install VS Code Extensions

### Required Extensions

**1. Lua Language Server**
- Extension ID: `sumneko.lua`
- Install via VS Code:
  ```
  Ctrl+Shift+X → Search "Lua" → Install "Lua" by sumneko
  ```
- Or via command line:
  ```powershell
  code --install-extension sumneko.lua
  ```

**2. Code Spell Checker**
- Extension ID: `streetsidesoftware.code-spell-checker`
- Install:
  ```powershell
  code --install-extension streetsidesoftware.code-spell-checker
  ```

**3. Lua Debug**
- Extension ID: `actboy168.lua-debug`
- Install:
  ```powershell
  code --install-extension actboy168.lua-debug
  ```

**4. Better Comments (Optional)**
- Extension ID: `aaron-bond.better-comments`
- Install:
  ```powershell
  code --install-extension aaron-bond.better-comments
  ```

**5. Bracket Pair Colorizer (Optional)**
- Extension ID: `CoenraadS.bracket-pair-colorizer-2`
- Install:
  ```powershell
  code --install-extension CoenraadS.bracket-pair-colorizer-2
  ```

**6. Error Lens (Optional)**
- Extension ID: `usernamehw.errorlens`
- Install:
  ```powershell
  code --install-extension usernamehw.errorlens
  ```

**7. XML (for embeds.xml files)**
- Extension ID: `redhat.vscode-xml`
- Install:
  ```powershell
  code --install-extension redhat.vscode-xml
  ```

---

## Part 3: Verify Configuration Files

The following files should already be created in your workspace:

### Configuration Files Checklist
- ✅ [.vscode/settings.json](.vscode/settings.json) - VS Code workspace settings
- ✅ [.vscode/launch.json](.vscode/launch.json) - Debugging configuration
- ✅ [.vscode/tasks.json](.vscode/tasks.json) - Build tasks
- ✅ [.luacheckrc](.luacheckrc) - Luacheck linter configuration

---

## Part 4: Configure WoW AddOns Path

### Update settings.json with your WoW installation path

1. Open [.vscode/settings.json](.vscode/settings.json)
2. Find the `Lua.workspace.library` setting
3. Update the path to match your WoW installation:

```json
"Lua.workspace.library": [
    "${workspaceFolder}/_WoWAPI",
    "C:/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns",
    // OR for non-retail:
    "C:/Program Files (x86)/World of Warcraft/_classic_/Interface/AddOns"
]
```

**Common WoW Installation Paths:**
- Default (Battle.net): `C:/Program Files (x86)/World of Warcraft/`
- Custom installations: Check your Battle.net app settings
- Steam: `C:/Program Files (x86)/Steam/steamapps/common/World of Warcraft/`

---

## Part 5: Create WoW API Stub File

Create a stub file for better IntelliSense:

1. The `_WoWAPI` stub file will be created in the next step
2. This provides autocomplete for WoW-specific functions

---

## Part 6: Test Your Setup

### 1. Test Lua Installation
```powershell
# Open terminal in VS Code (Ctrl+`)
lua5.1 -v
# Should output: Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
```

### 2. Test LuaCheck
```powershell
luacheck --version
# Should output: Luacheck: 0.x.x
```

### 3. Test VS Code Lua Extension
1. Create a test file: `test.lua`
2. Type: `print("Hello WoW")`
3. You should see syntax highlighting and autocomplete

### 4. Test Linting
```powershell
# Run linting task
# Press: Ctrl+Shift+P
# Type: "Tasks: Run Task"
# Select: "Lint Addon with Luacheck"
```

---

## Part 7: Quick Reference Commands

### VS Code Shortcuts
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+Shift+X` - Extensions
- `Ctrl+`` - Toggle Terminal
- `Ctrl+Shift+B` - Run Build Task
- `F5` - Start Debugging
- `Ctrl+Shift+F` - Find in Files

### Task Shortcuts
- `Ctrl+Shift+B` - Default build task (Package Addon)
- `Ctrl+Shift+T` - Default test task (Lint with Luacheck)

### Available Tasks (Access via Ctrl+Shift+P → "Tasks: Run Task")
1. **Lint Addon with Luacheck** - Run code quality checks
2. **Check Lua Syntax** - Verify syntax of current file
3. **Package Addon for Distribution** - Create distributable package
4. **Copy to WoW AddOns Folder** - Deploy to WoW directory
5. **Generate TOC File** - Auto-generate .toc file
6. **Run All Tests** - Execute test suite
7. **Open WoW AddOn Folder** - Quick access to AddOns directory

---

## Part 8: Troubleshooting

### Issue: Lua command not found
**Solution:**
- Verify Lua is in your PATH
- Restart VS Code
- Run: `$env:Path` in PowerShell to check PATH

### Issue: Luacheck not found
**Solution:**
```powershell
# Reinstall luacheck
luarocks install luacheck --force

# Verify installation
where luacheck
```

### Issue: Extensions not working
**Solution:**
- Reload VS Code: `Ctrl+Shift+P` → "Reload Window"
- Reinstall extensions
- Check VS Code output: `Ctrl+Shift+U`

### Issue: WoW API autocomplete not working
**Solution:**
- Verify `Lua.workspace.library` path in settings.json
- Create `_WoWAPI` stub folder (next step)
- Reload window

### Issue: Tasks not running
**Solution:**
- Verify PowerShell execution policy:
  ```powershell
  Get-ExecutionPolicy
  # If restricted, run:
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
  ```

---

## Next Steps

1. ✅ Complete this setup guide
2. ⏭️ Create WoW API stub files for better IntelliSense
3. ⏭️ Create your first addon structure
4. ⏭️ Build sample addons using templates from the guide

---

## Additional Resources

### Official Documentation
- **VS Code Lua Docs**: https://marketplace.visualstudio.com/items?itemName=sumneko.lua
- **Luacheck Docs**: https://luacheck.readthedocs.io/
- **WoW API**: https://wowprogramming.com/docs/

### Community Resources
- **WoW Interface Forums**: https://www.wowinterface.com/forums/
- **WoW Pedia**: https://wowpedia.fandom.com/
- **CurseForge**: https://www.curseforge.com/wow/addons

### Learning Resources
- **Lua 5.1 Reference**: https://www.lua.org/manual/5.1/
- **WoW Addon Tutorial**: https://wowprogramming.com/tutorial.html
- **GitHub WoW Addons**: Search for popular addons as examples

---

**Setup Complete!** Your VS Code environment is now ready for WoW addon development.
