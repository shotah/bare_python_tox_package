# Legacy Jenkins pipeline

`Jenkinsfile` in this folder is a **reference copy** of the pipeline we used when Jenkins was the primary CI runner.

**Current approach:** use **GitHub Actions** in `.github/workflows/` for continuous integration and for attaching **wheel + sdist** to **GitHub Releases** when you push a version tag (`v*`).

Copy `Jenkinsfile` back to a Jenkins job’s repo root if you still run Jenkins elsewhere; Groovy does not run from this path automatically.
