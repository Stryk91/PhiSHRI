# /build-mcp

Scaffold or rebuild the PhiSHRI MCP server.

## Usage
```
/build-mcp [target]
```

## Targets
- `release` - Build optimized release binary
- `debug` - Build debug binary with symbols
- `test` - Run test suite
- `clean` - Clean build artifacts

## Actions

### Default (release)
```bash
cd C:/Dev/PhiSHRI_MCP/phishri-mcp
cargo build --release
```

### Output
```
Building phishri-mcp...
Target: release
Binary: target/release/phishri-mcp.exe
Size: ~2.3 MB

Run tests? (y/n)
```

### Test Sequence
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"...}' | ./target/release/phishri-mcp
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"...}' | ./target/release/phishri-mcp
```

## Cross-Platform Builds
```bash
# Windows
cargo build --release --target x86_64-pc-windows-msvc

# Linux
cargo build --release --target x86_64-unknown-linux-gnu

# macOS Intel
cargo build --release --target x86_64-apple-darwin

# macOS ARM
cargo build --release --target aarch64-apple-darwin
```
