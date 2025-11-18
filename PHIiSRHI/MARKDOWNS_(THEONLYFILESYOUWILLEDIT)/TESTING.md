# PhiLaunch Testing Guide

Complete guide to testing PhiLaunch scripts and automation.

---

## Table of Contents

- [Overview](#overview)
- [Test Framework](#test-framework)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

---

## Overview

PhiLaunch uses **bats** (Bash Automated Testing System) for testing bash scripts.

### Test Types

- **Unit Tests** - Test individual functions and scripts in isolation
- **Integration Tests** - Test complete workflows and script interactions
- **Syntax Tests** - Validate bash syntax across all scripts
- **Security Tests** - Scan for exposed secrets and vulnerabilities

---

## Test Framework

### Directory Structure

```
tests/
├── test_helper.bash           # Shared test utilities
├── unit/                      # Unit tests
│   ├── test_config_loader.bats
│   ├── test_setup_wizard.bats
│   └── test_automation_scripts.bats
└── integration/               # Integration tests
    └── test_config_workflow.bats
```

### Test Helper Functions

`test_helper.bash` provides common functions:

- `setup_test_env()` - Creates isolated test environment
- `teardown_test_env()` - Cleans up after tests
- `assert_success()` - Assert command succeeded
- `assert_failure()` - Assert command failed
- `assert_output_contains()` - Check output contains string
- `assert_file_exists()` - Verify file exists
- `mock_ssh()` - Mock SSH for testing
- `mock_tmux()` - Mock tmux for testing

---

## Running Tests

### Prerequisites

Install bats:

```bash
# Ubuntu/Debian
sudo apt install bats

# macOS
brew install bats-core

# From source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

### Run All Tests

```bash
# From repository root
bats tests/

# With verbose output
bats tests/ --verbose

# With timing
bats tests/ --timing
```

### Run Specific Test Files

```bash
# Single file
bats tests/unit/test_config_loader.bats

# Multiple files
bats tests/unit/*.bats

# Integration tests only
bats tests/integration/
```

### Run Individual Tests

```bash
# Run specific test by name
bats tests/unit/test_config_loader.bats --filter "config loader exists"

# Run tests matching pattern
bats tests/ --filter "config"
```

---

## Writing Tests

### Basic Test Structure

```bash
#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "description of what you're testing" {
    # Arrange
    local input="value"

    # Act
    run command_to_test "$input"

    # Assert
    assert_success
    assert_output_contains "expected"
}
```

### Example Unit Test

```bash
@test "config loader loads variables" {
    # Setup
    mkdir -p "$TEST_TEMP_DIR/config"
    cat > "$TEST_TEMP_DIR/config/philaunch.conf" << EOF
PHILAUNCH_USER="testuser"
PHILAUNCH_HOST="192.168.1.100"
EOF

    # Test
    export PHILAUNCH_HOME="$TEST_TEMP_DIR"
    run bash -c "source config/load-config.sh && echo \$PHILAUNCH_USER"

    # Verify
    assert_success
    assert_output_contains "testuser"
}
```

### Example Integration Test

```bash
@test "complete setup and usage workflow" {
    # Create config
    mkdir -p "$TEST_TEMP_DIR/config"
    cp config/philaunch.conf.example "$TEST_TEMP_DIR/config/philaunch.conf"

    # Run setup
    run bash setup.sh --non-interactive

    # Verify setup succeeded
    assert_success
    assert_file_exists "$TEST_TEMP_DIR/config/philaunch.conf"

    # Test usage
    run bash automation/home-control.sh status
    assert_success
}
```

### Testing Scripts with Config

```bash
@test "script uses config variables" {
    # Setup config
    setup_test_env

    # Create script that uses config
    cat > "$TEST_TEMP_DIR/test.sh" << 'EOF'
#!/bin/bash
source "${PHILAUNCH_HOME}/config/load-config.sh"
echo "$PHILAUNCH_USER"
EOF

    # Test
    export PHILAUNCH_HOME="$TEST_TEMP_DIR"
    run bash "$TEST_TEMP_DIR/test.sh"

    assert_success
    assert_output_contains "testuser"
}
```

### Mocking Commands

```bash
@test "script works with mocked SSH" {
    setup_test_env
    mock_ssh  # Replace ssh with mock

    # Script that uses SSH
    run bash automation/remote-script.sh

    # Should succeed even without real SSH
    assert_success
    assert_output_contains "Mock SSH"
}
```

---

## CI/CD Integration

Tests run automatically in GitHub Actions on every push and pull request.

### Workflow Jobs

1. **ShellCheck** - Lints all .sh files
2. **Security Scan** - Checks for secrets with TruffleHog and GitLeaks
3. **Syntax Validation** - Validates bash syntax
4. **Test Suite** - Runs all bats tests
5. **Dependency Check** - Verifies required tools
6. **Config Validation** - Checks config system

### Viewing CI Results

```bash
# Check status locally before pushing
./scripts/check-dependencies.sh
bats tests/
shellcheck **/*.sh
```

### CI Configuration

See `.github/workflows/ci.yml` for the complete workflow.

---

## Test Coverage

### Current Coverage

Unit Tests:
- ✅ Config loader
- ✅ Setup wizard
- ✅ Automation scripts

Integration Tests:
- ✅ Config workflow
- ⏳ Full setup wizard (requires interactive testing)
- ⏳ SSH operations (requires SSH server)

### Adding Coverage

To add test coverage for a new script:

1. Create test file: `tests/unit/test_<script_name>.bats`
2. Load test helper: `load ../test_helper`
3. Write tests for key functionality
4. Run tests: `bats tests/unit/test_<script_name>.bats`
5. Commit tests with the script

---

## Troubleshooting

### Tests Fail Locally But Pass in CI

**Cause:** Environment differences

**Solution:**
```bash
# Check your environment
./scripts/check-dependencies.sh

# Ensure clean state
rm -rf config/philaunch.conf

# Run in isolated environment
docker run -v $(pwd):/workspace -w /workspace ubuntu:latest bash -c "apt update && apt install -y bats && bats tests/"
```

### "command not found: bats"

**Solution:**
```bash
# Install bats
sudo apt install bats  # Ubuntu/Debian
brew install bats-core  # macOS
```

### Tests Timeout

**Cause:** Background processes not cleaned up

**Solution:**
- Ensure `teardown()` function kills all spawned processes
- Use `timeout` command for long-running tests:
  ```bash
  run timeout 5 command_that_might_hang
  ```

### Mock Not Working

**Cause:** PATH not set correctly

**Solution:**
```bash
# In test, ensure mocks are first in PATH
mock_ssh
export PATH="${TEST_TEMP_DIR}/bin:$PATH"
```

### "Permission denied" Errors

**Cause:** Test files not executable

**Solution:**
```bash
# Make test files executable
chmod +x tests/**/*.bats

# Make scripts being tested executable
chmod +x *.sh **/*.sh
```

---

## Best Practices

### DO ✅

- Use `setup()` and `teardown()` for test isolation
- Test both success and failure cases
- Use descriptive test names
- Mock external dependencies (SSH, Docker, etc.)
- Clean up temp files in teardown
- Use `run` to capture command output
- Assert on exit codes and output

### DON'T ❌

- Don't modify global system state
- Don't rely on specific user environment
- Don't use absolute paths (use `$PHILAUNCH_ROOT`)
- Don't skip teardown (causes test pollution)
- Don't test implementation details
- Don't make tests dependent on each other

---

## Examples

### Complete Test File Example

```bash
#!/usr/bin/env bats
# Tests for my-script.sh

load ../test_helper

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "script exists and is executable" {
    [ -f "$PHILAUNCH_ROOT/my-script.sh" ]
    [ -x "$PHILAUNCH_ROOT/my-script.sh" ]
}

@test "script has valid syntax" {
    run bash -n "$PHILAUNCH_ROOT/my-script.sh"
    assert_success
}

@test "script shows help with no args" {
    run bash "$PHILAUNCH_ROOT/my-script.sh"
    assert_success
    assert_output_contains "Usage"
}

@test "script processes input correctly" {
    run bash "$PHILAUNCH_ROOT/my-script.sh" --test-arg
    assert_success
    assert_output_contains "expected output"
}
```

---

## Resources

- [Bats Documentation](https://bats-core.readthedocs.io/)
- [Bats GitHub](https://github.com/bats-core/bats-core)
- [ShellCheck](https://www.shellcheck.net/)
- [PhiLaunch CI Workflow](../.github/workflows/ci.yml)

---

**Last Updated:** 2025-11-12
**Maintained By:** PhiLaunch Contributors
