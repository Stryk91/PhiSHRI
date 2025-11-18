# Contributing to PhiLaunch

Thank you for considering contributing to PhiLaunch! This document provides guidelines and instructions for contributing.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

---

## Code of Conduct

### Be Respectful

- Treat all contributors with respect
- Welcome newcomers and help them get started
- Accept constructive criticism gracefully
- Focus on what is best for the project

### Be Collaborative

- Share knowledge and help others
- Review pull requests promptly
- Communicate clearly and professionally

---

## Getting Started

### 1. Fork and Clone

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/PhiLaunch.git
cd PhiLaunch
```

### 2. Setup Environment

```bash
# Run setup wizard
./setup.sh

# Install dependencies
./scripts/check-dependencies.sh

# Install git hooks
./scripts/install-hooks.sh
```

### 3. Create Branch

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Or bugfix branch
git checkout -b fix/bug-description
```

---

## Development Workflow

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test additions/changes

### Making Changes

1. **Write Code**
   ```bash
   # Edit files
   vim automation/my-script.sh
   ```

2. **Test Locally**
   ```bash
   # Run tests
   bats tests/

   # Check syntax
   bash -n automation/my-script.sh

   # Run shellcheck
   shellcheck automation/my-script.sh
   ```

3. **Run Pre-commit Checks**
   ```bash
   # Manual check
   .githooks/pre-commit

   # Or let git hook run automatically
   git commit -m "feat: Add new feature"
   ```

4. **Push Changes**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```bash
feat: Add WoW monitor script

Add script to monitor World of Warcraft server latency using mtr.
Includes automatic logging and high latency alerts.

Closes #42

---

fix: Correct path in launch-script.sh

The script was using hardcoded path instead of config variable.
Now properly sources config and uses $PHILAUNCH_HOME.

---

docs: Update testing guide

Add section on writing integration tests and mocking commands.
```

---

## Coding Standards

### Bash Scripts

#### File Header

```bash
#!/bin/bash
# Script Name: description.sh
# Description: What this script does
# Usage: ./description.sh [options]

set -e  # Exit on error (if appropriate)
```

#### Style Guidelines

- Use 4 spaces for indentation (not tabs)
- Maximum line length: 120 characters
- Use meaningful variable names
- Quote all variables: `"$variable"`
- Use `$()` for command substitution, not backticks
- Use `[[ ]]` for conditions, not `[ ]`

#### Example

```bash
#!/bin/bash
# Good example script

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/load-config.sh"

# Function with proper style
check_status() {
    local service="$1"

    if [[ -z "$service" ]]; then
        echo "Error: service name required"
        return 1
    fi

    if systemctl is-active --quiet "$service"; then
        echo "✓ $service is running"
        return 0
    else
        echo "✗ $service is not running"
        return 1
    fi
}

# Main logic
main() {
    echo "Checking services..."
    check_status "ssh"
    check_status "docker"
}

main "$@"
```

### Configuration Usage

**Always use config variables:**

```bash
# Bad ❌
ssh stryk@192.168.50.149 -p 2222 'uptime'

# Good ✅
source "${SCRIPT_DIR}/../config/load-config.sh"
ssh -p "${PHILAUNCH_SSH_PORT}" "${PHILAUNCH_SSH_CONN}" 'uptime'
```

### Error Handling

```bash
# Check for errors
if ! command_that_might_fail; then
    echo "Error: Command failed"
    exit 1
fi

# Or use set -e
set -e
command_that_should_succeed

# Cleanup on error
trap 'cleanup_function' EXIT ERR
```

---

## Testing

### Writing Tests

See [docs/TESTING.md](docs/TESTING.md) for comprehensive testing guide.

**Every new script should include tests:**

```bash
# tests/unit/test_my_script.bats
#!/usr/bin/env bats

load ../test_helper

@test "script exists and is executable" {
    [ -f "$PHILAUNCH_ROOT/my_script.sh" ]
    [ -x "$PHILAUNCH_ROOT/my_script.sh" ]
}

@test "script has valid syntax" {
    run bash -n "$PHILAUNCH_ROOT/my_script.sh"
    assert_success
}

@test "script shows help" {
    run bash "$PHILAUNCH_ROOT/my_script.sh" --help
    assert_success
    assert_output_contains "Usage"
}
```

### Running Tests

```bash
# All tests
bats tests/

# Specific test file
bats tests/unit/test_my_script.bats

# With verbose output
bats tests/ --verbose
```

### Coverage Goals

- All scripts should have syntax tests
- Critical functions should have unit tests
- Major workflows should have integration tests
- Aim for >70% coverage of important code paths

---

## Submitting Changes

### 1. Ensure Quality

```bash
# Run all checks
bats tests/
shellcheck **/*.sh
./scripts/check-dependencies.sh
```

### 2. Update Documentation

- Update README if adding features
- Add/update relevant docs in `docs/`
- Update CHANGES-SUMMARY.md if needed
- Add docstrings to functions

### 3. Create Pull Request

1. Push to your fork
2. Go to GitHub and create PR
3. Fill in PR template:
   - What does this PR do?
   - How to test?
   - Related issues?
   - Breaking changes?

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
How to test these changes:
1. Step one
2. Step two

## Checklist
- [ ] Tests pass locally
- [ ] ShellCheck passes
- [ ] Documentation updated
- [ ] Commit messages follow convention
- [ ] No hardcoded values (uses config)
```

---

## Review Process

### What Reviewers Look For

1. **Functionality** - Does it work as intended?
2. **Code Quality** - Is it well-written and maintainable?
3. **Testing** - Are there adequate tests?
4. **Documentation** - Is it documented?
5. **Style** - Does it follow project conventions?
6. **Security** - No exposed secrets or vulnerabilities?

### Responding to Feedback

- Be open to suggestions
- Ask questions if unclear
- Make requested changes
- Update PR with fixes
- Re-request review when ready

### Approval Process

1. **Automated Checks** - All CI checks must pass
2. **Code Review** - At least one approval required
3. **Testing** - Manual testing if needed
4. **Merge** - Maintainer merges PR

---

## Common Tasks

### Adding a New Script

1. **Create script**
   ```bash
   touch automation/new-script.sh
   chmod +x automation/new-script.sh
   ```

2. **Add header and load config**
   ```bash
   #!/bin/bash
   # New Script: Description

   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "${SCRIPT_DIR}/../config/load-config.sh"

   # Your code here
   ```

3. **Write tests**
   ```bash
   touch tests/unit/test_new_script.bats
   # Add tests
   ```

4. **Test and commit**
   ```bash
   bats tests/unit/test_new_script.bats
   git add automation/new-script.sh tests/unit/test_new_script.bats
   git commit -m "feat: Add new-script.sh for [purpose]"
   ```

### Fixing a Bug

1. **Create test that reproduces bug**
   ```bash
   @test "bug reproduction" {
       run bash script-with-bug.sh
       assert_failure  # This should fail until bug is fixed
   }
   ```

2. **Fix the bug**

3. **Verify test passes**
   ```bash
   bats tests/unit/test_script.bats
   ```

4. **Commit fix**
   ```bash
   git commit -m "fix: Correct [issue] in [script]

   [Description of what was wrong and how it's fixed]

   Fixes #123"
   ```

### Updating Documentation

1. **Edit relevant docs**
   ```bash
   vim docs/TESTING.md
   ```

2. **Check markdown**
   ```bash
   markdownlint docs/*.md
   ```

3. **Commit**
   ```bash
   git commit -m "docs: Update testing guide

   Add section on integration tests and examples."
   ```

---

## Getting Help

### Resources

- **Documentation**: See `docs/` directory
- **Examples**: Look at existing scripts
- **Testing Guide**: [docs/TESTING.md](docs/TESTING.md)
- **CI/CD Guide**: [docs/CI-CD.md](docs/CI-CD.md)

### Ask Questions

- Open an issue for questions
- Comment on relevant PR
- Check existing issues first

---

## Recognition

Contributors are recognized in:
- Git commit history
- CHANGES-SUMMARY.md for major features
- Release notes

Thank you for contributing to PhiLaunch! 🚀

---

**Last Updated:** 2025-11-12
**Maintained By:** PhiLaunch Contributors
