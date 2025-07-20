# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **uv-virtualenvwrapper**, a lightweight replacement for virtualenvwrapper designed to work with [uv](https://github.com/astral-sh/uv), a high-performance Python package manager. The project provides familiar virtualenvwrapper-style commands for managing named virtual environments in a centralized location.

## Architecture

**Core Design**: Single shell script (`uv-virtualenvwrapper.sh`) implementing a project-based virtual environment management system.

**Key Concepts**:
- **Marker directories**: Stored in `$WORKON_HOME` (default: `~/.virtualenvs`) containing project metadata
- **Project association**: Each environment links to a project directory via `.project` files
- **Local virtual environments**: Actual `.venv` directories live in project roots, activated when using `workon`

**Environment Variables**:
- `WORKON_HOME`: Virtual environment storage location
- `UV_VIRTUALENV_PROJECT_NAME`: Tracks currently active environment
- `VIRTUALENVWRAPPER_ENV_BIN_DIR`: Cross-platform binary directory handling

## Core Commands

The main functionality is provided through 7 shell functions:

| Command | Purpose |
|---------|---------|
| `mkvirtualenv <name>` | Creates environment marker and associates with current project |
| `workon [name]` | Activates environment and switches to project directory |
| `rmvirtualenv <name>` | Removes environment marker |
| `lsvirtualenv` | Lists all available environments |
| `cdproject [name]` | Changes to project directory |
| `cdvirtualenv` | Changes to virtual environment directory |
| `cdsitepackages` | Changes to site-packages directory |

## Development Commands

**No traditional build/test commands** - this is a shell script project. Testing is done manually by sourcing the script and testing commands.

**Installation for testing**:
```bash
# Source the script directly
source uv-virtualenvwrapper.sh

# Or install via uv for system-wide testing
uv tool install .
source $(which uv-virtualenvwrapper.sh)
```

## Key Files

- `uv-virtualenvwrapper.sh` - Main implementation (192 lines)
- `pyproject.toml` - Python packaging metadata for uv tool installation
- `README.md` - User documentation and installation instructions

## Cross-Platform Considerations

The script handles Windows MSYS environments by:
- Detecting platform with `uname -o` checks
- Adjusting binary directory paths (`bin` vs `Scripts`)
- Handling different site-packages directory structures

## Recent Major Changes

- **5c3bf67**: Refactored to support project-based `.venv` directories instead of centralized virtual environments
- **b3f5cb3**: Added navigation commands (`cdproject`, `cdvirtualenv`, `cdsitepackages`) and project directory support