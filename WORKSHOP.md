# LLM Context Prep MCP Server - Workshop Guide

Welcome to the LLM Context Prep workshop! This guide will help you get up and running in minutes.

---

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] **Claude Code** installed ([Download](https://claude.ai/download))
- [ ] **Docker Desktop** installed and running ([Download](https://docker.com/products/docker-desktop))
- [ ] A terminal/command prompt

### Quick Check

```bash
# Verify Claude Code
claude --version

# Verify Docker
docker --version
docker info  # Should not show errors
```

---

## 🚀 Installation (Choose ONE)

### Option A: One-Line Install (Recommended)

**macOS/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.ps1 | iex
```

### Option B: Manual Docker Install

```bash
# 1. Pull the image
docker pull juliusolsson/llm-prep:latest

# 2. Add to Claude Code
claude mcp add llm-prep -s user -- docker run -i --rm -v '$(pwd):/workspace' juliusolsson/llm-prep:latest
```

### Option C: Python Install (No Docker)

```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash -s -- --method python

# Windows PowerShell
.\install.ps1 -Method python
```

---

## ✅ Verify Installation

```bash
# List installed MCP servers
claude mcp list
```

You should see `llm-prep` in the list.

**Restart Claude Code** (or start a new session) to load the new MCP server.

---

## 🎯 Workshop Exercises

### Exercise 1: Analyze a Project

Open Claude Code in any project directory and type:

```
Use llm-prep to analyze the project structure and suggest what to ignore
```

**What to observe:**
- Project type detection (Python, JavaScript, etc.)
- Suggested ignore patterns
- Large directories identified

---

### Exercise 2: Create Your First Context

```
Use llm-prep to prepare context for this entire project
```

**What to observe:**
- Generated context file in `context_reports/`
- Project tree structure
- File contents with line numbers

---

### Exercise 3: Focused Context

```
Use llm-prep to prepare context for just the src/ directory, excluding tests
```

---

### Exercise 4: Debug Notes

Create notes first, then include them in context:

```
Use llm-prep to create debug notes called "investigation.md" with the content:
"# Bug Investigation
- Error: Connection timeout
- Occurs when: High traffic
- Suspected: Database pool exhaustion"
```

Then:

```
Use llm-prep to prepare context including the investigation notes and the database configuration files
```

---

### Exercise 5: Chunk Large Codebases

For large projects:

```
Use llm-prep to chunk the src/ directory into context files of 3000 lines each
```

---

## 📁 Understanding the Output

### Project Structure After Using llm-prep

```
your_project/
├── .llm_prep_config.json      # Configuration (auto-created)
├── .llm_prep_notes/           # Your debug notes
│   └── investigation.md
├── context_reports/           # Generated contexts
│   └── context_20250127.md
└── [your files]
```

### Context Document Structure

Generated context files contain:

1. **Header** - Generation timestamp and project info
2. **Summary** - Files included, notes, dumps
3. **Project Tree** - Visual structure (respects ignore patterns)
4. **Context Dumps** - Your markdown notes as sections
5. **File Contents** - Full source with line numbers
6. **General Notes** - Additional context at the end

---

## 💡 Tips for Best Results

### 1. Configure Ignore Patterns First

```
Use llm-prep to update tree ignore with auto-detect
```

This prevents large directories like `node_modules` from cluttering context.

### 2. Use Notes for Context

Create notes BEFORE generating context:
- Error logs → debug notes
- Requirements → context dumps
- Decisions → general notes

### 3. Keep Context Focused

Instead of:
```
Prepare context for the entire project
```

Try:
```
Prepare context for the authentication module, including the auth config and middleware
```

### 4. Use Dry Run First

For large operations:
```
Use llm-prep to prepare context with dry_run=true to preview what will be included
```

---

## 🔧 Available Tools Reference

| Tool | Use When |
|------|----------|
| `prepare_context` | Generating context documents |
| `analyze_project_structure` | Starting with a new project |
| `create_debug_notes` | Saving error logs, analysis |
| `update_tree_ignore` | Configuring exclusions |
| `get_tree_ignore` | Viewing current patterns |
| `chunk_path_for_llm` | Large directories/codebases |
| `list_recent_contexts` | Finding previous contexts |
| `clean_temp_notes` | Cleaning up old notes |

---

## ❓ Common Issues

### "MCP server not found"

1. Restart Claude Code
2. Verify with `claude mcp list`
3. Re-run the install command

### "Docker not running"

1. Start Docker Desktop
2. Wait for it to fully initialize
3. Verify with `docker info`

### "Permission denied"

**macOS/Linux:**
```bash
# If Docker socket permission issue
sudo usermod -aG docker $USER
# Then log out and back in
```

**Windows:**
Run PowerShell as Administrator for installation.

### Context too large

Use more specific paths and ignore patterns:
```
Use llm-prep to prepare context for src/api/ only, excluding __pycache__ and tests
```

---

## 🎓 Next Steps

1. **Try on your own projects** - See how llm-prep handles your codebase
2. **Experiment with chunking** - For large codebases
3. **Create workflow templates** - Standard notes for your debug process
4. **Share contexts** - Upload to Claude.ai for deeper analysis

---

## 📚 Resources

- [Full Documentation](https://github.com/Juliusolsson05/llm-prep-mcp)
- [MCP Protocol Docs](https://modelcontextprotocol.io)
- [Report Issues](https://github.com/Juliusolsson05/llm-prep-mcp/issues)

---

## 📞 Need Help?

During the workshop:
- Raise your hand!
- Ask in the chat

After the workshop:
- Open a GitHub issue
- Check the documentation

---

Happy context preparing! 🚀
