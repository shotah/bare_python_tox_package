# TODO: Package Setup Checklist

This document tracks steps for the **GitHub + GitHub Actions** workflow: CI on PR/push; **Release** workflow attaches wheel/sdist to **GitHub Releases** on `v*` tags. Consumers install via **git URL** or **release wheel URL** (see `docs/using-in-another-service.md`).

## Phase 1: Project Structure

- [x] **Create source directory structure**
- [x] **Create test directory structure**

## Phase 2: Package Configuration

- [x] **Update pyproject.toml for packaging**
- [x] **Update Pipfile for package development** (twine used for `twine check` on `dist/`, not for a private index by default)

## Phase 3: Tox Configuration

- [x] **Create tox.ini** (local dev; Jenkins uses direct commands)

## Phase 4: Makefile Updates

- [x] **Refactor Makefile for package workflow**
- [x] `build` / `publish-test` (twine check only); no private index upload target

## Phase 5: Pre-commit Updates

- [x] **Update .pre-commit-config.yaml**

## Phase 6: GitHub Actions

- [x] **`.github/workflows/ci.yml`** — lint, type, security, test, build, upload `dist` artifact
- [x] **`.github/workflows/release.yml`** — on tag `v*`, run checks, build, attach `dist/*` to GitHub Release (`softprops/action-gh-release`)
- [ ] **Org policy** — allow Actions, `contents: write` for releases, third-party action allowlist if required

## Phase 6b: Legacy Jenkins (reference only)

- [x] **`docs/legacy/Jenkinsfile`** — copy of former root pipeline for teams still on Jenkins

## Phase 7: GitHub & Releases

- [x] **Repository** — https://github.com/shotah/bare_python_tox_package (`pyproject.toml` URLs and docs updated)
- [ ] **Release discipline** — bump `__version__`, tag `vX.Y.Z`, push tags; confirm Release assets on GitHub

## Phase 8: Testing & Validation

- [x] **Local validation** (lint, type, security, test, build)
- [ ] Run `make hooks` / `make tox` if not already verified
- [ ] **CI validation** — push branch, confirm GitHub Actions passes
- [ ] **Consumer smoke test** — from another repo, `pip install git+https://...git@v0.1.0#egg=hello-world-package`

## Phase 9: Documentation

- [x] **README** — GitHub-first workflow
- [x] **docs/using-in-another-service.md** — git installs from GitHub
- [ ] CONTRIBUTING.md / CHANGELOG.md (optional)

---

## Quick Reference: File Changes Summary

| File | Purpose |
|------|---------|
| `src/hello_world/` | Package source |
| `tests/` | Tests |
| `pyproject.toml` | Metadata (GitHub URLs are placeholders) |
| `Pipfile` | Dev deps |
| `tox.ini` | Local tox envs |
| `Makefile` | Dev commands |
| `.pre-commit-config.yaml` | Hooks |
| `.github/workflows/*.yml` | CI + release assets |
| `docs/legacy/Jenkinsfile` | Reference Jenkins pipeline |
| `docs/using-in-another-service.md` | How other services depend on this repo |

---

## Notes

### Python version strategy

| Aspect | Version |
|--------|---------|
| **Supported** | `>=3.12` |
| **Developed/Tested** | `3.14` |
| **Ruff target** | `py312` |

### Package version strategy

- Single source: `src/hello_world/__init__.py` → `__version__`
- Release: feature-branch **bump-version.yml** pushes bump; **release.yml** on `main` publishes (no bot push to `main`)

### Security

- Never commit credentials; use GitHub deploy keys / `GITHUB_TOKEN` / OIDC in CI for private repos.

### Optional later

- **PyPI** (public or private): consumers could switch to `pip install hello-world-package==...`
- **GitHub Releases**: attach `dist/*.whl` for download-only workflows
