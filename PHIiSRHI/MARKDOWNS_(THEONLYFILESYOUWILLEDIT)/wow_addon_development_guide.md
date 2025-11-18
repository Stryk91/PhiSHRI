# World of Warcraft Addon Development Codex
*Complete Visual Studio Code Setup and Development Environment Guide*

---

## 1. VS Code Setup & Extensions

### Purpose
This section covers the essential Visual Studio Code configuration for professional World of Warcraft addon development, focusing on Lua programming, debugging, and WoW-specific tooling.

### Essential VS Code Extensions for Lua Development

#### 1. Lua Language Support
**Extension:** `sumneko.lua` (now `Lua.wolf`)
- **Installation:** Search "Lua" in VS Code extensions marketplace
- **Features:** 
  - Advanced IntelliSense for Lua
  - Syntax highlighting and error detection
  - Code completion for WoW API functions
  - Real-time linting and type checking

**Configuration:**
```json
{
    "Lua.workspace.library": [
        "C:/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns"
    ],
    "Lua.diagnostics.globals": [
        "GameTooltip",
        "CreateFrame",
        "UnitHealth",
        "UnitMana",
        "GetSpellInfo",
        "CastSpellByName"
    ],
    "Lua.runtime.version": "Lua 5.1",
    "Lua.workspace.preloadFileSize": 1000
}
```

#### 2. Code Formatting Tools
**Extension:** `streetsidesoftware.code-spell-checker`
- **Purpose:** Spell checking for addon names, descriptions, and user-facing text
- **Configuration:** Add WoW-specific terms to dictionary

**Extension:** `esbenp.prettier-vscode` (with Lua support)
- **Installation:** Requires additional Lua parser
- **Setup Command:** `npm install -g prettier`

```json
{
    "[lua]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true
    }
}
```

#### 3. Linting and Quality Assurance
**Extension:** `dcbakker.lua-linter`
- **Features:** Real-time syntax checking
- **Supported Linters:** luac, luacheck

**Luacheck Setup:**
```bash
# Install luacheck globally
luarocks install luacheck

# Create .luacheckrc in project root
ignore = { "631" } -- ignore unused fields
max_line_length = 120
```

**.luacheckrc Configuration:**
```lua
-- WoW Addon specific luacheck configuration
ignore = {
    "211", -- unused variable
    "212", -- unused argument
    "213", -- unused loop variable
    "631", -- unused fields (common in WoW API)
}

-- Define WoW global variables
globals = {
    "GameTooltip", "CreateFrame", "UnitHealth", "UnitMana",
    "GetSpellInfo", "CastSpellByName", "DEFAULT_CHAT_FRAME",
    "print", "InterfaceOptions_AddCategory", "StaticPopup_Show"
}
```

### WoW-Specific Addon Development Extensions

#### 1. WoW API Integration
**Extension:** `WoW-API-IntelliSense` (community extension)
- **Features:** Complete WoW API autocomplete
- **Setup:** Requires manual WoW API database installation

**Alternative: Manual API Setup**
```lua
-- Create _WoWAPI.lua in your workspace
-- Add this to your workspace settings
_G.WoWAPI = {
    -- Common WoW globals will be defined here
    GameTooltip = {},
    CreateFrame = function() end,
    UnitHealth = function() return 0 end,
    -- Add more as needed
}
```

#### 2. Addon Project Templates
**Extension:** `ms-vscode.vscode-json` (for .toc files)
- **Purpose:** Syntax highlighting for TOC (Table of Contents) files

**TOC File Association:**
```json
{
    "files.associations": {
        "*.toc": "plaintext"
    },
    "emmet.includeLanguages": {
        "toc": "html"
    }
}
```

### Debugging Extensions

#### 1. Debug Adapter Protocol for Lua
**Extension:** `actboy168.lua-debug`
- **Setup Requirements:**
  1. Install Lua debugger: `luarocks install mobdebug`
  2. Configure launch settings

**launch.json Configuration:**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug WoW Addon",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/main.lua",
            "cwd": "${workspaceFolder}",
            "stopOnEntry": false,
            "sourceMaps": true,
            "luaVersion": "5.1"
        }
    ]
}
```

#### 2. WoW-Specific Debugging Setup
**Create debug framework:**
```lua
-- debug.lua - Add to your addon for debugging
local Debug = {}
Debug.enabled = false
Debug.output = DEFAULT_CHAT_FRAME

function Debug.enable()
    Debug.enabled = true
    print("Debug mode enabled")
end

function Debug.disable()
    Debug.enabled = false
    print("Debug mode disabled")
end

function Debug.log(message, ...)
    if not Debug.enabled then return end
    
    local formatted = string.format(message, ...)
    if Debug.output then
        Debug.output:AddMessage("[DEBUG] " .. formatted)
    end
end

function Debug.printTable(t, indent)
    if not Debug.enabled or not t then return end
    
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            Debug.log(indent .. tostring(k) .. ":")
            Debug.printTable(v, indent .. "  ")
        else
            Debug.log(indent .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

_G.Debug = Debug
```

### Workspace Configuration

#### 1. Project Structure Setup
```
MyAddon/
├── .vscode/
│   ├── settings.json
│   ├── launch.json
│   └── tasks.json
├── src/
│   ├── core/
│   ├── ui/
│   └── modules/
├── locales/
├── embeds.xml
├── MyAddon.toc
└── README.md
```

#### 2. Tasks Configuration (tasks.json)
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Addon",
            "type": "shell",
            "command": "lua",
            "args": [
                "build.lua",
                "${workspaceFolder}"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Lint Addon",
            "type": "shell",
            "command": "luacheck",
            "args": [
                "src/",
                "--globals",
                "GameTooltip,CreateFrame,UnitHealth"
            ],
            "group": "test"
        }
    ]
}
```

### Installation Instructions

#### 1. VS Code Setup
1. Install Visual Studio Code from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install Lua extension from the marketplace
3. Configure Lua workspace settings for WoW API

#### 2. Lua Toolchain Installation
```bash
# Install Lua 5.1 (WoW version)
sudo apt-get install lua5.1

# Install LuaRocks package manager
sudo apt-get install luarocks

# Install essential tools
luarocks install luacheck
luarocks install luacheck
luarocks install busted  -- for testing
```

#### 3. WoW Development Environment
1. Navigate to WoW AddOns directory
2. Create development folder structure
3. Set up symbolic links for easier development:
```bash
# Example on Windows
mklink /D "C:\WoW-Dev\MyAddon" "C:\Games\World of Warcraft\_retail_\Interface\AddOns\MyAddon"
```

---

## 2. Lua Development Resources

### Purpose
This section provides essential Lua development resources specifically tailored for World of Warcraft addon development, including code snippets, templates, and best practices.

### Code Snippet Libraries for Common WoW Addon Patterns

#### 1. Addon Initialization Pattern
```lua
-- Standard addon initialization template
local ADDON_NAME, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)

-- Addon namespace
Addon.name = ADDON_NAME
Addon.version = GetAddOnMetadata(ADDON_NAME, "Version")

-- Initialize addon
function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AddonDB", defaults, true)
    
    -- Register options
    self:SetupOptions()
    
    -- Initialize modules
    self:InitializeModules()
    
    print(format("|cffFF6600%s|r v%s loaded", ADDON_NAME, Addon.version))
end

-- Event registration
function Addon:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end
```

#### 2. Event Handler Pattern
```lua
-- Event handler template
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
    if Addon[event] then
        Addon[event](Addon, event, ...)
    end
end)

-- Register events
local function RegisterEvents(events)
    for event in pairs(events) do
        EventFrame:RegisterEvent(event)
    end
end

-- Example event handlers
function Addon:PLAYER_LOGIN()
    -- Initialize player-specific data
    self.playerName = UnitName("player")
    self.playerClass = UnitClass("player")
    self:LoadSettings()
end

function Addon:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        local spellId, spellName, spellSchool = select(9, ...)
        self:OnSpellCast(sourceGUID, spellId, spellName)
    end
end
```

#### 3. Configuration Management Pattern
```lua
-- Default settings structure
local defaults = {
    profile = {
        enabled = true,
        debug = false,
        position = {
            point = "CENTER",
            x = 0,
            y = 0
        },
        appearance = {
            scale = 1.0,
            alpha = 1.0,
            locked = false
        },
        modules = {
            combat = true,
            ui = true,
            alerts = true
        }
    }
}

-- Settings management
function Addon:GetSetting(key)
    local keys = {}
    for k in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k)
    end
    
    local value = self.db.profile
    for i, k in ipairs(keys) do
        value = value[k]
        if not value then break end
    end
    
    return value
end

function Addon:SetSetting(key, value)
    local keys = {}
    for k in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k)
    end
    
    local target = self.db.profile
    for i = 1, #keys - 1 do
        target = target[keys[i]]
    end
    
    target[keys[#keys]] = value
end
```

### Template Structures for Different Addon Types

#### 1. UI-Focused Addon Template
```lua
-- UI Addon Template
local Addon = {}
Addon.frames = {}
Addon.buttons = {}

-- Create main frame
function Addon:CreateMainFrame()
    local frame = CreateFrame("Frame", "AddonMainFrame", UIParent)
    frame:SetSize(200, 150)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Make frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    self.frames.main = frame
    return frame
end

-- Create button template
function Addon:CreateButton(parent, text, onClick, width, height)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, height or 25)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    
    return button
end

-- Initialize UI
function Addon:InitializeUI()
    local mainFrame = self:CreateMainFrame()
    
    -- Add title
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", mainFrame, "TOP", 0, -20)
    title:SetText("Addon Title")
    
    -- Add buttons
    local button1 = self:CreateButton(mainFrame, "Button 1", function()
        print("Button 1 clicked!")
    end)
    button1:SetPoint("TOP", title, "BOTTOM", 0, -20)
    
    local button2 = self:CreateButton(mainFrame, "Button 2", function()
        self:ToggleWindow()
    end)
    button2:SetPoint("TOP", button1, "BOTTOM", 0, -10)
    
    self.buttons.main1 = button1
    self.buttons.main2 = button2
end
```

#### 2. Combat Addon Template
```lua
-- Combat Addon Template
local Addon = {}
Addon.combat = {}
Addon.spells = {}
Addon.abilities = {}

-- Spell data management
function Addon:RegisterSpell(spellId, spellName, cooldown, category)
    self.spells[spellId] = {
        id = spellId,
        name = spellName,
        cooldown = cooldown,
        category = category,
        lastUsed = 0
    }
end

-- Combat state tracking
function Addon:OnCombatStart()
    self.combat.active = true
    self.combat.startTime = GetTime()
    self.combat.enemies = {}
    self:ResetCooldowns()
    
    print("Combat started!")
end

function Addon:OnCombatEnd()
    self.combat.active = false
    self.combat.endTime = GetTime()
    self.combat.duration = self.combat.endTime - self.combat.startTime
    
    print(format("Combat ended! Duration: %.2f seconds", self.combat.duration))
end

-- Cooldown tracking
function Addon:TrackCooldown(spellId)
    local spell = self.spells[spellId]
    if not spell then return end
    
    local currentTime = GetTime()
    spell.lastUsed = currentTime
    
    -- Schedule cooldown end notification
    C_Timer.After(spell.cooldown, function()
        self:OnCooldownReady(spell)
    end)
end

function Addon:OnCooldownReady(spell)
    -- Notify that cooldown is ready
    self:ShowCooldownNotification(spell)
end

-- Rotation helper
function Addon:GetNextAction()
    local currentTime = GetTime()
    local bestAction = nil
    local bestPriority = 0
    
    for spellId, spell in pairs(self.spells) do
        if self:CanCastSpell(spell, currentTime) then
            local priority = self:GetSpellPriority(spell)
            if priority > bestPriority then
                bestPriority = priority
                bestAction = spell
            end
        end
    end
    
    return bestAction
end

function Addon:CanCastSpell(spell, currentTime)
    -- Check if spell is ready
    local cooldownRemaining = spell.lastUsed + spell.cooldown - currentTime
    if cooldownRemaining > 0 then return false end
    
    -- Check mana/energy requirements
    local spellInfo = GetSpellInfo(spell.id)
    if spellInfo then
        local cost = GetSpellPowerCost(spell.id)
        -- Additional checks based on resources
    end
    
    return true
end
```

#### 3. Automation Addon Template
```lua
-- Automation Addon Template
local Addon = {}
Addon.automation = {}
Addon.tasks = {}
Addon.schedules = {}

-- Task management
function Addon:RegisterTask(name, func, interval, condition)
    self.tasks[name] = {
        name = name,
        func = func,
        interval = interval or 1.0,
        condition = condition or function() return true end,
        lastRun = 0
    }
end

function Addon:UnregisterTask(name)
    self.tasks[name] = nil
end

-- Schedule system
function Addon:Schedule(time, func)
    local schedule = {
        time = time,
        func = func,
        id = #self.schedules + 1
    }
    table.insert(self.schedules, schedule)
    return schedule.id
end

function Addon:ProcessSchedules()
    local currentTime = GetTime()
    local activeSchedules = {}
    
    for i, schedule in ipairs(self.schedules) do
        if currentTime >= schedule.time then
            schedule.func()
        else
            table.insert(activeSchedules, schedule)
        end
    end
    
    self.schedules = activeSchedules
end

-- Auto-processing loop
function Addon:ProcessAutomation()
    local currentTime = GetTime()
    
    -- Process scheduled tasks
    self:ProcessSchedules()
    
    -- Process recurring tasks
    for name, task in pairs(self.tasks) do
        if currentTime - task.lastRun >= task.interval and task.condition() then
            task.func()
            task.lastRun = currentTime
        end
    end
end

-- Example automation tasks
function Addon:RegisterDefaultTasks()
    -- Health monitoring
    self:RegisterTask("healthMonitor", function()
        local health = UnitHealth("player")
        local maxHealth = UnitHealthMax("player")
        local healthPercent = (health / maxHealth) * 100
        
        if healthPercent < 30 then
            self:TriggerLowHealthAlert()
        end
    end, 1.0)
    
    -- Buff monitoring
    self:RegisterTask("buffMonitor", function()
        self:CheckImportantBuffs()
    end, 2.0)
    
    -- Auto-repair
    self:RegisterTask("autoRepair", function()
        if self:IsAtVendor() then
            self:RepairItems()
        end
    end, 5.0)
end
```

### Best Practices for Writing Clean, Maintainable Lua Code for WoW

#### 1. Code Organization Standards
```lua
-- File: MyAddon/Core/Constants.lua
local ADDON_NAME, Addon = ...

-- Constants should be in ALL_CAPS
Addon.Constants = {
    -- Addon metadata
    ADDON_NAME = ADDON_NAME,
    VERSION = GetAddOnMetadata(ADDON_NAME, "Version"),
    
    -- Event names
    EVENTS = {
        PLAYER_LOGIN = "PLAYER_LOGIN",
        COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED",
        UNIT_SPELLCAST_SUCCEEDED = "UNIT_SPELLCAST_SUCCEEDED",
    },
    
    -- Spell IDs (avoid using string names)
    SPELLS = {
        POWER_WORD_FORTITUDE = 1243,
        RENEW = 139,
        FLASH_HEAL = 2061,
    },
    
    -- Configuration limits
    MAX_PLAYERS_TRACKED = 40,
    UPDATE_INTERVAL = 0.1,
    
    -- Colors
    COLORS = {
        CLASS = {
            PRIEST = { r = 1.0, g = 1.0, b = 1.0 },
            WARRIOR = { r = 0.78, g = 0.61, b = 0.43 },
            MAGE = { r = 0.41, g = 0.8, b = 0.94 },
        }
    }
}
```

#### 2. Error Handling and Debugging
```lua
-- File: MyAddon/Core/ErrorHandling.lua
local ADDON_NAME, Addon = ...

-- Error handling utilities
Addon.ErrorHandling = {}

function Addon.ErrorHandling.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        local errorMsg = format("[%s] Error: %s", ADDON_NAME, result)
        print(errorMsg)
        return nil
    end
    return result
end

function Addon.ErrorHandling.ValidateType(value, expectedType, name)
    if type(value) ~= expectedType then
        error(format("Expected %s for %s, got %s", expectedType, name, type(value)))
        return false
    end
    return true
end

function Addon.ErrorHandling.Assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

-- Usage examples
function Addon:ProcessPlayerData(playerName)
    -- Validate input
    self.ErrorHandling.ValidateType(playerName, "string", "playerName")
    self.ErrorHandling.Assert(#playerName > 0, "Player name cannot be empty")
    
    -- Safe function call
    return self.ErrorHandling.SafeCall(function()
        return self:DoComplexProcessing(playerName)
    end)
end
```

#### 3. Performance Optimization Patterns
```lua
-- File: MyAddon/Core/Performance.lua
local ADDON_NAME, Addon = ...

-- Performance optimization utilities
Addon.Performance = {}

-- Object pooling for frequently created/destroyed objects
function Addon.Performance.CreatePool(createFunc, resetFunc)
    local pool = {
        objects = {},
        inUse = {},
        create = createFunc,
        reset = resetFunc
    }
    
    function pool:Acquire()
        local obj
        if #self.objects > 0 then
            obj = table.remove(self.objects)
        else
            obj = self.create()
        end
        table.insert(self.inUse, obj)
        return obj
    end
    
    function pool:Release(obj)
        for i, usedObj in ipairs(self.inUse) do
            if usedObj == obj then
                table.remove(self.inUse, i)
                break
            end
        end
        
        if self.reset then
            self.reset(obj)
        end
        table.insert(self.objects, obj)
    end
    
    return pool
end

-- Throttled updates to prevent excessive processing
function Addon.Performance.CreateThrottler(interval, func)
    local lastUpdate = 0
    
    return function(...)
        local currentTime = GetTime()
        if currentTime - lastUpdate >= interval then
            lastUpdate = currentTime
            return func(...)
        end
    end
end

-- Cached API calls
function Addon.Performance.CreateCache(ttl)
    local cache = {}
    local timestamps = {}
    
    return function(key, computeFunc)
        local currentTime = GetTime()
        
        -- Check if cache is valid
        if cache[key] and timestamps[key] and (currentTime - timestamps[key]) < ttl then
            return cache[key]
        end
        
        -- Compute and cache new value
        local value = computeFunc()
        cache[key] = value
        timestamps[key] = currentTime
        return value
    end
end

-- Usage examples
local framePool = Addon.Performance.CreatePool(
    function() return CreateFrame("Frame") end,
    function(frame) 
        frame:Hide()
        frame:ClearAllPoints()
        frame:SetParent(nil)
    end
)

local throttledUpdate = Addon.Performance.CreateThrottler(0.1, function()
    Addon:UpdateDisplay()
end)

local spellInfoCache = Addon.Performance.CreateCache(300, function(spellId)
    return GetSpellInfo(spellId)
end)
```

#### 4. Memory Management Best Practices
```lua
-- File: MyAddon/Core/Memory.lua
local ADDON_NAME, Addon = ...

-- Memory management utilities
Addon.Memory = {}

-- Track memory usage
function Addon.Memory:GetMemoryUsage()
    UpdateAddOnMemoryUsage()
    return GetAddOnMemoryUsage(ADDON_NAME)
end

-- Clean up references
function Addon.Memory:CleanupReferences(obj, visited)
    visited = visited or {}
    obj = obj or _G
    
    for key, value in pairs(obj) do
        if type(value) == "table" and value ~= obj and not visited[value] then
            visited[value] = true
            
            -- Check for WoW-specific cleanup
            if value.GetObjectType then
                value:SetParent(nil)
                if value.ClearAllPoints then
                    value:ClearAllPoints()
                end
            end
            
            self:CleanupReferences(value, visited)
        end
    end
end

-- Memory usage monitoring
function Addon.Memory:StartMonitoring(interval)
    self.monitorTimer = self.monitorTimer or C_Timer.NewTicker(interval or 10, function()
        local memory = self:GetMemoryUsage()
        if memory > (self.lastMemory or 0) + 1000 then -- 1KB increase
            print(format("[Memory] Usage increased to %.2f KB", memory / 1024))
        end
        self.lastMemory = memory
    end)
end

function Addon.Memory:StopMonitoring()
    if self.monitorTimer then
        self.monitorTimer:Cancel()
        self.monitorTimer = nil
    end
end
```

### Documentation Resources and API References

#### 1. Essential Documentation Links
- **Official WoW API Documentation:** [WoW Programming Guide](https://wowprogramming.com/docs/)
- **Lua Reference Manual:** [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)
- **WoW UI Documentation:** [Interface Customization](https://wowpedia.fandom.com/wiki/Interface_customization)
- **Community Resources:** [WoW Interface Forums](https://www.wowinterface.com/forums/)

#### 2. API Reference Template
```lua
-- File: MyAddon/Core/APIReference.lua
local ADDON_NAME, Addon = ...

-- API wrapper with documentation
Addon.API = {}

-- Unit Information
-- Returns the current health of a unit
-- @param unitId string - Unit identifier ("player", "target", etc.)
-- @return number - Current health value
function Addon.API.GetUnitHealth(unitId)
    self.ErrorHandling.ValidateType(unitId, "string", "unitId")
    return UnitHealth(unitId)
end

-- Spell Information
-- Retrieves spell information by ID
-- @param spellId number - Spell identifier
-- @return table - Spell information {name, rank, icon, castTime, minRange, maxRange}
function Addon.API.GetSpellInfo(spellId)
    self.ErrorHandling.ValidateType(spellId, "number", "spellId")
    
    local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spellId)
    
    return {
        name = name,
        rank = rank,
        icon = icon,
        castTime = castTime,
        minRange = minRange,
        maxRange = maxRange
    }
end

-- Combat Log Parsing
-- Parses combat log events efficiently
-- @param timestamp number - Event timestamp
-- @param subEvent string - Combat log sub-event type
-- @param ... mixed - Additional event parameters
-- @return table - Parsed event data
function Addon.API.ParseCombatLogEvent(timestamp, subEvent, ...)
    local eventData = {
        timestamp = timestamp,
        subEvent = subEvent
    }
    
    -- Parse based on subEvent type
    if subEvent == "SPELL_CAST_SUCCESS" then
        local sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = select(4, ...)
        
        eventData.spellId = spellId
        eventData.spellName = spellName
        eventData.sourceGUID = sourceGUID
        eventData.sourceName = sourceName
        eventData.destGUID = destGUID
        eventData.destName = destName
        
    elseif subEvent == "SPELL_DAMAGE" then
        -- Parse damage events
        local sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...)
        
        eventData.spellId = spellId
        eventData.spellName = spellName
        eventData.amount = amount
        eventData.critical = critical
        eventData.destGUID = destGUID
        eventData.destName = destName
    end
    
    return eventData
end
```

---

## 3. WoW Addon Development Components

### Purpose
This section provides comprehensive code templates and examples for creating core WoW addon components, including UI elements, configuration systems, keybinding management, and combat assistance tools.

### Creating Visually Appealing and Accessible UI Elements

#### 1. Modern UI Framework Template
```lua
-- File: MyAddon/UI/Framework.lua
local ADDON_NAME, Addon = ...

-- Modern UI framework with accessibility features
Addon.UI = {}
Addon.UI.frames = {}
Addon.UI.themes = {}

-- Theme system
Addon.UI.themes.default = {
    background = {
        color = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 },
        texture = "Interface/DialogFrame/UI-DialogBox-Background"
    },
    border = {
        color = { r = 0.3, g = 0.3, b = 0.3, a = 1.0 },
        texture = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 16
    },
    fonts = {
        title = { font = "Fonts/FRIZQT__.TTF", size = 16, flags = "OUTLINE" },
        normal = { font = "Fonts/FRIZQT__.TTF", size = 12, flags = "" },
        small = { font = "Fonts/FRIZQT__.TTF", size = 10, flags = "" }
    },
    colors = {
        primary = { r = 0.2, g = 0.6, b = 1.0, a = 1.0 },
        secondary = { r = 0.8, g = 0.8, b = 0.8, a = 1.0 },
        success = { r = 0.2, g = 0.8, b = 0.2, a = 1.0 },
        warning = { r = 1.0, g = 0.8, b = 0.2, a = 1.0 },
        error = { r = 1.0, g = 0.2, b = 0.2, a = 1.0 }
    }
}

-- Create styled frame
function Addon.UI:CreateStyledFrame(name, parent, width, height, theme)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetSize(width or 200, height or 150)
    
    theme = theme or self.themes.default
    
    -- Apply theme
    frame:SetBackdrop({
        bgFile = theme.background.texture,
        edgeFile = theme.border.texture,
        tile = true, tileSize = 32, edgeSize = theme.border.edgeSize,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    frame:SetBackdropColor(theme.background.color.r, theme.background.color.g, 
                         theme.background.color.b, theme.background.color.a)
    frame:SetBackdropBorderColor(theme.border.color.r, theme.border.color.g, 
                               theme.border.color.b, theme.border.color.a)
    
    -- Add accessibility features
    frame:SetScript("OnEnter", function(self)
        if self.accessibilityText then
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText(self.accessibilityText, 1, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    return frame
end

-- Create accessible button
function Addon.UI:CreateButton(parent, text, onClick, width, height, theme)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 120, height or 25)
    button:SetScript("OnClick", onClick)
    
    theme = theme or self.themes.default
    
    -- Style
    button:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
    button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
    button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight", "ADD")
    
    -- Text
    local fontString = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontString:SetPoint("CENTER")
    fontString:SetText(text)
    button:SetFontString(fontString)
    
    -- Accessibility
    button.accessibilityText = text
    button:SetScript("OnEnter", function(self)
        if IsShiftKeyDown() then
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText(self.accessibilityText, 1, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    return button
end

-- Create progress bar
function Addon.UI:CreateProgressBar(parent, width, height, theme)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width or 200, height or 20)
    
    theme = theme or self.themes.default
    
    -- Background
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    
    -- Fill
    frame.fill = CreateFrame("StatusBar", nil, frame)
    frame.fill:SetAllPoints()
    frame.fill:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    frame.fill:SetStatusBarColor(theme.colors.primary.r, theme.colors.primary.g, 
                               theme.colors.primary.b, theme.colors.primary.a)
    frame.fill:SetMinMaxValues(0, 100)
    frame.fill:SetValue(0)
    
    -- Text
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.text:SetPoint("CENTER")
    frame.text:SetText("0%")
    
    -- Methods
    function frame:SetValue(value, max)
        max = max or 100
        local percentage = (value / max) * 100
        self.fill:SetValue(percentage)
        self.text:SetText(format("%d%%", percentage))
    end
    
    function frame:SetColor(r, g, b, a)
        self.fill:SetStatusBarColor(r, g, b, a or 1.0)
    end
    
    return frame
end
```

#### 2. Responsive UI System
```lua
-- File: MyAddon/UI/Responsive.lua
local ADDON_NAME, Addon = ...

-- Responsive design system
Addon.UI.Responsive = {}

-- Screen size detection
function Addon.UI.Responsive:GetScreenSize()
    local width, height = GetScreenWidth(), GetScreenHeight()
    
    -- Categorize screen sizes
    if width <= 1024 then
        return "small"
    elseif width <= 1440 then
        return "medium"
    elseif width <= 1920 then
        return "large"
    else
        return "ultrawide"
    end
end

-- Adaptive layout manager
function Addon.UI.Responsive:CreateLayoutManager(frame)
    local layout = {
        frame = frame,
        elements = {},
        currentSize = self:GetScreenSize()
    }
    
    function layout:AddElement(element, positions)
        self.elements[element] = positions or {}
        self:UpdateElementPosition(element)
    end
    
    function layout:UpdateElementPosition(element)
        local positions = self.elements[element]
        if not positions then return end
        
        local position = positions[self.currentSize] or positions.medium or positions.default
        if position then
            element:ClearAllPoints()
            element:SetPoint(position.point or "CENTER", 
                          position.relativeTo or self.frame,
                          position.relativePoint or "CENTER",
                          position.x or 0, position.y or 0)
            
            if position.width then element:SetWidth(position.width) end
            if position.height then element:SetHeight(position.height) end
            if position.scale then element:SetScale(position.scale) end
        end
    end
    
    function layout:UpdateLayout()
        local newSize = Addon.UI.Responsive:GetScreenSize()
        if newSize ~= self.currentSize then
            self.currentSize = newSize
            for element in pairs(self.elements) do
                self:UpdateElementPosition(element)
            end
        end
    end
    
    -- Auto-update on screen size change
    layout.updateTimer = C_Timer.NewTicker(1, function()
        layout:UpdateLayout()
    end)
    
    return layout
end

-- Usage example
function Addon.UI:CreateResponsiveWindow()
    local window = self:CreateStyledFrame("MyAddonWindow", UIParent, 300, 200)
    local layout = self.Responsive:CreateLayoutManager(window)
    
    -- Title text
    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetText("My Addon")
    
    -- Responsive positioning
    layout:AddElement(title, {
        small = { point = "TOP", x = 0, y = -10, scale = 0.8 },
        medium = { point = "TOP", x = 0, y = -15, scale = 1.0 },
        large = { point = "TOP", x = 0, y = -20, scale = 1.2 },
        ultrawide = { point = "TOP", x = 0, y = -25, scale = 1.4 }
    })
    
    return window
end
```

### Implementing CVar (Console Variable) Management and Profiles

#### 1. CVar Management System
```lua
-- File: MyAddon/Core/CVarManager.lua
local ADDON_NAME, Addon = ...

-- CVar management system
Addon.CVar = {}
Addon.CVar.watchedCVars = {}
Addon.CVar.originalValues = {}

-- Register CVar for monitoring
function Addon.CVar:Register(name, defaultValue, category)
    self.watchedCVars[name] = {
        name = name,
        defaultValue = defaultValue,
        currentValue = GetCVar(name) or defaultValue,
        category = category or "general",
        onChange = nil
    }
    
    -- Store original value
    self.originalValues[name] = GetCVar(name) or defaultValue
end

-- Set CVar with validation
function Addon.CVar:Set(name, value)
    local cvar = self.watchedCVars[name]
    if not cvar then
        error("CVar '" .. name .. "' is not registered")
        return false
    end
    
    -- Validate value type
    if type(value) ~= type(cvar.defaultValue) then
        error("Invalid type for CVar '" .. name .. "'. Expected " .. type(cvar.defaultValue))
        return false
    end
    
    local oldValue = GetCVar(name)
    SetCVar(name, tostring(value))
    cvar.currentValue = value
    
    -- Trigger change callback
    if cvar.onChange and oldValue ~= tostring(value) then
        cvar.onChange(oldValue, tostring(value))
    end
    
    return true
end

-- Get CVar value with type conversion
function Addon.CVar:Get(name)
    local cvar = self.watchedCVars[name]
    if not cvar then
        return GetCVar(name)
    end
    
    local value = GetCVar(name)
    if value == nil then
        return cvar.defaultValue
    end
    
    -- Convert to proper type
    if type(cvar.defaultValue) == "number" then
        return tonumber(value)
    elseif type(cvar.defaultValue) == "boolean" then
        return value == "1" or value == "true"
    end
    
    return value
end

-- Reset CVar to original value
function Addon.CVar:Reset(name)
    local original = self.originalValues[name]
    if original then
        self:Set(name, original)
    end
end

-- Reset all CVars
function Addon.CVar:ResetAll()
    for name in pairs(self.watchedCVars) do
        self:Reset(name)
    end
end

-- Profile system
function Addon.CVar:SaveProfile(profileName)
    local profile = {}
    for name, cvar in pairs(self.watchedCVars) do
        profile[name] = self:Get(name)
    end
    
    -- Save to database
    if not self.db.profiles then
        self.db.profiles = {}
    end
    self.db.profiles[profileName] = profile
    self.db.currentProfile = profileName
end

function Addon.CVar:LoadProfile(profileName)
    local profile = self.db.profiles and self.db.profiles[profileName]
    if not profile then
        error("Profile '" .. profileName .. "' not found")
        return false
    end
    
    -- Apply profile settings
    for name, value in pairs(profile) do
        self:Set(name, value)
    end
    
    self.db.currentProfile = profileName
    return true
end

-- Initialize common CVars
function Addon.CVar:InitializeCommonCVars()
    -- Graphics settings
    self:Register("gxWindowedResolution", "1920x1080", "graphics")
    self:Register("gxMonitor", "1", "graphics")
    self:Register("windowSize", "1920x1080", "graphics")
    
    -- UI settings
    self:Register("useUiScale", "0", "ui")
    self:Register("uiScale", "1", "ui")
    self:Register("uiScaleMinScale", "0.64", "ui")
    
    -- Combat settings
    self:Register("ShowTargetCastbar", "1", "combat")
    self:Register("ShowVKeyCastbar", "1", "combat")
    self:Register("CombatLogRecording", "0", "combat")
    
    -- Accessibility settings
    self:Register("colorblindMode", "0", "accessibility")
    self:Register("ShowDispelDebuffs", "1", "accessibility")
    
    -- Performance settings
    self:Register("ParticleDensity", "100", "performance")
    self:Register("GroundClutter", "100", "performance")
    self:Register("entityLodDist", "100", "performance")
end
```

#### 2. Profile Management UI
```lua
-- File: MyAddon/UI/ProfileManager.lua
local ADDON_NAME, Addon = ...

-- Profile management interface
Addon.UI.Profiles = {}

function Addon.UI.Profiles:CreateProfileManager(parent)
    local frame = Addon.UI:CreateStyledFrame("ProfileManagerFrame", parent, 400, 300)
    frame:SetToplevel(true)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    title:SetText("Profile Manager")
    
    -- Profile list
    local profileList = CreateFrame("Frame", nil, frame, "UIPanelScrollFrameTemplate")
    profileList:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
    profileList:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 80)
    profileList:SetWidth(150)
    
    local listContent = CreateFrame("Frame", nil, profileList)
    listContent:SetWidth(130)
    profileList:SetScrollChild(listContent)
    
    -- Profile buttons container
    local profileButtons = {}
    local selectedProfile = nil
    
    function UpdateProfileList()
        -- Clear existing buttons
        for _, button in ipairs(profileButtons) do
            button:Hide()
        end
        profileButtons = {}
        
        local profiles = Addon.CVar.db.profiles or {}
        local yOffset = 0
        
        for profileName in pairs(profiles) do
            local button = Addon.UI:CreateButton(listContent, profileName, function()
                SelectProfile(profileName)
            end, 120, 25)
            
            button:SetPoint("TOP", listContent, "TOP", 0, -yOffset)
            table.insert(profileButtons, button)
            yOffset = yOffset + 30
        end
        
        listContent:SetHeight(yOffset)
    end
    
    function SelectProfile(profileName)
        selectedProfile = profileName
        UpdateProfileButtons()
    end
    
    function UpdateProfileButtons()
        -- Enable/disable action buttons based on selection
        if selectedProfile then
            loadButton:Enable()
            deleteButton:Enable()
            if selectedProfile == Addon.CVar.db.currentProfile then
                loadButton:SetText("Current")
                loadButton:Disable()
            else
                loadButton:SetText("Load")
                loadButton:Enable()
            end
        else
            loadButton:SetText("Load")
            loadButton:Disable()
            deleteButton:Disable()
        end
    end
    
    -- Action buttons
    local loadButton = Addon.UI:CreateButton(frame, "Load", function()
        if selectedProfile and selectedProfile ~= Addon.CVar.db.currentProfile then
            Addon.CVar:LoadProfile(selectedProfile)
            UpdateProfileButtons()
        end
    end, 100, 25)
    loadButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 20)
    
    local saveButton = Addon.UI:CreateButton(frame, "Save New", function()
        local profileName = ProfileNameInput:GetText()
        if profileName and profileName ~= "" then
            Addon.CVar:SaveProfile(profileName)
            UpdateProfileList()
            ProfileNameInput:SetText("")
        end
    end, 100, 25)
    saveButton:SetPoint("LEFT", loadButton, "RIGHT", 10, 0)
    
    local deleteButton = Addon.UI:CreateButton(frame, "Delete", function()
        if selectedProfile then
            Addon.CVar.db.profiles[selectedProfile] = nil
            if selectedProfile == Addon.CVar.db.currentProfile then
                Addon.CVar.db.currentProfile = nil
            end
            UpdateProfileList()
            selectedProfile = nil
            UpdateProfileButtons()
        end
    end, 100, 25)
    deleteButton:SetPoint("LEFT", saveButton, "RIGHT", 10, 0)
    
    -- Profile name input
    local inputLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inputLabel:SetPoint("TOPLEFT", profileList, "TOPRIGHT", 20, 0)
    inputLabel:SetText("New Profile Name:")
    
    local ProfileNameInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    ProfileNameInput:SetSize(150, 32)
    ProfileNameInput:SetPoint("TOPLEFT", inputLabel, "BOTTOMLEFT", 0, -5)
    ProfileNameInput:SetAutoFocus(false)
    
    -- Current profile display
    local currentProfileLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentProfileLabel:SetPoint("TOP", ProfileNameInput, "BOTTOM", 0, -20)
    currentProfileLabel:SetText("Current Profile: None")
    
    function UpdateCurrentProfile()
        local current = Addon.CVar.db.currentProfile
        currentProfileLabel:SetText("Current Profile: " .. (current or "None"))
    end
    
    -- Initialize
    UpdateProfileList()
    UpdateProfileButtons()
    UpdateCurrentProfile()
    
    return frame
end
```

### Designing Optimized Keybinding Systems and Macro Strategies

#### 1. Advanced Keybinding Manager
```lua
-- File: MyAddon/Core/KeybindingManager.lua
local ADDON_NAME, Addon = ...

-- Advanced keybinding system
Addon.Keybindings = {}
Addon.Keybindings.bindings = {}
Addon.Keybindings.categories = {}

-- Register keybinding category
function Addon.Keybindings:RegisterCategory(name, description)
    self.categories[name] = {
        name = name,
        description = description,
        bindings = {}
    }
end

-- Register keybinding
function Addon.Keybindings:Register(name, description, action, category, defaultKey)
    local binding = {
        name = name,
        description = description,
        action = action,
        category = category or "general",
        defaultKey = defaultKey,
        currentKey = nil
    }
    
    self.bindings[name] = binding
    
    if self.categories[category] then
        table.insert(self.categories[category].bindings, binding)
    end
    
    -- Set default key if available
    if defaultKey then
        self:SetKey(name, defaultKey)
    end
end

-- Set keybinding
function Addon.Keybindings:SetKey(bindingName, key)
    local binding = self.bindings[bindingName]
    if not binding then
        error("Binding '" .. bindingName .. "' not found")
        return false
    end
    
    -- Clear existing binding for this key
    if binding.currentKey then
        SetBinding(binding.currentKey)
    end
    
    -- Check if key is already bound
    local existingAction = GetBindingAction(key)
    if existingAction and existingAction ~= "" then
        print(format("Warning: Key '%s' already bound to '%s'", key, existingAction))
    end
    
    -- Set new binding
    local success = SetBindingClick(key, bindingName)
    if success then
        binding.currentKey = key
        _G[bindingName] = CreateFrame("Button", bindingName)
        _G[bindingName]:SetScript("OnClick", function()
            binding.action()
        end)
        return true
    end
    
    return false
end

-- Clear keybinding
function Addon.Keybindings:ClearKey(bindingName)
    local binding = self.bindings[bindingName]
    if not binding then return false end
    
    if binding.currentKey then
        SetBinding(binding.currentKey)
        binding.currentKey = nil
    end
    
    if _G[bindingName] then
        _G[bindingName]:SetScript("OnClick", nil)
    end
    
    return true
end

-- Save keybindings
function Addon.Keybindings:SaveBindings()
    local savedBindings = {}
    for name, binding in pairs(self.bindings) do
        if binding.currentKey then
            savedBindings[name] = binding.currentKey
        end
    end
    Addon.db.profile.keybindings = savedBindings
end

-- Load keybindings
function Addon.Keybindings:LoadBindings()
    local savedBindings = Addon.db.profile.keybindings or {}
    for name, key in pairs(savedBindings) do
        self:SetKey(name, key)
    end
end

-- Create keybinding configuration UI
function Addon.Keybindings:CreateConfigUI(parent)
    local frame = Addon.UI:CreateStyledFrame("KeybindingConfigFrame", parent, 500, 400)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    title:SetText("Keybinding Configuration")
    
    -- Category dropdown
    local categoryDropDown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
    categoryDropDown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
    
    -- Populate categories
    local categoryList = {}
    for name in pairs(self.categories) do
        table.insert(categoryList, name)
    end
    
    UIDropDownMenu_Initialize(categoryDropDown, function()
        for _, name in ipairs(categoryList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = name
            info.func = function()
                UIDropDownMenu_SetSelectedID(categoryDropDown, this:GetID())
                ShowCategoryBindings(name)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    -- Bindings list
    local bindingsFrame = CreateFrame("Frame", nil, frame, "UIPanelScrollFrameTemplate")
    bindingsFrame:SetPoint("TOPLEFT", categoryDropDown, "BOTTOMLEFT", 0, -20)
    bindingsFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
    
    local bindingsContent = CreateFrame("Frame", nil, bindingsFrame)
    bindingsFrame:SetScrollChild(bindingsContent)
    
    local function ShowCategoryBindings(categoryName)
        -- Clear existing bindings UI
        for _, child in pairs({bindingsContent:GetChildren()}) do
            child:Hide()
        end
        
        local category = self.categories[categoryName]
        if not category then return end
        
        local yOffset = 0
        
        for _, binding in ipairs(category.bindings) do
            -- Binding name
            local nameText = bindingsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("TOPLEFT", bindingsContent, "TOPLEFT", 10, -yOffset)
            nameText:SetText(binding.description)
            nameText:SetWidth(300)
            nameText:SetJustifyH("LEFT")
            
            -- Current key display
            local keyText = bindingsContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            keyText:SetPoint("TOPRIGHT", bindingsContent, "TOPRIGHT", -100, -yOffset)
            keyText:SetText(binding.currentKey or "Unbound")
            
            -- Set key button
            local setButton = Addon.UI:CreateButton(bindingsContent, "Set Key", function()
                StartKeyBinding(binding, keyText)
            end, 80, 20)
            setButton:SetPoint("TOPRIGHT", bindingsContent, "TOPRIGHT", -10, -yOffset - 2)
            
            -- Clear button
            local clearButton = Addon.UI:CreateButton(bindingsContent, "Clear", function()
                self:ClearKey(binding.name)
                keyText:SetText("Unbound")
            end, 50, 20)
            clearButton:SetPoint("RIGHT", setButton, "LEFT", -5, 0)
            
            yOffset = yOffset + 30
        end
        
        bindingsContent:SetHeight(yOffset)
    end
    
    local function StartKeyBinding(binding, keyText)
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetAllPoints(UIParent)
        frame:SetFrameStrata("DIALOG")
        
        local message = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        message:SetPoint("CENTER")
        message:SetText("Press a key to bind '" .. binding.description .. "' (ESC to cancel)")
        
        frame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                frame:Hide()
                return
            end
            
            if self:SetKey(binding.name, key) then
                keyText:SetText(key)
                self:SaveBindings()
            end
            
            frame:Hide()
        end)
        
        frame:EnableKeyboard(true)
    end
    
    -- Show first category by default
    if #categoryList > 0 then
        ShowCategoryBindings(categoryList[1])
        UIDropDownMenu_SetSelectedID(categoryDropDown, 1)
    end
    
    return frame
end

-- Initialize default keybindings
function Addon.Keybindings:InitializeDefaults()
    self:RegisterCategory("general", "General addon functions")
    self:RegisterCategory("combat", "Combat-related functions")
    self:RegisterCategory("ui", "Interface functions")
    
    -- Example bindings
    self:Register("TOGGLE_MAIN", "Toggle Main Window", function()
        Addon.UI:ToggleMainWindow()
    end, "general", "F1")
    
    self:Register("QUICK_HEAL", "Quick Heal Target", function()
        if UnitExists("target") and UnitIsFriend("target", "player") then
            CastSpellByName("Flash Heal")
        end
    end, "combat", "F2")
    
    self:Register("RELOAD_UI", "Reload Interface", function()
        ReloadUI()
    end, "general", "CTRL+R")
end
```

### Building Combat Rotation Helpers and Ability Tracking

#### 1. Combat Rotation System
```lua
-- File: MyAddon/Combat/Rotation.lua
local ADDON_NAME, Addon = ...

-- Combat rotation helper system
Addon.Combat = {}
Addon.Combat.rotation = {}
Addon.Combat.abilities = {}
Addon.Combat.cooldowns = {}
Addon.Combat.buffs = {}
Addon.Combat.enemies = {}

-- Ability database
function Addon.Combat:RegisterAbility(name, spellId, cooldown, manaCost, priority, conditions)
    self.abilities[name] = {
        name = name,
        spellId = spellId,
        cooldown = cooldown,
        manaCost = manaCost,
        priority = priority,
        conditions = conditions or {},
        lastUsed = 0,
        castCount = 0
    }
end

-- Condition evaluator
function Addon.Combat:EvaluateConditions(ability)
    for conditionName, conditionValue in pairs(ability.conditions) do
        if conditionName == "health_below" then
            local healthPercent = (UnitHealth("player") / UnitHealthMax("player")) * 100
            if healthPercent >= conditionValue then return false end
        elseif conditionName == "mana_above" then
            local manaPercent = (UnitPower("player") / UnitPowerMax("player")) * 100
            if manaPercent <= conditionValue then return false end
        elseif conditionName == "target_exists" then
            if conditionValue and not UnitExists("target") then return false end
            if not conditionValue and UnitExists("target") then return false end
        elseif conditionName == "in_combat" then
            local inCombat = UnitAffectingCombat("player")
            if conditionValue and not inCombat then return false end
            if not conditionValue and inCombat then return false end
        elseif conditionName == "buff_present" then
            local hasBuff = false
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
                if spellId == conditionValue then
                    hasBuff = true
                    break
                end
            end
            if not hasBuff then return false end
        elseif conditionName == "cooldown_ready" then
            local start, duration = GetSpellCooldown(ability.spellId)
            if start and duration and (start + duration) > GetTime() then
                return false
            end
        end
    end
    
    return true
end

-- Get next recommended action
function Addon.Combat:GetNextAction()
    local currentTime = GetTime()
    local bestAction = nil
    local bestPriority = -1
    
    for name, ability in pairs(self.abilities) do
        -- Check cooldown
        if (currentTime - ability.lastUsed) >= ability.cooldown then
            -- Check mana
            local manaPercent = (UnitPower("player") / UnitPowerMax("player")) * 100
            if manaPercent >= ability.manaCost then
                -- Check conditions
                if self:EvaluateConditions(ability) then
                    -- Check priority
                    if ability.priority > bestPriority then
                        bestPriority = ability.priority
                        bestAction = ability
                    end
                end
            end
        end
    end
    
    return bestAction
end

-- Execute rotation step
function Addon.Combat:ExecuteRotationStep()
    if not UnitAffectingCombat("player") then return end
    
    local nextAction = self:GetNextAction()
    if nextAction then
        CastSpellByName(nextAction.name)
        nextAction.lastUsed = GetTime()
        nextAction.castCount = nextAction.castCount + 1
        
        -- Track rotation efficiency
        self:TrackRotationEfficiency(nextAction)
    end
end

-- Rotation efficiency tracking
function Addon.Combat:TrackRotationEfficiency(ability)
    if not self.rotationStats then
        self.rotationStats = {
            totalActions = 0,
            abilityUsage = {},
            wastedTime = 0,
            lastActionTime = GetTime()
        }
    end
    
    local currentTime = GetTime()
    local timeSinceLastAction = currentTime - self.rotationStats.lastActionTime
    self.rotationStats.wastedTime = self.rotationStats.wastedTime + timeSinceLastAction
    self.rotationStats.lastActionTime = currentTime
    self.rotationStats.totalActions = self.rotationStats.totalActions + 1
    
    if not self.rotationStats.abilityUsage[ability.name] then
        self.rotationStats.abilityUsage[ability.name] = 0
    end
    self.rotationStats.abilityUsage[ability.name] = self.rotationStats.abilityUsage[ability.name] + 1
end

-- Initialize rotation for Priest (example)
function Addon.Combat:InitializePriestRotation()
    -- Healing spells
    self:RegisterAbility("Flash Heal", 2061, 0, 4, 90, {
        health_below = 80,
        target_exists = true
    })
    
    self:RegisterAbility("Renew", 139, 0, 2, 60, {
        health_below = 95,
        buff_present = false,
        target_exists = true
    })
    
    self:RegisterAbility("Power Word: Shield", 17, 4, 3, 80, {
        health_below = 90,
        target_exists = true
    })
    
    -- Damage spells
    self:RegisterAbility("Shadow Word: Pain", 589, 0, 2, 50, {
        in_combat = true,
        target_exists = true,
        cooldown_ready = true
    })
    
    self:RegisterAbility("Mind Blast", 8092, 8, 5, 70, {
        in_combat = true,
        target_exists = true,
        cooldown_ready = true
    })
    
    self:RegisterAbility("Smite", 585, 0, 2, 40, {
        in_combat = true,
        target_exists = true
    })
end
```

#### 2. Cooldown Tracking System
```lua
-- File: MyAddon/Combat/Cooldowns.lua
local ADDON_NAME, Addon = ...

-- Advanced cooldown tracking system
Addon.Cooldowns = {}
Addon.Cooldowns.tracked = {}
Addon.Cooldowns.display = {}

-- Track spell cooldown
function Addon.Cooldowns:TrackSpell(spellId, spellName, cooldown)
    self.tracked[spellId] = {
        name = spellName,
        cooldown = cooldown,
        startTime = 0,
        duration = 0,
        charges = 1,
        maxCharges = 1,
        lastUsed = 0
    }
end

-- Update cooldown information
function Addon.Cooldowns:UpdateCooldown(spellId)
    local cd = self.tracked[spellId]
    if not cd then return end
    
    local start, duration, enabled, modRate = GetSpellCooldown(spellId)
    local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellId)
    
    cd.startTime = start or 0
    cd.duration = duration or 0
    cd.charges = charges or 1
    cd.maxCharges = maxCharges or 1
    
    if start and duration and start > 0 then
        cd.lastUsed = start
    end
end

-- Check if cooldown is ready
function Addon.Cooldowns:IsReady(spellId)
    local cd = self.tracked[spellId]
    if not cd then return false end
    
    self:UpdateCooldown(spellId)
    
    local currentTime = GetTime()
    if cd.startTime > 0 and (cd.startTime + cd.duration) > currentTime then
        return false
    end
    
    return cd.charges > 0
end

-- Get remaining cooldown time
function Addon.Cooldowns:GetRemainingTime(spellId)
    local cd = self.tracked[spellId]
    if not cd then return 0 end
    
    self:UpdateCooldown(spellId)
    
    local currentTime = GetTime()
    if cd.startTime > 0 then
        return math.max(0, (cd.startTime + cd.duration) - currentTime)
    end
    
    return 0
end

-- Create cooldown display
function Addon.Cooldowns:CreateDisplay(parent)
    local frame = Addon.UI:CreateStyledFrame("CooldownDisplayFrame", parent, 300, 200)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Cooldown Tracker")
    
    -- Cooldown list container
    local cooldownContainer = CreateFrame("Frame", nil, frame)
    cooldownContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
    cooldownContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    
    -- Update function
    local function UpdateDisplay()
        -- Clear existing cooldown displays
        for _, child in pairs({cooldownContainer:GetChildren()}) do
            child:Hide()
        end
        
        local yOffset = 0
        local currentTime = GetTime()
        
        for spellId, cd in pairs(self.tracked) do
            local remainingTime = self:GetRemainingTime(spellId)
            local isReady = self:IsReady(spellId)
            
            -- Create cooldown bar
            local barFrame = CreateFrame("Frame", nil, cooldownContainer)
            barFrame:SetSize(280, 20)
            barFrame:SetPoint("TOP", cooldownContainer, "TOP", 0, -yOffset)
            
            -- Background
            local bg = barFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            
            -- Cooldown fill
            local fill = CreateFrame("StatusBar", nil, barFrame)
            fill:SetAllPoints()
            fill:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
            
            if isReady then
                fill:SetStatusBarColor(0.2, 0.8, 0.2, 0.8)
                fill:SetMinMaxValues(0, 1)
                fill:SetValue(1)
            else
                fill:SetStatusBarColor(0.8, 0.2, 0.2, 0.8)
                fill:SetMinMaxValues(0, cd.cooldown)
                fill:SetValue(cd.cooldown - remainingTime)
            end
            
            -- Spell name
            local nameText = barFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", barFrame, "LEFT", 5, 0)
            nameText:SetText(cd.name)
            nameText:SetJustifyH("LEFT")
            
            -- Time remaining
            local timeText = barFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            timeText:SetPoint("RIGHT", barFrame, "RIGHT", -5, 0)
            if isReady then
                timeText:SetText("Ready")
                timeText:SetTextColor(0.2, 0.8, 0.2)
            else
                timeText:SetText(format("%.1fs", remainingTime))
                timeText:SetTextColor(0.8, 0.2, 0.2)
            end
            
            -- Charges display
            if cd.maxCharges > 1 then
                local chargesText = barFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                chargesText:SetPoint("RIGHT", timeText, "LEFT", -10, 0)
                chargesText:SetText(format("%d/%d", cd.charges, cd.maxCharges))
            end
            
            yOffset = yOffset + 25
        end
    end
    
    -- Update timer
    local updateTimer = C_Timer.NewTicker(0.1, UpdateDisplay)
    
    return frame
end

-- Initialize common cooldowns
function Addon.Cooldowns:InitializeDefaults()
    -- Priest cooldowns (example)
    self:TrackSpell(17, "Power Word: Shield", 4)
    self:TrackSpell(2061, "Flash Heal", 0)
    self:TrackSpell(8092, "Mind Blast", 8)
    self:TrackSpell(34433, "Shadowfiend", 180)
    self:TrackSpell(47585, "Dispersion", 120)
    
    -- Generic cooldowns
    self:TrackSpell(6603, "Auto Attack", 0)
    self:TrackSpell(20580, "Shadow Word: Death", 8)
end
```

---

## 4. Network & Performance Monitoring

---

## Final Configuration and Deployment

### Complete Addon Structure
```
MyAddon/
├── MyAddon.toc
├── embeds.xml
├── core/
│   ├── Constants.lua
│   ├── ErrorHandling.lua
│   ├── Memory.lua
│   └── CVarManager.lua
├── ui/
│   ├── Framework.lua
│   ├── Responsive.lua
│   └── ProfileManager.lua
├── combat/
│   ├── Rotation.lua
│   ├── Cooldowns.lua
│   └── CooldownTracker.lua
├── monitoring/
│   ├── Network.lua
│   ├── NetworkParser.lua
│   ├── Latency.lua
│   ├── Performance.lua
│   └── Memory.lua
├── pvp/
│   ├── Arena.lua
│   └── EnemyMonitor.lua
├── pve/
│   └── Encounters.lua
└── locales/
    ├── enUS.lua
    └── locales.xml
```

### Installation Instructions Summary

#### 1. VS Code Setup
- Install Visual Studio Code from [code.visualstudio.com](https://code.visualstudio.com/)
- Install essential extensions: `Lua.wolf`, `streetsidesoftware.code-spell-checker`, `esbenp.prettier-vscode`
- Configure Lua workspace with WoW API globals
- Set up debugging with `actboy168.lua-debug`

#### 2. Development Environment
- Install Lua 5.1 and LuaRocks: `luarocks install luacheck`, `luarocks install busted`
- Configure project structure with proper `.vscode/` settings
- Set up symbolic links for easier development
- Initialize git repository for version control

### Recommended Documentation Links

#### Essential Resources
- **WoW API Documentation:** [WoW Programming Guide](https://wowprogramming.com/docs/)
- **Lua Reference Manual:** [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)
- **WoW UI Documentation:** [Interface Customization](https://wowpedia.fandom.com/wiki/Interface_customization)
- **Community Forums:** [WoW Interface](https://www.wowinterface.com/forums/)

#### Development Tools
- **Lua Check:** [Luacheck Documentation](https://luacheck.readthedocs.io/)
- **VS Code Lua:** [Lua Extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
- **Addon Development:** [CurseForge Dev Hub](https://www.curseforge.com/)

This comprehensive guide provides everything needed to set up a professional World of Warcraft addon development environment in Visual Studio Code. The included code templates, monitoring tools, and best practices will enable developers to create efficient, performance-optimized addons for both PvP and PvE scenarios.

