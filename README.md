# uv-virtualenvwrapper

A lightweight replacement for [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) when using [uv](https://github.com/astral-sh/uv).

I want to have global named Python virtual environments that I can activate with a single command using tab completion. I also want to be able to create and remove them easily. I used to use virtualenvwrapper for this, but have switched to uv and wanted to replicate the functionality I used in a lightweight script for bash and zsh.

## Features

- `workon`: Activate virtual environments with tab completion
- `mkvirtualenv`: Create new virtual environments using `uv venv --seed`
- `rmvirtualenv`: Remove virtual environments
- Follows `WORKON_HOME` convention (default: `~/.virtualenvs`)

## Installation

1. **Install uv**  
   Follow the [official installation instructions](https://github.com/astral-sh/uv#installation).

2. **Add to shell config**
   ```bash
   source /path/to/uv-virtualenv-wrapper.sh
   ```
3. **Reload shell**

## Usage

Create a new virtual environment:
```bash
mkvirtualenv --python 3.13 myenv
```
which is equivalent to this `uv` command:
```bash
uv venv --seed --python 3.13 ~/.virtualenvs/myenv && source ~/.virtualenvs/myenv/bin/activate
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
