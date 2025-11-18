# Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           USER INTERFACE                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐│
│  │   Monitor    │  │  Examples    │  │     API      │  │     AHK     ││
│  │   Console    │  │   Scripts    │  │   Callback   │  │   Scripts   ││
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────────────┘│
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                      AI RESPONSE CAPTURE ENGINE                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    AIResponseCapture                                │ │
│  │  • Platform Detection    • Capture Orchestration                   │ │
│  │  • Response Processing   • Event Management                        │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                         CAPTURE LAYER                                    │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                        CDP Manager                                │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │  │
│  │  │WebSocket │  │   SSE    │  │ Network  │  │ Console  │        │  │
│  │  │Intercept │  │ Monitor  │  │ Capture  │  │  Hook    │        │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │  │
│  │  ┌──────────┐  ┌──────────┐                                     │  │
│  │  │Mutation  │  │   DOM    │                                     │  │
│  │  │Observer  │  │ Scraper  │                                     │  │
│  │  └──────────┘  └──────────┘                                     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                       PLATFORM ADAPTERS                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│
│  │  Claude  │  │ ChatGPT  │  │Perplexity│  │  Gemini  │  │ Copilot  ││
│  │ Adapter  │  │ Adapter  │  │ Adapter  │  │ Adapter  │  │ Adapter  ││
│  │          │  │          │  │          │  │          │  │          ││
│  │WebSocket │  │   SSE    │  │ Network  │  │Mutation  │  │   SSE    ││
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘│
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                      PROCESSING PIPELINE                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│  │  Stream Buffer   │→ │Response Normalizer│→ │  Deduplication   │     │
│  │                  │  │                   │  │                  │     │
│  │• Buffer chunks   │  │• Unified schema   │  │• Similarity check│     │
│  │• Timeout mgmt    │  │• Code extraction  │  │• Time window     │     │
│  │• Method priority │  │• Metadata capture │  │• Content compare │     │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                         STORAGE LAYER                                    │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      SQLite Database                                │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │ │
│  │  │Conversations │  │   Messages   │  │ Code Blocks  │            │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘            │ │
│  │  ┌──────────────┐                                                 │ │
│  │  │Capture Events│                                                 │ │
│  │  └──────────────┘                                                 │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                      EXTERNAL INTERFACES                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐│
│  │   Browser    │  │     CDP      │  │   AutoHotkey │  │  File System││
│  │  (Chrome)    │  │  (Port 9222) │  │   (Windows)  │  │   (SQLite)  ││
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────────────┘│
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────┐
│   Browser   │
│ AI Platform │
└──────┬──────┘
       │ AI Response Generated
       ↓
┌─────────────────────────────────────────────────────────┐
│              6 Capture Methods (Parallel)                │
├─────────────────────────────────────────────────────────┤
│ 1. WebSocket Frame → [WS Data]                          │
│ 2. SSE Event       → [SSE Data]                         │
│ 3. Network Call    → [API Data]                         │
│ 4. Console Log     → [Log Data]                         │
│ 5. DOM Mutation    → [DOM Data]                         │
│ 6. DOM Scraping    → [Scraped Data]                     │
└─────────────────────────────────────────────────────────┘
       │ Multiple capture events
       ↓
┌─────────────────────────────────────────────────────────┐
│              Platform Adapter                            │
├─────────────────────────────────────────────────────────┤
│ • Identify platform                                      │
│ • Extract response from raw data                         │
│ • Apply platform-specific parsing                        │
└─────────────────────────────────────────────────────────┘
       │ Extracted response
       ↓
┌─────────────────────────────────────────────────────────┐
│              Stream Buffer                               │
├─────────────────────────────────────────────────────────┤
│ • Buffer incomplete responses                            │
│ • Combine chunks from multiple methods                   │
│ • Wait for completion or timeout                         │
└─────────────────────────────────────────────────────────┘
       │ Complete response
       ↓
┌─────────────────────────────────────────────────────────┐
│              Response Normalizer                         │
├─────────────────────────────────────────────────────────┤
│ • Convert to unified schema                              │
│ • Parse markdown/HTML                                    │
│ • Extract code blocks                                    │
│ • Capture metadata                                       │
└─────────────────────────────────────────────────────────┘
       │ Normalized response
       ↓
┌─────────────────────────────────────────────────────────┐
│              Deduplication Check                         │
├─────────────────────────────────────────────────────────┤
│ • Compare with recent responses                          │
│ • Calculate similarity                                   │
│ • Filter duplicates                                      │
└─────────────────────────────────────────────────────────┘
       │ Unique response
       ↓
┌─────────────────────────────────────────────────────────┐
│              Database Storage                            │
├─────────────────────────────────────────────────────────┤
│ • Save to conversations table                            │
│ • Save to messages table                                 │
│ • Save code blocks                                       │
│ • Log capture event                                      │
└─────────────────────────────────────────────────────────┘
       │ Stored successfully
       ↓
┌─────────────────────────────────────────────────────────┐
│              User Callback / Monitor                     │
├─────────────────────────────────────────────────────────┤
│ • Trigger onResponseCaptured event                       │
│ • Display in monitor console                             │
│ • Update statistics                                      │
└─────────────────────────────────────────────────────────┘
```

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                     Initialization Phase                          │
└──────────────────────────────────────────────────────────────────┘

User Code
   │
   ├─→ new AIResponseCapture(config)
   │      │
   │      ├─→ Create CDPManager
   │      ├─→ Create StreamBuffer
   │      ├─→ Create ResponseNormalizer
   │      ├─→ Create Database
   │      └─→ Create Platform Adapters
   │
   ├─→ capture.initialize()
   │      │
   │      ├─→ CDPManager.connect()
   │      │      └─→ Connect to Chrome via Puppeteer
   │      │
   │      └─→ CDPManager.initializeCaptureMethods()
   │             ├─→ Enable WebSocket capture
   │             ├─→ Enable SSE capture
   │             ├─→ Enable Network capture
   │             ├─→ Enable Console capture
   │             ├─→ Enable Mutation capture
   │             └─→ Enable DOM scraping
   │
   └─→ capture.startCapture()
          │
          ├─→ Detect platform
          ├─→ Initialize platform adapter
          ├─→ Start DOM scraping interval
          └─→ Start mutation polling

┌──────────────────────────────────────────────────────────────────┐
│                      Capture Phase                                │
└──────────────────────────────────────────────────────────────────┘

Browser Event (AI Response)
   │
   ├─→ CDP Event Triggered
   │      │
   │      ├─→ WebSocket Frame Received
   │      ├─→ SSE Event Received
   │      ├─→ Network Response Received
   │      ├─→ Console API Called
   │      ├─→ DOM Mutation Detected
   │      └─→ DOM Content Scraped
   │
   └─→ CDPManager.onCapture(method, data)
          │
          └─→ Platform Adapter Handler
                 │
                 ├─→ adapter.extractResponse(data, method)
                 │      └─→ Platform-specific parsing
                 │
                 └─→ AIResponseCapture.handleCapturedResponse()
                        │
                        ├─→ StreamBuffer.addToBuffer()
                        │      └─→ Buffer chunks
                        │
                        ├─→ Check if complete
                        │
                        └─→ If complete:
                               │
                               ├─→ StreamBuffer.flushBuffer()
                               │      └─→ Combine chunks
                               │
                               ├─→ ResponseNormalizer.normalize()
                               │      └─→ Convert to unified format
                               │
                               ├─→ StreamBuffer.isDuplicate()
                               │      └─→ Check for duplicates
                               │
                               ├─→ Database.saveMessage()
                               │      └─→ Store in SQLite
                               │
                               └─→ Trigger onResponseCaptured callback
                                      └─→ User code / Monitor

┌──────────────────────────────────────────────────────────────────┐
│                      Query Phase                                  │
└──────────────────────────────────────────────────────────────────┘

User Code
   │
   ├─→ capture.getConversation(id)
   │      └─→ Database.getConversation(id)
   │             └─→ Query SQLite
   │
   ├─→ capture.searchMessages(query)
   │      └─→ Database.searchMessages(query)
   │             └─→ Full-text search
   │
   └─→ capture.getStats()
          └─→ Database.getCaptureStats()
                 └─→ Aggregate statistics
```

## Capture Method Priority

```
┌─────────────────────────────────────────────────────────┐
│              Capture Method Selection                    │
└─────────────────────────────────────────────────────────┘

Platform Detected
   │
   ├─→ Check Primary Method (from config)
   │      │
   │      ├─→ If WebSocket: Use WebSocket capture
   │      ├─→ If SSE: Use SSE capture
   │      ├─→ If Network: Use Network capture
   │      └─→ If Mutation: Use Mutation capture
   │
   ├─→ Enable Backup Methods
   │      │
   │      ├─→ Enable all configured methods
   │      └─→ Run in parallel
   │
   └─→ Response Received
          │
          ├─→ Multiple methods may capture
          │
          ├─→ StreamBuffer combines all
          │
          └─→ Deduplication removes duplicates

Priority Order (when multiple captures):
   1. WebSocket (lowest latency, most reliable)
   2. SSE (streaming, reliable)
   3. Network (complete responses)
   4. Mutation (DOM-based, reliable)
   5. DOM Scraping (fallback)
   6. Console (debugging only)
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────┐
│                  Error Handling                          │
└─────────────────────────────────────────────────────────┘

Error Occurs
   │
   ├─→ CDP Connection Error
   │      │
   │      ├─→ Log error
   │      ├─→ Attempt reconnection
   │      └─→ Throw if critical
   │
   ├─→ Capture Method Error
   │      │
   │      ├─→ Log error
   │      ├─→ Continue with other methods
   │      └─→ Log to capture_events table
   │
   ├─→ Platform Detection Error
   │      │
   │      ├─→ Log warning
   │      ├─→ Use generic capture
   │      └─→ Continue operation
   │
   ├─→ Response Processing Error
   │      │
   │      ├─→ Log error with raw data
   │      ├─→ Save raw data to database
   │      └─→ Continue with next response
   │
   └─→ Database Error
          │
          ├─→ Log error
          ├─→ Retry operation
          └─→ If critical, stop capture
```

## State Machine

```
┌─────────────────────────────────────────────────────────┐
│              Capture State Machine                       │
└─────────────────────────────────────────────────────────┘

[UNINITIALIZED]
      │
      │ initialize()
      ↓
[INITIALIZED]
      │
      │ startCapture()
      ↓
[CAPTURING]
      │
      ├─→ Response captured → [PROCESSING]
      │                            │
      │                            │ Process complete
      │                            ↓
      │                       [CAPTURING]
      │
      │ stopCapture()
      ↓
[STOPPED]
      │
      │ cleanup()
      ↓
[CLEANED_UP]
```