.SILENT: # Disable echo of commands
ifneq ("$(wildcard .env)", "")
    include .env
endif

SHELL := /bin/bash
export

PIPENV_IGNORE_VIRTUALENVS=1

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo ""
	@echo "Hello World Package - Available Commands"
	@echo "========================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make install-dev     Install all dependencies (including dev)"
	@echo "  make install         Install production dependencies only"
	@echo "  make hooks           Install git pre-commit hooks"
	@echo "  make hooks-update    Bump pre-commit hook revisions (autoupdate)"
	@echo "  make bump            Bump package __version__ (BUMP=patch|minor|major)"
	@echo "  make sync-dev        Sync all dependencies from Pipfile.lock"
	@echo ""
	@echo "Quality Checks:"
	@echo "  make lint            Run all linters (ruff check + format)"
	@echo "  make type-check      Run type checking (mypy)"
	@echo "  make security        Run security checks (bandit)"
	@echo "  make test            Run tests with pytest"
	@echo "  make test-cov        Run tests with coverage report"
	@echo "  make check           Run all checks (lint, type, security, test)"
	@echo ""
	@echo "Tox (Multi-environment):"
	@echo "  make tox             Run all tox environments"
	@echo "  make tox-lint        Run tox lint environment"
	@echo "  make tox-type        Run tox type environment"
	@echo "  make tox-security    Run tox security environment"
	@echo ""
	@echo "Build:"
	@echo "  make build           Build package (wheel + sdist)"
	@echo "  make publish-test    Validate dist/ with twine check"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           Clean virtual environment"
	@echo "  make clean-build     Clean build artifacts"
	@echo "  make clean-all       Clean everything"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make install-dev"
	@echo "  2. make hooks"
	@echo "  3. make check"
	@echo ""

# ============================================================================
# Setup & Installation
# ============================================================================

.PHONY: install
install: ## Install production dependencies only
	pipenv install

.PHONY: install-dev
install-dev: ## Install all dependencies (including dev)
	pipenv install --dev

.PHONY: sync
sync: ## Sync production dependencies from Pipfile.lock
	pipenv sync

.PHONY: sync-dev
sync-dev: ## Sync all dependencies from Pipfile.lock (including dev)
	pipenv sync --dev

.PHONY: hooks
hooks: ## Install git pre-commit hooks
	pip install pre-commit
	pre-commit install || echo "pre-commit hooks already installed"

.PHONY: hooks-update
hooks-update: ## Bump pre-commit hook revisions (run pre-commit autoupdate)
	pip install pre-commit
	pre-commit autoupdate

BUMP ?= patch

.PHONY: bump
bump: ## Bump __version__ in src/hello_world/__init__.py (BUMP=patch|minor|major)
	python scripts/bump_version.py $(BUMP)

# ============================================================================
# Quality Checks
# ============================================================================

.PHONY: lint
lint: ## Run all linters (ruff check + format check)
	pipenv run ruff check src/ tests/ scripts/
	pipenv run ruff format --check src/ tests/ scripts/

.PHONY: lint-fix
lint-fix: ## Run linters and auto-fix issues
	pipenv run ruff check --fix src/ tests/ scripts/
	pipenv run ruff format src/ tests/ scripts/

.PHONY: type-check
type-check: ## Run type checking with mypy
	pipenv run mypy src/

.PHONY: security
security: ## Run security checks with bandit
	pipenv run bandit -r src/ -c pyproject.toml

.PHONY: test
test: ## Run tests with pytest
	pipenv run pytest tests/ -v

.PHONY: test-cov
test-cov: ## Run tests with coverage report
	pipenv run pytest tests/ --cov=hello_world --cov-report=term-missing --cov-report=xml --cov-report=html

.PHONY: test-failed
test-failed: ## Re-run only failed tests
	pipenv run pytest --last-failed --exitfirst

.PHONY: check
check: lint type-check security test ## Run all checks (lint, type, security, test)
	@echo ""
	@echo "All checks passed!"

# ============================================================================
# Tox (Multi-environment Testing)
# ============================================================================

.PHONY: tox
tox: ## Run all tox environments
	pipenv run tox

.PHONY: tox-lint
tox-lint: ## Run tox lint environment
	pipenv run tox -e lint

.PHONY: tox-type
tox-type: ## Run tox type environment
	pipenv run tox -e type

.PHONY: tox-security
tox-security: ## Run tox security environment
	pipenv run tox -e security

.PHONY: tox-build
tox-build: ## Run tox build environment
	pipenv run tox -e build

# ============================================================================
# Build
# ============================================================================

.PHONY: build
build: clean-build ## Build package (wheel + sdist)
	pipenv run python -m build
	pipenv run twine check dist/*

.PHONY: publish-test
publish-test: build ## Validate distribution artifacts (twine check only)
	@echo "Checking distribution artifacts..."
	pipenv run twine check dist/*
	@echo ""
	@echo "Artifacts in dist/:"
	@ls -la dist/

# ============================================================================
# Maintenance
# ============================================================================

.PHONY: clean
clean: ## Clean virtual environment
	pipenv --rm || echo "No virtual environment to remove"

.PHONY: clean-build
clean-build: ## Clean build artifacts
	rm -rf dist/ build/ *.egg-info src/*.egg-info
	rm -rf .pytest_cache .mypy_cache .ruff_cache
	rm -rf coverage.xml .coverage htmlcov/
	rm -rf .tox/

.PHONY: clean-all
clean-all: clean-build clean ## Clean everything (build artifacts + venv)
	rm -rf Pipfile.lock

# ============================================================================
# All-in-one
# ============================================================================

.PHONY: all
all: hooks install-dev check ## Run full setup: hooks, install, and all checks
