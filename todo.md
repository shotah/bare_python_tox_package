# TODO: Package Setup Checklist

This document tracks all steps needed to get the package ready for publishing to Artifactory via Jenkins.

## Phase 1: Project Structure

- [x] **Create source directory structure**
  - [x] Create `src/hello_world/` directory
  - [x] Create `src/hello_world/__init__.py` with version
  - [x] Create `src/hello_world/main.py` with hello world function

- [x] **Create test directory structure**
  - [x] Create `tests/` directory
  - [x] Create `tests/__init__.py`
  - [x] Create `tests/test_hello.py` with basic tests

## Phase 2: Package Configuration

- [x] **Update pyproject.toml for packaging**
  - [x] Change project name from `bare-python-lambda` to `hello-world-package`
  - [x] Add package metadata (author, license, classifiers)
  - [x] Configure build system (setuptools)
  - [x] Define package discovery for `src/` layout
  - [x] Add optional dependencies groups
  - [x] Remove AWS Lambda-specific configs

- [x] **Update Pipfile for package development**
  - [x] Add `build` package for building wheels
  - [x] Add `twine` for publishing to Artifactory
  - [x] Add `tox` for multi-environment testing
  - [x] Remove AWS/Lambda specific packages (aws-lambda-powertools, boto3-stubs, etc.)
  - [x] Keep dev packages: pytest, pre-commit, ruff, mypy, bandit
  - [x] Update Python version requirement to 3.14

## Phase 3: Tox Configuration

- [x] **Create tox.ini** (for local dev convenience; Jenkins uses direct commands)
  - [x] Configure base testenv with pytest
  - [x] Add `py314` environment (Python 3.14 only)
  - [x] Add `lint` environment (ruff check + format)
  - [x] Add `type` environment (mypy)
  - [x] Add `security` environment (bandit)
  - [x] Add `build` environment (build wheel + sdist)
  - [x] Add `all` environment (run all checks in one go)
  - [x] Configure coverage reporting

## Phase 4: Makefile Updates

- [x] **Refactor Makefile for package workflow**
  - [x] Remove SAM/Lambda specific commands
  - [x] Keep: `install`, `install-dev`, `hooks`, `lint`, `test`, `clean`
  - [x] Add: `type-check` (mypy standalone)
  - [x] Add: `security` (bandit standalone)
  - [x] Add: `tox` (run all tox environments)
  - [x] Add: `build` (build wheel + sdist)
  - [x] Add: `publish` (upload to Artifactory)
  - [x] Add: `clean-build` (remove dist/, build/, *.egg-info)
  - [x] Update help text

## Phase 5: Pre-commit Updates

- [x] **Update .pre-commit-config.yaml**
  - [x] Remove cfn-lint hook (SAM specific)
  - [x] Keep all other hooks (ruff, mypy, bandit, pytest, etc.)
  - [x] Update hook versions
  - [x] Verify mypy additional_dependencies are correct for new package

## Phase 6: Jenkins Pipeline

- [x] **Create Jenkinsfile**
  - [x] Define pipeline agent (Python 3.14 + Pipenv available)
  - [x] Add environment variables section
    - [x] `ARTIFACTORY_URL`
    - [x] `ARTIFACTORY_REPO`
    - [x] `ARTIFACTORY_CREDS` (username/password from credentials)
  - [x] **Stage: Checkout**
    - [x] Checkout from CodeCommit
  - [x] **Stage: Setup**
    - [x] Install pipenv
    - [x] Run `pipenv install --dev`
  - [x] **Stage: Lint**
    - [x] Run `pipenv run ruff check src/ tests/`
    - [x] Run `pipenv run ruff format --check src/ tests/`
  - [x] **Stage: Type Check**
    - [x] Run `pipenv run mypy src/`
  - [x] **Stage: Security**
    - [x] Run `pipenv run bandit -r src/ -c pyproject.toml`
    - [x] Archive bandit-report.json
  - [x] **Stage: Test**
    - [x] Run `pipenv run pytest --cov=hello_world --cov-report=xml`
    - [x] Publish test results (JUnit)
    - [x] Publish coverage report (Cobertura)
  - [x] **Stage: Build**
    - [x] Run `pipenv run python -m build`
    - [x] Archive artifacts (dist/*.whl, dist/*.tar.gz)
  - [x] **Stage: Publish** (main branch only)
    - [x] Configure twine for Artifactory
    - [x] Upload wheel and sdist to Artifactory

- [x] **Add post actions**
  - [x] Always: Clean workspace
  - [x] Success: Log message
  - [x] Failure: Log message (notification commented out as template)

## Phase 7: Artifactory Configuration

- [x] **Create .pypirc template** (for local development)
  - [x] Add Artifactory repository configuration
  - [x] Document how to set up locally
  - [x] Document environment variable approach

- [ ] **Artifactory setup (infrastructure team)**
  - [ ] Create PyPI repository in Artifactory (local repo type)
  - [ ] Set up service account for Jenkins
  - [ ] Generate API token for service account
  - [ ] Add credentials to Jenkins credential store
  - [ ] Configure repository permissions

## Phase 8: Testing & Validation

- [x] **Local validation**
  - [x] Run `make install-dev` - verify deps install
  - [x] Run `make lint` - verify linting passes (ruff check + format)
  - [x] Run `make type-check` - verify mypy passes
  - [x] Run `make security` - verify bandit passes
  - [x] Run `make test` - verify tests pass (9 tests)
  - [x] Run `make build` - verify package builds
  - [ ] Run `make hooks` - verify pre-commit installs
  - [ ] Run `make tox` - verify all tox environments pass
  - [ ] Verify wheel can be installed: `pip install dist/*.whl`

- [ ] **CI validation (after infrastructure ready)**
  - [ ] Push to CodeCommit feature branch
  - [ ] Verify Jenkins pipeline runs
  - [ ] Verify all stages pass
  - [ ] Merge to main
  - [ ] Verify package publishes to Artifactory

## Phase 9: Documentation

- [x] **Finalize documentation**
  - [x] Update README with commands and structure
  - [ ] Add CONTRIBUTING.md (optional)
  - [ ] Add CHANGELOG.md (optional)
  - [ ] Document any GovCloud-specific considerations

---

## Quick Reference: File Changes Summary

| File | Action | Status |
|------|--------|--------|
| `src/hello_world/__init__.py` | Create | Done |
| `src/hello_world/main.py` | Create | Done |
| `tests/__init__.py` | Create | Done |
| `tests/test_hello.py` | Create | Done |
| `pyproject.toml` | Modify | Done |
| `Pipfile` | Modify | Done |
| `tox.ini` | Create | Done |
| `Makefile` | Modify | Done |
| `.pre-commit-config.yaml` | Modify | Done |
| `.gitignore` | Modify | Done |
| `Jenkinsfile` | Create | Done |
| `.pypirc.example` | Create | Done |
| `readme.md` | Modify | Done |

---

## Built Artifacts

```
dist/
├── hello_world_package-0.1.0-py3-none-any.whl
└── hello_world_package-0.1.0.tar.gz
```

---

## Notes

### GovCloud Considerations

- Artifactory URL will be internal to GovCloud VPC
- May need VPN or Direct Connect for local publishing
- Jenkins agents must have network access to Artifactory

### Python Version Strategy

| Aspect | Version | Notes |
|--------|---------|-------|
| **Supported** | `>=3.12` | Consumers can install on Python 3.12+ |
| **Developed/Tested** | `3.14` | CI builds and tests on Python 3.14 |
| **Ruff Target** | `py312` | Linting rules target 3.12 for compatibility |

### Package Version Strategy

**Current: Single Source of Truth**

- Version defined in `src/hello_world/__init__.py` → `__version__ = "X.Y.Z"`
- `pyproject.toml` reads it dynamically via `[tool.setuptools.dynamic]`
- Use semantic versioning (MAJOR.MINOR.PATCH)

**Release workflow:**

1. Update `__version__` in `src/hello_world/__init__.py`
2. Commit and tag: `git commit -am "Bump to X.Y.Z" && git tag vX.Y.Z`
3. Push: `git push && git push --tags`

**Future: Git-Tag Versioning (setuptools-scm)**

- Migration instructions are in `pyproject.toml` comments
- Versions derived automatically from git tags
- No manual version editing needed

### Security

- Never commit credentials
- Use Jenkins credentials store for Artifactory token
- Consider using Artifactory access tokens with limited scope

### Jenkins Credentials Required

| Credential ID | Type | Description |
|---------------|------|-------------|
| `artifactory-url` | Secret text | Artifactory server URL |
| `artifactory-credentials` | Username/Password | Service account credentials |
