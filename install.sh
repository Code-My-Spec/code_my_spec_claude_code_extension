#!/bin/bash
# CodeMySpec CLI Installer
# Downloads the appropriate binary for your platform from GitHub Releases

set -e

REPO="Code-My-Spec/code_my_spec_claude_code_extension"
BINARY_NAME="cms"
VERSION="${CMS_VERSION:-latest}"

# Determine script directory (where extension is installed)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"

# Detect OS and architecture
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin) OS="darwin" ;;
    Linux) OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
  esac

  case "$ARCH" in
    arm64|aarch64) ARCH="arm64" ;;
    x86_64|amd64) ARCH="x64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
  esac

  if [ "$OS" = "windows" ]; then
    BINARY_FILE="${BINARY_NAME}-${OS}-${ARCH}.exe"
  else
    BINARY_FILE="${BINARY_NAME}-${OS}-${ARCH}"
  fi
}

# Get download URL from GitHub releases
get_download_url() {
  if [ "$VERSION" = "latest" ]; then
    RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"
  else
    RELEASE_URL="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}"
  fi

  DOWNLOAD_URL=$(curl -s "$RELEASE_URL" | grep "browser_download_url.*${BINARY_FILE}" | cut -d '"' -f 4)

  if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find binary for ${BINARY_FILE}"
    echo "Available binaries at: https://github.com/${REPO}/releases"
    exit 1
  fi
}

# Download and install binary
install_binary() {
  echo "Creating bin directory..."
  mkdir -p "$BIN_DIR"

  echo "Downloading ${BINARY_FILE}..."
  curl -L -o "$BIN_DIR/$BINARY_NAME" "$DOWNLOAD_URL"

  echo "Making binary executable..."
  chmod +x "$BIN_DIR/$BINARY_NAME"
}

# Main
main() {
  echo "CodeMySpec CLI Installer"
  echo "========================"
  echo ""

  detect_platform
  echo "Detected platform: ${OS}-${ARCH}"
  echo "Binary: ${BINARY_FILE}"
  echo ""

  if [ "$1" = "--dry-run" ]; then
    get_download_url
    echo "Would download from: $DOWNLOAD_URL"
    echo "Would install to: $BIN_DIR/$BINARY_NAME"
    exit 0
  fi

  get_download_url
  install_binary

  echo ""
  echo "Installation complete!"
  echo ""
  echo "Binary installed to: $BIN_DIR/$BINARY_NAME"
  echo ""
  echo "To add the extension to Claude Code:"
  echo "  claude extension add $SCRIPT_DIR"
  echo ""
  echo "To verify installation:"
  echo "  $BIN_DIR/$BINARY_NAME --help"
}

main "$@"
