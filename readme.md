# bare-python-tox-package

A Python package template configured for enterprise CI/CD with CodeCommit, Jenkins, and Artifactory (AWS GovCloud).

## Overview

This project provides a minimal "hello world" Python package with a production-ready build and deployment pipeline:

- **Build Tools**: Makefile, Pipenv, Tox
- **Source Control**: AWS CodeCommit
- **CI/CD**: Jenkins
- **Artifact Repository**: JFrog Artifactory (AWS GovCloud)

## Features

- **Linting**: Ruff (replaces flake8, isort, black)
- **Type Checking**: MyPy with strict mode
- **Security Scanning**: Bandit
- **Testing**: Pytest with coverage
- **Formatting**: Ruff formatter
- **Pre-commit Hooks**: Automated quality gates

## Python Version Strategy

| Aspect | Version | Notes |
|--------|---------|-------|
| **Supported** | `>=3.12` | Consumers can install on Python 3.12, 3.13, or 3.14 |
| **Developed/Tested** | `3.14` | CI builds and tests on Python 3.14 for forward compatibility |
| **Ruff Target** | `py312` | Linting rules target 3.12 for broad compatibility |

This package is designed to support LTS Python versions (3.12+) while being developed and tested on the latest Python (3.14) to catch deprecations early and ensure forward compatibility.

## Project Structure

```
bare-python-tox-package/
├── src/
│   └── hello_world/
│       ├── __init__.py
│       └── main.py
├── tests/
│   └── test_hello.py
├── .pre-commit-config.yaml   # Git hooks for local dev
├── Jenkinsfile               # CI/CD pipeline definition
├── Makefile                  # Development commands
├── Pipfile                   # Pipenv dependencies
├── pyproject.toml            # Package metadata & tool config
├── tox.ini                   # Multi-environment testing
└── todo.md                   # Implementation checklist
```

## Quick Start

### Prerequisites

- Python 3.12+
- Pipenv (`pip install pipenv`)
- Git

### Setup

```bash
# Clone the repository
git clone <codecommit-repo-url>
cd bare-python-tox-package

# Install dependencies
make install-dev

# Install pre-commit hooks
make hooks

# Run all quality checks
make lint

# Run tests
make test
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make install-dev` | Install all dependencies (including dev) |
| `make install` | Install production dependencies only |
| `make hooks` | Install git pre-commit hooks |
| `make lint` | Run all linters (ruff, mypy, bandit) |
| `make test` | Run tests with pytest |
| `make security` | Run security checks (bandit) |
| `make type-check` | Run type checking (mypy) |
| `make tox` | Run all tox environments |
| `make check` | Run all checks (lint, type, security, test) |
| `make build` | Build the package (wheel + sdist) |
| `make publish` | Publish to Artifactory |
| `make clean` | Clean build artifacts |

## Tox (Local Development)

Tox provides isolated environments for running checks locally. Jenkins uses direct commands for speed, but tox is available for local dev convenience.

```bash
# Run all default environments (py314, lint, type, security)
make tox

# Run specific environment
pipenv run tox -e lint
pipenv run tox -e py314

# Run all checks in one environment (faster)
pipenv run tox -e all
```

| Environment | Description |
|-------------|-------------|
| `py314` | Run tests on Python 3.14 |
| `lint` | Ruff linting and format check |
| `type` | MyPy type checking |
| `security` | Bandit security scan |
| `build` | Build wheel and sdist |
| `all` | Run all checks in one go |

## CI/CD Pipeline (Jenkins)

The Jenkins pipeline runs the following stages:

1. **Checkout** - Pull code from CodeCommit
2. **Install** - Set up Python environment with Pipenv
3. **Lint** - Run Ruff linting and formatting checks
4. **Type Check** - Run MyPy strict type checking
5. **Security** - Run Bandit security scanning
6. **Test** - Run Pytest with coverage
7. **Build** - Build wheel and source distribution
8. **Publish** - Push to Artifactory (on main branch only)

## Artifactory Configuration

### Environment Variables (Jenkins)

| Variable | Description |
|----------|-------------|
| `ARTIFACTORY_URL` | Artifactory server URL (GovCloud) |
| `ARTIFACTORY_REPO` | Target PyPI repository name |
| `ARTIFACTORY_USER` | Service account username |
| `ARTIFACTORY_TOKEN` | API token (Jenkins credential) |

### Publishing

```bash
# Manual publish (uses ARTIFACTORY_* env vars)
make publish

# Or via twine directly
pipenv run twine upload \
    --repository-url ${ARTIFACTORY_URL}/api/pypi/${ARTIFACTORY_REPO} \
    -u ${ARTIFACTORY_USER} \
    -p ${ARTIFACTORY_TOKEN} \
    dist/*
```

## Development Workflow

1. **Create feature branch**: `git checkout -b feature/my-feature`
2. **Make changes**: Edit code in `src/hello_world/`
3. **Run checks locally**: `make lint test`
4. **Commit**: Pre-commit hooks run automatically
5. **Push to CodeCommit**: `git push origin feature/my-feature`
6. **Jenkins runs CI**: Automatic on push
7. **Merge to main**: Jenkins publishes to Artifactory

## Versioning

The package version is defined in a single location:

```
src/hello_world/__init__.py → __version__ = "X.Y.Z"
```

`pyproject.toml` reads this dynamically, so you only update one file.

### Release Workflow

1. Update `__version__` in `src/hello_world/__init__.py`
2. Commit: `git commit -am "Bump version to X.Y.Z"`
3. Tag: `git tag vX.Y.Z`
4. Push: `git push && git push --tags`
5. Jenkins builds and publishes to Artifactory

### Future: Git-Tag Versioning

When ready to automate versioning, migrate to `setuptools-scm`. The pyproject.toml includes commented instructions for this migration. With setuptools-scm, versions are derived from git tags automatically.

## Configuration Files

| File | Purpose |
|------|---------|
| `pyproject.toml` | Package metadata, ruff, mypy, pytest, bandit config |
| `Pipfile` | Development and production dependencies |
| `tox.ini` | Local dev environments (isolated checks) |
| `.pre-commit-config.yaml` | Git hook definitions |
| `Jenkinsfile` | CI/CD pipeline (uses direct commands for speed) |
| `Makefile` | Developer convenience commands |

## License

Internal use only.
