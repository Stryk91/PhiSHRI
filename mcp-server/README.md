# PhiSHRI MCP Server

Rust implementation of the PhiSHRI MCP (Model Context Protocol) server.

## Building from Source

```bash
cd mcp-server
cargo build --release
```

The binary will be at `target/release/phishri-mcp`.

## Configuration

Set environment variables:
- `PHISHRI_PATH` - Path to knowledge base (CONTEXTS folder)
- `PHISHRI_SESSION_ROOT` - Root for session storage

## License

MIT
