"""Hello World package."""

# Single source of truth (pyproject.toml reads this via setuptools).
# PATCH: push to a feature branch → bump-version.yml commits here; merge to main → Release publishes.
# On main only: run `make bump` (or edit) before push if you skip feature branches.
# MINOR/MAJOR: make bump BUMP=minor|major on your branch, then push (bump workflow still PATCHes once).
__version__ = "0.1.4"

from hello_world.main import greet, hello_world

__all__ = ["hello_world", "greet", "__version__"]
