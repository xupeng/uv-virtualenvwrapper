# uv-virtualenvwrapper
[![PyPI](https://img.shields.io/pypi/v/uv-virtualenvwrapper.svg)](https://pypi.org/project/uv-virtualenvwrapper/)

A lightweight replacement for [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io) when using [uv](https://github.com/astral-sh/uv).

Provides simple management of named Python virtual environments with tab completion support. Virtual environments are stored in `~/.virtualenvs` by default and can be activated with `workon myenv` anywhere in the filesystem. Only basic functions of virtualenvwrapper are replicated, such as `mkvirtualenv`, `rmvirtualenv`, and `workon`.

## Features

- `workon`: Activate virtual environments with tab completion
- `mkvirtualenv`: Create new virtual environments using `uv venv --seed`
- `rmvirtualenv`: Remove virtual environments
- Bash and zsh shell support
- Follows `WORKON_HOME` convention (default: `~/.virtualenvs`)

## Installation

### Method 1: Direct Download

1. **Download the script:**
   Download [uv-virtualenvwrapper.sh](uv-virtualenvwrapper.sh).
2. **Add to shell config:**
    Add
   ```bash
   source /path/to/uv-virtualenvwrapper.sh
   ```
   to your shell configuration file (`~/.bashrc` or `~/.zshrc`).

### Method 2: Install with `uv`
1. **Install [uv-virtualenvwrapper](https://pypi.org/project/uv-virtualenvwrapper/)**:
    ```bash
    uv tool install uv-virtualenvwrapper
    ```
2. **Add to shell config:**
    Add
   ```bash
   source $(which uv-virtualenvwrapper.sh)
   ```
   to your shell configuration file (`~/.bashrc` or `~/.zshrc`).

## Usage

Create a new virtual environment:
```bash
mkvirtualenv myenv
```
which is equivalent to this `uv` command:
```bash
uv venv --seed  ~/.virtualenvs/myenv && source ~/.virtualenvs/myenv/bin/activate
```
All arguments to `mkvirtualenv` are passed to `uv venv --seed`.

Deactivate the virtual environment as usual with:
```bash
deactivate
```

Now you can activate the virtual environment wherever you are in the filesystem with:
```bash
workon myenv
```

## Links
* [GitHub repository](https://github.com/sitic/uv-virtualenvwrapper)
* [PyPI package](https://pypi.org/project/uv-virtualenvwrapper/)