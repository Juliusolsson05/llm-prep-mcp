# LLM Prep MCP - Quick Reference Card

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                      LLM CONTEXT PREP - CHEAT SHEET                       ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

## 🚀 Installation

```bash
# macOS/Linux (one line)
curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.ps1 | iex

# Verify
claude mcp list
```

---

## 🛠️ Essential Commands

### Analyze Project
```
Use llm-prep to analyze the project structure
```

### Auto-Configure Ignore Patterns
```
Use llm-prep to update tree ignore with auto-detect
```

### Generate Full Context
```
Use llm-prep to prepare context for the project
```

### Generate Focused Context
```
Use llm-prep to prepare context for src/ directory only
```

### Create Debug Notes
```
Use llm-prep to create debug notes called "bug.md" with content: "# Error\n..."
```

### Include Notes in Context
```
Use llm-prep to prepare context including the debug notes
```

### Chunk Large Directory
```
Use llm-prep to chunk src/ into files of 3000 lines each
```

### Preview (Dry Run)
```
Use llm-prep to prepare context with dry_run=true
```

---

## 📁 Files Created

```
your_project/
├── .llm_prep_config.json    ← Project config
├── .llm_prep_notes/         ← Your debug notes
└── context_reports/         ← Generated contexts
```

---

## 🔧 Tools Reference

| Tool | Purpose |
|------|---------|
| `prepare_context` | Generate context docs |
| `analyze_project_structure` | Detect project type |
| `create_debug_notes` | Save notes/logs |
| `update_tree_ignore` | Set ignore patterns |
| `get_tree_ignore` | View ignore patterns |
| `chunk_path_for_llm` | Split large dirs |
| `list_recent_contexts` | View history |
| `clean_temp_notes` | Cleanup old notes |

---

## ⚡ Quick Tips

1. **Run `analyze_project_structure` first** on new projects
2. **Use `auto` action** for tree ignore setup
3. **Create notes BEFORE context** for debug workflows
4. **Use dry_run** to preview large operations
5. **Restart Claude Code** after installing MCP

---

## ❓ Troubleshooting

| Issue | Solution |
|-------|----------|
| MCP not found | Restart Claude Code |
| Docker error | Start Docker Desktop |
| Permission denied | Run as admin/sudo |
| Context too large | Use more specific paths |

---

## 🔗 Links

- **Docs**: github.com/Juliusolsson05/llm-prep-mcp
- **Issues**: github.com/Juliusolsson05/llm-prep-mcp/issues
- **MCP**: modelcontextprotocol.io

---

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  Docker: juliusolsson/llm-prep:latest                                     ║
║  GHCR:   ghcr.io/juliusolsson05/llm-prep-mcp:latest                      ║
╚═══════════════════════════════════════════════════════════════════════════╝
```
