"""
Unit tests for LLM Context Prep MCP Server.

Run with: pytest tests/ -v
"""

import pytest
import sys
import os
import tempfile
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))


class TestImports:
    """Test that all modules can be imported."""

    def test_import_mcp_server(self):
        """Test that main MCP server module can be imported."""
        try:
            import mcp_server_fastmcp
            assert mcp_server_fastmcp is not None
        except ImportError as e:
            pytest.fail(f"Failed to import mcp_server_fastmcp: {e}")

    def test_import_llm_prep(self):
        """Test that LLM prep module can be imported."""
        try:
            import llm_prep
            assert llm_prep is not None
        except ImportError as e:
            pytest.fail(f"Failed to import llm_prep: {e}")

    def test_import_config(self):
        """Test that config module can be imported."""
        try:
            import config
            assert config is not None
        except ImportError as e:
            pytest.fail(f"Failed to import config: {e}")

    def test_fastmcp_available(self):
        """Test that FastMCP is available from MCP package."""
        try:
            from mcp.server.fastmcp import FastMCP
            assert FastMCP is not None
        except ImportError as e:
            pytest.fail(f"FastMCP not available: {e}")


class TestFastMCPServer:
    """Test FastMCP server creation."""

    def test_server_creation(self):
        """Test that FastMCP server can be instantiated."""
        from mcp.server.fastmcp import FastMCP

        mcp = FastMCP("Test Server")
        assert mcp.name == "Test Server"

    def test_server_name_from_module(self):
        """Test that server name is set correctly in module."""
        from mcp_server_fastmcp import mcp

        assert mcp.name == "llm-context-prep"


class TestLLMContextPrep:
    """Test LLMContextPrep class functionality."""

    def test_init_default(self):
        """Test default initialization."""
        from llm_prep import LLMContextPrep

        prep = LLMContextPrep()
        assert prep.project_root is not None
        assert prep.focus_files == []
        assert prep.general_notes == []

    def test_init_with_root(self):
        """Test initialization with custom root."""
        from llm_prep import LLMContextPrep

        with tempfile.TemporaryDirectory() as tmpdir:
            prep = LLMContextPrep(project_root=Path(tmpdir))
            assert prep.project_root == Path(tmpdir)

    def test_add_file(self):
        """Test adding a file."""
        from llm_prep import LLMContextPrep

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a test file
            test_file = Path(tmpdir) / "test.py"
            test_file.write_text("print('hello')")

            prep = LLMContextPrep(project_root=Path(tmpdir))
            prep.add_file("test.py", "Test file")

            assert len(prep.focus_files) == 1
            assert prep.focus_files[0][1] == "Test file"

    def test_add_general_note(self):
        """Test adding a general note."""
        from llm_prep import LLMContextPrep

        prep = LLMContextPrep()
        prep.add_general_note("This is a test note")

        assert len(prep.general_notes) == 1
        assert prep.general_notes[0] == "This is a test note"

    def test_add_context_dump(self):
        """Test adding a context dump."""
        from llm_prep import LLMContextPrep

        prep = LLMContextPrep()
        prep.add_context_dump("Test Dump", "Content here")

        assert len(prep.context_dumps) == 1
        assert prep.context_dumps[0] == ("Test Dump", "Content here")

    def test_generate_markdown(self):
        """Test markdown generation."""
        from llm_prep import LLMContextPrep

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a test file
            test_file = Path(tmpdir) / "test.py"
            test_file.write_text("print('hello')")

            prep = LLMContextPrep(project_root=Path(tmpdir))
            prep.add_file("test.py", "Test file")
            prep.add_general_note("Test note")

            markdown = prep.generate_markdown()

            assert "# LLM Context Document" in markdown
            assert "test.py" in markdown
            assert "Test note" in markdown


class TestConfig:
    """Test configuration functionality."""

    def test_project_config_defaults(self):
        """Test ProjectConfig default values."""
        from config import ProjectConfig

        config = ProjectConfig()
        assert "node_modules" in config.tree_ignore
        assert config.output_dir == "context_reports"

    def test_project_config_from_dict(self):
        """Test ProjectConfig.from_dict."""
        from config import ProjectConfig

        data = {
            "tree_ignore": "*.pyc|.git",
            "output_dir": "custom_output",
        }
        config = ProjectConfig.from_dict(data)

        assert config.tree_ignore == "*.pyc|.git"
        assert config.output_dir == "custom_output"

    def test_project_config_to_dict(self):
        """Test ProjectConfig.to_dict."""
        from config import ProjectConfig

        config = ProjectConfig(tree_ignore="test", output_dir="out")
        data = config.to_dict()

        assert data["tree_ignore"] == "test"
        assert data["output_dir"] == "out"

    def test_server_config_defaults(self):
        """Test ServerConfig default values."""
        from config import server_config

        assert server_config.max_file_size > 0
        assert server_config.max_context_size > 0
        assert len(server_config.allowed_extensions) > 0

    def test_detect_project_type_python(self):
        """Test Python project detection."""
        from config import detect_project_type

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create requirements.txt to indicate Python project
            (Path(tmpdir) / "requirements.txt").write_text("pytest")

            project_type = detect_project_type(Path(tmpdir))
            assert project_type == "python"

    def test_detect_project_type_javascript(self):
        """Test JavaScript project detection."""
        from config import detect_project_type

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create package.json to indicate JS project
            (Path(tmpdir) / "package.json").write_text("{}")

            project_type = detect_project_type(Path(tmpdir))
            assert project_type == "javascript"


class TestIgnorePatterns:
    """Test ignore pattern functionality."""

    def test_split_patterns(self):
        """Test splitting pipe-separated patterns."""
        from config import split_patterns

        result = split_patterns("a|b|c")
        assert result == ["a", "b", "c"]

    def test_join_patterns(self):
        """Test joining patterns with pipes."""
        from config import join_patterns

        result = join_patterns(["a", "b", "c"])
        assert result == "a|b|c"

    def test_validate_ignore_patterns_critical_file(self):
        """Test that critical files cannot be ignored."""
        from config import validate_ignore_patterns

        result = validate_ignore_patterns(["README.md", "src"])

        assert len(result["errors"]) > 0
        assert any("README.md" in e for e in result["errors"])

    def test_validate_ignore_patterns_protected_dir(self):
        """Test warning for protected directories."""
        from config import validate_ignore_patterns

        result = validate_ignore_patterns(["src", "node_modules"])

        assert len(result["warnings"]) > 0
        assert any("src" in w for w in result["warnings"])


@pytest.mark.asyncio
class TestAsyncTools:
    """Test async MCP tool functions."""

    async def test_create_debug_notes(self):
        """Test create_debug_notes tool."""
        from mcp_server_fastmcp import create_debug_notes, CreateDebugNotesInput

        with tempfile.TemporaryDirectory() as tmpdir:
            result = await create_debug_notes(CreateDebugNotesInput(
                project_path=tmpdir,
                filename="test_notes.md",
                content="# Test\nThis is a test note."
            ))

            assert "✅" in result
            assert Path(tmpdir, ".llm_prep_notes", "test_notes.md").exists()

    async def test_set_project_config(self):
        """Test set_project_config tool."""
        from mcp_server_fastmcp import set_project_config, SetProjectConfigInput

        with tempfile.TemporaryDirectory() as tmpdir:
            result = await set_project_config(SetProjectConfigInput(
                project_path=tmpdir,
                tree_ignore="*.pyc|.git",
                default_output_dir="test_output"
            ))

            assert "✅" in result
            assert Path(tmpdir, ".llm_prep_config.json").exists()

    async def test_list_recent_contexts(self):
        """Test list_recent_contexts tool."""
        from mcp_server_fastmcp import list_recent_contexts, ListRecentContextsInput

        with tempfile.TemporaryDirectory() as tmpdir:
            result = await list_recent_contexts(ListRecentContextsInput(
                project_path=tmpdir,
                limit=5
            ))

            # Should return "no recent" message for empty project
            assert "No recent" in result or "Context" in result

    async def test_get_tree_ignore(self):
        """Test get_tree_ignore tool."""
        from mcp_server_fastmcp import get_tree_ignore, GetTreeIgnoreInput

        with tempfile.TemporaryDirectory() as tmpdir:
            result = await get_tree_ignore(GetTreeIgnoreInput(
                project_path=tmpdir
            ))

            assert "Project:" in result

    async def test_analyze_project_structure(self):
        """Test analyze_project_structure tool."""
        from mcp_server_fastmcp import analyze_project_structure, AnalyzeProjectInput

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a Python project indicator
            (Path(tmpdir) / "requirements.txt").write_text("pytest")

            result = await analyze_project_structure(AnalyzeProjectInput(
                project_path=tmpdir
            ))

            assert "Project:" in result
            assert "python" in result.lower()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
