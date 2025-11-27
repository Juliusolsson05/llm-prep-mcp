# LLM Context Prep MCP Server

[![Docker Hub](https://img.shields.io/docker/v/juliusolsson/llm-prep?label=Docker%20Hub&logo=docker)](https://hub.docker.com/r/juliusolsson/llm-prep)
[![GitHub release](https://img.shields.io/github/v/release/Juliusolsson05/llm-prep-mcp?logo=github)](https://github.com/Juliusolsson05/llm-prep-mcp/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)

An MCP (Model Context Protocol) server that prepares comprehensive codebase context documents for LLMs. Generate well-structured context that helps AI assistants understand your entire project.

---

## 🎯 Problem This Solves

When debugging complex issues or implementing features across multiple files, AI coding assistants often hit token limits. This MCP server enables a two-stage workflow:

1. **Claude Code** prepares detailed notes and identifies relevant files
2. **MCP Server** generates a comprehensive context document
3. **Upload** the document to Claude.ai for deep analysis with higher token limits

---

## 🚀 Quick Install

### One-Line Install (Recommended)

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.ps1 | iex
```

### Docker Manual Install

```bash
# Pull the image
docker pull juliusolsson/llm-prep:latest

# Add to Claude Code
claude mcp add llm-prep -s user -- docker run -i --rm -v '$(pwd):/workspace' juliusolsson/llm-prep:latest

# Verify
claude mcp list
```

### GitHub Container Registry

```bash
claude mcp add llm-prep -s user -- docker run -i --rm -v '$(pwd):/workspace' ghcr.io/juliusolsson05/llm-prep-mcp:latest
```

### Python Install (Alternative)

```bash
curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash -s -- --method python
```

---

## ✅ Verify Installation

```bash
# List MCP servers
claude mcp list

# Should show:
# llm-prep: docker run -i --rm -v '$(pwd):/workspace' ...
```

Then in Claude Code, try:
```
Use llm-prep to analyze this project
```

---

## 🛠️ Available Tools

| Tool | Description |
|------|-------------|
| `prepare_context` | Generate comprehensive markdown context documents |
| `analyze_project_structure` | Detect project type and suggest ignore patterns |
| `create_debug_notes` | Save markdown notes for later inclusion |
| `update_tree_ignore` | Configure file/folder exclusions |
| `get_tree_ignore` | View current ignore patterns |
| `chunk_path_for_llm` | Split large directories into manageable chunks |
| `list_recent_contexts` | View generation history |
| `clean_temp_notes` | Cleanup old temporary files |
| `set_project_config` | Configure project-specific settings |
| `save_tokens` | Rewrite old contexts to cheaper format |
| `get_server_limits` | Check file size and context limits |

---

## 📖 Usage Examples

### Generate Full Project Context
```
Use llm-prep to prepare context for the entire project, excluding node_modules and .git
```

### Analyze Project Structure
```
Use llm-prep to analyze the project structure and suggest what to ignore
```

### Generate Context for Specific Directory
```
Use llm-prep to prepare context for just the src/ directory
```

### Debug Workflow
```
# Step 1: Create debug notes
Use llm-prep to create debug notes with the error log

# Step 2: Prepare context
Use llm-prep to prepare context including the debug notes and relevant source files
```

### Chunk Large Codebases
```
Use llm-prep to chunk the src/services directory into multiple context files, max 3000 lines each
```

---

## 🎯 MCP Prompts

The server provides intelligent prompts for common workflows:

- `debug_workflow` - Complete debugging workflow
- `feature_implementation` - Feature development context
- `notes_first` - Guided workflow for creating notes before context

---

## 🔧 Configuration

### Project Settings

Each project can have a `.llm_prep_config.json`:

```json
{
  "tree_ignore": "*.pyc|__pycache__|node_modules|.git",
  "output_dir": "context_reports",
  "default_context_dumps": [
    {"file": "docs/architecture.md", "title": "System Architecture"}
  ],
  "project_type": "python",
  "auto_detected_patterns": ["__pycache__", ".venv", "*.pyc"]
}
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MCP_DEBUG` | `false` | Enable debug logging |
| `MCP_MAX_FILE_SIZE` | `10485760` | Max file size (10MB) |
| `MCP_MAX_CONTEXT_SIZE` | `52428800` | Max context size (50MB) |
| `MCP_WORKSPACE_DIR` | `/workspace` | Workspace directory in Docker |

---

## 🗂️ Project Structure

When you use llm-prep, it creates:

```
your_project/
├── .llm_prep_config.json    # Project configuration
├── .llm_prep_notes/         # Temporary debug notes
│   └── debug_analysis.md
└── context_reports/         # Generated context documents
    └── context_20250127.md
```

---

## 🏗️ Development

### Local Setup

```bash
# Clone
git clone https://github.com/Juliusolsson05/llm-prep-mcp.git
cd llm-prep-mcp

# Setup with Make
make setup

# Or manually with uv
uv venv
uv pip install -r requirements.txt

# Run locally
uv run python src/mcp_server_fastmcp.py --transport stdio

# Run tests
make test
# or
pytest tests/ -v
```

### Docker Development

```bash
# Build development image
docker build -f docker/Dockerfile.dev -t llm-prep-mcp:dev .

# Run with source mounted
docker run -it --rm \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/workspace:/workspace \
  llm-prep-mcp:dev
```

### Running Tests

```bash
# Unit tests
pytest tests/ -v

# Integration tests
python scripts/test_server.py

# All tests
make test
```

---

## 📦 Distribution

Docker images are automatically published on every release:

| Registry | Image |
|----------|-------|
| **Docker Hub** | `juliusolsson/llm-prep` |
| **GitHub Container Registry** | `ghcr.io/juliusolsson05/llm-prep-mcp` |

**Tags:**
- `latest` - Latest stable release
- `vX.Y.Z` - Specific version
- `latest-dev` - Latest from main branch

---

## 📊 Best Practices

1. **Large Error Logs**: Always use `create_debug_notes` for logs over 100 lines
2. **File Organization**: Keep debug notes in `.llm_prep_notes/`, contexts in `context_reports/`
3. **Descriptive Notes**: Add clear notes to each file explaining its relevance
4. **Context Size**: Keep documents under 2MB for optimal performance
5. **Regular Cleanup**: Use `clean_temp_notes` to remove old temporary files
6. **Tree Ignore**: Run `update_tree_ignore(action="auto")` when starting a new project

---

## ❓ FAQ

**Q: How is this different from just copying files to Claude?**
A: This tool creates structured, comprehensive contexts with project trees, line numbers, and organized sections optimized for LLM consumption.

**Q: Can I use this without Docker?**
A: Yes! Use the Python installation method or install manually.

**Q: How do I handle secrets/sensitive data?**
A: Add sensitive files to `tree_ignore` patterns and never include them in context documents.

**Q: What's the maximum context size?**
A: Default is 50MB, but Claude.ai typically handles 100K-200K tokens well.

---

## ❓ Troubleshooting

### "Connection closed" error
- Ensure Docker is running: `docker info`
- Verify image exists: `docker images | grep llm-prep`
- Check volume mounts are correct

### Files not found
- Use relative paths from project root
- Check that files exist in the mounted workspace
- Verify file permissions

### Context too large
- Use `tree_ignore` to exclude unnecessary directories
- Split into multiple focused contexts with `chunk_path_for_llm`
- Remove large binary files or datasets

### Windows-specific issues
```powershell
# If volume mount fails, try explicit path:
claude mcp add llm-prep -s user -- docker run -i --rm -v "C:\Users\YOU\project:/workspace" juliusolsson/llm-prep:latest

# If PowerShell blocks scripts:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🔗 Links

- [Model Context Protocol Documentation](https://modelcontextprotocol.io)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Report Issues](https://github.com/Juliusolsson05/llm-prep-mcp/issues)

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

---

Made with ❤️ for the AI coding community
