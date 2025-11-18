# PhiLaunch CI/CD Documentation

Continuous Integration and Continuous Deployment setup for PhiLaunch.

---

## Overview

PhiLaunch uses **GitHub Actions** for automated testing, linting, and security scanning on every push and pull request.

---

## Workflow Jobs

### 1. ShellCheck Linting

**Purpose:** Lint all shell scripts for common issues

**What it checks:**
- Syntax errors
- Deprecated syntax
- Quoting issues
- Variable usage problems
- Portability issues

**Configuration:**
- Runs on: All `.sh` files
- Excludes: `.git/`, `workspace/`, `exported_chats/`
- Ignores: SC1090, SC1091 (source file checking)

**Fix failures:**
```bash
# Install shellcheck
sudo apt install shellcheck  # Ubuntu
brew install shellcheck      # macOS

# Run locally
shellcheck **/*.sh

# Fix specific file
shellcheck automation/home-control.sh
```

### 2. Security Scanning

**Purpose:** Detect exposed secrets and credentials

**Tools:**
- **TruffleHog** - Scans for high-entropy strings and known patterns
- **GitLeaks** - Checks for hardcoded secrets in code and history

**What it finds:**
- API keys
- Passwords
- Tokens
- Private keys
- AWS credentials
- Database credentials

**Fix failures:**
```bash
# Remove the secret from code
# If already committed, remove from history:
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch <file-with-secret>" \
  --prune-empty --tag-name-filter cat -- --all

# Or use BFG Repo-Cleaner
bfg --delete-files <file-with-secret>
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

### 3. Syntax Validation

**Purpose:** Validate bash syntax across all scripts

**How it works:**
- Finds all `.sh` files
- Runs `bash -n` on each
- Reports syntax errors

**Fix failures:**
```bash
# Check specific file
bash -n automation/home-control.sh

# Common issues:
# - Missing quotes
# - Unclosed brackets
# - Invalid command names
```

### 4. Test Suite

**Purpose:** Run automated tests with bats

**What it tests:**
- Unit tests for individual scripts
- Integration tests for workflows
- Config system functionality
- Script interactions

**Fix failures:**
```bash
# Run tests locally
bats tests/

# Run specific test
bats tests/unit/test_config_loader.bats

# Debug test
bats tests/unit/test_config_loader.bats --verbose
```

See [TESTING.md](TESTING.md) for complete testing guide.

### 5. Dependency Check

**Purpose:** Verify required tools are available

**Checks for:**
- bash, git, ssh, tmux
- grep, sed, awk, curl
- Optional: docker, python3, node, shellcheck

**Fix failures:**
```bash
# Install missing dependencies
sudo apt install git openssh-client tmux  # Ubuntu
brew install git openssh tmux             # macOS

# Check locally
./scripts/check-dependencies.sh
```

### 6. Config Validation

**Purpose:** Ensure config system is intact

**Validates:**
- Config template exists (`config/philaunch.conf.example`)
- Personal config NOT committed (`config/philaunch.conf` should not exist)
- Setup wizard exists (`setup.sh`)

**Fix failures:**
```bash
# If personal config committed:
git rm --cached config/philaunch.conf
git commit -m "Remove personal config"

# Ensure it's in .gitignore
echo "config/philaunch.conf" >> .gitignore
```

### 7. Markdown Linting

**Purpose:** Check markdown file formatting

**Note:** This job uses `continue-on-error: true` and won't fail the build.

**Configuration:** See `.markdownlint.json`

**Fix warnings:**
```bash
# Install markdownlint-cli
npm install -g markdownlint-cli

# Check files
markdownlint '**/*.md'

# Auto-fix
markdownlint '**/*.md' --fix
```

---

## Workflow Triggers

### Push to Branches

Runs on:
- `main`
- `develop`
- `claude/**` (Claude-generated branches)

```yaml
on:
  push:
    branches: [ main, develop, 'claude/**' ]
```

### Pull Requests

Runs on PRs targeting:
- `main`
- `develop`

```yaml
on:
  pull_request:
    branches: [ main, develop ]
```

### Manual Trigger

Can be triggered manually from GitHub Actions UI:

```yaml
on:
  workflow_dispatch:
```

---

## Status Badges

Add to README.md:

```markdown
![CI Status](https://github.com/your-username/PhiLaunch/workflows/PhiLaunch%20CI/badge.svg)
```

---

## Local Pre-commit Checks

Run the same checks locally before committing:

### Install Pre-commit Hook

```bash
./scripts/install-hooks.sh
```

This installs a pre-commit hook that runs:
- Secret detection
- Personal config check
- Bash syntax validation
- ShellCheck linting

### Manual Pre-commit Checks

```bash
# Run all checks
.githooks/pre-commit

# Or individual checks
bash -n **/*.sh              # Syntax
shellcheck **/*.sh           # Linting
./scripts/check-dependencies.sh  # Dependencies
bats tests/                  # Tests
```

---

## Workflow Configuration

### File Location

`.github/workflows/ci.yml`

### Customization

#### Skip CI for Commits

Add to commit message:

```bash
git commit -m "docs: Update README [skip ci]"
```

#### Add New Job

```yaml
new-job:
  name: My New Check
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run my check
      run: ./my-check-script.sh
```

#### Modify Existing Job

Edit `.github/workflows/ci.yml` and adjust the relevant job.

---

## Troubleshooting

### "Workflow file is invalid"

**Cause:** YAML syntax error

**Solution:**
```bash
# Validate YAML locally
yamllint .github/workflows/ci.yml

# Or use GitHub's action validator
# https://github.com/rhysd/actionlint
```

### Job Timeout

**Cause:** Job running too long (default: 6 hours)

**Solution:**
```yaml
jobs:
  job-name:
    timeout-minutes: 10  # Set lower timeout
```

### Secrets Not Available

**Cause:** Secret not configured in repository settings

**Solution:**
1. Go to Settings → Secrets and variables → Actions
2. Add secret (e.g., `DISCORD_TOKEN`)
3. Reference in workflow: `${{ secrets.DISCORD_TOKEN }}`

### Tests Pass Locally But Fail in CI

**Common causes:**
1. Environment differences (PATH, installed tools)
2. Hardcoded paths (use relative paths)
3. Missing dependencies
4. Timing issues

**Solution:**
```bash
# Match CI environment
docker run -v $(pwd):/workspace -w /workspace ubuntu:latest bash -c "
  apt update &&
  apt install -y bats shellcheck git &&
  bats tests/
"
```

### ShellCheck Warnings

**Ignore specific warnings:**

In script:
```bash
# shellcheck disable=SC2086
variable_usage_without_quotes
```

In workflow:
```yaml
env:
  SHELLCHECK_OPTS: -e SC1090 -e SC1091 -e SC2086
```

---

## Best Practices

### DO ✅

- Run checks locally before pushing
- Keep workflows fast (<5 minutes)
- Use caching for dependencies
- Add status badges to README
- Document any required secrets
- Use specific action versions (not `@latest`)

### DON'T ❌

- Don't commit secrets (use GitHub Secrets)
- Don't skip CI without good reason
- Don't ignore failures (fix them!)
- Don't make workflows dependent on external services
- Don't use `--no-verify` to bypass hooks

---

## GitHub Actions Limits

**Free tier (public repos):**
- Unlimited minutes
- 20 concurrent jobs

**Free tier (private repos):**
- 2,000 minutes/month
- 20 concurrent jobs

**Paid plans:** See [GitHub pricing](https://github.com/pricing)

---

## Monitoring

### View Workflow Runs

1. Go to repository on GitHub
2. Click "Actions" tab
3. See all workflow runs and their status

### Get Notifications

Configure in GitHub Settings → Notifications:
- Email on workflow failure
- GitHub notifications
- Mobile app notifications

---

## Advanced Configuration

### Matrix Builds

Test on multiple OS/versions:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, ubuntu-20.04, macos-latest]
runs-on: ${{ matrix.os }}
```

### Conditional Jobs

```yaml
if: github.ref == 'refs/heads/main'
```

### Artifacts

Save test results:

```yaml
- uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: test-results/
```

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [PhiLaunch CI Workflow](../.github/workflows/ci.yml)
- [ShellCheck](https://www.shellcheck.net/)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)
- [GitLeaks](https://github.com/gitleaks/gitleaks)

---

**Last Updated:** 2025-11-12
**Maintained By:** PhiLaunch Contributors
