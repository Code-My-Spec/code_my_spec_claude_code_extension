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

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}${BOLD}>>>${NC} $1"; }
ok()    { echo -e "${GREEN}${BOLD}>>>${NC} $1"; }
err()   { echo -e "${RED}${BOLD}>>>${NC} $1"; }

# Detect OS and architecture
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
    *)      err "Unsupported OS: $OS"; exit 1 ;;
  esac

  case "$ARCH" in
    arm64|aarch64) ARCH="arm64" ;;
    x86_64|amd64)  ARCH="x64" ;;
    *)              err "Unsupported architecture: $ARCH"; exit 1 ;;
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
    err "Could not find binary for ${BINARY_FILE}"
    echo "  Available binaries at: https://github.com/${REPO}/releases"
    exit 1
  fi
}

# Download and install binary
install_binary() {
  mkdir -p "$BIN_DIR"

  info "Downloading ${BINARY_FILE}..."
  curl -fSL --progress-bar -o "$BIN_DIR/$BINARY_NAME" "$DOWNLOAD_URL"

  chmod +x "$BIN_DIR/$BINARY_NAME"
}

# Main
main() {
  echo ""
  echo -e "${BOLD}CodeMySpec CLI Installer${NC}"
  echo ""

  detect_platform
  info "Platform: ${OS}-${ARCH}"

  if [ "$1" = "--dry-run" ]; then
    get_download_url
    echo "Would download from: $DOWNLOAD_URL"
    echo "Would install to: $BIN_DIR/$BINARY_NAME"
    exit 0
  fi

  get_download_url
  install_binary

  echo ""
  ok "Installation complete!"
  echo ""
  echo "  Next steps:"
  echo ""
  echo "  1. Install the plugin in Claude Code:"
  echo "     claude plugin install $SCRIPT_DIR"
  echo ""
  echo "  2. Open Claude Code in your Phoenix project and run:"
  echo "     /codemyspec:init auth"
  echo ""
}

main "$@"
