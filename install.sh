#!/usr/bin/env bash
#
# PhiSHRI MCP Installer for Linux/macOS
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash
#
# Or download and run:
#   ./install.sh [--method auto|manual] [--verify] [--uninstall]
#

set -e

# Configuration
VERSION="0.0.1"
GITHUB_REPO="Stryk91/PhiSHRI"
PHISHRI_ROOT="${PHISHRI_ROOT:-$HOME/.phishri}"

# Derived paths
BIN_DIR="$PHISHRI_ROOT/bin"
KNOWLEDGE_DIR="$PHISHRI_ROOT/knowledge"
SESSIONS_DIR="$PHISHRI_ROOT/sessions"
CONTEXTS_DIR="$KNOWLEDGE_DIR/CONTEXTS"
INDEXES_DIR="$KNOWLEDGE_DIR/INDEXES"
BINARY_PATH="$BIN_DIR/phishri-mcp"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Detect OS and architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Linux*)  PLATFORM="linux" ;;
        Darwin*) PLATFORM="darwin" ;;
        MINGW*|MSYS*|CYGWIN*)
            echo -e "${RED}[ERROR]${NC} Windows detected. Please use install.ps1 instead."
            exit 1
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unsupported OS: $OS"
            exit 1
            ;;
    esac

    case "$ARCH" in
        x86_64|amd64) ARCH="x64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    BINARY_NAME="phishri-mcp-${PLATFORM}-${ARCH}"
}

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print banner
print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'

  ____  _     _ ____  _   _ ____  ___
 |  _ \| |__ (_) ___|| | | |  _ \|_ _|
 | |_) | '_ \| \___ \| |_| | |_) || |
 |  __/| | | | |___) |  _  |  _ < | |
 |_|   |_| |_|_|____/|_| |_|_| \_\___|

EOF
    echo -e "  MCP Server Installer v${VERSION}"
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check for curl or wget
    if command -v curl &> /dev/null; then
        DOWNLOADER="curl"
    elif command -v wget &> /dev/null; then
        DOWNLOADER="wget"
    else
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    # Check for unzip or tar
    if ! command -v unzip &> /dev/null && ! command -v tar &> /dev/null; then
        log_error "Neither unzip nor tar found. Please install one of them."
        exit 1
    fi

    # Check for jq (optional but helpful)
    if command -v jq &> /dev/null; then
        HAS_JQ=true
    else
        HAS_JQ=false
        log_warn "jq not found - using basic JSON manipulation"
    fi

    log_ok "Prerequisites OK"
}

# Download function that works with curl or wget
download() {
    local url="$1"
    local output="$2"

    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fsSL "$url" -o "$output"
    else
        wget -q "$url" -O "$output"
    fi
}

# Download to stdout
download_stdout() {
    local url="$1"

    if [ "$DOWNLOADER" = "curl" ]; then
        curl -fsSL "$url"
    else
        wget -qO- "$url"
    fi
}

# Create directory structure
init_directories() {
    log_info "Creating directory structure..."

    mkdir -p "$BIN_DIR"
    mkdir -p "$KNOWLEDGE_DIR"
    mkdir -p "$SESSIONS_DIR"
    mkdir -p "$CONTEXTS_DIR"
    mkdir -p "$INDEXES_DIR"

    log_ok "Directory structure created"
}

# Check if Rust/Cargo is available for building from source
check_rust() {
    # Check if cargo is in PATH
    if command -v cargo &> /dev/null; then
        return 0
    fi

    # Check common Rust install locations
    if [ -f "$HOME/.cargo/bin/cargo" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
        return 0
    fi

    # Try sourcing cargo env
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env" 2>/dev/null
        if command -v cargo &> /dev/null; then
            return 0
        fi
    fi

    return 1
}

# Build from source
build_from_source() {
    log_info "Building PhiSHRI MCP from source..."

    local temp_dir=$(mktemp -d)
    local repo_url="https://github.com/${GITHUB_REPO}/archive/refs/heads/main.zip"

    # Download source
    log_info "  Downloading source..."
    download "$repo_url" "$temp_dir/source.zip"

    # Extract
    log_info "  Extracting..."
    unzip -q "$temp_dir/source.zip" -d "$temp_dir"

    # Find extracted folder and mcp-server subfolder
    local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "PhiSHRI*" | head -1)
    local source_dir="$extracted_dir/mcp-server"

    if [ -z "$extracted_dir" ] || [ ! -d "$source_dir" ]; then
        log_error "Could not find mcp-server source directory"
        rm -rf "$temp_dir"
        return 1
    fi

    # Build
    log_info "  Building (this may take a few minutes)..."
    cd "$source_dir"
    cargo build --release 2>&1 | tail -5

    # Copy binary
    if [ -f "target/release/phishri-mcp" ]; then
        cp "target/release/phishri-mcp" "$BINARY_PATH"
        chmod +x "$BINARY_PATH"
        log_ok "Binary built successfully"
    else
        log_error "Build failed - binary not found"
        rm -rf "$temp_dir"
        return 1
    fi

    # Cleanup
    rm -rf "$temp_dir"
    return 0
}

# Install binary (download prebuilt or build from source)
install_binary() {
    log_info "Installing PhiSHRI MCP binary..."

    # Try to download prebuilt binary first
    local release_url="https://github.com/${GITHUB_REPO}/releases/latest/download/${BINARY_NAME}"
    local temp_binary=$(mktemp)

    log_info "  Trying prebuilt binary: $BINARY_NAME"

    if download "$release_url" "$temp_binary" 2>/dev/null; then
        # Verify it's actually a binary (not HTML error page)
        if file "$temp_binary" | grep -qE "(executable|ELF|Mach-O)"; then
            mv "$temp_binary" "$BINARY_PATH"
            chmod +x "$BINARY_PATH"
            log_ok "Prebuilt binary installed"
            return 0
        else
            log_warn "Downloaded file is not a valid binary"
            rm -f "$temp_binary"
        fi
    else
        rm -f "$temp_binary"
        log_warn "Prebuilt binary not available for $PLATFORM-$ARCH"
    fi

    # Fallback: build from source
    if check_rust; then
        log_info "Building from source (Rust found)..."
        if build_from_source; then
            return 0
        fi
    else
        log_warn "Rust not installed. Install Rust to build from source:"
        echo "    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo ""
    fi

    log_error "Could not install binary. Options:"
    echo "  1. Install Rust and re-run this script to build from source"
    echo "  2. Download a prebuilt binary manually from GitHub releases"
    return 1
}

# Install knowledge base
install_knowledge_base() {
    log_info "Downloading PhiSHRI knowledge base..."

    local temp_dir=$(mktemp -d)
    local zip_url="https://github.com/${GITHUB_REPO}/archive/refs/heads/main.zip"

    # Download
    log_info "  Downloading knowledge base archive..."
    download "$zip_url" "$temp_dir/kb.zip"

    # Extract
    log_info "  Extracting..."
    unzip -q "$temp_dir/kb.zip" -d "$temp_dir"

    # Find PhiSHRI folder
    local extracted=$(find "$temp_dir" -maxdepth 1 -type d -name "PhiSHRI*" | head -1)
    local source_kb="$extracted/PhiSHRI"

    if [ ! -d "$source_kb" ]; then
        log_error "Knowledge base not found in archive"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy CONTEXTS
    if [ -d "$source_kb/CONTEXTS" ]; then
        log_info "  Copying CONTEXTS..."
        cp -r "$source_kb/CONTEXTS/"* "$CONTEXTS_DIR/"
    fi

    # Copy INDEXES
    if [ -d "$source_kb/INDEXES" ]; then
        log_info "  Copying INDEXES..."
        cp -r "$source_kb/INDEXES/"* "$INDEXES_DIR/"
    else
        # Fallback: copy from root
        [ -f "$source_kb/HASH_TABLE.json" ] && cp "$source_kb/HASH_TABLE.json" "$INDEXES_DIR/"
        [ -f "$source_kb/SEMANTIC_MAP.json" ] && cp "$source_kb/SEMANTIC_MAP.json" "$INDEXES_DIR/"
    fi

    # Cleanup
    rm -rf "$temp_dir"

    log_ok "Knowledge base installed"
}

# Find Claude Desktop config path
find_claude_config() {
    local config_path=""

    if [ "$PLATFORM" = "darwin" ]; then
        # macOS: Check Application Support
        config_path="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
        config_dir="$HOME/Library/Application Support/Claude"
    else
        # Linux: Check XDG config or .config
        if [ -n "$XDG_CONFIG_HOME" ]; then
            config_path="$XDG_CONFIG_HOME/Claude/claude_desktop_config.json"
            config_dir="$XDG_CONFIG_HOME/Claude"
        else
            config_path="$HOME/.config/Claude/claude_desktop_config.json"
            config_dir="$HOME/.config/Claude"
        fi
    fi

    echo "$config_path"
}

# Configure Claude Desktop
configure_claude_desktop() {
    log_info "Configuring Claude Desktop..."

    local config_path=$(find_claude_config)
    local config_dir=$(dirname "$config_path")

    # Create config directory if needed
    mkdir -p "$config_dir"

    # Build MCP config JSON
    local mcp_config=$(cat << EOF
{
  "command": "$BINARY_PATH",
  "args": [],
  "env": {
    "PHISHRI_PATH": "$KNOWLEDGE_DIR",
    "PHISHRI_SESSION_ROOT": "$PHISHRI_ROOT"
  }
}
EOF
)

    if [ -f "$config_path" ]; then
        # Config exists - merge
        log_info "  Found existing config, merging..."

        if [ "$HAS_JQ" = true ]; then
            # Use jq for proper JSON manipulation
            local temp_config=$(mktemp)
            jq --argjson phishri "$mcp_config" '.mcpServers.phishri = $phishri' "$config_path" > "$temp_config"
            mv "$temp_config" "$config_path"
        else
            # Backup and use basic manipulation
            cp "$config_path" "${config_path}.backup.$(date +%Y%m%d%H%M%S)"

            # Check if mcpServers exists
            if grep -q '"mcpServers"' "$config_path"; then
                # Try to add phishri to existing mcpServers
                # This is fragile without jq, so warn user
                log_warn "Manual config merge may be needed (install jq for better handling)"
                show_manual_config
                return 1
            else
                # Add mcpServers section
                local temp_config=$(mktemp)
                # Remove trailing } and add mcpServers
                sed '$ s/}$//' "$config_path" > "$temp_config"
                echo ',' >> "$temp_config"
                echo '"mcpServers": {' >> "$temp_config"
                echo "  \"phishri\": $mcp_config" >> "$temp_config"
                echo '}' >> "$temp_config"
                echo '}' >> "$temp_config"
                mv "$temp_config" "$config_path"
            fi
        fi
    else
        # Create new config
        log_info "  Creating new config..."
        cat > "$config_path" << EOF
{
  "mcpServers": {
    "phishri": $mcp_config
  }
}
EOF
    fi

    log_ok "Claude Desktop configured at: $config_path"
    return 0
}

# Configure Claude Code CLI
configure_claude_code() {
    log_info "Checking for Claude Code CLI..."

    if command -v claude &> /dev/null; then
        log_info "  Found Claude Code CLI, configuring..."

        # Add MCP server
        claude mcp add phishri "$BINARY_PATH" \
            --env "PHISHRI_PATH=$KNOWLEDGE_DIR" \
            --env "PHISHRI_SESSION_ROOT=$PHISHRI_ROOT" 2>/dev/null || true

        log_ok "Claude Code CLI configured"
        return 0
    else
        log_info "  Claude Code CLI not found (skipping)"
        return 0
    fi
}

# Show manual configuration instructions
show_manual_config() {
    echo ""
    echo -e "${YELLOW}Manual Configuration Required${NC}"
    echo ""
    echo "Add this to your Claude Desktop config:"
    echo ""
    echo -e "${CYAN}"
    cat << EOF
{
  "mcpServers": {
    "phishri": {
      "command": "$BINARY_PATH",
      "args": [],
      "env": {
        "PHISHRI_PATH": "$KNOWLEDGE_DIR",
        "PHISHRI_SESSION_ROOT": "$PHISHRI_ROOT"
      }
    }
  }
}
EOF
    echo -e "${NC}"
    echo ""
    echo "Config file location:"
    echo "  $(find_claude_config)"
    echo ""
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    local errors=0

    # Check binary
    if [ -f "$BINARY_PATH" ] && [ -x "$BINARY_PATH" ]; then
        local size=$(stat -f%z "$BINARY_PATH" 2>/dev/null || stat -c%s "$BINARY_PATH" 2>/dev/null)
        log_ok "  Binary: OK ($(numfmt --to=iec $size 2>/dev/null || echo "${size} bytes"))"
    else
        log_error "  Binary: NOT FOUND at $BINARY_PATH"
        ((errors++))
    fi

    # Check CONTEXTS
    local door_count=$(find "$CONTEXTS_DIR" -name "*.json" -type f 2>/dev/null | wc -l)
    if [ "$door_count" -gt 0 ]; then
        log_ok "  CONTEXTS: OK ($door_count doors)"
    else
        log_error "  CONTEXTS: No doors found"
        ((errors++))
    fi

    # Check INDEXES
    if [ -f "$INDEXES_DIR/HASH_TABLE.json" ]; then
        log_ok "  HASH_TABLE.json: OK"
    else
        log_warn "  HASH_TABLE.json: Not found (will be rebuilt on first run)"
    fi

    # Check Claude config
    local config_path=$(find_claude_config)
    if [ -f "$config_path" ] && grep -q '"phishri"' "$config_path" 2>/dev/null; then
        log_ok "  Claude Desktop config: OK"
    else
        log_warn "  Claude Desktop config: PhiSHRI not found (may need manual setup)"
    fi

    echo ""
    if [ "$errors" -eq 0 ]; then
        log_ok "Installation verified successfully!"
        return 0
    else
        log_error "Installation has $errors error(s)"
        return 1
    fi
}

# Test that MCP can start
test_mcp() {
    log_info "Testing MCP server..."

    if [ ! -x "$BINARY_PATH" ]; then
        log_error "Binary not executable"
        return 1
    fi

    # Try to start and quickly stop
    timeout 2 "$BINARY_PATH" --help &>/dev/null || true

    # Just verify it exists and is reasonable size
    local size=$(stat -f%z "$BINARY_PATH" 2>/dev/null || stat -c%s "$BINARY_PATH" 2>/dev/null)
    if [ "$size" -gt 1000000 ]; then
        log_ok "MCP binary appears valid ($(numfmt --to=iec $size 2>/dev/null || echo "${size} bytes"))"
        return 0
    fi

    log_warn "MCP binary seems small - may be corrupted"
    return 1
}

# Uninstall
uninstall_phishri() {
    print_banner
    log_info "Uninstalling PhiSHRI..."

    # Remove installation directory
    if [ -d "$PHISHRI_ROOT" ]; then
        rm -rf "$PHISHRI_ROOT"
        log_ok "Removed $PHISHRI_ROOT"
    fi

    # Remove from Claude Desktop config
    local config_path=$(find_claude_config)
    if [ -f "$config_path" ] && [ "$HAS_JQ" = true ]; then
        if grep -q '"phishri"' "$config_path"; then
            local temp_config=$(mktemp)
            jq 'del(.mcpServers.phishri)' "$config_path" > "$temp_config"
            mv "$temp_config" "$config_path"
            log_ok "Removed from Claude Desktop config"
        fi
    fi

    # Remove from Claude Code CLI
    if command -v claude &> /dev/null; then
        claude mcp remove phishri 2>/dev/null || true
        log_ok "Removed from Claude Code CLI"
    fi

    echo ""
    log_ok "PhiSHRI has been uninstalled"
    echo ""
}

# Main installation
install_phishri() {
    local method="${1:-auto}"

    print_banner

    detect_platform
    log_info "Detected platform: $PLATFORM-$ARCH"
    echo ""

    check_prerequisites
    init_directories

    if ! install_binary; then
        log_error "Binary installation failed"
        exit 1
    fi

    install_knowledge_base

    case "$method" in
        auto)
            configure_claude_desktop || true
            configure_claude_code || true
            ;;
        manual)
            show_manual_config
            ;;
    esac

    echo ""
    test_mcp || true
    verify_installation || true

    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart Claude Desktop (if using)"
    echo "  2. Look for 'phishri' in the MCP servers list"
    echo "  3. Try asking: 'What doors are available?'"
    echo ""
    echo "To verify installation later, run:"
    echo "  $0 --verify"
    echo ""
}

# Parse arguments
METHOD="auto"
VERIFY_ONLY=false
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --method)
            METHOD="$2"
            shift 2
            ;;
        --verify)
            VERIFY_ONLY=true
            shift
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --help|-h)
            echo "PhiSHRI MCP Installer v${VERSION}"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --method auto|manual    Installation method (default: auto)"
            echo "  --verify                Verify existing installation"
            echo "  --uninstall             Remove PhiSHRI"
            echo "  --help, -h              Show this help"
            echo ""
            echo "One-liner install:"
            echo "  curl -fsSL https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh | bash"
            echo ""
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main entry point
if [ "$UNINSTALL" = true ]; then
    detect_platform
    check_prerequisites
    uninstall_phishri
elif [ "$VERIFY_ONLY" = true ]; then
    detect_platform
    check_prerequisites
    print_banner
    verify_installation
    test_mcp
else
    install_phishri "$METHOD"
fi
