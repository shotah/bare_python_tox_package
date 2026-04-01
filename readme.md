# bare-python-tox-package

[![Coverage](https://github.com/shotah/bare_python_tox_package/raw/gh-pages/badges/coverage.svg)](https://github.com/shotah/bare_python_tox_package/actions/workflows/ci.yml)
[![CI](https://github.com/shotah/bare_python_tox_package/actions/workflows/ci.yml/badge.svg)](https://github.com/shotah/bare_python_tox_package/actions/workflows/ci.yml)
[![Python 3.14](https://img.shields.io/badge/python-3.14-blue.svg)](https://www.python.org/)

**Repo:** [github.com/shotah/bare_python_tox_package](https://github.com/shotah/bare_python_tox_package)

A Python package template for CI/CD with **GitHub** as the source of truth. **GitHub Actions** runs lint, tests, and builds; **releases** attach the **wheel and sdist** to **GitHub Releases** when you push a `v*` tag. Consumers can install from **git** or from **release assets**.

## Overview

- **Build tools**: Makefile, Pipenv, Tox
- **Source control**: GitHub
- **CI/CD**: **GitHub Actions** (`.github/workflows/`)
- **Legacy reference**: Jenkins pipeline lives under [docs/legacy/](docs/legacy/) (not used by default)
- **Consumption**: Git URL + tag, **or** direct `pip install` of a `.whl` URL from a Release (see [docs/using-in-another-service.md](docs/using-in-another-service.md))

## Features

- **Linting**: Ruff (replaces flake8, isort, black)
- **Type Checking**: MyPy with strict mode
- **Security Scanning**: Bandit
- **Testing**: Pytest with coverage
- **Formatting**: Ruff formatter
- **Pre-commit Hooks**: Automated quality gates (includes **pyupgrade** for Python 3.12+ syntax, plus Ruff’s `UP` rules)

## Pre-commit: staying up to date

Hook versions are pinned under `rev:` in `.pre-commit-config.yaml`. To bump them to the latest tagged releases:

```bash
pre-commit autoupdate
# or
make hooks-update
```

Commit the updated YAML. Re-run all hooks once: `pre-commit run --all-files`.

`asottile/pyupgrade` uses `--py311-plus` (current pyupgrade release does not ship `--py312-plus` yet). Ruff’s `target-version = "py312"` and **UP** rules still apply after pyupgrade. The pyupgrade hook runs before Ruff.

**Why pre-commit does not bump `__version__`:** Hooks run *before* the commit is created. Bumping there would change a tracked file after staging, which forces `git add` + amend or a second commit and fights the “one commit per change” flow. **PATCH bumps run in GitHub Actions on feature branches** (`bump-version.yml`); **`main`** only **publishes** (`release.yml`).

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
├── .github/
│   └── workflows/
│       ├── ci.yml              # PR / push: lint, test, build, coverage badge
│       ├── bump-version.yml    # feature branches: PATCH bump + push to same branch
│       └── release.yml         # main: publish GitHub Release if vX.Y.Z missing
├── src/
│   └── hello_world/
├── tests/
├── .pre-commit-config.yaml
├── Makefile
├── Pipfile
├── pyproject.toml
├── tox.ini
├── scripts/
│   └── bump_version.py      # make bump + Release workflow (--quiet in CI)
├── docs/
│   ├── legacy/              # Jenkinsfile reference
│   └── using-in-another-service.md
└── todo.md
```

## Quick Start

### Prerequisites

- Python 3.12+ (3.14 recommended for this repo’s dev environment)
- Pipenv (`pip install pipenv`)
- Git

### Setup

```bash
git clone https://github.com/shotah/bare_python_tox_package.git
cd bare_python_tox_package

make install-dev
make hooks
make lint
make test
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make install-dev` | Install all dependencies (including dev) |
| `make install` | Install production dependencies only |
| `make hooks` | Install git pre-commit hooks |
| `make hooks-update` | Run `pre-commit autoupdate` to refresh hook `rev`s |
| `make bump` | Bump `__version__` locally (`BUMP=patch|minor|major`; on feature branches CI also PATCH-bumps on each **push**) |
| `make lint` | Run all linters (ruff check + format check) |
| `make test` | Run tests with pytest |
| `make security` | Run security checks (bandit) |
| `make type-check` | Run type checking (mypy) |
| `make tox` | Run all tox environments |
| `make check` | Run all checks (lint, type, security, test) |
| `make build` | Build the package (wheel + sdist) |
| `make publish-test` | Validate `dist/*` with `twine check` |
| `make clean` | Clean virtual environment |
| `make clean-build` | Clean build artifacts |

## Tox (Local Development)

Tox provides isolated environments for running checks locally. **CI uses GitHub Actions** (`pip install -e ".[dev]"`); tox is for local convenience.

```bash
make tox
pipenv run tox -e lint
pipenv run tox -e py314
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

## GitHub Actions

### CI (`ci.yml`)

Runs on **push** and **pull_request** to `main` / `master`:

1. Install with `pip install -e ".[dev]"`
2. Ruff (lint + format check)
3. MyPy, Bandit, Pytest with coverage (writes `coverage.xml` in Cobertura format)
4. `python -m build` and `twine check`
5. Upload `dist/` as a workflow artifact (handy for debugging builds)
6. **On push to `main` only:** build a **coverage** SVG from `coverage.xml` and push it to the **`gh-pages`** branch under `badges/` (`peaceiris/actions-gh-pages`). Badges in this README use [github.com/shotah/bare_python_tox_package](https://github.com/shotah/bare_python_tox_package); fork or rename the repo as needed and update URLs.

### Bump version (`bump-version.yml`)

Runs on **push to any branch except `main` / `master`**.

1. Skips if HEAD is **`chore(release):`** (loop guard).
2. **PATCH-bumps** `__version__` and **pushes to the same branch** (no `main` access needed).

### Release (`release.yml`)

Runs on **`main` / `master` only** — **no bump, no git push**.

1. Skips if HEAD is **`chore(release):`** (unusual tip on `main`).
2. If GitHub Release **`v{__version__}`** exists → skip; else lint, test, build, publish **`dist/*`**.

**Direct `main` pushes:** use **`make bump`** locally first (see Versioning).

**Org restrictions:** `contents: write`, `softprops/action-gh-release`, **`peaceiris/actions-gh-pages`** (CI) may need allowlisting.

## Development Workflow

1. **Branch**: `git checkout -b feature/my-feature`
2. **Develop** in `src/hello_world/`
3. **Check locally**: `make check`
4. **Commit** → pre-commit validates (no version bump in hooks)
5. **Push branch** → **Bump** workflow PATCHes and may add **`chore(release):`** on **that branch** → open PR → **merge to `main`**
6. On **`main`**: **CI** + **Release** → new **`vX.Y.Z`** when that release is missing ([Releases](https://github.com/shotah/bare_python_tox_package/releases))

## Versioning

**Declared in git:** `src/hello_world/__init__.py` → `__version__`. **`PKG-INFO` / `*.egg-info/`** are generated — **gitignored**.

### Feature / topic branches (default)

Every **push** to a non-`main` branch triggers **`bump-version.yml`**, which **PATCH-bumps** and commits to **that same branch**. After merge, **`main`** already contains the new version — **no bot push to `main`**, so usual **branch protection** on `main` is fine.

### Push directly to `main`

**`bump-version.yml` is skipped** (it ignores `main` / `master`). Run **`make bump`** (or edit `__version__`) **before** you push so **Release** can publish a new **`vX.Y.Z`**.

### MINOR / MAJOR

Use **`make bump BUMP=minor`** or **`BUMP=major`** on your branch and push. The next **Bump** workflow run will still apply one **PATCH** on top (e.g. `0.2.0` → `0.2.1`) unless you adjust workflows.

### `make bump`

```bash
make bump              # patch (same as CI on a feature branch)
make bump BUMP=minor
make bump BUMP=major
```

### Fork PRs

Contributors from forks often need to bump **locally** or maintain a branch **in your repo** so Actions can push.

## Configuration Files

| File | Purpose |
|------|---------|
| `pyproject.toml` | Package metadata, ruff, mypy, pytest, bandit config |
| `Pipfile` | Development and production dependencies (local dev) |
| `tox.ini` | Local dev environments (isolated checks) |
| `.pre-commit-config.yaml` | Git hook definitions |
| `.github/workflows/*.yml` | CI and release automation |
| `Makefile` | Developer convenience commands |
| `docs/legacy/Jenkinsfile` | Historical Jenkins pipeline (reference) |

## Documentation

- [Using this package in another Python service](docs/using-in-another-service.md) — git installs, **Release wheel URLs**, private repo auth, optional PyPI later
- [Legacy Jenkins reference](docs/legacy/README.md)

## License

Internal use only.
