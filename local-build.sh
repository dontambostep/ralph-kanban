#!/bin/bash

set -e  # Exit on any error

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case "$ARCH" in
  x86_64)
    ARCH="x64"
    ;;
  arm64|aarch64)
    ARCH="arm64"
    ;;
  *)
    echo "Warning: Unknown architecture $ARCH, using as-is"
    ;;
esac

# Map OS names
case "$OS" in
  linux)
    OS="linux"
    ;;
  darwin)
    OS="macos"
    ;;
  *)
    echo "Warning: Unknown OS $OS, using as-is"
    ;;
esac

PLATFORM="${OS}-${ARCH}"

# Set CARGO_TARGET_DIR if not defined
if [ -z "$CARGO_TARGET_DIR" ]; then
  CARGO_TARGET_DIR="target"
fi

echo "Detected platform: $PLATFORM"
echo "Using target directory: $CARGO_TARGET_DIR"
echo "Cleaning previous builds..."
rm -rf npx-cli/dist
mkdir -p npx-cli/dist/$PLATFORM

echo "Building frontend..."
(cd frontend && npm run build)

echo "Building Rust binaries..."
cargo build --release --manifest-path Cargo.toml
cargo build --release --bin mcp_task_server --manifest-path Cargo.toml

echo "Creating distribution package..."

# Copy the main binary
cp ${CARGO_TARGET_DIR}/release/server ralph-kanban
zip -q ralph-kanban.zip ralph-kanban
rm -f ralph-kanban
mv ralph-kanban.zip npx-cli/dist/$PLATFORM/ralph-kanban.zip

# Copy the MCP binary
cp ${CARGO_TARGET_DIR}/release/mcp_task_server ralph-kanban-mcp
zip -q ralph-kanban-mcp.zip ralph-kanban-mcp
rm -f ralph-kanban-mcp
mv ralph-kanban-mcp.zip npx-cli/dist/$PLATFORM/ralph-kanban-mcp.zip

# Copy the Review CLI binary
cp ${CARGO_TARGET_DIR}/release/review ralph-kanban-review
zip -q ralph-kanban-review.zip ralph-kanban-review
rm -f ralph-kanban-review
mv ralph-kanban-review.zip npx-cli/dist/$PLATFORM/ralph-kanban-review.zip

echo "Build complete!"
echo "Files created:"
echo "   - npx-cli/dist/$PLATFORM/ralph-kanban.zip"
echo "   - npx-cli/dist/$PLATFORM/ralph-kanban-mcp.zip"
echo "   - npx-cli/dist/$PLATFORM/ralph-kanban-review.zip"
echo ""
echo "To test locally, run:"
echo "   cd npx-cli && node bin/cli.js"
