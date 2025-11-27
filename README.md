# LLM Context Prep MCP Server

MCP server that generates comprehensive context documents from your codebase for LLM analysis.

## Install

```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.sh | bash

# Windows
irm https://raw.githubusercontent.com/Juliusolsson05/llm-prep-mcp/main/scripts/install.ps1 | iex
```

Restart Claude Code, then verify: `claude mcp list`

## Usage

In Claude Code:
```
Use llm-prep to prepare context for this project
Use llm-prep to analyze the project structure
Use llm-prep to chunk src/ into 3000-line files
```

## Tools

| Tool | Purpose |
|------|---------|
| `prepare_context` | Generate context document |
| `analyze_project_structure` | Detect project type, suggest ignores |
| `create_debug_notes` | Save notes for inclusion |
| `chunk_path_for_llm` | Split large dirs into chunks |
| `update_tree_ignore` | Configure exclusions |

## Output

```
your_project/
├── .llm_prep_config.json    # Config
├── .llm_prep_notes/         # Your notes
└── context_reports/         # Generated contexts
```

## License

MIT
