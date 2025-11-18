# Git Hooks for PhiLaunch

This directory contains git hooks to maintain code quality and security.

## Available Hooks

### pre-commit

Runs before each commit to check for:
- Exposed secrets (passwords, API keys, tokens)
- Personal config files (config/philaunch.conf)
- Bash syntax errors
- ShellCheck linting issues

## Installation

### Automatic (Recommended)

Run the installation script:

```bash
./scripts/install-hooks.sh
```

### Manual

Configure git to use this hooks directory:

```bash
git config core.hooksPath .githooks
```

Or symlink individual hooks:

```bash
ln -s ../../.githooks/pre-commit .git/hooks/pre-commit
```

## Usage

Hooks run automatically when you commit:

```bash
git commit -m "your message"
# Pre-commit checks will run automatically
```

### Bypass Hooks (Not Recommended)

If you need to bypass hooks:

```bash
git commit --no-verify -m "your message"
```

**Warning:** Only bypass hooks if you know what you're doing!

## Troubleshooting

### Hook not running

Check that the hook is executable:

```bash
chmod +x .githooks/pre-commit
```

Verify git is configured to use hooks:

```bash
git config core.hooksPath
# Should output: .githooks
```

### ShellCheck not found

Install shellcheck for better linting:

```bash
# Ubuntu/Debian
sudo apt install shellcheck

# macOS
brew install shellcheck
```

The hook will still work without shellcheck, but you'll miss linting checks.

### False positive on secrets

If the hook incorrectly flags something as a secret:

1. Check if it's actually a secret (passwords, keys, tokens)
2. If it's a false positive, you can temporarily bypass with `--no-verify`
3. Consider updating the pattern in the hook to be more specific

## Customization

Edit `.githooks/pre-commit` to customize checks:

- Add new secret patterns
- Adjust shellcheck options
- Add custom validation logic

## CI Integration

These same checks run in CI (GitHub Actions). Catching issues locally with hooks saves time!
