#!/bin/bash
# =============================================================================
# LLM Context Prep MCP Server - One-Line Installer
# =============================================================================
# Usage: curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash
#    or: curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash -s -- --method python
# =============================================================================

set -e

# Configuration
DOCKER_IMAGE="juliusolsson/llm-prep"
GITHUB_REPO="Juliusolsson05/llm-prep-mcp"
SERVER_NAME="llm-prep"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Parse arguments
METHOD="docker"
VERSION="latest"
while [[ $# -gt 0 ]]; do
    case $1 in
        --method)
            METHOD="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --help|-h)
            echo "LLM Context Prep MCP Server - Installer"
            echo ""
            echo "Usage: install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --method docker|python    Installation method (default: docker)"
            echo "  --version VERSION         Docker image version (default: latest)"
            echo "  --help                    Show this help"
            echo ""
            echo "Examples:"
            echo "  curl -fsSL https://raw.githubusercontent.com/${GITHUB_REPO}/main/scripts/install.sh | bash"
            echo "  curl -fsSL https://raw.githubusercontent.com/${GITHUB_REPO}/main/scripts/install.sh | bash -s -- --method python"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

print_banner() {
    echo ""
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   🚀 LLM Context Prep MCP Server Installer                    ║"
    echo "║                                                               ║"
    echo "║   Prepare comprehensive context documents for LLMs            ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }
print_step() { echo -e "${BLUE}▶ $1${NC}"; }

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

check_docker_running() {
    if docker info &> /dev/null 2>&1; then
        return 0
    else
        print_error "Docker is not running. Please start Docker Desktop."
        return 1
    fi
}

install_with_docker() {
    print_banner
    print_step "Installing via Docker..."
    echo ""

    # Check prerequisites
    echo -e "${BOLD}Checking prerequisites...${NC}"
    echo ""

    if ! check_command docker; then
        echo ""
        print_error "Docker is required but not installed."
        echo ""
        echo "Please install Docker Desktop:"
        echo "  • macOS: https://docs.docker.com/desktop/install/mac-install/"
        echo "  • Linux: https://docs.docker.com/engine/install/"
        echo ""
        exit 1
    fi

    if ! check_docker_running; then
        echo ""
        echo "Please start Docker Desktop and try again."
        exit 1
    fi

    if ! check_command claude; then
        echo ""
        print_error "Claude Code CLI is required but not installed."
        echo ""
        echo "Please install Claude Code:"
        echo "  https://claude.ai/download"
        echo ""
        echo "Or install via npm:"
        echo "  npm install -g @anthropic-ai/claude-code"
        echo ""
        exit 1
    fi

    echo ""
    print_step "Pulling Docker image: ${DOCKER_IMAGE}:${VERSION}..."
    echo ""

    if ! docker pull "${DOCKER_IMAGE}:${VERSION}"; then
        print_error "Failed to pull Docker image."
        echo ""
        echo "This could mean:"
        echo "  • The image hasn't been published yet"
        echo "  • Network connectivity issues"
        echo ""
        echo "Try the Python installation method instead:"
        echo "  curl -fsSL https://raw.githubusercontent.com/${GITHUB_REPO}/main/scripts/install.sh | bash -s -- --method python"
        exit 1
    fi

    echo ""
    print_step "Registering with Claude Code..."
    echo ""

    # Remove existing server if present (silently)
    claude mcp remove "$SERVER_NAME" 2>/dev/null || true

    # Add new server
    if claude mcp add "$SERVER_NAME" -s user -- docker run -i --rm -v '$(pwd):/workspace' "${DOCKER_IMAGE}:${VERSION}"; then
        print_success "MCP server registered successfully!"
    else
        print_error "Failed to register MCP server."
        echo ""
        echo "Try manually:"
        echo "  claude mcp add $SERVER_NAME -s user -- docker run -i --rm -v '\$(pwd):/workspace' ${DOCKER_IMAGE}:${VERSION}"
        exit 1
    fi

    print_success_message
}

install_with_python() {
    print_banner
    print_step "Installing via Python..."
    echo ""

    # Check prerequisites
    echo -e "${BOLD}Checking prerequisites...${NC}"
    echo ""

    if ! check_command python3; then
        print_error "Python 3.11+ is required but not installed."
        echo ""
        echo "Please install Python 3.11+:"
        echo "  • macOS: brew install python@3.11"
        echo "  • Linux: apt install python3.11 (or use pyenv)"
        exit 1
    fi

    # Check Python version
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if [[ $(echo "$PYTHON_VERSION < 3.11" | bc -l 2>/dev/null || python3 -c "print(1 if $PYTHON_VERSION < 3.11 else 0)") == "1" ]]; then
        print_warning "Python $PYTHON_VERSION detected. Python 3.11+ recommended."
    else
        print_success "Python $PYTHON_VERSION is installed"
    fi

    if ! check_command claude; then
        print_error "Claude Code CLI is required but not installed."
        echo ""
        echo "Please install Claude Code:"
        echo "  https://claude.ai/download"
        exit 1
    fi

    # Install uv if not present
    if ! command -v uv &> /dev/null; then
        echo ""
        print_info "Installing uv package manager..."
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # Add to PATH for current session
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

        if ! command -v uv &> /dev/null; then
            print_error "Failed to install uv. Please install manually:"
            echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
            exit 1
        fi
    fi
    print_success "uv package manager is installed"

    # Clone and setup
    INSTALL_DIR="$HOME/.local/share/llm-prep-mcp"
    echo ""
    print_step "Setting up in ${INSTALL_DIR}..."

    if [ -d "$INSTALL_DIR" ]; then
        print_info "Updating existing installation..."
        cd "$INSTALL_DIR"
        git fetch origin
        git reset --hard origin/main
    else
        print_info "Cloning repository..."
        git clone "https://github.com/${GITHUB_REPO}.git" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi

    # Create venv and install dependencies
    echo ""
    print_step "Installing dependencies..."
    uv venv --quiet
    uv pip install --quiet -r requirements.txt

    echo ""
    print_step "Registering with Claude Code..."

    # Remove existing server if present (silently)
    claude mcp remove "$SERVER_NAME" 2>/dev/null || true

    # Add new server using uv run
    if claude mcp add "$SERVER_NAME" -s user -- uv --directory "$INSTALL_DIR" run python src/mcp_server_fastmcp.py --transport stdio; then
        print_success "MCP server registered successfully!"
    else
        print_error "Failed to register MCP server."
        exit 1
    fi

    print_success_message
}

print_success_message() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║  🎉 LLM Prep MCP Server installed successfully!               ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo ""
    echo "  1. ${CYAN}Restart Claude Code${NC} (or start a new session)"
    echo ""
    echo "  2. Verify installation:"
    echo -e "     ${CYAN}claude mcp list${NC}"
    echo ""
    echo "  3. Try it out! In Claude Code, ask:"
    echo -e "     ${CYAN}\"Use llm-prep to analyze this project\"${NC}"
    echo ""
    echo "  4. Or use specific tools:"
    echo -e "     ${CYAN}\"Use llm-prep to prepare context for the src/ directory\"${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📚 Documentation: https://github.com/${GITHUB_REPO}"
    echo "🐛 Issues:        https://github.com/${GITHUB_REPO}/issues"
    echo ""
}

# Main
case "$METHOD" in
    docker)
        install_with_docker
        ;;
    python)
        install_with_python
        ;;
    *)
        print_error "Unknown method: $METHOD"
        print_info "Use --method docker or --method python"
        exit 1
        ;;
esac
