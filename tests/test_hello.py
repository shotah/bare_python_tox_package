"""Tests for hello_world package."""

import pytest

from hello_world import __version__, greet, hello_world


class TestHelloWorld:
    """Tests for the hello_world function."""

    def test_hello_world_returns_string(self):
        """Test that hello_world returns a string."""
        result = hello_world()
        assert isinstance(result, str)

    def test_hello_world_message(self):
        """Test the hello world message content."""
        result = hello_world()
        assert result == "Hello, World!"


class TestGreet:
    """Tests for the greet function."""

    def test_greet_with_name(self):
        """Test greeting with a name."""
        result = greet("Alice")
        assert result == "Hello, Alice!"

    def test_greet_with_empty_string(self):
        """Test greeting with empty string."""
        result = greet("")
        assert result == "Hello, !"

    @pytest.mark.parametrize(
        ("name", "expected"),
        [
            ("Bob", "Hello, Bob!"),
            ("World", "Hello, World!"),
            ("Python Developer", "Hello, Python Developer!"),
        ],
    )
    def test_greet_parametrized(self, name, expected):
        """Test greeting with various names."""
        assert greet(name) == expected


class TestVersion:
    """Tests for package version."""

    def test_version_exists(self):
        """Test that version is defined."""
        assert __version__ is not None

    def test_version_format(self):
        """Test that version follows semver format."""
        parts = __version__.split(".")
        assert len(parts) == 3
        assert all(part.isdigit() for part in parts)
