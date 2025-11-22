# Skill: MCP Development

## When to Activate
- User mentions MCP, Model Context Protocol
- Building stdio-based tool servers
- JSON-RPC implementation
- Claude Desktop integration

## MCP Protocol Essentials

### Communication
- Transport: stdio (stdin/stdout)
- Format: JSON-RPC 2.0
- No HTTP, no WebSocket - pure stdio

### Message Flow
```
Client                    Server
  |-- initialize -------->|
  |<----- result ---------|
  |-- tools/list -------->|
  |<----- tools[] --------|
  |-- tools/call -------->|
  |<----- result ---------|
```

### Required Handlers
```rust
match method {
    "initialize" => handle_initialize(),
    "tools/list" => handle_list_tools(),
    "tools/call" => handle_tool_call(params),
    _ => error_method_not_found()
}
```

### Tool Definition Schema
```json
{
  "name": "tool_name",
  "description": "What the tool does",
  "inputSchema": {
    "type": "object",
    "properties": {
      "param1": { "type": "string", "description": "..." }
    },
    "required": ["param1"]
  }
}
```

### Claude Desktop Config
```json
{
  "mcpServers": {
    "server-name": {
      "command": "/path/to/binary",
      "args": ["--flag"],
      "env": { "VAR": "value" }
    }
  }
}
```

## PhiSHRI MCP Tools (10)

| Tool | Purpose |
|------|---------|
| phishri_read_door | Read single door by code |
| phishri_list_doors | List doors by category |
| phishri_find_door | Fuzzy search doors |
| phishri_load_chain | Load multiple doors |
| phishri_get_bootstrap | Get session state |
| phishri_update_bootstrap | Update session state |
| phishri_session_checkpoint | Create checkpoint |
| phishri_search_semantic | Search by path |
| phishri_get_prerequisites | Get prereq chain |
| phishri_rebuild_indexes | Rebuild indexes |

## Testing MCP Servers
```bash
# Send initialize
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | ./server

# Send tools/list
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | ./server

# Call a tool
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"tool","arguments":{}}}' | ./server
```

## Common Issues
- **Hanging:** Server waiting for more input - ensure single-line JSON
- **Parse errors:** Escaped quotes in nested JSON
- **No response:** Check stderr for panics/errors
- **Permission denied:** Binary not executable
