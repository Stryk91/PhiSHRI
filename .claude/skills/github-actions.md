---
name: GitHub Actions
description: Create, debug, and optimize GitHub Actions workflows
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
argument-hint: "<command> [workflow-name]"
---

# GitHub Actions Skill

You are an expert at GitHub Actions CI/CD workflows. Help users create, debug, and optimize their workflows.

## Commands

When the user invokes this skill, parse their request:

- `/github-actions create <type>` - Create a new workflow
- `/github-actions debug` - Debug failing workflows
- `/github-actions optimize` - Optimize existing workflows
- `/github-actions secrets` - Help with secrets management
- `/github-actions matrix` - Set up matrix builds
- `/github-actions cache` - Add caching to workflows
- `/github-actions reusable` - Create reusable workflows
- `/github-actions list` - List all workflows in repo

## Workflow Types for `create`

When creating workflows, ask which type if not specified:

1. **ci** - Basic CI (test on push/PR)
2. **release** - Build and publish releases
3. **deploy** - Deploy to environments
4. **docker** - Build and push Docker images
5. **rust** - Rust-specific CI (cargo test, clippy, fmt)
6. **node** - Node.js CI (npm test, lint, build)
7. **python** - Python CI (pytest, mypy, ruff)
8. **docs** - Documentation deployment
9. **scheduled** - Cron-based scheduled tasks
10. **composite** - Reusable composite action

## Workflow Location

All workflows go in `.github/workflows/`. Create the directory if it doesn't exist.

## Templates

### Basic CI Template
```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup
        # Add setup steps here

      - name: Build
        run: echo "Add build command"

      - name: Test
        run: echo "Add test command"
```

### Rust CI Template
```yaml
name: Rust CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

env:
  CARGO_TERM_COLOR: always

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy

      - name: Cache cargo
        uses: Swatinem/rust-cache@v2

      - name: Check format
        run: cargo fmt --all -- --check

      - name: Clippy
        run: cargo clippy --all-targets --all-features -- -D warnings

      - name: Test
        run: cargo test --all-features

  build:
    needs: check
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    steps:
      - uses: actions/checkout@v4

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Cache cargo
        uses: Swatinem/rust-cache@v2

      - name: Build
        run: cargo build --release

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: binary-${{ matrix.os }}
          path: target/release/
```

### Node.js CI Template
```yaml
name: Node.js CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18.x, 20.x, 22.x]
    steps:
      - uses: actions/checkout@v4

      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint --if-present

      - name: Test
        run: npm test --if-present

      - name: Build
        run: npm run build --if-present
```

### Python CI Template
```yaml
name: Python CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ruff pytest mypy
          pip install -r requirements.txt

      - name: Lint with ruff
        run: ruff check .

      - name: Type check with mypy
        run: mypy . --ignore-missing-imports

      - name: Test with pytest
        run: pytest -v
```

### Docker Build & Push Template
```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Release Template
```yaml
name: Release

on:
  push:
    tags: ['v*']

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: echo "Add build steps here"

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
          files: |
            dist/*
```

### Scheduled Task Template
```yaml
name: Scheduled Task

on:
  schedule:
    # Run at 00:00 UTC every day
    - cron: '0 0 * * *'
  workflow_dispatch:  # Allow manual trigger

jobs:
  task:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run scheduled task
        run: echo "Add your scheduled task here"
```

### Reusable Workflow Template
```yaml
# .github/workflows/reusable-build.yml
name: Reusable Build

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      version:
        required: false
        type: string
        default: 'latest'
    secrets:
      deploy_key:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4

      - name: Build for ${{ inputs.environment }}
        run: echo "Building version ${{ inputs.version }}"
        env:
          DEPLOY_KEY: ${{ secrets.deploy_key }}
```

## Debugging Failed Workflows

When debugging, check these in order:

1. **Read the error message** - Usually in the failed step's logs
2. **Check permissions** - `permissions:` block may be missing
3. **Check secrets** - Secrets not available in forks or may be expired
4. **Check paths** - Working directory issues are common
5. **Check shell** - Windows uses PowerShell by default
6. **Check cache** - Stale cache can cause issues

### Common Fixes

```yaml
# Fix: Add permissions
permissions:
  contents: read
  packages: write
  pull-requests: write

# Fix: Set working directory
- name: Build
  working-directory: ./app
  run: npm build

# Fix: Use specific shell
- name: Script
  shell: bash
  run: |
    echo "This runs in bash even on Windows"

# Fix: Clear cache
# Add to workflow or use GitHub UI to clear caches

# Fix: Debug with tmate
- name: Debug with tmate
  if: failure()
  uses: mxschmitt/action-tmate@v3
```

## Caching Strategies

```yaml
# Generic cache
- uses: actions/cache@v4
  with:
    path: ~/.cache
    key: ${{ runner.os }}-cache-${{ hashFiles('**/lockfile') }}
    restore-keys: |
      ${{ runner.os }}-cache-

# Rust cache (recommended)
- uses: Swatinem/rust-cache@v2

# Node cache (built into setup-node)
- uses: actions/setup-node@v4
  with:
    cache: 'npm'

# Python cache (built into setup-python)
- uses: actions/setup-python@v5
  with:
    cache: 'pip'
```

## Secrets Management

```yaml
# Reference secrets
env:
  API_KEY: ${{ secrets.API_KEY }}

# Use GitHub token (auto-provided)
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# Environment-specific secrets
jobs:
  deploy:
    environment: production
    steps:
      - run: echo "Uses production secrets"
        env:
          API_KEY: ${{ secrets.PROD_API_KEY }}
```

## Matrix Builds

```yaml
strategy:
  fail-fast: false  # Don't cancel other jobs if one fails
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node: [18, 20, 22]
    exclude:
      - os: windows-latest
        node: 18
    include:
      - os: ubuntu-latest
        node: 22
        experimental: true
```

## Conditional Execution

```yaml
# Run on specific conditions
- name: Deploy
  if: github.ref == 'refs/heads/main'
  run: ./deploy.sh

# Run on tag
- name: Release
  if: startsWith(github.ref, 'refs/tags/v')
  run: ./release.sh

# Run on failure
- name: Notify on failure
  if: failure()
  run: ./notify.sh

# Run always (even if cancelled)
- name: Cleanup
  if: always()
  run: ./cleanup.sh
```

## Best Practices

1. **Pin action versions** - Use `@v4` not `@main`
2. **Use caching** - Speed up builds significantly
3. **Fail fast in PRs** - But not in main branch builds
4. **Use matrix for cross-platform** - Test all targets
5. **Keep secrets minimal** - Only what's needed
6. **Use environments** - For deployment protection
7. **Add concurrency limits** - Prevent duplicate runs

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Execution Instructions

1. First, check if `.github/workflows/` exists in the repo
2. List existing workflows if any
3. Based on the command, create/modify/debug workflows
4. Always validate YAML syntax before saving
5. Explain what the workflow does after creating it
