# Skill: Python Packaging

## When to Activate
- Creating Python packages
- pyproject.toml configuration
- Module structure setup
- PyPI distribution
- Entry points and CLI tools

## Modern Python Packaging (2024+)

### pyproject.toml (Complete)
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "phishri"
version = "1.0.0"
description = "AI session continuity protocol"
readme = "README.md"
license = { text = "MIT" }
authors = [{ name = "Stryk91", email = "contact@phishri.dev" }]
requires-python = ">=3.10"
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "click>=8.0",
    "rich>=13.0",
]

[project.optional-dependencies]
dev = ["pytest", "black", "ruff", "mypy"]

[project.scripts]
phishri = "phishri.cli:main"

[project.urls]
Homepage = "https://github.com/Stryk91/PhiSHRI"
Documentation = "https://github.com/Stryk91/PhiSHRI#readme"
Repository = "https://github.com/Stryk91/PhiSHRI.git"

[tool.setuptools.packages.find]
where = ["src"]

[tool.black]
line-length = 88
target-version = ["py310"]

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W"]

[tool.mypy]
python_version = "3.10"
strict = true
```

### Directory Structure
```
phishri/
├── pyproject.toml
├── README.md
├── LICENSE
├── src/
│   └── phishri/
│       ├── __init__.py
│       ├── cli.py
│       ├── core.py
│       └── py.typed        # For type hints
├── tests/
│   ├── __init__.py
│   └── test_core.py
└── .github/
    └── workflows/
        └── publish.yml
```

### __init__.py
```python
"""PhiSHRI - AI session continuity protocol."""
from phishri.core import DoorLoader, Bootstrap

__version__ = "1.0.0"
__all__ = ["DoorLoader", "Bootstrap", "__version__"]
```

### Entry Point CLI
```python
# src/phishri/cli.py
import click
from rich.console import Console

console = Console()

@click.group()
@click.version_option()
def main():
    """PhiSHRI CLI - AI context continuity."""
    pass

@main.command()
@click.argument("door_code")
def read(door_code: str):
    """Read a door by code."""
    # Implementation
    pass

if __name__ == "__main__":
    main()
```

### Build & Publish
```bash
# Build
python -m build

# Test locally
pip install dist/phishri-1.0.0-py3-none-any.whl

# Publish to PyPI
python -m twine upload dist/*

# Publish to TestPyPI first
python -m twine upload --repository testpypi dist/*
```

### GitHub Actions Publish
```yaml
name: Publish to PyPI
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install build twine
      - run: python -m build
      - run: twine upload dist/*
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_TOKEN }}
```
