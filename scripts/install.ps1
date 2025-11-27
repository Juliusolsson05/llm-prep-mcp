<#
.SYNOPSIS
    LLM Context Prep MCP Server - Windows Installer

.DESCRIPTION
    One-line installer for the LLM Context Prep MCP Server.
    Supports both Docker and Python installation methods.

.PARAMETER Method
    Installation method: "docker" (default) or "python"

.PARAMETER Version
    Docker image version (default: "latest")

.EXAMPLE
    # One-line install (run in PowerShell):
    irm https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.ps1 | iex

.EXAMPLE
    # Install using Python instead of Docker:
    .\install.ps1 -Method python

.LINK
    https://github.com/Juliusolsson05/llm-prep-mcp
#>

param(
    [ValidateSet("docker", "python")]
    [string]$Method = "docker",

    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

# Configuration
$DOCKER_IMAGE = "juliusolsson/llm-prep"
$GITHUB_REPO = "Juliusolsson05/llm-prep-mcp"
$SERVER_NAME = "llm-prep"

# Helper Functions
function Write-Banner {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                               ║" -ForegroundColor Cyan
    Write-Host "║   🚀 LLM Context Prep MCP Server Installer                    ║" -ForegroundColor Cyan
    Write-Host "║                                                               ║" -ForegroundColor Cyan
    Write-Host "║   Prepare comprehensive context documents for LLMs            ║" -ForegroundColor Cyan
    Write-Host "║                                                               ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

function Write-Step {
    param([string]$Message)
    Write-Host "▶ $Message" -ForegroundColor Blue
}

function Test-Command {
    param([string]$Command)
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            Write-Success "$Command is installed"
            return $true
        }
    } catch {}
    Write-Error "$Command is not installed"
    return $false
}

function Test-DockerRunning {
    try {
        $null = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
    } catch {}
    Write-Error "Docker is not running. Please start Docker Desktop."
    return $false
}

function Install-WithDocker {
    Write-Banner
    Write-Step "Installing via Docker..."
    Write-Host ""

    # Check prerequisites
    Write-Host "Checking prerequisites..." -ForegroundColor White
    Write-Host ""

    if (-not (Test-Command "docker")) {
        Write-Host ""
        Write-Error "Docker is required but not installed."
        Write-Host ""
        Write-Host "Please install Docker Desktop:"
        Write-Host "  https://docs.docker.com/desktop/install/windows-install/"
        Write-Host ""
        exit 1
    }

    if (-not (Test-DockerRunning)) {
        Write-Host ""
        Write-Host "Please start Docker Desktop and try again."
        exit 1
    }

    if (-not (Test-Command "claude")) {
        Write-Host ""
        Write-Error "Claude Code CLI is required but not installed."
        Write-Host ""
        Write-Host "Please install Claude Code:"
        Write-Host "  https://claude.ai/download"
        Write-Host ""
        exit 1
    }

    Write-Host ""
    Write-Step "Pulling Docker image: ${DOCKER_IMAGE}:${Version}..."
    Write-Host ""

    try {
        docker pull "${DOCKER_IMAGE}:${Version}"
        if ($LASTEXITCODE -ne 0) { throw "Docker pull failed" }
    } catch {
        Write-Error "Failed to pull Docker image."
        Write-Host ""
        Write-Host "Try the Python installation method instead:"
        Write-Host "  .\install.ps1 -Method python"
        exit 1
    }

    Write-Host ""
    Write-Step "Registering with Claude Code..."
    Write-Host ""

    # Remove existing server if present
    try {
        claude mcp remove $SERVER_NAME 2>$null
    } catch {}

    # Add new server - Windows requires different volume mount syntax
    try {
        claude mcp add $SERVER_NAME -s user -- docker run -i --rm -v "${PWD}:/workspace" "${DOCKER_IMAGE}:${Version}"
        if ($LASTEXITCODE -ne 0) { throw "Failed to add MCP server" }
        Write-Success "MCP server registered successfully!"
    } catch {
        Write-Error "Failed to register MCP server."
        Write-Host ""
        Write-Host "Try manually in PowerShell:"
        Write-Host "  claude mcp add $SERVER_NAME -s user -- docker run -i --rm -v `"`${PWD}:/workspace`" ${DOCKER_IMAGE}:${Version}"
        exit 1
    }

    Write-SuccessMessage
}

function Install-WithPython {
    Write-Banner
    Write-Step "Installing via Python..."
    Write-Host ""

    # Check prerequisites
    Write-Host "Checking prerequisites..." -ForegroundColor White
    Write-Host ""

    # Check for Python (try both 'python' and 'python3')
    $pythonCmd = $null
    if (Get-Command "python" -ErrorAction SilentlyContinue) {
        $pythonCmd = "python"
    } elseif (Get-Command "python3" -ErrorAction SilentlyContinue) {
        $pythonCmd = "python3"
    } elseif (Get-Command "py" -ErrorAction SilentlyContinue) {
        $pythonCmd = "py -3"
    }

    if (-not $pythonCmd) {
        Write-Error "Python 3.11+ is required but not installed."
        Write-Host ""
        Write-Host "Please install Python 3.11+:"
        Write-Host "  https://www.python.org/downloads/"
        Write-Host ""
        Write-Host "Or install via winget:"
        Write-Host "  winget install Python.Python.3.11"
        exit 1
    }
    Write-Success "Python is installed ($pythonCmd)"

    if (-not (Test-Command "claude")) {
        Write-Error "Claude Code CLI is required but not installed."
        Write-Host ""
        Write-Host "Please install Claude Code:"
        Write-Host "  https://claude.ai/download"
        exit 1
    }

    # Install uv if not present
    if (-not (Get-Command "uv" -ErrorAction SilentlyContinue)) {
        Write-Host ""
        Write-Info "Installing uv package manager..."
        try {
            Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression

            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } catch {
            Write-Error "Failed to install uv. Please install manually:"
            Write-Host "  irm https://astral.sh/uv/install.ps1 | iex"
            exit 1
        }
    }
    Write-Success "uv package manager is installed"

    # Clone and setup
    $INSTALL_DIR = "$env:LOCALAPPDATA\llm-prep-mcp"
    Write-Host ""
    Write-Step "Setting up in $INSTALL_DIR..."

    if (Test-Path $INSTALL_DIR) {
        Write-Info "Updating existing installation..."
        Push-Location $INSTALL_DIR
        try {
            git fetch origin
            git reset --hard origin/main
        } catch {
            Write-Warning "Git update failed, continuing with existing version"
        }
    } else {
        Write-Info "Cloning repository..."
        try {
            git clone "https://github.com/${GITHUB_REPO}.git" $INSTALL_DIR
        } catch {
            Write-Error "Failed to clone repository. Is git installed?"
            Write-Host ""
            Write-Host "Install git: https://git-scm.com/download/win"
            exit 1
        }
        Push-Location $INSTALL_DIR
    }

    # Create venv and install dependencies
    Write-Host ""
    Write-Step "Installing dependencies..."
    try {
        uv venv --quiet
        uv pip install --quiet -r requirements.txt
    } catch {
        Write-Error "Failed to install dependencies"
        Pop-Location
        exit 1
    }

    Write-Host ""
    Write-Step "Registering with Claude Code..."

    # Remove existing server if present
    try {
        claude mcp remove $SERVER_NAME 2>$null
    } catch {}

    # Add new server using uv run
    try {
        claude mcp add $SERVER_NAME -s user -- uv --directory $INSTALL_DIR run python src/mcp_server_fastmcp.py --transport stdio
        if ($LASTEXITCODE -ne 0) { throw "Failed to add MCP server" }
        Write-Success "MCP server registered successfully!"
    } catch {
        Write-Error "Failed to register MCP server."
        Pop-Location
        exit 1
    }

    Pop-Location
    Write-SuccessMessage
}

function Write-SuccessMessage {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                               ║" -ForegroundColor Green
    Write-Host "║  🎉 LLM Prep MCP Server installed successfully!               ║" -ForegroundColor Green
    Write-Host "║                                                               ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. " -NoNewline; Write-Host "Restart Claude Code" -ForegroundColor Cyan -NoNewline; Write-Host " (or start a new session)"
    Write-Host ""
    Write-Host "  2. Verify installation:"
    Write-Host "     " -NoNewline; Write-Host "claude mcp list" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Try it out! In Claude Code, ask:"
    Write-Host "     " -NoNewline; Write-Host "`"Use llm-prep to analyze this project`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  4. Or use specific tools:"
    Write-Host "     " -NoNewline; Write-Host "`"Use llm-prep to prepare context for the src/ directory`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 Documentation: https://github.com/${GITHUB_REPO}"
    Write-Host "🐛 Issues:        https://github.com/${GITHUB_REPO}/issues"
    Write-Host ""
}

# Main
switch ($Method) {
    "docker" { Install-WithDocker }
    "python" { Install-WithPython }
}
