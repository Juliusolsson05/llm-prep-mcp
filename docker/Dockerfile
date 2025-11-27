# =============================================================================
# LLM Context Prep MCP Server - Production Dockerfile
# =============================================================================
# Multi-stage build for minimal image size
# Usage: docker build -f docker/Dockerfile -t llm-prep-mcp .
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Builder
# -----------------------------------------------------------------------------
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# -----------------------------------------------------------------------------
# Stage 2: Production Runtime
# -----------------------------------------------------------------------------
FROM python:3.11-slim AS runtime

# Labels for container registries
LABEL org.opencontainers.image.title="LLM Context Prep MCP Server"
LABEL org.opencontainers.image.description="MCP server for preparing comprehensive codebase context documents for LLMs"
LABEL org.opencontainers.image.source="https://github.com/Juliusolsson05/llm-prep-mcp"
LABEL org.opencontainers.image.url="https://github.com/Juliusolsson05/llm-prep-mcp"
LABEL org.opencontainers.image.documentation="https://github.com/Juliusolsson05/llm-prep-mcp#readme"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Julius Olsson"

# Install runtime dependencies (tree, git for repo analysis)
RUN apt-get update && apt-get install -y --no-install-recommends \
    tree \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security
RUN groupadd --gid 1000 mcp && \
    useradd --uid 1000 --gid mcp --shell /bin/bash --create-home mcp && \
    mkdir -p /workspace /app && \
    chown -R mcp:mcp /workspace /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Setup application
WORKDIR /app

# Copy application files
COPY --chown=mcp:mcp src/ ./src/
COPY --chown=mcp:mcp prompts/ ./prompts/
COPY --chown=mcp:mcp requirements.txt ./

# Switch to non-root user
USER mcp

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH=/app:$PYTHONPATH
ENV MCP_TRANSPORT=stdio
ENV MCP_DOCKER_MODE=true
ENV MCP_WORKSPACE_DIR=/workspace

# Expose port for HTTP/SSE transport (optional)
EXPOSE 8847

# Volume for workspace
VOLUME ["/workspace"]

# Health check for orchestration platforms
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Default: STDIO transport for Claude Code
CMD ["python", "src/mcp_server_fastmcp.py", "--transport", "stdio"]
