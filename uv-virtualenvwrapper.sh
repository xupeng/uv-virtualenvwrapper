# Shell functions to act as a virtualenvwrapper replacement for uv
#
# Author: Jan Lebert
# License: MIT
# Project home page: https:://github.com/sitic/uv-virtualenvwrapper
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
  mkdir -p "$WORKON_HOME"
}

workon() {
  if [ $# -eq 0 ]; then
    lsvirtualenv
    return 0
  fi

  local venv_name="$1"
  local venv_path="$WORKON_HOME/$venv_name"

  if [ ! -d "$venv_path" ]; then
    echo "Virtualenv '$venv_name' not found in $WORKON_HOME" >&2
    return 1
  fi

  source "$venv_path/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate"

  # change current directory to the project directory if .project file exists
  if [ -f "$venv_path/.project" ]; then
    local project_path
    project_path=$(cat "$venv_path/.project")
    if [ -d "$project_path" ]; then
      cd "$project_path"
    else
      echo "Warning: Project directory '$project_path' does not exist" >&2
    fi
  fi
}

mkvirtualenv() {
  if [ $# -eq 0 ]; then
    echo "Usage: mkvirtualenv [uv_venv_args...] [-a PATH] <name>" >&2
    return 1
  fi

  _mkdir_workon_home

  local venv_name uv_args project_path
  local args=("$@")
  local i=0
  local last_arg_index=$(( $# - 1 ))

  # iterate over all arguments
  while [ $i -le $last_arg_index ]; do
    case "${args[$i]}" in
      -a)
        if [ $(( i + 1 )) -gt $last_arg_index ]; then
          echo "Error: -a requires a path argument" >&2
          return 1
        fi
        project_path="${args[$(( i + 1 ))]}"
        i=$(( i + 2 ))
        ;;
      *)
        if [ $i -eq $last_arg_index ]; then
          # last argument is the virtual environment name
          venv_name="${args[$i]}"
        else
          # other arguments are uv arguments
          uv_args+=("${args[$i]}")
        fi
        i=$(( i + 1 ))
        ;;
    esac
  done

  if [ -z "$venv_name" ]; then
    echo "Error: Virtual environment name is required" >&2
    return 1
  fi

  local venv_path="$WORKON_HOME/$venv_name"

  if [ -d "$venv_path" ]; then
    echo "Virtualenv '$venv_name' already exists" >&2
    return 1
  fi

  if uv venv "${uv_args[@]}" --seed "$venv_path"; then
    # if a project path is specified, write it to the .project file
    if [ -n "$project_path" ]; then
      echo "$project_path" > "$venv_path/.project"
    fi
    workon "$venv_name"
  fi
}

rmvirtualenv() {
  if [ $# -eq 0 ]; then
    echo "Usage: rmvirtualenv <name>" >&2
    return 1
  fi

  local venv_name="$1"
  local venv_path="$WORKON_HOME/$venv_name"

  if [ ! -d "$venv_path" ]; then
    echo "Virtualenv '$venv_name' not found" >&2
    return 1
  fi

  if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
  fi

  rm -rf "$venv_path" && echo "Removed virtualenv '$venv_name'"
}

lsvirtualenv() {
  find "$WORKON_HOME" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null
}

cdproject() {
  if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: No virtualenv is currently active" >&2
    return 1
  fi

  if [ ! -f "$VIRTUAL_ENV/.project" ]; then
    echo "Error: No .project file found in current virtualenv" >&2
    return 1
  fi

  local project_path
  project_path=$(cat "$VIRTUAL_ENV/.project")

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
    site_packages_dir="$VIRTUAL_ENV/lib/python$(python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')/site-packages"
  fi

  if [ ! -d "$site_packages_dir" ]; then
    echo "Error: site-packages directory not found" >&2
    return 1
  fi

  cd "$site_packages_dir"
}

# Setup tab completion
__uvvirtualenvwrapper_setup() {
  if [ -n "${BASH:-}" ]; then
    _virtualenvs() {
      local cur="${COMP_WORDS[COMP_CWORD]}"
      COMPREPLY=($(compgen -W "$(lsvirtualenv)" -- "${cur}"))
    }
    complete -o default -F _virtualenvs workon rmvirtualenv cdvirtualenv cdsitepackages cdproject

  elif [ -n "${ZSH_VERSION:-}" ]; then
    _virtualenvs() {
      local -a venvs
      venvs=($(lsvirtualenv))
      _describe 'virtualenvs' venvs
    }
    compdef _virtualenvs workon rmvirtualenv cdvirtualenv cdsitepackages cdproject
  fi
}
__uvvirtualenvwrapper_setup