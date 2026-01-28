#!/bin/bash
set -e

# Ralph Kanban Installer
# Usage: curl -sSL https://raw.githubusercontent.com/dontambostep/ralph-kanban/main/install.sh | bash

REPO="dontambostep/ralph-kanban"
INSTALL_DIR="${RALPH_KANBAN_INSTALL_DIR:-$HOME/.ralph-kanban}"
BIN_DIR="${RALPH_KANBAN_BIN_DIR:-$HOME/.local/bin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Detect OS and architecture
detect_platform() {
    local os arch

    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="macos" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) error "Unsupported OS: $(uname -s)" ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="x64" ;;
        arm64|aarch64) arch="arm64" ;;
        *) error "Unsupported architecture: $(uname -m)" ;;
    esac

    echo "${os}-${arch}"
}

# Get latest release tag from GitHub
get_latest_version() {
    curl -sSL "https://api.github.com/repos/${REPO}/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/'
}

# Download and extract binary
download_binary() {
    local platform="$1"
    local version="$2"
    local binary_name="$3"
    local url="https://github.com/${REPO}/releases/download/${version}/${platform}-${binary_name}.zip"
    local tmp_dir=$(mktemp -d)
    local zip_file="${tmp_dir}/${binary_name}.zip"

    info "Downloading ${binary_name} for ${platform}..."

    if command -v curl &> /dev/null; then
        curl -sSL -o "$zip_file" "$url" || error "Failed to download from $url"
    elif command -v wget &> /dev/null; then
        wget -q -O "$zip_file" "$url" || error "Failed to download from $url"
    else
        error "Neither curl nor wget found. Please install one of them."
    fi

    info "Extracting ${binary_name}..."
    unzip -q -o "$zip_file" -d "$tmp_dir" || error "Failed to extract $zip_file"

    # Move binary to install dir
    mkdir -p "$INSTALL_DIR/bin"
    mv "${tmp_dir}/${binary_name}" "$INSTALL_DIR/bin/" 2>/dev/null || \
    mv "${tmp_dir}/${binary_name}.exe" "$INSTALL_DIR/bin/" 2>/dev/null || \
    error "Binary not found in archive"

    chmod +x "$INSTALL_DIR/bin/${binary_name}" 2>/dev/null || true

    # Cleanup
    rm -rf "$tmp_dir"
}

# Create wrapper script in bin directory
create_wrapper() {
    local name="$1"
    local target="$INSTALL_DIR/bin/$name"

    mkdir -p "$BIN_DIR"

    cat > "$BIN_DIR/$name" << EOF
#!/bin/bash
exec "$target" "\$@"
EOF
    chmod +x "$BIN_DIR/$name"
}

main() {
    echo ""
    echo "  ██████╗  █████╗ ██╗     ██████╗ ██╗  ██╗"
    echo "  ██╔══██╗██╔══██╗██║     ██╔══██╗██║  ██║"
    echo "  ██████╔╝███████║██║     ██████╔╝███████║"
    echo "  ██╔══██╗██╔══██║██║     ██╔═══╝ ██╔══██║"
    echo "  ██║  ██║██║  ██║███████╗██║     ██║  ██║"
    echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝"
    echo ""

    local platform=$(detect_platform)
    info "Detected platform: $platform"

    local version=$(get_latest_version)
    if [ -z "$version" ]; then
        error "Could not determine latest version. Check https://github.com/${REPO}/releases"
    fi
    info "Latest version: $version"

    # Download main binary
    download_binary "$platform" "$version" "ralph-kanban"

    # Create wrapper in PATH
    create_wrapper "ralph-kanban"

    # Optionally download MCP server
    if [ "${INSTALL_MCP:-0}" = "1" ]; then
        download_binary "$platform" "$version" "ralph-kanban-mcp"
        create_wrapper "ralph-kanban-mcp"
    fi

    echo ""
    info "Installation complete!"
    echo ""
    echo "  Installed to: $INSTALL_DIR"
    echo "  Wrapper at:   $BIN_DIR/ralph-kanban"
    echo ""

    # Check if BIN_DIR is in PATH
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        warn "$BIN_DIR is not in your PATH"
        echo ""
        echo "  Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo ""
        echo "    export PATH=\"\$PATH:$BIN_DIR\""
        echo ""
        echo "  Then restart your shell or run: source ~/.bashrc"
        echo ""
    fi

    echo "  To start Ralph Kanban, run:"
    echo ""
    echo "    ralph-kanban"
    echo ""
}

main "$@"
