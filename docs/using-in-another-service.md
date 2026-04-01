# Using this package in another Python service

This guide assumes **GitHub** hosts this repository. Consumers typically install from **git** (tag or commit). If your team uses **GitHub Actions** releases (see `.github/workflows/release.yml`), you can also **`pip install` the wheel** attached to a **GitHub Release** (no `git` needed on the install machine).

**Package facts**

| Item | Value |
|------|--------|
| Distribution name (for `pip`) | `hello-world-package` |
| Import name | `hello_world` |
| Python (supported) | `>=3.12` |
| Console script | `hello-world` (optional CLI entry point) |

---

## Recommended: Install from GitHub (tag or commit)

Canonical repository: **https://github.com/shotah/bare_python_tox_package**

Pin a **release tag** (e.g. `v0.1.0`) for reproducible builds. Import name and package metadata come from this repo’s `pyproject.toml`. Examples below use `shotah/bare_python_tox_package`; adjust org/repo if you fork.

### `pip`

HTTPS (fine for local dev; in CI use a token with least privilege):

```bash
pip install "git+https://github.com/shotah/bare_python_tox_package.git@v0.1.0#egg=hello-world-package"
```

SSH (common on developer machines):

```bash
pip install "git+git@github.com:shotah/bare_python_tox_package.git@v0.1.0#egg=hello-world-package"
```

Use a **commit SHA** instead of a tag when you need an exact revision:

```bash
pip install "git+https://github.com/shotah/bare_python_tox_package.git@abc1234deadbeef#egg=hello-world-package"
```

### Pipenv

```toml
[packages]
hello-world-package = {ref = "v0.1.0", git = "https://github.com/shotah/bare_python_tox_package.git"}
```

For a branch (less reproducible):

```toml
hello-world-package = {ref = "main", git = "https://github.com/shotah/bare_python_tox_package.git"}
```

### `requirements.txt`

```text
hello-world-package @ git+https://github.com/shotah/bare_python_tox_package.git@v0.1.0
```

(Requires a recent `pip` that supports PEP 508 direct references in requirements files.)

### `pyproject.toml` (PEP 621)

```toml
[project]
dependencies = [
    "hello-world-package @ git+https://github.com/shotah/bare_python_tox_package.git@v0.1.0",
]
```

**Requirements:** Python `>=3.12`, `git` available on the install machine, and network access to GitHub.

---

## Install from a GitHub Release (wheel or sdist)

When you push a tag like `v0.1.0`, the **Release** workflow uploads **`dist/*.whl`** and **`dist/*.tar.gz`** to that release. The exact wheel filename includes the version from `pyproject.toml` / `__init__.py`, for example:

`hello_world_package-0.1.0-py3-none-any.whl`

### Direct URL with `pip`

1. Open the release on GitHub (e.g. **Releases** → `v0.1.0`).
2. Copy the **browser download URL** for the `.whl` (right-click the asset → copy link).
3. Install:

```bash
pip install "https://github.com/shotah/bare_python_tox_package/releases/download/v0.1.0/hello_world_package-0.1.0-py3-none-any.whl"
```

Replace org, repo, tag, and **filename** with the values shown on your release page.

### `requirements.txt`

```text
https://github.com/shotah/bare_python_tox_package/releases/download/v0.1.0/hello_world_package-0.1.0-py3-none-any.whl
```

### `pyproject.toml`

```toml
[project]
dependencies = [
    "hello-world-package @ https://github.com/shotah/bare_python_tox_package/releases/download/v0.1.0/hello_world_package-0.1.0-py3-none-any.whl",
]
```

**Private repos:** the download URL still requires **authorization** for non-public assets. Use a PAT in CI (`curl` + `pip install ./file.whl`), a private mirror, or stick to **git+SSH** installs instead.

---

## Private GitHub repository

If this repo is **private**, nothing changes in **Python code**: you still `import hello_world` the same way. Only **install time** needs Git to authenticate to GitHub so `pip` can clone the dependency.

### What `pip` does

`pip install git+https://...` (or `git+ssh:...`) runs `git clone` under the hood. A private repo rejects anonymous clones, so the machine running `pip` must present credentials Git accepts.

### Option A: SSH (good for developers and many CI setups)

1. Use an **SSH URL** in your dependency (same as the public examples, but with `git@github.com:...`).
2. Ensure an SSH **private key** is loaded (`ssh-agent`) that is authorized on GitHub:
   - **Personal**: your user’s SSH key added to GitHub → Settings → SSH keys.
   - **CI / server**: a **deploy key** on the dependency repo (read-only) or a **machine user** whose key Jenkins/GitLab/etc. holds.

Example dependency (unchanged from public case, just the URL form):

```bash
pip install "git+git@github.com:shotah/bare_python_tox_package.git@v0.1.0#egg=hello-world-package"
```

In **Docker**, you typically forward the agent (`ssh-agent`) or use BuildKit SSH mounts so the build can clone private repos without baking keys into the image.

### Option B: HTTPS + personal access token (PAT)

GitHub does **not** accept account passwords for Git over HTTPS. Use a **fine-grained** or **classic** PAT with **read** access to repository contents.

**Avoid** putting the token in the URL inside committed files (`git+https://TOKEN@github.com/...`). Prefer:

- **`~/.netrc`** (permissions `600`) on a build agent:

  ```text
  machine github.com
    login YOUR_GITHUB_USERNAME
    password ghp_xxxxxxxxxxxx
  ```

- Or configure Git’s **credential helper** so `git` supplies the token when `pip` invokes it.

Then keep the dependency URL **without** embedded credentials:

```text
hello-world-package @ git+https://github.com/shotah/bare_python_tox_package.git@v0.1.0
```

### Option C: GitHub Actions (consumer repo also on GitHub)

If the **consuming** workflow runs in GitHub Actions and needs to install another **private** repo in the same org (or one `GITHUB_TOKEN` can read):

- Use `actions/checkout` with appropriate `token` / permissions, or
- Use a **PAT** stored in **repository secrets** and pass it only in the install step (e.g. set `GIT_CONFIG_*` or use `https://x-access-token:${{ secrets.MY_PAT }}@github.com/...` in a **secret-only** step—never log or commit that URL).

Cross-org private deps often need a PAT or a deploy key with access to the dependency repo.

### Pipenv with a private repo

The `git = "https://github.com/..."` form is the same; authentication is still via SSH agent, netrc, or credential helper when Pipenv runs `git clone`.

### Summary

| Concern | Answer |
|--------|--------|
| **Imports in Python** | Still `from hello_world import ...` after install succeeds. |
| **What’s different for private repos** | Git must authenticate for the clone; choose SSH or HTTPS+PAT. |
| **CI** | Store keys/tokens in secret storage; use read-only deploy keys or least-privilege PATs. |
| **Never** | Commit PATs or embed long-lived tokens in `pyproject.toml` / `Pipfile` in git. |

---

## Local editable install

When both projects are on the same machine:

```bash
pip install -e /path/to/bare_python_tox_package
```

Or with Pipenv:

```bash
pipenv install -e ../bare_python_tox_package
```

---

## Using the library in code

```python
from hello_world import greet, hello_world

print(hello_world())
print(greet("Team"))
```

Optional CLI (if console scripts are installed):

```bash
hello-world
```

---

## Versioning and upgrades

- Version is defined in this repo’s `src/hello_world/__init__.py` (see root `readme.md`).
- **Pin tags** in consumer dependencies (`v0.1.0`, not floating `main`) for production.
- To upgrade: change the tag or SHA in the consumer’s dependency and reinstall.

---

## CI/CD for the consuming service

1. **Private GitHub repo**: give the job a deploy key, `GITHUB_TOKEN`, or machine user with read access.
2. **Install step**: run `pip install` / `pipenv install` so the git URL resolves (same commands as above).
3. **Caching**: cache pip wheels; git-based installs still clone the repo each time unless you vendor a wheel you built yourself.

---

## Optional: PyPI or another index later

If your org later publishes wheels to **PyPI** (public or private), consumers can switch to:

```bash
pip install hello-world-package==0.1.0
```

That is **not** the default for this template; everything above stays valid without any package index.

---

## Troubleshooting

| Problem | What to check |
|---------|----------------|
| `git` errors during install | `git` installed, URL correct, tag/branch exists |
| `401` / `403` | Private repo: token or SSH key, repo access |
| Wrong code version | Pin tag or SHA; avoid unpinned `main` in production |
| Build failures | Consumer must use Python `>=3.12`; check error from `pip` when building the sdist/wheel |

For building this package locally, see the root `readme.md` and `.github/workflows/`. For the historical Jenkins pipeline, see `docs/legacy/Jenkinsfile`.
