## UltraBar Development Guide

### Architecture Overview

UltraBar uses a modular, performance-optimized architecture:

```
Core Layer (Foundation)
├── Constants.lua      - Enums, settings, configuration
├── Utils.lua          - Helper functions, math, color, etc.
├── EventManager.lua   - High-performance event system
└── Database.lua       - Profile and settings storage

Module Layer (Features)
├── Button/
│   ├── ButtonBase.lua     - Button object pool, rendering
│   ├── ActionButton.lua   - Action-specific behavior
│   └── ButtonUpdater.lua  - Batched state updates
├── Bar/
│   ├── BarBase.lua        - Bar lifecycle, layout
│   ├── BarManager.lua     - Bar registry, events
│   └── BarFactory.lua     - Bar type creation
└── Features/
    ├── Visibility.lua     - Conditional visibility
    ├── Positioning.lua    - Grid snap, positioning
    ├── Fading.lua         - Fade animations
    ├── Scaling.lua        - Dynamic scaling
    └── Theming.lua        - Custom textures/colors

Config Layer (User Settings)
├── Defaults.lua       - Default profiles
├── Options.lua        - AceConfig options
└── ProfileManager.lua - Import/export

GUI Layer (Interface)
├── DragFrame.lua      - Drag-drop positioning
└── ConfigPanel.lua    - Configuration UI
```

### Performance Design

**Event Optimization:**
- Throttled events (0.1s, 0.5s, 2.0s intervals)
- Batched updates (max 10/frame)
- Time-sliced processing (<16ms per frame)
- Lazy event registration

**Memory Optimization:**
- Object pooling for buttons
- Weak table references
- Minimal global pollution
- Lazy loading of disabled bars

**Rendering Optimization:**
- Minimal OnUpdate hooks
- Conditional rendering
- Smart visibility checks
- Frame stacking optimization

### Adding New Features

**1. Create New Module:**

```lua
---@class UltraBar
local ADDON_NAME, UltraBar = ...

UltraBar.MyFeature = {}
local MyFeature = UltraBar.MyFeature

function MyFeature:Initialize()
    -- Your code
end

return MyFeature
```

**2. Register in TOC:**

Add to `UltraBar.toc`:
```
Modules\Features\MyFeature.lua
```

**3. Hook into Events:**

```lua
UltraBar.EventManager:RegisterCallback("PLAYER_LOGIN", function()
    MyFeature:Initialize()
end, "MyFeature_Init")
```

### Extending Bar System

**Custom Bar Type:**

```lua
-- In BarFactory.lua
function BarFactory:CreateBar(barID, barType)
    if barType == "custom" then
        return CustomBar:New(barID)
    end
    return BarBase:New(barID)
end
```

**Custom Visibility Condition:**

```lua
-- In Visibility.lua
function Visibility:Evaluate(condition, customMacro)
    if condition == "MY_CUSTOM_CONDITION" then
        return MyCustomCheck()
    end
    -- ... existing conditions
end
```

### Plugin API

**External addons can hook into UltraBar:**

```lua
-- In your addon
if UltraBar then
    -- Listen for bar updates
    UltraBar.EventManager:RegisterCallback("BAR_CONFIG_UPDATED",
        function(event, barID, config)
            print("Bar", barID, "updated!")
        end,
        "MyAddon_BarUpdate"
    )

    -- Get bar data
    local bar = UltraBar.BarManager:GetBar(1)
    local config = UltraBar.Database:GetBarConfig(1)

    -- Modify bar configuration
    UltraBar.Database:UpdateBarConfig(1, {
        scale = 1.5,
        fadeAlpha = 0.5
    })
end
```

### Testing

**Manual Testing:**

1. Enable debug mode: `/ub debug`
2. Watch console for debug messages
3. Test each bar type individually
4. Test all visibility conditions
5. Test performance with 10 bars + 120 buttons

**Performance Profiling:**

```lua
-- In your code
local start = debugprofilestop()
-- Code to profile
local elapsed = debugprofilestop() - start
print("Operation took", elapsed, "ms")
```

**Memory Profiling:**

```lua
UpdateAddOnMemoryUsage()
local memory = GetAddOnMemoryUsage("UltraBar")
print("UltraBar using", memory, "KB")
```

### Code Style

**Naming Conventions:**
- Classes: `PascalCase`
- Functions: `PascalCase` for public, `camelCase` for private
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Private locals: `camelCase`

**Documentation:**
- Use LuaLS annotations (`---@param`, `---@return`)
- Document all public functions
- Add inline comments for complex logic

**Example:**
```lua
---Calculate button position in grid layout
---@param index number Button index (1-based)
---@param cols number Number of columns
---@param buttonSize number Size of each button
---@param spacing number Spacing between buttons
---@return number x, number y Position coordinates
local function calculateGridPosition(index, cols, buttonSize, spacing)
    local row = math.floor((index - 1) / cols)
    local col = (index - 1) % cols
    local x = col * (buttonSize + spacing)
    local y = -row * (buttonSize + spacing)
    return x, y
end
```

### Contributing

**Before submitting PR:**

1. Test on live realm
2. Check for errors (`/console scriptErrors 1`)
3. Profile performance (no FPS drops)
4. Check memory usage (< 10MB per 10 bars)
5. Document all new features
6. Follow existing code style
7. Add to README.md if user-facing

### Roadmap

**v1.1 (Next):**
- Full AceConfig GUI
- Profile import/export (JSON)
- Per-button customization

**v1.2:**
- Circular/radial layouts
- Dynamic button scaling
- LibSharedMedia support

**v2.0:**
- WeakAuras integration
- Advanced macro conditions
- Multi-profile support
- ElvUI skins

### Known Limitations

**Current:**
- Profile import/export uses simple serialization
- No circular layout (yet)
- GUI config panel is placeholder
- No dynamic button scaling (yet)

**By Design:**
- Requires Ace3 for full functionality
- WoW 11.0.2+ only
- No classic support (different action bar API)

### Resources

**WoW API:**
- https://wowprogramming.com/docs/
- https://wowpedia.fandom.com/

**Ace3:**
- https://www.wowace.com/projects/ace3

**Performance:**
- https://wowprogramming.com/docs/secure_functions

---

**Questions?** Open an issue on GitHub or ask in Discord.
