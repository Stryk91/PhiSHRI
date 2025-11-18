# PhiLaunch MCP Screen Control

An MCP (Model Context Protocol) server that provides AI assistants with **safe, monitored access** to screen interaction capabilities including mouse control, keyboard input, clipboard operations, OCR, and visual element detection.

## 🎯 Features

### Core Capabilities
- **Mouse Control** - Move, click, drag, scroll
- **Keyboard Input** - Type text, press keys, hotkeys
- **Clipboard Operations** - Read and write clipboard content
- **Screen Capture** - Take screenshots of full screen or regions
- **OCR (Optical Character Recognition)** - Read text from screen
- **Element Detection** - Find UI elements by text or image
- **Visual Feedback** - Annotated screenshots showing AI actions

### Safety & Oversight
- **Human Oversight GUI** - Real-time monitoring and approval
- **Action Confirmation** - Require approval for critical operations
- **Rate Limiting** - Prevent runaway automation
- **Safety Zones** - Restrict actions to specific screen areas
- **Action History** - Complete audit trail of all operations
- **Screenshot Logging** - Visual record of every action

### Integration
- **Claude Desktop** - Native MCP integration
- **Remote Access** - SSH-compatible for remote monitoring
- **Cross-Platform** - Works on Windows, macOS, Linux
- **Automation-Ready** - Scriptable and schedulable

## 📋 Requirements

- Python 3.8+
- Tesseract OCR (for text detection)
- X11/Wayland (Linux) or native windowing system
- MCP SDK (`mcp>=0.9.0`)

## 🚀 Quick Start

### 1. Installation

```bash
# Clone or navigate to the directory
cd /path/to/PhiLaunch/mcp-screen-control

# Run installer
./install.sh
```

The installer will:
- Create a Python virtual environment
- Install all dependencies
- Check for Tesseract OCR
- Create required directories
- Set up logging

### 2. Configure Claude Desktop

Add to your Claude Desktop MCP configuration file (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "screen-control": {
      "command": "/path/to/PhiLaunch/mcp-screen-control/venv/bin/python",
      "args": ["/path/to/PhiLaunch/mcp-screen-control/server/screen_mcp_server.py"]
    }
  }
}
```

**Configuration file locations:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

### 3. Start Oversight GUI (Recommended)

```bash
./start-gui.sh
```

The GUI provides:
- Real-time action monitoring
- Visual feedback of AI operations
- Approve/reject action requests
- Screenshot viewer
- Action history and statistics
- Safety zone configuration

### 4. Use with Claude

Ask Claude to interact with your screen:

```
"Take a screenshot and analyze what's on my screen"

"Find and click the 'Submit' button"

"Read the text from the notification that just appeared"

"Type 'Hello World' in the current text field"

"Copy the selected text to clipboard"
```

## 🛠️ MCP Tools

The server provides these tools to AI assistants:

### Screen Information
- `get_screen_info` - Get screen size and mouse position
- `take_screenshot` - Capture screen or region
- `get_mouse_position` - Get current cursor position

### Mouse Control
- `move_mouse` - Move cursor to coordinates
- `click_mouse` - Click at position (left/right/middle, single/double)

### Keyboard Control
- `type_text` - Type text string
- `press_key` - Press key or key combination (e.g., Ctrl+C)

### Clipboard
- `get_clipboard` - Read clipboard content
- `set_clipboard` - Write to clipboard

### OCR & Element Detection
- `ocr_screen` - Perform OCR on screen/region
- `find_text_element` - Find element by text content
- `click_text_element` - Find and click on text

### Monitoring
- `get_action_history` - Get recent actions for audit

## 📖 Usage Examples

### Example 1: Take Screenshot and Analyze

```python
# AI can use this tool
result = await call_tool("take_screenshot", {})
# Returns screenshot as base64 image
```

### Example 2: Find and Click Button

```python
# Find "Submit" button using OCR
element = await call_tool("find_text_element", {
    "text": "Submit",
    "fuzzy": True
})

# Click it
if element["found"]:
    await call_tool("click_mouse", {
        "x": element["element"]["center_x"],
        "y": element["element"]["center_y"]
    })
```

### Example 3: Automated Form Filling

```python
# Click name field
await call_tool("click_text_element", {"text": "Name:"})

# Type name
await call_tool("type_text", {"text": "John Doe"})

# Press Tab to next field
await call_tool("press_key", {"keys": ["tab"]})

# Type email
await call_tool("type_text", {"text": "john@example.com"})

# Submit form
await call_tool("click_text_element", {"text": "Submit"})
```

### Example 4: Copy Selected Text

```python
# Press Ctrl+C to copy
await call_tool("press_key", {"keys": ["ctrl", "c"]})

# Read clipboard
result = await call_tool("get_clipboard", {})
print(f"Copied text: {result['content']}")
```

## ⚙️ Configuration

Edit `config/config.json` to customize behavior:

### Safety Settings

```json
{
  "safety": {
    "require_confirmation": true,
    "max_actions_per_minute": 30,
    "screenshot_before_action": true,
    "failsafe_enabled": true
  }
}
```

### OCR Settings

```json
{
  "ocr": {
    "language": "eng",
    "confidence_threshold": 60
  }
}
```

### Mouse Settings

```json
{
  "mouse": {
    "movement_duration": 0.3,
    "click_delay": 0.1
  }
}
```

## 🔒 Safety Features

### 1. Rate Limiting
Prevents AI from performing too many actions per minute (default: 30).

### 2. Failsafe
Move mouse to screen corner to immediately abort operations (PyAutoGUI FAILSAFE).

### 3. Action Confirmation
Requires human approval for mouse clicks and text input (configurable).

### 4. Safety Zones
Restrict AI actions to specific screen regions:

```json
{
  "safety": {
    "allowed_areas": [
      [0, 0, 1920, 200],
      [0, 800, 1920, 280]
    ]
  }
}
```

### 5. Complete Audit Trail
All actions are logged with:
- Timestamp
- Action type
- Parameters
- Result
- Screenshot (optional)

### 6. Human Oversight GUI
Real-time monitoring and intervention capability.

## 🖥️ Oversight GUI

### Main Features

**Control Panel:**
- Start/stop monitoring
- Enable/disable auto-approve
- Configure safety settings
- View real-time statistics

**Action Log:**
- Filter by action type
- Export to JSON/text
- Color-coded by severity
- Search functionality

**Screen Viewer:**
- Live screenshot display
- Mouse position tracking
- Click location highlighting
- OCR overlay mode

**Approval System:**
- Review pending actions
- Approve or reject with one click
- View action details and parameters

### Screenshot

```
┌─────────────────────────────────────────────────────┐
│  PhiLaunch MCP Screen Control - Oversight          │
├─────────────────┬───────────────────────────────────┤
│  Control        │  Screen View                      │
│  [Start/Stop]   │  ┌─────────────────────────────┐  │
│                 │  │                             │  │
│  Settings       │  │    Live Screenshot          │  │
│  □ Auto-approve │  │                             │  │
│  ☑ Confirm      │  │                             │  │
│  ☑ Highlight    │  │                             │  │
│                 │  └─────────────────────────────┘  │
│  Statistics     │  Mouse: (1024, 768)               │
│  Actions: 47    │                                   │
│  Clicks: 23     │  [Refresh] [OCR] [Safety Zones]   │
│  Errors: 0      │                                   │
│                 │                                   │
│  Action Log     │                                   │
│  ┌───────────┐  │                                   │
│  │[12:34:56] │  │                                   │
│  │Click OK   │  │                                   │
│  │[12:35:12] │  │                                   │
│  │Type text  │  │                                   │
│  └───────────┘  │                                   │
└─────────────────┴───────────────────────────────────┘
```

## 🔧 Advanced Usage

### Remote Monitoring over SSH

```bash
# Start GUI with X11 forwarding
ssh -X user@host 'cd /path/to/mcp-screen-control && ./start-gui.sh'

# Or run server in background and monitor logs
ssh user@host 'cd /path/to/mcp-screen-control && ./start-server.sh' &
ssh user@host 'tail -f /path/to/mcp-screen-control/logs/screen_mcp_server.log'
```

### Custom OCR Training

For better accuracy with specific fonts or languages:

```bash
# Train Tesseract for your use case
tesseract image.png output --psm 6 -l eng+custom

# Update config
{
  "ocr": {
    "language": "eng+custom",
    "training_data": "/path/to/custom.traineddata"
  }
}
```

### Safety Zone Calibration

1. Run the calibration tool from GUI: `Tools > Define Safety Zones`
2. Click corners of allowed area
3. Save configuration
4. Restart server

### Integration with Other Tools

```python
# Example: Integrate with automation framework
import asyncio
from mcp import ClientSession

async def automate_task():
    async with ClientSession() as session:
        # Connect to MCP server
        await session.initialize()

        # Take screenshot
        screenshot = await session.call_tool("take_screenshot", {})

        # Find element
        element = await session.call_tool("find_text_element", {
            "text": "Login"
        })

        # Click it
        if element["found"]:
            await session.call_tool("click_text_element", {
                "text": "Login"
            })
```

## 📊 Logging

Logs are stored in `logs/screen_mcp_server.log`:

```
2025-11-17 14:30:45 - screen-mcp-server - INFO - Starting PhiLaunch MCP Screen Control Server...
2025-11-17 14:30:46 - screen-mcp-server - INFO - Safety settings: {'require_confirmation': True, ...}
2025-11-17 14:31:12 - screen-mcp-server - INFO - Action: take_screenshot | Params: {}
2025-11-17 14:31:15 - screen-mcp-server - INFO - Action: find_text_element | Params: {'text': 'Submit'}
2025-11-17 14:31:16 - screen-mcp-server - INFO - Action: click_mouse | Params: {'x': 450, 'y': 320}
```

## 🐛 Troubleshooting

### Issue: Tesseract not found

```bash
# Ubuntu/Debian
sudo apt-get install tesseract-ocr

# macOS
brew install tesseract

# Windows
# Download from https://github.com/UB-Mannheim/tesseract/wiki
```

### Issue: Permission denied on screenshots

```bash
# macOS: Grant screen recording permission
System Preferences > Security & Privacy > Privacy > Screen Recording

# Linux: Check X11 display variable
echo $DISPLAY
export DISPLAY=:0
```

### Issue: MCP server not connecting

1. Check Claude Desktop config path is correct
2. Verify virtual environment activation
3. Check logs: `tail -f logs/screen_mcp_server.log`
4. Restart Claude Desktop

### Issue: OCR not detecting text

1. Increase confidence threshold in config
2. Try different OCR language: `"language": "eng+fra"`
3. Preprocess images (grayscale, denoise)
4. Check Tesseract installation: `tesseract --version`

## 📚 Architecture

```
┌─────────────────────────────────────────────────────┐
│              Claude Desktop / AI Assistant          │
└─────────────────┬───────────────────────────────────┘
                  │ MCP Protocol
                  ▼
┌─────────────────────────────────────────────────────┐
│         MCP Screen Control Server                   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Tool Handlers                               │   │
│  │  • Mouse, Keyboard, Clipboard                │   │
│  │  • Screenshot, OCR                           │   │
│  │  • Element Detection                         │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  Safety Layer                                │   │
│  │  • Rate Limiting                             │   │
│  │  • Confirmation                              │   │
│  │  • Safety Zones                              │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│         Oversight GUI (Optional)                    │
│  • Real-time monitoring                             │
│  • Action approval                                  │
│  • Visual feedback                                  │
└─────────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│              Operating System                       │
│  • PyAutoGUI → Mouse/Keyboard                       │
│  • PIL/Pillow → Screenshots                         │
│  • Tesseract → OCR                                  │
│  • OpenCV → Image Recognition                       │
└─────────────────────────────────────────────────────┘
```

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- Additional OCR engines (EasyOCR, PaddleOCR)
- Computer vision element detection
- Mobile device control (Android/iOS)
- Web automation integration (Selenium/Playwright)
- Voice control integration
- Accessibility features

## 📄 License

Part of the PhiLaunch project.

## ⚠️ Security Notice

This tool grants AI assistants access to your screen and input devices. Always:
- Use the oversight GUI for monitoring
- Enable action confirmation for production use
- Define safety zones to restrict access
- Review action logs regularly
- Never run on systems with sensitive data without proper precautions
- Keep rate limiting enabled
- Use strong authentication if enabling remote access

## 📞 Support

- Issues: GitHub Issues for PhiLaunch
- Documentation: This README and inline code comments
- Examples: See `examples/` directory

---

**PhiLaunch MCP Screen Control v1.0.0** - Safe AI Screen Interaction with Human Oversight
