# Shell functions to act as a virtualenvwrapper replacement for uv
#
# Author: Jan Lebert
# License: MIT
# Project home page: https://github.com/sitic/uv-virtualenvwrapper
#
# Usage:
#   source uv-virtualenvwrapper.sh
#
#   mkvirtualenv [uv_venv_args...] [-a PATH] <name>
#   workon <name>
#   rmvirtualenv <name>
#   lsvirtualenv
#   cdproject
#   cdvirtualenv
#   cdsitepackages
#   updateproject
#

export WORKON_HOME="${WORKON_HOME:-$HOME/.virtualenvs}"

# Windows use 'Scripts' instead of 'bin'
VIRTUALENVWRAPPER_ENV_BIN_DIR="bin"
if [ "${OS:-}" = "Windows_NT" ] && ([ "${MSYSTEM:-}" = "MINGW32" ] || [ "${MSYSTEM:-}" = "MINGW64" ])
then
    # Only assign this for msys, cygwin uses 'bin'
    VIRTUALENVWRAPPER_ENV_BIN_DIR="Scripts"
fi

_mkdir_workon_home() {
  if ! mkdir -p "$WORKON_HOME" 2>/dev/null; then
    echo "Error: Cannot create or access WORKON_HOME directory: $WORKON_HOME" >&2
    return 1
  fi
}

_validate_venv_name() {
  local venv_name="$1"
  
  if [ -z "$venv_name" ]; then
    echo "Error: Environment name cannot be empty" >&2
    return 1
  fi
  
  # Check for path separators and other problematic characters
  case "$venv_name" in
    */*|*\\*|*..*|*\ *|*$'\t'*|*$'\n'*)
      echo "Error: Environment name '$venv_name' contains invalid characters" >&2
      echo "Environment names cannot contain: / \\ .. spaces tabs or newlines" >&2
      return 1
      ;;
  esac
  
  return 0
}

workon() {
  if [ $# -eq 0 ]; then
    lsvirtualenv
    return 0
  fi

  local venv_name="$1"
  
  if ! _validate_venv_name "$venv_name"; then
    return 1
  fi
  
  local venv_path="$WORKON_HOME/$venv_name"

  if [ ! -d "$venv_path" ]; then
    echo "Virtualenv '$venv_name' not found in $WORKON_HOME" >&2
    return 1
  fi

  # Check if .project file exists
  if [ ! -f "$venv_path/.project" ]; then
    echo "Error: No .project file found for virtualenv '$venv_name'" >&2
    return 1
  fi

  local project_path
  project_path=$(cat "$venv_path/.project")

  if [ ! -d "$project_path" ]; then
    echo "Error: Project directory '$project_path' does not exist" >&2
    return 1
  fi

  # Change to project directory
  cd "$project_path"

  export UV_VIRTUALENV_PROJECT_NAME="$venv_name"

  # Check if .venv exists in project root and activate it
  local venv_in_project="$project_path/.venv"
  if [ -d "$venv_in_project" ]; then
    if [ -f "$venv_in_project/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate" ]; then
      source "$venv_in_project/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate"
    else
      echo "Error: .venv directory found but activation script missing" >&2
      return 1
    fi
  fi
}

mkvirtualenv() {
  if [ $# -ne 1 ]; then
    echo "Usage: mkvirtualenv <name>" >&2
    return 1
  fi

  local venv_name="$1"
  
  if ! _validate_venv_name "$venv_name"; then
    return 1
  fi
  
  local venv_path="$WORKON_HOME/$venv_name"
  local project_path=$(pwd)

  if [ -d "$venv_path" ]; then
    echo "Virtualenv '$venv_name' already exists" >&2
    return 1
  fi

  _mkdir_workon_home

  # Create only a directory marker instead of actual virtualenv
  if mkdir -p "$venv_path"; then
    # Always write current directory to .project file
    echo "$project_path" > "$venv_path/.project"
    echo "Created virtualenv marker directory '$venv_name'"
    echo "Associated with project: $project_path"
  fi
}

rmvirtualenv() {
  if [ $# -eq 0 ]; then
    echo "Usage: rmvirtualenv <name>" >&2
    return 1
  fi

  local venv_name="$1"
  
  if ! _validate_venv_name "$venv_name"; then
    return 1
  fi
  
  local venv_path="$WORKON_HOME/$venv_name"

  if [ ! -d "$venv_path" ]; then
    echo "Virtualenv '$venv_name' not found" >&2
    return 1
  fi

  # Deactivate if currently active virtualenv matches the one being removed
  if [ -n "$VIRTUAL_ENV" ] && [ "$UV_VIRTUALENV_PROJECT_NAME" = "$venv_name" ]; then
    deactivate
    unset UV_VIRTUALENV_PROJECT_NAME
  fi

  rm -rf "$venv_path" && echo "Removed virtualenv '$venv_name'"
}

lsvirtualenv() {
  find "$WORKON_HOME" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null
}

cdproject() {
  local venv_name
  
  if [ $# -eq 1 ]; then
    # If argument provided, use it as venv name
    venv_name="$1"
    if ! _validate_venv_name "$venv_name"; then
      return 1
    fi
  elif [ -n "$UV_VIRTUALENV_PROJECT_NAME" ]; then
    # If no argument, use currently active project
    venv_name="$UV_VIRTUALENV_PROJECT_NAME"
  else
    echo "Error: No virtualenv is currently active" >&2
    echo "Usage: cdproject [venv_name]" >&2
    return 1
  fi

  local venv_path="$WORKON_HOME/$venv_name"

  if [ ! -f "$venv_path/.project" ]; then
    echo "Error: No .project file found for project '$venv_name'" >&2
    return 1
  fi

  local project_path
  project_path=$(cat "$venv_path/.project")

  if [ ! -d "$project_path" ]; then
    echo "Error: Project directory '$project_path' does not exist" >&2
    return 1
  fi

  cd "$project_path"
}

cdvirtualenv() {
  if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: No virtualenv is currently active" >&2
    return 1
  fi

  cd "$VIRTUAL_ENV"
}

cdsitepackages() {
  if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: No virtualenv is currently active" >&2
    return 1
  fi

  local site_packages_dir
  if [ "${OS:-}" = "Windows_NT" ] && ([ "${MSYSTEM:-}" = "MINGW32" ] || [ "${MSYSTEM:-}" = "MINGW64" ])
  then
    site_packages_dir="$VIRTUAL_ENV/Lib/site-packages"
  else
    site_packages_dir="$VIRTUAL_ENV/lib/python$("$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/python" -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')/site-packages"
  fi

  if [ ! -d "$site_packages_dir" ]; then
    echo "Error: site-packages directory not found" >&2
    return 1
  fi

  cd "$site_packages_dir"
}

updateproject() {
  if [ -z "$UV_VIRTUALENV_PROJECT_NAME" ]; then
    echo "Error: No virtualenv is currently active" >&2
    return 1
  fi

  local venv_name="$UV_VIRTUALENV_PROJECT_NAME"
  local project_path=$(pwd)
  
  # Write current directory to .project file
  echo "$project_path" > "$WORKON_HOME/$venv_name/.project"
  echo "Updated project path for '$venv_name' to: $project_path"
}

# Setup tab completion
__uvvirtualenvwrapper_setup() {
  if [ -n "${BASH:-}" ]; then
    _virtualenvs() {
      local cur="${COMP_WORDS[COMP_CWORD]}"
      COMPREPLY=($(compgen -W "$(lsvirtualenv)" -- "${cur}"))
    }
    complete -o default -F _virtualenvs workon rmvirtualenv cdvirtualenv cdsitepackages cdproject updateproject

  elif [ -n "${ZSH_VERSION:-}" ]; then
    _virtualenvs() {
      local -a venvs
      venvs=($(lsvirtualenv))
      _describe 'virtualenvs' venvs
    }
    compdef _virtualenvs workon rmvirtualenv cdvirtualenv cdsitepackages cdproject updateproject
  fi
}
__uvvirtualenvwrapper_setup