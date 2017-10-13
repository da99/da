#!/usr/bin/env zsh
#
#

set -u -e -o pipefail

local +x ACTION="[none]"
if [[ ! -z "$@" ]]; then
  local +x ACTION="$1"; shift
fi

local +x THE_ARGS="$@"
local +x THIS_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
PATH="$PATH:$THIS_DIR/bin"
PATH="$PATH:$THIS_DIR/../my_crystal/bin"

case $ACTION in

  help|--help|-h)
    PATH="$PATH:$THIS_DIR/../my_zsh/bin"
    my_zsh print-help $0 "$@"
    ;;

  *)
    local +x SHELL_SCRIPT="$THIS_DIR/sh/${ACTION}"/_
    if [[ -s  "$SHELL_SCRIPT"  ]]; then
      source "$SHELL_SCRIPT"
      exit 0
    fi

    if [[ -f "$THIS_DIR/progs/bin/$ACTION" ]]; then
      export PATH="$THIS_DIR/progs/bin:$PATH"
      "$THIS_DIR"/progs/bin/$ACTION "$@"
      exit 0
    fi

    # === It's an error:
    echo "!!! Unknown action: $ACTION" 1>&2
    exit 1
    ;;

esac
