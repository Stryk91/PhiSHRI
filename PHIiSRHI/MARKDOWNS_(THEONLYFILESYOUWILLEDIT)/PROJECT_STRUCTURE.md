# Project Structure

Complete overview of the AI Response Capture Framework file organization.

```
ai-response-capture-framework/
├── src/                          # Source code
│   ├── capture/                  # Core capture engine
│   │   ├── ai-response-capture.js    # Main orchestrator
│   │   ├── cdp-manager.js            # CDP connection manager
│   │   └── stream-buffer.js          # Stream buffering & deduplication
│   │
│   ├── adapters/                 # Platform-specific adapters
│   │   ├── base-adapter.js           # Base adapter interface
│   │   ├── claude.js                 # Claude.ai adapter
│   │   ├── chatgpt.js                # ChatGPT adapter
│   │   ├── perplexity.js             # Perplexity.ai adapter
│   │   ├── gemini.js                 # Google Gemini adapter
│   │   └── copilot.js                # Microsoft Copilot adapter
│   │
│   ├── storage/                  # Database layer
│   │   └── database.js               # SQLite database operations
│   │
│   ├── utils/                    # Utility modules
│   │   ├── logger.js                 # Colored console logging
│   │   └── response-normalizer.js    # Response format normalization
│   │
│   ├── index.js                  # Main entry point
│   └── monitor.js                # Real-time monitoring console
│
├── ahk/                          # AutoHotkey integration
│   ├── AIMessaging.ahk               # Main AHK library
│   └── example-usage.ahk             # AHK usage examples
│
├── examples/                     # Usage examples
│   ├── basic-usage.js                # Simple capture example
│   ├── automated-conversation.js     # Automated messaging
│   ├── multi-platform-capture.js     # Multi-platform demo
│   └── database-queries.js           # Database query examples
│
├── docs/                         # Documentation
│   ├── SETUP_GUIDE.md                # Complete setup instructions
│   └── API_REFERENCE.md              # Full API documentation
│
├── data/                         # Database storage (created at runtime)
│   └── conversations.db              # SQLite database
│
├── capture_config.json           # Main configuration file
├── package.json                  # Node.js dependencies
├── README.md                     # Main documentation
├── QUICK_START.md                # Quick start guide
├── LICENSE                       # MIT license
├── .gitignore                    # Git ignore rules
├── start-chrome-debug.bat        # Windows Chrome launcher
└── start-chrome-debug.sh         # macOS/Linux Chrome launcher
```

## Directory Descriptions

### `/src/capture/`
Core capture engine components that handle CDP connections and response capture.

**Key Files:**
- `ai-response-capture.js` - Main orchestrator that coordinates all components
- `cdp-manager.js` - Manages Chrome DevTools Protocol connection and capture methods
- `stream-buffer.js` - Buffers streaming responses and handles deduplication

### `/src/adapters/`
Platform-specific adapters that handle unique capture logic for each AI service.

**Key Files:**
- `base-adapter.js` - Abstract base class that all adapters extend
- `claude.js` - WebSocket-based capture for Claude
- `chatgpt.js` - SSE-based capture for ChatGPT
- `perplexity.js` - Network API capture for Perplexity
- `gemini.js` - MutationObserver capture for Gemini
- `copilot.js` - SSE-based capture for Copilot

### `/src/storage/`
Database layer for persistent storage of conversations and messages.

**Key Files:**
- `database.js` - SQLite operations, schema management, and queries

### `/src/utils/`
Utility modules used across the framework.

**Key Files:**
- `logger.js` - Colored console output with log levels
- `response-normalizer.js` - Converts platform-specific formats to unified schema

### `/ahk/`
AutoHotkey integration for Windows automation.

**Key Files:**
- `AIMessaging.ahk` - Main library with classes for each platform
- `example-usage.ahk` - Example scripts and hotkey bindings

### `/examples/`
Example scripts demonstrating various use cases.

**Key Files:**
- `basic-usage.js` - Simple capture setup
- `automated-conversation.js` - Sending messages and capturing responses
- `multi-platform-capture.js` - Capturing from multiple platforms
- `database-queries.js` - Querying conversation history

### `/docs/`
Detailed documentation.

**Key Files:**
- `SETUP_GUIDE.md` - Complete installation and setup instructions
- `API_REFERENCE.md` - Full API documentation with examples

### `/data/`
Runtime data directory (created automatically).

**Contents:**
- `conversations.db` - SQLite database with all captured data
- `*.db-wal`, `*.db-shm` - SQLite write-ahead log files

## Configuration Files

### `capture_config.json`
Main configuration file controlling:
- CDP connection settings
- Enabled capture methods
- Platform-specific selectors
- Storage settings
- Monitoring preferences

### `package.json`
Node.js project configuration with:
- Dependencies
- Scripts (start, monitor, test)
- Project metadata

## Entry Points

### For Users

**Basic Capture:**
```bash
npm start                    # Run basic capture
```

**Real-time Monitor:**
```bash
npm run monitor             # Run monitoring console
```

**Examples:**
```bash
node examples/basic-usage.js
node examples/automated-conversation.js
```

**AutoHotkey (Windows):**
```bash
ahk\example-usage.ahk       # Run AHK examples
```

### For Developers

**Main Module:**
```javascript
import AIResponseCapture from './src/capture/ai-response-capture.js';
```

**Individual Components:**
```javascript
import CDPManager from './src/capture/cdp-manager.js';
import ClaudeAdapter from './src/adapters/claude.js';
import ConversationDatabase from './src/storage/database.js';
```

## Data Flow

```
Browser (AI Platform)
    ↓
Chrome DevTools Protocol (Port 9222)
    ↓
CDPManager (Capture Methods)
    ↓
Platform Adapter (Extract Response)
    ↓
StreamBuffer (Buffer & Deduplicate)
    ↓
ResponseNormalizer (Unified Format)
    ↓
ConversationDatabase (SQLite Storage)
    ↓
User Callback / Monitor Display
```

## Capture Methods Flow

```
WebSocket Frames → CDPManager.onCapture('websocket')
SSE Events → CDPManager.onCapture('sse')
Network Requests → CDPManager.onCapture('network')
Console Logs → CDPManager.onCapture('console')
DOM Mutations → CDPManager.onCapture('mutation')
DOM Scraping → CDPManager.scrapeDOMContent()
    ↓
Platform Adapter.extractResponse()
    ↓
AIResponseCapture.handleCapturedResponse()
```

## Database Schema

```
conversations
├── id (TEXT, PRIMARY KEY)
├── platform (TEXT)
├── title (TEXT)
├── created_at (INTEGER)
├── updated_at (INTEGER)
└── metadata (TEXT)

messages
├── id (TEXT, PRIMARY KEY)
├── conversation_id (TEXT, FOREIGN KEY)
├── platform (TEXT)
├── role (TEXT)
├── content_text (TEXT)
├── content_markdown (TEXT)
├── content_html (TEXT)
├── model (TEXT)
├── timestamp (INTEGER)
├── capture_method (TEXT)
├── metadata (TEXT)
└── raw_data (TEXT)

code_blocks
├── id (INTEGER, PRIMARY KEY)
├── message_id (TEXT, FOREIGN KEY)
├── language (TEXT)
├── code (TEXT)
├── start_pos (INTEGER)
└── end_pos (INTEGER)

capture_events
├── id (INTEGER, PRIMARY KEY)
├── timestamp (INTEGER)
├── platform (TEXT)
├── method (TEXT)
├── success (INTEGER)
├── latency (INTEGER)
├── error (TEXT)
└── metadata (TEXT)
```

## Extension Points

### Adding a New Platform

1. Create adapter in `/src/adapters/new-platform.js`
2. Extend `BaseAdapter`
3. Implement `extractResponse()` method
4. Add configuration to `capture_config.json`
5. Register in `ai-response-capture.js`

### Adding a New Capture Method

1. Add method to `CDPManager`
2. Implement CDP event listeners
3. Add to configuration options
4. Update documentation

### Custom Response Processing

1. Extend `ResponseNormalizer`
2. Override normalization methods
3. Add custom metadata extraction
4. Update database schema if needed

## Build & Deployment

### Development
```bash
npm install              # Install dependencies
npm start               # Run main script
npm run monitor         # Run monitor
```

### Production
```bash
# Set production config
export NODE_ENV=production

# Run with PM2 (process manager)
pm2 start src/index.js --name ai-capture

# Or as a service
node src/index.js > logs/capture.log 2>&1 &
```

## Testing

```bash
# Run examples as tests
node examples/basic-usage.js
node examples/automated-conversation.js
node examples/multi-platform-capture.js
node examples/database-queries.js
```

## Maintenance

### Database Cleanup
```javascript
const db = new ConversationDatabase('./data/conversations.db');
db.cleanOldData(30); // Keep last 30 days
```

### Log Rotation
```bash
# Rotate logs (if using file logging)
mv logs/capture.log logs/capture.log.1
touch logs/capture.log
```

### Backup
```bash
# Backup database
cp data/conversations.db backups/conversations-$(date +%Y%m%d).db
```