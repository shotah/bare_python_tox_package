"""Hello World package."""

# Single source of truth for package version.
# Update this value when releasing a new version.
# pyproject.toml reads this dynamically.
__version__ = "0.1.0"

from hello_world.main import greet, hello_world

__all__ = ["hello_world", "greet", "__version__"]
